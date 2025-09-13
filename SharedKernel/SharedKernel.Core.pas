{***********************************************************************************************************************
  Unit:        SharedKernel.Core
  Purpose:     Contains core types and methods used across the SharedKernel.
  Author:      David Harper
  License:     MIT
  History:     2025-08-20  Initial version
***********************************************************************************************************************}
unit SharedKernel.Core;

interface

uses
  System.Generics.Collections,
  System.SysUtils;

type

  { semantic abstractions for interface management }
  TSingleton = class(TNoRefCountObject);
  TTransient = class(TInterfacedObject);

  TRefPredicate<T> = reference to function(const [ref] aItem: T): Boolean;
  TConstPredicate<T> = reference to function(const aItem: T): Boolean;
  TVarPredicate<T> = reference to function(var aItem: T): Boolean;

  TDisposer<T> = reference to procedure (const Item: T);

  { predicate with a var argument }
  TProcvar<T> = reference to procedure (var Arg1: T);

  { for working with most types }
  TConstProc<T> = reference to procedure (const Arg1: T);
  TConstProc<T1,T2> = reference to procedure (const Arg1: T1; const Arg2: T2);
  TConstProc<T1,T2,T3> = reference to procedure (const Arg1: T1; const Arg2: T2; const Arg3: T3);
  TConstProc<T1,T2,T3,T4> = reference to procedure (const Arg1: T1; const Arg2: T2; const Arg3: T3; const Arg4: T4);

  TConstFunc<T,R> = reference to function (const Arg1: T): R;
  TConstFunc<T1,T2,R> = reference to function (const Arg1: T1; const Arg2: T2): R;
  TConstFunc<T1,T2,T3,R> = reference to function (const Arg1: T1; const Arg2: T2; const Arg3: T3): R;
  TConstFunc<T1,T2,T3,T4,R> = reference to function (const Arg1: T1; const Arg2: T2; const Arg3: T3; const Arg4: T4): R;

  { for efficiently working with records }
  TConstRefProc<T: record> = reference to procedure (const [ref] Arg1: T);
  TConstRefProc<T1,T2: record> = reference to procedure (const [ref] Arg1: T1; const [ref] Arg2: T2);
  TConstRefProc<T1,T2,T3: record> = reference to procedure (const [ref] Arg1: T1; const [ref] Arg2: T2; const [ref] Arg3: T3);
  TConstRefProc<T1,T2,T3,T4: record> = reference to procedure (const [ref] Arg1: T1; const [ref] Arg2: T2; const [ref] Arg3: T3; const [ref] Arg4: T4);

  TConstRefFunc<T:record; R> = reference to function (const [ref] Arg1: T): R;
  TConstRefFunc<T1,T2: record; R> = reference to function (const [ref] Arg1: T1; const [ref] Arg2: T2): R;
  TConstRefFunc<T1,T2,T3: record; R> = reference to function (const [ref] Arg1: T1; const [ref] Arg2: T2; const [ref] Arg3: T3): R;
  TConstRefFunc<T1,T2,T3,T4: record; R> = reference to function (const [ref] Arg1: T1; const [ref] Arg2: T2; const [ref] Arg3: T3; const [ref] Arg4: T4): R;

  { used for managing local references, avoids try/finally/free blocks }
  TScope = record
  private
    fInstances: TObjectList<TObject>;
  public
    function Add<T:class>(aInstance: T): T; overload;
    function Add<T:class, constructor>: T; overload;

    class operator Initialize (out Dest: TScope);
    class operator Finalize (var Dest: TScope);
  end;

  /// <summary>
  /// Represents an optional value. Inspired by Option/Maybe monads.
  /// </summary>
  /// <typeparam name="T">Type of the optional value</typeparam>
  TMaybe<T> = record
  private
    FHasValue: Boolean;
    FValue: T;

    /// <summary>Accesses the value. Raises if value is not present.</summary>
    /// <summary>Returns the value if successful. Raises on error.</summary>
    function GetValue: T;

  public
    /// <summary>The value if successful.</summary>
    property Value: T read GetValue;

    /// <summary>Returns true if value is present.</summary>
    function IsSome: Boolean;

    /// <summary>Returns true if no value is present.</summary>
    function IsNone: Boolean;

    /// <summary>Returns the value if present, otherwise the fallback.</summary>
    function OrElse(const Fallback: T): T;

    /// <summary>Returns the value if present, otherwise computes it from the function.</summary>
    function OrElseGet(Func: TFunc<T>): T;

    /// <summary>Constructs a TMaybe with a value.</summary>
    class function Some(const AValue: T): TMaybe<T>; static;

    /// <summary>Constructs an empty TMaybe.</summary>
    class function None: TMaybe<T>; static;
  end;

  /// <summary>
  /// Represents the result of an operation: either a value or an error.
  /// </summary>
  /// <typeparam name="T">Type of the value on success</typeparam>
  TResult<T> = record
  private
    FValue: T;
    FError: string;
    FOk: Boolean;

    function GetValue: T;

    /// <summary>Returns the error message if failed.</summary>
    function GetError: string;

  public
     /// <summary>Constructs a successful result.</summary>
    class function Ok(const AValue: T): TResult<T>; static;

    /// <summary>Constructs an error result.</summary>
    class function Err(const AError: string): TResult<T>; static;

    /// <summary>True if result is success.</summary>
    function IsOk: Boolean;

    /// <summary>True if result is error.</summary>
    function IsErr: Boolean;

    property Value: T read GetValue;

    /// <summary>The error message if failed.</summary>
    property Error: string read GetError;
  end;

   { basic guard class }
  TExpect = class
  private
    class var
      fInstance: TExpect;
  public
    function IsNotBlank(const aValue: string; const aMessage: string = ''): TExpect;
    function IsEmpty<T>(const aList: TList<T>; const aMessage: string = ''): TExpect;
    function IsAssigned<T>(aInstance: T; const aMessage: string = ''): TExpect;
    function IsTrue(aValue: boolean; const aMessage: string = ''): TExpect;
    function IsFalse(aValue: boolean; const aMessage: string = ''): TExpect;

    class constructor Create;
    class destructor Destroy;
  end;

  { guard class exception }
  TExpectException = class(Exception)
  public
    class procedure Throw(const aMessage: string; const aDefaultMessage: string = '');
  end;

  { determines whether the container will use the type or interface map to resolve the provide }
  TRegisterType = (rtFromType, rtFromMap);

  { supplies interface to provider mapping, or facilitates flexible registration }
  TRegisterAttribute = class(TCustomAttribute)
  private
    fInterfaceGUID: TGUID;
    fRegisterType: TRegisterType;
  public
    property InterfaceGUID: TGUID read fInterfaceGUID;
    property RegisterType: TRegisterType read fRegisterType;

    function IsByForce: boolean;

    constructor Create(const aInterfaceGUID: TGUID; aRegisterType: TRegisterType = rtFromType);
  end;

  { Functions }

  function Iff(aCondition: boolean; const aTrueValue: string; const aFalseValue: string): string; overload;
  function Iff(aCondition: boolean; aTrueValue: integer; aFalseValue: integer): integer; overload;
  function Iff(aCondition: boolean; const aTrueValue: char; const aFalseValue: char): char; overload;
  function ToPair(const aString: string; const aDelimiter: string): TPair<string, string>;

  procedure Let(out int1: integer; out int2: integer; const values: array of integer); overload;
  procedure Let(out int1: integer; out int2: integer; out int3: integer; const values: array of integer); overload;
  procedure Let(out int1: integer; out int2: integer; out int3: integer; out int4: integer; const values: array of integer); overload;

  { randomize the time based on the current milliseconds }
  procedure RandomizeSeed;

  { Instance wrappers }
  function Expect: TExpect;

