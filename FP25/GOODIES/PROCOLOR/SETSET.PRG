*:*********************************************************************
*:
*: Procedure file: SETSET.PRG
*:
*:         System: PROCOLOR
*:         Author: C. Blaise Mitsutama
*:      Copyright (c) 1991-1993, C. Blaise Mitsutama
*:  Last modified: 06/13/91     12:00
*:
*:      Documented 06/21/91 at 10:47               FoxDoc  version 2.10
*:*********************************************************************

SET TALK OFF
SET BLINK      &_oldsets(1)
SET CLEAR      &_oldsets(2)
SET CLOCK      &_oldsets(3)
SET CONFIRM    &_oldsets(4)
SET DEVICE TO  &_oldsets(5)
SET DOHISTORY  &_oldsets(6)
SET ECHO       &_oldsets(7)
SET ESCAPE     &_oldsets(8)
SET RESOURCE   &_oldsets(9)
SET SCOREBOARD &_oldsets(10)
SET STATUS     &_oldsets(11)
= INSMODE(_oldsets(12))
= CAPSLOCK(_oldsets(13))
= NUMLOCK(_oldsets(14))
SET TALK &_oldsets(15)
RETURN

*: EOF: SETSAVE.PRG
