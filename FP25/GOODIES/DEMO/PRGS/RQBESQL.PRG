on key label escape do escout
on escape do escout
set escape on
set blink off
clear typeahead
do bigchars with 8,10,"RQBE/SQL"
do apause
for cnt = 1 to 8
	release window ("letter"+alltrim(str(cnt)))
endfor
set blink on
set sysmenu automatic
DEFINE WINDOW rqbe1 from 16,7 to 21,74 DOUBLE COLOR SCHEME 12 TITLE " FoxPro 2.5 - RQBE/SQL" SHADOW
ACTIVATE WINDOW rqbe1
@ 0,1 say "         RQBE stands for Relational Query By Example."                    
@ 1,1 say "RQBE is designed to allow you to quickly extract meaningful "
@ 2,1 say "information from your databases.  The RQBE window is the control" 
@ 3,1 say "center for building your queries."
do apause
define window menusys from 19,47 to 19,57 none noshadow COLOR SCHEME 12
@ 2,39 say "RQBE window" color w+/r
activate window menusys
@ 0,0 say "RQBE window"
for cnt = 19 to 16 step -1
	move window menusys to cnt,47
	do inpause with 4
endfor
release window menusys
define window menusys from 15,47 to 15,57 none noshadow
activate window menusys
@ 0,0 say "RQBE window"  COLOR GR+/B
for cnt = 15 to 8 step -1
	move window menusys to cnt,47
	do inpause with 4
endfor
for cnt = 47 to 35 step -1
	move window menusys to 8,cnt
	do inpause with 4
endfor

DEFINE WINDOW rqbescr ;
	FROM 1, 1 ;
	TO 22,78 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 8

*       ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
*       º                                                         º
*       º                  RQBESCR Screen Layout                  º
*       º                                                         º 
*       ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
*    

ACTIVATE WINDOW rqbescr NOSHOW
@ 0,0 TO 21,77 PANEL ;
	COLOR W/W     
@ 10,1 TO 10,76 ;
	COLOR W/BG    
@ 1,17 TO 10,17 ;
	COLOR W/BG    
@ 1,60 TO 10,60 ;
	COLOR W/BG    
@ 7,60 TO 7,76 ;
	COLOR W/BG    
@ 7,60 SAY "Ã" ;
	COLOR W/BG    
@ 10,60 SAY "Á" ;
	COLOR W/BG    
@ 10,17 SAY "Á" ;
	COLOR W/BG    
@ 1,4 SAY "Databases"
@ 2,2 TO 7,15 ;
	COLOR B/BG    
@ 3,4 SAY "CUSTOMER"
@ 4,4 SAY "INVOICES"
@ 5,4 SAY "SALESMAN"
@ 3,3 SAY ""
@ 8,4 SAY "<" ;
	COLOR B/BG    
@ 8,12 SAY ">" ;
	COLOR B/BG    
@ 8,7 SAY "A"
@ 8,8 SAY "dd" ;
	COLOR B/BG    
@ 9,4 SAY "<" ;
	COLOR B/BG    
@ 9,12 SAY ">" ;
	COLOR B/BG    
@ 9,6 SAY "C"
@ 9,7 SAY "lear" ;
	COLOR B/BG    
@ 1,21 SAY "Output Fields"
@ 2,19 TO 9,37 ;
	COLOR B/BG    
@ 3,20 SAY ""
@ 3,20 SAY "" ;
	COLOR B+/BG   
@ 4,20 SAY "" ;
	COLOR B+/BG   
@ 5,20 SAY "" ;
	COLOR B+/BG   
@ 6,20 SAY "" ;
	COLOR B+/BG   
@ 7,20 SAY "" ;
	COLOR B+/BG   
@ 8,20 SAY "" ;
	COLOR B/BG    
@ 3,21 SAY " 1"
@ 4,22 SAY "2"
@ 3,23 SAY ""
@ 4,23 SAY ""
@ 3,25 SAY "NAME"
@ 4,25 SAY "ITOTAL"
@ 5,25 SAY "COMPANY"
@ 6,25 SAY "CONTACT"
@ 7,25 SAY "PHONE"
@ 3,39 SAY "[X] Select  ields..." ;
	COLOR B/BG    
@ 5,39 SAY "[X] Order  y..." ;
	COLOR B/BG    
@ 7,39 SAY "[ ]  roup By..." ;
	COLOR B/BG    
@ 8,39 SAY "[ ]  aving..." ;
	COLOR B/BG    
@ 5,49 SAY "B"
@ 3,50 SAY "F"
@ 7,43 SAY "G"
@ 8,43 SAY "H"
@ 1,64 SAY "Output To"
@ 2,62 SAY "ÚÄÄÄÄÄÄÄÄÄÄÄÄ·" ;
	COLOR B/BG    
