unit SharedKernel.Mocks.Customer;

interface

uses
  System.Generics.Collections;

type

 TCustomer = record
    Id: integer;
    Name: string;
    Department: string;
    Salary: integer;

    class function Create(aId: integer; const aName: string; aDepartment: string; aSalary: integer): TCustomer; static;
  end;

  TCustomerList = TList<TCustomer>;

implementation

{ TCustomer }

{----------------------------------------------------------------------------------------------------------------------}
class function TCustomer.Create(aId: integer; const aName: string; aDepartment: string; aSalary: integer): TCustomer;
begin
  Result.Id := aId;
  Result.Name := aName;
  Result.Department := aDepartment;
  Result.Salary := aSalary;
end;

end.
