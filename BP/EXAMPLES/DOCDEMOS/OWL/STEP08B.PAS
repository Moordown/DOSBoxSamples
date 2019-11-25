{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$R-} { Turn off range check because Windows message parameters
        don't distinguish between Integer and Word. }

program Step08b;

uses WinDos, Strings, WinTypes, WinProcs, Objects, OWindows, ODialogs, OStdDlgs,
  Pen, DrawLine;

{$R STEPS.RES}

{$I STEPS.INC}

type
  PStepWindow = ^TStepWIndow;
  TStepWindow = object(TWindow)
    DragDC: HDC;
    ButtonDown, HasChanged, IsNewFile: Boolean;
    CurrentPen: PPen;
    FileName: array[0..fsPathName] of Char;
    Drawing: PCollection;
    CurrentLine: PLine;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    function CanClose: Boolean; virtual;
    procedure CMAbout(var Msg: TMessage);
      virtual cm_First + cm_About;
    procedure CMFileNew(var Msg: TMessage);
      virtual cm_First + cm_FileNew;
    procedure CMFileOpen(var Msg: TMessage);
      virtual cm_First + cm_FileOpen;
    procedure CMFileSave(var Msg: TMessage);
      virtual cm_First + cm_FileSave;
    procedure CMFileSaveAs(var Msg: TMessage);
      virtual cm_First + cm_FileSaveAs;
    procedure CMFilePrint(var Msg: TMessage);
      virtual cm_First + cm_FilePrint;
    procedure CMFileSetup(var Msg: TMessage);
      virtual cm_First + cm_FileSetup;
    procedure CMPen(var Msg: TMessage);
      virtual cm_First + cm_Pen;
    procedure LoadFile;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure SaveFile;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMLButtonUp(var Msg: TMessage);
      virtual wm_First + wm_LButtonUp;
    procedure WMMouseMove(var Msg: TMessage);
      virtual wm_First + wm_MouseMove;
    procedure WMRButtonDown(var Msg: TMessage);
      virtual wm_First + wm_RButtonDown;
  end;
  TMyApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

procedure StreamRegistration;
begin
  RegisterType(RCollection);
end;

constructor TStepWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  Attr.Menu := LoadMenu(HInstance, MakeIntResource(100));
  HasChanged := False;
  IsNewFile := True;
  ButtonDown := False;
  StrCopy(FileName, '*.PTS');
  CurrentPen := New(PPen, Init(ps_Solid, 1, 0));
  Drawing := New(PCollection, Init(50, 50));
  CurrentLine := nil;
  StreamRegistration;
end;

destructor TStepWindow.Done;
begin
  Dispose(CurrentPen, Done);
  Dispose(Drawing, DOne);
  inherited Done;
end;

function TStepWindow.CanClose: Boolean;
var
  Reply: Integer;
begin
  CanClose := True;
  if HasChanged then
  begin
    Reply := MessageBox(HWindow, 'Do you want to save?',
      'Drawing has changed', mb_YesNo or mb_IconQuestion);
    if Reply = id_Yes then CanClose := False;
  end;
end;

procedure TStepWindow.CMAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(New(PDialog, Init(@Self, 'ABOUTBOX')));
end;

procedure TStepWindow.CMFileNew(var Msg: TMessage);
begin
  Drawing^.FreeAll;
  InvalidateRect(HWindow, nil, True);
  HasChanged := False;
  IsNewFile := True;
end;

procedure TStepWindow.CMFileOpen(var Msg: TMessage);
begin
  if CanClose then
    if Application^.ExecDialog(New(PFileDialog,
      Init(@Self, PChar(sd_FileOpen), FileName))) = id_OK then
      LoadFile;
end;

procedure TStepWindow.CMFileSave(var Msg: TMessage);
begin
  if IsNewFile then CMFileSaveAs(Msg) else SaveFile;
end;

procedure TStepWindow.CMFileSaveAs(var Msg: TMessage);
begin
  if IsNewFile then StrCopy(FileName, '*.pts');
  if Application^.ExecDialog(New(PFileDialog,
    Init(@Self, PChar(sd_FileSave), FileName))) = id_OK then
    SaveFile;
end;

procedure TStepWindow.CMFilePrint(var Msg: TMessage);
begin
  MessageBox(HWindow, 'Feature not implemented.', 'File Print', mb_OK);
end;

procedure TStepWindow.CMFileSetup(var Msg: TMessage);
begin
  MessageBox(HWindow, 'Feature not implemented.', 'Printer Setup', mb_OK);
end;

procedure TStepWindow.CMPen(var Msg: TMessage);
begin
  CurrentPen^.ChangePen;
end;

procedure TStepWindow.LoadFile;
var
  TempColl: PCollection;
  TheFile: TDosStream;
begin
  TheFile.Init(FileName, stOpen);
  TempColl := PCollection(TheFile.Get);
  TheFile.Done;
  if TempColl <> nil then
  begin
    Dispose(Drawing, Done);
    Drawing := TempColl;
    InvalidateRect(HWindow, nil, True);
  end;
  HasChanged := False;
  IsNewFile := False;
end;

procedure TStepWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);

  procedure DrawLine(P: PLine); far;
  begin
    P^.Draw(PaintDC);
  end;

begin
  Drawing^.ForEach(@DrawLine);
end;

procedure TStepWindow.SaveFile;
var
  TheFile: TDosStream;
begin
  TheFile.Init(FileName, stCreate);
  TheFile.Put(Drawing);
  TheFile.Done;
  IsNewFile := False;
  HasChanged := False;
end;

procedure TStepWindow.WMLButtonDown(var Msg: TMessage);
begin
  if not ButtonDown then
  begin
    ButtonDown := True;
    SetCapture(HWindow);
    DragDC := GetDC(HWindow);
    CurrentPen^.Select(DragDC);
    MoveTo(DragDC, Msg.LParamLo, Msg.LParamHi);
    CurrentLine := New(PLine, Init(CurrentPen));
    Drawing^.Insert(CurrentLine);
    HasChanged := True;
  end;
end;

procedure TStepWindow.WMLButtonUp(var Msg: TMessage);
begin
  if ButtonDown then
  begin
    ButtonDown := False;
    ReleaseCapture;
    CurrentPen^.Delete;
    ReleaseDC(HWindow, DragDC);
  end;
end;

procedure TStepWindow.WMMouseMove(var Msg: TMessage);
begin
  if ButtonDown then
  begin
    LineTo(DragDC, Msg.LParamLo, Msg.LParamHi);
    CurrentLine^.AddPoint(Msg.LParamLo, Msg.LParamHi);
  end;
end;

procedure TStepWindow.WMRButtonDown(var Msg: TMessage);
begin
  if not ButtonDown then CurrentPen^.ChangePen;
end;

procedure TMyApplication.InitMainWindow;
begin
  MainWindow := New(PStepWindow, Init(nil, 'Steps'));
end;

var
  MyApp: TMyApplication;

begin
  MyApp.Init('Steps');
  MyApp.Run;
  MyApp.Done;
end.