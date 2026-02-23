object FormSftp: TFormSftp
  Left = 198
  Top = 116
  Width = 585
  Height = 421
  ActiveControl = ComboBoxLocHistory
  Caption = 'IPWorks SFTP Demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = 11
  Font.Name = 'MS Sans Serif'
  Font.Pitch = fpVariable
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    577
    394)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 4
    Top = 8
    Width = 265
    Height = 257
    Anchors = [akLeft, akTop, akBottom]
    Caption = ' Local System '
    TabOrder = 0
    DesignSize = (
      265
      257)
    object ComboBoxLocHistory: TComboBox
      Left = 8
      Top = 16
      Width = 251
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboBoxLocHistoryChange
    end
    object ListBoxLocFiles: TListBox
      Left = 8
      Top = 40
      Width = 200
      Height = 209
      Anchors = [akLeft, akTop, akBottom]
      ExtendedSelect = False
      ItemHeight = 13
      Sorted = True
      TabOrder = 1
      OnDblClick = ListBoxLocFilesDblClick
    end
    object ButtonLocChgDir: TButton
      Left = 208
      Top = 40
      Width = 50
      Height = 25
      Caption = 'ChgDir'
      TabOrder = 2
      OnClick = ButtonLocChgDirClick
    end
    object ButtonLocMkDir: TButton
      Left = 208
      Top = 64
      Width = 50
      Height = 25
      Caption = 'MkDir'
      TabOrder = 3
      OnClick = ButtonLocMkDirClick
    end
    object ButtonLocRename: TButton
      Left = 208
      Top = 88
      Width = 50
      Height = 25
      Caption = 'Rename'
      TabOrder = 4
      OnClick = ButtonLocRenameClick
    end
    object ButtonLocDelete: TButton
      Left = 208
      Top = 112
      Width = 50
      Height = 25
      Caption = 'Delete'
      TabOrder = 5
      OnClick = ButtonLocDeleteClick
    end
    object ButtonLocRefresh: TButton
      Left = 208
      Top = 136
      Width = 50
      Height = 25
      Caption = 'Refresh'
      TabOrder = 6
      OnClick = ButtonLocRefreshClick
    end
  end
  object ButtonDownload: TButton
    Left = 276
    Top = 68
    Width = 25
    Height = 25
    Caption = '<--'
    TabOrder = 1
    OnClick = ButtonDownloadClick
  end
  object ButtonUpload: TButton
    Left = 276
    Top = 100
    Width = 25
    Height = 25
    Caption = '-->'
    TabOrder = 2
    OnClick = ButtonUploadClick
  end
  object ListBoxStatus: TListBox
    Left = 4
    Top = 275
    Width = 569
    Height = 77
    Anchors = [akLeft, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 3
  end
  object ButtonConnectDisconnect: TButton
    Left = 8
    Top = 359
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Connect'
    TabOrder = 4
    OnClick = ButtonConnectDisconnectClick
  end
  object ButtonCancel: TButton
    Left = 92
    Top = 359
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = ButtonCancelClick
  end
  object ButtonExit: TButton
    Left = 176
    Top = 359
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Exit'
    TabOrder = 6
    OnClick = ButtonExitClick
  end
  object GroupBox2: TGroupBox
    Left = 308
    Top = 8
    Width = 265
    Height = 257
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = ' Remote Host '
    TabOrder = 7
    DesignSize = (
      265
      257)
    object ComboBoxRemHistory: TComboBox
      Left = 8
      Top = 16
      Width = 251
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboBoxRemHistoryChange
    end
    object ListBoxRemFiles: TListBox
      Left = 8
      Top = 40
      Width = 200
      Height = 209
      Anchors = [akLeft, akTop, akRight, akBottom]
      ExtendedSelect = False
      ItemHeight = 13
      Sorted = True
      TabOrder = 1
      OnDblClick = ListBoxRemFilesDblClick
    end
    object ButtonRemChgDir: TButton
      Left = 208
      Top = 40
      Width = 50
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'ChgDir'
      TabOrder = 2
      OnClick = ButtonRemChgDirClick
    end
    object ButtonRemMkDir: TButton
      Left = 208
      Top = 64
      Width = 50
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'MkDir'
      TabOrder = 3
      OnClick = ButtonRemMkDirClick
    end
    object ButtonRemRename: TButton
      Left = 208
      Top = 88
      Width = 50
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Rename'
      TabOrder = 4
      OnClick = ButtonRemRenameClick
    end
    object ButtonRemDelete: TButton
      Left = 208
      Top = 112
      Width = 50
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Delete'
      TabOrder = 5
      OnClick = ButtonRemDeleteClick
    end
    object ButtonRemRefresh: TButton
      Left = 208
      Top = 136
      Width = 50
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Refresh'
      TabOrder = 6
      OnClick = ButtonRemRefreshClick
    end
  end
  object SFTP1: TipfSFTPClient
    SSHCertStore = 'MY'
    SSHCompressionAlgorithms = 'none,'
    OnDirList = SFTP1DirList
    OnEndTransfer = SFTP1EndTransfer
    OnSSHServerAuthentication = SFTP1SSHServerAuthentication
    OnSSHStatus = SFTP1SSHStatus
    OnStartTransfer = SFTP1StartTransfer
    OnTransfer = SFTP1Transfer
    Left = 280
    Top = 136
  end
end


