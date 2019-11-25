

uses
{$IFDEF DLL}
  ChessDll,
{$ELSE}
  ChessInf,
{$ENDIF}
  Crt, Strings;

const
  PieceName: array[TPiece] of Char =
    ('+', 'K', 'Q', 'R', 'B', 'N', 'P');

procedure WriteBoard(var Board: TBoard; Player: TColor);
var
  I, J: Integer;
begin
  Writeln('  A B C D E F G H');
  for I := High(Board) downto Low(Board) do
  begin
    NormVideo;
    Write(I, ' ');
    for J := Low(Board[I]) to High(Board[I]) do
    begin
      with Board[J, I] do
      begin
        if Piece = pEmpty then
        begin
          if (I + J) and 1 = 0 then LowVideo
          else HighVideo;
        end
        else
        begin
          if Color = cWhite then HighVideo
          else LowVideo;
        end;
        Write(PieceName[Piece], ' ');
      end;
    end;
    Writeln;
  end;
end;

procedure WriteMove(var Move: TMove);
var
  Str: array[0..30] of Char;
begin
  MoveToStr(Move, Str);
  Write(Str);
end;
procedure DisplayBoard(CH: HChess);
var
  Board: TBoard;
  Player: TColor;
  Move: TMove;
begin
  GetLastMove(CH, Move);
  Write(' Last move = ');
  WriteMove(Move);
  Writeln;
  GetBoard(CH, Board);
  WriteBoard(Board, GetPlayer(CH));
end;

procedure WriteMoves(var Moves: array of TMove);
var
  I: Integer;
begin
  for I := Low(Moves) to High(Moves) do
  begin
    if Moves[I].Change.Piece <> pEmpty then
    begin
      WriteMove(Moves[I]);
      Write(' ');
    end
    else
      Break;
  end;
end;

procedure CalcLocation(X, Y: Char; var Location: TLocation);
begin
   if (X in ['A'..'H']) and (Y in ['1'..'8']) then
   begin
     Location.X := ord(X) - ord('A') + 1;
     Location.Y := ord(Y) - ord('1') + 1;
   end
   else
   begin
     Location.X := 0;
     Location.Y := 0;
   end;
end;

procedure WriteMainLine(var Moves: array of TMove);
begin
  Write(#13);
  ClrEol;
  Write('Main line = ');
  WriteMoves(Moves);
end;

var
  CH: HChess;
  Str: array[0..30] of Char;
  Change: TChange;
  Move: TMove;

  Status: TSearchStatus;
  Result: TChessError;
  Player: TColor;
  Single: Boolean;
  Auto: Boolean;

  MainValue: Integer;
  MainLine: array[0..10] of TMove;
  ValidMoves: array[0..100] of TMove;

  I: TPiece;

  Count: Integer;

  OpponentColor: TColor;

begin
  TextAttr := $07;
  ClrScr;

  NewGame(CH);

  Single := False;
  Auto := False;
  OpponentColor := cWhite;

  repeat
    Player := GetPlayer(CH);
    NormVideo;
    if Player = cWhite then Write('White')
    else Write('Black');
    Writeln(' to play');

    DisplayBoard(CH);

    if not Auto and (Single or (Player = OpponentColor)) then
      repeat
        Write('Enter move: ');
        {ThinkAhead(CH);
        repeat
          Think(CH, 2, Status);
        until KeyPressed;}
        Readln(Str);
        case UpCase(Str[0]) of
          'P':
            if Str[1] = #0 then
            begin
              if OpponentColor = cWhite then
                OpponentColor := cBlack
              else
                OpponentColor := cWhite;
              Continue;
            end;
          'A':
            if Str[1] = #0 then
            begin
              Auto := True;
              Continue;
            end;
          'Q':
            if Str[1] = #0 then
            begin
              DisposeGame(CH);
              Exit;
            end;
          'R':
            if Str[1] = #0 then
            begin
              RetractMove(CH, Move);
              RetractMove(CH, Move);
              Continue;
            end;
          'S':
            begin
              Single := not Single;
              Continue;
            end;
          'B':
            if Str[1] = #0 then
            begin
              asm int 3 end;
              Continue;
            end;
          '?':
            begin
              FillChar(Change, SizeOf(Change), 0);
              case StrLen(Str) of
                2:
                  for I := Low(TPiece) to High(TPiece) do
                    if PieceName[I] = UpCase(Str[1]) then
                      Change.Piece := I;
                3:
                  CalcLocation(UpCase(Str[1]), Str[2], Change.Source);
                4:
                  if Str[1] = '?' then
                    CalcLocation(UpCase(Str[2]), Str[3], Change.Dest);
              end;

              GetValidMoves(CH, Change, ValidMoves);
              WriteMoves(ValidMoves);
              Writeln;
              Continue;
            end;
        end;

        Result := ParseMove(Str, Change);
        if Result = ceOK then
          Result := SubmitMove(CH, Change);
        case Result of
          ceOK: begin end;
          ceInvalidSyntax: Writeln('Syntax error');
          ceAmbiguousMove: Writeln('Ambiguous move');
          ceInvalidMove:   Writeln('Not a legal move');
          ceIllegalMove:   Writeln('Check prevents that move');
        else
          Writeln('Error');
        end;
      until Result = ceOK
    else
    begin
      ComputerMove(CH, 91);
      repeat
        Think(CH, 4, Status);
        GetMainLine(CH, MainValue, MainLine);
        WriteMainLine(MainLine);
      until (Status = ssComplete) or (Status = ssGameOver);
      if Status = ssGameOver then break;
      Writeln;
      Writeln(' Nodes = ', GetNodes(CH));
      case GetChessStatus(CH, Count) of
        csCheck:          Writeln('*** Check! ***');
        csCheckmate:      Writeln('*** Checkmate! ***');
        csStalemate,
        csFiftyMoveRule,
        csRepetitionRule: Writeln('*** Stalemate ***');
        csResigns:
          if GetPlayer(CH) = cWhite then
            Writeln('Black resigns')
          else
            Writeln('White resigns');
        csMateFound:
          begin
            Write('*** Checkmate in ', Count, ' move');
            if Count <> 1 then Write('s');
            Writeln(' ***');
          end;
      end;
      Writeln;
      OpponentColor := GetPlayer(CH);
    end;
  until False;

  DisposeGame(CH);
end.