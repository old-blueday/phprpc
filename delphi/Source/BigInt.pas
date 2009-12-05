{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| BigInt.pas                                               |
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
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* BigInteger Variant Type
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Oct 30, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */
}

unit BigInt;

{$I PHPRPC.inc}

interface

uses Types;

type
  TRadix = 2..36;

{ BigInteger variant creation utils }

function VarBi: TVarType;
function Zero: Variant;
function One: Variant;
procedure BigInteger(var V: Variant; const I: Int64); overload;
function BigInteger(const I: Int64): Variant; overload;
procedure BigInteger(var V: Variant; const S: string); overload;
function BigInteger(const S: string): Variant; overload;
function PowMod(var X, Y, Z: Variant): Variant; overload;
function Rand(BitNumber: Integer; SetHighBit: Boolean): Variant;
function BigIntToBinStr(const V: Variant): AnsiString;
function BinStrToBigInt(const S: AnsiString): Variant;
function BigIntToString(const V: Variant; Radix: TRadix = 10): AnsiString;

implementation

uses Variants, SysUtils, StrUtils, Math;

type
  PLongWordArray = ^TLongWordArray;
  TLongWordArray = array [0..$7FFFFFF] of LongWord;
  TBiVarData = packed record
    VType: TVarType;
    Reserved1, Reserved2, Reserved3: Word;
    VData: PLongWordArray;
    VLength: LongInt;
  end;

  TBiVariantType = class(TCustomVariantType)
  public
    procedure Clear(var V: TVarData); override;
    function IsClear(const V: TVarData): Boolean; override;
    procedure Copy(var Dest: TVarData; const Source: TVarData;
      const Indirect: Boolean); override;
    procedure Cast(var Dest: TVarData; const Source: TVarData); override;
    procedure CastTo(var Dest: TVarData; const Source: TVarData;
      const AVarType: TVarType); override;
    procedure BinaryOp(var Left: TVarData; const Right: TVarData;
      const Op: TVarOp); override;
    procedure Compare(const Left, Right: TVarData;
      var Relationship: TVarCompareResult); override;
  end;

var
  BiVariantType: TBiVariantType = nil;

const
  CharacterSet: AnsiString = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

function ZeroFill(const S: string; N: Integer): string;
var
  L: Integer;
begin
  L := N - Length(S);
  if L > 0 then Result := StringOfChar('0', L) + S else Result := S;
end;

procedure SetLength(var V: TBiVarData; Count: Integer);
begin
  ReallocMem(V.VData, SizeOf(LongWord) * Count);
  if Count > V.VLength then
    FillChar(V.VData[V.VLength], SizeOf(LongWord) * (Count - V.VLength), 0);
  V.VLength := Count;
end;

procedure FixLength(var V: TBiVarData);
begin
  while (V.VLength > 1) and (V.VData[V.VLength - 1] = 0) do Dec(V.VLength);
end;

procedure Add(var A: TBiVarData; B: Word); overload;
var
  I: Integer;
begin
  FixLength(A);
  Inc(A.VData[0], B);
  if A.VData[0] > $FFFF then begin
    I := 0;
    if (A.VLength = 1) or (A.VData[A.VLength - 1] = $FFFF) then
      SetLength(A, A.VLength + 1);
    repeat
      A.VData[I] := A.VData[I] and $FFFF;
      Inc(I);
      Inc(A.VData[I]);
    until A.VData[I] <= $FFFF;
    FixLength(A);
  end;
end;

procedure Add(var A, B: TBiVarData); overload;
var
  AL, BL, I, L, N: Integer;
begin
  FixLength(A);
  FixLength(B);
  AL := A.VLength;
  BL := B.VLength;
  L := Max(AL, BL) + 1;
  SetLength(A, L);
  for I := 0 to Min(AL, BL) - 1 do Inc(A.VData[I], B.VData[I]);
  if AL < BL then
    for I := AL to BL - 1 do A.VData[I] := B.VData[I];
  I := 0;
  N := 0;
  while (I < L - 1) do begin
    if (A.VData[I] > $FFFF) then begin
      A.VData[I] := A.VData[I] and $FFFF;
      N := I + 1;
      Inc(A.VData[N]);
    end;
    Inc(I);
  end;
  if N = L - 1 then A.VLength := L else A.VLength := L - 1;
end;

procedure Mul(var A: TBiVarData; B: Word); overload;
var
  Temp: LongWord;
  I: Integer;
