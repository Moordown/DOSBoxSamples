unit GameRec;
{ contains all internal types and the big game context record }

interface

uses ChessInf, LTimer, TaskMgr;

type
  LevelType = (Normal,FullGameTime,DemoGame,
               Infinite,PlySearch,MateSearch);

const
  Back = -104;    { Number of stored moves }
  MaxPly = 23;    { Maximal search depth }
  MaxGames = 5;  { Max number of simultaneous games }

type

  { Squarenumbers. a1=0, b1=1,..., a2=$10,..., h8=$77 }

  SquareType     = $00..$77;   { The 64 squares }
  EdgeSquareType = -$21..$98;

  ColorType      = (White, Black);
  PieceType      = (Empty, King, Queen, Rook, Bishop, Knight, Pawn);

  IndexType      = 0..15;       { Index in PieceTab }

  BoardType      = record
                      Piece : PieceType;   { PieceType }
                      Color : ColorType;   { Color }
                      Index : 0..16;       { Index to PieceTab }
                   end;

{ The MoveType, which is used to represent all moves in the program }
  MoveType = record
                New1, Old : SquareType; { New1 and Old Square }
                Spe:      boolean;    { Indicates special Move:
                                        case MovPiece of
                                         King: Castling
                                         Pawn: E.p. capture
                                         else : Pawnpromotion }
                MovPiece,              { Moving Piece }
                Content :  PieceType;  { Evt. captured Piece }
             end;

const
         { The undefined Move. Testing is Done using MovPiece=Empty }
  ZeroMove : MoveType = (New1    : 8;
                        Old      : 8;
                        Spe      : False;
                        MovPiece : Empty;
                        Content  : Empty);

  Pieces : array[0..7] of PieceType =
       ( Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook );

  PieceLetter : array[Empty..Pawn] of char = ' KQRBNP';

{ The played moves.
  MovTab[Back..Depth] contains all the moves played so far }
type
  DepthType = Back..MaxPly;
  MoveTabType = array[depthtype] of movetype;

  MaxType  = integer;                               { Evaluation type }
  LineType = array[0..MaxPly] of MoveType; { Principal variation type }

  NodeVal = LongInt;

  StateTypes = (GameOver, InLibrary, Analysis, OppAnalysis, MovePending);

  StateSet = set of StateTypes;

  { ReadyForMove = Computer's turn is complete.
                   This may be combined with ThinkAhead.
    StartGameMove= First pass in computer's turn.
                    Exclusive of ReadyForMove
    ThinkAhead   = Computer looks beyond the next turn to better select its
                 next turn, while waiting for human to respond with his
                 next turn.  Compatible with ReadyForMove.
    GameOver   = The game is over.  No more moves will be accepted.
    AutoPlay   = Game plays itself
    MultiMove  = User plays both sides
    SingleStep = Single steps through move searches, for debugging
    InLibrary  = Opening library is being used for move selection
    Analysis   = We're analyzing our moves
    OppAnalysis= We're analyzing the oponent's moves
  }

const
  gmGameMagic = $4246;
   
type
  PGameData = ^TGameData;
  TGameData = record
      Magic: Word;
      { Board contains the Content of each Square,
        Square by Square }
      Board : array[SquareType] of BoardType;

      { PieceTab contains the squares of all the Pieces,
        Piece by Piece.
        Board and PieceTab is two different representations of the
        same position, and they are always changed simultaniously.

        No. 0 is the King,
        No. 1 - OfficerNo is the officers and evt. Pawns,
        No. OfficerNo + 1 - PawnNo is the pawns }

      PieceTab : array[ColorType,IndexType] of
                   record
                      ISquare : SquareType;  { Square and Index to Board }
                      IPiece :  PieceType;                   { PieceType }
                   end;

      { Indexes to PieceTab, used to speed Up the program a Bit }
      OfficerNo, PawnNo : array[ColorType] of - 1..15;

      Player,
      Opponent : ColorType;     { Player is always Next to Move }
      Depth  : DepthType;
      MovTab : MoveTabType;
                                 { The Piece-Value-table }
      PVTable: array[ColorType, King..Pawn, SquareType] of -64..191;

      NextMove : MoveType;                  { The generated move }
      Buffer   : array[1..80] of MoveType;  { Buffer of generated moves }
      BufCount,
      BufPnt : 0..80;                     { Counters for Buffer    }

      ProgramColor :   ColorType;     { Color of program }
      MaxDepth :       integer;       { Search Depth counter }
      LegalMoves :     integer;       { Number of Legal moves }
      MoveNo :         integer;       { Move Number }
      MainLine :       LineType;      { Principal variation }
      MainEvalu :      MaxType;       { Evaluation for
                                        principal variation }
      Nodes :          NodeVal;       { Number of analysed Nodes }
      Clock :          TTaskTimer;    { Time limit per complete turn }
      TaskTimer:       TTaskTimer;    { Time limit per Think period  }

      PlayerMove :     MoveType;

      { The two chess clocks. Running indicates
        that the Clock for RunColor is Running }
      ChessTime :      array[ColorType] of TStopWatch;
      RunColor :       ColorType;
      Running : Boolean;
      KeyMove   : MoveType;
      HintLine  : LineType;   { Suggested Hint Line }
      HintEvalu : MaxType;    { Evaluation for HINTLINT }

      OpCount :  -1..61;            { Opening library }
      LibNo   : integer;
      UseLib  : integer;     { program uses library if MoveNo < UseLib }

      Level        : LevelType;     { LevelType }
      MaxLevel     : byte;          { Maximum Search Depth }
      AverageTime  : Longint;

      Command : string[10];      { text command from user }
      State : StateSet;  { state transitions }
      Engaged: Boolean;
      AppStack,
      GameStack: TTaskInfo;
   end;

var
  GameList: array [1..MaxGames] of TGameData;
  CCHandle: HChess;  { Index of current game context in the GameList }
  CC: TGameData; { Current game context, set by exported DLL functions
                 before performing any game-related operations.  All
                 game operations are done relative to this game context }

implementation

end.