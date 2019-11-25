program OWLChess;

uses Winprocs, WinTypes, Objects, OWindows, ODialogs, BWCC, AppUtils,
     Chessdll, Board, MoveList, ChessDlg, ChConst, FileDlgs, Strings,
     CommDlg, WinDos, CTimers;

{$R OWLChess}

const

  ChessSignature : array [0..33] of Char = 'Borland Pascal Chess saved game'#26#0;
  ChessFileFilter = 'Chess games'#0'*.chs'#0#0;

type

  TGameMode = (SinglePlayer, TwoPlayer, AutoPlay);

  PChessApp = ^TChessApp;
  TChessApp = object(TXtendedApp)
    procedure InitMainWindow; virtual;
    function  IdleAction: Boolean; virtual;
  end;

  PChessWindow = ^TChessWindow;
  TChessWindow = object(TWindow)
    Game: HChess;
    Board: PChessBoard;
    ThinkState: TSearchStatus;
    Mode : TGameMode;
    Player: TColor;
    MoveHistory: PMoveList;
    InfoPane: PChessInfoWindow;
    ThinkMenu: HMenu;
    GameFileName: array [0..fsPathName] of Char;
    Timer: array [cWhite..cBlack] of PChessTimer;
    ActiveTimer: PChessTimer;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor  Done; virtual;
    procedure SetupWindow; virtual;         { first place HWindow is valid }
    procedure WMDestroy(var Msg: TMessage); { last place HWindow is valid }
      virtual wm_First + wm_Destroy;
    function  GetClassName: PChar; virtual;
    procedure GetWindowClass(var WC: TWndClass); virtual;
    procedure RestartGame;
    function  CanClose: Boolean; virtual;
    function  IdleAction: Boolean;
    function  ShowMsg(const Ctx, MsgCode: Integer): Integer;
    procedure ReportGameState;
    procedure GameOver;
    function  SaveGame(FileName: PChar): Boolean;
    function  LoadGame(FileName: PChar): Boolean;
    procedure RecordMove(const Move: TMove);
    procedure StartComputerMove;
    procedure AcceptComputerMove;
    procedure AMSubmitMove(var Msg: TMessage);
      virtual am_SubmitMove;
    procedure CMNewGame(var Msg: TMessage);
      virtual cm_First + cm_NewGame;
    procedure CMLoadGame(var Msg: TMessage);
      virtual cm_First + cm_LoadGame;
    procedure CMSaveGame(var Msg: TMessage);
      virtual cm_First + cm_SaveGame;
    procedure CMSaveAs(var Msg: TMessage);
      virtual cm_First + cm_SaveAs;
{    procedure CMAutoPlay(var Msg: TMessage);
      virtual cm_First + cm_AutoPlay;
}    procedure CMPauseGame(var Msg: TMessage);
      virtual cm_First + cm_PauseGame;
    procedure CMUndoMove(var Msg: TMessage);
      virtual cm_First + cm_UndoMove;
    procedure CMRedoMove(var Msg: TMessage);
      virtual cm_First + cm_RedoMove;
    procedure CMSettings(var Msg: TMessage);
      virtual cm_First + cm_Settings;
    procedure CMStopThinking(var Msg: TMessage);
      virtual cm_First + cm_StopThinking;
    procedure WMTimer(var Msg: TMessage);
      virtual wm_First + wm_Timer;
    procedure WMSetCursor(var Msg: TMessage);
      virtual wm_First + wm_SetCursor;
  end;

constructor TChessWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  inherited Init(AParent, ATitle);
  Attr.X := 10;
  Attr.Y := 50;
  Attr.W := 350;
  Attr.H := 350;
  Attr.Style := ws_OverlappedWindow;
  Attr.Menu := LoadMenu(HInstance, PChar(idMainMenu));
  ThinkMenu := LoadMenu(HInstance, PChar(idThinkMenu));
  LoadINISettings;
  GameFileName[0] := #0;
  if ChessSettings.OnePlayer then
    Mode := SinglePlayer
  else
    Mode := TwoPlayer;
  Player := cWhite;
  Status := Context(cxChessError, Ord(NewGame(Game)));
  if Status <> 0 then Exit;
  ThinkState := GetSearchStatus(Game);
  Timer[cWhite] := New(PChessTimer, Init);
  Timer[cBlack] := New(PChessTimer, Init);
  ActiveTimer := nil;
  MoveHistory := New(PMoveList, Init(20, 10));
  Board := New(PChessBoard, Init(@Self, Game));
  InfoPane := New(PChessInfoWindow, Init(@Self, PChar(dlgInfoPane)));
