{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPCIOCPHttpServer.pas                                 |
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
| terms of the GNU General Public License (GPL) version    |
| 2.0 as published by the Free Software Foundation and     |
| appearing in the included file LICENSE.                  |
|                                                          |
\**********************************************************/

/* PHPRPC IOCP HTTP Server library.
 *
 * Copyright: Chen fei <cf850118@163.com>
 * Version: 3.0.2
 * LastModified: Oct 30, 2009
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */
}

unit PHPRPCIOCPHttpServer;

{$I PHPRPC.inc}

interface

uses
  Classes, SysUtils, Variants,
  IOCPTCPServer, IOCPHTTPServer,
  DHParams, PHPRPC, PHPRPCServer;

type

  { TPHPRPCIOCPHttpServer }

  TPHPRPCIOCPHttpServer = class(TPHPRPCServer)
  private
    FHTTPServer:      TIOCPHTTPServer;
    FDefaultPort:     Word;
    FSupportCommands: THTTPCommandTypes;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
  protected
    procedure HandleCommand(Connection: TConnection;
      RequestInfo: TRequestInfo; ResponseInfo: TResponseInfo); virtual;
  published
    property DefaultPort: Word read FDefaultPort write FDefaultPort default 80;
    property SupportCommands: THTTPCommandTypes read FSupportCommands write FSupportCommands default [hcGET, hcPOST];
  end;

procedure Register;

implementation

uses
  StrUtils, Math,
  MD5, Base64, BigInt, XXTEA;

{ TPHPRPCIOCPHttpServer }

constructor TPHPRPCIOCPHttpServer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefaultPort := 80;
  FHTTPServer := TIOCPHTTPServer.Create(Self);
  FHTTPServer.KeepAlive := True;
  FHTTPServer.OnCommandGet := HandleCommand;
  FHTTPServer.OnCommandOther := HandleCommand;
  FSupportCommands := [hcGET, hcPOST];
end;

destructor TPHPRPCIOCPHttpServer.Destroy;
begin
  Stop;
  inherited;
end;

procedure TPHPRPCIOCPHttpServer.Start;
begin
  if not FHTTPServer.Active then
  begin
    FHTTPServer.DefaultPort := FDefaultPort;
    FHTTPServer.Active := True;
  end;
end;

procedure TPHPRPCIOCPHttpServer.Stop;
begin
  if FHTTPServer.Active then
    FHTTPServer.Active := False;
end;

procedure TPHPRPCIOCPHttpServer.HandleCommand(Connection: TConnection; RequestInfo: TRequestInfo; ResponseInfo: TResponseInfo);
const
  SEnd = '";' + sLineBreak;
