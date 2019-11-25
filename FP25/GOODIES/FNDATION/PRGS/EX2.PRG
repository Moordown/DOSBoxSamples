*:*********************************************************************
*:
*: Procedure file: C:\EXAMPLE\PRGS\EX2.PRG
*:
*:         System: EX2
*:         Author: Fox Software Systems Group
*:      Copyright (c) 1991, Fox Software, Inc.
*:  Last modified: 05/29/91     11:36
*:
*:  Procs & Fncts: STOPREAD()
*:               : EFFACE
*:               : MYHANDLER()
*:
*:          Calls: EX2.MPR
*:               : MYHANDLER()    (function  in EX2.PRG)
*:
*:      Documented 05/29/91 at 11:39               FoxDoc  version 2.07á
*:*********************************************************************
PUBLIC dropdead, tobedone, menu
SET TALK OFF
PUSH MENU _MSYSMENU
menu = SET("SYSMENU")
SET SYSMENU AUTOMATIC
dropdead = .F.
tobedone=""

DO ex2.mpr

READ VALID myhandler()                           &&	<=== Foundation READ!

SET TALK ON
CLEAR WINDOW ALL
CLOSE DATABASES
POP MENU _MSYSMENU
SET SYSMENU &menu


*!*********************************************************************
*!
*!       Function: MYHANDLER()
*!
*!      Called by: EX2.PRG                       
*!
*!          Calls: EXCUST.SPR
*!               : EXPARTS.SPR
*!               : EXSMAN.SPR
*!               : INV.APP
*!
*!*********************************************************************
FUNCTION myhandler
PRIVATE temp

IF dropdead
	RETURN .T.
ENDIF

IF LEN(tobedone) > 0
	temp = tobedone
	tobedone = ""
	DO (temp)
	RETURN .F.
ENDIF

DO CASE                                   && Handles ALL OTHER cases
CASE WONTOP("cust")                       && WHEN 'Customer' SCREEN foremost
	DO excust.spr
CASE WONTOP("parts")                      && WHEN 'Parts' SCREEN foremost
	DO exparts.spr
CASE WONTOP("sman")                       && WHEN 'Salesman' SCREEN foremost
	DO exsman.spr
CASE WONTOP("inv") ;
	OR WONTOP("control2") ;
	OR WONTOP("Line Items") ;
	OR WONTOP("Part Records")
	 
	IF WLAST("inv") OR WLAST("control2") 
		RETURN .F.
	ENDIF
	*
	*	If any of the windows associated with the INV.APP are
	*	brought forward make sure all of them are visible and
	*	then launch the INV.APP.
	*
	m.x = WCHILD("",0)
	DO WHILE LEN(m.x) > 0
		IF INLIST(m.x, "INV","Line Items","Part Records","CONTROL2")
			SHOW WINDOW (m.x) TOP
		ENDIF
		m.x = WCHILD("",1)
	ENDDO
	DO inv.app
CASE WONTOP("sman")
	DO exsman.spr
CASE WONTOP("control3")
	*
	*	Following code finds the
	*	foremost application window,
	*	then launches the .SPR which
	*	controls that window.  If none
	*	is found, nothing happens.
	*
	*	It is executed when the control
	*	panel is foremost.
	*
	m.temp = ""
	m.x = WCHILD("",0)
	DO WHILE LEN(m.x) > 0
		DO CASE
		CASE m.x = "CUST"
			m.temp = "excust.spr"
		CASE m.x = "PARTS"
			m.temp = "exparts.spr"
		CASE m.x = "SMAN"
			m.temp = "exsman.spr"
		ENDCASE
		m.x = WCHILD("",1)
	ENDDO
	IF LEN(m.temp) > 0
		DO (m.temp)                       && Launch code TO handle foremost
	ENDIF                                 && APPLICATION SCREEN
ENDCASE

RETURN .F.

*!*********************************************************************
*!
*!      Procedure: EFFACE
*!
*!      Called by: EXCUST.SPR                    
*!               : EXPARTS.SPR                   
*!               : EXSMAN.SPR                    
*!
*!*********************************************************************

*  Routine to decide whether or not to release the control panel.
*
*  EFFACE is called when either the 'Quit' button has been pressed
*  or a READ window has been manually closed by clicking in the
*  close box or by selecting 'Close' from the 'File' menu.
*
*  It looks through all the windows that are open, from back to front.
*  If it finds any of the user application windows (which
*  will require the control panel) it simply exits.
*
*  Otherwise, it concludes we're finished with the control panel
*  and releases it.
*
*  The surrounding application insures that WONTOP() is the control panel.

PROCEDURE efface
PRIVATE m.x

m.x = WCHILD("",0)
DO WHILE LEN(m.x) > 0
	IF INLIST(m.x, "CUST","PARTS","SMAN")
		RETURN
	ENDIF
	m.x = WCHILD("",1)
ENDDO
RELEASE WINDOW (WONTOP())

*!*********************************************************************
*!
*!       Function: STOPREAD()
*!
*!      Called by: EXCUST.SPR                    
*!               : EXPARTS.SPR                   
*!               : EXSMAN.SPR                    
*!
*!*********************************************************************

*	Routine executed when the DEACTIVATE clause of one of the
*	application READs is triggered.  If it returns .T., the
*	READ terminates.  Otherwise, it returns .F.
*
*	NOTE:  the value of 'quitting' may have been set to .T. prior to
*	entering this routine if the user pressed the 'Quit' button to
*	terminate the read.

FUNCTION stopread
PARAMETER m.window

IF NOT WVISIBLE(m.window)                        && Did WINDOW GET closed manually?
	SHOW WINDOW control3 TOP                     && Yes, bring control PANEL back
	quitting = .T.                               && AND act AS IF 'Quit' was pressed
ENDIF

RETURN quitting OR NOT WREAD()                   && Stop IF 'quitting', OR
&& if WONTOP() isn't a READ window.
*: EOF: EX2.PRG
