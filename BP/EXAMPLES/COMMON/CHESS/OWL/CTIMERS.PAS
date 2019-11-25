unit CTimers;
interface
uses Objects;

type
  TTimerStatus = (tsStopped, tsRunning);

  PChessTimer = ^TChessTimer;
  TChessTimer = object(TObject)
    Status: TTimerStatus;
    TotalTime: Longint;
    constructor Init;
    constructor Load(var S: TStream);
    function AddTo(ATimer: PChessTimer): Longint;
    procedure Clear;
    function GetCurrentTicks: Longint;
    procedure Start;
    procedure Stop;
    procedure Store(var S: TStream);
  private
    TimeAtStart: Longint;
    function TicksSinceStart: Longint;
  end;

const
  RChessTimer: TStreamRec = (
    ObjType: 5005;
    VmtLink: Ofs(TypeOf(TChessTimer)^);
    Load:    @TChessTimer.Load;
    Store:   @TChessTimer.Store);

procedure ConvertTicks(TotalTicks: Longint; var Hours, Minutes, Seconds, Ticks: Word);

implementation

const
  TotalDayTime = $0017FE7F;

{$IFDEF WINDOWS}
procedure __0040H;  far; external 'Kernel' index 193;
const
  Seg0040: Word = Ofs(__0040H);
{$ENDIF}

function CurrentTicks: Longint;
begin
  CurrentTicks := MemL[Seg0040:$6C];
end;

function PastMidnight: Boolean;
begin
  PastMidnight := MemL[Seg0040:$70] <> 0;
end;

constructor TChessTimer.Init;
begin
  Status := tsStopped;
  TimeAtStart := 0;
  TotalTime := 0;
end;

constructor TChessTimer.Load(var S: TStream);
begin
  S.Read(Status, SizeOf(Status) + SizeOf(Longint));
end;

function TChessTimer.AddTo(ATimer: PChessTimer): Longint;
begin
  AddTo := GetCurrentTicks + ATimer^.GetCurrentTicks;
end;

procedure TChessTimer.Clear;
begin
  if Status = tsStopped then TotalTime := 0;
end;

function TChessTimer.GetCurrentTicks: Longint;
begin
  if Status = tsRunning then
    GetCurrentTicks := TotalTime + TicksSinceStart
  else GetCurrentTicks := TotalTime;
end;

procedure TChessTimer.Start;
begin
  if Status = tsStopped then
  begin
    Status := tsRunning;
    TimeAtStart := CurrentTicks;
  end;
end;

procedure TChessTimer.Stop;
begin
  if Status = tsRunning then
  begin
    Status := tsStopped;
    TotalTime := TotalTime + TicksSinceStart;
  end;
end;

procedure TChessTimer.Store(var S: TStream);
begin
  S.Write(Status, SizeOf(Status) + SizeOf(Longint));
end;

function TChessTimer.TicksSinceStart: Longint;
var
  Ticks, TickDif: Longint;
begin
  Ticks := CurrentTicks;
  if PastMidnight then
    TickDif := TotalDayTime - TimeAtStart + Ticks
  else TickDif := Ticks - TimeAtStart;
  TicksSinceStart := TickDif;
end;

procedure ConvertTicks(TotalTicks: Longint; var Hours, Minutes, Seconds, Ticks: Word);
begin
  Hours := TotalTicks div 65520;
  Minutes := (TotalTicks mod 65520) div 1092;
  Seconds := ((((TotalTicks mod 65520) mod 1092) div 91) * 5);
  Seconds := Seconds + ((((TotalTicks mod 65520) mod 1092) mod 91) div 18);
  Ticks := ((((TotalTicks mod 65520) mod 1092) mod 91) mod 18);
end;

end.
