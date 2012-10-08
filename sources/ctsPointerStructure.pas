{$I CetusOptions.inc}

unit ctsPointerStructure;

interface

uses
{$I ctsUseDeclare.inc}
  ctsPointerInterface;

const
  cUnitName = 'ctsPointerStructure';

{.$I template\ctsStructImp.inc}

type
  // Notifier
  PctsNotifyEntry = ^TctsNotifyEntry;
  TctsNotifyEntry = record
    Data: TctsDataType;
    NotifyAction: TctsNotifyAction
  end;

  TctsBaseNotifier = class(TObject)
  protected
    procedure Notify(AValue: TctsDataType; ANotifyAction: TctsNotifyAction); virtual;
  end;

  TctsNotifier = class(TctsBaseNotifier)
  protected
    FCompare: TctsCompareEvent;
    FDispose: TctsDisposeEvent;
  {$IFDEF USE_Object}
    FOwnsObjects: Boolean;
  {$ENDIF}
    procedure Notify(AValue: TctsDataType; ANotifyAction: TctsNotifyAction); override;
  public
  {$IFDEF USE_Object}
    constructor Create;
  {$ENDIF}
    procedure SetCompare(const AValue: TctsCompareEvent);
    procedure SetDispose(const AValue: TctsDisposeEvent);
  end;

  TctsNotifierWithObserver = class(TctsNotifier)
  protected
    FObCollection: TctsObserverCollection;
  public
    destructor Destroy; override;
    procedure Notify(AValue: TctsDataType; ANotifyAction: TctsNotifyAction); override;
  end;

  //TctsObserver
  TctsObserver = class(TctsBaseObserver, IctsObserver)
  private
    FOnChanged: TctsNotifyEvent;
  protected
    procedure Changed(AParams: Pointer); override;
    function GetOnChanged: TctsNotifyEvent;
    procedure SetOnChanged(const AValue: TctsNotifyEvent);
  end;

  //Vector
  TctsCustomVector = class(TObject)
  protected
    FArray: PctsArray;
    FCapacity: LongInt;
    FCount: LongInt;
    procedure DoAdd(const AItem: TctsDataType); virtual;
    procedure DoClear; virtual;
    procedure DoDelete(const AIndex: LongInt); virtual;
    procedure DoInsert(const AIndex: LongInt; const AItem: TctsDataType); virtual;
    procedure DoPack; virtual;
    procedure DoSetCapacity(const AValue: LongInt); virtual;
    procedure Grow; virtual;
  public
    destructor Destroy; override;
  end;

  TctsVector = class(TctsContainer, IctsContainer, IctsCollection, IctsVector)
  private
    FNotifier: TctsNotifier;
    FIsSorted: Boolean;
    FVector: TctsCustomVector;
  protected
    procedure Error(AMsg: PResStringRec; AMethodName: string; AData: LongInt);
    function GetCapacity: LongInt;
    function GetCompare: TctsCompareEvent;
    function GetCount: LongInt; override;
    function GetDispose: TctsDisposeEvent;
    function GetItems(AIndex: LongInt): TctsDataType;
    procedure GetNotifier; virtual;
  {$IFDEF USE_Object}
    function GetOwnsObjects: Boolean;
  {$ENDIF}
    procedure SetCapacity(const AValue: LongInt);
    procedure SetCompare(const AValue: TctsCompareEvent);
    procedure SetCount(const AValue: LongInt); override;
    procedure SetDispose(const AValue: TctsDisposeEvent);
    procedure SetItems(AIndex: LongInt; const AItem: TctsDataType);
  {$IFDEF USE_Object}
    procedure SetOwnsObjects(const Value: Boolean);
  {$ENDIF}
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Add(const AItem: TctsDataType);
    procedure Clear; virtual;
    function Contain(const AItem: TctsDataType): Boolean;
    procedure Delete(const AIndex: LongInt);
    function First: IctsIterator;
    function GetArray: PctsArray;
    function IndexOf(const AItem: TctsDataType): LongInt;
    procedure Insert(const AIndex: LongInt; const AItem: TctsDataType);
    function IsSorted: Boolean;
    function Last: IctsIterator;
    procedure Pack;
    function Remove(const AItem: TctsDataType): Boolean;
    procedure Sort;
    property Capacity: LongInt read GetCapacity write SetCapacity;    
    property Compare: TctsCompareEvent read GetCompare write SetCompare;
    property Dispose: TctsDisposeEvent read GetDispose write SetDispose;
    property Items[AIndex: LongInt]: TctsDataType read GetItems write SetItems; default;
  {$IFDEF USE_Object}
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  {$ENDIF}
  end;

  TctsVectorWithObserver = class(TctsVector, IctsContainer, IctsCollection, IctsVector, IctsObserverGenerator)
  protected
    function GenerateObserver: IctsObserver;
    procedure GetNotifier; override;
    procedure Register(const AObserver: IctsBaseObserver);
    procedure UnRegister(const AObserver: IctsBaseObserver);
  end;

  //LinkedList
  TctsCustomLinkedList = class(TObject)
  protected
    FCount: LongInt;
    FHead: PctsNode;
    FPool: IctsMemoryPool;
    FTail: PctsNode;
    procedure DoAdd(const AItem: TctsDataType); virtual;
    procedure DoClear; virtual;
    procedure DoDeleteNode(aNode: PctsNode); virtual;
    procedure DoPack; virtual;
    procedure InsertAfter(aNode: PctsNode; const AItem: TctsDataType); virtual;
    procedure InsertBefore(aNode: PctsNode; const AItem: TctsDataType); virtual;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TctsLinkedList = class(TctsContainer, IctsContainer, IctsCollection, IctsList)
  private
    FIsSorted: Boolean;
    FList: TctsCustomLinkedList;
    FNotifier: TctsNotifier;
  protected
    procedure Error(AMsg: PResStringRec; AMethodName: string);
    function GetCompare: TctsCompareEvent;
    function GetCount: LongInt; override;
    function GetDispose: TctsDisposeEvent;
    procedure GetNotifier; virtual;
  {$IFDEF USE_Object}
    function GetOwnsObjects: Boolean;
  {$ENDIF}
    function NodeOf(const AItem: TctsDataType): PctsNode;
    procedure SetCompare(const AValue: TctsCompareEvent);
    procedure SetCount(const AValue: LongInt); override;
    procedure SetData(const aNode: PctsNode; const AItem: TctsDataType); virtual;
    procedure SetDispose(const AValue: TctsDisposeEvent);
  {$IFDEF USE_Object}
    procedure SetOwnsObjects(const Value: Boolean);
  {$ENDIF}
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Add(const AItem: TctsDataType);
    procedure Clear;
    function Contain(const AItem: TctsDataType): Boolean;
    procedure DeleteNode(aNode: PctsNode);
    function First: IctsIterator;
    function GetHead: PctsNode;
    function GetTail: PctsNode;
    procedure InsertNode(aNode: PctsNode; const AItem: TctsDataType);
    function IsSorted: Boolean;
    function Last: IctsIterator;
    procedure Pack;
    function Remove(const AItem: TctsDataType): Boolean;
    procedure Sort;
    property Compare: TctsCompareEvent read GetCompare write SetCompare;
    property Dispose: TctsDisposeEvent read GetDispose write SetDispose;
  {$IFDEF USE_Object}
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  {$ENDIF}
  end;

  TctsLinkedListWithObserver = class(TctsLinkedList, IctsContainer, IctsCollection, IctsList, IctsObserverGenerator)
  protected
    function GenerateObserver: IctsObserver;
    procedure GetNotifier; override;
    procedure Register(const AObserver: IctsBaseObserver);
    procedure UnRegister(const AObserver: IctsBaseObserver);
  end;
  
  TctsSortFunctions = class(TObject)
  public
    class procedure HeapSort(const aList: TctsCustomVector; L, R: LongInt; const aCompare: TctsCompareEvent);
    class procedure MergeSort(const aList: TctsCustomLinkedList; const aCount: LongInt; const aCompare: TctsCompareEvent);
    class procedure QuickSort(const aList: TctsCustomVector; L, R: LongInt; const aCompare: TctsCompareEvent);
  end;

  TctsThreadSafeVector = class(TObject)
  private
    FResLock: TctsCriticalSection;  
    FVector: TctsVector;
  public
    constructor Create;
    destructor Destroy; override;
    function Lock: TctsVector;
    procedure UnLock;
  end;

  TctsThreadSafeLinkedList = class(TObject)
  private
    FList: TctsLinkedList;
    FResLock: TctsCriticalSection;  
  public
    constructor Create;
    destructor Destroy; override;
    function Lock: TctsLinkedList;
    procedure UnLock;
  end;

  // stack and queue

  TctsOrderOperator = class(TctsNamedClass, IctsOrderOperator)
  protected
    FContainer: TctsContainer;
    function GetReference: TObject;
  public
    constructor Create(const AClass: TctsContainerClass);
    destructor Destroy; override;
    function GetCount: LongInt;
    function IsEmpty: Boolean;
    procedure Pop; virtual; abstract;
    procedure Push(const aItem: TctsDataType); virtual; abstract;
  end;

  // TctsStack

  TctsStack = class(TctsOrderOperator, IctsStack)
  protected
    procedure Error(const AMsg: PResStringRec; const AMethodName: string);
  public
    procedure Pop; override;
    function Top: TctsDataType; virtual;
  end;

  TctsStackVector = class(TctsStack)
  public
    constructor Create(const aSize: LongInt = 0); reintroduce;
    procedure Pop; override;
    procedure Push(const aItem: TctsDataType); override;
    function Top: TctsDataType; override;
  end;

  TctsStackLinked = class(TctsStack)
  public
    constructor Create;
    procedure Pop; override;
    procedure Push(const aItem: TctsDataType); override;
    function Top: TctsDataType; override;
  end;

  // TctsQueue

  TctsQueue = class(TctsOrderOperator, IctsQueue)
  protected
    procedure Error(AMsg: PResStringRec; AMethodName: string);
  public
    function Back: TctsDataType; virtual;
    function Front: TctsDataType; virtual;
    procedure Pop; override;
  end;

  TctsQueueVector = class(TctsQueue)
  public
    constructor Create(const aSize: LongInt = 0); reintroduce;
    function Back: TctsDataType; override;
    function Front: TctsDataType; override;
    procedure Pop; override;
    procedure Push(const aItem: TctsDataType); override;
  end;

  TctsQueueLinked = class(TctsQueue)
  public
    constructor Create;
    function Back: TctsDataType; override;
    function Front: TctsDataType; override;
    procedure Pop; override;
    procedure Push(const aItem: TctsDataType); override;
  end;

