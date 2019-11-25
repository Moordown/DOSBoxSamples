* * * * * * * * * * * * * * * * * * * * * * * * * *
* WELCOME is the procedure that provides the actions for
* the Welcome to FoxPro topic.
*
clear typeahead
set escape on
on key label escape do escout
on escape do escout
activate screen
clear

** display intro sceen in large font
set blink off  && for proper colors
do bigchars with 6,14,"Welcome|   to| FoxPro"
do apause
for cnt = 1 to 21
	release window ("letter"+alltrim(str(cnt)))
endfor
set blink on
SET SYSMENU TO 

SET SYSMENU AUTOMATIC

DEFINE PAD _pw30kdvp0 OF _MSYSMENU PROMPT "\<System" COLOR SCHEME 3 ;
	KEY ALT+S, ""
DEFINE PAD _pw30kdvvd OF _MSYSMENU PROMPT "\<File" COLOR SCHEME 3 ;
	KEY ALT+F, ""
DEFINE PAD _pw30kdvwb OF _MSYSMENU PROMPT "\<Edit" COLOR SCHEME 3 ;
	KEY ALT+E, ""
DEFINE PAD _pw30kdvy4 OF _MSYSMENU PROMPT "\<Database" COLOR SCHEME 3 ;
	KEY ALT+D, ""
DEFINE PAD _pw30kdvz5 OF _MSYSMENU PROMPT "\<Record" COLOR SCHEME 3 ;
	KEY ALT+R, ""
DEFINE PAD _pw30kdw02 OF _MSYSMENU PROMPT "\<Program" COLOR SCHEME 3 ;
	KEY ALT+P, ""
DEFINE PAD _pw30kdw1p OF _MSYSMENU PROMPT "\<Window" COLOR SCHEME 3 ;
	KEY ALT+W, ""

DEFINE WINDOW welcome1 from 14,5 to 21,75 DOUBLE COLOR SCHEME 12 TITLE " Welcome to FoxPro 2.5 " SHADOW
ACTIVATE WINDOW welcome1
@ 1,1 say "               Welcome to the Quick Tour of FoxPro!"                    
@ 3,1 say "During this tour you will see many of FoxPro's tools for managing"
@ 4,1 say "your data.  The tools help you easily create and manipulate your"
@ 5,1 say "data, and quickly extract useful information."
do apause
release window welcome1

DEFINE WINDOW welcome2 from 17,5 to 21,75 DOUBLE COLOR SCHEME 12 TITLE " Welcome to FoxPro 2.5 " SHADOW
ACTIVATE WINDOW welcome2

@ 0,1 say "   You can communicate with FoxPro using a mouse or the keyboard,"
@ 1,1 say "   whichever you prefer.  You tell FoxPro what to do by selecting"
@ 2,1 say "   items from the menu system."
do apause
define window menusys from 20,25 to 20,35 none noshadow COLOR SCHEME 12
@ 2,19 say "menu system" color w+/r
activate window menusys
@ 0,0 say "menu system"
for cnt = 20 to 17 step -1
	move window menusys to cnt,25
	do inpause with 4
endfor
release window menusys
define window menusys from 16,25 to 16,35 none noshadow
activate window menusys
@ 0,0 say "menu system"  COLOR GR+/B
for cnt = 16 to 2 step -1
	move window menusys to cnt,25
	do inpause with 4
endfor

for cnt = 25 to 46 
	move window menusys to 2,cnt
	do inpause with 4
endfor
release window menusys

define window littlewin from 1,1 to 14,26 none noshadow 
activate window littlewin 
@ 0,0 say "       "  COLOR GR+/B
@ 1,0 say " System Menu Bar"  COLOR GR+/B
for cnt = 46 to 24 step -1
	move window littlewin to 1,cnt
	do inpause with 4
endfor
DEFINE WINDOW syspop ;
	FROM 1, 0 ;
	TO 13,21 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 4

ACTIVATE WINDOW syspop NOSHOW
@ 4,0 TO 4,21 ;
	COLOR N/W     
@ 0,0 TO 12,21 ;
	COLOR N/W     
@ 4,0 SAY "Ã" ;
	COLOR N/W     
@ 4,21 SAY "´" ;
	COLOR N/W     
@ 1,2 SAY "A" ;
	COLOR W+/W    
@ 1,3 SAY "bout FoxPro..." ;
	COLOR N/W     
@ 2,2 SAY "H" ;
	COLOR W+/W    
@ 2,3 SAY "elp..." ;
	COLOR N/W     
@ 3,2 SAY "M" ;
	COLOR W+/W    
@ 3,3 SAY "acros..." ;
	COLOR N/W     
@ 2,18 SAY "F1" ;
	COLOR W+/W    
@ 5,2 SAY "F" ;
	COLOR W+/W    
@ 6,2 SAY "C" ;
	COLOR W+/W    
@ 5,3 SAY "iler" ;
	COLOR N/W     
@ 6,3 SAY "alculator" ;
	COLOR N/W     
@ 7,11 SAY "D" ;
	COLOR W+/W    
@ 7,12 SAY "iary" ;
	COLOR N/W     
@ 7,2 SAY "Calender/" ;
	COLOR N/W     
@ 8,3 SAY "pecial Characters" ;
	COLOR N/W     
@ 8,2 SAY "S" ;
	COLOR W+/W    
@ 9,2 SAY "ASC" ;
	COLOR N/W     
@ 9,5 SAY "I" ;
	COLOR W+/W    
@ 9,6 SAY "I Chart" ;
	COLOR N/W     
@ 10,2 SAY "Ca" ;
	COLOR N/W     
@ 10,4 SAY "p" ;
	COLOR W+/W    
@ 10,5 SAY "ture" ;
	COLOR N/W     
@ 11,2 SAY "Pu" ;
	COLOR N/W     
@ 11,4 SAY "z" ;
	COLOR W+/W    
@ 11,5 SAY "zle" ;
	COLOR N/W     

