*:*********************************************************************
*:
*: Procedure file: C:\FOXPRO2\SNIPFMT\SNIP.PRG
*:
*:         System: SnipFmt
*:         Author: Walter J. Kennamer
*:      Copyright (c) 1991, Fox Holdings, Inc.
*:  Last modified: 05/05/91      2:22
*:
*:  Procs & Fncts: BAILOUT
*:               : JUSTEXT()
*:               : FMT
*:               : WORDS
*:               : WORDNUM
*:               : DELFILE
*:
*:          Calls: BAILOUT        (procedure in SNIP.PRG)
*:               : ALERT.PRG
*:               : JUSTEXT()      (function  in SNIP.PRG)
*:               : FMT            (procedure in SNIP.PRG)
*:
*:           Uses: KEYWORDS.DBF   
*:               : SNIPTEMP.DBF   
*:
*:        Indexes: KEYNAME        (tag)
*:
*:    Other Files: PROWORDS.FXD
*:
*:      Documented 05/16/91 at 16:07               FoxDoc  version 2.07á
*:*********************************************************************
* Limitations: SNIPFMT does not support the use of brackets as quote marks

CREATE VIEW snipfmt
SET TALK OFF
in_error = ON('ERROR')
ON ERROR
CLOSE ALL
SET SAFETY OFF
SET BELL OFF
SET DELETED ON
SET NOTIFY ON
SET EXACT ON
CLEAR

PUBLIC spacetab, saveall, caseind, procind, filemode, abort, usetab, ;
   keywrdcap, varcap, fname

* Main dialog
document = 2
DO snipfmt.spr

IF document = 2   && set by "Document/Cancel" button in SNIPFMT.SPR
   WAIT WINDOW "Normal termination" NOWAIT
   DO bailout
ENDIF

saveall   = .F.          && save all snippets without prompting?
filemode  = ''           && screen or menu file
abort     = .F.          && abnormal termination?

m.keyfname = SYS(2004)+'PROWORDS.FXD'
IF !FILE(m.keyfname)
   m.keyfname = LOCFILE('PROWORDS.FXD','FXD','Locate the PROWORDS.FXD file')
   IF EMPTY(keyfname)
      m.abort = .T.
      DO bailout
   ENDIF
ENDIF

IF FILE(m.keyfname)
   WAIT WINDOW 'Retrieving key words' NOWAIT
   CREATE TABLE keywords (keyname C(20))
   ZAP
   APPEND FROM (keyfname) SDF
   DELETE FOR INLIST(LEFT(keyname,1),'*') OR EMPTY(keyname)
   REPLACE ALL keyname WITH SUBSTR(keyname,2) FOR INLIST(LEFT(keyname,1),'%','!','@')
   PACK
   INDEX ON keyname TAG keyname
   WAIT CLEAR

   CREATE TABLE sniptemp (snipmemo m)
   APPEND BLANK
ELSE
   DO alert WITH "Could not find PROWORDS.FXD file.;Press any key to quit."
   m.abort = .T.
   DO bailout
ENDIF

* Document the code in a group of files, if this is a project, or an
* individual file if fname isn't a project.
IF justext(fname) = 'PJX'
   SELECT 0
   USE (fname) AGAIN ALIAS pjxfile
   LOCATE FOR pjxfile->TYPE = "H"
   IF FOUND()
      s_homedir = CHRTRAN(pjxfile->homedir,CHR(0),'')
   ELSE
      WAIT WINDOW "Error reading &fname."
      DO bailout
   ENDIF
   GOTO TOP
   SCAN
      f_ext = UPPER(justext(ALLTRIM(pjxfile->name)))
      IF INLIST(f_ext,'PRG','SCX','MNX')
         WAIT WINDOW "Documenting "+justfname(ALLTRIM(pjxfile->name)) NOWAIT
         DO fmtfile WITH addbs(ALLTRIM(s_homedir))+ALLTRIM(pjxfile->name)
      ENDIF
      SELECT pjxfile
   ENDSCAN
ELSE
   DO fmtfile WITH fname
ENDIF

abort = .F.    &&  ready for normal termination
DO bailout

*!*****************************************************************
*!
*!      Procedure: FMTFILE
*!
*!*****************************************************************
PROCEDURE fmtfile
* Document the code in a particular file
parameter fname
IF EMPTY(m.fname)  && chosen in SNIPFMT.SPR
   DO bailout
ENDIF
DO CASE
CASE justext(m.fname) = 'PRG'
   filemode = 'PROGRAM'
