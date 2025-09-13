unit SharedKernel.Tests.StreamsFixture;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TStreamFixture = class
  public
    { initialization tests }

    [Test]
    [TestCase('one list item',    '70')]
    [TestCase('three list items', '23, 85, 64')]
    procedure Should_Initialize_From_Array(const aItems: array of integer);

    [Test] procedure Should_Initialize_From_Enumerator;
    [Test] procedure Should_Initialize_Using_Classes;
    [Test] procedure Should_Initialize_From_Class_Instances;

    { terminating operation tests}
    [Test]
    [TestCase('count of one',  '45')]
    [TestCase('count of five', '45, 63, 72, 79, 81')]
    procedure Should_Provide_CorrectCount(const aItems: array of integer);

    [Test] procedure Should_Filter_Items;
    [Test] procedure Should_Filter_Records;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Character,
  System.Generics.Collections,
  System.Generics.Defaults,
  SharedKernel.Streams,
  SharedKernel.Mocks.Customer;

{ TStreamFixture }

{$region 'terminating operation tests'}

{------------------------------------------------------------------------------}
procedure TStreamFixture.Should_Provide_CorrectCount(const aItems: array of integer);
begin
  var items := Stream<integer>.From(aItems);
  Assert.AreEqual(Length(aItems), items.Count);
end;

{------------------------------------------------------------------------------}
procedure TStreamFixture.Should_Filter_Items;
begin
  var nums := Stream<integer>
    .From([1, 2, 3, 4, 5])
    .Filter(function(const num: integer): boolean begin Result := num mod 2 = 0; end)
    .ToArray;

  Assert.AreEqual(2, Length(nums));
  Assert.AreEqual(2, nums[0]);
  Assert.AreEqual(4, nums[1]);
end;

{------------------------------------------------------------------------------}
procedure TStreamFixture.Should_Filter_Records;
begin
  var customers := Stream<TCustomer>
    .From([
        TCustomer.Create(1, 'Alan',  'IT', 10),
        TCustomer.Create(2, 'Roger', 'IT', 20),
        TCustomer.Create(3, 'Osin',  'Support', 15)])
    .Filter(function(const c: TCustomer): boolean
      begin
        Result := c.Salary > 10;
      end)
    .ToArray;

  Assert.AreEqual(2, Length(customers));
  Assert.AreEqual(2, customers[0].Id);
  Assert.AreEqual(3, customers[1].Id);
end;

{$endregion}

{$region 'initialization tests'}

{------------------------------------------------------------------------------}
procedure TStreamFixture.Should_Initialize_From_Array(const aItems: array of integer);
begin
  var items := Stream<integer>.From(aItems).ToArray;

  Assert.AreEqual(Length(aItems), Length(items));

  for var i := 0 to High(aItems) do
    Assert.AreEqual(aItems[0], items[i]);
end;

{------------------------------------------------------------------------------}
procedure TStreamFixture.Should_Initialize_From_Enumerator;
begin
  var languages := TList<string>.Create(['Delphi', 'Java', 'Kotlin']);

  var items := Stream<string>.From(languages).ToArray;

  Assert.AreEqual(3, Length(items));
  Assert.AreEqual('Delphi', items[0]);
  Assert.AreEqual('Java',   items[1]);
  Assert.AreEqual('Kotlin', items[2]);

  languages.Free;
end;

{------------------------------------------------------------------------------}
procedure TStreamFixture.Should_Initialize_From_Class_Instances;
begin
  var wrapper := TCustomerWrapper.Create(1, 'Alan',  'IT', 10);

  Assert.WillNotRaise(
    procedure
    begin
      var customers := Stream<TCustomerWrapper>
        .From([wrapper])
        .ToArray;
    end,
    nil, 'Object/pointers are not allowed');

  wrapper.Free;
end;

{------------------------------------------------------------------------------}
procedure TStreamFixture.Should_Initialize_Using_Classes;
begin
 Assert.WillNotRaise(
    procedure
    begin
      Stream<TCustomerWrapper>
        .From([
            TCustomerWrapper.Create(1, 'Alan',  'IT', 10),
            TCustomerWrapper.Create(2, 'Roger', 'IT', 20),
            TCustomerWrapper.Create(3, 'Osin',  'Support', 15)])
        .FreeAll;
    end);
end;

{$endregion}

initialization
  TDUnitX.RegisterTestFixture(TStreamFixture);

end.
