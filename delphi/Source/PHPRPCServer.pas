{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPCServer.pas                                         |
|                                                          |
| Release 3.0.2                                            |
| Copyright by Team-PHPRPC                                 |
|                                                          |
| WebSite:  http://www.phprpc.org/                         |
|           http://www.phprpc.net/                         |
|           http://www.phprpc.com/                         |
|           http://sourceforge.net/projects/php-rpc/       |
|                                                          |
| Authors:  Chen fei <cf850118@163.com>                    |
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* PHPRPC Server library.
 *
 * Copyright: Chen fei <cf850118@163.com>
 * Version: 3.0.2
 * LastModified: Oct 30, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */
}

unit PHPRPCServer;

{$I PHPRPC.inc}

interface

uses
  Classes, SysUtils, Variants, Types, SyncObjs, ObjAutoX,
  IOCPTCPServer, IOCPHTTPServer,
  PHPRPC, DHParams;

type

  TLifeCycle = (lcServer, lcSession, lcInvoke);

{$MethodInfo ON}
  TPHPRPCObject = class(TComponent);
  TPHPRPCClass  = class of TPHPRPCObject;
{$MethodInfo OFF}

  TPHPRPCServer = class;

  { TPHPRPCSession }

  TPHPRPCSession = class(THTTPSession)
  public
    FX: Variant;
    FP: Variant;
    FKey: AnsiString;
    FKeyLen: Integer;
    FClassInstances: THashMap;
  public
    constructor Create(Owner: THTTPSessionList; const SessionID: string); override;
    destructor Destroy; override;
    property X: Variant read FX write FX;
    property P: Variant read FP write FP;
    property KeyLen: Integer read FKeyLen write FKeyLen;
    property Key: AnsiString read FKey write FKey;
    property ClassInstances: THashMap read FClassInstances;
  end;

  { TPHPRPCMethod }

  TPHPRPCMethod = class(TPHPObject)
  private
    FOwner:      TPHPRPCServer;
    FMethodInfo: PMethodInfoHeader;
    FMethodName: string;
    FClassRef:   TPHPRPCClass;
    FHasSelf:    Boolean;
    FHasResult:  Boolean;
    FReturnInfo: PReturnInfo;
    FParamInfos: TParamInfoArray;
  public
    constructor Create(Owner: TPHPRPCServer; ClassRef: TPHPRPCClass;
      MethodInfo: PMethodInfoHeader; Prefix: string); reintroduce;
    function Invoke(Params: TVariantDynArray; Session: TPHPRPCSession): Variant;
    function ToString: string; override;
    property HasSelf: Boolean read FHasSelf;
    property HasResult: Boolean read FHasResult;
    property ReturnInfo: PReturnInfo read FReturnInfo;
    property ParamInfos: TParamInfoArray read FParamInfos;
  end;

  { TPHPRPCServer }

  TPHPRPCServer = class(TPHPObject)
  protected
    FDebugMode:       Boolean;
    FMaxKeyLen:       Integer;
    FClassLifes:      THashMap;
    FClassInstances:  THashMap;
    FMethods:         THashMap;
    procedure SetMaxKeyLen(Value: Integer);
    function AddJsSlashes(const Data: AnsiString): string;
    function EncodeString(const Data: AnsiString; const Encode: Boolean): string;
    function EncryptString(const Data: AnsiString; const Key: AnsiString;
      const EncryptMode: Integer; const Level: Byte): AnsiString;
    function DecryptString(const Data: AnsiString; const Key: AnsiString;
      const EncryptMode: Integer; const Level: Byte): AnsiString;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Add(PHPRPCClass: TPHPRPCClass); overload;
    procedure Add(PHPRPCClass: TPHPRPCClass; LifeCycle: TLifeCycle); overload;
    procedure Add(PHPRPCClass: TPHPRPCClass; LifeCycle: TLifeCycle; Prefix: string); overload;
  published
    property DebugMode: Boolean read FDebugMode write FDebugMode default False;
    property MaxKeyLen: Integer read FMaxKeyLen write SetMaxKeyLen default 128;
  end;

implementation

uses
  StrUtils, Math,
  MD5, Base64, BigInt, XXTEA;

