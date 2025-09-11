{***********************************************************************************************************************
  Unit:        SharedKernel.Stream
  Purpose:     A synchronous (basic) Java-like stream for declarative stlye programming.
  Author:      David Harper
  License:     MIT
  History:     2025-08-20  Initial version
***********************************************************************************************************************}
unit SharedKernel.Streams;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  SharedKernel.Core;

type
  /// <summary>
  /// Managed record that allows transforms and termination operations on a stream. Please note,
  /// the stream does not own anything, it is merely a pipeline for processing. The client is
  /// responsible for making sure resources are cleaned up, although helpers exist. Operations
  /// are divided into stream initialization, transformation, and termination.
  /// /summary>
  Stream<T> = record
  private
    fList: TList<T>;

  public
    (* -------------------------------------------------------------------------------------------------------------- *)
    (*                                          Stream Terminating Operations                                         *)
    (* -------------------------------------------------------------------------------------------------------------- *)

    /// <summary>
    /// Gets the number of items in the stream.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function Count: integer;

    /// <summary>
    /// Determines if any of the items satisfies the provided predicate.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function AnyMatch(aPredicate: TConstPredicate<T>): boolean;

    /// <summary>
    /// Determines if all of the items satisfy the provided predicate.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function AllMatch(aPredicate: TConstPredicate<T>): boolean;

    /// <summary>
    /// Determines if none of the items satisfy the provided predicate.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function None(aPredicate: TConstPredicate<T>): boolean;

    /// <summary>
    /// Converts the stream to a list.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function ToList: TList<T>;

    /// <summary>
    /// Converts the stream to an array.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function ToArray: TArray<T>;

    /// <summary>
    /// Reduces all the items into a single value.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function Reduce<U>(aValue: U; const reducer: TFunc<U,T,U>): U;

    /// <summary>
    /// Determines the minimum value in the stream based on a specified comparer.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function Min(aComparer: IComparer<T> = nil): T;

    /// <summary>
    /// Determines the maximum value in the stream based on a specified comparer.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function Max(aComparer: IComparer<T> = nil): T;

    /// <summary>
    /// Converts the stream to a dictionary using the specified key/value factory.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function ToMap<K,V>(const aFactory: TConstFunc<T,TPair<K,V>>): TDictionary<K, V>; overload;

    /// <summary>
    /// Converts the stream to a dictionary using the specified default(U) for values.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function ToMap<U>: TDictionary<T, U>; overload;

    /// <summary>
    /// Converts the stream to a dictionary using the specified factory for values.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function ToMap<U>(const aFactory: TFunc<T, U>): TDictionary<T, U>; overload;

    /// <summary>
    /// Groups the items by an equality comparer.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function GroupBy(aComparer: IEqualityComparer<T> = nil): TDictionary<T, TList<T>>; overload;

    /// <summary>
    /// Groups the items according to keys produced by the supplied factory function.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function GroupBy<U>(const aKeyFactory: TConstFunc<T,U>): TDictionary<U, TList<T>>; overload;

    /// <summary>
    /// Gets the first item in the stream if present; otherwise an exception is thrown.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function First: T; overload;

    /// <summary>
    /// Gets the first item in the stream that matches the predicate; otherwise an exception is thrown.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function First(aPredicate: TConstPredicate<T>):T; overload;

    /// <summary>
    /// Gets the first item in the stream if present; otherwise the supplied default value.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function FirstOr(aDefault: T): T; overload;

    /// <summary>
    /// Gets the first item in the stream if present; otherwise default (T).
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function FirstOrDefault:T; overload;

    /// <summary>
    /// Gets the first item in the stream that matches the predicate; otherwise the default(T).
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function FirstOrDefault(aPredicate: TConstPredicate<T>):T; overload;

    /// <summary>
    /// Gets the last item in the stream if present; otherwise an exception is thrown.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function Last: T; overload;

    /// <summary>
    /// Gets the last item in the stream that matches the predicate; otherwise an exception is thrown.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function Last(aPredicate: TConstPredicate<T>):T; overload;

    /// <summary>
    /// Gets the last item in the stream if found; otherwise the default(T).
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function LastOrDefault: T; overload;

    /// <summary>
    /// Gets the last item in the stream that matches the predicate; otherwise the default(T).
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    function LastOrDefault(aPredicate: TConstPredicate<T>):T; overload;

    /// <summary>
    /// Passes each of the items to the consumer function.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    procedure Apply(aConsumer: TConstProc<T>);

    /// <summary>
    /// Frees all the items in the stream.
    /// </summary>
    /// <remarks>Terminates the stream.</remarks>
    procedure FreeAll(const aDisposer: TDisposer<T> = nil);

    (* -------------------------------------------------------------------------------------------------------------- *)
    (*                                          Stream Transforming Operations                                        *)
    (* -------------------------------------------------------------------------------------------------------------- *)

    /// <summary>
    /// Filters the stream by the specified predicate.
    /// </summary>
    /// <remarks>Returns the filtered stream.</remarks>
    function Filter(aPredicate: TConstPredicate<T>): Stream<T>;

    /// <summary>
    /// Keeps only the specified number of items in the stream.
    /// </summary>
    /// <remarks>Returns the limited stream.</remarks>
    function Limit(aCount: integer): Stream<T>;

    /// <summary>
    /// Maps the items to TPair<T,U> using the items for keys and default(U) for the values.
    /// </summary>
    /// <remarks>Returns the mapped stream.</remarks>
    function Map<U>(aMapper: TConstFunc<T, U>): Stream<U>;

    /// <summary>
    /// Passes the items to a consumer function.
    /// </summary>
    /// <remarks>Returns the stream.</remarks>
    function Peek(aConsumer: TConstProc<T>): Stream<T>;

    /// <summary>
    /// Reverses the items in the stream.
    /// </summary>
    /// <remarks>Returns the reversed stream.</remarks>
    function Reverse: Stream<T>;

    /// <summary>
    /// Skips the specified number of items.
    /// </summary>
    /// <remarks>Returns the stream, minus the skipped items.</remarks>
    function Skip(aCount: integer): Stream<T>;

    /// <summary>
    /// Skips items while the items match the specified predicate.
    /// </summary>
    /// <remarks>Returns the stream, minus the skipped items.</remarks>
    function SkipWhile(aPredicate: TConstPredicate<T>): Stream<T>;

    /// <summary>
    /// Takes items whilst they match the predicate.
    /// </summary>
    /// <remarks>Returns the stream with the matching items.</remarks>
    function TakeWhile(aPredicate: TConstPredicate<T>): Stream<T>;

    /// <summary>
    /// Sorts the items by the specified comparer, if none specified then the default is used.
    /// </summary>
    /// <remarks>Returns the sorted stream.</remarks>
    function Sort(aComparer: IComparer<T> = nil): Stream<T>;

    /// <summary>
    /// Selects distinct items via the specified equality comparer, if none specified then the default is ussd.
    /// </summary>
    /// <remarks>Returns the stream with distinct items.</remarks>
    function Distinct(aComparer: IEqualityComparer<T> = nil): Stream<T>; overload;

    /// <summary>
    /// Selects distinct items via the specified equality comparer, if none specified then the default is ussd.
    /// </summary>
    /// <remarks>Returns the stream with distinct items.</remarks>
    function Distinct<U>(const aKeyFactory: TConstFunc<T, U>): Stream<T>; overload;

    /// <summary>
    /// Selects the union with the specified stream using the equality comparer, or default comparer if non specified.
    /// </summary>
    /// <remarks>Returns the union as a stream.</remarks>
    function Union(const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T> = nil): Stream<T>; overload;

    /// <summary>
    /// Selects the union with the specified stream using the specified factory to generate keys for comparison.
    /// </summary>
    /// <remarks>Returns the union as a stream.</remarks>
    function Union<U>(const [ref] aStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>): Stream<T>; overload;

    /// <summary>
    /// Selects the difference with the specified stream using the equality comparer, or default comparer in none specified.
    /// </summary>
    /// <remarks>Returns the difference as a stream.</remarks>
    function Difference(const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T> = nil): Stream<T>; overload;

    /// <summary>
    /// Selects the difference with the specified stream using the specified factory to generate keys for comparison.
    /// </summary>
    /// <remarks>Returns the difference as a stream.</remarks>
    function Difference<U>(const [ref] aStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>): Stream<T>; overload;

    /// <summary>
    /// Selects the inserection with the specified stream using the equality comparer, or default comparer in none specified.
    /// </summary>
    /// <remarks>Returns the insersection as a stream.</remarks>
    function Intersect(const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T> = nil): Stream<T>; overload;

    /// <summary>
    /// Selects the inserection with the specified stream using the specified factory to generate keys for comparison.
    /// </summary>
    /// <remarks>Returns the insersection as a stream.</remarks>
    function Intersect<U>(const [ref] aStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>): Stream<T>; overload;

    /// <summary>
    /// Concates the stream with the specified items.
    /// </summary>
    /// <remarks>Returns the concatenated stream.</remarks>
    function Concat(const aItems: array of T): Stream<T>; overload;

    /// <summary>
    /// Concates the stream with the specified items.
    /// </summary>
    /// <remarks>Returns the concatenated stream.</remarks>
    function Concat(const aItems: TEnumerable<T>): Stream<T>; overload;

    /// <summary>
    /// Concates the stream with the specified stream.
    /// </summary>
    /// <remarks>Returns the concatenated stream.</remarks>
    function Concat(const [ref] aStream: Stream<T>): Stream<T>; overload;

    /// <summary>
    /// Removes items found in the specified stream, using the comparer or a default comparer.
    /// </summary>
    /// <remarks>Returns the stream.</remarks>
    function Remove(const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T> = nil): Stream<T>; overload;

    /// <summary>
    /// Removes the specified items from the stream, using the comparer or a default comparer.
    /// </summary>
    /// <remarks>Returns the stream.</remarks>
    function Remove(const aItems: TEnumerable<T>; aComparer: IEqualityComparer<T> = nil): Stream<T>; overload;

    /// <summary>
    /// Removes the specified items from the stream, using the comparer or a default comparer.
    /// </summary>
    /// <remarks>Returns the stream.</remarks>
    function Remove(const aItems: array of T; aComparer: IEqualityComparer<T> = nil): Stream<T>; overload;

    /// <summary>
    /// Removes the specified items from the stream, using a key factory to determine matches.
    /// </summary>
    /// <remarks>Returns the stream.</remarks>
    function Remove<U>(const [ref] aStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>): Stream<T>; overload;

    (* -------------------------------------------------------------------------------------------------------------- *)
    (*                                        Stream Initialization Operations                                        *)
    (* -------------------------------------------------------------------------------------------------------------- *)

    /// <summary>
    /// Initializes a stream with the specified items.
    /// </summary>
    procedure InitializeFrom(const aItems: TEnumerable<T>); overload;

    /// <summary>
    /// Initializes a stream with the specified items.
    /// </summary>
    procedure InitializeFrom(const aItems: array of T); overload;

    /// <summary>
    /// Creates a stream with the specified items.
    /// </summary>
    class function From(const aItems: TEnumerable<T>): Stream<T>; overload; static;

    /// <summary>
    /// Creates a stream with the specified items.
    /// </summary>
    class function From(const aItems: array of T): Stream<T>; overload; static;

    /// <summary>
    /// Creates a stream from the specified range.
    /// </summary>
    class function Range(aStart: integer; aEnd: integer; aStep: integer = 1): Stream<integer>; static;

    /// <summary>
    /// Creates a stream of count items which are random numbers between the specified start and end (inclusive).
    /// </summary>
    class function Random(aStart: integer; aEnd: integer; aCount: integer): Stream<integer>; static;

    /// <summary>
    /// Produces a stream of count values.
    /// </summary>
    class function Produce(aCount: integer; const aValue: T): Stream<T>; overload; static;

    /// <summary>
    /// Produces a stream of count values provided by the factory function.
    /// </summary>
    /// <remarks>Passes the current index (zero based) to the factory</remarks>
    class function Produce(aCount: integer; const aFactory: TConstFunc<integer, T>): Stream<T>; overload; static;

    { class operators }

    class operator Initialize (out Dest: Stream<T>);

    class operator Finalize(var Dest: Stream<T>);
  end;

  /// <summary>
  /// Stream helper classes to help reduce bloat.
  /// </summary>
  StreamExtensions = class
  public
    class function GroupBy<T>(const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T> = nil): TDictionary<T, TList<T>>; overload;

    class function GroupBy<T>(const [ref] aStream: Stream<T>; const aKeyFactory: TFunc<T, string>; aIgnoreCase: boolean = true): TDictionary<string, TList<T>>; overload;

    class function Max<T>(const [ref] aStream: Stream<T>; aComparer: IComparer<T> = nil): T;

    class function Min<T>(const [ref] aStream: Stream<T>; aComparer: IComparer<T> = nil): T;

    class procedure Difference<T, U>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; const aKeyFactory: TConstFunc<T, U>); overload;

    class procedure Difference<T>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; aComparer: IEqualityComparer<T> = nil); overload;

    class procedure Distinct<T, U>(const [ref] aResult: Stream<T>; const [ref] aStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>); overload;

    class procedure Distinct<T>(const [ref] aResult: Stream<T>; const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T> = nil); overload;

    class procedure Intersect<T, U>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; const aKeyFactory: TConstFunc<T, U>); overload;

    class procedure Intersect<T>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; aComparer: IEqualityComparer<T> = nil); overload;

    class procedure Remove<T, U>(const [ref] aResult: Stream<T>; const [ref] aStream: Stream<T>; const [ref] aRemoveStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>); overload;

    class procedure Remove<T>(const [ref] aResult: Stream<T>;const [ref] aStream: Stream<T>; const [ref] aRemoveStream: Stream<T>; aComparer: IEqualityComparer<T> = nil); overload;

    class procedure Union<T, U>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; const aKeyFactory: TConstFunc<T, U>); overload;

    class procedure Union<T>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; aComparer: IEqualityComparer<T> = nil); overload;
  end;

