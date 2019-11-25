on key label escape do escout
on escape do escout
set escape on
clear typeahead
set blink off
do bigchars with 6,4,"Distribution|     Kit"
do apause
for cnt = 1 to 21
	release window ("letter"+alltrim(str(cnt)))
endfor
set blink on
set sysmenu automatic

DEFINE WINDOW marque1 from 18,3 to 21,76 DOUBLE COLOR SCHEME 12;
	TITLE " FoxPro 2.5 - Distribution Kit" SHADOW
ACTIVATE WINDOW marque1
@ 0,1 say "FoxPro's Distribution Kit allows developers to distribute applications"          
@ 1,1 say "to end users and clients.  Multiple packaging options include:"
do apause

*
* Move Distribution Kit text from marque to center of the screen.
*

define window menusys from 19,14 to 19,29 none noshadow COLOR SCHEME 12
@ 0,10 say "Distribution Kit" color w+/r
activate window menusys
@ 0,0 say "Distribution Kit"
move window menusys to 18,14
do inpause with 4
release window menusys
define window menusys from 17,14 to 17,29 none noshadow
activate window menusys
@ 0,0 say "Distribution Kit"  COLOR GR+/B
for cnt = 17 to 8 step -1
	move window menusys to cnt,14
	do inpause with 4
endfor
for cnt = 14 to 30
	move window menusys to 8,cnt
	do inpause with 4
endfor
do inpause with 100
hide window marque1
hide window menusys
hide window botmess
DEFINE WINDOW tradrt ;
	FROM 24,5 ;
	TO 42,24 ;
	NOFLOAT ;
	NOCLOSE ;
	NONE ;
	COLOR SCHEME 1

ACTIVATE WINDOW tradrt NOSHOW
@ 0,2 TO 4,17 DOUBLE
@ 4,0 TO 5,19
@ 5,5 TO 18,14
@ 5,7 TO 18,12
@ 5,9 TO 18,10
@ 5,9 SAY "ย"
@ 18,9 SAY "ม"
@ 5,10 SAY "ย"
@ 18,10 SAY "ม"
@ 5,7 SAY "ย"
@ 18,7 SAY "ม"
@ 5,12 SAY "ย"
@ 18,12 SAY "ม"
@ 5,5 SAY "ย"
@ 5,14 SAY "ย"
@ 4,2 SAY "ะ"
@ 4,17 SAY "ะ"
@ 4,2 SAY "ศออออออออออออออผ"
@ 1,3 say  " Traditional " color gr+/b
@ 2,3 say  "   Runtime   " color gr+/b
activate WINDOW tradrt
for cnt = 24 to 10 step -1
	move window tradrt to cnt,5
	do inpause with 4
endfor
do apause


DEFINE WINDOW tradrt3 ;
	FROM 24,53 ;
	TO 42,72 ;
	NOFLOAT ;
	NOCLOSE ;
	NONE ;
	COLOR SCHEME 1

ACTIVATE WINDOW tradrt3 NOSHOW
@ 0,2 TO 4,17 DOUBLE
@ 4,0 TO 5,19
@ 5,5 TO 18,14
@ 5,7 TO 18,12
@ 5,9 TO 18,10
@ 5,9 SAY "ย"
@ 18,9 SAY "ม"
@ 5,10 SAY "ย"
@ 18,10 SAY "ม"
@ 5,7 SAY "ย"
@ 18,7 SAY "ม"
@ 5,12 SAY "ย"
@ 18,12 SAY "ม"
@ 5,5 SAY "ย"
@ 5,14 SAY "ย"
@ 4,2 SAY "ะ"
@ 4,17 SAY "ะ"
@ 4,2 SAY "ศออออออออออออออผ"
@ 1,3 say  "   Compact   " color gr+/b
@ 2,3 say  "    .EXE     " color gr+/b
@ 3,3 say  " Executables " color gr+/b
activate WINDOW tradrt3
for cnt = 24 to 10 step -1
	move window tradrt3 to cnt,53
	do inpause with 4
endfor
do apause

DEFINE WINDOW tradrt2 ;
	FROM 24,29 ;
	TO 48,48 ;
	NOFLOAT ;
	NOCLOSE ;
	NONE ;
	COLOR SCHEME 1

ACTIVATE WINDOW tradrt2 NOSHOW
@ 0,2 TO 4,17 DOUBLE
@ 4,0 TO 5,19
@ 5,5 TO 24,14
@ 5,7 TO 24,12
@ 5,9 TO 24,10
@ 5,9 SAY "ย"
@ 24,9 SAY "ม"
@ 5,10 SAY "ย"
@ 24,10 SAY "ม"
@ 5,7 SAY "ย"
@ 24,7 SAY "ม"
@ 5,12 SAY "ย"
@ 24,12 SAY "ม"
@ 5,5 SAY "ย"
@ 5,14 SAY "ย"
@ 4,2 SAY "ะ"
@ 4,17 SAY "ะ"
@ 4,2 SAY "ศออออออออออออออผ"
@ 1,3 say  "Free Standing " color gr+/b
@ 2,3 say  "    .EXE      " color gr+/b
@ 3,3 say  " Executables " color gr+/b
activate WINDOW tradrt2
for cnt = 24 to 2 step -1
	move window tradrt2 to cnt,29
	do inpause with 4
endfor
do apause
@ 4,0 SAY "  ศออออออออออออออผ  "
@ 5,0 clear to 24,19
do inpause with 100
activate window marque1
@ 0,1 say "All of these packaging options are completely royalty free!  There is "
@ 1,1 say "no need to pay Fox Software royalties or account for sales in any way."
do apause

release window tradrt
release window tradrt2
release window tradrt3
release window marque1
release window menusys
show window botmess	
*********************
do overnout
*********************
procedure overnout
set escape off
on escape *
on key label escape *
if wexist("marque1")
	release window marque1
endif
if wexist("menusys")
	release window menusys
endif
if wexist("tradrt")
	release window tradrt
endif
if wexist("tradrt2")
	release window tradrt2
endif
if wexist("tradrt3")
	release window tradrt3
endif
for cnt = 1 to 21
	if wexist("letter"+alltrim(str(cnt)))
		release window ("letter"+alltrim(str(cnt)))
	endif
endfor
activate screen
clear
close databases
return to rundemo

procedure escout
escpress = .t.
do overnout
return
