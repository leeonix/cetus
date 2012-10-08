{$I CetusOptions.inc}

unit ctsSyncObjects;

interface

uses
  Windows;

type
  TctsCriticalSection = class(TObject)
  protected
    FSection: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Enter;
    procedure Leave;
    function TryEnter: Boolean;
  end;

implementation

{ TctsCriticalSection }

constructor TctsCriticalSection.Create;
begin
  InitializeCriticalSection(FSection)
end;

destructor TctsCriticalSection.Destroy;
begin
  DeleteCriticalSection(FSection)
end;

procedure TctsCriticalSection.Enter;
begin
  EnterCriticalSection(FSection)
end;

procedure TctsCriticalSection.Leave;
begin
  LeaveCriticalSection(FSection)
end;

function TctsCriticalSection.TryEnter: Boolean;
begin
  Result := TryEnterCriticalSection(FSection)
end;


end.

