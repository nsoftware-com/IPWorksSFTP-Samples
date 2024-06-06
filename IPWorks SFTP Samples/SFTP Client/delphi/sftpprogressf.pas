unit sftpprogressf;

interface

uses
{$IFDEF LINUX}
  QForms, QStdCtrls, Classes, QControls, Controls,
  StdCtrls, ComCtrls;
{$ELSE}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ipfcore, ipftypes, ipfsftpclient;
{$ENDIF}

type
  TFormSftpprogress = class(TForm)
    ButtonCancel: TButton;
    //ProgressBar1: TProgressBar;
    LabelUpDown: TLabel;
    ProgressBar1: TProgressBar;
    procedure ButtonCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
   FormSftpprogress: TFormSftpprogress;

implementation

uses sftpf;

{$R *.dfm}

procedure TFormSftpprogress.ButtonCancelClick(Sender: TObject);
begin
   try
      FormSftp.SFTP1.Interrupt;
   except on E: Exception do
      FormSftp.UpdateNotes(E.Message);
   end;
end;

end.
