*:*********************************************************************
*:
*: Procedure file: PROCOLOR.PRG
*:
*:         System: PROCOLOR
*:         Author: C. Blaise Mitsutama
*:      Copyright (c) 1990-1993, C. Blaise Mitsutama
*:       Modified: 06/21/91      9:59
*:	Last modified: 03/25/92		17:49
*:
*:          Calls: SETSAVE.PRG
*:               : LEAVE          (procedure in PROCOLOR.PRG)
*:               : SIGNON.SPR
*:               : DEFCLRARRAY    (procedure in PROCOLOR.PRG)
*:               : CSET.SPR
*:               : PK_RSC         (procedure in PROCOLOR.PRG)
*:
*:*********************************************************************
*     Program: PROCOLOR.PRG
*     Purpose: Create FoxPro 2.5 Color Sets
*      Author: C. Blaise Mitsutama
* CompuServe#: 72260,420
*  FoxPro Ver: 2.5
*
* ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
* Copyright (c) 1990-1993, C. Blaise Mitsutama
* All rights reserved.
* ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
*
* CONVERT TO ASCII:
* ออออออออออออออออ
* I have used some ASCII graphic characters in the code. If your printer
* does not handle these, use the search and replace function of your text
* editor to substitute the codes. Many printers which do not handle these
* characters in the printer's native mode will handle them in graphics
* mode or may emulate other printers which are capable of printing graphic
* characters.
*
* If not, to replace the graphic characters with text equivalents, in
* FoxPro's editor hold down the [Alt] key while typing the numbers on the
* numeric keypad to create the "Look for" character. The replacements are:
*
* ASCII 196 ฤ  = Single underscore
* ASCII 205 อ  = Double underscore
*
* Where graphics are used in @...SAY commands, replace the delimited
* graphic with its CHR(nn) equivalent:
*
* "ฑ" = CHR(177)
* "ฒ" = CHR(178)
*
* Where graphics are used in literal strings, replace the graphic with
* its CHR(nn) equivalent as in the following example:
*
* "  Window Title  " becomes " "+CHR(17)+" Window Title "+CHR(16)+" "
*
* Set environment
* อออออออออออออออ

DO setsave                                  && save settings

SET TALK OFF
SET ECHO OFF
SET DOHIST OFF
SET DEVICE TO SCREEN
SET STATUS OFF
SET CLOCK OFF
SET CONFIRM ON
SET CURSOR OFF
SET ESCAPE OFF
SET SCOREBOARD OFF
SET BLINK OFF

PUSH KEY CLEAR
_DBLCLICK = .5

CREATE VIEW colrview                        && Record state of DBFs, CDXs,...
SET RESOURCE ON
CREATE COLOR SET initial                    && Save settings in case user cancels

m.in_error  = ON("ERROR")                   && Note ON ERROR/ON ESCAPE routines
m.in_escape = ON("ESCAPE")
m.in_rsc    = SET("RESOURCE",1)             && Name of the resource file

ON ERROR DO leave
ON ESCAPE

PUBLIC m.dlogscheme
m.dlogscheme = SCHEME(5)                    && Save Schemes 5&6--dialogs
m.dlogpops   = SCHEME(6)
m.mainobject = 0
m.moreobject = 0

* Screen object characteristics for color picker.
* The ScrnObj array defines parameters for the "fake" check boxes
* and push buttons used on the color picker screen.  This screen cannot
* use traditional screen controls because most of its action has to take
* place inside an INKEY loop.
maxobj = 3
DIMENSION scrnobj[maxobj,6]
scrnobj[1,1] = '[ ] Bright/blink'
scrnobj[1,2] = 18                           && row for object
scrnobj[1,3] = 1                            && leftmost column of object
scrnobj[1,4] = 16                           && rightmost column of object
scrnobj[1,5] = "W+/N"                       && unselected color
scrnobj[1,6] = "W+/B"                       && selected color

scrnobj[2,1] = 'ฎ See It ฏ'
scrnobj[2,2] = 20
scrnobj[2,3] = 1
scrnobj[2,4] = 10
scrnobj[2,5] = "W+/N"
scrnobj[2,6] = "W+/B"

scrnobj[3,1] = '< Cancel >'
scrnobj[3,2] = 20
scrnobj[3,3] = 14
scrnobj[3,4] = 23
scrnobj[3,5] = "W+/N"
scrnobj[3,6] = "W+/B"

* Color choice prompt for most dialogs
clrpickprmpt= "* \!\<Choose Color;\?\<Cancel"
clrpicksize = 14

SET RESOURCE OFF

* Change name to HLP extension so that it doesn't
* appear in the resource file picker popup
* Changed help file extension to .DBF per request
* from development.

IF FILE("COLRHELP.DBF")
  SET HELP TO colrhelp.dbf
ENDIF

CLEAR WINDOWS
CLEAR PROGRAM

SET CLOCK OFF
CLEAR
ON KEY                                      && Release any okls
ON KEY LABEL f1  HELP

m.redraw   = .T.                            && Controls screen redraws after colors picked
m.winshadow = 1

SET ESCAPE OFF

DO signon.spr

m.resfname = 'FOXUSER.DBF'
m.resfname = getresf(m.resfname)

* Define the array containing all color pair combinations
DO defclrarray

m.csetname = 'XXXX'
DO WHILE !EMPTY(m.csetname)
  * Get color set from a scrollable list
  IF WVISIBLE("wMainObject")
    HIDE WINDOW wmainobject
  ENDIF
  m.csetname = ''
  DO cset.spr WITH m.resfname,m.csetname,'to edit'

  DO CASE
  CASE m.csetname == '_INVALID'
    * Get another resource file and try again
    m.resfname = getresf(m.resfname)
    IF EMPTY(m.resfname)
       DO leave WITH .T.
    ENDIF
    m.csetname = 'XXXX'
    LOOP
  CASE EMPTY(m.csetname)
    DO leave WITH .T.
  OTHERWISE
    CLOSE DATABASES
    SET RESOURCE TO (m.resfname)
    SET RESOURCE ON
    SET COLOR SET TO (m.csetname)
    ACTIVATE SCREEN
    CLEAR
    SET BLINK OFF
  ENDCASE
  
  DO pk_rsc
ENDDO

DO leave WITH .F.
RETURN

*!*********************************************************************
*!
*!      Procedure: LEAVE
*!
*!          Calls: ALERT          (procedure in PROCOLOR.PRG)
*!               : SETSET.PRG
*!
*!*********************************************************************
PROCEDURE leave
* This procedure centralizes all cleanup housekeeping code.  It is
* called as an ON ERROR routine and also is the "gateway" out of the
* PROCOLOR system.

PARAMETER docancl
IF PARAMETERS() < 1
  docancl = .T.
ENDIF
* Report on any pending errors
IF ERROR() <> 0
  DO alert WITH  '  Error: '+MESSAGE() +';' ;
    +' Source: '+IIF(LEN(MESSAGE(1))<50,;
    MESSAGE(1),SUBSTR(MESSAGE(1),1,50)+'...')
ENDIF

POP KEY ALL

IF SET("RESOURCE") = "ON"
  SET RESOURCE OFF
ENDIF
IF USED(resfname)
  SELECT (m.resfname)
  USE
ENDIF
SET RESOURCE ON

* Restore name of original resource file
SET RESOURCE TO &in_rsc

IF setexist('INITIAL')
   SET COLOR SET TO initial                    && restore initial colors
ENDIF

CLOSE DATABASES

IF FILE("COLRVIEW.VUE")
  SET VIEW TO colrview
  DELETE FILE colrview.vue
ENDIF

ON ERROR

IF TYPE("IN_ERROR") <> "U"
  err_stmt = "ON ERROR "+in_error
  &err_stmt
ENDIF

IF TYPE("IN_ESCAPE") <> "U"
  esc_stmt = "ON ESCAPE "+in_escape
  &esc_stmt
ENDIF

CLEAR WIND
CLEAR                                       && necessary to restore screen color

* Look for Foxhelp in the FoxPro startup directory
IF FILE("COLRHELP.DBF")
  IF FILE(SYS(2004)+"FOXHELP.DBF")
    SET HELP TO (SYS(2004)+"FOXHELP.DBF")
  ENDIF
ENDIF

RELEASE clrarry

DO setset                                   && restore original SET values
SET BLINK OFF                               && ...except for BLINK
IF docancl
  CANCEL
ENDIF
RETURN

*!*********************************************************************
*!
*!      Procedure: GETRESF
*!
*!*********************************************************************

FUNCTION getresf
PARAMETERS resfname
PRIVATE m.res_picked, m.resname
m.res_picked = .F.
DO WHILE !m.res_picked
  m.resfile = GETFILE('DBF','Locate the resource file to edit')
  IF EMPTY(m.resfile)
    DO leave
  ELSE
    CLOSE DATABASES
    IF FILE(m.resfile)
      USE (m.resfile)
      IF FIELD(1)="TYPE" AND FIELD(2)="ID" AND FIELD(3)="NAME";
          AND FIELD(4)="READONLY" AND FIELD(5)="CKVAL" AND;
          FIELD(6)="DATA" AND FIELD(7)="UPDATED")
        m.res_picked = .T.
      ELSE
        WAIT WINDOW "That file is not a valid resource file."
      ENDIF
    ELSE
      WAIT WINDOW "That file could not be found."
    ENDIF
  ENDIF
ENDDO
RETURN m.resfile

* Pick the resource file
* ออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: PK_RSC
*!
*!          Calls: E_SYSMNU       (procedure in PROCOLOR.PRG)
*!               : E_SYSPOP       (procedure in PROCOLOR.PRG)
*!               : E_DIALOG       (procedure in PROCOLOR.PRG)
*!               : E_SYSWIN       (procedure in PROCOLOR.PRG)
*!               : E_ALERT        (procedure in PROCOLOR.PRG)
*!               : E_BROWS1       (procedure in PROCOLOR.PRG)
*!               : PK_OBJ         (procedure in PROCOLOR.PRG)
*!
*!*********************************************************************
PROCEDURE pk_rsc

* STRUCTURE for Colorlst.lst:
* ออออออออออออออออออออออออออ
* Field Name  Type  Width  Description
* ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
* SCHEME       C      9    Name of Color Scheme
* ONE          C      7    Color Pair 1
* TWO          C      7    Color Pair 2
* THREE        C      7    Color Pair 3
* FOUR         C      7    Color Pair 4
* FIVE         C      7    Color Pair 5
* SIX          C      7    Color Pair 6
* SEVEN        C      7    Color Pair 7
* EIGHT        C      7    Color Pair 8
* NINE         C      7    Color Pair 9
* TEN          C      7    Color Pair 10
* SHADOW       C      1    Shadow attribute
* UPDATED      C      7    Date & Time of last color change
*
* Copy Color Schemes to Colorlst.lst
* ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
IF !FILE('COLORLST.LST')
  CREATE TABLE colorlst.lst ( ;
    scheme C(9), ;
    one C(7), ;
    two C(7), ;
    three C(7), ;
    four C(7), ;
    five C(7), ;
    six C(7), ;
    seven C(7), ;
    eight C(7), ;
    nine C(7), ;
    ten C(7), ;
    shadow C(1), ;
    updated C(7) ;
    )
    FOR i = 1 to 24
       APPEND BLANK
    ENDFOR
ENDIF
USE colorlst.lst ALIAS clr

* Copy Schemes from Color Set to Colorlst.lst
* 5/22/91 Added 12th iteration to account for new Alert Pops
* 6/11/91 Added all 24 iterations to account for use of all
* Color Schemes
* ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
FOR m.repeat = 1 TO 24
  REPLACE one WITH SCHEME(m.repeat,1);
    two       WITH SCHEME(m.repeat,2);
    three     WITH SCHEME(m.repeat,3);
    four      WITH SCHEME(m.repeat,4);
    five      WITH SCHEME(m.repeat,5);
    six       WITH SCHEME(m.repeat,6);
    seven     WITH SCHEME(m.repeat,7);
    eight     WITH SCHEME(m.repeat,8);
    nine      WITH SCHEME(m.repeat,9);
    ten       WITH SCHEME(m.repeat,10);
    updated   WITH DTOC(DATE())+"  "+TIME()
  SKIP
ENDFOR m.repeat
GO TOP

* m.Usr_shdw is the User Window shadow color for display behind simulated
* screens (e.g., Browse, Report). m.Back_shdw determines whether a shadow
* will display behind an object.
* อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
GOTO 1
m.usr_shdw  = TRIM(eight)
m.back_shdw = (SET("SHADOW") = "ON")
IF m.back_shdw
  m.winshadow = 1
ELSE
  m.winshadow = 0
ENDIF

