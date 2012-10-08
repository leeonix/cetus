{$I CetusOptions.inc}

unit ctsThreads;

interface

uses
  Classes,
  SysUtils,

  JclSynch,

  ctsSyncObjects,
  ctsBaseInterfaces,
  ctsBaseClasses,
  ctsIInterfaceInclude,
  ctsPointerInclude;

type
  TCheckDuplicate = (cdQueue, cdProcessing);
  TCheckDuplicates = set of TCheckDuplicate;
  TThreadState = (ctsInitializing, ctsWaiting, ctsGetting, ctsProcessing, ctsProcessed, ctsTerminating, ctsForReduce);

  IctsTaskData = interface(IctsBaseInterface)
    ['{C6B157E2-6CDF-41F0-9A39-3A0F8A7D6AF4}']
    function Clone: IctsTaskData;
    function Duplicate(aTaskData: IctsTaskData; const aProcessing: Boolean): Boolean;
    function Info: string;
  end;

  { TctsTaskData }

  TctsTaskData = class(TctsBaseClass, IctsTaskData)
  public
    function Clone: IctsTaskData; virtual; abstract;
    function Duplicate(aTaskData: IctsTaskData; const aProcessing: Boolean): Boolean; virtual;
    function Info: string; virtual;
  end;

  TctsTaskArray = array of IctsTaskData;

  TctsTaskQueue = class;
  TQueueEmpty = procedure(Sender: TctsTaskQueue) of object;

  TctsTaskList = class(TctsIntfCustomVector)
  protected
    function GetItems(AIndex: LongInt): IctsTaskData;
  public
    property Items[AIndex: LongInt]: IctsTaskData read GetItems; default;
  end;

  { TctsTaskQueue }

  TctsTaskQueue = class(TctsTaskList)
  protected
    FDeadTaskList: TctsTaskList;
    FLastGetPoint: LongInt;
    FOnQueueEmpty: TQueueEmpty;
    FQueueLock: TJclCriticalSection;
    FQueuePackCount: LongInt;
    FTaskCount: LongInt;
    procedure DoQueueEmpty;
    function Duplicate(aTaskData: IctsTaskData): Boolean;
    procedure GetRequest(out aTaskData: IctsTaskData);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AItem: IctsTaskData);
    procedure ClearDeadTask;
    function HasTask: Boolean;
    procedure Remove(const AItem: IctsTaskData);
    function TaskIsEmpty: Boolean;
    property QueuePackCount: LongInt read FQueuePackCount write FQueuePackCount default 127;
    property TaskCount: LongInt read FTaskCount;
    property OnQueueEmpty: TQueueEmpty read FOnQueueEmpty write FOnQueueEmpty;
  end;

  { TctsPoolingThread }

  TctsThreadPool = class;

  TctsPoolingThread = class(TThread)
  private
    FInitError: string;
    FInitFinished: TJclEvent;
    procedure ForceTerminate;
  {$IFDEF DEBUG}    
    procedure Trace(const Str: string);
  {$ENDIF DEBUG}
  protected
    FProcessLock: TJclCriticalSection;
    FAverageProcessing: LongInt;
    FAverageWaitingTime: LongInt;
    FCurState: TThreadState;
    FPool: TctsThreadPool;
    FProcessingData: IctsTaskData;
    FProcessingStart: LongWord;
    FStillWorking: LongWord;
    FEventTerminated: TJclEvent;
    FWaitingStart: LongWord;
    FWorkCount: Int64;
    function AverageProcessingTime: LongWord;
    function AverageWaitingTime: LongWord;
    function CloneData: IctsTaskData;
    function Duplicate(aTaskData: IctsTaskData): Boolean; virtual;
    procedure Execute; override;
    function Info: string; virtual;
    function IsDead: Boolean; virtual;
    function IsFinished: Boolean; virtual;
    function IsIdle: Boolean; virtual;
    function NewAverage(OldAvg, NewVal: LongInt): LongInt; virtual;
  public
    constructor Create(aPool: TctsThreadPool); virtual;
    destructor Destroy; override;
    procedure StillWorking;
    procedure Terminate(const Force: Boolean = False);
  end;

  TctsPoolingThreadClass = class of TctsPoolingThread;

  TGetInfo = procedure(Sender: TctsThreadPool; var InfoText: string) of object;
  TProcessRequest = procedure(Sender: TctsThreadPool; aTaskData: IctsTaskData; aThread: TctsPoolingThread) of object;
  TTaskEmpty = procedure(Sender: TctsThreadPool) of object;
  TThreadInPoolInitializing = procedure(Sender: TctsThreadPool; aThread: TctsPoolingThread) of object;
  TThreadInPoolFinalizing = procedure(Sender: TctsThreadPool; aThread: TctsPoolingThread) of object;

  { TctsThreadVector }

  TctsThreadVector = class(TctsPtrCustomVector)
  protected
    procedure DoClear; override;
    function GetItems(AIndex: LongInt): TctsPoolingThread;
  public
    property Items[AIndex: LongInt]: TctsPoolingThread read GetItems; default;
  end;

  { TctsThreadPool }

  TctsThreadPool = class(TctsNamedClass)
  private
    FAdjustInterval: LongWord;
    FDeadCheckCount: LongInt;
    FDeadTaskAsNew: Boolean;
    FGetInfo: TGetInfo;
    FIdleThreadCount: LongInt;
    FMaxDeadTaskCheckCount: LongInt;
    FMinAtLeast: Boolean;
    FProcessRequest: TProcessRequest;
    FTaskQueue: TctsTaskQueue;
    FTerminateWaitTime: LongWord;
    FThreadClass: TctsPoolingThreadClass;
    FThreadDeadTimeout: LongWord;
    FThreadFinalizing: TThreadInPoolFinalizing;
    FThreadInitializing: TThreadInPoolInitializing;
    FThreadLock: IReadWriteSync;
    FThreads: TctsThreadVector;
    FThreadsKilling: TctsThreadVector;
    FThreadsMaxCount: LongInt;
    FThreadsMinCount: LongInt;
    procedure AddThread; inline;
    procedure CopyToKillingList(const AThread: TctsPoolingThread; const AIndex: LongInt); inline;
    procedure SetAdjustInterval(const Value: LongWord);
  protected
    FOnTaskEmpty: TTaskEmpty;
    FSemaphoreRequest: TJclSemaphore;
    FTimerReduce: TJclWaitableTimer;
    procedure CheckTaskEmpty;
    procedure DecreaseThreads;
    procedure DefaultGetInfo(Sender: TctsThreadPool; var InfoText: string);
    procedure DoProcessRequest(aTaskData: IctsTaskData; aThread: TctsPoolingThread); virtual;
    procedure DoTaskEmpty;
    procedure DoThreadFinalizing(aThread: TctsPoolingThread); virtual;
    procedure DoThreadInitializing(aThread: TctsPoolingThread); virtual;
    function DuplicateInThreads(aTaskData: IctsTaskData): Boolean;
    function FinishedThreadsAreFull: Boolean; virtual;
    procedure FreeFinishedThreads;
    procedure IncreaseThreads;
    procedure ReAddDeadRequest;
  public
    constructor Create;
    constructor CreateSpecial(AClass: TctsPoolingThreadClass);
    destructor Destroy; override;
    function AddRequest(aTaskData: IctsTaskData; CheckDuplicate: TCheckDuplicates = [cdQueue]): Boolean;
    procedure AddRequests(const aTaskDatas: TctsTaskArray; CheckDuplicate: TCheckDuplicates = [cdQueue]);
    function AverageProcessingTime: LongInt;
    function AverageWaitingTime: LongInt;
    function HasProcessingThread: Boolean;
    function HasSpareThread: Boolean;
    function HasThread: Boolean;
    function Info: string;
    procedure RemoveRequest(aTaskData: IctsTaskData);
    procedure TerminateAllThread(const AForce: Boolean = False);
    function ThreadCount: LongInt;
    function ThreadInfo(const I: LongInt): string;
    function ThreadKillingCount: LongInt;
    function ThreadKillingInfo(const I: LongInt): string;
    property AdjustInterval: LongWord read FAdjustInterval write SetAdjustInterval default 10000;
    property DeadTaskAsNew: Boolean read FDeadTaskAsNew write FDeadTaskAsNew default True;
    property MaxDeadTaskCheckCount: LongInt read FMaxDeadTaskCheckCount write FMaxDeadTaskCheckCount default 50;
    property MinAtLeast: Boolean read FMinAtLeast write FMinAtLeast default False;
    property TaskQueue: TctsTaskQueue read FTaskQueue write FTaskQueue;
    property TerminateWaitTime: LongWord read FTerminateWaitTime write FTerminateWaitTime;
    property ThreadDeadTimeout: LongWord read FThreadDeadTimeout write FThreadDeadTimeout default 0;
    property Threads: TctsThreadVector read FThreads;
    property ThreadsKilling: TctsThreadVector read FThreadsKilling;
    property ThreadsMaxCount: LongInt read FThreadsMaxCount write FThreadsMaxCount default 10;
    property ThreadsMinCount: LongInt read FThreadsMinCount write FThreadsMinCount default 0;
    property OnGetInfo: TGetInfo read FGetInfo write FGetInfo;
    property OnProcessRequest: TProcessRequest read FProcessRequest write FProcessRequest;
    property OnTaskEmpty: TTaskEmpty read FOnTaskEmpty write FOnTaskEmpty;
    property OnThreadFinalizing: TThreadInPoolFinalizing read FThreadFinalizing write FThreadFinalizing;
    property OnThreadInitializing: TThreadInPoolInitializing read FThreadInitializing write FThreadInitializing;
  end;

