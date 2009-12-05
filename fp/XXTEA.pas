{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| XXTEA.pas                                                |
|                                                          |
| Release 3.0.1                                            |
| Copyright (c) 2005-2008 by Team-PHPRPC                   |
|                                                          |
| WebSite:  http://www.phprpc.org/                         |
|           http://www.phprpc.net/                         |
|           http://www.phprpc.com/                         |
|           http://sourceforge.net/projects/php-rpc/       |
|                                                          |
| Authors:  Ma Bingyao <andot@ujn.edu.cn>                  |
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* XXTEA encryption arithmetic library.
 *
 * Copyright (C) 2005-2008 Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.1
 * LastModified: Dec 28, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */
}

unit XXTEA;

{$IFDEF VER200}
  {$DEFINE DELPHI2009}
{$ENDIF}

interface

{$IFNDEF DELPHI2009}
type
  RawByteString = type AnsiString;
{$ENDIF}

function Encrypt(const data:RawByteString; const key:RawByteString):RawByteString;
function Decrypt(const data:RawByteString; const key:RawByteString):RawByteString;

implementation

type
  TLongWordDynArray = array of LongWord;

const
  delta:LongWord = $9e3779b9;

function StrToArray(const data:RawByteString; includeLength:Boolean):TLongWordDynArray;
var
  n, i:LongWord;
begin
  n := Length(data);
  if ((n and 3) = 0) then n := n shr 2 else n := (n shr 2) + 1;
  if (includeLength) then begin
    setLength(result, n + 1);
    result[n] := Length(data);
  end else begin
    setLength(result, n);
  end;
  n := Length(data);
  for i := 0 to n - 1 do begin
    result[i shr 2] := result[i shr 2] or (($000000ff and ord(data[i + 1])) shl ((i and 3) shl 3));
  end;
end;

function ArrayToStr(const data:TLongWordDynArray; includeLength:Boolean):RawByteString;
var
  n, m, i:LongWord;
begin
  n := Length(data) shl 2;
  if (includeLength) then begin
    m := data[Length(data) - 1];
    if (m > n) then begin
      result := '';
      exit;
    end else begin
      n := m;
    end;
  end;
  SetLength(result, n);
  for i := 0 to n - 1 do begin
    result[i + 1] := AnsiChar((data[i shr 2] shr ((i and 3) shl 3)) and $ff);
  end;
end;

function XXTeaEncrypt(var v:TLongWordDynArray; var k:TLongWordDynArray):TLongWordDynArray;
var
  n, z, y, sum, e, p, q:LongWord;
  function mx : LongWord;
  begin
    result := (((z shr 5) xor (y shl 2)) + ((y shr 3) xor (z shl 4))) xor ((sum xor y) + (k[p and 3 xor e] xor z));
  end;
begin
  n := Length(v) - 1;
  if (n < 1) then begin
    result := v;
    exit;
  end;
  if Length(k) < 4 then setLength(k, 4);
  z := v[n];
  y := v[0];
  sum := 0;
  q := 6 + 52 div (n + 1);
  repeat
    inc(sum, delta);
    e := (sum shr 2) and 3;
    for p := 0 to n - 1 do begin
      y := v[p + 1];
      inc(v[p], mx());
      z := v[p];
    end;
    p := n;
    y := v[0];
    inc(v[p], mx());
    z := v[p];
    dec(q);
  until q = 0;
  result := v;
end;

function XXTeaDecrypt(var v:TLongWordDynArray; var k:TLongWordDynArray):TLongWordDynArray;
var
  n, z, y, sum, e, p, q:LongWord;
  function mx : LongWord;
  begin
    result := (((z shr 5) xor (y shl 2)) + ((y shr 3) xor (z shl 4))) xor ((sum xor y) + (k[p and 3 xor e] xor z));
  end;
begin
  n := Length(v) - 1;
  if (n < 1) then begin
    result := v;
    exit;
  end;
  if Length(k) < 4 then setLength(k, 4);
  z := v[n];
  y := v[0];
  q := 6 + 52 div (n + 1);
  sum := q * delta;
  while (sum <> 0) do begin
    e := (sum shr 2) and 3;
    for p := n downto 1 do begin
      z := v[p - 1];
      dec(v[p], mx());
      y := v[p];
    end;
    p := 0;
    z := v[n];
    dec(v[0], mx());
    y := v[0];
    dec(sum, delta);
  end;
  result := v;
end;

function Encrypt(const data:RawByteString; const key:RawByteString):RawByteString;
var
  v, k:TLongWordDynArray;
begin
  if (Length(data) = 0) then exit;
  v := StrToArray(data, true);
  k := StrToArray(key, false);
  result := ArrayToStr(XXTeaEncrypt(v, k), false);
end;

function Decrypt(const data:RawByteString; const key:RawByteString):RawByteString;
var
  v, k:TLongWordDynArray;
begin
  if (Length(data) = 0) then exit;
  v := StrToArray(data, false);
  k := StrToArray(key, false);
  result := ArrayToStr(XXTeaDecrypt(v, k), true);
end;

end.