@ 3,62 SAY "³" ;
	COLOR B/BG    
@ 4,62 SAY "ÔÍÍÍÍÍÍÍÍÍÍÍÍ¼" ;
	COLOR B/BG    
@ 3,75 SAY "º" ;
	COLOR B/BG    
@ 3,66 SAY "Browse" ;
	COLOR B/BG    
@ 6,62 SAY "[ ] Options..." ;
	COLOR W/BG    
@ 5,62 SAY "SAMPLE        " ;
	COLOR W+/W    
@ 8,63 SAY "<  ee SQL  >"
@ 9,63 SAY "®"
@ 9,65 SAY "Do  uery"
@ 9,74 SAY "¯"
@ 9,68 SAY "Q"
@ 8,65 SAY "S"
@ 11,4 SAY "Field Name"
@ 11,26 SAY "NOT"
@ 13,26 SAY "[ ]" ;
	COLOR B/BG    
@ 14,26 SAY "[ ]" ;
	COLOR B/BG    
@ 15,26 SAY "[ ]" ;
	COLOR B/BG    
@ 12,1 TO 20,66 ;
	COLOR B/BG    
@ 13,2 SAY "" ;
	COLOR B/BG    
@ 14,2 SAY "" ;
	COLOR B/BG    
@ 15,2 SAY "" ;
	COLOR B/BG    
@ 13,3 SAY "Ý" ;
	COLOR B/BG    
@ 14,3 SAY "Ý" ;
	COLOR B/BG    
@ 13,4 SAY "INVOICES.CNO         " ;
	COLOR W+/W    
@ 16,4 SAY "                     " ;
	COLOR W+/W    
@ 15,4 SAY "INVOICES.ITOTAL      " ;
	COLOR W+/W    
@ 14,4 SAY "SALESMAN.ONO         " ;
	COLOR W+/W    
@ 15,30 SAY "More Than" ;
	COLOR W+/W    
@ 13,30 SAY "Like     " ;
	COLOR W+/W    
@ 14,30 SAY "Like     " ;
	COLOR W+/W    
@ 15,63 SAY "[ ]" ;
	COLOR B/BG    
@ 14,63 SAY "[ ]" ;
	COLOR B/BG    
@ 13,63 SAY "[ ]" ;
	COLOR B/BG    
@ 11,40 SAY "Example"
@ 11,62 SAY "Up Lo"
@ 11,64 SAY "÷"
@ 12,68 SAY "Criteria"
@ 15,40 SAY "2500                  " ;
	COLOR W+/W    
@ 14,40 SAY "CUSTOMER.ONO          " ;
	COLOR W+/W    
@ 13,40 SAY "CUSTOMER.CNO          " ;
	COLOR W+/W    
@ 11,69 SAY "Select"
@ 14,68 SAY "< nsert>" ;
	COLOR B/BG    
@ 16,68 SAY "< emove>" ;
	COLOR B/BG    
@ 18,68 SAY "<   r  >" ;
	COLOR B/BG    
@ 18,71 SAY "O"
@ 16,69 SAY "R"
@ 14,69 SAY "I"
@ 0,0 SAY "þ" ;
	COLOR GR+/W   
@ 0,32 SAY "RQBE - SAMPLE" ;
	COLOR GR+/W   

ACTIVATE WINDOW rqbescr

do apause
define window arrow from 4,50 to 4,69 none color scheme 8
activate window arrow noshow
@ 0,0 say "ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ<<<" color r/bg
move window arrow to 4,79
show window arrow
for cnt = 79 to 17 step -1
	move window arrow to 4,cnt
endfor
@ 0,2 say "Ñ" color r/bg
@ 0,15 say "Ñ" color r/bg
define window sign6 from 5,19 to 5,32 none color scheme 8
activate window sign6
@ 0,0 say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ" color r/bg
do inpause with 4

define window sign1 from 5,19 to 5,32 none color scheme 8
move window sign6 to 6,19
activate window sign1
@ 0,0 say "ÃÄÄÄÄÄÄÄÄÄÄÄÄ´" color r/bg
do inpause with 4

define window sign2 from 6,19 to 6,32 none color scheme 8
move window sign6 to 7,19
activate window sign2
@ 0,0 say "  Databases   " color gr+/r
do inpause with 4

define window sign3 from 7,19 to 7,32 none color scheme 8
move window sign6 to 8,19
activate window sign3
@ 0,0 say "  to be used  " color gr+/r
do inpause with 4

define window sign4 from 8,19 to 8,32 none color scheme 8
move window sign6 to 9,19
activate window sign4
@ 0,0 say "    in the    " color gr+/r
do inpause with 4

