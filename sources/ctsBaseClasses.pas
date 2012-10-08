{$I CetusOptions.inc}

unit ctsBaseClasses;

interface

uses
  ctsTypesDef,
  ctsBaseInterfaces;

type
  TctsBaseClass = TInterfacedObject;

  TctsNamedClass = class(TctsBaseClass)
  private
    FName: TctsNameString;
  protected
    function GetName: TctsNameString;
    procedure SetName(const AValue: TctsNameString);
  public
    property Name: TctsNameString read GetName write SetName;
  end;

  TctsContainer = class(TctsNamedClass, IctsContainer)
  protected
    function GetCount: LongInt; virtual; abstract;
    function GetReference: TObject;
    procedure SetCount(const AValue: LongInt); virtual; abstract;
  public
    constructor Create; virtual;
    function IsEmpty: Boolean; virtual;
    property Count: LongInt read GetCount write SetCount;
  end;

  TctsContainerClass = class of TctsContainer;

implementation

// ===== TctsNamedClass =====

function TctsNamedClass.GetName: TctsNameString;
begin
  Result := FName;
end;

procedure TctsNamedClass.SetName(const AValue: TctsNameString);
begin
  if FName <> AValue then
  begin
    FName := AValue;
  end;
end;

// ===== TctsContainer =====

constructor TctsContainer.Create;
begin
end;

function TctsContainer.GetReference: TObject;
begin
  Result := Self;
end;

function TctsContainer.IsEmpty: Boolean;
begin
  Result := Count = 0;
end;

end.
