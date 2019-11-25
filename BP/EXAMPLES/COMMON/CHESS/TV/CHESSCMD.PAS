unit ChessCmd;

interface

uses App, Dialogs;

type
  TSettings = record
    TimeMode: Word;    { Game timing mode }
    GameTime: Longint; { Max Game time }
    TurnTime: Longint; { Max Turn time }
    Hints:    Word;    { Hint Options }
    Players:  Word     { Number of players }
  end;

const
  { Move event }
  evMove         = $0400;

  { Game Menu }
  cmRunDemo      = 100;
  cmStop         = 101;

  { Edit menu }
  cmRedo         = 110;
  cmComputerMove = 111;
  cmEnterMove    = 112;
  cmShowHint     = 113;

  { Options Menu }
  cmSettings     = 120;
  cmColors       = 121;

  { Game control }
  cmSubmitMove   = 1000;
  cmMovePiece    = 1001;
  cmUndoMove     = 1002;
  cmClearBoard   = 1003;
  cmFindPiece    = 1004;
  cmGameOver     = 1005;
  cmRegisterSave = 1006;
  cmTimeOptChg   = 1007;

  { Color palettes }
  CChessAppColor      = CAppColor +
    #$1E#$20#$40#$07#$70#$78#$18#$1E;
  CChessAppBlackWhite = CAppBlackWhite +
    #$07#$70#$07#$07#$70#$07#$07#$70;
  CChessAppMonochrome = CAppMonochrome +
    #$07#$70#$07#$07#$70#$07#$07#$70;

  CChessBoard = #128#129#130#131#132;

  CSettingsDlg = CGrayDialog + #133#134;
  CStatusDialog = CGrayDialog + #135;

  CTimeLabel = #33#33#33#33;
  CTimeInput = #34#34#34#34;

  CBestLine = #33;

  gmOnePlay  = $0000;
  gmTwoPlay  = $0001;
  gmDemo     = $0002;

  tmGameLimit  = $0000;
  tmTurnLimit  = $0001;
  tmMatchUser  = $0002;
  tmInfinite   = $0003;

  hoAttacks    = $0001;
  hoJeopardies = $0002;
  hoBestLine   = $0004;

  plOnePlayer  = $0000;
  plTwoPlayer  = $0001;

  { Stream registration types }

  otChessPiece  = 5001;
  otTimeLabel   = 5002;
  otTimeInput   = 5003;
  otSettingsDlg = 5004;

  Settings: TSettings = (
    TimeMode: tmGameLimit;
    GameTime: 10;
    TurnTime: 30;
    Hints: hoAttacks + hoJeopardies + hoBestLine;
    Players: plOnePlayer);

implementation

end.
