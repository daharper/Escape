unit SharedKernel.Tests.CollectionsFixture;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Collections,
  System.Generics.Defaults,
  SharedKernel.Mocks.Customer;

type
  [TestFixture]
  TCollectionsFixture = class
  private
    fClassyCustomers: TList<TClassyCustomer>;
  public
    [Setup]
    procedure Setup;

    [Teardown]
    procedure Teardown;

    [Test]
    procedure Should_Convert_To_Map;

    [Test]
    procedure Should_Convert_To_ObjectDictionary;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Character,
  SharedKernel.Core,
  SharedKernel.Collections;

{ TCollectionsFixture }

{----------------------------------------------------------------------------------------------------------------------}
procedure TCollectionsFixture.Should_Convert_To_Map;
begin
  var map := TCollections.ToMap<TClassyCustomer, integer, TClassyCustomer>(fClassyCustomers,
    function (const c: TClassyCustomer): TPair<integer, TClassyCustomer>
    begin
      Result := TPair<integer, TClassyCustomer>.Create(c.Id, c);
    end,
    saNone);

  Assert.AreEqual(3, map.Count);

  Assert.AreEqual(1, map[1].Id);
  Assert.AreEqual(2, map[2].Id);
  Assert.AreEqual(3, map[3].Id);

  map.Free;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TCollectionsFixture.Should_Convert_To_ObjectDictionary;
begin
  var map := TCollections.ToMap<TClassyCustomer, integer, TClassyCustomer>(fClassyCustomers,
    function (const c: TClassyCustomer): TPair<integer, TClassyCustomer>
    begin
      Result := TPair<integer, TClassyCustomer>.Create(c.Id, c);
    end,
    saFreeSource);

  Assert.IsNull(fClassyCustomers);

  var objMap := TCollections.ToObjectDictionary<integer, TClassyCustomer>(map, [doOwnsValues], saFreeSource);

  Assert.IsNull(map);
  Assert.AreEqual(3, objMap.Count);

  objMap.Free;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TCollectionsFixture.Setup;
begin
  fClassyCustomers := TList<TClassyCustomer>.Create([
    TClassyCustomer.New(1, 'fred', 'allstars', 100000),
    TClassyCustomer.New(2, 'tom', 'allstars',   25000),
    TClassyCustomer.New(3, 'pete', 'allstars',  60000)
  ]);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TCollectionsFixture.Teardown;
begin
  if Assigned(fClassyCustomers) then
  begin
    if fClassyCustomers.Count > 0 then
      TCollections.FreeAll<TClassyCustomer>(fClassyCustomers);

    FreeAndNil(fClassyCustomers);
  end;
end;

end.