* Only 8 objects will display legibly on a 24 line screen. If you will be
* using or have access to 43/50 line screens, you can reset the coordinates
* to display all 11 objects on one screen.
*
* The first 8 objects are defined by FoxPro, so you don't have to bother
* changing their basic appearance (borders, item placement, etc.).
* อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
DO e_sysmnu                                 && draw system menu
DO e_syspop                                 && draw system menu popup (below sysmenu)
DO e_dialog                                 && draw dialog
DO e_syswin                                 && draw system window
DO e_alert                                  && draw alert
DO e_brows1                                 && draw browse with normal colors
DO pk_obj                                   && select the object to color
RETURN


* Pick the object to color
* ออออออออออออออออออออออออ
* You can move the Windows wColors and wMainObject with the mouse or by
* pressing [Ctrl][F7] and using the arrow keys.
* อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: PK_OBJ
*!
*!          Calls: MAINVALID      (procedure in PROCOLOR.PRG)
*!               : SHDWVALID      (procedure in PROCOLOR.PRG)
*!               : SAVECSET.SPR
*!               : PK_COLOR       (procedure in PROCOLOR.PRG)
*!               : E_SYSMNU       (procedure in PROCOLOR.PRG)
*!               : E_SYSPOP       (procedure in PROCOLOR.PRG)
*!               : E_DIALOG       (procedure in PROCOLOR.PRG)
*!               : E_DLGPOP       (procedure in PROCOLOR.PRG)
*!               : E_ALERT        (procedure in PROCOLOR.PRG)
*!               : E_SYSWIN       (procedure in PROCOLOR.PRG)
*!               : E_WINPOP       (procedure in PROCOLOR.PRG)
*!               : E_BROWS1       (procedure in PROCOLOR.PRG)
*!               : E_ALERTP       (procedure in PROCOLOR.PRG)
*!               : PUTMORE        (procedure in PROCOLOR.PRG)
*!
*!*********************************************************************
PROCEDURE pk_obj

DEFINE WINDOW wmainobject FROM 3,24 TO 20,54;
  TITLE " Select an Object ";
  FLOAT ;
  NOCLOSE ;
  SHADOW ;
  DOUBLE ;
  COLOR (m.dlogscheme)

DEFINE WINDOW wmoreobject FROM 3,24 TO 17,54;
  TITLE " Select an Object ";
  FLOAT ;
  NOCLOSE ;
  SHADOW ;
  DOUBLE ;
  COLOR (m.dlogscheme)

DEFINE WINDOW wobject FROM 3,24 TO 20,54;
  TITLE " Select an Attribute ";
  FLOAT ;
  NOCLOSE ;
  SHADOW ;
  DOUBLE ;
  COLOR (m.dlogscheme)

m.mainobject = 1                            && main menu radio button choice
DO WHILE .T.
  IF WVISIBLE("wMainObject")
    HIDE WINDOW wmainobject
  ENDIF
  ACTIVATE WINDOW wmainobject NOSHOW
  CLEAR
  m.mainchoice = 1
  
  @ 0, 1 GET m.mainobject;
    FUNC "*RN System Menu         CS3;"+;
    "System Menu Popups  CS4;Dialogs             CS5;"+;
    "Dialog Popups       CS6;Alerts              CS7;"+;
    "System Windows      CS8;Window Popups       CS9;"+;
    "Browses            CS10;Alert Popups       CS12;"+;
    "Other Objects ..." ;
    VALID mainvalid() ;
    COLOR (m.dlogscheme)
  
  @11, 0 CLEAR TO 11,24
  @11, 1 GET m.winshadow  FUNCTION "*CN Shadows on windows?" ;
    COLOR (m.dlogscheme) VALID shdwvalid()
  @13, 7 GET m.mainchoice FUNC "* \!\<Edit Colors;\<Save Colors;\?\<Cancel" ;
    SIZE 1,15 ;
    COLOR (m.dlogscheme)
  
  IF !WVISIBLE("wMainObject")
    ACTIVATE WINDOW wmainobject
  ENDIF
  
  READ MODAL CYCLE
  
  
  DO CASE
  CASE m.mainchoice = 2
    HIDE WINDOW wmainobject
    
    m.origcset = m.csetname
    m.scrnset  = m.csetname
    
    * Dialog for saving screen set
    DO savecset.spr WITH scrnset
    
    IF !EMPTY(m.scrnset)                        && save
      m.csetname = m.scrnset
      WAIT WINDOW "Saving color set..." NOWAIT
      SET RESOURCE TO (m.resfname)
      SET RESOURCE ON
      CREATE COLOR SET &csetname
      CREATE COLOR SET initial                    && this makes these colors current
      SET COLOR SET TO initial
      SET RESOURCE OFF
      WAIT WINDOW "Color set saved!" NOWAIT
    ELSE
      m.csetname = m.origcset                     && user canceled save. Restore.
    ENDIF
    RETURN
    
  CASE m.mainchoice = 3                       && user selected <cancel>
    HIDE WINDOW wmainobject
    RETURN
    
  CASE m.mainchoice = 1 AND m.mainobject = 1  && SYSTEM menu
    HIDE WINDOW wmainobject
    m.group = "SYSTEM MENU"
    m.object = 1
    m.option = 1
    
    DO WHILE .T.
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      MOVE WINDOW wobject TO 2,40                 && move out of the way
      
      DO CASE                                     && reset object numbers for menu
      CASE m.object = 6
        m.object = 3
      CASE m.object = 7
        m.object = 4
      ENDCASE
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Disabled Pads       CP1;Enabled Pads        CP2;"+;
        "Selected Pad        CP6;Hot Keys            CP7"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      
      IF !WVISIBLE("wObject")
        ACTIVATE WINDOW wobject
      ENDIF
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27
        EXIT
      ENDIF
      
      GOTO 3                                      && go to sysmenu record
      
      DO CASE
      CASE m.object = 1                           && repl cp w/colors
        m.to_color = "Disabled pads"
      CASE m.object = 2
        m.to_color = "Enabled pads"
      CASE m.object = 3
        m.to_color = "Selected pad"               && reset obj. nbrs for color pkr
        m.object = 6
      CASE m.object = 4
        m.to_color = "Hot keys"
        m.object = 7
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        DO e_sysmnu                               && redraw the menu
      ENDIF
    ENDDO                                       (.T.)
    
  CASE m.mainchoice = 1 AND m.mainobject = 2  && SYSTEM menu popups
    HIDE WINDOW wmainobject
    m.group = "SYSMENU POPUPS"
    m.object = 1
    m.option = 1
    
    DO WHILE .T.
      DO e_syspop
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      MOVE WINDOW wobject TO 2,40
      
      DO CASE                                     && reset object numbers for menu
      CASE m.object = 6
        m.object = 4
      CASE m.object = 7
        m.object = 5
      CASE m.object = 8
        m.object = 6
      ENDCASE
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Disabled Option     CP1;Enabled Option      CP2;"+;
        "Border              CP3;Selected Option     CP6;"+;
        "Hot Keys            CP7;Shadow              CP8"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      
      IF !WVISIBLE("wObject")
        ACTIVATE WINDOW wobject
      ENDIF
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27
        EXIT
      ENDIF
      
      GOTO 4                                      && go to syspop record
      
      DO CASE
      CASE m.object = 1
        m.to_color = "Disabled option"
      CASE m.object = 2
        m.to_color = "Enabled option"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4
        m.to_color = "Selected option"
        m.object = 6
      CASE m.object = 5
        m.to_color = "Hot keys"
        m.object = 7
      CASE m.object = 6
        m.to_color = "Shadow"
        m.object = 8
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        DO e_syspop                               && redraw menu popup
      ENDIF
    ENDDO
  CASE m.mainchoice = 1 AND m.mainobject = 3  && dialogs
    HIDE WINDOW wmainobject
    m.group = "DIALOGS"
    m.object = 1
    m.option = 1
    
    DO WHILE .T.
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      MOVE WINDOW wobject TO 2, 7
      
      DO CASE                                     && reset object numbers for menu
      CASE m.object = 6
        m.object = 4
      CASE m.object = 7
        m.object = 5
      CASE m.object = 8
        m.object = 6
      CASE m.object = 9
        m.object = 7
      CASE m.object = 10
        m.object = 8
      ENDCASE
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Normal Text         CP1;Text Box            CP2;"+;
        "Border              CP3;Selected Item       CP6;"+;
        "Hot Keys            CP7;Shadow              CP8;"+;
        "Enabled Control     CP9;Disabled Control   CP10"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      
      IF !WVISIBLE("wObject")
        ACTIVATE WINDOW wobject
      ENDIF
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27
        EXIT
      ENDIF
      
      GOTO 5                                      && go to dialog record
      
      DO CASE
      CASE m.object = 1
        m.to_color = "Normal text"
      CASE m.object = 2
        m.to_color = "Text box"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4
        m.to_color = "Selected item"
        m.object = 6
      CASE m.object = 5
        m.to_color = "Hot keys"
        m.object = 7
      CASE m.object = 6
        m.to_color = "Shadow"
        m.object = 8
      CASE m.object = 7
        m.to_color = "Enabled control"
        m.object = 9
      CASE m.object = 8
        m.to_color = "Disabled control"
        m.object = 10
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        DO e_dialog                               && redraw the dialog
      ENDIF
    ENDDO
  CASE m.mainchoice = 1 AND m.mainobject = 4      && dialog popups
    HIDE WINDOW wmainobject
    m.group = "DIALOG POPUPS"
    m.object = 1
    m.option = 1
    
    DO WHILE .T.
      DO e_dlgpop
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      MOVE WINDOW wobject TO 2, 7
      
      DO CASE                                     && reset object numbers for menu
      CASE m.object = 6
        m.object = 4
      CASE m.object = 7
        m.object = 5
      CASE m.object = 8
        m.object = 6
      ENDCASE
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Disabled Option     CP1;Enabled Option      CP2;"+;
        "Border              CP3;Selected Option     CP6;"+;
        "Hot Keys            CP7;Shadow              CP8"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      
      IF !WVISIBLE("wObject")
        ACTIVATE WINDOW wobject
      ENDIF
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27
        EXIT
      ENDIF
      
      GOTO 6                                      && go to dialog popup rec
      
      DO CASE
      CASE m.object = 1
        m.to_color = "Disabled option"
      CASE m.object = 2
        m.to_color = "Enabled option"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4
        m.to_color = "Selected option"
        m.object = 6
      CASE m.object = 5
        m.to_color = "Hot Keys"                   && new in 2.0
        m.object = 7
      CASE m.object = 6
        m.to_color = "Shadow"
        m.object = 8
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        DO e_dlgpop                               && redraw the dialog popup
      ENDIF
    ENDDO
    HIDE WINDOW wdlgpop
  CASE m.mainchoice = 1 AND m.mainobject = 5      && alerts
    HIDE WINDOW wmainobject
    m.group = "ALERTS"
    m.object = 1
    m.option = 1
    
    DO WHILE .T.
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      MOVE WINDOW wobject TO 2,40
      
      DO CASE                                     && reset object numbers for menu
      CASE m.object = 6
        m.object = 4
      CASE m.object = 7
        m.object = 5
      CASE m.object = 8
        m.object = 6
      CASE m.object = 9
        m.object = 7
      CASE m.object = 10
        m.object = 8
      ENDCASE
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Normal Text         CP1;Text Box            CP2;"+;
        "Border              CP3;Selected Item       CP6;"+;
        "Hot Keys            CP7;Shadow              CP8;"+;
        "Enabled Control     CP9;Disabled Control   CP10"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      
      IF !WVISIBLE("wObject")
        ACTIVATE WINDOW wobject
      ENDIF
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27
        EXIT
      ENDIF
      
      GOTO 7                                      && go to alert record
      
      DO CASE
      CASE m.object = 1
        m.to_color = "Normal text"
      CASE m.object = 2
        m.to_color = "Text box"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4
        m.to_color = "Selected item"
        m.object = 6
      CASE m.object = 5
        m.to_color = "Hot keys"
        m.object = 7
      CASE m.object = 6
        m.to_color = "Shadow"
        m.object = 8
      CASE m.object = 7
        m.to_color = "Enabled control"
        m.object = 9
      CASE m.object = 8
        m.to_color = "Disabled control"
        m.object = 10
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      
      IF m.redraw
        DO e_alert                                && redraw the alert
      ENDIF
    ENDDO
  CASE m.mainchoice = 1 AND m.mainobject = 6      && system windows
    HIDE WINDOW wmainobject
    m.group = "SYSTEM WINDOWS"
    m.object = 1
    m.option = 1
    
    DO WHILE .T.
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      MOVE WINDOW wobject TO 2,40
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Normal Text         CP1;Text Box            CP2;"+;
        "Border              CP3;Title, Active       CP4;"+;
        "Title, Idle         CP5;Selected Object     CP6;"+;
        "Hot Keys            CP7;Shadow              CP8;"+;
        "Enabled Control     CP9;Disabled Control   CP10"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      
      IF !WVISIBLE("wObject")
        ACTIVATE WINDOW wobject
      ENDIF
      
      READ MODAL CYCLE
      
      IF m.option = 2
        EXIT
      ENDIF
      
      GOTO 8                                      && go to the syswin rec.
      
      DO CASE
      CASE m.object = 1
        m.to_color = "Normal text"
      CASE m.object = 2
        m.to_color = "Text box"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4
        m.to_color = "Title, active"
      CASE m.object = 5
        m.to_color = "Title, idle"
      CASE m.object = 6
        m.to_color = "Selected text"
      CASE m.object = 7
        m.to_color = "Hot keys"
      CASE m.object = 8
        m.to_color = "Shadow"
      CASE m.object = 9
        m.to_color = "Enabled control"
      CASE m.object = 10
        m.to_color = "Disabled control"
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        DO e_syswin                               && redraw system window
      ENDIF
    ENDDO
  CASE m.mainchoice = 1 AND m.mainobject = 7      && window popups
    HIDE WINDOW wmainobject
    m.group = "WINDOW POPUPS"
    m.object = 1
    m.option = 1
    
    DO WHILE .T.
      DO e_winpop
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      MOVE WINDOW wobject TO 2,40
      
      DO CASE                                     && reset object numbers for menu
      CASE m.object = 6
        m.object = 4
      CASE m.object = 8
        m.object = 5
      ENDCASE
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Disabled Option     CP1;Enabled Option      CP2;"+;
        "Border              CP3;Selected Option     CP6;"+;
        "Shadow              CP8"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      
      IF !WVISIBLE("wObject")
        ACTIVATE WINDOW wobject
      ENDIF
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27
        EXIT
      ENDIF
      
      GOTO 9                                      && go to the winpop rec.
      
      DO CASE
      CASE m.object = 1
        m.to_color = "Disabled option"
      CASE m.object = 2
        m.to_color = "Enabled option"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4
        m.to_color = "Selected option"
        m.object = 6
      CASE m.object = 5
        m.to_color = "Shadow"
        m.object = 8
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        DO e_winpop                               && redraw the winpop
      ENDIF
    ENDDO
    HIDE WINDOW wwinpop
  CASE m.mainchoice = 1 AND m.mainobject = 8      && browses
    HIDE WINDOW wmainobject
    m.group = "BROWSE"
    m.object = 1
    m.option = 1
    
    DO WHILE .T.
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      MOVE WINDOW wobject TO 2, 7
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Other Records       CP1;Current Field       CP2;"+;
        "Border              CP3;Title, Active       CP4;"+;
        "Title, Idle         CP5;Selected Text       CP6;"+;
        "Current Record      CP7;Shadow              CP8"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      
      IF !WVISIBLE("wObject")
        ACTIVATE WINDOW wobject
      ENDIF
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27
        EXIT
      ENDIF
      
      GOTO 10                                     && go to browse record
      
      DO CASE
      CASE m.object = 1
        m.to_color = "Other records"
      CASE m.object = 2
        m.to_color = "Current field"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4
        m.to_color = "Title, active"
      CASE m.object = 5
        m.to_color = "Title, idle"
      CASE m.object = 6
        m.to_color = "Selected text"
      CASE m.object = 7
        m.to_color = "Current record"
      CASE m.object = 8
        m.to_color = "Shadow"
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        DO e_brows1                               && redraw browse
      ENDIF
    ENDDO
  CASE m.mainchoice = 1 AND m.mainobject = 9      && alert popups
    HIDE WINDOW wmainobject
    
    m.group = "ALERT POPUPS"
    m.object = 1
    m.option = 1
    
    DO WHILE .T.
      DO e_alertp
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      MOVE WINDOW wobject TO 2,40
      
      DO CASE                                     && reset object numbers for menu
      CASE m.object = 6
        m.object = 4
      CASE m.object = 7
        m.object = 5
      CASE m.object = 8
        m.object = 6
      ENDCASE
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Disabled Option     CP1;Enabled Option      CP2;"+;
        "Border              CP3;Selected Option     CP6;"+;
        "Hot Keys            CP7;Shadow              CP8"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      
      IF !WVISIBLE("wObject")
        ACTIVATE WINDOW wobject
      ENDIF
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27
        EXIT
      ENDIF
      
      GOTO 12                                     && go to alert popup rec
      
      DO CASE
      CASE m.object = 1
        m.to_color = "Disabled option"
      CASE m.object = 2
        m.to_color = "Enabled option"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4
        m.to_color = "Selected option"
        m.object = 6
      CASE m.object = 5
        m.to_color = "Hot keys"
        m.object = 7
      CASE m.object = 6
        m.to_color = "Shadow"
        m.object = 8
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        DO e_alertp                               && redraw the alert popup
      ENDIF
    ENDDO
    HIDE WINDOW walertpop
  CASE m.mainchoice = 1 AND m.mainobject = 10     && other objects
    DO putmore
  ENDCASE
  
  IF WVISIBLE("wObject")
    HIDE WINDOW wobject
  ENDIF