end;

destructor  TChessWindow.Done;
begin
  Dispose(MoveHistory, Done);
  Dispose(Timer[cWhite], Done);
  Dispose(Timer[cBlack], Done);
  SaveINISettings;
  DisposeGame(Game);
  DestroyMenu(ThinkMenu);
  inherited Done;
end;

procedure TChessWindow.SetupWindow;
var
  W, WX, WY, H: Word;
  WR, CR, IR: TRect;
begin
  inherited SetupWindow;
  W := Board^.IdealWidth;
  H := W;
  GetWindowRect(HWindow, WR);
  GetClientRect(HWindow, CR);
  GetClientRect(InfoPane^.HWindow, IR);
  WX := (WR.Right - WR.Left) - CR.Right;
  WY := (WR.Bottom - WR.Top) - CR.Bottom;
  if H < IR.Bottom then
    H := IR.Bottom;
  SetWindowPos(HWindow, 0, 0, 0, W + 75 + IR.Right + WX,
                              H + 50 + WY, swp_NoZOrder or swp_NoMove);
  SetWindowPos(Board^.HWindow, 0, 25, 25, W, W, swp_NoZOrder);
  SetWindowPos(InfoPane^.HWindow, 0, W + 50, 25, 0, 0,
                               swp_NoZOrder or swp_NoSize);
  ShowWindow(Board^.HWindow, sw_ShowNormal);
  SetTimer(HWindow, 1, ChessSettings.RefreshRate, nil);
end;

procedure TChessWindow.WMDestroy(var Msg: TMessage);
begin
  KillTimer(HWindow, 1);
  inherited WMDestroy(Msg);
end;

function  TChessWindow.GetClassName: PChar;
begin
  GetClassName := 'TPWOWLChess';
end;

procedure TChessWindow.GetWindowClass(var WC: TWndClass);
var
  LB: TLogBrush;
begin
  inherited GetWindowClass(WC);
  WC.Style := cs_ByteAlignWindow;
  WC.hCursor := 0;
  { Duplicate the BWCCPattern brush.  hbrBackground brush will be destroyed
    when our window is closed.  If we didn't duplicate this brush, but just
    used BWCCGetPattern's result directly, BWCC could be left without
    a valid background brush when our window closes.  }
  GetObject(BWCCGetPattern, SizeOf(LB), @LB);
  WC.hbrBackground := CreateBrushIndirect(LB);
  { !! add icon here }
end;

procedure TChessWindow.RestartGame;
var
  Cursor : HCursor;
begin
  UpdateWindow(HWindow);  { Clean up after the dialog that just closed }
  Cursor := SetCursor(LoadCursor(0, idc_Wait));
  if ActiveTimer <> nil then
    ActiveTimer^.Stop;
  Timer[cWhite]^.Clear;
  Timer[cBlack]^.Clear;
  MoveHistory^.FreeAll;
  EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or
                                         mf_Disabled or mf_Grayed);
  EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or
                                         mf_Disabled or mf_Grayed);
  DisposeGame(Game);
  ShowMsg(cxChessError, Ord(NewGame(Game)));
  ThinkState := GetSearchStatus(Game);
  Board^.ResetBoard(Game);
  SetCursor(Cursor);
end;

function TChessWindow.CanClose: Boolean;
begin
  CanClose := inherited CanClose and
              ((ThinkState = ssGameOver) or
               (MoveHistory^.Count = 0) or
               (MessageBox(HWindow, PChar(strCancelGame),
                 PChar(strLeaveGame), mb_YesNo) = id_Yes));
  UpdateWindow(HWindow);    { Clean up after the message box asap }
end;

function  TChessWindow.IdleAction: Boolean;
var
  OldState: TSearchStatus;
  Value: Integer;
  Line: array [0..15] of TMove;
