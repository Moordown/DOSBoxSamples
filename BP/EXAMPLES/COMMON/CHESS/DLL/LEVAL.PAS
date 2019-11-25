{                             EVALU.CH
                              CHESS 4.0
            Copyright (c) 1985, 87 by Borland International, Inc.

  This module evaluates the current game positions.

}
unit LEval;

interface

function FindMove(MaxLevel : integer): integer;
procedure InitPawnStrTables;

implementation

uses Strings, GameRec, LBoard, LMovegen, LMoves, LTimer, TaskMgr, GameTask;


type
  FileType  = 0..7;   { file numbers }
  RankType  = 0..7;   { Rank numbers }

const { Evaluation parameters }

  { Value of Pieces used in Evaluation }

  PieceValue : array[Empty..Pawn] of integer =
    (0, $1000, $900, $4C0, $300, $300, $100);
  Tolerance = 8;   { Tolerance Width }
  { Used to calculate distance to center }
  DistAn : array[0..7] of integer = (3,2,1,0,0,1,2,3);
  { The Value of a Pawn is the sum of Rank and file values.
    The file Value is equal to PawnFileFactor * (Rank Number + 2) }
  PawnRank : array [RankType] of integer = (0,0, 0, 2, 4, 8,30,0);
  PassPawnRank : array [RankType] of integer = (0,0,10,20,40,60,70,0);
  PawnFileFactor :  array [FileType] of integer = (0,0,2,5,6,2,0,0);

  { Value of castling (Long..Short) }
  CastValue :      array[CastDirType] of integer = (4,32);
  { Value of exchanging Pieces (not pawns) when ahead }
  ExchangeValue = 32;
  { Pawnstructure values }
  IsolatedPawn  = 20;   { Isolated Pawn.
                          Double isolated Pawn is 3 * 20 }
  DoublePawn    =  8;   { Double Pawn }
  SidePawn      =  6;   { Having a Pawn On the side }
  ChainPawn     =  3;   { Being covered by a Pawn }
  CoverPawn     =  3;   { Covering a Pawn }
  NotMovePawn   =  3;   { Penalty for moving Pawn }

  { Penalty for Bishop blocking d2/e2 Pawn }
  BishopBlockValue   = 20;
  { Bonus for Rook behind passed Pawn }
  RookBehindPassPawn = 16;
  { Values for calculating importance of each Square (AttVal) }
  SquareRankValue : array [RankType] of byte = (0,0,0,0,1,2,4,4);

{ Pawnstructure table.
  One and Dob are SETs of FILEs, and contains
  the FILEs which has One respectively more pawns.
  The table is updated and evaluated at each Ply in the Search.
  FileBitTab is used to lookup a file in a set of FILEs }

type
  SetofFile   = byte;
  PawnBitRec  = record
                  One,Dob : SetofFile;
                 end;
  PawnBitType = array [ColorType] of PawnBitRec;

const
  FileBitTab : array [FileType] of SetofFile = (1,2,4,8,$10,$20,$40,$80);


function PiecePosVal(Piece :  PieceType;
                     Color :  ColorType;
                    Square : SquareType) : integer;
{ Calculates the Value of the Piece On the Square }
begin
   PiecePosVal := PieceValue[Piece] + CC.PVTable[Color,Piece,Square];
end;


var
  PawnStrDob: array[0..255] of Byte;
  PawnStrIso: array[0..255] of Byte;

procedure InitPawnStrTables;
var
  I: Integer;

   function BitCount(B: SetOFFile): Integer; assembler;
   asm
	XOR	AX,AX
	MOV	DL,B
	MOV	CX,8
	CLC
@@1:    SHR	DL,1
	JNC	@@2
	INC	AX
@@2:    JZ	@@3
	LOOP	@@1
@@3:
   end;

begin
  for I := 0 to 255 do
  begin
    PawnStrDob[I] := BitCount(I) * DoublePawn;
    PawnStrIso[I] := BitCount(I) * IsolatedPawn;
  end;
end;

function PawnStrVal(var PB: PawnBitRec): Integer; near; assembler;
asm
	XOR	AX,AX
	LES	DI,PB
        MOV	AL,ES:[DI].PawnBitRec.One
	MOV	CX,AX
        MOV	BX,AX
	SHR	CX,1
        SHL	BX,1
        OR	CX,BX
        NOT	CX
        MOV	BX,AX
        AND	BX,CX
        MOV	AL,ES:[DI].PawnBitRec.Dob
        MOV	SI,AX
        MOV	AL,BYTE PTR PawnStrDob[SI]
        ADD	AL,BYTE PTR PawnStrIso[BX]
        ADC	AH,0
	AND	BL,ES:[DI].PawnBitRec.Dob
        ADD	AL,BYTE PTR PawnStrIso[BX]
        ADC	AH,0
        ADD	AL,BYTE PTR PawnStrIso[BX]
        ADC	AH,0
        NEG	AX
end;


(*	        
function PawnStrVal( PB: PawnBitRec) : integer;
{ Calculate Value of the Pawn structure in PawnBit[Depth,Color] }

var
  Iso : SetofFile;   { Contains FILEs with isolated pawns }
  V1, V2: Integer;
begin
  with PB do
  begin
    Iso := One and not ((One shl 1) or (One shr 1));
    V1 := -(PawnStrDob[Dob] +
            PawnStrIso[Iso] +
            (PawnStrIso[Iso and Dob] shl 1));
    V2 := NewPawnStrVal(PB);
    if V1 <> V2 then
      asm int 3 end;
    PawnStrVal := V1;
  end;
end;
*)

(* old code:

function PawnStrVal( Depth : DepthType;   Color : ColorType) : integer;
{ Calculate Value of the Pawn structure in PawnBit[Depth,Color] }

   function Count(b : SetofFile) : integer;
   { Counts the Number of set bits in B }
   var Cnt : 0..8;
   begin
      Cnt := 0;
      while b <> 0 do
      begin
         if odd(b) then Cnt := Succ(Cnt);
         b := b shr 1;
      end;
      Count := Cnt;
   end;

var   Iso : SetofFile;   { Contains FILEs with isolated pawns }
begin
  with PawnBit[Depth,Color] do
  begin
    Iso := One and not ((One shl 1) or (One shr 1));
    PawnStrVal := -(Count(Dob) * DoublePawn +
                    Count(Iso) * IsolatedPawn +
                    Count(Iso and Dob) * IsolatedPawn * 2);
 end;
end;

*)

