unit ChessApp;

interface

uses App, Views, Dialogs, Menus, Objects, Drivers;

type
  PChessApp = ^TChessApp;
  TChessApp = object(TApplication)
    constructor Init;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure InitChessBoard;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure InitDesktop; virtual;
    procedure InitStatusDialog;
    procedure InitScreenMode;
  end;

implementation

uses ChessCmd, Status, Board, Pieces, MoveList, ChessDlg, ChessSt;

constructor TChessApp.Init;
begin
  inherited Init;
  InitScreenMode;
  InitStatusDialog;
  InitChessBoard;
  if ChessBoard <> nil then Insert(ChessBoard);
  if StatusDialog <> nil then InsertWindow(StatusDialog);
  RegisterObjects;
  RegisterViews;
  RegisterType(RChessPiece);
  RegisterType(RMoveList);
  RegisterType(RTimeLabel);
  RegisterType(RTimeInput);
  RegisterType(RSettingsDlg);
end;

function TChessApp.GetPalette: PPalette;
const
  P: array[apColor..apMonochrome] of string[Length(CChessAppColor)] =
    (CChessAppColor, CChessAppBlackWhite, CChessAppMonochrome);
begin
  GetPalette := @P[AppPalette];
end;

procedure TChessApp.HandleEvent(var Event: TEvent);
var
  D: PDialog;
begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmSettings:
          begin
            D := CreateSettingsDlg;
            D^.SetData(Settings);
            if ExecView(ValidView(D)) <> cmCancel then
              D^.GetData(Settings);
            Dispose(D, Done);
            ClearEvent(Event);
          end;
      end;
  end;
end;

procedure TChessApp.Idle;
begin
  inherited Idle;
  if ChessBoard <> nil then ChessBoard^.DoThink;
end;

procedure TChessApp.InitChessBoard;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.X := R.B.X - 28;
  ChessBoard := New(PChessBoard, Init(R));
end;

procedure TChessApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  R.A.X := R.B.X - 28;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~G~ame', hcNoContext, NewMenu(
      NewItem('~N~ew', '', kbNoKey, cmNew, hcNoContext,
      NewItem('~L~oad', 'F3', kbF3, cmOpen, hcNoContext,
      NewItem('~S~ave', 'F2', kbF2, cmSave, hcNoContext,
      NewItem('Save ~a~s', '', kbNoKey, cmSaveAs, hcNoContext,
      NewLine(
      NewItem('~R~un demo', '', kbNoKey, cmRunDemo, hcNoContext,
      NewItem('S~t~op', 'Alt+T', kbAltT, cmStop, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt+X', kbAltX, cmQuit, hcNoContext,
      nil)))))))))),
    NewSubMenu('~M~ove', hcNoContext, NewMenu(
      NewItem('~U~ndo', 'Alt+Bksp', kbAltBack, cmUndo, hcNoContext,
      NewItem('~R~edo', 'Ctrl+Bksp', kbCtrlBack, cmRedo, hcNoContext,
      NewLine(
      NewItem('~C~omputer move', 'Alt+C', kbAltC, cmComputerMove, hcNoContext,
      NewItem('~E~nter move...', 'Alt+E', kbAltE, cmEnterMove, hcNoContext,
      NewItem('~S~how hint', 'Alt+H', kbAltH, cmShowHint, hcNoContext,
      nil))))))),
    NewSubMenu('~O~ptions', hcNoContext, NewMenu(
      NewItem('~S~ettings', '', kbNoKey, cmSettings, hcNoContext,
      NewItem('~C~olors', '', kbNoKey, cmColors, hcNoContext,
      nil))), nil))))));
end;

procedure TChessApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  R.A.X := R.B.X - 28;
  StatusLine := New(PChessStatusLine, Init(R,
    NewStatusDef($0, $FFFF,
      StdStatusKeys(nil), nil)));
end;

procedure TChessApp.InitDesktop;
var
  R: TRect;
begin
  GetExtent(R);
  R.Grow(0, -1);
  R.A.X := R.B.X - 28;
  Desktop := New(PDesktop, Init(R));
end;

procedure TChessApp.InitStatusDialog;
var
  R: TRect;
begin
  R.Assign(0, 0, Desktop^.Size.X, Size.Y - 2);
  StatusDialog := New(PStatusDialog, Init(R));
end;

procedure TChessApp.InitScreenMode;
begin
  ShadowSize.X := 2;
  SetScreenMode(ScreenMode and (not smFont8x8));
end;


end.
