unit Board;

interface

{$IFDEF DLL}
uses Views, Objects, ChessCmd, ChessDLL, MoveList, Drivers,
  StdDlg, Dos, CTimers;
{$ELSE}
uses Views, Objects, ChessCmd, ChessInf, MoveList, Drivers,
  StdDlg, Dos, CTimers;
{$ENDIF}

const
  ChessSignature : array [0..33] of Char = 'Borland Pascal Chess saved game'#26#0;

type
  PChessSurface = ^TChessSurface;
  TChessSurface = object(TView)
    procedure Draw; virtual;
  end;

  { Palette layout }
  { 1 = Border }
  { 2 = Black square }
  { 3 = White sqaure }
  { 4 = Black piece }
  { 5 = White piece }

  PChessBoard = ^TChessBoard;
  TChessBoard = object(TGroup)
    Surface: PChessSurface;
    Game: HChess;
    Computer, Player: TColor;
    GameMode: Word;
    MoveHistory: PMoveList;
    GameName: PathStr;
    ChessTimers: array[TColor] of PChessTimer;
    constructor Init(var Bounds: TRect);
    destructor Done; virtual;
    procedure AddToHistory(const AMove: TMove);
    function CanMovePiece(Color: TColor): Boolean;
    function CheckActiveGame: Word;
    procedure ClearBoard;
    procedure DoThink;
    function GetComputerTime: Longint;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitGameBoard;
    function Opponent: TColor;
    procedure Process;
    procedure ReadGame;
    procedure Redo;
    procedure SaveGame;
    procedure SaveGameAs;
    procedure SetGameBoard(const ABoard: TBoard);
    procedure SetupNewGameBoard;
    procedure StartComputerMove;
    procedure Undo;
    function ValidateMove(C: TChange): TChessError;
    function Valid(Command: Word): Boolean; virtual;
    procedure Update;
  end;

{  PStreamBoard = ^TStreamBoard;
  TStreamBoard = object(TObject)
    Board: TBoard;
    Player: TColor;
    constructor Init(const ABoard: TBoard; APlayer: TColor);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
  end;

const
  RStreamBoard: TStreamRec = (
    ObjType: 5002;
    VmtLink: Ofs(TypeOf(TStreamBoard)^);
    Load:    @TStreamBoard.Load;
    Store:   @TStreamBoard.Store);}

const
  ChessBoard: PChessBoard = nil;

implementation
uses Pieces, ChessUtl, Status, App, MsgBox, Strings, ChessSt;

procedure TChessSurface.Draw;
var
  Border, White, Black: Word;
  B: TDrawBuffer;
  I, J, K, Line: Integer;

begin
  Border := GetColor($0101);
  White := GetColor($0202);
  Black := GetColor($0303);
  Line := 0;
  for J := 7 downto 0 do
  begin
    if J = 7 then
    begin
      MoveChar(B, ' ', Border, 2);
      for I := 0 to 7 do
      begin
        MoveChar(B[2 + 6 * I], ' ', Border, 3);
        MoveChar(B[5 + 6 * I], Chr($41 + I), Border, 1);
        MoveChar(B[6 + 6 * I], ' ', Border, 2);
      end;
      MoveChar(B[Size.X - 2], ' ', Border, 2);
      WriteBuf(0, Line, Size.X, 1, B);
      Inc(Line);
    end;
    for I := 0 to 2 do
    begin
      MoveChar(B, ' ', Border, 2);
      if I = 1 then
        MoveChar(B, Chr($31 + J), Border, 1);
      for K := 0 to 7 do
        if (K + J) and 1 = 0 then
          MoveChar(B[2 + 6 * K], '²', Black, 6)
        else MoveChar(B[2 + 6 * K], '°', White, 6);
      MoveChar(B[Size.X - 2], ' ', Border, 2);
      WriteBuf(0, Line, Size.X, 1, B);
      Inc(Line);
    end;
  end;
end;

constructor TChessBoard.Init(var Bounds: TRect);
var
  Color: TColor;
begin
  inherited Init(Bounds);
  EventMask := EventMask or evMove;
  Surface := New(PChessSurface, Init(Bounds));
  Insert(Surface);
  if NewGame(Game) <> ceOK then
    Game := 0
  else SetupNewGameBoard;
  Computer := cBlack;
  Player := cWhite;
  MoveHistory := New(PMoveList, Init(20, 10));
  for Color := cWhite to cBlack do
    ChessTimers[Color] := New(PChessTimer, Init);
  if (StatusDialog <> nil) and (Game <> 0) then
    StatusDialog^.Update(Game, ChessTimers);
  GameMode := Settings.Players;
end;