CASE justext(m.fname) = 'SCX'
   filemode = 'SCREEN'
CASE justext(m.fname) = 'MNX'
   filemode = 'MENU'
OTHERWISE
   DO alert WITH m.fname + " is an unknown file type.;The file must be an SCX or MNX file."
   abort = .T.
   DO bailout
ENDCASE

IF filemode = 'PROGRAM'
   DO fmt WITH m.fname
ELSE
   IF !EMPTY(m.fname)
      SELECT 0
      USE (m.fname) ALIAS snipfile
   ELSE
      DO alert WITH "Filename not specified"    && should never happen
      m.abort = .T.
      DO bailout
   ENDIF

   SCAN         && scan through the SCX/MNX database looking for snippets
      DO CASE
      CASE m.filemode = 'SCREEN'
         SELECT snipfile
         IF !EMPTY(VALID)
            DO fmt WITH "VALID"
         ENDIF
         IF !EMPTY(WHEN)
            DO fmt WITH "WHEN"
         ENDIF
         IF !EMPTY(proccode)
            DO fmt WITH "PROCCODE"
         ENDIF
         IF !EMPTY(setupcode)
            DO fmt WITH "SETUPCODE"
         ENDIF
         IF !EMPTY(ERROR)
            DO fmt WITH "ERROR"
         ENDIF
         IF !EMPTY(MESSAGE)
            DO fmt WITH "MESSAGE"
         ENDIF
         IF !EMPTY(SHOW)
            DO fmt WITH "SHOW"
         ENDIF
         IF !EMPTY(ACTIVATE)
            DO fmt WITH "ACTIVATE"
         ENDIF
         IF !EMPTY(DEACTIVATE)
            DO fmt WITH "DEACTIVATE"
         ENDIF

      CASE m.filemode = 'MENU'
         SELECT snipfile
         IF !EMPTY(COMMAND)
            DO fmt WITH "COMMAND"
         ENDIF
         IF !EMPTY(PROCEDURE)
            DO fmt WITH "PROCEDURE"
         ENDIF
         IF !EMPTY(setup)
            DO fmt WITH "SETUP"
         ENDIF
         IF !EMPTY(cleanup)
            DO fmt WITH "CLEANUP"
         ENDIF
      ENDCASE
   ENDSCAN
   USE   && close snipfile
ENDIF

*!*****************************************************************
*!
*!      Procedure: FMT
*!
*!*****************************************************************
PROCEDURE fmt
PARAMETERS snipname
* Document the code in a particular snippet

* The characters in this string delimit words in the command statement
break_str = ' +-/\*$#@()[]{}^%!=<>,;'

DO CASE
CASE filemode == 'PROGRAM'
   msg = "Documenting "+snipname
   IF FILE(snipname)
      COPY FILE (snipname) TO sniptemp.prg
   ELSE
      DO alert WITH snipname+';could not be found.'
      abort = .T.
      DO bailout
   ENDIF
CASE filemode == 'SCREEN'
   IF !EMPTY(name)
      msg = "Documenting "+PROPER(snipname)+" for "+name
   ELSE
      msg = "Documenting "+PROPER(snipname)
   ENDIF
   COPY MEMO (snipname) TO sniptemp.prg
CASE filemode == 'MENU'
   IF !EMPTY(PROMPT)
      msg = "Documenting "+PROPER(snipname)+" for ";
         +PROPER(CHRTRAN(PROMPT,'\?!<',''))
   ELSE
      msg = "Documenting "+PROPER(snipname)
   ENDIF
   COPY MEMO (snipname) TO sniptemp.prg
ENDCASE

fp = FOPEN('SNIPTEMP.PRG',0)
IF fp < 0
   DO alert WITH "Error "+ALLTRIM(STR(fp,4))+" opening SNIPTEMP.PRG"
   abort = .T.
   DO bailout
ENDIF

fp_out = FCREATE("SNIPTEMP.NEW",0)
IF fp_out < 0
   DO alert WITH "Error creating SNIPTEMP.NEW"
   abort = .T.
   DO bailout
ENDIF

thislevel = 0      && number of tab stops to indent
nextlevel = 0      && number of tab stops for next line
iscontin  = .F.    && is this line a continuation line?
hascontin = .F.    && does this line have a continuation?

