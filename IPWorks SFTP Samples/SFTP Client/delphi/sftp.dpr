(*
 * IPWorks SFTP 2024 Delphi Edition - Sample Project
 *
 * This sample project demonstrates the usage of IPWorks SFTP in a 
 * simple, straightforward way. It is not intended to be a complete 
 * application. Error handling and other checks are simplified for clarity.
 *
 * www.nsoftware.com/ipworkssftp
 *
 * This code is subject to the terms and conditions specified in the 
 * corresponding product license agreement which outlines the authorized 
 * usage and restrictions.
 *)

program sftp;

uses
  Forms,
  sftpdialogf in 'sftpdialogf.pas'   {FormSftpdialogf},
  sftploginf in 'sftploginf.pas'   {FormSftploginf},
  sftpprogressf in 'sftpprogressf.pas'   {FormSftpprogressf},
  sftpf in 'sftpf.pas' {FormSftp};

begin
  Application.Initialize;

  Application.CreateForm(TFormSftp, FormSftp);
  Application.CreateForm(TFormSftpdialog, FormSftpdialog);

  Application.CreateForm(TFormSftplogin, FormSftplogin);

  Application.CreateForm(TFormSftpprogress, FormSftpprogress);

  Application.Run;
end.


         
