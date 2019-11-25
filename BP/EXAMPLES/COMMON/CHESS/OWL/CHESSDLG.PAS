{ Dialogs for the OWL Chess program. }

unit chessdlg;

interface

uses Winprocs, Wintypes, OWindows, ODialogs, Validate, ChessDLL, ChConst;

type

  PChessInfoWindow = ^TChessInfoWindow;
  TChessInfoWindow = object(TDlgWindow)
    Msg: PStatic;
    constructor Init(AParent: PWindowsObject; AName: PChar);
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var WC: TWndClass); virtual;
    procedure Update(Game: HChess; WhiteTime, BlackTime: Longint);
  end;

  PSettingsXferRec = ^TSettingsXferRec;
  TSettingsXferRec = record
    LimitGame,
    LimitTurn,
    MatchUser,
    NoLimit:  WordBool;
    GameTime,
    TurnTime: Longint;
    ShowAttacks,
    ShowJeopardies,
    ShowBestLine,
    RightClickHints,
    OnePlayer,
    TwoPlayer: WordBool;
    ThinkTime: TScrollBarTransferRec;
    RefreshRate: Word;   { not used by dialog, keep at bottom of record }
  end;

  PSettingsDlg = ^TSettingsDlg;
  TSettingsDlg = object(TDialog)
    constructor Init(AParent: PWindowsObject; AName: PChar;
                     var XferBuf: TSettingsXferRec);
    procedure SetupWindow; virtual;
    procedure EnableSet(Game, Turn: Boolean);
    procedure ShowSet(Game, Turn: Boolean);
    procedure LimitGameTime(var Msg: TMessage);
      virtual id_First + idLimitGameTime;
    procedure LimitTurnTime(var Msg: TMessage);
      virtual id_First + idLimitTurnTime;
    procedure MatchUserTime(var Msg: TMessage);
      virtual id_First + idMatchUserTime;
    procedure NoTimeLimit(var Msg: TMessage);
      virtual id_First + idNoTimeLimit;
  end;

var
  ChessSettings: TSettingsXferRec;

procedure LoadINISettings;
procedure SaveINISettings;

implementation

uses AppUtils, Strings, CTimers;

  { The LockWindowUpdate function will eliminate all flicker caused by
    switching between the two edit controls set up in the Settings dialog.
    This function is only available in Windows 3.1, though, so in order
    to allow this program to run (with some flicker) in Windows 3.0,
    this program should:

      1) Never call LockWindowUpdate when running under Windows 3.0
      2) Avoid using static declarations (like Win31.pas) to import
         the function, since Windows 3.0 won't load an app if the app
         contains static references to DLL functions Windows 3.0
         doesn't have.

    The following code uses a function variable and GetProcAddress to
    request the address of the LockWindowUpdate function.  Windows 3.0
    will return a nil function address if you ask for a function that
    doesn't exist in the indicated DLL.  Before each use of the
    function variable, test it for nil using the Assigned function.
  }

type
  Win31LockWindowUpdateFunc = function (Wnd: HWnd): Bool;

const
  Win31LockWindowUpdate: Win31LockWindowUpdateFunc = nil;
  AM_InfoUpdate = wm_User + 502;

type
  PUpdateRec = ^TUpdateRec;
  TUpdateRec = record
    Time : array [cWhite..cBlack] of Longint;
  end;

  PTurnDisplay = ^TTurnDisplay;
  TTurnDisplay = object(TWindow)
    Color: TColor;
    Tag: array [cWhite..cBlack] of PChar;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer);
    destructor Done; virtual;
    procedure Paint(DC: HDC; var PS: TPaintStruct); virtual;
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PTimeDisplay = ^TTimeDisplay;
  TTimeDisplay = object(TStatic)
    Color : TColor;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer;
                             ATextLen: Word; AColor: TColor);
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PBestLine = ^TBestLine;
  TBestLine = object(TStatic)
    CurrentLine: array [0..100] of Char;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer);
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

  PValueLine = ^TValueLine;
  TValueLine = object(TStatic)
    CurrentValue: Integer;
    constructor InitResource(AParent: PWindowsObject; ResID: Integer);
    procedure AMInfoUpdate(var Msg: TMessage);
      virtual wm_First + am_InfoUpdate;
  end;

