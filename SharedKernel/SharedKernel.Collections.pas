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
    class function ToArray<T>(const aSource: TEnumerable<T>; aCount: integer = -1): TArray<T>; static;

    /// <summary>
    /// Randomly shuffles the items in a list.
    /// </summary>
    class procedure Shuffle<T>(const aSource: TList<T>); static;

    /// <summary>
    /// Creates an array of integers in the specified ranger
    class procedure Range(const aList: TList<integer>; aStart, aEnd: integer;aStep: integer = 1); overload; static;

    /// <summary>
    /// Creates an array of integers from the specified start to the specified end (inclusive).
    /// </summary>
    class function Range(aStart, aEnd: integer; aStep: integer = 1): TArray<integer>; overload; static;

    /// <summary>
    /// Creates an array of random integers in the specified range (inclusive).
    /// </summary>
    class function RandRange(aStart, aEnd, aCount: integer): TArray<integer>; overload; static;

    /// <summary>
    /// Populates a list of random integers in the specified start to end range.
    /// </summary>
    class procedure RandRange(const aList: TList<integer>; aStart, aEnd, aCount: integer); overload; static;

    /// <summary>
    /// Frees objects in a list, optionally calling the supplied disposer.
    /// </summary>
    class procedure FreeAll<T>(const aSource: TList<T>; const aDisposer: TDisposer<T> = nil); overload; static;
  end;

implementation

uses
  System.SysUtils,
  System.Math,
  System.IOUtils,
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
class procedure TCollections.Range(const aList: TList<integer>; aStart, aEnd, aStep: integer);
var
  i: integer;
begin
  if aStep = 0 then
    raise EArgumentException.Create('Step must not be zero');

  if (aStart < aEnd) and (aStep < 0) then
    raise EArgumentException.Create('Step must be positive when start < end');

  if (aStart > aEnd) and (aStep > 0) then
    raise EArgumentException.Create('Step must be negative when start > end');

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
class function TCollections.RandRange(aStart, aEnd, aCount: integer): TArray<integer>;
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
class procedure TCollections.RandRange(const aList: TList<integer>; aStart, aEnd, aCount: integer);
var
  i: integer;
  n: integer;
begin
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
class function TCollections.ToArray<T>(const aSource: TEnumerable<T>; aCount: integer): TArray<T>;
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
class procedure TCollections.FreeAll<T>(const aSource: TList<T>; const aDisposer: TDisposer<T>);
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

    aSource.Clear;
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

  aSource.Clear;
end;

end.
