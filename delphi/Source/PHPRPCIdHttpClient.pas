{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPCIdHttpClient.pas                                   |
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

/* PHPRPC Indy Http Client Library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 *            Chen fei <cf850118@163.com>
 * Version: 3.0.2
 * LastModified: Oct 30, 2009
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */
}

unit PHPRPCIdHttpClient;

{$I PHPRPC.inc}

interface

uses
  Classes, SysUtils,
  IdHTTP, IdHTTPHeaderInfo, IdCookieManager,
  PHPRPC, PHPRPCClient;

type

  { TPHPRPCIdHttpClient }

  TPHPRPCIdHttpClient = class(TPHPRPCClient)
  private
    FProxy: TIdProxyConnectionInfo;
  protected
    procedure Initialize; override;
    function Post(const ReqStr: AnsiString): THashMap; override;
  public
    destructor Destroy; override;
  published
    property Proxy: TIdProxyConnectionInfo read FProxy write FProxy;
  end;

procedure Register;

implementation

uses
  Base64;

var
  CookieManager: TIdCookieManager = nil;

{ TPHPRPCIdHttpClient }

procedure TPHPRPCIdHttpClient.Initialize;
begin
  inherited;
  FProxy := TIdProxyConnectionInfo.Create;
  FProxy.Clear;
end;

destructor TPHPRPCIdHttpClient.Destroy;
begin
  FreeAndNil(FProxy);
  inherited;
end;

function TPHPRPCIdHttpClient.Post(const ReqStr: AnsiString): THashMap;
var
  IdHTTP: TIdHTTP;
  Source: TMemoryStream;
  Dest: string;
  xPoweredBy, Buf, Left, Right: string;
  P, I: Integer;
  Data: TStringList;
  OldProxy: TIdProxyConnectionInfo;
  version: Currency;
begin
  IdHTTP := nil;
  Source := TMemoryStream.Create;
  Source.WriteBuffer(PAnsiChar(ReqStr)^, Length(ReqStr));
  Result := THashMap.Create;
  OldProxy := nil;
  try
    try
      IdHTTP := TIdHTTP.Create(nil);
      IdHTTP.AllowCookies := True;
      IdHTTP.CookieManager := CookieManager;
      OldProxy := IdHTTP.ProxyParams;
      IdHTTP.ProxyParams := FProxy;
      IdHTTP.ReadTimeout := FTimeout;
      IdHTTP.Request.Connection := 'Keep-Alive';
      IdHTTP.Request.Accept := '*.*';
      IdHTTP.Request.ContentType := 'application/x-www-form-urlencoded; charset=' + FCharset;
      IdHTTP.Request.UserAgent := 'PHPRPC 3.0 Client for Delphi';
      IdHTTP.Request.AcceptEncoding := 'gzip, deflate';
      IdHTTP.Request.CacheControl := 'no-cache';
      IdHTTP.HTTPOptions := IdHTTP.HTTPOptions + [hoKeepOrigProtocol];
      IdHTTP.ProtocolVersion := pv1_1;
      Dest := IdHTTP.Post(FURL, Source);
      if IdHTTP.ResponseCode = 200 then begin
        version := 0;
        for I := 0 to IdHTTP.Response.RawHeaders.Count - 1 do begin
          if SysUtils.AnsiLowerCase(IdHTTP.Response.RawHeaders.Names[I]) = 'x-powered-by' then begin
            xPoweredBy := IdHTTP.Response.RawHeaders[I];
            P := Pos('PHPRPC Server/', xPoweredBy);
            if P > 0 then version := StrToCurr(Copy(xPoweredBy, P + 14, Length(xPoweredBy)));
          end;
        end;
        if version = 0 then
          raise Exception.Create('Illegal PHPRPC Server!')
        else
          FVersion := version;
        Data := Split(Dest);
        try
          for I := 0 to Data.Count - 1 do begin
            Buf := Data[I];
            P := Pos('=', Buf);
            if P > 0 then begin
              Left := Copy(Buf, 1, P - 1);
              Right := Copy(Buf, P + 2, Length(Buf) - P - 3);
              if (Left = 'phprpc_errno') or (Left = 'phprpc_keylen') then
                Result[Left] := StrToInt(Right)
              else
                Result[Left] := Base64.Decode(Right);
            end;
          end;
        finally
          FreeAndNil(Data);
        end;
      end
      else begin
        Result['phprpc_errno'] := IdHTTP.ResponseCode;
        Result['phprpc_errstr'] := IdHTTP.ResponseText;
      end;
    except
      on E: Exception do begin
        Result['phprpc_errno'] := 1;
        Result['phprpc_errstr'] := E.Message;
      end;
    end;
  finally
    FreeAndNil(Source);
    if OldProxy <> nil then
      IdHTTP.ProxyParams := OldProxy;
    FreeAndNil(IdHTTP);
  end;
end;

procedure Register;
begin
  RegisterComponents('Internet', [TPHPRPCIdHttpClient]);
end;

initialization
  CookieManager := TIdCookieManager.Create(nil);
finalization
  FreeAndNil(CookieManager);
end.