define window sign5 from 9,19 to 9,32 none color scheme 8
move window sign6 to 10,19
activate window sign5
@ 0,0 say "    Query     " color gr+/r
do inpause with 4
do apause

hide window sign5
move window sign6 to 9,19
do inpause with 4

hide window sign4
move window sign6 to 8,19
do inpause with 4

hide window sign3
move window sign6 to 7,19
do inpause with 4

hide window sign2
move window sign6 to 6,19
do inpause with 4

hide window sign1
move window sign6 to 5,19
do inpause with 4

hide window sign6
activate window arrow
@ 0,2 say "Í" color r/bg
@ 0,15 say "Í" color r/bg
for cnt = 4 to 21
	move window arrow to cnt,17
endfor
hide window arrow
************************
move window arrow to 4,79
show window arrow
for cnt = 79 to 39 step -1
	move window arrow to 4,cnt
endfor
activate window arrow
@ 0,2 say "Ñ" color r/bg
@ 0,15 say "Ñ" color r/bg
move window sign6 to 5,41
activate window sign6
do inpause with 4

move window sign1 to 5,41
move window sign6 to 6,41
activate window sign1
do inpause with 4

move window sign2 to 6,41
move window sign6 to 7,41
activate window sign2
@ 0,0 say "    Fields    " color gr+/r
do inpause with 4

move window sign3 to 7,41
move window sign6 to 8,41
activate window sign3
@ 0,0 say "   selected   " color gr+/r
do inpause with 4

move window sign4 to 8,41
move window sign6 to 9,41
activate window sign4
@ 0,0 say "   for this   " color gr+/r
do inpause with 4

move window sign5 to 9,41
move window sign6 to 10,41
activate window sign5
@ 0,0 say "    Query     " color gr+/r
do inpause with 4
do apause

hide window sign5
move window sign6 to 9,41
do inpause with 4

hide window sign4
move window sign6 to 8,41
do inpause with 4

hide window sign3
move window sign6 to 7,41
do inpause with 4

hide window sign2
move window sign6 to 6,41
do inpause with 4

hide window sign1
move window sign6 to 5,41
do inpause with 4

hide window sign6
activate window arrow
@ 0,2 say "Í" color r/bg
@ 0,15 say "Í" color r/bg
for cnt = 4 to 21
	move window arrow to cnt,39
endfor
hide window arrow
****************************
*  fake Select fields dialog

DEFINE WINDOW fakesele ;
	FROM INT((SROW()-19)/2) + 2,INT((SCOL()-77)/2) ;
	TO INT((SROW()-19)/2)+20,INT((SCOL()-77)/2)+76 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	DOUBLE ;
	COLOR SCHEME 5

ACTIVATE WINDOW fakesele NOSHOW
@ 0,8 SAY "Database Fields"
@ 11,1 TO 16,29
@ 11,4 SAY " Functions/Expressions "
@ 12,3 GET x ;
	PICTURE "@^  Functions " ;
	SIZE 3,15 ;
	DEFAULT " Functions "	 ;
	COLOR SCHEME 5, 5
@ 2,32 GET x ;
	PICTURE "@*VN   \<Move   ;   \<All    " ;
	SIZE 1,12,1 ;
	DEFAULT 1
@ 1,46 TO 10,73 ;
	COLOR W/RB    
@ 2,47 SAY ""
@ 3,47 SAY ""
@ 4,47 SAY ""
@ 5,47 SAY ""
@ 9,47 SAY "" ;
	COLOR W/RB    
@ 7,47 SAY "" ;
	COLOR W/RB    
@ 8,47 SAY "" ;
	COLOR W/RB    
@ 7,32 GET x ;
	PICTURE "@*VN  \<Remove  ;Remove \<All" ;
	SIZE 1,12,1 ;
	DEFAULT 1
@ 6,47 SAY ""
@ 0,52 SAY "Selected Output"
@ 11,52 GET xx ;
	PICTURE "@*C No \<Duplicates" ;
	SIZE 1,17 ;
	DEFAULT 0
@ 12,52 GET xx ;
	PICTURE "@*C \<Cross Tabulate" ;
	SIZE 1,17 ;
	DEFAULT 0
@ 14,56 SAY "®   OK   ¯"
@ 16,56 SAY "< CANCEL >"
@ 2,2 SAY "CUSTOMER.CNO           ³ C " ;
	COLOR W+/BG   
@ 9,2 SAY "CUSTOMER.CNO           ³ C " ;
	COLOR W+/BG   
@ 3,2 SAY "CUSTOMER.COMPANY       ³ C " ;
	COLOR W/BG    
