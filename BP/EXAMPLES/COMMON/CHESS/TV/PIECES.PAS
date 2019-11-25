unit Pieces;

interface

{$IFDEF DLL}
uses Objects, Views, Dialogs, ChessDLL, ChessCmd, Drivers;
{$ELSE}
uses Objects, Views, Dialogs, ChessInf, ChessCmd, Drivers;
{$ENDIF}

type
  PChessPiece = ^TChessPiece;
  TChessPiece = object(TView)
    PieceType: TSquare;
    Location: TLocation;
    constructor Init(var Bounds: TRect; APieceType: TSquare; ALocation: TLocation);
    constructor Load(var S:TStream);
    procedure CapturePiece;
    procedure Draw; virtual;
    function GetPromotionPiece: TPiece;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure MoveToSquare(ALocation: TLocation);
    procedure SnapToSquare;
    procedure Store(var S: TStream);
  end;

const
  RChessPiece: TStreamRec = (
    ObjType: otChessPiece;
    VmtLink: Ofs(TypeOf(TChessPiece)^);
    Load:    @TChessPiece.Load;
    Store:   @TChessPiece.Store);

implementation
uses ChessUtl, Board;

type
  TPictureType = array[0..2] of
  record
     x : integer;
     s : string[6];
  end;

const
  PiecePicture: array[pKing..pPawn] of TPictureType =

        (((x : 1;   s :  '++++'),
          (x : 1;   s :  'ô Kô'),
          (x : 1;   s :  'õõõõ')),

         ((x : 1;   s :  'éééé'),
          (x : 1;   s :  'ÆÎÎµ'),
          (x : 1;   s :  '³ Q³')),

         ((x : 1;   s :  'ÚÒÒ¿'),
          (x : 1;   s :  '³ R³'),
          (x : 1;   s :  '³  ³')),

         ((x : 2;   s :   'Úê¿'),
          (x : 2;   s :   '³ ³'),
          (x : 2;   s :   '³B³')),

         ((x : 1;   s :  'ÚÄÄ¿'),
          (x : 1;   s :  'Ô¿''³'),
          (x : 2;   s :   '³N³')),

         ((x : 0;   s : ''     ),
          (x : 3;   s :    'P' ),
          (x : 2;   s :   'ððð')));


constructor TChessPiece.Init(var Bounds: TRect; APieceType: TSquare; ALocation: TLocation);
begin
  inherited Init(Bounds);
  EventMask := EventMask or (evMove + evBroadcast);
  PieceType := APieceType;
  Location := ALocation;
end;

constructor TChessPiece.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(PieceType, SizeOf(PieceType) + SizeOf(TLocation));
end;

procedure TChessPiece.CapturePiece;
begin
  Hide;
  DrawView;
  Free;
end;

procedure TChessPiece.Draw;
var
  Color: Word;
  I: Integer;
  B: TDrawBuffer;
  XOfs, XLen: Integer;
  R: TRect;
  WasVisible: Boolean;

  procedure DoDraws(P: PView);
  var
    Bounds: TRect;
  begin
    while P <> nil do
    begin
      P^.GetBounds(Bounds);
      Bounds.Intersect(R);
      if not Bounds.Empty then
        P^.DrawView;
      P := P^.NextView;
    end;
  end;

begin
  Owner^.Lock;
  WasVisible := State and sfVisible <> 0;
  State := State and not sfVisible;
  GetBounds(R);
  DoDraws(NextView);
  if not WasVisible then Exit;
  State := State or sfVisible;

  if PieceType.Color = cBlack then
    Color := GetColor($0404) else Color := GetColor($0505);
  for I := 0 to 2 do
  begin
    XOfs := PiecePicture[PieceType.Piece][I].x;
    XLen := Length(PiecePicture[PieceType.Piece][I].s);
    if XLen > 0 then
    begin
      MoveStr(B, PiecePicture[PieceType.Piece][I].s, Color);
      WriteBuf(XOfs, I, XLen, 1, B);
    end;
  end;
  Owner^.Unlock;
end;

function TChessPiece.GetPromotionPiece: TPiece;
begin
  if PieceType.Piece = pPawn then
    GetPromotionPiece := pQueen
  else GetPromotionPiece := PieceType.Piece;
end;

