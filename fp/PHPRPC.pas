{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC.pas                                               |
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

/* PHPRPC Library.
 *
 * Copyright (C) 2005-2008 Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.1
 * LastModified: Dec 28, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */
}

unit PHPRPC;

{$IFDEF VER130}
  Not Support Delphi 5
{$ENDIF}
{$IFDEF VER120}
  Not Support Delphi 4
{$ENDIF}
{$IFDEF VER100}
  Not Support Delphi 3
{$ENDIF}
{$IFDEF VER90}
  Not Support Delphi 2
{$ENDIF}
{$IFDEF VER80}
  Not Support Delphi 1
{$ENDIF}

{$IFDEF VER200}
  {$DEFINE DELPHI2009}
{$ENDIF}

interface

uses
  Classes, IdHTTP, IdHTTPHeaderInfo, Types, TypInfo, Variants, SysUtils;

type

{$IFNDEF DELPHI2009}
  RawByteString = type AnsiString;
{$ENDIF}

  TVariantDynArray = array of Variant;

  TStringBuffer = class;

  TArrayList = class;

  TPHPClass = class of TPHPObject;

  {$M+}
  ISerializable = interface
    ['{2523DF0D-A532-4CF9-AA96-C60DA18E21A4}']
    function Serialize: RawByteString;
    procedure UnSerialize(ss: RawByteString);
  end;

  TPHPObject = class(TComponent)
  private
    function GetProp(const Name: String): Variant;
    procedure SetProp(const Name: String; const Value: Variant);
  protected
    function DoFunction(var Dest: TVarData; const Name: string;
      const Arguments: TVarDataArray): Boolean; virtual;
    function DoProcedure(const Name: string;
      const Arguments: TVarDataArray): Boolean; virtual;
    function DoSerialize(const Buffer: TStringBuffer = nil;
      const ObjectContainer: TArrayList = nil): RawByteString; virtual;
    procedure DoUnSerialize(const Buffer: TStringBuffer;
      const ObjectContainer: TArrayList; StringAsByteArray: Boolean); virtual;
    function GetProperty(var Dest: TVarData;
      const Name: string): Boolean; virtual;
    function SetProperty(const Name: string;
      const Value: TVarData): Boolean; virtual;
    function __sleep: TStringDynArray; virtual;
    procedure __wakeup; virtual;
    function ToBoolean: Boolean; virtual;
    function ToDate: TDateTime; virtual;
    function ToDouble: Double; virtual;
    function ToInt64: Int64; virtual;
    function ToInteger: Integer; virtual;
  public
    function Equal(const Right: TPHPObject): Boolean; overload; virtual;
    class function Equal(const Left, Right: Variant): Boolean; overload;
    constructor Create; reintroduce; overload; virtual;
    class function New: Variant;
    class function FromVariant(const V: Variant): TPHPObject;
    class function AliasName: string;
    class function GetClass(const AliasName: string): TPHPClass;
    class procedure RegisterClass(const AliasName: string = '');
    procedure MoveComponentsTo(AComponent: TComponent);
    function HashCode: Integer; virtual;
    function ToString: string; {$IFDEF DELPHI2009}override{$ELSE}virtual{$ENDIF};
    function ToVariant: Variant; virtual;
    property Properties[const Name: string]: Variant read GetProp write SetProp; default;
  end;
  {$M-}

  TStringBuffer = class(TPHPObject)
  private
    FDataString: RawByteString;
    FPosition: Integer;
    FCapacity: Integer;
    FLength: Integer;
    procedure Grow;
    procedure SetPosition(NewPosition: Integer);    
    procedure SetCapacity(NewCapacity: Integer);
  protected
    function DoFunction(var Dest: TVarData; const Name: string;
      const Arguments: TVarDataArray): Boolean; override;
    function DoProcedure(const Name: string;
      const Arguments: TVarDataArray): Boolean; override;
    function DoSerialize(const Buffer: TStringBuffer = nil;
      const ObjectContainer: TArrayList = nil): RawByteString; override;
    procedure DoUnSerialize(const Buffer: TStringBuffer;
      const ObjectContainer: TArrayList; StringAsByteArray: Boolean); override;
  public
    constructor Create; overload; override;
    constructor Create(Capacity: Integer); reintroduce; overload;
    constructor Create(const AString: RawByteString); reintroduce; overload;
    class function New(Capacity: Integer): Variant; overload;
    class function New(const AString: RawByteString): Variant; overload;
    function Read(var Buffer; Count: Longint): Longint;
    function ReadString(Count: Longint): RawByteString;
    function Write(const Buffer; Count: Longint): Longint;
    procedure WriteString(const AString: RawByteString);
    function Insert(const Buffer; Count: Longint): Longint;
    procedure InsertString(const AString: RawByteString);
    function Seek(Offset: Longint; Origin: Word): Longint;
    function ToString: string; override;
    {$IFDEF DELPHI2009}
    function ToRawByteString: RawByteString;
    {$ENDIF}
  published
    property Position: Integer read FPosition write SetPosition;
    property Length: Integer read FLength;
    property Capacity: Integer read FCapacity write SetCapacity;
    property DataString: RawByteString read FDataString;
  end;

  TArrayList = class(TPHPObject)
  private
    FCount: Integer;
    FCapacity: Integer;
    FList: TVariantDynArray;
  protected
    function DoFunction(var Dest: TVarData; const Name: string;
      const Arguments: TVarDataArray): Boolean; override;
    function DoProcedure(const Name: string;
      const Arguments: TVarDataArray): Boolean; override;
    function DoSerialize(const Buffer: TStringBuffer = nil;
      const ObjectContainer: TArrayList = nil): RawByteString; override;
    procedure DoUnSerialize(const Buffer: TStringBuffer;
      const ObjectContainer: TArrayList; StringAsByteArray: Boolean); override;
    function Get(Index: Integer): Variant; virtual;
    function GetList: TVariantDynArray; virtual;
    procedure Grow; virtual;
    procedure Put(Index: Integer; const Value: Variant); virtual;
    procedure SetCapacity(NewCapacity: Integer); virtual;
    procedure SetCount(NewCount: Integer); virtual;
    procedure SetList(const Value: TVariantDynArray); virtual;
  public
    constructor Create; overload; override;
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(Capacity: Integer; AOwner: TComponent = nil); reintroduce; overload; virtual;
    constructor Create(const ArrayList: TArrayList; AOwner: TComponent = nil); reintroduce; overload; virtual;
    destructor Destroy; override;
    class function New(Capacity: Integer): Variant; overload;
    class function New(const ArrayList: TArrayList): Variant; overload;
    function Add(const Value: Variant): Integer; virtual;
    procedure AddAll(const ArrayList: TArrayList); overload; virtual;
    procedure AddAll(const Container: Variant); overload; virtual;
    procedure Clear; virtual;
    function Contains(const Value: Variant): Boolean; virtual;
    function Delete(Index: Integer): Variant; virtual;
    procedure Exchange(Index1, Index2: Integer); virtual;
    function IndexOf(const Value: Variant): Integer; virtual;
    procedure Insert(Index: Integer; const Value: Variant); virtual;
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    function Remove(const Value: Variant): Integer; virtual;
    property Items[Index: Integer]: Variant read Get write Put; default;
    property List: TVariantDynArray read GetList write SetList;
  published
    property Count: Integer read FCount write SetCount;
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

  PHashItem = ^THashItem;

  THashItem = record
    Next: PHashItem;
    Index: Integer;
    HashCode: Integer;
  end;

  THashItemDynArray = array of PHashItem;

  TIndexCompareMethod = function (Index: Integer; const Value: Variant): Boolean of object;

  THashBucket = class
  private
    FCount: Integer;
    FCapacity: Integer;
    FIndices: THashItemDynArray;
    procedure Grow;
    procedure SetCapacity(NewCapacity: Integer);
  public
    constructor Create(Capacity: Integer = 4); overload;
    destructor Destroy; override;
    function Add(Hash, Index: Integer): PHashItem;
    procedure Clear;
    procedure Delete(Hash, Index: Integer);
    function IndexOf(Hash: Integer; const Value: Variant; CompareProc: TIndexCompareMethod): Integer;
    function Modify(OldHash, NewHash, Index: Integer): PHashItem;
    property Count: Integer read FCount;
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

  THashedArrayList = class(TArrayList)
  private
    FHashBucket: THashBucket;
    function IndexCompare(Index: Integer; const Value: Variant): Boolean;
  protected
    procedure Put(Index: Integer; const Value: Variant); override;
    procedure SetList(const Value: TVariantDynArray); override;
  public
    constructor Create(Capacity: Integer; AOwner: TComponent = nil); overload; override;
    constructor Create(const ArrayList: TArrayList; AOwner: TComponent = nil); overload; override;
    destructor Destroy; override;
    function Add(const Value: Variant): Integer; override;
    procedure Clear; override;
    function Delete(Index: Integer): Variant; override;
    procedure Exchange(Index1, Index2: Integer); override;
    function IndexOf(const Value: Variant): Integer; override;
    procedure Insert(Index: Integer; const Value: Variant); override;
  end;

  THashMap = class(TPHPObject)
  private
    FRefCount: Integer;
    FKeys: TArrayList;
    FValues: TArrayList;
    function GetCount: Integer;
  protected
    function DoFunction(var Dest: TVarData; const Name: string;
      const Arguments: TVarDataArray): Boolean; override;
    function DoProcedure(const Name: string;
      const Arguments: TVarDataArray): Boolean; override;
    function DoSerialize(const Buffer: TStringBuffer = nil;
      const ObjectContainer: TArrayList = nil): RawByteString; override;
    procedure DoUnSerialize(const Buffer: TStringBuffer;
      const ObjectContainer: TArrayList; StringAsByteArray: Boolean); override;
    function Get(const Key: Variant): Variant; virtual;
    procedure Put(const Key, Value: Variant); virtual;
  public
    procedure AfterConstruction; override;
    constructor Create; overload; override;
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(Capacity: Integer; AOwner: TComponent = nil); reintroduce; overload; virtual;
    constructor Create(const ArrayList: TArrayList; AOwner: TComponent = nil); reintroduce; overload; virtual;
    constructor Create(const HashMap: THashMap; AOwner: TComponent = nil); reintroduce; overload; virtual;
    constructor Create(const Container: Variant; AOwner: TComponent = nil); reintroduce; overload; virtual;
    destructor Destroy; override;
    procedure Clear; virtual;
    function ContainsKey(const Key: Variant): Boolean; virtual;
    function ContainsValue(const Value: Variant): Boolean; virtual;
    class function New(Capacity: Integer): Variant; overload;
    class function New(const ArrayList: TArrayList): Variant; overload;
    class function New(const HashMap: THashMap): Variant; overload;
    class function New(const Container: Variant): Variant; overload;
    procedure PutAll(const ArrayList: TArrayList); overload; virtual;
    procedure PutAll(const HashMap: THashMap); overload; virtual;
    procedure PutAll(const Container: Variant); overload; virtual;
    function Delete(const Key: Variant): Variant; virtual;
    function ToArrayList: TArrayList; virtual;
    property Items[const Key: Variant]: Variant read Get write Put; default;
  published
    property Count: Integer read GetCount;
    property Keys: TArrayList read FKeys;
    property Values: TArrayList read FValues;
  end;

  ESerializeError = class(Exception);
  EUnSerializeError = class(Exception);
  EHashBucketError = class(Exception);
  EArrayListError = class(Exception);

  TPHPRPC_Error = class(TPHPObject)
  private
    FNumber: Integer;
    FMessage: string;
  public
    constructor Create(ErrNo: Integer; const ErrStr: string); reintroduce; overload;
    function ToString: string; override;
  published
    property Number: Integer read FNumber write FNumber;
    property Message: string read FMessage write FMessage;
  end;

  TPHPRPC_Client = class(TPHPObject)
  private
    FIdHTTP: TIdHTTP;
    FURL: string;
    FKey: RawByteString;
    FKeyLength: Integer;
    FEncryptMode: Integer;
    FCharset: string;
    FOutput: RawByteString;
    FWarning: TPHPRPC_Error;
    FVersion: Currency;
    FStringAsByteArray: Boolean;
    procedure SetKeyLength(Value: Integer);
    procedure SetEncryptMode(Value: Integer);
    procedure SetCharset(const Value: string);
    function GetProxy: TIdProxyConnectionInfo;
    procedure SetProxy(const Value: TIdProxyConnectionInfo);
    function GetTimeout: Integer;
    procedure SetTimeout(const Value: Integer);
    procedure SetURL(const Value: string);
    procedure KeyExchange;
    function Post(const ReqStr: RawByteString): THashMap;
    function Decrypt(const Data: RawByteString; Level: Integer): RawByteString;
    function Encrypt(const Data: RawByteString; Level: Integer): RawByteString;
  protected
    function DoFunction(var Dest: TVarData; const Name: string;
      const Arguments: TVarDataArray): Boolean; override;
  public
    constructor Create(); overload; override;
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(const AURL: string; AOwner: TComponent = nil); reintroduce; overload;
    destructor Destroy; override;
    function UseService(const AURL: string): Variant; overload;
    function Invoke(const FuncName: string; const Args: TVariantDynArray; byRef: boolean = False): Variant;
    property Output: RawByteString read FOutput;
    property Warning: TPHPRPC_Error read FWarning;
  published
    property KeyLength: Integer read FKeyLength write SetKeyLength default 128;
    property EncryptMode: Integer read FEncryptMode write SetEncryptMode default 0;
    property Charset: string read FCharset write SetCharset;
    property Proxy: TIdProxyConnectionInfo read GetProxy write SetProxy;
    property URL: string read FURL write SetURL;
    property Timeout: Integer read GetTimeout write SetTimeout;
    property StringAsByteArray: Boolean read FStringAsByteArray write FStringAsByteArray default False;
  end;

const
  IID_ISerializeble: TGUID = '{2523DF0D-A532-4CF9-AA96-C60DA18E21A4}';

function HashOf(const Value: Variant): Integer; overload;

function VarPHP: TVarType;
function VarIsPHPObject(const V: Variant): Boolean;
function PHPObject(const V: Variant): TPHPObject;
function VariantRef(const V: Variant): Variant;

function Serialize(const V: Variant): RawByteString; overload;
function Serialize(const V: TVariantDynArray): RawByteString; overload;
function UnSerialize(const Data: RawByteString; StringAsByteArray: Boolean):Variant; overload;

function GetPropValue(Instance: TObject; const PropName: string;
  PreferStrings: Boolean = True): Variant; overload;
function GetPropValue(Instance: TObject; PropInfo: PPropInfo;
  PreferStrings: Boolean = True): Variant; overload;

procedure SetPropValue(Instance: TObject; const PropName: string;
  const Value: Variant); overload;