begin
  FixLength(A);
  if B = 0 then begin
    SetLength(A, 1);
    A.VData[0] := 0;
    Exit;
  end;
  if B = 1 then Exit;
  SetLength(A, A.VLength + 1);
  Temp := A.VData[0];
  A.VData[0] := 0;
  for I := 0 to A.VLength - 2 do begin
    Inc(A.VData[I], Temp * B);
    Temp := A.VData[I + 1];
    A.VData[I + 1] := A.VData[I] shr 16;
    A.VData[I] := A.VData[I] and $FFFF;
  end;
  FixLength(A);
end;

procedure Mul(var A, B: TBiVarData); overload;
var
  R: PLongWordArray;
  L, I, J, K: Integer;
begin
  FixLength(A);
  FixLength(B);
  if B.VLength = 1 then begin
    Mul(A, B.VData[0]);
    Exit;
  end;
  L := A.VLength + B.VLength;
  GetMem(R, SizeOf(LongWord) * L);
  FillChar(R^, SizeOf(LongWord) * L, 0);
  for I := 0 to A.VLength - 1 do for J := 0 to B.VLength - 1 do begin
    K := I + J;
    Inc(R[K], A.VData[I] * B.VData[J]);
    Inc(R[K + 1], R[K] shr 16);
    R[K] := R[K] and $FFFF;
  end;
  FreeMem(A.VData);
  A.VData := R;
  A.VLength := L;
  FixLength(A);
end;

function IntDivMod(var A: TBiVarData; B: Word): Word; overload;
var
  R: LongWord;
  I: Integer;
begin
  FixLength(A);
  if B = 0 then Error(reDivByZero);
  if B = 1 then begin
    Result := 0;
    Exit;
  end;
  R := 0;
  I := A.VLength;
  Dec(I);
  while I >= 0 do begin
    R := R shl 16;
    R := R or A.VData[I];
    A.VData[I] := R div B;
    R := R mod B;
    Dec(I);
  end;
  FixLength(A);
  Result := R;
end;

procedure LeftShift(var A: TBiVarData; B: Word);
var
  W, X, C: Word;
  I, L: Integer;
  R: PLongWordArray;
begin
  FixLength(A);
  // add one empty element for IntDivMod !
  if B = 0 then begin
    SetLength(A, A.VLength + 1);
    FixLength(A);
    Exit;
  end;
  W := B shr 4;
  B := B and 15;
  GetMem(R, SizeOf(LongWord) * (A.VLength + W + 1));
  FillChar(R^, SizeOf(LongWord) * (A.VLength + W + 1), 0);
  L := A.VLength;
  if B = 0 then
    Move(A.VData[0], R[W], SizeOf(LongWord) * L)
  else begin
    I := 0;
    C := 0;
    while I < L do begin
      X := A.VData[I];
      R[I + W] := Word(X shl B) or C;
      C := X shr (16 - B);
      Inc(I);
    end;
    R[I + W] := C;
  end;
  FreeMem(A.VData);
  A.VData := R;
  Inc(A.VLength, W + 1);
  FixLength(A);
end;

procedure RightShift(var A: TBiVarData; B: Word);
var
  W, X, C: Word;
  L: Integer;
  R: PLongWordArray;
begin
  FixLength(A);
  if B = 0 then Exit;
  W := B shr 4;
  B := B and 15;
  if W >= A.VLength then begin
    W := A.VLength - 1;
    B := 0;
  end;
  L := A.VLength - W;
  GetMem(R, SizeOf(LongWord) * L);
  FillChar(R^, SizeOf(LongWord) * L, 0);
  if B = 0 then
    Move(A.VData[W], R[0], SizeOf(LongWord) * L)
  else begin
    C := 0;
    Dec(L);
    while (L >= 0) do begin
      X := A.VData[L + W];
      R[L] := Word(X shr B) or C;
      C := X shl (16 - B);
      Dec(L);
    end;
  end;
  FreeMem(A.VData);
  A.VData := R;
  Dec(A.VLength, W);
  FixLength(A);
end;

function Compare(var A, B: TBiVarData): TVarCompareResult;
var
  I: Integer;
begin
  FixLength(A);
  FixLength(B);
  if A.VLength < B.VLength then Result := crLessThan
  else if A.VLength > B.VLength then Result := crGreaterThan
  else begin
    Result := crEqual;
    for I := A.VLength - 1 to 0 do begin
      if A.VData[I] < B.VData[I] then Result := crLessThan
      else if A.VData[I] > B.VData[I] then Result := crGreaterThan;
    end;
  end;
