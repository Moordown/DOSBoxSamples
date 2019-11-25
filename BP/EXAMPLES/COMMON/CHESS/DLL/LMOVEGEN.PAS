{                             MOVGEN.CH
                              CHESS 4.0
            Copyright (c) 1985, 87 by Borland International, Inc.

  This module contains the Move generator and various other
  procedures.

}
unit LMoveGen;

interface

uses  GameRec;

procedure CalcAttackTab;
function PieceAttacks(APiece : PieceType;
                      AColor : ColorType;
                      ASquare,
                      Square :  SquareType) : boolean;
function Attacks(AColor : ColorType;   Square : SquareType) : boolean;

type  CastDirType = (Long,Short);  { Castling types }
      CastType    = set of CastDirType;

procedure CalcCastling(InColor : ColorType; var Cast : CastType);
function RepeatMove(Move : MoveType) : boolean;

type FiftyType = 0..150;
function FiftyMoveCnt : FiftyType;

type RepeatType = 1..4;
function Repetition(Immediate : boolean) : RepeatType;

function KillMovGen(Move : MoveType) : boolean;
procedure InitMovGen;
procedure MovGen;

type  { Directions }
      DirType   = 0..7;

const { Move directions used in the Move generation }
      DirTab :    array[DirType] of integer =       { Rook, Bishop etc. }
                    (1,-1,$10,-$10,$11,-$11,$F,-$F);
      KnightDir : array[DirType] of integer =            { Knight moves }
                    ($E,-$E,$12,-$12,$1F,-$1F,$21,-$21);
      PawnDir :   array[ColorType] of integer =        { Pawn Direction }
                    ($10,-$10);

{ Castling moves }
const CastMove :  array[ColorType,CastDirType] of
                    record
                       CastNew,CastOld : SquareType;
                    end =
                    (((CastNew :   2;   CastOld :   4),
                      (CastNew :   6;   CastOld :   4)),
                     ((CastNew : $72;   CastOld : $74),
                      (CastNew : $76;   CastOld : $74)));

implementation

{ Tables for calculating whether a Piece Attacks a Square }
type
  SetOfPiece = byte;
const
  BitTab : array[King..Pawn] of SetOfPiece = (1,2,4,8,$10,$20);

var   { A constant, which is calculated in CalcAttackTab.
        Gives the squares which a Piece in the middle of the
        table can Move to.
        This is not modified during the game and can safely be
        made global in the chessdll, shared between game contexts.}
      AttackTab : array[-$77..$77] of
                    record
                       { A set of King..Pawn.
                         Gives the Pieces, which can
                         Move to the Square }
                       PieceSet :  SetOfPiece;
                       Direction: integer;  { The Direction from
                                              the Piece to the Square }
                    end;

procedure CalcAttackTab;
{ Calculates AttackTab }
var   Dir:    DirType;
      Sq :   integer;
       i :   byte;
begin
   FillChar(AttackTab, sizeof(AttackTab), 0);
{   for Sq:=-$77 to $77 do
      with AttackTab[Sq] do
      begin
         PieceSet:=0;
         Direction:=0;
      end;
}   for Dir:=7 downto 0 do
   begin
      for i:=1 to 7 do
         with AttackTab[DirTab[Dir]*i] do
         begin
            if Dir<4 then
               PieceSet:=BitTab[Queen]+BitTab[Rook]
            else
               PieceSet:=BitTab[Queen]+BitTab[Bishop];
            Direction:=DirTab[Dir];
         end;
      with AttackTab[DirTab[Dir]] do
         PieceSet:=PieceSet+BitTab[King];
      with AttackTab[KnightDir[Dir]] do
      begin
         PieceSet:=BitTab[Knight];
         Direction:=KnightDir[Dir];
      end;
   end;
end; { CalcAttackTab }