const
  cThreadState: array[TThreadState] of string = (
    'ctsInitializing', 'ctsWaiting', 'ctsGetting',
    'ctsProcessing', 'ctsProcessed', 'ctsTerminating', 'ctsForReduce');

implementation

uses
  Windows,
  Math,
{$IFDEF USE_CODESITE}
  CodeSiteLogging,
{$ENDIF USE_CODESITE}
  ctsUtils,
  ctsConsts;

const
  MaxInt64 = High(int64);

function GetTickDiff(const AOldTickCount, ANewTickCount: LongWord): LongWord; inline;
begin
  if ANewTickCount >= AOldTickCount then
    Result := ANewTickCount - AOldTickCount
  else
    Result := High(LongWord) - AOldTickCount + ANewTickCount;
end;

{ TctsTaskData }

function TctsTaskData.Duplicate(aTaskData: IctsTaskData; const aProcessing: Boolean): Boolean;
begin
  Result := False;
end;

function TctsTaskData.Info: string;
begin
  Result := IntToHex(LongWord(Self), 8);
end;

function TctsTaskList.GetItems(AIndex: LongInt): IctsTaskData;
begin
  Result := nil;
  if not OutRange(AIndex, 0, FCount) then
    Result := FArray[AIndex] as IctsTaskData;