show WINDOW syspop
activate window littlewin
@ 0,0 say "        "  COLOR GR+/B
@ 1,0 say " System Menu Bar"  COLOR GR+/B
do inpause with 4
@ 1,0 say "                "  COLOR GR+/B
@ 2,0 say " System Menu Bar"  COLOR GR+/B
do inpause with 4
@ 2,0 say "                "  COLOR GR+/B
@ 3,0 say " System Menu Bar"  COLOR GR+/B
do inpause with 4
@ 3,0 say "                "  COLOR GR+/B
@ 4,0 say " System Menu Bar"  COLOR GR+/B
do inpause with 4
@ 4,0 say "                "  COLOR GR+/B
@ 5,0 say " System Menu Bar"  COLOR GR+/B
do inpause with 4
@ 5,0 say "                "  COLOR GR+/B
@ 6,0 say " System Menu Bar"  COLOR GR+/B
do inpause with 4
@ 6,0 say "ÍÍÍ System Menu Popup"  COLOR GR+/B
do inpause with 4
@ 5,0 say "Ä¿"  COLOR GR+/B
@ 6,0 say "  ÆÍ System Menu Popup"  COLOR GR+/B
@ 7,0 say "ÄÙ"  COLOR GR+/B
do inpause with 4
@ 4,0 say "Ä¿"  COLOR GR+/B
@ 5,0 say "  ³"  COLOR GR+/B
@ 7,0 say "  ³"  COLOR GR+/B
@ 8,0 say "ÄÙ"  COLOR GR+/B
do inpause with 4
@ 3,0 say "Ä¿"  COLOR GR+/B
@ 4,0 say "  ³"  COLOR GR+/B
@ 8,0 say "  ³"  COLOR GR+/B
@ 9,0 say "ÄÙ"  COLOR GR+/B
do inpause with 4
@ 2,0 say "Ä¿"  COLOR GR+/B
@ 3,0 say "  ³"  COLOR GR+/B
@ 9,0 say "  ³"  COLOR GR+/B
@ 10,0 say "ÄÙ"  COLOR GR+/B
do inpause with 4
@ 1,0 say "Ä¿"  COLOR GR+/B
@ 2,0 say "  ³"  COLOR GR+/B
@ 10,0 say "  ³"  COLOR GR+/B
@ 11,0 say "ÄÙ"  COLOR GR+/B
do inpause with 4
@ 0,0 say "Ä¿"  COLOR GR+/B
@ 1,0 say "  ³"  COLOR GR+/B
@ 11,0 say "  ³"  COLOR GR+/B
@ 12,0 say "ÄÙ"  COLOR GR+/B
do apause

DEFINE WINDOW filepop ;
	FROM 1, 8 ;
	TO 14,27 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 4

ACTIVATE WINDOW filepop NOSHOW
@ 0,0 TO 13,19 ;
	COLOR N/W     
@ 4,0 TO 4,19 ;
	COLOR N/W     
@ 8,0 TO 8,19 ;
	COLOR N/W     
@ 11,0 TO 11,19 ;
	COLOR N/W     
@ 11,0 SAY "Ã" ;
	COLOR N/W     
@ 11,19 SAY "´" ;
	COLOR N/W     
@ 8,0 SAY "Ã" ;
	COLOR N/W     
@ 8,19 SAY "´" ;
	COLOR N/W     
@ 4,0 SAY "Ã" ;
	COLOR N/W     
@ 4,19 SAY "´" ;
	COLOR N/W     
@ 1,2 SAY "N" ;
	COLOR W+/W    
@ 2,2 SAY "O" ;
	COLOR W+/W    
@ 3,2 SAY "C" ;
	COLOR W+/W    
@ 1,3 SAY "ew..." ;
	COLOR N/W     
@ 2,3 SAY "pen..." ;
	COLOR N/W     
@ 3,3 SAY "lose" ;
	COLOR N/W     
@ 5,2 SAY "S" ;
	COLOR W+/W    
@ 5,3 SAY "ave" ;
	COLOR N/W     
@ 6,2 SAY "Sa" ;
	COLOR N/W     
@ 6,4 SAY "v" ;
	COLOR W+/W    
@ 6,5 SAY "e as..." ;
	COLOR N/W     
@ 7,2 SAY "R" ;
	COLOR W+/W    
@ 7,3 SAY "evert" ;
	COLOR N/W     
@ 9,5 SAY "nter Setup..." ;
	COLOR N/W     
@ 9,4 SAY "i" ;
	COLOR W+/W    
@ 9,2 SAY "Pr" ;
	COLOR N/W     
@ 10,2 SAY "P" ;
	COLOR W+/W    
@ 10,3 SAY "rint..." ;
	COLOR N/W     
@ 12,2 SAY "Q" ;
	COLOR W+/W    
@ 12,3 SAY "uit" ;
	COLOR N/W     
release window syspop

activate window littlewin
@ 6,0 say "  ÆÍ File Menu Popup  "  COLOR GR+/B
@ 12,0 say "  ³"  COLOR GR+/B
@ 13,0 say "ÄÙ"  COLOR GR+/B
for cnt = 25 to 30 
	move window littlewin to 1,cnt
	do inpause with 4
endfor

ACTIVATE WINDOW filepop
do apause
DEFINE WINDOW editpop ;
	FROM 1, 14 ;
	TO 19,42 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 4

ACTIVATE WINDOW editpop NOSHOW
@ 0,0 TO 18,28 ;
	COLOR N/W     
@ 3,0 TO 3,28 ;
	COLOR N/W     
@ 8,0 TO 8,28 ;
	COLOR N/W     
@ 10,0 TO 10,28 ;
	COLOR N/W     
@ 16,0 TO 16,28 ;
	COLOR N/W     
@ 16,0 SAY "Ã" ;
	COLOR N/W     
@ 16,28 SAY "´" ;
	COLOR N/W     
@ 10,0 SAY "Ã" ;
	COLOR N/W     
@ 10,28 SAY "´" ;
	COLOR N/W     
@ 8,0 SAY "Ã" ;
	COLOR N/W     
@ 8,28 SAY "´" ;
	COLOR N/W     
@ 3,0 SAY "Ã" ;
	COLOR N/W     
@ 3,28 SAY "´" ;
	COLOR N/W     
@ 1,2 SAY "U" ;
	COLOR W+/W    
@ 2,2 SAY "R" ;
	COLOR W+/W    
@ 1,3 SAY "ndo" ;
	COLOR N/W     
@ 2,3 SAY "edo" ;
	COLOR N/W     
@ 4,2 SAY "Cu" ;
	COLOR N/W     
@ 4,4 SAY "t" ;
	COLOR W+/W    
