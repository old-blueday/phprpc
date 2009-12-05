{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC.pas                                               |
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

/* PHPRPC Library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Oct 30, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */
}

unit PHPRPC;

{$I PHPRPC.inc}

interface

uses
  Classes, Types, TypInfo, Variants, SyncObjs, SysUtils;

type

  PVariantDynArray = ^TVariantDynArray;
  TVariantDynArray = array of Variant;

  TStringBuffer = class;

  TArrayList = class;

  TPHPClass = class of TPHPObject;

  {$M+}
  ISerializable = interface
    ['{2523DF0D-A532-4CF9-AA96-C60DA18E21A4}']
    function Serialize: AnsiString;
    procedure UnSerialize(ss: AnsiString);
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
      const ObjectContainer: TArrayList = nil): AnsiString; virtual;
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
    class function New: Variant; overload;
    class function New(AOwner: TComponent): Variant; overload;
    class function FromVariant(const V: Variant): TPHPObject;
    class function AliasName: string;
    class function GetClass(const AliasName: string): TPHPClass;
    class procedure RegisterClass(const AliasName: string = '');
    procedure MoveComponentsTo(AComponent: TComponent);
    function HashCode: Integer; virtual;
    function ToString: string; {$IFDEF DELPHI2009_UP}override{$ELSE}virtual{$ENDIF};
    function ToVariant: Variant; virtual;
    property Properties[const Name: string]: Variant read GetProp write SetProp; default;
  published
    property Name stored False;
    property Tag stored False;
  end;
  {$M-}

  TStringBuffer = class(TPHPObject)
  private
    FDataString: AnsiString;
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
      const ObjectContainer: TArrayList = nil): AnsiString; override;
    procedure DoUnSerialize(const Buffer: TStringBuffer;
      const ObjectContainer: TArrayList; StringAsByteArray: Boolean); override;
  public
    constructor Create; overload; override;
    constructor Create(Capacity: Integer); reintroduce; overload;
    constructor Create(const AString: AnsiString); reintroduce; overload;
    class function New(Capacity: Integer): Variant; overload;
    class function New(const AString: AnsiString): Variant; overload;
    function Read(var Buffer; Count: Longint): Longint;
    function ReadString(Count: Longint): AnsiString;
    function Write(const Buffer; Count: Longint): Longint;
    procedure WriteString(const AString: AnsiString);
    function Insert(const Buffer; Count: Longint): Longint;
    procedure InsertString(const AString: AnsiString);
    function Seek(Offset: Longint; Origin: Word): Longint;
    function ToString: string; override;
    {$IFDEF DELPHI2009_UP}
    function ToAnsiString: AnsiString;
    {$ENDIF}
  published
    property Position: Integer read FPosition write SetPosition;
    property Length: Integer read FLength;
    property Capacity: Integer read FCapacity write SetCapacity;
    property DataString: AnsiString read FDataString;
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
      const ObjectContainer: TArrayList = nil): AnsiString; override;
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
    class function New(Capacity: Integer; AOwner: TComponent = nil): Variant; overload;
    class function New(const ArrayList: TArrayList; AOwner: TComponent = nil): Variant; overload;
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
  published
    property Count: Integer read FCount write SetCount;
    property Capacity: Integer read FCapacity write SetCapacity;
    property List: TVariantDynArray read GetList write SetList;
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
      const ObjectContainer: TArrayList = nil): AnsiString; override;
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
    class function New(Capacity: Integer; AOwner: TComponent = nil): Variant; overload;
    class function New(const ArrayList: TArrayList; AOwner: TComponent = nil): Variant; overload;
    class function New(const HashMap: THashMap; AOwner: TComponent = nil): Variant; overload;
    class function New(const Container: Variant; AOwner: TComponent = nil): Variant; overload;
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

  EPropertyConvertError = class(Exception);
  ESerializeError = class(Exception);
  EUnSerializeError = class(Exception);
  EHashBucketError = class(Exception);
  EArrayListError = class(Exception);

const
  IID_ISerializeble: TGUID = '{2523DF0D-A532-4CF9-AA96-C60DA18E21A4}';

function HashOf(const Value: Variant): Integer; overload;

