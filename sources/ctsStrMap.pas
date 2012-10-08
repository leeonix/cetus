{$I CetusOptions.inc}

unit ctsStrMap;

interface

uses
  ctsTypesDef,
  ctsUtils,
  ctsBaseInterfaces,
  ctsBaseClasses,
  ctsStrMapInterface;

const
  cUnitName = 'ctsStrMap';

type
  // red black tree
  TctsRBColor = (Black, Red); // Black = False, Red = True;
  TctsChildType = Boolean;    // Left = False, Right = True;

const
  Left = True;
  Right = False;

type
  PTreeNode = ^TTreeNode;
  TTreeNode = packed record
    Pair: PPair;
    Color: TctsRBColor;
    Parent: PTreeNode;
    case Boolean of
      False: (Left, Right: PTreeNode;);
      True : (Child: array[TctsChildType] of PTreeNode);
  end;

  TctsNotifierTree = class(TObject)
  protected
    FKeyCompare: TctsKeyCompareEvent;
    FPairDispose: TctsDisposePairEvent;
    procedure Notify(const aPair: PPair; ANotifyAction: TctsNotifyAction);
  public
    procedure SetKeyCompare(const AValue: TctsKeyCompareEvent);
    procedure SetPairDispose(const AValue: TctsDisposePairEvent);
  end;

type
  TctsCustomTree = class(TctsContainer)
  protected
    FCount: LongInt;
    FHead: PTreeNode;
    FNodePool: IctsMemoryPool;
    FNotifier: TctsNotifierTree;
    procedure DisposeNode(ANode: Pointer); virtual;
    procedure DoClear; virtual;
    procedure DoDelete(const aKey: TctsKeyType); virtual;
    procedure DoInsert(const aPair: PPair); virtual;
    procedure Error(AMsg: PResStringRec; AMethodName: string);
    function NewNode: Pointer; virtual;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

  TctsStrMap = class(TctsCustomTree)
  protected
    FPairPool: IctsMemoryPool;
    function CreatePair: PPair;
    procedure DestroyPair(const aPair: PPair);
    procedure DisposeNode(ANode: Pointer); override;
    procedure Error(AMsg: PResStringRec; AMethodName: string);
  public
    constructor Create; override;
    destructor Destroy; override;
    function Root: PTreeNode;
  end;

implementation

uses
  SysUtils,
  ctsConsts,
  ctsMemoryPools;

function Promote(const Me: PTreeNode): PTreeNode;
var
  Dad: PTreeNode;
  T, BrotherType: TctsChildType;
begin
  Dad := Me.Parent;
  T := Dad.Left = Me;
  BrotherType := not T;  
  Dad.Child[T] := Me.Child[BrotherType];
  if Dad.Child[T] <> nil then
    Dad.Child[T].Parent := Dad;
  Me.Parent := Dad.Parent;
  Me.Parent.Child[Me.Parent.Left = Dad] := Me;
  Me.Child[BrotherType] := Dad;
  Dad.Parent := Me;
  Result := Me;
end;

procedure RebalanceDelete(Me, Dad, Root: PTreeNode);
var
  Brother, FarNephew, NearNephew: PTreeNode;
  T: TctsChildType;
begin
  T := Dad.Left = Me;
  Brother := Dad.Child[not T];

  while Me <> Root do
  begin
    if Me <> nil then
    begin
      Dad := Me.Parent;
      T := Dad.Left = Me;
      Brother := Dad.Child[not T];
    end;

    if Brother = nil then
    begin
      Me := Dad;
      Continue;
    end;

    if Brother.Color = Red then
    begin
      Dad.Color := Red;
      Brother.Color := Black;
      Promote(Brother);
      Continue;
    end;

    FarNephew := Brother.Child[not T];
    if (FarNephew <> nil) and (FarNephew.Color = Red) then
    begin
      FarNephew.Color := Black;
      Brother.Color := Dad.Color;
      Dad.Color := Black;
      Promote(Brother);
      Exit;
    end
    else
    begin
      NearNephew := Brother.Child[T];
      if (NearNephew <> nil) and (NearNephew.Color = Red) then
      begin
        NearNephew.Color := Dad.Color;
        Dad.Color := Black;
        Promote(Promote(NearNephew));
        Exit;
      end
      else
      begin
        if Dad.Color = Red then
        begin
          Dad.Color := Black;
          Brother.Color := Red;
          Exit;
        end
        else
        begin
          Brother.Color := Red;
          Me := Dad;
        end;
      end;
    end;
  end; // end while;