begin
  OldState := ThinkState;
  if (OldState = ssMoveSearch) and (ActiveTimer <> nil) then
    ActiveTimer^.Start;
  Think(Game, ChessSettings.ThinkTime.Position, ThinkState);
    { Return True if we want to continue to get IdleAction calls ASAP,
      Return False if we don't need more IdleAction immediately }
  if (OldState = ssMoveSearch) and (ActiveTimer <> nil) then
    ActiveTimer^.Stop;
  IdleAction := False;
  if (ThinkState = ssComplete) and (OldState <> ssComplete) then
    AcceptComputerMove
  else
  if (ThinkState = ssGameOver) and (Oldstate <> ssGameOver) then
    GameOver
  else
    IdleAction := True;  { continue calling IdleAction - still thinking }
end;

function  TChessWindow.ShowMsg(const Ctx, MsgCode: Integer): Integer;
var
  S: array [0..100] of Char;
begin
  S[0] := #0;
  if MsgCode <> 0 then
    LoadString(HInstance, Ctx + MsgCode, S, SizeOf(S));
  InfoPane^.Msg^.SetText(S);
  ShowMsg := MsgCode;
end;

procedure TChessWindow.ReportGameState;
var State: TChessStatus;
    Count: Integer;
begin
  State := GetChessStatus(Game, Count);
  ShowMsg(cxChessState, ord(State));
  InfoPane^.Update(Game, Timer[cWhite]^.GetCurrentTicks,
                         Timer[cBlack]^.GetCurrentTicks);
end;

procedure TChessWindow.RecordMove(const Move: TMove);
begin
  if MoveHistory^.Count = 0 then  { Enable the menu on first move }
    EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or mf_Enabled);
  if MoveHistory^.RedoAvail then  { not any more...}
    EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or mf_Disabled
                                                        or mf_Grayed);
  MoveHistory^.AddMove(Move);
end;

procedure TChessWindow.StartComputerMove;
var
  TimeLimit : Longint;
begin
  with ChessSettings do
  begin
    if NoLimit then
      TimeLimit := MaxLongint
    else {if LimitTurn then}  {!! do matchuser and limitgame}
      TimeLimit := TurnTime * 18;
  end;
  ComputerMove(Game, TimeLimit);
end;


procedure TChessWindow.AcceptComputerMove;
var
  Move: TMove;
begin
  GetLastMove(Game, Move);
  RecordMove(Move);
  Board^.ExecuteMove(Move);
  ReportGameState;
  if Mode = AutoPlay then
    StartComputerMove
  else
  begin
    Board^.Enable;
    SetMenu(HWindow, Attr.Menu);
    Board^.ResetValidMoves;
    ActiveTimer := Timer[GetPlayer(Game)];
    ActiveTimer^.Start;
    EnableMenuItem(Attr.Menu, cm_PauseGame, mf_ByCommand or mf_Enabled);
  end;
end;

procedure TChessWindow.GameOver;
begin
  if GetPlayer(Game) = cWhite then
    MessageBox(HWindow, PChar(strWhiteWins), PChar(strGameOver), mb_OK)
  else
    MessageBox(HWindow, PChar(strBlackWins), PChar(strGameOver), mb_OK);
end;

function TChessWindow.LoadGame(FileName: PChar): Boolean;
var
  S: PBufStream;
  Test: array [0..SizeOf(ChessSignature)] of Char;
  NewMoveList : PMoveList;
  X: Integer;

  function ReplayMoves(P: PMove): Boolean; far;
  begin
    SubmitMove(Game, P^.Change);
    Board^.ExecuteMove(P^);
    ReplayMoves := (X >= MoveHistory^.UndoPos);
    Inc(X);
  end;

begin
  LoadGame := False;
  S := New(PBufStream, Init(FileName, stOpenRead, 1024));
  S^.Read(Test, SizeOf(ChessSignature));
  if S^.Status <> stOK then
    MessageBox(HWindow, PChar(Context(cxStreamError, S^.Status)),
                        PChar(strLoadError), mb_Ok)
  else
  if StrLComp(ChessSignature, Test, SizeOf(ChessSignature)) <> 0 then
    MessageBox(HWindow, PChar(strNotAChessFile),
                        PChar(strInvalidFile), mb_Ok)
  else
  begin
    NewMoveList := PMoveList(S^.Get);
    if S^.Status <> stOK then
      MessageBox(HWindow, PChar(Context(cxStreamError, S^.Status)),
                          PChar(strLoadError), mb_Ok)
    else
    begin
      RestartGame;
      Dispose(MoveHistory, Done);
      MoveHistory := NewMoveList;
      X := 0;
      MoveHistory^.FirstThat(@ReplayMoves);
      if MoveHistory^.UndoAvail then
        EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or mf_Enabled);
      if MoveHistory^.RedoAvail then
        EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or mf_Enabled);
      Board^.ResetValidMoves;
      ReportGameState;
      LoadGame := True;
    end;
  end;
  Dispose(S, Done);
