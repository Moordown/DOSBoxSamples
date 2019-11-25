*:*****************************************************************************
*:
*:        Program: C:\DOS250\MISC\FOX210.PRG
*:         System: FoxPro Application
*:         Author: Wayne Lampel
*:      Copyright (c) 1992, Microsoft Corporation
*:  Last modified: 06/13/91 at 12:00:00
*:
*:
*:  Procs & Fncts: MYERROR
*:
*:          Calls: MYERROR        (procedure in FOX210.PRG)
*:
*:   Memory Files: FOX210.MEM
*:
*:		Notes:	This program is just for fun.  It's intended 
*:				for those who truly LOVE the dot-prompt and 
*:				does a fair job of emulating the old-style
*:				interface.  To exit this program cleanly,
*:				either type 'QUIT' or 'EXIT' from the "Dot Prompt".
*:				Implementation of the old-style history list
*:				and any other missing features is left as an
*:				exercise for the reader.
*:
*:      Documented 20:09:48                                FoxDoc version 3.00a
*:*****************************************************************************
IF SET('talk') == 'ON'
   SET TALK OFF
   TALK = 'ON'
ELSE
   TALK = 'OFF'
ENDIF

STAT = SET('stat')
SET STATUS ON
RESTORE FROM fox210 ADDITIVE

DEFINE WINDOW desk FROM 0,0 TO 21,79 NONE
ACTIVATE WINDOW desk

RESTORE SCREEN FROM X
SET COLO TO W+/B,W+/B
ON ESCAPE LOOP
ON ERROR DO myerror

DO WHILE .T.
   cmd = SPACE(75)
   @ 21,0 SAY '. '
   @ 21, 2 GET cmd
   READ
   SCROLL 0,0,21,79, 1
   &cmd
ENDDO

ON ERROR
SET COLOR TO
ON ESCAPE
RELEASE WINDOW desk
SET STATUS &stat
SET TALK &talk
RETURN

*!*********************************************************************
*!
*!      Procedure: MYERROR
*!
*!      Called by: FOX210.PRG                    
*!
*!*********************************************************************
PROC myerror
? MESSAGE()
?
RETURN


*: EOF: FOX210.PRG