@ 5,2 SAY "C" ;
	COLOR W+/W    
@ 5,3 SAY "opy" ;
	COLOR N/W     
@ 6,2 SAY "P" ;
	COLOR W+/W    
@ 6,3 SAY "aste" ;
	COLOR N/W     
@ 7,2 SAY "Clear" ;
	COLOR N/W     
@ 9,2 SAY "Select " ;
	COLOR N/W     
@ 9,9 SAY "A" ;
	COLOR W+/W    
@ 9,10 SAY "ll" ;
	COLOR N/W     
@ 11,2 SAY "Goto " ;
	COLOR N/W     
@ 11,7 SAY "L" ;
	COLOR W+/W    
@ 11,8 SAY "ine..." ;
	COLOR N/W     
@ 12,2 SAY "F" ;
	COLOR W+/W    
@ 12,3 SAY "ind..." ;
	COLOR N/W     
@ 13,2 SAY "Find A" ;
	COLOR N/W     
@ 13,8 SAY "g" ;
	COLOR W+/W    
@ 13,9 SAY "ain" ;
	COLOR N/W     
@ 14,2 SAY "R" ;
	COLOR N/W     
@ 14,3 SAY "e" ;
	COLOR W+/W    
@ 14,4 SAY "place And Find Again" ;
	COLOR N/W     
@ 15,2 SAY "Replace All" ;
	COLOR N/W     
@ 17,2 SAY "Prefere" ;
	COLOR N/W     
@ 17,9 SAY "n" ;
	COLOR W+/W    
@ 17,10 SAY "ces..." ;
	COLOR N/W     
@ 1,25 SAY "^U" ;
	COLOR W+/W    
@ 2,25 SAY "^R" ;
	COLOR W+/W    
@ 4,25 SAY "^X" ;
	COLOR W+/W    
@ 5,25 SAY "^C" ;
	COLOR W+/W    
@ 6,25 SAY "^V" ;
	COLOR W+/W    
@ 9,25 SAY "^A" ;
	COLOR W+/W    
@ 12,25 SAY "^F" ;
	COLOR W+/W    
@ 13,25 SAY "^G" ;
	COLOR W+/W    
@ 14,25 SAY "^E" ;
	COLOR W+/W    

release window filepop

activate window littlewin
@ 6,0 say "  ÆÍ Edit Menu Popup   "  COLOR GR+/B
for cnt = 30 to 45 
	move window littlewin to 1,cnt
	do inpause with 4
endfor

ACTIVATE WINDOW editpop
do apause
DEFINE WINDOW datapop ;
	FROM 1, 20 ;
	TO 19,37 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 4

ACTIVATE WINDOW datapop NOSHOW
@ 0,0 TO 18,17 ;
	COLOR N/W     
@ 3,0 TO 3,17 ;
	COLOR N/W     
@ 8,0 TO 8,17 ;
	COLOR N/W     
@ 15,0 TO 15,17 ;
	COLOR N/W     
@ 15,0 SAY "Ã" ;
	COLOR N/W     
@ 15,17 SAY "´" ;
	COLOR N/W     
@ 8,0 SAY "Ã" ;
	COLOR N/W     
@ 8,17 SAY "´" ;
	COLOR N/W     
@ 3,0 SAY "Ã" ;
	COLOR N/W     
@ 3,17 SAY "´" ;
	COLOR N/W     
@ 1,2 SAY "Set" ;
	COLOR N/W     
@ 1,5 SAY "u" ;
	COLOR W+/W    
@ 1,6 SAY "p..." ;
	COLOR N/W     
@ 2,2 SAY "B" ;
	COLOR W+/W    
@ 2,3 SAY "rowse" ;
	COLOR N/W     
@ 4,2 SAY "A" ;
	COLOR W+/W    
@ 5,2 SAY "C" ;
	COLOR W+/W    
@ 6,2 SAY "S" ;
	COLOR W+/W    
@ 7,2 SAY "T" ;
	COLOR W+/W    
@ 4,3 SAY "ppend From..." ;
	COLOR N/W     
@ 5,3 SAY "opy To..." ;
	COLOR N/W     
@ 6,3 SAY "ort..." ;
	COLOR N/W     
@ 7,3 SAY "otal..." ;
	COLOR N/W     
@ 9,2 SAY "A" ;
	COLOR N/W     
@ 9,3 SAY "v" ;
	COLOR W+/W    
@ 9,4 SAY "erage..." ;
	COLOR N/W     
@ 10,2 SAY "C" ;
	COLOR N/W     
@ 10,3 SAY "o" ;
	COLOR W+/W    
@ 10,4 SAY "unt..." ;
	COLOR N/W     
@ 11,2 SAY "Su" ;
	COLOR N/W     
@ 11,4 SAY "m" ;
	COLOR W+/W    
@ 11,5 SAY "..." ;
	COLOR N/W     
@ 12,2 SAY "Calculat" ;
	COLOR N/W     
@ 12,10 SAY "e" ;
	COLOR W+/W    
@ 12,11 SAY "..." ;
	COLOR N/W     
@ 13,2 SAY "R" ;
	COLOR W+/W    
@ 14,2 SAY "L" ;
	COLOR W+/W    
@ 13,3 SAY "eport..." ;
	COLOR N/W     
@ 14,3 SAY "abel..." ;
	COLOR N/W     
@ 16,2 SAY "P" ;
	COLOR W+/W    
@ 16,3 SAY "ack" ;
	COLOR N/W     
@ 17,2 SAY "Reinde" ;
	COLOR N/W     
@ 17,8 SAY "x" ;
	COLOR W+/W    

release window editpop

activate window littlewin
@ 6,0 say "  ÆÍ Database Menu Popup "  COLOR GR+/B
@ 12,0 say "ÄÙ"  COLOR GR+/B
@ 13,0 say "   "  COLOR GR+/B
for cnt = 45 to 40 step -1 
	move window littlewin to 1,cnt
	do inpause with 4
endfor

ACTIVATE WINDOW datapop
do apause
DEFINE WINDOW recopop ;
	FROM 1, 30 ;
	TO 13,44 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 4

ACTIVATE WINDOW recopop NOSHOW
@ 0,0 TO 12,14 ;
	COLOR N/W     
@ 3,0 TO 3,14 ;
	COLOR N/W     
