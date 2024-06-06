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
unit sftpf;

interface

uses
  Windows, Messages, SysUtils, Graphics, Controls, Classes, Forms, Dialogs, StdCtrls, ExtCtrls,
  ipfcore, ipftypes, ipfsftpclient;

const
  OffLineConst    = 1;
  OnLineConst     = 2;

type
  TFormSftp = class(TForm)
    GroupBox1: TGroupBox;
    ComboBoxLocHistory: TComboBox;
    ListBoxLocFiles: TListBox;
    ButtonLocChgDir: TButton;
    ButtonLocMkDir: TButton;
    ButtonLocRename: TButton;
    ButtonLocDelete: TButton;
    ButtonLocRefresh: TButton;
    ButtonDownload: TButton;
    ButtonUpload: TButton;
    ListBoxStatus: TListBox;
    ButtonConnectDisconnect: TButton;
    ButtonCancel: TButton;
    ButtonExit: TButton;
    GroupBox2: TGroupBox;
    ComboBoxRemHistory: TComboBox;
    ListBoxRemFiles: TListBox;
    ButtonRemChgDir: TButton;
    ButtonRemMkDir: TButton;
    ButtonRemRename: TButton;
    ButtonRemDelete: TButton;
    ButtonRemRefresh: TButton;
    SFTP1: TipfSFTPClient;

    procedure UpdateLocal;
    procedure UpdateRemote;
    procedure UpdateNotes(Note: String);

    procedure ButtonConnectDisconnectClick( Sender: TObject);
    procedure ButtonExitClick( Sender: TObject );
    procedure ListBoxLocFilesDblClick( Sender: TObject );
    procedure ListBoxRemFilesDblClick( Sender: TObject );
    procedure ButtonCancelClick( Sender: TObject );
    procedure ButtonRemChgDirClick( Sender: TObject );
    procedure ButtonRemMkDirClick( Sender: TObject );
    procedure ButtonRemRenameClick( Sender: TObject );
    procedure ButtonRemDeleteClick( Sender: TObject );
    procedure ButtonRemRefreshClick( Sender: TObject );
    procedure ButtonLocChgDirClick( Sender: TObject );
    procedure ButtonLocMkDirClick( Sender: TObject );
    procedure ButtonLocRenameClick( Sender: TObject );
    procedure ButtonLocDeleteClick( Sender: TObject );
    procedure ButtonLocRefreshClick( Sender: TObject );
    procedure ButtonDownloadClick( Sender: TObject );
    procedure ButtonUploadClick( Sender: TObject );
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboBoxLocHistoryChange(Sender: TObject);
    procedure ComboBoxRemHistoryChange(Sender: TObject);
    procedure SFTP1SSHStatus(Sender: TObject; const Message: String);
    procedure SFTP1StartTransfer(Sender: TObject; Direction: Integer;
      const LocalFile, RemoteFile: string);
    procedure SFTP1EndTransfer(Sender: TObject; Direction: Integer;
      const LocalFile, RemoteFile: string);
    procedure SFTP1Transfer(Sender: TObject; Direction: Integer;
      const LocalFile, RemoteFile: string; BytesTransferred: Int64;
      PercentDone: Integer; Text: string; TextB: TArray<System.Byte>; var Cancel: Boolean);
    procedure SFTP1DirList(Sender: TObject; const DirEntry: String;
  FileName: String; IsDir: Boolean; FileSize: Int64;
  const FileTime: String; isSymlink: Boolean);
    procedure SFTP1SSHServerAuthentication(Sender: TObject;
      HostKey: string; HostKeyB: TArray<System.Byte>; const Fingerprint, KeyAlgorithm, CertSubject, CertIssuer,
      Status: string; var Accept: Boolean);
  private
    { Private declarations }
    CurrentFileSize: Integer;
    LocFileSizes, RemFileSizes: TStringList;
    State: Integer;
    procedure UpdateComboBox(ComboBox: TComboBox; ItemName: String);
    procedure UpdateButtons;
  public
    { Public declarations }
  end;

