unit sftploginf;

interface

uses
{$IFDEF LINUX}
  QForms, QExtCtrls, QStdCtrls, QControls, Classes, QComCtrls,
  StdCtrls, Controls;
{$ELSE}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;
{$ENDIF}

type
  TFormSftplogin = class(TForm)
    Label1: TLabel;
    EditHostName: TEdit;
    EditUser: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    EditPassword: TEdit;
    ButtonOk: TButton;
    ButtonCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSftplogin: TFormSftplogin;

implementation

{$R *.dfm}

end.