function VarPHP: TVarType;
function VarIsPHPObject(const V: Variant): Boolean; overload;
function VarIsPHPObject(const V: Variant; PHPClass: TPHPClass): Boolean; overload;
function PHPObject(const V: Variant): TPHPObject;
function ArrayList(var V: Variant): TArrayList;
function HashMap(var V: Variant): THashMap;

function VariantRef(const V: Variant): Variant;

function Serialize(const V: Variant): AnsiString; overload;
function Serialize(const V: TVariantDynArray): AnsiString; overload;
function UnSerialize(const Data: AnsiString; StringAsByteArray: Boolean):Variant; overload;

function GetPropValue(Instance: TObject; const PropName: string;
  PreferStrings: Boolean = True): Variant; overload;
function GetPropValue(Instance: TObject; PropInfo: PPropInfo;
  PreferStrings: Boolean = True): Variant; overload;

procedure SetPropValue(Instance: TObject; const PropName: string;
  const Value: Variant); overload;
procedure SetPropValue(Instance: TObject; PropInfo: PPropInfo;
  const Value: Variant); overload;

function ByteArrayToString(const ByteArray: Variant): AnsiString;
function StringToByteArray(const S: Variant): Variant;

implementation

uses
  BigInt, DateUtils, Math, RTLConsts
  , StrUtils, SysConst, VarUtils
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
{$IFDEF DELPHI6}
    procedure DispInvoke(var DDest: TVarData; const Source: TVarData;
      CallDesc: PCallDesc; Params: Pointer); override;
{$ELSE}
    procedure DispInvoke(Dest: PVarData; const Source: TVarData;
      CallDesc: PCallDesc; Params: Pointer); override;
{$ENDIF}
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

{ private functions and procedures }

{$IFDEF DELPHI6}
function PosEx(const SubStr, S: string; Offset: Cardinal = 1): Integer;
var
  I,X: Integer;
  Len, LenSubStr: Integer;
begin
  if Offset = 1 then
    Result := Pos(SubStr, S)
  else
  begin
    I := Offset;
    LenSubStr := Length(SubStr);
    Len := Length(S) - LenSubStr + 1;
    while I <= Len do
    begin
      if S[I] = SubStr[1] then
      begin
        X := 1;
        while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do
          Inc(X);
        if (X = LenSubStr) then
        begin
          Result := I;
          exit;
        end;
      end;
      Inc(I);
    end;
    Result := 0;
  end;
end;
{$ENDIF}

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

function GetAccessToProperty(Instance: TObject; PropInfo: PPropInfo;
  AccessorProc: Longint; out FieldData: Pointer;
  out Accessor: TMethod): TAccessStyle;
begin
  if (AccessorProc and $FF000000) = $FF000000 then
  begin  // field - Getter is the field's offset in the instance data
    FieldData := Pointer(Integer(Instance) + (AccessorProc and $00FFFFFF));
    Result := asFieldData;
  end
  else
  begin
    if (AccessorProc and $FF000000) = $FE000000 then
      // virtual method  - Getter is a signed 2 byte integer VMT offset
      Accessor.Code := Pointer(PInteger(PInteger(Instance)^ + SmallInt(AccessorProc))^)
    else
      // static method - Getter is the actual address
      Accessor.Code := Pointer(AccessorProc);

    Accessor.Data := Instance;
    if PropInfo^.Index = Integer($80000000) then  // no index
      Result := asAccessor
    else
      Result := asIndexedAccessor;
  end;
end;

function GetDynArrayProp(Instance: TObject; PropInfo: PPropInfo): Pointer;
type
  { Need a(ny) dynamic array type to force correct call setup.
    (Address of result passed in EDX) }
  TDynamicArray = TVariantDynArray;
type
  TDynArrayGetProc = function: TDynamicArray of object;
  TDynArrayIndexedGetProc = function (Index: Integer): TDynamicArray of object;
var
  M: TMethod;
begin
  case GetAccessToProperty(Instance, PropInfo, Longint(PropInfo^.GetProc),
    Result, M) of

    asFieldData:
      Result := PPointer(Result)^;

    asAccessor:
      Result := Pointer(TDynArrayGetProc(M)());

    asIndexedAccessor:
      Result := Pointer(TDynArrayIndexedGetProc(M)(PropInfo^.Index));

  end;
