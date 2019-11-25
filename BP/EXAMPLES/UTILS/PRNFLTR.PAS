program PrinterOutputFilter;

{$M 2048, 0, 0}
{$I-,S-,X+}

const
  MaxAttributes = 8;

type
  TPCharArray = array[0..16380] of PChar;
  PPCharArray = ^TPCharArray;

  PPrinterCodes = ^TPrinterCodes;
  TPrinterCodes = record
    PreambleCount: Byte;
    Preamble: PPCharArray;
    CodeArray: PPCharArray;
    Attributes: array[0..MaxAttributes - 1] of Byte;
    StartPage: PChar;
    EndPage: PChar;
    EndLine: PChar;
    Postamble:  PChar;
  end;

const
  EpsonItalic   = #27'4';
  EpsonNoItalic = #27'5';
  EpsonBold     = #27'E';
  EpsonNoBold   = #27'F';
  EpsonULine    = #27'-'#1;
  EpsonNoULine  = #27'-'#0;

  EpsonCodeArray: array[0..7] of PChar = (
    EpsonBold,
    EpsonNoBold,
    EpsonItalic,
    EpsonNoItalic,
    EpsonULine,
    EpsonNoULine,
    EpsonBold + EpsonItalic,
    EpsonNoBold + EpsonNoItalic);

  EpsonCodes: TPrinterCodes = (
    PreambleCount: 0;
    Preamble: nil;
    CodeArray: @EpsonCodeArray;
    Attributes: (
      0,        { Whitespace }
      2,        { Comment }
      1,        { Reserved word }
      0,        { Identifier }
      0,        { Symbol }
      4,        { String }
      0,        { Number }
      1);       { Assembler }
    StartPage: '';
    EndPage: #12;
    EndLine: #13#10;
    Postamble: ''
  );

  HPInit      = #27'E'#27'(10U'#27'&k0S'#27'(s3T';
  HPItalic    = #27'(s1S';
  HPNoItalic  = #27'(s0S';
  HPBold      = #27'(s3B';
  HPNoBold    = #27'(s0B';
  HPULine     = #27'&dD';
  HPNoULine   = #27'&d@';

  HPCodeArray: array[0..7] of PChar = (
    HPBold,
    HPNoBold,
    HPItalic,
    HPNoItalic,
    HPULine,
    HPNoULine,
    HPBold + HPItalic,
    HPNoBold + HPNoItalic);

  LaserJetPreamble: PChar = HPInit;
  LaserJetCodes: TPrinterCodes = (
    PreambleCount: 1;
    Preamble: @LaserJetPreamble;
    CodeArray: @HPCodeArray;
    Attributes: (
      0,        { Whitespace }
      2,        { Comment }
      1,        { Reserved word }
      0,        { Identifier }
      0,        { Symbol }
      4,        { String }
      0,        { Number }
      1);       { Assembler }
    StartPage: '';
    EndPage: #12;
    EndLine: #13#10;
    Postamble: #12
  );

  AsciiCodes: TPrinterCodes = (
    PreambleCount: 0;
    Preamble: nil;
    CodeArray: nil;
    Attributes: (
      0,        { Whitespace }
      0,        { Comment }
      0,        { Reserved word }
      0,        { Identifier }
      0,        { Symbol }
      0,        { String }
      0,        { Number }
      0);       { Assembler }
    StartPage: '';
    EndPage: #12;
    EndLine: #13#10;
    Postamble: ''
  );

  PSPreamble0  = #4'%!PS-Adobe-3.0'#13#10+
                'initgraphics'#13#10;
  PSPreamble1  = '/fnr /Courier findfont 10 scalefont def'#13#10;
  PSPreamble2  = '/fni /Courier-Oblique findfont 10 scalefont def'#13#10;
  PSPreamble3  = '/fnb /Courier-Bold findfont 10 scalefont def'#13#10;
  PSPreamble4  = '/fnbi /Courier-BoldOblique findfont 10 scalefont def'#13#10;
  PSPreamble5  = '/newl {20 currentpoint exch pop 12 sub moveto} def'#13#10+
                 '/newp {20 765 moveto} def'#13#10+
                 'fnr setfont'#13#10;
  PSNormal     = 'fnr setfont'#13#10;
  PSItalic     = 'fni setfont'#13#10;
  PSBold       = 'fnb setfont'#13#10;
  PSBoldItalic = 'fnbi setfont'#13#10;

  PSCodeArray: array[0..5] of PChar = (
    PSBold,
    PSNormal,
    PSItalic,
    PSNormal,
    PSBoldItalic,
    PSNormal);

  PSPreamble: array[0..5] of PChar = (
    PSPreamble0,
    PSPreamble1,
    PSPreamble2,
    PSPreamble3,
    PSPreamble4,
    PSPreamble5);
  PSCodes: TPrinterCodes = (
    PreambleCount: High(PSPreamble) - Low(PSPreamble) + 1;
    Preamble: @PSPreamble;
    CodeArray: @PSCodeArray;
    Attributes: (
      0,        { Whitespace }
      2,        { Comment }
      1,        { Reserved word }
      0,        { Identifier }
      0,        { Symbol }
      3,        { String }
      0,        { Number }
      1);       { Assembler }
    StartPage: 'newp'#13#10;
    EndPage: 'showpage'#13#10;
    EndLine: 'newl'#13#10;
    Postamble: #4
  );

  pmNormal     = $0001;
  pmPostScript = $0002;

  PrintMode: Word = pmNormal;
  LinesPerPage: Word = 59;
  ToFile: Boolean = False;
  TabSize: Word = 8;