ENDDO
RETURN


*!*********************************************************************
*!
*!      Procedure: MAINVALID
*!
*!          Calls: PUTMORE        (procedure in PROCOLOR.PRG)
*!
*!*********************************************************************
FUNCTION mainvalid
IF m.mainobject = 10
  DO putmore
  ACTIVATE WINDOW wmainobject
  m.mainchoice = 1
  SHOW GETS
ENDIF
RETURN .T.


*!*********************************************************************
*!
*!      Procedure: SHDWVALID
*!
*!*********************************************************************
FUNCTION shdwvalid
IF m.winshadow = 1
  m.back_shdw = .T.
  SET SHADOW ON
ELSE
  m.back_shdw = .F.
  SET SHADOW OFF
ENDIF
ACTIVATE SCREEN

IF m.back_shdw
  @24,41 FILL TO 24,79 COLOR &usr_shdw        && simulate shadow for BROWSE
  @15,79 FILL TO 24,79 COLOR &usr_shdw
ELSE
  @24,41 CLEAR TO 24,79
  @15,79 CLEAR TO 24,79
ENDIF
ACTIVATE WINDOW wmainobject
RETURN .T.


*!*********************************************************************
*!
*!      Procedure: PUTMORE
*!
*!          Calls: E_USRMNU       (procedure in PROCOLOR.PRG)
*!               : E_USRWIN       (procedure in PROCOLOR.PRG)
*!               : E_STATUS       (procedure in PROCOLOR.PRG)
*!               : E_REPORT       (procedure in PROCOLOR.PRG)
*!               : E_BROWS2       (procedure in PROCOLOR.PRG)
*!               : MOREVALID      (procedure in PROCOLOR.PRG)
*!               : E_SYSMNU       (procedure in PROCOLOR.PRG)
*!               : E_SYSPOP       (procedure in PROCOLOR.PRG)
*!               : E_DIALOG       (procedure in PROCOLOR.PRG)
*!               : E_SYSWIN       (procedure in PROCOLOR.PRG)
*!               : E_ALERT        (procedure in PROCOLOR.PRG)
*!               : E_BROWS1       (procedure in PROCOLOR.PRG)
*!               : E_MNUMSG       (procedure in PROCOLOR.PRG)
*!               : PK_COLOR       (procedure in PROCOLOR.PRG)
*!
*!*********************************************************************
PROCEDURE putmore
SET CLOCK OFF
ACTIVATE SCREEN
CLEAR
DEACTIVATE WINDOWS wsyspop,wdialog,wdlgpop,walert,wsyswin,wwinpop,;
  walertpop
HIDE WINDOW wmainobject

DO e_usrmnu                                 && draw user menu
DO e_usrwin                                 && draw user window
DO e_status                                 && draw status bar
DO e_report                                 && draw report writer
DO e_brows2                                 && browse window

m.moreobject = 1
DO WHILE .T.
  ACTIVATE WINDOW wmoreobject
  m.moreoption = 1
  CLEAR
  
  @ 1, 3 GET m.moreobject;
    FUNC "*RN User Menu     CS2;User Windows  CS1;Reports       CS11;"+;
    "Other Objects...";
    SIZE 1,12,1 ;
    VALID morevalid()
  
  @11, 7 GET m.moreoption FUNC "* \!\<Edit Colors;\?\<Cancel" SIZE 1,13
  READ MODAL
  
  HIDE WINDOW wmoreobject
  
  DO CASE
  CASE m.moreoption = 2 OR m.moreobject = 4
    * Clean off the "More" stuff and restore the Main screens
    SET CLOCK OFF
    DEACTIVATE WINDOWS wuserpop,wusr_wind
    DEACTIVATE WINDOW wmoreobject
    
    ACTIVATE SCREEN
    CLEAR
    DO e_sysmnu                                 && draw system menu
    DO e_syspop                                 && draw system menu popup
    DO e_dialog                                 && draw dialog
    DO e_syswin                                 && draw system window
    DO e_alert                                  && draw alert
    DO e_brows1                                 && draw browse with normal colors
    RETURN
  CASE m.moreobject = 1
    DO e_usrmnu                                 && redraw user menu
    DO e_mnumsg                                 && redraw status bar
  CASE m.moreobject = 2
    DO e_usrwin                                 && redraw user window
    DO e_status                                 && redraw status bar
    DO e_brows2                                 && redraw browse window
  CASE m.moreobject = 3
    DO e_report                                 && redraw report
  ENDCASE
  
  HIDE WINDOW wmoreobject
  m.option = 1
  DO CASE
  CASE m.moreobject = 1                         && user menus
    m.group = "USER MENUS"
    m.object = 1
    DO WHILE .T.
      DEACTIVATE WINDOW wcolors
      MOVE WINDOW wobject TO 2,40
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Disabled Option     CP1;Enabled Option      CP2;"+;
        "Border              CP3;Menu Titles         CP4;"+;
        "Messages            CP5;Selected Option     CP6;"+;
        "Hot Keys            CP7;Shadow              CP8"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      SHOW WINDOW wobject
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27 OR m.option = 2
        EXIT
      ENDIF
      
      GOTO 2                                      && go to user menu record
      
      DO CASE
      CASE m.object = 1
        m.to_color = "Disabled option"
      CASE m.object = 2
        m.to_color = "Enabled option"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4
        m.to_color = "Menu titles"
      CASE m.object = 5
        m.to_color = "Message"
      CASE m.object = 6
        m.to_color = "Selected option"
      CASE m.object = 7
        m.to_color = "Hot keys"
      CASE m.object = 8
        m.to_color = "Shadow"
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        DO e_usrmnu                               && redraw user menu
        DO e_mnumsg                               && redraw menu message
      ENDIF
    ENDDO                                       (.T.)
    
  CASE m.moreobject = 2                           && user windows
    m.group = "USER WINDOWS"
    m.object = 1
    DO WHILE .T.
      DEACTIVATE WINDOW wcolors
      MOVE WINDOW wobject TO 2,40
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "SAY Field           CP1;GET Field           CP2;"+;
        "Border              CP3;Title, Active       CP4;"+;
        "Title, Idle         CP5;Selected Item       CP6;"+;
        "Clock               CP7;Shadow              CP8;"+;
        "Enabled Control     CP9;Disabled Control    CP10"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      SHOW WINDOW wobject
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27 OR m.option = 2
        EXIT
      ENDIF                                       LASTKEY() = 27 OR m.Option = 2
      
      DEACTIVATE WINDOW wobject
      GOTO 1                                      && go to user window rec
      
      DO CASE
      CASE m.object = 1
        m.to_color = "? & SAY field"
      CASE m.object = 2
        m.to_color = "GET field"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4                           && also status bar-lan version
        m.to_color = "Title, active"
      CASE m.object = 5                           && also " and Control Messages
        m.to_color = "Title, idle"
      CASE m.object = 6                           && also selected control
        m.to_color = "Selected item"
      CASE m.object = 7                           && also control hot keys & status bar
        m.to_color = "Clock"
      CASE m.object = 8
        m.to_color = "Shadow"
      CASE m.object = 9                           && new to 2.0
        m.to_color = "Enabled control"
      CASE m.object = 10                          && new to 2.0
        m.to_color = "Disabled control"
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        * Reset SAY field (Color Pair 1) of User Window (Color Scheme 1)
        * so the background screen displays in the proper color. Reset
        * m.Usr_shdw to display new values.
        * ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        
        HIDE WINDOW ALL
        SET CLOCK OFF
        GOTO 1
        m.clr_prmpt   = TRIM(one)
        m.usr_shdw = TRIM(eight)
        IF m.back_shdw
          SET COLOR OF SCHEME 1 TO &clr_prmpt,,,,,,,&usr_shdw,
        ELSE
          SET COLOR OF SCHEME 1 TO &clr_prmpt,,,,,,,,
        ENDIF
        CLEAR
        DO e_usrwin                                 && redraw user window
        DO e_status                                 && redraw status bar
        DO e_report                                 && redraw report
        DO e_brows2                                 && redraw browse window
      ENDIF
    ENDDO                                       (.T.)
    
  CASE m.moreobject = 3                             && reports
    m.group = "REPORTS"
    m.object = 1
    DO WHILE .T.
      DEACTIVATE WINDOW wcolors
      MOVE WINDOW wobject TO 2, 7
      ACTIVATE WINDOW wobject NOSHOW
      CLEAR
      SET CLOCK OFF
      
      @ 1, 0 SAY PADC(m.group,29," ")
      @ 3, 1 GET m.object FUNC "*RN "+;
        "Text & B full       CP1;Report field        CP2;"+;
        "Border              CP3;Title, Active       CP4;"+;
        "Title, Idle         CP5;Selected Item       CP6;"+;
        "Band A, empty       CP7;Shadow              CP8;"+;
        "Band A, full        CP9;Band B, empty       CP10"
      @14, 8 GET m.option FUNC clrpickprmpt SIZE 1,clrpicksize
      SHOW WINDOW wobject
      
      READ MODAL CYCLE
      
      IF LASTKEY() = 27 OR m.object = 0
        SET CLOCK ON
        EXIT
      ENDIF
      
      GOTO 11                                     && go to the reports rec
      
      DO CASE
      CASE m.object = 1
        m.to_color = "Text & B full"
      CASE m.object = 2
        m.to_color = "Report field"
      CASE m.object = 3
        m.to_color = "Border"
      CASE m.object = 4
        m.to_color = "Title, active"
      CASE m.object = 5
        m.to_color = "Title, idle"
      CASE m.object = 6
        m.to_color = "Selected item"
      CASE m.object = 7
        m.to_color = "Band A, empty"
      CASE m.object = 8
        m.to_color = "Shadow"
      CASE m.object = 9
        m.to_color = "Band A, full"
      CASE m.object = 10
        m.to_color = "Band B, empty"
      ENDCASE
      
      DO pk_color WITH m.redraw                   && pick the color pairs
      IF m.redraw
        DO e_report                               && redraw report writer
      ENDIF
    ENDDO
  CASE m.moreobject = 4
    * Intercepted by VALID
  ENDCASE
  HIDE WINDOW wobject