end;

procedure IntDivMod(var A, B: TBiVarData; out Q: TBiVarData); overload;
var
  DP, NP, RP, RL, DL, I, P: Integer;
  T, S, Mask, Val: Word;
  Sum, B1, B2, D, QH, RH, MC: LongWord;
begin
  if Compare(A, B) = crLessThan then begin
    Q.VType := A.VType;
    SetLength(Q, 1);
    Q.VData[0] := 0;
    Exit;
  end;

  if B.VLength = 1 then begin
    if Q.VType = VarBi then
      FreeMem(Q.VData)
    else
      Q.VType := VarBi;
    Q.VData := A.VData;
    Q.VLength := A.VLength;
    A.VData := nil;
    SetLength(A, 1);
    A.VData[0] := IntDivMod(Q, B.VData[0]);
    Exit;
  end;

  RL := A.VLength + 1;
  DL := B.VLength + 1;
  Mask := $8000;
  Val := B.VData[B.VLength - 1];
  S := 0;
  RP := A.VLength - B.VLength;
  while (Mask <> 0) and ((Val and Mask) = 0) do begin
    Inc(S);
    Mask := Mask shr 1;
  end;

  if Q.VType <> VarBi then begin
    Q.VType := VarBi;
    Q.VData := nil;
    Q.VLength := 0;
  end;
  SetLength(Q, A.VLength - B.VLength + 1);
  LeftShift(A, S);
  LeftShift(B, S);

  I := RL - B.VLength;
  P := RL - 1;

  B1 := B.VData[B.VLength - 1];
  B2 := B.VData[B.VLength - 2];

  while I > 0 do begin
    // maybe you will find P is out of range (P >= A.VLength),
    // but A has more elements than A.VLength (because of LeftShift) ,
    // so here is no mistake. it also appears in the following code.

    D := (A.VData[P] shl 16) + A.VData[P - 1];
    QH := D div B1;
    RH := D mod B1;
    repeat
      if (QH = $10000) or ((QH * B2) > ((RH shl 16) + A.VData[P - 2])) then begin
        Dec(QH);
        Inc(RH, B1);
        if (RH < $10000) then Continue;
      end;
      Break;
    until False;

    //
    // At this point, QH is either exact, or one too large
    // (more likely to be exact) so, we attempt to multiply the
    // divisor by QH, if we get a borrow, we just subtract
    // one from QH and add the divisor back.
    //

    DP := 0;
    NP := P - DL + 1;
    MC := 0;
    QH := QH and $FFFF;
    repeat
      Inc(MC, B.VData[DP] * QH);
      T := A.VData[NP];
      Dec(A.VData[NP], MC and $FFFF);
      A.VData[NP] := A.VData[NP] and $FFFF;
      MC := MC shr 16;
      if A.VData[NP] > T then Inc(MC);
      Inc(DP);
      Inc(NP);
    until DP >= DL;

    NP := P - DL + 1;
    DP := 0;

    // Overestimate
    if MC <> 0 then begin
      Dec(QH);
      Sum := 0;
      repeat
        Inc(Sum, A.VData[NP] + B.VData[DP]);
        A.VData[NP] := Sum and $FFFF;
        Sum := Sum shr 16;
        Inc(DP);
        Inc(NP);
      until DP >= DL;
    end;

    Q.VData[RP] := QH and $FFFF;
    Dec(RP);
    Dec(P);
    Dec(I);
  end;

  FixLength(Q);
  FixLength(A);

  if S <> 0 then RightShift(A, S);
end;

function BigIntToString(const V: Variant; Radix: TRadix): AnsiString;
var
  T: Variant;
  R: Word;
begin
  if V = Zero then
    Result := '0'
  else if V = One then
    Result := '1'
  else begin
    Result := '';
    T := V;
    while T <> Zero do begin
      R := IntDivMod(TBiVarData(T), Radix);
      Result := CharacterSet[R + 1] + Result;
    end;
  end;
end;

function VarBi: TVarType;
begin
  Result := BiVariantType.VarType;
end;

function Zero: Variant;
begin
  VarClear(Result);
  with TBiVarData(Result) do begin
    VType := VarBi;
    VData := nil;
    VLength := 0;
    SetLength(TBiVarData(Result), 1);
  end;
end;

function One: Variant;
begin
  VarClear(Result);
  with TBiVarData(Result) do begin
    VType := VarBi;
    VData := nil;
    VLength := 0;
    SetLength(TBiVarData(Result), 1);
    VData[0] := 1;
  end;