{$IFDEF USE_Reference}
procedure FreeData(var aData: TctsDataType);
procedure FreeDataArray(const aArray: PctsArray; const aCount: LongInt);
{$ENDIF}
procedure MoveArray(var aArray: PctsArray; FromIndex, ToIndex, aCount: LongInt);

implementation

uses
  ctsConsts,
  ctsUtils;

const
{$IFDEF USE_String}
  cDataSize = SizeOf(TctsDataType);
{$ELSE}
  cDataSize = SizeOf(Pointer);
{$ENDIF}

type
  // TctsIteratorVector
  TctsIteratorVector = class(TctsBaseClass, IctsIterator)
  protected
    FCursorIx: LongInt;
    FVector: TctsVector;
    function GetData: TctsDataType;
    function HasNext: Boolean;
    function HasPrior: Boolean;
    procedure Insert(AItem: TctsDataType);
    procedure Next;
    procedure Prior;
    procedure Remove;
    procedure SetData(const aData: TctsDataType);
  public
    constructor Create(const AVector: TctsVector; const AIndex: LongInt);
  end;

  // TctsIteratorLinkedList
  TctsIteratorLinkedList = class(TctsBaseClass, IctsIterator)
  protected
    FCursor: PctsNode;
    FHead: PctsNode;
    FList: TctsLinkedList;
    FTail: PctsNode;
    function GetData: TctsDataType;
    function HasNext: Boolean;
    function HasPrior: Boolean;
    procedure Insert(AItem: TctsDataType);
    procedure Next;
    procedure Prior;
    procedure Remove;
    procedure SetData(const aData: TctsDataType);
  public
    constructor Create(const AList: TctsLinkedList; ANode: PctsNode);
  end;