destructor TChessBoard.Done;
begin
  if Game <> 0 then DisposeGame(Game);
  inherited Done;
end;

procedure TChessBoard.AddToHistory(const AMove: TMove);
var
  ChessPiece: PChessPiece;
begin
  if MoveHistory <> nil then
    MoveHistory^.AddMove(AMove);
end;

function TChessBoard.CanMovePiece(Color: TColor): Boolean;
begin
  CanMovePiece := False;
  if (Game <> 0) and (GetSearchStatus(Game) in [ssComplete, ssThinkAhead]) and
    (Color = GetPlayer(Game)) then CanMovePiece := True;
end;

function TChessBoard.CheckActiveGame: Word;
var
  Result: Word;
begin
  if ((MoveHistory <> nil) and (MoveHistory^.Count <> 0)) then
  begin
    Result := MessageBox('Save currently active game?', nil,
      mfError + mfYesNoCancel + mfInsertInApp);
    if Result = cmYes then SaveGame;
  end else Result := cmOK;
  CheckActiveGame := Result;
end;

procedure TChessBoard.ClearBoard;
var
  KillCollection: TCollection;
begin
  KillCollection.Init(32, 0);
  Message(@Self, evBroadcast, cmRegisterSave, @KillCollection);
  KillCollection.Done;
end;

procedure TChessBoard.DoThink;
begin
  if (Game <> 0) and
    not (GetSearchStatus(Game) in [ssComplete, ssGameOver]) then
    Process;
  Update;
end;

function TChessBoard.GetComputerTime: Longint;
var
  MarkTime: Longint;
begin
  case Settings.TimeMode of
    tmGameLimit,
    tmTurnLimit: GetComputerTime := Settings.TurnTime * 18;
    tmMatchUser:
      begin
        MarkTime := ChessTimers[Opponent]^.GetMarkTime;
        if MarkTime > 0 then
          GetComputerTime := MarkTime
        else GetComputerTime := 5 * 18;
      end;
    tmInfinite:  GetComputerTime := High(Longint);
  end;
end;

function TChessBoard.GetPalette: PPalette;
const
  P: string[Length(CChessBoard)] = CChessBoard;
begin
  GetPalette := @P;
end;

procedure TChessBoard.HandleEvent(var Event: TEvent);
var
  Move: TMove;
begin
  if (Event.What = evMove) and (Event.Command = cmSubmitMove) then
  begin
    ChessTimers[GetPlayer(Game)]^.Stop;
    if SubmitMove(Game, TChange(Event.InfoPtr^)) = ceOK then
    begin
      if GetLastMove(Game, Move) = ceOK then
      begin
        AddToHistory(Move);
        Message(@Self, evMove, cmMovePiece, @Move);
      end;
      if GameMode and gmTwoPlay = gmOnePlay then
        StartComputerMove;
      Exit;
    end;
  end;
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmNew:
            begin
              if CheckActiveGame <> cmCancel then
              begin
                DisposeGame(Game);
                if NewGame(Game) <> ceOK then
                  Game := 0;
                SetupNewGameBoard;
                if Game <> 0 then StatusDialog^.Update(Game, ChessTimers);
              end;
            end;
          cmComputerMove:
            if GetSearchStatus(Game) in [ssComplete, ssThinkAhead] then
            begin
              StartComputerMove;
              ClearEvent(Event);
              Exit;
            end;
          cmRunDemo:
            if GameMode and gmDemo = 0 then
            begin
              GameMode := GameMode or gmDemo;
              if GetSearchStatus(Game) in [ssComplete, ssThinkAhead] then
              begin
                StartComputerMove;
                ClearEvent(Event);
                Exit;
              end;
            end;
          cmStop:
            if (Game <> 0) and (GetSearchStatus(Game) = ssMoveSearch) then
            begin
              ForceMove(Game);
              Computer := GetPlayer(Game);
              Player := Opponent;
              GameMode := GameMode and not gmDemo;
            end;
          cmUndo: Undo;
          cmRedo: Redo;
          cmGameOver:
            MessageBox(^C'Checkmate!', nil, mfInformation + mfOKButton + mfInsertInApp);
          cmSave: SaveGame;
          cmSaveAs: SaveGameAs;
          cmOpen: ReadGame;
        else
          Exit
        end;
        ClearEvent(Event);
      end;
  end;
end;

procedure TChessBoard.InitGameBoard;
var
  I, J: Integer;
  P: PChessPiece;
  R: TRect;
  Board: TBoard;
  Location: TLocation;
  ChessStatus: TChessStatus;
