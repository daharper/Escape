{***********************************************************************************************************************
  Unit:        SharedKernel.Collections
  Purpose:     Helper classes for working with collections.
  Author:      David Harper
  License:     MIT
  History:     2025-08-20  Initial version
***********************************************************************************************************************}
unit SharedKernel.Collections;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  SharedKernel.Core;

type
  /// <summary>
  /// Simple case-insensitive properties container.
  /// </summary>
  TProperties = class
  private
    fMap: TDictionary<string, string>;

  public
    type TEnumerator = TDictionary<string,string>.TPairEnumerator;

    /// <summary>
    /// Removes all properties.
    /// </summary>
    procedure Clear;

    /// <summary>
    /// Removes the property with the specified key.
    /// </summary>
    procedure Remove(const aKey: string);

    /// <summary>
    /// Adds or sets a property with the specified key and value.
    /// </summary>
    procedure Put(const aKey: string; const aValue: string);

    /// <summary>
    /// Gets the number of properties in the list.
    /// </summary>
    function Count: integer;

    /// <summary>
    /// Gets the value of the property with the specified key; returns an empty string of not found.
    /// </summary>
    function Get(const aKey: string): string;

    /// <summary>
    /// Gets the value of the property with the specified key; returns the default if not found.
    /// </summary>
    function GetOr(const aKey: string; const aDefault: string = ''): string;

    /// <summary>
    /// Tries to get the value of the property with the specified key; returns true if found.
    /// </summary>
    function TryGetValue(const aKey: string; out aValue:string): boolean;

    /// <summary>
    /// Determines whether a property with the specified key exists; returns true if found.
    /// </summary>
    function Contains(const aKey: string): boolean;

    /// <summary>
    /// Returns a list of keys.
    /// </summary>
    function Keys: TEnumerable<string>;

    /// <summary>
    /// Returns a list of values.
    /// </summary>
    function Values: TEnumerable<string>;

    /// <summary>
    /// Gets an enumerator for iterating the properties.
    /// </summary>
    function GetEnumerator: TEnumerator;

    /// <summary>
    /// Gets a value with the specified key if found; otherwise an empty string.
    /// </summary>
    property Value[const aKey: string]: string read Get write Put;

    /// <summary>
    /// Saves to the specified XML file.
    /// </summary>
    procedure SaveAsXml(aPath: string);

    /// <summary>
    /// Loads from the specified XML file.
    /// </summary>
    class function LoadFromXml(aPath: string): TProperties;

    /// <summary>
    /// Creates a new instance.
    /// </summary>
    constructor Create; overload;

    /// <summary>
    /// Creates a new instance initialized with the specified source.
    /// </summary>
    constructor Create(aSource: TEnumerable<TPair<string, string>>); overload;

    /// <summary>
    /// Creates a new instance initialized with the specified source.
    /// </summary>
    constructor Create(aSource: array of TPair<String, string>); overload;

    /// <summary>
    /// Frees up resources.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Utility methods to assist working with collections.
  /// </summary>
  TCollections = record
  public
    /// <summary>
    /// Adapts a TDictionary to a TObjectDictionary.
    /// </summary>
    class function ToObjectDictionary<T, V>(
      var aSource: TDictionary<T,V>;
      aOwnerships: TDictionaryOwnerships = [];
      aCleanupSource: boolean = true): TObjectDictionary<T,V>; static;

     /// <summary>
     /// Copies an enumerable to an array.
     /// </summary>
     /// <remarks>If you know the count, then it is more efficient to provide it.</remarks>
    class function ToArray<T>(var aSource: TEnumerable<T>; aCount: integer = -1): TArray<T>; static;

    /// <summary>
    /// Randomly shuffles the items in a list.
    /// </summary>
    class procedure Shuffle<T>(const aSource: TList<T>); static;

    /// <summary>
    /// Creates an array of integers from the specified start to the specified end (inclusive).
    /// </summary>
    class function Range(aStart, aEnd: integer; aStep: integer = 1): TArray<integer>; overload; static;

    /// <summary>
    /// Populates a list of integers in the specified start to end range (inclusive).
    /// </summary>
    class procedure Range(out aList : TList<integer>; aStart, aEnd: integer;aStep: integer = 1); overload; static;

    /// <summary>
    /// Creates an array of random integers in the specified range (inclusive).
    /// </summary>
    class function RangeRandom(aStart, aEnd, aCount: integer): TArray<integer>; overload; static;

    /// <summary>
    /// Populates a list of random integers in the specified start to end range.
    /// </summary>
    class procedure RangeRandom(out aList: TList<integer>; aStart, aEnd, aCount: integer); overload; static;

    /// <summary>
    /// Frees objects in a list, optionally calling the supplied disposer
    class procedure FreeAll<T>(var aSource: TList<T>; const aDisposer: TDisposer<T> = nil); overload; static;
  end;

  Enumerable<T> = record
  private
    fList: TList<T>;
    fOwnsList: boolean;

    procedure ReleaseOwnership(aDisposeList: boolean);

  public