@ 4,2 SAY "CUSTOMER.CONTACT       ³ C " ;
	COLOR W/BG    
@ 5,2 SAY "CUSTOMER.ADDRESS       ³ C " ;
	COLOR W+/BG   
@ 6,2 SAY "CUSTOMER.CITY          ³ C " ;
	COLOR W+/BG   
@ 7,2 SAY "CUSTOMER.STATE         ³ C " ;
	COLOR W+/BG   
@ 8,2 SAY "CUSTOMER.ZIP           ³ C " ;
	COLOR W+/BG   
@ 9,2 SAY "CUSTOMER.PHONE         ³ C " ;
	COLOR W/BG    
@ 2,48 SAY "    SALESMAN.NAME        " ;
	COLOR W+/BG   
@ 3,48 SAY "    INVOICES.ITOTAL      " ;
	COLOR W+/BG   
@ 4,48 SAY "    CUSTOMER.COMPANY     " ;
	COLOR W+/BG   
@ 5,48 SAY "    CUSTOMER.CONTACT     " ;
	COLOR W+/BG   
@ 6,48 SAY "    CUSTOMER.PHONE       " ;
	COLOR W+/BG   
@ 7,48 SAY "                         " ;
	COLOR W+/BG   
@ 8,48 SAY "                         " ;
	COLOR W+/BG   
@ 9,48 SAY "                         " ;
	COLOR W+/BG   
@ 15,3 SAY "                         " ;
	COLOR W+/BG   
@ 2,40 SAY chr(26)
@ 4,40 SAY chr(26)
@ 1,1 TO 10,29 ;
	COLOR W/RB    
@ 1,29 SAY "Ü" ;
	COLOR W/RB    
@ 2,29 SAY "" ;
	COLOR RB/W    
@ 3,29 SAY "" ;
	COLOR RB/W    
@ 4,29 SAY "Û" ;
	COLOR W/RB    
@ 5,29 SAY "Û" ;
	COLOR W/RB    
@ 6,29 SAY "Û" ;
	COLOR W/RB    
@ 7,29 SAY "Û" ;
	COLOR W/RB    
@ 8,29 SAY "Û" ;
	COLOR W/RB    
@ 9,29 SAY "" ;
	COLOR RB/W    
@ 10,29 SAY "ß" ;
	COLOR W/RB    

ACTIVATE WINDOW fakesele
	
DEFINE WINDOW seletitl ;
	FROM 2, 0 ;
	TO 4,23 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	DOUBLE ;
	COLOR SCHEME 1

ACTIVATE WINDOW seletitl
@ 0,1 SAY "Select Fields Dialog"
do apause
release window seletitl
release window fakesele

**************************
move window arrow to 4,79
show window arrow
for cnt = 79 to 25 step -1
	move window arrow to 4,cnt
endfor
activate window arrow
@ 0,2 say "Ñ" color r/bg
@ 0,15 say "Ñ" color r/bg
move window sign6 to 5,27
activate window sign6
do inpause with 4

move window sign1 to 5,27
move window sign6 to 6,27
activate window sign1
do inpause with 4

move window sign2 to 6,27
move window sign6 to 7,27
activate window sign2
@ 0,0 say "   Order in   " color gr+/r
do inpause with 4

move window sign3 to 7,27
move window sign6 to 8,27
activate window sign3
@ 0,0 say "  which data  " color gr+/r
do inpause with 4

move window sign4 to 8,27
move window sign6 to 9,27
activate window sign4
@ 0,0 say "    will be   " color gr+/r
do inpause with 4

move window sign5 to 9,27
move window sign6 to 10,27
activate window sign5
@ 0,0 say "  displayed   " color gr+/r
do inpause with 4
do apause

hide window sign5
move window sign6 to 9,27
do inpause with 4

hide window sign4
move window sign6 to 8,27
do inpause with 4

hide window sign3
move window sign6 to 7,27
do inpause with 4

hide window sign2
move window sign6 to 6,27
do inpause with 4

hide window sign1
move window sign6 to 5,27
do inpause with 4

hide window sign6
activate window arrow
@ 0,2 say "Í" color r/bg
@ 0,15 say "Í" color r/bg
for cnt = 4 to 21
	move window arrow to cnt,25
endfor
hide window arrow
**************************
*  fake Order fields dialog
DEFINE WINDOW fakeorde ;
	FROM 5, 3 ;
	TO 22,76 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	DOUBLE ;
	COLOR SCHEME 5


ACTIVATE WINDOW fakeorde NOSHOW
@ 2,30 GET x ;
	PICTURE "@*VN \<Move  ;\<Remove" ;
	SIZE 1,12,1 ;
	DEFAULT 1