end;

{ TctsTaskQueue }

constructor TctsTaskQueue.Create;
begin
  inherited;
  FLastGetPoint := 0;
  FTaskCount := 0;
  FQueuePackCount := 127;  
  FQueueLock := TJclCriticalSection.Create;
  FDeadTaskList := TctsTaskList.Create;
end;

destructor TctsTaskQueue.Destroy;
begin
  FQueueLock.Enter;
  try
    FreeAndNil(FDeadTaskList);
    inherited Destroy;
  finally
    FQueueLock.Free;
  end;
end;

procedure TctsTaskQueue.Add(const AItem: IctsTaskData);
begin
  {$IFDEF USE_CODESITE}CodeSite.EnterMethod(Self, 'Add');{$ENDIF}

  FQueueLock.Enter;
  try
    DoAdd(AItem);
    Inc(FTaskCount);
  finally
    FQueueLock.Leave;
  end;

  {$IFDEF USE_CODESITE}CodeSite.ExitMethod(Self, 'Add');{$ENDIF}
end;

procedure TctsTaskQueue.ClearDeadTask;
begin
  {$IFDEF USE_CODESITE}CodeSite.EnterMethod(Self, 'ClearDeadTask');{$ENDIF}

  FQueueLock.Enter;
  try
    FDeadTaskList.DoClear;
  finally
    FQueueLock.Leave;
  end;

  {$IFDEF USE_CODESITE}CodeSite.ExitMethod(Self, 'ClearDeadTask');{$ENDIF}
end;

procedure TctsTaskQueue.DoQueueEmpty;
begin
  if Assigned(FOnQueueEmpty) then
  begin
    FQueueLock.Enter;
    try
      FOnQueueEmpty(Self);
    finally
      FQueueLock.Leave;
    end;
  end;
end;

function TctsTaskQueue.Duplicate(aTaskData: IctsTaskData): Boolean;
var
  I: LongInt;
  Task: IctsTaskData;
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'Duplicate' );
{$ENDIF}
  Result := False;
  FQueueLock.Enter;
  try
    for I := 0 to FCount - 1 do
    begin
      Task := FArray[I] as IctsTaskData;
      if (Task <> nil) and aTaskData.Duplicate(Task, False) then
      begin
      {$IFDEF DEBUG}
        CodeSite.Send('Duplicate: ( ' + Task.Info + ' )');
      {$ENDIF DEBUG}
        aTaskData := nil;
        Result := True;
        Break;
      end;
    end;
  finally
    FQueueLock.Leave;
  end;
{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'Duplicate' );
{$ENDIF}
end;

procedure TctsTaskQueue.GetRequest(out aTaskData: IctsTaskData);
var
  DeadCount: LongInt;
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'GetRequest' );  
{$ENDIF DEBUG}
  FQueueLock.Enter;
  try
    while (FLastGetPoint < FCount) and (FArray[FLastGetPoint] = nil) do
      Inc(FLastGetPoint);

    if (FCount > FQueuePackCount) and (FLastGetPoint >= FCount * 3 div 4) then
    begin
      DoPack;
      FTaskCount := FCount;
      FLastGetPoint := 0
    end;

    FArray[FLastGetPoint].QueryInterface(IctsTaskData, aTaskData);
    FArray[FLastGetPoint] := nil;
    
    DeadCount := FDeadTaskList.FCount;
    if DeadCount > 0 then
    begin
      FArray[FLastGetPoint] := FDeadTaskList[DeadCount - 1];
      FDeadTaskList.DoDelete(DeadCount - 1);
    end
    else
      Dec(FTaskCount);

    Inc(FLastGetPoint);

  {$IFDEF DEBUG}
    CodeSite.Send('GetRequest: ( ' + aTaskData.Info + ' )');
  {$ENDIF DEBUG}

    if TaskIsEmpty then
    begin
      DoQueueEmpty;
      FTaskCount := 0;
      FLastGetPoint := 0;
      DoClear;
    end;
    
  finally
    FQueueLock.Leave;
  end;
{$IFDEF DEBUG}
  CodeSite.Send(aTaskData.Info);
  CodeSite.ExitMethod( Self, 'GetRequest' );
{$ENDIF}
end;

function TctsTaskQueue.HasTask: Boolean;
begin
  Result := FTaskCount > 0;
end;

procedure TctsTaskQueue.Remove(const AItem: IctsTaskData);
var
  I: LongInt;
begin
  FQueueLock.Enter;
  try
    I := 0;
    while (I < FCount) and (FArray[I] <> AItem) do
      Inc(I);
    if I < FCount then
    begin
      DoDelete(I);
      Dec(FTaskCount);
    end;
  finally
    FQueueLock.Leave;
  end;          