procedure SetPropValue(Instance: TObject; PropInfo: PPropInfo;
  const Value: Variant); overload;

function ByteArrayToString(const ByteArray: Variant): RawByteString;
function StringToByteArray(const S: Variant): Variant;

procedure Register;

implementation

uses
  BigInt, DateUtils, Math, RTLConsts
  , StrUtils, SysConst, VarUtils, XXTEA
{$IFDEF MSWINDOWS}
  , Windows
{$ENDIF};

type

  TPHPVarData = packed record
    VType: TVarType;
    Reserved1, Reserved2, Reserved3: Word;
    VObject: TPHPObject;
    Reserved4: LongInt;
  end;

  TPHPVariantType = class(TCustomVariantType)
  protected
    procedure DispInvoke(Dest: PVarData; const Source: TVarData;
      CallDesc: PCallDesc; Params: Pointer); override;
  public
    procedure CastTo(var Dest: TVarData; const Source: TVarData;
      const AVarType: TVarType); override;
    procedure Clear(var V: TVarData); override;
    function CompareOp(const Left, Right: TVarData;
      const Operation: TVarOp): Boolean; override;
    procedure Copy(var Dest: TVarData; const Source: TVarData;
      const Indirect: Boolean); override;
    function IsClear(const V: TVarData): Boolean; override;
    { IVarInvokeable }
    function DoFunction(var Dest: TVarData; const V: TVarData;
      const Name: string; const Arguments: TVarDataArray): Boolean; virtual;
    function DoProcedure(const V: TVarData; const Name: string;
      const Arguments: TVarDataArray): Boolean; virtual;
    function GetProperty(var Dest: TVarData; const V: TVarData;
      const Name: string): Boolean; virtual;
    function SetProperty(const V: TVarData; const Name: string;
      const Value: TVarData): Boolean; virtual;
  end;

  TAccessStyle = (asFieldData, asAccessor, asIndexedAccessor);

var
  PHPClassList: THashMap = nil;
  PHPVariantType: TPHPVariantType = nil;

{ MD5 }

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
  for I := 0 to Len - 1 do begin
    Result[I shr 2] := Result[I shr 2] or (LongWord(Ord(Data[I + 1])) shl ((I and 3) shl 3));
  end;
  Result[Len shr 2] := Result[Len shr 2] or (LongWord($00000080) shl ((Len and 3) shl 3));
  Result[Count - 2] := (Len and $1fffffff) shl 3;
  Result[Count - 1] := Len shr 29;
end;

function ROL(const AVal: LongWord; AShift: Byte): LongWord;
begin
   Result := (AVal shl AShift) or (AVal shr (32 - AShift));
end;

function RawMD5(const Data: RawByteString): RawByteString;
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
  while I < Count do begin
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

{ Base 64 }
const

  Base64EncodeChars: array[0..63] of Char = (
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3',
    '4', '5', '6', '7', '8', '9', '+', '/');

  Base64DecodeChars: array[0..255] of SmallInt = (
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
    -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
    -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);

function Base64Encode(const Data:RawByteString):string;
var
  R, Len, I, J, L : Longint;
  C : LongWord;
begin
  Result := '';
  Len := Length(Data);
  if Len = 0 then Exit;
  R := Len mod 3;
  Dec(Len, R);
  L := (Len div 3) * 4;
  if (R > 0) then Inc(L, 4);
  SetLength(Result, L);
  I := 1;
  J := 1;
  while (I <= Len) do begin
    C := Ord(Data[I]);
    Inc(I);
    C := (C shl 8) or Ord(Data[I]);
    Inc(I);
    C := (C shl 8) or Ord(Data[I]);
    Inc(I);
    Result[J] := Base64EncodeChars[C shr 18];
    Inc(J);
    Result[J] := Base64EncodeChars[(C shr 12) and $3F];
    Inc(J);
    Result[J] := Base64EncodeChars[(C shr 6) and $3F];
    Inc(J);
    Result[J] := Base64EncodeChars[C and $3F];
    Inc(J);
  end;
  if (R = 1) then begin
    C := Ord(Data[I]);
    Result[J] := Base64EncodeChars[C shr 2];
    Inc(J);
    Result[J] := Base64EncodeChars[(C and $03) shl 4];
    Inc(J);
    Result[J] := '=';
    Inc(J);
    Result[J] := '=';
  end
  else if (R = 2) then begin
    C := Ord(Data[I]);
    Inc(I);
    C := (C shl 8) or Ord(Data[I]);
    Result[J] := Base64EncodeChars[C shr 10];
    Inc(J);
    Result[J] := Base64EncodeChars[(C shr 4) and $3F];
    Inc(J);
    Result[J] := Base64EncodeChars[(C and $0F) shl 2];
    Inc(J);
    Result[J] := '=';
  end;
end;

function Base64Decode(const Data:string):RawByteString;
var
  R, Len, I, J, L : Longint;
  B1, B2, B3, B4: SmallInt;
begin
  Result := '';
  Len := Length(Data);
  if (Len = 0) or (Len mod 4 > 0) then Exit;
  R := 0;
  if (Data[Len - 1] = '=') then R := 1 else if (Data[Len] = '=') then R := 2;
  L := Len;
  if (R > 0) then Dec(L, 4);
  L := (L div 4) * 3;
  Inc(L, R);
  SetLength(Result, L);
  I := 1;
  J := 1;
  while (I <= Len) do begin
    repeat
      B1 := Base64DecodeChars[Ord(Data[I])];
      Inc(I);
    until ((I > Len) or (B1 <> -1));
    if (B1 = -1) then Break;

    repeat
      B2 := Base64DecodeChars[Ord(Data[I])];
      Inc(I);
    until ((I > Len) or (B2 <> -1));
    if (B2 = -1) then Break;

    Result[J] := AnsiChar((B1 shl 2) or ((B2 and $30) shr 4));
    Inc(J);

    repeat
      if (Data[I] = '=') then Exit;
      B3 := Base64DecodeChars[Ord(Data[I])];
      Inc(I);
    until ((I > Len) or (B3 <> -1));
    if (B3 = -1) then Break;

    Result[J] := AnsiChar(((B2 and $0F) shl 4) or ((B3 and $3C) shr 2));
    Inc(J);

    repeat
      if (Data[I] = '=') then Exit;
      B4 := Base64DecodeChars[Ord(Data[I])];
      Inc(I);
    until ((I > Len) or (B4 <> -1));
    if (B4 = -1) then Break;
    Result[J] := AnsiChar(((B3 and $03) shl 6) or B4);
    Inc(J);
  end;
end;

{ private functions and procedures }

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

function HashOfString(const Value: string): Integer; overload;
var
  I: Integer;
begin
	Result := 0;
  for I := 1 to Length(Value) do
    Result := ((Result shl 2) or (Result shr 30)) xor Ord(Value[I]);
end;

function HashOfString(const Value: WideString): Integer; overload;
var
  I: Integer;
begin
	Result := 0;
  for I := 1 to Length(Value) do
    Result := ((Result shl 2) or (Result shr 30)) xor Ord(Value[I]);
end;

{ GetPropValue/SetPropValue }

procedure PropertyNotFound(const Name: string);
begin
  raise EPropertyError.CreateResFmt(@SUnknownProperty, [Name]);
end;

procedure PropertyConvertError(const Name: AnsiString);
begin
  raise EPropertyConvertError.CreateResFmt(@SInvalidPropertyType, [Name]);
end;

function GetPropValue(Instance: TObject; PropInfo: PPropInfo;
  PreferStrings: Boolean = True): Variant; overload;
var
  TypeData: PTypeData;
begin
  // assume failure
  Result := Null;

  if PropInfo <> nil then
    case PropInfo^.PropType^.Kind of
      tkInteger, tkWChar:
        Result := GetOrdProp(Instance, PropInfo);
      tkChar:
        Result := Char(GetOrdProp(Instance, PropInfo));
      tkEnumeration:
        if PreferStrings then
          Result := GetEnumProp(Instance, PropInfo)
        else if GetTypeData(PropInfo^.PropType).BaseType^.Kind = tkBool then
          Result := Boolean(GetOrdProp(Instance, PropInfo))
        else
          Result := GetOrdProp(Instance, PropInfo);
      tkSet:
        if PreferStrings then
          Result := GetSetProp(Instance, PropInfo, False)
        else
          Result := GetOrdProp(Instance, PropInfo);
      tkFloat:
        Result := GetFloatProp(Instance, PropInfo);
      tkString, tkLString{$IFDEF DELPHI2009}, tkUString{$ENDIF}:
        Result := GetStrProp(Instance, PropInfo);
      tkWString:
        Result := GetWideStrProp(Instance, PropInfo);
      tkVariant:
        Result := GetVariantProp(Instance, PropInfo);
      tkInt64:
        Result := GetInt64Prop(Instance, PropInfo);
      tkClass: if GetOrdProp(Instance, PropInfo) = 0 then
        Result := Null
      else begin
        TypeData := GetTypeData(PropInfo^.PropType);
        if TypeData^.ClassType.InheritsFrom(TPHPObject) then
          Result := TPHPObject(GetOrdProp(Instance, PropInfo)).ToVariant
        else
          PropertyConvertError(PropInfo.PropType^.Name);
      end;
    else
      PropertyConvertError(PropInfo.PropType^.Name);
    end;
end;

function GetPropValue(Instance: TObject; const PropName: string;
  PreferStrings: Boolean = True): Variant; overload;
var
  PropInfo: PPropInfo;
begin
  Result := Null;
  PropInfo := GetPropInfo(Instance, PropName);
  if PropInfo = nil then
    PropertyNotFound(PropName)
  else
    Result := PHPRPC.GetPropValue(Instance, PropInfo, PreferStrings);
end;

procedure SetPropValue(Instance: TObject; PropInfo: PPropInfo;
  const Value: Variant); overload;
  function RangedValue(const AMin, AMax: Int64): Int64;
  begin
    Result := Trunc(Value);
    if (Result < AMin) or (Result > AMax) then
      raise ERangeError.CreateRes(@SRangeError);
  end;

var
  TypeData: PTypeData;
  DynArray: TVariantDynArray;
  Temp: TPHPObject;
begin
  DynArray := nil;
  if PropInfo <> nil then begin
    TypeData := GetTypeData(PropInfo^.PropType);

    // set the right type
    case PropInfo.PropType^.Kind of
      tkInteger, tkWChar:
        if TypeData^.MinValue < TypeData^.MaxValue then
          SetOrdProp(Instance, PropInfo, RangedValue(TypeData^.MinValue,
            TypeData^.MaxValue))
        else
          // Unsigned type
          SetOrdProp(Instance, PropInfo,
            RangedValue(LongWord(TypeData^.MinValue),
            LongWord(TypeData^.MaxValue)));
      tkChar:
        if (VarType(Value) = varString){$IFDEF DELPHI2009} or (VarType(Value) = varUString){$ENDIF} then
          SetOrdProp(Instance, PropInfo, Ord(VarToStr(Value)[1]))
        else if VarType(Value) = varBoolean then
          SetOrdProp(Instance, PropInfo, Abs(Trunc(Value)))
        else
          SetOrdProp(Instance, PropInfo, RangedValue(TypeData^.MinValue,
            TypeData^.MaxValue));
      tkEnumeration:
        if (VarType(Value) = varString){$IFDEF DELPHI2009} or (VarType(Value) = varUString){$ENDIF} then
          SetEnumProp(Instance, PropInfo, VarToStr(Value))
        else if VarType(Value) = varBoolean then
          // Need to map variant boolean values -1,0 to 1,0
          SetOrdProp(Instance, PropInfo, Abs(Trunc(Value)))
        else
          SetOrdProp(Instance, PropInfo, RangedValue(TypeData^.MinValue,
            TypeData^.MaxValue));
      tkSet:
        if VarType(Value) = varInteger then
          SetOrdProp(Instance, PropInfo, Value)
        else
          SetSetProp(Instance, PropInfo, VarToStr(Value));
      tkFloat:
        SetFloatProp(Instance, PropInfo, Value);
      tkString, tkLString{$IFDEF DELPHI2009}, tkUString{$ENDIF}:
        if VarIsArray(Value) then
          SetStrProp(Instance, PropInfo, string(ByteArrayToString(Value)))
        else
          SetStrProp(Instance, PropInfo, VarToStr(Value));
      tkWString:
        SetWideStrProp(Instance, PropInfo, VarToWideStr(Value));
      tkVariant:
        SetVariantProp(Instance, PropInfo, Value);
      tkInt64:
        SetInt64Prop(Instance, PropInfo, RangedValue(TypeData^.MinInt64Value,
          TypeData^.MaxInt64Value));
      tkClass: if VarIsNull(Value) then
        SetOrdProp(Instance, PropInfo, 0)
      else if VarIsPHPObject(Value) then begin
        Temp := TPHPObject.FromVariant(Value);
        if (Temp is THashMap) and (TypeData^.ClassType = TArrayList) then begin
          SetOrdProp(Instance, PropInfo, Integer(THashMap(Temp).ToArrayList));
          Dec(THashMap(Temp).FRefCount);
        end
        else if (Temp.ClassType.InheritsFrom(TypeData^.ClassType)) then
          SetOrdProp(Instance, PropInfo, Integer(Temp))
        else
          PropertyConvertError(PropInfo.PropType^.Name);
      end
      else
        PropertyConvertError(PropInfo.PropType^.Name);
    else
      PropertyConvertError(PropInfo.PropType^.Name);
    end;
  end;
end;

procedure SetPropValue(Instance: TObject; const PropName: string;
  const Value: Variant); overload;
var
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(Instance, PropName);
  if PropInfo = nil then
    PropertyNotFound(PropName)
  else
  PHPRPC.SetPropValue(Instance, PropInfo, Value);
end;

{ Serialize }

procedure Serialize(const Buffer: TStringBuffer; const V: Variant;
  const ObjectContainer: TArrayList); overload; forward;

procedure SerializeNull(const Buffer: TStringBuffer);
begin
  Buffer.WriteString('N;');
end;

procedure SerializePointerRef(const Buffer: TStringBuffer; V: Integer);
begin
  Buffer.WriteString('R:' + RawByteString(IntToStr(V)) + ';');
end;

procedure SerializeRef(const Buffer: TStringBuffer; V: Integer);
begin
  Buffer.WriteString('r:' + RawByteString(IntToStr(V)) + ';');
end;

procedure SerializeInt(const Buffer: TStringBuffer; V: Integer);
begin
  Buffer.WriteString('i:' + RawByteString(IntToStr(V)) + ';');
end;

procedure SerializeInt64(const Buffer: TStringBuffer; V: Int64);
begin
  if (V > MaxInt) or (V < Low(Longint)) then Buffer.WriteString('d:' + RawByteString(IntToStr(V)) + ';')
  else Buffer.WriteString('i:' + RawByteString(IntToStr(V)) + ';');
