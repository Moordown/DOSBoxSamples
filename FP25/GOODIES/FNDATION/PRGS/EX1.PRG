*:*********************************************************************
*:
*: Procedure file: C:\DEMO\EXAMPLE\EX1.PRG
*:
*:         System: EX1 - Event Driven Example #1
*:         Author: Fox Software, Engineering Group
*:      Copyright (c) 1991, Fox Holdings, Inc.
*:  Last modified: 05/29/91      0:27
*:
*:  Procs & Fncts: EFFACE
*:               : MYHANDLER()
*:               : STOPREAD
*:
*:          Calls: EX1.MPR
*:               : MYHANDLER()    (function  in EX1.PRG)
*:
*:      Documented 05/29/91 at 00:32               FoxDoc  version 2.07á
*:*********************************************************************
PUBLIC dropdead, tobedone, menu
SET TALK OFF
PUSH MENU _MSYSMENU
menu = SET("SYSMENU")
SET SYSMENU AUTOMATIC
dropdead = .F.
tobedone=""

DO ex1.mpr

READ VALID myhandler()		  &&	<=== Foundation READ!

SET TALK ON
CLEAR WINDOW ALL
CLOSE DATABASES
POP MENU _MSYSMENU
SET SYSMENU &menu


*!*********************************************************************
*!
*!       Function: MYHANDLER()
*!
*!      Called by: EX1.PRG                       
*!
*!          Calls: EXCUST.SPR
*!               : EXPARTS.SPR
*!               : EXINV.SPR
*!               : EXSMAN.SPR
*!
*!
*!*********************************************************************

*   The Foundation READ terminates when this routine returns .T.
*   As long as it returns .F., execution of the Foundation READ will
*   continue

FUNCTION myhandler
PRIVATE m.temp, m.x

IF dropdead
   RETURN .T.				  && Only when 'Exit' is selected
ENDIF						  && from the menu.

IF LEN(tobedone) > 0		  && Launches an SPR which was
   m.temp = tobedone		  && specified from the menu
   tobedone = ""
   DO (m.temp)
   RETURN .F.
ENDIF

DO CASE						  && Handles all other cases
CASE WONTOP("cust")			  && When 'Customer' screen foremost
   DO excust.spr
CASE WONTOP("parts")		  && When 'Parts' screen foremost
   DO exparts.spr
CASE WONTOP("inv")			  && When 'Invoices' screen foremost
   DO exinv.spr
CASE WONTOP("sman")			  && When 'Salesman' screen foremost
   DO exsman.spr
CASE WONTOP("control3")
   *
   *	Following code finds the foremost application window,
   *	then launches the .SPR which controls that window.  If none
   *	is found, nothing happens.
   *
   *	It is executed when the control panel is foremost.
   *
   m.temp = ""
   m.x = WCHILD("",0)
   DO WHILE LEN(m.x) > 0
      DO CASE
      CASE m.x = "CUST"
         m.temp = "excust.spr"
      CASE m.x = "PARTS"
         m.temp = "exparts.spr"
      CASE m.x = "INV"
         m.temp = "exinv.spr"
      CASE m.x = "SMAN"
         m.temp = "exsman.spr"
      ENDCASE
      m.x = WCHILD("",1)
   ENDDO
   IF LEN(m.temp) > 0
      DO (m.temp)			  && Launch code to handle foremost
   ENDIF					  && application screen
ENDCASE

RETURN .F.



*!*********************************************************************
*!
*!      Procedure: EFFACE
*!
*!      Called by: EXCUST.SPR                    
*!               : EXINV.SPR                     
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
   IF INLIST(m.x, "CUST","PARTS","INV","SMAN")
      RETURN
   ENDIF
   m.x = WCHILD("",1)
ENDDO
RELEASE WINDOW (WONTOP())



*!*********************************************************************
*!
*!      Procedure: STOPREAD
*!
*!*********************************************************************

*	Routine executed when the DEACTIVATE clause of one of the
*	application READs is triggered.  If it returns .T., the
*	READ terminates.  Otherwise if it returns .F., the READ
*	continues.
*
*	NOTE:  the value of 'quitting' may have been set to .T. prior to
*	entering this routine if the user pressed the 'Quit' button to
*	terminate the READ.

FUNCTION stopread
PARAMETER m.window

IF NOT WVISIBLE(m.window)			&& Did window get closed manually?
   SHOW WINDOW control3 TOP			&& Yes, bring control panel back
   quitting = .T.					&& and act as if 'Quit' was pressed
ENDIF

RETURN quitting OR NOT WREAD()		&& Stop if 'quitting', or
									&& if WONTOP() isn't a READ window.

*: EOF: EX1.PRG
