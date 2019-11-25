PARAMETERS fname

filehand = 	fopen(fname)
if filehand = -1
	wait window "Settings could not be restored! File does not exist "+alltrim(fname) timeout 3
	return
endif

DO readit WITH 'set ALTERNATE ',0
DO readit WITH 'set ALTERNATE TO  ',0
DO readit WITH 'set ANSI ',0
DO readit WITH 'set AUTOSAVE ',0
DO readit WITH 'set BELL ',0
DO readit WITH 'set BLINK ',0
DO readit WITH 'set BLOCKSIZE TO ',1
DO readit WITH 'set BRSTATUS ',0
DO readit WITH 'set CARRY ',0
DO readit WITH 'set CENTURY ',0
DO readit WITH 'set CLEAR ',0
DO readit WITH 'set CLOCK ',0
DO readit WITH 'set COMPATIBLE ',0
DO readit WITH 'set CONFIRM ',0
DO readit WITH 'set CONSOLE ',0
DO readit WITH 'set CURRENCY ',0
DO readit WITH 'set CURRENCY TO  ',0
DO readit WITH 'set CURSOR ',0
DO readit WITH 'set DATE ',0
DO readit WITH 'set DEBUG ',0
DO readit WITH 'set DECIMALS TO ',1
DO readit WITH 'set DEFAULT TO ',0
DO readit WITH 'set DELETED ',0
DO readit WITH 'set DELIMITERS ',0
DO readit WITH 'set DEVELOPMENT ',0
DO readit WITH 'set DEVICE TO ',0
DO readit WITH 'set DOHISTORY ',0
DO readit WITH 'set ECHO ',0
DO readit WITH 'set ESCAPE ',0
DO readit WITH 'set EXACT ',0
DO readit WITH 'set EXCLUSIVE ',0
DO readit WITH 'set FIELDS ',0
DO readit WITH 'set FIXED ',0
DO readit WITH 'set FORMAT TO ',0
DO readit WITH 'set FULLPATH ',0
DO readit WITH 'set HEADING ',0
DO readit WITH 'set HOURS TO ',1
DO readit WITH 'set INTENSITY ',0
DO readit WITH 'set LOCK ',0
DO readit WITH 'set LOGERRORS ',0
DO readit WITH 'set MACKEY TO ',0
DO readit WITH 'set MARGIN TO ',1
DO readit WITH 'set MARK TO ',0
DO readit WITH 'set MEMOWIDTH TO ',1
DO readit WITH 'set MESSAGE TO ',1
DO readit WITH 'set MESSAGE TO ',0
DO readit WITH 'set MOUSE ',0
DO readit WITH 'set MOUSE TO ',1
DO readit WITH 'set MULTILOCKS ',0
DO readit WITH 'set NEAR ',0
DO readit WITH 'set NOTIFY ',0
DO readit WITH 'set ODOMETER TO ',1
DO readit WITH 'set OPTIMIZE ',0
DO readit WITH 'set PATH TO ',0
DO readit WITH 'set POINT TO ',0
DO readit WITH 'set PRINTER ',0
DO readit WITH 'set PRINTER TO ',0
DO readit WITH 'set PROCEDURE TO ',0
DO readit WITH 'set REFRESH TO ',1
DO readit WITH 'set REPROCESS TO ',1
DO readit WITH 'set RESOURCE ',0
DO readit WITH 'set RESOURCE TO ',0
DO readit WITH 'set SAFETY ',0
DO readit WITH 'set SCOREBOARD ',0
DO readit WITH 'set SEPARATOR TO ',0
DO readit WITH 'set SHADOWS ',0
DO readit WITH 'set SPACE ',0
DO readit WITH 'set STATUS ',0
DO readit WITH 'set STEP ',0
DO readit WITH 'set STICKY ',0
DO readit WITH 'set SYSMENU ',0
DO readit WITH 'set TALK ',0
DO readit WITH 'set TALK ',0
DO readit WITH 'set TEXTMERGE ',0
DO readit WITH 'set TYPEAHEAD TO ',1
DO readit WITH 'set UDFPARMS TO ',0
DO readit WITH 'set UNIQUE ',0

DO readit WITH 'set HELP ',0

helpfile = alltrim(fgets(filehand))
if not empty(helpfile)
	setting = 'set HELP TO '+helpfile
	&setting
endif

=fclose(filehand)

PROCEDURE readit
PARAMETERS str1,typeread

setting = str1+fgets(filehand)
&setting
RETURN 