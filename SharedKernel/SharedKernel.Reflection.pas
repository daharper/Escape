{***********************************************************************************************************************
  Unit:        SharedKernel.Reflection
  Purpose:     Helper classes for working with reflection.
  Author:      David Harper
  License:     MIT
  History:     2025-08-20  Initial version
***********************************************************************************************************************}
unit SharedKernel.Reflection;

interface

uses
  System.TypInfo;

type
  TReflection = record
  public
    // Basic kind helpers
    class function IsInterface<T>: Boolean; static; inline;
    class function IsClass<T>: Boolean; static; inline;
    class function IsRecord<T>: Boolean; static; inline;
    class function IsClassRef<T>: Boolean; static; inline;   // metaclass
    class function IsOrdinal<T>: Boolean; static; inline;    // enums, sets, integers, chars, int64
    class function IsFloat<T>: Boolean; static; inline;      // Float/Curr
    class function IsString<T>: Boolean; static; inline;     // Short/Ansi/Wide/UnicodeString
    class function IsArray<T>: Boolean; static; inline;      // static array
    class function IsDynArray<T>: Boolean; static; inline;   // dynamic array
    class function IsMethod<T>: Boolean; static; inline;     // method pointer
    class function IsPointer<T>: Boolean; static; inline;
    class function IsVariant<T>: Boolean; static; inline;
    class function IsPrimitive<T>: Boolean; static; inline;

    // Managed-type (ref-counted / compiler-managed) check
    class function IsManaged<T>: Boolean; static; inline;
    class function IsNonOwningSafe<T>: Boolean; static; inline;
    class function NeedsFinalization<T>: Boolean; static; inline;
    class function IsReferenceCounted<T>: Boolean; static; inline;
    class function IsTriviallyCopyable<T>: Boolean; static; inline;

    // array element type
    class function ElementTypeInfo<T>: PTypeInfo; static;
    class function ElementTypeName<T>: string; static;

    // Names & metadata
    class function KindOf<T>: TTypeKind; static; inline;
    class function TypeInfoOf<T>: PTypeInfo; static; inline;
    class function TypeNameOf<T>: string; static; inline;
    class function FullNameOf<T>: string; static; inline;

    // --- Utility
    class function DefaultOf<T>: T; static; inline;
    class function InterfaceGuidOf<T>: TGUID; static; inline;

    class procedure RequireInterfaceType<T>; static; inline;

    class function &As<T>(const aSource: TObject): T; overload; static; inline;
    class function &As<T>(const aSource: IInterface): T; overload; static; inline;

    class function Implements<T>(const aSource: TObject): Boolean; overload; static; inline;
    class function Implements<T>(const aSource: TObject; out aTarget: T): Boolean; overload; static; inline;
    class function Implements<T>(const aSource: IInterface): Boolean; overload; static; inline;
    class function Implements<T>(const aSource: IInterface; out aTarget: T): Boolean; overload; static; inline;

    // --- Interface GUID helper
    class function TryGetInterfaceGuid<T>(out Guid: TGUID): Boolean; static;
  end;

const
  AnEmptyGuid: TGUID = '{00000000-0000-0000-0000-000000000000}';

implementation

uses
  System.SysUtils;

{--------------------------------------------------------------------------------------------------}
class function TReflection.TypeInfoOf<T>: PTypeInfo;
begin
  Result := System.TypeInfo(T);
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.TypeNameOf<T>: string;
begin
  Result := GetTypeName(TypeInfoOf<T>);
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.KindOf<T>: TTypeKind;
begin
  Result := TypeInfoOf<T>.Kind;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsInterface<T>: Boolean;
begin
  Result := KindOf<T> = tkInterface;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsClass<T>: Boolean;
begin
  Result := KindOf<T> = tkClass;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsClassRef<T>: Boolean;
begin
  Result := KindOf<T> = tkClassRef;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsRecord<T>: Boolean;
begin
  Result := KindOf<T> = tkRecord;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsOrdinal<T>: Boolean;
begin
  Result := KindOf<T> in [tkInteger, tkInt64, tkChar, tkWChar, tkEnumeration, tkSet];
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsFloat<T>: Boolean;
begin
  Result := KindOf<T> = tkFloat;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsString<T>: Boolean;
begin
  Result := KindOf<T> in [tkString, tkLString, tkWString, tkUString];
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsArray<T>: Boolean;
begin
  Result := KindOf<T> = tkArray;    // static (fixed-length) array
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsDynArray<T>: Boolean;
begin
  Result := KindOf<T> = tkDynArray;  // dynamic array
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsMethod<T>: Boolean;
begin
  Result := KindOf<T> = tkMethod;    // method pointers (of object)
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsPointer<T>: Boolean;
begin
  Result := KindOf<T> = tkPointer;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsVariant<T>: Boolean;
begin
  Result := KindOf<T> = tkVariant;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsPrimitive<T>: Boolean;
begin
  case PTypeInfo(TypeInfo(T)).Kind of
    tkInteger, tkInt64, tkEnumeration, tkSet,
    tkChar, tkWChar,
    tkFloat,
    tkPointer,
    tkString:
      Result := True;
  else
      Result := False;
  end;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsManaged<T>: Boolean;