function FindMove(MaxLevel : Integer): Integer;
{ Finds a move in the position.
  On exit :
     MAINLINE contains principal variation.
     MAINEVALU contains evaluation of the line
}

var   { Value of root position in the Search }
      RootValue : MaxType;

      { Total material and material advantage }
      TotalMaterial,PawnTotalMaterial,Material : integer;
      { Material Level of the game
        (early middlegame = 43 - 32, endgame = 0) }
      MaterialLevel : 0..60;

var   PawnBit : array[-1..MaxPly] of PawnBitType;


var
  Mating : BOOLEAN;   { Mating Evaluation function is used }

procedure CalcPVTable;
{ Calculates Piece-Value table for the static Evaluation function }

type  { Pawn table, containing the squares with a Pawn }
      PawnTabType = array[RankType] of SetofFile;

var   PawnTab :      array[ColorType] of PawnTabType;

      { Bit tables for static Pawn structure Evaluation }
      PawnFileTab,Bit,
      OpPassTab,BehindOpPass,
      LeftSideTab ,RightSideTab ,SideTab,
      LeftChainTab,RightChainTab,ChainTab,
      LeftCoverTab,RightCoverTab : SetofFile;

      { Importance of an attack of the Square }
      AttackValue :  array[ColorType,SquareType] of 0..120;

      { Value of squares controlled from the Square }
      PVControl :
         array[ColorType,Rook..Bishop,SquareType] of 0..250;

      LosingColor : ColorType;   { The Color which is being mated }
      PosVal      : integer;     { The positional Value of Piece }
      AttVal      : integer;     { The attack Value of the sqaure }
      Line        : FileType;    { The file of the Piece }
      Rank,Row    : RankType;    { The Rank and Row of the Piece }
      Dist,                      { Distance to center }
      KingDist    : 0..14;       { Distance to opponents King }
      Cast        : CastType;    { Possible castlings }
      Direct      : BOOLEAN;     { Indicates Direct attack }
      Cnt         : integer;     { Counter for attack values }
      StrVal      : integer;     { Pawnstructure Value }
      Color,
      OppColor    : ColorType;   { Color and opponents Color }
      PieceCount  : PieceType;   { Piece counter }
      Square      : SquareType;  { Square counter }
      Dir         : DirType;     { Direction counter }
      Sq          : EdgeSquareType;   { Square counter }
      Temp,Temp2  : integer;     { Temporary junk }
      TempColor   : ColorType;