type

  { TPHPRPCAdmin }

  TPHPRPCAdmin = class(TPHPRPCObject)
  private
    FOwner: TPHPRPCServer;
    function GetMethodInfo(const MethodName: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    function GetMethodInfos: string;
  end;

{ TPHPRPCSession }

constructor TPHPRPCSession.Create(Owner: THTTPSessionList;
  const SessionID: string);
begin
  inherited Create(Owner, SessionID);
  FClassInstances := THashMap.Create;
end;

destructor TPHPRPCSession.Destroy;
begin
  FClassInstances.Free;
  inherited;
end;  
  
{ TPHPRPCMethod }

constructor TPHPRPCMethod.Create(Owner: TPHPRPCServer; ClassRef: TPHPRPCClass;
  MethodInfo: PMethodInfoHeader; Prefix: string);
var
  ParamInfo: PParamInfo;
  NumParams: Integer;
  I: Integer;
begin
  inherited Create(Owner);
  FOwner := Owner;
  FClassRef := ClassRef;
  FMethodInfo := MethodInfo;
  FMethodName := string(MethodInfo.Name);
  FReturnInfo := Pointer(MethodInfo);
  Inc(Integer(FReturnInfo), SizeOf(TMethodInfoHeader) - SizeOf(ShortString) + 1 + Length(MethodInfo.Name));
  ParamInfo := Pointer(FReturnInfo);
  Inc(Integer(ParamInfo), SizeOf(TReturnInfo));
  NumParams := 0;
  FHasSelf := False;
  FHasResult := False;
{$ifdef DELPHI2010_UP}
  for I := 0 to ReturnInfo^.ParamCount - 1 do
{$else}
  while Integer(ParamInfo) < Integer(Integer(MethodInfo) + MethodInfo^.Len) do
{$endif}
  begin
    Inc(NumParams);
    FHasSelf := FHasSelf or SameText(string(ParamInfo.Name), 'Self'); // do not localize
    FHasResult := FHasResult or (pfResult in ParamInfo.Flags);
    Inc(Integer(ParamInfo), SizeOf(TParamInfo) - SizeOf(ShortString) + 1 +
      Length(PParamInfo(ParamInfo)^.Name));
  {$ifdef DELPHI2010_UP}
    Inc(Integer(ParamInfo), PWord(ParamInfo)^);
  {$endif}
  end;
  SetLength(FParamInfos, NumParams - Ord(FHasSelf) - Ord(FHasResult));
  ParamInfo := Pointer(FReturnInfo);
  Inc(Integer(ParamInfo), SizeOf(TReturnInfo));
  for I := 0 to NumParams - 1 - Ord(FHasResult) do
  begin
    if (I > 0) or not FHasSelf then
    begin
      FParamInfos[I - Ord(FHasSelf)] := ParamInfo;
    end;
    Inc(Integer(ParamInfo), SizeOf(TParamInfo) - SizeOf(ShortString) + 1 +
      Length(PParamInfo(ParamInfo)^.Name));
  {$ifdef DELPHI2010_UP}
    Inc(Integer(ParamInfo), PWord(ParamInfo)^);
  {$endif}
  end;
  FHasResult := FReturnInfo^.ReturnType <> nil;
  FOwner.FMethods[IntToStr(Length(FParamInfos)) + Prefix + FMethodName] := Integer(Self);
end;

function TPHPRPCMethod.Invoke(Params: TVariantDynArray; Session: TPHPRPCSession): Variant;
var
  I: Integer;
  ParamIndexes: TIntegerDynArray;
  LifeCycle: TLifeCycle;
  ClassInstance: TPHPRPCObject;
  ClassName: string;
begin
  SetLength(ParamIndexes, Length(Params));
  for I := 0 to Length(ParamIndexes) - 1 do ParamIndexes[I] := I + 1;
  ClassInstance := nil;
  ClassName := FClassRef.ClassName;
  if FOwner.FClassLifes.ContainsKey(ClassName) then
  begin
    LifeCycle := TLifeCycle(FOwner.FClassLifes[ClassName]);
    case LifeCycle of
      lcServer:
        ClassInstance := TPHPRPCObject(Integer(FOwner.FClassInstances[ClassName]));
      lcSession:
      begin
        if not Session.ClassInstances.ContainsKey(ClassName) then
        begin
          Session.ClassInstances[ClassName] := Integer(FClassRef.Create(Session.ClassInstances));
        end;
        ClassInstance := TPHPRPCObject(Integer(Session.ClassInstances[ClassName]));
      end;
      lcInvoke:
        ClassInstance := FClassRef.Create(nil);
    end;
    if not (ClassInstance is TPHPRPCObject) then
      raise Exception.CreateFmt('Class instance get failed for method %s.', [FMethodName]);
    try
      Result := ObjectInvoke(ClassInstance, FMethodInfo, ParamIndexes, Params);
    finally
      if LifeCycle = lcInvoke then ClassInstance.Free;
    end;
  end;
end;

function TPHPRPCMethod.ToString: string;
const
  CallingArray: array[TCallingConvention] of string = (
    'register', 'cdecl', 'pascal', 'stdcall', 'safecall');
var
  I: Integer;
begin
  Result := IfThen(FHasResult, 'function ', 'procedure ');
  Result := Result + FClassRef.ClassName + '.' + FMethodName;
  if Length(FParamInfos) > 0 then
  begin
    Result := Result + '(';
    for I := 0 to Length(FParamInfos) - 1 do
    begin
      if pfVar in FParamInfos[I]^.Flags then
        Result := Result + 'var '
      else if pfConst in FParamInfos[I]^.Flags then
        Result := Result + 'const '
      else if pfOut in FParamInfos[I]^.Flags then
        Result := Result + 'out ';
      Result := Result + string(FParamInfos[I]^.Name) + ': ' +
        string(FParamInfos[I]^.ParamType^.Name);
      if I <> Length(FParamInfos) - 1 then
        Result := Result + '; ';
    end;
    Result := Result + ')';
  end;
  if HasResult then
  begin
    Result := Result + ': ' + string(FReturnInfo^.ReturnType^.Name);
  end;
  Result := Result + ';';
  if ReturnInfo.CallingConvention <> ccRegister then
    Result := Result + ' ' + CallingArray[ReturnInfo.CallingConvention] + ';'
end;

{ TPHPRPC_Admin }

constructor TPHPRPCAdmin.Create(AOwner: TComponent);
begin
  inherited;
  FOwner := AOwner as TPHPRPCServer;
end;

function TPHPRPCAdmin.GetMethodInfo(const MethodName: string): string;
begin
  if FOwner.FMethods.ContainsKey(MethodName) then
    Result := TPHPRPCMethod(Integer(FOwner.FMethods[MethodName])).ToString;
end;

function TPHPRPCAdmin.GetMethodInfos: string;
var
  I: Integer;
begin
  for I := 0 to FOwner.FMethods.Count - 1 do
    Result := Result + GetMethodInfo(FOwner.FMethods.Keys[I]) + sLineBreak;
end;

{ TPHPRPC_Server }

constructor TPHPRPCServer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMaxKeyLen := 128;
  FClassLifes := THashMap.Create(Self);
  FClassInstances := THashMap.Create(Self);
  FMethods := THashMap.Create(Self);
  Add(TPHPRPCAdmin, lcServer, 'PHPRPC');
end;

procedure TPHPRPCServer.SetMaxKeyLen(Value: Integer);
begin
  if Value > 4096 then Value := 4096;
  if Value < 96 then Value := 96;
  FMaxKeyLen := Value;
end;

procedure TPHPRPCServer.Add(PHPRPCClass: TPHPRPCClass);
begin
  Add(PHPRPCClass, lcServer);
end;

procedure TPHPRPCServer.Add(PHPRPCClass: TPHPRPCClass; LifeCycle: TLifeCycle);
begin
  Add(PHPRPCClass, LifeCycle, '');
end;

procedure TPHPRPCServer.Add(PHPRPCClass: TPHPRPCClass; LifeCycle: TLifeCycle;
  Prefix: string);
var
  I: Integer;
  ClassInfo: TMethodInfoArray;
  ClassName: string;
begin
  ClassName := PHPRPCClass.ClassName;
  if not FClassLifes.ContainsKey(ClassName) then
  begin
    FClassLifes[ClassName] := LifeCycle;
    if LifeCycle = lcServer then
    begin
      FClassInstances[ClassName] := Integer(PHPRPCClass.Create(Self));
    end;
    ClassInfo := GetMethods(PHPRPCClass);
    for I := 0 to Length(ClassInfo) - 1 do
    begin
      TPHPRPCMethod.Create(Self, PHPRPCClass, ClassInfo[I], Prefix);
    end;
  end;
end;

function TPHPRPCServer.AddJsSlashes(const Data: AnsiString): string;
var
  I: Integer;
begin
  for I := 0 to Length(Data) - 1 do
  begin
    if Data[I] in [#0..#31, #34, #39, #92, #127..#255] then
      Result := Result + '\x' + IntToHex(Byte(Data[I]), 2)
    else
      Result := Result + Char(Data[I]);
  end;
end;

function TPHPRPCServer.EncodeString(const Data: AnsiString; const Encode: Boolean): string;
begin
  if Encode then
    Result := Base64.Encode(Data)
  else
    Result := AddJsSlashes(Data);
end;

function TPHPRPCServer.EncryptString(const Data: AnsiString; const Key: AnsiString;
  const EncryptMode: Integer; const Level: Byte): AnsiString;
begin
  if EncryptMode >= level then
    Result := XXTEA.Encrypt(Data, Key)
  else
    Result := Data;
end;

function TPHPRPCServer.DecryptString(const Data: AnsiString;
  const Key: AnsiString; const EncryptMode: Integer;
  const Level: Byte): AnsiString;
begin
  if EncryptMode >= level then
    Result := XXTEA.Decrypt(Data, Key)
  else
    Result := Data;
end;

end.
