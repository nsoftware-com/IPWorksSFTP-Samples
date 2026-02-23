unit sftpdialogf;

interface

uses
{$IFDEF LINUX}
  QForms, QStdCtrls, Classes, QControls, StdCtrls, Controls;
{$ELSE}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;
{$ENDIF}

type
  TFormSftpdialog = class(TForm)
    ButtonOk: TButton;
    ButtonCancel: TButton;
    LabelWhat: TLabel;
    EditLine: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSftpdialog: TFormSftpdialog;

implementation

{$R *.dfm}

end.