implementation

uses
  System.StrUtils,
  System.Classes,
  System.TypInfo,
  System.Character;

{ Functions }

{----------------------------------------------------------------------------------------------------------------------}
function Expect: TExpect;
begin
  Result := TExpect.fInstance;
end;

{----------------------------------------------------------------------------------------------------------------------}
function ToPair(const aString: string; const aDelimiter: string): TPair<string, string>;
var
  lParts: TArray<string>;
begin
  lParts := SplitString(aString, aDelimiter);
  Result := TPair<string, string>.Create(lParts[0], lParts[1]);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Iff(aCondition: boolean; const aTrueValue: char; const aFalseValue: char): char;
begin
  if aCondition then
    Result := aTrueValue
  else
    Result := aFalseValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Iff(aCondition: boolean; const aTrueValue: string; const aFalseValue: string): string;
begin
  if aCondition then
    Result := aTrueValue
  else
    Result := aFalseValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Iff(aCondition: boolean; aTrueValue: integer; aFalseValue: integer): integer;
begin
  if aCondition then
    Result := aTrueValue
  else
    Result := aFalseValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure Let(out int1: integer; out int2: integer; const values: array of integer); overload;
begin
  int1 := 0;
  int2 := 0;

  if Length(values) > 0 then
    int1 := values[0];

  if Length(values) > 1 then
    int2 := values[1];
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure Let(out int1: integer; out int2: integer; out int3: integer; const values: array of integer); overload;
begin
  int1 := 0;
  int2 := 0;
  int3 := 0;

  if Length(values) > 0 then
    int1 := values[0];

  if Length(values) > 1 then
    int2 := values[1];

  if Length(values) > 2 then
    int3 := values[2];
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure Let(out int1: integer; out int2: integer; out int3: integer; out int4: integer; const values: array of integer); overload;
begin
  int1 := 0;
  int2 := 0;
  int3 := 0;
  int4 := 0;

  if Length(values) > 0 then
    int1 := values[0];

  if Length(values) > 1 then
    int2 := values[1];

  if Length(values) > 2 then
    int3 := values[2];

  if Length(values) > 3 then
    int4 := values[3];
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure RandomizeSeed;
var
  hours, mins, secs, milliSecs : Word;