//    procedure AddRange(const aItem: array of  T);

    class operator Initialize;
    class operator Finalize;
    class operator Assign(var Dest: Enumerable<T>; const [ref] Src: Enumerable<T>);
  end;

implementation

uses
  System.SysUtils,
  System.Math,
  System.IOUtils,
  SharedKernel.XmlParser,
  SharedKernel.Reflection;

{----------------------------------------------------------------------------------------------------------------------}
class function TCollections.Range(aStart, aEnd, aStep: integer): TArray<integer>;
var
  i: Integer;
  l: TList<integer>;
begin
  if aStep = 0 then
    raise EArgumentException.Create('Step must not be zero');

  if (aStart < aEnd) and (aStep < 0) then
    raise EArgumentException.Create('Step must be positive when start < end');

  if (aStart > aEnd) and (aStep > 0) then
    raise EArgumentException.Create('Step must be negative when start > end');

  i := aStart;
  l := TList<integer>.Create;

  try
    if aStep > 0 then
      while i <= aEnd do
      begin
        l.Add(i);
        Inc(i, aStep);
      end
    else
      while i >= aEnd do
      begin
        l.Add(i);
        Inc(i, aStep);
      end;

    Result := l.ToArray;
  finally
    l.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure TCollections.Range(out aList:TList<integer>; aStart, aEnd, aStep: integer);
var
  i: integer;
begin
  if aStep = 0 then
    raise EArgumentException.Create('Step must not be zero');

  if (aStart < aEnd) and (aStep < 0) then
    raise EArgumentException.Create('Step must be positive when start < end');

  if (aStart > aEnd) and (aStep > 0) then
    raise EArgumentException.Create('Step must be negative when start > end');

  aList := TList<integer>.Create;

  i := aStart;

  if aStep > 0 then
    while i <= aEnd do
    begin
      aList.Add(i);
      Inc(i, aStep);
    end
  else
    while i >= aEnd do
    begin
      aList.Add(i);
      Inc(i, aStep);
    end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class function TCollections.RangeRandom(aStart, aEnd, aCount: integer): TArray<integer>;
var
  i: integer;
  n: integer;
begin
  RandomizeSeed;

  SetLength(Result, aCount);

  n := aEnd + 1;

  for i := Low(Result) to High(Result) do
    Result[i] := RandomRange(aStart, n);
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure TCollections.RangeRandom(out aList: TList<integer>; aStart, aEnd, aCount: integer);
var
  i: integer;
  n: integer;
begin
  aList := TList<integer>.Create;

  RandomizeSeed;

  n := aEnd + 1;

  for i := 1 to aCount do
    aList.Add(RandomRange(aStart, n));
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure TCollections.Shuffle<T>(const aSource: TList<T>);
var
  lItems: TList<T>;
  i: integer;
begin
  if aSource.Count < 2 then exit;

  RandomizeSeed;

  lItems := TList<T>.Create(aSource);

  try
    aSource.Clear;

    while lItems.Count > 1 do
    begin
      i := RandomRange(0, lItems.Count);

      aSource.Add(lItems[i]);

      lItems.Delete(i);
    end;

    aSource.Add(lItems[0]);

  finally
    lItems.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class function TCollections.ToArray<T>(var aSource: TEnumerable<T>; aCount: integer): TArray<T>;
begin
  if aCount = -1 then
  begin
    var list := TList<T>.Create(aSource);
    exit(list.ToArray);
  end;

  SetLength(Result, aCount);

  var i := 0;

  for var item in aSource do
  begin
    Result[i] := item;
    Inc(i);

    if i = aCount then exit;
  end;
end;

{ TCollections }

{----------------------------------------------------------------------------------------------------------------------}
class function TCollections.ToObjectDictionary<T, V>(
  var aSource: TDictionary<T, V>;
  aOwnerships: TDictionaryOwnerships;
  aCleanupSource: boolean): TObjectDictionary<T, V>;
begin
  Result := TObjectDictionary<T,V>.Create(aOwnerships, aSource.Count, aSource.Comparer);

  for var p in aSource do
    Result.Add(p.Key, p.Value);

  if aCleanupSource then
  begin
    aSource.Clear;
    aSource.Free;
    aSource := nil;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure TCollections.FreeAll<T>(var aSource: TList<T>; const aDisposer: TDisposer<T>);
var
  i, count: Integer;
  tmp: T;
  obj: TObject;
  seen: TDictionary<TObject, Byte>;
  uniq: TList<TObject>;
  scope: TScope;