end;

procedure SerializeDouble(const Buffer: TStringBuffer; V: Double);
begin
  Buffer.WriteString('d:' + RawByteString(Format('%g', [V])) + ';');
end;

procedure SerializeCurrency(const Buffer: TStringBuffer; V: Currency);
begin
  Buffer.WriteString('d:' + RawByteString(CurrToStr(V)) + ';');
end;

procedure SerializeBoolean(const Buffer: TStringBuffer; V: Boolean);
begin
  if V then Buffer.WriteString('b:1;') else Buffer.WriteString('b:0;');
end;

procedure SerializeString(const Buffer: TStringBuffer; const V: RawByteString); overload;
begin
  Buffer.WriteString('s:' + RawByteString(IntToStr(Length(V))) + ':"' + V + '";');
end;

procedure SerializeString(const Buffer: TStringBuffer; const V: WideString); overload;
var
  I: Integer;
begin
  Buffer.WriteString('U:' + RawByteString(IntToStr(Length(V))) + ':"');
  for I := 1 to Length(V) do
    if Ord(V[I]) > 127 then
      Buffer.WriteString('\' + RawByteString(IntToHex(Ord(V[I]), 4)))
    else
      Buffer.WriteString(AnsiChar(V[I]));
  Buffer.WriteString('";');
end;

procedure SerializeByteArray(const Buffer: TStringBuffer; const V: Variant);
var
  Size: Integer;
  P: Pointer;
begin
  Size := VarArrayHighBound (V, 1) - VarArrayLowBound(V,  1) + 1;
  Buffer.WriteString('s:' + RawByteString(IntToStr(Size)) + ':"');
  P := VarArrayLock(V);
  Buffer.Write(P^, Size);
  VarArrayUnLock(V);
  Buffer.WriteString('";');
end;

procedure SerializeDateTime(const Buffer: TStringBuffer; const V: TDateTime);
begin
  Buffer.WriteString('O:11:"PHPRPC_Date":7:{');
  SerializeString(Buffer, 'year');
  SerializeInt(Buffer, YearOf(V));
  SerializeString(Buffer, 'month');
  SerializeInt(Buffer, MonthOf(V));
  SerializeString(Buffer, 'day');
  SerializeInt(Buffer, DayOf(V));
  SerializeString(Buffer, 'hour');
  SerializeInt(Buffer, HourOf(V));
  SerializeString(Buffer, 'minute');
  SerializeInt(Buffer, MinuteOf(V));
  SerializeString(Buffer, 'second');
  SerializeInt(Buffer, SecondOf(V));
  SerializeString(Buffer, 'millisecond');
  SerializeInt(Buffer, MilliSecondOf(V));
  Buffer.WriteString('}');
end;

procedure SerializeArray(const Buffer: TStringBuffer; const V: TVariantDynArray;
  const ObjectContainer: TArrayList); overload;
var
  I, Len: Integer;
begin
  Len := Length(V);
  Buffer.WriteString('a:' + RawByteString(IntToStr(Len)) + ':{');
  for I := 0 to Len - 1 do begin
    SerializeInt(Buffer, I);
    Serialize(Buffer, V[I], ObjectContainer);
  end;
  Buffer.WriteString('}');
end;

procedure SerializeArray(const Buffer: TStringBuffer; const V: Variant;
  const ObjectContainer: TArrayList); overload;
var
  I, Len: Integer;
  DynArray: TVariantDynArray;
begin
  if VarArrayDimCount(V) > 1 then raise ESerializeError.Create('Only single dimension arrays are supported here.');
  DynArrayFromVariant(Pointer(DynArray), V, TypeInfo(TVariantDynArray));
  Len := Length(DynArray);
  Buffer.WriteString('a:' + RawByteString(IntToStr(Len)) + ':{');
  for I := 0 to Len - 1 do begin
    SerializeInt(Buffer, I);
    Serialize(Buffer, DynArray[I], ObjectContainer);
  end;
  Buffer.WriteString('}');
end;

procedure Serialize(const Buffer: TStringBuffer; const V: Variant;
  const ObjectContainer: TArrayList); overload;
var
  P: PVarData;
  T: Variant;
  ObjectID, Index: Integer;
begin
  ObjectID := ObjectContainer.Count;
  ObjectContainer.Count := ObjectID + 1;
  P := FindVarData(V);
  case P.VType of
    varEmpty, varNull: SerializeNull(Buffer);
    varSmallint: SerializeInt(Buffer, P.VSmallInt);
    varInteger:  SerializeInt(Buffer, P.VInteger);
    varShortInt: SerializeInt(Buffer, P.VShortInt);
    varByte:     SerializeInt(Buffer, P.VByte);
    varWord:     SerializeInt(Buffer, P.VWord);
    varLongWord: SerializeInt64(Buffer, P.VLongWord);
    varInt64:    SerializeInt64(Buffer, P.VInt64);
    varSingle:   SerializeDouble(Buffer, P.VSingle);
    varDouble:   SerializeDouble(Buffer, P.VDouble);
    varCurrency: SerializeCurrency(Buffer, P.VCurrency);
    varBoolean:  SerializeBoolean(Buffer, P.VBoolean);
    varString{$IFDEF DELPHI2009}, varUString{$ENDIF}: begin
      Index := ObjectContainer.IndexOf(V);
      if Index > -1 then
        SerializeRef(Buffer, Index)
      else begin
        ObjectContainer.Put(ObjectID, V);
        SerializeString(Buffer, RawByteString(P.VString));
      end;
    end;
    varOleStr: begin
      Index := ObjectContainer.IndexOf(V);
      if Index > -1 then
        SerializeRef(Buffer, Index)
      else begin
        ObjectContainer.Put(ObjectID, V);
        SerializeString(Buffer, VarToWideStr(V));
      end;
    end;
    varDate: begin
      Index := ObjectContainer.IndexOf(V);
      if Index > -1 then
        SerializeRef(Buffer, Index)
      else begin
        ObjectContainer.Put(ObjectID, V);
        SerializeDateTime(Buffer, P.VDate);
        ObjectContainer.Count := ObjectID + 8;
      end;
    end;
  else
    if  P.VType and varByRef <> 0 then begin
      case P.VType and not varByRef of
        varSmallInt: SerializeInt(Buffer, PSmallInt(P.VPointer)^);
        varInteger:  SerializeInt(Buffer, PInteger(P.VPointer)^);
        varShortInt: SerializeInt(Buffer, PShortInt(P.VPointer)^);
        varByte:     SerializeInt(Buffer, PByte(P.VPointer)^);
        varWord:     SerializeInt(Buffer, PWord(P.VPointer)^);
        varLongWord: SerializeInt64(Buffer, PLongWord(P.VPointer)^);
        varInt64:    SerializeInt64(Buffer, PInt64(P.VPointer)^);
        varSingle:   SerializeDouble(Buffer, PSingle(P.VPointer)^);
        varDouble:   SerializeDouble(Buffer, PDouble(P.VPointer)^);
        varCurrency: SerializeCurrency(Buffer, PCurrency(P.VPointer)^);
        varBoolean:  SerializeBoolean(Buffer, PWordBool(P.VPointer)^);
        varOleStr: begin
          T := VarToWideStr(V);
          Index := ObjectContainer.IndexOf(T);
          if Index > -1 then
            SerializeRef(Buffer, Index)
          else begin
            ObjectContainer.Put(ObjectID, T);
            SerializeString(Buffer, VarToWideStr(T));
          end;
        end;
        varDate: begin
          T := PDateTime(P.VPointer)^;
          Index := ObjectContainer.IndexOf(T);
          if Index > -1 then
            SerializeRef(Buffer, Index)
          else begin
            ObjectContainer.Put(ObjectID, T);
            SerializeDateTime(Buffer, T);
            ObjectContainer.Count := ObjectID + 8;
          end;
        end;
      else
        if VarIsArray(V) then begin
          Index := ObjectContainer.IndexOf(V);
          if (VarType(V) and varTypeMask) = varByte then
            if Index > -1 then
              SerializeRef(Buffer, Index)
            else begin
              ObjectContainer.Put(ObjectID, V);
              SerializeByteArray(Buffer, V);
            end
          else if Index > -1 then begin
            ObjectContainer.Count := ObjectID;
            SerializePointerRef(Buffer, Index);
          end
          else begin
            ObjectContainer.Put(ObjectID, V);
            SerializeArray(Buffer, V, ObjectContainer);
          end;
        end
        else
          raise ESerializeError.Create('This variant can not to be serialize!');
      end
    end
    else if VarIsArray(V) then begin
      Index := ObjectContainer.IndexOf(V);
      if (VarType(V) and varTypeMask) = varByte then
        if Index > -1 then
          SerializeRef(Buffer, Index)
        else begin
          ObjectContainer.Put(ObjectID, V);
          SerializeByteArray(Buffer, V);
        end
      else if Index > -1 then begin
        ObjectContainer.Count := ObjectID;
        SerializePointerRef(Buffer, Index);
      end
      else begin
        ObjectContainer.Put(ObjectID, V);
        SerializeArray(Buffer, V, ObjectContainer);
      end;
    end
    else if P.VType = varPHP then begin
      Index := ObjectContainer.IndexOf(V);
      if Index > -1 then
        if TPHPVarData(V).VObject.AliasName = 'Array' then begin
          ObjectContainer.Count := ObjectID;
          SerializePointerRef(Buffer, Index);
        end
        else
          SerializeRef(Buffer, Index)
      else begin
        ObjectContainer.Put(ObjectID, V);
        TPHPVarData(V).VObject.DoSerialize(Buffer, ObjectContainer);
      end
    end
    else raise ESerializeError.Create('This variant can not to be serialize!');
  end;
end;

{ UnSerialize }

function UnSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList; StringAsByteArray: Boolean): Variant; overload; forward;

function ReadNumber(const Buffer: TStringBuffer): string;
var
  C: AnsiChar;
  Number: TStringBuffer;
begin
  Number := TStringBuffer.Create;
  try
    while True do begin
      if (Buffer.Read(C, 1) = 0) or (C in [':', ';']) then Break;
      Number.Write(C, 1);
    end;
    Result := Number.ToString;
  finally
    FreeAndNil(Number);
  end;
end;

function UnSerializeBoolean(const Buffer: TStringBuffer): Boolean;
begin
  Result := (Buffer.DataString[Buffer.Position + 2] = '1');
  Buffer.Position := Buffer.Position + 3;
end;

function UnSerializeInteger(const Buffer: TStringBuffer): Integer;
begin
  Buffer.Position := Buffer.Position + 1;
  Result := StrToInt(ReadNumber(Buffer));
end;

function UnSerializeDouble(const Buffer: TStringBuffer): Variant;
var
  D: string;
begin
  Buffer.Position := Buffer.Position + 1;
  D := ReadNumber(Buffer);
  if D = 'NAN' then Result := NaN
  else if D = 'INF' then Result := Infinity
  else if D = '-INF' then Result := NegInfinity
  else try
    Result := StrToInt(D);
  except
    try
      Result := StrToInt64(D);
    except
      try
        if AnsiContainsText(D, 'e') then Result := StrToFloat(D)
        else try
          Result := StrToCurr(D);
        except
          Result := StrToFloat(D);
        end;
      except
        if D = '' then Result := 0
        else if D[1] = '-' then Result := NegInfinity
        else Result := Infinity;
      end;
    end;
  end;
end;

function UnSerializeString(const Buffer: TStringBuffer): RawByteString;
var
  L: Integer;
begin
  L := UnSerializeInteger(Buffer);
  Buffer.Position := Buffer.Position + 1;
  Result := Buffer.ReadString(L);
  Buffer.Position := Buffer.Position + 2;
end;

function UnSerializeByteArray(const Buffer: TStringBuffer): Variant;
var
  L: Integer;
  P: pointer;
begin
  L := UnSerializeInteger(Buffer);
  Buffer.Position := Buffer.Position + 1;
  Result := VarArrayCreate([0, L - 1], varByte);
  P := VarArrayLock(Result);
  Buffer.Read(P^, L);
  VarArrayUnlock (Result);
  Buffer.Position := Buffer.Position + 2;
end;

function UnSerializeEscapedString(const Buffer: TStringBuffer): RawByteString;
var
  L, I: Integer;
  C: AnsiChar;
begin
  L := UnSerializeInteger(Buffer);
  SetLength(Result, L);
  Buffer.Position := Buffer.Position + 1;
  for I := 1 to L do begin
    Buffer.Read(C, 1);
    if C = '\' then Result[I] := AnsiChar(StrToInt(string('$' + Buffer.ReadString(2))))
    else Result[I] := C;
  end;
  Buffer.Position := Buffer.Position + 2;
end;

function UnSerializeUnicodeString(const Buffer: TStringBuffer): WideString;
var
  L, I: Integer;
  C: Char;
begin
  L := UnSerializeInteger(Buffer);
  SetLength(Result, L);
  Buffer.Position := Buffer.Position + 1;
  for I := 1 to L do begin
    Buffer.Read(C, 1);
    if C = '\' then Result[I] := WideChar(StrToInt(string('$' + Buffer.ReadString(4))))
    else Result[I] := WideChar(C);
  end;
  Buffer.Position := Buffer.Position + 2;
end;

function UnserializeKey(const Buffer: TStringBuffer): Variant;
var
  Tag: Char;
begin
  if (Buffer.Read(Tag, 1) = 0) then
    raise EUnserializeError.Create('End of Stream encountered before parsing was completed.');
  case Tag of
    's': begin
      Result := UnSerializeString(Buffer);
    end;
    'S': begin
      Result := UnSerializeEscapedString(Buffer);
    end;
    'U': begin
      Result := UnSerializeUnicodeString(Buffer);
    end;
  else
    raise EUnserializeError.Create('Unexpected Tag: "' + Tag + '".');
  end;
end;

function UnSerializeDateTime(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList): Variant;
var
  DT: THashMap;
  N, I, Count: Integer;
  Key: Variant;
begin
  DT := THashMap.Create;
  try
    N := ObjectContainer.Add(Null);
    Count := UnserializeInteger(Buffer);
    Buffer.Position := Buffer.Position + 1;
    for I := 1 to Count do begin
      Key := UnserializeKey(Buffer);
      DT.Put(Key, UnSerialize(Buffer, ObjectContainer, True));
    end;
    Buffer.Position := Buffer.Position + 1;
    Result := EncodeDateTime(DT['year'], DT['month'], DT['day'],
      DT['hour'], DT['minute'], DT['second'], DT['millisecond']);
    ObjectContainer[N] := Result;
  finally
    FreeAndNil(DT);
  end;
end;

function UnSerializeRef(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList): Variant;
var
  Temp: TPHPObject;