@ 8,0 TO 8,14 ;
	COLOR N/W     
@ 8,0 SAY "Ã" ;
	COLOR N/W     
@ 8,14 SAY "´" ;
	COLOR N/W     
@ 3,0 SAY "Ã" ;
	COLOR N/W     
@ 3,14 SAY "´" ;
	COLOR N/W     
@ 1,2 SAY "A" ;
	COLOR W+/W    
@ 1,3 SAY "ppend" ;
	COLOR N/W     
@ 2,2 SAY "Chang" ;
	COLOR N/W     
@ 2,7 SAY "e" ;
	COLOR W+/W    
@ 4,2 SAY "G" ;
	COLOR W+/W    
@ 5,2 SAY "L" ;
	COLOR W+/W    
@ 6,2 SAY "C" ;
	COLOR W+/W    
@ 7,2 SAY "S" ;
	COLOR W+/W    
@ 10,2 SAY "D" ;
	COLOR W+/W    
@ 11,2 SAY "R" ;
	COLOR W+/W    
@ 9,4 SAY "p" ;
	COLOR W+/W    
@ 4,3 SAY "oto..." ;
	COLOR N/W     
@ 5,3 SAY "ocate..." ;
	COLOR N/W     
@ 6,3 SAY "ontinue" ;
	COLOR N/W     
@ 7,3 SAY "eek..." ;
	COLOR N/W     
@ 9,2 SAY "Re" ;
	COLOR N/W     
@ 9,5 SAY "lace..." ;
	COLOR N/W     
@ 10,3 SAY "elete..." ;
	COLOR N/W     
@ 11,3 SAY "ecall..." ;
	COLOR N/W     
@ 6,11 SAY "^K" ;
	COLOR W+/W    
release window datapop

activate window littlewin
@ 6,0 say "  ÆÍ Record Menu Popup     "  COLOR GR+/B
for cnt = 40 to 47
	move window littlewin to 1,cnt
	do inpause with 4
endfor

ACTIVATE WINDOW recopop
do apause
DEFINE WINDOW progpop ;
	FROM 1, 38 ;
	TO 11,52 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 4

ACTIVATE WINDOW progpop NOSHOW
@ 0,0 TO 10,14 ;
	COLOR N/W     
@ 2,0 TO 2,14 ;
	COLOR N/W     
@ 5,0 TO 5,14 ;
	COLOR N/W     
@ 5,0 SAY "Ã" ;
	COLOR N/W     
@ 5,14 SAY "´" ;
	COLOR N/W     
@ 2,0 SAY "Ã" ;
	COLOR N/W     
@ 2,14 SAY "´" ;
	COLOR N/W     
@ 3,2 SAY "C" ;
	COLOR W+/W    
@ 4,2 SAY "R" ;
	COLOR W+/W    
@ 6,4 SAY "m" ;
	COLOR W+/W    
@ 7,4 SAY "n" ;
	COLOR W+/W    
@ 8,4 SAY "x" ;
	COLOR W+/W    
@ 9,5 SAY "G" ;
	COLOR W+/W    
@ 3,3 SAY "ancel" ;
	COLOR N/W     
@ 4,3 SAY "esume" ;
	COLOR N/W     
@ 6,2 SAY "Co" ;
	COLOR N/W     
@ 6,5 SAY "pile..." ;
	COLOR N/W     
@ 7,2 SAY "Ge" ;
	COLOR N/W     
@ 7,5 SAY "erate..." ;
	COLOR N/W     
@ 8,2 SAY "Fo" ;
	COLOR N/W     
@ 8,5 SAY "Doc" ;
	COLOR N/W     
@ 9,2 SAY "Fox" ;
	COLOR N/W     
@ 9,6 SAY "raph..." ;
	COLOR N/W     
@ 1,11 SAY "^D" ;
	COLOR W+/W    
@ 4,11 SAY "^M" ;
	COLOR W+/W    
@ 1,3 SAY "o..." ;
	COLOR N/W     
@ 1,2 SAY "D" ;
	COLOR W+/W    

release window recopop

activate window littlewin
for cnt = 47 to 12 step -1
	move window littlewin to 1,cnt
	do inpause with 4
endfor
@ 0,0 say "   "  COLOR GR+/B
@ 12,0 say "   "  COLOR GR+/B
do inpause with 4
@ 1,0 say "   "  COLOR GR+/B
@ 11,0 say "   "  COLOR GR+/B
do inpause with 4
@ 2,0 say "   "  COLOR GR+/B
@ 10,0 say "   "  COLOR GR+/B
do inpause with 4
@ 3,0 say "   "  COLOR GR+/B
@ 9,0 say "   "  COLOR GR+/B
do inpause with 4
@ 4,0 say "   "  COLOR GR+/B
@ 8,0 say "   "  COLOR GR+/B
do inpause with 4
@ 5,0 say "   "  COLOR GR+/B
@ 7,0 say "   "  COLOR GR+/B
do inpause with 4
@ 6,0 say "  ÆÍ Program Menu Popup"  COLOR GR+/B
do inpause with 4
@ 6,0 say "  ÆÍProgram Menu Popup "  COLOR GR+/B
do inpause with 4
@ 6,0 say "  ÆProgram Menu Popup  "  COLOR GR+/B
do inpause with 4
@ 6,0 say "  Program Menu Popup   "  COLOR GR+/B
do inpause with 4
@ 6,0 say "  Program Menu Popupµ  "  COLOR GR+/B
do inpause with 4
@ 6,0 say "  Program Menu PopupÍµ  "  COLOR GR+/B
do inpause with 4
@ 6,0 say "  Program Menu Popup Íµ  "  COLOR GR+/B
@ 7,0 say "                      ³  "  COLOR GR+/B
do inpause with 4
@ 8,0 say "                      ³  "  COLOR GR+/B
@ 5,0 say "                      ³  "  COLOR GR+/B
do inpause with 4
@ 9,0 say "                      ³  "  COLOR GR+/B
@ 4,0 say "                      ³  "  COLOR GR+/B
do inpause with 4
@ 10,0 say "                      ÀÄ"  COLOR GR+/B
@ 3,0 say "                      ³  "  COLOR GR+/B
do inpause with 4
@ 2,0 say "                      ³  "  COLOR GR+/B
@ 1,0 say "                      ³  "  COLOR GR+/B
do inpause with 4
@ 0,0 say "                      ÚÄ"  COLOR GR+/B