ENDDO 
RETURN


*!*********************************************************************
*!
*!      Procedure: MOREVALID
*!
*!*********************************************************************
FUNCTION morevalid
IF m.moreobject = 4
  CLEAR READ
ENDIF
RETURN .T.

* Choose the colors for an object
* ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
* Using a FOR ... ENDFOR construct would save program space, but takes
* longer to display than direct SAY statements.
* ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: PK_COLOR
*!
*!          Calls: GETROWCOL      (procedure in PROCOLOR.PRG)
*!               : PUT_CHEVRON    (procedure in PROCOLOR.PRG)
*!               : GOODCLICK      (procedure in PROCOLOR.PRG)
*!               : UPD_CHEVRON    (procedure in PROCOLOR.PRG)
*!               : UPDCOLOR       (procedure in PROCOLOR.PRG)
*!               : INBLINK        (procedure in PROCOLOR.PRG)
*!               : SETBLINK       (procedure in PROCOLOR.PRG)
*!               : ONBUTTON       (procedure in PROCOLOR.PRG)
*!               : UNPAINT_OBJ    (procedure in PROCOLOR.PRG)
*!               : PAINT_OBJ      (procedure in PROCOLOR.PRG)
*!
*!*********************************************************************
PROCEDURE pk_color
PARAMETER redraw
m.redraw = .T.                              && force a redraw unless user presses escape/cancel
m.choice = 1

DEFINE WINDOW wcolors FROM 1, 0 TO 23,39;
  FLOAT ;
  TITLE " "+m.group+" - "+m.to_color+" " "ฑ" COLOR (m.dlogscheme)
*                                         
*                                         ณ
*                                  Border character

ACTIVATE WINDOW wcolors NOSHOW

* if the object is on the right side of the screen,
* move color picker left and vice versa
DO CASE
CASE INLIST(m.mainobject,1,2,5,6,7,9) OR INLIST(m.moreobject,1,2)
  MOVE WINDOW wcolors TO 2,40
CASE INLIST(m.mainobject,3,4,8) OR INLIST(m.moreobject,3)
  MOVE WINDOW wcolors TO 2, 0
ENDCASE

CLEAR
@ 0, 0 FILL TO 21,25 COLOR N/N
@ 0,22 FILL TO 21,38 COLOR G/N+

m.row = 1
m.col = 2

* Default to current color for this object attribute
m.start_row = 1
m.start_col = 2
DO getrowcol WITH m.object,m.start_row,m.start_col

* Map array subscript to physical column locations
m.start_col = (m.start_col-1)*3 + 2

m.row = m.start_row
m.col = m.start_col

DO put_chevron WITH m.row,m.col,'ฏ','ฎ'

SET ESCAPE OFF

* Display color selection matrix
FOR m.colcount = 1 TO 8
  m.colpos = (colcount-1) * 3 + 2
  FOR m.rowcount = 1 TO 16
    @ m.rowcount,m.colpos SAY "X" COLOR (clrarry[m.rowcount,m.colcount])
  ENDFOR
ENDFOR

@ 1,26 SAY "Mouse or"   COLOR W+/N+
@ 2,26 SAY "press ู"    COLOR W+/N+
@ 3,26 SAY "to pick CP." COLOR W+/N+
@ 5,26 SAY "Mouse or"  COLOR W+/N+
@ 6,26 SAY "ฎ See It ฏ"  COLOR W+/N+
@ 7,26 SAY "to complete" COLOR W+/N+
@ 8,26 SAY "selection."  COLOR W+/N+
@10,26 SAY "Press [Esc]" COLOR W+/N+
@11,26 SAY "to abort."   COLOR W+/N+

* Display the buttons/check boxes/etc.
FOR i = 1 TO maxobj
  @ scrnobj[i,2], scrnobj[i,3] SAY scrnobj[i,1] COLOR (scrnobj[i,5])
ENDFOR

SHOW WINDOW wcolors         && pop up window all of a sudden
m.bright = 0
m.more   = .T.

* The last known color pair combination
colr_row = 0
colr_col = 0

* Object number for the fake buttons at the bottom
scrnobjnum = 0

DO WHILE m.more
  colr_sel = .F.
  DO WHILE !colr_sel
    inbuttons = scrnobjnum <> 0
    
    m.input = INKEY(.06,"HM")                   && get inkey(), hide cursor, check mouse
    IF m.input = 0                              && no key or mouse press
      LOOP
    ENDIF
    
    m.prev_row = m.row
    m.prev_col = m.col
    
    DO CASE
    CASE m.input = 151                          && single mouse click
      m.row = MROW("wColors")                   && get mouse pointer position
      m.col = MCOL("wColors")
      DO CASE
      CASE goodclick(m.row,m.col)               && mouse clicked on a color pair?
        DO upd_chevron
        
        m.ltimer = SECONDS()+_DBLCLICK          && time for double click
        
        DO WHILE SECONDS() < m.ltimer           && check for double mouse click
          m.input2 = INKEY("HM")
          IF m.input2 = 151
            * It was a double mouse click
            m.input  = 10                       && map double click to ctrl-enter
            colr_sel = .T.
            DO upd_chevron
            DO updcolor WITH m.colr_row,m.colr_col,m.object
            SET CURSOR OFF
            m.more = .F.
            HIDE WINDOW wcolors
          ENDIF
        ENDDO
      CASE inblink()
        IF inbuttons
          * Set the blink check box with highlighted color
          DO setblink WITH scrnobj[1,6]
        ELSE
          * Set the blink check box with non-highlighted color
          DO setblink WITH scrnobj[1,5]
        ENDIF
        colr_sel = .F.
        m.row = m.prev_row
        m.col = m.prev_col
      CASE onbutton(1)
        m.input  = 10
        colr_sel = .T.
        m.row = m.prev_row
        m.col = m.prev_col
      CASE onbutton(2)
        m.input = 27                            && simulate an escape key press
        colr_sel = .T.
        HIDE WINDOW wcolors
      OTHERWISE
        ?? CHR(7)
        m.row = m.prev_row
        m.col = m.prev_col
      ENDCASE
    CASE m.input = 1                            && home
      m.row = 1
      m.col = 2
      DO upd_chevron
      
    CASE m.input = 4                            && rightarrow
      DO CASE
      CASE inbuttons
        DO unpaint_obj WITH m.scrnobjnum
        m.scrnobjnum = IIF(m.scrnobjnum=m.maxobj,0,m.scrnobjnum + 1)
        DO paint_obj WITH m.scrnobjnum
      OTHERWISE
        IF m.col = 23
          m.col = 2
        ELSE
          m.col = m.col +3
        ENDIF
        DO upd_chevron
      ENDCASE
      
    CASE m.input = 5                            && uparrow
      DO CASE
      CASE inbuttons
        IF scrnobjnum = 1
          DO unpaint_obj WITH m.scrnobjnum
          m.scrnobjnum = 0
          DO upd_chevron
        ELSE
          DO unpaint_obj WITH m.scrnobjnum
          m.scrnobjnum = IIF(m.scrnobjnum=1,0,m.scrnobjnum - 1)
          DO paint_obj WITH m.scrnobjnum
        ENDIF
      OTHERWISE
        IF m.row = 1
          m.row = 16
        ELSE
          m.row = m.row -1
        ENDIF
        DO upd_chevron
      ENDCASE
    CASE m.input = 6                            && end
      m.row = 16
      m.col = 23
      DO upd_chevron
      
    CASE m.input = 9                            && tab
      IF m.col = 23
        m.col = 2
      ELSE
        m.col = m.col +3
      ENDIF
      DO upd_chevron
      
    CASE m.input = 19                           && leftarrow
      DO CASE
      CASE inbuttons
        DO unpaint_obj WITH m.scrnobjnum
        m.scrnobjnum = IIF(m.scrnobjnum=1,0,m.scrnobjnum - 1)
        DO paint_obj WITH m.scrnobjnum
      OTHERWISE
        IF m.col = 2
          m.col = 23
        ELSE
          m.col = m.col -3
        ENDIF 
        DO upd_chevron
      ENDCASE
      
    CASE m.input = 24                           && downarrow
      DO CASE
      CASE inbuttons
        DO unpaint_obj WITH m.scrnobjnum
        m.scrnobjnum = IIF(m.scrnobjnum=m.maxobj,0,m.scrnobjnum + 1)
        IF m.scrnobjnum = 0
          m.row = 1
          m.col = 2
          DO upd_chevron
        ELSE
          DO paint_obj WITH m.scrnobjnum
        ENDIF
      OTHERWISE
        IF m.row = 16
          m.row = 1
        ELSE
          m.row = m.row +1
        ENDIF
        DO upd_chevron
      ENDCASE
    CASE m.input = 27                           && escape
      colr_sel = .T.
      HIDE WINDOW wcolors
    CASE m.input = 10                           && CTRL-ENTER
      colr_sel =.T.
      HIDE WINDOW wcolors
    CASE m.input = 13                           && enter
      IF inbuttons
        colr_sel =.T.
        DO CASE
        CASE m.scrnobjnum = 1
          DO setblink WITH scrnobj[1,6]
        CASE m.scrnobjnum = 2                       && simulate a CTRL-ENTER
          m.input  = 10
          colr_sel = .T.
          HIDE WINDOW wcolors
        CASE m.scrnobjnum = 3                       && simulate an escape
          m.input  = 27
          colr_sel = .T.
          HIDE WINDOW wcolors
        ENDCASE
      ELSE
        scrnobjnum = 1
        inbuttons = .T.
        DO paint_obj WITH m.scrnobjnum
      ENDIF
    ENDCASE
  ENDDO
  
  DO CASE
  CASE m.input = 27
    m.redraw = .F.
    HIDE WINDOW wcolors
    RETURN
  CASE m.input = 10                           && ctrl-enter or double-click
    DO upd_chevron
    DO updcolor WITH m.colr_row,m.colr_col,m.object
    SET CURSOR OFF
    m.more = .F.
    HIDE WINDOW wcolors
  ENDCASE
