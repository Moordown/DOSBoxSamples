unit board;

interface

uses Winprocs, Wintypes, Objects, OWindows, ChPieces, Chessdll,
     chconst;

type
  PChessBoard = ^TChessBoard;
  TChessBoard = object(TWindow)
    Game: HChess;
    Squares: array [1..8,1..8] of PChessPiece;
    Pieces: TCollection;
    BoardBitmap: HBitmap;
    WhiteColor: TColorRef;
    BlackColor: TColorRef;
    WhiteBrush: HBrush;
    BlackBrush: HBrush;
    SquareWidth: Word;
    Dragger: PChessPiece;    { if <> nil, we're dragging it }
    BoardDC, DragDC: HDC;
    BoardOldBM, DragBM : HBitmap;
    ValidMoves,
    OpponentMoves: array [0..(28*16+1)] of TMove;
    { Setup and shutdown }
    constructor Init(AParent: PWindowsObject; GH: HChess);
    destructor Done; virtual;
    function  GetClassName: PChar; virtual;
    procedure GetWindowClass(var WC: TWndClass); virtual;
    procedure ResetBoard(GH: HChess);

    { Board display }
    function  IdealWidth: Word;
    procedure InitBoardBitmap;
    procedure DrawBoard;
    procedure Paint(DC: HDC; var PS: TPaintStruct); virtual;
    procedure WMEraseBkgnd(var Msg: TMessage);
      virtual wm_First + wm_EraseBkgnd;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;

    { Conversions }
    function  PieceFromPoint(Pt: TPoint): PChessPiece;
    procedure SquareFromPoint(Pt: TPoint; var Sq: TLocation);
    procedure SquareToRect(Sq: TLocation; var R: TRect);

    { Piece management }
    procedure InsertPiece(Sq: TLocation; P: PChessPiece);
    function  RemovePiece(Sq: TLocation): PChessPiece;
    procedure ExecuteMove(const Move: TMove);
    procedure RetractMove(const Move: TMove);
    procedure ResetValidMoves;
    procedure FreshenPiece(P : PChessPiece);

    { Piece dragging routines }
    procedure WMSetCursor(var Msg: TMessage);
      virtual wm_First + wm_SetCursor;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMMouseMove(var Msg: TMessage);
      virtual wm_First + wm_MouseMove;
    procedure WMLButtonUp(var Msg: TMessage);
      virtual wm_First + wm_LButtonUp;
  end;

  function OtherPlayer(Color: TColor): TColor;

implementation

uses AppUtils, ChessDlg;

function OtherPlayer(Color: TColor): TColor;
begin
  if Color = cWhite then
    OtherPlayer := cBlack
  else
    OtherPlayer := cWhite;
end;

constructor TChessBoard.Init(AParent: PWindowsObject; GH: HChess);
begin
  inherited Init(AParent, nil);
  with Attr do
  begin
    X := 0;
    Y := 0;
    W := 200;
    H := 200;
    Style := ws_Child {or ws_Border};
        { NOT ws_Visible - the parent window will resize us  }
        { to the ideal width and then show us.               }
  end;
  BoardBitmap := 0;
  DragDC := 0;
  BoardDC := CreateMemoryDC;
  Dragger := nil;
  WhiteColor := XApp^.GetAppProfileRGB(
                       'Board','WhiteColor',RGB(255,255,255));
  WhiteBrush := CreateSolidBrush(WhiteColor);
  BlackColor := XApp^.GetAppProfileRGB(
                       'Board','BlackColor',RGB(255,0,0));
  BlackBrush := CreateSolidBrush(BlackColor);
  Pieces.Init(32, 4);  { Growth allows for edited boards with > 32 pieces }
  ResetBoard(GH);
end;

destructor TChessBoard.Done;
var
  Temp: array [0..15] of Char;
begin
  inherited Done;
  Pieces.Done;
  if BoardDC <> 0 then
  begin
    SelectObject(BoardDC, BoardOldBM);
    DeleteDC(BoardDC);
  end;
  if DragDC <> 0 then
  begin
    DeleteObject(SelectObject(DragDC, DragBM));
    DeleteDC(DragDC);
  end;
  if BoardBitmap <> 0 then
    DeleteObject(BoardBitmap);
  DeleteObject(WhiteBrush);
  DeleteObject(BlackBrush);
  XApp^.WriteAppProfileRGB('Board','WhiteColor',WhiteColor);
  XApp^.WriteAppProfileRGB('Board','BlackColor',BlackColor);
end;

function  TChessBoard.GetClassName: PChar;
begin
  GetClassName := 'TPWOWLChessBoard';
end;

procedure TChessBoard.GetWindowClass(var WC: TWndClass);
begin
  inherited GetWindowClass(WC);
  WC.Style := cs_ByteAlignWindow;
  WC.hCursor := 0;
end;

procedure TChessBoard.ResetBoard(GH: HChess);
  procedure DoResize(P : PChessPiece); far;
  var
    R: TRect;
    S: TLocation;
  begin
    P^.GetSquare(S);
    SquareToRect(S, R);
    P^.SetRect(R);
  end;
var
  TempBoard: TBoard;
  Square: TLocation;
begin
  Game := GH;
  Pieces.FreeAll;
  FillChar(Squares, SizeOf(Squares), 0);

  GetBoard(Game, TempBoard);

  SquareWidth := Attr.W div 8;
  for Square.X := 1 to 8 do
    for Square.Y := 1 to 8 do
      if (TempBoard[Square.X, Square.Y].Piece <> pEmpty) then
      begin
        Squares[Square.X,Square.Y] := New(PChessPiece,
             Init(@Self, TempBoard[Square.X, Square.Y], Square));
        Pieces.Insert(Squares[Square.X,Square.Y]);
      end;
  ResetValidMoves;
  if HWindow <> 0 then
  begin
    Pieces.ForEach(@DoResize);
    DrawBoard;
    InvalidateRect(HWindow, nil, False);
  end;
end;

function TChessBoard.IdealWidth: Word;
var
  Best: Word;
  procedure CheckBitmapSize(P: PChessPiece); far;
  begin
    if Best < P^.BitSize.X then Best := P^.BitSize.X;
    if Best < P^.BitSize.Y then Best := P^.BitSize.Y;
  end;
begin
  Best := 0;
  Pieces.ForEach(@CheckBitmapSize);
  IdealWidth := (Best + 4) * 8;
end;

procedure TChessBoard.InitBoardBitmap;
var
  DC: HDC;
begin
  if BoardBitmap <> 0 then
  begin
    SelectObject(BoardDC, BoardOldBM);
    DeleteObject(BoardBitmap);
  end;

  DC := GetDC(HWindow);
  BoardBitmap := CreateCompatibleBitmap(DC, Attr.W, Attr.H);
  ReleaseDC(HWindow, DC);
  BoardOldBM := SelectObject(BoardDC, BoardBitmap);
  SquareWidth := Attr.W div 8;
end;

procedure TChessBoard.DrawBoard;
var
  OldBrush, SquareBrush : HBrush;
  X, Y: Integer;

  procedure DoPaint(P: PChessPiece); far;
  begin
    P^.Paint(BoardDC);
  end;

begin
  OldBrush := SelectObject(BoardDC, CreateSolidBrush(WhiteColor));
  PatBlt(BoardDC, 0, 0, Attr.W, Attr.H, PatCopy);

  DeleteObject(SelectObject(BoardDC, CreateSolidBrush(BlackColor)));
  for Y := 0 to 7 do
    for X := 0 to 7 do
      if Odd(X + Y) then
        PatBlt(BoardDC, X * SquareWidth, Y * SquareWidth,
                      SquareWidth, SquareWidth, PatCopy);

  DeleteObject(SelectObject(BoardDC, OldBrush));
  Pieces.ForEach(@DoPaint);
end;

{ Because of the way the board paints from a memory bitmap, we don't
  need the window to erase the background before we paint.  }
procedure TChessBoard.WMEraseBkgnd(var Msg: TMessage);
begin
  Msg.Result := 1;
end;

procedure TChessBoard.Paint(DC: HDC; var PS: TPaintStruct);
  procedure CheckPieces(P: PChessPiece); far;
  var
    Sq: TLocation;
    OldBrush: HBrush;
  begin
    if P^.NeedRedraw then
    begin
      P^.GetSquare(Sq);
      if Odd(Sq.X + Sq.Y) then
        OldBrush := SelectObject(BoardDC, WhiteBrush)
      else
        OldBrush := SelectObject(BoardDC, BlackBrush);
      with P^.Rect do
        PatBlt(BoardDC, Left, Top, Right - Left, Bottom - Top, PatCopy);
      SelectObject(BoardDC, OldBrush);
      P^.Paint(BoardDC);
    end;
  end;
begin
  Pieces.ForEach(@CheckPieces);
  with PS.rcPaint do
    BitBlt(DC, Left, Top, Right - Left, Bottom - Top,
           BoardDC, Left, Top, SrcCopy);
  if Dragger <> nil then
    Dragger^.Paint(DC);
end;

procedure TChessBoard.WMSize(var Msg: TMessage);

  procedure DoResize(P : PChessPiece); far;
  var
    R: TRect;
    S: TLocation;
  begin
    P^.GetSquare(S);
    SquareToRect(S, R);
    P^.SetRect(R);
  end;

begin
  inherited WMSize(Msg);
  SquareWidth := Attr.W div 8;
  InitBoardBitmap;
  Pieces.ForEach(@DoResize);
  DrawBoard;
end;

function TChessBoard.PieceFromPoint(Pt: TPoint): PChessPiece;
  function DoHitTest(P: PChessPiece): Boolean; far;
  begin
    DoHitTest := P^.HitTest(Pt);
  end;
begin
  PieceFromPoint := PChessPiece(Pieces.FirstThat(@DoHitTest));
end;

procedure TChessBoard.SquareFromPoint(Pt: TPoint; var Sq: TLocation);
begin
  Sq.X := (Pt.X div SquareWidth) + 1;
  Sq.Y := (Attr.H - Pt.Y) div SquareWidth + 1;
end;

procedure TChessBoard.SquareToRect(Sq: TLocation; var R: TRect);
begin
  R.Left   := (Sq.X - 1) * SquareWidth;
  R.Right  := R.Left + SquareWidth;
  R.Top    := Attr.H - (Sq.Y * SquareWidth);
  R.Bottom := R.Top + SquareWidth;
end;

procedure TChessBoard.ExecuteMove(const Move: TMove);

  function  CreatePromote(P: TPiece; Dest: TLocation): PChessPiece;
  var                    { This function creates the piece specified by }
    X: TSquare;          { P using color info from the piece already on }
  begin                  { on the board at Dest.  This is for           }
    X.Piece := P;        { Pawn Promotion moves only.                   }
    X.Color := Squares[Dest.X, Dest.Y]^.Color;
    InsertPiece(Dest, New(PChessPiece, Init(@Self, X, Dest)));
  end;

begin
  if Move.Change.Piece = pEmpty then Exit;
  with Move, Move.Change do
  begin
    InsertPiece(Dest, RemovePiece(Source)); { Also deletes what's at dest }
    case Move.Kind of
      kEnPassant  : Dispose(RemovePiece(EPCapture), Done);
      kCastling   : InsertPiece(RookDest, RemovePiece(RookSource));
      kPawnPromote: CreatePromote(Piece, Dest);
    end;
  end;
end;

procedure TChessBoard.RetractMove(const Move: TMove);
  procedure CreatePiece(P: TPiece; Color: Boolean; Dest: TLocation);
  var
    X: TSquare;
  begin
    X.Piece := P;
    X.Color := TColor(Color);
    InsertPiece(Dest, New(PChessPiece, Init(@Self, X, Dest)));
  end;
var
  Color: Boolean;   { Color of opponent }
begin
  if Move.Change.Piece = pEmpty then Exit;
  with Move, Move.Change do
  begin
    Color := not Boolean(Squares[Dest.X, Dest.Y]^.Color);
    InsertPiece(Source, RemovePiece(Dest)); {Back out of destination }
    case Move.Kind of
      kNormal     : if Capture then CreatePiece(Contents, Color, Dest);
      kEnPassant  : CreatePiece(Contents, Color, EPCapture);
      kCastling   : InsertPiece(RookSource, RemovePiece(RookDest));
      kPawnPromote:
        begin
          if Capture then CreatePiece(Contents, not Color, Dest);
          CreatePiece(pPawn, Color, Source);
        end;
    end;
  end;
end;


procedure TChessBoard.ResetValidMoves;
var
  Chg: TChange;
  PlayerColor: TColor;
  EmptyMove: TMove;

  procedure DoValids(P : PChessPiece); far;
  begin
    if P^.Color = PlayerColor then
      P^.ResetValidMoves(ValidMoves)  { piece gets its moves from list }
    else
    begin
      P^.ResetValidMoves(EmptyMove);  { clear opponent's move lists }
      if ChessSettings.ShowAttacks then
        P^.CheckJeopardy(ValidMoves);
    end;
  end;

  procedure DoJeopardies(P : PChessPiece); far;
  begin
    if P^.Color = PlayerColor then
      P^.CheckJeopardy(OpponentMoves);
  end;

begin
  Chg.Piece := pEmpty;
  Word(Chg.Source) := 0;
  Word(Chg.Dest) := 0;
  FillChar(EmptyMove, SizeOf(EmptyMove), 0);
  PlayerColor := GetPlayer(Game);
  if ChessSettings.ShowJeopardies then
  begin
    { Switch players to see which opponent pieces attack ours }
    SetPlayer(Game, OtherPlayer(PlayerColor));
    GetValidMoves(Game, Chg, OpponentMoves);
    SetPlayer(Game, PlayerColor);
    Pieces.ForEach(@DoJeopardies);
  end;
  { Now see what moves our pieces can make }
  GetValidMoves(Game, Chg, ValidMoves);
  Pieces.ForEach(@DoValids);
end;

procedure TChessBoard.FreshenPiece(P:PChessPiece);
var
  TempMoves: array [0..28] of TMove;
  PlayerColor: TColor;
  Chg: TChange;
  EmptyMove: TMove;
begin
  Chg.Piece := pEmpty;
  Word(Chg.Source) := 0;
  Chg.Dest := P^.Square;
  FillChar(EmptyMove, SizeOf(EmptyMove), 0);
  PlayerColor := GetPlayer(Game);
  if ChessSettings.ShowJeopardies then
  begin
    { Switch players to see which opponent pieces attack ours }
    SetPlayer(Game, OtherPlayer(PlayerColor));
    GetValidMoves(Game, Chg, TempMoves);
    SetPlayer(Game, PlayerColor);
    P^.CheckJeopardy(TempMoves);
  end;
end;

procedure TChessBoard.WMSetCursor(var Msg: TMessage);
var
  P: TPoint;
  X: PChessPiece;
begin
  DefWndProc(Msg);
  if Msg.Result = 0 then
  begin
    GetCursorPos(P);
    ScreenToClient(HWindow, P);
    X := PieceFromPoint(P);
    if (X <> nil) and X^.CanDrag then
      SetCursor(X^.GetCursor)
    else
      SetCursor(LoadCursor(0, PChar(idc_Arrow)));
  end;
end;

procedure TChessBoard.WMLButtonDown(var Msg: TMessage);
var
   R: TRect;
  Sq: TLocation;
  DC: HDC;
begin
  if Dragger = nil then
  begin
    Dragger := PieceFromPoint(TPoint(Msg.LParam));
    if Dragger <> nil then
      if Dragger^.CanDrag then
      begin
        Dragger^.GetSquare(Sq);
        RemovePiece(Sq);
        SetCapture(HWindow);
        DC := GetDC(HWindow);
        DragDC := CreateCompatibleDC(DC);
        DragBM := SelectObject(DragDC,
                    CreateCompatibleBitmap(DC, Attr.W, Attr.H));
        BitBlt(DragDC, 0, 0, Attr.W, Attr.H, BoardDC, 0, 0, SrcCopy);
        R := Dragger^.Rect;
        Dragger^.DragBegin(DragDC, TPoint(Msg.LParam));
        UnionRect(R, R, Dragger^.Rect);
        with R do
          BitBlt(DC, Left, Top, Right - Left, Bottom - Top,
                 DragDC, Left, Top, SrcCopy);
        ReleaseDC(HWindow, DC);
      end
      else
      begin
        Dragger := nil;
        MessageBeep(0);
      end;
  end;
  DefWndProc(Msg);
end;

procedure TChessBoard.WMMouseMove(var Msg: TMessage);
var
   R: TRect;
  Sq: TLocation;
  DC: HDC; 
begin
  if Dragger <> nil then
  begin
    GetClientRect(HWindow, R);
    if PtInRect(R, TPoint(Msg.LParam)) then
    begin
      SquareFromPoint(TPoint(Msg.LParam), Sq);
      with Dragger^.Rect do
        BitBlt(DragDC, Left, Top, Right - Left, Bottom - Top,
               BoardDC, Left, Top, SrcCopy);
      R := Dragger^.Rect;
      Dragger^.DragContinue(DragDC, TPoint(Msg.LParam), Sq);
      UnionRect(R, R, Dragger^.Rect);
      DC := GetDC(HWindow);
      with R do
        BitBlt(DC, Left, Top, Right - Left, Bottom - Top,
               DragDC, Left, Top, SrcCopy);
      ReleaseDC(HWindow, DC);
    end
    else
    begin
      Dragger^.DragHide;
      InvalidateRect(HWindow, @Dragger^.Rect, False);
      SetCursor(LoadCursor(GetModuleHandle('User'), PChar(idc_No)));
    end;
  end;
  DefWndProc(Msg);
end;

procedure TChessBoard.WMLButtonUp(var Msg: TMessage);
var
  NewSq, OldSq: TLocation;
  R: TRect;
  Chg: TChange;
  ValidMove: Boolean;
  PlayerColor : TColor;
begin
  if Dragger <> nil then
  begin
    GetClientRect(HWindow, R);
    with Dragger^.Rect do
      BitBlt(DragDC, Left, Top, Right - Left, Bottom - Top,
             BoardDC, Left, Top, SrcCopy);
    if PtInRect(R, TPoint(Msg.LParam)) then
      SquareFromPoint(TPoint(Msg.LParam), NewSq)
    else
    begin
      NewSq.X := 0;     { 0 = off board or invalid }
      NewSq.Y := 0;
    end;
    R := Dragger^.Rect;
    Dragger^.GetSquare(OldSq);
    ValidMove := Dragger^.DragEnd(DragDC, TPoint(Msg.LParam), NewSq, Chg);
    InvalidateRect(HWindow, @R, False);
    InsertPiece(OldSq, Dragger);  { Go back to original square }
    Dragger := nil;
    ReleaseCapture;
    DeleteObject(SelectObject(DragDC, DragBM));
    DeleteDC(DragDC);
    DragDC := 0;
    if (Chg.Piece = pPawn) and (VerifyMove(Game, Chg) = ceAmbiguousMove) then
      Chg.Piece := pQueen;
            { am_SubmitMove will return a boolean accept/reject response }
    if ValidMove and
       LongBool(SendMessage(Parent^.HWindow, am_SubmitMove, 0, Longint(@Chg))) then
    begin
        { After Submitmove, player color has switched.  We need to temporarily
          switch it back to our color for the following operations. }
      PlayerColor := GetPlayer(Game);
      SetPlayer(Game, OtherPlayer(PlayerColor));
      if ChessSettings.ShowAttacks then
        { Reset all pieces' valid moves, so that opponents that were attacked by
          the moved piece's former position can be cleared as well as note what
          opponent pieces are now attacked in the new position. }
        ResetValidMoves
      else
      if ChessSettings.ShowJeopardies then
        { For jeopardies, we just need to see who attacks the new square.
          FreshenPiece is must faster and simpler than ResetValidMoves. }
        FreshenPiece(Squares[NewSq.X,NewSq.Y]);
      SetPlayer(Game, PlayerColor);
    end;
    UpdateWindow(HWindow);
  end;
  DefWndProc(Msg);
end;

procedure TChessBoard.InsertPiece(Sq: TLocation; P: PChessPiece);
var
  R: TRect;
begin
  if Squares[Sq.X,Sq.Y] = P then Exit;
  if (Squares[Sq.X,Sq.Y] <> nil) then
    Dispose(RemovePiece(Sq), Done);
  Pieces.Insert(P);
  P^.SetSquare(Sq);
  Squares[Sq.X, Sq.Y] := P;
  SquareToRect(Sq, R);
  P^.SetRect(R);
  P^.Paint(BoardDC);
  InvalidateRect(HWindow, @R, False);
end;

function TChessBoard.RemovePiece(Sq: TLocation): PChessPiece;
var
  OldBrush: HBrush;
  R: TRect;
begin
  RemovePiece := nil;
  if Squares[Sq.X,Sq.Y] <> nil then
  begin
    RemovePiece := Squares[Sq.X,Sq.Y];
    Pieces.Delete(Squares[Sq.X,Sq.Y]);
    Squares[Sq.X,Sq.Y] := nil;

    if Odd(Sq.X + Sq.Y) then
      OldBrush := SelectObject(BoardDC, WhiteBrush)
    else
      OldBrush := SelectObject(BoardDC, BlackBrush);
    SquareToRect(Sq, R);
    with R do
      PatBlt(BoardDC, Left, Top, Right - Left, Bottom - Top, PatCopy);
    SelectObject(BoardDC, OldBrush);
    InvalidateRect(HWindow, @R, False);
  end;
end;

end.