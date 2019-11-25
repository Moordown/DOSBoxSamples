* APPSHELL is part of the FoxApp system.
* This is a routine to display a list of APP files and prompt
* the user for the one to run.  It does not display the list of 
* files if a file name is passed as a parameter.

PARAMETERS fname
SET TALK OFF
IF PARAMETERS() = 1
   IF FILE(fname)
      DO (fname)
   ELSE
      WAIT WINDOW fname + ' could not be located.' NOWAIT
      RETURN
   ENDIF
ENDIF


