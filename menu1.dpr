program menu1;

uses
  Forms,
  Unit1menu in 'Unit1menu.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
