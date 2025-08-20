{*******************************************************************************
  Unit:        SharedKernel.Stream
  Purpose:     A synchronous Java-like stream for declarative stlye programming.
  Author:      David Harper
  License:     MIT
  History:     2025-08-20  Initial version
*******************************************************************************}

unit SharedKernel.Stream;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  SharedKernel.Core;

type
  TReflectionHelper = class

  end;

  Stream<T> = record
  private
    fList: TList<T>;

  public
    { terminating operations }

    function Count: integer;
    function ToArray: TArray<T>;

    { transforming operations }

    function Filter(aPredicate: TPredicate<T>): Stream<T>; overload;
    function FilterRecord(aPredicate: TRefPredicate<T>): Stream<T>; overload;

    { initializing operations }
    class function From(const aItems: TEnumerable<T>): Stream<T>; overload; static;
    class function From(const aItems: array of T): Stream<T>; overload; static;

    { class operators }
    class operator Initialize (out Dest: Stream<T>);
    class operator Finalize(var Dest: Stream<T>);
  end;

implementation

uses
  System.TypInfo;

{ Stream<T> }

{------------------------------------------------------------------------------}
function Stream<T>.Count: integer;
begin
  Result := fList.Count;
end;

{------------------------------------------------------------------------------}
function Stream<T>.Filter(aPredicate: TPredicate<T>): Stream<T>;
var
  lItem: T;
begin
  for lItem in fList do
    if aPredicate(lItem) then
      Result.fList.Add(lItem);
end;

{------------------------------------------------------------------------------}
function Stream<T>.FilterRecord(aPredicate: TRefPredicate<T>): Stream<T>;
var
  lItem: T;
begin
  for lItem in fList do
    if aPredicate(lItem) then
      Result.fList.Add(lItem);
end;

{------------------------------------------------------------------------------}
function Stream<T>.ToArray: TArray<T>;
begin
  Result := fList.ToArray;
end;

{$region 'initializing operations'}

//-----------------------------------------------------------------------------}
class function Stream<T>.From(const aItems: array of T): Stream<T>;
begin
  Result.fList.AddRange(aItems);
end;

{------------------------------------------------------------------------------}
class function Stream<T>.From(const aItems: TEnumerable<T>): Stream<T>;
begin
  Result.fList.AddRange(aItems);
end;

{$endregion}

{$region 'class operators'}

{------------------------------------------------------------------------------}
class operator Stream<T>.Initialize(out Dest: Stream<T>);
begin
  Dest.fList := TList<T>.Create;
end;

{------------------------------------------------------------------------------}
class operator Stream<T>.Finalize(var Dest: Stream<T>);
begin
  Dest.fList.Free;
end;

{$endregion}

end.