var
  FormSftp: TFormSftp;

implementation

uses
  sftploginf, sftpprogressf, sftpdialogf;

{$R *.dfm}

procedure TFormSftp.FormCreate(Sender: TObject);
begin
   State := OffLineConst;
   LocFileSizes := TStringList.Create;
   RemFileSizes := TStringList.Create;
   ComboBoxLocHistory.Items.Insert(0, GetCurrentDir);
   ComboBoxLocHistory.ItemIndex := 0;
   UpdateLocal;
   UpdateButtons;
end;

procedure TFormSftp.ButtonConnectDisconnectClick(Sender: TObject);
begin
   Screen.Cursor := crAppStart;
   if State = OffLineConst then
      with TFormSftplogin.Create(self) do
      begin
         if ShowModal = mrOK then
         begin
            SFTP1.ChangeRemotePath('');
            SFTP1.RemoteFile := '';
            SFTP1.SSHHost := EditHostName.Text;
            SFTP1.SSHUser := EditUser.Text;
            SFTP1.SSHPassword := EditPassword.Text;
            SFTP1.SSHPort := 22;
            ComboBoxRemHistory.Clear;
            try
               SFTP1.SSHLogon(SFTP1.SSHHost,SFTP1.SSHPort);
               State := OnLineConst;
               ComboBoxRemHistory.Items.Insert(0, SFTP1.RemotePath);
               ComboBoxRemHistory.ItemIndex := 0;
               UpdateRemote;
            except on E: Exception do
               UpdateNotes(E.Message);
            end;
         end;
         Free;
      end
   else
   begin
      try
        SFTP1.SSHLogoff
      except on E: Exception do
         UpdateNotes(E.Message);
      end;
      State := OffLineConst;
   end;
   UpdateButtons;
   Screen.Cursor := crDefault;
end;

procedure TFormSftp.ButtonExitClick(Sender: TObject);
begin
   if State = OnLineConst then
   begin
      Screen.Cursor := crAppStart;
      try
         SFTP1.SSHLogoff;
      except on E: Exception do
         UpdateNotes(E.Message);
      end;
      Screen.Cursor := crDefault;
   end;
   Close;
end;

procedure TFormSftp.ListBoxLocFilesDblClick(Sender: TOBject);
var
   Name: String;
begin
   // Local System Box:  If double-clicked on a file, send it
   //                    If double-clicked on a directory, open it
   Name := ListBoxLocFiles.Items.Strings[ListBoxLocFiles.ItemIndex];
   if Name[1] = '<' then
   begin
      Delete(Name, 1, 7);  // Remove first seven characters, '<DIR>  '
      ChDir(Name);
      UpdateComboBox(ComboBoxLocHistory, GetCurrentDir);
      UpdateLocal;
   end else
      ButtonUploadClick(nil);
end;

procedure TFormSftp.ListBoxRemFilesDblClick( Sender: TOBject );
var
   Name: String;
begin
   // Remote Host Box:  If double-clicked on a file, get it
   //                   If double-clicked on a directory, open it
   Name := ListBoxRemFiles.Items.Strings[ListBoxRemFiles.ItemIndex];
   if Name[1] = '<' then
   begin
      Delete(Name, 1, 7); { Remove first seven characters, '<DIR>  '}
      SFTP1.ChangeRemotePath(Name);
      UpdateComboBox(ComboBoxRemHistory, SFTP1.RemotePath);
      UpdateRemote;
   end else
      ButtonDownloadClick(nil);
end;

procedure TFormSftp.ButtonLocChgDirClick( Sender: TObject );
begin
   // Local ChgDir Button
   with TFormSftpdialog.Create(self) do
   begin
      Caption := 'Change Directory';
      LabelWhat.Caption := 'New directory:';
      EditLine.Text := GetCurrentDir;
      if ShowModal = mrOk then
      begin
         ChDir(EditLine.Text);
         UpdateComboBox(ComboBoxLocHistory, GetCurrentDir);
         UpdateLocal;
      end;
      Free;
   end;
end;