end;

procedure BigInteger(var V: Variant; const I: Int64); overload;
begin
  VarClear(V);
  with TBiVarData(V) do begin
    VType := VarBi;
    VData := nil;
    VLength := 0;
    if I > $FFFFFFFF then begin
      SetLength(TBiVarData(V), 4);
      VData[0] := I and $FFFF;
      VData[1] := (I shr 16) and $FFFF;
      VData[2] := (I shr 32) and $FFFF;
      VData[3] := (I shr 48) and $FFFF;
      if VData[3] = 0 then VLength := 3 else VLength := 4;
    end
    else if I > $FFFF then begin
      SetLength(TBiVarData(V), 2);
      VData[0] := I and $FFFF;
      VData[1] := (I shr 16) and $FFFF;
      VLength := 2;
    end
    else begin
      SetLength(TBiVarData(V), 1);
      VData[0] := I;
      VLength := 1;
    end;
  end;
end;

function BigInteger(const I: Int64): Variant; overload;
begin
  BigInteger(Result, I);
end;

procedure BigInteger(var V: Variant; const S: string); overload;
var
  I, SLen, ALen: Integer;
  Temp: string;
begin
  BigInteger(V, 0);
  SLen := Length(S);
  Inc(SLen, 4 - (SLen mod 4));
  Temp := ZeroFill(S, SLen);
  ALen := SLen shr 2;
  for I := 0 to ALen - 1 do begin
    Mul(TBiVarData(V), 10000);
    Add(TBiVarData(V), StrToInt(MidStr(Temp, I shl 2 + 1, 4)));
  end;
end;

function BigInteger(const S: string): Variant; overload;
begin
  BigInteger(Result, S);
end;

function PowMod(var X, Y, Z: Variant): Variant; overload;
var
  A, B, C: Variant;
  N, I, J: Integer;
  Temp: LongWord;
begin
  if VarType(X) = VarBi then A := X else VarCast(A, X, VarBi);
  if VarType(Y) = VarBi then B := Y else VarCast(B, Y, VarBi);
  if VarType(Z) = VarBi then C := Z else VarCast(C, Z, VarBi);
  with TBiVarData(B) do begin
    N := VLength;
    Result := One;
    for I := 0 to N - 2 do begin
      Temp := VData[I];
      for J := 0 to 15 do begin
        if (Temp and 1) <> 0 then Result := (Result * A) mod C;
        Temp := Temp shr 1;
        A := (A * A) mod C;
      end;
    end;
    Temp := VData[N - 1];
    while (Temp <> 0) do begin
      if (Temp and 1) <> 0 then Result := (Result * A) mod C;
      Temp := Temp shr 1;
      A := (A * A) mod C;
    end;
  end;
end;

function Rand(BitNumber: Integer; SetHighBit: Boolean): Variant;
const
  LowBitMasks: array [0..15] of Word = ($0001, $0002, $0004, $0008,
                                        $0010, $0020, $0040, $0080,
                                        $0100, $0200, $0400, $0800,
                                        $1000, $2000, $4000, $8000);
var
  I, R, Q: Integer;
begin
  VarClear(Result);
  R := BitNumber mod 16;
  Q := BitNumber shr 4;
  with TBiVarData(Result) do begin
    VType := VarBi;
    VData := nil;
    VLength := 0;
    SetLength(TBiVarData(Result), Q + 1);
    for I := 0 to Q - 1 do VData[I] := Random($10000);
    if R <> 0 then begin
      VData[Q] := Random(LowBitMasks[R]);
      if SetHighBit then VData[Q] := VData[Q] or LowBitMasks[R - 1];
    end
    else begin
      VData[Q] := 0;
      if SetHighBit then VData[Q - 1] := VData[Q - 1] or $8000;
    end;
  end;
  FixLength(TBiVarData(Result));
end;

function BigIntToBinStr(const V: Variant): AnsiString;
var
  N, I: Integer;
begin
  with TBiVarData(V) do begin
    N := VLength;
    System.SetLength(Result, N * 2);
    for I := 0 to N - 1 do begin
      Result[(N - I) * 2] := AnsiChar(VData[I] and $FF);
      Result[(N - I) * 2 - 1] := AnsiChar((VData[I] shr 8) and $FF);
    end;
  end;
end;

function BinStrToBigInt(const S: AnsiString): Variant;
var
  I, N: Integer;
