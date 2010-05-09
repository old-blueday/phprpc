{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPCClient.pas                                         |
|                                                          |
| Release 3.0.2                                            |
| Copyright by Team-PHPRPC                                 |
|                                                          |
| WebSite:  http://www.phprpc.org/                         |
|           http://www.phprpc.net/                         |
|           http://www.phprpc.com/                         |
|           http://sourceforge.net/projects/php-rpc/       |
|                                                          |
| Authors:  Ma Bingyao <andot@ujn.edu.cn>                  |
|           Chen fei <cf850118@163.com>                    |
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU General Public License (GPL) version    |
| 2.0 as published by the Free Software Foundation and     |
| appearing in the included file LICENSE.                  |
|                                                          |
\**********************************************************/

/* PHPRPC Client Library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 *            Chen fei <cf850118@163.com>
 * Version: 3.0.2
 * LastModified: Oct 30, 2009
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */
}

unit PHPRPCClient;

{$I PHPRPC.inc}

interface

uses
  SysUtils, Classes, Windows, SyncObjs, Variants,
  PHPRPC;

type

  { TPHPRPCError }

  TPHPRPCError = class(TPHPObject)
  private
    FNumber: Integer;
    FMessage: string;
  public
    constructor Create(ErrNo: Integer; const ErrStr: string; AOwner: TComponent = nil); reintroduce; overload;
    class function New(ErrNo: Integer; const ErrStr: string; AOwner: TComponent = nil): Variant; overload;
    function ToString: string; override;
  published
    property Number: Integer read FNumber write FNumber;
    property Message: string read FMessage write FMessage;
  end;

  { TPHPRPCCallbackProcs }

  TPHPRPCCallbackProc1 = procedure(Result: Variant);
  TPHPRPCCallbackProc2 = procedure(Result: Variant; const Args: TVariantDynArray);
  TPHPRPCCallbackProc3 = procedure(Result: Variant; const Args: TVariantDynArray; const Output: AnsiString);
  TPHPRPCCallbackProc4 = procedure(Result: Variant; const Args: TVariantDynArray; const Output: AnsiString; Warning: TPHPRPCError);

  { TPHPRPCCallbackMethods }

  TPHPRPCCallbackMethod1 = procedure(Result: Variant) of object;
  TPHPRPCCallbackMethod2 = procedure(Result: Variant; const Args: TVariantDynArray) of object;
  TPHPRPCCallbackMethod3 = procedure(Result: Variant; const Args: TVariantDynArray; const Output: AnsiString) of object;
  TPHPRPCCallbackMethod4 = procedure(Result: Variant; const Args: TVariantDynArray; const Output: AnsiString; Warning: TPHPRPCError) of object;

  { TPHPRPCCallback }

  TPHPRPCCallback = class(TPHPObject)
  private
    FResult: Variant;
    FArgs: TVariantDynArray;
    FOutput: AnsiString;
    FWarning: TPHPRPCError;
    FCallbackProc1: TPHPRPCCallbackProc1;
    FCallbackProc2: TPHPRPCCallbackProc2;
    FCallbackProc3: TPHPRPCCallbackProc3;
    FCallbackProc4: TPHPRPCCallbackProc4;
    FCallbackMethod1: TPHPRPCCallbackMethod1;
    FCallbackMethod2: TPHPRPCCallbackMethod2;
    FCallbackMethod3: TPHPRPCCallbackMethod3;
    FCallbackMethod4: TPHPRPCCallbackMethod4;
    procedure DoCallback;
  public
    constructor Create(CallbackProc: TPHPRPCCallbackProc1); overload;
    constructor Create(CallbackProc: TPHPRPCCallbackProc2); overload;
    constructor Create(CallbackProc: TPHPRPCCallbackProc3); overload;
    constructor Create(CallbackProc: TPHPRPCCallbackProc4); overload;
    constructor Create(CallbackMethod: TPHPRPCCallbackMethod1); overload;
    constructor Create(CallbackMethod: TPHPRPCCallbackMethod2); overload;
    constructor Create(CallbackMethod: TPHPRPCCallbackMethod3); overload;
    constructor Create(CallbackMethod: TPHPRPCCallbackMethod4); overload;
    class function New(CallbackProc: TPHPRPCCallbackProc1): Variant; overload;
    class function New(CallbackProc: TPHPRPCCallbackProc2): Variant; overload;
    class function New(CallbackProc: TPHPRPCCallbackProc3): Variant; overload;
    class function New(CallbackProc: TPHPRPCCallbackProc4): Variant; overload;
    class function New(CallbackMethod: TPHPRPCCallbackMethod1): Variant; overload;
    class function New(CallbackMethod: TPHPRPCCallbackMethod2): Variant; overload;
    class function New(CallbackMethod: TPHPRPCCallbackMethod3): Variant; overload;
    class function New(CallbackMethod: TPHPRPCCallbackMethod4): Variant; overload;
  end;

 { TPHPRPCClient }

  TPHPRPCClient = class(TPHPObject)
  protected
    FURL: string;
    FKey: AnsiString;
    FKeyLength: Integer;
    FEncryptMode: Integer;
    FKeyExchanged: Boolean;
    FCharset: string;
    FOutput: AnsiString;
    FWarning: TPHPRPCError;
    FVersion: Currency;
    FStringAsByteArray: Boolean;
    FCS: TCriticalSection;
    FTimeout: Integer;
    FClientID: string;
    procedure SetKeyLength(Value: Integer);
    procedure SetEncryptMode(Value: Integer);
    procedure SetCharset(const Value: string);
    procedure SetURL(const Value: string);
    function KeyExchange(EncryptMode: Integer): Integer;
    function Decrypt(const Data: AnsiString; Level: Integer; EncryptMode: Integer): AnsiString;
    function Encrypt(const Data: AnsiString; Level: Integer; EncryptMode: Integer): AnsiString;
    function DoFunction(var Dest: TVarData; const Name: string; const Arguments: TVarDataArray): Boolean; override;
  protected
    procedure Initialize; virtual;
    function Post(const ReqStr: AnsiString): THashMap; virtual; abstract;
  public
    constructor Create(); overload; override;
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(const AURL: string; AOwner: TComponent = nil); reintroduce; overload;
    destructor Destroy; override;
    class function New(const AURL: string; AOwner: TComponent = nil): Variant; overload;
    function UseService(const AURL: string): Variant; overload;
    function Invoke(const FuncName: string; const Args: TVariantDynArray; ByRef: Boolean = False): Variant; overload;
    procedure Invoke(const FuncName: string; const Args: TVariantDynArray; Callback: TPHPRPCCallback; ByRef: Boolean; EncryptMode: Integer); overload;
    function Invoke(const FuncName: string; const Args: TVariantDynArray; ByRef: Boolean; EncryptMode: Integer): THashMap; overload;
    property Output: AnsiString read FOutput;
    property Warning: TPHPRPCError read FWarning;
  published
    property Name stored True;
    property Tag stored True;
    property KeyLength: Integer read FKeyLength write SetKeyLength default 128;
    property EncryptMode: Integer read FEncryptMode write SetEncryptMode default 0;
    property Charset: string read FCharset write SetCharset;
    property Timeout: Integer read FTimeout write FTimeout default 30000;
    property StringAsByteArray: Boolean read FStringAsByteArray write FStringAsByteArray default False;
  end;

  { TAsyncInvokeThread }

  TAsyncInvokeThread = class(TThread)
  private
    FClient: TPHPRPCClient;
    FFuncName: string;
    FArgs: TVariantDynArray;
    FCallback: TPHPRPCCallback;
    FByRef: Boolean;
    FEncryptMode: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(Client: TPHPRPCClient; const FuncName: string;
      const Args: TVariantDynArray; Callback: TPHPRPCCallback; ByRef: Boolean;
      EncryptMode: Integer);
  end;