function PieceAttacks(APiece : PieceType;
                      AColor : ColorType;
                      ASquare,
                      Square :  SquareType) : boolean;
{ Calculates whether APiece placed On ASquare Attacks the Square }
var   Sq : EdgeSquareType;
begin
   if APiece = Pawn then
      { Pawn Attacks }
      PieceAttacks := abs(Square - ASquare - PawnDir[AColor]) = 1
   else
      { Other Attacks: Can the Piece Move to the Square? }
      with AttackTab[Square - ASquare] do
         if (PieceSet and BitTab[APiece]) <> 0 then
            if (APiece = King) or (APiece = Knight) then
               PieceAttacks := true
            else
            begin
               { Are there any blocking Pieces in between? }
               Sq := ASquare;
               repeat
                  Sq := Sq + Direction;
               until (Sq = Square) or (CC.Board[Sq].Piece <> Empty);
               PieceAttacks := Sq = Square;
            end
         else
            PieceAttacks := False;
end { PieceAttacks };

function Attacks(AColor : ColorType;   Square : SquareType) : boolean;
{ Calculates whether AColor Attacks the Square }

  function PawnAttacks(AColor: ColorType; Square: SquareType):
              boolean;
  { Calculates whether AColor Attacks the Square with a Pawn }
  var   Sq: EdgeSquareType;
  begin
     PawnAttacks:=true;
     Sq := Square - PawnDir[AColor] - 1;   { Left Square }
     if (Sq and $88) = 0 then
        with CC.Board[Sq] do
           if (Piece = Pawn) and (Color = AColor) then Exit;
     Sq := Sq + 2;                       { Right Square }
     if (Sq and $88) = 0 then
        with CC.Board[Sq] do
           if (Piece = Pawn) and (Color = AColor) then Exit;
     PawnAttacks := False;
  end; { PawnAttacks }


var   i :  IndexType;

begin { Attacks }
   Attacks := true;
   if PawnAttacks(AColor,Square) then   { Pawn Attacks }
      Exit;
   { Other Attacks:  Try all Pieces, starting with the smallest }
   with CC do
     for i := OfficerNo[AColor] downto 0 do
       with PieceTab[AColor,i] do
         if IPiece <> Empty then
           if PieceAttacks(IPiece,AColor,ISquare,Square) then
             Exit;
   Attacks := False;
end { Attacks };

procedure CalcCastling(InColor : ColorType; var Cast : CastType);
{ Calculates whether InColor can castle }

  function Check(Square : SquareType; InPiece : PieceType) : boolean;
  { Checks whether InPiece is placed On Square and has never moved }
  var
    Dep : DepthType;
  begin
    Check := False;
    with CC, Board[Square] do                           { Check Square }
      if (Piece = InPiece) and (Color = InColor) then
      begin
        Dep := Depth - 1;                            { Check all moves }
        while MovTab[Dep].MovPiece <> Empty do
        begin
          if MovTab[Dep].New1 = Square then Exit;
          Dep := Dep - 1;
        end;
        Check := true;
      end;
  end; { Check }

var   Square : SquareType;
begin
   Square := 0;
   if InColor = Black then Square := $70;
   Cast :=[];
   if Check(Square + 4,King) then
   begin                                                        { Check King }
      if Check(Square  ,Rook) then Cast := Cast +[Long];      { Check a-Rook }
      if Check(Square + 7,Rook) then Cast := Cast +[Short];   { Check h-Rook }
   end;
end { CalcCastling };

function RepeatMove(Move : MoveType) : boolean;
{ Check if Move is a Pawn Move or a capture }
begin
  with Move do
    RepeatMove := (MovPiece <> Empty) and (MovPiece <> Pawn)
                 and (Content = Empty) and not Spe;
end; { RepeatMove }

function FiftyMoveCnt : FiftyType;
{ Counts the Number of moves since Last capture or Pawn Move.
  The game is a Draw when FiftyMoveCnt = 100 }
var   Cnt : FiftyType;
begin
  Cnt := 0;
  with CC do
    while RepeatMove(MovTab[Depth - Cnt]) do
      Cnt := Cnt + 1;
  FiftyMoveCnt := Cnt;
