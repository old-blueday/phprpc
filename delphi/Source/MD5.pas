{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| MD5.pas                                                  |
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

/* MD5 Library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Oct 30, 2009
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */
}

unit MD5;

{$I PHPRPC.inc}

interface

function RawMD5(const Data: AnsiString): AnsiString;
function HexMD5(const Data: AnsiString): string;

implementation

uses
  SysUtils, Classes, Types;

const
  MD5_SINE : array[1..64] of LongWord = (
   { Round 1. }
   $d76aa478, $e8c7b756, $242070db, $c1bdceee, $f57c0faf, $4787c62a,
   $a8304613, $fd469501, $698098d8, $8b44f7af, $ffff5bb1, $895cd7be,
   $6b901122, $fd987193, $a679438e, $49b40821,
   { Round 2. }
   $f61e2562, $c040b340, $265e5a51, $e9b6c7aa, $d62f105d, $02441453,
   $d8a1e681, $e7d3fbc8, $21e1cde6, $c33707d6, $f4d50d87, $455a14ed,
   $a9e3e905, $fcefa3f8, $676f02d9, $8d2a4c8a,
   { Round 3. }
   $fffa3942, $8771f681, $6d9d6122, $fde5380c, $a4beea44, $4bdecfa9,
   $f6bb4b60, $bebfbc70, $289b7ec6, $eaa127fa, $d4ef3085, $04881d05,
   $d9d4d039, $e6db99e5, $1fa27cf8, $c4ac5665,
   { Round 4. }
   $f4292244, $432aff97, $ab9423a7, $fc93a039, $655b59c3, $8f0ccc92,
   $ffeff47d, $85845dd1, $6fa87e4f, $fe2ce6e0, $a3014314, $4e0811a1,
   $f7537e82, $bd3af235, $2ad7d2bb, $eb86d391
  );

{$Q-}
function UnPack(const Data: AnsiString): TLongWordDynArray;
var
  Len, Count, I: LongWord;
begin
  Len := Length(Data);
  Count := ((Len + 72) shr 6) shl 4;
  SetLength(Result, Count);
  for I := 0 to Len - 1 do
    Result[I shr 2] := Result[I shr 2] or (LongWord(Ord(Data[I + 1])) shl ((I and 3) shl 3));
  Result[Len shr 2] := Result[Len shr 2] or (LongWord($00000080) shl ((Len and 3) shl 3));
  Result[Count - 2] := (Len and $1fffffff) shl 3;
  Result[Count - 1] := Len shr 29;
end;

function ROL(const AVal: LongWord; AShift: Byte): LongWord;
begin
   Result := (AVal shl AShift) or (AVal shr (32 - AShift));
end;

function RawMD5(const Data: AnsiString): AnsiString;
var
  A, B, C, D, OA, OB, OC, OD : LongWord;
  I, Count: Integer;
  X : TLongWordDynArray;