begin
  if Game <> 0 then
  begin
    if GetBoard(Game, Board) = ceOK then
      for J := 1 to 8 do
        for I := 1 to 8 do
          if Board[I, J].Piece <> pEmpty then
          begin
            Location.X := I; Location.Y := J;
            SquareToLocal(Location, R.A, Size.Y);
            R.Assign(R.A.X, R.A.Y, R.A.X + 6, R.A.Y + 3);
            P := New(PChessPiece, Init(R, Board[I, J], Location));
            Insert(P);
          end;
  end;
end;

function TChessBoard.Opponent: TColor;
var
  APlayer: TColor;
begin
  APlayer := GetPlayer(Game);
  Opponent := TColor(Byte(cBlack) - Byte(APlayer));
end;

procedure TChessBoard.Process;
var
  Status: TSearchStatus;
  ChessStatus: TChessStatus;
  Move: TMove;
  Event: TEvent;
  ComputerPlayer: TColor;
  I: Integer;
begin
  if (GetPlayer(Game) = Computer) or (GameMode and gmDemo <> 0) then
  begin
    ComputerPlayer := GetPlayer(Game);
    ChessTimers[ComputerPlayer]^.Start;
    Think(Game, 4, Status);
    ChessTimers[ComputerPlayer]^.Stop;
  end
  else Think(Game, 2, Status);
  case Status of
    ssComplete:
      begin
        if GetLastMove(Game, Move) = ceOK then
        begin
          AddToHistory(Move);
          Message(@Self, evMove, cmMovePiece, @Move);
          if GameMode and gmDemo <> 0 then
            StartComputerMove
          else
          begin
            ChessTimers[GetPlayer(Game)]^.Mark;
            ChessTimers[GetPlayer(Game)]^.Start;
{            ThinkAhead(Game);
            Process;}
          end;
        end;
      end;
    ssGameOver:
      begin
        ChessStatus := GetChessStatus(Game, I);
        Event.What := evCommand;
        Event.Command := cmGameOver;
        Event.InfoInt := Integer(ChessStatus);
        PutEvent(Event);
      end;
  end;
end;

procedure TChessBoard.ReadGame;
var
  S: PBufStream;
  Test: array [0..SizeOf(ChessSignature)] of Char;
  NewMoveList : PMoveList;
  FileDialog: PFileDialog;
  AGameName: PathStr;
  X: Integer;

  function ReplayMoves(P: PMove): Boolean; far;
  begin
    SubmitMove(Game, P^.Change);
    ReplayMoves := (X >= MoveHistory^.UndoPos);
    Message(@Self, evMove, cmMovePiece, P);
    Inc(X);
  end;

begin
  if CheckActiveGame <> cmCancel then
  begin
    FileDialog := New(PFileDialog, Init('*.CHS', 'Open a Game', '~G~ame',
      fdOpenButton, 100));
    if Application^.ExecView(FileDialog) <> cmCancel then
    begin
      FileDialog^.GetFileName(AGameName);
      S := New(PBufStream, Init(AGameName, stOpenRead, 1024));
      S^.Read(Test, SizeOf(ChessSignature));
      if S^.Status <> stOK then
        {!!} MessageBox('Error reading file', nil, mfError + mfOKButton + mfInsertInApp)
      else
      if StrLComp(ChessSignature, Test, SizeOf(ChessSignature)) <> 0 then
        {!!} MessageBox('This is not a chess game file', nil, mfError + mfOKButton + mfInsertInApp)
      else
      begin
        NewMoveList := PMoveList(S^.Get);
        if S^.Status <> stOK then
          {!!} MessageBox('Error reading file', nil, mfError + mfOKButton + mfInsertInApp)
        else
        begin
          ClearBoard;
          DisposeGame(Game);
          if NewGame(Game) <> ceOK then
            Game := 0
          else
          begin
            Dispose(MoveHistory, Done);
            MoveHistory := NewMoveList;
            X := 0;
            InitGameBoard;
            MoveHistory^.FirstThat(@ReplayMoves);
            Update;
          end;
        end;
      end;
      Dispose(S, Done);
    end;
  end;
end;

procedure TChessBoard.Redo;
var
  Move: TMove;
begin
  MoveHistory^.Redo(Move);
  if SubmitMove(Game, Move.Change) = ceOK then
    if GetLastMove(Game, Move) = ceOK then
      Message(@Self, evMove, cmMovePiece, @Move);
  if GameMode = gmOnePlay then
  begin
    MoveHistory^.Redo(Move);
    if SubmitMove(Game, Move.Change) = ceOK then
      if GetLastMove(Game, Move) = ceOK then
        Message(@Self, evMove, cmMovePiece, @Move);
  end;
  Update;
end;

