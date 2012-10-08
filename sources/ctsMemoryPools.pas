{$I CetusOptions.inc}

unit ctsMemoryPools;

interface

uses
  ctsTypesDef,
  ctsBaseInterfaces,
  ctsBaseClasses;

type
  //& 轻型内存池，空闲内存没有大小限制。
  TctsMiniMemoryPool = class(TctsNamedClass, IctsMemoryPool)
  private
    FBlockSize: LongWord;
    FBlockStack: Pointer;
    FNodeQuantity: LongWord;
    FNodeSize: LongWord;
    FNodeStack: Pointer;
  protected
    procedure GrowStack;
  public
    constructor Create; overload;
    constructor Create(const ANodeSize: LongWord; const ANodeQuantity: LongWord = ctsDefaultNodeQuantity); overload;
    destructor Destroy; override;
    procedure Delete(ANode: Pointer);
    function New: Pointer;
    function NewClear: Pointer;
  end;

implementation

type
  PPoolNode = ^TPoolNode;
  TPoolNode = record
    Link: PPoolNode;
  end;

constructor TctsMiniMemoryPool.Create;
begin
  inherited Create;
  Create(SizeOf(Pointer));
end;

constructor TctsMiniMemoryPool.Create(const ANodeSize: LongWord; const ANodeQuantity: LongWord = ctsDefaultNodeQuantity);
begin
  inherited Create;
  FNodeSize := ANodeSize;
  FNodeQuantity := ANodeQuantity;
  FBlockSize := ANodeQuantity * ANodeSize + SizeOf(Pointer);
end;

destructor TctsMiniMemoryPool.Destroy;
var
  P: Pointer;
begin
  while (FBlockStack <> nil) do
  begin
    P := PPoolNode(FBlockStack)^.Link;
    FreeMem(FBlockStack, FBlockSize);
    FBlockStack := P;
  end;
  inherited Destroy;
end;

procedure TctsMiniMemoryPool.Delete(ANode: Pointer);
begin
  if ANode <> nil then
  begin
{$IFDEF DEBUG}
    FillChar(ANode^, FNodeSize, ctsDebugSign);
{$ENDIF}
    PPoolNode(ANode)^.Link := FNodeStack;
    FNodeStack := ANode;
  end;
end;

procedure TctsMiniMemoryPool.GrowStack;
var
  NewBlock: PAnsiChar;
  Temp: Pointer;
  I: LongInt;
begin
  GetMem(NewBlock, FBlockSize);
  PPoolNode(NewBlock)^.Link := FBlockStack;
  FBlockStack := NewBlock;
  Inc(NewBlock, SizeOf(Pointer));

  Temp := FNodeStack;
  for I := 1 to FNodeQuantity do
  begin
    PPoolNode(NewBlock)^.Link := Temp;
    Temp := NewBlock;
    Inc(NewBlock, FNodeSize);
  end;
  FNodeStack := Temp;
end;

function TctsMiniMemoryPool.New: Pointer;
begin
  if (FNodeStack = nil) then
    GrowStack;
  Result := FNodeStack;
  FNodeStack := PPoolNode(Result)^.Link;
end;

function TctsMiniMemoryPool.NewClear: Pointer;
begin
  if (FNodeStack = nil) then
    GrowStack;
  Result := FNodeStack;
  FNodeStack := PPoolNode(Result)^.Link;
  FillChar(Result^, FNodeSize, 0);
end;

end.