constructor TTurnDisplay.InitResource(AParent: PWindowsObject;
                                      ResID: Integer);
begin
  inherited InitResource(AParent, ResID);
  Color := cWhite;
  StrNewRes(Tag[cWhite], PChar(strWhite));
  StrNewRes(Tag[cBlack], PChar(strBlack));
end;

destructor TTurnDisplay.Done;
begin
  StrDispose(Tag[cWhite]);
  StrDispose(Tag[cBlack]);
  inherited Done;
end;

procedure TTurnDisplay.Paint(DC: HDC; var PS: TPaintStruct);
var
  R: TRect;
  TE: Integer;
begin
  SaveDC(DC);
  GetClientRect(HWindow, R);
  if Color = cBlack then
  begin
    SetTextColor(DC, RGB(255,255,255));
    SetBkColor(DC, RGB(0,0,0));
    PatBlt(DC, R.Left, R.Top, R.Right, R.Bottom, Blackness);
  end
  else
  begin
    SetTextColor(DC, RGB(0,0,0));
    SetBkColor(DC, RGB(255,255,255));
    PatBlt(DC, R.Left, R.Top, R.Right, R.Bottom, Whiteness);
  end;
  TE := GetTextExtent(DC, Tag[Color], StrLen(Tag[Color]));
  TextOut(DC, (R.Right div 2) - (LoWord(TE) div 2), 0,
                 Tag[Color], StrLen(Tag[Color]));
  RestoreDC(DC, -1);
end;

procedure TTurnDisplay.AMInfoUpdate(var Msg: TMessage);
begin
  if GetPlayer(HChess(Msg.WParam)) <> Color then
  begin
    Color := GetPlayer(HChess(Msg.WParam));
    InvalidateRect(HWindow,nil,False);
  end;
end;

constructor TTimeDisplay.InitResource(AParent: PWindowsObject;
                                      ResID: Integer;
                                      ATextLen: Word;
                                      AColor: TColor);
begin
  inherited InitResource(AParent, ResID, ATextLen);
  Color := AColor;
end;

procedure TTimeDisplay.AMInfoUpdate(var Msg: TMessage);
var
  s: array [0..20] of Char;
  P: array [0..3] of Word;
begin
 if GetPlayer(HChess(Msg.WParam)) = Color then
 begin
   ConvertTicks(PUpdateRec(Msg.LParam)^.Time[Color],P[0],P[1],P[2],P[3]);
   WVSprintf(S, '%02i:%02i:%02i.%03i', P);
   SetText(S);
 end;
end;

constructor TBestLine.InitResource(AParent: PWindowsObject; ResID: Integer);
begin
  inherited InitResource(AParent, ResID, 100);
  CurrentLine[0] := #0;
end;

procedure TBestLine.AMInfoUpdate(var Msg: TMessage);
var
  Value: Integer;
  Line: array [0..23] of TMove;
  S: array [0..8] of Char;
  NewLine : array [0..100] of Char;
  X, L: Integer;
begin
  NewLine[0] := #0;
  if ChessSettings.ShowBestLine then
  begin
    GetMainLine(HChess(Msg.WParam), Value, Line);
    X := 0;
    L := 0;
    while (X <= High(Line))
      and (Line[X].Change.Piece <> pEmpty)
      and (L <= (High(NewLine) - High(S))) do
    begin
      MoveToStr(Line[X],S);
      StrCopy(@NewLine[L],StrCat(S, ' '));
      Inc(L, StrLen(S));
      Inc(X);
    end;
  end;
  if StrComp(CurrentLine, NewLine) <> 0 then
  begin
    SetText(NewLine);
    StrCopy(CurrentLine, NewLine);
  end;
end;

constructor TValueLine.InitResource(AParent: PWindowsObject;
                                    ResID: Integer);
begin
  inherited InitResource(AParent, ResID, 10);
  CurrentValue := 0;
end;

procedure TValueLine.AMInfoUpdate(var Msg: TMessage);
var
  Value: Integer;
  Move: TMove;
  S: array [0..10] of Char;
begin
  GetMainLine(HChess(Msg.WParam), Value, Move);
  if Value <> CurrentValue then
  begin
    Str(Value, S);
    SetText(S);
    CurrentValue := Value;
  end;