ENDDO
RETURN


*!*********************************************************************
*!
*!      Procedure: PAINT_OBJ
*!
*!*********************************************************************
PROCEDURE paint_obj
PARAMETER m.s_objnum
IF m.s_objnum <> 0
  @ scrnobj[m.s_objnum,2],scrnobj[m.s_objnum,3] ;
    FILL TO scrnobj[m.s_objnum,2],scrnobj[m.s_objnum,4];
    COLOR (scrnobj[m.s_objnum,6])
  
ENDIF
RETURN

*!*********************************************************************
*!
*!      Procedure: UNPAINT_OBJ
*!
*!*********************************************************************
PROCEDURE unpaint_obj
PARAMETER m.s_objnum
IF m.s_objnum <> 0
  @ scrnobj[m.s_objnum,2],scrnobj[m.s_objnum,3] ;
    FILL TO scrnobj[m.s_objnum,2],scrnobj[m.s_objnum,4] ;
    COLOR (scrnobj[m.s_objnum,5])
ENDIF
RETURN


*!*********************************************************************
*!
*!      Procedure: UPD_CHEVRON
*!
*!          Calls: PUT_CHEVRON    (procedure in PROCOLOR.PRG)
*!
*!*********************************************************************
PROCEDURE upd_chevron
* Erase old chevrons
DO put_chevron WITH m.prev_row,m.prev_col,' ',' '
* Draw chevrons at new color selection
DO put_chevron WITH m.row,m.col,'ฏ','ฎ'
colr_row = m.row
colr_col = m.col
RETURN


*!*********************************************************************
*!
*!      Procedure: PUT_CHEVRON
*!
*!*********************************************************************
PROCEDURE put_chevron
PARAMETER ROW,COL,s1,s2
@m.row,m.col-1 SAY m.s1  COLOR W+/N
@m.row,m.col+1 SAY m.s2  COLOR W+/N
RETURN



*!*********************************************************************
*!
*!      Procedure: SETBLINK
*!
*!*********************************************************************
PROCEDURE setblink
PARAMETER boxcolr
m.bright = IIF(m.bright=0,1,0)
@ scrnobj[1,2],scrnobj[1,3]+1 SAY IIF(m.bright<>0,'X',' ');
  COLOR (m.boxcolr)
RETURN


*!*********************************************************************
*!
*!      Procedure: INBLINK
*!
*!*********************************************************************
FUNCTION inblink
RETURN (m.row = 18 AND m.col <= 16)


*!*********************************************************************
*!
*!      Procedure: ONBUTTON
*!
*!*********************************************************************
FUNCTION onbutton
PARAMETER bnum
DO CASE
CASE bnum = 1
  RETURN (m.row = 20 AND m.col <= 12)
CASE bnum = 2
  RETURN (m.row = 20 AND BETWEEN(m.col,13,24))
ENDCASE


*!*********************************************************************
*!
*!      Procedure: UPDCOLOR
*!
*!          Calls: NUM2WRD        (procedure in PROCOLOR.PRG)
*!
*!*********************************************************************
PROCEDURE updcolor
PARAMETERS clr_row,clr_col,clr_object
m.colorcode = TRIM(clrarry[m.clr_row,INT((m.clr_col-2)/3)+1]) + IIF(m.bright=1,'*','')
m.fldname = 'clr->'+num2wrd(m.clr_object)
replace (m.fldname) WITH m.colorcode
RETURN


*!*********************************************************************
*!
*!      Procedure: GOODCLICK
*!
*!*********************************************************************
FUNCTION goodclick
PARAMETERS ROW, COL
* Was the mouse clicked on a valid row and column inside the window?
RETURN (m.col != -1 AND m.row != -1) ;
  AND BETWEEN(m.row,1,16)  ;
  AND INLIST(m.col,2,5,8,11,14,17,20,23)


*!*********************************************************************
*!
*!      Procedure: PUT_CHEVRON
*!
*!*********************************************************************
PROCEDURE put_chevron
PARAMETER ROW,COL,s1,s2
@m.row,m.col-1 SAY m.s1  COLOR W+/N
@m.row,m.col+1 SAY m.s2  COLOR W+/N
RETURN



* ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
*                                DRAW OBJECTS
* ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

* Color the User Window (Color Scheme 1)
* ออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_USRWIN
*!
*!*********************************************************************
PROCEDURE e_usrwin

GOTO 1                                      && go to user window rec
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.clr_prmpt= TRIM(one)
m.clr_input= TRIM(two)                      && @EDIT text editing enabled
m.border   = TRIM(three)
m.ttl_actv = TRIM(four)
m.message  = TRIM(five)                     && title, idle; control message
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)                    && clock; control hotkeys
m.shadow   = TRIM(eight)
m.enabled  = TRIM(nine)                     && new to 2.0
m.disabled = TRIM(ten)                      && new to 2.0

SET COLOR OF SCHEME 1 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

DEFINE WINDOW wusr_wind FROM 9, 0 TO 21,36;
  SHADOW DOUBLE;
  TITLE "User Window"

ACTIVATE WINDOW wusr_wind
@ 1, 1 SAY "Prompt color:"             COLOR &clr_prmpt && cp 1
@ 1,15 SAY "Input item color"          COLOR &clr_input && cp 2
@ 2,15 SAY "Selected item color"       COLOR &chosen && cp 6
@ 4,22 SAY "Text Edit:"                COLOR &clr_prmpt && cp1
@ 5, 1 SAY "[X] Check Boxes"           COLOR &enabled && CP 9
@ 5,22 SAY "If enabled "               COLOR &clr_input && CP 2
@ 6, 1 SAY "< OK > Push Buttons"       COLOR &enabled && CP 9
@ 6,22 SAY "If disabled"               COLOR &disabled && CP10
@ 4, 1 SAY "Controls:"                 COLOR &clr_prmpt && cp 1
@ 8, 1 SAY "() Selected Radio Button" COLOR &chosen && cp 6
@ 9, 1 SAY "( ) Disabled Radio Button" COLOR &disabled && cp10
@10, 1 SAY "( ) "                      COLOR &enabled && cp9
@10, 5 SAY "E"                         COLOR &hotkey
@10, 6 SAY "nabled Radio Button"       COLOR &enabled && cp 9

* Since SET CLOCK does not have a COLOR argument, the only way I've found
* to make sure the clock color is changed without affecting other color
* options is to reset COLOR SCHEME 1. The commas act as place holders for
* Color Pairs I don't want to change.
* อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
SET CLOCK TO 21,13
SET CLOCK ON                                && cp 7
ACTIVATE SCREEN
RETURN


* Color the Status Bar (Color Scheme 1)
* ออออออออออออออออออออออออออออออออออออออ
* 5/23/91 Added Status Bar. The Status Bar is associated with User
* Windows because it is employs CS1 colors.
* อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_STATUS
*!
*!*********************************************************************
PROCEDURE e_status
GOTO 1                                      && go to user window rec
m.message  = TRIM(five)                     && title, idle
m.hotkey   = TRIM(seven)                    && status line

@22, 0 CLEAR TO 24,79
@23, 0 SAY;
  "                ณ<C:> ณFILENAME     ณEXCLUSIVE     "+;
  "ณRec: None      ณIns ณNumCaps";
  COLOR &hotkey

IF "LAN"$VERSION()
  @24, 0 SAY REPL(" ",80) COLOR &message
ENDIF                                       "LAN"$VERSION()
RETURN


* Color the Control Messages (Color Scheme 1)
* อออออออออออออออออออออออออออออออออออออออออออ
* 5/23/91 Added Control Messages.  Control Messages are associated with
* User Windows because they employ CS1 colors.
* อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_CTLMSG
*!
*!*********************************************************************
PROCEDURE e_ctlmsg
GOTO 1                                      && go to user window rec
m.message  = TRIM(five)                     && title, idle

@22, 0 CLEAR TO 24,79
@24, 0 SAY REPLICATE(" ",27) COLOR &message
@24,27 SAY "This is a Control Message" COLOR &message
@24,52 SAY REPLICATE(" ",28) COLOR &message
RETURN


* Color the User Menu (Color Scheme 2)
* อออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_USRMNU
*!
*!*********************************************************************
PROCEDURE e_usrmnu

GOTO 2                                      && go to user menu record
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.disabled = TRIM(one)
m.enabled  = TRIM(two)
m.border   = TRIM(three)
m.ttl_actv = TRIM(four)                     && menu titles
m.message  = TRIM(five)
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)
m.shadow   = TRIM(eight)

SET COLOR OF SCHEME 2 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

DEFINE MENU musrmenu
DEFINE PAD penabled OF musrmenu  PROMPT "\<Enabled "  AT 2, 0
DEFINE PAD pdisabled OF musrmenu PROMPT "\Disabled "  AT 2,10
DEFINE PAD pselected OF musrmenu PROMPT "Selected "   AT 2,21
ON SELECTION PAD pselected OF musrmenu ACTIVATE POPUP oselected

DEFINE POPUP oselected FROM 3,21
DEFINE BAR  1 OF oselected PROMPT "Selected"  COLOR ,&chosen
DEFINE BAR  2 OF oselected PROMPT "\Disabled"
DEFINE BAR  3 OF oselected PROMPT "\<Enabled"

ACTIVATE SCREEN
SHOW MENU musrmenu PAD pselected SAVE
IF m.back_shdw
  @ 4,22 FILL TO 8,32 COLOR &usr_shdw
ENDIF
SHOW POPUP oselected SAVE
RETURN


* Color the Menu Message Line (Color Scheme 2)
* ออออออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_MNUMSG
*!
*!*********************************************************************
PROCEDURE e_mnumsg
GOTO 2                                      && go to user menu record
m.message  = TRIM(five)

@22, 0 CLEAR TO 24,79
@24, 0 SAY REPLICATE(" ",26) COLOR &message
@24,26 SAY "This is a User Menu Message" COLOR &message
@24,53 SAY REPLICATE(" ",27) COLOR &message
RETURN


* Color the System Menu Bar (Color Scheme 3)
* ออออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_SYSMNU
*!
*!*********************************************************************
PROCEDURE e_sysmnu

GOTO 3                                      && go to menu bar record
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.disabled = TRIM(one)
m.enabled  = TRIM(two)
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)

SET COLOR OF SCHEME 3 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

ACTIVATE SCREEN
@ 2, 0 SAY " "          COLOR &enabled
@ 2, 1 SAY "S"          COLOR &hotkey
@ 2, 2 SAY "ysmenu "    COLOR &enabled
@ 2, 9 SAY " Disabled " COLOR &disabled
@ 2,19 SAY " Selected " COLOR &chosen
@ 2,29 SAY " "          COLOR &enabled
@ 2,30 SAY "E"          COLOR &hotkey
@ 2,31 SAY "nabled "    COLOR &enabled
RETURN


* Color the System Menu Popups (Color Scheme 4)
* อออออออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_SYSPOP
*!
*!*********************************************************************
PROCEDURE e_syspop

GOTO 4                                      && go to menu popup rec
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.disabled = TRIM(one)
m.enabled  = TRIM(two)
m.border   = TRIM(three)
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)
m.shadow   = TRIM(eight)

SET COLOR OF SCHEME 4 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

DEFINE WINDOW wsyspop FROM 3,20 TO 7,37;
  SHADOW;
  COLOR &disabled,&enabled,&border,,,;
  &chosen,&hotkey,&shadow,,,+

ACTIVATE WINDOW wsyspop NOSHOW
@ 0, 0 SAY REPLICATE(" ",17)  COLOR &enabled
@ 0, 1 SAY "E"                COLOR &hotkey
@ 0, 2 SAY "nabled"           COLOR &enabled
@ 0,13 SAY "^Z"               COLOR &hotkey
@ 1, 0 SAY " Disabled       " COLOR &disabled
@ 2, 0 SAY " Selected...    " COLOR &chosen
ACTIVATE WINDOW wsyspop

ACTIVATE SCREEN
RETURN


* Color the System Dialogs (Color Scheme 5)
* อออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_DIALOG
*!
*!*********************************************************************
PROCEDURE e_dialog

GOTO 5                                      && go to dialog record
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.clr_prmpt= TRIM(one)
m.clr_input= TRIM(two)
m.border   = TRIM(three)
m.ttl_actv = TRIM(four)                     && (not documented)
m.message  = TRIM(five)                     && title, idle (not documented)
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)
m.shadow   = TRIM(eight)
m.enabled  = TRIM(nine)
m.disabled = TRIM(ten)

SET COLOR OF SCHEME 5 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