ACTIVATE WINDOW progpop
do apause
DEFINE WINDOW windpop ;
	FROM 1, 47 ;
	TO 16,61 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 4

ACTIVATE WINDOW windpop NOSHOW
@ 0,0 TO 15,14 ;
	COLOR N/W     
@ 3,0 TO 3,14 ;
	COLOR N/W     
@ 10,0 TO 10,14 ;
	COLOR N/W     
@ 10,0 SAY "Ã" ;
	COLOR N/W     
@ 10,14 SAY "´" ;
	COLOR N/W     
@ 3,0 SAY "Ã" ;
	COLOR N/W     
@ 3,14 SAY "´" ;
	COLOR N/W     
@ 1,2 SAY "H" ;
	COLOR W+/W    
@ 2,6 SAY "r" ;
	COLOR W+/W    
@ 4,2 SAY "M" ;
	COLOR W+/W    
@ 5,2 SAY "S" ;
	COLOR W+/W    
@ 6,2 SAY "Z" ;
	COLOR W+/W    
@ 7,3 SAY "o" ;
	COLOR W+/W    
@ 8,2 SAY "C" ;
	COLOR W+/W    
@ 9,4 SAY "l" ;
	COLOR W+/W    
@ 12,2 SAY "D" ;
	COLOR W+/W    
@ 13,2 SAY "T" ;
	COLOR W+/W    
@ 14,2 SAY "V" ;
	COLOR W+/W    
@ 1,3 SAY "ide" ;
	COLOR N/W     
@ 2,2 SAY "Clea" ;
	COLOR N/W     
@ 4,3 SAY "ove" ;
	COLOR N/W     
@ 5,3 SAY "ize" ;
	COLOR N/W     
@ 6,3 SAY "oom " ;
	COLOR N/W     
@ 7,2 SAY "Z" ;
	COLOR N/W     
@ 8,3 SAY "ycle" ;
	COLOR N/W     
@ 9,2 SAY "Co" ;
	COLOR N/W     
@ 9,5 SAY "or..." ;
	COLOR N/W     
@ 11,2 SAY "Command" ;
	COLOR N/W     
@ 12,3 SAY "ebug" ;
	COLOR N/W     
@ 13,3 SAY "race" ;
	COLOR N/W     
@ 14,3 SAY "iew" ;
	COLOR N/W     
@ 11,10 SAY "^F2" ;
	COLOR W+/W    
@ 8,10 SAY "^F1" ;
	COLOR W+/W    
@ 7,10 SAY "^F9" ;
	COLOR W+/W    
@ 6,9 SAY "^F10" ;
	COLOR W+/W    
@ 5,10 SAY "^F8" ;
	COLOR W+/W    
@ 5,10 SAY "^F7" ;
	COLOR W+/W    
@ 6,7 SAY "" ;
	COLOR N/W     
@ 7,7 SAY "" ;
	COLOR N/W     
@ 7,4 SAY "om" ;
	COLOR N/W     
release window progpop

activate window littlewin
@ 6,0 say "   Window Menu Popup Íµ  "  COLOR GR+/B
@ 10,0 say "                      ³  "  COLOR GR+/B
@ 11,0 say "                      ³  "  COLOR GR+/B
@ 12,0 say "                      ³  "  COLOR GR+/B
@ 13,0 say "                      ÀÄ"  COLOR GR+/B
do inpause with 4
for cnt = 12 to 21
	move window littlewin to 1,cnt
	do inpause with 4
endfor

ACTIVATE WINDOW windpop
do apause
release window windpop
@ 13,0 say "                         "  COLOR GR+/B
@ 0,0 say "                         "  COLOR GR+/B
do inpause with 4
@ 12,0 say "                         "  COLOR GR+/B
@ 1,0 say "                         "  COLOR GR+/B
do inpause with 4
@ 11,0 say "                         "  COLOR GR+/B
@ 2,0 say "                         "  COLOR GR+/B
do inpause with 4
@ 10,0 say "                         "  COLOR GR+/B
@ 3,0 say "                         "  COLOR GR+/B
do inpause with 4
@ 9,0 say "                         "  COLOR GR+/B
@ 4,0 say "                         "  COLOR GR+/B
do inpause with 4
@ 8,0 say "                         "  COLOR GR+/B
@ 5,0 say "                         "  COLOR GR+/B
do inpause with 4
release window littlewin

define window menusys from 7,25 to 7,35 none noshadow
activate window menusys
@ 0,0 say "menu system"  COLOR GR+/B
for cnt = 7 to 16
	move window menusys to cnt,25
	do inpause with 4
endfor
release window menusys
define window menusys from 17,25 to 17,35 none noshadow COLOR SCHEME 12
activate window menusys
@ 0,0 say "menu system"
for cnt = 17 to 20
	move window menusys to cnt,25
	do inpause with 4
endfor
do inpause with 6

activate window welcome2
release window menusys
@ 0,1 say "  More specific information is communicated to FoxPro via dialogs"
@ 1,1 say "  that may contain check boxes, lists, popups, push buttons, and "
@ 2,1 say "  radio buttons.                                                 "
do apause

declare fakeit(9)
fakeit(1) = "[..]"
fakeit(2) = "[DBFS]"
fakeit(3) = "[SAMPLES]"
fakeit(4) = "CUSTOMER.DBF"
fakeit(5) = "DETAIL.DBF"
fakeit(6) = "INVOICES.DBF"
fakeit(7) = "OFFICES"
fakeit(8) = "PARTS"
fakeit(9) = "SALESMAN"
	
DEFINE WINDOW fakediag ;
		FROM 3,15 TO 20,64;
		FLOAT ;
		NOCLOSE ;
		SHADOW ;
		DOUBLE ;
		COLOR SCHEME 5



ACTIVATE WINDOW fakediag NOSHOW
@ 1,35 GET drive ;
	PICTURE "@^ C" ;
	SIZE 3,11 ;
	DEFAULT "C"	
@ 2,29 SAY "Drive"
@ 6,25 SAY "Directory"
@ 5,35 GET thedir ;
	PICTURE "@^ FOXPRO" ;
	SIZE 3,11 ;
	DEFAULT "FOXPRO"	