begin
  count := aSource.Count;

  // for non-class types clean up, exit quickly
  if not TReflection.IsClass<T> then
  begin
    if Assigned(aDisposer) then
    begin
      for i := 0 to count - 1 do
      begin
        tmp := aSource[i];
        aDisposer(tmp);
      end;
    end;

    exit;
  end;

  seen := scope.Add(TDictionary<TObject, Byte>.Create(count));
  uniq := scope.Add(TList<TObject>.Create);

  uniq.Capacity := count;

  // identify unique objects
  for i := 0 to count - 1 do
  begin
    tmp := aSource[i];
    obj := PObject(@tmp)^;

    if (obj <> nil) and not seen.ContainsKey(obj) then
    begin
      seen.Add(obj, 0);
      uniq.Add(obj);
    end;
  end;

  // free up unique objects
  for obj in uniq do
  begin
    if Assigned(aDisposer) then
    begin
      PObject(@tmp)^ := obj;
      aDisposer(tmp);
    end;

    obj.Free;
  end;
end;

{ TProperties }

{----------------------------------------------------------------------------------------------------------------------}
procedure TProperties.Clear;
begin
  fMap.Clear;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.Contains(const aKey: string): boolean;
begin
  Result := fMap.ContainsKey(aKey);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.Count: integer;
begin
  Result := fMap.Count;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.Get(const aKey: string): string;
begin
  fMap.TryGetValue(aKey, Result);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.GetOr(const aKey, aDefault: string): string;
begin
  if not fMap.ContainsKey(aKey) then
    Result := aDefault
  else
    Result := fMap[aKey];
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.GetEnumerator: TEnumerator;
begin
  Result := fMap.GetEnumerator;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TProperties.Put(const aKey, aValue: string);
begin
  fMap.AddOrSetValue(aKey, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TProperties.Remove(const aKey: string);
begin
  fMap.Remove(aKey);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.TryGetValue(const aKey: string; out aValue: string): boolean;
begin
  Result := fMap.TryGetValue(aKey, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.Keys: TEnumerable<string>;
begin
  Result := FMap.Keys;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.Values: TEnumerable<string>;
begin
  Result := FMap.Values;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TProperties.SaveAsXml(aPath: string);
var
  lElem: TBvElement;
begin
  lElem := TBvElement.FromProperties('properties', fMap);
  try
    TFile.WriteAllText(aPath, lElem.ToXml);
  finally
    lElem.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class function TProperties.LoadFromXml(aPath: string): TProperties;
var
  lXml:     string;
  lParser:  TResult<TBvElement>;
  lElem:    TBvElement;
  lSubElem: TBvElement;
begin
  Result  := TProperties.Create;
  lXml    := TFile.ReadAllText(aPath);
  lParser := TBvParser.Execute(lXml);

  Expect.IsTrue(lParser.IsOk, lParser.Error);

  lElem := lParser.Value;
  try
    for lSubElem in lElem do
      Result.Put(lSubElem.Name, lSubElem.Value);
  finally
    lElem.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TProperties.Create;
begin
  fMap := TDictionary<string, string>.Create(TIStringComparer.Ordinal);
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TProperties.Create(aSource: TEnumerable<TPair<string, string>>);
begin
  fMap := TDictionary<string, string>.Create(aSource, TIStringComparer.Ordinal);
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TProperties.Create(aSource: array of TPair<String, string>);
begin
  fMap := TDictionary<string, string>.Create(aSource, TIStringComparer.Ordinal);
end;

{----------------------------------------------------------------------------------------------------------------------}
destructor TProperties.Destroy;
begin
  fMap.Free;

  inherited;
end;

{ Enumerable<T> }

{----------------------------------------------------------------------------------------------------------------------}
class operator Enumerable<T>.Assign(var Dest: Enumerable<T>; const [ref] Src: Enumerable<T>);
var
  lDisposeList: boolean;
begin
  lDisposeList := Assigned(Dest.fList);

  if lDisposeList then
    Dest.fList := Src.fList
  else
    Dest.fList.AddRange(Src.fList);

  Src.ReleaseOwnership(lDisposeList);
end;

{----------------------------------------------------------------------------------------------------------------------}
class operator Enumerable<T>.Finalize;
begin
  if fOwnsList then
  begin
    TCollections.FreeAll<T>(fList);
    fList.Free;
  end;

  fList := nil;
end;

{----------------------------------------------------------------------------------------------------------------------}
class operator Enumerable<T>.Initialize;
begin
  fList := TList<T>.Create
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure Enumerable<T>.ReleaseOwnership(aDisposeList: boolean);
begin
  fOwnsList := false;

  if aDisposeList then
    fList.Free;

  fList := nil;
end;

end.