gtlinecnt = 0     && grand total line count
WAIT WINDOW msg NOWAIT
DO WHILE !FEOF(fp)
   gtlinecnt = gtlinecnt + 1

   * Display status 
   IF gtlinecnt % 20 = 0
      WAIT WINDOW msg + 'ÄÄ'+ALLTRIM(STR(gtlinecnt,6))+' lines' NOWAIT
   ENDIF

   s = FGETS(fp)

   * Write the comment as is, but don't echo earlier SNIPFMT headings.
   * Also, bypass template statements.
   firstchars = LEFT(ALLTRIM(s),2)
   IF LEFT(firstchars,1) = '*' OR firstchars == CHR(38)+CHR(38) ;
         OR UPPER(wordnum(s,1)) == 'NOTE' OR LEFT(firstchars,1) = '\'

      IF firstchars <> '*!'
         numbytes = FPUTS(fp_out,s)
      ENDIF
      LOOP
   ENDIF

   s = STRTRAN(s,CHR(9),SPACE(spacetab)) && convert tabs to spaces
   s = ALLTRIM(s)

   cmtpos = AT(CHR(38)+CHR(38),s)        && double ampersand
   IF cmtpos = 0
      cmtpos = 10000        && fake a big value for the comment position
   ENDIF

   * Scan the statement, capitalizating/lower-casing words as appropriate
   i = 1
   DO WHILE i <= LEN(s) AND i < cmtpos
      * Skip opening break characters
      DO WHILE i <= LEN(s) AND SUBSTR(s,i,1) $ break_str
         i = i + 1
      ENDDO

      * Skip over any quoted strings
      indblquote = .F.
      insngquote = .F.
      DO CASE
      CASE SUBSTR(s,i,1) = '"'
         indblquote = .T.
         i = i + 1
      CASE SUBSTR(s,i,1) = "'"
         insngquote = .T.
         i = i + 1
      ENDCASE
      DO WHILE insngquote AND i <= LEN(s) AND SUBSTR(s,i,1) <> "'"
         i = i + 1
      ENDDO
      DO WHILE indblquote AND i <= LEN(s) AND SUBSTR(s,i,1) <> '"'
         i = i + 1
      ENDDO

      * Skip past the closing quotation mark
      IF (insngquote OR indblquote) ;
            AND SUBSTR(s,i,1) $ (CHR(34) + CHR(39))
         i = i + 1
      ENDIF

      * Skip any break characters following the quoted string
      DO WHILE i <= LEN(s) AND SUBSTR(s,i,1) $ break_str
         i = i + 1
      ENDDO

      * Extract the next word
      word_start = i
      DO WHILE i <= LEN(s) AND !(SUBSTR(s,i,1) $ break_str) ;
            AND ! (SUBSTR(s,i,1) $ CHR(34) + CHR(39))
         i = i + 1
      ENDDO
      thisword = SUBSTR(s,word_start,i - word_start)

      * Capitalize or lower case the word, as appropriate
      IF i < cmtpos     && don't change capitalization of comments
         * Allow for abbreviations
         IF !EMPTY(thisword) AND LEN(thisword) < 4
            * Pad so that it will match during the SEEK()
            thisword = PADR(thisword,4)
         ENDIF

         IF !EMPTY(thisword) AND SEEK(UPPER(thisword),"KEYWORDS")
            DO CASE
            CASE keywrdcap = 1
               thisword = ALLTRIM(UPPER(thisword))
            CASE keywrdcap = 2
               thisword = ALLTRIM(LOWER(thisword))
            ENDCASE
         ELSE
            DO CASE
            CASE varcap = 1
               thisword = ALLTRIM(UPPER(thisword))
            CASE varcap = 2
               thisword = ALLTRIM(LOWER(thisword))
            ENDCASE
         ENDIF
      ENDIF

      * Advance the string index past this word
      DO CASE
      CASE word_start = 1
         s = thisword + SUBSTR(s,i)
      CASE i > LEN(s)
         s = SUBSTR(s,1,word_start-1)+thisword
      OTHERWISE
         s = SUBSTR(s,1,word_start-1)+thisword+SUBSTR(s,i)
      ENDCASE

   ENDDO

   * Indent the statement, if necessary
   IF !EMPTY(s)
      iscontin  = hascontin      && is this line itself a continuation?
      hascontin = RIGHT(TRIM(s),1) = ';'

      word1 = UPPER(wordnum(s,1))
      word2 = UPPER(wordnum(s,2))

      thislevel = nextlevel
      DO CASE
      CASE INLIST(word1,'IF','FOR','SCAN')
         nextlevel = thislevel + 1
      CASE word1 = 'CASE' OR word1 = 'OTHERWISE'
         thislevel = thislevel - 1
         nextlevel = thislevel + 1
      CASE INLIST(word1,'ENDIF','ENDDO','ENDFOR','NEXT','ENDSCAN')
         thislevel = thislevel - 1
         nextlevel = thislevel
      CASE word1 = 'DO' AND word2 = 'WHILE'
         nextlevel = thislevel + 1
      CASE word1 = 'DO' AND word2 = 'CASE'
         nextlevel = thislevel + 1
         IF caseind    && add an extra indent
            nextlevel = nextlevel + 1
         ENDIF
      CASE word1 = 'ELSE'
         thislevel = thislevel - 1
         nextlevel = thislevel + 1
      CASE word1 = 'ENDCASE'
         thislevel = thislevel - 1
         nextlevel = thislevel
         IF caseind      && take back the extra indent
            thislevel = thislevel - 1
            nextlevel = thislevel
         ENDIF
      ENDCASE

      DO CASE
      CASE hascontin AND !iscontin
         nextlevel = nextlevel + 1        && extra indent for continuations
      CASE iscontin AND !hascontin
         nextlevel = thislevel - 1        && take the indent back
      ENDCASE
      thislevel = MAX(thislevel,0)
      nextlevel = MAX(nextlevel,0)

      IF word1 == 'PROCEDURE' OR word1 == 'FUNCTION'
         = FPUTS(fp_out,'*!'+REPLICATE('*',65))
         = FPUTS(fp_out,'*!')
         IF word1 == 'PROCEDURE'
            = FPUTS(fp_out,'*!      Procedure: '+UPPER(wordnum(s,2)))
         ELSE
            = FPUTS(fp_out,'*!       Function: '+UPPER(wordnum(s,2)))
        ENDIF   
         = FPUTS(fp_out,'*!')
         = FPUTS(fp_out,'*!'+REPLICATE('*',65))
         thislevel = 0
         nextlevel = IIF(procind,1,0)
      ENDIF

      IF usetab
         s = REPLICATE(CHR(9),thislevel)+LTRIM(s)
      ELSE
         s = REPLICATE(SPACE(spacetab),thislevel)+LTRIM(s)
      ENDIF

   ENDIF
   numbytes = FPUTS(fp_out,s)

