{$I CetusOptions.inc}

unit ctsObserver;

interface

uses
  ctsBaseInterfaces;

type
  // Observer

  TctsBaseObserver = class(TInterfacedObject, IctsBaseObserver)
  private
    FEnabled: Boolean;
  protected
    procedure Changed(AParams: Pointer); virtual; abstract;
    function GetEnabled: Boolean;
    procedure SetEnabled(const AValue: Boolean);
  public
    procedure AfterConstruction; override;
  end;

  PctsObserverNode = ^TctsObserverNode;
  TctsObserverNode = record
    Link: PctsObserverNode;
    Observer: IctsBaseObserver;
  end;

  TctsObserverCollection = class(TObject)
  private
    FHead: PctsObserverNode;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AItem: IctsBaseObserver);
    procedure IterateChange(AParams: Pointer);
    procedure Remove(const AItem: IctsBaseObserver);
  end;

implementation

// ===== TctsBaseObserver =====

procedure TctsBaseObserver.AfterConstruction;
begin
  inherited;
  FEnabled := True;
end;

function TctsBaseObserver.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

procedure TctsBaseObserver.SetEnabled(const AValue: Boolean);
begin
  FEnabled := AValue;
end;

// ===== TctsObserverCollection =====

constructor TctsObserverCollection.Create;
begin
  inherited Create;
  New(FHead);
  FillChar(FHead^, SizeOf(TctsObserverNode), 0);
end;

destructor TctsObserverCollection.Destroy;
var
  P, Temp: PctsObserverNode;
begin
  P := FHead^.Link;
  while (P <> nil) do
  begin
    Temp := P;
    P := P^.Link;
    Temp^.Observer := nil;
    Dispose(Temp);
  end;
  Dispose(FHead);
  inherited Destroy;
end;

procedure TctsObserverCollection.Add(const AItem: IctsBaseObserver);
var
  P: PctsObserverNode;
begin
  New(P);
  P^.Observer := AItem;
  P^.Link := FHead^.Link;
  FHead^.Link := P;
end;

procedure TctsObserverCollection.IterateChange(AParams: Pointer);
var
  P: PctsObserverNode;
begin
  P := FHead^.Link;
  while P <> nil do
  begin
    P^.Observer.Changed(AParams);
    P := P^.Link;
  end;
end;

procedure TctsObserverCollection.Remove(const AItem: IctsBaseObserver);
var
  P, Parent: PctsObserverNode;
begin
  Parent := FHead;
  P := Parent^.Link;
  while P <> nil do
  begin
    if (P^.Observer = AItem) then
    begin
      Parent^.Link := P^.Link;
      P^.Observer := nil;
      Dispose(P);
      Exit;
    end;
    Parent := P;
    P := P^.Link;
  end; //end while
end;

end.
