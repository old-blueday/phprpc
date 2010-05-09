{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| XXTEA.pas                                                |
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
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU General Public License (GPL) version    |
| 2.0 as published by the Free Software Foundation and     |
| appearing in the included file LICENSE.                  |
|                                                          |
\**********************************************************/

/* XXTEA encryption arithmetic library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Oct 30, 2009
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */
}

unit XXTEA;

{$I PHPRPC.inc}

interface

function Encrypt(const Data, Key: AnsiString): AnsiString;
function Decrypt(const Data, Key: AnsiString): AnsiString;

implementation

type
  TLongWordDynArray = array of LongWord;

const
  Delta: LongWord = $9e3779b9;

function StrToArray(const Data: AnsiString; IncludeLength: Boolean): TLongWordDynArray;
var
  N, I: LongWord;
begin
  N := Length(Data);
  if ((N and 3) = 0) then N := N shr 2 else N := (N shr 2) + 1;
  if (IncludeLength) then
  begin
    SetLength(Result, N + 1);
    Result[N] := Length(Data);
  end
  else SetLength(Result, N);
  N := Length(Data);
  for I := 0 to N - 1 do
  begin
    Result[I shr 2] := Result[I shr 2] or (($000000ff and ord(Data[I + 1])) shl ((I and 3) shl 3));
  end;
end;

function ArrayToStr(const Data: TLongWordDynArray; IncludeLength: Boolean): AnsiString;
var
  N, M, I: LongWord;
begin
  N := Length(Data) shl 2;
  if (IncludeLength) then
  begin
    M := Data[Length(Data) - 1];
    if (M > N) then
    begin
      Result := '';
      Exit;
    end
    else N := M;
  end;
  SetLength(Result, N);
  for I := 0 to N - 1 do
    Result[I + 1] := AnsiChar((Data[I shr 2] shr ((I and 3) shl 3)) and $ff);
end;

function XXTeaEncrypt(var V, K: TLongWordDynArray): TLongWordDynArray;
var
  N, Z, Y, Sum, E, P, Q: LongWord;

  function MX: LongWord;
  begin
    Result := (((Z shr 5) xor (Y shl 2)) + ((Y shr 3) xor (Z shl 4))) xor ((Sum xor Y) + (K[P and 3 xor E] xor Z));
  end;

begin
  N := Length(V) - 1;
  if (N < 1) then
  begin
    Result := V;
    Exit;
  end;
  if Length(K) < 4 then SetLength(K, 4);
  Z := V[N];
  Y := V[0];
  Sum := 0;
  Q := 6 + 52 div (N + 1);
  repeat
    Inc(Sum, Delta);
    E := (Sum shr 2) and 3;
    for P := 0 to N - 1 do
    begin
      Y := V[P + 1];
      inc(V[P], MX());
      Z := V[P];
    end;
    P := N;
    Y := V[0];
    inc(V[P], MX());
    Z := V[P];
    Dec(Q);
  until Q = 0;
  Result := V;
end;

function XXTeaDecrypt(var V, K: TLongWordDynArray): TLongWordDynArray;
var
  N, Z, Y, Sum, E, P, Q: LongWord;

  function MX : LongWord;
  begin
    Result := (((Z shr 5) xor (Y shl 2)) + ((Y shr 3) xor (Z shl 4))) xor ((Sum xor Y) + (K[P and 3 xor E] xor Z));
  end;

begin
  N := Length(V) - 1;
  if (N < 1) then
  begin
    Result := V;
    Exit;
  end;
  if Length(K) < 4 then SetLength(K, 4);
  Z := V[N];
  Y := V[0];
  Q := 6 + 52 div (N + 1);
  Sum := Q * Delta;
  while (Sum <> 0) do
  begin
    E := (Sum shr 2) and 3;
    for P := N downto 1 do
    begin
      Z := V[P - 1];
      Dec(V[P], MX());
      Y := V[P];
    end;
    P := 0;
    Z := V[N];
    Dec(V[0], MX());
    Y := V[0];
    Dec(Sum, Delta);
  end;
  Result := V;
end;

function Encrypt(const Data, Key: AnsiString): AnsiString;
var
  V, K: TLongWordDynArray;
begin
  if (Length(Data) = 0) then Exit;
  V := StrToArray(Data, True);
  K := StrToArray(Key, False);
  Result := ArrayToStr(XXTeaEncrypt(V, K), False);
end;

function Decrypt(const Data, Key: AnsiString): AnsiString;
var
  V, K: TLongWordDynArray;
begin
  if (Length(Data) = 0) then exit;
  V := StrToArray(Data, False);
  K := StrToArray(Key, False);
  Result := ArrayToStr(XXTeaDecrypt(V, K), True);
end;

end.
