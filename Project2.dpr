program Project2;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmNsisVerify};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmNsisVerify, frmNsisVerify);
  Application.Run;
end.
