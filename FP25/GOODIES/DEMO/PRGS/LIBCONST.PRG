on key label escape do escout
on escape do escout
set escape on
clear typeahead
set blink off
do bigchars with 4,1," API/Library|Construction|     Kit"
do apause
for cnt = 1 to 42
	release window ("letter"+alltrim(str(cnt)))
endfor
set blink on
set sysmenu automatic

DEFINE WINDOW marque1 from 18,5 to 22,74 DOUBLE COLOR SCHEME 12;
	TITLE " FoxPro 2.5 - API/Library Construction Kit" SHADOW
ACTIVATE WINDOW marque1
@ 0,1 say "FoxPro's Application Programmer's Interface (API) allows users and"          
@ 1,1 say "programmers to extend the FoxPro system in nearly any conceivable"
@ 2,1 say "direction."
do apause
clear
@ 0,1 say "Program execution can pass from FoxPro code to both C routines and"          
@ 1,1 say "assembly language routines."
do apause

define window foxwin from 7,10 to 11,24 none 
activate window foxwin
@ 0,0 to 4,14 double color gr+/b
@ 1,1 say "   FoxPro"
@ 2,1 say " Application"

define window assemwin from 11,54 to 16,65 none 
activate window assemwin
@ 0,0 to 5,11 double
@ 1,1 say " Assembly"
@ 2,1 say " Language"
@ 3,1 say " Routine"

define window cwin from 2,54 to 6,66 none 
activate window cwin
@ 0,0 to 4,10 double
@ 1,1 say "    C    "
@ 2,1 say " Routine "

define window ball1 from 10,11 to 10,11 none
activate window ball1
@ 0,0 say "|"
for cnt = 1 to 12
	do spinball with 1
	move window ball1 by 0,1
endfor
for cnt = 1 to 12
	do spinball with 1
	move window ball1 by 0,-1
endfor
for cnt = 1 to 12
	do spinball with 1
	move window ball1 by 0,1
endfor
do spinball with 1
move window ball1 by 0,2
activate window foxwin
@ 0,0 to 4,14 double

for cnt = 25 to 40
	do spinball with 0
	move window ball1 to 10,cnt
endfor
for cnt = 10 to 5 step -1
	do spinball with 0
	move window ball1 to cnt,40
endfor
for cnt = 40 to 53
	do spinball with 0
	move window ball1 to 5,cnt
endfor
move window ball1 to 5,55
activate window cwin
@ 0,0 to 4,10 double color gr+/b
for cnt = 1 to 8
	do spinball with 1
	move window ball1 by 0,1
endfor
for cnt = 1 to 8
	do spinball with 1
	move window ball1 by 0,-1
endfor
for cnt = 1 to 8
	do spinball with 1
	move window ball1 by 0,1
endfor
for cnt = 1 to 8
	do spinball with 1
	move window ball1 by 0,-1
endfor
do spinball with 1
move window ball1 by 0,-2
activate window cwin
@ 0,0 to 4,10 double
for cnt = 53 to 40 step -1
	do spinball with 0
	move window ball1 to 5,cnt
endfor
for cnt = 5 to 10
	do spinball with 0
	move window ball1 to cnt,40
endfor
for cnt = 40 to 25 step -1
	do spinball with 0
	move window ball1 to 10,cnt
endfor
move window ball1 to 10,23
activate window foxwin
@ 0,0 to 4,14 double color gr+/b
for cnt = 1 to 12
	do spinball with 1
	move window ball1 by 0,-1
endfor
for cnt = 1 to 12
	do spinball with 1
	move window ball1 by 0,1
endfor
do spinball with 1
move window ball1 by 0,2
activate window foxwin
@ 0,0 to 4,14 double

for cnt = 25 to 40
	do spinball with 0
	move window ball1 to 10,cnt
endfor
for cnt = 10 to 15
	do spinball with 0
	move window ball1 to cnt,40
endfor
for cnt = 40 to 53
	do spinball with 0
	move window ball1 to 15,cnt
endfor
move window ball1 to 15,55
activate window assemwin
@ 0,0 to 5,11 double color gr+/b
for cnt = 1 to 9
	do spinball with 1
	move window ball1 by 0,1
endfor
for cnt = 1 to 9
	do spinball with 1
	move window ball1 by 0,-1
endfor
for cnt = 1 to 9
	do spinball with 1
	move window ball1 by 0,1
endfor
for cnt = 1 to 9
	do spinball with 1
	move window ball1 by 0,-1
endfor
do spinball with 1
move window ball1 by 0,-2
activate window assemwin
@ 0,0 to 5,11 double
for cnt = 53 to 40 step -1
	do spinball with 0
	move window ball1 to 15,cnt
endfor
for cnt = 15 to 10 step -1
	do spinball with 0
	move window ball1 to cnt,40
endfor
for cnt = 40 to 25 step -1
	do spinball with 0
	move window ball1 to 10,cnt
endfor
move window ball1 to 10,23
activate window foxwin
@ 0,0 to 4,14 double color gr+/b
for cnt = 1 to 12
	do spinball with 1
	move window ball1 by 0,-1
endfor
for cnt = 1 to 12
	do spinball with 1
	move window ball1 by 0,1
endfor

release window cwin
release window assemwin
release window foxwin
release window ball1


activate window marque1
clear
@ 0,1 say "The API integrates C and assembly language routines into a library"          
@ 1,1 say "that can be used by any FoxPro application."
do apause
clear
@ 0,1 say "FoxPro's Library Construction Kit allows developers to build these"
@ 1,1 say "external libraries."
do apause
	
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
if wexist("foxwin")
	release window foxwin
endif
if wexist("cwin")
	release window cwin
endif
if wexist("assemwin")
	release window assemwin
endif
if wexist("ball1")
	release window ball1
endif
for cnt = 1 to 100
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

procedure spinball
parameter pauswit
activate window ball1
@ 0,0 say "/"
if pauswit = 1
	do inpause with 1
endif
@ 0,0 say "Ä"
if pauswit = 1
	do inpause with 1
endif
@ 0,0 say "\"
if pauswit = 1
	do inpause with 1
endif
@ 0,0 say "|"
if pauswit = 1
	do inpause with 1
endif
@ 0,0 say "/"
if pauswit = 1
	do inpause with 1
endif
@ 0,0 say "Ä"
if pauswit = 1
	do inpause with 1
endif
@ 0,0 say "\"
if pauswit = 1
	do inpause with 1
endif
@ 0,0 say "|"
return