begin
  Result := ObjectContainer[UnSerializeInteger(Buffer) - 1];
  if VarIsPHPObject(Result) then begin
    Temp := TPHPObject.FromVariant(Result);
    if Temp is THashMap then Inc(THashMap(Temp).FRefCount);
  end;
end;

function UnSerializeHashMap(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList; StringAsByteArray: Boolean): Variant;
var
  HashMap: THashMap;
begin
  HashMap := THashMap.Create;
  Result := HashMap.ToVariant;
  ObjectContainer.Add(Result);
  HashMap.DoUnSerialize(Buffer, ObjectContainer, StringAsByteArray);
end;

function UnSerializeObject(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList; StringAsByteArray: Boolean): Variant;
var
  PHPObject: TPHPObject;
  PHPClass: TPHPClass;
  ClassName: string;
begin
  ClassName := string(UnSerializeString(Buffer));
  Buffer.Position := Buffer.Position - 1;
  if ClassName = 'PHPRPC_Date' then
    Result := UnSerializeDateTime(Buffer, ObjectContainer)
  else begin
    PHPClass := TPHPObject.GetClass(ClassName);
    if PHPClass = nil then PHPClass := THashMap;
    PHPObject := PHPClass.Create;
    Result := PHPObject.ToVariant;
    ObjectContainer.Add(Result);
    PHPObject.DoUnSerialize(Buffer, ObjectContainer, StringAsByteArray);
  end;
end;

function UnSerializeCustomObject(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList): Variant;
var
  PHPObject: TPHPObject;
  PHPClass: TPHPClass;
  ClassName: string;
  Intf: ISerializable;
  Len: Integer;
begin
  ClassName := string(UnSerializeString(Buffer));
  PHPClass := TPHPObject.GetClass(ClassName);
  if PHPClass = nil then
    ObjectContainer.Add(Null)
  else begin
    PHPObject := PHPClass.Create;
    Len := StrToInt(readNumber(Buffer));
    Buffer.Position := Buffer.Position + 1;
    if Supports(PHPObject, ISerializable, Intf) then begin
      Intf.UnSerialize(Buffer.ReadString(Len));
      Result := PHPObject.ToVariant;
      ObjectContainer.Add(Result);
    end
    else begin
      Buffer.Position := Buffer.Position + Len;
      ObjectContainer.Add(Null);
    end;
    Buffer.Position := Buffer.Position + 1;
  end;
end;

function UnSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList; StringAsByteArray: Boolean): Variant; overload;
var
  Tag: Char;
begin
  VarClear(Result);
  if Buffer.Read(Tag, 1) = 0 then
    raise EUnSerializeError.Create('End of Stream encountered before parsing was completed.');
  case Tag of
    'N': begin
      Buffer.Position := Buffer.Position + 1;
      Result := Null;
      ObjectContainer.Add(Result);
    end;
    'b': begin
      Result := UnSerializeBoolean(Buffer);
      ObjectContainer.Add(Result);
    end;
    'i': begin
      Result := UnSerializeInteger(Buffer);
      ObjectContainer.Add(Result);
    end;
    'd': begin
      Result := UnSerializeDouble(Buffer);
      ObjectContainer.Add(Result);
    end;
    's': begin
      if StringAsByteArray then
        Result := UnserializeByteArray(Buffer)
      else
        Result := UnSerializeString(Buffer);
      ObjectContainer.Add(Result);
    end;
    'S': begin
      Result := UnSerializeEscapedString(Buffer);
      ObjectContainer.Add(Result);
    end;
    'U': begin
      Result := UnSerializeUnicodeString(Buffer);
      ObjectContainer.Add(Result);
    end;
    'r': begin
      Result := UnSerializeRef(Buffer, ObjectContainer);
      ObjectContainer.Add(Result);
    end;
    'R': Result := UnSerializeRef(Buffer, ObjectContainer);
    'a': Result := UnSerializeHashMap(Buffer, ObjectContainer, StringAsByteArray);
    'O': Result := UnSerializeObject(Buffer, ObjectContainer, StringAsByteArray);
    'C': Result := UnSerializeCustomObject(Buffer, ObjectContainer);
  else
    raise EUnSerializeError.Create('Unknown Tag: "' + Tag + '".');
  end;
end;

{ public functions and procedures }

function HashOf(const Value: Variant): Integer;
const
  htNull    = $00000000;
  htBoolean = $10000000;
  htInteger = $20000000;
  htInt64   = $30000000;
  htDouble  = $40000000;
  htString  = $50000000;
  htWString = $60000000;
  htObject  = $70000000;
  htArray   = $80000000;

  function GetHashType(VType: Integer): Integer;
  begin
    case VType of
      varEmpty:    Result := htNull;
      varNull:     Result := htNull;
      varBoolean:  Result := htBoolean;
      varByte:     Result := htInteger;
      varWord:     Result := htInteger;
      varShortInt: Result := htInteger;
      varSmallint: Result := htInteger;
      varInteger:  Result := htInteger;
      varLongWord: Result := htInt64;
      varInt64:    Result := htInt64;
      varSingle:   Result := htDouble;
      varDouble:   Result := htDouble;
      varCurrency: Result := htDouble;
      varString:   Result := htString;
{$IFDEF DELPHI2009}
      varUString:  Result := htString;
{$ENDIF}
      varOleStr:   Result := htWString;
      varDate:     Result := htObject;
      varVariant:  Result := htObject;
    else
      if VType = VarPHP then Result := htObject else Result := htNull;
    end;
  end;
var
  P: PVarData;
begin
  P := FindVarData(Value);
  case P.VType of
    varEmpty:    Result := 0;
    varNull:     Result := 1;
    varBoolean:  Result := htBoolean or Abs(Integer(P.VBoolean));
    varByte:     Result := htInteger or P.VByte;
    varWord:     Result := htInteger or P.VWord;
    varShortInt: Result := htInteger or (P.VShortInt and $FF);
    varSmallint: Result := htInteger or (P.VSmallInt and $FFFF);
    varInteger:  Result := htInteger or (P.VInteger and $0FFFFFFF);
    varLongWord: Result := htInt64 or (P.VLongWord and $0FFFFFFF)
                           xor (not (P.VLongWord shr 3) and $10000000);
    varInt64:    Result := htInt64 or (P.VInt64 and $0FFFFFFF)
                           xor (not (P.VInt64 shr 3) and $10000000);
    varSingle:   Result := htDouble or (P.VInteger and $0FFFFFFF);
    varDouble:   Result := htDouble or ((P.VLongs[1] xor P.VLongs[2]) and $0FFFFFFF);
    varCurrency: Result := htDouble or ((P.VLongs[1] xor P.VLongs[2]) and $0FFFFFFF);
    varString{$IFDEF DELPHI2009}, varUString{$ENDIF}:   Result := htString or (HashOfString(VarToStr(Value)) and $0FFFFFFF);
    varOleStr:   Result := htWString or (HashOfString(VarToWideStr(Value)) and $0FFFFFFF);
    varDate:     Result := htObject or ((P.VLongs[1] xor P.VLongs[2]) and $0FFFFFFF);
  else
    if  P.VType and varByRef <> 0 then
      case P.VType and not varByRef of
        varBoolean:  Result := htBoolean or Abs(Integer(PWordBool(P.VPointer)^));
        varByte:     Result := htInteger or PByte(P.VPointer)^;
        varWord:     Result := htInteger or PWord(P.VPointer)^;
        varShortInt: Result := htInteger or (PShortInt(P.VPointer)^ and $FF);
        varSmallInt: Result := htInteger or (PSmallInt(P.VPointer)^ and $FFFF);
        varInteger:  Result := htInteger or (PInteger(P.VPointer)^ and $0FFFFFFF);
        varLongWord: Result := htInt64 or (PLongWord(P.VPointer)^ and $0FFFFFFF)
                               xor (not (PLongWord(P.VPointer)^ shr 3) and $10000000);
        varInt64:    Result := htInt64 or (PInt64(P.VPointer)^ and $0FFFFFFF)
                               xor (not (PInt64(P.VPointer)^ shr 3) and $10000000);
        varSingle:   Result := htDouble or (PInteger(P.VPointer)^ and $0FFFFFFF);
        varDouble:   Result := htDouble or ((PInteger(P.VPointer)^ xor (PInt64(P.VPointer)^ shr 32)) and $0FFFFFFF);
        varCurrency: Result := htDouble or ((PInteger(P.VPointer)^ xor (PInt64(P.VPointer)^ shr 32)) and $0FFFFFFF);
        varOleStr:   Result := htWString or (HashOfString(VarToWideStr(Value)) and $0FFFFFFF);
        varDate:     Result := htObject or ((PInteger(P.VPointer)^ xor (PInt64(P.VPointer)^ shr 32)) and $0FFFFFFF);
      else
        if VarIsArray(Value) then
          Result := Integer(htArray) or GetHashType(P.VType and varTypeMask) or (Integer(P.VPointer^) and $0FFFFFFF)
        else
          raise Exception.Create('This variant cannot use as a key!');
      end
    else if VarIsArray(Value) then
      Result := Integer(htArray) or GetHashType(P.VType and varTypeMask) or (Integer(P.VArray) and $0FFFFFFF)
    else if P.VType = varPHP then
      Result := htObject or (TPHPVarData(Value).VObject.HashCode and $0FFFFFFF)
    else
      Result := (P.VLongs[0] xor P.VLongs[1] xor P.VLongs[2]) and $0FFFFFFF;
  end;
end;

function VariantRef(const V: Variant): Variant;
var
  vType: TVarType;
begin
  if VarIsByRef(V) then
    Result := V
  else if VarIsArray(V, False) then
    Result := VarArrayRef(V)
  else begin
    VarClear(Result);
    vType := VarType(v);
    if vType in [varSmallint, varInteger, varSingle, varDouble,
                 varCurrency, varDate, varOleStr, varDispatch,
                 varError, varBoolean, varVariant, varUnknown,
                 varShortInt, varByte ,varWord, varLongWord, varInt64] then
      TVarData(Result).VType := VarType(v) or varByRef
    else
      TVarData(Result).VType := varInteger or varByRef;
    TVarData(Result).VPointer := @TVarData(V).VPointer;
  end;
end;

function VarPHP: TVarType;
begin
  Result := PHPVariantType.VarType;
end;

function VarIsPHPObject(const V: Variant): Boolean;
begin
  Result := VarType(V) = VarPHP;
end;

function PHPObject(const V: Variant): TPHPObject;
begin
  Result := TPHPObject.FromVariant(V);
end;

function Serialize(const V: Variant): RawByteString; overload;
var
  ObjectContainer: TArrayList;
  Buffer: TStringBuffer;
begin
  Buffer := TStringBuffer.Create;
  ObjectContainer := THashedArrayList.Create;
  try
    ObjectContainer.Count := 1;
    Serialize(Buffer, V, ObjectContainer);
    Result := Buffer.{$IFDEF DELPHI2009}ToRawByteString{$ELSE}ToString{$ENDIF};
  finally
    FreeAndNil(ObjectContainer);
    FreeAndNil(Buffer);
  end;
end;

function Serialize(const V: TVariantDynArray): RawByteString; overload;
var
  ObjectContainer: TArrayList;
  Buffer: TStringBuffer;
begin
  Buffer := TStringBuffer.Create;
  ObjectContainer := THashedArrayList.Create;
  try
    ObjectContainer.Count := 1;
    SerializeArray(Buffer, V, ObjectContainer);
    Result := Buffer.{$IFDEF DELPHI2009}ToRawByteString{$ELSE}ToString{$ENDIF};
  finally
    FreeAndNil(ObjectContainer);
    FreeAndNil(Buffer);
  end;
end;

function UnSerialize(const Data: RawByteString; StringAsByteArray: Boolean):Variant; overload;
var
  ObjectContainer: TArrayList;
  Buffer: TStringBuffer;
  I: Integer;
  Temp: TPHPObject;
begin
  Buffer := TStringBuffer.Create(Data);
  ObjectContainer := TArrayList.Create;
  try
    Buffer.Position := 0;
    Result := UnSerialize(Buffer, ObjectContainer, StringAsByteArray);
  finally
    for I := 0 to ObjectContainer.Count - 1 do
      if VarIsPHPObject(ObjectContainer[I]) then begin
        Temp := TPHPObject.FromVariant(ObjectContainer[I]);
        if (Temp is THashMap) and (THashMap(Temp).FRefCount = 0) then FreeAndNil(Temp);
      end;
    FreeAndNil(ObjectContainer);
    FreeAndNil(Buffer);
  end;
end;

function ByteArrayToString(const ByteArray: Variant): RawByteString;
var
  N: Integer;
  P: Pointer;
begin
  if (VarType(ByteArray) = varString){$IFDEF DELPHI2009} or (varType(ByteArray) = varUString){$ENDIF} then
    Result := RawByteString(TVarData(ByteArray).vstring)
  else if VarIsArray(ByteArray) and ((VarType(ByteArray) and varTypeMask) = varByte) then begin
    N := VarArrayHighBound(ByteArray, 1) - VarArrayLowBound(ByteArray, 1) + 1;
    SetLength(Result, N);
    P := VarArrayLock(ByteArray);
    Move(P^, PAnsiChar(Result)^, N);
    VarArrayUnlock(ByteArray);
  end
  else
    raise EVariantBadVarTypeError.Create('This VarType can not convert to RawByteString.');
end;

function StringToByteArray(const S: Variant): Variant;
var
  N: Integer;
  P: Pointer;
  SP: Pointer;
begin
  if (VarType(S) = varString){$IFDEF DELPHI2009} or (varType(S) = varUString){$ENDIF} then begin
    SP := TVarData(S).VString;
    N := Length(RawByteString(SP));
    Result := VarArrayCreate([0, N - 1], varByte);
    P := VarArrayLock(Result);
    Move(PAnsiChar(RawByteString(SP))^, P^, N);
    VarArrayUnlock(Result);
  end
  else if VarIsArray(S) and ((VarType(S) and varTypeMask) = varByte) then
    Result := S
  else
    raise EVariantBadVarTypeError.Create('This VarType can not convert to Variant of ByteArray.');
end;

{ TPHPVariantType }

procedure TPHPVariantType.CastTo(var Dest: TVarData;
  const Source: TVarData; const AVarType: TVarType);
var
  LTemp: TVarData;