{$IFDEF USE_Reference}
procedure FreeData(var aData: TctsDataType);
begin
{$IFDEF USE_Interface}
  aData := nil;
{$ENDIF}
{$IFDEF USE_String}
  aData := '';
{$ENDIF}
end;

procedure FreeDataArray(const aArray: PctsArray; const aCount: LongInt);
var
  I: LongInt;
begin
  for I := 0 to aCount - 1 do
    FreeData(aArray[I]);
end;
{$ENDIF USE_Reference}

procedure MoveArray(var aArray: PctsArray; FromIndex, ToIndex, aCount: LongInt);
begin
  if aCount > 0 then
  begin
    Move(aArray[FromIndex], aArray[ToIndex], aCount * cDataSize);
{$IFDEF USE_Reference}
    { Keep reference counting working }
    if FromIndex < ToIndex then
    begin
      if (ToIndex - FromIndex) < aCount then
        FillChar(aArray[FromIndex], (ToIndex - FromIndex) * cDataSize, 0)
      else
        FillChar(aArray[FromIndex], aCount * cDataSize, 0);
    end
    else
    if FromIndex > ToIndex then
    begin
      if (FromIndex - ToIndex) < aCount then
        FillChar(aArray[ToIndex + aCount], (FromIndex - ToIndex) * cDataSize, 0)
      else
        FillChar(aArray[FromIndex], aCount * cDataSize, 0);
    end;
{$ENDIF USE_Reference}    
  end;
end;

procedure ExchangeData(var Data1, Data2);
var
  T: LongInt;
begin
  T := LongInt(Data1);
  LongInt(Data1) := LongInt(Data2);
  LongInt(Data2) := T;
end;

// ===== Heapsort =====

procedure HSTrickleDown(const aSortAry: PctsArray; aFrom, aCount: LongInt; const aCompare: TctsCompareEvent);
var
  I, Temp: LongInt;
begin
  Temp := LongInt(aSortAry[aFrom]);
  I := (aFrom * 2) + 1;
  while (I < aCount) do
  begin
    if (I + 1 < aCount) and (aCompare(aSortAry[I], aSortAry[I + 1]) < 0) then
      Inc(I);
    LongInt(aSortAry[aFrom]) := LongInt(aSortAry[I]);
    aFrom := I;
    I := (aFrom * 2) + 1;
  end;

  I := (aFrom - 1) div 2;
  while (aFrom > 0) and (aCompare(TctsDataType(Temp), aSortAry[I]) > 0) do
  begin
    LongInt(aSortAry[aFrom]) := LongInt(aSortAry[I]);
    aFrom := I;
    I := (aFrom - 1) div 2;
  end;

  LongInt(aSortAry[aFrom]) := Temp;
end;

procedure HSTrickleDownS(const aSortAry: PctsArray; aFrom, aCount: LongInt; const aCompare: TctsCompareEvent);
var
  I, Temp: LongInt;
begin
  Temp := LongInt(aSortAry[aFrom]);
  I := (aFrom * 2) + 1;
  while I < aCount do
  begin
    if (I + 1 < aCount) and (aCompare(aSortAry[I], aSortAry[I + 1]) < 0) then
      Inc(I);
    if aCompare(TctsDataType(Temp), aSortAry[I]) >= 0 then
      Break;
    LongInt(aSortAry[aFrom]) := LongInt(aSortAry[I]);
    aFrom := I;
    I := (aFrom * 2) + 1;
  end;
  LongInt(aSortAry[aFrom]) := Temp;
end;

class procedure TctsSortFunctions.HeapSort(const aList: TctsCustomVector; L, R: LongInt; const aCompare: TctsCompareEvent);
var
  I, ItemCount: LongInt;
  Ary: PctsArray;
begin
  Ary := aList.FArray;
  ItemCount := R - L + 1;
  for I := ItemCount div 2 - 1 downto 0 do
    HSTrickleDownS(@Ary[L], I, ItemCount, aCompare);

  for I := ItemCount - 1 downto 0 do
  begin
    ExchangeData(Ary[L], Ary[L + I]);
    HSTrickleDown(@Ary[L], 0, I, aCompare);
  end;
end;

// ===== MergeSort =====

function Merge(APriorNode1, APriorNode2: PctsNode; ACount1, ACount2: LongInt; const aCompare: TctsCompareEvent): PctsNode;
var
  I: LongInt;
  Node1, Node2, LastNode, P: PctsNode;
begin
  LastNode := aPriorNode1;
  Node1 := APriorNode1.Next;
  Node2 := APriorNode2.Next;

  while (ACount1 <> 0) and (ACount2 <> 0) do
  begin
    if aCompare(Node1.Data, Node2.Data) <= 0 then
    begin
      LastNode := Node1;
      Node1 := Node1.Next;
      Dec(ACount1);
    end
    else
    begin
      P := Node2.Next;
      Node2.Next := Node1;
      LastNode.Next := Node2;
      LastNode := Node2;
      Node2 := P;
      Dec(ACount2);
    end;
  end;

  if ACount1 = 0 then
  begin
    LastNode.Next := Node2;
    for I := 1 to ACount2 do
      LastNode := LastNode.Next;
  end
  else
  begin
    for I := 1 to ACount1 do
      LastNode := LastNode.Next;
    LastNode.Next := Node2;
  end;
  Result := LastNode;
end;

function MergeSortFunc(const APriorNode: PctsNode; ACount: LongInt; const aCompare: TctsCompareEvent): PctsNode;
var
  vCount: LongInt;
  vPriorNode: PctsNode;
begin
  if ACount = 1 then
  begin
    Result := APriorNode.Next;
    Exit;
  end;
  vCount := ACount div 2;
  ACount := ACount - vCount;
  vPriorNode := MergeSortFunc(APriorNode, ACount, aCompare);
  MergeSortFunc(vPriorNode, vCount, aCompare);
  Result := Merge(APriorNode, vPriorNode, ACount, vCount, aCompare);
end;

class procedure TctsSortFunctions.MergeSort(const aList: TctsCustomLinkedList; const aCount: LongInt; const aCompare: TctsCompareEvent);
var
  Parent, P: PctsNode;
