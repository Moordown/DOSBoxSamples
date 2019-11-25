*!*****************************************************************
*!
*!      Procedure: INVERT
*!
*!*****************************************************************
PROCEDURE invert
* Invert (i.e., index on all fields) the "filname" database

PARAMETERS filname
PRIVATE comp_stat, safe_stat, in_area, fstem, i

comp_stat = SET("COMPATIBLE")
safe_stat = SET("SAFETY")
SET COMPATIBLE TO FOXPLUS
SET SAFETY OFF

m.in_area = SELECT()          && currently selected area

m.fstem = juststem(m.filname)
IF USED(m.fstem)
   SELECT (m.fstem)
ELSE
   SELECT 0
   USE (m.filname)
ENDIF


FOR i = 1 TO FCOUNT()
   fldname = FIELD(i)
   IF !INLIST(TYPE(m.fldname),"M","G","P")
      WAIT WINDOW "Indexing on "+m.fldname NOWAIT
      INDEX ON &fldname TAG (m.fldname)
   ENDIF
ENDFOR

IF m.in_area <> SELECT()
   USE
ENDIF
SELECT (m.in_area)
IF m.comp_stat = "ON" OR m.comp_stat = "DB4"
   SET COMPATIBLE TO DB4
ENDIF
IF m.safe_stat = "ON"
   SET SAFETY ON
ENDIF
RETURN


*!*****************************************************************
*!
*!      Procedure: OPENDBF
*!
*!*****************************************************************
FUNCTION opendbf
* Open a database and return the alias name, or an empty string
*   if the database could not be opened.  Prompt user to find 
*   database if necessary
PARAMETERS fname
PRIVATE stem
IF FILE(m.fname)
   m.stem = juststem(m.fname)
   IF USED(m.stem)
      SELECT (m.stem)
   ELSE
      SELECT 0
      m.fname = LOCFILE(m.fname,'DBF',;
         'Please locate the '+juststem(m.fname)+' database')
      IF EMPTY(m.fname)
         RETURN ''
      ELSE
         USE (m.fname)
      ENDIF
   ENDIF
   RETURN ALIAS()
ELSE
   RETURN ''
ENDIF

*!*****************************************************************
*!
*!      Procedure: ACTWIN
*!
*!*****************************************************************
FUNCTION actwin
* Activate window wind_name

parameter wind_name
PRIVATE ALL
wind_name = UPPER(ALLTRIM(m.wind_name))
IF !EMPTY(m.wind_name) AND WEXIST(m.wind_name)
   ACTIVATE WINDOW (m.wind_name)
ENDIF
RETURN ''


*!*****************************************************************
*!
*!      Procedure: ALERT
*!
*!*****************************************************************
PROCEDURE alert
* Display an error message, automatically sizing the message window
*    as necessary.  Semicolons in "strg" mean "new line".
PARAMETERS strg
PRIVATE in_talk, in_cons, numlines, i, remain, maxlen, keycode

in_talk = SET('TALK')
SET TALK OFF
in_cons = SET('CONSOLE')

m.numlines = OCCURS(';',m.strg) + 1

DIMENSION alert_arry[m.numlines]
m.remain = m.strg
m.maxlen = 0
FOR i = 1 TO m.numlines
   IF AT(';',m.remain) > 0
      alert_arry[i] = SUBSTR(m.remain,1,AT(';',m.remain)-1)
      alert_arry[i] = CHRTRAN(alert_arry[i],';','')
      m.remain = SUBSTR(m.remain,AT(';',m.remain)+1)
   ELSE
      alert_arry[i] = m.remain
      m.remain = ''
   ENDIF
   IF LEN(alert_arry[i]) > SCOLS() - 6
      alert_arry[i] = SUBSTR(alert_arry[i],1,SCOLS()-6)
   ENDIF
   IF LEN(alert_arry[i]) > m.maxlen
      m.maxlen = LEN(alert_arry[i])
   ENDIF
ENDFOR

m.top_row = INT( (SROWS() - 4 - m.numlines) / 2)
m.bot_row = m.top_row + 3 + m.numlines

m.top_col = INT((SCOLS() - m.maxlen - 6) / 2)
m.bot_col = m.top_col + m.maxlen + 6

DEFINE WINDOW alert FROM m.top_row,m.top_col TO m.bot_row,m.bot_col;
   DOUBLE COLOR SCHEME 7
ACTIVATE WINDOW alert

FOR i = 1 TO m.numlines
   @ i,3 SAY PADC(alert_arry[i],m.maxlen)
ENDFOR

SET CONSOLE OFF
keycode = 0
DO WHILE m.keycode = 0
   keycode = INKEY(0,'HM')
ENDDO
SET CONSOLE ON

RELEASE WINDOW alert

