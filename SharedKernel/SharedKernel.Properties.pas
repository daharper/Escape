{***********************************************************************************************************************
  Unit:        SharedKernel.Collections
  Purpose:     Simple case-insensitive propertyies bag.
  Author:      David Harper
  License:     MIT
  History:     2025-08-20  Initial version
***********************************************************************************************************************}
unit SharedKernel.Properties;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  SharedKernel.Core;

type
  /// <summary>
  /// Simple case-insensitive properties container.
  /// </summary>
  TProperties = class
  private
    fMap: TDictionary<string, string>;

  public
    type TEnumerator = TDictionary<string,string>.TPairEnumerator;

    /// <summary>
    /// Removes all properties.
    /// </summary>
    procedure Clear;

    /// <summary>
    /// Removes the property with the specified key.
    /// </summary>
    procedure Remove(const aKey: string);

    /// <summary>
    /// Adds or sets a property with the specified key and value.
    /// </summary>
    procedure Add(const aKey: string; const aValue: string);

    /// <summary>
    /// Gets the number of properties in the list.
    /// </summary>
    function Count: integer;

    /// <summary>
    /// Gets the value of the property with the specified key; returns an empty string of not found.
    /// </summary>
    function Get(const aKey: string): string;

    /// <summary>
    /// Gets the value of the property with the specified key; returns the default if not found.
    /// </summary>
    function GetOr(const aKey: string; const aDefault: string = ''): string;

    /// <summary>
    /// Tries to get the value of the property with the specified key; returns true if found.
    /// </summary>
    function TryGetValue(const aKey: string; out aValue:string): boolean;

    /// <summary>
    /// Determines whether a property with the specified key exists; returns true if found.
    /// </summary>
    function Contains(const aKey: string): boolean;

    /// <summary>
    /// Returns a list of keys.
    /// </summary>
    function Keys: TEnumerable<string>;

    /// <summary>
    /// Returns a list of values.
    /// </summary>
    function Values: TEnumerable<string>;

    /// <summary>
    /// Gets an enumerator for iterating the properties.
    /// </summary>
    function GetEnumerator: TEnumerator;

    /// <summary>
    /// Gets a value with the specified key if found; otherwise an empty string.
    /// </summary>
    property Value[const aKey: string]: string read Get write Add;

    /// <summary>
    /// Saves to the specified XML file.
    /// </summary>
    procedure SaveAsXml(aPath: string);

    /// <summary>
    /// Loads from the specified XML file.
    /// </summary>
    class function LoadFromXml(aPath: string): TProperties;

    /// <summary>
    /// Creates a new instance.
    /// </summary>
    constructor Create; overload;

    /// <summary>
    /// Creates a new instance initialized with the specified source.
    /// </summary>
    constructor Create(aSource: TEnumerable<TPair<string, string>>); overload;

    /// <summary>
    /// Creates a new instance initialized with the specified source.
    /// </summary>
    constructor Create(aSource: array of TPair<String, string>); overload;

    /// <summary>
    /// Frees up resources.
    /// </summary>
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  SharedKernel.XmlParser;

{ TProperties }

{----------------------------------------------------------------------------------------------------------------------}
procedure TProperties.Clear;
begin
  fMap.Clear;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.Contains(const aKey: string): boolean;
begin
  Result := fMap.ContainsKey(aKey);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.Count: integer;
begin
  Result := fMap.Count;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.Get(const aKey: string): string;
begin
  fMap.TryGetValue(aKey, Result);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.GetOr(const aKey, aDefault: string): string;
begin
  if not fMap.ContainsKey(aKey) then
    Result := aDefault
  else
    Result := fMap[aKey];
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.GetEnumerator: TEnumerator;
begin
  Result := fMap.GetEnumerator;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TProperties.Add(const aKey, aValue: string);
begin
  fMap.AddOrSetValue(aKey, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TProperties.Remove(const aKey: string);
begin
  fMap.Remove(aKey);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.TryGetValue(const aKey: string; out aValue: string): boolean;
begin
  Result := fMap.TryGetValue(aKey, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.Keys: TEnumerable<string>;
begin
  Result := FMap.Keys;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TProperties.Values: TEnumerable<string>;
begin
  Result := FMap.Values;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TProperties.SaveAsXml(aPath: string);
var
  lElem: TBvElement;
begin
  lElem := TBvElement.FromProperties('properties', fMap);
  try
    TFile.WriteAllText(aPath, lElem.ToXml);
  finally
    lElem.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
class function TProperties.LoadFromXml(aPath: string): TProperties;
var
  lXml:     string;
  lParser:  TResult<TBvElement>;
  lElem:    TBvElement;
  lSubElem: TBvElement;
begin
  Result  := TProperties.Create;
  lXml    := TFile.ReadAllText(aPath);
  lParser := TBvParser.Execute(lXml);

  Expect.IsTrue(lParser.IsOk, lParser.Error);

  lElem := lParser.Value;
  try
    for lSubElem in lElem do
      Result.Add(lSubElem.Name, lSubElem.Value);
  finally
    lElem.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TProperties.Create;
begin
  fMap := TDictionary<string, string>.Create(TIStringComparer.Ordinal);
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TProperties.Create(aSource: TEnumerable<TPair<string, string>>);
begin
  fMap := TDictionary<string, string>.Create(aSource, TIStringComparer.Ordinal);
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TProperties.Create(aSource: array of TPair<String, string>);
begin
  fMap := TDictionary<string, string>.Create(aSource, TIStringComparer.Ordinal);
end;

{----------------------------------------------------------------------------------------------------------------------}
destructor TProperties.Destroy;
begin
  fMap.Free;

  inherited;
end;

end.
