{***********************************************************************************************************************
  Unit:        SharedKernel.Enumerable
  Purpose:     Helper class for working with list.
  Author:      David Harper
  License:     MIT
  History:     2025-08-20  Initial version
***********************************************************************************************************************}

unit SharedKernel.Enumerable;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  SharedKernel.Core;

type
  /// <summary>
  /// Managed record that wraps a list, providing convenience methods. Becareful not to pass by value,
  /// you'll transfer ownership. Returning it as a value also transfers ownership to the receiver.
  /// /summary>
  Enumerable<T> = record
  private
    fList: TList<T>;
    fOwnsList: boolean;

    function GetCount: integer;
    function GetItem(aIndex: integer): T;

    procedure SetItem(aIndex: integer; const Value: T);
    procedure ReleaseOwnership(aDisposeList: boolean);
  public
    property List: TList<T> read fList;
    property Count: integer read GetCount;
    property Item[aIndex: integer]: T read GetItem write SetItem;

    function GetItems: TEnumerator<T>;

    procedure Add(const aItems: array of T); overload;
    procedure Add(const aItems: TEnumerable<T>); overload;

    class operator Initialize;
    class operator Finalize;
    class operator Assign(var Dest: Enumerable<T>; const [ref] Src: Enumerable<T>);
  end;

implementation

uses
  SharedKernel.Collections;

{ Enumerable<T> }

{----------------------------------------------------------------------------------------------------------------------}
procedure Enumerable<T>.Add(const aItems: TEnumerable<T>);
begin
  fList.AddRange(aItems);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure Enumerable<T>.Add(const aItems: array of T);
begin
  fList.AddRange(aItems);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Enumerable<T>.GetCount: integer;
begin
  Result := fList.Count;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Enumerable<T>.GetItem(aIndex: integer): T;
begin
  Result := fList[aIndex];
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure Enumerable<T>.SetItem(aIndex: integer; const Value: T);
begin
  fList[aIndex] := Value;
end;

{----------------------------------------------------------------------------------------------------------------------}
function Enumerable<T>.GetItems: TEnumerator<T>;
begin
  Result := fList.GetEnumerator();
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure Enumerable<T>.ReleaseOwnership(aDisposeList: boolean);
begin
  fOwnsList := false;

  if aDisposeList then
    fList.Free;

  fList := nil;
end;

{----------------------------------------------------------------------------------------------------------------------}
class operator Enumerable<T>.Initialize;
begin
  fList := TList<T>.Create;
  fOwnsList := true;
end;

{----------------------------------------------------------------------------------------------------------------------}
class operator Enumerable<T>.Assign(var Dest: Enumerable<T>; const [ref] Src: Enumerable<T>);
var
  lDisposeList: boolean;
begin
  lDisposeList := Assigned(Dest.fList);

  if not lDisposeList then
      Dest.fList := Src.fList
  else
  begin
    Dest.fList.AddRange(Src.fList);
    Src.fList.Clear;
  end;

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

end.