DEFINE WINDOW wdialog FROM 2,40 TO 12,78;
  DOUBLE;
  SHADOW;
  TITLE " Dialogs " ;
  COLOR &clr_prmpt,&clr_input,&border,&ttl_actv,&message,&chosen,&hotkey,;
  &shadow,&enabled,&disabled,+

ACTIVATE WINDOW wdialog NOSHOW
@ 0, 1 SAY "Dialog Popups:"          COLOR &clr_prmpt
@ 1, 1 SAY "ฺฤฤฤฤฤฤฤฤฤฤฤฤท"          COLOR &clr_prmpt
@ 2, 1 SAY "ณ Enabled    บ"          COLOR &clr_prmpt
@ 3, 1 SAY "ิออออออออออออผ"          COLOR &clr_prmpt
@ 0,16,3,38 BOX
@ 0,17 SAY " Options "               COLOR &clr_prmpt
@ 1,18 SAY "[ ] "                    COLOR &enabled
@ 1,22 SAY "E"                       COLOR &hotkey
@ 1,23 SAY "nabled ctrl"             COLOR &enabled
@ 2,18 SAY "[X] Selected item"       COLOR &chosen
@ 5,18 SAY "<  "                     COLOR &enabled
@ 5,20 SAY "E"                       COLOR &hotkey
@ 5,21 SAY "nabled Ctrl>"            COLOR &enabled
@ 7, 1 SAY "User Entered:"           COLOR &clr_prmpt
@ 7,18 SAY "<Disabled ctrl>"         COLOR &disabled
@ 8, 1 SAY "Text Box       "         COLOR &clr_input
SHOW WINDOW wdialog

ACTIVATE SCREEN
RETURN


* Color the Dialogs Popups (Color Scheme 6)
* อออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_DLGPOP
*!
*!*********************************************************************
PROCEDURE e_dlgpop

GOTO 6                                      && go to dialog popup rec
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.disabled = TRIM(one)
m.enabled  = TRIM(two)
m.border   = TRIM(three)
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)
m.shadow   = TRIM(eight)

SET COLOR OF SCHEME 6 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

DEFINE WINDOW wdlgpop FROM 4,41 TO  8,55;
  SHADOW;
  COLOR &disabled,&enabled,&border,,,&chosen,&hotkey,;
  &shadow,,,+

ACTIVATE WINDOW wdlgpop
@ 0, 0 SAY " "             COLOR &enabled
@ 0, 1 SAY "E"             COLOR &hotkey
@ 0, 2 SAY "nabled     "   COLOR &enabled
@ 1, 0 SAY " Selected    " COLOR &chosen
@ 2, 0 SAY " Disabled    " COLOR &disabled
RETURN


* Color the Alerts (Color Scheme 7)
* อออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_ALERT
*!
*!*********************************************************************
PROCEDURE e_alert

GOTO 7                                      && go to alert record
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.clr_prmpt= TRIM(one)
m.clr_input= TRIM(two)
m.border   = TRIM(three)
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)
m.shadow   = TRIM(eight)
m.enabled  = TRIM(nine)
m.disabled = TRIM(ten)

SET COLOR OF SCHEME 7 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

DEFINE WINDOW walert FROM 18, 0 TO 23,37;
  DOUBLE SHADOW;
  TITLE " Alerts ";
  COLOR &clr_prmpt,&clr_input,&border,,,&chosen,&hotkey,;
  &shadow,&enabled,&disabled,+

ACTIVATE WINDOW walert NOSHOW
@ 0, 1 SAY "Prompt:"               COLOR &clr_prmpt
@ 0, 9 SAY "Alert "                COLOR &clr_input
@ 0,24 SAY "ฺฤฤฤฤฤฤฤฤฤฤท"          COLOR &clr_prmpt
@ 1,24 SAY "ณ Enabled  บ"          COLOR &clr_prmpt
@ 2,24 SAY "ิออออออออออผ"          COLOR &clr_prmpt
@ 3, 1 SAY "<"                     COLOR &enabled
@ 3, 2 SAY "E"                     COLOR &hotkey
@ 3, 3 SAY "nabled>"               COLOR &enabled
@ 3,13 SAY "<Disabled>"            COLOR &disabled
@ 3,26 SAY "<Selected>"            COLOR &chosen
SHOW WINDOW walert

ACTIVATE SCREEN
RETURN


* Color the System Windows (Color Scheme 8)
* อออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_SYSWIN
*!
*!*********************************************************************
PROCEDURE e_syswin

GOTO 8                                      && go to sys window rec
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.clr_prmpt= TRIM(one)
m.clr_input= TRIM(two)
m.border   = TRIM(three)
m.ttl_actv = TRIM(four)
m.message  = TRIM(five)                     && title, idle
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)
m.shadow   = TRIM(eight)
m.enabled  = TRIM(nine)
m.disabled = TRIM(ten)

SET COLOR OF SCHEME 8 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

DEFINE WINDOW wsyswin FROM 9, 0 TO 16,37;
  SHADOW;
  TITLE " System Windows ";
  COLOR &clr_prmpt,&clr_input,&border,&ttl_actv,&message,;
  &chosen,&hotkey,&shadow,&enabled,&disabled,+

ACTIVATE WINDOW wsyswin NOSHOW
@ 0, 1 SAY "Prompt:"       COLOR &clr_prmpt
@ 0, 9 SAY "Text box "     COLOR &clr_input
@ 0,24 SAY "ฺฤฤฤฤฤฤฤฤฤฤท"  COLOR &clr_prmpt
@ 1,24 SAY "ณ Enabled  บ"  COLOR &clr_prmpt
@ 2,24 SAY "ิออออออออออผ"  COLOR &clr_prmpt
@ 5, 1 SAY "<"             COLOR &clr_prmpt
@ 5, 2 SAY "E"             COLOR &hotkey
@ 5, 3 SAY "nabled>"       COLOR &enabled
@ 5,12 SAY "<Disabled>"    COLOR &disabled
@ 5,24 SAY "<Selected>"    COLOR &chosen
SHOW WINDOW wsyswin

ACTIVATE SCREEN
RETURN


* Color the SysWin Popups (Color Scheme 9)
* ออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_WINPOP
*!
*!*********************************************************************
PROCEDURE e_winpop

GOTO 9                                      && go to syswin popup rec
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.disabled = TRIM(one)
m.enabled  = TRIM(two)
m.border   = TRIM(three)
m.chosen   = TRIM(six)
m.shadow   = TRIM(eight)

SET COLOR OF SCHEME 9 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

IF m.back_shdw
  DEFINE WINDOW wwinpop FROM 10,24 TO 14,36;
    SHADOW;
    COLOR &disabled,&enabled,&border,,,&chosen,,;
    &shadow,,,+
ELSE
  DEFINE WINDOW wwinpop FROM 10,24 TO 14,36;
    COLOR &disabled,&enabled,&border,,,&chosen,,;
    &shadow,,,-
ENDIF                                       (m.Back_shdw)

ACTIVATE WINDOW wsyswin
ACTIVATE WINDOW wwinpop
@ 0, 0 SAY "  Enabled  " COLOR &enabled
@ 1, 0 SAY "  Selected " COLOR &chosen
@ 2, 0 SAY "  Disabled " COLOR &disabled
RETURN


* Color Browse (Color Scheme 10)
* 5/23/91 Modified to make room for Status Bar
* ออออออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_BROWS1
*!
*!*********************************************************************
PROCEDURE e_brows1

GOTO 10                                     && go to browse record
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.disabled = TRIM(one)                      && other records
m.enabled  = TRIM(two)                      && current field
m.border   = TRIM(three)
m.ttl_actv = TRIM(four)
m.message  = TRIM(five)                     && title, idle
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)                    && current record
m.shadow   = TRIM(eight)
*                                  && Bkgd CP3/Bkgd CP1
m.grid     = TRIM(SUBSTR(three,AT("/",three)+1))+"/"+;
  TRIM(SUBSTR(one,AT("/",one)+1))
*                                  && Bkgd CP7/Bkgd CP1
m.marked   = TRIM(SUBSTR(seven,AT("/",seven)+1))+"/"+;
  TRIM(SUBSTR(one,AT("/",one)+1))

SET COLOR OF SCHEME 10 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

ACTIVATE SCREEN
IF m.back_shdw
  @15,41 FILL TO 24,79 COLOR &usr_shdw        && simulate shadow
ELSE
  @15,41 CLEAR TO 24,79
ENDIF

@14,40 FILL TO 23,78 COLOR &disabled

@14,40 SAY "þ"               COLOR &border  && top line
@14,41 SAY REPLICATE(" ",37) COLOR &border
@14,50 SAY "TITLE_ACTV/"     COLOR &ttl_actv
@14,61 SAY "TITLE_IDLE"      COLOR &message
@14,78 SAY "๐"               COLOR &border

@15,40 SAY " "               COLOR &border  && lt/rt
@15,78 SAY ""               COLOR &border

@15,42 SAY "Field1"          COLOR &disabled && field names
@15,49 SAY "ณ"               COLOR &grid
@15,50 SAY "Field2"          COLOR &disabled
@15,58 SAY "ณ"               COLOR &grid
@15,59 SAY "Field3"          COLOR &disabled
@15,67 SAY "ณ"               COLOR &grid
@15,68 SAY "Field4"          COLOR &disabled
@15,76 SAY "ณ"               COLOR &grid

@16,40 SAY " "               COLOR &border
@16,41 SAY REPLICATE("อ",37) COLOR &grid
@16,49 SAY "ุ"               COLOR &grid
@16,58 SAY "ุ"               COLOR &grid
@16,67 SAY "ุ"               COLOR &grid
@16,76 SAY "ุ"               COLOR &grid
@16,78 SAY " "               COLOR &border

@17,40 SAY " "               COLOR &border  && 1st record
@17,42 SAY "Other"           COLOR &disabled
@17,49 SAY "ณ"               COLOR &grid
@17,50 SAY "Data"            COLOR &disabled
@17,58 SAY "ณ"               COLOR &grid
@17,67 SAY "ณ"               COLOR &grid
@17,68 SAY "Data"            COLOR &disabled
@17,76 SAY "ณ"               COLOR &grid
@17,78 SAY " "               COLOR &border

@18,40 SAY " "               COLOR &border  && 2nd record
@18,42 SAY "Cur rec"         COLOR &hotkey  && pointer is
@18,49 SAY "ณ"               COLOR &grid    && on this
@18,50 SAY "Data    "        COLOR &hotkey  && record.
@18,58 SAY "ณ"               COLOR &grid    && cursor is
@18,59 SAY "Cur. "           COLOR &chosen  && on the 3rd
@18,64 SAY "fld"             COLOR &enabled && field.
@18,67 SAY "ณ"               COLOR &grid
@18,68 SAY "Data    "        COLOR &hotkey
@18,76 SAY "ณ"               COLOR &grid
@18,78 SAY " "               COLOR &border

@19,40 SAY " "               COLOR &border  && 3rd record
@19,42 SAY "Other"           COLOR &disabled
@19,49 SAY "ณ"               COLOR &grid
@19,50 SAY "Data"            COLOR &disabled
@19,58 SAY "ณ"               COLOR &grid
@19,59 SAY "Data"            COLOR &disabled
@19,67 SAY "ณ"               COLOR &grid
@19,68 SAY "Data"            COLOR &disabled
@19,76 SAY "ณ"               COLOR &grid
@19,78 SAY " "               COLOR &border

@20,40 SAY " "               COLOR &border  && 4th record
@20,41 SAY CHR(4)            COLOR &marked  && shows
@20,42 SAY "Marked"          COLOR &disabled && deleted
@20,49 SAY "ณ"               COLOR &grid    && marker
@20,50 SAY "for"             COLOR &disabled
@20,58 SAY "ณ"               COLOR &grid
@20,59 SAY "Deletion"        COLOR &disabled
@20,67 SAY "ณ"               COLOR &grid
@20,68 SAY "Data"            COLOR &disabled
@20,76 SAY "ณ"               COLOR &grid
@20,78 SAY " "               COLOR &border

@21,40 SAY " "               COLOR &border  && 5th record
@21,42 SAY "Other"           COLOR &disabled
@21,49 SAY "ณ"               COLOR &grid
@21,58 SAY "ณ"               COLOR &grid
@21,59 SAY "Data"            COLOR &disabled
@21,67 SAY "ณ"               COLOR &grid
@21,68 SAY "Data"            COLOR &disabled
@21,76 SAY "ณ"               COLOR &grid
@21,78 SAY CHR(4)            COLOR &border

