{***********************************************************************************************************************
  Unit:        SharedKernel.XmlParser
  Purpose:     Basic XML Object and Parser for simple persistance requirements.
  Author:      David Harper
  License:     MIT
  History:     2025-08-20  Initial version
***********************************************************************************************************************}
unit SharedKernel.XmlParser;

interface

{$define TRACE_OFF}

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  SharedKernel.Core;

type
  { Currently, just basic XML entities are mapped, but given the leisure, see this page:

    https://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references

    and map all entities accepted by the HTML5 specification.

    Note, Unicode characters can be expressed as such:

    &apos;        =>     #$0027
    &DownBreve;   =>     #$0020 + #$0311 + #$0311
    &TripleDot;   =>     #$0020 + #$20DB + #$20DB + #$20DB

    Ordinary mappings as per normal:

    &Tab;         =>     #9
    &NewLine;     =>     #10
    &dollar;      =>     '$'
    &lpar;        =>     '('
  }
  TXmlEntity = (
    xAmpersand,
    xLessThan,
    xGreaterThan,
    xApostrophe,
    xQuote
  );

  TBvAttribute = class
  private
    fName: string;
    fValue: string;

    procedure SetName(const aValue: string);
    procedure SetValue(const aValue: string);
  public
    property Name: string read fName write SetName;
    property Value: string read fValue write SetValue;

    function AsInt: integer;
    function AsBool: boolean;
    function AsStr: string;
    function AsFloat: single;
    function AsDouble: double;

    function AsXml: string;

    { sets the value }
    procedure From(aValue: integer); overload;
    procedure From(aValue: boolean); overload;
    procedure From(aValue: string); overload;
    procedure From(aValue: single); overload;
    procedure From(aValue: double); overload;

    constructor Create(const aName: string; const aValue: string = '');
  end;

  TBvElement = class
  private
    fElems: TList<TBvElement>;
    fAttrs: TList<TBvAttribute>;
    fName: string;
    fValue: string;
    fParent: TBvElement;

    function GetElement(const aName: string): TBvElement;

    procedure SetName(const aValue: string);
    procedure SetValue(const aValue: string);
    procedure Initialize;
    procedure AppendXml(const [ref] aBuilder: TStringBuilder; indent: string = '');
  public
    property Name: string read fName write SetName;
    property Value: string read fValue write SetValue;
    property Parent: TBvElement read fParent write fParent;
    property Element[const aName: string]: TBvElement read GetElement; default;

    function HasElems: boolean;
    function HasAttrs: boolean;
    function HasValue: boolean;

    function LastAttr: TBvAttribute;

    { gets the Value as per type }
    function AsInt: integer; overload;
    function AsBool: boolean; overload;
    function AsStr: string; overload;
    function AsFloat: single; overload;
    function AsDouble: double; overload;

    { gets an Attribute Value as per type }
    function AsInt(const aName: string; aValue: integer = 0): integer; overload;
    function AsBool(const aName: string; aValue: boolean = false): boolean; overload;
    function AsStr(const aName: string; aValue: string = ''): string; overload;
    function AsFloat(const aName: string; aValue: single = 0): single; overload;
    function AsDouble(const aName: string; aValue: double = 0): double; overload;

    { go to the parent(s), or if specified, the parent with the argument name }
    function Up(const aName: string = ''): TBvElement;
    function ↑(const aName: string = ''): TBvElement;
    function ↑↑: TBvElement;
    function ↑↑↑: TBvElement;

    { go to the root element }
    function Root: TBvElement;
    function Build: TBvElement;
    function «: TBvElement;

    { gets the element with the specified name; if it doesn't exist, it is added with the optional value }
    function Elem(const aName: string; const aValue: string = ''): TBvElement;
    function _(const aName: string; const aValue: string = ''): TBvElement;
    function E(const aName: string; const aValue: string = ''): TBvElement;
    function SetElem(const aName: string; const aValue: string = ''): TBvElement;

    class function FromProperties(const aName: string; const aItems: TEnumerable<TPair<string, string>>): TBvElement;

    { adds an attribute with the specified details and returns the current element }
    function AddAttr(const aName: string; const aValue: string = ''): TBvElement;

    { sets or adds the attribute }
    function SetAttr(const aName: string; const aValue: string = ''): TBvElement;
    function →(const aName: string; const aValue: string = ''): TBvElement;
    function A(const aName: string; const aValue: string = ''): TBvElement;

    { gets the attribute value for the specified name; if it doesn't exist, it is added with the optional value }
    function Attr(const aName: string; const aValue: string = ''): TBvAttribute;
    function ←(const aName: string; const aValue: string = ''): TBvAttribute;

    function HasElem(const aName: string): boolean;
    function HasAttr(const aName: string): boolean;
    function HasParent: boolean;

    function GetEnumerator: TEnumerator<TBvElement>;
    function Attrs: TEnumerable<TBvAttribute>;

    function ToXml:string;

    function Add(aElem: TBvElement): TBvElement; overload;
    function Add(aAttr: TBvAttribute): TBvElement; overload;

    { add a range of elements }
    function AddRange(const aElems: array of string): TBvElement; overload;
    function AddRange(const aElems: TEnumerable<TBvElement>): TBvElement; overload;

    { add a range of attributes }
    function AddRange(const aAttrs: TEnumerable<TPair<string, string>>): TBvElement; overload;

    { sets the value }
    procedure From(aValue: integer); overload;
    procedure From(aValue: boolean); overload;
    procedure From(aValue: string); overload;
    procedure From(aValue: single); overload;
    procedure From(aValue: double); overload;

    { sets the attribute value }
    procedure From(const aName: string; aValue: integer); overload;
    procedure From(const aName: string; aValue: boolean); overload;
    procedure From(const aName: string; aValue: string); overload;
    procedure From(const aName: string; aValue: single); overload;
    procedure From(const aName: string; aValue: double); overload;

    class function New(const aName: string; const aValue: string = ''): TBvElement;

    constructor Create; overload;
    constructor Create(const aName: string; const aValue: string = ''); overload;

    { takes ownership of aOther's properties and frees aOther }
    constructor Create(aOther: TBvElement); overload;

    destructor Destroy; override;
  end;

  TBvParserState = (
    { The parser has no state }
    psNone,
    { The parser is analyzing a start element tag (opening tag) }
    psStartElement,
    { The parser is analyzing an end element tag (closing tag) }
    psEndElement,
    { The parser is expecting an attribute name or a terminating tag character '>' }
    psExpectAttrName,
    { The parser is analyzing an attribute name. }
    psAttrName,
    { The parser is expecting an attribute value }
    psExpectAttrValue,
    { The parser is expecting an '=' sign following the construction of an attribute name }
    psExpectEquals,
    { The parser is analyzing an attribute value }
    psAttrValue,
    { The parser is analyzing an element value }
    psValue,
    { The parser has completed building the root element }
    psDone,
    { The parser is currently ignoring characters, i.e. prologue, comments, will return to previous state }
    psIgnore
  );

  TBvParserStates = set of TBvParserState;

  TBvParserException = class(Exception)
    Index: integer;
    CurrentChar: char;
    NextChar: char;
    PrevQuote: char;
    State: TBvParserState;
    PrevState: TBvParserState;
    Xml: string;
    Token: string;
    Stack: string;
    Hint: string;
    LastElement: string;
    Error: string;

    function ToString: string; override;

    constructor Create;
  end;

  { Simple xml text parser }
  TBvParser = class
  private
    fBuffer:      string;
    fRoot:        TBvElement;
    fState:       TBvParserState;
    fPrevState:   TBvParserState;
    fPrevQuote:   char;
    fElement:     TBvElement;

    { the core parsing routine }
    function Parse(const aXml: string): TBvElement;

    { called when we are ready to identify an element opening tag }
    procedure OnStartElement;

    { called when we are ready to identify an attribute name }
    procedure OnExpectAttributeName;

    { called when the attribute name has been processed }
    procedure OnAttributeNameComplete;

    { called when we are to begin processing an attribute value }
    procedure OnAttributeValue;

    { called when the attribute value has been processed }
    procedure OnAttributeValueComplete;

    { called when the start element tag has been processed }
    procedure OnStartElementComplete;

    { called when we are to begin processing an end element tag }
    procedure OnEndElement;

    { called when the end element tag has been processed }
    procedure OnEndElementComplete;

    { sometimes tokens are split into two, i.e. because of an interjected comment }
    procedure UpdateLastValue;

    { changes the parser state, keeps track of previous state }
    procedure SetState(aState: TBvParserState);

    { raises an exception with debug information }
    procedure Fail(const aXml: string; const aHint: string; aIndex: integer; aCurrChar, aNextChar: char);

    { ensures we keep previous state on state changes }
    property State: TBvParserState read FState write SetState;
  public
    class function Execute(const aXml: string): TResult<TBvElement>;
  end;

const
  XmlEntities: array[xAmpersand..xQuote] of string = (
    '&amp;',
    '&lt;',
    '&gt;',
    '&apos;',
    '&quot;'
  );

  XmlLiterals: array[xAmpersand..xQuote] of string = (
    '&',
    '<',
    '>',
    #$0027,
    #$0022
  );

  { Functions }

  function IsValidNameChar(aChar: char): boolean;
  function IsValidName(const aName: string): boolean;
  function RemoveEntities(const aValue: string): string;

  { creates a new instance of an element }
  function Elem(const aName: string; const aValue: string = ''): TBvElement;

  { synonym for Elem }
  function _(const aName: string; const aValue: string = ''): TBvElement;
  function »(const aName: string; const aValue: string = ''): TBvElement;

implementation

uses
  System.Rtti,
  System.StrUtils,
  System.Character
  {$IFDEF TRACE_ON}, Infrastructure.Utils.Log {$ENDIF};

const
  IgnoreState:                TBvParserStates = [psIgnore];
  ValueState:                 TBvParserStates = [psValue, psAttrValue];
  NoneOrValueState:           TBvParserStates = [psNone, psValue, psAttrValue];
  StartEndOrExpAttrNameState: TBvParserStates = [psStartElement, psEndElement, psExpectAttrName];

var
  lEntityToLiteralMap: TDictionary<string, string>;
  lLiteralToEntityMap: TDictionary<string, string>;

{ Functions }

{----------------------------------------------------------------------------------------------------------------------}
function _(const aName: string; const aValue: string): TBvElement;
begin
  Result := TBvElement.New(aName, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function Elem(const aName: string; const aValue: string = ''): TBvElement;
begin
  Result := TBvElement.New(aName, aValue);
end;

function E(const aName: string; const aValue: string = ''): TBvElement;
begin
  Result := TBvElement.New(aName, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function »(const aName: string; const aValue: string = ''): TBvElement;
begin
  Result := TBvElement.New(aName, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function IsValidNameChar(aChar: char): boolean;
const
  VALID_CHARS = ['-', '_', '.', '#'];
begin
  Result := (aChar.IsLetterOrDigit) or (CharInSet(aChar, VALID_CHARS));
end;

{----------------------------------------------------------------------------------------------------------------------}
function IsValidName(const aName: string): boolean;
var
  lCh: Char;
begin
  for lCh in aName do
    if not IsValidNameChar(lCh) then exit(false);

  Result := Length(aName) > 0;
end;

{----------------------------------------------------------------------------------------------------------------------}
function RemoveEntities(const aValue: string): string;
var
  lTokens: TList<string>;
  lToken: string;
  lCh: char;

{$region 'helpers'}

  function IsTokens: boolean;
  begin
    Result := Assigned(lTokens);
  end;

  procedure OnClearToken;
  begin
    lToken := '';
  end;

  procedure OnTokenStart;
  begin
    lToken := '&';
  end;

  procedure OnTokenChar(aChar: char);
  begin
    lToken := lToken + aChar.ToLower;
  end;

  procedure OnTokenEnd;
  begin
    if lEntityToLiteralMap.ContainsKey(lToken) then
    begin
      if not IsTokens then lTokens := TList<string>.Create;

      if not lTokens.Contains(lToken) then
        lTokens.Add(lToken);
    end;
  end;

{$endregion}

begin
  if string.IsNullOrWhiteSpace(aValue) then exit(aValue);

  lTokens := nil;

  try
    for lCh in aValue do
    begin
      if lCh = '&' then
      begin
        OnTokenStart;
        continue;
      end;

      if (Length(lToken) = 0) then continue;

      if lCh = ';' then
      begin
        OnTokenEnd;
        OnClearToken;
        continue;
      end;

      if not IsValidNameChar(lCh) then
        OnClearToken
      else
        OnTokenChar(lCh);
    end;

    if not IsTokens then exit(aValue);

    for lToken in lTokens do
      Result := ReplaceText(Result, lToken, lEntityToLiteralMap[lToken]);

  finally
    lTokens.Free;
  end;
end;

{ TBvAttribute }

{----------------------------------------------------------------------------------------------------------------------}
function TBvAttribute.AsBool: boolean;
begin
  Result := StrToBool(Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvAttribute.AsDouble: double;
begin
  Result := StrToFloat(Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvAttribute.AsFloat: single;
begin
  Result := StrToFloat(Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvAttribute.AsInt: integer;
begin
  Result := StrToInt(Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvAttribute.AsStr: string;
begin
  Result := Value;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvAttribute.AsXml: string;
begin
  if Length(fValue) = 0 then exit('');

  if not fValue.Contains('"') then
    exit(Format('%s="%s"', [fName, fValue]));

  if not fValue.Contains('''') then
    exit(Format('%s=''%s''', [fName, fValue]));

  { TODO : Replace Literals with Entities }
  Result := Format('%s="%s"', [fName, fValue]);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvAttribute.SetName(const aValue: string);
var
  lName: string;
begin
  lName := Trim(aValue);

  if not IsValidName(lName) then
    raise Exception.Create('invalid attribute name: ' + aValue);

  fName := LowerCase(lName);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvAttribute.SetValue(const aValue: string);
begin
  fValue := RemoveEntities(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvAttribute.From(aValue: integer);
begin
  fValue := IntToStr(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvAttribute.From(aValue: boolean);
begin
  fValue := BoolToStr(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvAttribute.From(aValue: string);
begin
  fValue := aValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvAttribute.From(aValue: single);
begin
  fValue := FloatToStr(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvAttribute.From(aValue: double);
begin
  fValue := FloatToStr(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TBvAttribute.Create(const aName, aValue: string);
begin
  SetName(aName);
  SetValue(aValue);
end;

{ TBvElement }

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.HasAttrs: boolean;
begin
  Result := fAttrs.Count > 0;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.HasElems: boolean;
begin
  Result := fElems.Count > 0;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.HasValue: boolean;
begin
  Result := Length(fValue) > 0;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.Add(aAttr: TBvAttribute): TBvElement;
begin
  fAttrs.Add(aAttr);
  Result := self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.Add(aElem: TBvElement): TBvElement;
begin
  aElem.Parent := self;

  fElems.Add(aElem);

  Result := self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AddAttr(const aName, aValue: string): TBvElement;
begin
  fAttrs.Add(TBvAttribute.Create(aName, aValue));
  Result := Self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AddRange(const aElems: array of string): TBvElement;
var
  e: TBvElement;
  lElem: string;
begin
  for lElem in aElems do
  begin
    e := TBvElement.Create(lElem);
    e.Parent := Self;
    fElems.Add(e);
  end;

  Result := self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AddRange(const aAttrs: TEnumerable<TPair<string, string>>): TBvElement;
var
  lAttr: TPair<string, string>;
begin
  for lAttr in aAttrs do
    SetAttr(lAttr.Key, lAttr.Value);

  Result := self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AddRange(const aElems: TEnumerable<TBvElement>): TBvElement;
var
  e: TBvElement;
begin
  for e in aElems do
  begin
    e.Parent := Self;
    fElems.Add(e);
  end;

  Result := self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AsBool: boolean;
begin
  Result := StrToBool(Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AsDouble: double;
begin
  Result := StrToFloat(Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AsFloat: single;
begin
  Result := StrToFloat(Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AsInt: integer;
begin
  if string.IsNullOrWhiteSpace(Value) then
    Result := 0
  else
    Result := StrToInt(Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AsStr: string;
begin
  Result := Value;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.Attr(const aName, aValue: string): TBvAttribute;
var
  i: integer;
  a: TBvAttribute;
begin
  for i := 0 to Pred(fAttrs.Count) do
    if CompareText(aName, fAttrs[i].Name) = 0 then exit(fAttrs[i]);

  a := TBvAttribute.Create(aName, aValue);

  fAttrs.Add(a);

  Result := a;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.←(const aName, aValue: string): TBvAttribute;
begin
  Result := Attr(aName, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AsStr(const aName: string; aValue: string): string;
begin
  Result := Attr(aName, aValue).Value;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AsInt(const aName: string; aValue: integer): integer;
var
  lValue: string;
begin
  lValue := IntToStr(aValue);
  lValue := Attr(aName, lValue).Value;
  Result := StrToInt(lValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AsBool(const aName: string; aValue: boolean): boolean;
begin
  Result := StrToBool(Attr(aName, BoolToStr(aValue)).Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AsFloat(const aName: string; aValue: single): single;
begin
  Result := StrToFloat(Attr(aName, FloatToStr(aValue)).Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.AsDouble(const aName: string; aValue: double): double;
begin
  Result := StrToFloat(Attr(aName, FloatToStr(aValue)).Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.SetAttr(const aName: string; const aValue: string): TBvElement;
var
  i: integer;
begin
  for i := 0 to Pred(fAttrs.Count) do
  begin
    if CompareText(aName, fAttrs[i].Name) = 0 then
    begin
      fAttrs[i].Value := RemoveEntities(aValue);
      exit(self);
    end;
  end;

  fAttrs.Add(TBvAttribute.Create(aName, aValue));
  Result := Self;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.A(const aName, aValue: string): TBvElement;
begin
  Result := SetAttr(aName, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.→(const aName, aValue: string): TBvElement;
begin
  Result := SetAttr(aName, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.HasAttr(const aName: string): boolean;
var
  i: integer;
begin
  for i := 0 to Pred(fAttrs.Count) do
    if CompareText(aName, fAttrs[i].Name) = 0 then exit(true);

  Result := false;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.Attrs: TEnumerable<TBvAttribute>;
begin
  Result := fAttrs;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.Elem(const aName, aValue: string): TBvElement;
var
  e: TBvElement;
begin
  for e in fElems do
    if CompareText(aName, e.Name) = 0 then exit(e);

  e := TBvElement.Create(aName, aValue);
  e.Parent := Self;

  fElems.Add(e);

  Result := e;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.From(aValue: double);
begin
  fValue := FloatToStr(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.From(aValue: single);
begin
  fValue := FloatToStr(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.From(aValue: string);
begin
  fValue := aValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.From(aValue: boolean);
begin
  fValue := BoolToStr(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.From(aValue: integer);
begin
  fValue := IntToStr(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.From(const aName: string; aValue: double);
begin
  Attr(aName).From(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.From(const aName: string; aValue: single);
begin
  Attr(aName).From(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.From(const aName: string; aValue: string);
begin
  Attr(aName).From(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.From(const aName: string; aValue: boolean);
begin
  Attr(aName).From(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.From(const aName: string; aValue: integer);
begin
  Attr(aName).From(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement._(const aName, aValue: string): TBvElement;
begin
  Result := Elem(aName, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.E(const aName, aValue: string): TBvElement;
begin
  Result := Elem(aName, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.SetElem(const aName, aValue: string): TBvElement;
begin
  Result := Elem(aName, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
class function TBvElement.FromProperties(const aName: string; const aItems: TEnumerable<TPair<string, string>>): TBvElement;
var
  lItem: TPair<string, string>;
begin
  Result := TBvElement.Create(aName);

  for lItem in aItems do
    Result.SetElem(lItem.Key, lItem.Value);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.HasElem(const aName: string): boolean;
var
  e: TBvElement;
begin
  for e in fElems do
    if CompareText(aName, e.Name) = 0 then exit(true);

  Result := false;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.HasParent: boolean;
begin
  Result := Assigned(fParent);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.GetElement(const aName: string): TBvElement;
begin
  Result := Elem(aName);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.GetEnumerator: TEnumerator<TBvElement>;
begin
  Result := fElems.GetEnumerator;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.SetName(const aValue: string);
var
  lName: string;
begin
  lName := Trim(aValue);

  if not IsValidName(lName) then
    raise Exception.Create('invalid element name: ' + aValue);

  fName := LowerCase(lName);
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.SetValue(const aValue: string);
begin
  fValue := RemoveEntities(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
class function TBvElement.New(const aName, aValue: string): TBvElement;
begin
  Result := TBvElement.Create(aName, aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.Root: TBvElement;
begin
  Result := self;

  while Assigned(Result.Parent) do
    Result := Result.Parent;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.Build: TBvElement;
begin
  Result := Root;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.«: TBvElement;
begin
  Result := Root;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.Up(const aName: string): TBvElement;
begin
  if not Assigned(fParent) then
    raise Exception.Create('Already at root element');

  if Length(aName) = 0 then
    exit(fParent);

  Result := self.Parent;

  while (Assigned(Result.Parent)) and (CompareText(aName, Result.Name) <> 0) do
    Result := Result.Parent;

  if CompareText(aName, Result.Name) <> 0 then
    raise Exception.Create('Unable to find parent: ' + aName);
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.↑(const aName: string): TBvElement;
begin
  Result := Up(aName);
end;
{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.↑↑: TBvElement;
begin
  if not Assigned(fParent) then
    raise Exception.Create('Already at root element');

  if not Assigned(fParent.Parent) then
    raise Exception.Create('Unable to find parent two levels up');

  Result := fParent.Parent;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.↑↑↑: TBvElement;
begin
  if not Assigned(fParent) then
    raise Exception.Create('Already at root element');

  if not Assigned(fParent.Parent) then
    raise Exception.Create('Unable to find parent two levels up');

  if not Assigned(fParent.Parent.Parent) then
    raise Exception.Create('Unable to find parent three levels up');

  Result := fParent.Parent.Parent;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.AppendXml(const [ref] aBuilder: TStringBuilder; indent: string);
var
  lAttr: TBvAttribute;
  lElem: TBvElement;
begin
  aBuilder.AppendFormat('%s<%s', [indent, fName]);

  for lAttr in Attrs do
    aBuilder.AppendFormat(' %s', [lAttr.AsXml]);

  if (not HasValue) and (not HasElems) then
  begin
    aBuilder.AppendLine(' />');
    exit;
  end;

  aBuilder.Append('>');

  if HasValue then
    aBuilder.Append(fValue);

  if not HasElems then
  begin
    aBuilder.AppendFormat('</%s>', [fName]);
    aBuilder.AppendLine;
    exit;
  end;

  aBuilder.AppendLine;

  for lElem in self do
    lElem.AppendXml(aBuilder, indent + '  ');

  aBuilder.AppendFormat('%s</%s>', [indent, fName]);
  aBuilder.AppendLine;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.ToXml: string;
var
  lBuilder: TStringBuilder;
begin
  lBuilder := TStringBuilder.Create;
  try
    AppendXml(lBuilder);
    Result := lBuilder.ToString;
  finally
    lBuilder.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvElement.Initialize;
begin
  fElems := TList<TBvElement>.Create;
  fAttrs := TList<TBvAttribute>.Create;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvElement.LastAttr: TBvAttribute;
begin
  Result := fAttrs[Pred(fAttrs.Count)];
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TBvElement.Create;
begin
  Initialize;
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TBvElement.Create(const aName, aValue: string);
begin
  Initialize;

  SetName(aName);
  SetValue(aValue);
end;

{----------------------------------------------------------------------------------------------------------------------}
constructor TBvElement.Create(aOther: TBvElement);
begin
  fName := aOther.Name;
  fValue := aOther.Value;

  fElems := TList<TBvElement>.Create(aOther.fElems);
  fAttrs := TList<TBvAttribute>.Create(aOther.fAttrs);

  aOther.fElems.Clear;
  aOther.fAttrs.Clear;

  aOther.Free;
end;

{----------------------------------------------------------------------------------------------------------------------}
destructor TBvElement.Destroy;
var
  i: integer;
begin
  for i := 0 to Pred(fAttrs.Count) do
    fAttrs[i].Free;

  fAttrs.Free;

  for i := 0 to Pred(fElems.Count) do
    fElems[i].Free;

  fElems.Free;

  inherited;
end;

{ TBvParserException }

{----------------------------------------------------------------------------------------------------------------------}
constructor TBvParserException.Create;
begin
  Index := -1;
  State := psNone;
  PrevState := psNone;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvParserException.ToString: string;
var
  sb: TStringBuilder;
  st, prevSt: string;
begin
  st     := TRttiEnumerationType.GetName(State);
  prevSt := TRttiEnumerationType.GetName(PrevState);
  sb     := TStringBuilder.Create;

  sb.AppendLine('An error occurred during xml parsing:');
  sb.AppendLine(Hint);
  sb.AppendLine;

  sb.AppendLine('Debugging details:');
  sb.AppendLine;
  sb.AppendFormat('curr index: %d', [Index]);
  sb.AppendLine;
  sb.AppendFormat('curr  char: %s', [CurrentChar]);
  sb.AppendLine;
  sb.AppendFormat('next  char: %s', [NextChar]);
  sb.AppendLine;
  sb.AppendFormat('prev quote: %s', [PrevQuote]);
  sb.AppendLine;
  sb.AppendFormat('curr state: %s', [st]);
  sb.AppendLine;
  sb.AppendFormat('prev state: %s', [prevSt]);
  sb.AppendLine;
  sb.AppendFormat('curr token: %s', [Token]);

  if Length(Stack) > 0 then
  begin
    sb.AppendLine;
    sb.AppendLine('Element stack details:');
    sb.AppendLine;
    sb.AppendLine(Stack);
  end;

  if Length(LastElement) > 0 then
  begin
    sb.AppendLine;
    sb.AppendLine('Last created element:');
    sb.AppendLine;
    sb.AppendLine(LastElement);
  end;

  if Length(Xml) > 0 then
  begin
    sb.AppendLine;
    sb.AppendLine('Xml details:');
    sb.AppendLine;
    sb.AppendLine(Xml);
  end;

  if Length(Error) > 0 then
  begin
    sb.AppendLine;
    sb.AppendLine('Exception details');
    sb.AppendLine;
    sb.AppendLine(Error);
  end;

  Result := sb.ToString;

  sb.Free;
end;

{ TBvXmlParser }

{----------------------------------------------------------------------------------------------------------------------}
class function TBvParser.Execute(const aXml: string): TResult<TBvElement>;
var
  e: TBvElement;
  p: TBvParser;
begin
  if string.IsNullOrWhiteSpace(aXml) then
    TResult<TBvElement>.Err('xml is blank');

  p := TBvParser.Create;
  try
    try
      e := p.Parse(aXml);

      if Assigned(e) then
      begin
        Result := TResult<TBvElement>.Ok(e);
{$IFDEF TRACE_ON}
        Log.Write('Successfully parsed:');
        Log.NewLine;
        Log.Write(e.ToXml);
{$ENDIF}
        exit;
      end;

      Result := TResult<TBvElement>.Err('xml is blank');
    except on E: Exception do
      Result := TResult<TBvElement>.Err(e.ToString);
    end;

{$IFDEF TRACE_ON}
    Log.Error(Result.Error);
{$ENDIF}

    p.fRoot.Free;
  finally
    p.Free;
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
function TBvParser.Parse(const aXml: string): TBvElement;
var
  i:      integer;
  count:  integer;
  curr:   char;
  next:   char;
begin
  fPrevState := psNone;
  fState     := psNone;
  fPrevQuote := #0;
  i          := 0;
  count      := Length(aXml);

{$IFDEF TRACE_ON}
  Log.Write('Parsing:');
  Log.NewLine;
  Log.Write(aXml);
{$ENDIF}

  while (fState <> psDone) and (i < count) do
  begin
    curr := aXml.Chars[i];

{$IFDEF TRACE_ON}
    Log.Write(curr);
{$ENDIF}

    Inc(i);

    next := Iff(i = count, #0, aXml.Chars[i]);

    { terminate prologue if possible }
    if (curr = '?') and (not (fState in ValueState)) then
    begin
      if (not (fState in IgnoreState)) or (next <> '>') then
        Fail(aXml, 'Unexpected characters "?"', i, curr, next);

      Inc(i);
      State := psNone;
      continue;
    end;

    { terminate comment, or continue ignoring }
    if fState in IgnoreState then
    begin
      if (curr = '-') and (next = '-') then
      begin
        Inc(i);
        if (i < count) and (aXml.Chars[i] = '>') then
        begin
          Inc(i);
          fState := fPrevState;
        end;
      end;
      continue;
    end;

    { manage quotes }
    if (curr = '''') or (curr = '"') then
    begin
      if fState = psExpectAttrValue then
      begin
        fPrevQuote := curr;
        OnAttributeValue;
        continue;
      end;

      if fState = psAttrValue then
      begin
        if fPrevQuote <> curr then
          fBuffer := fBuffer + curr
        else
        begin
          OnAttributeValueComplete;
          fPrevQuote := #0;
        end;
        continue;
      end;

      if FState <> psValue then
        Fail(aXml, 'Unexpected character (quote): ' + curr, i, curr, next);

      fBuffer := fBuffer + curr;
      continue;
    end;

    { manage start tag identifier }
    if curr = '<' then
    begin
      if not (fState in NoneOrValueState) then
        Fail(aXMl, 'Unexpected character "<"', i, curr, next);

      if next = '/' then
      begin
        Inc(i);
        OnEndElement;
        continue;
      end;

      if (next = '?') and (not (fState in ValueState)) then
      begin
        Inc(i);
        State := psIgnore;
        continue;
      end;

      if next = '!' then
      begin
        Inc(i);
        if (i < count) and (aXml.Chars[i] = '-') then
        begin
          Inc(i);
          if (i < count) and (aXml.Chars[i] = '-') then
          begin
            Inc(i);
            State := psIgnore;
            continue;
          end;
        end;
        Fail(aXml, 'Unexpected character "!"', i, curr, next);
      end;

      OnStartElement;
      continue;
    end;

    { manage end tag identifier }
    if curr = '>' then
    begin
      if not (fState in StartEndOrExpAttrNameState) then
        Fail(aXml, 'Unexpected character ">"', i, curr, next);

      if fState <> psEndElement then
      begin
        OnStartElementComplete;
        continue;
      end;

      if not Assigned(fRoot) then
        Fail(aXml, 'Empty element, unexpected character ">"', i, curr, next);

      OnEndElementComplete;
      continue;
    end;

    { add to current value }
    if fState in ValueState then
    begin
      if not ((Length(fBuffer) = 0) and ((curr = '\t') or (curr = '\n') or (curr = '\r'))) then
        FBuffer := fBuffer + curr;

      continue;
    end;

    { identify state change triggered by space }
    if curr = #32 then
    begin
      if fState = psStartElement then
        OnExpectAttributeName
      else if fState = psAttrName then
        OnAttributeNameComplete;

      continue;
    end;

    { identify state change triggered by an equal sign }
    if curr = '=' then
    begin
      if fState = psAttrName then
        OnAttributeNameComplete
      else if fState <> psExpectEquals then
        Fail(aXml, 'Unexpected character "="', i, curr, next);

      State := psExpectAttrValue;
      continue
    end;

    { manage end of tag }
    if curr = '/' then
    begin
      if (fState in StartEndOrExpAttrNameState) and (next <> '>') then
        Fail(aXml, 'Unexpected character "/"', i, curr, next);

      OnStartElementComplete;
      OnEndElementComplete;
      Inc(i);
      continue;
    end;

    if (fState = psExpectAttrName) and (Length(fBuffer) = 0) then
      State := psAttrName;

    if fState <> psNone then
      fBuffer := fBuffer + curr;
  end;

  Result := fRoot;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.OnStartElement;
var
  e: TBvElement;
begin
  if Length(fBuffer) > 0 then UpdateLastValue;

  e := TBvElement.Create;

  if not Assigned(fRoot) then
  begin
    fElement := e;
    fRoot    := e;
  end
  else
  begin
    fElement.Add(e);
    fElement := e;
  end;

  State := psStartElement;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.OnExpectAttributeName;
begin
  if Length(fBuffer) > 0 then
  begin
    fElement.Name := fBuffer;
    FBuffer       := '';
  end;

  State := psExpectAttrName;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.OnAttributeNameComplete;
begin
  fElement.AddAttr(fBuffer);
  FBuffer := '';

  State := psExpectEquals;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.OnAttributeValue;
begin
  State := psAttrValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.OnAttributeValueComplete;
begin
  fElement.LastAttr.Value := fBuffer;
  FBuffer := '';

  State := psExpectAttrName;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.OnStartElementComplete;
begin
  if Length(FBuffer) > 0 then
  begin
    fElement.Name := fBuffer;
    FBuffer := '';
  end;

  State := psValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.OnEndElement;
begin
  if Length(FBuffer) > 0 then
    UpdateLastValue;

  State := psEndElement;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.OnEndElementComplete;
begin
  fElement := fElement.Parent;
  fBuffer := '';

  if not Assigned(fElement) then
    State := psDone
  else
    State := psValue;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.UpdateLastValue;
begin
  fElement.Value := fElement.Value + Trim(fBuffer);
  fBuffer := '';
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.SetState(aState: TBvParserState);
{$IFDEF TRACE_ON}
var
  st, prevSt: string;
{$ENDIF}
begin
{$IFDEF TRACE_ON}
  st     := TRttiEnumerationType.GetName(aState);
  prevSt := TRttiEnumerationType.GetName(fState);

  Log.Write(Format('State change from %s => %s', [prevSt, st]));
{$ENDIF}

  fPrevState := fState;
  fState := aState;
end;

{----------------------------------------------------------------------------------------------------------------------}
procedure TBvParser.Fail(const aXml: string; const aHint: string; aIndex: integer; aCurrChar, aNextChar: char);
var
  e: TBvParserException;
begin
  e := TBvParserException.Create;

  with e do begin
    Hint        := AHint;
    Index       := AIndex;
    CurrentChar := ACurrChar;
    NextChar    := ANextChar;
    State       := FState;
    PrevState   := FPrevState;
    PrevQuote   := FPrevQuote;
    LastElement := Iff(Assigned(fElement), fElement.ToXml, '');
    Stack       := Iff(Assigned(fRoot), fRoot.ToXml, '');
    Token       := fBuffer;
    Xml         := aXml;
  end;

  raise e;
end;

{----------------------------------------------------------------------------------------------------------------------}
initialization
var
  lEntity: TXmlEntity;
begin
  lEntityToLiteralMap := TDictionary<string, string>.Create(TIStringComparer.Ordinal);
  lLiteralToEntityMap := TDictionary<string, string>.Create(TIStringComparer.Ordinal);

  for lEntity in [xAmpersand..xQuote] do
  begin
    lEntityToLiteralMap.Add(XmlEntities[lEntity], XmlLiterals[lEntity]);
    lLiteralToEntityMap.Add(XmlLiterals[lEntity], XmlEntities[lEntity]);
  end;
end;

{----------------------------------------------------------------------------------------------------------------------}
finalization
  FreeAndNil(lEntityToLiteralMap);
  FreeAndNil(lLiteralToEntityMap);

end.