procedure TChessPiece.HandleEvent(var Event: TEvent);
var
  E: TEvent;
  R: TRect;
  P: PChessPiece;
  S: TSquare;
begin
  inherited HandleEvent(Event);
  case Event.What of
    evMouseDown:
      if PChessBoard(Owner)^.CanMovePiece(PieceType.Color) then
      begin
        MakeFirst;
        R.Assign(0, 0, Owner^.Size.X, Owner^.Size.Y);
        DragView(Event, dmDragMove, R, Size, Size);
        SnapToSquare;
      end;
    evMove:
      case Event.Command of
        cmMovePiece:
          with PMove(Event.InfoPtr)^ do
            if (Kind in [kNormal, kEnPassant, kPawnPromote, kCastling]) and
              (Word(Change.Source) = Word(Location)) then
            begin
              if (Kind = kPawnPromote) and (PieceType.Piece = pPawn) then
                PieceType.Piece := Change.Piece;
              MoveToSquare(Change.Dest);
            end
            else if (PieceType.Piece = Contents) and Capture and
              (Word(Change.Dest) = Word(Location)) then
              CapturePiece
            else if (Kind = kCastling) and (PieceType.Piece = pRook) and
              (Word(RookSource) = Word(Location)) then
              MoveToSquare(RookDest)
            else if (Kind = kEnPassant) and (PieceType.Piece = Contents) and
              Capture and (Word(EPCapture) = Word(Location)) then
              CapturePiece;
        cmUndoMove:
          with PMove(Event.InfoPtr)^ do
            if (Word(Change.Dest) = Word(Location)) then
            begin
              if (Kind = kPawnPromote) and (Change.Piece = PieceType.Piece) then
                PieceType.Piece := pPawn;
              MoveToSquare(Change.Source);
              if Capture then
              begin
                S.Piece := Contents;
                if PieceType.Color = cWhite then
                  S.Color := cBlack else S.Color := cWhite;
                case Kind of
                  kNormal:
                    begin
                      SquareToLocal(Change.Dest, R.A, Owner^.Size.Y);
                      R.Assign(R.A.X, R.A.Y, R.A.X + 6, R.A.Y + 3);
                      P := New(PChessPiece, Init(R, S, Change.Dest));
                    end;
                  kEnPassant:
                    begin
                      SquareToLocal(EPCapture, R.A, Size.Y);
                      R.Assign(R.A.X, R.A.Y, R.A.X + 6, R.A.Y + 3);
                      P := New(PChessPiece, Init(R, S, EPCapture));
                    end;
                end;
                Owner^.Insert(P);
              end;
            end
            else if (Kind = kCastling) and (PieceType.Piece = pRook) and
              (Word(RookDest) = Word(Location)) then
              MoveToSquare(RookSource);
        cmFindPiece:
          if Event.InfoWord = Word(Location) then
            ClearEvent(Event);
      end;
    evBroadcast:
      case Event.Command of
        cmRegisterSave: PCollection(Event.InfoPtr)^.Insert(@Self);
      end;
  end;        
end;

procedure TChessPiece.MoveToSquare(ALocation: TLocation);
var
  Point: TPoint;
begin
  Location := ALocation;
  SquareToLocal(Location, Point, Owner^.Size.Y);
  MoveTo(Point.X, Point.Y);
end;

procedure TChessPiece.SnapToSquare;
var
  S: TLocation;
  P: TPoint;
  C: TChange;
  Result: TChessError;
begin
  P.X := Origin.X + (Size.X div 2);
  P.Y := Origin.Y + (Size.Y div 2);
  PointInSquare(P, S);
  C.Piece := PieceType.Piece;
  C.Source := Location;
  C.Dest := S;
  Result := PChessBoard(Owner)^.ValidateMove(C);
  case Result of
    ceOK: Message(Owner, evMove, cmSubmitMove, @C);
    ceAmbiguousMove:
      begin
        C.Piece := GetPromotionPiece;
        Message(Owner, evMove, cmSubmitMove, @C);
      end;
  else
    SquareToLocal(Location, P, Owner^.Size.Y);
    MoveTo(P.X, P.Y);
  end;
end;

procedure TChessPiece.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(PieceType, SizeOf(PieceType) + SizeOf(TLocation));
end;

end.