begin
  if Source.VType = VarType then begin
    VarDataInit(LTemp);
    try
      case AVarType of
        varOleStr:
          VarDataFromOleStr(Dest, TPHPVarData(Source).VObject.ToString);
        varString{$IFDEF DELPHI2009}, varUString{$ENDIF}:
          VarDataFromStr(Dest, TPHPVarData(Source).VObject.ToString);
        varNull:
          if IsClear(Source) then Variant(Dest) := Null else RaiseCastError;
        varShortInt, varByte, varSmallint, varWord, varInteger: begin
          LTemp.VType := varInteger;
          LTemp.VInteger := TPHPVarData(Source).VObject.ToInteger;
          VarDataCastTo(Dest, LTemp, AVarType);
        end;
        varLongWord, varInt64: begin
          LTemp.VType := varInt64;
          LTemp.VInt64 := TPHPVarData(Source).VObject.ToInt64;
          VarDataCastTo(Dest, LTemp, AVarType);
        end;
        varSingle, varDouble, varCurrency: begin
          LTemp.VType := varDouble;
          LTemp.VDouble := TPHPVarData(Source).VObject.ToDouble;
          VarDataCastTo(Dest, LTemp, AVarType);
        end;
        varDate: begin
          LTemp.VType := varDate;
          LTemp.VDate := TPHPVarData(Source).VObject.ToDate;
          VarDataCopy(Dest, LTemp);
        end;
        varBoolean: begin
          LTemp.VType := varBoolean;
          LTemp.VBoolean := TPHPVarData(Source).VObject.ToBoolean;
          VarDataCopy(Dest, LTemp);
        end;
      else
      end;
    finally
      VarDataClear(LTemp);
    end;
  end
  else
    RaiseCastError;
end;

procedure TPHPVariantType.Clear(var V: TVarData);
begin
  V.VType := varEmpty;
  TPHPVarData(V).VObject := nil;
end;

function TPHPVariantType.CompareOp(const Left, Right: TVarData;
   const Operation: TVarOp): Boolean;
begin
  Result := False;
  if (Left.VType = VarType) and (Right.VType = VarType) then
    case Operation of
      opCmpEQ:
        Result := TPHPVarData(Left).VObject.Equal(TPHPVarData(Right).VObject);
      opCmpNE:
        Result := not TPHPVarData(Left).VObject.Equal(TPHPVarData(Right).VObject);
    else
      RaiseInvalidOp;
    end
  else
    case Operation of
      opCmpEQ:
        Result := False;
      opCmpNE:
        Result := True;
    else
      RaiseInvalidOp;
    end
end;

procedure TPHPVariantType.Copy(var Dest: TVarData; const Source: TVarData;
  const Indirect: Boolean);
begin
  if Indirect and VarDataIsByRef(Source) then
    VarDataCopyNoInd(Dest, Source)
  else
    VarDataClear(Dest);
    with TPHPVarData(Dest) do
    begin
      VType := VarType;
      VObject := TPHPVarData(Source).VObject;
    end;
end;

function TPHPVariantType.IsClear(const V: TVarData): Boolean;
begin
  Result := TPHPVarData(V).VObject = nil;
end;

procedure TPHPVariantType.DispInvoke(Dest: PVarData;
  const Source: TVarData; CallDesc: PCallDesc; Params: Pointer);
type
  PParamRec = ^TParamRec;
  TParamRec = array[0..3] of LongInt;
const
  CDoMethod    = $01;
  CPropertyGet = $02;
  CPropertySet = $04;
var
  LArguments: TVarDataArray;
  LParamPtr: Pointer;

  procedure ParseParam(I: Integer);
  const
    CArgClass       = $49;
    CArgTypeMask    = $7F;
    CArgByRef       = $80;
  var
    LArgType: Integer;
    LArgByRef: Boolean;
    Temp: Integer;
  begin
    LArgType := CallDesc^.ArgTypes[I] and CArgTypeMask;
    LArgByRef := (CallDesc^.ArgTypes[I] and CArgByRef) <> 0;

    VarDataInit(LArguments[I]);

    // error is an easy expansion
    if LArgType = varError then begin
      LArguments[I].VType := varError;
      LArguments[I].VError := VAR_PARAMNOTFOUND;
    end

    // Class
    else if LArgType = CArgClass then begin
      if LArgByRef then
        Temp := Integer(Pointer(LParamPtr^)^)
      else
        Temp := Integer(LParamPtr^);
      if TObject(Temp).InheritsFrom(TPHPObject) then
        Variant(LArguments[I]) := TPHPObject(Temp).ToVariant
      else
        RaiseDispError;
    end

    // literal string
    else if LArgType = varStrArg then begin
      if LArgByRef then begin
        LArguments[I].VType := varString;
        LArguments[I].VString := PString(Pointer(LParamPtr^)^);
      end
      else begin
        LArguments[I].VType := varString;
        LArguments[I].VString := PString(LParamPtr^);
      end;
    end

    // value is by ref
    else if LArgByRef then begin
      LArguments[I].VType := LArgType or varByRef;
      LArguments[I].VPointer := Pointer(LParamPtr^);
      while LArguments[I].VType = varByRef or varVariant do
        LArguments[I] := PVarData(LArguments[I].VPointer)^;
    end

    // value is a variant
    else if LArgType = varVariant then begin
      LArguments[I] := PVarData(LParamPtr)^;
      Inc(Integer(LParamPtr), SizeOf(TVarData) - SizeOf(Pointer));
    end

    else if LArgType = varNull then begin
      LArguments[I].VType := varNull;
      LArguments[I].VPointer := nil;
    end

    else begin
      LArguments[I].VType := LArgType;
      case CVarTypeToElementInfo[LArgType].Size of
        1, 2, 4:
        begin
          LArguments[I].VLongs[1] := PParamRec(LParamPtr)^[0];
        end;
        8:
        begin
          LArguments[I].VLongs[1] := PParamRec(LParamPtr)^[0];
          LArguments[I].VLongs[2] := PParamRec(LParamPtr)^[1];
          Inc(Integer(LParamPtr), 8 - SizeOf(Pointer));
        end;
      else
        RaiseDispError;
      end;
    end;
    Inc(Integer(LParamPtr), SizeOf(Pointer));
  end;

var
  I, LArgCount: Integer;
  LIdent: string;
  LTemp: TVarData;
begin
  // Grab the identifier
  LArgCount := CallDesc^.ArgCount;
  LIdent := string(PAnsiChar(@CallDesc^.ArgTypes[LArgCount]));

  // Parse the arguments
  LParamPtr := Params;
  SetLength(LArguments, LArgCount);
  for I := 0 to LArgCount - 1 do
    ParseParam(I);

  // What type of invoke is this?
  case CallDesc^.CallType of
    CDoMethod:
      // procedure with N arguments
      if Dest = nil then
      begin
        if not DoProcedure(Source, LIdent, LArguments) then
        begin

          // ok maybe its a function but first we must make room for a result
          VarDataInit(LTemp);
          try

            // notate that the destination shouldn't be bothered with
            // functions can still return stuff, we just do this so they
            //  can tell that they don't need to if they don't want to
            LTemp.VType := varError;
            LTemp.VError := VAR_PARAMNOTFOUND;

            // ok lets try for that function
            if not DoFunction(LTemp, Source, LIdent, LArguments) then
              RaiseDispError;
          finally
            VarDataClear(LTemp);
          end;
        end
      end

      // property get or function with 0 argument
      else if LArgCount = 0 then
      begin
        if not DoFunction(Dest^, Source, LIdent, LArguments) and
           not GetProperty(Dest^, Source, LIdent) then
          RaiseDispError;
      end

      // function with N arguments
      else if not DoFunction(Dest^, Source, LIdent, LArguments) then
        RaiseDispError;

    CPropertyGet:
      if not ((Dest <> nil) and                         // there must be a dest
              (LArgCount = 0) and                       // only no args
              GetProperty(Dest^, Source, LIdent)) then  // get op be valid
        RaiseDispError;

    CPropertySet:
      if not ((Dest = nil) and                          // there can't be a dest
              (LArgCount = 1) and                       // can only be one arg
              SetProperty(Source, LIdent, LArguments[0])) then // set op be valid
        RaiseDispError;
  else
    RaiseDispError;
  end;
end;

function TPHPVariantType.DoFunction(var Dest: TVarData; const V: TVarData;
  const Name: string; const Arguments: TVarDataArray): Boolean;
begin
  Result := TPHPVarData(V).VObject.DoFunction(Dest, Name, Arguments);
end;

function TPHPVariantType.DoProcedure(const V: TVarData;
  const Name: string; const Arguments: TVarDataArray): Boolean;
begin
  Result := TPHPVarData(V).VObject.DoProcedure(Name, Arguments);
end;

function TPHPVariantType.GetProperty(var Dest: TVarData;
  const V: TVarData; const Name: string): Boolean;
begin
  Result := TPHPVarData(V).VObject.GetProperty(Dest, Name);
end;

function TPHPVariantType.SetProperty(const V: TVarData;
  const Name: string; const Value: TVarData): Boolean;
begin
  Result := TPHPVarData(V).VObject.SetProperty(Name, Value);
end;

{ TPHPObject }

constructor TPHPObject.Create;
begin
  inherited Create(nil);
end;

function TPHPObject.HashCode: Integer;
begin
  Result := Integer(Self) and $FFFF;
end;

class function TPHPObject.AliasName: string;
var
  I: Integer;
begin
  I := PHPClassList.Keys.IndexOf(Integer(Self));
  if I >= 0 then Result := PHPClassList.Values[I] else Result := Self.ClassName;
end;

class function TPHPObject.GetClass(const AliasName: string): TPHPClass;
var
  I: Integer;
begin
  I := PHPClassList.Values.IndexOf(AliasName);
  if I >= 0 then Result := TPHPClass(Integer(PHPClassList.Keys[I])) else Result := nil;
end;

class procedure TPHPObject.RegisterClass(const AliasName: string);
begin
  if AliasName = '' then
    PHPClassList[Integer(Self)] := Self.ClassName
  else
    PHPClassList[Integer(Self)] := AliasName;
end;

function TPHPObject.DoFunction(var Dest: TVarData; const Name: string;
  const Arguments: TVarDataArray): Boolean;
begin
  Result := False;
end;

function TPHPObject.DoProcedure(const Name: string;
  const Arguments: TVarDataArray): Boolean;
var
  Ident: string;
begin
  Ident := LowerCase(Name);
  Result := True;
  if Ident = 'free' then
    Free
  else
    Result := False;
end;

function TPHPObject.DoSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList): RawByteString;
var
  Name: string;
  PropList: PPropList;
  PropInfo: PPropInfo;
  PropCount, I, CountIndex: Integer;
  Intf: ISerializable;
  Data: RawByteString;
  PropNames: TStringDynArray;
  Value: Variant;
begin
  Result := '';
  if Buffer = nil then
    Result := Serialize(ToVariant)
  else begin
    Name := AliasName;
    if Supports(Self, ISerializable, Intf) then begin
      Data := Intf.Serialize;
      Buffer.WriteString('C:' + RawByteString(IntToStr(Length(RawByteString(Name))))
        + ':"' + RawByteString(Name) + '":' + RawByteString(IntToStr(Length(Data))) + ':{' + Data + '}');
    end
    else begin
      PropNames := __sleep;
      if PropNames = nil then begin
        PropCount := GetPropList(PTypeInfo(ClassInfo), PropList);
        try
          Buffer.WriteString('O:' + RawByteString(IntToStr(Length(RawByteString(Name))))
            + ':"' + RawByteString(Name) + '":');
          CountIndex := Buffer.Position;
          Buffer.WriteString(':{');
          for I := 0 to PropCount - 1 do begin
            PropInfo := PropList^[I];
            if IsStoredProp(Self, PropInfo) then
              try
                Value := PHPRPC.GetPropValue(Self, PropInfo);
                SerializeString(Buffer, PropInfo^.Name);
                Serialize(Buffer, Value, ObjectContainer);
              except
                Dec(PropCount);
              end
            else Dec(PropCount);
          end;
          Buffer.Position := CountIndex;
          Buffer.InsertString(RawByteString(IntToStr(PropCount)));
          Buffer.Position := Buffer.Length;
        finally
          FreeMem(PropList);
        end;
      end
      else begin
        PropCount := Length(PropNames);
        Buffer.WriteString('O:' + RawByteString(IntToStr(Length(RawByteString(Name))))
          + ':"' + RawByteString(Name) + '":' + RawByteString(IntToStr(PropCount)) + ':{');
        for I := 0 to PropCount - 1 do begin
          SerializeString(Buffer, PropNames[I]);
          Serialize(Buffer, GetProp(PropNames[I]), ObjectContainer);
        end;
      end;
      Buffer.WriteString('}');
    end;
  end;
end;

procedure TPHPObject.DoUnSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList; StringAsByteArray: Boolean);
var
  PropCount, I: Integer;
  Key: Variant;
  Temp: Variant;
  TObj: TPHPObject;
begin
  PropCount := UnSerializeInteger(Buffer);
  Buffer.Position := Buffer.Position + 1;
  for I := 1 to PropCount do begin
    Key := UnserializeKey(Buffer);
    if Key[1] = #0 then Key := RightStr(VarToStr(Key), Length(Key) - PosEx(#0, Key, 2));
    Temp := UnSerialize(Buffer, ObjectContainer, StringAsByteArray);
    if VarIsPHPObject(Temp) then begin
      TObj := FromVariant(Temp);
      if TObj <> Self then begin
        TObj.MoveComponentsTo(Self);
        if TObj.ComponentIndex = -1 then InsertComponent(TObj);
      end;
    end;
    SetProp(Key, Temp);
  end;
  __wakeup;
  Buffer.Position := Buffer.Position + 1;
end;

function TPHPObject.GetProperty(var Dest: TVarData;
  const Name: String): Boolean;
begin
  Variant(Dest) := PHPRPC.GetPropValue(Self, Name);
  Result := True;
end;

function TPHPObject.SetProperty(const Name: String;
  const Value: TVarData): Boolean;
begin
  PHPRPC.SetPropValue(Self, Name, Variant(Value));
  Result := True;
end;

function TPHPObject.Equal(const Right: TPHPObject): Boolean;
begin
  Result := Self = Right;
end;

class function TPHPObject.Equal(const Left, Right: Variant): Boolean;
var
  L, R: PVarData;
  LA, RA: PVarArray;
begin
  Result := False;
  try
    Result := Left = Right;
  except
    if VarIsArray(Left) and VarIsArray(Right) then begin
      L := FindVarData(Left);
      R := FindVarData(Right);
      if (L.VType and varByRef) <> 0 then
        LA := PVarArray(L.VPointer^)
      else
        LA := L.VArray;
      if (R.VType and varByRef) <> 0 then
        RA := PVarArray(R.VPointer^)
      else
        RA := R.VArray;
      if LA = RA then Result := True;
    end;
  end;
end;

function TPHPObject.GetProp(const Name: String): Variant;
begin
  GetProperty(TVarData(Result), Name);
end;

procedure TPHPObject.SetProp(const Name: String;
  const Value: Variant);
begin
  SetProperty(Name, TVarData(Value));
end;

{$WARNINGS OFF}
function TPHPObject.ToBoolean: Boolean;
begin
  VarCastError;
