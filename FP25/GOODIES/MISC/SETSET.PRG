*:*****************************************************************************
*:
*:        Program: C:\DOS250\MISC\SETSET.PRG
*:         System: FoxPro Application
*:         Author: Wayne Lampel
*:      Copyright (c) 1992, Microsoft Corporation
*:  Last modified: 06/13/91 at 12:00:00
*:
*:
*:			Notes:	This program is the other half of
*:					SETSAVE.PRG.  In actual practice,
*:					you'll only want to save/restore the
*:					specific SET options you are going to
*:					change in your routine.  This is because
*:					this routine works largely by means of
*:					macro substitution and this is comparatively
*:					inefficient.
*:
*:      Documented 20:09:48                                FoxDoc version 3.00a
*:*****************************************************************************
SET AUTOSAVE &_oldsets(1)
SET BELL &_oldsets(2)
SET blink &_oldsets(3)
SET BLOCKSIZE TO &_oldsets(4)
SET CARRY &_oldsets(5)
SET CENTURY &_oldsets(6)
SET CLEAR &_oldsets(7)
SET CLOCK &_oldsets(8)
SET COLOR TO &_oldsets(9)
SET compatible &_oldsets(10)
SET CONFIRM &_oldsets(11)
SET CONSOLE &_oldsets(12)
SET CURRENCY &_oldsets(13)
SET DATE &_oldsets(14)
SET DEBUG &_oldsets(15)
SET DECIMALS TO &_oldsets(16)
SET DEFAULT TO &_oldsets(17)
SET DELETED &_oldsets(18)
SET DELIMITERS &_oldsets(19)
SET DEVELOPMENT &_oldsets(20)
SET DEVICE TO &_oldsets(21)
SET DOHISTORY &_oldsets(22)
SET ECHO &_oldsets(23)
SET ESCAPE &_oldsets(24)
SET EXACT &_oldsets(25)
SET EXCLUSIVE &_oldsets(26)
SET FIELDS &_oldsets(27)
*	SET FILTER TO &_oldsets(28)
SET FIXED &_oldsets(29)
SET FULLPATH &_oldsets(30)
SET HEADING &_oldsets(31)
SET HELP &_oldsets(32)
SET HISTORY &_oldsets(33)
SET HOURS TO &_oldsets(34)
SET INTENSITY &_oldsets(35)
SET MARGIN TO &_oldsets(36)
SET MARK TO &_oldsets(37)
SET MEMOWIDTH TO &_oldsets(38)
SET MENU &_oldsets(39)
SET MESSAGE TO &_oldsets(40)
SET mouse TO &_oldsets(41)
SET NEAR &_oldsets(42)
SET ODOMETER TO &_oldsets(43)
SET PATH TO &_oldsets(44)
SET POINT TO &_oldsets(45)
SET PRINT &_oldsets(46)
SET RESOURCE &_oldsets(47)
SET SAFETY &_oldsets(48)
SET SCOREBOARD &_oldsets(49)
SET SEPARATOR TO &_oldsets(50)
SET SHADOW &_oldsets(51)
SET SPACE &_oldsets(52)
SET STATUS &_oldsets(53)
SET STEP &_oldsets(54)
SET sticky &_oldsets(55)
SET sysmenus &_oldsets(56)
SET TALK &_oldsets(57)
SET TITLE &_oldsets(58)
SET TYPEAHEAD TO &_oldsets(59)
SET UNIQUE &_oldsets(60)
= INSMODE(_oldsets(61))			&& Note usefulness of
= CAPSLOCK(_oldsets(62))		&& '=' evaluate command.
= NUMLOCK(_oldsets(63))

RELEASE _oldsets
RETURN
*: EOF: SETSET.PRG