var
  C, LineCount, TabCount: Integer;
  Line, OutputLine: String;
  InputBuffer: array[0..4095] of Char;
  PrinterCodes: PPrinterCodes;
  CurCode, NewCode: Byte;
  AKey: Word;
  Lst: Text;

procedure UpStr(var S: String);
var
  I: Integer;
begin
  for I := 1 to Length(S) do S[I] := UpCase(S[I]);
end;

procedure SetDeviceRaw(var T: Text); assembler;
asm
	LES	DI,T
	MOV	BX,WORD PTR ES:[DI]
	MOV	AX,4400H
	INT	21H
	TEST	DX,0080H
	JZ	@@1
	OR	DL,20H
	MOV	DH,DH
	MOV	AX,4401H
	INT	21H
@@1:		
end;

procedure ProcessCommandLine;
var
  Param: String;
  I: Integer;

  function ParamVal(var P: String; Default: Word): Word;
  var
    N, E: Integer;
  begin
    Delete(P, 1, 1);
    Val(P, N, E);
    if E = 0 then
      ParamVal := N
    else
      ParamVal := Default;
  end;

begin
  PrinterCodes := @AsciiCodes;
  for I := 1 to ParamCount do
  begin
    Param := ParamStr(I);
    if (Length(Param) >= 2) and ((Param[1] = '/') or (Param[1] = '-')) then
    begin
      Delete(Param, 1, 1);
      UpStr(Param);
      if Param = 'EPSON' then
        PrinterCodes := @EpsonCodes
      else if Param = 'HP' then
        PrinterCodes := @LaserJetCodes
      else if Param = 'ASCII' then
        PrinterCodes := @AsciiCodes
      else if Param = 'PS' then
      begin
        PrinterCodes := @PSCodes;
        PrintMode := pmPostScript;
      end
      else if Param[1] = 'L' then
        LinesPerPage := ParamVal(Param, LinesPerPage)
      else if Param[1] = 'T' then
        TabSize := ParamVal(Param, TabSize)
      else if Param[1] = 'O' then
      begin
        Delete(Param, 1, 1);
        Assign(Lst, Param);
        Rewrite(Lst);
        ToFile := True;
        SetDeviceRaw(Lst);
      end;
    end;
  end;
  if not ToFile then
  begin
    Assign(Lst, 'LPT1');
    Rewrite(Lst);
    SetDeviceRaw(Lst);
  end;
end;

