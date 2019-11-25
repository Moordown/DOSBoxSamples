on key label escape do escout
set escape on
on escape do escout
set sysmenu to default
set sysmenu automatic
set blink off
do bigchars with 8,2,"Trace/Debug"
do apause
for cnt = 1 to 11
	release window ("letter"+alltrim(str(cnt)))
endfor
set blink on

DEFINE WINDOW marque1 from 18,7 to 21,74 DOUBLE COLOR SCHEME 12;
	TITLE " FoxPro 2.5 - Trace & Debug" SHADOW
ACTIVATE WINDOW marque1
@ 0,1 say "FoxPro's Trace window allows you to watch program code as it"          
@ 1,1 say "executes."
do apause

*
* Move Trace window text from marque to center of the screen.
*

define window menusys from 19,18 to 19,29 none noshadow COLOR SCHEME 12
@ 0,10 say "Trace window" color w+/r
activate window menusys
@ 0,0 say "Trace window"
move window menusys to 18,18
do inpause with 4
release window menusys
define window menusys from 17,18 to 17,29 none noshadow
activate window menusys
@ 0,0 say "Trace window"  COLOR GR+/B
for cnt = 17 to 8 step -1
	move window menusys to cnt,18
	do inpause with 4
endfor
for cnt = 18 to 35
	move window menusys to 8,cnt
	do inpause with 4
endfor

if file('temptrac.prg')
	delete file temptrac.prg
endif
* copy program out of application so it can be traced
copy file dotrace.prg to temptrac.prg

* fake out project manager so there is no reference to a program 
* that didn't exist a project build time

on key label escape *
on escape *
set escape off
afilename = "temptrac"
do (afilename) with 0
on escape do escout
set escape on
on key label escape do escout

*
* Move Trace window text from the center of the screen back into  
* marque text.
*
activate window menusys
for cnt = 35 to 18 step -1
	move window menusys to 8,cnt
	do inpause with 4
endfor
for cnt = 8 to 17
	move window menusys to cnt,18
	do inpause with 4
endfor
release window menusys
define window menusys from 18,18 to 18,29 none noshadow COLOR SCHEME 12
activate window menusys
@ 0,0 say "Trace window"
move window menusys to 19,18
do inpause with 40

activate window marque1
clear
@ 0,1 say "The Debug window allows you to monitor the values of variables"
@ 1,1 say "and expressions while your program is executing."
do apause

define window menusys from 19,13 to 19,24 none noshadow COLOR SCHEME 12
@ 0,5 say "Debug window" color w+/r
activate window menusys
@ 0,0 say "Debug window"
move window menusys to 18,13
do inpause with 4
release window menusys
define window menusys from 17,13 to 17,24 none noshadow
activate window menusys
@ 0,0 say "Debug window"  COLOR GR+/B
for cnt = 17 to 8 step -1
	move window menusys to cnt,13
	do inpause with 4
endfor
for cnt = 13 to 35
	move window menusys to 8,cnt
	do inpause with 4
endfor

on key label escape *
on escape *
set escape off
afilename = "temptrac"
do (afilename) with 1
on escape do escout
set escape on
on key label escape do escout

delete file temptrac.prg
delete file temptrac.fxp	
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
if wexist("laserm")
	release window laserm
endif
for cnt = 1 to 11
	if wexist("letter"+alltrim(str(cnt)))
		release window ("letter"+alltrim(str(cnt)))
	endif
endfor
set sysmenu off
set sysmenu to default
activate screen
clear

* Fake out topics screen to think some other key has been 
* pressed (other than the last key of the macro just played)
keyboard "x"
= inkey()

return to rundemo

procedure escout
if file('temptrac.prg')
	delete file temptrac.prg
endif
if file('temptrac.fxp')
	delete file temptrac.fxp	
endif
escpress = .t.
do overnout
return