@22,40 SAY " "               COLOR &border  && 6th record
@22,42 SAY "Other"           COLOR &disabled
@22,49 SAY "ณ"               COLOR &grid
@22,50 SAY "Data"            COLOR &disabled
@22,58 SAY "ณ"               COLOR &grid
@22,59 SAY "Data"            COLOR &disabled
@22,67 SAY "ณ"               COLOR &grid
@22,68 SAY "Data"            COLOR &disabled
@22,76 SAY "ณ"               COLOR &grid
@22,78 SAY " "               COLOR &border
@22,78 SAY ""               COLOR &border

@23,40 SAY ""               COLOR &border  && bottom
@23,41 SAY ""               COLOR &border
@23,42 SAY REPLICATE(" ",35) COLOR &border
@23,77 SAY ""               COLOR &border
@23,78 SAY CHR(249)          COLOR &border
RETURN


* Color Browse WINDOW (Window attributes)
* อออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_BROWS2
*!
*!*********************************************************************
PROCEDURE e_brows2
GOTO 1                                      && go to user window rec

m.disabled = TRIM(one)                      && other records
m.enabled  = TRIM(two)                      && current field
m.border   = TRIM(three)
m.ttl_actv = TRIM(four)
m.message  = TRIM(five)                     && title, idle
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)                    && current record
m.shadow   = TRIM(eight)
*                                  && Bkgd CP3/Bkgd CP1
m.grid     = TRIM(SUBSTR(three,AT("/",three)+1))+"/"+;
  TRIM(SUBSTR(one,AT("/",one)+1))
*                                  && Bkgd CP7/Bkgd CP1
m.marked   = TRIM(SUBSTR(seven,AT("/",seven)+1))+"/"+;
  TRIM(SUBSTR(one,AT("/",one)+1))

ACTIVATE SCREEN

IF m.back_shdw
  @15,41 FILL TO 22,79 COLOR &usr_shdw        && simulate shadow
ELSE
  * Only clear through line 22 so that you don't overwrite status bar
  @15,41 CLEAR TO 22,79
ENDIF

@13,40 FILL TO 21,78 COLOR &disabled

@13,40 SAY "þ"               COLOR &border  && top line
@13,41 SAY REPLICATE(" ",38) COLOR &border
@13,52 SAY "BROWSE WINDOW"   COLOR &ttl_actv
@13,78 SAY "๐"               COLOR &border

@14,40 SAY " "               COLOR &border  && lt/rt
@14,42 SAY "Field1"          COLOR &disabled && field names
@14,49 SAY "ณ"               COLOR &grid
@14,51 SAY "Field2"          COLOR &disabled
@14,58 SAY "ณ"               COLOR &grid
@14,60 SAY "Field3"          COLOR &disabled
@14,67 SAY "ณ"               COLOR &grid
@14,69 SAY "Field4"          COLOR &disabled
@14,78 SAY ""               COLOR &border

@15,40 SAY " "               COLOR &border
@15,41 SAY REPLICATE("อ",38) COLOR &grid
@15,49 SAY "ุ"               COLOR &grid
@15,58 SAY "ุ"               COLOR &grid
@15,67 SAY "ุ"               COLOR &grid
@15,78 SAY " "               COLOR &border

@16,40 SAY " "               COLOR &border  && 1st record
@16,42 SAY "Other"           COLOR &disabled
@16,49 SAY "ณ"               COLOR &grid
@16,50 SAY "Data"            COLOR &disabled
@16,58 SAY "ณ"               COLOR &grid
@16,67 SAY "ณ"               COLOR &grid
@16,69 SAY "Data"            COLOR &disabled
@16,78 SAY " "               COLOR &border

@17,40 SAY " "               COLOR &border  && 2nd record
@17,42 SAY "Cur rec    "     COLOR &hotkey  && pointer is
@17,49 SAY "ณ"               COLOR &grid    && on this
@17,50 SAY "Data    "        COLOR &hotkey  && record.
@17,58 SAY "ณ"               COLOR &grid    && cursor is
@17,59 SAY "Cur. "           COLOR &chosen  && on the 3rd
@17,64 SAY "fld"             COLOR &enabled && field
@17,67 SAY "ณ"               COLOR &grid
@17,78 SAY CHR(4)            COLOR &border

@18,40 SAY " "               COLOR &border  && 3rd record
@18,41 SAY CHR(4)            COLOR &marked
@18,42 SAY "Marked"          COLOR &disabled
@18,49 SAY "ณ"               COLOR &grid
@18,50 SAY "for"             COLOR &disabled
@18,58 SAY "ณ"               COLOR &grid
@18,59 SAY "Deletion"        COLOR &disabled
@18,67 SAY "ณ"               COLOR &grid
@18,78 SAY " "               COLOR &border

@19,40 SAY " "               COLOR &border  && 1st record
@19,42 SAY "Other"           COLOR &disabled
@19,49 SAY "ณ"               COLOR &grid
@19,50 SAY "Data"            COLOR &disabled
@19,58 SAY "ณ"               COLOR &grid
@19,67 SAY "ณ"               COLOR &grid
@19,78 SAY " "               COLOR &border

@20,40 SAY " "               COLOR &border  && 1st record
@20,42 SAY "Other"           COLOR &disabled
@20,49 SAY "ณ"               COLOR &grid
@20,50 SAY "Data"            COLOR &disabled
@20,58 SAY "ณ"               COLOR &grid
@20,67 SAY "ณ"               COLOR &grid
@20,78 SAY ""               COLOR &border

@21,40 SAY ""               COLOR &border  && bottom line
@21,41 SAY ""               COLOR &border
@21,42 SAY REPLICATE(" ",37) COLOR &border
@21,77 SAY ""               COLOR &border
@21,78 SAY CHR(249)          COLOR &border
RETURN


* Color the Report Writer (Color Scheme 11)
* อออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_REPORT
*!
*!*********************************************************************
PROCEDURE e_report

GOTO 11                                     && go to report wrtr rec
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.text_b   = TRIM(one)
m.rpt_fld  = TRIM(two)
m.border   = TRIM(three)
m.ttl_actv = TRIM(four)
m.message  = TRIM(five)                     && title, idle
m.chosen   = TRIM(six)
m.a_empty  = TRIM(seven)
m.shadow   = TRIM(eight)
m.a_full   = TRIM(nine)
m.b_empty  = TRIM(ten)

SET COLOR OF SCHEME 11 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

ACTIVATE SCREEN

IF m.back_shdw
  @ 3,42 FILL TO 12,79 COLOR &usr_shdw
ELSE
  @ 3,42 CLEAR TO 12,79
ENDIF                                       (m.Back_shdw)

@ 2,40 FILL TO 11,78 COLOR &text_b

@ 2,40 SAY "þ"               COLOR &border
@ 2,41 SAY REPLICATE(" ",37) COLOR &border
@ 2,47 SAY "RPT_ACTV.FRX/"   COLOR &ttl_actv
@ 2,60 SAY "RPT_IDLE.FRX"    COLOR &message
@ 2,78 SAY "๐"               COLOR &border

@ 3,40 SAY " "               COLOR &border

@ 3,41 SAY " R:  4 C: 17 บ  Move บ  Page Header บ";
  COLOR &a_full

@ 3,78 SAY " "               COLOR &border

@ 4,40 SAY " "               COLOR &border
@ 4,41 SAY " PgHead "        COLOR &text_b
@ 4,60 SAY "Report Title"    COLOR &text_b
@ 4,49 SAY " "               COLOR &a_full
@ 4,78 SAY " "               COLOR &border

@ 5,40 SAY " "               COLOR &border
@ 5,41 SAY " PgHead "        COLOR &text_b
@ 5,49 SAY " "               COLOR &a_full
@ 5,78 SAY " "               COLOR &border

@ 6,40 SAY " "               COLOR &border
@ 6,42 SAY "Detail "         COLOR &a_full
@ 6,49 SAY "ฑ"               COLOR &a_full
@ 6,51 SAY "Report field"    COLOR &rpt_fld
@ 6,69 SAY "Selected"        COLOR &chosen
@ 6,78 SAY " "               COLOR &border

@ 7,40 SAY " "               COLOR &border
@ 7,42 SAY "Detail "         COLOR &a_empty
@ 7,49 SAY "ฑ"               COLOR &a_full
@ 7,78 SAY " "               COLOR &border

@ 8,40 SAY " "               COLOR &border
@ 8,42 SAY "PgFoot "         COLOR &b_empty
@ 8,49 SAY " "               COLOR &a_full
@ 8,78 SAY " "               COLOR &border

@ 9,40 SAY " "               COLOR &border
@ 9,41 SAY REPLICATE(" ",37) COLOR &a_full
@ 9,78 SAY " "               COLOR &border

@10,40 SAY " "               COLOR &border
@10,41 SAY REPLICATE("ฑ",37) COLOR &text_b
@10,78 SAY " "               COLOR &border

@11,40 SAY " "               COLOR &border
@11,41 SAY ""               COLOR &border
@11,42 SAY CHR(4)            COLOR &border
@11,43 SAY REPLICATE(" ",34) COLOR &border
@11,77 SAY ""               COLOR &border
@11,78 SAY CHR(249)          COLOR &border
RETURN


* Color the Alert Popups (Color Scheme 12)
* ออออออออออออออออออออออออออออออออออออออออ
*!*********************************************************************
*!
*!      Procedure: E_ALERTP
*!
*!*********************************************************************
PROCEDURE e_alertp

GOTO 12                                     && go to dialog popup rec
replace SHADOW WITH IIF(m.back_shdw,"+","-")

m.disabled = TRIM(one)
m.enabled  = TRIM(two)
m.border   = TRIM(three)
m.chosen   = TRIM(six)
m.hotkey   = TRIM(seven)
m.shadow   = TRIM(eight)

SET COLOR OF SCHEME 12 TO (clr->one)+','+(clr->two)+','+(clr->three)+','+;
  (clr->four)+','+(clr->five)+','+(clr->six)+','+(clr->seven)+','+(clr->eight)+','+;
  (clr->nine)+','+(clr->ten)+','+(clr->shadow)

IF m.back_shdw
  DEFINE WINDOW walertpop FROM 19,24 TO 23,36;
    SHADOW;
    COLOR &disabled,&enabled,&border,,,&chosen,&hotkey,;
    &shadow,,,+
ELSE
  DEFINE WINDOW walertpop FROM 19,24 TO 23,36;
    COLOR &disabled,&enabled,&border,,,&chosen,&hotkey,;
    &shadow,,,-
ENDIF                                       (m.Back_shdw)

ACTIVATE WINDOW walert
ACTIVATE WINDOW walertpop
@ 0, 0 SAY "  "          COLOR &enabled
@ 0, 2 SAY "E"           COLOR &hotkey
@ 0, 3 SAY "nabled  "    COLOR &enabled
@ 1, 0 SAY "  Selected " COLOR &chosen
@ 2, 0 SAY "  Disabled " COLOR &disabled
RETURN



*!*********************************************************************
*!
*!      Procedure: COLORWIN
*!
*!*********************************************************************
PROCEDURE colorwin
DEFINE WINDOW wcolors FROM 1, 0 TO 23,39;
  FLOAT ;
  TITLE "OBJECT: "+m.group+"  "+"PART: "+m.to_color;
  "ฑ" COLOR ,,W/B
*  
*  ณ
*  Border character
RETURN

*!*********************************************************************
*!
*!      Procedure: ACTWIN
*!
*!*********************************************************************
FUNCTION actwin
* Activate window wind_name

PARAMETER wind_name
PRIVATE ALL
wind_name = UPPER(ALLTRIM(m.wind_name))
IF !EMPTY(m.wind_name) AND WEXIST(m.wind_name)
  ACTIVATE WINDOW (m.wind_name)
ENDIF
RETURN ''


*!*********************************************************************
*!
*!      Procedure: ALERT
*!
*!*********************************************************************
PROCEDURE alert
* Display an error message, automatically sizing the message window
*    as necessary.  Semicolons in "strg" mean "new line".
PARAMETERS strg
PRIVATE ALL

in_talk = SET('TALK')
SET TALK OFF
in_cons = SET('CONSOLE')

m.numlines = OCCURS(';',m.strg) + 1

DIMENSION alert_arry[m.Numlines]
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
keycode = INKEY(0,'HM')
SET CONSOLE ON

RELEASE WINDOW alert

IF m.in_talk = "ON"
  SET TALK ON
ENDIF
IF m.in_cons = "OFF"
  SET CONSOLE OFF
ENDIF
RETURN

*!*********************************************************************
*!
*!      Procedure: GETROWCOL
*!
*!          Calls: NUM2WRD        (procedure in PROCOLOR.PRG)
*!
*!*********************************************************************
PROCEDURE getrowcol
* Get the row and column coordinates given a color string
PARAMETERS c_object, ret_row, ret_col
PRIVATE c_object, clrstrg

