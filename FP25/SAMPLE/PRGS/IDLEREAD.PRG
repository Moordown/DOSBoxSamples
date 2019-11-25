*:*********************************************************************
*:
*: Procedure file: C:\ORGANIZE\IDLEREAD.PRG
*:
*:         System: Organizer Application
*:         Author: Microsoft Corporation
*:      Copyright (c) 1992, Microsoft Corporation
*:  Last modified: 06/01/91     10:51
*:
*:  Procs & Fncts: DOFIRSTAPP()
*:               : IDLELOOP()
*:
*:          Calls: ERRORHANDLER   (procedure in UTILITY.PRG)
*:               : STRIPEXT       (procedure in UTILITY.PRG)
*:               : STRIPPATH      (procedure in UTILITY.PRG)
*:               : SETUP          (procedure in UTILITY.PRG)
*:               : MAINMENU.MPR
*:               : DOFIRSTAPP()   (function  in IDLEREAD.PRG)
*:               : IDLELOOP()     (function  in IDLEREAD.PRG)
*:               : CLEANUP        (procedure in UTILITY.PRG)
*:
*:      Documented 06/01/91 at 10:52               FoxDoc  version 2.07á
*:*********************************************************************
*
* Initialize variable, prepare for environment setup.
*
SET PROCEDURE TO utility
ON ERROR DO errorhandler WITH MESSAGE(), LINENO()
CLEAR PROGRAM
CLEAR GETS

IF SET("TALK") = "ON"
	SET TALK OFF
	m.talkstat = "ON"
ELSE
	m.talkstat = "OFF"
ENDIF

mdevice  = ""
m.area   = 0
m.exact  = ""
m.safety = ""
m.deci   = 0
m.escap  = ""
m.noti   = ""
m.deli   = ""
m.memow  = 0
m.oldhelp = SET("HELP",1)
m.helpset = SET("HELP")
m.resoset = SET("RESOURCE")
m.oldreso = SET("RESOURCE",1)

IF TYPE("m.hidecomm") = "U"
	m.hidecomm = WVISIBLE("command")
ENDIF

m.macrosave = "savmacro.fky"
m.idlequit = .F.
m.module   = LOWER(stripext(strippath(SYS(16))))
m.tobedone = m.module + ".spr"

DO setup

PUSH MENU _msysmenu
RELEASE POPUPS organizer, moneymanag

DO mainmenu.mpr

*
* Launch the GET-LESS READ.
*
READ WHEN dofirstapp() ;
	VALID idleloop()

*
* Cleanup and reset the environment.
*
POP MENU _msysmenu
CLEAR WINDOW ALL

DO cleanup
DO closdbfs
SET COLOR OF SCHEME 1 TO
IF RDLEVEL() = 0
	SET PROCEDURE TO
ENDIF

*!*********************************************************************
*!
*!       Function: DOFIRSTAPP()
*!
*!      Called by: IDLEREAD.PRG                  
*!
*!*********************************************************************
*
* DOFIRSTAPP - Trigger the first application by forcing the FOUNDATION
*				READ to evaluate its VALID clause.
*
FUNCTION dofirstapp
CLEAR READ

*!*********************************************************************
*!
*!       Function: IDLELOOP()
*!
*!      Called by: IDLEREAD.PRG                  
*!
*!*********************************************************************
*
* IDLELOOP - Processing in the idle loop.
*
FUNCTION idleloop
PRIVATE m.temp, m.ontop

IF m.idlequit
	RETURN .T.
ENDIF

IF LEN(m.tobedone) > 0
	m.temp = m.tobedone
	m.tobedone = ""
	DO (m.temp)
	RETURN .F.
ENDIF

m.ontop = LOWER(WONTOP())

DO CASE
CASE m.ontop = "convert"
	DO (m.ontop+".app")
CASE m.ontop = "family" OR m.ontop = "restaurs" OR ;
		m.ontop = "credit" OR m.ontop = "accnts" OR ;
		m.ontop = "trans"
	SHOW WINDOW controls TOP
	IF m.ontop = "accnts"
		SHOW WINDOW 'Details' TOP
	ENDIF
	DO (m.ontop+".spr")
CASE m.ontop = "details" OR m.ontop = "details.service"
	m.temp = "accnts.spr"
	SHOW WINDOW "Details" TOP
	SHOW WINDOW controls TOP
	DO (m.temp)
CASE m.ontop = "controls"
	m.temp = ""
	DO CASE
	CASE WVISIBLE("family")
		m.temp = "family.spr"
	CASE WVISIBLE("restaurs")
		m.temp = "restaurs.spr"
	CASE WVISIBLE("credit")
		m.temp = "credit.spr"
	CASE WVISIBLE("trans")
		m.temp = "trans.spr"
	CASE WVISIBLE("accnts")
		m.temp = "accnts.spr"
		SHOW WINDOW "Details" TOP
	ENDCASE
	IF NOT EMPTY(m.temp)
		SHOW WINDOW controls TOP
		DO (m.temp)
	ENDIF
ENDCASE

RETURN .F.

*: EOF: IDLEREAD.PRG