begin
  MergeSortFunc(aList.FHead, aCount, aCompare);
  Parent := aList.FHead;
  P := Parent.Next;
  while (P <> nil) do
  begin
    P.Prior := Parent;
    Parent := P;
    P := Parent.Next;
  end;
end;

// ===== QuickSort =====

class procedure TctsSortFunctions.QuickSort(const aList: TctsCustomVector; L, R: LongInt; const aCompare: TctsCompareEvent);
var
  I, J, Mid: LongInt;
  Ary: PctsArray;
begin
  Ary := aList.FArray;
  repeat
    I := L;
    J := R;
    Mid := LongInt(Ary[(L + R) shr 1]);
    repeat
      while aCompare(Ary[I], TctsDataType(Mid)) < 0 do
        Inc(I);
      while aCompare(Ary[J], TctsDataType(Mid)) > 0 do
        Dec(J);
      if I <= J then
      begin
        ExchangeData(Ary[I], Ary[J]);
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(aList, L, J, aCompare);
    L := I;
  until I >= R;
end;

// ===== TctsBaseNotifier =====

procedure TctsBaseNotifier.Notify(AValue: TctsDataType; ANotifyAction: TctsNotifyAction);
begin
end;

// ===== TctsNotifier =====
{$IFDEF USE_Object}
constructor TctsNotifier.Create;
begin
  FOwnsObjects := False;
end;
{$ENDIF}

procedure TctsNotifier.Notify(AValue: TctsDataType; ANotifyAction: TctsNotifyAction);
begin
  if (ANotifyAction = naDeleting) {$IFDEF USE_Object}and FOwnsObjects{$ENDIF} then
  begin
    if Assigned(FDispose) then
      FDispose(AValue)
  {$IFDEF USE_Object}
    else
      AValue.Free;
  {$ENDIF}
  end;
end;

procedure TctsNotifier.SetCompare(const AValue: TctsCompareEvent);
begin
  FCompare := AValue;
end;

procedure TctsNotifier.SetDispose(const AValue: TctsDisposeEvent);
begin
  FDispose := AValue;
end;

// ===== FctsNotifierWithObserver =====

destructor TctsNotifierWithObserver.Destroy;
begin
  if FObCollection <> nil then
    FObCollection.Free;
  inherited;
end;

procedure TctsNotifierWithObserver.Notify(AValue: TctsDataType; ANotifyAction: TctsNotifyAction);
var
  Entry: TctsNotifyEntry;
begin
  if FObCollection <> nil then
  begin
    Entry.Data := AValue;
    Entry.NotifyAction := ANotifyAction;
    FObCollection.IterateChange(@Entry);
  end;
  inherited;
end;

// ===== TctsObserver =====

procedure TctsObserver.Changed(AParams: Pointer);
var
  Entry: PctsNotifyEntry;
begin
  if GetEnabled and Assigned(FOnChanged) then
  begin
    Entry := AParams;
    FOnChanged(Entry.Data, Entry.NotifyAction);
  end;
end;

function TctsObserver.GetOnChanged: TctsNotifyEvent;
begin
  Result := FOnChanged;
end;

procedure TctsObserver.SetOnChanged(const AValue: TctsNotifyEvent);
begin
  FOnChanged := AValue;
end;

// ===== TctsCustomVector =====

destructor TctsCustomVector.Destroy;
begin
  DoClear;
  inherited Destroy;
end;

procedure TctsCustomVector.DoAdd(const AItem: TctsDataType);
begin
  if FCount = FCapacity then
    Grow;
{$IFDEF USE_Reference}
  Pointer(FArray[FCount]) := nil;
{$ENDIF USE_Reference}
  FArray[FCount] := AItem;
  Inc(FCount);
end;

procedure TctsCustomVector.DoClear;
begin
  if FCount = 0 then
    Exit;
{$IFDEF USE_Reference}
  FreeDataArray(FArray, FCount);
{$ENDIF USE_Reference}
  FCount := 0;
  if FCapacity > 0 then
  begin
    ReallocMem(FArray, 0);
    FCapacity := 0;
  end;
end;

procedure TctsCustomVector.DoDelete(const AIndex: LongInt);
begin
  Dec(FCount);
{$IFDEF USE_Reference}
  Pointer(FArray[AIndex]) := nil;
{$ENDIF USE_Reference}
  if AIndex < FCount then
  begin
    Move(FArray[AIndex + 1], FArray[AIndex], (FCount - AIndex) * cDataSize);
{$IFDEF USE_Reference}
    Pointer(FArray[FCount]) := nil;
{$ENDIF USE_Reference}
  end;
end;

procedure TctsCustomVector.DoInsert(const AIndex: LongInt; const AItem: TctsDataType);
begin
  if FCount = FCapacity then
    Grow;
  if AIndex < FCount then
  begin
{$IFDEF USE_Reference}
    Pointer(FArray[FCount]) := nil;
{$ENDIF USE_Reference}  
    Move(FArray[AIndex], FArray[AIndex + 1], (FCount - AIndex) * cDataSize);
  end;
{$IFDEF USE_Reference}
  Pointer(FArray[AIndex]) := nil;
{$ENDIF USE_Reference}
  FArray[AIndex] := AItem;
  Inc(FCount);
end;

procedure TctsCustomVector.DoPack;
var
  MoveCount: LongInt;
  PackedCount: LongInt;
  StartIndex: LongInt;
  EndIndex: LongInt;
begin
  if FCount = 0 then
    Exit;
  PackedCount := 0;
  StartIndex := 0;
  repeat
    while (Pointer(FArray[StartIndex]) = nil) and (StartIndex < FCount) do
      Inc(StartIndex);
    if StartIndex < FCount then
    begin
      EndIndex := StartIndex;
      while (Pointer(FArray[EndIndex]) <> nil) and (EndIndex < FCount) do
        Inc(EndIndex);
      MoveCount := EndIndex - StartIndex;
      if StartIndex > PackedCount then
        MoveArray(FArray, StartIndex, PackedCount, MoveCount);
      Inc(PackedCount, MoveCount);
      StartIndex := EndIndex;
    end;
  until StartIndex >= FCount;
  FCount := PackedCount;
end;

procedure TctsCustomVector.DoSetCapacity(const AValue: LongInt);
begin
  ReallocMem(FArray, AValue * cDataSize);
  FCapacity := AValue;
