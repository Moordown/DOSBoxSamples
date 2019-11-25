*:*****************************************************************************
*:
*:        Program: C:\DOS250\MISC\SETSAVE.PRG
*:         System: FoxPro Application
*:         Author: Wayne Lampel
*:      Copyright (c) 1992, Microsoft Corporation
*:  Last modified: 06/13/91 at 12:00:00
*:
*:
*:			Notes:	This routine illustrates how the values
*:					of all the FoxPro SET options can be
*:					saved in an array.  Notice the special
*:					treatment necessary for the TALK option.
*:					Program SETSET.PRG restores the original
*:					status of the system.  This is useful if
*:					you're trying to write a generally applicable
*:					UDF where it's desirable to preserve the
*:					original SET options.  Of course, you
*:					actually need to save/restore only the
*:					SET options which you change in your routine
*:
*:      Documented 20:09:48                                FoxDoc version 3.00a
*:*****************************************************************************
PUBLIC _oldsets(64)			&& Array to save old values
IF SET("TALK") = "ON"		&& TALK has to be handled
   SET TALK OFF				&& as a special case.
   _oldsets(57) = "ON"
ELSE
   _oldsets(57) = "OFF"
ENDIF
SET TALK OFF
_oldsets(1) = SET("AUTOSAVE")
_oldsets(2) = SET("BELL")
_oldsets(3) = SET("BLINK")
_oldsets(4) = STR(SET("BLOCKSIZE"))
_oldsets(5) = SET("CARRY")
_oldsets(6) = SET("CENTURY")
_oldsets(7) = SET("CLEAR")
_oldsets(8) = SET("CLOCK")
_oldsets(9) = SET("COLOR")
_oldsets(10) = SET("COMPATIBLE")
_oldsets(11) = SET("CONFIRM")
_oldsets(12) = SET("CONSOLE")
_oldsets(13) = SET("CURRENCY")
_oldsets(14) = SET("DATE")
_oldsets(15) = SET("DEBUG")
_oldsets(16) = STR(SET("DECIMALS"))
_oldsets(17) = SET("DEFAULT")
_oldsets(18) = SET("DELETED")
_oldsets(19) = SET("DELIMITERS")
_oldsets(20) = SET("DEVELOPMENT")
_oldsets(21) = SET("DEVICE")
_oldsets(22) = SET("DOHISTORY")
_oldsets(23) = SET("ECHO")
_oldsets(24) = SET("ESCAPE")
_oldsets(25) = SET("EXACT")
_oldsets(26) = SET("EXCLUSIVE")
_oldsets(27) = SET("FIELDS")
*	_oldsets(28) = SET("FILTER")
_oldsets(29) = SET("FIXED")
_oldsets(30) = SET("FULLPATH")
_oldsets(31) = SET("HEADING")
_oldsets(32) = SET("HELP")
_oldsets(33) = SET("HISTORY")
_oldsets(34) = STR(SET("HOURS"))
_oldsets(35) = SET("INTENSITY")
_oldsets(36) = STR(SET("MARGIN"))
_oldsets(37) = SET("MARK")
_oldsets(38) = STR(SET("MEMOWIDTH"))
_oldsets(39) = SET("MENU")
_oldsets(40) = SET("MESSAGE")
_oldsets(41) = STR(SET("MOUSE",1))
_oldsets(42) = SET("NEAR")
_oldsets(43) = STR(SET("ODOMETER"))
_oldsets(44) = SET("PATH")
_oldsets(45) = SET("POINT")
_oldsets(46) = SET("PRINT")
_oldsets(47) = SET("RESOURCE")
_oldsets(48) = SET("SAFETY")
_oldsets(49) = SET("SCOREBOARD")
_oldsets(50) = SET("SEPARATOR")
_oldsets(51) = SET("SHADOW")
_oldsets(52) = SET("SPACE")
_oldsets(53) = SET("STATUS")
_oldsets(54) = SET("STEP")
_oldsets(55) = SET("STICKY")
_oldsets(56) = SET("SYSMENUS")
_oldsets(58) = SET("TITLE")
_oldsets(59) = STR(SET("TYPEAHEAD"))
_oldsets(60) = SET("UNIQUE")
_oldsets(61) = INSMODE()
_oldsets(62) = CAPSLOCK()
_oldsets(63) = NUMLOCK()
SET TALK &_oldsets(57)
RETURN
*: EOF: SETSAVE.PRG