ENDDO

=FCLOSE(fp)
=FCLOSE(fp_out)
WAIT WINDOW msg + 'ÄÄ'+ALLTRIM(STR(gtlinecnt,6))+' lines' NOWAIT

IF saveall
   IF filemode = 'PROGRAM'
      COPY FILE sniptemp.new TO (snipname)
   ELSE
      APPEND MEMO (snipname) FROM sniptemp.new OVERWRITE
   ENDIF
ELSE        && prompt for save/discard choices
   SELECT sniptemp
   APPEND MEMO snipmemo FROM sniptemp.new OVERWRITE
   _CUROBJ = 2
   action = 3
   IF filemode <> 'PROGRAM' AND !EMPTY(snipfile->name)
      scrntitl = ' '+PROPER(snipname)+" for "+snipfile->name+' '
   ELSE
      scrntitl = ' '+PROPER(snipname)+' '
   ENDIF

   DO saveit.spr WITH action
   DO CASE
   CASE action = 1       && save this one snippet
      COPY MEMO snipmemo TO sniptemp.new
      IF filemode = 'PROGRAM'
         COPY FILE sniptemp.new TO (snipname)
      ELSE
         SELECT snipfile
         APPEND MEMO (snipname) FROM sniptemp.new OVERWRITE
      ENDIF
   CASE action = 2 OR saveall     && save all formatted snippets
      IF filemode = 'PROGRAM'
         COPY FILE sniptemp.new TO (snipname)
      ELSE
         COPY MEMO snipmemo TO sniptemp.new
         SELECT snipfile
         APPEND MEMO (snipname) FROM sniptemp.new OVERWRITE
      ENDIF
      saveall = .T.
   CASE action = 3       && discard the formatted snippet
   CASE action = 4       && cancel the program
      abort = .F.        && normal termination
      DO bailout
   ENDCASE
   IF filemode <> 'PROGRAM'
      SELECT snipfile      && back to the snippet file
   ENDIF
ENDIF
RETURN


*!*****************************************************************
*!
*!      Procedure: WORDS
*!
*!*****************************************************************
FUNCTION words
PARAMETERS s1,bk_strg

PRIVATE s1,bk_strg
DO CASE
CASE PARAMETERS() = 0
   RETURN ""