end;

procedure RebalanceInsert(Me, Dad, Root: PTreeNode);
var
  Grandad, Uncle: PTreeNode;
  DadType: TctsChildType;
begin
  Me.Color := Red;
  while (Me <> Root) and (Dad.Color = Red) do
  begin
    if Dad = Root then
    begin
      Dad.Color := Black;
      Exit;
    end;

    Grandad := Dad.Parent;
    Grandad.Color := Red;
    DadType := Grandad.Left = Dad;
    Uncle := Grandad.Child[not DadType];

    if (Uncle <> nil) and (Uncle.Color = Red) then
    begin
      Dad.Color := Black;
      Uncle.Color := Black;
      Me := Grandad;
      Dad := Me.Parent;
    end
    else
    begin
      if (Dad.Left = Me) = DadType then
      begin
        Dad.Color := Black;
        Promote(Dad);
        Exit;
      end
      else
      begin
        Me.Color := Black;
        Promote(Promote(Me));
        Exit;
      end; // end else
    end; // end else
  end;
end;

function SearchNode(const aKey: TctsKeyType; var aNode: PTreeNode; var aType: TctsChildType;
  aComp: TctsKeyCompareEvent): Boolean;
var
  I: integer;
begin
  Result := False;
  if aNode = nil then
    Exit;
  I := aComp(aKey, aNode.Pair.Key);
  while I <> 0 do
  begin
    aType := I < 0;
    if (aNode.Child[aType] = nil) then
      Exit;
    aNode := aNode.Child[aType];
    I := aComp(aKey, aNode.Pair.Key);
  end;
  Result := True;
end;

// ===== TctsNotifierTree =====

procedure TctsNotifierTree.Notify(const aPair: PPair; ANotifyAction: TctsNotifyAction);
begin
  if Assigned(FPairDispose) and (ANotifyAction = naDeleting) then
    FPairDispose(aPair);
end;

procedure TctsNotifierTree.SetKeyCompare(const AValue: TctsKeyCompareEvent);
begin
  FKeyCompare := AValue;
end;

procedure TctsNotifierTree.SetPairDispose(const AValue: TctsDisposePairEvent);
begin
  FPairDispose := AValue;
end;

// ===== TctsCustomTree =====

constructor TctsCustomTree.Create;
begin
  inherited Create;
  FNodePool := TctsMiniMemoryPool.Create(SizeOf(TTreeNode));
  FNotifier := TctsNotifierTree.Create;  
  FHead := NewNode;
end;

destructor TctsCustomTree.Destroy;
begin
  FNodePool := nil;
  FNotifier.Free;
  inherited Destroy;
end;

procedure TctsCustomTree.DisposeNode(ANode: Pointer);
begin
  FNodePool.Delete(ANode);
end;

procedure TctsCustomTree.DoClear;

  procedure FreeChild(aNode: PTreeNode);
  var
    P: PTreeNode;
  begin
    while aNode <> nil do
    begin
      FreeChild(aNode.Right);
      P := aNode.Left;
      DisposeNode(aNode);
      aNode := P;
    end;
  end;

begin
  if FCount = 0 then
    Exit;
  FreeChild(FHead.Left);
  FCount := 0;
  FHead.Left := nil;
end;