end;

function TChessWindow.SaveGame(FileName: PChar): Boolean;
var
  S: PBufStream;
begin
  S := New(PBufStream, Init(FileName, stCreate, 1024));
  S^.Write(ChessSignature, SizeOf(ChessSignature));
  S^.Put(MoveHistory);
  if S^.Status <> stOK then
    MessageBox(HWindow, PChar(Context(cxStreamError, S^.Status)),
                        PChar(strSaveError), mb_Ok);
  SaveGame := S^.Status = stOK;
  Dispose(S, Done);
end;

procedure TChessWindow.AMSubmitMove(var Msg: TMessage);
var
  Move: TMove;
begin
  Msg.Result := ShowMsg(cxChessError, Ord(SubmitMove(Game, PChange(Msg.LParam)^)));
    { Result = True if SubmitMove returns zero, else Result = False }
  LongBool(Msg.Result) := not LongBool(Msg.Result);
  if LongBool(Msg.Result) then
  begin
    if ActiveTimer <> nil then
      ActiveTimer^.Stop;
    ActiveTimer := Timer[GetPlayer(Game)];
    GetLastMove(Game, Move);       { Retrieve the full move from the engine }
    RecordMove(Move);              { Enter in history list, enable Redo menu}
    Board^.ExecuteMove(Move);      { Adjust the board }
    ReportGameState;
(*    if ChessSettings.TwoPlayer then
    begin
      Player := GetPlayer(Game);
      Board^.ResetValidMoves;       { Refresh the valid move tables }
      ActiveTimer^.Start;
    end
    else
*)    begin
      StartComputerMove;
      ThinkState := GetSearchStatus(Game);
      SetMenu(HWindow, ThinkMenu);
      Board^.Disable;              { Prevent mouse dragging of pieces }
      EnableMenuItem(Attr.Menu, cm_PauseGame, mf_ByCommand or mf_Disabled or mf_Grayed);
    end;
  end;
end;

procedure TChessWindow.CMNewGame(var Msg: TMessage);
begin
  if (ThinkState = ssGameOver) or
     (MoveHistory^.Count = 0) or
     (MessageBox(HWindow, PChar(strCancelGame),
        PChar(strStartNewGame), mb_YesNo) = id_Yes) then
  begin
    RestartGame;
  end;
end;

procedure TChessWindow.CMLoadGame(var Msg: TMessage);
var
  Temp : array [0..fsPathName] of Char;
begin
  StrCopy(Temp, GameFileName);
  if ((ThinkState = ssGameOver) or
     (MoveHistory^.Count = 0) or
     (MessageBox(HWindow, PChar(strCancelGame),
        PChar(strLoadSavedGame), mb_YesNo) = id_Yes))
    and
     (XApp^.ExecDialog(New(PCDFileOpen, Init(@Self,
        ofn_FileMustExist, Temp, SizeOf(Temp),
        ChessFileFilter))) = idOk) then
    if LoadGame(Temp) then
      StrCopy(GameFileName, Temp);
end;

procedure TChessWindow.CMSaveGame(var Msg: TMessage);
begin
  if GameFileName[0] = #0 then
    CMSaveAs(Msg)
  else
    SaveGame(GameFileName);
end;

procedure TChessWindow.CMSaveAs(var Msg: TMessage);
var
  Temp : array [0..fsPathName] of Char;
begin
  StrCopy(Temp, GameFileName);
  if XApp^.ExecDialog(New(PCDFileSaveAs, Init(@Self,
      ofn_PathMustExist, Temp, SizeOf(Temp), ChessFileFilter))) = idOk then
    if SaveGame(Temp) then
      StrCopy(GameFileName, Temp);
end;

procedure TChessWindow.CMPauseGame(var Msg: TMessage);
var
  P: PChar;
begin
  if ActiveTimer = Timer[Player] then
  begin
    ActiveTimer^.Stop;
    ActiveTimer := nil;
    ModifyMenu(Attr.Menu, cm_PauseGame, mf_ByCommand or mf_String,
                           cm_PauseGame, StrNewRes(P, PChar(strResumeMenu)));
    StrDispose(P);
    Board^.Disable;
  end
  else
    if ActiveTimer = nil then
    begin
      ActiveTimer := Timer[GetPlayer(Game)];
      ActiveTimer^.Start;
      ModifyMenu(Attr.Menu, cm_PauseGame, mf_ByCommand or mf_String,
                             cm_PauseGame, StrNewRes(P, PChar(strPauseMenu)));
      StrDispose(P);
      Board^.Enable;
    end;