end;

function Repetition(Immediate : boolean) : RepeatType;
{ Calculates how many times the position has occured before.
  The game is a Draw when Repetition = 3.
  MovTab[Back..Depth] contains the previous moves.
  When Immediate is set, only Immediate Repetition is checked }

var   LastDep,CompDep,TraceDep,CheckDep,SameDepth : DepthType;
      TraceSq,CheckSq : SquareType;
      RepeatCount : RepeatType;
label 10;
begin
  with CC do
  begin
    Repetition := 1;
    RepeatCount := 1;
    SameDepth := Depth + 1;                     { Current position }
    CompDep := SameDepth - 4;          { First position to compare }
    LastDep := SameDepth;
    { MovTab[LastDep..Depth] contains previous relevant moves  }
    while RepeatMove(MovTab[LastDep - 1]) and
          ((CompDep < LastDep) or not Immediate) do
       LastDep := LastDep - 1;
    if CompDep < LastDep then Exit;     { No Repetition Possible }
    CheckDep := SameDepth;
    repeat
       CheckDep := CheckDep - 1;           { Get Next Move to test }
       CheckSq := MovTab[CheckDep].New1;
       TraceDep := CheckDep + 2;          { Check if Move has been }
       while TraceDep < SameDepth do
       begin
         if MovTab[TraceDep].Old = CheckSq then goto 10;
         TraceDep := TraceDep + 2;
       end;

       { Trace the Move backward to see whether
         it has been 'undone' earlier }
       TraceDep := CheckDep;
       TraceSq := MovTab[TraceDep].Old;
       repeat
          if TraceDep - 2 < LastDep then Exit;
          TraceDep := TraceDep - 2;
          with MovTab[TraceDep] do  { Check if Piece has been moved before }
             if TraceSq = New1 then
                TraceSq := Old;
       until (TraceSq = CheckSq) and (TraceDep <= CompDep + 1);
       if TraceDep < CompDep then                      { Adjust evt. CompDep }
       begin
         CompDep := TraceDep;
         if odd(SameDepth - CompDep) then
         begin
           if CompDep = LastDep then Exit;
           CompDep := CompDep - 1;
         end;
         CheckDep := SameDepth;
       end;
    { All moves between SAMEDEP and CompDep have been checked,
      so a Repetition is Found }
    10 : if CheckDep <= CompDep then
       begin
          RepeatCount := RepeatCount + 1;
          Repetition := RepeatCount;
          if CompDep - 2 < LastDep then Exit;
          SameDepth := CompDep;               { Search for more repetitions }
          CompDep := CompDep - 2;
          CheckDep := SameDepth;
       end;
    until False;
  end;  { with CC^ }
end { Repetition };

function KillMovGen(Move : MoveType) : boolean;
{ Tests whether a Move is Possible.

   On entry :
      Move contains a full description of a Move, which
      has been legally generated in a different position.
      MovTab[Depth - 1] contains Last performed Move.

   On Exit :
      KillMovGen indicates whether the Move is Possible
}
var   CastSq  : SquareType;
      Promote : PieceType;
      CastDir : CastDirType;
      Cast    : CastType;