end;

function TctsTaskQueue.TaskIsEmpty: Boolean;
begin
  Result := FLastGetPoint >= FCount;
end;

{ TctsPoolingThread }

constructor TctsPoolingThread.Create(aPool: TctsThreadPool);
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'Create' );
{$ENDIF DEBUG}

  inherited Create(True);
  FPool := aPool;
  FAverageWaitingTime := 0;
  FAverageProcessing := 0;
  FWorkCount := 0;
  FInitError := '';
  FreeOnTerminate := False;
  FInitFinished := TJclEvent.Create(nil, True, False, '');
  FEventTerminated := TJclEvent.Create(nil, True, False, '');
  FProcessLock := TJclCriticalSection.Create;
  try
    Resume;
    FInitFinished.WaitForever;
  {$IFDEF DEBUG}
    CodeSite.Send( 'Wait InitFinished' );
  {$ENDIF DEBUG}
    if FInitError <> '' then
      raise Exception.Create(FInitError);
  finally
    FInitFinished.Free;
  end;

{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'Create' );
{$ENDIF DEBUG}
end;

destructor TctsPoolingThread.Destroy;
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'Destroy' );  
{$ENDIF DEBUG}
  FProcessLock.Enter;
  try
    FProcessingData := nil;
  finally
    FProcessLock.Free;
  end;
  FEventTerminated.Free;
  inherited Destroy;

{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'Destroy' );
{$ENDIF}
end;

function TctsPoolingThread.AverageProcessingTime: LongWord;
begin
  if FCurState in [ctsProcessing] then
    Result := NewAverage(FAverageProcessing, GetTickDiff(FProcessingStart, GetTickCount))
  else
    Result := FAverageProcessing;
end;

function TctsPoolingThread.AverageWaitingTime: LongWord;
begin
  if FCurState in [ctsWaiting, ctsForReduce] then
    Result := NewAverage(FAverageWaitingTime, GetTickDiff(FWaitingStart, GetTickCount))
  else
    Result := FAverageWaitingTime;
end;

function TctsPoolingThread.CloneData: IctsTaskData;
begin
  FProcessLock.Enter;
  try
    Result := nil;
    if FProcessingData <> nil then
      Result := FProcessingData.Clone;
  finally
    FProcessLock.Leave;
  end;
end;

function TctsPoolingThread.Duplicate(aTaskData: IctsTaskData): Boolean;
begin
  FProcessLock.Enter;
  try
    Result := (FProcessingData <> nil) and aTaskData.Duplicate(FProcessingData, True);
  finally
    FProcessLock.Leave;
  end;
end;

const
  WAIT_REQUEST   = WAIT_OBJECT_0;
  WAIT_REDURE    = WAIT_REQUEST + 1;
  WAIT_TERMINATE = WAIT_REDURE  + 1;

procedure TctsPoolingThread.Execute;
var
  WaitedTime: LongInt;
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'Execute' );  
{$ENDIF DEBUG}

  FCurState := ctsInitializing;
  try
    FPool.DoThreadInitializing(Self);
  except
    on E: Exception do
      FInitError := E.Message;
  end;
  FInitFinished.SetEvent;

{$IFDEF DEBUG}
  Trace('Initialized');
{$ENDIF DEBUG}

  FWaitingStart := GetTickCount;
  FProcessingData := nil;

  while not Terminated do
  begin
    if not (FCurState in [ctsWaiting, ctsForReduce]) then
      LockedInc(FPool.FIdleThreadCount);
    FCurState := ctsWaiting;
    /////////////////////////////////////////////////////////////////////////////////////////////
    case JclSynch.WaitForMultipleObjects([FPool.FSemaphoreRequest,
                                          FPool.FTimerReduce,
                                          FEventTerminated], False, INFINITE) of
      WAIT_REQUEST:
      begin
      {$IFDEF DEBUG}
        Trace('FSemaphoreRequest');
      {$ENDIF DEBUG}

        WaitedTime := GetTickDiff(FWaitingStart, GetTickCount);
        FAverageWaitingTime := NewAverage(FAverageWaitingTime, WaitedTime);

        if FCurState in [ctsWaiting, ctsForReduce] then
          LockedDec(FPool.FIdleThreadCount);
        FCurState := ctsGetting;
        FPool.FTaskQueue.GetRequest(FProcessingData);
        if FWorkCount < MaxInt64 then
          Inc(FWorkCount);
        FProcessingStart := GetTickCount;
        FStillWorking := FProcessingStart;

        FCurState := ctsProcessing;
        try
        {$IFDEF DEBUG}
          Trace('Processing: ' + FProcessingData.Info);
        {$ENDIF DEBUG}

          FPool.DoProcessRequest(FProcessingData, Self)
        except
        {$IFDEF DEBUG}
          on E: Exception do
            Trace('OnProcessRequest Exception: ' + E.Message);
        {$ENDIF DEBUG}
        end;

        FProcessLock.Enter;
        try
          FProcessingData := nil;
          FAverageProcessing := NewAverage(FAverageProcessing, GetTickDiff(FProcessingStart, GetTickCount));
        finally
          FProcessLock.Leave;
        end;

        FCurState := ctsProcessed;
        FPool.CheckTaskEmpty;
        FWaitingStart := GetTickCount;
      end;
      WAIT_REDURE:
      begin
      {$IFDEF DEBUG}
        Trace('FTimerReduce');
      {$ENDIF DEBUG}

        if not (FCurState in [ctsWaiting, ctsForReduce]) then
          LockedInc(FPool.FIdleThreadCount);
        FCurState := ctsForReduce;
        FPool.DecreaseThreads;
      end;
      WAIT_TERMINATE:
      begin
      {$IFDEF DEBUG}
        Trace('FEventTerminated');
      {$ENDIF DEBUG}

        if FCurState in [ctsWaiting, ctsForReduce] then
          LockedDec(FPool.FIdleThreadCount);

        FCurState := ctsTerminating;
        Break;
      end;
    end;
  end;

  if FCurState in [ctsWaiting, ctsForReduce] then
    InterlockedDecrement(FPool.FIdleThreadCount);
  FCurState := ctsTerminating;
  FPool.DoThreadFinalizing(Self);
{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'Execute' );
{$ENDIF}  
end;