end;


constructor TChessInfoWindow.Init(AParent: PWindowsObject; AName: PChar);
var
  Dummy : PWindowsObject;
begin
  inherited Init(AParent, AName);
  Msg := New(PStatic, InitResource(@Self, idInfoMsg, 50));
  Dummy := New(PValueLine, InitResource(@Self, idInfoValue));
  Dummy := New(PBestLine, InitResource(@Self, idInfoBestLine));
  Dummy := New(PTimeDisplay, InitResource(@Self, idInfoWhite, 30, cWhite));
  Dummy := New(PTimeDisplay, InitResource(@Self, idInfoBlack, 30, cBlack));
  Dummy := New(PTurnDisplay, InitResource(@Self, idInfoTurn));
end;

function TChessInfoWindow.GetClassName: PChar;
begin
  GetClassName := 'BorDlg_ChessInfo';
end;

procedure TChessInfoWindow.GetWindowClass(var WC: TWndClass);
begin
  inherited GetWindowClass(WC);
  WC.hCursor := 0;      { reflect wm_setcursor back to parent window }
end;

procedure TChessInfoWindow.Update(Game: HChess; WhiteTime, BlackTime: Longint);
var
  N: TUpdateRec;

  procedure DoUpdate(P: PWindowsObject); far;
  begin
    SendMessage(P^.HWindow, AM_InfoUpdate, Game, Longint(@N));
  end;

begin
  N.Time[cWhite] := WhiteTime;
  N.Time[cBlack] := BlackTime;
  ForEach(@DoUpdate);
end;


constructor TSettingsDlg.Init(AParent: PWindowsObject;
                              AName: PChar;
                              var XferBuf: TSettingsXferRec);
var
  P : PWindowsObject;
begin
  inherited Init(AParent, AName);
  P := New(PRadioButton, InitResource(@Self, idLimitGameTime));
  P := New(PRadioButton, InitResource(@Self, idLimitTurnTime));
  P := New(PRadioButton, InitResource(@Self, idMatchUserTime));
  P := New(PRadioButton, InitResource(@Self, idNoTimeLimit));
  P := New(PEdit, InitResource(@Self, idLimitGameTimeInput, TimeLimitInputLen));
  PEdit(P)^.SetValidator(New(PRangeValidator, Init(1, 600)));
  with PEdit(P)^.Validator^ do
    Options := Options or voTransfer;
  P := New(PEdit, InitResource(@Self, idLimitTurnTimeInput, TimeLimitInputLen));
  PEdit(P)^.SetValidator(New(PRangeValidator, Init(1, 36000)));
  with PEdit(P)^.Validator^ do
    Options := Options or voTransfer;
  P := New(PCheckBox, InitResource(@Self, idShowAttacks));
  P := New(PCheckBox, InitResource(@Self, idShowJeopardies));
  P := New(PCheckBox, InitResource(@Self, idShowBestLine));
  P := New(PCheckBox, InitResource(@Self, idRightClickQueries));
  P := New(PRadioButton, InitResource(@Self, idSinglePlayer));
  P := New(PRadioButton, InitResource(@Self, idTwoPlayer));
  P := New(PScrollbar, InitResource(@Self, idThinkTime));
  P^.EnableTransfer;
  TransferBuffer := @XferBuf;
end;

procedure TSettingsDlg.SetupWindow;
begin
  inherited SetupWindow;
  with PSettingsXferRec(TransferBuffer)^ do
    ShowSet(LimitGame, LimitTurn);
end;

procedure TSettingsDlg.EnableSet(Game, Turn: Boolean);
begin
  EnableWindow(GetItemHandle(idLimitTurnTimeLabel), Turn);
  EnableWindow(GetItemHandle(idLimitTurnTimeInput), Turn);
  EnableWindow(GetItemHandle(idTurnTimeUnit), Turn);
  EnableWindow(GetItemHandle(idLimitGameTimeLabel), Game);
  EnableWindow(GetItemHandle(idLimitGameTimeInput), Game);
  EnableWindow(GetItemHandle(idGameTimeUnit), Game);
end;

procedure TSettingsDlg.ShowSet(Game, Turn: Boolean);
const
  sw : array [False..True] of Word = (sw_Hide, sw_Show);