begin
  // Prefer the RTL’s own test when available (it also detects records with managed fields)
  {$IF DECLARED(IsManagedType)}
  Result := IsManagedType(TypeInfoOf<T>);
  {$ELSE}
  // Fallback: shallow kind-based check (does NOT catch records with managed fields)
  Result := KindOf<T> in [tkInterface, tkDynArray, tkUString, tkLString, tkWString, tkVariant];
  {$IFEND}
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsNonOwningSafe<T>: Boolean;
begin
  case PTypeInfo(TypeInfo(T)).Kind of
    tkClass,   // TObject refs (need .Free if you own them)
    tkPointer: // raw pointers (need Dispose/FreeMem if you own them)
      Result := False;
  else
      Result := True;
  end;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.TryGetInterfaceGuid<T>(out Guid: TGUID): Boolean;
var
  lInfo: PTypeInfo;
  lData: PTypeData;
begin
  lInfo := TypeInfoOf<T>;

  if (lInfo <> nil) and (lInfo.Kind = tkInterface) then
  begin
    lData := GetTypeData(lInfo);
    Guid := lData.Guid;
    Result := not IsEqualGUID(Guid, AnEmptyGuid);
  end
  else
  begin
    Guid := AnEmptyGuid;
    Result := False;
  end;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.NeedsFinalization<T>: Boolean;
begin
  Result := IsManaged<T>;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsReferenceCounted<T>: Boolean;
begin
  // Things the compiler/RTL refcount: interfaces, Unicode/Ansi/Wide strings, dyn arrays.
  // Note: tkString (short string) is NOT refcounted.
  case KindOf<T> of
    tkInterface, tkDynArray, tkLString, tkWString, tkUString:
      Result := True;
  else
      Result := False;
  end;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.IsTriviallyCopyable<T>: Boolean;
begin
  // Safe for Move/memcpy and no Finalize needed
  Result := not IsManaged<T>;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.ElementTypeInfo<T>: PTypeInfo;
var
  lInfo: PTypeInfo;
  lData: PTypeData;
begin
  Result := nil;

  lInfo := TypeInfoOf<T>;
  if lInfo = nil then Exit;

  lData := GetTypeData(lInfo);

  case lInfo.Kind of
    tkArray:
      // Static/fixed array: PTypeData.ArrayData.ElType
      {$IFDEF NEXTGEN}
        // NEXTGEN kept the same fields for tkArray
        Result := TD.ArrayData.ElType^;
      {$ELSE}
        Result := lData.ArrayData.ElType^;
      {$ENDIF}
    tkDynArray:
      // Dynamic array: PTypeData.DynArrElType^
      Result := lData.DynArrElType^;
  end;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.ElementTypeName<T>: string;
var
  lInfo: PTypeInfo;
begin
  lInfo := ElementTypeInfo<T>;

  if lInfo <> nil then
    Result := GetTypeName(lInfo)
  else
    Result := '';
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.DefaultOf<T>: T;
begin
  Result := Default(T);
end;

{--------------------------------------------------------------------------------------------------}
class procedure TReflection.RequireInterfaceType<T>;
begin
{$IFDEF DEBUG}
  if PTypeInfo(TypeInfo(T)).Kind <> tkInterface then
    raise EInvalidCast.CreateFmt('Implements<%s>: T must be an interface type', [GetTypeName(TypeInfo(T))]);
{$ENDIF}
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.InterfaceGuidOf<T>: TGUID;
begin
  Result := GetTypeData(TypeInfo(T))^.Guid;
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.&As<T>(const aSource: TObject): T;
begin
  RequireInterfaceType<T>;

  if not Supports(aSource, InterfaceGuidOf<T>, Result) then
    raise EInvalidCast.CreateFmt('%s does not implement %s', [aSource.ClassName, GetTypeName(TypeInfo(T))]);
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.&As<T>(const aSource: IInterface): T;
begin
  RequireInterfaceType<T>;

  if not Supports(aSource, InterfaceGuidOf<T>, Result) then
    raise EIntfCastError.CreateFmt('Interface does not support %s', [GetTypeName(TypeInfo(T))]);
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.Implements<T>(const aSource: TObject): Boolean;
begin
  RequireInterfaceType<T>;
  Result := Supports(aSource, InterfaceGuidOf<T>);
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.Implements<T>(const aSource: TObject; out aTarget: T): Boolean;
begin
  RequireInterfaceType<T>;
  Result := Supports(aSource, InterfaceGuidOf<T>, aTarget);
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.Implements<T>(const aSource: IInterface): Boolean;
begin
  RequireInterfaceType<T>;
  Result := Supports(aSource, InterfaceGuidOf<T>);
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.Implements<T>(const aSource: IInterface; out aTarget: T): Boolean;
begin
  RequireInterfaceType<T>;
  Result := Supports(aSource, InterfaceGuidOf<T>, aTarget);
end;

{--------------------------------------------------------------------------------------------------}
class function TReflection.FullNameOf<T>: string;
var
  lInfo: PTypeInfo;
  lData: PTypeData;
  lUnit : string;
begin
  lInfo := TypeInfo(T);
  Result := GetTypeName(lInfo);
  lData := GetTypeData(lInfo);

  case lInfo.Kind of
    tkClass, tkInterface, tkRecord:
      lUnit := string(lData.UnitName);
  else
      lUnit := '';
  end;

  if lUnit <> '' then
    Result := lUnit + '.' + Result;
end;

end.
