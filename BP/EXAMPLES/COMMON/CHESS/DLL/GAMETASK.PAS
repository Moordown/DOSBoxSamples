unit GameTask;

{$W-}

interface

const
  tmFindMove    = 1;
  tmThinkAhead  = 2;
  tmResume      = 3;
  tmComplete    = 4;
  tmEnterMove   = 5;
  tmTimeExpired = 6;
  tmTerminate   = $FFFF;

procedure DoGameTask;

implementation

uses GameRec, LMoves, LMoveGen, LOpenLib, LEval, TaskMgr;

procedure EnterOppMove;
begin
  AdjustMoves;
  EnterKeyMove;
  StoreMoves;
  Exclude(CC.State, MovePending);
end;

procedure RecordFindMove;
begin
  with CC do
  begin
    MovTab[0] := MainLine[0];       { Copy the MainLine to HintLine }
    Move(MainLine[1], HintLine[0], Sizeof(MainLine) - Sizeof(MoveType));
    HintEvalu := MainEvalu;
    if MovTab[0].MovPiece = Empty then
    begin
      HintLine[0] := ZeroMove;      { No Possible Move }
      Include(State, GameOver);
      Exit;
    end; { if }

    EnterMove(MovTab[Depth + 1]);
    StoreMoves;
    PlayerMove := ZeroMove;
    Exclude(State, Analysis);
  end;
end;

procedure StartMove;
{ The program moves }
var
  Result: Integer;
  Dep: DepthType;
begin
  Include(CC.State, Analysis);
  Exclude(CC.State, OppAnalysis);

  { Wait for a Think }
  repeat until Message(tmComplete) = tmResume;

  AdjustMoves;
  CalcLibNo;                        { Try to find a Move in }
  with CC do                       {  the opening library  }
  begin
    Depth := 0;
    if LibNo > 0 then
    begin
 {!     OpeningLibMsg;}
      Include(State, InLibrary);
      FindOpeningMove;
    end
    else
    begin
      Exclude(State, InLibrary);
      FindMove(MaxLevel);           { Perform the Search }
    end;
    Depth := -1;
    RecordFindMove;
  end;  { with }
end; { StartMove }

procedure ThinkAhead;
begin
{ Perform analysis in the opponents time of reflection.
  The program assumes that the Opponent will Perform the
  Hint Move, and starts analysing On it counter Move }

  with CC do
  begin
    if HintLine[0].MovPiece = Empty then
      Exit;

    Exclude(State, Analysis);
    Include(State, OppAnalysis);

    { Wait for a Think }
    repeat until Message(tmComplete) = tmResume;

    AdjustMoves;                     { Setup surroundings as if the }
    MovTab[Depth + 1] := HintLine[0];      { Opponent had performed }
    MakeMove(MovTab[Depth + 1]);                   {  the hint move }
    StoreMoves;
    AdjustMoves;
    Depth := 0;                        { Analyse until something is }
    FindMove(MaxLevel);                {  entered from the keyboard }

    Depth := -1;
    Exclude(State, OppAnalysis);

    if MovePending in State then
    begin
      { Here if we received a tmEnterMove and the opponent did not make
        the hint move.  Find the move the old fashioned way }
      TakeBackMove(MovTab[Depth]);

      { Enter opponents move }
      EnterOppMove;

      { Only legal message to receive now is tmFindMove }
      repeat until Message(tmFindMove) = tmFindMove;

      { Start the move }
      StartMove;
    end
    else
      RecordFindMove;
  end;
end; { ThinkAwhile }

{ Game background task's main loop }

procedure DoGameTask;
begin
  repeat
    case Message(tmComplete) of
      tmEnterMove:  EnterOppMove;
      tmFindMove:   StartMove;
      tmThinkAhead: ThinkAhead;
      tmTerminate:  Exit;
    end;
  until False;
end;

end.