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

  { class for testing ownership - ref counted }
  TCustomerWrapper = class(TTransient, ICustomerWrapper)
  private
    fCustomer: TCustomer;
  public
    function Customer: TCustomer;

    constructor Create(aId: integer; const aName: string; const aDepartment: string; aSalary: integer);
  end;

  TClassyCustomer = class
  private
    fId: integer;
    fName: string;
    fCompany: string;
    fSales: integer;
  public
    property Id: integer read fId write fId;
    property Name: string read fName write fName;
    property Company: string read fCompany write fCompany;
    property Sales: integer read fSales write fSales;

    class function New(aId: integer; const aName: string; const aCompany: string; aSales: integer): TClassyCustomer;
  end;

implementation

{ TCustomer }

{----------------------------------------------------------------------------------------------------------------------}
class function TCustomer.Create(aId: integer; const aName: string; const aDepartment: string; aSalary: integer): TCustomer;
begin
  Result.Id := aId;
  Result.Name := aName;
  Result.Department := aDepartment;
  Result.Salary := aSalary;
end;

{ TCustomerWrapper }

{----------------------------------------------------------------------------------------------------------------------}
function TCustomerWrapper.Customer: TCustomer;
begin
  Result := fCustomer;
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TCustomerWrapper.Create(aId: integer; const aName: string; const aDepartment: string; aSalary: integer);
begin
  fCustomer.Id := aId;
  fCustomer.Name := aName;
  fCustomer.Department := aDepartment;
  fCustomer.Salary := aSalary;
end;

{ TClassyCustomer }

{----------------------------------------------------------------------------------------------------------------------}
class function TClassyCustomer.New(aId: integer; const aName, aCompany: string; aSales: integer): TClassyCustomer;
begin
  Result := TClassyCustomer.Create;
  Result.Id := aId;
  Result.Name := aName;
  Result.Company := aCompany;
  Result.Sales := aSales;
end;

end.