@ 1,1 TO 14,25 ;
	COLOR W/RB    
@ 0,6 SAY "Selected Output"
@ 12,31 SAY "®   OK   ¯"
@ 14,31 SAY "< CANCEL >"
@ 1,47 SAY ""
@ 2,47 SAY ""
@ 3,47 SAY ""
@ 8,47 SAY "" ;
	COLOR W/RB    
@ 6,47 SAY "" ;
	COLOR W/RB    
@ 7,47 SAY "" ;
	COLOR W/RB    
@ 1,46 TO 14,70 ;
	COLOR W/RB    
@ 11,47 SAY "" ;
	COLOR W/RB    
@ 9,47 SAY "" ;
	COLOR W/RB    
@ 10,47 SAY "" ;
	COLOR W/RB    
@ 12,47 SAY "" ;
	COLOR W/RB    
@ 4,47 SAY "" ;
	COLOR W/RB    
@ 5,47 SAY "" ;
	COLOR W/RB    
@ 6,27 TO 10,44
@ 6,28 SAY " Order Options "
@ 0,50 SAY "Ordering Criteria"
@ 2,2 SAY " SALESMAN.NAME         " ;
	COLOR W/BG    
@ 3,2 SAY " INVOICES.ITOTAL       " ;
	COLOR W/BG    
@ 4,2 SAY " CUSTOMER.COMPANY      " ;
	COLOR W+/BG   
@ 5,2 SAY " CUSTOMER.CONTACT      " ;
	COLOR W+/BG   
@ 6,2 SAY " CUSTOMER.PHONE        " ;
	COLOR W+/BG   
@ 7,2 SAY "                       " ;
	COLOR W+/BG   
@ 8,2 SAY "                       " ;
	COLOR W+/BG   
@ 9,2 SAY "                       " ;
	COLOR W+/BG   
@ 10,2 SAY "                       " ;
	COLOR W+/BG   
@ 11,2 SAY "                       " ;
	COLOR W+/BG   
@ 12,2 SAY "                       " ;
	COLOR W+/BG   
@ 2,48 SAY "   SALESMAN.NAME     " ;
	COLOR W+/BG   
@ 3,48 SAY "   INVOICES.ITOTAL   " ;
	COLOR W+/BG   
@ 4,48 SAY "                      " ;
	COLOR W+/BG   
@ 5,48 SAY "                      " ;
	COLOR W+/BG   
@ 6,48 SAY "                      " ;
	COLOR W+/BG   
@ 7,48 SAY "                      " ;
	COLOR W+/BG   
@ 8,48 SAY "                      " ;
	COLOR W+/BG   
@ 9,48 SAY "                      " ;
	COLOR W+/BG   
@ 10,48 SAY "                      " ;
	COLOR W+/BG   
@ 11,48 SAY "                      " ;
	COLOR W+/BG   
@ 12,48 SAY "                      " ;
	COLOR W+/BG   
@ 7,28 GET x ;
	PICTURE "@*RVN \<Ascending;\<Descending" ;
	SIZE 1,14,0 ;
	DEFAULT 1
@ 9,28 GET xx ;
	PICTURE "@*C \<Ignore Case" ;
	SIZE 1,15 ;
	DEFAULT 0
@ 13,48 SAY "                      " ;
	COLOR W+/BG   
@ 13,47 SAY "" ;
	COLOR W/RB    
@ 13,2 SAY "                       " ;
	COLOR W+/BG   
@ 2,38 SAY chr(26)

ACTIVATE WINDOW fakeorde
**************************
DEFINE WINDOW ordetitl ;
	FROM 2, 0 ;
	TO 4,23 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	DOUBLE ;
	COLOR SCHEME 1

ACTIVATE WINDOW ordetitl
@ 0,1 SAY "Order Fields Dialog"
do apause
release window ordetitl
release window fakeorde
*************************
define window arrow2 from 4,50 to 4,69 none color scheme 8
activate window arrow2 noshow
@ 0,0 say ">>>ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ" color r/bg
move window arrow2 to 4,0
show window arrow2
for cnt = 0 to 43
	move window arrow2 to 4,cnt
endfor

DEFINE WINDOW fakepop ;
	FROM 3, 64 ;
	TO 9,79 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	NONE ;
	COLOR SCHEME 8

ACTIVATE WINDOW fakepop NOSHOW
@ 0,0 TO 6,15 ;
	COLOR B/BG    
@ 1,2 SAY "Browse"
@ 2,2 SAY "Report/Label"
@ 3,2 SAY "Table/DBF"
@ 4,2 SAY "Cursor"
@ 5,2 SAY "Graph"