begin
  X := UnPack(Data);
  A := $67452301;
  B := $efcdab89;
  C := $98badcfe;
  D := $10325476;
  I := 0;
  Count := Length(X);
  while I < Count do
  begin
    OA := A;
    OB := B;
    OC := C;
    OD := D;

    { Round 1 }
    { Note:
      (x and y) or ( (not x) and z)
      is equivalent to
      (((z xor y) and x) xor z)
    }
    A := ROL(A + (((D xor C) and B) xor D) + X[I +  0] + MD5_SINE[ 1],  7) + B;
    D := ROL(D + (((C xor B) and A) xor C) + X[I +  1] + MD5_SINE[ 2], 12) + A;
    C := ROL(C + (((B xor A) and D) xor B) + X[I +  2] + MD5_SINE[ 3], 17) + D;
    B := ROL(B + (((A xor D) and C) xor A) + X[I +  3] + MD5_SINE[ 4], 22) + C;
    A := ROL(A + (((D xor C) and B) xor D) + X[I +  4] + MD5_SINE[ 5],  7) + B;
    D := ROL(D + (((C xor B) and A) xor C) + X[I +  5] + MD5_SINE[ 6], 12) + A;
    C := ROL(C + (((B xor A) and D) xor B) + X[I +  6] + MD5_SINE[ 7], 17) + D;
    B := ROL(B + (((A xor D) and C) xor A) + X[I +  7] + MD5_SINE[ 8], 22) + C;
    A := ROL(A + (((D xor C) and B) xor D) + X[I +  8] + MD5_SINE[ 9],  7) + B;
    D := ROL(D + (((C xor B) and A) xor C) + X[I +  9] + MD5_SINE[10], 12) + A;
    C := ROL(C + (((B xor A) and D) xor B) + X[I + 10] + MD5_SINE[11], 17) + D;
    B := ROL(B + (((A xor D) and C) xor A) + X[I + 11] + MD5_SINE[12], 22) + C;
    A := ROL(A + (((D xor C) and B) xor D) + X[I + 12] + MD5_SINE[13],  7) + B;
    D := ROL(D + (((C xor B) and A) xor C) + X[I + 13] + MD5_SINE[14], 12) + A;
    C := ROL(C + (((B xor A) and D) xor B) + X[I + 14] + MD5_SINE[15], 17) + D;
    B := ROL(B + (((A xor D) and C) xor A) + X[I + 15] + MD5_SINE[16], 22) + C;

    { Round 2 }
    { Note:
      (x and z) or (y and (not z) )
      is equivalent to
      (((y xor x) and z) xor y)
    }
    A := ROL(A + (C xor (D and (B xor C))) + X[I +  1] + MD5_SINE[17],  5) + B;
    D := ROL(D + (B xor (C and (A xor B))) + X[I +  6] + MD5_SINE[18],  9) + A;
    C := ROL(C + (A xor (B and (D xor A))) + X[I + 11] + MD5_SINE[19], 14) + D;
    B := ROL(B + (D xor (A and (C xor D))) + X[I +  0] + MD5_SINE[20], 20) + C;
    A := ROL(A + (C xor (D and (B xor C))) + X[I +  5] + MD5_SINE[21],  5) + B;
    D := ROL(D + (B xor (C and (A xor B))) + X[I + 10] + MD5_SINE[22],  9) + A;
    C := ROL(C + (A xor (B and (D xor A))) + X[I + 15] + MD5_SINE[23], 14) + D;
    B := ROL(B + (D xor (A and (C xor D))) + X[I +  4] + MD5_SINE[24], 20) + C;
    A := ROL(A + (C xor (D and (B xor C))) + X[I +  9] + MD5_SINE[25],  5) + B;
    D := ROL(D + (B xor (C and (A xor B))) + X[I + 14] + MD5_SINE[26],  9) + A;
    C := ROL(C + (A xor (B and (D xor A))) + X[I +  3] + MD5_SINE[27], 14) + D;
    B := ROL(B + (D xor (A and (C xor D))) + X[I +  8] + MD5_SINE[28], 20) + C;
    A := ROL(A + (C xor (D and (B xor C))) + X[I + 13] + MD5_SINE[29],  5) + B;
    D := ROL(D + (B xor (C and (A xor B))) + X[I +  2] + MD5_SINE[30],  9) + A;
    C := ROL(C + (A xor (B and (D xor A))) + X[I +  7] + MD5_SINE[31], 14) + D;
    B := ROL(B + (D xor (A and (C xor D))) + X[I + 12] + MD5_SINE[32], 20) + C;

    { Round 3. }
    A := ROL(A + (B xor C xor D) + X[I +  5] + MD5_SINE[33],  4) + B;
    D := ROL(D + (A xor B xor C) + X[I +  8] + MD5_SINE[34], 11) + A;
    C := ROL(C + (D xor A xor B) + X[I + 11] + MD5_SINE[35], 16) + D;
    B := ROL(B + (C xor D xor A) + X[I + 14] + MD5_SINE[36], 23) + C;
    A := ROL(A + (B xor C xor D) + X[I +  1] + MD5_SINE[37],  4) + B;
    D := ROL(D + (A xor B xor C) + X[I +  4] + MD5_SINE[38], 11) + A;
    C := ROL(C + (D xor A xor B) + X[I +  7] + MD5_SINE[39], 16) + D;
    B := ROL(B + (C xor D xor A) + X[I + 10] + MD5_SINE[40], 23) + C;
    A := ROL(A + (B xor C xor D) + X[I + 13] + MD5_SINE[41],  4) + B;
    D := ROL(D + (A xor B xor C) + X[I +  0] + MD5_SINE[42], 11) + A;
    C := ROL(C + (D xor A xor B) + X[I +  3] + MD5_SINE[43], 16) + D;
    B := ROL(B + (C xor D xor A) + X[I +  6] + MD5_SINE[44], 23) + C;
    A := ROL(A + (B xor C xor D) + X[I +  9] + MD5_SINE[45],  4) + B;
    D := ROL(D + (A xor B xor C) + X[I + 12] + MD5_SINE[46], 11) + A;
    C := ROL(C + (D xor A xor B) + X[I + 15] + MD5_SINE[47], 16) + D;
    B := ROL(B + (C xor D xor A) + X[I +  2] + MD5_SINE[48], 23) + C;

    { Round 4. }
    A := ROL(A + ((B or not D) xor C) + X[I +  0] + MD5_SINE[49],  6) + B;
    D := ROL(D + ((A or not C) xor B) + X[I +  7] + MD5_SINE[50], 10) + A;
    C := ROL(C + ((D or not B) xor A) + X[I + 14] + MD5_SINE[51], 15) + D;
    B := ROL(B + ((C or not A) xor D) + X[I +  5] + MD5_SINE[52], 21) + C;
    A := ROL(A + ((B or not D) xor C) + X[I + 12] + MD5_SINE[53],  6) + B;
    D := ROL(D + ((A or not C) xor B) + X[I +  3] + MD5_SINE[54], 10) + A;
    C := ROL(C + ((D or not B) xor A) + X[I + 10] + MD5_SINE[55], 15) + D;
    B := ROL(B + ((C or not A) xor D) + X[I +  1] + MD5_SINE[56], 21) + C;
    A := ROL(A + ((B or not D) xor C) + X[I +  8] + MD5_SINE[57],  6) + B;
    D := ROL(D + ((A or not C) xor B) + X[I + 15] + MD5_SINE[58], 10) + A;
    C := ROL(C + ((D or not B) xor A) + X[I +  6] + MD5_SINE[59], 15) + D;
    B := ROL(B + ((C or not A) xor D) + X[I + 13] + MD5_SINE[60], 21) + C;
    A := ROL(A + ((B or not D) xor C) + X[I +  4] + MD5_SINE[61],  6) + B;
    D := ROL(D + ((A or not C) xor B) + X[I + 11] + MD5_SINE[62], 10) + A;
    C := ROL(C + ((D or not B) xor A) + X[I +  2] + MD5_SINE[63], 15) + D;
    B := ROL(B + ((C or not A) xor D) + X[I +  9] + MD5_SINE[64], 21) + C;

    Inc(A, OA);
    Inc(B, OB);
    Inc(C, OC);
    Inc(D, OD);
    Inc(I, 16);
  end;

  SetLength(Result, 16);
  Result[1]  := AnsiChar(A and $ff);
  Result[2]  := AnsiChar((A shr  8) and $ff);
  Result[3]  := AnsiChar((A shr 16) and $ff);
  Result[4]  := AnsiChar((A shr 24) and $ff);
  Result[5]  := AnsiChar(B and $ff);
  Result[6]  := AnsiChar((B shr  8) and $ff);
  Result[7]  := AnsiChar((B shr 16) and $ff);
  Result[8]  := AnsiChar((B shr 24) and $ff);
  Result[9]  := AnsiChar(C and $ff);
  Result[10] := AnsiChar((C shr  8) and $ff);
  Result[11] := AnsiChar((C shr 16) and $ff);
  Result[12] := AnsiChar((C shr 24) and $ff);
  Result[13] := AnsiChar(D and $ff);
  Result[14] := AnsiChar((D shr  8) and $ff);
  Result[15] := AnsiChar((D shr 16) and $ff);
  Result[16] := AnsiChar((D shr 24) and $ff);
end;
{$Q+}

function HexMD5(const Data: AnsiString): string;
var
  Raw: AnsiString;
begin
  Raw := RawMD5(Data);
  SetLength(Result, 32);
  BinToHex(PAnsiChar(Raw), PChar(Result), 16);
end;

end.