CASE PARAMETERS() = 1
   m->bk_strg = ' .,'
ENDCASE

m->s1 = CHRTRAN(m->s1,m->bk_strg,SPACE(LEN(m->bk_strg)))
m->s1 = ALLTRIM(m->s1)

DO WHILE AT('  ',m->s1) > 0
   m->s1 = STRTRAN(m->s1,'  ',' ')
ENDDO

RETURN ( OCCURS(" ",m->s1) + 1)

*!*****************************************************************
*!
*!      Procedure: WORDNUM
*!
*!*****************************************************************
FUNCTION wordnum
PARAMETERS strg,w_num, bkstrg
PRIVATE strg,s1,w_num,ret_str,bkstrg
IF PARAMETERS() = 2
   bkstrg = ".,"
ENDIF
m->s1 = m->strg
m->s1 = CHRTRAN(m->s1,bkstrg,"  ")
m->s1 = ALLTRIM(m->s1)

DO WHILE AT('  ',m->s1) > 0
   m->s1 = STRTRAN(m->s1,'  ',' ')
ENDDO

DO CASE
CASE m->w_num > 1
   DO CASE
   CASE AT(" ",m->s1,m->w_num-1) = 0  && no word w_num past end of string.
      m->ret_str = ""
   CASE AT(" ",m->s1,m->w_num) = 0    && word w_num is last word in string.
      m->ret_str = SUBSTR(m->s1,AT(" ",m->s1,m->w_num-1)+1,255)
   OTHERWISE                              && word w_num is in the middle.
      strt_pos = AT(" ",m->s1,m->w_num-1)
      m->ret_str = SUBSTR(m->s1,strt_pos,;
         AT(" ",m->s1,m->w_num)+1 - strt_pos)
   ENDCASE
CASE m->w_num = 1
   IF AT(" ",m->s1) > 0        && get first word.
      m->ret_str = SUBSTR(m->s1,1,AT(" ",m->s1)-1)
   ELSE                        && there is only one word.  get it.
      m->ret_str = m->s1
   ENDIF
ENDCASE

m->ret_str = ALLTRIM(m->ret_str)

RETURN m->ret_str

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
*!      Procedure: JUSTEXT
*!
*!*****************************************************************
FUNCTION justext
PARAMETERS filname
PRIVATE ALL
m.ext = ""
IF AT('.',m.filname) > 0
   m.ext = SUBSTR(m.filname,AT('.',m.filname)+1,3)
ENDIF
RETURN UPPER(m.ext)

*!*****************************************************************
*!
*!      Procedure: DELFILE
*!
*!*****************************************************************
FUNCTION delfile
parameter fname
PRIVATE fname

IF FILE(m.fname)
   DELETE FILE (m.fname)
ENDIF
RETURN 0

*!*****************************************************************
*!
*!      Procedure: ADDBS
*!
*!*****************************************************************
FUNCTION addbs
* Add a backslash to a path name, if there isn't already one there
parameter pathname
PRIVATE ALL
m.pathname = ALLTRIM(UPPER(m.pathname))
IF !(RIGHT(m.pathname,1) $ '\:') AND !EMPTY(m.pathname)
   m.pathname = m.pathname + '\'
ENDIF
RETURN m.pathname

*!*****************************************************************
*!
*!      Procedure: BAILOUT
*!
*!*****************************************************************
PROCEDURE bailout
IF NOT abort
   WAIT WINDOW "Normal termination" NOWAIT
ENDIF
RELEASE spacetab, saveall, caseind, procind, filemode, abort, usetab, ;
   keywrdcap, varcap, fname

CLOSE ALL
CLEAR ALL
CLEAR WINDOW
SET PROCEDURE TO
=delfile('sniptemp.prg')
=delfile('sniptemp.new')
=delfile('keywords.dbf')
=delfile('keywords.cdx')
=delfile('keywords.bak')
=delfile('sniptemp.dbf')
=delfile('sniptemp.fpt')
=delfile('sniptemp.bak')
IF TYPE('in_error') <> 'U'
   ON ERROR &in_error
ENDIF
IF FILE('snipfmt.vue')
   SET VIEW TO snipfmt.vue
   IF SET('TALK') = 'ON'
      SET TALK OFF
      DELETE FILE snipfmt.vue
      SET TALK ON
   ELSE
      DELETE FILE snipfmt.vue
   ENDIF
ENDIF
CANCEL
*: EOF: SNIP.PRG