ACTIVATE WINDOW fakepop
do inpause with 4
hide window fakepop
do inpause with 4
show window fakepop
do inpause with 4
hide window fakepop
do inpause with 4
show window fakepop

activate window arrow2
@ 0,4 say "Ñ" color r/bg
@ 0,17 say "Ñ" color r/bg
move window sign6 to 5,47
activate window sign6
do inpause with 4

move window sign1 to 5,47
move window sign6 to 6,47
activate window sign1
do inpause with 4

move window sign2 to 6,47
move window sign6 to 7,47
activate window sign2
@ 0,0 say "    Output    " color gr+/r
do inpause with 4

move window sign3 to 7,47
move window sign6 to 8,47
activate window sign3
@ 0,0 say " destinations " color gr+/r
do inpause with 4

move window sign4 to 8,47
move window sign6 to 9,47
activate window sign4
@ 0,0 say "   for the    " color gr+/r
do inpause with 4

move window sign5 to 9,47
move window sign6 to 10,47
activate window sign5
@ 0,0 say "    Query     " color gr+/r
do inpause with 4
do apause

hide window sign5
move window sign6 to 9,47
do inpause with 4

hide window sign4
move window sign6 to 8,47
do inpause with 4

hide window sign3
move window sign6 to 7,47
do inpause with 4

hide window sign2
move window sign6 to 6,47
do inpause with 4

hide window sign1
move window sign6 to 5,47
do inpause with 4

hide window sign6
activate window arrow2
@ 0,4 say "Í" color r/bg
@ 0,17 say "Í" color r/bg
for cnt = 4 to 21
	move window arrow2 to cnt,43
endfor
hide window arrow2

release window fakepop
***********************
move window arrow2 to 7,0
show window arrow2
for cnt = 0 to 43
	move window arrow2 to 7,cnt
endfor

activate window arrow2
@ 0,4 say "Ñ" color r/bg
@ 0,17 say "Ñ" color r/bg
move window sign6 to 8,47
activate window sign6
do inpause with 4

move window sign1 to 8,47
move window sign6 to 9,47
activate window sign1
do inpause with 4

move window sign2 to 9,47
move window sign6 to 10,47
activate window sign2
@ 0,0 say "    Output    " color gr+/r
do inpause with 4

move window sign3 to 10,47
move window sign6 to 11,47
activate window sign3
@ 0,0 say "   options    " color gr+/r
do inpause with 4

move window sign4 to 11,47
move window sign6 to 12,47
activate window sign4
@ 0,0 say "   for the    " color gr+/r
do inpause with 4

move window sign5 to 12,47
move window sign6 to 13,47
activate window sign5
@ 0,0 say "    Query     " color gr+/r
do inpause with 4
do apause

hide window sign5
move window sign6 to 12,47
do inpause with 4

hide window sign4
move window sign6 to 11,47
do inpause with 4

hide window sign3
move window sign6 to 10,47
do inpause with 4

hide window sign2
move window sign6 to 9,47
do inpause with 4

hide window sign1
move window sign6 to 8,47
do inpause with 4

hide window sign6
activate window arrow2
@ 0,4 say "Í" color r/bg
@ 0,17 say "Í" color r/bg
for cnt = 7 to 21
	move window arrow2 to cnt,43
endfor
hide window arrow2
***************************
DEFINE WINDOW fakedisp ;
	FROM 4, 2 ;
	TO 23,76 ;
	NOFLOAT ;
	NOCLOSE ;
	SHADOW ;
	DOUBLE ;
	COLOR SCHEME 5

ACTIVATE WINDOW fakedisp NOSHOW
@ 10,52 SAY "®   OK   ¯"
@ 12,52 SAY "< CANCEL >"
@ 0,1 SAY "RQBE Display Options:"
@ 2,2 TO 17,42
@ 2,4 SAY " Formatting Options "
@ 3,4 GET x ;
	PICTURE "@*RVN Screen \<Display;\<Report;\<Label" ;
	SIZE 1,18,0 ;
	DEFAULT 2
@ 6,8 GET xx ;
	PICTURE "@*C Report/Label Form \<Name" ;
	SIZE 1,26 ;
	DEFAULT 0
@ 7,12 SAY "                     " ;
	COLOR W+/BG   
@ 8,8 GET xx ;
	PICTURE "@*C \<Quick Report..." ;
	SIZE 1,19 ;
	DEFAULT 0
@ 9,8 GET xx ;
	PICTURE "@*C \<Preview Report/Label" ;
	SIZE 1,24 ;
	DEFAULT 0
@ 10,8 GET xx ;
	PICTURE "@*C \<Show Summary Info Only" ;
	SIZE 1,26 ;
	DEFAULT 0