begin
   KillMovGen := False;
   with CC, Move do
   begin
      if Spe and (MovPiece = King) then
      begin
         CalcCastling(Player,Cast);         { Castling }
         if New1 > Old then
            CastDir := Short
         else
            CastDir := Long;

         if CastDir in Cast then   { Has King or Rook moved before? }
         begin
            CastSq := (New1 + Old) div 2;
            { Are the squares Empty? }
            if (Board[New1   ].Piece = Empty) then
              if (Board[CastSq].Piece = Empty) then
                if ((New1 > Old) or (Board[New1 - 1 ].Piece = Empty)) then
                  { Are the squares unattacked? }
                  if not Attacks(Opponent,Old) then
                    if not Attacks(Opponent,New1) then
                      if not Attacks(Opponent,CastSq) then
                        KillMovGen := true;
         end;
      end
      else
      if Spe and (MovPiece = Pawn) then
      begin
         { E.p. capture }
         with MovTab[Depth - 1] do
            { Was the Opponent's Move a 2 Square Move }
            if MovPiece = Pawn then
               if abs(New1 - Old) >= $20 then
                  { Is there a Piece On the Square? }
                  with Board[Move.Old] do
                     if (Piece = Pawn) and (Color = Player) then
                        KillMovGen := Move.New1 = (New1 + Old) div 2;
      end { if }
      else
      begin
         if Spe then                      { Normal test }
         begin
            Promote := MovPiece;            { Pawnpromotion }
            MovPiece := Pawn;
         end;

         { Is the Content of Old and New1 squares correct? }
         if (Board[Old].Piece = MovPiece) then if
            (Board[Old].Color = Player) then if
            (Board[New1].Piece = Content) then if
           ((Content = Empty) or
            (Board[New1].Color = Opponent)) then

            if MovPiece = Pawn then             { Is the Move Possible? }
               if abs(New1 - Old) < $20 then
                  KillMovGen := true
               else
                  KillMovGen := Board[(New1 + Old) div 2].Piece = Empty
            else
               KillMovGen := PieceAttacks(MovPiece,Player,Old,New1);
         if Spe then
            MovPiece := Promote;
      end;
   end { with };
end; { KillMovGen }

{ Movegeneration variables }

procedure InitMovGen;
{ The move generator.
  InitMovGen generates all Possible moves and places them
  in a Buffer. MovGen will then Generate the moves One by One and
  place them in Next.

  On entry :
     Player contains the Color to Move.
     MovTab[Depth - 1] the Last performed Move.

  On Exit :
     Buffer contains the generated moves.

     The moves are generated in the order :
        Captures
        Castlings
        Non captures
        E.p. captures }

  procedure Generate;
     { Stores a Move in Buffer }
  begin
    with CC do
    begin
      BufCount := BufCount + 1;
      Buffer[BufCount] := NextMove;
    end;
  end; { Generate }

  procedure PawnPromotionGen;
  { Generates Pawnpromotion }
  var   Promote : PieceType;
  begin
    with CC.NextMove do
    begin
      Spe := true;
      for Promote := Queen to Knight do
      begin
        MovPiece := Promote;
        Generate;
      end;
      Spe := False;
    end;
  end; { PawnPromotionGen }

  procedure CapMovGen;
     { Generates captures of the Piece On New1 using PieceTab }
  var   NextSq,Sq : EdgeSquareType;
    i :  IndexType;
  begin
    with CC, NextMove do
    begin
      Spe := False;
      Content := Board[New1].Piece;
      MovPiece := Pawn;                   { Pawn captures }
      NextSq := New1 - PawnDir[Player];
      for Sq := NextSq - 1 to NextSq + 1 do if Sq <> NextSq then
      if (Sq and $88) = 0 then
        with Board[Sq] do
          if (Piece = Pawn) and (Color = Player) then
          begin
            Old := Sq;
            if (New1 < 8) or (New1 >= $70) then
              PawnPromotionGen
            else
              Generate;
          end;
           { Other captures, starting with the smallest Pieces }
      for i := OfficerNo[Player] downto 0 do
        with PieceTab[Player,i] do
          if (IPiece <> Empty) and (IPiece <> Pawn) then
            if PieceAttacks(IPiece,Player,ISquare,New1) then
            begin
              Old := ISquare;
              MovPiece := IPiece;
              Generate;
            end;
        end { with };
  end; { CapMovGen }

  procedure NonCapMovGen;
  { Generates non captures for the Piece On Old }
  var
     First,Last,Dir : DirType;
     Direction      : integer;
     NewSq          : EdgeSquareType;

  label 10;
  begin
    with CC, NextMove do
    begin
      Spe := False;
      MovPiece := Board[Old].Piece;
      Content := Empty;
      case MovPiece of
        King :   for Dir := 7 downto 0 do
                 begin
                   NewSq := Old + DirTab[Dir];
                   if (NewSq and $88) = 0 then
                     if Board[NewSq].Piece = Empty then
                     begin
                       New1 := NewSq;
                       Generate;
                     end;
                 end;
        Knight : for Dir := 7 downto 0 do
                 begin
                   NewSq := Old + KnightDir[Dir];
                   if (NewSq and $88) = 0 then
                     if Board[NewSq].Piece = Empty then
                     begin
                       New1 := NewSq;
                       Generate;
                     end;
                 end;
        Queen,
        Rook,
        Bishop : begin
                   First := 7;
                   Last := 0;
                   if MovPiece = Rook   then First := 3;
                   if MovPiece = Bishop then Last := 4;
                   for Dir := First downto Last do
                   begin
                     Direction := DirTab[Dir];
                     NewSq := Old + Direction;
                     { Generate all non captures in
                           the Direction }
                     while (NewSq and $88) = 0 do
                     begin
                       if Board[NewSq].Piece <> Empty then goto 10;
                       New1 := NewSq;
                       Generate;
                       NewSq := New1 + Direction;
                     end;
              10 : end;
                 end;
        Pawn :   begin
                   New1 := Old + PawnDir[Player];    { One Square forward }
                   if Board[New1].Piece = Empty then
                     if (New1 < 8) or (New1 >= $70) then
                       PawnPromotionGen
                     else
                     begin
                       Generate;
                       if (Old < $18) or (Old >= $60) then
                       begin
                         New1 := New1 + (New1 - Old); { Two squares forward }
                         if Board[New1].Piece = Empty then Generate;
                       end;
                     end;
                 end;
      end { case };
    end { with };
  end; { NonCapMovGen }

var
  CastDir : CastDirType;
  Sq      : EdgeSquareType;
  Index   : IndexType;

begin { InitMovGen }
   with CC, NextMove do                    { Reset the Buffer }
   begin
      BufCount := 0;
      BufPnt := 0;
      { Generate all captures starting with captures of
        largest Pieces }
      for Index := 1 to PawnNo[Opponent] do
         with PieceTab[Opponent,Index] do
            if IPiece <> Empty then
            begin
               New1 := ISquare;
               CapMovGen;
            end;
      Spe := true;                           { Castling }
      MovPiece := King;
      Content := Empty;
      for CastDir := Short downto Long do
         with CastMove[Player,CastDir] do
         begin
            New1 := CastNew;
            Old := CastOld;
            if KillMovGen(NextMove) then Generate;
         end;

      { Generate non captures, starting with pawns }
      for Index := PawnNo[Player] downto 0 do
         with PieceTab[Player,Index] do
            if IPiece <> Empty then
            begin
               Old := ISquare;
               NonCapMovGen;
            end;
      with MovTab[Depth - 1] do               { E.p. captures }
         if MovPiece = Pawn then
            if abs(New1 - Old) >= $20 then
            begin
               NextMove.Spe := true;
               NextMove.MovPiece := Pawn;
               NextMove.Content := Empty;
               NextMove.New1 := (New1 + Old) div 2;
               for Sq := New1 - 1 to New1 + 1 do
                 if Sq <> New1 then
                   if (Sq and $88) = 0 then
                   begin
                     NextMove.Old := Sq;
                     if KillMovGen(NextMove) then Generate;
                  end;
            end;
    end { with };
end; { InitMovGen }

procedure MovGen;
{ Place Next Move from the Buffer in Next.
  Generate ZeroMove when there is No more moves }
begin
  with CC do
  begin
    if BufPnt >= BufCount then
       NextMove := ZeroMove
    else
    begin
       BufPnt := BufPnt + 1;
       NextMove := Buffer[BufPnt];
    end;
  end;
end; { MovGen }

end.