end;

procedure SetDynArrayProp(Instance: TObject; PropInfo: PPropInfo;
  const Value: Pointer);
type
  TDynArraySetProc = procedure (const Value: Pointer) of object;
  TDynArrayIndexedSetProc = procedure (Index: Integer;
                                       const Value: Pointer) of object;
var
  P: Pointer;
  M: TMethod;
begin
  case GetAccessToProperty(Instance, PropInfo, Longint(PropInfo^.SetProc), P, M) of

    asFieldData:
      asm
        MOV    ECX, PropInfo
        MOV    ECX, [ECX].TPropInfo.PropType
        MOV    ECX, [ECX]

        MOV    EAX, [P]
        MOV    EDX, Value
        CALL   System.@DynArrayAsg
      end;

    asAccessor:
      TDynArraySetProc(M)(Value);

    asIndexedAccessor:
      TDynArrayIndexedSetProc(M)(PropInfo^.Index, Value);

  end;
end;

function GetDateTimeProp(Instance: TObject; PropInfo: PPropInfo): TDateTime;
type
  TDateTimeGetProc = function :TDateTime of object;
  TDateTimeIndexedGetProc = function (Index: Integer): TDateTime of object;
var
  P: Pointer;
  M: TMethod;
  Getter: Longint;
begin
  Getter := Longint(PropInfo^.GetProc);
  if (Getter and $FF000000) = $FF000000 then begin  // field - Getter is the field's offset in the instance data
    P := Pointer(Integer(Instance) + (Getter and $00FFFFFF));
    Result := PDateTime(P)^;
  end
  else begin
    if (Getter and $FF000000) = $FE000000 then
      // virtual method  - Getter is a signed 2 byte integer VMT offset
      M.Code := Pointer(PInteger(PInteger(Instance)^ + SmallInt(Getter))^)
    else
      // static method - Getter is the actual address
      M.Code := Pointer(Getter);

    M.Data := Instance;
    if PropInfo^.Index = Integer($80000000) then  // no index
      Result := TDateTimeGetProc(M)()
    else
      Result := TDateTimeIndexedGetProc(M)(PropInfo^.Index);
  end;
end;

function GetPropValue(Instance: TObject; PropInfo: PPropInfo;
  PreferStrings: Boolean = True): Variant; overload;
var
  TypeData: PTypeData;