end;

procedure TctsCustomVector.Grow;
var
  Delta: LongInt;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    Delta := ctsDefaultCapacity;
  DoSetCapacity(FCapacity + Delta);
end;

// ===== TctsVector =====

constructor TctsVector.Create;
begin
  inherited Create;
  FVector := TctsCustomVector.Create;
  GetNotifier;
end;

destructor TctsVector.Destroy;
begin
  Clear;
  FVector.Free;
  FNotifier.Free;
  inherited Destroy;
end;

procedure TctsVector.Add(const AItem: TctsDataType);
begin
  FVector.DoAdd(AItem);
  FIsSorted := False;  
  FNotifier.Notify(AItem, naAdded);
end;

procedure TctsVector.Clear;
var
  I: LongInt;
begin
  with FVector do
  begin
    for I := 0 to FCount - 1 do
      FNotifier.Notify(FArray[I], naDeleting);
    DoClear;
  end;    
end;

function TctsVector.Contain(const AItem: TctsDataType): Boolean;
begin
  Result := IndexOf(AItem) >= 0;
end;

procedure TctsVector.Delete(const AIndex: LongInt);
begin
  with FVector do
  begin
    if OutRange(AIndex, 0, FCount) then
      Error(@SListIndexError, SDelete, AIndex);
    FNotifier.Notify(FArray[AIndex], naDeleting);
    DoDelete(AIndex);
  end;
end;

procedure TctsVector.Error(AMsg: PResStringRec; AMethodName: string; AData: LongInt);
begin
  if Name = '' then
    Name := SDefaultVectorName;
  raise EctsListError.CreateResFmt(AMsg, [cUnitName, ClassName, AMethodName, Name, AData]);
end;

function TctsVector.First: IctsIterator;
begin
  Result := TctsIteratorVector.Create(Self, 0);
end;

function TctsVector.GetArray: PctsArray;
begin
  Result := FVector.FArray;
end;

function TctsVector.GetCapacity: LongInt;
begin
  Result := FVector.FCapacity;
end;

function TctsVector.GetCompare: TctsCompareEvent;
begin
  Result := FNotifier.FCompare;
end;

function TctsVector.GetCount: LongInt;
begin
  Result := FVector.FCount;
end;

function TctsVector.GetDispose: TctsDisposeEvent;
begin
  Result := FNotifier.FDispose;
end;

function TctsVector.GetItems(AIndex: LongInt): TctsDataType;
begin
  with FVector do
  begin
    if OutRange(AIndex, 0, FCount) then
      Error(@SListIndexError, SGetItems, AIndex);
    Result := FArray[AIndex];
  end;    
end;

procedure TctsVector.GetNotifier;
begin
  FNotifier := TctsNotifier.Create;
end;

{$IFDEF USE_Object}
function TctsVector.GetOwnsObjects: Boolean;
begin
  Result := FNotifier.FOwnsObjects;
end;
{$ENDIF}

function TctsVector.IndexOf(const AItem: TctsDataType): LongInt;
begin
  Result := 0;
  with FVector do
  begin
    while (Result < FCount) and (FArray[Result] <> AItem) do
      Inc(Result);
    if Result = FCount then
      Result := -1;
  end;
end;

procedure TctsVector.Insert(const AIndex: LongInt; const AItem: TctsDataType);
begin
  with FVector do
  begin
    if OutRange(AIndex, 0, FCount + 1) then
      Error(@SListIndexError, SInsert, AIndex);
    DoInsert(AIndex, AItem);
  end;    
  FIsSorted := False;
  FNotifier.Notify(AItem, naAdded);
end;

function TctsVector.IsSorted: Boolean;
begin
  Result := FIsSorted;
end;

function TctsVector.Last: IctsIterator;
begin
  Result := TctsIteratorVector.Create(Self, Count - 1);
end;

procedure TctsVector.Pack;
begin
  FVector.DoPack;
end;

function TctsVector.Remove(const AItem: TctsDataType): Boolean;
var
  I: LongInt;
begin
  I := IndexOf(AItem);
  Result := I >= 0;
  if Result then
    Delete(I);
end;

procedure TctsVector.SetCapacity(const AValue: LongInt);
begin
  with FVector do
  begin
    if OutRange(AValue, FCount, ctsMaxBlockSize) then
      Error(@SVectorCapacityError, SSetCapacity, AValue);
    if AValue <> FCapacity then
      DoSetCapacity(AValue);
  end;        
end;

procedure TctsVector.SetCompare(const AValue: TctsCompareEvent);
begin
  FNotifier.FCompare := AValue;
end;

procedure TctsVector.SetCount(const AValue: LongInt);
var
  I: LongInt;
begin
  if OutRange(AValue, 0, ctsMaxBlockSize) then
    Error(@SVectorCountError, SSetCount, AValue);
  with FVector do
  begin
    if AValue > FCapacity then
      DoSetCapacity(AValue);
    if AValue > FCount then
      FillChar(FArray[FCount], (AValue - FCount) * cDataSize, 0)
    else
      for I := FCount - 1 downto AValue do
        DoDelete(I);
    FCount := AValue;
  end;
end;

procedure TctsVector.SetDispose(const AValue: TctsDisposeEvent);
begin
  FNotifier.FDispose := AValue;
end;

procedure TctsVector.SetItems(AIndex: LongInt; const AItem: TctsDataType);
begin
  if OutRange(AIndex, 0, Count) then
    Error(@SListIndexError, SSetItems, AIndex);

  with FVector, FNotifier do
    if AItem <> FArray[AIndex] then
    begin
      Notify(FArray[AIndex], naDeleting);
      FArray[AIndex] := AItem;
      FIsSorted := False;
      Notify(AItem, naAdded);
    end;
end;

{$IFDEF USE_Object}
procedure TctsVector.SetOwnsObjects(const Value: Boolean);
begin
  FNotifier.FOwnsObjects := Value;
end;
{$ENDIF}

procedure TctsVector.Sort;
begin
  if not Assigned(FNotifier.FCompare) then
    EctsListError.CreateResFmt(@SListHaveNotCompareFunc, [cUnitName, SSort, Name]);

  with FVector do
    if (FArray <> nil) and (FCount > 1) then
    begin
      TctsSortFunctions.QuickSort(FVector, 0, FCount - 1, FNotifier.FCompare);
      FIsSorted := True;
    end;