@ 9,36 GET y ;
	PICTURE "@*VN  \!Open; New; Cancel " ;
	SIZE 1,10,1 ;
	DEFAULT 0
@ 0,3 SAY "Open:"
@ 1,1 GET z ;
	PICTURE "@&N" ;
	FROM fakeit ;
	SIZE 10,18 ;
	DEFAULT 1 ;
	COLOR SCHEME 6
@ 11,3 GET w ;
	PICTURE "@*C All Files" ;
	SIZE 1,13 ;
	DEFAULT 0
@ 12,2 GET v ;
	PICTURE "@^ Screen" ;
	SIZE 3,16 ;
	DEFAULT "Screen"	
@ 13,19 SAY "Type"
@ 15,3 GET u ;
	PICTURE "@*C Restore Environment" ;
	SIZE 1,23 ;
	DEFAULT 1

define window menusys from 18,65 to 18,71 none noshadow COLOR SCHEME 12
activate window menusys
@ 0,0 say "dialogs"
move window menusys to 17,65
activate window welcome2
@ 0,59 say "dialogs" color w+/r
release window menusys
define window menusys from 15,59 to 16,72 none noshadow
activate window menusys
@ 1,0 say "      dialogs"  COLOR GR+/B
for cnt = 15 to 8 step -1
	move window menusys to cnt,59
	do inpause with 4
endfor

for cnt = 59 to 1 step -1 
	move window menusys to 8,cnt
	do inpause with 4
endfor
@ 1,0 SAY "     List ÍÍ" COLOR GR+/B
do inpause with 4	
ACTIVATE WINDOW fakediag
hide window welcome2
do apause	
activate window menusys
@ 1,0 say "Check Box ÍÍ" color GR+/B
for cnt = 8 to 14
	move window menusys to cnt,1
	do inpause with 4
endfor
if speed = 4
	for cnt2 = 1 to 50
		nullst = "null"
	endfor
else
	do inpause with 30	
endif

@ 0,0 say "  Popup      " color GR+/B
@ 1,0 say "  Control ÍÍ" color GR+/B
for cnt = 14 to 16
	move window menusys to cnt,1
	do inpause with 4
endfor
if speed = 4
	for cnt2 = 1 to 50
		nullst = "null"
	endfor
else
	do inpause with 30	
endif

@ 0,0 say "             " color GR+/B
@ 1,0 say "Check Box ÍÍ" color GR+/B
for cnt = 16 to 18
	move window menusys to cnt,1
	do inpause with 4
endfor
if speed = 4
	for cnt2 = 1 to 50
		nullst = "null"
	endfor
else
	do inpause with 30	
endif

@ 0,0 SAY "    Push     " COLOR GR+/B
@ 1,0 SAY "ÍÍ Button   " COLOR GR+/B
for cnt = 18 to 12 step -1
	move window menusys to cnt,1
	do inpause with 4
endfor
do inpause with 4
activate window fakediag	
for cnt = 0 to 15
	move window menusys to 12,cnt
	do inpause with 4
endfor
move window menusys to 12,51
for cnt = 51 to 67
	move window menusys to 12,cnt
	do inpause with 4
endfor
if speed = 4
	for cnt2 = 1 to 50
		nullst = "null"
	endfor
else
	do inpause with 30	
endif
for cnt = 12 to 14
	move window menusys to cnt,67
	do inpause with 4
endfor
do inpause with 30
for cnt = 14 to 16
	move window menusys to cnt,67
	do inpause with 4
endfor
if speed = 4
	for cnt2 = 1 to 50
		nullst = "null"
	endfor
else
	do inpause with 30	
endif

hide WINDOW fakediag
activate window menusys
@ 0,0 say "             "
@ 1,0 say "dialogs      "  COLOR GR+/B
move window menusys to 15,67
do inpause with 4
show window welcome2
for cnt = 67 to 65 step -1
	move window menusys to 15,cnt
	do inpause with 4
endfor
release window menusys
define window menusys from 17,65 to 17,71 none noshadow COLOR SCHEME 12
activate window menusys
@ 0,0 say "dialogs"
move window menusys to 18,65
do inpause with 40

activate window welcome2
release window menusys
clear
@ 0,1 say " Have you ever had a question and no one was around to answer it?"
@ 1,1 say " With FoxPro, help is always close at hand.  FoxPro provides help"
@ 2,1 say " for hundreds of topics. "
do apause
if NOT empty(alltrim(set("HELP",1)))
	if set('HELP') = "OFF"
		helpset = "OFF"
		set help on
	else
		helpset = "ON"
	endif
	clear typeahead
	set typeahead to 128
	for cnt = 1 to 126
		keyboard "{RIGHTARROW}"
	endfor
	keyboard "{CTRL+W}"
	HELP
	clear typeahead
	if helpset = "OFF"
		set help off
	endif
else
	wait window "Help file is not available" timeout 3
endif

activate window welcome2
clear
@ 0,1 say "If you ask for help while looking at a dialog, FoxPro tells you all"
@ 1,1 say "about that particular dialog.  FoxPro even provides a handy list"
@ 2,1 say "of related topics."
do apause
hide window welcome2
define window menusys from 18,50 to 19,62 none noshadow
activate window menusys
@ 0,0 say "ÍÍ Open File"  COLOR GR+/B
@ 1,0 say "     Dialog  "  COLOR GR+/B
move window fakediag to 3,14
activate WINDOW fakediag
for cnt = 50 to 66
	move window menusys to 18,cnt
	do inpause with 4
endfor

do inpause with 30

faketext =	"ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·                     "+;
 			"º           Open File             º                     "+;
 			"ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½                     "+;
 			"When you choose Open... from the File menu popup, the   "+;
 			"Open File dialog appears so you can open existing       "+;
 			"files.  Variations of this dialog appear at other times "+;
 			"in the product when you need to open a file.  For       "+;
 			"example, when you need to open a report, an Open Report "+;
 			"File dialog appears.  The Open File dialog displays all "+;
 			"files of a particular type.  File types are categorized "+;
 			"by their extensions.                                    "+;
 			"                                                        "+;
 			"                                                        "

DEFINE WINDOW fakehelp ;
	FROM 2, 2 ;
	TO 15,75 ;
	TITLE "Help" ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 8