begin
  // assume failure
  Result := Null;

  if PropInfo <> nil then
    case PropInfo^.PropType^^.Kind of
      tkInteger, tkWChar:
        Result := GetOrdProp(Instance, PropInfo);
      tkChar:
        Result := Char(GetOrdProp(Instance, PropInfo));
      tkEnumeration:
        if PreferStrings then
          Result := GetEnumProp(Instance, PropInfo)
        else if GetTypeData(PropInfo^.PropType^)^.BaseType^ = TypeInfo(Boolean) then
          Result := Boolean(GetOrdProp(Instance, PropInfo))
        else
          Result := GetOrdProp(Instance, PropInfo);
      tkSet:
        if PreferStrings then
          Result := GetSetProp(Instance, PropInfo)
        else
          Result := GetOrdProp(Instance, PropInfo);
      tkFloat:
        if (PropInfo^.PropType^^.Name = 'TDateTime') then
          Result := GetDateTimeProp(Instance, PropInfo)
        else
          Result := GetFloatProp(Instance, PropInfo);
      tkString, tkLString{$IFDEF DELPHI2009_UP}, tkUString{$ENDIF}:
        Result := GetStrProp(Instance, PropInfo);
      tkWString:
        Result := GetWideStrProp(Instance, PropInfo);
      tkVariant:
        Result := GetVariantProp(Instance, PropInfo);
      tkInt64:
    		Result := GetInt64Prop(Instance, PropInfo);
  	  tkDynArray:
        DynArrayToVariant(Result, GetDynArrayProp(Instance, PropInfo), PropInfo^.PropType^);
      tkClass: if GetOrdProp(Instance, PropInfo) = 0 then
        Result := Null
      else begin
        TypeData := GetTypeData(PropInfo^.PropType^);
        if TypeData^.ClassType.InheritsFrom(TPHPObject) then
          Result := TPHPObject(GetOrdProp(Instance, PropInfo)).ToVariant
        else
          PropertyConvertError(PropInfo.PropType^^.Name);
      end;
    else
      PropertyConvertError(PropInfo.PropType^^.Name);
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
    TypeData := GetTypeData(PropInfo^.PropType^);

    // set the right type
    case PropInfo.PropType^^.Kind of
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
        if (VarType(Value) = varString){$IFDEF DELPHI2009_UP} or (VarType(Value) = varUString){$ENDIF} then
          SetOrdProp(Instance, PropInfo, Ord(VarToStr(Value)[1]))
        else if VarType(Value) = varBoolean then
          SetOrdProp(Instance, PropInfo, Abs(Trunc(Value)))
        else
          SetOrdProp(Instance, PropInfo, RangedValue(TypeData^.MinValue,
            TypeData^.MaxValue));
      tkEnumeration:
        if (VarType(Value) = varString){$IFDEF DELPHI2009_UP} or (VarType(Value) = varUString){$ENDIF} then
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
      tkString, tkLString{$IFDEF DELPHI2009_UP}, tkUString{$ENDIF}:
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
	    tkDynArray:	begin
        if VarIsPHPObject(Value) then begin
          Temp := TPHPObject.FromVariant(Value);
          if (Temp is TArrayList) then
     		    DynArrayFromVariant(Pointer(DynArray), TArrayList(Temp).List, PropInfo^.PropType^)
          else if (Temp is THashMap) then begin
       		  DynArrayFromVariant(Pointer(DynArray), THashMap(Temp).Values.List, PropInfo^.PropType^);
            Dec(THashMap(Temp).FRefCount);
          end
          else
            PropertyConvertError(PropInfo.PropType^^.Name);
        end
        else if VarIsArray(Value) then
     		  DynArrayFromVariant(Pointer(DynArray), Value, PropInfo^.PropType^)
        else if (FindVarData(Value).VType = varString){$IFDEF DELPHI2009_UP} or (FindVarData(Value).VType = varUString){$ENDIF} then
     		  DynArrayFromVariant(Pointer(DynArray), StringToByteArray(AnsiString(Value)), PropInfo^.PropType^)
        else
          PropertyConvertError(PropInfo.PropType^^.Name);
 	  	  SetDynArrayProp(Instance, PropInfo, Pointer(DynArray));
		  end;
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
          PropertyConvertError(PropInfo.PropType^^.Name);
      end
      else
        PropertyConvertError(PropInfo.PropType^^.Name);
    else
      PropertyConvertError(PropInfo.PropType^^.Name);
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
  Buffer.WriteString('R:' + AnsiString(IntToStr(V)) + ';');
end;

procedure SerializeRef(const Buffer: TStringBuffer; V: Integer);
begin
  Buffer.WriteString('r:' + AnsiString(IntToStr(V)) + ';');
end;

procedure SerializeInt(const Buffer: TStringBuffer; V: Integer);
begin
  Buffer.WriteString('i:' + AnsiString(IntToStr(V)) + ';');
end;

procedure SerializeInt64(const Buffer: TStringBuffer; V: Int64);
begin
  if (V > MaxInt) or (V < Low(Longint)) then Buffer.WriteString('d:' + AnsiString(IntToStr(V)) + ';')
  else Buffer.WriteString('i:' + AnsiString(IntToStr(V)) + ';');
end;

procedure SerializeDouble(const Buffer: TStringBuffer; V: Double);
begin
  Buffer.WriteString('d:' + AnsiString(Format('%g', [V])) + ';');
end;

procedure SerializeCurrency(const Buffer: TStringBuffer; V: Currency);
begin
  Buffer.WriteString('d:' + AnsiString(CurrToStr(V)) + ';');
end;

procedure SerializeBoolean(const Buffer: TStringBuffer; V: Boolean);
begin
  if V then Buffer.WriteString('b:1;') else Buffer.WriteString('b:0;');
end;