end;

// ===== TctsVectorWithObserver =====

function TctsVectorWithObserver.GenerateObserver: IctsObserver;
begin
  Result := TctsObserver.Create;
end;

procedure TctsVectorWithObserver.GetNotifier;
begin
  FNotifier := TctsNotifierWithObserver.Create;
end;

procedure TctsVectorWithObserver.Register(const AObserver: IctsBaseObserver);
begin
  with TctsNotifierWithObserver(FNotifier) do
  begin
    if FObCollection = nil then
      FObCollection := TctsObserverCollection.Create;
    FObCollection.Add(AObserver);
  end;
end;

procedure TctsVectorWithObserver.UnRegister(const AObserver: IctsBaseObserver);
begin
  TctsNotifierWithObserver(FNotifier).FObCollection.Remove(AObserver);
end;

// ===== TctsIteratorVector =====

constructor TctsIteratorVector.Create(const AVector: TctsVector; const AIndex: LongInt);
begin
  FCursorIx := AIndex;
  FVector := AVector;
end;

function TctsIteratorVector.GetData: TctsDataType;
begin
  Result := FVector[FCursorIx];
end;

function TctsIteratorVector.HasNext: Boolean;
begin
  Result := FCursorIx < FVector.Count;
end;

function TctsIteratorVector.HasPrior: Boolean;
begin
  Result := FCursorIx >= 0;
end;

procedure TctsIteratorVector.Insert(AItem: TctsDataType);
begin
  FVector.Insert(FCursorIx, AItem);
end;

procedure TctsIteratorVector.Next;
begin
  Inc(FCursorIx);
end;

procedure TctsIteratorVector.Prior;
begin
  Dec(FCursorIx);
end;

procedure TctsIteratorVector.Remove;
begin
  FVector.Delete(FCursorIx);
end;

procedure TctsIteratorVector.SetData(const aData: TctsDataType);
begin
  FVector[FCursorIx] := aData;
end;

// ===== TctsCustomLinkedList =====

constructor TctsCustomLinkedList.Create;
begin
  FPool := TctsMiniMemoryPool.Create(SizeOf(TctsNode));
  FPool.SetName(SDefaultLinkedListMemoryPoolName);
  FHead := FPool.NewClear;
  FTail := FPool.NewClear;
  FHead.Next := FTail;
  FTail.Prior := FHead;
end;

destructor TctsCustomLinkedList.Destroy;
begin
  FPool := nil;
  inherited Destroy;
end;

procedure TctsCustomLinkedList.DoAdd(const AItem: TctsDataType);
var
  P: PctsNode;
begin
  P := FPool.NewClear;
  P.Data := AItem;
  P.Next := FTail;
  P.Prior := FTail.Prior;
  FTail.Prior.Next := P;
  FTail.Prior := P;
  Inc(FCount);
end;

procedure TctsCustomLinkedList.DoClear;
var
  P, N: PctsNode;
begin
  if FCount = 0 then
    Exit;
  P := FHead.Next;
  while P <> FTail do
  begin
    N := P.Next;
    FPool.Delete(P);
    P := N;
  end;
  FHead.Next := FTail;
  FHead.Prior := nil;
  FTail.Next := nil;  
  FTail.Prior := FHead;
  FCount := 0;
end;

procedure TctsCustomLinkedList.DoDeleteNode(aNode: PctsNode);
begin
  with aNode^ do
  begin
    Prior.Next := Next;
    Next.Prior := Prior;
  end;
  Dec(FCount);
{$IFDEF USE_Reference}
  FreeData(aNode.Data);
{$ENDIF USE_Reference}
  FPool.Delete(aNode);
end;

procedure TctsCustomLinkedList.DoPack;
var
  P, N: PctsNode;
begin
  if FCount = 0 then
    Exit;
  P := FHead.Next;
  while P <> FTail do
  begin
    if Pointer(P.Data) = nil then
    begin
      N := P.Next;
      DoDeleteNode(P);
      P := N;
    end           
    else
      P := P.Next;
  end;
end;

procedure TctsCustomLinkedList.InsertAfter(aNode: PctsNode; const AItem: TctsDataType);
var
  P: PctsNode;
begin
  if aNode = FTail then
    aNode := aNode.Prior;
  P := FPool.NewClear;
  P.Data := AItem;
  P.Prior := aNode;
  P.Next := aNode.Next;
  aNode.Next.Prior := P;
  aNode.Next := P;
  Inc(FCount);
end;

procedure TctsCustomLinkedList.InsertBefore(aNode: PctsNode; const AItem: TctsDataType);
var
  P: PctsNode;
begin
  if aNode = FHead then
    aNode := aNode.Next;
  P := FPool.NewClear;
  P.Data := AItem;
  P.Next := aNode;
  P.Prior := aNode.Prior;
  aNode.Prior.Next := P;
  aNode.Prior := P;
  Inc(FCount);
end;

// ===== TctsLinkedList =====

constructor TctsLinkedList.Create;
begin
  inherited Create;
  GetNotifier;
  FList := TctsCustomLinkedList.Create;
end;

destructor TctsLinkedList.Destroy;
begin
  Clear;
  FList.Free;
  FNotifier.Free;
  inherited Destroy;
end;

procedure TctsLinkedList.Add(const AItem: TctsDataType);
begin
  FList.DoAdd(AItem);
  FIsSorted := False;
  FNotifier.Notify(AItem, naAdded);
end;

procedure TctsLinkedList.Clear;
var
  P, N: PctsNode;
begin
  with FList do
  begin
    if FList.FCount = 0 then
      Exit;
    P := FHead.Next;
    while P <> FTail do
    begin
      N := P.Next;
      FNotifier.Notify(P.Data, naDeleting);
      P := N;
    end;
    FList.DoClear;
  end;
end;

function TctsLinkedList.Contain(const AItem: TctsDataType): Boolean;
begin
  Result := NodeOf(AItem) <> nil;
end;