begin
  N := Length(S);
  if N = 0 then begin
    Result := Zero;
    Exit;
  end;
  VarClear(Result);
  with TBiVarData(Result) do begin
    VType := VarBi;
    VData := nil;
    VLength := 0;
    SetLength(TBiVarData(Result), (N + 1) shr 1);
    I := N;
    while I > 1 do begin
      VData[VLength - ((I + 1) shr 1)] := (Ord(S[I - 1]) shl 8) or Ord(S[I]);
      Dec(I, 2);
    end;
    if Odd(N) then VData[VLength - 1] := Ord(S[1]);
  end;
end;

{ TBiVariantType }

procedure TBiVariantType.BinaryOp(var Left: TVarData;
  const Right: TVarData; const Op: TVarOp);
var
  TL, TR: TVarData;
begin
  VarDataInit(TL);
  VarDataInit(TR);
  try
    VarDataCopy(TL, Left);
    VarDataCopy(TR, Right);
    case Op of
      opAdd:
        Add(TBiVarData(Left), TBiVarData(TR));
      opMultiply:
        Mul(TBiVarData(Left), TBiVarData(TR));
      opDivide, opIntDivide:
        IntDivMod(TBiVarData(TVarData(TL)), TBiVarData(TVarData(TR)), TBiVarData(Left));
      opModulus:
        IntDivMod(TBiVarData(Left), TBiVarData(TVarData(TR)), TBiVarData(TVarData(TL)));
      opShiftLeft:
        LeftShift(TBiVarData(Left), TBiVarData(TR).VData[0]);
      opShiftRight:
        RightShift(TBiVarData(Left), TBiVarData(TR).VData[0]);
    else
      RaiseInvalidOp;
    end;
  finally
    VarDataClear(TL);
    VarDataClear(TR);
  end;
end;

procedure TBiVariantType.Cast(var Dest: TVarData;
  const Source: TVarData);
var
  LTemp: TVarData;
begin
  if VarDataIsStr(Source) then begin
    BigInteger(Variant(Dest), VarToStr(Variant(Source)));
  end
  else begin
    VarDataInit(LTemp);
    try
      VarDataCastTo(LTemp, Source, varInt64);
      BigInteger(Variant(Dest), LTemp.VInt64);
    finally
      VarDataClear(LTemp);
    end;
  end;
end;

procedure TBiVariantType.CastTo(var Dest: TVarData;
  const Source: TVarData; const AVarType: TVarType);
var
  S: AnsiString;
begin
  if Source.VType = VarType then begin
    S := BigIntToString(Variant(Source));
    case AVarType of
      varOleStr:
        VarDataFromOleStr(Dest, WideString(StringToOleStr(S)));
      varString{$IFDEF DELPHI2009_UP}, varUString{$ENDIF}:
        VarDataFromStr(Dest, string(S));
    else
      RaiseCastError;
    end
  end
  else
    RaiseCastError;
end;

procedure TBiVariantType.Clear(var V: TVarData);
begin
  V.VType := varEmpty;
  FreeMem(TBiVarData(V).VData);
  TBiVarData(V).VData := nil;
  TBiVarData(V).VLength := 0;
end;

procedure TBiVariantType.Compare(const Left, Right: TVarData;
  var Relationship: TVarCompareResult);
var
  L, R: TBiVarData;
begin
  if (Left.VType = VarType) and (Right.VType = VarType) then begin
    L := TBiVarData(Left);
    R := TBiVarData(Right);
    Relationship := BigInt.Compare(L, R);
  end
  else RaiseInvalidOp;
end;

procedure TBiVariantType.Copy(var Dest: TVarData;
  const Source: TVarData; const Indirect: Boolean);
begin
  if Indirect and VarDataIsByRef(Source) then
    VarDataCopyNoInd(Dest, Source)
  else
    VarDataClear(Dest);
  Dest.VType := VarType;
  TBiVarData(Dest).VLength := TBiVarData(Source).VLength;
  GetMem(TBiVarData(Dest).VData, SizeOf(LongWord) * TBiVarData(Dest).VLength);
  Move(TBiVarData(Source).VData^, TBiVarData(Dest).VData^, SizeOf(LongWord) * TBiVarData(Dest).VLength);
end;

function TBiVariantType.IsClear(const V: TVarData): Boolean;
begin
  Result := (TBiVarData(V).VData = nil) and (TBiVarData(V).VLength = 0);
end;

initialization
  Randomize;
  BiVariantType := TBiVariantType.Create;
finalization
  FreeAndNil(BiVariantType);
end.