procedure SerializeString(const Buffer: TStringBuffer; const V: AnsiString); overload;
begin
  Buffer.WriteString('s:' + AnsiString(IntToStr(Length(V))) + ':"' + V + '";');
end;

procedure SerializeString(const Buffer: TStringBuffer; const V: WideString); overload;
var
  I: Integer;
begin
  Buffer.WriteString('U:' + AnsiString(IntToStr(Length(V))) + ':"');
  for I := 1 to Length(V) do
    if Ord(V[I]) > 127 then
      Buffer.WriteString('\' + AnsiString(IntToHex(Ord(V[I]), 4)))
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
  Buffer.WriteString('s:' + AnsiString(IntToStr(Size)) + ':"');
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
  Buffer.WriteString('a:' + AnsiString(IntToStr(Len)) + ':{');
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
  Buffer.WriteString('a:' + AnsiString(IntToStr(Len)) + ':{');
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
    varString{$IFDEF DELPHI2009_UP}, varUString{$ENDIF}: begin
      Index := ObjectContainer.IndexOf(V);
      if Index > -1 then
        SerializeRef(Buffer, Index)
      else begin
        ObjectContainer.Put(ObjectID, V);
        SerializeString(Buffer, AnsiString(P.VString));
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
    else if P.VType = varBi then begin
      Index := ObjectContainer.IndexOf(V);
      if Index > -1 then
        SerializeRef(Buffer, Index)
      else begin
        ObjectContainer.Put(ObjectID, V);
        SerializeString(Buffer, BigIntToString(V));
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

function UnSerializeString(const Buffer: TStringBuffer): AnsiString;
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

function UnSerializeEscapedString(const Buffer: TStringBuffer): AnsiString;
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
{$IFDEF DELPHI2009_UP}
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
    varDouble:   Result := htDouble or ((P.VInteger xor (P.VInt64 shr 32)) and $0FFFFFFF);
    varCurrency: Result := htDouble or ((P.VInteger xor (P.VInt64 shr 32)) and $0FFFFFFF);
    varString{$IFDEF DELPHI2009_UP}, varUString{$ENDIF}:   Result := htString or (HashOfString(VarToStr(Value)) and $0FFFFFFF);
    varOleStr:   Result := htWString or (HashOfString(VarToWideStr(Value)) and $0FFFFFFF);
    varDate:     Result := htObject or ((P.VInteger xor (P.VInt64 shr 32)) and $0FFFFFFF);
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
      Result := (P.VInteger xor (P.VInt64 shr 32)) and $0FFFFFFF;
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

function VarIsPHPObject(const V: Variant; PHPClass: TPHPClass): Boolean;
begin
  Result := (VarType(V) = VarPHP) and (PHPObject(V) is PHPClass);
end;

function PHPObject(const V: Variant): TPHPObject;
begin
  Result := TPHPObject.FromVariant(V);
end;

function ArrayList(var V: Variant): TArrayList;
var
  Obj: TPHPObject;
begin
  Result := nil;
  if VarIsArray(V) then begin
    Result := TArrayList.Create;
    Result.AddAll(V);
    V := Result.ToVariant;
  end
  else begin
    Obj := PHPObject(V);
    if (Obj is TArrayList) then
      Result := TArrayList(Obj)
    else if (Obj is THashMap) then begin
      Result := THashMap(Obj).ToArrayList;
      Obj.MoveComponentsTo(Result);
      V.Free;
      V := Result.ToVariant;
    end
    else if not VarIsNull(V) then
      System.Error(reInvalidCast);
  end;
end;

function HashMap(var V: Variant): THashMap;
var
  Obj: TPHPObject;
begin
  Result := nil;
  if VarIsArray(V) then begin
    Result := THashMap.Create;
    Result.PutAll(V);
    V := Result.ToVariant;
  end
  else begin
    Obj := PHPObject(V);
    if (Obj is THashMap) then
      Result := THashMap(Obj)
    else if (Obj is TArrayList) then begin
      Result := THashMap.Create(TArrayList(Obj));
      Obj.MoveComponentsTo(Result);
      V.Free;
      V := Result.ToVariant;
    end
    else if not VarIsNull(V) then
      System.Error(reInvalidCast);
  end;
end;

function Serialize(const V: Variant): AnsiString; overload;
var
  ObjectContainer: TArrayList;
  Buffer: TStringBuffer;
begin
  Buffer := TStringBuffer.Create;
  ObjectContainer := THashedArrayList.Create;
  try
    ObjectContainer.Count := 1;
    Serialize(Buffer, V, ObjectContainer);
    Result := Buffer.{$IFDEF DELPHI2009_UP}ToAnsiString{$ELSE}ToString{$ENDIF};
  finally
    FreeAndNil(ObjectContainer);
    FreeAndNil(Buffer);
  end;
end;

function Serialize(const V: TVariantDynArray): AnsiString; overload;
var
  ObjectContainer: TArrayList;
  Buffer: TStringBuffer;
begin
  Buffer := TStringBuffer.Create;
  ObjectContainer := THashedArrayList.Create;
  try
    ObjectContainer.Count := 2;
    ObjectContainer.Put(1, V);
    SerializeArray(Buffer, V, ObjectContainer);
    Result := Buffer.{$IFDEF DELPHI2009_UP}ToAnsiString{$ELSE}ToString{$ENDIF};
  finally
    FreeAndNil(ObjectContainer);
    FreeAndNil(Buffer);
  end;
end;

function UnSerialize(const Data: AnsiString; StringAsByteArray: Boolean):Variant; overload;
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

function ByteArrayToString(const ByteArray: Variant): AnsiString;
var
  N: Integer;
  P: Pointer;
begin
  if (VarType(ByteArray) = varString){$IFDEF DELPHI2009_UP} or (varType(ByteArray) = varUString){$ENDIF} then
    Result := AnsiString(ByteArray)
  else if VarIsArray(ByteArray) and ((VarType(ByteArray) and varTypeMask) = varByte) then begin
    N := VarArrayHighBound(ByteArray, 1) - VarArrayLowBound(ByteArray, 1) + 1;
    SetLength(Result, N);
    P := VarArrayLock(ByteArray);
    Move(P^, PAnsiChar(Result)^, N);
    VarArrayUnlock(ByteArray);
  end
  else
    raise EVariantBadVarTypeError.Create('This VarType can not convert to AnsiString.');
end;

function StringToByteArray(const S: Variant): Variant;
var
  N: Integer;
  P: Pointer;
  SP: Pointer;
begin
  if (VarType(S) = varString){$IFDEF DELPHI2009_UP} or (varType(S) = varUString){$ENDIF} then begin
    SP := TVarData(S).VString;
    N := Length(AnsiString(SP));
    Result := VarArrayCreate([0, N - 1], varByte);
    P := VarArrayLock(Result);
    Move(PAnsiChar(AnsiString(SP))^, P^, N);
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
        varString{$IFDEF DELPHI2009_UP}, varUString{$ENDIF}:
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

{$IFDEF DELPHI6}
const
  VAR_PARAMNOTFOUND = HRESULT($00020004); // = Windows.DISP_E_PARAMNOTFOUND
{$ENDIF}

procedure TPHPVariantType.DispInvoke({$IFDEF DELPHI6}var DDest: TVarData;{$ELSE}Dest: PVarData;{$ENDIF}
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
{$IFDEF DELPHI6}
  Dest: PVarData;
{$ENDIF}
begin
{$IFDEF DELPHI6}
  Dest := @DDest;
{$ENDIF}
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
  const ObjectContainer: TArrayList): AnsiString;
var
  Name: string;
  PropList: PPropList;
  PropInfo: PPropInfo;
  PropCount, I, CountIndex: Integer;
  Intf: ISerializable;
  Data: AnsiString;
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
      Buffer.WriteString('C:' + AnsiString(IntToStr(Length(AnsiString(Name))))
        + ':"' + AnsiString(Name) + '":' + AnsiString(IntToStr(Length(Data))) + ':{' + Data + '}');
    end
    else begin
      PropNames := __sleep;
      if PropNames = nil then begin
        PropCount := GetPropList(PTypeInfo(ClassInfo), PropList);
        try
          Buffer.WriteString('O:' + AnsiString(IntToStr(Length(AnsiString(Name))))
            + ':"' + AnsiString(Name) + '":');
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
          Buffer.InsertString(AnsiString(IntToStr(PropCount)));
          Buffer.Position := Buffer.Length;
        finally
          FreeMem(PropList);
        end;
      end
      else begin
        PropCount := Length(PropNames);
        Buffer.WriteString('O:' + AnsiString(IntToStr(Length(AnsiString(Name))))
          + ':"' + AnsiString(Name) + '":' + AnsiString(IntToStr(PropCount)) + ':{');
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
    if LeftStr(Key, 1) = #0 then Key := RightStr(Key, Length(Key) - PosEx(#0, Key, 2));
    Temp := UnSerialize(Buffer, ObjectContainer, StringAsByteArray);
    if VarIsPHPObject(Temp) then begin
      TObj := TPHPObject.FromVariant(Temp);
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

class function TPHPObject.New(AOwner: TComponent): Variant;
begin
  Result := Self.Create(AOwner).ToVariant;
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

constructor TStringBuffer.Create(const AString: AnsiString);
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
    InsertString(AnsiString(Variant(Arguments[0])))
  else if Ident = 'writestring' then
    WriteString(AnsiString(Variant(Arguments[0])))
  else
    Result := inherited DoProcedure(Name, Arguments);
end;

function TStringBuffer.DoSerialize(const Buffer: TStringBuffer;
  const ObjectContainer: TArrayList): AnsiString;
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

procedure TStringBuffer.InsertString(const AString: AnsiString);
begin
  Insert(PAnsiChar(AString)^, System.Length(AString));
end;

class function TStringBuffer.New(Capacity: Integer): Variant;
begin
  Result := Self.Create(Capacity).ToVariant;
end;

class function TStringBuffer.New(const AString: AnsiString): Variant;
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

function TStringBuffer.ReadString(Count: Integer): AnsiString;
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

{$IFDEF DELPHI2009_UP}
function TStringBuffer.ToAnsiString: AnsiString;
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

procedure TStringBuffer.WriteString(const AString: AnsiString);
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
  const ObjectContainer: TArrayList): AnsiString;