procedure TctsLinkedList.DeleteNode(aNode: PctsNode);
begin
  with FList do
  begin
    if (aNode = FHead) or (aNode = FTail) then
      Error(@SLinkedListNodeError, SDelete);
    FNotifier.Notify(aNode.Data, naDeleting);      
    DoDeleteNode(aNode);
  end;    
end;

procedure TctsLinkedList.Error(AMsg: PResStringRec; AMethodName: string);
begin
  if Name = '' then
    Name := SDefaultLinkedListName;
  raise EctsListError.CreateResFmt(AMsg, [cUnitName, ClassName, AMethodName, Name]);
end;

function TctsLinkedList.First: IctsIterator;
begin
  Result := TctsIteratorLinkedList.Create(Self, GetHead.Next);
end;

function TctsLinkedList.GetCompare: TctsCompareEvent;
begin
  Result := FNotifier.FCompare;
end;

function TctsLinkedList.GetCount: LongInt;
begin
  Result := FList.FCount;
end;

function TctsLinkedList.GetDispose: TctsDisposeEvent;
begin
  Result := FNotifier.FDispose;
end;

function TctsLinkedList.GetHead: PctsNode;
begin
  Result := FList.FHead;
end;

procedure TctsLinkedList.GetNotifier;
begin
  FNotifier := TctsNotifier.Create;
end;

{$IFDEF USE_Object}
function TctsLinkedList.GetOwnsObjects: Boolean;
begin
  Result := FNotifier.FOwnsObjects;
end;
{$ENDIF}

function TctsLinkedList.GetTail: PctsNode;
begin
  Result := FList.FTail;
end;

procedure TctsLinkedList.InsertNode(aNode: PctsNode; const AItem: TctsDataType);
begin
  FList.InsertBefore(aNode, AItem);
  FNotifier.Notify(AItem, naAdded);
end;

function TctsLinkedList.IsSorted: Boolean;
begin
  Result := FIsSorted;
end;

function TctsLinkedList.Last: IctsIterator;
begin
  Result := TctsIteratorLinkedList.Create(Self, GetTail.Prior);
end;

function TctsLinkedList.NodeOf(const AItem: TctsDataType): PctsNode;
begin
  with FList do
  begin
    Result := FHead.Next;
    while (Result <> FTail) do
    begin
      if Result.Data = AItem then
        Exit;
      Result := Result.Next;
    end;
  end;    
  Result := nil;
end;

procedure TctsLinkedList.Pack;
begin
  FList.DoPack;
end;

function TctsLinkedList.Remove(const AItem: TctsDataType): Boolean;
var
  P: PctsNode;
begin
  P := NodeOf(AItem);
  Result := P <> nil;
  if Result then
    FList.DoDeleteNode(P);
end;

procedure TctsLinkedList.SetCompare(const AValue: TctsCompareEvent);
begin
  FNotifier.FCompare := AValue;
end;

procedure TctsLinkedList.SetCount(const AValue: LongInt);
begin
  Error(@SLinkedListSetCountError, SSetCount);
end;

procedure TctsLinkedList.SetData(const aNode: PctsNode; const AItem: TctsDataType);
begin
  with FList do
    if (aNode = FHead) or (aNode = FTail) then
      Error(@SLinkedListNodeError, SSetValue);

  if AItem <> aNode.Data then
  begin
    FNotifier.Notify(aNode.Data, naDeleting);    
    aNode.Data := AItem;
    FIsSorted := False;    
    FNotifier.Notify(aItem, naAdded);
  end;
end;

procedure TctsLinkedList.SetDispose(const AValue: TctsDisposeEvent);
begin
  FNotifier.FDispose := AValue;
end;

{$IFDEF USE_Object}
procedure TctsLinkedList.SetOwnsObjects(const Value: Boolean);
begin
  FNotifier.FOwnsObjects := Value;
end;
{$ENDIF}

procedure TctsLinkedList.Sort;
begin
  if not Assigned(FNotifier.FCompare) then
    EctsListError.CreateResFmt(@SListHaveNotCompareFunc, [cUnitName, SSort, Name]);
  with FList do
    if FCount > 1 then
      TctsSortFunctions.MergeSort(FList, FCount, FNotifier.FCompare);
  FIsSorted := True;
end;

// ===== TctsLinkedListWithObserver =====

function TctsLinkedListWithObserver.GenerateObserver: IctsObserver;
begin
  TctsObserver.Create.QueryInterface(IctsObserver, Result);
end;

procedure TctsLinkedListWithObserver.GetNotifier;
begin
  FNotifier := TctsNotifierWithObserver.Create;
end;

procedure TctsLinkedListWithObserver.Register(const AObserver: IctsBaseObserver);
begin
  with TctsNotifierWithObserver(FNotifier) do
  begin
    if FObCollection = nil then
      FObCollection := TctsObserverCollection.Create;
    FObCollection.Add(AObserver);
  end;
end;

procedure TctsLinkedListWithObserver.UnRegister(const AObserver: IctsBaseObserver);
begin
  TctsNotifierWithObserver(FNotifier).FObCollection.Remove(AObserver);
end;

// ===== TctsIteratorLinkedList =====

constructor TctsIteratorLinkedList.Create(const AList: TctsLinkedList; ANode: PctsNode);
begin
  FCursor := ANode;
  FHead := AList.GetHead;
  FTail := AList.GetTail;
  FList := AList;
end;

function TctsIteratorLinkedList.GetData: TctsDataType;
begin
  Result := FCursor.Data;
end;

function TctsIteratorLinkedList.HasNext: Boolean;
begin
  Result := FCursor <> FTail;
end;

function TctsIteratorLinkedList.HasPrior: Boolean;
begin
  Result := FCursor <> FHead;
end;

procedure TctsIteratorLinkedList.Insert(AItem: TctsDataType);
begin
  FList.InsertNode(FCursor, AItem);
  FCursor := FCursor.Prior;
end;

procedure TctsIteratorLinkedList.Next;
begin
  FCursor := FCursor.Next;
end;

procedure TctsIteratorLinkedList.Prior;
begin
  FCursor := FCursor.Prior;
end;

procedure TctsIteratorLinkedList.Remove;
var
  P: PctsNode;
begin
  P := FCursor;
  FCursor := FCursor.Next;
  FList.DeleteNode(P);
end;

