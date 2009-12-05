{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPCSynaHttpClient.pas                                 |
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

/* PHPRPC Syna Http Client Library.
 *
 * Copyright: Chen fei <cf850118@163.com>
 * Version: 3.0.2
 * LastModified: Oct 30, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */
}

unit PHPRPCSynaHttpClient;

{$I PHPRPC.inc}

interface

uses
  Classes, SysUtils,
  httpsend,
  PHPRPC, PHPRPCClient;

type

  { TPHPRPCSynaHttpClient }

  TPHPRPCSynaHttpClient = class(TPHPRPCClient)
  protected
    function Post(const ReqStr: AnsiString): THashMap; override;
  end;

procedure Register;

implementation

uses
  Base64;

{ TPHPRPCSynaHttpClient }

function TPHPRPCSynaHttpClient.Post(const ReqStr: AnsiString): THashMap;
var
  HTTPSend: THTTPSend;
  Dest: AnsiString;
  xPoweredBy, Buf, Left, Right: string;
  P, I: Integer;
  Data: TStringList;
  version: Currency;
begin
  HTTPSend := nil;
  Result := THashMap.Create;
  try
    try
      HTTPSend := THTTPSend.Create;
      HTTPSend.KeepAlive := True;
      HTTPSend.MimeType := 'application/x-www-form-urlencoded; charset=' + FCharset;
      HTTPSend.UserAgent := 'PHPRPC 3.0 Client for Delphi';
      HTTPSend.Protocol := '1.1';
      HTTPSend.Headers.Add('Accept: *.*');
      HTTPSend.Headers.Add('CacheControl: no-cache');
      HTTPSend.Document.WriteBuffer(PAnsiChar(ReqStr)^, Length(ReqStr));
      HTTPSend.HTTPMethod('POST', FURL);
      SetLength(Dest, HTTPSend.Document.Size);
      HTTPSend.Document.ReadBuffer(PAnsiChar(Dest)^, HTTPSend.Document.Size);
      if HTTPSend.ResultCode = 200 then
      begin
        version := 0;
        HTTPSend.Headers.NameValueSeparator := ':';
        for I := 0 to HTTPSend.Headers.Count - 1 do begin
          if SysUtils.AnsiLowerCase(HTTPSend.Headers.Names[I]) = 'x-powered-by' then begin
            xPoweredBy := HTTPSend.Headers[I];
            P := Pos('PHPRPC Server/', xPoweredBy);
            if P > 0 then version := StrToCurr(Copy(xPoweredBy, P + 14, Length(xPoweredBy)));
          end;
        end;
        if version = 0 then
          raise Exception.Create('Illegal PHPRPC Server!')
        else
          FVersion := version;
        Data := Split(string(Dest));
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
        Result['phprpc_errno'] := HTTPSend.ResultCode;
        Result['phprpc_errstr'] := HTTPSend.ResultString;
      end;
    except
      on E: Exception do begin
        Result['phprpc_errno'] := 1;
        Result['phprpc_errstr'] := E.Message;
      end;
    end;
  finally
    FreeAndNil(HTTPSend);
  end;
end;

procedure Register;
begin
  RegisterComponents('Internet', [TPHPRPCSynaHttpClient]);
end;

end.
