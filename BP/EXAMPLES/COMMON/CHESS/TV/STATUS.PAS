unit Status;

interface

{$IFDEF DLL}
uses Objects, Views, Dialogs, ChessDLL, CTimers;
{$ELSE}
uses Objects, Views, Dialogs, ChessInf, CTimers;
{$ENDIF}

type
  PBestLine = ^TBestLine;
  TBestLine = object(TParamText)
    function GetPalette: PPalette; virtual;
  end;

  PStatusDialog = ^TStatusDialog;
  TStatusDialog = object(TDialog)
    constructor Init(var Bounds: TRect);
    function GetPalette: PPalette; virtual;
    procedure Update(Game: HChess; ATimers: array of PChessTimer);
  end;

  PGameStatus = ^TGameStatus;
  TGameStatus = record
    ToMove:   PString;
    WhtTime:  PString;
    BlkTime:  PString;
    Nodes:    Longint;
    MainLine: PString;
  end;

const
  StatusDialog: PStatusDialog = nil;

  CurPlayer: String[5] = '';
  BestLine: String = '';
  TimeStrs: array [TColor] of String[11] = ('', '');
  GameStatus: TGameStatus = (
    ToMove:   @CurPlayer;
    WhtTime:  @TimeStrs[cWhite];
    BlkTime:  @TimeStrs[cBlack];
    Nodes:    0;
    MainLine: @BestLine
  );

implementation
uses Strings, ChessCmd, Drivers;

function TBestLine.GetPalette: PPalette;
const
  P: string[Length(CBestLine)] = CBestLine;
begin
  GetPalette := @P;
end;

constructor TStatusDialog.Init(var Bounds: TRect);
var
  R: TRect;
begin
  inherited Init(Bounds, '');
  Flags := 0;
  R.Assign(1, 2, Size.X - 1, 7);
  Insert(New(PParamText, Init(R,
    'To Move:  %s'#13 +
    'White:    %s'#13 +
    'Black:    %s'#13 +
    'Nodes:    %d'#13, 4)));
  R.Assign(1, Size.Y - 10, Size.X - 1, Size.Y - 9);
  Insert(New(PStaticText, Init(R, 'Bestline:')));
  R.Assign(1, Size.Y - 9, Size.X - 1, Size.Y - 1);
  Insert(New(PBestLine, Init(R, '%s', 1)));
  SetData(GameStatus);
end;

function TStatusDialog.GetPalette: PPalette;
const
  P: string[Length(CStatusDialog)] = CStatusDialog;
begin
  GetPalette := @P;
end;

{$V-}
procedure TStatusDialog.Update(Game: HChess;
  ATimers: array of PChessTimer);
var
  MLine: array[0..10] of TMove;
  MainValue: Integer;
  Str: array[0..20] of Char;
  I: Integer;
  Params: array[0..3] of Longint;

  procedure GetTime(ATimer: PChessTimer;
    var Hours, Minutes, Seconds, Ticks: Longint);
  var
    H, M, S, T: Word;
  begin
    ConvertTicks(ATimer^.GetCurrentTicks, H, M, S, T);
    Hours := H;
    Minutes := M;
    Seconds := S;
    Ticks := T;
  end;

begin
  if GetPlayer(Game) = cWhite then
    CurPlayer := 'White'
  else CurPlayer := 'Black';
  GameStatus.Nodes := GetNodes(Game);
  for I := Low(ATimers) to High(ATimers) do
  begin
    GetTime(ATimers[I], Params[0], Params[1], Params[2], Params[3]);
    FormatStr(TimeStrs[TColor(I)], '%02d:%02d:%02d.%02d', Params);
  end;
  GetMainLine(Game, MainValue, MLine);
  BestLine := '';
  for I := Low(MLine) to High(MLine) do
  begin
    if MLine[I].Change.Piece <> pEmpty then
    begin
      MoveToStr(MLine[I], Str);
      BestLine := BestLine + StrPas(Str) + ' ';
    end else Break;
  end;
  SetData(GameStatus);
end;

end.