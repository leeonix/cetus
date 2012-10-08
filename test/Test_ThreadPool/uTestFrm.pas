unit uTestFrm;

{
  The sample of using TctsThreadPool.
  uses memo.lines as a source of request and
  MessageBox procedure as processing
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ctsCommons, ctsThreads, StdCtrls, ExtCtrls;

const
  WM_U_EMPTY = WM_USER + 1;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Memo2: TMemo;
    Timer1: TTimer;
    btnFreeThreadPool: TButton;
    procedure Button1Click(Sender: TObject);
    procedure btnFreeThreadPoolClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FThreadPool: TctsThreadPool;
    procedure PoolEmpty(var Msg: TMessage); message WM_U_EMPTY;
  public
    procedure FThreadPoolProcessRequest(Sender: TctsThreadPool; aDataObj: IctsTaskData; aThread: TctsPoolingThread);
    procedure FThreadPoolQueueEmpty(Sender: TctsTaskQueue);
    procedure FThreadPoolTaskEmpty(Sender: TctsThreadPool);
  end;

var
  Form1: TForm1;

implementation

//uses
//  FileCtrl;

{$R *.DFM}

type
  IMyDo = interface(IctsTaskData)
    ['{45A89C0E-4ADC-4112-A1EE-2F195018FBD1}']
    function GetStr: string;
    procedure SetStr(const Value: string);
    property Str: string read GetStr write SetStr;
  end;
  
  TMyDO = class(TctsTaskData, IMyDo)
  protected
    FStr: string;
    function GetStr: string;
    procedure SetStr(const Value: string);
  public
    function Clone: IctsTaskData; override;
    function Duplicate(DataObj: IctsTaskData; const Processing: Boolean): Boolean; override;    
    constructor Create(const s: string);
    function Info: string; override;
  end;


{ TMyDO }

function TMyDO.Clone: IctsTaskData;
begin
  Result := Self;
end;

constructor TMyDO.Create(const s: string);
begin
  FStr := s;
end;

function TMyDO.Duplicate(DataObj: IctsTaskData; const Processing: Boolean): Boolean;
begin
  Result := inherited Duplicate(DataObj, Processing);
//  Result := Self.Str = TMyDO(DataObj).Str;
end;

function TMyDO.GetStr: string;
begin
  Result := FStr;
end;

function TMyDO.Info: string;
begin
  Result := 'Request: "' + FStr + '"';
end;

procedure TMyDO.SetStr(const Value: string);
begin
  FStr := Value;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  s: string;
  i: Integer;
begin
  for i := 0 to Memo1.Lines.Count - 1 do
  begin
    s := Trim(Memo1.Lines[i]);
    if s <> '' then
    begin
      FThreadPool.AddRequest(TMyDO.Create(s), [cdQueue, cdProcessing]);
    end;
  end;
end;

var
  CurFileHandle: THandle;
  FileOpenDay: Integer;
  csLog: TRTLCriticalSection;

procedure LogMessage(const Str: string; const LogID: Integer);
var
  Msg: string;
  Buf: array[0..MAX_PATH] of Char;
  CurFileName: string;
  CurDay: Integer;
  n: Cardinal;
const
  sMsgLevelMarkers: array[0..10] of string =
    ('', '', 't:', 'i:', 'I:', 'w:', 'W:',
    'e:', 'E:', 'Error:', '!!! Fatal error !!!: ');
begin
  EnterCriticalSection(csLog);
  try
    CurDay := trunc(Date);
    if CurDay > FileOpenDay then // It's a time to switch to other log file
    begin
      if CurFileHandle <> INVALID_HANDLE_VALUE then
        CloseHandle(CurFileHandle);

      GetModuleFileName(HInstance, Buf, SizeOf(Buf));

      CurFileName := ExtractFilePath(Buf) + 'Logs\' + ExtractFileName(Buf) + FormatDateTime('YYYY_MM_DD', Date) + '.log';
      ForceDirectories(ExtractFilePath(CurFileName));

      CurFileHandle := CreateFile(PChar(CurFileName), GENERIC_WRITE, FILE_SHARE_READ,
        nil, OPEN_ALWAYS, FILE_FLAG_WRITE_THROUGH or FILE_FLAG_SEQUENTIAL_SCAN, 0);

      if CurFileHandle <> INVALID_HANDLE_VALUE then
        SetFilePointer(CurFileHandle, 0, nil, FILE_END);
      FileOpenDay := CurDay;
    end;

    if CurFileHandle = INVALID_HANDLE_VALUE then
      Exit;

  finally
    LeaveCriticalSection(csLog);
  end;

  Msg := Format('(%5d) ', [GetCurrentThreadId]) + FormatDateTime('HH:NN:SS: ', Now) + Str + #13#10;
  WriteFile(CurFileHandle, Msg[1], Length(Msg), n, nil);
end;

procedure TForm1.btnFreeThreadPoolClick(Sender: TObject);
begin
  Timer1.Enabled := False;
  CloseHandle(CurFileHandle);
  FThreadPool.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FThreadPool := TctsThreadPool.Create;
  TraceLog := LogMessage;
  FThreadPool.ThreadsMinCount := 5;
  FThreadPool.ThreadsMaxCount := 10;
//  FThreadPool.MinAtLeast := True;
  FThreadPool.OnProcessRequest := FThreadPoolProcessRequest;
  FThreadPool.OnTaskEmpty := FThreadPoolTaskEmpty;
  FThreadPool.TaskQueue.OnQueueEmpty := FThreadPoolQueueEmpty;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CloseHandle(CurFileHandle);
  FThreadPool.Free;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  s: string;
begin
  s := FThreadPool.Info;
  if s <> Memo2.Lines.Text then
    Memo2.Lines.Text := s;
end;

procedure TForm1.FThreadPoolProcessRequest(Sender: TctsThreadPool; aDataObj: IctsTaskData; aThread: TctsPoolingThread);
begin
  MessageBox(0, PChar((aDataObj as IMyDO).Str), PChar(Format('ThreadID=%d', [GetCurrentThreadId])), 0);
end;

procedure TForm1.FThreadPoolQueueEmpty(Sender: TctsTaskQueue);
begin
  PostMessage(Handle, WM_U_EMPTY, 1, integer(Sender));
end;

procedure TForm1.FThreadPoolTaskEmpty(Sender: TctsThreadPool);
begin
  PostMessage(Handle, WM_U_EMPTY, 2, integer(Sender));
end;

procedure TForm1.PoolEmpty(var Msg: TMessage);
begin
  case Msg.wParam of
    1:
      ShowMessage('ThreadPoolEvent: The queue is empty');
    2:
      ShowMessage('ThreadPoolEvent: Processing finished');
  end;
end;

initialization
  InitializeCriticalSection(csLog);

finalization
  DeleteCriticalSection(csLog);
end.




