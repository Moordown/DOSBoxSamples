unit Regexp;

interface

type
  HRegexp = Word;

  TRegMatch = record
    Start: Word;        { Start of match }
    Stop:  Word;        { End of match }
  end;

function RegComp(Pattern: PChar; var Error: Integer): HRegexp;
function RegExec(Regex: HRegexp; Str: PChar; var Match: TRegMatch): Integer;
function RegError(Regex: HRegexp; Error: Integer;
  ErrorBuf: array of Char): Integer;
procedure RegFree(Regex: HRegexp);

implementation

procedure RegFree;              external 'REGEXP' index 2;
function RegError;              external 'REGEXP' index 3;
function RegExec;               external 'REGEXP' index 4;
function RegComp;               external 'REGEXP' index 5;

end.