ACTIVATE WINDOW fakehelp NOSHOW
@ 1,15 TO 12,15 ;
	COLOR W/BG    
@ 2,2 GET helpbut ;
	PICTURE "@*VN  \!\<Topics ; \<Next ; \<Previous ; \<Look Up " ;
	SIZE 1,12,1 ;
	DEFAULT 1
@ 10,2 GET helppop ;
	PICTURE "@^ See Also;junk" ;
	SIZE 3,12 ;
	DEFAULT "See Also"	 ;
	COLOR SCHEME 8, 8
@ 0,0 TO 13,73 PANEL ;
	COLOR W/BG    
@ 1,17 EDIT faketext ;
	SIZE 12,56,0 ;
	DEFAULT " " ;
	COLOR SCHEME 17
@ 0,35 SAY "Help" ;
	COLOR GR+/W   
@ 0,0 SAY "þ" ;
	COLOR GR+/W   
@ 0,73 SAY "ð" ;
	COLOR GR+/W   
@ 13,73 SAY "" ;
	COLOR GR+/W   

ACTIVATE WINDOW fakehelp
release window menusys
do effect1 with 8,49,"ÚÄ  Help Text for  Ä¿","  Open File Dialog "
do effect1 with 3,28,"     Help Topics     ","ÄÄÄÄÄÄÄÄÄÙ          "
do effect1 with 5,28,"   Next Help Topic   ","ÄÄÄÄÄÄÄÄÄÙ          "
do effect1 with 7,28," Previous Help Topic ","ÄÄÄÄÄÄÄÄÄÙ          "
do effect1 with 9,28," Look Up Highlighted ","ÄÄÄÄÄÄÄText         "

@ 4,60 say "p" color w+/r
do inpause with 40
@ 4,61 say "o" color w+/r
do inpause with 40
@ 4,62 say "p" color w+/r
do inpause with 40
@ 4,63 say "u" color w+/r
do inpause with 40
@ 4,64 say "p" color w+/r
do inpause with 40
@ 8,2 say "< Look Up  >" color w+/r
do inpause with 45

faketext =	"ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·                     "+;
            "º             Popup               º                     "+;
            "ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½                     "+;
            "Popups are used for setting values or choosing from a   "+;
            "list of related items.  Popups are represented by a box "+;
            "with a double line on the right and bottom borders.  A  "+;
            "value is displayed in the box.  When the user chooses   "+;
            "this popup control in an input screen, the popup        "+;
            "appears.                                                "+;
            "                                                        "+;
            "A popup may be defined as either a list popup or an     "+;
            "array popup.  In a list popup, you will define all the  "
ACTIVATE WINDOW fakehelp
@ 1,17 EDIT faketext ;
	SIZE 12,56,0 ;
	DEFAULT " " ;
	COLOR SCHEME 17
@ 8,2 say "< Look Up  >" color b/gb
do apause

DEFINE WINDOW freltop ;
	FROM 12,5;
	TO 20,29 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 8

ACTIVATE WINDOW freltop NOSHOW
@ 0,0 TO 8,24 COLOR B/BG    
@ 2,0 say "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" COLOR B/BG 
@ 1,2 SAY "Open File"
@ 3,2 SAY "Choose Field/Variable"
@ 4,2 SAY "Code Snippet"
@ 5,2 SAY "Comment"
@ 6,2 SAY "Expression Builder"
@ 7,2 SAY "Screen Builder"

ACTIVATE WINDOW freltop
do effect1 with 13,42,"   Related Topics    ","ÄÄÄÄÄÄÄÄÙ         "

release window fakehelp
release window freltop
release window fakediag

activate window welcome2
clear
@ 0,1 say "  Most actions in FoxPro take place in windows.  A window can be"
@ 1,1 say "  opened, closed, moved, resized, zoomed, minimized and scrolled."
do apause
define window fakewin from 2,2 to 10,30 system shadow grow close zoom;
 minimize title "Sample Window" color scheme 8
activate window fakewin
@ 0,1 say "    Opened" color gr+/bg
do inpause with 30
@ 0,1 say "    Opened"
@ 1,1 say "    Moving" color gr+/bg
for r = 2 to 15
	move window fakewin to r,2
	do inpause with 4
endfor
for c = 2 to 30
	move window fakewin to 15,c
	do inpause with 4
endfor
for r = 15 to 2 step -1
	move window fakewin to r,30
	do inpause with 4
endfor
for c = 30 to 2 step -1
	move window fakewin to 2,c
	do inpause with 4
endfor
@ 1,1 say "    Moved "
@ 2,1 say "About to be resized"  color gr+/bg
do apause

for cnt = 31 to 71
	zoom window fakewin norm from 2,2 to 10,cnt
endfor

@ 2,1 say "    Resized         "
@ 3,1 say "About to be minimized"  color gr+/bg
do apause

zoom window fakewin min
do apause
zoom window fakewin norm
@ 3,1 say "    No longer Minimized         "
@ 4,1 say "About to be Zoomed to full screen" color gr+/bg
do apause

zoom window fakewin max
@ 4,1 say "    Zoomed to full screen         " color gr+/bg
do apause
zoom window fakewin norm
@ 4,1 say "    No longer Zoomed          "
do apause
release window fakewin

*******************************
* desk accessory section

activate window welcome2
clear
@ 0,1 say "Several handy desk accessories are always available for use, such"
@ 1,1 say "as a file manager, calendar, special characters chart, ASCII chart,"
@ 2,1 say "calculator and even a small puzzle."
do apause


********************************
* define fake filer window

DEFINE WINDOW filerwin ;
	FROM 2, 2 ;
	TO 21,76 ;
	NOFLOAT ;
	CLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 8

ACTIVATE WINDOW filerwin NOSHOW
@ 0,0 TO 19,74 PANEL ;
	COLOR W/BG    
@ 0,0 SAY "þ" ;
	COLOR GR+/W   
@ 17,4 GET fx ;
	PICTURE "@*VN  Find ; Edit " ;
	SIZE 1,8,0 ;
	DEFAULT 1
@ 17,16 GET fx ;
	PICTURE "@*VN  Copy ; Attr " ;
	SIZE 1,8,0 ;
	DEFAULT 1
@ 17,28 GET fx ;
	PICTURE "@*VN  Move ; Rename " ;
	SIZE 1,10,0 ;
	DEFAULT 1
