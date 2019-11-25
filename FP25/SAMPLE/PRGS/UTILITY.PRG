*:*********************************************************************
*:
*: Procedure file: C:\ORGANIZE\UTILITY.PRG
*:
*:         System: Organizer Application
*:         Author: Microsoft Corporation
*:      Copyright (c) 1992, Microsoft Corporation
*:  Last modified: 06/01/91     10:50
*:
*:  Procs & Fncts: SETUP
*:               : CLEANUP
*:               : LOCATEDB
*:               : CHECKFPT
*:               : STRIPEXT
*:               : STRIPPATH
*:               : ERRORHANDLER
*:               : CLEARHLP
*:               : CLOSDBFS
*:               : SETCOLORS
*:               : ORG2
*:
*:          Calls: SETCOLORS      (procedure in UTILITY.PRG)
*:
*:    Other Files: ORGHELP.DBF
*:
*:      Documented 06/01/91 at 10:52               FoxDoc  version 2.07á
*:*********************************************************************

*!*********************************************************************
*!
*!      Procedure: SETUP
*!
*!      Called by: IDLEREAD.PRG                  
*!
*!*********************************************************************
PROCEDURE setup
PRIVATE mpath

ON KEY LABEL F1 HELP
CLEAR PROGRAM
CLEAR GETS
IF m.module <> "convert"
	DO setcolors
ENDIF

IF NOT FILE(m.macrosave)
	SAVE MACROS TO (m.macrosave)
ENDIF

CLEAR MACROS

IF WVISIBLE("command")
	HIDE WINDOW "command"
ENDIF

m.area = SELECT()
RELEASE WINDOW 'help'
SET HELP TO "orghelp.dbf"
SET HELP ON
SET UDFPARMS TO VALUE
SET DATE AMERICAN

m.deli = SET("TEXTMERGE",1)
SET TEXTMERGE DELIMITERS TO
m.memow = SET("MEMOWIDTH")
SET MEMOWIDTH TO 256
m.escap = SET("ESCAPE")
m.noti  = SET("NOTIFY")
m.exact = SET("EXACT")
SET EXACT ON
m.safety = SET("SAFETY")
SET SAFETY OFF
m.deci = SET("DECIMALS")
SET DECIMALS TO 18
mdevice = SET("DEVICE")
SET DEVICE TO SCREEN
RETURN