end;


procedure TChessWindow.CMUndoMove(var Msg: TMessage);
var
  M : TMove;
  RedoBefore, UndoBefore: Boolean;
begin
  { No error checking is performed here - it is assumed that the
    menu enable/disable code will only allow the user
    to select this menu item when there is a valid undo available. }

  UndoBefore := MoveHistory^.UndoAvail;
  RedoBefore := MoveHistory^.RedoAvail;

  MoveHistory^.Undo(M);
  RetractMove(Game, M);
  Board^.RetractMove(M);

  if Mode = SinglePlayer then  { Undo both player's and computer's move }
  begin
    MoveHistory^.Undo(M);
    RetractMove(Game, M);
    Board^.RetractMove(M);
  end;
  if MoveHistory^.RedoAvail and not RedoBefore then
    EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or mf_Enabled);
  if (not MoveHistory^.UndoAvail) and UndoBefore then
   EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or
                                          mf_Disabled or mf_Grayed);
  Board^.ResetValidMoves;
end;

procedure TChessWindow.CMRedoMove(var Msg: TMessage);
var
  M : TMove;
  RedoBefore, UndoBefore: Boolean;
begin
  { No error checking is performed here - it is assumed that the
    menu enable/disable code will only allow the user
    to select this menu item when there is a valid redo available. }
  UndoBefore := MoveHistory^.UndoAvail;
  RedoBefore := MoveHistory^.RedoAvail;

  MoveHistory^.Redo(M);
  SubmitMove(Game, M.Change);
  Board^.ExecuteMove(M);

  if Mode = SinglePlayer then
  begin
    MoveHistory^.Redo(M);  { Redo both player's and computer's moves }
    SubmitMove(Game, M.Change);
    Board^.ExecuteMove(M);
  end;

  { Update the menus, but only when the undo/redo state changes
    (to avoid menubar flicker caused by unnecessary menu changes) }
  if (not MoveHistory^.RedoAvail) and RedoBefore then
    EnableMenuItem(Attr.Menu, cm_RedoMove, mf_ByCommand or
                                           mf_Disabled or mf_Grayed);
  if MoveHistory^.UndoAvail and not UndoBefore then
    EnableMenuItem(Attr.Menu, cm_UndoMove, mf_ByCommand or mf_Enabled);
  Board^.ResetValidMoves;
end;

procedure TChessWindow.CMSettings(var Msg: TMessage);
begin
  XApp^.ExecDialog(new(PSettingsDlg, Init(@Self, PChar(dlgSettings),
                                                 ChessSettings)));
end;

procedure TChessWindow.CMStopThinking(var Msg: TMessage);
begin
  if ThinkState = ssMoveSearch then
    ForceMove(Game);     { Move search will terminate at next Think call }
end;

procedure TChessWindow.WMTimer(var Msg: TMessage);
begin
  InfoPane^.Update(Game, Timer[cWhite]^.GetCurrentTicks,
                         Timer[cBlack]^.GetCurrentTicks);
end;

procedure TChessWindow.WMSetCursor(var Msg: TMessage);
begin
  DefWndProc(Msg);
  Msg.Result := 1;  { Cancel any pending WMSetCursor in children }
  if (ThinkState = ssMoveSearch) and (Msg.LParamLo = HTClient) then
    SetCursor(LoadCursor(0, PChar(idc_Wait)))
  else
  begin
    if Msg.WParam = Board^.HWindow then
      Msg.Result := 0   { Allow Board to use its own cursor }
    else
      SetCursor(LoadCursor(0, PChar(idc_Arrow)));
  end;
end;


procedure TChessApp.InitMainWindow;
begin
  MainWindow := new(PChessWindow, Init(nil, 'OWL Chess'));
end;

function TChessApp.IdleAction: Boolean;
begin
  IdleAction := PChessWindow(MainWindow)^.IdleAction;
end;

var
  App: TChessApp;

begin
  RegisterType(RMoveList);
  App.Init('OWL Chess');
  App.Run;
  App.Done;
end.