end;

function TPHPObject.ToDate: TDateTime;
begin
  VarCastError;
end;

function TPHPObject.ToDouble: Double;
begin
  VarCastError;
end;

function TPHPObject.ToInt64: Int64;
begin
  VarCastError;
end;

{$WARNINGS ON}

function TPHPObject.ToInteger: Integer;
begin
  Result := Integer(self);
end;

function TPHPObject.ToString: string;
begin
  Result := string(DoSerialize);
end;

function TPHPObject.ToVariant: Variant;
begin
  VarClear(Result);
  TPHPVarData(Result).VType := varPHP;
  TPHPVarData(Result).VObject := Self;
end;

class function TPHPObject.FromVariant(const V: Variant): TPHPObject;
begin
  Result := nil;
  if VarIsPHPObject(V) then
    Result := TPHPVarData(V).VObject as Self
  else if not VarIsNull(V) then
    System.Error(reInvalidCast);
end;

function TPHPObject.__sleep: TStringDynArray;
begin
  Result := nil;
end;

procedure TPHPObject.__wakeup;
begin
end;

class function TPHPObject.New: Variant;
begin
  Result := Self.Create.ToVariant;
end;

procedure TPHPObject.MoveComponentsTo(AComponent: TComponent);
var
  I: Integer;
  Temp: TComponent;
begin
  for I := ComponentCount - 1 downto 0 do begin
    Temp := Components[I];
    RemoveComponent(Temp);
    if Temp <> AComponent then AComponent.InsertComponent(Temp);
  end;
end;

{ TStringBuffer }

constructor TStringBuffer.Create;
begin
  Create(255);
end;

constructor TStringBuffer.Create(Capacity: Integer);
begin
  FLength := 0;
  FPosition := 0;
  FCapacity := Capacity;
  SetLength(FDataString, Capacity);
end;

constructor TStringBuffer.Create(const AString: RawByteString);
begin
  FLength := System.Length(AString);
  FPosition := 0;
  FCapacity := FLength;
  FDataString := AString;
end;

function TStringBuffer.DoFunction(var Dest: TVarData; const Name: string;
  const Arguments: TVarDataArray): Boolean;
var
  Ident: string;
begin
  Ident := LowerCase(Name);
  Result := True;
  if Ident = 'readstring' then
    Variant(Dest) := ReadString(Variant(Arguments[0]))
  else if Ident = 'seek' then
    Variant(Dest) := Seek(Variant(Arguments[0]), Variant(Arguments[1]))
  else
    Result := inherited DoFunction(Dest, Name, Arguments);
end;

function TStringBuffer.DoProcedure(const Name: string;
  const Arguments: TVarDataArray): Boolean;
var
  Ident: string;
begin
  Ident := LowerCase(Name);
  Result := True;
  if Ident = 'insertstring' then
    InsertString(RawByteString(Arguments[0].vstring))
  else if Ident = 'writestring' then
    WriteString(RawByteString(Arguments[0].vstring))
  else
    Result := inherited DoProcedure(Name, Arguments);
end;

function TStringBuffer.DoSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList): RawByteString;
begin
  Result := '';
  if Buffer = nil then
    Result := Serialize(ToString)
  else
    SerializeString(Buffer, ToString);
end;

procedure TStringBuffer.DoUnSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList; StringAsByteArray: Boolean);
begin
  raise EUnSerializeError.Create('Unexpected Type!');
end;

procedure TStringBuffer.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TStringBuffer.Insert(const Buffer; Count: Integer): Longint;
begin
  if FPosition = FLength then
    Result := Write(Buffer, Count)
  else begin
    Result := Count;
    if (FLength + Result > FCapacity) then begin
      FCapacity := FLength + Result;
      Grow;
    end;
    Move(PAnsiChar(@FDataString[FPosition + 1])^,
      PAnsiChar(@FDataString[FPosition + Result + 1])^, FLength - FPosition);
    Move(Buffer, PAnsiChar(@FDataString[FPosition + 1])^, Result);
    Inc(FPosition, Result);
    Inc(FLength, Result);
  end;
end;

procedure TStringBuffer.InsertString(const AString: RawByteString);
begin
  Insert(PAnsiChar(AString)^, System.Length(AString));
end;

class function TStringBuffer.New(Capacity: Integer): Variant;
begin
  Result := Self.Create(Capacity).ToVariant;
end;

class function TStringBuffer.New(const AString: RawByteString): Variant;
begin
  Result := Self.Create(AString).ToVariant;
end;

function TStringBuffer.Read(var Buffer; Count: Integer): Longint;
begin
  Result := FLength - FPosition;
  if Result > Count then Result := Count;
  if Result > 0 then begin
    Move(PAnsiChar(@FDataString[FPosition + 1])^, Buffer, Result);
    Inc(FPosition, Result);
  end
  else Result := 0;
end;

function TStringBuffer.ReadString(Count: Integer): RawByteString;
var
  Len: Integer;
begin
  Len := FLength - FPosition;
  if Len > Count then Len := Count;
  if Len > 0 then begin
    SetString(Result, PAnsiChar(@FDataString[FPosition + 1]), Len);
    Inc(FPosition, Len);
  end;
end;

function TStringBuffer.Seek(Offset: Integer; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: FPosition := FPosition + Offset;
    soFromEnd: FPosition := FLength - Offset;
  end;
  if FPosition > FLength then
    FPosition := FLength
  else if FPosition < 0 then FPosition := 0;
  Result := FPosition;
end;

procedure TStringBuffer.SetCapacity(NewCapacity: Integer);
begin
  FCapacity := NewCapacity;
  if FLength > NewCapacity then FLength := NewCapacity;
  if FPosition > NewCapacity then FPosition := NewCapacity;
  SetLength(FDataString, NewCapacity);
end;

procedure TStringBuffer.SetPosition(NewPosition: Integer);
begin
  if NewPosition < 0 then FPosition := 0
  else if NewPosition > FLength then FPosition := FLength
  else FPosition := NewPosition;
end;

{$IFDEF DELPHI2009}
function TStringBuffer.ToRawByteString: RawByteString;
begin
  SetString(Result, PAnsiChar(FDataString), FLength);
end;
{$ENDIF}

function TStringBuffer.ToString: string;
begin
  SetString(Result, PAnsiChar(FDataString), FLength);
end;

function TStringBuffer.Write(const Buffer; Count: Integer): Longint;
begin
  Result := Count;
  if (FPosition + Result > FCapacity) then begin
    FCapacity := FPosition + Result;
    Grow;
  end;
  Move(Buffer, PAnsiChar(@FDataString[FPosition + 1])^, Result);
  Inc(FPosition, Result);
  if FPosition > FLength then FLength := FPosition;
end;

procedure TStringBuffer.WriteString(const AString: RawByteString);
begin
  Write(PAnsiChar(AString)^, System.Length(AString));
end;

{ THashBucket }

function THashBucket.Add(Hash, Index: Integer): PHashItem;
var
  HashIndex: Integer;
begin
  if FCount = FCapacity then Grow;
  HashIndex := (Hash and $7FFFFFFF) mod FCapacity;
  System.New(Result);
  Result.HashCode := Hash;
  Result.Index := Index;
  Result.Next := FIndices[HashIndex];
  FIndices[HashIndex] := Result;
  Inc(FCount);
end;

procedure THashBucket.Clear;
var
  I: Integer;
  HashItem: PHashItem;
begin
  for I := 0 to FCapacity - 1 do begin
    while FIndices[I] <> nil do begin
      HashItem := FIndices[I].Next;
      Dispose(FIndices[I]);
      FIndices[I] := HashItem;
    end;
  end;
  FCount := 0;
end;

constructor THashBucket.Create(Capacity: Integer);
begin
  FCount := 0;
  FCapacity := Capacity;
  SetLength(FIndices, FCapacity);
end;

procedure THashBucket.Delete(Hash, Index: Integer);
var
  HashIndex: Integer;
  HashItem, Prev: PHashItem;
begin
  HashIndex := (Hash and $7FFFFFFF) mod FCapacity;
  HashItem := FIndices[HashIndex];
  Prev := nil;
  while HashItem <> nil do begin
    if HashItem.Index = Index then begin
      if Prev <> nil then
        Prev.Next := HashItem.Next
      else
        FIndices[HashIndex] := HashItem.Next;
      Dispose(HashItem);
      Dec(FCount);
      Exit;
    end;
    Prev := HashItem;
    HashItem := HashItem.Next;
  end;
end;

destructor THashBucket.Destroy;
begin
  Clear;
  inherited;
end;

procedure THashBucket.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function THashBucket.IndexOf(Hash: Integer; const Value: Variant;
  CompareProc: TIndexCompareMethod): Integer;
var
  HashIndex: Integer;
  HashItem: PHashItem;
begin
  Result := -1;
	HashIndex := (Hash and $7FFFFFFF) mod FCapacity;
  HashItem := FIndices[HashIndex];
  while HashItem <> nil do
    if (HashItem.HashCode = Hash) and CompareProc(HashItem.Index, Value) then begin
      Result := HashItem.Index;
      Exit;
    end
    else
      HashItem := HashItem.Next;
end;

function THashBucket.Modify(OldHash, NewHash, Index: Integer): PHashItem;
var
  HashIndex: Integer;
  Prev: PHashItem;
begin
  if OldHash = NewHash then
    Result := nil
  else begin
   	HashIndex := (OldHash and $7FFFFFFF) mod FCapacity;
    Result := FIndices[HashIndex];
    Prev := nil;
    while Result <> nil do begin
      if Result.Index = Index then begin
        if Prev <> nil then
          Prev.Next := Result.Next
       else
          FIndices[HashIndex] := Result.Next;
        Result.HashCode := NewHash;
        HashIndex := (NewHash and $7FFFFFFF) mod FCapacity;
        Result.Next := FIndices[HashIndex];
        FIndices[HashIndex] := Result;
        Exit;
      end;
      Prev := Result;
      Result := Result.Next;
    end;
  end;
end;

procedure THashBucket.SetCapacity(NewCapacity: Integer);
var
  HashIndex, I: Integer;
  NewIndices: THashItemDynArray;
  HashItem, NewHashItem: PHashItem;
begin
  if (NewCapacity < 0) or (NewCapacity > MaxListSize) then
    raise EHashBucketError.CreateResFmt(@SListCapacityError, [NewCapacity]);
  if FCapacity = NewCapacity then Exit;
  if NewCapacity = 0 then begin
    Clear;
    SetLength(FIndices, 0);
    FCapacity := 0;
  end
  else begin
    SetLength(NewIndices, NewCapacity);
    for I := 0 to FCapacity - 1 do begin
      HashItem := FIndices[I];
      while HashItem <> nil do begin
        NewHashItem := HashItem;
        HashItem := HashItem.Next;
        HashIndex := (NewHashItem.HashCode and $7FFFFFFF) mod NewCapacity;
        NewHashItem.Next := NewIndices[HashIndex];
        NewIndices[HashIndex] := NewHashItem;
      end;
    end;
    FIndices := NewIndices;
    FCapacity := NewCapacity;
  end;
end;

{ TArrayList }

function TArrayList.Add(const Value: Variant): Integer;
begin
  Result := FCount;
  if FCount = FCapacity then Grow;
  FList[Result] := Value;
  Inc(FCount);
end;

procedure TArrayList.AddAll(const ArrayList: TArrayList);
var
  TotalCount, I: Integer;
begin
  TotalCount := FCount + ArrayList.Count;
  if TotalCount > FCapacity then begin
    FCapacity := TotalCount;
    Grow;
  end;
  for I := 0 to ArrayList.Count - 1 do Add(ArrayList[I]);
end;

procedure TArrayList.AddAll(const Container: Variant);
var
  I: Integer;
  Temp: TPHPObject;
begin
  if FindVarData(Container).VType = varPHP then begin
    Temp := TPHPObject.FromVariant(Container);
    if Temp is TArrayList then AddAll(TArrayList(Temp));
  end
  else if VarIsArray(Container) then begin
    for I := VarArrayLowBound(Container, 1) to VarArrayHighBound(Container, 1) do
      Add(Container[I]);
  end;
end;

procedure TArrayList.Clear;
begin
  SetLength(FList, 0);
  FCount := 0;
  FCapacity := 0;
end;

function TArrayList.Contains(const Value: Variant): Boolean;
begin
  Result := IndexOf(Value) > -1;
end;

constructor TArrayList.Create;
begin
  Create(4);
end;

constructor TArrayList.Create(AOwner: TComponent);
begin
  Create(4, AOwner);
end;

constructor TArrayList.Create(Capacity: Integer; AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCapacity := Capacity;
  FCount := 0;
  SetLength(FList, FCapacity);
end;

constructor TArrayList.Create(const ArrayList: TArrayList; AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCount := ArrayList.Count;
  FCapacity := ArrayList.Count;
  FList := ArrayList.List;
end;

function TArrayList.Delete(Index: Integer): Variant;
begin
  if (Index >= 0) and (Index < FCount) then begin
    Result := FList[Index];
    Dec(FCount);

    VarClear(FList[Index]);

    if Index < FCount then begin
      System.Move(FList[Index + 1], FList[Index],
        (FCount - Index) * SizeOf(Variant));
      FillChar(FList[FCount], SizeOf(Variant), 0);
    end;
  end;
end;

destructor TArrayList.Destroy;
begin
  Clear;
  inherited;
end;

function TArrayList.DoFunction(var Dest: TVarData; const Name: string;
  const Arguments: TVarDataArray): Boolean;
var
  Ident: string;
begin
  Ident := LowerCase(Name);
  Result := True;
  if Ident = 'add' then
    Variant(Dest) := Add(Variant(Arguments[0]))
  else if Ident = 'contains' then
    Variant(Dest) := Contains(Variant(Arguments[0]))
  else if Ident = 'delete' then
    Variant(Dest) := Delete(Variant(Arguments[0]))
  else if Ident = 'get' then
    Variant(Dest) := Get(Variant(Arguments[0]))
  else if Ident = 'indexof' then
    Variant(Dest) := IndexOf(Variant(Arguments[0]))
  else if Ident = 'remove' then
    Variant(Dest) := Remove(Variant(Arguments[0]))
  else
    Result := inherited DoFunction(Dest, Name, Arguments);
end;

function TArrayList.DoProcedure(const Name: string;
  const Arguments: TVarDataArray): Boolean;
var
  Ident: string;
begin
  Ident := LowerCase(Name);
  Result := True;
  if Ident = 'addall' then
    AddAll(Variant(Arguments[0]))
  else if Ident = 'put' then
    Put(Variant(Arguments[0]), Variant(Arguments[1]))
  else if Ident = 'clear' then
    Clear
  else if Ident = 'exchange' then
    Exchange(Variant(Arguments[0]), Variant(Arguments[1]))
  else if Ident = 'insert' then
    Insert(Variant(Arguments[0]), Variant(Arguments[1]))
  else if Ident = 'move' then
    Move(Variant(Arguments[0]), Variant(Arguments[1]))
  else
    Result := inherited DoProcedure(Name, Arguments);
end;

function TArrayList.DoSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList): RawByteString;
var
  I: Integer;
  LList: TVariantDynArray;
begin
  Result := '';
  if Buffer = nil then
    Result := Serialize(List)
  else begin
    LList := List;
    Buffer.WriteString('a:' + RawByteString(IntToStr(FCount)) + ':{');
    for I := 0 to FCount - 1 do begin
      SerializeInt(Buffer, I);
      Serialize(Buffer, LList[I], ObjectContainer);
    end;
    Buffer.WriteString('}');
  end;
end;

procedure TArrayList.DoUnSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList; StringAsByteArray: Boolean);
begin
  raise EUnSerializeError.Create('Unexpected Type!');
end;

procedure TArrayList.Exchange(Index1, Index2: Integer);
var
  Item: Variant;
begin
  if (Index1 < 0) or (Index1 >= FCount) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index1]);
  if (Index2 < 0) or (Index2 >= FCount) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index2]);

  Item := FList[Index1];
  FList[Index1] := FList[Index2];
  FList[Index2] := Item;
