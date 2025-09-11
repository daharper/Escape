unit SharedKernel.Mocks.Customer;

interface

uses
  System.Generics.Collections,
  SharedKernel.Core;

type

 { simple record for tests }
 TCustomer = record
    Id: integer;
    Name: string;
    Department: string;
    Salary: integer;

    class function Create(aId: integer; const aName: string; const aDepartment: string; aSalary: integer): TCustomer; static;
  end;

  { interface for testing ownership }
  ICustomerWrapper = interface
    ['{FF3D3B3F-19DE-4AF1-832C-5B433DC005E0}']

    function Customer: TCustomer;
  end;

  { class for testing ownership }
  TCustomerWrapper = class(TTransient, ICustomerWrapper)
  private
    fCustomer: TCustomer;
  public
    function Customer: TCustomer;

    constructor Create(aId: integer; const aName: string; const aDepartment: string; aSalary: integer);
  end;

implementation

{ TCustomer }

{------------------------------------------------------------------------------}
class function TCustomer.Create(aId: integer; const aName: string; const aDepartment: string; aSalary: integer): TCustomer;
begin
  Result.Id := aId;
  Result.Name := aName;
  Result.Department := aDepartment;
  Result.Salary := aSalary;
end;

{ TCustomerWrapper }

{------------------------------------------------------------------------------}
function TCustomerWrapper.Customer: TCustomer;
begin
  Result := fCustomer;
end;

{------------------------------------------------------------------------------}
constructor TCustomerWrapper.Create(aId: integer; const aName: string; const aDepartment: string; aSalary: integer);
begin
  fCustomer.Id := aId;
  fCustomer.Name := aName;
  fCustomer.Department := aDepartment;
  fCustomer.Salary := aSalary;
end;

end.