procedure TFormSftp.ButtonLocMkDirClick(Sender: TOBject);
begin
   // Local MkDir Button
   with TFormSftpdialog.Create(self) do
   begin
      Caption := 'Make Directory';
      LabelWhat.Caption := 'New directory:';
      EditLine.Text := '';

      if ShowModal = mrOk then
      begin
         CreateDir(EditLine.Text);
         UpdateLocal;
      end;
    end;
end;

procedure TFormSftp.ButtonLocRenameClick( Sender: TObject);
var
   IsDir: Boolean;
   Name: String;
begin
   // Local Rename Button
   Name := ListBoxLocFiles.Items.Strings[ListBoxLocFiles.ItemIndex];
   IsDir := Name[1] = '<';
   if IsDir then
   begin
      Delete(Name, 1, 7); { // Remove first seven characters, '<DIR>  ' }
      if Name[1] = '.' then Exit;
   end;

   with TFormSftpdialog.Create(self) do
   begin
      Caption := 'Rename File';
      LabelWhat.Caption := 'New filename:';
      EditLine.Text := Name;

      if ShowModal = mrOk then
         if RenameFile(Name, EditLine.Text) then
            UpdateLocal
         else
            UpdateNotes('Could not change the value.');
      Free;
   end;
end;

procedure TFormSftp.ButtonLocDeleteClick(Sender: TObject);
var
   IsDir: boolean;
   Name: string;
begin
   // Local Delete Button
   Name := ListBoxLocFiles.Items.Strings[ListBoxLocFiles.ItemIndex];
   IsDir := Name[1] = '<';
   if IsDir then
   begin
      Delete(Name, 1, 7); { // Remove first seven characters, '<DIR>  ' }
      if Name[1] = '.' then Exit;
   end;

   with TFormSftpdialog.Create(self) do
   begin
      Caption := 'Remove File';
      LabelWhat.Caption := 'Remove file:';
      EditLine.Text := Name;

      if ShowModal = mrOk then
         if IsDir then
            if RemoveDir(EditLine.Text) then
               UpdateLocal
            else
               UpdateNotes('Could not delete directory')
         else
            if DeleteFile(EditLine.Text) then
               UpdateLocal
            else
               UpdateNotes('Could not delete directory');
      Free;
   end;
end;

procedure TFormSftp.ButtonRemChgDirClick( Sender: TObject );
begin
   // Remote ChgDir Button
   with TFormSftpdialog.Create(self) do
   begin
      Caption := 'Change Directory';
      LabelWhat.Caption := 'New directory:';
      EditLine.Text := SFTP1.RemotePath;

      if ShowModal = mrOk then
      begin
         SFTP1.ChangeRemotePath(EditLine.Text);
         UpdateComboBox(ComboBoxRemHistory, EditLine.Text);
         UpdateRemote;
      end;
      Free;
   end;
end;

procedure TFormSftp.ButtonRemMkDirClick( Sender: TOBject );
begin
   with TFormSftpdialog.Create(self) do
   begin
      Caption := 'Make Directory';
      LabelWhat.Caption := 'New directory:';
      EditLine.Text := '';

      if ShowModal = mrOk then
      begin
         try
            SFTP1.MakeDirectory(EditLine.Text);
            UpdateRemote;
         except on E: Exception do
            UpdateNotes(E.Message);
         end;
      end;
      Free;
   end;
end;

procedure TFormSftp.ButtonRemRenameClick( Sender: TObject );
var
   Name: String;
begin
   // Remote Rename Button
   Name := ListBoxRemFiles.Items.Strings[ListBoxRemFiles.ItemIndex];
   if Name[1] = '<' then
   begin
      Delete(Name, 1, 7); { // Remove first seven characters, '<DIR>  ' }
      if Name[1] = '.' then Exit;
   end;

   with TFormSftpdialog.Create(self) do
   begin
      Caption := 'Rename File';
      LabelWhat.Caption := 'New filename:';
      EditLine.Text := Name;

      if ShowModal = mrOk then
      begin
         if EditLine.Text = Name then
            Exit;

         SFTP1.RemoteFile := Name;
         try
            SFTP1.RenameFile(EditLine.Text);
         except on E: Exception do
            UpdateNotes(E.Message);
         end;
         UpdateRemote;
      end;
      Free;
   end;
end;

procedure TFormSftp.ButtonRemDeleteClick( Sender: TObject );
var
   Name: String;
   IsDir: Boolean;
begin
   // Remote Delete Button
   Name := ListBoxRemFiles.Items.Strings[ListBoxRemFiles.ItemIndex];
   IsDir := Name[1] = '<';
   if IsDir then
   begin
      Delete(Name, 1, 7); { // Remove first seven characters, '<DIR>  ' }
      if Name[1] = '.' then Exit;
   end;

   with TFormSftpdialog.Create(self) do
   begin
      Caption := 'Delete File or Directory';
      LabelWhat.Caption := 'Name:';
      EditLine.Text := Name;

      if ShowModal = mrOk then
      begin
         try
            if IsDir then
               SFTP1.RemoveDirectory(Name)
            else
               SFTP1.DeleteFile(Name);
         except on E: Exception do
            UpdateNotes(E.Message);
         end;
         UpdateRemote;
      end;
      Free;
   end;
end;

procedure TFormSftp.ButtonDownloadClick( Sender: TOBject );
var
   Name: String;
begin
   // Download currently selected file from Remote Host box
   if ListBoxRemFiles.ItemIndex = -1 then
      UpdateNotes('No file selected to download.')
   else if ListBoxRemFiles.Items.Strings[ListBoxRemFiles.ItemIndex][1] = '<' then
      UpdateNotes('Can not download directories.')
   else begin
      Name := ListBoxRemFiles.Items.Strings[ListBoxRemFiles.ItemIndex];
      SFTP1.RemoteFile := Name;
      SFTP1.LocalFile := Name;
      CurrentFileSize := StrToInt(RemFileSizes.Strings[ListBoxRemFiles.ItemIndex]);
      FormSftpprogress.Caption := 'Download Progress';
      FormSftpprogress.LabelUpDown.Caption := 'Download Progress';
      FormSftpprogress.Show;
      Screen.Cursor := crAppStart;
      try
         SFTP1.Download;
      except on E: Exception do
      begin
         UpdateNotes(E.Message);
         UpdateRemote;  // this is to test the connection
      end;
      end;
      FormSftpprogress.Hide;
      UpdateLocal;
      Screen.Cursor := crDefault;
   end;
end;

procedure TFormSftp.ButtonUploadClick(Sender: TObject);
var
   Name: String;
begin
   // Upload currently selected file from Local System box }
   if ListBoxLocFiles.ItemIndex = -1 then
      UpdateNotes('No file selected to upload.')
   else if ListBoxLocFiles.Items.Strings[ListBoxLocFiles.ItemIndex][1] = '<' then
      UpdateNotes('Can not upload directories.')
   else begin
      Name := ListBoxLocFiles.Items.Strings[ListBoxLocFiles.ItemIndex];
      SFTP1.LocalFile := Name;
      SFTP1.RemoteFile := Name;
      CurrentFileSize := StrToInt(LocFileSizes.Strings[ListBoxLocFiles.ItemIndex]);
      FormSftpprogress.Caption := 'Upload Progress';
      FormSftpprogress.LabelUpDown.Caption := 'Upload Progress';
      FormSftpprogress.Show;
      Screen.Cursor := crAppStart;
      try
         SFTP1.Upload;
      except on E: Exception do
         UpdateNotes(E.Message);
      end;

      FormSftpprogress.Hide;
      UpdateRemote;
      Screen.Cursor := crDefault;
   end;
end;

procedure TFormSftp.UpdateLocal;
var
   SearchRec: TSearchRec;
begin
   // Show updated file list for the local system
   // we know the value of CurrentLocDirectory  here

   Screen.Cursor := crAppStart;
   ListBoxLocFiles.Clear;
   LocFileSizes.Clear;

   if FindFirst('*', faAnyFile, SearchRec) = 0 then
   repeat
      if (SearchRec.Attr and faDirectory) <> 0 then
         ListBoxLocFiles.Items.Add('<DIR>  ' + SearchRec.Name)
      else
         ListBoxLocFiles.Items.Add(SearchRec.Name);

      LocFileSizes.Add(IntToStr(SearchRec.Size));
   until FindNext(SearchRec) <> 0;

   FindClose(SearchRec);
   Screen.Cursor := crDefault;
end;

procedure TFormSftp.UpdateButtons;
begin
   ButtonRemChgDir.Enabled := State = OnLineConst;
   ButtonRemMkDir.Enabled := State = OnLineConst;
   ButtonRemRename.Enabled := State = OnLineConst;
   ButtonRemDelete.Enabled := State = OnLineConst;
   ButtonRemRefresh.Enabled := State = OnLineConst;
   ButtonDownload.Enabled := State = OnLineConst;
   ButtonUpload.Enabled := State = OnLineConst;

   if State = OnLineConst then
      ButtonConnectDisconnect.Caption := 'Disconnect'
   else
   begin
      ComboBoxRemHistory.Clear;
      ButtonConnectDisconnect.Caption := 'Connect';
   end;

   //ListBoxRemFiles.Enabled := State = OnLineConst;
   ComboBoxRemHistory.Enabled := State = OnLineConst;
end;

procedure TFormSftp.UpdateRemote;
begin
   // Show updated file list for the remote host
   // Called only when connected

   Screen.Cursor := crAppStart;
   ListBoxRemFiles.Clear;
   RemFileSizes.Clear;
   SFTP1.RemoteFile := '';
   try
      SFTP1.ListDirectory;
   except on E: Exception do
   begin
      try
         SFTP1.Interrupt;
      except on E: Exception do
      end;
      State := OffLineConst;
      UpdateButtons;
   end;
   end;
   Screen.Cursor := crDefault;
end;

procedure TFormSftp.UpdateNotes(note: string);
begin
   // Add a message to the status box and scroll down to make it visible
   ListBoxStatus.Items.Add(note);

   if ListBoxStatus.Items.Count > 255 then
      ListBoxStatus.Items.Delete(0);

   if ListBoxStatus.Items.Count > 3 then
      ListBoxStatus.TopIndex := ListBoxStatus.Items.Count - 3;
end;

procedure TFormSftp.UpdateComboBox(ComboBox: TComboBox; ItemName: String);
var
   Pos: Integer;
begin
   Pos := ComboBox.Items.IndexOf(ItemName);
   if Pos > -1 then
      ComboBox.Items.Delete(Pos);

   ComboBox.Items.Insert(0, ItemName);
   ComboBox.ItemIndex := 0;
end;

procedure TFormSftp.ButtonLocRefreshClick( Sender: TObject );
begin
   UpdateLocal;
end;

procedure TFormSftp.ButtonRemRefreshClick( Sender: TOBject );
begin
   UpdateRemote;
end;

procedure TFormSftp.ButtonCancelClick(Sender: TObject);
begin
   // Cancel Button:  Stop the current SFTP process
   Screen.Cursor := crAppStart;
   try
      SFTP1.Interrupt;
   except on E: Exception do
      UpdateNotes(E.Message);
   end;
   Screen.Cursor := crDefault;
end;

procedure TFormSftp.FormResize(Sender: TObject);
begin
    GroupBox1.Height := Height - 195 ;
    GroupBox1.Width := (Width div 2) - 27 ;
    ComboBoxLocHistory.Width := GroupBox1.Width - 16 ;
    ListBoxLocFiles.Height := GroupBox1.Height -  48;
    ListBoxLocFiles.Width := GroupBox1.Width - 65;
    ButtonLocChgDir.Left := ListBoxLocFiles.Left + ListBoxLocFiles.Width;
    ButtonLocMkDir.Left := ButtonLocChgDir.Left ;
    ButtonLocRename.Left := ButtonLocChgDir.Left ;
    ButtonLocDelete.Left := ButtonLocChgDir.Left ;
    ButtonLocRefresh.Left := ButtonLocChgDir.Left ;

    GroupBox2.Height := GroupBox1.Height ;
    GroupBox2.Width := GroupBox1.Width ;
    GroupBox2.Left := GroupBox1.Left + GroupBox1.Width + 39;
    ComboBoxRemHistory.Width := ComboBoxLocHistory.Width ;
    ListBoxRemFiles.Height := ListBoxLocFiles.Height ;
    ListBoxRemFiles.Width := ListBoxLocFiles.Width ;
    ButtonRemChgDir.Left := ListBoxRemFiles.Left + ListBoxRemFiles.Width;
    ButtonRemMkDir.Left := ButtonRemChgDir.Left ;
    ButtonRemRename.Left := ButtonRemChgDir.Left ;
    ButtonRemDelete.Left := ButtonRemChgDir.Left ;
    ButtonRemRefresh.Left := ButtonRemChgDir.Left ;

    ButtonDownload.Left := (Width div 2) - 16 ;
    ButtonDownload.Top := (Height div 2) - 124 ;
    ButtonUpload.Left := ButtonDownload.Left ;
    ButtonUpload.Top := ButtonDownload.Top + 32 ;
    ButtonCancel.Top := ButtonConnectDisconnect.Top ;
    ButtonExit.Top := ButtonConnectDisconnect.Top ;
end;

procedure TFormSftp.FormDestroy(Sender: TObject);
begin
   LocFileSizes.Free;
   RemFileSizes.Free;
end;

procedure TFormSftp.ComboBoxLocHistoryChange(Sender: TObject);
begin
   // Return to recent local directory
   ChDir(ComboBoxLocHistory.Text);
   UpdateComboBox(ComboBoxLocHistory, GetCurrentDir);
   UpdateLocal;
end;

procedure TFormSftp.ComboBoxRemHistoryChange(Sender: TObject);
begin
   // Return to recent remote directory
   SFTP1.ChangeRemotePath(ComboBoxRemHistory.Text);
   UpdateComboBox(ComboBoxRemHistory, ComboBoxRemHistory.Text);
   UpdateRemote;
end;

procedure TFormSftp.SFTP1SSHStatus(Sender: TObject; const Message: String);
begin
  UpdateNotes(Message);
end;

procedure TFormSftp.SFTP1StartTransfer(Sender: TObject; Direction: Integer;
  const LocalFile, RemoteFile: string);
begin
  UpdateNotes('Transfer Started');
  FormSftpprogress.ProgressBar1.Position := 0;
end;

procedure TFormSftp.SFTP1EndTransfer(Sender: TObject; Direction: Integer;
  const LocalFile, RemoteFile: string);
begin
  // When finished transferring, hide the progress bar
  UpdateNotes('Transfer Ended');
  FormSftpprogress.Hide;
  UpdateLocal;
end;

procedure TFormSftp.SFTP1Transfer(Sender: TObject; Direction: Integer;
  const LocalFile, RemoteFile: string; BytesTransferred: Int64;
  PercentDone: Integer; Text: string; TextB: TArray<System.Byte>; var Cancel: Boolean);
begin
  FormSftpprogress.ProgressBar1.Position := PercentDone;
end;

procedure TFormSftp.SFTP1DirList(Sender: TObject; const DirEntry: String;
  FileName: String; IsDir: Boolean; FileSize: Int64;
  const FileTime: String; isSymlink: Boolean);
begin
   // DirList Event:  Keep directory items distinct from file items
   if IsDir then
      ListBoxRemFiles.Items.Add('<DIR>  ' + FileName)
   else
      ListBoxRemFiles.Items.Add(FileName);

   RemFileSizes.Add(IntToStr(FileSize));
end;

procedure TFormSftp.SFTP1SSHServerAuthentication(Sender: TObject;
      HostKey: string; HostKeyB: TArray<System.Byte>; const Fingerprint, KeyAlgorithm, CertSubject, CertIssuer,
      Status: string; var Accept: Boolean);
begin
Accept := true;
end;

end.