IF m.in_talk = "ON"
   SET TALK ON
ENDIF
IF m.in_cons = "OFF"
   SET CONSOLE OFF
ENDIF


*!*****************************************************************
*!
*!      Procedure: APPERROR
*!
*!*****************************************************************
PROCEDURE apperror
* Simple ON ERROR routine for FoxApp application

PARAMETERS e_program,e_message,e_source,e_lineno,e_error
CLEAR TYPEAHEAD

DO CASE
CASE e_error = 217     && invalid display mode
   SET CURSOR OFF
   WAIT WINDOW "That display mode is not available on your computer."
   SET CURSOR ON
   RETURN
CASE e_error = 1707    && CDX not found.  Ignore it.
   RETURN
OTHERWISE

   ON ERROR
   m.e_source = ALLTRIM(m.e_source)
   DO alert WITH 'Line No.: '+ALLTRIM(STR(m.e_lineno,5))+';' ;
      +'Program: '+m.e_program +';' ;
      +'  Error: '+m.e_message +';' ;
      +' Source: '+IIF(LEN(m.e_source)<50,;
      m.e_source,SUBSTR(m.e_source,1,50)+'...')
   ON KEY
   CLOSE ALL
   CLEAR PROGRAM
   CLEAR WINDOW
   SET SYSMENU TO DEFAULT
   IF FILE("foxapp.fky")
      RESTORE MACROS FROM foxapp.fky
      DELETE FILE foxapp.fky
   ENDIF
   * Restore original error routine if possible
   IF TYPE('fxapp_error') = 'C'
      ON ERROR &fxapp_error
   ENDIF

   CANCEL
ENDCASE
RETURN

*!*****************************************************************
*!
*!      Procedure: SHOWPOP
*!
*!*****************************************************************
PROCEDURE showpop
* Determine if a popup can be displayed for this field
PARAMETERS sourcedbf, varname

PRIVATE sourcedbf, targetdbf, varname, i, retval

* varname is in Proper case coming from BROWSE
varname = UPPER(ALLTRIM(m.varname))

* See if any databases are keyed on varname
m.targetdbf = 0
FOR i = 1 TO m.numareas
   IF SUBSTR(dbflist[i,m.cfldnum],AT('.',dbflist[i,m.cfldnum])+1);
         == m.varname
      m.targetdbf = i
   ENDIF
ENDFOR

* Make sure we can display list
DO CASE
CASE m.targetdbf = 0
   WAIT WINDOW "No pick list is available for ";
      +PROPER(m.varname)+'.' NOWAIT
   retval = "NULL"
CASE dbflist[m.targetdbf,m.cstemnum] = m.sourcedbf
   * The target database is the one we are in!

   * Show the popup, but don't allow any replacements.
   =disppop(dbflist[m.targetdbf,m.cdbfnum], m.varname)
   retval = "NULL"
OTHERWISE
   retval = disppop(dbflist[m.targetdbf,m.cdbfnum], m.varname)
ENDCASE

* Replace the selected value into the current field
IF TYPE("retval") = "C"
   IF retval <> "NULL"
      REPLACE &varname WITH retval
   ENDIF
ELSE
   REPLACE &varname WITH retval
ENDIF

RETURN
*!*****************************************************************
*!
*!      Procedure: DISPPOP
*!
*!*****************************************************************
FUNCTION disppop
* Display a scrollable list of items in the popdbf database
PARAMETERS popdbf, varname
PRIVATE ALL

* Store the value that varname has in the current database
varnameval = &varname

in_area = SELECT()
SELECT 0
USE (popdbf) AGAIN

* Make sure it has a TAG of varname
i = 1
tag_found = .F.
DO WHILE !EMPTY(TAG(i)) AND !tag_found
   tag_found = (TAG(i) == varname)
   IF !tag_found
      i = i + 1
   ENDIF
ENDDO
IF !tag_found
   INDEX ON (varname) TAG (varname)
ENDIF
SET ORDER TO TAG (varname)

* Position picklist at the default value 
SEEK varnameval
IF !FOUND()
   GOTO TOP
ENDIF

* Figure out where the pick list should go
DO CASE
CASE COL() < scol()/2
   s_col = scol()/2 + 1
   e_col = scol() - 1
   s_row = 5
   e_row = SROWS() - 3
CASE COL() >= scol()/2
   s_col = 2
   e_col = scol()/2 - 1
   s_row = 5
   e_row = SROWS() - 3
ENDCASE

* Display pick list
DEFINE WINDOW dbfwin FROM s_row, s_col TO e_row, e_col ;
   TITLE PROPER(varname)+" pick list" ;
   CLOSE GROW ZOOM FLOAT MINIMIZE ;
   COLOR SCHEME 11
