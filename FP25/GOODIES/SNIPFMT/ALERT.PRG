*:*********************************************************************
*:
*: Procedure file: C:\FOXPRO2\SNIPFMT\ALERT.PRG
*:
*:         System: SnipFmt
*:         Author: Walter J. Kennamer
*:      Copyright (c) 1991, Fox Holdings, Inc.
*:  Last modified: 05/05/91     15:49
*:
*:         Set by: SNIP.PRG                      
*:               : FMT            (procedure in SNIP.PRG)
*:
*:      Documented 05/16/91 at 16:07               FoxDoc  version 2.07á
*:*********************************************************************
*!*****************************************************************
*!
*!      Procedure: ALERT
*!
*!*****************************************************************
PROCEDURE alert
PARAMETERS strg, cscheme, buttons, action

PRIVATE ALL

SET TALK OFF

in_cons = SET('CONSOLE')

numparams = 4
DIMENSION dflts[numparams,2]
dflts[1,1] = "STRG"
dflts[2,1] = "CSCHEME"
dflts[3,1] = "BUTTONS"
dflts[4,1] = "ACTION"
dflts[1,2] = ''
dflts[2,2] = 7
dflts[3,2] =''
dflts[4,2] = 0

FOR i = 1 TO numparams
   IF PARAMETERS() < i
      vname = dflts[i,1]
      &vname = dflts[i,2]
   ENDIF
ENDFOR

m.numlines = OCCURS(';',strg) + 1          && number of message lines
IF !EMPTY(buttons)
   m.numbuts  = OCCURS(';',buttons) + 1    && number of buttons
ELSE
   m.numbuts = 0
ENDIF

DIMENSION alert_arry[numlines]

IF numbuts > 0
   DIMENSION but_arry[numbuts]
ELSE
   DIMENSION but_arry[1]
ENDIF

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

m.remain = m.buttons
m.maxbut = 0
FOR i = 1 TO m.numbuts
   IF AT(';',m.remain) > 0
      but_arry[i] = SUBSTR(m.remain,1,AT(';',m.remain)-1)
      but_arry[i] = CHRTRAN(but_arry[i],';','')
      m.remain = SUBSTR(m.remain,AT(';',m.remain)+1)
   ELSE
      but_arry[i] = m.remain
      m.remain = ''
   ENDIF
   IF LEN(but_arry[i]) > m.maxbut
      m.maxbut = LEN(but_arry[i])
   ENDIF
ENDFOR

IF !EMPTY(buttons)
   m.numlines = m.numlines + 2
ENDIF

m.butsize = m.numbuts * (m.maxbut + 3)    && chevrons + space
IF m.butsize > m.maxlen
   m.maxlen = m.butsize
ENDIF

m.top_row = INT( (SROWS() - 4 - m.numlines) / 2)
m.bot_row = m.top_row + 3 + m.numlines

m.top_col = INT((SCOLS() - m.maxlen - 6) / 2)
m.bot_col = m.top_col + m.maxlen + 6

DEFINE WINDOW alert FROM m.top_row,m.top_col TO m.bot_row,m.bot_col;
   DOUBLE FLOAT COLOR SCHEME (cscheme)
ACTIVATE WINDOW alert

IF !EMPTY(buttons)
   FOR i = 1 TO m.numlines - 2
      @ i,3 SAY PADC(alert_arry[i],m.maxlen)
   ENDFOR
   m.butpos = 3 + (m.maxlen - m.butsize)/2
   @ m.numlines,m.butpos GET action FUNCTION '*H' PICTURE buttons SIZE 1,m.maxbut+2,1
   READ
ELSE
   FOR i = 1 TO m.numlines
      @ i,3 SAY PADC(alert_arry[i],m.maxlen)
   ENDFOR

   SET CONSOLE OFF
   =INKEY(0,'HM')
   SET CONSOLE ON
ENDIF
RELEASE WINDOW alert

IF in_cons = "OFF"
   SET CONSOLE OFF
ENDIF
*: EOF: ALERT.PRG