@ 11,8 GET xx ;
	PICTURE "@*C \<Eject Page Before Report" ;
	SIZE 1,28 ;
	DEFAULT 0
@ 12,8 GET xx ;
	PICTURE "@*C Report \<Heading" ;
	SIZE 1,18 ;
	DEFAULT 0
@ 13,12 SAY "                     " ;
	COLOR W+/BG   
@ 14,8 GET xx ;
	PICTURE "@*C Suppress \<Column Headings" ;
	SIZE 1,28 ;
	DEFAULT 0
@ 15,8 GET xx ;
	PICTURE "@*RHN Console O\<n;Console \<Off" ;
	SIZE 1,15,0 ;
	DEFAULT 1
@ 2,44 TO 6,70
@ 2,45 SAY " Output Destinations "
@ 3,46 GET xx ;
	PICTURE "@*C \<To Printer" ;
	SIZE 1,14 ;
	DEFAULT 0
@ 4,46 GET xx ;
	PICTURE "@*C To \<File" ;
	SIZE 1,11 ;
	DEFAULT 0
@ 4,58 SAY "           " ;
	COLOR W+/BG   
@ 8,28 SAY "[ ] Overwrite" ;
	COLOR W/RB    
@ 16,12 SAY "[ ] Pause Between Screens" ;
	COLOR W/RB    
@ 5,50 SAY "[ ] Overwrite File" ;
	COLOR W/RB    

ACTIVATE WINDOW fakedisp
do apause
release window fakedisp
**************************
move window arrow2 to 9,0
show window arrow2
for cnt = 0 to 43
	move window arrow2 to 9,cnt
endfor

activate window arrow2
@ 0,4 say "Ñ" color r/bg
@ 0,17 say "Ñ" color r/bg
move window sign6 to 10,47
activate window sign6
do inpause with 4

move window sign1 to 10,47
move window sign6 to 11,47
activate window sign1
do inpause with 4

move window sign2 to 11,47
move window sign6 to 12,47
activate window sign2
@ 0,0 say "   Look at    " color gr+/r
do inpause with 4

move window sign3 to 12,47
move window sign6 to 13,47
activate window sign3
@ 0,0 say "   the SQL    " color gr+/r
do inpause with 4

move window sign4 to 13,47
move window sign6 to 14,47
activate window sign4
@ 0,0 say " statement to " color gr+/r
do inpause with 4

move window sign5 to 14,47
move window sign6 to 15,47
activate window sign5
@ 0,0 say " be generated " color gr+/r
do inpause with 4
do apause

hide window sign5
move window sign6 to 14,47
do inpause with 4

hide window sign4
move window sign6 to 13,47
do inpause with 4

hide window sign3
move window sign6 to 12,47
do inpause with 4

hide window sign2
move window sign6 to 11,47
do inpause with 4

hide window sign1
move window sign6 to 10,47
do inpause with 4

hide window sign6
activate window arrow2
@ 0,4 say "Í" color r/bg
@ 0,17 say "Í" color r/bg
for cnt = 9 to 21
	move window arrow2 to cnt,43
endfor
hide window arrow2
**************************
define window sqlwin from 5,10 to 15,70 system 
activate window sqlwin
@ 0,1 say "SELECT SALESMAN.NAME, INVOICES.ITOTAL, CUSTOMER.COMPANY,;"
@ 1,1 say "  CUSTOMER.CONTACT, CUSTOMER.PHONE;"
@ 2,1 say " FROM CUSTOMER, INVOICES, SALESMAN;"
@ 3,1 say " WHERE INVOICES.CNO = CUSTOMER.CNO;"
@ 4,1 say "   AND SALESMAN.ONO = CUSTOMER.ONO;"
@ 5,1 say "   AND INVOICES.ITOTAL > 2500;"
@ 6,1 say " ORDER BY SALESMAN.NAME, INVOICES.ITOTAL DESCENDING;"
@ 7,1 say " INTO CURSOR SAMPLE"
@ 8,1 say "BROWSE NOMODIFY"
do apause
release window sqlwin
**************************
move window arrow2 to 10,0
show window arrow2
for cnt = 0 to 43
	move window arrow2 to 10,cnt
endfor

activate window arrow2
@ 0,4 say "Ñ" color r/bg
@ 0,17 say "Ñ" color r/bg
move window sign6 to 11,47
activate window sign6
do inpause with 4

move window sign1 to 11,47
move window sign6 to 12,47
activate window sign1
do inpause with 4

move window sign2 to 12,47
move window sign6 to 13,47
activate window sign2
@ 0,0 say "  The Action  " color gr+/r
do inpause with 4