begin
  DecodeTime(Now, hours, mins, secs, milliSecs);
  RandSeed := milliSecs;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TExpect.IsNotBlank(const aValue, aMessage: string): TExpect;
const
  BLANK_ERROR = 'value is blank error';
begin
  if string.IsNullOrWhiteSpace(aValue) then
    TExpectException.Throw(aMessage, BLANK_ERROR);

  Result := Self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TExpect.IsTrue(aValue: boolean; const aMessage: string): TExpect;
const
  CONDITION_ERROR = 'condition is false error';
begin
  if not aValue then
    TExpectException.Throw(aMessage, CONDITION_ERROR);

  Result := Self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TExpect.IsFalse(aValue: boolean; const aMessage: string): TExpect;
const
  CONDITION_ERROR = 'condition is true error';
begin
  if aValue then
    TExpectException.Throw(aMessage, CONDITION_ERROR);

  Result := Self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TExpect.IsAssigned<T>(aInstance: T; const aMessage: string): TExpect;
const
  NOT_ASSIGNED_ERROR = 'this instance is not assigned error';
begin
  if aInstance = default(T) then
    TExpectException.Throw(aMessage, NOT_ASSIGNED_ERROR);

  Result := Self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TExpect.IsEmpty<T>(const aList: TList<T>; const aMessage: string): TExpect;
const
  NOT_EMPTY_ERROR = 'the list is not empty error';
begin
  if aList.Count > 0 then
    TExpectException.Throw(aMessage, NOT_EMPTY_ERROR);

  Result := Self;
end;

{----------------------------------------------------------------------------------------------------------------------}
class constructor TExpect.Create;
begin
  fInstance := TExpect.Create;
end;

{----------------------------------------------------------------------------------------------------------------------}
class destructor TExpect.Destroy;
begin
  FreeAndNil(fInstance);
end;

{ TExpectException }

{----------------------------------------------------------------------------------------------------------------------}
class procedure TExpectException.Throw(const aMessage, aDefaultMessage: string);
var
  lMessage: string;
begin
  if Length(aMessage) > 0 then
    lMessage := aMessage
  else
    lMessage := aDefaultMessage;

  raise TExpectException.Create(lMessage);
end;

{ TScope }

{----------------------------------------------------------------------------------------------------------------------}
class operator TScope.Initialize(out Dest: TScope);
begin
  Dest.fInstances := TObjectList<TObject>.Create;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TScope.Add<T>(aInstance: T): T;
begin
  fInstances.Add(aInstance);
  Result := aInstance;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TScope.Add<T>: T;
begin
  Result := T.Create;
  fInstances.Add(Result);
end;

{----------------------------------------------------------------------------------------------------------------------}
class operator TScope.Finalize(var Dest: TScope);
begin
  Dest.fInstances.Free;
end;

{ TMaybe<T> }

{----------------------------------------------------------------------------------------------------------------------}
class function TMaybe<T>.Some(const AValue: T): TMaybe<T>;
begin
  Result.FHasValue := True;
  Result.FValue := AValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
class function TMaybe<T>.None: TMaybe<T>;
begin
  Result.FHasValue := False;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TMaybe<T>.OrElse(const Fallback: T): T;
begin
  if FHasValue then
    Result := FValue
  else
    Result := Fallback;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TMaybe<T>.IsSome: Boolean;
begin
  Result := FHasValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TMaybe<T>.IsNone: Boolean;
begin
  Result := not FHasValue;
end;

function TMaybe<T>.GetValue: T;
begin
  if not FHasValue then
    raise Exception.Create('Cannot access value of None');

  Result := FValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TMaybe<T>.OrElseGet(Func: TFunc<T>): T;
begin
  if FHasValue then
    Result := FValue
  else
    Result := Func();
end;

{ TResult<T> }

{----------------------------------------------------------------------------------------------------------------------}
class function TResult<T>.Ok(const AValue: T): TResult<T>;
begin
  Result.FValue := AValue;
  Result.FError := '';
  Result.FOk := True;
end;

{----------------------------------------------------------------------------------------------------------------------}
class function TResult<T>.Err(const AError: string): TResult<T>;
begin
  Result.FOk := False;
  Result.FError := AError;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TResult<T>.IsOk: Boolean;
begin
  Result := FOk;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TResult<T>.IsErr: Boolean;
begin
  Result := not FOk;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TResult<T>.GetValue: T;
begin
  if not FOk then
    raise Exception.Create('Cannot access Value of Err result');

  Result := FValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TResult<T>.GetError: string;
begin
  Result := FError;
end;

{ TRegisterAttribute }

{----------------------------------------------------------------------------------------------------------------------}
constructor TRegisterAttribute.Create(const aInterfaceGUID: TGUID; aRegisterType: TRegisterType);
begin
  inherited Create;

  fInterfaceGUID := aInterfaceGUID;
  fRegisterType  := aRegisterType;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TRegisterAttribute.IsByForce: boolean;
begin
  Result := fRegisterType = rtFromMap;
end;

end.
