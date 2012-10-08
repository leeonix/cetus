// ctsStruct.int

  PctsDataType = ^TctsDataType;
  TctsDisposeEvent = procedure(AData: TctsDataType) of object;
  TctsCompareEvent = function(AData1, AData2: TctsDataType): LongInt of object;
  TctsNotifyEvent = procedure(AValue: TctsDataType; ANotifyAction: TctsNotifyAction) of object;

  // observer

  IctsObserver = interface(IctsBaseObserver)
    ['{89848C61-C6B6-4CAE-BF5B-5D02A9D482F4}']
    function GetOnChanged: TctsNotifyEvent;
    procedure SetOnChanged(const AValue: TctsNotifyEvent);
    property OnChanged: TctsNotifyEvent read GetOnChanged write SetOnChanged;
  end;

  IctsObserverGenerator = interface(IctsObserverRegister)
    ['{96D5A9AE-F62A-4409-9406-AD59C5BDEADE}']
    function GenerateObserver: IctsObserver;
  end;

  // iterator

  IctsIterator = interface(IUnknown)
    ['{3BED617C-AF2E-4003-8FE5-3B73856404B0}']
    function GetData: TctsDataType;
    function HasNext: Boolean;
    function HasPrior: Boolean;
    procedure Insert(AItem: TctsDataType);
    procedure Next;
    procedure Prior;
    procedure Remove;
    procedure SetData(const aData: TctsDataType);
    property Data: TctsDataType read GetData write SetData;
  end;

  // collection vector list.

  IctsCollection = interface(IctsContainer)
    ['{4ABAFAC4-F71A-4275-8216-254C284B28B5}']
    procedure Add(const AItem: TctsDataType);
    procedure Clear;
    function Contain(const AItem: TctsDataType): Boolean;
    function First: IctsIterator;
    function GetCompare: TctsCompareEvent;
    function GetDispose: TctsDisposeEvent;
    function IsSorted: Boolean;
    function Last: IctsIterator;
    procedure Pack;
    function Remove(const AItem: TctsDataType): Boolean;
    procedure SetCompare(const AValue: TctsCompareEvent);
    procedure SetDispose(const AValue: TctsDisposeEvent);
    procedure Sort;
  {$IFDEF USE_Object}
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  {$ENDIF}
    property Compare: TctsCompareEvent read GetCompare write SetCompare;
    property Dispose: TctsDisposeEvent read GetDispose write SetDispose;
  end;

  PctsArray = ^TctsArray;
  TctsArray = array[0..ctsMaxBlockSize - 1] of TctsDataType;

  IctsVector = interface(IctsCollection)
    ['{E5C83823-912C-4B42-88BB-E336A0D73329}']
    procedure Delete(const AIndex: LongInt);
    function GetArray: PctsArray;
    function GetCapacity: LongInt;
    function GetItems(AIndex: LongInt): TctsDataType;
    function IndexOf(const AItem: TctsDataType): LongInt;
    procedure Insert(const AIndex: LongInt; const AItem: TctsDataType);
    procedure SetCapacity(const AValue: LongInt);
    procedure SetItems(AIndex: LongInt; const AItem: TctsDataType);
    property Capacity: LongInt read GetCapacity write SetCapacity;
    property Items[AIndex: LongInt]: TctsDataType read GetItems write SetItems; default;
  end;

  PctsNode = ^TctsNode;
  TctsNode = packed record
    Data: TctsDataType;
    case Boolean of
      False: (Link: PctsNode);
      True: (Next, Prior: PctsNode)
  end;

  IctsList = interface(IctsCollection)
    ['{23A434F6-388E-4578-BB4F-014C815796BE}']
    procedure DeleteNode(aNode: PctsNode);
    function GetHead: PctsNode;
    function GetTail: PctsNode;
    procedure InsertNode(aNode: PctsNode; const AItem: TctsDataType);
  end;

  // stack and queue

  IctsOrderOperator = interface(IctsBaseContainer)
    ['{A544295E-C7A5-44C0-9974-65E8A6AB2F3C}']
    procedure Pop;
    procedure Push(const aItem: TctsDataType);
  end;

  IctsStack = interface(IctsOrderOperator)
    ['{792A684C-33A6-4F62-88AA-7BC7A5726EE9}']
    function Top: TctsDataType;
  end;

  IctsQueue = interface(IctsOrderOperator)
    ['{61B33183-C6BA-44B0-9D8D-1F29906D6AEF}']
    function Back: TctsDataType;
    function Front: TctsDataType;
  end;

implementation
