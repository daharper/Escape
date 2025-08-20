unit SharedKernel.Core;

interface

type

  { semantic abstractions for interface management }
  TSingleton = class(TNoRefCountObject);
  TTransient = class(TInterfacedObject);

  TRecPredicate<T: record> = reference to function(const [ref] aRecord: T): Boolean;


implementation

end.
