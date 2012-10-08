program ThreadPoolTest;

uses
  FastMM4,
  FastCode,
  Forms,
  uTestFrm in 'uTestFrm.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