procedure TChessBoard.SaveGame;
var
  S: PBufStream;
begin
  if GameName = '' then
  begin
    SaveGameAs;
    Exit;
  end
  else if Game <> 0 then
  begin
    S := New(PBufStream, Init(GameName, stCreate, 1024));
    S^.Write(ChessSignature, SizeOf(ChessSignature));
    S^.Put(MoveHistory);
    if S^.Status <> stOK then
      {!!} MessageBox('Error writing file', nil, mfError + mfOKButton + mfInsertInApp);
    Dispose(S, Done);
  end;
end;

procedure TChessBoard.SaveGameAs;
var
  FileDialog: PFileDialog;
begin
  FileDialog := New(PFileDialog, Init('*.CHS', 'Save Game As',
    '~S~ave game as', fdOKButton, 101));
  if Application^.ExecView(FileDialog) <> cmCancel then
  begin
    FileDialog^.GetFileName(GameName);
    SaveGame;
  end;
  Dispose(FileDialog, Done);
end;

procedure TChessBoard.SetGameBoard(const ABoard: TBoard);
begin
  if Game <> 0 then
    if SetBoard(Game, ABoard) <> ceOK then
      MessageBox('Error setting game board', nil,
        mfError + mfOKButton + mfInsertInApp);
end;

procedure TChessBoard.SetupNewGameBoard;
var
  Color: TColor;
begin
  ClearBoard;
  InitGameBoard;
  if MoveHistory <> nil then MoveHistory^.FreeAll;
  GameName := '';
  for Color := cWhite to cBlack do
    if ChessTimers[Color] <> nil then
      ChessTimers[Color]^.Clear;
end;

procedure TChessBoard.StartComputerMove;
var
  ComputerTime: Longint;
begin
  ComputerTime := GetComputerTime;
  ChessTimers[GetPlayer(Game)]^.Mark;
  ComputerMove(Game, ComputerTime);
  Process;
end;

procedure TChessBoard.Undo;
var
  Move: TMove;
  R: TRect;
  P: PChessPiece;
begin
  MoveHistory^.Undo(Move);
  if RetractMove(Game, Move) = ceOK then
    Message(@Self, evMove, cmUndoMove, @Move);
  if GameMode = gmOnePlay then
  begin
    MoveHistory^.Undo(Move);
    if RetractMove(Game, Move) = ceOK then
      Message(@Self, evMove, cmUndoMove, @Move);
  end;
  Update;
end;

procedure TChessBoard.Update;
var
  ChessStatus: TChessStatus;
  MateInMoves: Integer;
begin
  if StatusDialog <> nil then StatusDialog^.Update(Game, ChessTimers);
  if MoveHistory <> nil then
  begin
    SetCmdState([cmRedo], (MoveHistory^.RedoAvail) and
      (GameMode and gmDemo = 0) and ((GetPlayer(Game) = Player) or
      (GameMode = gmOnePlay)));
    SetCmdState([cmUndo], (MoveHistory^.UndoAvail) and
      (GameMode and gmDemo = 0) and ((GetPlayer(Game) = Player) or
      (GameMode = gmOnePlay)));
    SetCmdState([cmComputerMove, cmEnterMove, cmShowHint],
      (GameMode and gmDemo = 0) and ((GetPlayer(Game) = Player) or
      (GameMode = gmOnePlay)));
    SetCmdState([cmStop], (GameMode and gmDemo <> 0) or
      (GetSearchStatus(Game) = ssMoveSearch));
  end;
  if StatusLine <> nil then
  begin
    ChessStatus := GetChessStatus(Game, MateInMoves);
    PChessStatusLine(StatusLine)^.SetStatus(ChessStatus, MateInMoves);
  end;
end;

function TChessBoard.ValidateMove(C: TChange): TChessError;
begin
  if (GetSearchStatus(Game) in [ssComplete, ssThinkAhead]) then
    ValidateMove := VerifyMove(Game, C)
  else
    ValidateMove := ceInvalidMove;
end;

function TChessBoard.Valid(Command: Word): Boolean;
begin
  Valid := True;
  if Command = cmQuit then
    Valid := CheckActiveGame <> cmCancel;
end;

{constructor TStreamBoard.Init(const ABoard: TBoard; APlayer: TColor);
begin
  inherited Init;
  Board := ABoard;
  Player := APlayer;
end;

constructor TStreamBoard.Load(var S: TStream);
begin
  inherited Init;
  S.Read(Board, SizeOf(Board) + SizeOf(Player));
end;

procedure TStreamBoard.Store(var S: TStream);
begin
  S.Write(Board, SizeOf(Board) + SizeOf(Player));
end;}

end.
