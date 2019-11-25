unit LBoard;

{internal board and move data and functions used by chessdll}

interface

uses GameRec;

function EqMove(var a,b : MoveType) : boolean;
function Min(a,b : integer) : integer;
function Max(a,b : integer) : integer;
procedure InitBoard;
procedure CalcPieceTab;
procedure GenCastSquare(New1 : SquareType; var CastSquare,
  CornerSquare : SquareType);
procedure Perform(Move : MoveType; ResetMove : boolean);
procedure MovePiece(New1,Old : SquareType);
procedure DeletePiece(InSquare : SquareType);
procedure InsertPiece(InPiece : PieceType; InColor : ColorType;
  InSquare : SquareType);
procedure ChangeType(NewType : PieceType; InSquare : SquareType);

const    { To make Perform's ResetMove parameter easier to read: }
  DoIt = False;
  UndoIt = True;

implementation

uses Strings;

function EqMove(var a,b : MoveType) : boolean;
{ Compares two moves }
begin
   EqMove := False;
   if a.MovPiece = b.MovPiece then
     if a.New1 = b.New1 then
       if a.Old = b.Old then
         if a.Content = b.Content then
           if a.Spe = b.Spe then
             EqMove := true;
end; { EqMove }

function Min(a,b : integer) : integer;
begin
  if a < b then
    Min := a
  else
    Min := b;
end; { Min }

function Max(a,b : integer) : integer;
begin
  if a > b then
    Max := a
  else
    Max := b;
end; { Max }

procedure CalcPieceTab;
{ Calculates PieceTab from scratch }
var   Square : SquareType;
      Piece1 : PieceType;

  procedure ClearIndex;
  { Clears indexes in Board and PieceTab }
  var Square : SquareType;
      Col :    ColorType;
      Index :  IndexType;
  begin
     with CC do
     begin
       for Square := 0 to $77 do
          Board[Square].Index := 16;
       for Col := White to Black do
         for Index := 0 to 15 do
           PieceTab[Col,Index].IPiece := Empty;
       PawnNo[White] := -1;
       PawnNo[Black] := -1;
       OfficerNo := PawnNo;
     end;
  end;

begin
  ClearIndex;
  for Piece1 := King to Pawn do    { Insert all the Pieces of the type }
  with CC do
  begin
     if Piece1 = Pawn then
        OfficerNo := PawnNo;      { Save Number of officers }
     Square := 0;
     repeat
       with Board[Square] do
         if Piece = Piece1 then
         begin
           PawnNo[Color] := PawnNo[Color] + 1;          { Count Pieces }
           with PieceTab[Color,PawnNo[Color]] do        { Insert Piece }
           begin
             IPiece := Piece1;
             ISquare := Square;
             Index := PawnNo[Color];
           end;
         end;
         Square := Square xor $77;     { Generate all squares from }
         if (Square and 4) = 0 then    {  border to center }
            if Square >= $70 then
               Square := (Square + $11) and $73
            else
               Square := Square + $10;
     until Square = 0;
   end;
end; { CalcPieceTab }

procedure GenCastSquare(New1 : SquareType;
                        var CastSquare,
                            CornerSquare : SquareType);
{ Calculates the squares for the Rook Move in a castling }
begin
   if (New1 and 7) >= 4 then     { Short }
   begin
      CastSquare := New1 - 1;
      CornerSquare := New1 + 1;
   end
   else
   begin                         { Long }
     CastSquare := New1 + 1;
     CornerSquare := New1 - 2;
   end;
end; { GenCastSquare }


{ Utility functions for Perform: }

procedure MovePiece(New1,Old : SquareType);
{ Is used to Move a Piece }
var
  B : BoardType;
begin
  with CC do
  begin
    B := Board[New1];
    Board[New1] := Board[Old];
    Board[Old] := B;
    with Board[New1] do
       PieceTab[Color,Index].ISquare := New1;
  end;
end; { MovePiece }

procedure DeletePiece(InSquare : SquareType);
{ Is used in captures. The Square must not be Empty }
begin
  with CC, Board[InSquare] do
  begin
    Piece := Empty;
    PieceTab[Color,Index].IPiece := Empty;
  end;
end; { DeletePiece }

procedure InsertPiece(InPiece : PieceType;
                      InColor : ColorType;
                     InSquare : SquareType);
{ Is used to take Back captures }
begin
   with CC, Board[InSquare],PieceTab[InColor,Index] do
   begin
      Piece := InPiece;
      Color := InColor;
      IPiece := InPiece;
      ISquare := InSquare;
   end;
end; { InsertPiece }

procedure ChangeType(NewType : PieceType; InSquare : SquareType);
{ Is used for Pawn promotion }
begin
   with CC, Board[InSquare] do
   begin
      Piece := NewType;
      PieceTab[Color,Index].IPiece := NewType;
      if OfficerNo[Color] < Index then
         OfficerNo[Color] := Index;
   end;
end; { ChangeType }


procedure InitBoard;
{ Clears the Board and initializes the Board-module }
var
  i : 0..7;
begin
  with CC do
  begin
    FillChar(Board, sizeof(Board), 0);
    for i := 0 to 7 do                   { Setup Start position }
    begin
      InsertPiece(Pieces[i],White, i);
      InsertPiece(Pawn,White, i + $10);
      InsertPiece(Pawn,Black, i + $60);
      InsertPiece(Pieces[i],Black, i + $70);
    end;
  end;
  CalcPieceTab;  { init the PieceTable, closely coupled with the board }
end; { InitBoard }



procedure Perform(Move : MoveType; ResetMove : boolean);
{ Performs or takes Back Move (takes Back if ResetMove if true),
  and performs the updating of Board and PieceTab. Player must
  contain the Color of the moving Player, Opponent the Color
  of the Opponent.

  MovePiece, DeletePiece, InsertPiece and ChangeType
  are used to Update the Board module
}

var
  New1,CastSquare,CornerSquare,EpSquare : SquareType;
begin
  with CC, Move do
  begin
    if ResetMove then              { Perform Move }
    begin
      MovePiece(Old,New1);
      if Content <> Empty then
        InsertPiece(Content,Opponent,New1);
    end
    else
    begin
      if Content <> Empty then
        DeletePiece(New1);
      MovePiece(New1,Old);
    end;
    if Spe then                   { Test if Move is special }
      if MovPiece = King then
      begin
        GenCastSquare(New1,CastSquare,CornerSquare); { Castling Move }
        if ResetMove then
          MovePiece(CornerSquare,CastSquare)
        else
          MovePiece(CastSquare,CornerSquare);
      end
      else
        if MovPiece = Pawn then
        begin
          EpSquare := (New1 and 7) + (Old and $70);    { E.p. capture }
          if ResetMove then
            InsertPiece(Pawn,Opponent,EpSquare)
          else
            DeletePiece(EpSquare);
        end
        else                                          { Pawn-promotion }
          if ResetMove then
            ChangeType(Pawn,Old)
          else
            ChangeType(MovPiece,New1);
  end; { with }
end; { Perform }

end.