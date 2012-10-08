unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ctsThreads, ctsSyncObjects,
  ExtCtrls, IdBaseComponent, IdComponent, IdTCPServer, IdTCPClient,
  StdCtrls, Buttons;

type
  TfrmTest = class(TForm)
    btn1: TButton;
    edt1: TEdit;
    lbl1: TLabel;
    mmo1: TMemo;
    btn2: TButton;
    edt2: TComboBox;
    lbl2: TLabel;
    rg1: TRadioGroup;
    edt3: TEdit;
    mmo2: TMemo;
    IdTCPServer1: TIdTCPServer;
    lbl3: TLabel;
    edt4: TEdit;
    tmr1: TTimer;
    btn3: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure IdTCPServer1Execute(AThread: TIdPeerThread);
    procedure edt1Change(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
  private
    { Private declarations }
    PoolSend: TctsThreadPool;
    RecivedCount: Integer;
    SendCount, ProcessCount: Integer;
    Sending: Boolean;
    iSendInterval: Integer;
    csReciver: TctsCriticalSection;
    sReadLn: string;

    procedure SeparateHostAndPort(const s: string; var host: string; var port: Integer);
    procedure Updatemmo1;
    procedure ProcessRequest(Sender: TctsThreadPool; aDataObj: IctsTaskData; aThread: TctsPoolingThread);
  public
    { Public declarations }
  end;

var
  frmTest: TfrmTest;
  GetData: Boolean = False;

implementation

uses StrUtils, IdSocketHandle, CodeSiteLogging;

{$R *.DFM}

procedure Delay(const i: DWORD);
var
  t: DWORD;
begin
  t := GetTickCount;
  while (not Application.Terminated) and (GetTickCount - t < i) do
    Application.ProcessMessages
end;

type
  ISendData = interface(IctsTaskData)
    ['{F603834E-BAD6-4DD9-AADB-9E6D23F9E224}']
    function GetCanMerge: Boolean;
    function GetHost: string;
    function GetMsg: string;
    function GetPort: Integer;
    procedure SetCanMerge(const Value: Boolean);
    procedure SetHost(const Value: string);
    procedure SetMsg(const Value: string);
    procedure SetPort(const Value: Integer);
    property CanMerge: Boolean read GetCanMerge write SetCanMerge;
    property Host: string read GetHost write SetHost;
    property Msg: string read GetMsg write SetMsg;
    property Port: Integer read GetPort write SetPort;
  end;

  TSendData = class(TctsTaskData, ISendData)
  private
    FCanMerge: Boolean;
    FHost: string;
    FMsg: string;
    FPort: Integer;
    function GetCanMerge: Boolean;
    function GetHost: string;
    function GetMsg: string;
    function GetPort: Integer;
    procedure SetCanMerge(const Value: Boolean);
    procedure SetHost(const Value: string);
    procedure SetMsg(const Value: string);
    procedure SetPort(const Value: Integer);
  public
    constructor Create(const ahost: string; aport: Integer; amsg: string; amerge: Boolean);
    function Clone: IctsTaskData; override;
    function Duplicate(aTaskData: IctsTaskData; const Processing: Boolean): Boolean; override;
    function Info: string; override;
    property CanMerge: Boolean read GetCanMerge write SetCanMerge;
    property Host: string read GetHost write SetHost;
    property Msg: string read GetMsg write SetMsg;
    property Port: Integer read GetPort write SetPort;
  end;

  TSendThread = class(TctsPoolingThread)
  private
    FIdTCPClient: TIdTCPClient;
  public
    constructor Create(aPool: TctsThreadPool); override;
    destructor Destroy; override;
  end;

constructor TSendData.Create(const ahost: string; aport: Integer; amsg: string; amerge: Boolean);
begin
  FHost := ahost;
  FPort := aport;
  FMsg := amsg;
  FCanMerge := amerge;
end;

{ TSendData }

function TSendData.Clone: IctsTaskData;
begin
  Result := TSendData.Create(FHost, FPort, FMsg, FCanMerge);
end;

function TSendData.Duplicate(aTaskData: IctsTaskData; const Processing: Boolean): Boolean;
var
  sData: ISendData;
begin
  sData := aTaskData as ISendData;
  Result := (not Processing) and FCanMerge and sData.CanMerge and (FHost = sData.Host) and (FPort = sData.Port);
  if Result then
    sData.Msg := sData.Msg + '#' + Msg
end;

function TSendData.GetCanMerge: Boolean;
begin
  Result := FCanMerge;
end;

function TSendData.GetHost: string;
begin
  Result := FHost;
end;

function TSendData.GetMsg: string;
begin
  Result := FMsg;
end;

function TSendData.GetPort: Integer;
begin
  Result := FPort;
end;

function TSendData.Info: string;
begin
  Result := 'IP=' + FHost + ':' + IntToStr(FPort) + ';Len(Msg)=' + IntToStr(Length(FMsg));
  if FCanMerge then
    Result := Result + ';Can Merge'
end;

procedure TSendData.SetCanMerge(const Value: Boolean);
begin
  FCanMerge := Value;
end;

procedure TSendData.SetHost(const Value: string);
begin
  FHost := Value;
end;

procedure TSendData.SetMsg(const Value: string);
begin
  FMsg := Value;
end;

procedure TSendData.SetPort(const Value: Integer);
begin
  FPort := Value;
end;

{ TSendThread }

constructor TSendThread.Create(aPool: TctsThreadPool);
begin
  OutputDebugString('TSendThread.Create');
  inherited;
  FIdTCPClient := TIdTCPClient.Create(nil)
end;

destructor TSendThread.Destroy;
begin
  FIdTCPClient.Disconnect;
  FIdTCPClient.Free;
  inherited;
  OutputDebugString('TSendThread.Destroy');
end;

{ TfrmTest }

procedure TfrmTest.SeparateHostAndPort(const s: string; var host: string; var port: Integer);
var
  i: Integer;
begin
  i := Pos(':', s);
  if i > 0 then
  begin
    host := Copy(s, 1, i - 1);
    port := StrToIntDef(Copy(s, i + 1, MaxInt), IdTCPServer1.DefaultPort)
  end
  else
  begin
    host := s;
    port := IdTCPServer1.DefaultPort
  end
end;

procedure TfrmTest.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to ControlCount - 1 do
    if Controls[i] is TMemo then
      TMemo(Controls[i]).Clear;
  csReciver := TctsCriticalSection.Create;
  PoolSend := TctsThreadPool.CreateSpecial(TSendThread);
  with PoolSend do
  begin
    OnProcessRequest := ProcessRequest;
    AdjustInterval := 5 * 1000;
    MinAtLeast := True;
    ThreadDeadTimeout := 10 * 1000;
    ThreadsMinCount := 30;
    ThreadsMaxCount := 200;
    TerminateWaitTime := 2 * 1000;
    DeadTaskAsNew := False;
  end;
  RecivedCount := 0;
  SendCount := 0;
  ProcessCount := 0;
  IdTCPServer1.DefaultPort := StrToIntDef(edt1.Text, 5999);
  iSendInterval := StrToIntDef(edt4.Text, 5999)
end;

procedure TfrmTest.IdTCPServer1Execute(AThread: TIdPeerThread);
begin
  sReadLn := AThread.Connection.ReadLn();
  if sReadLn = 'getdata' then
  begin
    AThread.Connection.WriteLn('data');
    AThread.Synchronize(Updatemmo1);
  end;
end;

procedure TfrmTest.edt1Change(Sender: TObject);
var
  i, port, newport: Integer;
  host, s: string;
begin
  if not IdTCPServer1.Active then
  begin
    newport := StrToIntDef(edt1.Text, IdTCPServer1.DefaultPort);
    IdTCPServer1.DefaultPort := newport;
    edt1.Text := IntToStr(newport);
    SeparateHostAndPort(edt2.Text, host, port);
    s := host + ':' + IntToStr(newport);
    for i := 0 to edt2.Items.Count - 1 do
    begin
      SeparateHostAndPort(edt2.Items.Strings[i], host, port);
      edt2.Items.Strings[i] := host + ':' + IntToStr(newport)
    end;
    edt2.Text := s
  end
  else
    edt1.Text := IntToStr(IdTCPServer1.DefaultPort)
end;

procedure TfrmTest.btn2Click(Sender: TObject);
const
  cHostFormat = '192.168.1.%d';
var
  i,j: Integer;
  host: string;
  port: Integer;
begin
  Sending := not Sending;
  btn2.Caption := IfThen(Sending, 'ֹͣ����', '��ʼ����' + IntToStr(SendCount));
  if Sending then
  begin
    iSendInterval := StrToIntDef(edt4.Text, iSendInterval);
    SendCount := 0;
    ProcessCount := 0;
    j := 80;
    while Sending and not Application.Terminated and (j < 256) do
    begin
      Inc(j);
      host := Format(cHostFormat, [j]);
      port := 5999;
      //SeparateHostAndPort(edt2.Text, host, port);
      PoolSend.AddRequest(TSendData.Create(host, port, edt3.Text, rg1.ItemIndex = 0), [cdQueue,cdProcessing]);
      Inc(SendCount);
      btn2.Caption := 'ֹͣ����' + IntToStr(SendCount);
      case iSendInterval of
        0..5:
        begin
          Application.ProcessMessages
        end;
        6..10:
        begin
          Sleep(iSendInterval);
          Application.ProcessMessages
        end;
        11..50:
        begin
          Sleep(iSendInterval div 2);
          Delay(iSendInterval div 2)
        end;
        else
          for i := 0 to iSendInterval div 50 - 1 do
          begin
            Sleep(10);
            Delay(40)
          end
      end;
    end
  end
end;

procedure TfrmTest.btn1Click(Sender: TObject);
begin
  RecivedCount := 0;
  if not IdTCPServer1.Active then
  begin
    IdTCPServer1.Bindings.Clear;
    with IdTCPServer1.Bindings.Add do
    begin
      IP := '0.0.0.0'; //'127.0.0.1';
      Port := IdTCPServer1.DefaultPort
    end
  end;
  IdTCPServer1.Active := not IdTCPServer1.Active;
  btn1.Caption := IfThen(IdTCPServer1.Active, 'ֹͣ����' + IntToStr(IdTCPServer1.DefaultPort), '��ʼ����')
end;

procedure TfrmTest.tmr1Timer(Sender: TObject);
begin
  if PoolSend <> nil then
  begin
    mmo2.Text := PoolSend.Info;
    if GetData then
    begin
      PoolSend.TerminateAllThread();
      tmr1.Enabled := False;
      OutputDebugString('BeginFreePool');
      PoolSend.Free;
      OutputDebugString('EndFreePool');
    end;
  end;
end;

procedure TfrmTest.ProcessRequest(Sender: TctsThreadPool; aDataObj: IctsTaskData; aThread: TctsPoolingThread);
var
  d: ISendData;
  t: TSendThread;
  s: string;
begin
  d := aDataObj as ISendData;
  t := TSendThread(aThread);
  if (d = nil) or (t = nil) then
    Exit;

  Inc(ProcessCount);
  //OutputDebugString(PChar('ProcessRequest: ' + IntToStr(ProcessCount)));
  t.FIdTCPClient.Host := d.Host;
  t.FIdTCPClient.Port := d.Port;
  if t.FIdTCPClient.Connected then
    t.FIdTCPClient.Disconnect;
  try
    try
      t.FIdTCPClient.Connect();
      if d.Msg <> '' then
        t.FIdTCPClient.WriteLn(d.Msg)
      else
        Sleep(1000);
      if t.FIdTCPClient.Connected then
      begin
        s := t.FIdTCPClient.ReadLn();
        edt3.Text := s;
        GetData := True;
      end;
    finally
      if t.FIdTCPClient.Connected then
        t.FIdTCPClient.Disconnect
    end;
  except
  end;
  //Sleep(10)
end;

procedure TfrmTest.FormDestroy(Sender: TObject);
begin
  PoolSend.Free;
  csReciver.Free;
end;

procedure TfrmTest.Updatemmo1;
begin
  Inc(RecivedCount);
  mmo1.Lines.Add(IntToStr(RecivedCount) + ':' + sReadln)
end;

procedure TfrmTest.btn3Click(Sender: TObject);
begin
  Application.MessageBox(
    '====˵��====' + #13#10 +
    '  ���̳߳���Windowsƽ̨�й�������Win9xƽ̨�в��ܶ�̬�����߳�������NT�ܹ�ƽ̨���ܹ�����ѵı��֡�' + #13#10 + #13#10 +
    '====����====' + #13#10 + 
    '  ����ʼ��������ť�������ǰ�������ĳ���˿ڣ������˸ü����������IP����127.0.0.1�ȣ������Ҫ�����̳߳ط��͵�TCP��Ϣ���Ϳ�����Ŀ�������ϵ���ð�ť���ٴε���ð�ťȡ��������' + #13#10 +
    '  ����ʼ������������ı������ʾ�յ���TCP��Ϣ������Indy��TIdTCPServer��ʵ�ֻ������ƣ��������߷��͵�Ƶ�ʺܴ�ʱ�����ܻᵼ�¼��������������ܶ���̣߳���Ϊ���ܹ���������ȷ����ʾ�յ�����Ϣ������ʹ����ͬ����' + '����ȴ��߳�̫��ʱ�����ܻᵼ��TIdTCPServer���ܼ���������' + #13#10 +
    '  ����ʼ���͡�����ÿ��һ��ʱ�䲻�ϵ���Ŀ���ַ����TCP��Ϣ���ٴε��ֹͣ���͡�' + #13#10 +
    '  ������ѡ��-��ƴ�ϡ���ʾ�µ�TCP��Ϣ����������е���Ϣ����ƴ�ϴ���������Ԥ����֮���̳߳ؽ����и��õ���չ�ԡ�' + #13#10 +
    '  ������ѡ��-����ƴ�ϡ���ʾ�µ�TCP��Ϣ���������Ϣ�޷�ƴ�ϡ�' + #13#10 +
    '  ������ѡ��µ��ı���Ϊ�����͵����ݣ���������˷���ƴ�ϣ���ƴ�ϵ�TCP��Ϣ�ķ�������ͨ��#�ָ���' + #13#10 +
    '  ��������ı���ÿ��һ��ˢ��һ���̳߳ص�����״̬��' + #13#10 + #13#10 +
    '====����====' + #13#10 + 
    '  ����ͨѶ�кܶ������Σ����͵��У�ͨ����IP�����޼�����IP�����ڡ���������������Ҫ�Ĺ���ʱ��Ҳ��ͬ��ͨ���������¿���ֻҪ������Ϳ������һ��ͨ�ţ���IP�����޼���������һ����Ҫ���ٺ��뵽����֮�䣬IP�����ڿ�����Ҫ��ʮ�롣' + '���ǱȽϸ��ӵ�ʵ�����ε�ģ�⣬Ӧ�ÿ��Դ���ʵ�ʵ�Ӧ�á�' + #13#10 +
    '  ͨ���Ĳ��ԣ���Ŀ�������ϵ������ʼ������������ʹ��ͬһ������������ͼ��������ʼ���͡��������ͼ����Сʱ��������˿�ƴ��ѡ��һ��Ҳֻ��Ҫһ�������̣߳�����ʹ����ƴ��Ҳ�����кܶ���̣߳�Ϊ�����ӹ���ʱ�䣬�����߳���Sleep(10)����' + '�ڲ���ƴ���´ﵽƽ��ʱ�л�������ƴ�ϡ�Ӧ��Ҳ������ٹ����̣߳���Ϊʵ���ϲ���ƴ�ϵ��߳�������������Ҫ���߳�����' + #13#10 +
    '  IP�����޼�����Ŀ��������ֹͣ���������ɡ���ʱ�򲻿�ƴ�ϵĹ����߳���Ӧ�ñȿ�ƴ������һЩ�����Ӹ�״̬ת�䵽ͨ��״̬ʱ���̳߳�Ӧ�ÿ��Զ�̬�ļ����߳�����' + #13#10 +
    '  IP�����ڣ����Ĺ���ʱ�䣬����ƴ��ʱӦ�û��кܶ���̡߳���������ʹ�ڸ�״̬��ֱ���˳�����Ҳ��Ӧ�û���ɳ�����쳣������������ʱ��Ϊ���ܹ���ʱ�˳����򣬻�ǿ����ֹ�˹����̣߳���'
    , '�̳߳ز��Է���', 0);
end;

procedure TfrmTest.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
var
  shift: TShiftState;
begin
  if ActiveControl is TCustomEdit then
  begin
    shift := KeyDataToShiftState(Msg.KeyData);
    if (ssCtrl in shift) and (Msg.CharCode = Ord('A')) then
    begin
      TCustomEdit(ActiveControl).SelectAll;
      Handled := True
    end
  end
  else if ActiveControl is TCustomCombo then
  begin
    shift := KeyDataToShiftState(Msg.KeyData);
    if (ssCtrl in shift) and (Msg.CharCode = Ord('A')) then
    begin
      TCustomCombo(ActiveControl).SelectAll;
      Handled := True
    end
  end
end;

end.

