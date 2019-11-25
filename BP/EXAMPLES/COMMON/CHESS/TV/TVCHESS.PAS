program ChessDemo;

uses App, Views, Dialogs, Menus, Objects, Drivers, ChessCmd, 
  Board, ChessApp;

var
  ChessDLLDemo: TChessApp;

begin
  ChessDLLDemo.Init;
  ChessDLLDemo.Run;
  ChessDLLDemo.Done;
end.
