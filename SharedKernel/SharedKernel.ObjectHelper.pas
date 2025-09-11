{***********************************************************************************************************************
  Unit:        SharedKernel.ObjectHelper
  Purpose:     Useful TObject extension methods.
  Author:      David Harper
  License:     MIT
  History:     2025-08-20  Initial version
***********************************************************************************************************************}
unit SharedKernel.ObjectHelper;

interface

uses
  System.SysUtils,
  System.TypInfo,
  SharedKernel.Reflection;

type
  TObjectHelper = class helper for TObject
  public
    function Implements<T>: Boolean; inline;
    function TryAs<T>(out aSource: T): Boolean; inline;
    function &As<T>: T; inline;
  end;

implementation

{--------------------------------------------------------------------------------------------------}
function TObjectHelper.Implements<T>: Boolean;
begin
  Result := TReflection.Implements<T>(Self);
end;

{--------------------------------------------------------------------------------------------------}
function TObjectHelper.TryAs<T>(out aSource: T): Boolean;
begin
  Result := TReflection.Implements<T>(Self, aSource);
end;

{--------------------------------------------------------------------------------------------------}
function TObjectHelper.&As<T>: T;
begin
  Result := TReflection.&As<T>(Self);
end;

end.