procedure TctsPoolingThread.ForceTerminate;
begin
  TerminateThread(Handle, 0);
end;

function TctsPoolingThread.Info: string;
const
  cInfoFormat = 'AverageWaitingTime=%d; AverageProcessingTime=%d; FCurState=%s; FWorkCount=%d';
begin
  Result := Format(cInfoFormat, [AverageWaitingTime, AverageProcessingTime, cThreadState[FCurState], FWorkCount]);
  FProcessLock.Enter;
  try
    Result := Result + '; FProcessingData=';
    if FProcessingData = nil then
      Result := Result + 'nil'
    else
      Result := Result + FProcessingData.Info;
  finally
    FProcessLock.Leave;
  end;
end;

function TctsPoolingThread.IsDead: Boolean;
begin
  Result := Terminated or
            ((FCurState = ctsProcessing) and
            (FPool.ThreadDeadTimeout > 0) and
            (GetTickDiff(FStillWorking, GetTickCount) > FPool.ThreadDeadTimeout));
{$IFDEF DEBUG}
  if Result then
    Trace('Thread is dead, Info = ' + Info);
{$ENDIF DEBUG}
end;

function TctsPoolingThread.IsFinished: Boolean;
begin
  Result := WaitForSingleObject(Handle, 0) = WAIT_OBJECT_0;
end;

function TctsPoolingThread.IsIdle: Boolean;
begin
  Result := (FCurState in [ctsWaiting, ctsForReduce]) and
            (AverageWaitingTime > 200) and
            (AverageWaitingTime * 2 > AverageProcessingTime);
end;

function TctsPoolingThread.NewAverage(OldAvg, NewVal: LongInt): LongInt;
begin
  if FWorkCount >= 8 then
    Result := (OldAvg * 7 + NewVal) div 8
  else if FWorkCount > 0 then
    Result := (OldAvg * FWorkCount + NewVal) div FWorkCount
  else
    Result := NewVal;
end;

procedure TctsPoolingThread.StillWorking;
begin
  FStillWorking := GetTickCount;
end;

procedure TctsPoolingThread.Terminate(const Force: Boolean);
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'Terminate' );
  CodeSite.Send('Force', Force);
{$ENDIF DEBUG}

  inherited Terminate;
  if Force then
  begin
    ForceTerminate;
    Free;
  end
  else
    FEventTerminated.SetEvent;
    
{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'Terminate' );
{$ENDIF}
end;

{$IFDEF DEBUG}
procedure TctsPoolingThread.Trace(const Str: string);
begin
  CodeSite.Send(IntToStr(ThreadID) + ': ( ' + Str + ' )');
end;
{$ENDIF DEBUG}

{ TctsThreadVector }

procedure TctsThreadVector.DoClear;
var
  I: LongInt;
begin
  for I := 0 to FCount - 1 do
    TObject(FArray[I]).Free;
  inherited DoClear;
end;

function TctsThreadVector.GetItems(AIndex: LongInt): TctsPoolingThread;
begin
  Result := nil;
  if not OutRange(AIndex, 0, FCount) then
    Result := FArray[AIndex];
end;

{ TctsThreadPool }

constructor TctsThreadPool.Create;
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'Create' );
{$ENDIF DEBUG}

  inherited Create;
  //FThreadLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FThreadLock := TSimpleRWSync.Create;
  FTaskQueue := TctsTaskQueue.Create;
  FThreads := TctsThreadVector.Create;
  FThreadsKilling := TctsThreadVector.Create;
  FThreadsMinCount := 0;
  FThreadsMaxCount := 10;
  FThreadDeadTimeout := 0;
  FThreadClass := TctsPoolingThread;
  FAdjustInterval := 10000;
  FMaxDeadTaskCheckCount := 50;
  FDeadTaskAsNew := True;
  FDeadCheckCount := 0;
  FMinAtLeast := False;
  FTerminateWaitTime := 10000;
  FIdleThreadCount := 0;
  FSemaphoreRequest := TJclSemaphore.Create(nil, 0, MAXLONG, '');
  FTimerReduce := TJclWaitableTimer.Create(nil, False, '');
  FTimerReduce.SetTimer(-1, FAdjustInterval, False);
{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'Create' );
{$ENDIF}
end;