begin
  if Assigned(Win31LockWindowUpdate) then
    Win31LockWindowUpdate(HWindow);
  ShowWindow(GetItemHandle(idLimitTurnTimeInput), sw[Turn]);
  ShowWindow(GetItemHandle(idLimitTurnTimeLabel), sw[Turn]);
  ShowWindow(GetItemHandle(idTurnTimeUnit), sw[Turn]);
  ShowWindow(GetItemHandle(idLimitGameTimeInput), sw[Game]);
  ShowWindow(GetItemHandle(idLimitGameTimeLabel), sw[Game]);
  ShowWindow(GetItemHandle(idGameTimeUnit), sw[Game]);
  if Assigned(Win31LockWindowUpdate) then
    Win31LockWindowUpdate(0);
  EnableSet(Game, Turn);
end;

procedure TSettingsDlg.LimitGameTime(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if Msg.LParamHi = BN_Clicked then
    ShowSet(True, False);
end;

procedure TSettingsDlg.LimitTurnTime(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if Msg.LParamHi = BN_Clicked then
    ShowSet(False, True);
end;                                           

procedure TSettingsDlg.MatchUserTime(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if Msg.LParamHi = BN_Clicked then
    EnableSet(False, False);
end;

procedure TSettingsDlg.NoTimeLimit(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if Msg.LParamHi = BN_Clicked then
    EnableSet(False, False);
end;


procedure LoadINISettings;
var
  I: Longint;
begin
  FillChar(ChessSettings, SizeOf(ChessSettings), 0);
  with ChessSettings, XApp^ do
  begin
    I := GetAppProfileLongint('Settings','TimeLimitType',2);
    case I of
      1: LimitGame := True;
      2: LimitTurn := True;
      4: MatchUser := True;
      8: NoLimit   := True;
    else
      {!! Display error msg }
      LimitTurn := True;
    end;
    TurnTime := GetAppProfileLongint('Settings','SecsPerTurn',60);
    GameTime := GetAppProfileLongint('Settings','MinsPerGame',30);
    ShowAttacks := GetAppProfileBoolean('Settings','ShowAttacks',True);
    ShowJeopardies := GetAppProfileBoolean('Settings',
                                           'ShowJeopardies',True);
    ShowBestLine := GetAppProfileBoolean('Settings','ShowBestLine',True);
    RightClickHints := GetAppProfileBoolean('Settings',
                                            'RightClickHints',True);
    TwoPlayer := GetAppProfileBoolean('Settings','TwoPlayers',False);
    OnePlayer := not TwoPlayer;
    with ThinkTime do
    begin
      LowValue := 1;
      HighValue := 36;
      Position := Integer(GetAppProfileLongint('Settings','TicsPerThink',2));
    end;
    RefreshRate := Word(GetAppProfileLongint('Settings','RefreshRate',500));
  end;
end;

procedure SaveINISettings;
var
  X: Longint;
begin
  with ChessSettings, XApp^ do
  begin
    X := Word(LimitGame) +
         Word(LimitTurn) shl 1 +
         Word(MatchUser) shl 2 +
         Word(NoLimit) shl 3;
    WriteAppProfileLongint('Settings','TimeLimitType',X);
    WriteAppProfileLongint('Settings','SecsPerTurn',TurnTime);
    WriteAppProfileLongint('Settings','MinsPerGame',GameTime);
    WriteAppProfileBoolean('Settings','ShowAttacks',ShowAttacks);
    WriteAppProfileBoolean('Settings','ShowJeopardies',ShowJeopardies);
    WriteAppProfileBoolean('Settings','ShowBestLine',ShowBestLine);
    WriteAppProfileBoolean('Settings','RightClickHints',RightClickHints);
    WriteAppProfileBoolean('Settings','TwoPlayers',TwoPlayer);
    WriteAppProfileLongint('Settings','TicsPerThink',ThinkTime.Position);
    WriteAppProfileLongint('Settings','RefreshRate',RefreshRate);
  end;
end;


begin
      { In Windows 3.0, the following GetProcAddress call will return nil,
        but not cause a critical error message.  Any code that uses
        this function variable should always test it first, with
        the Assigned system function. }
  @Win31LockWindowUpdate := GetProcAddress(
                             GetModuleHandle('User'), PChar(294));
end.