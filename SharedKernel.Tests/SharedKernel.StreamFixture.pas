unit SharedKernel.StreamFixture;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TStreamFixture = class
  public
    [Test] procedure Should_Initialize_From_Const_Array;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Character,
  System.Generics.Collections,
  System.Generics.Defaults,
  SharedKernel.Stream;

{ TStreamFixture }

{------------------------------------------------------------------------------}
procedure TStreamFixture.Should_Initialize_From_Const_Array;
begin
  var items := Stream<integer>.From([1, 2, 3]).ToArray;

  Assert.AreEqual(3, Length(items));

  Assert.AreEqual(1, items[0]);
  Assert.AreEqual(2, items[1]);
  Assert.AreEqual(3, items[2]);
end;

initialization
  TDUnitX.RegisterTestFixture(TStreamFixture);

end.
