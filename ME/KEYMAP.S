macro KEYMAP DUMP {
// This macro was created by the Multi-Edit install macro version 6.00aP

// Default key assignments
MACRO_TO_KEY(<F1>,'USERIN^MAINHELP ',EDIT);
FLABEL('Help',1,EDIT);
Set_Global_Str('!HM_KEY1', '<F1>');
MACRO_TO_KEY(<F2>,'MEMENUS ',EDIT);
FLABEL('Menu',2,EDIT);
Set_Global_Str('!MM_KEY', '<F2>');
MACRO_TO_KEY(<ESC>,'MEMENUS ',EDIT);
MACRO_TO_KEY(<AltH>,'MEMENUS /K=H',EDIT);
Set_Global_Str('!HELP_MKEY', '<AltH>');
MACRO_TO_KEY(<AltF>,'MEMENUS /K=F',EDIT);
Set_Global_Str('!FILE_MKEY', '<AltF>');
MACRO_TO_KEY(<AltE>,'MEMENUS /K=E',EDIT);
Set_Global_Str('!EDIT_MKEY', '<AltE>');
MACRO_TO_KEY(<AltW>,'MEMENUS /K=W',EDIT);
Set_Global_Str('!WIN_MKEY', '<AltW>');
MACRO_TO_KEY(<AltB>,'MEMENUS /K=B',EDIT);
Set_Global_Str('!BLOCK_MKEY', '<AltB>');
MACRO_TO_KEY(<AltS>,'MEMENUS /K=S',EDIT);
Set_Global_Str('!SEARCH_MKEY', '<AltS>');
MACRO_TO_KEY(<AltT>,'MEMENUS /K=T',EDIT);
Set_Global_Str('!TEXT_MKEY', '<AltT>');
MACRO_TO_KEY(<AltM>,'MEMENUS /K=M',EDIT);
Set_Global_Str('!MACRO_MKEY', '<AltM>');
MACRO_TO_KEY(<AltU>,'MEMENUS /K=U',EDIT);
Set_Global_Str('!USER_MKEY', '<AltU>');
MACRO_TO_KEY(<AltO>,'MEMENUS /K=O',EDIT);
Set_Global_Str('!OTHER_MKEY', '<AltO>');
MACRO_TO_KEY(<MEVENT>,'MOUSE^MOUEVENT ',EDIT);
MACRO_TO_KEY(<MEVENT2>,'MOUSE^MOUSEEVENT2 ',EDIT);
MACRO_TO_KEY(<ShftMEVENT>,'MOUSE^CUA_Shft_Button ',EDIT);
MACRO_TO_KEY(<CtrlMEVENT>,'MOUSE_BLOCK_OP /BT=0',EDIT);
MACRO_TO_KEY(<AltMEVENT>,'MOUSE^MOUSE_BLOCK_OP /BT=1',EDIT);
MACRO_TO_KEY(<F3>,'MEUTIL1^SAVEFILE /NP=1',EDIT);
FLABEL('Save',3,EDIT);
Set_Global_Str('!FM_KEY3', '<F3>');
MACRO_TO_KEY(<CtrlF3>,'MEUTIL1^SAVEFILE ',EDIT);
FLABEL('SaveAs',23,EDIT);
Set_Global_Str('!FM_KEY4', '<CtrlF3>');
MACRO_TO_KEY(<AltF3>,'MEUTIL1^SAVEBLCK ',EDIT);
FLABEL('SaveBl',33,EDIT);
Set_Global_Str('!BM_KEY5', '<AltF3>');
MACRO_TO_KEY(<CtrlF4>,'MEUTIL1^LOADFILE /E=1',EDIT);
FLABEL('EditFl',24,EDIT);
Set_Global_Str('!FM_KEY1', '<CtrlF4>');
MACRO_TO_KEY(<ShftF3>,'MEUTIL3^Print ',EDIT);
FLABEL('Print ',13,EDIT);
Set_Global_Str('!FM_KEY9', '<ShftF3>');
MACRO_TO_KEY(<F6>,'MEUTIL2^SEARCH ',EDIT);
FLABEL('Search',6,EDIT);
Set_Global_Str('!SRM_KEY1', '<F6>');
MACRO_TO_KEY(<ShftF6>,'MEUTIL2^S_REPL ',EDIT);
FLABEL('S/Repl',16,EDIT);
Set_Global_Str('!SRM_KEY2', '<ShftF6>');
MACRO_TO_KEY(<CtrlF6>,'MEUTIL2^REPSRCH ',EDIT);
FLABEL('NxtSrc',26,EDIT);
Set_Global_Str('!SRM_KEY3', '<CtrlF6>');
MACRO_TO_KEY(<CtrlM>,'MEUTIL2^FS ',EDIT);
Set_Global_Str('!SRM_KEY5', '<CtrlM>');
MACRO_TO_KEY(<CtrlL>,'MEUTIL2^FS /N',EDIT);
Set_Global_Str('!SRM_KEY6', '<CtrlL>');
MACRO_TO_KEY(<F7>,'MEUTIL2^MARKBLCK ',EDIT);
FLABEL('Block',7,EDIT);
Set_Global_Str('!BM_KEY15', '<F7>');
MACRO_TO_KEY(<ShftF7>,'MEUTIL2^MCOLBLCK ',EDIT);
FLABEL('ColBl',17,EDIT);
Set_Global_Str('!BM_KEY16', '<ShftF7>');
MACRO_TO_KEY(<AltF7>,'MEUTIL2^MSTRBLCK ',EDIT);
FLABEL('StrBl',37,EDIT);
Set_Global_Str('!BM_KEY17', '<AltF7>');
MACRO_TO_KEY(<CtrlF9>,'MEUTIL2^BLOCKOFF ',EDIT);
FLABEL('BlOff',29,EDIT);
Set_Global_Str('!BM_KEY18', '<CtrlF9>');
MACRO_TO_KEY(<F9>,'MEUTIL2^BLOCKOP /BT=0',EDIT);
FLABEL('CopyBl',9,EDIT);
Set_Global_Str('!BM_KEY1', '<F9>');
MACRO_TO_KEY(<F10>,'MEUTIL2^BLOCKOP /BT=1',EDIT);
FLABEL('MoveBl',10,EDIT);
Set_Global_Str('!BM_KEY2', '<F10>');
MACRO_TO_KEY(<CtrlF10>,'MEUTIL2^BLOCKOP /BT=2',EDIT);
FLABEL('DelBl',30,EDIT);
Set_Global_Str('!BM_KEY3', '<CtrlF10>');
MACRO_TO_KEY(<ShftF9>,'MEUTIL2^BLOCKOP /BT=3',EDIT);
FLABEL('WnCopy',19,EDIT);
Set_Global_Str('!BM_KEY10', '<ShftF9>');
MACRO_TO_KEY(<ShftF10>,'MEUTIL2^BLOCKOP /BT=4',EDIT);
FLABEL('WnMove',20,EDIT);
Set_Global_Str('!BM_KEY11', '<ShftF10>');
MACRO_TO_KEY(<GREY+>,'MEUTIL2^CUT ',EDIT);
Set_Global_Str('!CPM_KEY1', '<GREY+>');
MACRO_TO_KEY(<GREY->,'MEUTIL2^CUT /M',EDIT);
Set_Global_Str('!CPM_KEY2', '<GREY->');
MACRO_TO_KEY(<CtrlGREY+>,'MEUTIL2^CUT /A',EDIT);
Set_Global_Str('!CPM_KEY3', '<CtrlGREY+>');
MACRO_TO_KEY(<CtrlGREY->,'MEUTIL2^CUT /M /A',EDIT);
Set_Global_Str('!CPM_KEY4', '<CtrlGREY->');
MACRO_TO_KEY(<GreyENTER>,'MEUTIL2^PASTE ',EDIT);
Set_Global_Str('!CPM_KEY5', '<GreyENTER>');
MACRO_TO_KEY(<ShftF1>,'WINDOW^NEXTWIN ',EDIT);
FLABEL('NxtWin',11,EDIT);
Set_Global_Str('!WM_KEY6', '<ShftF1>');
MACRO_TO_KEY(<CtrlF1>,'WINDOW^LASTWIN ',EDIT);
FLABEL('PreWin',21,EDIT);
Set_Global_Str('!WM_KEY7', '<CtrlF1>');
MACRO_TO_KEY(<AltF1>,'WINDOW^WINOP /T=3',EDIT);
FLABEL('LstWin',31,EDIT);
Set_Global_Str('!WM_KEY4', '<AltF1>');
MACRO_TO_KEY(<F12>,'WINDOW^ADJACENT_WIN ',EDIT);
FLABEL('AdjWin',42,EDIT);
Set_Global_Str('!WM_KEY8', '<F12>');
MACRO_TO_KEY(<ScrollLockOn>,'WINDOW^WINOP /T=5',EDIT);
Set_Global_Str('!WM_KEY11', '<ScrollLockOn>');
MACRO_TO_KEY(<AltF4>,'WINDOW^WINOP /T=1',EDIT);
FLABEL('ClosWn',34,EDIT);
Set_Global_Str('!WM_KEY2', '<AltF4>');
MACRO_TO_KEY(<ShftF11>,'WINDOW^WINOP /T=8',EDIT);
FLABEL('Zoom',43,EDIT);
Set_Global_Str('!WM_KEY12', '<ShftF11>');
MACRO_TO_KEY(<F11>,'WINDOW^WINOP /T=4',EDIT);
FLABEL('Split',41,EDIT);
Set_Global_Str('!WM_KEY3', '<F11>');
MACRO_TO_KEY(<AltD>,'DELEOL ',EDIT);
Set_Global_Str('!DELEOL_KEY', '<AltD>');
MACRO_TO_KEY(<DEL>,'DEL ',EDIT);
MACRO_TO_KEY(<CtrlDEL>,'DELWORD ',EDIT);
Set_Global_Str('!DELW_KEY', '<CtrlDEL>');
CMD_TO_KEY(<BS>,BACK_SPACE,EDIT);
MACRO_TO_KEY(<CtrlBS>,'BSWORD ',EDIT);
Set_Global_Str('!DELWB_KEY', '<CtrlBS>');
CMD_TO_KEY(<ShftF8>,DEL_LINE,EDIT);
FLABEL('DelLin',18,EDIT);
Set_Global_Str('!DELLN_KEY', '<ShftF8>');
CMD_TO_KEY(<CtrlY>,DEL_LINE,EDIT);
CMD_TO_KEY(<CtrlENTER>,UNDO,EDIT);
Set_Global_Str('!TXM_KEY1', '<CtrlENTER>');
CMD_TO_KEY(<CtrlF7>,UNDO,EDIT);
FLABEL('UNDO',27,EDIT);
CMD_TO_KEY(<AltENTER>,REDO,EDIT);
Set_Global_Str('!TXM_KEY2', '<AltENTER>');
CMD_TO_KEY(<LF>,LEFT,EDIT);
CMD_TO_KEY(<RT>,RIGHT,EDIT);
CMD_TO_KEY(<UP>,UP,EDIT);
CMD_TO_KEY(<DN>,DOWN,EDIT);
MACRO_TO_KEY(<HOME>,'HOME /T=500',EDIT);
MACRO_TO_KEY(<END>,'END /T=500',EDIT);
CMD_TO_KEY(<PgUp>,PAGE_UP,EDIT);
CMD_TO_KEY(<PgDn>,PAGE_DOWN,EDIT);
CMD_TO_KEY(<CtrlHome>,TOF,EDIT);
Set_Global_Str('!TOF_KEY', '<CtrlHome>');
CMD_TO_KEY(<CtrlEnd>,EOF,EDIT);
Set_Global_Str('!EOF_KEY', '<CtrlEnd>');
CMD_TO_KEY(<CtrlPgDn>,NEXT_PAGE_BREAK,EDIT);
Set_Global_Str('!NEXT_PB_KEY', '<CtrlPgDn>');
CMD_TO_KEY(<CtrlPgUp>,LAST_PAGE_BREAK,EDIT);
Set_Global_Str('!LAST_PB_KEY', '<CtrlPgUp>');
CMD_TO_KEY(<CtrlLF>,WORD_LEFT,EDIT);
CMD_TO_KEY(<CtrlRT>,WORD_RIGHT,EDIT);
MACRO_TO_KEY(<CtrlW>,'SCROLLUP ',EDIT);
Set_Global_Str('!SUP_KEY', '<CtrlW>');
MACRO_TO_KEY(<CtrlX>,'SCROLLDN ',EDIT);
Set_Global_Str('!SDN_KEY', '<CtrlX>');
MACRO_TO_KEY(<CtrlT>,'TOPBLOCK ',EDIT);
Set_Global_Str('!TOB_KEY', '<CtrlT>');
MACRO_TO_KEY(<CtrlB>,'ENDBLOCK ',EDIT);
Set_Global_Str('!EOB_KEY', '<CtrlB>');
MACRO_TO_KEY(<AltF6>,'GOTOLINE ',EDIT);
FLABEL('GotoLn',36,EDIT);
Set_Global_Str('!CRSM_KEY7', '<AltF6>');
MACRO_TO_KEY(<TAB>,'TAB /M=0',EDIT);
MACRO_TO_KEY(<ShftTAB>,'TAB /M=1',EDIT);
MACRO_TO_KEY(<F5>,'TEXT^MARKPOS ',EDIT);
FLABEL('Mark',5,EDIT);
Set_Global_Str('!CRSM_KEY1', '<F5>');
MACRO_TO_KEY(<ShftF5>,'TEXT^GOTOMARK ',EDIT);
FLABEL('GotoMk',15,EDIT);
Set_Global_Str('!CRSM_KEY2', '<ShftF5>');
MACRO_TO_KEY(<CtrlF5>,'TEXT^SET_MARK ',EDIT);
FLABEL('SetRn',25,EDIT);
Set_Global_Str('!CRSM_KEY4', '<CtrlF5>');
MACRO_TO_KEY(<AltF5>,'TEXT^GET_MARK ',EDIT);
FLABEL('GetRn',35,EDIT);
Set_Global_Str('!CRSM_KEY5', '<AltF5>');
MACRO_TO_KEY(<ShftLF>,'SHIFT_CURSOR ',EDIT);
MACRO_TO_KEY(<ShftUP>,'SHIFT_CURSOR ',EDIT);
MACRO_TO_KEY(<ShftRT>,'SHIFT_CURSOR ',EDIT);
MACRO_TO_KEY(<ShftDN>,'SHIFT_CURSOR ',EDIT);
MACRO_TO_KEY(<CtrlR>,'TEXT^REFORMAT ',EDIT);
Set_Global_Str('!TXM_KEY11', '<CtrlR>');
MACRO_TO_KEY(<CtrlC>,'TEXT^CENTER ',EDIT);
Set_Global_Str('!TXM_KEY7', '<CtrlC>');
MACRO_TO_KEY(<CtrlUP>,'MENU /MN=UPPER_CASE',EDIT);
Set_Global_Str('!TXM_KEY5', '<CtrlUP>');
MACRO_TO_KEY(<CtrlDN>,'MENU /MN=LOWER_CASE',EDIT);
Set_Global_Str('!TXM_KEY6', '<CtrlDN>');
MACRO_TO_KEY(<CtrlD>,'DATETIME ',EDIT);
Set_Global_Str('!TXM_KEY8', '<CtrlD>');
MACRO_TO_KEY(<CtrlP>,'PAGEBRK ',EDIT);
Set_Global_Str('!INS_PB_KEY', '<CtrlP>');
MACRO_TO_KEY(<ENTER>,'CR ',EDIT);
MACRO_TO_KEY(<INS>,'INSTGL ',EDIT);
MACRO_TO_KEY(<F8>,'MEUTIL1^RUNMAC ',EDIT);
FLABEL('RunMac',8,EDIT);
Set_Global_Str('!MCM_KEY1', '<F8>');
CMD_TO_KEY(<AltF10>,KEY_RECORD,EDIT);
FLABEL('Record',40,EDIT);
Set_Global_Str('!RECORD_KEY', '<AltF10>');
CMD_TO_KEY(<AltF10>,KEY_RECORD,DOS_SHELL);
FLABEL('Record',40,DOS_SHELL);
MACRO_TO_KEY(<AltF2>,'SUPPORT^ASCII ',EDIT);
FLABEL('ASCII',32,EDIT);
Set_Global_Str('!MIM_KEY10', '<AltF2>');
MACRO_TO_KEY(<F4>,'DIRSHELL^DIRSHELL ',EDIT);
FLABEL('DIR',4,EDIT);
Set_Global_Str('!FM_KEY10', '<F4>');
MACRO_TO_KEY(<ShftF4>,'MEUTIL1^SHELLDOS ',EDIT);
FLABEL('DOS',14,EDIT);
Set_Global_Str('!MIM_KEY12', '<ShftF4>');
MACRO_TO_KEY(<CtrlF8>,'LANGUAGE^COMPILE ',EDIT);
FLABEL('Compil',28,EDIT);
Set_Global_Str('!MIM_KEY4', '<CtrlF8>');
MACRO_TO_KEY(<AltF8>,'LANGUAGE^CMPERROR ',EDIT);
FLABEL('NxtErr',38,EDIT);
Set_Global_Str('!MIM_KEY5', '<AltF8>');
MACRO_TO_KEY(<AltLF>,'LANGUAGE^MATCH ',EDIT);
Set_Global_Str('!MIM_KEY7', '<AltLF>');
MACRO_TO_KEY(<AltRT>,'LANGUAGE^MATCH ',EDIT);
MACRO_TO_KEY(<CtrlF2>,'CALC ',EDIT);
FLABEL('Calc',22,EDIT);
Set_Global_Str('!MIM_KEY9', '<CtrlF2>');
MACRO_TO_KEY(<ShftF2>,'SUPPORT^LINEDRAW ',EDIT);
FLABEL('LnDraw',12,EDIT);
Set_Global_Str('!MIM_KEY13', '<ShftF2>');
MACRO_TO_KEY(<AltX>,'EXIT^EXIT ',EDIT);
Set_Global_Str('!FM_KEY11', '<AltX>');
MACRO_TO_KEY(<AltQ>,'EXIT /NP=1',EDIT);
MACRO_TO_KEY(<CtrlK>,'SETUP^KEYCODE ',EDIT);
MACRO_TO_KEY(<AltF9>,'MEUTIL1^REPEAT ',EDIT);
FLABEL('Repeat',39,EDIT);
Set_Global_Str('!TXM_KEY15', '<AltF9>');
MACRO_TO_KEY(<CtrlS>,'SPELL^SPELL ',EDIT);
Set_Global_Str('!MIM_KEY16', '<CtrlS>');
MACRO_TO_KEY(<CtrlN>,'NOTEBOOK ',ALL);
Set_Global_Str('!NOTE_KEY', '<CtrlN>');
MACRO_TO_KEY(<CtrlA>,'USERIN^DB /F=PHONE.DB/SRP=1',ALL);
Set_Global_Str('!PHONE_KEY', '<CtrlA>');
MACRO_TO_KEY(<F1>,'MECOM^COM_HELP ',TERM);
Set_Global_Str('!COM_HELP', '<F1>');
MACRO_TO_KEY(<ESC>,'MECOM^COM_ASCII_DOWN /QUIT=1',TERM);
Set_Global_Str('!COM_ASCII_QUIT', '<ESC>');
MACRO_TO_KEY(<F2>,'MECOM^COM_MAIN_MENU ',TERM);
Set_Global_Str('!COM_MENU', '<F2>');
MACRO_TO_KEY(<AltF>,'MECOM^COM_MAIN_MENU /K=F',TERM);
Set_Global_Str('!COM_FILE_MENU', '<AltF>');
MACRO_TO_KEY(<PGDN>,'MECOM^COM_FILE /TP=1',TERM);
Set_Global_Str('!COM_FM_KEY1', '<PGDN>');
MACRO_TO_KEY(<PGUP>,'MECOM^COM_FILE /TP=2',TERM);
Set_Global_Str('!COM_FM_KEY2', '<PGUP>');
MACRO_TO_KEY(<AltF1>,'MECOM^COM_FILE /TP=3',TERM);
Set_Global_Str('!COM_FM_KEY4', '<AltF1>');
MACRO_TO_KEY(<AltX>,'MECOM^COM_QUIT /X=30/Y=10',TERM);
Set_Global_Str('!COM_FM_KEY10', '<AltX>');
MACRO_TO_KEY(<AltP>,'MECOM^COM_MAIN_MENU /K=P',TERM);
Set_Global_Str('!COM_PHONE_MENU', '<AltP>');
MACRO_TO_KEY(<AltD>,'MECOM^COM_PHONE /TP=1',TERM);
Set_Global_Str('!COM_PM_KEY1', '<AltD>');
MACRO_TO_KEY(<AltM>,'MECOM^COM_PHONE /TP=2',TERM);
Set_Global_Str('!COM_PM_KEY2', '<AltM>');
MACRO_TO_KEY(<AltR>,'MECOM^COM_PHONE /TP=4',TERM);
Set_Global_Str('!COM_PM_KEY3', '<AltR>');
MACRO_TO_KEY(<CtrlH>,'MECOM^COM_PHONE /TP=3',TERM);
Set_Global_Str('!COM_PM_KEY5', '<CtrlH>');
MACRO_TO_KEY(<AltB>,'MECOM^COM_SEND_BREAK ',TERM);
Set_Global_Str('!COM_PM_KEY6', '<AltB>');
MACRO_TO_KEY(<AltS>,'MECOM^COM_MAIN_MENU /K=S',TERM);
Set_Global_Str('!COM_SETUP_MENU', '<AltS>');
MACRO_TO_KEY(<AltU>,'MECOM^COM_MAIN_MENU /K=U',TERM);
Set_Global_Str('!COM_USER_MENU', '<AltU>');
MACRO_TO_KEY(<AltC>,'MECOM^COM_SCREEN_OP /TP=3',TERM);
Set_Global_Str('!COM_CLEAR_SCREEN', '<AltC>');
MACRO_TO_KEY(<AltG>,'MECOM^COM_SCREEN_DUMP ',TERM);
Set_Global_Str('!COM_SCREEN_DUMP', '<AltG>');
MACRO_TO_KEY(<AltH>,'MECOM^COM_MAIN_MENU /K=H',TERM);
Set_Global_Str('!COM_HELP_MENU', '<AltH>');

}
