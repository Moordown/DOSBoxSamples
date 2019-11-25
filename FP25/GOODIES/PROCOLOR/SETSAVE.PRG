*:*********************************************************************
*:
*: Procedure file: SETSAVE.PRG
*:
*:         System: PROCOLOR
*:         Author: C. Blaise Mitsutama
*:      Copyright (c) 1991-1993, C. Blaise Mitsutama
*:  Last modified: 06/19/91     18:36
*:
*:      Documented 06/21/91 at 10:47               FoxDoc  version 2.10
*:*********************************************************************
PUBLIC _oldsets(15)                         && Array to save old values
IF SET("TALK") = "ON"                       && TALK has to be handled
  SET TALK OFF                                && as a special case.
  _oldsets(15) = "ON"
ELSE
  _oldsets(15) = "OFF"
ENDIF

SET TALK OFF
_oldsets(1)  = SET("BLINK")
_oldsets(2)  = SET("CLEAR")
_oldsets(3)  = SET("CLOCK")
_oldsets(4)  = SET("CONFIRM")
_oldsets(5)  = SET("DEVICE")
_oldsets(6)  = SET("DOHISTORY")
_oldsets(7)  = SET("ECHO")
_oldsets(8)  = SET("ESCAPE")
_oldsets(9)  = SET("RESOURCE")
_oldsets(10)  = SET("SCOREBOARD")
_oldsets(11) = SET("STATUS")
_oldsets(12) = INSMODE()
_oldsets(13) = CAPSLOCK()
_oldsets(14) = NUMLOCK()
SET TALK &_oldsets(15)
RETURN
*: EOF: SETSAVE.PRG