var
  Buffer: TStringBuffer;
  Session: TPHPRPCSession;

  ErrNo: Integer;
  ErrStr: AnsiString;

  ClientID: string;
  Encode: Boolean;
  ByRef: Boolean;
  EncryptStr: string;
  Encrypt: Boolean;
  EncryptMode: Integer;
  Y: Variant;

  MethodName: string;
  CallBack: AnsiString;

  procedure SendError;
  begin
    Buffer.WriteString('phprpc_errno="' + AnsiString(IntToStr(errno)) + SEnd);
    Buffer.WriteString('phprpc_errstr="' + AnsiString(EncodeString(ErrStr, Encode)) + SEnd);
    Buffer.WriteString('phprpc_output=""');
    Buffer.WriteString(CallBack);
  end;

  function GetArguments: TVariantDynArray;
  var
    I: Integer;
    ArgsString: string;
    ArgsMap: THashMap;
  begin
    ArgsString := RequestInfo.Params.Values['phprpc_args'];
    if ArgsString <> '' then
    begin
      ArgsMap := THashMap(PHPObject(UnSerialize(DecryptString(
        Base64.Decode(ArgsString), Session.Key, EncryptMode, 1), False)));
      try
        SetLength(Result, ArgsMap.Count);
        for I := 0 to ArgsMap.Count - 1 do
          Result[I] := ArgsMap[I];
      finally
        ArgsMap.Free;
      end;
    end;
  end;

  procedure CallFunction;
  var
    Method: TPHPRPCMethod;
    Params: TVariantDynArray;
  begin
    Params := GetArguments;
    MethodName := IntToStr(Length(Params)) + MethodName;
    if FMethods.ContainsKey(MethodName) then
    begin
      Method := TPHPRPCMethod(Integer(FMethods[MethodName]));
      if (Session.Key = '') and (EncryptMode > 0) then
      begin
        EncryptMode := 0;
        raise Exception.Create('Can' + #39 + 't find the key for decryption.');
      end;
      Buffer.WriteString('phprpc_result="' + AnsiString(EncodeString(
        EncryptString(Serialize(Method.Invoke(Params, Session)), Session.Key, EncryptMode, 1), Encode)) + SEnd);
      if ByRef then
      begin
        Buffer.WriteString('phprpc_args="' + AnsiString(EncodeString(
          EncryptString(Serialize(Params), Session.Key, EncryptMode, 1), Encode)) + SEnd);
      end;
    end
    else
      raise Exception.Create('Can' + #39 + 't find this function ' + MethodName + '().');
    SendError;
  end;

  procedure KeyExchange;
  var
    DHParams: TDHParams;
    P, G, X: Variant;
    I, N: Integer;
    K: AnsiString;
  begin
    if Encrypt then
    begin
      Session.KeyLen := StrToIntDef(RequestInfo.Params.Values['phprpc_keylen'], 128);
      DHParams := TDHParams.Create(Min(Session.KeyLen, FMaxKeyLen));
      try
        Session.KeyLen := DHParams.Len;
        P := BigInteger(VarToStr(DHParams.P));
        G := BigInteger(VarToStr(DHParams.G));
        X := DHParams.X;
        Session.X := X;
        Session.P := P;
        DHParams.DHParams['y'] := VarToStr(PowMod(G, X, P));
        Buffer.WriteString('phprpc_encrypt="' +
          AnsiString(EncodeString(Serialize(DHParams.DHParams.ToVariant), Encode)) + SEnd);
        if Session.KeyLen <> 128 then
          Buffer.WriteString('phprpc_keylen="' + AnsiString(IntToStr(Session.KeyLen)) + SEnd);
      finally
        DHParams.Free;
      end;
    end
    else
    begin
      X := Session.X;
      P := Session.P;
      if Session.Keylen = 128 then
      begin
        SetLength(Session.FKey, 16);
        FillChar(PAnsiChar(Session.Key)^, 16, 0);
        K := BigIntToBinStr(PowMod(Y, X, P));
        N := Min(Length(K), 16);
        for I := 0 to N - 1 do Session.FKey[16 - I] := K[N - I];
      end
      else
        Session.Key := RawMD5(BigIntToString(PowMod(Y, X, P)));
      VarClear(Session.FX);
      VarClear(Session.FP);
    end;
    Buffer.WriteString(CallBack);
  end;

  procedure SendFunctions;
  begin
    Buffer.WriteString('phprpc_functions="' +
      AnsiString(EncodeString(Serialize(FMethods.Keys.ToVariant), Encode)) + SEnd);
    Buffer.WriteString(CallBack);
  end;

begin
  if not (RequestInfo.CommandType in FSupportCommands) then Exit;

  Buffer := TStringBuffer.Create;
  try
    try
      ErrNo := 0;

      ClientID := RequestInfo.Params.Values['phprpc_id'];
      ClientID := 'phprpc_' + IfThen(ClientID <> '', ClientID, '0');

      Session := FHTTPServer.SessionList.GetSession(ClientID) as TPHPRPCSession;
      if Session = nil then
      begin
        Session := TPHPRPCSession.Create(FHTTPServer.SessionList, ClientID);
      end;
      Session.InUse := True;

      ResponseInfo.ContentType  := 'text/plain; charset=UTF-8';
      ResponseInfo.CacheControl := 'no-store, no-cache, must-revalidate, max-age=0';
      ResponseInfo.Expires := Now;
      ResponseInfo.CustomHeaders.Add('X-Powered-By: PHPRPC Server/3.0');

      Encode := StrToBoolDef(RequestInfo.Params.Values['phprpc_encode'], True);
      ByRef  := StrToBoolDef(RequestInfo.Params.Values['phprpc_ref'], True);

      Encrypt := False;
      EncryptMode := 0;
      EncryptStr := RequestInfo.Params.Values['phprpc_encrypt'];
      case Length(EncryptStr) of
        0:;
        1:
          EncryptMode := StrToIntDef(EncryptStr, 0);
        4:
          Encrypt := StrToBoolDef(EncryptStr, False);
        else
          Y := EncryptStr;
      end;

      CallBack := Base64.Decode(RequestInfo.Params.Values['phprpc_callback']);

      MethodName := RequestInfo.Params.Values['phprpc_func'];
      if MethodName <> '' then
        CallFunction
      else if (FMaxKeyLen >= 96) and (Encrypt or (Length(EncryptStr) > 4)) then
        KeyExchange
      else
        SendFunctions;

    except
      on E: Exception do
      begin
        ErrNo := 1;
        {$ifdef DELPHI2009_UP}
        if FDebugMode then
          ErrStr := UTF8Encode(E.ToString)
        else
        {$endif}
          ErrStr := UTF8Encode(E.Message);
        SendError;
      end;
    end;
  finally
    Session.InUse := False;
    ResponseInfo.ContentText := Buffer{$ifdef DELPHI2009_UP}.ToAnsiString{$else}.ToString{$endif};
    Buffer.Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('Internet', [TPHPRPCIOCPHttpServer]);
end;


end.