@ 17,42 GET fx ;
	PICTURE "@*VN  Delete ; Size " ;
	SIZE 1,10,0 ;
	DEFAULT 1
@ 17,57 GET fx ;
	PICTURE "@*VN  Sort ; Tree " ;
	SIZE 1,8,0 ;
	DEFAULT 1
@ 16,53 TO 16,72
@ 13,57 GET fx ;
	PICTURE "@*VN Tag All ; Tag None ; Invert " ;
	SIZE 1,12,0 ;
	DEFAULT 1
@ 9,53 TO 9,72
@ 10,55 SAY "Files Like"
@ 11,57 SAY "*.*         " ;
	COLOR W+/W    
@ 7,55 SAY "Dir."
@ 4,55 SAY "Drv."
@ 3,61 GET fx ;
	PICTURE "@^ C;D" ;
	SIZE 3,10 ;
	DEFAULT "C"	 ;
	COLOR SCHEME 8, 8
@ 6,61 GET fx ;
	PICTURE "@^ DEMO; DEMO" ;
	SIZE 3,10 ;
	DEFAULT "DEMO"	 ;
	COLOR SCHEME 8, 8
@ 3,3 TO 16,52 ;
	COLOR B/BG    
@ 2,5 SAY "Name"
@ 2,16 SAY "Ext"
@ 2,23 SAY "Size"
@ 2,30 SAY "Last Modified"
@ 2,47 SAY "Attr"
@ 3,52 SAY "Ü" ;
	COLOR B/BG    
@ 14,52 SAY "Û" ;
	COLOR B/BG    
@ 5,52 SAY "" ;
	COLOR BG/B    
@ 4,52 SAY "" ;
	COLOR BG/B    
@ 15,52 SAY "" ;
	COLOR BG/B    
@ 16,52 SAY "ß" ;
	COLOR B/BG    
@ 13,52 SAY "Û" ;
	COLOR B/BG    
@ 12,52 SAY "Û" ;
	COLOR B/BG    
@ 11,52 SAY "Û" ;
	COLOR B/BG    
@ 8,52 SAY "Û" ;
	COLOR B/BG    
@ 10,52 SAY "Û" ;
	COLOR B/BG    
@ 9,52 SAY "Û" ;
	COLOR B/BG    
@ 7,52 SAY "Û" ;
	COLOR B/BG    
@ 6,52 SAY "Û" ;
	COLOR B/BG    
@ 4,5 SAY "[..]                    08-May-91  2:16p  ...."
@ 5,5 SAY "DEMO      .APP  356178  23-May-91  4:23p  .a.."
@ 6,5 SAY "SAMPLE    .DBF    4248  23-May-91  7:17a  .a.."
@ 7,5 SAY "SAMPLE    .FRX    4696  23-May-91 12:55p  .a.."
@ 8,5 SAY "SAMPLE    .PJX    7835  23-May-91  4:39a  .a.."
@ 9,5 SAY "SAMPLE    .QPR     331  23-May-91  8:45a  .a.."
@ 0,35 SAY "Filer" ;
	COLOR GR+/W   

ACTIVATE WINDOW filerwin
activate window welcome2
clear
@ 0,1 say "FoxPro's Filer allows you to copy, move and delete files, change"
@ 1,1 say "file attributes and find specific files.  You can also create,"
@ 2,1 say "copy, move and delete entire directories."
do apause
********************************
hide window welcome2
activate window calendar
define window menusys from 2,22 to 10,41 none color scheme 8
activate window menusys
@ 0,0 say "Saw fantastic demo"
@ 1,0 say "of FoxPro 2.5 today."
@ 3,0 say "Order it ASAP!!!!!!"
do apause
activate window special
do apause
activate window ascii
do apause
activate window puzzle
do apause
activate window calculator
do apause
release window calculator
do inpause with 40
release window puzzle
do inpause with 40
release window ascii
do inpause with 40
release window special
do inpause with 40
release window menusys
release window calendar
do inpause with 40
release window filerwin

release window welcome2
do overnout

procedure overnout
set escape off
on escape *
on key label escape *
if wexist("welcome1")
	release window welcome1
endif
if wexist("welcome2")
	release window welcome2
endif
if wexist("syspop")
	release window syspop
endif
if wexist("filepop")
	release window filepop
endif
if wexist("littlewin")
	release window littlewin
endif
if wexist("menusys")
	release window menusys
endif
if wexist("editpop")
	release window editpop
endif
if wexist("datapop")
	release window datapop
endif
if wexist("recopop")
	release window recopop
endif
if wexist("progpop")
	release window progpop
endif
if wexist("windpop")
	release window windpop
endif
if wexist("fakediag")
	release window fakediag
endif
if wexist("fakehelp")
	release window fakehelp
endif
if wexist("freltop")
	release window freltop
endif
if wexist("enlarge")
	release window enlarge
endif
if wexist("fakewin")
	release window fakewin
endif
if wexist("help")
	release window help
endif
if wexist("calendar")
	release window calendar
endif
if wexist("calculator")
	release window calculator
endif
if wexist("special")
	release window special
endif
if wexist("ascii")
	release window ascii
endif
if wexist("puzzle")
	release window puzzle
endif
if wexist("filerwin")
	release window filerwin
endif
for cnt = 1 to 21
	if wexist("letter"+alltrim(str(cnt)))
		release window ("letter"+alltrim(str(cnt)))
	endif
endfor
set sysmenu to default
set sysmenu off
activate screen
clear
clear typeahead
return to rundemo

procedure escout
escpress = .t.
do overnout
return
	
procedure effect1
parameters xfrom, yfrom, textstr1, textstr2
yto = yfrom
define window enlarge from xfrom,yfrom to xfrom+1,yto none color scheme 7
activate window enlarge
for z = 1 to 10
	do inpause with 4
	zoom window enlarge norm from xfrom, yfrom-1 to xfrom+1, yto+1
	yfrom = yfrom - 1
	yto = yto + 1
endfor
@ 0,0 say textstr1
@ 1,0 say textstr2
do apause
for z = 1 to 10
	do inpause with 4
	zoom window enlarge norm from xfrom, yfrom+1 to xfrom+1, yto-1
	yfrom = yfrom + 1
	yto = yto - 1
endfor
release window enlarge
return