constructor TctsThreadPool.CreateSpecial(AClass: TctsPoolingThreadClass);
begin
  Create;
  if AClass <> nil then
    FThreadClass := AClass;
end;

destructor TctsThreadPool.Destroy;
var
  I, N: LongInt;
  Thread: TctsPoolingThread;
  Handles: array of THandle;
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'Destroy' );
{$ENDIF DEBUG}

  with FThreads, FThreadLock do
  begin
    BeginWrite;
    try
      if FCount > 0 then
      begin
        SetLength(Handles, FCount);
        N := 0;
        for I := 0 to FCount - 1 do
        begin
          Thread := FArray[I];
          if Thread <> nil then
          begin
            Handles[N] := Thread.Handle;
            Thread.Terminate(False);
            Inc(N);
          end;
        end;
        WaitForMultipleObjects(N, @Handles[0], True, FTerminateWaitTime);
      end;
      FThreads.Free;
      FThreadsKilling.Free;
    finally
      FThreadLock.EndWrite;
      FThreadLock := nil;
    end;
  end;
  FTaskQueue.Free;
  FSemaphoreRequest.Free;
  FTimerReduce.Free;
  inherited Destroy;
  
{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'Destroy' );
{$ENDIF}
end;

function TctsThreadPool.AddRequest(aTaskData: IctsTaskData; CheckDuplicate: TCheckDuplicates = [cdQueue]): Boolean;
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'AddRequest' );
{$ENDIF}  

  Result := False;
  if aTaskData = nil then
    Exit;

{$IFDEF DEBUG}
  CodeSite.Send('AddRequest:' + aTaskData.Info);
{$ENDIF DEBUG}

  if ((cdQueue in CheckDuplicate) and FTaskQueue.Duplicate(aTaskData)) or
     ((cdProcessing in CheckDuplicate) and DuplicateInThreads(aTaskData)) then Exit;

  FTaskQueue.Add(aTaskData);
  IncreaseThreads;
  
{$IFDEF DEBUG}
  CodeSite.Send('FSemaphoreRequest.Release');
{$ENDIF}

  FSemaphoreRequest.Release(1);
  Result := True;

{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'AddRequest' );  
{$ENDIF DEBUG}
end;

procedure TctsThreadPool.AddRequests(const aTaskDatas: TctsTaskArray; CheckDuplicate: TCheckDuplicates = [cdQueue]);
var
  I: LongInt;
begin
  for I := Low(aTaskDatas) to High(aTaskDatas) do
    AddRequest(aTaskDatas[I], CheckDuplicate);
end;

procedure TctsThreadPool.AddThread;
{$IFDEF DEBUG}
const
  cNewThreadExceptionFormat = 'New thread Exception on %s: %s';
{$ENDIF}
begin
  try
    FThreads.DoAdd(FThreadClass.Create(Self));
  except
  {$IFDEF DEBUG}
    on E: Exception do
      CodeSite.Send(Format(cNewThreadExceptionFormat, [E.ClassName, E.Message]));
  {$ENDIF DEBUG}
  end;
end;

function TctsThreadPool.AverageProcessingTime: LongInt;
var
  I, N: LongInt;
begin
  N := FThreads.FCount;
  if N > 0 then
  begin
    Result := 0;
    for I := 0 to N - 1 do
      Inc(Result, TctsPoolingThread(FThreads.FArray[I]).AverageProcessingTime);
    Result := Result div N;
  end
  else
    Result := 20;
end;

function TctsThreadPool.AverageWaitingTime: LongInt;
var
  I, N: LongInt;
begin
  N := FThreads.FCount;
  if N > 0 then
  begin
    Result := 0;
    for I := 0 to N - 1 do
      Inc(Result, TctsPoolingThread(FThreads.FArray[I]).AverageWaitingTime);
    Result := Result div N;
  end
  else
    Result := 10;
end;

procedure TctsThreadPool.CheckTaskEmpty;
begin
  if FTaskQueue.TaskIsEmpty and (not HasProcessingThread) then
    DoTaskEmpty;
end;

procedure TctsThreadPool.CopyToKillingList(const AThread: TctsPoolingThread; const AIndex: LongInt);
begin
  AThread.Terminate(False);
  FThreadsKilling.DoAdd(AThread);
  FThreads.DoDelete(AIndex);
end;  

procedure TctsThreadPool.DecreaseThreads;
var
  I: LongInt;
  Thread: TctsPoolingThread;
  NotFinished: Boolean;
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'DecreaseThreads' );
{$ENDIF DEBUG}

  ReAddDeadRequest();
  with FThreads, FThreadLock do
    if (FCount <> 0) and not FinishedThreadsAreFull and
      BeginWrite then
      try
        NotFinished := True;
        for I := FCount - 1 downto 0 do
        begin
          Thread := FArray[I];
          if Thread.IsDead then
          begin
            {$IFDEF DEBUG}
              CodeSite.Send( 'Dead Thread' );
            {$ENDIF DEBUG}
            if FDeadTaskAsNew then
              FTaskQueue.FDeadTaskList.DoAdd(Thread.CloneData);
            CopyToKillingList(Thread, I);
          end else if Thread.IsIdle and (I >= FThreadsMinCount) and NotFinished then
          begin
            CopyToKillingList(Thread, I);
            NotFinished := False;
          end;
        end;
      finally
        EndWrite;
      end;

  FreeFinishedThreads;
    
