{*******************************************************************************
  Unit:        SharedKernel.Core
  Purpose:     Contains core types and methods used across the SharedKernel.
  Author:      David Harper
  License:     MIT
  History:     2025-08-20  Initial version
*******************************************************************************}

unit SharedKernel.Core;

interface

type

  { semantic abstractions for interface management }
  TSingleton = class(TNoRefCountObject);
  TTransient = class(TInterfacedObject);

  TRefPredicate<T> = reference to function(const [ref] aItem: T): Boolean;
  TVarPredicate<T> = reference to function(var aItem: T): Boolean;

implementation

end.