move window sign3 to 13,47
move window sign6 to 14,47
activate window sign3
@ 0,0 say "    button    " color gr+/r
do inpause with 4

move window sign4 to 14,47
move window sign6 to 15,47
activate window sign4
@ 0,0 say "  to perform  " color gr+/r
do inpause with 4

move window sign5 to 15,47
move window sign6 to 16,47
activate window sign5
@ 0,0 say "  the query   " color gr+/r
do inpause with 4
do apause

hide window sign5
move window sign6 to 15,47
do inpause with 4

hide window sign4
move window sign6 to 14,47
do inpause with 4

hide window sign3
move window sign6 to 13,47
do inpause with 4

hide window sign2
move window sign6 to 12,47
do inpause with 4

hide window sign1
move window sign6 to 11,47
do inpause with 4

hide window sign6
activate window arrow2
@ 0,4 say "Í" color r/bg
@ 0,17 say "Í" color r/bg
for cnt = 10 to 21
	move window arrow2 to cnt,43
endfor
hide window arrow2
********************************
move window arrow2 to 10,0
show window arrow2
for cnt = 0 to 43
	move window arrow2 to 10,cnt
endfor

activate window arrow2
@ 0,4 say "Ñ" color r/bg
@ 0,17 say "Ñ" color r/bg
move window sign6 to 11,47
activate window sign6
do inpause with 4

move window sign1 to 11,47
move window sign6 to 12,47
activate window sign1
do inpause with 4

move window sign2 to 12,47
move window sign6 to 13,47
activate window sign2
@ 0,0 say "  This query  " color gr+/r
do inpause with 4

move window sign3 to 13,47
move window sign6 to 14,47
activate window sign3
@ 0,0 say "  produces a  " color gr+/r
do inpause with 4

move window sign4 to 14,47
move window sign6 to 15,47
activate window sign4
@ 0,0 say "browse window " color gr+/r
do inpause with 4

move window sign5 to 15,47
move window sign6 to 16,47
activate window sign5
@ 0,0 say "with your data" color gr+/r
do inpause with 4
do apause

hide window sign5
move window sign6 to 15,47
do inpause with 4

hide window sign4
move window sign6 to 14,47
do inpause with 4

hide window sign3
move window sign6 to 13,47
do inpause with 4

hide window sign2
move window sign6 to 12,47
do inpause with 4

hide window sign1
move window sign6 to 11,47
do inpause with 4

hide window sign6
activate window arrow2
@ 0,4 say "Í" color r/bg
@ 0,17 say "Í" color r/bg
for cnt = 10 to 21
	move window arrow2 to cnt,43
endfor
hide window arrow2
********************************
select 0
use sampleq
browse normal preference sampleq nowait
do apause
use

release window rqbescr

activate window menusys
for cnt = 35 to 47 
	move window menusys to 8,cnt
	do inpause with 4
endfor
for cnt = 8 to 15
	move window menusys to cnt,47
	do inpause with 4
endfor
release window menusys
define window menusys from 16,47 to 16,57 none noshadow COLOR SCHEME 12
activate window menusys
@ 0,0 say "RQBE window"
for cnt = 16 to 19
	move window menusys to cnt,47
	do inpause with 4
endfor
do inpause with 40
	
*********************
do overnout
*********************
procedure overnout
set escape off
on escape *
on key label escape *
if wexist("rqbe1")
	release window rqbe1
endif
if wexist("arrow")
	release window arrow
endif
if wexist("arrow2")
	release window arrow2
endif
if wexist("RQBESCR")
	release window rqbescr
endif
if wexist("sign1")
	release window sign1
endif
if wexist("sign2")
	release window sign2
endif
if wexist("sign3")
	release window sign3
endif
if wexist("sign4")
	release window sign4
endif
if wexist("sign5")
	release window sign5
endif
if wexist("sign6")
	release window sign6
endif
if wexist("fakesele")
	release window fakesele
endif
if wexist("seletitl")
	release window seletitl
endif
if wexist("ordetitl")
	release window ordetitl
endif
if wexist("sqlwin")
	release window sqlwin
endif
if wexist("menusys")
	release window menusys
endif
if wexist("fakepop")
	release window fakepop
endif
if wexist("fakedisp")
	release window fakedisp
endif
if wexist("fakeorde")
	release window fakeorde
endif
if wexist("sampleq")
	release window sampleq
endif
if wexist("tempbrow")
	release window tempbrow
endif
for cnt = 1 to 8
	if wexist("letter"+alltrim(str(cnt)))
		release window ("letter"+alltrim(str(cnt)))
	endif
endfor
activate screen
clear
close databases
return to rundemo

procedure escout
clear typeahead
escpress = .t.
do overnout
return