begin
  { Calculate SAMMAT, PAWNSAMMAT and Material }
  Mating := False;
  TotalMaterial := 0;
  PawnTotalMaterial := 0;
  Material := 0;
  with CC do
  begin
    for Square := 0 to $77 do
      if (Square and $88) = 0 then
        with Board[Square] do
          if Piece <> Empty then
            if Piece <> King then
            begin
              Temp := PieceValue[Piece];
              TotalMaterial := TotalMaterial + Temp;
              if Piece = Pawn then
                PawnTotalMaterial := PawnTotalMaterial + PieceValue[Pawn];
              if Color = White then Temp := -Temp;
              Material := Material - Temp;
            end;
    MaterialLevel := Max(0,TotalMaterial - $2000) div $100;
    { set Mating if weakest Player has less that the equivalence of
    two Bishops and the advantage is at least a Rook for a Bishop }
    if Material < 0 then
      LosingColor := White
    else
      LosingColor := Black;
    Mating := ((TotalMaterial - abs(Material)) div 2 <= PieceValue[Bishop] * 2)
              and (abs(Material) >= PieceValue[Rook] - PieceValue[Bishop]);
     { Calculate ATTACKVAL (importance of each Square) }
    for Rank := 0 to 7 do
      for Line := 0 to 7 do
      begin
        Square := Rank shl 4 + Line;
        AttVal := Max(0,8 - 3 *
                   (DistAn[Rank] + DistAn[Line])); { Center importance }
        for Color := White to Black do               { Rank importance }
        begin
          AttackValue[Color,Square] := SquareRankValue[Rank] * 3 *
                                       (MaterialLevel + 8) shr 5 + AttVal;
          Square := Square xor $70;
        end;
      end; { for }
     for Color := White to Black do
     begin
        OppColor := ColorType(1 - ord(Color));
        CalcCastling(OppColor,Cast);
        if not (Short in Cast) and (MaterialLevel > 0) then
           { Importance of the 8 squares around the Opponent's King }
           with PieceTab[OppColor,0] do
              for Dir := 0 to 7 do
              begin
                 Sq := ISquare + DirTab[Dir];
                 if (Sq and $88) = 0 then
                    AttackValue[Color,Sq] := AttackValue[Color,Sq] +
                                             12 * (MaterialLevel + 8) shr 5;
              end;
     end; { for }

     { Calculate PVControl }
     for Square := $77 downto 0 do
       if (Square and $88) = 0 then
         for Color := White to Black do
           for PieceCount := Rook to Bishop do
              PVControl[Color,PieceCount,Square] := 0;
     for Square := $77 downto 0 do
       if (Square and $88) = 0 then
         for Color := White to Black do
         begin
           for Dir := 7 downto 0 do
           begin
              if Dir < 4 then
                 PieceCount := Rook
              else
                 PieceCount := Bishop;
              { Count Value of all Attacks from the Square in
                the Direction.
                The Value of attacking a Square is Found in ATTACKVAL.
                Indirect Attacks (e.g. a Rook attacking through
                another Rook) counts for a Normal attack,
                Attacks through another Piece counts half }
              Cnt := 0;
              Sq := Square;
              Direct := true;
              repeat
                 { Get Next Square }
                 Sq := Sq + DirTab[Dir];
                 if (Sq and $88) <> 0 then Break;
                 Temp:=AttackValue[Color,Sq];
                 if Direct then                     { Add AttackValue }
                    Inc(Cnt, Temp)
                 else
                    Inc(Cnt, Temp shr 1);
                 with Board[Sq] do
                   if Piece <> Empty then
                     if (Piece <> PieceCount) and (Piece <> Queen) then
                        Direct := False;
              until Board[Sq].Piece = Pawn;
              Inc(PVControl[Color,PieceCount,Square],Cnt shr 2);
           end { for Dir };
        end { for Color };

     { Calculate PVTable, Value by Value }
     for Square := $77 downto 0 do
       if (Square and $88) = 0 then
       begin
         for Color := White to Black do
         begin
           OppColor := ColorType(1 - ord(Color));
           Line := Square and 7;
           Row := Square shr 4;
           Rank := Row;
           if Color = Black then Rank := 7 - Rank;
           Dist := DistAn[Rank] + DistAn[Line];
           with PieceTab[OppColor,0] do
              KingDist := abs(Square shr 4 - ISquare shr 4) +
                        (Square - ISquare) and 7;
           for PieceCount := King to Pawn do
           begin
              PosVal := 0;          { Calculate POSITIONAL Value for }
                                    { the Piece On the Square }
              if Mating and (PieceCount <> Pawn) then
              begin
                 if PieceCount = King then               { Mating Evaluation }
                    if Color = LosingColor then
                    begin
                       PosVal := 128 - 16 * DistAn[Rank] - 12 * DistAn[Line];
                       if DistAn[Rank] = 3 then
                          PosVal := PosVal - 16;
                    end
                    else
                    begin
                       PosVal := 128 - 4 * KingDist;
                       if (DistAn[Rank] >= 2) or (DistAn[Line] = 3) then
                          PosVal := PosVal - 16;
                    end;
              end { Mating }
              else
              begin
                 Temp := PVControl[Color,Rook,Square];
                 Temp2:= PVControl[Color,Bishop,Square];
                 { Normal Evaluation function }
                 case PieceCount of
                    King :   if MaterialLevel <= 0 then PosVal := -2 * Dist;
                    Queen :  PosVal := (Temp + Temp2) shr 2;
                    Rook :   PosVal := Temp;
                    Bishop : PosVal := Temp2;
                    Knight : begin
                               Cnt := 0;
                               for Dir := 0 to 7 do
                               begin
                                  Sq := Square + KnightDir[Dir];
                                  if (Sq and $88) = 0 then
                                     Cnt := Cnt + AttackValue[Color,Sq];
                               end;
                               PosVal := Cnt shr 1 - Dist * 3;
                            end;
                    Pawn :   if (Rank <> 0) and (Rank <> 7) then
                               PosVal :=
                                  PawnRank[Rank] +
                                  PawnFileFactor[Line] * (Rank + 2) - 12;
                 end { case };
              end; { else }
              PVTable[Color,PieceCount,Square] := PosVal;
           end { for PieceCount };
         end { for Color };
     end { for Square };

     { Calculate PawnTab (indicates which squares contain pawns) }
     for Color := White to Black do
       for Rank := 0 to 7 do
         PawnTab[Color,Rank] := 0;
     for Square := $77 downto 0 do
       if (Square and $88) = 0 then
         with Board[Square] do
           if Piece = Pawn then
           begin
              Rank := Square shr 4;
              if Color = Black then Rank := 7 - Rank;
              PawnTab[Color,Rank] :=
                 PawnTab[Color,Rank] or FileBitTab[Square and 7];
           end; { if }
     for Color := White to Black do   { Initialize PawnBit }
        with PawnBit[-1,Color] do
        begin
           One := 0;
           Dob := 0;
           for Rank := 1 to 6 do
           begin
              Temp := PawnTab[Color,Rank];
              Dob := Dob or One and Temp;
              One := One or Temp;
           end;
        end;
     { Calculate PawnStructureValue }
     RootValue := PawnStrVal(PawnBit[-1,Player]) - PawnStrVal(PawnBit[-1,Opponent]);

     { Calculate static Value for Pawn structure }
     for Color := White to Black do
     begin
        OppColor := ColorType(1 - ord(Color));
        PawnFileTab := 0;
        LeftSideTab := 0;
        RightSideTab := 0;
        OpPassTab := $FF;
        BehindOpPass := 0;
        for Rank := 1 to 6 do { Squares where opponents pawns are passed pawns }
        begin
           OpPassTab := OpPassTab and not (PawnFileTab or
                               LeftSideTab or RightSideTab);
           { Squares behind the opponents passed pawns }
           BehindOpPass := BehindOpPass or
                          (OpPassTab and PawnTab[OppColor,7 - Rank]);
           { Squares which are covered by a Pawn }
           LeftChainTab := LeftSideTab;
           RightChainTab := RightSideTab;
           PawnFileTab  := PawnTab[Color,Rank];         { Squares with pawns }
           { Squares with a Pawn beside them }
           LeftSideTab  := (PawnFileTab shl 1) and $FF;
           RightSideTab := (PawnFileTab shr 1) and $FF;
           SideTab      := LeftSideTab  or RightSideTab;
           ChainTab     := LeftChainTab or RightChainTab;
           { Squares covering a Pawn }
           Temp := PawnTab[Color,Succ(Rank)];
           LeftCoverTab := (Temp shl 1) and $FF;
           RightCoverTab := (Temp shr 1) and $FF;
           Sq := Rank shl 4;
           if Color = Black then Sq := Sq xor $70;
           Bit := 1;
           while Bit <> 0 do
           begin
              StrVal := 0;
              if (Bit and SideTab) <> 0 then
                 StrVal := SidePawn
              else if (Bit and ChainTab) <> 0 then
                 StrVal := ChainPawn;
              if (Bit and LeftCoverTab) <> 0 then
                 StrVal := StrVal + CoverPawn;
              if (Bit and RightCoverTab) <> 0 then
                 StrVal := StrVal + CoverPawn;
              if (Bit and PawnFileTab) <> 0 then
                 StrVal := StrVal + NotMovePawn;
              PVTable[Color,Pawn,Sq] := PVTable[Color,Pawn,Sq] + StrVal;
              if (MaterialLevel <= 0) or (OppColor <> ProgramColor) then
              begin
                if (Bit and OpPassTab) <> 0 then                 { Passed pawns }
                   PVTable[OppColor,Pawn,Sq] :=
                      PVTable[OppColor,Pawn,Sq] + PassPawnRank[7 - Rank];
                if (Bit and BehindOpPass) <> 0 then { Rooks behind passed pawns }
                begin
                   Temp := Sq xor $10;
                   for TempColor := Black to White do
                   begin
                     PVTable[TempColor,Rook,Sq] :=
                        PVTable[TempColor,Rook,Sq] + RookBehindPassPawn;
                     if Rank = 6 then
                       PVTable[TempColor,Rook,Temp] :=
                          PVTable[TempColor,Rook,Temp] + RookBehindPassPawn;
                   end; { for }
                end; { if }
              end; { if }
              Sq := Succ(Sq);
              Bit := (Bit shl 1) and $FF;
           end; { while }
        end; { for }
     end; { for }
     { Calculate penalty for blocking center pawns with a Bishop }
     for Sq := 3 to 4 do
     begin
        with Board[Sq + $10] do
           if (Piece = Pawn) and (Color = White) then
              PVTable[White,Bishop,Sq + $20] :=
                 PVTable[White,Bishop,Sq + $20] - BishopBlockValue;
        with Board[Sq + $60] do
           if (Piece = Pawn) and (Color = Black) then
              PVTable[Black,Bishop,Sq + $50] :=
                 PVTable[Black,Bishop,Sq + $50] - BishopBlockValue;
     end; { for }
     for Square := $77 downto 0 do         { Calculate RootValue }
       if (Square and $88) = 0 then
         with Board[Square] do
           if Piece <> Empty then
             if Color = Player then
               RootValue :=
                    RootValue + PiecePosVal(Piece,Player,Square)
             else
               RootValue :=
                  RootValue - PiecePosVal(Piece,Opponent,Square);
  end;  { with CC^ }
end { CalcPVTable };


function DecPawnStrVal(Color : ColorType; Line : FileType) : Integer;
{ Updates PawnBit and calculates Value when a Pawn is
  removed from Line }
var
  Temp : Integer;
begin
   with PawnBit[CC.Depth,Color] do
   begin
      Temp := not FileBitTab[Line];
      One := One and Temp or Dob;
      Dob := Dob and Temp;
   end;
   DecPawnStrVal := PawnStrVal(PawnBit[CC.Depth,Color]) -
                    PawnStrVal(PawnBit[Pred(CC.Depth),Color]);
end; { DecPawnStrVal }

function MovePawnStrVal(Color : ColorType;
                    New1, Old : FileType) : integer;
{ Updates PawnBit and calculates Value when a Pawn moves
  from Old to New1 file }
var
  Temp, Temp2: Integer;
begin
   with PawnBit[CC.Depth,Color] do
   begin
      Temp := FileBitTab[New1];
      Temp2 := not FileBitTab[Old];
      Dob := Dob or One and Temp;
      One := One and Temp2 or Dob or Temp;
      Dob := Dob and Temp2;
   end; { with }
   MovePawnStrVal := PawnStrVal(PawnBit[CC.Depth,Color]) -
                     PawnStrVal(PawnBit[Pred(CC.Depth),Color]);
end; { MovePawnStrVal }


function StateValu(MoveIt : MoveType) : integer;
{ Calculates STATIC Evaluation of the Move }
var   Value : integer;
      CastSquare,CornerSquare,EpSquare : SquareType;

begin { StateValu }
   with CC, MoveIt do
   begin
      Value := 0;
      if Spe then
         if MovPiece = King then
         begin
            GenCastSquare(New1,CastSquare,CornerSquare);    { Castling }
            Value := PiecePosVal(Rook,Player,CastSquare) -
                     PiecePosVal(Rook,Player,CornerSquare);
            if New1 > Old then
               Value := Value + CastValue[Short]
            else
               Value := Value + CastValue[Long];
         end
         else
           if MovPiece = Pawn then
           begin
             EpSquare := New1 - PawnDir[Player];         { E.p. capture }
             Value := PiecePosVal(Pawn,Opponent,EpSquare);
           end
           else
             { Pawnpromotion }
             Value := PiecePosVal(MovPiece,Player,Old) -
                   PiecePosVal(Pawn    ,Player,Old) +
                   DecPawnStrVal(Player  ,Old and 7);
      if Content <> Empty then                      { Normal moves }
      begin
         Value := Value + PiecePosVal(Content,Opponent,New1);
         { Penalty for exchanging Pieces when behind in material }
         if abs(MainEvalu) >= $100 then
            if Content <> Pawn then
               if (ProgramColor = Opponent) = (MainEvalu >= 0) then
                  Value := Value - ExchangeValue;
      end; { if }
      PawnBit[Depth] := PawnBit[Pred(Depth)];       { Calculate PawnBit }
      if (MovPiece = Pawn) and ((Content <> Empty) or Spe) then
         Value := Value + MovePawnStrVal(Player,New1 and 7,Old and 7);
      if (Content = Pawn) or Spe and (MovPiece = Pawn) then
         Value := Value - DecPawnStrVal(Opponent,New1 and 7);
      { Calculate Value of Move }
      StateValu := Value + PiecePosVal(MovPiece,Player,New1) -
                       PiecePosVal(MovPiece,Player,Old);
   end; { with }
end; { StateValu }

var
  KillingMove : array[ 0..MaxPly,0..1] of MoveType;
  CheckTab : array[-1..MaxPly] of boolean;       { Table of checks }
  { Square of eventual pawn On 7th Rank }
  PassedPawn : array[-2..MaxPly] of EdgeSquareType;

procedure ClearKillMove;
{ Initializes KillingMove, CheckTab and PassedPawn }
const rank7 : array[ColorType] of SquareType = ($60,$10);
var
  Dep : DepthType;
  Col : ColorType;
  Sq  : SquareType;
  i   : byte;
begin
  {Clear KillingMove }
  FillChar(KillingMove, SizeOf(KillingMove), 0);
  CheckTab[-1] := False;                        { No Check at First Ply }
  PassedPawn[-2] := -1;
  PassedPawn[-1] := -1;
  { Place eventual pawns On 7th Rank in PassedPawn }
  for Col := White to Black do
    for Sq := rank7[Col] to rank7[Col] + 7 do
      with CC, Board[Sq] do
        if (Piece = Pawn) and (Color = Col) then
          if Col = Player then
            PassedPawn[-2] := Sq
          else
            PassedPawn[-1] := Sq;
end; { ClearKillMove }

var   SkipSearch : boolean;

procedure CallSmallTalk;
{ Communicates with the user }
var
  SearchStateDepth : DepthType;
  StoredMove : MoveType;
  Msg: Word;
  OpAn: Boolean;

   procedure GetProgramState;
   { Backup the Search and setup Talk surroundings }
   var   OldPlayer : ColorType;
   begin
     with CC do
     begin
        SearchStateDepth := Depth;
        while Depth > 0 do
        begin
           Dec(Depth);
           OldPlayer := Opponent;
           Opponent := Player;
           Player   := OldPlayer;
           Perform(MovTab[Depth],true);
        end;
        Dec(Depth);
        if OpAn then
          TakeBackMove(MovTab[Depth]);
      end;
   end; { GetProgramState }

   procedure GetSearchState;
   { Restore the Search surroundings }
   var   OldPlayer : ColorType;
   begin
     with CC do
     begin
       if OpAn then
         MakeMove(MovTab[Depth + 1]);
       Inc(Depth);
       while Depth < SearchStateDepth do
       begin
         Perform(MovTab[Depth],False);
         OldPlayer := Player;
         Player   := Opponent;
         Opponent := OldPlayer;
         Inc(Depth);
       end;
     end;
   end; { GetSearchState }

begin { CallSmallTalk }

 with CC do
 begin
   if TaskTimer.TimeExpired then
   begin
     OpAn := OppAnalysis in State;
     GetProgramState;           {  Save Search surroundings }
     StoredMove := MovTab[Depth + 1];

     Msg := Message(tmTimeExpired);
     case Msg of
       tmEnterMove:
         begin
           SkipSearch := True;
           Include(State, MovePending);
           if (OppAnalysis in State) and EqMove(KeyMove,StoredMove) then
           begin
             Exclude(State, MovePending);
     	     Exclude(State, OppAnalysis);
             SkipSearch := False;
             EnterKeyMove;
             { Only legal think to receive is a tmFindMove }
             repeat until Message(tmFindMove) = tmFindMove;
             repeat until Message(tmFindMove) = tmResume;
             Include(State, Analysis);
             Clock.Start;
           end;
         end;
       tmResume:
         SkipSearch := False;
     end;
     GetSearchState;            {  Restore Search surroundings }
   end;
 end;
end;

type  InfType = record
                   PrincipVar : boolean;  { Principal Variation Search }
                   Value,              { Static incremental Evaluation }
                   Evaluation : MaxType;      { Evaluation of position }
                end;

var   StartInf :   InfType;    { Inf at First Ply }
      AlphaWindow : MaxType;   { Alpha window Value }
      RepeatEvalu : MaxType;   { MainEvalu at Ply One }

function Search(Alpha, Beta :   MaxType;
                Ply :          integer;
                Inf :          InfType;
       var BestLine :          LineType) : MaxType;

{ Performs the Search.
  On entry :
     Player is Next to Move.
     MovTab[Depth - 1] contains Last Move.
     Alpha, Beta contains the Alpha - Beta window.
     Ply contains the Depth of the Search.
     Inf contains various informations.

  On Exit :
     BestLine contains the principal variation.
     Search contains the Evaluation for Player }

var   Line :          LineType;   { Best Line at Next Ply }
      CaptureSearch : boolean;    { Indicates capture Search }
      MaxVal:        MaxType;    { Maximal Evaluation
                                   (returned in Search) }
      NextPly :       integer;    { Depth of Search at Next Ply }
      NextInf :          InfType;    { Information at Next Ply }
      ZeroWindow :    boolean;    { Zero-Width Alpha-Beta-window }
      MovGenType :    (Main,SpecialCap,Kill,Normal);   { Move type }

procedure UpdateKill(BestMove : MoveType);
{ Update KillingMove using BestMove }
begin
   with CC, BestMove do
      if MovPiece <> Empty then
      begin
         { Update KillingMove unless the Move is a capture of
           Last moved Piece }
         if (MovTab[Depth - 1].MovPiece = Empty) or
            (New1 <> MovTab[Depth - 1].New1) then
            if (KillingMove[Depth,0].MovPiece = Empty) or
               EqMove(BestMove,KillingMove[Depth,1]) then
            begin
               KillingMove[Depth,1] := KillingMove[Depth,0];
               KillingMove[Depth,0] := BestMove;
            end
            else
              if not EqMove(BestMove,KillingMove[Depth,0]) then
              begin
                 KillingMove[Depth,1] := BestMove;
              end;
      end; { if }
end; { UpdateKill }


function GeneratedBefore : boolean;
{ Test if Move has been generated before }
var i : 0..1;
begin
  GeneratedBefore := true;
  with CC do
  begin
    if MovGenType <> Main then
    begin
      if EqMove(MovTab[Depth],BestLine[Depth]) then Exit;
      if not CaptureSearch then
        if MovGenType <> Kill then
          for i := 0 to 1 do
            if EqMove(MovTab[Depth], KillingMove[Depth,i]) then Exit;
    end;
  end;
  GeneratedBefore := False;
end; { GeneratedBefore }

function Cut(CutVal : MaxType) : boolean;
{ Tests Cut-off. CutVal contains the maximal Possible Evaluation }
begin
  Cut := False;
  if CutVal <= Alpha then
  begin
    Cut := true;
    if MaxVal < CutVal then MaxVal := CutVal;
  end;
end; { Cut }

function Update : boolean;
{ Performs Move, calculates Evaluation, tests Cut-off etc. }
var
  Selection : boolean;
label AcceptMove,TakeBackMove,CutMove;
begin    { Update }
  with CC do
  begin
    with MovTab[Depth] do
    begin
      Inc(Nodes);
      NextPly := Ply - 1;                { Calculate next ply }
      if Level = MateSearch then           { MateSearch }
      begin
        Perform(MovTab[Depth],False);   { Perform Move On the Board }
        { Check if Move is Legal }
        if Attacks(Opponent,PieceTab[Player,0].ISquare) then
          goto TakeBackMove;
        if Depth = 0 then
          LegalMoves := LegalMoves + 1;
        CheckTab[Depth] := False;
        PassedPawn[Depth] := -1;
        NextInf.Value := 0;
        NextInf.Evaluation := 0;
        if NextPly <= 0 then { Calculate Check and Perform evt. Cut-off }
        begin
          if NextPly = 0 then
          CheckTab[Depth] := Attacks(Player,PieceTab[Opponent,0].ISquare);
          if not CheckTab[Depth] then
          begin
            if Cut(NextInf.Value) then goto TakeBackMove;
          end;
       end;
       goto AcceptMove;
     end;
     { Make special limited CaptureSearch at First iteration }
     if MaxDepth <= 1 then
       if CaptureSearch and (Depth >= 2) then
         if not ((Content < MovPiece) or
                (MovGenType = SpecialCap) or
                (Old = MovTab[Depth - 2].New1)) then
           goto CutMove;
           { Calculate Next static incremental Evaluation }
     NextInf.Value := -Inf.Value + StateValu(MovTab[Depth]);
           { Calculate CheckTab (only checks with moved Piece
             are calculated).  Giving Check does not Count as a Ply }
     CheckTab[Depth] := PieceAttacks(MovPiece,Player,New1,
                                     PieceTab[Opponent,0].ISquare);
     if CheckTab[Depth] then NextPly := Ply;
      { Calculate PassedPawn. Moving a Pawn to 7th Rank does not Count as a Ply }
     PassedPawn[Depth] := PassedPawn[Depth - 2];
     if MovPiece = Pawn then
       if (New1 < $18) or (New1 >= $60) then
       begin
         PassedPawn[Depth] := New1;
         NextPly := Ply;
       end;
       { Perform Selection at Last Ply and in capture Search }
       Selection := (NextPly <= 0) and not CheckTab[Depth] and (Depth > 0);
       if Selection then                  { Check Evaluation }
       if Cut(NextInf.Value + 0) then goto CutMove;
       Perform(MovTab[Depth],False);  { Perform Move On the Board }
       { check if move is legal }
       if Attacks(Opponent,PieceTab[Player,0].ISquare) then goto TakeBackMove;
       if PassedPawn[Depth] >= 0 then            { Check PassedPawn }
         with Board[PassedPawn[Depth]] do
           if (Piece <> Pawn) or (Color <> Player) then
             PassedPawn[Depth] := -1;
       if Depth = 0 then      { Count Number of Legal moves at Ply 0 }
         LegalMoves := LegalMoves + 1;
       if Depth = 0 then                          { Calculate Random }
         NextInf.Value := NextInf.Value + Random(4);
       { Calculate the Evaluation for the position }
       NextInf.Evaluation := NextInf.Value;
     end { with };
  AcceptMove :
     Update := False;
     Exit;
  TakeBackMove :
     Perform(MovTab[Depth],true);
  CutMove :
   end;  { with CC^ }
   Update := true;
end { Update };

function DrawGame : boolean;
{ Calculate Draw bonus/penalty, and set Draw if the game is a Draw }
var   DrawCount : 0..4;
      SearchRepeat : RepeatType;
      SearchFifty : FiftyType;
begin
  DrawGame := False;
  with CC do
  begin
    if Depth = 1 then
    begin
      SearchFifty := FiftyMoveCnt;
      SearchRepeat := Repetition(False);
      if SearchRepeat >= 3 then              { 3rd Repetition is Draw }
      begin
        DrawGame := true;
        NextInf.Evaluation := 0;
        Exit;
      end;
      DrawCount := 0;
      if SearchFifty >= 96 then        { 48 moves without Pawn }
        DrawCount := 3                  {  moves or captures }
      else
      if SearchRepeat >= 2 then         { 2nd Repetition }
        DrawCount := 2
      else
      if SearchFifty >= 20 then        { 10 moves without Pawn }
        DrawCount := 1;                 {  moves or captures }
      Inc(NextInf.Value, (RepeatEvalu div 4) * DrawCount);
      Inc(NextInf.Evaluation, (RepeatEvalu div 4) * DrawCount);
    end; { if }
    if Depth >= 3 then
    begin
      SearchRepeat := Repetition(true);
      if SearchRepeat >= 2 then
      begin                          { Immediate Repetition }
        DrawGame := true;                 {  counts as a Draw }
        NextInf.Evaluation := 0;
        Exit;
      end;
    end; { if }
  end; { with }
end; { DrawGame }

procedure UpdateBestLine;
{ Update BestLine and MainEvalu using Line and MaxVal }
begin
  BestLine := Line;
  with CC do
  begin
    BestLine[Depth] := MovTab[Depth];
    if Depth = 0 then
    begin
      MainEvalu := MaxVal;
      if Level = MateSearch then
        MaxVal := AlphaWindow;
    end;
  end;
end { UpdateBestLine };


function LoopBody : boolean;
{ The inner loop of the Search procedure.
  MovTab[Depth] contains the Move }


var   OldPlayer :    ColorType;
      LastAnalysis : boolean;

label RepeatSearch,NotSearch;
begin    { LoopBody }
  LoopBody := False;
  if GeneratedBefore then Exit;
  with CC do
  begin
    if Depth < MaxPly then                   { Initialize Line }
    begin
       Line[Depth + 1] := ZeroMove;
       if MovGenType = Main then
          Line := BestLine;
    end;
    { PrincipVar indicates Principal Variation Search.
      ZeroWindow indicates zero - Width Alpha - Beta window }
    NextInf.PrincipVar := False;
    ZeroWindow := False;
    if Inf.PrincipVar then
      if MovGenType = Main then
        NextInf.PrincipVar := BestLine[Depth + 1].MovPiece <> Empty
      else
        ZeroWindow := MaxVal >= Alpha;
  RepeatSearch :
    if Update then Exit;         { Update and test Cut-off }
    if Level = MateSearch then     { Stop evt. Search }
       if (NextPly <= 0) and not CheckTab[Depth] then goto NotSearch;
    if DrawGame then goto NotSearch;
    if Depth >= MaxPly then  goto NotSearch;
    { Analyse NextPly using a recursive call to Search }
    OldPlayer := Player; Player := Opponent; Opponent := OldPlayer;
    Inc(Depth);
    if ZeroWindow then
       NextInf.Evaluation := -Search(-Alpha - 1,- Alpha,NextPly,NextInf,Line)
    else
       NextInf.Evaluation := -Search(-Beta,- Alpha,NextPly,NextInf,Line);
    Dec(Depth);
    OldPlayer := Opponent;   Opponent := Player;   Player := OldPlayer;
  NotSearch :
    Perform(MovTab[Depth],true);                 { Take Back Move }
    if SkipSearch then
    begin
       LoopBody := true;
       Exit;
    end;
    LastAnalysis := Analysis in State;
                               { Check elapsed tic time and test SkipSearch }
    CallSmallTalk;

    if (not SkipSearch)
       and (Analysis in State)
       and ((Depth = 0) or not LastAnalysis)
       and (MainEvalu > AlphaWindow) then
    begin
      SkipSearch := Clock.TimeExpired;
    end;

    if (Analysis in State) and (MaxDepth <= 1) then
      SkipSearch := False;
    MaxVal := Max(MaxVal,NextInf.Evaluation);            { Update MaxVal }
    if EqMove(BestLine[Depth],MovTab[Depth]) then   { Update evt. BestLine }
       UpdateBestLine;
    if Alpha < MaxVal then                   { Update Alpha and test Cut-off }
    begin
       UpdateBestLine;
       if MaxVal >= Beta then
       begin
          LoopBody := true;                  { Cut-off }
          Exit;
       end;
       { Adjust MaxVal (Tolerance Search) }
       if (Ply >= 2) and Inf.PrincipVar and not ZeroWindow then
          MaxVal := Min(MaxVal + Tolerance,Beta - 1);
       Alpha := MaxVal;
       if ZeroWindow and not SkipSearch then
       begin
          { repeat Search with full window }
          ZeroWindow := False;
          goto RepeatSearch;
       end;
    end;
  end;  { with CC^ }
  LoopBody := SkipSearch;
end { LoopBody };


function PawnPromotionGen : boolean;
{ Generate Pawn promotions }
var   Promote : PieceType;
begin
   PawnPromotionGen := true;
   with CC, MovTab[Depth] do
   begin
      Spe := true;
      for Promote := Queen to Knight do
      begin
         MovPiece := Promote;
         if LoopBody then Exit;
      end;
      Spe := False;
   end;
   PawnPromotionGen := False;
end; { PawnPromotionGen }

function CapMovGen(NewSq : SquareType) : boolean;
{ Generates captures of the Piece On NewSq }
var   NextSq,Sq : EdgeSquareType;
      i :  IndexType;
begin
  CapMovGen := true;
  with CC, MovTab[Depth] do
  begin
    Content := Board[NewSq].Piece;
    Spe := False;
    New1 := NewSq;
    MovPiece := Pawn;                       { Pawn captures }
    NextSq := New1 - PawnDir[Player];
    for Sq := NextSq - 1 to NextSq + 1 do
      with Board[Sq] do
      if (Sq <> NextSq) and ((Sq and $88) = 0) and
         (Piece = Pawn) and (Color = Player) then
      begin
        Old := Sq;
        if (New1 < 8) or (New1 >= $70) then
        begin
          if PawnPromotionGen then Exit;
        end
        else
          if LoopBody then Exit;
      end;
    for i := OfficerNo[Player] downto 0 do      { Other captures }
      with PieceTab[Player,i] do
      if (IPiece <> Empty) and (IPiece <> Pawn) and
         PieceAttacks(IPiece,Player,ISquare,NewSq) then
      begin
        Old := ISquare;
        MovPiece := IPiece;
        if LoopBody then Exit;
      end;
  end;
  CapMovGen := False;
end { CapMovGen };

function NonCapMovGen(OldSq : SquareType) : boolean;
{ Generates non captures for the Piece On OldSq }
var   First,Last,Dir : DirType;
      Direction :      integer;
      NewSq :          EdgeSquareType;

label 10;
begin
   NonCapMovGen := true;
   with CC, MovTab[Depth] do
   begin
      Spe := False;
      Old := OldSq;
      MovPiece := Board[OldSq].Piece;
      Content := Empty;
      case MovPiece of
        King : for Dir := 7 downto 0 do
               begin
                 NewSq := Old + DirTab[Dir];
                 if (NewSq and $88) = 0 then
                    if Board[NewSq].Piece = Empty then
                    begin
                       New1 := NewSq;
                       if LoopBody then Exit;
                    end;
              end;
        Knight : for Dir := 7 downto 0 do
                begin
                  NewSq := Old + KnightDir[Dir];
                  if (NewSq and $88) = 0 then
                    if Board[NewSq].Piece = Empty then
                    begin
                       New1 := NewSq;
                       if LoopBody then Exit;
                    end;
              end;
        Queen,
        Rook,
        Bishop : begin
                 First := 7;
                 Last := 0;
                 if MovPiece = Rook then First := 3;
                 if MovPiece = Bishop then Last := 4;
                 for Dir := First downto Last do
                 begin
                    Direction := DirTab[Dir];
                    NewSq := Old + Direction;
                    while (NewSq and $88) = 0 do
                    begin
                       if Board[NewSq].Piece <> Empty then goto 10;
                       New1 := NewSq;
                       if LoopBody then Exit;
                       NewSq := New1 + Direction;
                    end;
              10 : end;
              end;
      Pawn :   begin
                 { One Square forward }
                 New1 := Old + PawnDir[Player];
                 if Board[New1].Piece = Empty then
                    if (New1 < 8) or (New1 >= $70) then
                    begin
                       if PawnPromotionGen then Exit;
                    end
                    else
                    begin
                       if LoopBody then Exit;
                       if (Old < $18) or (Old >= $60) then
                       begin
                          { Two squares forward }
                          New1 := New1 + (New1 - Old);
                          if Board[New1].Piece = Empty then
                             if LoopBody then Exit;
                       end;
                    end;
              end;
      end { case };
   end { with };
   NonCapMovGen := False;
end { NonCapMovGen };

function CastlingMovGen : boolean;
{ Castling moves }
var CastDir : CastDirType;
begin
   CastlingMovGen := true;
   with CC, MovTab[Depth] do
   begin
      Spe := true;
      MovPiece := King;
      Content := Empty;
      for CastDir := Short downto Long do
         with CastMove[Player,CastDir] do
         begin
            New1 := CastNew;
            Old := CastOld;
            if KillMovGen(MovTab[Depth]) then
               if LoopBody then Exit;
         end;
   end;
   CastlingMovGen := False;
end { CastlingMovGen };

function EpCapMovGen : boolean;
{ E.p. captures }
var   Sq : EdgeSquareType;
begin
   EpCapMovGen := true;
   with CC, MovTab[Depth - 1] do
      if MovPiece = Pawn then
         if abs(New1 - Old) >= $20 then
         begin
            MovTab[Depth].Spe := true;
            MovTab[Depth].MovPiece := Pawn;
            MovTab[Depth].Content := Empty;
            MovTab[Depth].New1 := (New1 + Old) div 2;
            for Sq := New1 - 1 to New1 + 1 do if Sq <> New1 then
               if (Sq and $88) = 0 then
               begin
                  MovTab[Depth].Old := Sq;
                  if KillMovGen(MovTab[Depth]) then
                     if LoopBody then Exit;
               end;
         end;
   EpCapMovGen := False;
end { EpCapMovGen };


procedure SearchMovGen;
{ Generates the Next Move to be analysed.
  Controls the order of the movegeneration.
     The moves are generated in the order :
     Main variation
     Captures of Last moved Piece
     Killing moves
     Other captures
     Pawnpromovtions
     Castling
     Normal moves
     E.p. captures
}

var   Index : IndexType;
      KillNo : 0..1;
begin
   with CC, MovTab[Depth] do
   begin
      { Generate Move from Main variation }
      if BestLine[Depth].MovPiece <> Empty then
      begin
         MovTab[Depth] := BestLine[Depth];
         MovGenType := Main;
         if LoopBody then Exit;
      end;
      with MovTab[Depth - 1] do        { Captures of Last moved Piece }
         if MovPiece <> Empty then if MovPiece <> King then
         begin
            MovGenType := SpecialCap;
            if CapMovGen(New1) then Exit;
         end;
      MovGenType := Kill;                             { Killing moves }
      if not CaptureSearch then
         for KillNo := 0 to 1 do
         begin
            MovTab[Depth] := KillingMove[Depth,KillNo];
            if MovPiece <> Empty then
               if KillMovGen(MovTab[Depth]) then
                  if LoopBody then Exit;
         end;
      MovGenType := Normal;                            { Captures }
      for Index := 1 to PawnNo[Opponent] do
         with PieceTab[Opponent,Index] do
            if IPiece <> Empty then
               with MovTab[Depth - 1] do
                  if (MovPiece = Empty) or (ISquare <> New1) then
                     if CapMovGen(ISquare) then Exit;
      if CaptureSearch then                    { Pawnpromotions }
         if PassedPawn[Depth - 2] >= 0 then
            with Board[PassedPawn[Depth - 2]] do
               if (Piece = Pawn) and (Color = Player) then
                  if NonCapMovGen(PassedPawn[Depth - 2]) then Exit;
      if not CaptureSearch then                  { Non-captures }
      begin
         if CastlingMovGen then Exit;            { Castling }
         for Index := PawnNo[Player] downto 0 do   { other moves }
            with PieceTab[Player,Index] do
               if IPiece <> Empty then
                  if NonCapMovGen(ISquare) then Exit;
      end;
      if EpCapMovGen then Exit;       { E.p. captures }
   end;
end { SearchMovGen };

label Stop;
begin { Search }
  with CC do
  begin
   { Perform CaptureSearch if Ply<=0 and not Check }
   CaptureSearch := (Ply <= 0) and not CheckTab[Depth - 1];
   if CaptureSearch then                     { Initialize MaxVal }
   begin
      MaxVal := -Inf.Evaluation;
      if Alpha < MaxVal then
      begin
         Alpha := MaxVal;
         if MaxVal >= Beta then goto Stop;
      end;
   end
   else
      MaxVal := -(LoseValue - Depth * DepthFactor);
   SearchMovGen;   { The Search loop }
   if SkipSearch then goto Stop;
   if MaxVal = -(LoseValue - Depth * DepthFactor) then   { test stalemate }
      if not Attacks(Opponent,PieceTab[Player,0].ISquare) then
      begin
         MaxVal := 0;
         goto Stop;
      end;
   UpdateKill(BestLine[Depth]);
  end;  { with }
Stop :
   Search := MaxVal;
end { Search };

function CallSearch(Alpha,Beta : MaxType) : MaxType;
{ Perform the Search }
var   MaxVal : MaxType;
begin
  with CC do
  begin
    StartInf.PrincipVar := MainLine[0].MovPiece <> Empty;
    LegalMoves := 0;
    MaxVal := Search(Alpha,Beta,MaxDepth,StartInf,MainLine);
    if LegalMoves = 0 then MainEvalu := MaxVal;
    CallSearch := MaxVal;
  end;
end; { CallSearch }

function TimeUsed : boolean;
{ Checks whether the Search Time is used }
begin
  TimeUsed := False;
  with CC do
    if Analysis in State then
      TimeUsed := Clock.TimeExpired;
end; { TimeUsed }

var
  MaxVal     : MaxType;
  CalcPVTime : real;
begin { FindMove }
  with CC do
  begin
    Clock.Start;                    { Initialize variables }
    Nodes := 0;
    SkipSearch := False;
    ClearKillMove;
    CalcPVTable;                    { Calculate the P-V table }
    CalcPVTime := Clock.GetElapsedTime;
    StartInf.Value := -RootValue;        { Initiate the search }
    StartInf.Evaluation := -RootValue;
    MaxDepth := 0;
    MainLine[0] := ZeroMove;
    MainEvalu := RootValue;
    AlphaWindow := MaxInt;
    repeat                             { The iterative search loop }
        { Update various variables }
      if MaxDepth <= 1 then RepeatEvalu := MainEvalu;
      AlphaWindow := Min(AlphaWindow,MainEvalu - $80);
      if Level = MateSearch then
      begin
        AlphaWindow := $6000;
        if MaxDepth > 0 then Inc(MaxDepth);
      end;
      Inc(MaxDepth);
      MaxVal := CallSearch(AlphaWindow,$7F00);     { Perform the search }
      if (MaxVal <= AlphaWindow) and not SkipSearch and
         (Level <> MateSearch) and (LegalMoves > 0) then
      begin
           { repeat the search if the value falls below
             the Alpha - window }
        MainEvalu := AlphaWindow;
        MaxVal := CallSearch(-$7F00,AlphaWindow - Tolerance * 2);
        LegalMoves := 2;
      end;
    until SkipSearch or TimeUsed or (MaxDepth >= MaxLevel) or
           (LegalMoves <= 1) or
           (abs(MainEvalu) >= MateValue - 24 * DepthFactor);
    Clock.Stop;
  end; { with }
end; { FindMove }

end.