procedure TctsIteratorLinkedList.SetData(const aData: TctsDataType);
begin
  FList.SetData(FCursor, aData);
end;

// ===== TctsThreadSafeVector =====

constructor TctsThreadSafeVector.Create;
begin
  inherited;
  FResLock := TctsCriticalSection.Create;
  FVector := TctsVector.Create;
end;

destructor TctsThreadSafeVector.Destroy;
begin
  FResLock.Free;
  FVector.Free;
  inherited;
end;

function TctsThreadSafeVector.Lock: TctsVector;
begin
  FResLock.Enter;
  Result := FVector;
end;

procedure TctsThreadSafeVector.UnLock;
begin
  FResLock.Leave;
end;

// ===== TctsThreadSafeLinkedList =====

constructor TctsThreadSafeLinkedList.Create;
begin
  inherited;
  FResLock := TctsCriticalSection.Create;  
  FList := TctsLinkedList.Create;
end;

destructor TctsThreadSafeLinkedList.Destroy;
begin
  FResLock.Free;
  FList.Free;
  inherited;
end;

function TctsThreadSafeLinkedList.Lock: TctsLinkedList;
begin
  FResLock.Enter;
  Result := FList;
end;

procedure TctsThreadSafeLinkedList.UnLock;
begin
  FResLock.Leave;
end;

// ===== TctsOrderOperator =====

constructor TctsOrderOperator.Create(const AClass: TctsContainerClass);
begin
  FContainer := AClass.Create;
end;

destructor TctsOrderOperator.Destroy;
begin
  if FContainer <> nil then
    FContainer.Free;
  inherited Destroy;
end;

function TctsOrderOperator.GetCount: LongInt;
begin
  Result := FContainer.Count;
end;

function TctsOrderOperator.GetReference: TObject;
begin
  Result := Self;
end;

function TctsOrderOperator.IsEmpty: Boolean;
begin
  Result := FContainer.IsEmpty;
end;

// ===== TctsStack =====

procedure TctsStack.Error(const AMsg: PResStringRec; const AMethodName: string);
begin
  if Name = '' then
    Name := SDefaultStackName;
  raise EctsStackError.CreateResFmt(AMsg, [cUnitName, ClassName, AMethodName, Name]);
end;

procedure TctsStack.Pop;
begin
  if IsEmpty then
    Error(@SPopEmptyStackError, SPop);
end;

function TctsStack.Top: TctsDataType;
begin
  if IsEmpty then
    Error(@SEmptyStackError, STop);
  Pointer(Result) := nil;
end;

// ===== TctsStackVector =====

constructor TctsStackVector.Create(const aSize: LongInt = 0);
begin
  inherited Create(TctsVector);
  if aSize <> 0 then
    TctsVector(FContainer).SetCapacity(aSize);
end;

procedure TctsStackVector.Pop;
begin
  inherited Pop;
  with TctsVector(FContainer) do
    Delete(Count - 1);
end;

procedure TctsStackVector.Push(const aItem: TctsDataType);
begin
  TctsVector(FContainer).Add(aItem);
end;

function TctsStackVector.Top: TctsDataType;
begin
  inherited Top;
  with TctsVector(FContainer) do
    Result := Items[Count - 1];
end;

// ===== TctsStackLinked =====

constructor TctsStackLinked.Create;
begin
  inherited Create(TctsLinkedList);
end;

procedure TctsStackLinked.Pop;
begin
  inherited Pop;
  with TctsLinkedList(FContainer) do
    DeleteNode(GetTail.Prior);
end;

procedure TctsStackLinked.Push(const aItem: TctsDataType);
begin
  TctsLinkedList(FContainer).Add(aItem);
end;

function TctsStackLinked.Top: TctsDataType;
begin
  inherited Top;
  Result := TctsLinkedList(FContainer).GetTail.Prior.Data;
end;

// ===== TctsQueue =====

function TctsQueue.Back: TctsDataType;
begin
  if IsEmpty then
    Error(@SEmptyQueueError, SBack);
  Pointer(Result) := nil;
end;

procedure TctsQueue.Error(AMsg: PResStringRec; AMethodName: string);
begin
  if Name = '' then
    Name := SDefaultQueueName;
  raise EctsQueueError.CreateResFmt(AMsg, [cUnitName, ClassName, AMethodName, Name]);
end;

function TctsQueue.Front: TctsDataType;
begin
  if IsEmpty then
    Error(@SEmptyQueueError, SFront);
  Pointer(Result) := nil;
end;

procedure TctsQueue.Pop;
begin
  if IsEmpty then
    Error(@SPopEmptyQueueError, SPop);
end;

// ===== TctsQueueVector =====

constructor TctsQueueVector.Create(const aSize: LongInt = 0);
begin
  inherited Create(TctsVector);
  if aSize <> 0 then
    TctsVector(FContainer).SetCapacity(aSize);
end;

function TctsQueueVector.Back: TctsDataType;
begin
  inherited Back;
  with TctsVector(FContainer) do
    Result := Items[Count - 1];
end;

function TctsQueueVector.Front: TctsDataType;
begin
  inherited Front;
  Result := TctsVector(FContainer)[0];
end;

procedure TctsQueueVector.Pop;
begin
  inherited Pop;
  with TctsVector(FContainer) do
    Delete(Count - 1);
end;

procedure TctsQueueVector.Push(const aItem: TctsDataType);
begin
  TctsVector(FContainer).Insert(0, aItem);
end;

// ===== TctsQueueLinked =====

constructor TctsQueueLinked.Create;
begin
  inherited Create(TctsLinkedList);
end;

function TctsQueueLinked.Back: TctsDataType;
begin
  inherited Back;
  Result := TctsLinkedList(FContainer).GetTail.Prior.Data;
end;

function TctsQueueLinked.Front: TctsDataType;
begin
  inherited Front;
  Result := TctsLinkedList(FContainer).GetHead.Next.Data;
end;

procedure TctsQueueLinked.Pop;
begin
  inherited Pop;
  with TctsLinkedList(FContainer) do
    DeleteNode(GetTail.Prior);
end;

procedure TctsQueueLinked.Push(const aItem: TctsDataType);
begin
  with TctsLinkedList(FContainer) do
    InsertNode(GetHead.Next, aItem);
end;



end.