*   COLOR W+/W,N/W,BG/N,BG/N,BG/N,N/BG,N/W,N+/N,BG/N,BG/N,+

ON KEY LABEL enter KEYBOARD CHR(23)
SET SYSMENU OFF
BROWSE WINDOW dbfwin NOEDIT NOAPPEND NODELETE
SET SYSMENU AUTOMATIC
ON KEY LABEL enter

* If user selected an item, return its value
IF LASTKEY() <> 27
   retval = &varname
ELSE
   retval = "NULL"
ENDIF

* Do housekeeping and return
RELEASE WINDOW dbfwin
USE
SELECT (in_area)

RETURN retval

*!*****************************************************************
*!
*!      Procedure: FORCEEXT
*!
*!*****************************************************************
FUNCTION forceext
* Force the extension of "filname" to be whatever ext is.
PARAMETERS filname,ext
PRIVATE ALL
IF SUBSTR(m.ext,1,1) = "."
   m.ext = SUBSTR(m.ext,2,3)
ENDIF

m.pname = justpath(m.filname)
m.filname = justfname(UPPER(ALLTRIM(m.filname)))
IF AT('.',m.filname) > 0
   m.filname = SUBSTR(m.filname,1,AT('.',m.filname)-1) + '.' + m.ext
ELSE
   m.filname = m.filname + '.' + m.ext
ENDIF
RETURN addbs(m.pname) + m.filname
*!*****************************************************************
*!
*!      Procedure: DEFAULTEXT
*!
*!*****************************************************************
FUNCTION defaultext
* Force the extension of "filname" to be whatever ext is, unless it
* already has an extension.
PARAMETERS filname,ext
PRIVATE ALL
IF EMPTY(justext(m.filname))
   RETURN forceext(m.filname,m.ext)
ELSE
   RETURN m.filname
ENDIF
*!*****************************************************************
*!
*!      Procedure: JUSTFNAME
*!
*!*****************************************************************
FUNCTION justfname
* Return just the filename (i.e., no path) from "filname"
PARAMETERS filname
PRIVATE ALL
IF RAT('\',m.filname) > 0
   m.filname = SUBSTR(m.filname,RAT('\',m.filname)+1,255)
ENDIF
IF AT(':',m.filname) > 0
   m.filname = SUBSTR(m.filname,AT(':',m.filname)+1,255)
ENDIF
RETURN ALLTRIM(UPPER(m.filname))

*!*****************************************************************
*!
*!      Procedure: JUSTSTEM
*!
*!*****************************************************************
FUNCTION juststem
* Return just the stem name from "filname"
PARAMETERS filname
PRIVATE ALL
IF RAT('\',m.filname) > 0
   m.filname = SUBSTR(m.filname,RAT('\',m.filname)+1,255)
ENDIF
IF AT(':',m.filname) > 0
   m.filname = SUBSTR(m.filname,AT(':',m.filname)+1,255)
ENDIF
IF AT('.',m.filname) > 0
   m.filname = SUBSTR(m.filname,1,AT('.',m.filname)-1)
ENDIF
RETURN ALLTRIM(UPPER(m.filname))

*!*****************************************************************
*!
*!      Procedure: JUSTEXT
*!
*!*****************************************************************
FUNCTION justext
* Return just the extension from "filname"
PARAMETERS filname
PRIVATE ALL
filname = JustFname(m.filname)   && prevents problems with ..\ paths
m.ext = ""
IF AT('.',m.filname) > 0
   m.ext = SUBSTR(m.filname,AT('.',m.filname)+1,3)
ENDIF
RETURN UPPER(m.ext)


*!*****************************************************************
*!
*!      Procedure: JUSTPATH
*!
*!*****************************************************************
FUNCTION justpath
* Return just the path name from "filname"
PARAMETERS filname
PRIVATE ALL
m.filname = ALLTRIM(UPPER(m.filname))
IF '\' $ m.filname
   m.filname = SUBSTR(m.filname,1,RAT('\',m.filname))
   IF RIGHT(m.filname,1) = '\' AND LEN(m.filname) > 1 ;
         AND SUBSTR(m.filname,LEN(m.filname)-1,1) <> ':'
      m.filname = SUBSTR(m.filname,1,LEN(m.filname)-1)
   ENDIF
   RETURN m.filname
ELSE
   RETURN ''
ENDIF

*!*****************************************************************
*!
*!      Procedure: ADDBS
*!
*!*****************************************************************
FUNCTION addbs
* Add a backslash to a path name, if there isn't already one there
PARAMETER pathname
PRIVATE ALL
m.pathname = ALLTRIM(UPPER(m.pathname))
IF !(RIGHT(m.pathname,1) $ '\:') AND !EMPTY(m.pathname)
   m.pathname = m.pathname + '\'
ENDIF
RETURN m.pathname