const
  INIT_ERROR = 'stream has already been initialized';

implementation

uses
  System.Math,
  SharedKernel.Collections,
  SharedKernel.Reflection;

{ Stream<T> }

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Concat(const [ref] aStream: Stream<T>): Stream<T>;
begin
  Result.fList.AddRange(fList);
  Result.fList.AddRange(aStream.fList);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Concat(const aItems: TEnumerable<T>): Stream<T>;
begin
  Result.fList.AddRange(fList);
  Result.fList.AddRange(aItems);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Concat(const aItems: array of T): Stream<T>;
begin
  Result.fList.AddRange(fList);
  Result.fList.AddRange(aItems);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Distinct(aComparer: IEqualityComparer<T>): Stream<T>;
begin
  StreamExtensions.Distinct<T>(Result, Self, aComparer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Distinct<U>(const aKeyFactory: TConstFunc<T, U>): Stream<T>;
begin
  StreamExtensions.Distinct<T, U>(Result, Self, aKeyFactory);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Union(const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T>): Stream<T>;
begin
  StreamExtensions.Union<T>(Result, Self, aStream, aComparer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Union<U>(const [ref] aStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>): Stream<T>;
begin
  StreamExtensions.Union<T,U>(Result, Self, aStream, aKeyFactory);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Difference(const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T>): Stream<T>;
begin
  StreamExtensions.Difference<T>(Result, Self, aStream, aComparer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Difference<U>(const [ref] aStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>): Stream<T>;
begin
  StreamExtensions.Difference<T, U>(Result, Self, aStream, aKeyFactory);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Intersect(const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T>): Stream<T>;
begin
  StreamExtensions.Intersect<T>(Result, Self, aStream, aComparer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Intersect<U>(const [ref] aStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>): Stream<T>;
begin
  StreamExtensions.Intersect<T, U>(Result, Self, aStream, aKeyFactory);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.AllMatch(aPredicate: TConstPredicate<T>): boolean;
var
  lItem: T;
begin
  for lItem in fList do
    if not aPredicate(lItem) then exit(false);

  Result := true;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.AnyMatch(aPredicate: TConstPredicate<T>): boolean;
var
  lItem: T;
begin
  for lItem in fList do
    if aPredicate(lItem) then exit(true);

  Result := false;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.None(aPredicate: TConstPredicate<T>): boolean;
var
  lItem: T;
begin
  for lItem in fList do
    if aPredicate(lItem) then exit(false);

  Result := true;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Count: integer;
begin
  Result := fList.Count;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.First: T;
const
  NOT_FOUND = 'item not found';
begin
  if fList.Count > 0 then exit(fList[0]);

  raise Exception.Create(NOT_FOUND);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.First(aPredicate: TConstPredicate<T>): T;
const
  NOT_FOUND = 'item not found';
var
  lItem: T;
begin
  for lItem in fList do
    if aPredicate(lItem) then exit(lItem);

  raise Exception.Create(NOT_FOUND);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.FirstOrDefault: T;
begin
  if fList.Count > 0 then exit(fList[0]);

  Result := default(T);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.FirstOr(aDefault: T): T;
begin
  if fList.Count > 0 then exit(fList[0]);

  Result := aDefault;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.FirstOrDefault(aPredicate: TConstPredicate<T>): T;
var
  lItem: T;
begin
  for lItem in fList do
    if aPredicate(lItem) then exit(lItem);

  Result := default(T);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Last: T;
const
  NOT_FOUND = 'item not found';
begin
  if fList.Count > 0 then exit(fList[Pred(fList.Count)]);

  raise Exception.Create(NOT_FOUND);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Last(aPredicate: TConstPredicate<T>): T;
const
  NOT_FOUND = 'item not found';
var
  i: integer;
  n: integer;
  lItem: T;
begin
  n := Pred(fList.Count);

  for i := n DownTo 0 do
  begin
    lItem := fList[i];
    if aPredicate(lItem) then exit(lItem);
  end;

  raise Exception.Create(NOT_FOUND);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.LastOrDefault: T;
begin
  if fList.Count > 0 then exit(fList[Pred(fList.Count)]);

  Result := default(T);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.LastOrDefault(aPredicate: TConstPredicate<T>): T;
var
  i: integer;
  n: integer;
  lItem: T;
begin
  n := Pred(fList.Count);

  for i := n DownTo 0 do
  begin
    lItem := fList[i];
    if aPredicate(lItem) then exit(lItem);
  end;

  Result := default(T);
end;

//{----------------------------------------------------------------------------------------------------------------------}
procedure Stream<T>.FreeAll(const aDisposer: TDisposer<T>);
begin
  TCollections.FreeAll<T>(fList, aDisposer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.ToArray: TArray<T>;
begin
  Result := fList.ToArray;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.ToList: TList<T>;
begin
  Result := TList<T>.Create(fList);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.ToMap<U>: TDictionary<T, U>;
var
  lItem: T;
  lValue: U;
begin
  Result := TDictionary<T, U>.Create;

  lValue := default(U);

  for lItem in fList do
    Result.Add(lItem, lValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.ToMap<U>(const aFactory: TFunc<T, U>): TDictionary<T, U>;
var
  lItem: T;
begin
  Result := TDictionary<T, U>.Create;

  for lItem in fList do
    Result.Add(lItem, aFactory(lItem));
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.ToMap<K, V>(const aFactory: TConstFunc<T,TPair<K,V>>): TDictionary<K, V>;
var
  lItem: T;
  lPair:  TPair<K,V>;
begin
  Result := TDictionary<K, V>.Create;

  for lItem in fList do
  begin
    lPair := aFactory(lItem);
    Result.Add(lPair.Key, lPair.Value);
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.GroupBy(aComparer: IEqualityComparer<T>): TDictionary<T, TList<T>>;
begin
  Result := StreamExtensions.GroupBy<T>(Self, aComparer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.GroupBy<U>(const aKeyFactory: TConstFunc<T,U>): TDictionary<U, TList<T>>;
var
  lItem: T;
  lKey: U;
begin
  Result := TDictionary<U, TList<T>>.Create;

  for lItem in fList do
  begin
    lKey := aKeyFactory(lItem);

    if not Result.ContainsKey(lKey) then
      Result.Add(lKey, TList<T>.Create);

    Result[lKey].Add(lItem);
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure Stream<T>.Apply(aConsumer: TConstProc<T>);
var
  lItem: T;
begin
  for lItem in fList do
    aConsumer(lItem);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Filter(aPredicate: TConstPredicate<T>): Stream<T>;
var
  lItem: T;
begin
  for lItem in fList do
    if aPredicate(lItem) then
      Result.fList.Add(lItem);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Map<U>(aMapper: TConstFunc<T, U>): Stream<U>;
var
  lItem: T;
begin
  for lItem in fList do
    Result.fList.Add(aMapper(lItem));
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Min(aComparer: IComparer<T>): T;
begin
  Result := StreamExtensions.Min<T>(Self, aComparer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Max(aComparer: IComparer<T>): T;
begin
  Result := StreamExtensions.Max<T>(Self, aComparer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Peek(aConsumer: TConstProc<T>): Stream<T>;
var
  lItem: T;
begin
  for lItem in fList do
    aConsumer(lItem);

  Result.fList.AddRange(fList);
end;

{----------------------------------------------------------------------------------------------------------------------}
class function Stream<T>.Produce(aCount: integer; const aFactory: TConstFunc<integer, T>): Stream<T>;
var
  i: integer;
begin
  for i := 0 to Pred(aCount) do
    Result.fList.Add(aFactory(i));
end;

{----------------------------------------------------------------------------------------------------------------------}
class function Stream<T>.Produce(aCount: integer; const aValue: T): Stream<T>;
var
  i: integer;
begin
  for i := 0 to Pred(aCount) do
    Result.fList.Add(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Reduce<U>(aValue: U; const reducer: TFunc<U, T, U>): U;
var
  lItem: T;
begin
  for lItem in fList do
    aValue := reducer(aValue, lItem);

  Result := aValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Remove(const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T>): Stream<T>;
begin
  StreamExtensions.Remove<T>(Result, Self, aStream, aComparer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Remove(const aItems: TEnumerable<T>; aComparer: IEqualityComparer<T>): Stream<T>;
var
  lStream: Stream<T>;
begin
  lStream.fList.AddRange(aItems);
  StreamExtensions.Remove<T>(Result, Self, lStream, aComparer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Remove(const aItems: array of T; aComparer: IEqualityComparer<T>): Stream<T>;
var
  lStream: Stream<T>;
begin
  lStream.fList.AddRange(aItems);
  StreamExtensions.Remove<T>(Result, Self, lStream, aComparer);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Remove<U>(const [ref] aStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>): Stream<T>;
begin
  StreamExtensions.Remove<T, U>(Result, Self, aStream, aKeyFactory);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Reverse: Stream<T>;
begin
  fList.Reverse;
  Result.fList.AddRange(fList);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Skip(aCount: integer): Stream<T>;
var
  i: integer;
begin
  if aCount >= fList.Count then exit;

  for i := aCount to Pred(fList.Count) do
    Result.fList.Add(fList[i]);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.SkipWhile(aPredicate: TConstPredicate<T>): Stream<T>;
var
  lItem: T;
  lIgnoring: boolean;
begin
  lIgnoring := true;

  for lItem in fList do
  begin
    if lIgnoring then
    begin
      if aPredicate(lItem) then continue;
      lIgnoring := false;
    end;

    Result.fList.Add(lItem);
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.TakeWhile(aPredicate: TConstPredicate<T>): Stream<T>;
var
  lItem: T;
begin
  for lItem in fList do
  begin
    if not aPredicate(lItem) then exit;
    Result.fList.Add(lItem)
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Sort(aComparer: IComparer<T>): Stream<T>;
begin
  if not Assigned(aComparer) then
    aComparer := TComparer<T>.Default;

  fList.Sort(aComparer);
  Result.fList.AddRange(fList);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Stream<T>.Limit(aCount: integer): Stream<T>;
var
  i: integer;
  n: integer;
begin
  n := System.Math.Min(aCount, fList.Count) - 1;

  for i := 0 to n do
    Result.fList.Add(fList[i]);
end;

//{----------------------------------------------------------------------------------------------------------------------}
class function Stream<T>.From(const aItems: array of T): Stream<T>;
begin
  Result.fList.AddRange(aItems);
end;

{----------------------------------------------------------------------------------------------------------------------}
class function Stream<T>.From(const aItems: TEnumerable<T>): Stream<T>;
begin
  Result.fList.AddRange(aItems);
end;

{----------------------------------------------------------------------------------------------------------------------}
class function Stream<T>.Range(aStart, aEnd, aStep: integer): Stream<integer>;
var
  i: Integer;
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
      Result.fList.Add(i);
      Inc(i, aStep);
    end
  else
    while i >= aEnd do
    begin
      Result.fList.Add(i);
      Inc(i, aStep);
    end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class function Stream<T>.Random(aStart, aEnd, aCount: integer): Stream<integer>;
var
  i: integer;
  r: integer;
  n: integer;
begin
  RandomizeSeed;

  i := 0;
  n := aEnd + 1;

  while i < aCount do
  begin
    r := RandomRange(aStart, n);
    Result.fList.Add(r);
    Inc(i);
  end;
end;

//{----------------------------------------------------------------------------------------------------------------------}
procedure Stream<T>.InitializeFrom(const aItems: array of T);
begin
  fList.AddRange(aItems);
end;

//{----------------------------------------------------------------------------------------------------------------------}
procedure Stream<T>.InitializeFrom(const aItems: TEnumerable<T>);
begin
  fList.AddRange(aItems);
end;

{----------------------------------------------------------------------------------------------------------------------}
class operator Stream<T>.Initialize(out Dest: Stream<T>);
begin
  Dest.fList := TList<T>.Create;
end;

{----------------------------------------------------------------------------------------------------------------------}
class operator Stream<T>.Finalize(var Dest: Stream<T>);
begin
  Dest.fList.Free;
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure StreamExtensions.Difference<T, U>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; const aKeyFactory: TConstFunc<T, U>);
var
  lMatches: TDictionary<U, TPair<integer, T>>;
  lPair: TPair<integer, T>;
  lItem: T;
  lKey: U;
begin
   lMatches := TDictionary<U, TPair<integer, T>>.Create;

  try
    { add distinct items from the first list to the matches map }
    for lItem in aFirst.fList do
    begin
      lKey := aKeyFactory(lItem);

      if not lMatches.ContainsKey(lKey) then
        lMatches.Add(lKey, TPair<integer, T>.Create(1, lItem));
    end;

    { try to identify matches between the map and the second list }
    for lItem in aSecond.fList do
    begin
      lKey := aKeyFactory(lItem);

      if not lMatches.ContainsKey(lKey) then
        lMatches.Add(lKey, TPair<integer, T>.Create(0, lItem))
      else if lMatches[lKey].Key = 1 then
        lMatches[lKey] := TPair<integer, T>.Create(2, lItem);
    end;

    for lPair in lMatches.Values do
      if lPair.Key < 2 then
        aResult.fList.Add(lPair.Value);

  finally
    lMatches.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure StreamExtensions.Difference<T>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; aComparer: IEqualityComparer<T>);
var
  lMatches: TDictionary<T, integer>;
  lPair: TPair<T, integer>;
  lItem: T;
begin
  if not Assigned(aComparer) then
    aComparer := TEqualityComparer<T>.Default;

  lMatches := TDictionary<T, integer>.Create(aComparer);

  try
    { add distinct items from the first list to the matches map }
    for lItem in aFirst.fList do
      if not lMatches.ContainsKey(lItem) then
        lMatches.Add(lItem, 1);

    { try to identify matches between the map and the second list }
    for lItem in aSecond.fList do
    begin
      if not lMatches.ContainsKey(lItem) then
        lMatches.Add(lItem, 0)
      else if lMatches[lItem] = 1 then
        lMatches[lItem] := 2;
    end;

    for lPair in lMatches do
      if lPair.Value < 2 then
        aResult.fList.Add(lPair.Key);

  finally
    lMatches.Free;
  end;

end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure StreamExtensions.Distinct<T, U>(const [ref] aResult: Stream<T>; const [ref] aStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>);
var
  lItem: T;
  lKey: U;
  lSeen: TDictionary<U, boolean>;
begin
  lSeen := TDictionary<U, boolean>.Create;

  try
    for lItem in aStream.fList do
    begin
      lKey := aKeyFactory(lItem);

      if not lSeen.ContainsKey(lKey) then
      begin
        lSeen.Add(lKey, true);
        aResult.fList.Add(lItem);
      end;
    end;
  finally
    lSeen.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure StreamExtensions.Distinct<T>(const [ref] aResult: Stream<T>; const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T>);
var
  lItem: T;
  lSeen: TDictionary<T, boolean>;
begin
  if not Assigned(aComparer) then
    aComparer := TEqualityComparer<T>.Default;

  lSeen := TDictionary<T, boolean>.Create(aComparer);
  try
    for lItem in aStream.fList do
      if not lSeen.ContainsKey(lItem) then
      begin
        lSeen.Add(lItem, true);
        aResult.fList.Add(lItem);
      end;
  finally
    lSeen.Free;
  end;
end;

{ StreamExtensions }

{----------------------------------------------------------------------------------------------------------------------}
class function StreamExtensions.GroupBy<T>(const [ref] aStream: Stream<T>; aComparer: IEqualityComparer<T>): TDictionary<T, TList<T>>;
var
  lItem: T;
begin
  if not Assigned(aComparer) then
    aComparer := TEqualityComparer<T>.Default;

  Result := TDictionary<T, TList<T>>.Create(aComparer);

  for lItem in aStream.fList do
  begin
    if not Result.ContainsKey(lItem) then
      Result.Add(lItem, TList<T>.Create);

    Result[lItem].Add(lItem);
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class function StreamExtensions.GroupBy<T>(const [ref] aStream: Stream<T>; const aKeyFactory: TFunc<T, string>; aIgnoreCase: boolean): TDictionary<string, TList<T>>;
var
  lItem: T;
  lKey: string;
begin
  if aIgnoreCase then
    Result := TDictionary<string, TList<T>>.Create(TIStringComparer.Ordinal)
  else
    Result := TDictionary<string, TList<T>>.Create;

  for lItem in aStream.fList do
  begin
    lKey := aKeyFactory(lItem);

    if not Result.ContainsKey(lKey) then
      Result.Add(lKey, TList<T>.Create);

    Result[lKey].Add(lItem);
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure StreamExtensions.Intersect<T, U>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; const aKeyFactory: TConstFunc<T, U>);
var
  lSmallest: TList<T>;
  lLargest: TList<T>;
  lMatches: TDictionary<U, TPair<integer, T>>;
  lPair: TPair<integer, T>;
  lItem: T;
  lKey: U;
begin
  { determine the smallest list of numbers }
  if aFirst.fList.Count > aSecond.fList.Count then
  begin
    lLargest  := aFirst.fList;
    lSmallest := aSecond.fList;
  end
  else
  begin
    lSmallest := aFirst.fList;
    lLargest  := aSecond.fList;
  end;

  lMatches := TDictionary<U, TPair<integer, T>>.Create;

  try
    { add distinct items from the first list to the matches map }
    for lItem in lSmallest do
    begin
      lKey := aKeyFactory(lItem);

      if not lMatches.ContainsKey(lKey) then
        lMatches.Add(lKey, TPair<integer, T>.Create(1, lItem));
    end;

    { try to identify matches between the map and the second list }
    for lItem in lLargest do
    begin
      lKey := aKeyFactory(lItem);

      if lMatches.ContainsKey(lKey) then
        if lMatches[lKey].Key = 1 then
          lMatches[lKey] := TPair<integer, T>.Create(2, lItem);
    end;

    for lPair in lMatches.Values do
      if lPair.Key = 2 then
        aResult.fList.Add(lPair.Value);

  finally
    lMatches.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure StreamExtensions.Intersect<T>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; aComparer: IEqualityComparer<T>);
var
  lSmallest: TList<T>;
  lLargest:  TList<T>;
  lMatches: TDictionary<T, integer>;
  lPair: TPair<T, integer>;
  lItem: T;
begin
  if not Assigned(aComparer) then
    aComparer := TEqualityComparer<T>.Default;

  { determine the smallest list of numbers }
  if aFirst.fList.Count > aSecond.fList.Count then
  begin
    lLargest  := aFirst.fList;
    lSmallest := aSecond.fList;
  end
  else
  begin
    lSmallest := aFirst.fList;
    lLargest  := aSecond.fList;
  end;

  lMatches := TDictionary<T, integer>.Create(aComparer);

  try
    { add distinct items from the first list to the matches map }
    for lItem in lSmallest do
    begin
      if not lMatches.ContainsKey(lItem) then
        lMatches.Add(lItem, 1);
    end;

    { try to identify matches between the map and the second list }
    for lItem in lLargest do
    begin
      if lMatches.ContainsKey(lItem) then
        if lMatches[lItem] = 1 then
          lMatches[lItem] := 2;
    end;

    for lPair in lMatches do
      if lPair.Value = 2 then
        aResult.fList.Add(lPair.Key);
  finally
    lMatches.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class function StreamExtensions.Max<T>(const [ref] aStream: Stream<T>; aComparer: IComparer<T>): T;
var
  lItem: T;
  i: integer;
begin
  if not Assigned(aComparer) then
    aComparer := TComparer<T>.Default;

  if aStream.fList.Count = 0 then exit(default(T));
  if aStream.fList.Count = 1 then exit(aStream.fList[0]);

  Result := aStream.fList[0];

  for i := 1 to Pred(aStream.fList.Count) do
  begin
    lItem := aStream.fList[i];

    if aComparer.Compare(lItem, Result) > 0 then
      Result := lItem;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class function StreamExtensions.Min<T>(const [ref] aStream: Stream<T>; aComparer: IComparer<T>): T;
var
  lItem: T;
  i: integer;
begin
  if not Assigned(aComparer) then
    aComparer := TComparer<T>.Default;

  if aStream.fList.Count = 0 then exit(default(T));
  if aStream.fList.Count = 1 then exit(aStream.fList[0]);

  Result := aStream.fList[0];

  for i := 1 to Pred(aStream.fList.Count) do
  begin
    lItem := aStream.fList[i];

    if aComparer.Compare(lItem, Result) < 0 then
      Result := lItem;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure StreamExtensions.Remove<T, U>(const [ref] aResult: Stream<T>; const [ref] aStream: Stream<T>; const [ref] aRemoveStream: Stream<T>; const aKeyFactory: TConstFunc<T, U>);
var
  lRemoved: TDictionary<U, boolean>;
  lItem: T;
  lKey: U;
begin
  lRemoved := TDictionary<U, boolean>.Create;

  try
    for lItem in aRemoveStream.fList do
    begin
      lKey := aKeyFactory(lItem);

      if not lRemoved.ContainsKey(lKey) then
        lRemoved.Add(lKey, true);
    end;

    for lItem in aStream.fList do
    begin
      lKey := aKeyFactory(lItem);

      if not lRemoved.ContainsKey(lKey) then
        aResult.fList.Add(lItem);
    end;
  finally
    lRemoved.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
 class procedure StreamExtensions.Remove<T>(const [ref] aResult: Stream<T>;const [ref] aStream: Stream<T>; const [ref] aRemoveStream: Stream<T>; aComparer: IEqualityComparer<T> = nil);
var
  lRemoved: TDictionary<T, boolean>;
  lItem: T;
begin
  if not Assigned(aComparer) then
    aComparer := TEqualityComparer<T>.Default;

  lRemoved := TDictionary<T, boolean>.Create(aComparer);

  try
    for lItem in aRemoveStream.fList do
    begin
      if not lRemoved.ContainsKey(lItem) then
        lRemoved.Add(lItem, true);
    end;

    for lItem in aStream.fList do
      if not lRemoved.ContainsKey(lItem) then
        aResult.fList.Add(lItem);
  finally
    lRemoved.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure StreamExtensions.Union<T, U>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; const aKeyFactory: TConstFunc<T, U>);
var
  lMatches: TDictionary<U, T>;
  lItem: T;
  lKey: U;
begin
  lMatches := TDictionary<U, T>.Create;

  try
    { add distinct items from the first list to the matches map }
    for lItem in aFirst.fList do
    begin
      lKey := aKeyFactory(lItem);

      if not lMatches.ContainsKey(lKey) then
        lMatches.Add(lKey, lItem);
    end;

    { add distinct items from the second list to the matches map }
    for lItem in aSecond.fList do
    begin
      lKey := aKeyFactory(lItem);

      if not lMatches.ContainsKey(lKey) then
        lMatches.Add(lKey, lItem);
    end;

    aResult.fList.AddRange(lMatches.Values);

  finally
    lMatches.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class procedure StreamExtensions.Union<T>(const [ref] aResult: Stream<T>; const [ref] aFirst: Stream<T>; const [ref] aSecond: Stream<T>; aComparer: IEqualityComparer<T>);
var
  lMatches: TDictionary<T, boolean>;
  lItem: T;
begin
  if not Assigned(aComparer) then
    aComparer := TEqualityComparer<T>.Default;

  lMatches := TDictionary<T, boolean>.Create(aComparer);

  try
    { add distinct items from the first list to the matches map }
    for lItem in aFirst.fList do
      if not lMatches.ContainsKey(lItem) then
        lMatches.Add(lItem, true);

    { add distinct items from the second list to the matches map }
    for lItem in aSecond.fList do
      if not lMatches.ContainsKey(lItem) then
        lMatches.Add(lItem, true);

    aResult.fList.AddRange(lMatches.Keys);

  finally
    lMatches.Free;
  end;
end;

end.