end;

function TArrayList.Get(Index: Integer): Variant;
begin
  if (Index >= 0) and (Index < FCount) then
    Result := FList[Index];
end;

function TArrayList.GetList: TVariantDynArray;
begin
  Result := Copy(FList, 0, FCount);
end;

procedure TArrayList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TArrayList.IndexOf(const Value: Variant): Integer;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    if TPHPObject.Equal(FList[I], Value) then begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

procedure TArrayList.Insert(Index: Integer; const Value: Variant);
begin
  if (Index < 0) or (Index > FCount) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index]);
  if FCount = FCapacity then Grow;
  if Index < FCount then begin
    System.Move(FList[Index], FList[Index + 1],
      (FCount - Index) * SizeOf(Variant));
    FillChar(FList[Index], SizeOf(Variant), 0);
  end;
  FList[Index] := Value;
  Inc(FCount);
end;

procedure TArrayList.Move(CurIndex, NewIndex: Integer);
var
  Value: Variant;
begin
  if CurIndex <> NewIndex then begin
    if (NewIndex < 0) or (NewIndex >= FCount) then
      raise EArrayListError.CreateResFmt(@SListIndexError, [NewIndex]);
    Value := Get(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, Value);
  end;
end;

class function TArrayList.New(Capacity: Integer): Variant;
begin
  Result := Self.Create(Capacity).ToVariant;
end;

class function TArrayList.New(const ArrayList: TArrayList): Variant;
begin
  Result := Self.Create(ArrayList).ToVariant;
end;

procedure TArrayList.Put(Index: Integer; const Value: Variant);
begin
  if (Index < 0) or (Index > MaxListSize) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index]);

  if Index >= FCapacity then begin
    FCapacity := Index;
    Grow;
  end;
  if Index >= FCount then FCount := Index + 1;

  FList[Index] := Value;
end;

function TArrayList.Remove(const Value: Variant): Integer;
begin
  Result := IndexOf(Value);
  if Result >= 0 then Delete(Result);
end;

procedure TArrayList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    raise EArrayListError.CreateResFmt(@SListCapacityError, [NewCapacity]);
  if NewCapacity <> FCapacity then begin
    SetLength(FList, NewCapacity);
    FCapacity := NewCapacity;
  end;
end;

procedure TArrayList.SetCount(NewCount: Integer);
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    raise EArrayListError.CreateResFmt(@SListCountError, [NewCount]);

  if NewCount > FCapacity then begin
    FCapacity := NewCount;
    Grow;
  end
  else if NewCount < FCount then
    for I := FCount - 1 downto NewCount do
      Delete(I);

  FCount := NewCount;
end;

procedure TArrayList.SetList(const Value: TVariantDynArray);
begin
  FCount := Length(Value);
  FCapacity := FCount;
  FList := Copy(Value, 0, FCount);
end;

{ THashedArrayList }

function THashedArrayList.Add(const Value: Variant): Integer;
begin
  Result := inherited Add(Value);
  FHashBucket.Add(HashOf(Value), Result);
end;

procedure THashedArrayList.Clear;
begin
  inherited;
  if FHashBucket <> nil then FHashBucket.Clear;
end;

constructor THashedArrayList.Create(Capacity: Integer; AOwner: TComponent = nil);
begin
  inherited Create(Capacity, AOwner);
  FHashBucket := THashBucket.Create(Capacity);
end;

constructor THashedArrayList.Create(const ArrayList: TArrayList; AOwner: TComponent = nil);
var
  I: Integer;
begin
  inherited Create(ArrayList, AOwner);
  FHashBucket := THashBucket.Create(Capacity);
  for I := 0 to Count - 1 do FHashBucket.Add(HashOf(Get(I)), I);
end;

function THashedArrayList.Delete(Index: Integer): Variant;
var
  OldHash, NewHash, I, OldCount: Integer;
begin
  OldCount := Count;
  Result := inherited Delete(Index);
  if (Index >= 0) and (Index < OldCount) then begin
    if Index < Count then begin
      OldHash := HashOf(Result);
      for I := Index to Count - 1 do begin
        NewHash := HashOf(FList[I]);
        FHashBucket.Modify(OldHash, NewHash, I);
        OldHash := NewHash;
      end;
    end;
    FHashBucket.Delete(HashOf(Result), Count);
  end;
end;

destructor THashedArrayList.Destroy;
begin
  FHashBucket.Clear;
  FreeAndNil(FHashBucket);
  inherited;
end;

procedure THashedArrayList.Exchange(Index1, Index2: Integer);
var
  Hash1, Hash2: Integer;
begin
  Hash1 := HashOf(Get(Index1));
  Hash2 := HashOf(Get(Index2));
  if Hash1 <> Hash2 then begin
    FHashBucket.Modify(Hash1, Hash2, Index1);
    FHashBucket.Modify(Hash2, Hash1, Index2);
  end;

  inherited Exchange(Index1, Index2);
end;

function THashedArrayList.IndexCompare(Index: Integer;
  const Value: Variant): Boolean;
begin
  Result := TPHPObject.Equal(Get(Index), Value);
end;

function THashedArrayList.IndexOf(const Value: Variant): Integer;
begin
  Result := FHashBucket.IndexOf(HashOf(Value), Value, IndexCompare);
end;

procedure THashedArrayList.Insert(Index: Integer; const Value: Variant);
var
  NewHash, OldHash, I, LastIndex: Integer;
begin
  LastIndex := Count;

  inherited Insert(Index, Value);

  NewHash := HashOf(Value);

  if Index < LastIndex then begin
    for I := Index to LastIndex - 1 do begin
      OldHash := HashOf(Get(I + 1));
      FHashBucket.Modify(OldHash, NewHash, I);
      NewHash := OldHash;
    end;
  end;

  FHashBucket.Add(NewHash, LastIndex);
end;

procedure THashedArrayList.Put(Index: Integer; const Value: Variant);
var
  OldHash, NewHash: Integer;
begin
  OldHash := HashOf(Get(Index));
  NewHash := HashOf(Value);

  inherited Put(Index, Value);

  if (OldHash <> NewHash) and
    (FHashBucket.Modify(OldHash, NewHash, Index) = nil) then
    FHashBucket.Add(NewHash, Index);
end;

procedure THashedArrayList.SetList(const Value: TVariantDynArray);
var
  I: Integer;
begin
  inherited SetList(Value);
  FHashBucket.Clear;
  for I := 0 to Count - 1 do
    FHashBucket.Add(HashOf(Value[I]), I);
end;

{ THashMap }

procedure THashMap.AfterConstruction;
begin
  FRefCount := 1;
end;

procedure THashMap.Clear;
begin
  FKeys.Clear;
  FValues.Clear;
end;

function THashMap.ContainsKey(const Key: Variant): Boolean;
begin
  Result := FKeys.Contains(Key);
end;

function THashMap.ContainsValue(const Value: Variant): Boolean;
begin
  Result := FValues.Contains(Value);
end;

constructor THashMap.Create;
begin
  Create(4);
end;

constructor THashMap.Create(AOwner: TComponent);
begin
  Create(4, AOwner);
end;

constructor THashMap.Create(Capacity: Integer; AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKeys := THashedArrayList.Create(Capacity);
  FValues := THashedArrayList.Create(Capacity);
end;

constructor THashMap.Create(const HashMap: THashMap; AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKeys := THashedArrayList.Create(0);
  FValues := THashedArrayList.Create(0);
  FKeys.List := HashMap.Keys.List;
  FValues.List := HashMap.Values.List;
end;

constructor THashMap.Create(const ArrayList: TArrayList;
  AOwner: TComponent);
var
  I: Integer;
begin
  inherited Create(AOwner);
  FKeys := THashedArrayList.Create(ArrayList.Count);
  for I := 0 to ArrayList.Count - 1 do FKeys.Add(I);
  FValues := THashedArrayList.Create(0);
  FValues.List := ArrayList.List;
end;

constructor THashMap.Create(const Container: Variant; AOwner: TComponent);
var
  I, L, H: Integer;
  Temp: TPHPObject;

begin
  inherited Create(AOwner);
  if FindVarData(Container).VType = varPHP then begin
    Temp := TPHPObject.FromVariant(Container);
    if Temp is TArrayList then Create(TArrayList(Temp))
    else if Temp is THashMap then Create(THashMap(Temp));
  end
  else if VarIsArray(Container) then begin
    L := VarArrayLowBound(Container, 1);
    H := VarArrayHighBound(Container, 1);
    Create(H - L + 1);
    for I := L to H do Put(I, Container[I]);
  end;
end;

function THashMap.Delete(const Key: Variant): Variant;
begin
  Result := FValues.Delete(FKeys.Remove(Key));
end;

destructor THashMap.Destroy;
begin
  FreeAndNil(FKeys);
  FreeAndNil(FValues);
  inherited;
end;

function THashMap.DoFunction(var Dest: TVarData; const Name: string;
  const Arguments: TVarDataArray): Boolean;
var
  Ident: string;
begin
  Ident := LowerCase(Name);
  Result := True;
  if Ident = 'containskey' then
    Variant(Dest) := ContainsKey(Variant(Arguments[0]))
  else if Ident = 'containsvalue' then
    Variant(Dest) := ContainsValue(Variant(Arguments[0]))
  else if Ident = 'delete' then
    Variant(Dest) := Delete(Variant(Arguments[0]))
  else if Ident = 'get' then
    Variant(Dest) := Get(Variant(Arguments[0]))
  else if Ident = 'toarraylist' then
    Variant(Dest) := ToArrayList.ToVariant
  else
    Result := inherited DoFunction(Dest, Name, Arguments);
end;

function THashMap.DoProcedure(const Name: string;
  const Arguments: TVarDataArray): Boolean;
var
  Ident: string;
begin
  Ident := LowerCase(Name);
  Result := True;
  if Ident = 'put' then
    Put(Variant(Arguments[0]), Variant(Arguments[1]))
  else if Ident = 'putall' then
    PutAll(Variant(Arguments[0]))
  else if Ident = 'clear' then
    Clear
  else
    Result := inherited DoProcedure(Name, Arguments);
end;

function THashMap.DoSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList): RawByteString;
var
  I, TotalCount, CountIndex: Integer;
  P: PVarData;
begin
  Result := '';
  if Buffer = nil then
    Result := Serialize(Self.ToVariant)
  else begin
    Buffer.WriteString('a:');
    CountIndex := Buffer.Position;
    Buffer.WriteString(':{');
    TotalCount := Count;
    for I := 0 to Count - 1 do begin
      P := FindVarData(FKeys[I]);
      case P.VType of
        varSmallint: SerializeInt(Buffer, P.VSmallInt);
        varInteger:  SerializeInt(Buffer, P.VInteger);
        varShortInt: SerializeInt(Buffer, P.VShortInt);
        varByte:     SerializeInt(Buffer, P.VByte);
        varWord:     SerializeInt(Buffer, P.VWord);
        varLongWord:
          if P.VLongWord <= LongWord(MaxInt) then
            SerializeInt(Buffer, Integer(P.VLongWord))
          else
            SerializeString(Buffer, IntToStr(P.VLongWord));
        varInt64:
          if (P.VInt64 >= Low(Integer)) and (P.VInt64 <= MaxInt) then
            SerializeInt(Buffer, Integer(P.VInt64))
          else
            SerializeString(Buffer, IntToStr(P.VInt64));
        varSingle:   SerializeString(Buffer, FloatToStr(P.VSingle));
        varDouble:   SerializeString(Buffer, FloatToStr(P.VDouble));
        varCurrency: SerializeString(Buffer, CurrToStr(P.VCurrency));
        varString:   SerializeString(Buffer, RawByteString(P.VString));
{$IFDEF DELPHI2009}
        varUString:  SerializeString(Buffer, RawByteString(P.VUString));
{$ENDIF}
        varOleStr:   SerializeString(Buffer, VarToWideStr(FKeys[I]));
      else
        if  P.VType and varByRef <> 0 then
          case P.VType and not varByRef of
            varSmallInt: SerializeInt(Buffer, PSmallInt(P.VPointer)^);
            varInteger:  SerializeInt(Buffer, PInteger(P.VPointer)^);
            varShortInt: SerializeInt(Buffer, PShortInt(P.VPointer)^);
            varByte:     SerializeInt(Buffer, PByte(P.VPointer)^);
            varWord:     SerializeInt(Buffer, PWord(P.VPointer)^);
            varLongWord:
              if PLongWord(P.VPointer)^ <= LongWord(MaxInt) then
                SerializeInt(Buffer, Integer(PLongWord(P.VPointer)^))
              else
                SerializeString(Buffer, IntToStr(PLongWord(P.VPointer)^));
            varInt64:
              if (PInt64(P.VPointer)^ >= Low(Integer))
                and (PInt64(P.VPointer)^ <= MaxInt) then
                SerializeInt(Buffer, Integer(PInt64(P.VPointer)^))
              else
                SerializeString(Buffer, IntToStr(PInt64(P.VPointer)^));
            varSingle:   SerializeString(Buffer, FloatToStr(PSingle(P.VPointer)^));
            varDouble:   SerializeString(Buffer, FloatToStr(PDouble(P.VPointer)^));
            varCurrency: SerializeString(Buffer, CurrToStr(PCurrency(P.VPointer)^));
            varOleStr:   SerializeString(Buffer, VarToWideStr(FKeys[I]));
          else
            Dec(TotalCount);
            Continue;
          end
        else begin
          Dec(TotalCount);
          Continue;
        end
      end;
      Serialize(Buffer, FValues[I], ObjectContainer);
    end;
    Buffer.WriteString('}');
    Buffer.Position := CountIndex;
    Buffer.InsertString(RawByteString(IntToStr(TotalCount)));
    Buffer.Position := Buffer.Length;
  end;
end;

procedure THashMap.DoUnSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList; StringAsByteArray: Boolean);
var
  TotalCount, I: Integer;
  Tag: Char;
  Key, Value: Variant;
  TObj: TPHPObject;