m.clrstrg = (EVAL("clr->"+num2wrd(m.c_object)))

m.clrstrg = UPPER(ALLTRIM(CHRTRAN(m.clrstrg,'*','')))

* Default values of row and column
m.ret_row = 1
m.ret_col = 2
FOR i = 1 TO 19                             && scan down the rows ...
  FOR j = 1 TO 8                              && ... and across the columns
    IF clrarry[i,j] == m.clrstrg
      m.ret_row = i
      m.ret_col = j
      RETURN
    ENDIF
  ENDFOR
ENDFOR
RETURN


*!*********************************************************************
*!
*!      Procedure: DEFCLRARRAY
*!
*!*********************************************************************
PROCEDURE defclrarray
* Define the color row/col array
PUBLIC clrarry[19,8]

clrarry[ 1, 1]="N/N"                        &&       black/black
clrarry[ 2, 1]="B/N"                        &&        blue/black
clrarry[ 3, 1]="G/N"                        &&       green/black
clrarry[ 4, 1]="BG/N"                       &&        cyan/black
clrarry[ 5, 1]="R/N"                        &&         red/black
clrarry[ 6, 1]="RB/N"                       &&     magenta/black
clrarry[ 7, 1]="GR/N"                       &&       brown/black
clrarry[ 8, 1]="W/N"                        &&       white/black
clrarry[ 9, 1]="N+/N"                       &&   brt black/black
clrarry[10, 1]="B+/N"                       &&    brt blue/black
clrarry[11, 1]="G+/N"                       &&   brt green/black
clrarry[12, 1]="BG+/N"                      &&    brt cyan/black
clrarry[13, 1]="R+/N"                       &&     brt red/black
clrarry[14, 1]="RB+/N"                      && brt magenta/black
clrarry[15, 1]="GR+/N"                      &&      yellow/black
clrarry[16, 1]="W+/N"                       &&   brt white/black

clrarry[ 1, 2]="N/B"                        &&       black/blue
clrarry[ 2, 2]="B/B"                        &&        blue/blue
clrarry[ 3, 2]="G/B"                        &&       green/blue
clrarry[ 4, 2]="BG/B"                       &&        cyan/blue
clrarry[ 5, 2]="R/B"                        &&         red/blue
clrarry[ 6, 2]="RB/B"                       &&     magenta/blue
clrarry[ 7, 2]="GR/B"                       &&       brown/blue
clrarry[ 8, 2]="W/B"                        &&       white/blue
clrarry[ 9, 2]="N+/B"                       &&   brt black/blue
clrarry[10, 2]="B+/B"                       &&    brt blue/blue
clrarry[11, 2]="G+/B"                       &&   brt green/blue
clrarry[12, 2]="BG+/B"                      &&    brt cyan/blue
clrarry[13, 2]="R+/B"                       &&     brt red/blue
clrarry[14, 2]="RB+/B"                      && brt magenta/blue
clrarry[15, 2]="GR+/B"                      &&      yellow/blue
clrarry[16, 2]="W+/B"                       &&   brt white/blue

clrarry[ 1, 3]="N/G"                        &&       black/green
clrarry[ 2, 3]="B/G"                        &&        blue/green
clrarry[ 3, 3]="G/G"                        &&       green/green
clrarry[ 4, 3]="BG/G"                       &&        cyan/green
clrarry[ 5, 3]="R/G"                        &&         red/green
clrarry[ 6, 3]="RB/G"                       &&     magenta/green
clrarry[ 7, 3]="GR/G"                       &&       brown/green
clrarry[ 8, 3]="W/G"                        &&       white/green
clrarry[ 9, 3]="N+/G"                       &&   brt black/green
clrarry[10, 3]="B+/G"                       &&    brt blue/green
clrarry[11, 3]="G+/G"                       &&   brt green/green
clrarry[12, 3]="BG+/G"                      &&    brt cyan/green
clrarry[13, 3]="R+/G"                       &&     brt red/green
clrarry[14, 3]="RB+/G"                      && brt magenta/green
clrarry[15, 3]="GR+/G"                      &&      yellow/green
clrarry[16, 3]="W+/G"                       &&   brt white/green

clrarry[ 1, 4]="N/BG"                       &&       black/cyan
clrarry[ 2, 4]="B/BG"                       &&        blue/cyan
clrarry[ 3, 4]="G/BG"                       &&       green/cyan
clrarry[ 4, 4]="BG/BG"                      &&        cyan/cyan
clrarry[ 5, 4]="R/BG"                       &&         red/cyan
clrarry[ 6, 4]="RB/BG"                      &&     magenta/cyan
clrarry[ 7, 4]="GR/BG"                      &&       brown/cyan
clrarry[ 8, 4]="W/BG"                       &&       white/cyan
clrarry[ 9, 4]="N+/BG"                      &&   brt black/cyan
clrarry[10, 4]="B+/BG"                      &&    brt blue/cyan
clrarry[11, 4]="G+/BG"                      &&   brt green/cyan
clrarry[12, 4]="BG+/BG"                     &&    brt cyan/cyan
clrarry[13, 4]="R+/BG"                      &&     brt red/cyan
clrarry[14, 4]="RB+/BG"                     && brt magenta/cyan
clrarry[15, 4]="GR+/BG"                     &&      yellow/cyan
clrarry[16, 4]="W+/BG"                      &&   brt white/cyan

clrarry[ 1, 5]="N/R"                        &&       black/red
clrarry[ 2, 5]="B/R"                        &&        blue/red
clrarry[ 3, 5]="G/R"                        &&       green/red
clrarry[ 4, 5]="BG/R"                       &&        cyan/red
clrarry[ 5, 5]="R/R"                        &&         red/red
clrarry[ 6, 5]="RB/R"                       &&     magenta/red
clrarry[ 7, 5]="GR/R"                       &&       brown/red
clrarry[ 8, 5]="W/R"                        &&       white/red
clrarry[ 9, 5]="N+/R"                       &&   brt black/red
clrarry[10, 5]="B+/R"                       &&    brt blue/red
clrarry[11, 5]="G+/R"                       &&   brt green/red
clrarry[12, 5]="BG+/R"                      &&    brt cyan/red
clrarry[13, 5]="R+/R"                       &&     brt red/red
clrarry[14, 5]="RB+/R"                      && brt magenta/red
clrarry[15, 5]="GR+/R"                      &&      yellow/red
clrarry[16, 5]="W+/R"                       &&   brt white/red

clrarry[ 1, 6]="N/RB"                       &&       black/magenta
clrarry[ 2, 6]="B/RB"                       &&        blue/magenta
clrarry[ 3, 6]="G/RB"                       &&       green/magenta
clrarry[ 4, 6]="BG/RB"                      &&        cyan/magenta
clrarry[ 5, 6]="R/RB"                       &&         red/magenta
clrarry[ 6, 6]="RB/RB"                      &&     magenta/magenta
clrarry[ 7, 6]="GR/RB"                      &&       brown/magenta
clrarry[ 8, 6]="W/RB"                       &&       white/magenta
clrarry[ 9, 6]="N+/RB"                      &&   brt black/magenta
clrarry[10, 6]="B+/RB"                      &&    brt blue/magenta
clrarry[11, 6]="G+/RB"                      &&   brt green/magenta
clrarry[12, 6]="BG+/RB"                     &&    brt cyan/magenta
clrarry[13, 6]="R+/RB"                      &&     brt red/magenta
clrarry[14, 6]="RB+/RB"                     && brt magenta/magenta
clrarry[15, 6]="GR+/RB"                     &&      yellow/magenta
clrarry[16, 6]="W+/RB"                      &&   brt white/magenta

clrarry[ 1,7]="N/GR"                        &&       black/brown
clrarry[ 2,7]="B/GR"                        &&        blue/brown
clrarry[ 3,7]="G/GR"                        &&       green/brown
clrarry[ 4,7]="BG/GR"                       &&        cyan/brown
clrarry[ 5,7]="R/GR"                        &&         red/brown
clrarry[ 6,7]="RB/GR"                       &&     magenta/brown
clrarry[ 7,7]="GR/GR"                       &&       brown/brown
clrarry[ 8,7]="W/GR"                        &&       white/brown
clrarry[ 9,7]="N+/GR"                       &&   brt black/brown
clrarry[10,7]="B+/GR"                       &&    brt blue/brown
clrarry[11,7]="G+/GR"                       &&   brt green/brown
clrarry[12,7]="BG+/GR"                      &&    brt cyan/brown
clrarry[13,7]="R+/GR"                       &&     brt red/brown
clrarry[14,7]="RB+/GR"                      && brt magenta/brown
clrarry[15,7]="GR+/GR"                      &&      yellow/brown
clrarry[16,7]="W+/GR"                       &&   brt white/brown

clrarry[ 1,8]="N/W"                         &&       black/white
clrarry[ 2,8]="B/W"                         &&        blue/white
clrarry[ 3,8]="G/W"                         &&       green/white
clrarry[ 4,8]="BG/W"                        &&        cyan/white
clrarry[ 5,8]="R/W"                         &&         red/white
clrarry[ 6,8]="RB/W"                        &&     magenta/white
clrarry[ 7,8]="GR/W"                        &&       brown/white
clrarry[ 8,8]="W/W"                         &&       white/white
clrarry[ 9,8]="N+/W"                        &&   brt black/white
clrarry[10,8]="B+/W"                        &&    brt blue/white
clrarry[11,8]="G+/W"                        &&   brt green/white
clrarry[12,8]="BG+/W"                       &&    brt cyan/white
clrarry[13,8]="R+/W"                        &&     brt red/white
clrarry[14,8]="RB+/W"                       && brt magenta/white
clrarry[15,8]="GR+/W"                       &&      yellow/white
clrarry[16,8]="W+/W"                        &&   brt white/white
RETURN


*!*********************************************************************
*!
*!      Procedure: NUM2WRD
*!
*!*********************************************************************
FUNCTION num2wrd
PARAMETER num
PRIVATE ALL
m.strg = ''
DO CASE
CASE m.num = 1
  m.strg = "ONE"
CASE m.num = 2
  m.strg = "TWO"
CASE m.num = 3
  m.strg = "THREE"
CASE m.num = 4
  m.strg = "FOUR"
CASE m.num = 5
  m.strg = "FIVE"
CASE m.num = 6
  m.strg = "SIX"
CASE num = 7
  m.strg = "SEVEN"
CASE m.num = 8
  m.strg = "EIGHT"
CASE m.num = 9
  m.strg = "NINE"
CASE m.num = 10
  m.strg = "TEN"
ENDCASE
RETURN m.strg


*!*********************************************************************
*!
*!      Procedure: WRD2NUM
*!
*!*********************************************************************
FUNCTION wrd2num
PARAMETER wrd
PRIVATE ALL
m.wrd = UPPER(ALLTRIM(m.wrd))
m.num = 0
DO CASE
CASE m.wrd == "ONE"
  m.num = 1
CASE m.wrd == "TWO"
  m.num = 2
CASE m.wrd == "THREE"
  m.num = 3
CASE m.wrd == "FOUR"
  m.num = 4
CASE m.wrd == "FIVE"
  m.num = 5
CASE m.wrd == "SIX"
  m.num = 6
CASE m.wrd == "SEVEN"
  m.num = 7
CASE m.wrd == "EIGHT"
  m.num = 8
CASE m.wrd == "NINE"
  m.num = 9
CASE m.wrd == "TEN"
  m.num = 10
ENDCASE
RETURN m.num
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


*!*********************************************************************
*!
*!      Procedure: SETEXIST
*!
*!*********************************************************************

FUNCTION setexist
PARAMETER setname
PRIVATE ALL
* Returns .T. if the named color set is in the current resource file

res_stat = SET('RESOURCE')
IF res_stat = 'OFF'
   RETURN .F.
ELSE   
   resname = SET('RESOURCE',1)
   in_area = SELECT()
   SET RESOURCE OFF
   resstem = juststem(resname)
   IF USED(resstem)
      SELECT (resstem)
      newdbf = .F.
   ELSE
      SELECT 0
      USE (resname)
      newdbf = .T.
   ENDIF
   LOCATE FOR ALLTRIM(type) =="PREF2.5" ;
       and ALLTRIM(id)      =="COLORSET";
       and UPPER(ALLTRIM(name)) == UPPER(ALLTRIM(setname))
   ret_val = FOUND()
   IF newdbf
      USE
   ENDIF  
   
   SET RESOURCE TO (resname)  
   SELECT (in_area)
   IF res_stat = 'ON'
      SET RESOURCE ON
   ELSE
      SET RESOURCE OFF
   ENDIF
   RETURN ret_val    
ENDIF


*: EOF: PROCOLOR.PRG
