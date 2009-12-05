{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| DHParams.pas                                             |
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

/* Diffie-Hellman Parameters for PHPRPC.
 *
 * Copyright: Chen fei <cf850118@163.com>
 * Version: 3.0.2
 * LastModified: Oct 30, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */
}

unit DHParams;

{$I PHPRPC.inc}

interface

uses
  Classes, SysUtils, Variants, Types,
  PHPRPC;

type

  { TDHParams }

  TDHParams = class
  private
    FLen: Integer;
    FDHParams: THashMap;
    function GetNearest(Len: Integer): Integer;
    function GetDHParams(Len: Integer): THashMap;
    function GetP: Variant;
    function GetG: Variant;
    function GetX: Variant;
  public
    constructor Create(Len: Integer);
    destructor Destroy; override;
    property Len: Integer read FLen;
    property DHParams: THashMap read FDHParams;
    property P: Variant read GetP;
    property G: Variant read GetG;
    property X: Variant read GetX;
  end;

implementation

uses
  BigInt;

var
  KeyLengths:  TIntegerDynArray;
  DHParamsGen: THashMap;

{ TDHParams }

constructor TDHParams.Create(Len: Integer);
begin
  FLen := GetNearest(Len);
  FDHParams := GetDHParams(FLen);
end;

destructor TDHParams.Destroy;
begin
  FDHParams.Free;
  inherited;
end;

function TDHParams.GetNearest(Len: Integer): Integer;
var
  I, J, M, T: Integer;
begin
  J := 0;
  M := Abs(KeyLengths[0] - Len);
  for I := 0 to Length(KeyLengths) - 1 do
  begin
    T := Abs(KeyLengths[I] - Len);
    if M > T then
    begin
      M := T;
      J := I;
    end;
  end;
  Result := KeyLengths[J];
end;

function TDHParams.GetDHParams(Len: Integer): THashMap;
var
  DHParamsList: THashMap;
begin
  DHParamsList := THashMap(PHPObject(DHParamsGen[FLen]));
  Randomize;
  Result := THashMap.Create(DHParamsList[Random(DHParamsList.Count)]);
end;

function TDHParams.GetP: Variant;
begin
  Result := FDHParams['p'];
end;

function TDHParams.GetG: Variant;
begin
  Result := FDHParams['g'];
end;

function TDHParams.GetX: Variant;
begin
  Randomize;
  Result := Rand(FLen - 1, True);
end;

procedure Initialze;
const
  AllKeyLengths: array[0..11] of Integer = (96, 128, 160, 192, 256, 512, 768, 1024, 1536, 2048, 3072, 4096);
var
  I, J: Integer;
  FileName: string;
  FS: TFileStream;
  ParamStr: AnsiString;
begin
  SetLength(KeyLengths, 12);
  DHParamsGen := THashMap.Create;
  J := 0;
  for I := 0 to Length(AllKeyLengths) - 1 do
  begin
    FileName := Format('dhparams\%d.dhp', [AllKeyLengths[I]]);
    if FileExists(FileName) then
    begin
      FS := TFileStream.Create(FileName, fmOpenRead);
      try
        SetLength(ParamStr, FS.Size);
        FS.Read(PAnsiChar(ParamStr)^, Length(ParamStr));
        DHParamsGen[AllKeyLengths[I]] := UnSerialize(ParamStr, False);
        KeyLengths[J] := AllKeyLengths[I];
        Inc(J);
      finally
        FS.Free;
      end;
    end;
  end;
end;

procedure Finalize;
var
  I: Integer;
begin
  if Assigned(DHParamsGen) then
  begin
    for I := 0 to Length(KeyLengths) - 1 do
    begin
      if DHParamsGen.ContainsKey(KeyLengths[I]) then
        DHParamsGen[KeyLengths[I]].Free;
    end;
    DHParamsGen.Free;
  end;
end;

initialization
  Initialze;
finalization
  Finalize;
end.