var
  I: Integer;
  LList: TVariantDynArray;
begin
  Result := '';
  if Buffer = nil then
    Result := Serialize(List)
  else begin
    LList := List;
    Buffer.WriteString('a:' + AnsiString(IntToStr(FCount)) + ':{');
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

class function TArrayList.New(Capacity: Integer; AOwner: TComponent = nil): Variant;
begin
  Result := Self.Create(Capacity, AOwner).ToVariant;
end;

class function TArrayList.New(const ArrayList: TArrayList; AOwner: TComponent = nil): Variant;
begin
  Result := Self.Create(ArrayList, AOwner).ToVariant;
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
  const ObjectContainer: TArrayList): AnsiString;
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
        varString:   SerializeString(Buffer, AnsiString(P.VString));
{$IFDEF DELPHI2009_UP}
        varUString:  SerializeString(Buffer, AnsiString(P.VUString));
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
    Buffer.InsertString(AnsiString(IntToStr(TotalCount)));
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
      TObj := TPHPObject.FromVariant(Value);
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

class function THashMap.New(const ArrayList: TArrayList; AOwner: TComponent = nil): Variant;
begin
  Result := Self.Create(ArrayList, AOwner).ToVariant;
end;

class function THashMap.New(const HashMap: THashMap; AOwner: TComponent = nil): Variant;
begin
  Result := Self.Create(HashMap, AOwner).ToVariant;
end;

class function THashMap.New(Capacity: Integer; AOwner: TComponent = nil): Variant;
begin
  Result := Self.Create(Capacity, AOwner).ToVariant;
end;

class function THashMap.New(const Container: Variant; AOwner: TComponent = nil): Variant;
begin
  Result := Self.Create(Container, AOwner).ToVariant;
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

initialization
  PHPClassList := THashMap.Create;
  PHPVariantType := TPHPVariantType.Create;
  TArrayList.RegisterClass('Array');
  THashedArrayList.RegisterClass('Array');
  THashMap.RegisterClass('Array');
finalization
  FreeAndNil(PHPVariantType);
  FreeAndNil(PHPClassList);
end.

