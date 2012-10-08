{$MINSTACKSIZE $00010000}
{$MAXSTACKSIZE $00400000}

program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmTest};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
