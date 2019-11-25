PARAMETERS fname

filehand = 	fcreate(fname)
if filehand = -1
	wait window "Settings could not be saved!" timeout 3
	return
endif

DO writeit WITH 'set("ALTERNATE")'
DO writeit WITH 'set("ALTERNATE",1)'
DO writeit WITH 'set("ANSI")'
DO writeit WITH 'set("AUTOSAVE")'
DO writeit WITH 'set("BELL")'
DO writeit WITH 'set("BLINK")'
DO writeit WITH 'alltrim(str(set("BLOCKSIZE")))'
DO writeit WITH 'set("BRSTATUS")'
DO writeit WITH 'set("CARRY")'
DO writeit WITH 'set("CENTURY")'
DO writeit WITH 'set("CLEAR")'
DO writeit WITH 'set("CLOCK")'
DO writeit WITH 'set("COMPATIBLE")'
DO writeit WITH 'set("CONFIRM")'
DO writeit WITH 'set("CONSOLE")'
DO writeit WITH 'set("CURRENCY")'
DO writeit WITH 'set("CURRENCY",1)'
DO writeit WITH 'set("CURSOR")'
DO writeit WITH 'set("DATE")'
DO writeit WITH 'set("DEBUG")'
DO writeit WITH 'alltrim(str(set("DECIMALS")))'
DO writeit WITH 'set("DEFAULT")'
DO writeit WITH 'set("DELETED")'
DO writeit WITH 'set("DELIMITERS")'
DO writeit WITH 'set("DEVELOPMENT")'
DO writeit WITH 'set("DEVICE")'
DO writeit WITH 'set("DOHISTORY")'
DO writeit WITH 'set("ECHO")'
DO writeit WITH 'set("ESCAPE")'
DO writeit WITH 'set("EXACT")'
DO writeit WITH 'set("EXCLUSIVE")'
DO writeit WITH 'set("FIELDS")'
DO writeit WITH 'set("FIXED")'
DO writeit WITH 'set("FORMAT")'
DO writeit WITH 'set("FULLPATH")'
DO writeit WITH 'set("HEADING")'
DO writeit WITH 'alltrim(str(set("HOURS")))'
DO writeit WITH 'set("INTENSITY")'
DO writeit WITH 'set("LOCK")'
DO writeit WITH 'set("LOGERRORS")'
DO writeit WITH 'set("MACKEY")'
DO writeit WITH 'alltrim(str(set("MARGIN")))'
DO writeit WITH 'set("MARK")'
DO writeit WITH 'alltrim(str(set("MEMOWIDTH")))'
DO writeit WITH 'alltrim(str(set("MESSAGE")))'
DO writeit WITH 'set("MESSAGE",1)'
DO writeit WITH 'set("MOUSE")'
DO writeit WITH 'alltrim(str(set("MOUSE",1)))'
DO writeit WITH 'set("MULTILOCKS")'
DO writeit WITH 'set("NEAR")'
DO writeit WITH 'set("NOTIFY")'
DO writeit WITH 'alltrim(str(set("ODOMETER")))'
DO writeit WITH 'set("OPTIMIZE")'
DO writeit WITH 'set("PATH")'
DO writeit WITH 'set("POINT")'
DO writeit WITH 'set("PRINTER")'
DO writeit WITH 'set("PRINTER",1)'
DO writeit WITH 'set("PROCEDURE")'
DO writeit WITH 'alltrim(str(set("REFRESH")))'
DO writeit WITH 'alltrim(str(set("REPROCESS")))'
DO writeit WITH 'set("RESOURCE")'
DO writeit WITH 'set("RESOURCE",1)'
DO writeit WITH 'set("SAFETY")'
DO writeit WITH 'set("SCOREBOARD")'
DO writeit WITH 'set("SEPARATOR")'
DO writeit WITH 'set("SHADOWS")'
DO writeit WITH 'set("SPACE")'
DO writeit WITH 'set("STATUS")'
DO writeit WITH 'set("STEP")'
DO writeit WITH 'set("STICKY")'
DO writeit WITH 'set("SYSMENU")'
DO writeit WITH 'set("TALK")'
DO writeit WITH 'set("TALK",1)'
DO writeit WITH 'set("TEXTMERGE")'
DO writeit WITH 'alltrim(str(set("TYPEAHEAD")))'
DO writeit WITH 'set("UDFPARMS")'
DO writeit WITH 'set("UNIQUE")'
DO writeit WITH 'set("HELP")'
DO writeit WITH 'set("HELP",1)'

=fclose(filehand)

PROCEDURE writeit
PARAMETERS str1

outerror = fputs(filehand,&str1)
if outerror = 0
	wait window "Settings could not be saved!" timeout 3
	=fclose(filehand)
	delete file (fname)
	return
endif
RETURN 