*!*********************************************************************
*!
*!      Procedure: CLEANUP
*!
*!      Called by: IDLEREAD.PRG                  
*!               : ERRORHANDLER   (procedure in UTILITY.PRG)
*!
*!          Calls: CLOSDBFS       (procedure in UTILITY.PRG)
*!
*!    Other Files: M.OLDHELP
*!               : LOCFILE(M.OLDHELP,
*!               : M.OLDRESO
*!               : LOCFILE(M.OLDRESO,
*!
*!*********************************************************************
PROCEDURE cleanup
PRIVATE m.delilen, m.ldelimi, m.rdelimi

IF FILE(m.macrosave)
	RESTORE MACROS FROM (m.macrosave)
	DELETE FILE (m.macrosave)
ENDIF

m.delilen = LEN(m.deli)
m.ldelimi = SUBSTR(m.deli,1,;
	IIF(MOD(m.delilen,2)=0,m.delilen/2,CEILING(m.delilen/2)))
m.rdelimi = SUBSTR(m.deli,;
	IIF(MOD(m.delilen,2)=0,m.delilen/2+1,CEILING(m.delilen/2)+1))
SET TEXTMERGE DELIMITERS TO m.ldelimi, m.rdelimi

SELECT (m.area)
IF m.escap = "ON"
	SET ESCAPE ON
ELSE
	SET ESCAPE OFF
ENDIF
IF m.noti = "ON"
	SET NOTIFY ON
ELSE
	SET NOTIFY OFF
ENDIF
IF m.talkstat = "ON"
	SET TALK ON
ENDIF
IF m.exact = "OFF"
	SET EXACT OFF
ENDIF
IF m.safety = "ON"
	SET SAFETY ON
ENDIF
SET DECIMALS TO m.deci
SET MEMOWIDTH TO m.memow
SET DEVICE TO &mdevice
DO clearhlp

ON KEY LABEL F1
ON ERROR
RETURN

*!*********************************************************************
*!
*!      Procedure: LOCATEDB
*!
*!          Calls: CHECKFPT       (procedure in UTILITY.PRG)
*!
*!*********************************************************************
FUNCTION locatedb
PARAMETER m.dbf, m.fpt
PRIVATE m.where, mpath, m.start, m.end
IF USED(m.dbf)
	SELECT (m.dbf)
	RETURN .T.
ENDIF
IF FILE(m.dbf+".DBF")
	IF NOT checkfpt(m.fpt)
		RETURN .F.
	ENDIF
ELSE
	m.where = GETFILE("DBF", "Where is "+UPPER(m.dbf)+;
		" database?")
	IF EMPTY(m.where)
		RETURN .F.
	ENDIF
	mpath = SET("PATH")
	mpath = mpath + IIF(EMPTY(mpath),"",";") +;
		SUBSTR(m.where,1,RAT("\",m.where))
	SET PATH TO &mpath
	m.start = RAT("\",m.where)+1
	m.end   = RAT(".",m.where)
	IF LOWER(SUBSTR(m.where,m.start,m.end-m.start)) = m.dbf
		IF NOT checkfpt(m.fpt)
			RETURN .F.
		ENDIF
	ELSE
		WAIT WINDOW "Incorrect databases selected" NOWAIT
		RETURN .F.
	ENDIF
ENDIF
RETURN .T.

*!*********************************************************************
*!
*!      Procedure: CHECKFPT
*!
*!      Called by: LOCATEDB       (procedure in UTILITY.PRG)
*!
*!*********************************************************************
FUNCTION checkfpt
PARAMETER m.fpt
IF m.fpt = 0
	SELECT 0
	USE (m.dbf)
	RETURN .T.
ENDIF
IF FILE(m.dbf+".FPT")
	SELECT 0
	USE (m.dbf)
ELSE
	WAIT WINDOW UPPER(m.dbf)+" memo file missing." NOWAIT
	RETURN .F.
ENDIF
RETURN .T.

*!*********************************************************************
*!
*!      Procedure: STRIPEXT
*!
*!      Called by: IDLEREAD.PRG                  
*!
*!*********************************************************************
*
* STRIPEXT - Strip the extension from a file name.
*
* Description:
* Use the algorithm employed by FoxPRO itself to strip a
* file of an extension (if any): Find the rightmost dot in
* the filename.  If this dot occurs to the right of a "\"
* or ":", then treat everything from the dot rightward
* as an extension.  Of course, if we found no dot,
* we just hand back the filename unchanged.
*
* Parameters:
* filename - character string representing a file name
*
* Return value:
* The string "filename" with any extension removed
*
FUNCTION stripext
PARAMETER m.filename
PRIVATE m.dotpos, m.terminator
m.dotpos = RAT(".", m.filename)
m.terminator = MAX(RAT("\", m.filename), RAT(":", m.filename))
IF m.dotpos > m.terminator
	m.filename = LEFT(m.filename, m.dotpos-1)
ENDIF
RETURN m.filename

*!*********************************************************************
*!
*!      Procedure: STRIPPATH
*!
*!      Called by: IDLEREAD.PRG                  
*!
*!*********************************************************************
*
* STRIPPATH - Strip the path from a file name.
*
* Description:
* Find positions of backslash in the name of the file.  If there is one
* take everything to the right of its position and make it the new file
* name.  If there is no slash look for colon.  Again if found, take
* everything to the right of it as the new name.  If neither slash
* nor colon are found then return the name unchanged.
*
* Parameters:
* filename - character string representing a file name
*
* Return value:
* The string "filename" with any path removed
*
FUNCTION strippath
PARAMETER m.filename
PRIVATE m.slashpos, m.namelen, m.colonpos
m.slashpos = RAT("\", m.filename)
IF m.slashpos <> 0
	m.namelen  = LEN(m.filename) - m.slashpos
	m.filename = RIGHT(m.filename, m.namelen)
ELSE
	m.colonpos = RAT(":", m.filename)
	IF m.colonpos <> 0
		m.namelen  = LEN(m.filename) - m.colonpos
		m.filename = RIGHT(m.filename, m.namelen)
	ENDIF
ENDIF
RETURN m.filename

*!*********************************************************************
*!
*!      Procedure: ERRORHANDLER
*!
*!      Called by: IDLEREAD.PRG                  
*!
*!          Calls: CLEARHLP       (procedure in UTILITY.PRG)
*!               : CLEANUP        (procedure in UTILITY.PRG)
*!               : CLOSDBFS       (procedure in UTILITY.PRG)
*!
*!*********************************************************************
PROCEDURE errorhandler
PARAMETER m.messg, m.lineno
PRIVATE m.fromrow, m.fromcol, m.torow, m.tocol

DO CASE 
CASE ERROR() = 216
	*
	* Extended display mode not available.
	*
	WAIT WINDOW "Extended mode not available" NOWAIT
	RETURN
CASE ERROR() = 109
	*
	* Record in use by another.
	*
	WAIT WINDOW "Attempt to LOCK record Aborted" NOWAIT
	m.islocked = .T.
	SHOW GETS
	RETURN
CASE ERROR() = 108
	*
	* File is in use by another.
	* Can also be a result of collision in APPEND BLANK.
	*
	RETRY
CASE ERROR() = 202 AND (WONTOP('labels') OR WONTOP('reports'))
	WAIT WINDOW 'Invalid path or file name' NOWAIT
	RETURN
ENDCASE

m.fromrow = INT((SROW()-6)/2)
m.fromcol = INT((SCOL()-50)/2)
m.torow   = m.fromrow + 6
m.tocol   = m.fromcol + 50

DEFINE WINDOW alert;
	FROM m.fromrow, m.fromcol TO m.torow, m.tocol;
	FLOAT NOGROW NOCLOSE NOZOOM	SHADOW DOUBLE;
	COLOR SCHEME 7

ACTIVATE WINDOW alert

@ 0,0 CLEAR
@ 1,0 SAY PADC(ALLTRIM(m.messg), WCOLS())
IF NOT EMPTY(m.lineno)
	@ 2,0 SAY PADC("Program: "+Program(1)+;
		" Line Number: "+STR(m.lineno, 4), WCOLS())
ENDIF
@ 3,0 SAY PADC("Press any key to cleanup and exit...", WCOLS())
WAIT ""

POP MENU _MSYSMENU

DO clearhlp
DO cleanup
SET COLOR OF SCHEME 1 TO

CLEAR READ ALL
CLEAR WINDOWS
DO closdbfs

ON ERROR
ON ESCAPE
ON KEY LABEL F1
CANCEL
RETURN

*!*********************************************************************
*!
*!      Procedure: CLEARHLP
*!
*!      Called by: ERRORHANDLER   (procedure in UTILITY.PRG)
*!
*!           Uses: OLDHELP.DBF    
*!               : OLDRESO.DBF    
*!
*!    Other Files: LOCFILE(OLDHELP,
*!               : LOCFILE(OLDRESO,
*!
*!*********************************************************************
*
* CLEARHLP
*
PROCEDURE clearhlp
IF NOT EMPTY(m.oldhelp)
	RELEASE WINDOW 'HELP'
	SET HELP TO LOCFILE(m.oldhelp, "DBF", "Where is "+m.oldhelp+" help file?")
	IF m.helpset = "ON"
		SET HELP ON
	ELSE
		SET HELP OFF
	ENDIF
ELSE
	SET HELP OFF
ENDIF
IF NOT EMPTY(m.oldreso)
	SET RESO TO LOCFILE(m.oldreso, "DBF", "Where is "+m.oldreso+" resource file?")
ENDIF
IF m.hidecomm
	SHOW WINDOW "Command"
ENDIF
IF m.resoset = "OFF"
	SET RESOURCE OFF
ELSE
	SET RESOURCE ON
ENDIF
RETURN

*!*********************************************************************
*!
*!      Procedure: CLOSDBFS
*!
*!      Called by: CLEANUP        (procedure in UTILITY.PRG)
*!               : ERRORHANDLER   (procedure in UTILITY.PRG)
*!
*!*********************************************************************
PROCEDURE closdbfs
IF USED('factors')
	SELECT factors
	USE
ENDIF
IF USED('units')
	SELECT units
	USE
ENDIF
IF USED('clients')
	SELECT clients
	USE
ENDIF
IF USED('personal')
	SELECT personal
	USE
ENDIF
IF USED('details')
	SELECT details
	USE
ENDIF
IF USED('reports')
	SELECT reports
	USE
ENDIF
IF USED('restaurs')
	SELECT restaurs
	USE
ENDIF
IF USED('labels')
	SELECT labels
	USE
ENDIF
IF USED('credcard')
	SELECT credcard
	USE
ENDIF
IF USED('carduser')
	SELECT carduser
	USE
ENDIF
IF USED('letters')
	SELECT letters
	USE
ENDIF
IF USED('cards2')
	SELECT cards2
	USE
ENDIF
RETURN

*!*********************************************************************
*!
*!      Procedure: SETCOLORS
*!
*!      Called by: UTILITY.PRG                   
*!
*!*********************************************************************
*
* SETCOLORS - Set background color of controls in COLOR SCHEME 1.
*
* Description:
* In order to make the hot keys on controls appear more distinctly
* change the background color of hot keys to match the
* background color of the enabled controls.
*
PROCEDURE setcolors
PRIVATE m.colors, m.sixth, m.seventh, m.eigth, ;
	m.nineth, pair7, pair9, m.background, m.forground

m.colors = SCHEME(1)

m.sixth  = AT(',',m.colors, 6)
m.seventh= AT(',',m.colors, 7)
m.eigth  = AT(',',m.colors, 8)
m.nineth = AT(',',m.colors, 9)

m.pair7  = SUBSTR(m.colors,m.sixth+1,m.seventh-m.sixth-1)
m.pair9  = SUBSTR(m.colors,m.eigth+1,m.nineth-m.eigth-1)

m.background = SUBSTR(pair9,AT('/',pair9)+1)
m.pair7  = STUFF(pair7,AT('/',pair7)+1,LEN(pair7),"") + m.background

IF pair7 = pair9                                 && i.e., forground colors are same
	m.forground = SUBSTR(pair7,1,AT('/',pair7)-1)
	IF m.forground <> 'W+'
		pair7 = 'W+/'+m.background
	ELSE
		pair7 = 'R+/'+m.background
	ENDIF
ENDIF

SET COLOR OF SCHEME 1 TO ,,,,,,&pair7
RETURN

*: EOF: UTILITY.PRG