begin
  TotalCount := UnSerializeInteger(Buffer);
  Buffer.Position := Buffer.Position + 1;
  for I := 1 to TotalCount do begin
    if Buffer.Read(Tag, 1) = 0 then
      raise EUnSerializeError.Create('End of Stream encountered before parsing was completed.');
    case Tag of
      'i': begin
        Key := UnSerializeInteger(Buffer);
      end;
      's': begin
        Key := UnSerializeString(Buffer);
      end;
      'S': begin
        Key := UnSerializeEscapedString(Buffer);
      end;
      'U': begin
        Key := UnSerializeUnicodeString(Buffer);
      end;
    else
      raise EUnSerializeError.Create('Unexpected Tag: "' + Tag + '".');
    end;
    Value := UnSerialize(Buffer, ObjectContainer, StringAsByteArray);
    if VarIsPHPObject(Value) then begin
      TObj := FromVariant(Value);
      if (TObj <> Self) then
        TObj.MoveComponentsTo(Self);
        if TObj.ComponentIndex = -1 then InsertComponent(TObj);
    end;
    Put(Key, Value);
  end;
  Buffer.Position := Buffer.Position + 1;
end;

function THashMap.Get(const Key: Variant): Variant;
begin
  Result := FValues[FKeys.IndexOf(Key)];
end;

function THashMap.GetCount: Integer;
begin
  Result := FKeys.Count;
end;

class function THashMap.New(const ArrayList: TArrayList): Variant;
begin
  Result := Self.Create(ArrayList).ToVariant;
end;

class function THashMap.New(const HashMap: THashMap): Variant;
begin
  Result := Self.Create(HashMap).ToVariant;
end;

class function THashMap.New(Capacity: Integer): Variant;
begin
  Result := Self.Create(Capacity).ToVariant;
end;

class function THashMap.New(const Container: Variant): Variant;
begin
  Result := Self.Create(Container).ToVariant;
end;

procedure THashMap.Put(const Key, Value: Variant);
var
  Index: Integer;
begin
  Index := FKeys.IndexOf(Key);
  if Index > -1 then
    FValues[Index] := Value
  else
    FValues[FKeys.Add(Key)] := Value;
end;

procedure THashMap.PutAll(const ArrayList: TArrayList);
var
  I: Integer;
begin
  for I := 0 to ArrayList.Count - 1 do Put(I, ArrayList[I]);
end;

procedure THashMap.PutAll(const HashMap: THashMap);
var
  I: Integer;
begin
  for I := 0 to HashMap.Count - 1 do Put(HashMap.Keys[I], HashMap.Values[I]);
end;

procedure THashMap.PutAll(const Container: Variant);
var
  I: Integer;
  Temp: TPHPObject;
begin
  if FindVarData(Container).VType = varPHP then begin
    Temp := TPHPObject.FromVariant(Container);
    if Temp is TArrayList then PutAll(TArrayList(Temp))
    else if Temp is THashMap then PutAll(THashMap(Temp));
  end
  else if VarIsArray(Container) then begin
    for I := VarArrayLowBound(Container, 1) to VarArrayHighBound(Container, 1) do
      Put(I, Container[I]);
  end;
end;

function THashMap.ToArrayList: TArrayList;
var
  I: Integer;
begin
  Result := TArrayList.Create(Count);
  for I := 0 to Count - 1 do
    if (FindVarData(FKeys[I]).VType in [varSmallint, varInteger, varShortInt,
      varByte, varWord, varLongWord, varInt64]) and (FKeys[I] >= 0)
      and (FKeys[I] <= MaxListSize) then Result.Put(FKeys[I], FValues[I]);
end;

{ TPHPRPC_Client }

constructor TPHPRPC_Client.Create;
begin
  Create('');
end;

constructor TPHPRPC_Client.Create(AOwner: TComponent);
begin
  Create('', AOwner);
end;

constructor TPHPRPC_Client.Create(const AURL: string; AOwner: TComponent);
begin
  inherited Create(AOwner);
  URL := AURL;
  FOutput := '';
  FWarning := nil;
  FVersion := 3.0;
  FIdHTTP := TIdHTTP.Create(Self);
  FIdHTTP.AllowCookies := True;
  FIdHTTP.Request.Connection := 'Keep-Alive';
  FIdHTTP.Request.Accept := '*.*';
  FIdHTTP.Request.ContentType := 'application/x-www-form-urlencoded; charset=' + FCharset;
  FIdHTTP.Request.UserAgent := 'PHPRPC 3.0 Client for Delphi';
  FIdHTTP.Request.AcceptEncoding := 'gzip, deflate';
  FIdHTTP.Request.CacheControl := 'no-cache';
  FIdHTTP.ReadTimeout := 30000;
  FIdHTTP.HTTPOptions := FIdHTTP.HTTPOptions + [hoKeepOrigProtocol];
  FIdHTTP.ProtocolVersion := pv1_1;
end;

destructor TPHPRPC_Client.Destroy;
begin
  FreeAndNil(FIdHTTP);
  FreeAndNil(FWarning);
  inherited;
end;

function TPHPRPC_Client.Encrypt(const Data: RawByteString; Level: Integer): RawByteString;
begin
  if (FKey <> '') and (FEncryptMode >= Level) then
    Result := XXTEA.Encrypt(Data, FKey)
  else
    Result := Data;
end;

function TPHPRPC_Client.Decrypt(const Data: RawByteString; Level: Integer): RawByteString;
begin
  if (FKey <> '') and (FEncryptMode >= Level) then
    Result := XXTEA.Decrypt(Data, FKey)
  else
    Result := Data;
end;

function TPHPRPC_Client.GetProxy: TIdProxyConnectionInfo;
begin
  Result := FIdHTTP.ProxyParams;
end;

function TPHPRPC_Client.GetTimeout: Integer;
begin
  Result := FIdHTTP.ReadTimeout;
end;

function TPHPRPC_Client.Invoke(const FuncName: string;
  const Args: TVariantDynArray; byRef: boolean): Variant;
var
  I, Errno: Integer;
  RequestBody: TStringBuffer;
  Data, Arguments: THashMap;
begin
  try
    KeyExchange;
    RequestBody := TStringBuffer.Create;
    try
      RequestBody.WriteString('phprpc_func=');
      RequestBody.WriteString(RawByteString(FuncName));
      if (Args <> nil) and (Length(Args) > 0) then begin
        RequestBody.WriteString('&phprpc_args=');
        RequestBody.WriteString(RawByteString(AnsiReplaceStr(Base64Encode(Encrypt(Serialize(Args), 1)), '+', '%2B')));
      end;
      RequestBody.WriteString('&phprpc_encrypt=');
      RequestBody.WriteString(RawByteString(IntToStr(FEncryptMode)));
      if not byRef then
        RequestBody.WriteString('&phprpc_ref=false');
      Data := Post(RequestBody.{$IFDEF DELPHI2009}ToRawByteString{$ELSE}ToString{$ENDIF});
    finally
      FreeAndNil(RequestBody);
    end;
    try
      Errno := Data['phprpc_errno'];
      FreeAndNil(FWarning);
      if Errno <> 0 then begin
        FWarning := TPHPRPC_Error.Create(Errno, Data['phprpc_errstr']);
      end;
      if Data.ContainsKey('phprpc_output') then
        FOutput := RawByteString(VartoStr(Data['phprpc_output']))
      else
        FOutput := '';
      if Data.ContainsKey('phprpc_result') then begin
        if Data.ContainsKey('phprpc_args') then begin
          Arguments := THashMap(PHPObject(UnSerialize(Decrypt(RawByteString(VarToStr(Data['phprpc_args'])), 1), FStringAsByteArray)));
          try
            for I := 0 to Math.Min(Length(Args), Arguments.Count) - 1 do
              Args[I] := Arguments[I];
          finally
            FreeAndNil(Arguments);
          end;
        end;
        Result := UnSerialize(Decrypt(RawByteString(VarToStr(Data['phprpc_result'])), 2), FStringAsByteArray);
      end
      else
        Result := FWarning.ToVariant;
    finally
      FreeAndNil(Data);
    end;
  except
    on E: Exception do begin
      FreeAndNil(FWarning);
      FWarning := TPHPRPC_Error.Create(1, E.Message);
      Result := FWarning.ToVariant;
    end;
  end;
end;

procedure TPHPRPC_Client.KeyExchange;
var
  Data, Encrypt: THashMap;
  X, Y, P, G: Variant;
  K: RawByteString;
  I, N: Integer;
begin
  if (FKey <> '') or (FEncryptMode = 0) then Exit;
  Data := Post('phprpc_encrypt=true&phprpc_keylen=' + RawByteString(IntToStr(FKeyLength)));
  try
    if Data.ContainsKey('phprpc_keylen') then
      FKeyLength := Data['phprpc_keylen']
    else
      FKeyLength := 128;
    if Data.ContainsKey('phprpc_encrypt') then begin
      Encrypt := THashMap(PHPObject(UnSerialize(RawByteString(VarToStr(Data['phprpc_encrypt'])), False)));
      try
        X := Rand(FKeyLength - 1, True);
        Y := BigInteger(VarToStr(Encrypt['y']));
        P := BigInteger(VarToStr(Encrypt['p']));
        G := BigInteger(VarToStr(Encrypt['g']));
      finally
        FreeAndNil(Encrypt);
      end;
      if (FKeyLength = 128) then begin
        SetLength(FKey, 16);
        FillChar(PAnsiChar(FKey)^, 16, 0);
        K := BigIntToBinStr(PowMod(Y, X, P));
        N := Min(Length(K), 16);
        for I := 0 to N - 1 do FKey[16 - I] := K[N - I];
      end
      else begin
        FKey := RawMD5(BigIntToString(PowMod(Y, X, P)));
      end;
      FreeAndNil(Data);
      Data := Post('phprpc_encrypt=' + RawByteString(VarToStr(PowMod(G, X, P))));
    end
    else begin
      Fkey := '';
      FEncryptMode := 0;
    end;
  finally
    FreeAndNil(Data);
  end;
end;

function TPHPRPC_Client.Post(const ReqStr: RawByteString): THashMap;
var
  Source: TMemoryStream;
  Dest: string;
  xPoweredBy, Buf, Left, Right: string;
  P, I: Integer;
  Data: TStringList;
begin
  Source := TMemoryStream.Create;
  Source.WriteBuffer(PAnsiChar(ReqStr)^, Length(ReqStr));
  Result := THashMap.Create;
  try
    try
      Dest := FIdHTTP.Post(FURL, Source);
      if FIdHTTP.ResponseCode = 200 then begin
        FVersion := 0;
        for I := 0 to FIdHTTP.Response.RawHeaders.Count - 1 do begin
          if SysUtils.AnsiLowerCase(FIdHTTP.Response.RawHeaders.Names[I]) = 'x-powered-by' then begin
            xPoweredBy := FIdHTTP.Response.RawHeaders.ValueFromIndex[I];
            P := Pos('PHPRPC Server/', xPoweredBy);
            if P > 0 then FVersion := StrToCurr(Copy(xPoweredBy, P + 14, Length(xPoweredBy)));
          end;
        end;
        if FVersion = 0 then raise Exception.Create('Illegal PHPRPC Server!');
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
              else begin
                Result[Left] := Base64Decode(Right);
                if (Left = 'phprpc_output') and (FVersion >= 3) then
                  Result[Left] := Decrypt(RawByteString(VarToStr(Result[Left])), 3);
              end;
            end;
          end;
        finally
          FreeAndNil(Data);
        end;
      end
      else begin
        Result['phprpc_errno'] := FIdHTTP.ResponseCode;
        Result['phprpc_errstr'] := FIdHTTP.ResponseText;
      end;
    except
      on E: Exception do begin
        Result['phprpc_errno'] := 1;
        Result['phprpc_errstr'] := E.Message;
      end;
    end;
  finally
    FreeAndNil(Source);
  end;
end;

procedure TPHPRPC_Client.SetCharset(const Value: string);
begin
  FCharset := Value;
  FIdHTTP.Request.ContentType := 'application/x-www-form-urlencoded; charset=' + FCharset;
end;

procedure TPHPRPC_Client.SetEncryptMode(Value: Integer);
begin
  if (Value >= 0) and (Value <= 3) then
    FEncryptMode := Value
  else
    FEncryptMode := 0;
end;

procedure TPHPRPC_Client.SetKeyLength(Value: Integer);
begin
  if FKey = '' then FKeyLength := Value;
end;

procedure TPHPRPC_Client.SetProxy(const Value: TIdProxyConnectionInfo);
begin
  FIdHTTP.ProxyParams := Value;
end;

procedure TPHPRPC_Client.SetTimeout(const Value: Integer);
begin
  FIdHTTP.ReadTimeout := Value;
end;

procedure TPHPRPC_Client.SetURL(const Value: string);
begin
  FURL := Value;
  FKey := '';
  FKeyLength := 128;
  FEncryptMode := 0;
  FCharset := 'UTF-8';
end;

function TPHPRPC_Client.UseService(const AURL: string): Variant;
begin
  URL := AURL;
  Result := ToVariant;
end;

function TPHPRPC_Client.DoFunction(var Dest: TVarData; const Name: string;
  const Arguments: TVarDataArray): Boolean;
var
  Args: TVariantDynArray;
begin
  Args := Pointer(Arguments);
  Variant(Dest) := Invoke(Name, Args, False);
  Result := True;
end;

{ TPHPRPC_Error }

constructor TPHPRPC_Error.Create(ErrNo: Integer; const ErrStr: string);
begin
  inherited Create;
  FNumber := ErrNo;
  FMessage := ErrStr;
end;

function TPHPRPC_Error.ToString: string;
begin
  Result := IntToStr(FNumber) + ':' + FMessage;
end;

procedure Register;
begin
  RegisterComponents('Internet', [TPHPRPC_Client]);
end;

initialization
  PHPClassList := THashMap.Create;
  PHPVariantType := TPHPVariantType.Create;
  TArrayList.RegisterClass('Array');
  THashedArrayList.RegisterClass('Array');
  THashMap.RegisterClass('Array');
  TPHPRPC_Error.RegisterClass('PHPRPC_Error');

finalization
  FreeAndNil(PHPVariantType);
  FreeAndNil(PHPClassList);
end.
 
