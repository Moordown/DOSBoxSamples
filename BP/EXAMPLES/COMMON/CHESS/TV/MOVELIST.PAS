unit MoveList;

interface

{$IFDEF DLL}
uses Objects, ChessDLL;
{$ELSE}
uses Objects, ChessInf;
{$ENDIF}

type
  PMoveList = ^TMoveList;
  TMoveList = object(TCollection)
    UndoPos: Integer;
    constructor Load(var S: TStream);
    procedure AddMove(Move: TMove);
    function GetItem(var S: TStream): Pointer; virtual;
    procedure FreeItem(Item: Pointer); virtual;
    procedure Redo(var Move: TMove);
    procedure Undo(var Move: TMove);
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
    function RedoAvail: Boolean;
    procedure Store(var S: TStream);
    function UndoAvail: Boolean;
  end;

const
  RMoveList: TStreamRec = (
    ObjType: 5000;
    VmtLink: Ofs(TypeOf(TMoveList)^);
    Load:    @TMoveList.Load;
    Store:   @TMoveList.Store);

function NewMove(Move: TMove): PMove;
procedure DisposeMove(Move: PMove);

implementation

constructor TMoveList.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(UndoPos, SizeOf(UndoPos));
end;

procedure TMoveList.AddMove(Move: TMove);
var
  I: Integer;
begin
  if UndoPos < Count - 1 then
    while UndoPos < Count - 1 do 
      AtFree(UndoPos + 1);
  AtInsert(Count, NewMove(Move));
  UndoPos := Count - 1;
end;

function TMoveList.GetItem(var S: TStream): Pointer;
var
  Move: TMove;
begin
  S.Read(Move, SizeOf(Move));
  GetItem := NewMove(Move);
end;

procedure TMoveList.FreeItem(Item: Pointer);
begin
  DisposeMove(PMove(Item));
end;

procedure TMoveList.Redo(var Move: TMove);
begin
  if RedoAvail then
  begin
    Inc(UndoPos);
    Move := PMove(At(UndoPos))^;
  end
  else FillChar(Move, SizeOf(Move), 0);
end;

procedure TMoveList.Undo(var Move: TMove);
begin
  if UndoAvail then
  begin
    Move := PMove(At(UndoPos))^;
    Dec(UndoPos);
  end
  else FillChar(Move, SizeOf(Move), 0);
end;

procedure TMoveList.PutItem(var S: TStream; Item: Pointer);
begin
  S.Write(PMove(Item)^, SizeOf(TMove));
end;

function TMoveList.RedoAvail: Boolean;
begin
  RedoAvail := (Count > 0) and (UndoPos < Count - 1);
end;

procedure TMoveList.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(UndoPos, SizeOf(UndoPos));
end;

function TMoveList.UndoAvail: Boolean;
begin
  UndoAvail := (Count > 0) and (UndoPos >= 0);
end;

function NewMove(Move: TMove): PMove;
var
  AMove: PMove;
begin
  GetMem(AMove, SizeOf(TMove));
  AMove^ := Move;
  NewMove := AMove;
end;

procedure DisposeMove(Move: PMove);
begin
  FreeMem(Move, SizeOf(TMove));
end;

end.
