program rb_tree;

uses
  Forms,
  test_tree in 'test_tree.pas' {Form1},
  ctsStrMap in '..\..\sources\ctsStrMap.pas',
  ctsStrMapInterface in '..\..\sources\ctsStrMapInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
