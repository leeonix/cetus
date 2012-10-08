object Form1: TForm1
  Left = 240
  Top = 222
  Caption = 'Form1'
  ClientHeight = 526
  ClientWidth = 947
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 5
    Width = 197
    Height = 340
    Lines.Strings = (
      'Thread1'
      'Thread2'
      'Thread3'
      'Thread4'
      'Thread5'
      'Thread6'
      'Thread7'
      'Thread8'
      'Thread9'
      'Thread10'
      'Thread11'
      'Thread12'
      'Thread13'
      'Thread14')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 96
    Top = 384
    Width = 99
    Height = 25
    Caption = 'Add tasks'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo2: TMemo
    Left = 216
    Top = 0
    Width = 731
    Height = 526
    Align = alRight
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Memo2')
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object btnFreeThreadPool: TButton
    Left = 104
    Top = 431
    Width = 99
    Height = 25
    Caption = 'FreeThreadPool'
    TabOrder = 3
    OnClick = btnFreeThreadPoolClick
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 196
    Top = 96
  end
end
