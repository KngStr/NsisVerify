object frmNsisVerify: TfrmNsisVerify
  Left = 0
  Top = 0
  Caption = 'frmNsisVerify'
  ClientHeight = 533
  ClientWidth = 679
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object btnDo: TButton
    Left = 16
    Top = 16
    Width = 75
    Height = 25
    Caption = 'btnDo'
    TabOrder = 0
    OnClick = btnDoClick
  end
  object mmo1: TMemo
    Left = 16
    Top = 64
    Width = 641
    Height = 449
    Lines.Strings = (
      'mmo1')
    TabOrder = 1
  end
  object OpenDialog1: TOpenDialog
    Left = 392
    Top = 8
  end
end