function Split(const Source: string; const Substr: string = #$0D#$0A): TStringList;

implementation

uses
  StrUtils, Math,
  Base64, BigInt, MD5, XXTEA;

var
  PHPRPC_ClientID: Integer = 0;

function Split(const Source: string; const Substr: string = #$0D#$0A): TStringList;
var
  Temp: string;
  I: Integer;
begin
  Result := TStringList.Create;
  if Source = '' then exit;
  Temp := Source;
  I := Pos(Substr, Temp);
  while I <> 0 do begin
   Result.Add(Copy(Temp, 0, I - 1));
   Delete(Temp, 1, I + Length(Substr) - 1);
   I := Pos(Substr, Temp);
  end;
  Result.Add(Temp);
end;

{ TPHPRPCError }

constructor TPHPRPCError.Create(ErrNo: Integer; const ErrStr: string; AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNumber := ErrNo;
  FMessage := ErrStr;
end;

class function TPHPRPCError.New(ErrNo: Integer; const ErrStr: string; AOwner: TComponent): Variant;
begin
  Result := Self.Create(ErrNo, ErrStr, AOwner).ToVariant;
end;

function TPHPRPCError.ToString: string;
begin
  Result := IntToStr(FNumber) + ':' + FMessage;
end;

{ TPHPRPCCallback }

constructor TPHPRPCCallback.Create(CallbackProc: TPHPRPCCallbackProc1);
begin
  inherited Create;
  FCallbackProc1 := CallbackProc;
  FCallbackProc2 := nil;
  FCallbackProc3 := nil;
  FCallbackProc4 := nil;
  FCallbackMethod1 := nil;
  FCallbackMethod2 := nil;
  FCallbackMethod3 := nil;
  FCallbackMethod4 := nil;
end;

constructor TPHPRPCCallback.Create(CallbackProc: TPHPRPCCallbackProc2);
begin
  inherited Create;
  FCallbackProc1 := nil;
  FCallbackProc2 := CallbackProc;
  FCallbackProc3 := nil;
  FCallbackProc4 := nil;
  FCallbackMethod1 := nil;
  FCallbackMethod2 := nil;
  FCallbackMethod3 := nil;
  FCallbackMethod4 := nil;
end;

constructor TPHPRPCCallback.Create(CallbackProc: TPHPRPCCallbackProc3);
begin
  inherited Create;
  FCallbackProc1 := nil;
  FCallbackProc2 := nil;
  FCallbackProc3 := CallbackProc;
  FCallbackProc4 := nil;
  FCallbackMethod1 := nil;
  FCallbackMethod2 := nil;
  FCallbackMethod3 := nil;
  FCallbackMethod4 := nil;
end;

constructor TPHPRPCCallback.Create(CallbackProc: TPHPRPCCallbackProc4);
begin
  inherited Create;
  FCallbackProc1 := nil;
  FCallbackProc2 := nil;
  FCallbackProc3 := nil;
  FCallbackProc4 := CallbackProc;
  FCallbackMethod1 := nil;
  FCallbackMethod2 := nil;
  FCallbackMethod3 := nil;
  FCallbackMethod4 := nil;
end;

constructor TPHPRPCCallback.Create(CallbackMethod: TPHPRPCCallbackMethod1);
begin
  inherited Create;
  FCallbackProc1 := nil;
  FCallbackProc2 := nil;
  FCallbackProc3 := nil;
  FCallbackProc4 := nil;
  FCallbackMethod1 := CallbackMethod;
  FCallbackMethod2 := nil;
  FCallbackMethod3 := nil;
  FCallbackMethod4 := nil;
end;

constructor TPHPRPCCallback.Create(CallbackMethod: TPHPRPCCallbackMethod2);
begin
  inherited Create;
  FCallbackProc1 := nil;
  FCallbackProc2 := nil;
  FCallbackProc3 := nil;
  FCallbackProc4 := nil;
  FCallbackMethod1 := nil;
  FCallbackMethod2 := CallbackMethod;
  FCallbackMethod3 := nil;
  FCallbackMethod4 := nil;
end;

constructor TPHPRPCCallback.Create(CallbackMethod: TPHPRPCCallbackMethod3);
begin
  inherited Create;
  FCallbackProc1 := nil;
  FCallbackProc2 := nil;
  FCallbackProc3 := nil;
  FCallbackProc4 := nil;
  FCallbackMethod1 := nil;
  FCallbackMethod2 := nil;
  FCallbackMethod3 := CallbackMethod;
  FCallbackMethod4 := nil;
end;

constructor TPHPRPCCallback.Create(CallbackMethod: TPHPRPCCallbackMethod4);
begin
  inherited Create;
  FCallbackProc1 := nil;
  FCallbackProc2 := nil;
  FCallbackProc3 := nil;
  FCallbackProc4 := nil;
  FCallbackMethod1 := nil;
  FCallbackMethod2 := nil;
  FCallbackMethod3 := nil;
  FCallbackMethod4 := CallbackMethod;
end;

class function TPHPRPCCallback.New(CallbackProc: TPHPRPCCallbackProc1): Variant;
begin
  Result := Self.Create(CallbackProc).ToVariant;
end;

class function TPHPRPCCallback.New(CallbackProc: TPHPRPCCallbackProc2): Variant;
begin
  Result := Self.Create(CallbackProc).ToVariant;
end;

class function TPHPRPCCallback.New(CallbackProc: TPHPRPCCallbackProc3): Variant;
begin
  Result := Self.Create(CallbackProc).ToVariant;
end;

class function TPHPRPCCallback.New(CallbackProc: TPHPRPCCallbackProc4): Variant;
begin
  Result := Self.Create(CallbackProc).ToVariant;
end;

class function TPHPRPCCallback.New(CallbackMethod: TPHPRPCCallbackMethod1): Variant;
begin
  Result := Self.Create(CallbackMethod).ToVariant;
end;

class function TPHPRPCCallback.New(CallbackMethod: TPHPRPCCallbackMethod2): Variant;
begin
  Result := Self.Create(CallbackMethod).ToVariant;
end;

class function TPHPRPCCallback.New(CallbackMethod: TPHPRPCCallbackMethod3): Variant;
begin
  Result := Self.Create(CallbackMethod).ToVariant;
end;

class function TPHPRPCCallback.New(CallbackMethod: TPHPRPCCallbackMethod4): Variant;
begin
  Result := Self.Create(CallbackMethod).ToVariant;
end;

procedure TPHPRPCCallback.DoCallback;
begin
  if @FCallbackProc1 <> nil then
    FCallbackProc1(FResult)
  else if @FCallbackProc2 <> nil then
    FCallbackProc2(FResult, FArgs)
  else if @FCallbackProc3 <> nil then
    FCallbackProc3(FResult, FArgs, FOutput)
  else if @FCallbackProc4 <> nil then
    FCallbackProc4(FResult, FArgs, FOutput, FWarning)
  else if @FCallbackMethod1 <> nil then
    FCallbackMethod1(FResult)
  else if @FCallbackMethod2 <> nil then
    FCallbackMethod2(FResult, FArgs)
  else if @FCallbackMethod3 <> nil then
    FCallbackMethod3(FResult, FArgs, FOutput)
  else if @FCallbackMethod4 <> nil then
    FCallbackMethod4(FResult, FArgs, FOutput, FWarning);
  FreeAndNil(FWarning);
  Free;
end;

{ TPHPRPCClient }

constructor TPHPRPCClient.Create;
begin
  Create('');
end;

constructor TPHPRPCClient.Create(AOwner: TComponent);
begin
  Create('', AOwner);
end;

constructor TPHPRPCClient.Create(const AURL: string; AOwner: TComponent);
begin
  inherited Create(AOwner);
  FClientID := 'Delphi' + IntToStr(Random(MaxInt)) + FormatDateTime('yyyymmddhhnnss', Now) + IntToStr(PHPRPC_ClientID);
  Inc(PHPRPC_ClientID);
  SetURL(AURL);
  FOutput := '';
  FWarning := nil;
  FVersion := 3.0;
  FCS := TCriticalSection.Create;
  Initialize;
end;

destructor TPHPRPCClient.Destroy;
begin
  FreeAndNil(FWarning);
  FreeAndNil(FCS);
  inherited;
end;

function TPHPRPCClient.Encrypt(const Data: AnsiString; Level: Integer; EncryptMode: Integer): AnsiString;
begin
  if (FKey <> '') and (EncryptMode >= Level) then
    Result := XXTEA.Encrypt(Data, FKey)
  else
    Result := Data;
end;

function TPHPRPCClient.Decrypt(const Data: AnsiString; Level: Integer; EncryptMode: Integer): AnsiString;
begin
  if (FKey <> '') and (EncryptMode >= Level) then
    Result := XXTEA.Decrypt(Data, FKey)
  else
    Result := Data;
end;

function TPHPRPCClient.Invoke(const FuncName: string;
  const Args: TVariantDynArray; ByRef: Boolean): Variant;
var
  Data: THashMap;
begin
  Data := Invoke(FuncName, Args, ByRef, FEncryptMode);
  FreeAndNil(FWarning);
  if (Data.ContainsKey('Warning')) then
    FWarning := TPHPRPCError(TPHPRPCError.FromVariant(Data['Warning']));
  if (Data.ContainsKey('Output')) then
    FOutput := AnsiString(Data['Output'])
  else
    FOutput := '';
  if (Data.ContainsKey('Result')) then
    Result := Data['Result'];
  Data.Free;
end;

procedure TPHPRPCClient.Invoke(const FuncName: string;
  const Args: TVariantDynArray; Callback: TPHPRPCCallback; ByRef: Boolean;
  EncryptMode: Integer);
begin
  TAsyncInvokeThread.Create(Self, FuncName, Args, Callback, ByRef, EncryptMode);
end;

procedure TPHPRPCClient.Initialize;
begin
//
end;

function TPHPRPCClient.Invoke(const FuncName: string;
  const Args: TVariantDynArray; ByRef: Boolean;
  EncryptMode: Integer): THashMap;
var
  I, Errno: Integer;
  RequestBody: TStringBuffer;
  Data, Arguments: THashMap;
begin
  Result := THashMap.Create(Self);
  try
    FCS.Acquire;
    EncryptMode := KeyExchange(EncryptMode);
    FCS.Release;
    RequestBody := TStringBuffer.Create;
    try
      RequestBody.WriteString('phprpc_func=');
      RequestBody.WriteString(AnsiString(FuncName));
      if (Args <> nil) and (Length(Args) > 0) then
      begin
        RequestBody.WriteString('&phprpc_args=');
        RequestBody.WriteString(AnsiString(AnsiReplaceStr(Base64.Encode(Encrypt(Serialize(Args), 1, EncryptMode)), '+', '%2B')));
      end;
      RequestBody.WriteString('&phprpc_encrypt=');
      RequestBody.WriteString(AnsiString(IntToStr(EncryptMode)));
      if not ByRef then
        RequestBody.WriteString('&phprpc_ref=false');
      Data := Post(RequestBody.{$IFDEF DELPHI2009_UP}ToAnsiString{$ELSE}ToString{$ENDIF});
    finally
      FreeAndNil(RequestBody);
    end;
    try
      Errno := Data['phprpc_errno'];
      if Errno <> 0 then
        Result['Warning'] := TPHPRPCError.New(Errno, Data['phprpc_errstr'], Self);
      if Data.ContainsKey('phprpc_output') then
      begin
        if FVersion >= 3 then
          Result['Output'] := Decrypt(AnsiString(Data['phprpc_output']), 3, EncryptMode)
        else
          Result['Output'] := Data['phprpc_output'];
      end;
      if Data.ContainsKey('phprpc_result') then
      begin
        if Data.ContainsKey('phprpc_args') then
        begin
          Arguments := THashMap(PHPObject(UnSerialize(Decrypt(AnsiString(Data['phprpc_args']), 1, EncryptMode), FStringAsByteArray)));
          try
            for I := 0 to Math.Min(Length(Args), Arguments.Count) - 1 do
              Args[I] := Arguments[I];
          finally
            FreeAndNil(Arguments);
          end;
        end;
        Result['Result'] := UnSerialize(Decrypt(AnsiString(Data['phprpc_result']), 2, EncryptMode), FStringAsByteArray);
      end
      else
        Result['Result'] := Result['Warning'];
    finally
      FreeAndNil(Data);
    end;
  except
    on E: Exception do
    begin
      Result['Warning'] := TPHPRPCError.New(1, E.Message, Self);
      Result['Result'] := Result['Warning'];
    end;
  end;
end;

function TPHPRPCClient.KeyExchange(EncryptMode: Integer): Integer;
var
  Data, Encrypt: THashMap;
  X, Y, P, G: Variant;
  K: AnsiString;
  I, N: Integer;
begin
  if (FKey <> '') or (EncryptMode = 0) then
  begin
    Result := EncryptMode;
    Exit;
  end;
  if (FKey = '') and FKeyExchanged then
  begin
    Result := 0;
    Exit;
  end;
  Data := nil;
  Encrypt := nil;
  try
    Data := Post('phprpc_encrypt=true&phprpc_keylen=' + AnsiString(IntToStr(FKeyLength)));
    if Data.ContainsKey('phprpc_keylen') then
      FKeyLength := Data['phprpc_keylen']
    else
      FKeyLength := 128;
    if Data.ContainsKey('phprpc_encrypt') then
    begin
      try
        Encrypt := THashMap(PHPObject(UnSerialize(AnsiString(Data['phprpc_encrypt']), False)));
        X := Rand(FKeyLength - 1, True);
        Y := BigInteger(VarToStr(Encrypt['y']));
        P := BigInteger(VarToStr(Encrypt['p']));
        G := BigInteger(VarToStr(Encrypt['g']));
      finally
        FreeAndNil(Encrypt);
      end;
      if (FKeyLength = 128) then
      begin
        SetLength(FKey, 16);
        FillChar(PAnsiChar(FKey)^, 16, 0);
        K := BigIntToBinStr(PowMod(Y, X, P));
        N := Min(Length(K), 16);
        for I := 0 to N - 1 do FKey[16 - I] := K[N - I];
      end
      else FKey := RawMD5(BigIntToString(PowMod(Y, X, P)));
      FreeAndNil(Data);
      Data := Post('phprpc_encrypt=' + AnsiString(PowMod(G, X, P)));
    end
    else
    begin
      FKey := '';
      FKeyExchanged := True;
      EncryptMode := 0;
    end;
  finally
    FreeAndNil(Data);
  end;
  Result := EncryptMode;
end;

procedure TPHPRPCClient.SetCharset(const Value: string);
begin
  FCharset := Value;
end;

procedure TPHPRPCClient.SetEncryptMode(Value: Integer);
begin
  if (Value >= 0) and (Value <= 3) then
    FEncryptMode := Value
  else
    FEncryptMode := 0;
end;

procedure TPHPRPCClient.SetKeyLength(Value: Integer);
begin
  if FKey = '' then FKeyLength := Value;
end;

procedure TPHPRPCClient.SetURL(const Value: string);
begin
  FURL := Value;
  if Pos('?', FURL) > 0 then
    FURL := FURL + '&phprpc_id=' + FClientID
  else
    FURL := FURL + '?phprpc_id=' + FClientID;
  FKey := '';
  FKeyLength := 128;
  FEncryptMode := 0;
  FKeyExchanged := False;
  FCharset := 'UTF-8';
end;

function TPHPRPCClient.UseService(const AURL: string): Variant;
begin
  SetURL(AURL);
  Result := ToVariant;
end;

function TPHPRPCClient.DoFunction(var Dest: TVarData; const Name: string;
  const Arguments: TVarDataArray): Boolean;
var
  Args: TVariantDynArray;
  L: Integer;
  Callback: TPHPRPCCallback;
  ByRef: Boolean;
  EncryptMode: Integer;
begin
  Args := Pointer(Arguments);
  L := Length(Args);
  if (L = 1) and (Arguments[0].VType = varError) then begin
    SetLength(Args, 0);
    L := 0;
  end;
  if (L > 0) and VarIsPHPObject(Args[L - 1], TPHPRPCCallback) then begin
    Callback := TPHPRPCCallback(PHPObject(Args[L - 1]));
    SetLength(Args, L - 1);
    Invoke(Name, Args, Callback, False, FEncryptMode);
    Variant(Dest) := Null;
  end
  else if (L > 1) and VarIsPHPObject(Args[L - 2], TPHPRPCCallback) then begin
    Callback := TPHPRPCCallback(PHPObject(Args[L - 2]));
    ByRef := Args[L - 1];
    SetLength(Args, L - 2);
    Invoke(Name, Args, Callback, ByRef, FEncryptMode);
    Variant(Dest) := Null;
  end
  else if (L > 2) and VarIsPHPObject(Args[L - 3], TPHPRPCCallback) then begin
    Callback := TPHPRPCCallback(PHPObject(Args[L - 3]));
    ByRef := Args[L - 2];
    EncryptMode := Args[L - 1];
    SetLength(Args, L - 3);
    Invoke(Name, Args, Callback, ByRef, EncryptMode);
    Variant(Dest) := Null;
  end
  else
    Variant(Dest) := Invoke(Name, Args, False);
  Result := True;
end;

class function TPHPRPCClient.New(const AURL: string;
  AOwner: TComponent): Variant;
begin
  Result := Self.Create(AURL, AOwner).ToVariant;
end;

{ TAsyncInvokeThread }

constructor TAsyncInvokeThread.Create(Client: TPHPRPCClient;
  const FuncName: string; const Args: TVariantDynArray;
  Callback: TPHPRPCCallback; ByRef: Boolean; EncryptMode: Integer);
begin
  inherited Create(False);
  FClient := Client;
  FFuncName := FuncName;
  FArgs := Args;
  FCallback := Callback;
  FByRef := ByRef;
  FEncryptMode := EncryptMode;
end;

procedure TAsyncInvokeThread.Execute;
var
  Data: THashMap;
begin
  Data := FClient.Invoke(FFuncName, FArgs, FByRef, FEncryptMode);
  FCallback.FArgs := FArgs;
  FreeAndNil(FCallback.FWarning);
  if (Data.ContainsKey('Warning')) then
    FCallback.FWarning := TPHPRPCError(TPHPRPCError.FromVariant(Data['Warning']));
  if (Data.ContainsKey('Output')) then
    FCallback.FOutput := AnsiString(Data['Output'])
  else
    FCallback.FOutput := '';
  FCallback.FResult := Data['Result'];
  Data.Free;
  Synchronize(FCallback.DoCallback);
end;

initialization
  TPHPRPCError.RegisterClass('PHPRPC_Error');
end.