procedure TctsCustomTree.DoDelete(const aKey: TctsKeyType);
var
  P, Me, Dad, Child: PTreeNode;
  T: TctsChildType;

  procedure DeleteNode;
  begin
    Dad.Child[T] := Child;
    if Child <> nil then
      Child.Parent := Dad;
    DisposeNode(Me);
    Dec(FCount);
  end;

  procedure ExchangeData(var Data1, Data2);
  var
    T: LongInt;
  begin
    T := LongInt(Data1);
    LongInt(Data1) := LongInt(Data2);
    LongInt(Data2) := T;
  end;

begin
  Me := FHead.Left;
  T := Left;
  if not SearchNode(aKey, Me, T, FNotifier.FKeyCompare) then
    Error(@STreeItemMissing, SReadyDelete);
  if (Me.Left <> nil) and (Me.Right <> nil) then
  begin
    P := Me.Left;
    while (P.Right <> nil) do
      P := P.Right;
    ExchangeData(P.Pair, Me.Pair);
    Me := P;
  end;
  Dad := Me.Parent;
  T := Dad.Left = Me;
  Child := Me.Child[Me.Left <> nil];
  if (Me.Color = Red) or (Me = FHead.Left) then
  begin
    DeleteNode;
    Exit;
  end;
  if (Child <> nil) and (Child.Color = Red) then
  begin
    Child.Color := Black;
    DeleteNode;
    Exit;
  end;
  DeleteNode;
  if Child <> FHead.Left then
    RebalanceDelete(Child, Dad, FHead.Left);
end;

procedure TctsCustomTree.DoInsert(const aPair: PPair);
var
  Me, Child: PTreeNode;
  T: TctsChildType;
begin
  Me := FHead.Left;
  T := Left;

  if SearchNode(aPair.Key, Me, T, FNotifier.FKeyCompare) then
    Error(@STreeDupItem, SInsert);

  Child := FNodePool.NewClear;
  Child.Pair := aPair;
  if Me = nil then
    Me := FHead;

  if Me.Child[T] <> nil then
    Error(@STreeHasChild, SInsert);

  Me.Child[T] := Child;
  Child.Parent := Me;
  Inc(FCount);
  FNotifier.Notify(aPair, naAdded);
  RebalanceInsert(Child, Me, FHead.Left);
end;

procedure TctsCustomTree.Error(AMsg: PResStringRec; AMethodName: string);
begin
  if Name = '' then
    Name := SDefaultTreeName;
  raise EctsTreeError.CreateResFmt(AMsg, [cUnitName, ClassName, AMethodName, Name]);
end;

function TctsCustomTree.NewNode: Pointer;
begin
  Result := FNodePool.NewClear;
end;

// ===== TctsStrMap =====

constructor TctsStrMap.Create;
begin
  inherited;
  FPairPool := TctsMiniMemoryPool.Create(SizeOf(TPair));
  if not Assigned(FNotifier.FKeyCompare) then
    FNotifier.FKeyCompare := CompareStr;
end;

destructor TctsStrMap.Destroy;
begin
  DoClear;
  FPairPool := nil;
  inherited;
end;

function TctsStrMap.CreatePair: PPair;
begin
  Result := FPairPool.NewClear;
end;

procedure TctsStrMap.DestroyPair(const aPair: PPair);
begin
  FPairPool.Delete(aPair);
end;

procedure TctsStrMap.DisposeNode(ANode: Pointer);
var
  Tree: PTreeNode absolute ANode;
  Pair: PPair;
begin
  Pair := Tree.Pair;
  FNotifier.Notify(Pair, naDeleting);
  DestroyPair(Pair);
  inherited;
end;

procedure TctsStrMap.Error(AMsg: PResStringRec; AMethodName: string);
begin
  if Name = '' then
    Name := SDefaultStrMapName;
  raise EctsTreeError.CreateResFmt(AMsg, [cUnitName, ClassName, AMethodName, Name]);
end;

function TctsStrMap.Root: PTreeNode;
begin
  Result := FHead.Left;
end;


end.