{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'DecreaseThreads' );
{$ENDIF}  
end;

procedure TctsThreadPool.DefaultGetInfo(Sender: TctsThreadPool; var InfoText: string);
const
  cInfoFormat =
    'MinCount=%d; MaxCount=%d; AdjustInterval=%d; DeadTimeOut=%d'#13#10'' +
    'ThreadCount=%d; KillingCount=%d; SpareThreadCount=%d; TaskCount=%d; DeadTaskCount=%d; DeadCheckCount=%d'#13#10'' +
    'AverageWaitingTime=%d; AverageProcessingTime=%d'#13#10'' +
    '===============Working Threads Info===============%s'#10#13'' +
    ''#10#13'===============Killing Threads Info===============%s';
  cFormat = '%s'#13#10'%s';
var
  I: LongInt;
  sThreadInfo, sThreadKillingInfo: string;
begin
  with Sender do
  begin
    FreeFinishedThreads;

    for I := 0 to ThreadCount - 1 do
      sThreadInfo := Format(cFormat, [sThreadInfo, ThreadInfo(I)]);

    for I := 0 to ThreadKillingCount - 1 do
      sThreadKillingInfo := Format(cFormat, [sThreadKillingInfo, ThreadKillingInfo(I)]);
      
    InfoText := Format(cInfoFormat,
      [ThreadsMinCount, ThreadsMaxCount, AdjustInterval, ThreadDeadTimeout,
       ThreadCount, ThreadKillingCount, FIdleThreadCount, FTaskQueue.FTaskCount,
       FTaskQueue.FDeadTaskList.FCount, FDeadCheckCount,
       AverageWaitingTime, AverageProcessingTime, sThreadInfo, sThreadKillingInfo]);
  end;
end;

procedure TctsThreadPool.DoProcessRequest(aTaskData: IctsTaskData; aThread: TctsPoolingThread);
begin
  if Assigned(FProcessRequest) then
    FProcessRequest(Self, aTaskData, aThread);
end;

procedure TctsThreadPool.DoTaskEmpty;
begin
  if Assigned(FOnTaskEmpty) then
  begin
    FThreadLock.BeginRead;
    try
      FOnTaskEmpty(Self);
    finally
      FThreadLock.EndRead;
    end;
  end;
end;

procedure TctsThreadPool.DoThreadFinalizing(aThread: TctsPoolingThread);
begin
  if Assigned(FThreadFinalizing) then
    FThreadFinalizing(Self, aThread);
end;

procedure TctsThreadPool.DoThreadInitializing(aThread: TctsPoolingThread);
begin
  if Assigned(FThreadInitializing) then
    FThreadInitializing(Self, aThread);
end;

function TctsThreadPool.DuplicateInThreads(aTaskData: IctsTaskData): Boolean;
var
  I: LongInt;
  Thread: TctsPoolingThread;
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'DuplicateInThreads' );
{$ENDIF}

  Result := False;
  with FThreads, FThreadLock do
    if FCount <> 0 then
    begin
      BeginRead;
      try
        for I := 0 to FCount - 1 do
        begin
          Thread := FThreads.FArray[I];
          if Thread.Duplicate(aTaskData) then
          begin
          {$IFDEF DEBUG}
            CodeSite.Send('Duplicate:' + Thread.FProcessingData.Info);
          {$ENDIF DEBUG}
            Result := True;
            aTaskData := nil;
            Break;
          end;
        end;
      finally
        EndRead;
      end;
    end;

{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'DuplicateInThreads' );
{$ENDIF}
end;

function TctsThreadPool.FinishedThreadsAreFull: Boolean;
begin
  FThreadLock.BeginRead;
  try
    if FThreadsMaxCount > 0 then
      Result := FThreadsKilling.FCount >= FThreadsMaxCount div 2
    else
      Result := FThreadsKilling.FCount >= 50;
  finally
    FThreadLock.EndRead;
  end;
end;

procedure TctsThreadPool.FreeFinishedThreads;
var
  I: LongInt;
  Thread: TctsPoolingThread;
begin
  with FThreadsKilling, FThreadLock do
    if (FCount <> 0) and
      BeginWrite then
      try
        for I := FCount - 1 downto 0 do
        begin
          Thread := FArray[I];
          if Thread.IsFinished then
          begin
            Thread.Free;
            DoDelete(I);
          end;
        end;
      finally
        EndWrite;
      end;
end;

function TctsThreadPool.HasProcessingThread: Boolean;
var
  I: LongInt;
begin
  Result := False;
  if FThreads.FCount = 0 then
    Exit;
  FThreadLock.BeginRead;
  try
    for I := 0 to FThreads.FCount - 1 do
      if TctsPoolingThread(FThreads.FArray[I]).FCurState in [ctsProcessing] then
      begin
        Result := True;
        Break;
      end;
  finally
    FThreadLock.EndRead;
  end;
end;

