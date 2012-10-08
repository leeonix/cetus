unit Test_Data;

interface

uses
  Windows,
  SysUtils,
  Classes,
  ctsTypesDef,
  ctsPointerInterface;

type
  TTestObj = class(TObject)
  public
    FStr: TStrings;
    Name: string;
    constructor Create;
    destructor Destroy; override;
    function CompareI(AData1, AData2 : Pointer): LongInt;
    function CompareII(AData1, AData2 : string): LongInt;
    procedure Observer(AValue: Pointer; ANotifyAction: TctsNotifyAction);
  end;

type
  IIntfMyObject = interface
    ['{BA33CBCC-9CB2-4672-BF54-F52C2A0BEFFE}']
    function GetInt: Integer;
    function GetStr: string;
    procedure SetInt(Value: Integer);
    procedure SetStr(const Value: string);
    property Int: Integer read GetInt write SetInt;
    property Str: string read GetStr write SetStr;
  end;

  TIntfMyObject = class(TInterfacedObject, IIntfMyObject)
  private
    FInt: Integer;
    FStr: string;
  protected
  { IIntfMyObject }
    function GetInt: Integer;
    function GetStr: string;
    procedure SetInt(Value: Integer);
    procedure SetStr(const Value: string);
  public
    property Int: Integer read GetInt write SetInt;
    property Str: string read GetStr write SetStr;
  end;

var
  ActionNames: array[TctsNotifyAction] of string = ('naAdded', 'naDeleting', 'naForEach');
  BooleanNames: array[Boolean] of string = ('False', 'True');

implementation

constructor TTestObj.Create;
begin
  inherited;
  FStr := TStringList.Create;
end;

destructor TTestObj.Destroy;
begin
  FStr.SaveToFile(Name + '.txt');
  FStr.Free;
  inherited;
end;

function TTestObj.CompareI(AData1, AData2 : Pointer): LongInt;
begin
  Result := Integer(AData1) - Integer(AData2);
end;

function TTestObj.CompareII(AData1, AData2 : string): LongInt;
begin
  Result := CompareStr(AData1, AData2);
end;

procedure TTestObj.Observer(AValue: Pointer; ANotifyAction: TctsNotifyAction);
var
  S: string;
begin
  S := Name + ': ' + IntToStr(Integer(AValue)) + ':' + ActionNames[ANotifyAction];
  FStr.Add(S);
end;

{ TIntfMyObject }

function TIntfMyObject.GetInt: Integer;
begin
  Result := FInt;
end;

function TIntfMyObject.GetStr: string;
begin
  Result := FStr;
end;

procedure TIntfMyObject.SetInt(Value: Integer);
begin
  FInt := Value;
end;

procedure TIntfMyObject.SetStr(const Value: string);
begin
  FStr := Value;
end;




end.
