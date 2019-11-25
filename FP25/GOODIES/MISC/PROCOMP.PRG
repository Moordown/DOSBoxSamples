*:*****************************************************************************
*:
*:        Program: C:\DOS250\MISC\PROCOMP.PRG
*:         System: FoxPro Application
*:         Author: Wayne Lampel
*:      Copyright (c) 1992, Microsoft Corporation
*:  Last modified: 01/05/93 at 19:24:25
*:
*:      Documented 19:46:06                                FoxDoc version 3.00a
*:*****************************************************************************
SET TALK OFF
x = FOPEN("$files.lst")
IF x<0
   ? "Can't open $FILES.LST"
   RETURN
ENDIF
DO WHILE ! FEOF(x)
   FILE = FGETS(x)
   COMPILE (FILE)
ENDDO
x = FCLOSE(x)
CLOSE ALL
QUIT
*: EOF: PROCOMP.PRG