function TctsThreadPool.HasSpareThread: Boolean;
begin
  Result := FIdleThreadCount > 0;
end;

function TctsThreadPool.HasThread: Boolean;
begin
  Result := FThreads.FCount > 0;
end;

procedure TctsThreadPool.IncreaseThreads;
{$IFDEF DEBUG}
const
  cIncreaseThreadsFormat = 'IncreaseThreads: %s';
{$ENDIF}
var
  I, iAvgWait, iAvgProc: LongInt;
  Thread: TctsPoolingThread;
begin
{$IFDEF DEBUG}
  CodeSite.EnterMethod( Self, 'IncreaseThreads' );
{$ENDIF}

  with FThreads, FThreadLock do
  begin
    BeginWrite;
    try
      if not FinishedThreadsAreFull then
        for I := FCount - 1 downto 0 do
        begin
          Thread := FArray[I];
          if Thread.IsDead then
          begin
            if FDeadTaskAsNew then
              FTaskQueue.FDeadTaskList.DoAdd(Thread.CloneData);
            CopyToKillingList(Thread, I);
          end;
        end;

      if FCount <= FThreadsMinCount then
      begin
      {$IFDEF DEBUG}
        CodeSite.Send(Format(cIncreaseThreadsFormat, ['FThreads.FCount < FThreadsMinCount']));
      {$ENDIF DEBUG}    
        if FMinAtLeast then
          for I := FCount to FThreadsMinCount - 1 do
            AddThread()
        else
          AddThread();
      end
      else if (FCount < FThreadsMaxCount) and FTaskQueue.HasTask and not HasSpareThread then
      begin
      {$IFDEF DEBUG}
        CodeSite.Send(Format(cIncreaseThreadsFormat, ['FThreads.FCount < FThreadsMaxCount']));
      {$ENDIF DEBUG}
        iAvgWait := Max(AverageWaitingTime, 1);
        if iAvgWait <= 100 then
        begin
          iAvgProc := Max(AverageProcessingTime, 2);
        {$IFDEF DEBUG}
          CodeSite.Send(Format('ThreadCount(%D); ThreadsMaxCount(%D); AvgWait(%D); AvgProc(%D); Killing(%D)',
            [FCount, FThreadsMaxCount, iAvgWait, iAvgProc, ThreadKillingCount]));
        {$ENDIF DEBUG}
          if ((iAvgProc + iAvgWait) * FTaskQueue.FTaskCount > iAvgProc * FCount) then
            AddThread();
        end;
      end;
    finally
      EndWrite;
    end;
  end;

{$IFDEF DEBUG}
  CodeSite.ExitMethod( Self, 'IncreaseThreads' );
{$ENDIF}
end;

function TctsThreadPool.Info: string;
begin
  FThreadLock.BeginRead;
  try
    if Assigned(FGetInfo) then
      FGetInfo(Self, Result)
    else
      DefaultGetInfo(Self, Result)
  finally
    FThreadLock.EndRead;
  end;
end;

procedure TctsThreadPool.ReAddDeadRequest;
var
  I: LongInt;
begin
  with FTaskQueue.FDeadTaskList do
  begin
    if FCount = 0 then
      Exit;
    I := FCount - 1;
    AddRequest(FArray[I] as IctsTaskData);
    DoDelete(I);
  end;
end;

procedure TctsThreadPool.RemoveRequest(aTaskData: IctsTaskData);
begin
  FTaskQueue.Remove(aTaskData);
end;

procedure TctsThreadPool.SetAdjustInterval(const Value: LongWord);
begin
  FAdjustInterval := Value;
  if FTimerReduce <> nil then
    FTimerReduce.SetTimer(-1, Value, False);
end;

procedure TctsThreadPool.TerminateAllThread(const AForce: Boolean = False);
var
  I: LongInt;
  Thread: TctsPoolingThread;
begin
  with FThreads, FThreadLock do
  begin
    BeginWrite;
    try
      if FCount > 0 then
        for I := 0 to FCount - 1 do
        begin
          Thread := FArray[I];
          if Thread <> nil then
            Thread.Terminate(AForce);
        end;
      FThreads.Free;
      FThreadsKilling.Free;
    finally
      FThreadLock.EndWrite;
    end;
  end;    
end;

function TctsThreadPool.ThreadCount: LongInt;
begin
  FThreadLock.BeginRead;
  try
    Result := FThreads.FCount;
  finally
    FThreadLock.EndRead;
  end;
end;

function TctsThreadPool.ThreadInfo(const I: LongInt): string;
begin
  Result := '';
  FThreadLock.BeginRead;
  try
    if I < FThreads.FCount then
      Result := FThreads[I].Info;
  finally
    FThreadLock.EndRead;
  end;
end;

function TctsThreadPool.ThreadKillingCount: LongInt;
begin
  FThreadLock.BeginRead;
  try
    Result := FThreadsKilling.FCount;
  finally
    FThreadLock.EndRead;
  end;
end;

function TctsThreadPool.ThreadKillingInfo(const I: LongInt): string;
begin
  Result := '';
  FThreadLock.BeginRead;
  try
    if I < FThreadsKilling.FCount then
      Result := FThreadsKilling[I].Info;
  finally
    FThreadLock.EndRead;
  end;
end;

end.
