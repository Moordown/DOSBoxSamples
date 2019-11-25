*:*****************************************************************************
*:
*:        Program: C:\DOS250\MISC\DBLCLICK.PRG
*:         System: FoxPro Application
*:         Author: Wayne Lampel
*:      Copyright (c) 1992, Microsoft Corporation
*:  Last modified: 06/13/91 at 12:00:00
*:
*:      Documented 20:09:48                                FoxDoc version 3.00a
*:*****************************************************************************
SET TALK OFF
SET ESCAPE ON
CLEAR
x = 0
DO WHILE .T.				&& Exit by pressing Esc
   x = INKEY("MH")			&& INKEY detecting mouse-downs, no cursor
   IF x=0					&& Nothing there,  try again.
      LOOP
   ENDIF
   IF x = 27				&& Exit if it's Esc.
      EXIT
   ENDIF
   IF x = 151				&& It's a mouse-down
      ROW = MROW()			&& Record row/column immediately
      COL = MCOL()
      timelimit = SECONDS()+_DBLCLICK	&& Note: New system variable
      y = 0
      DO WHILE SECONDS() < timelimit
         y = INKEY("MH")
         IF y = 151			&& Another click was just seen.
            @ 10,10 SAY "Double click at"
            EXIT
         ENDIF
      ENDDO
      IF y = 0				&& Here, if no further clicks seen.
         @ 10,10 SAY "Single click at"
      ENDIF
      ?? ROW, COL
   ENDIF
   IF x # 151				&& Here, if it wasn't a mouse-down
      @ 10,10 SAY "Character typed: "
      ?? "'"+CHR(x)+"'", TRANSFORM(x, "(999)"), SPACE(10)
   ENDIF
ENDDO
SET TALK ON
SET ESCAPE ON
*: EOF: DBLCLICK.PRG