procedure PurgeOutputBuf;
begin
  if OutputLine = '' then Exit;
  case PrintMode of
    pmNormal: Write(Lst, OutputLine);
    pmPostScript:
    begin
      Write(Lst, '(');
      Write(Lst, OutputLine);
      Write(Lst, ') show'#13#10);
    end;
  end;
  OutputLine := '';
  if IOResult <> 0 then Halt(1);
end;

procedure AddToOutputBuf(AChar: Char);
var
  I: Integer;
begin
  case AChar of
    '(',')','\':
    begin
      case PrintMode of
        pmPostScript:
        begin
          if Length(OutputLine) > 253 then
            PurgeOutputBuf;
          Inc(OutputLine[0]);
          OutputLine[Length(OutputLine)] := '\';
        end;
      end;
    end;
    #9:
    begin
      if Length(OutputLine) > (255 - TabSize) then
        PurgeOutputBuf;
      for I := 1 to TabSize - (TabCount mod TabSize) do
      begin
        Inc(OutputLine[0]);
        OutputLine[Length(OutputLine)] := ' ';
      end;
      Inc(TabCount, TabSize - (TabCount mod TabSize));
      Exit;
    end;
  end;
  if Length(OutputLine) > 254 then
    PurgeOutputBuf;
  Inc(OutputLine[0]);
  OutputLine[Length(OutputLine)] := AChar;
  Inc(TabCount);
end;

procedure NewPage(const PCodes: TPrinterCodes);
begin
  PurgeOutputBuf;
  Write(Lst, PCodes.EndPage);
  Write(Lst, PCodes.StartPage);
  LineCount := 0;
  TabCount := 0;
end;

procedure NewLine(const PCodes: TPrinterCodes);
begin
  PurgeOutputBuf;
  Write(Lst, PCodes.EndLine);
  Inc(LineCount);
  TabCount := 0;
  if LineCount > LinesPerPage then
    NewPage(PCodes);
end;

function GetKey(var Key: Word): Boolean; assembler;
asm
	MOV	AH,1
	INT	16H
	MOV	AL,0
	JE	@@1
	XOR	AH,AH
	INT	16H
	LES	DI,Key
	MOV	WORD PTR ES:[DI],AX
	MOV	AL,1
@@1:
end;

begin
  SetTextBuf(Input, InputBuffer);
  ProcessCommandLine;
  LineCount := 0;
  with PrinterCodes^ do
  begin
    if PreambleCount > 0 then
      for C := 0 to PreambleCount - 1 do
        Write(Lst, Preamble^[C]);
    if IOResult <> 0 then Halt(1);
    LineCount := 0;
    CurCode := $FF;
    TabCount := 0;
    Write(Lst, StartPage);
    Line := '';
    while True do
    begin
      if (Line = '') and Eof then
      begin
        PurgeOutputBuf;
        Break;
      end;
      ReadLn(Line);
      if GetKey(AKey) and (AKey = $011B) then
        Halt(1);
      C := 1;
      while C <= length(Line) do
      begin
        case Line[C] of
          #27:
            if (Line[C + 1] >= '1') and (Line[C + 1] <= '8') then
            begin
              NewCode := Attributes[Byte(Line[C + 1]) - $31];
              if NewCode <> CurCode then
              begin
                PurgeOutputBuf;
                if (CurCode > 0) and (CurCode < MaxAttributes) then
                  Write(Lst, CodeArray^[(CurCode - 1) * 2 + 1]);
                if (NewCode > 0) and (NewCOde < MaxAttributes) then
                  Write(Lst, CodeArray^[(NewCode - 1) * 2]);
                CurCode := NewCode;
              end;
              Inc(C);
            end;
          #12: NewPage(PrinterCodes^);
        else
          AddToOutputBuf(Line[C]);
        end;
        Inc(C);
      end;
      NewLine(PrinterCodes^);
    end;
    if LineCount > 0 then
      Write(Lst, EndPage);
    Write(Lst, Postamble);
  end;
  Close(Lst);
end.
