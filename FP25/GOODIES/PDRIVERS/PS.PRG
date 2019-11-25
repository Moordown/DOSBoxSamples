*:*********************************************************************
*:
*: Procedure file: C:\PRO20\PDRIVERS\PS.PRG
*:
*:         System: FoxPro Printer Driver Application
*:         Author: MCP
*:      Copyright (c) 1991, Fox Holdings, Inc.
*:  Last modified: 07/05/91     12:51
*:
*:  Procs & Fncts: CHK_SPECIAL
*:
*:      Documented 07/09/91 at 09:27               FoxDoc  version 2.10
*:      Impelmeded patch for intl. characters for PS incl. Sectionmark
*:      by MarkusK 12/07/92 16:39
*:*********************************************************************

*!*********************************************************************
*!
*!      Procedure: PDONLOAD
*!
*!*********************************************************************
PROCEDURE PDonload
	_pdparms[39] = _pdparms[39] + 1
RETURN


*!*********************************************************************
*!
*!      Procedure: PDONUNLOAD
*!
*!*********************************************************************
PROCEDURE PDonunload

	IF _pdparms[39] = 1
		RELEASE _pdparms
	ELSE
		_pdparms[39] = _pdparms[39] - 1
	ENDIF

RETURN


*!*********************************************************************
*!
*!      Procedure: PDDOCST
*!
*!*********************************************************************
PROCEDURE PDdocst
PARAMETER doc_height, doc_width
PRIVATE m.code1, m.code2, m.code3, m.code4, m.code5, m.code6, m.code7, m.ctlchars, m.leading, ;
		m.lineext, m.trans_x, m.trans_y, m.valof9, m.valof21


	*
	* Build the Postscript program which will handle the printing of the
	* report.  This includes procedures which control how lines, pages,
	* styles, and line characters are handled.
	*


	*
	* Set docuement values for the document height and width, super and subscript
	* values, and scaling factors.
	*


	m.valof21 = VAL(_pdparms[21])
	STORE ALLTRIM(STR(;
		MIN((_pdparms[36] - (_pdparms[11] * 2)) / doc_width, ;
			(_pdparms[37] - (_pdparms[7] * 2)) / doc_height),7,4)) TO ;
		_pdparms[9]
	m.valof9 = VAL(_pdparms[9])
	m.leading = _pdparms[4] /m.valof21
	_pdparms[19] = ALLTRIM(STR(_pdparms[22]/m.valof9, 4, 1))
	_pdparms[20] = ALLTRIM(STR(_pdparms[23]/m.valof9, 4, 1))
	_pdparms[34] = m.valof21 / m.valof9

	IF (_pdparms[34] + m.leading) > 1
		m.lineext = ALLTRIM(STR(_pdparms[34] + m.leading - 1,4,3))
	ELSE
		m.lineext = "0"
	ENDIF


	_pdparms[3] = ALLTRIM(STR(_pdparms[34],7,4))


	header ="%!PS-Adobe-1.0" + CHR(13) + ;
			"%%Creator: FoxPro Postscript driver, Version 1.0" + CHR(13) + ;
			"%%Title:" + CHR(13) + ;
			"%%Creation Date: " + DTOC(DATE()) + "         " + TIME() + CHR(13)


	*
	* Code1 will contain Postscript code for formfeeds, new lines, displaying an object,
	* and resetting of the font to the default font.
	*

	m.code1 =	"/ff {outputflag 0 ne {showpage} if" + CHR(13) + ;
			"            setupsave restore" + CHR(13) + ;
			"            /setupsave save def " + CHR(13) + ;
      "            0 linepos moveto" + CHR(13) + ;
			"            /lineno 0 def} def" + CHR(13) + ;
			"/nl {newpath linepos " + ALLTRIM(STR(_pdparms[10] * _pdparms[34])) + " lt" + CHR(13) + ;
			"     {ff}" + CHR(13) + ;
			"     {lineno " + ALLTRIM(STR(m.doc_height)) + " ge {ff} {/linepos linepos lineheight sub def} ifelse}" + CHR(13) + ;
			"     ifelse" + CHR(13) + ;
			"     /lineno lineno 1 add def" + CHR(13) + ;
			"     0 linepos moveto} def" + CHR(13) + ;
			"/say { show" + CHR(13) + ;
			"      /outputflag 1 def} def" + CHR(13) + ;
			"/norm {" + _pdparms[18] + " findfont " + CHR(13) + ;
			"     " + _pdparms[3] + " scalefont setfont} def" + CHR(13) + ;
			"/rmt {rmoveto} def" + CHR(13) + ;
			"/xy {/objx cp pop def /objy cp exch pop def} def" + CHR(13) + ;
			"/mtxy {objx objy moveto} def" + CHR(13) + ;
			"/slw {0 setlinewidth} def" + CHR(13)
	*
	* Code2 will contain the Postscript code for pushing the currentpoint on the stack,
	* moving to a point on the page, changing the font, manipulating the stack, and
	* underlining an object. Some of these are one command procedures which is done in
	* order to minimize the output of the printer driver.
	*

	m.code2 = "/trim {{( ) anchorsearch {pop} {exit} ifelse} loop} def" + CHR(13) + ;
			"/strw {dup length /strwidth exch def} def" + CHR(13) + ;
			"/numwidth {dup stringwidth pop strwidth exch sub} def" + CHR(13) + ;
			"/jfy {strw trim numwidth} def" + CHR(13) + ;
			"/rj {jfy 0 rmt xy} def" + CHR(13) + ;
			"/ctr {jfy 2 div 0 rmt xy} def" + CHR(13) + ;
			"/cp {currentpoint} def" + CHR(13) + ;
			"/mt {moveto} def" + CHR(13) + ;
			"/font {findfont exch scalefont setfont} def" + CHR(13) + ;
			"/rol {cp 3 -1 roll} def" + CHR(13) + ;
			"/mv {rol exch mt pop} def" + CHR(13) + ;
			"/up {rol add mt} def" + CHR(13) + ;
			"/dn {rol sub mt} def" + CHR(13) + ;
			"/u1 {xy 0 " + _pdparms[3] + " -.1 mul rmt} def" + CHR(13) + ;
			"/u2 {dup stringwidth" + CHR(13) + ;
			"     " + ALLTRIM(STR(_pdparms[34] * .04, 3,2)) + " setlinewidth" + CHR(13) + ;
			"      rlineto gsave stroke grestore" + CHR(13) + ;
			"      mtxy slw say} def" + CHR(13)
	*
	* Code3 - Code7 contain the Postscript code to handle the graphical characters in
	* range of ASCII 179 to 218.  Each character is handled sepearately.
	*
	m.code3 =	"/gcp {mt 1 0 rmt} def" + CHR(13) + ;
		    "/l1 {dup 0 le {" + m.lineext + " sub} {" + ;
				m.lineext + " add} ifelse 0 exch rlineto} def" + CHR(13) + ;
			"/l2 {0 rlineto} def" + CHR(13) + ;
			"/dhl {0 .4 rmt l2 0 .2 rmt l2} def" + CHR(13) + ;
			"/dvl {.4 0 rmt l1 .2 0 rmt l1} def" + CHR(13) + ;
			"/lm {rol 0 rmt} def" + CHR(13) + ;
			"/ulc {mt cp 0 .6 rmt .4 l2 .4 l1} def" + CHR(13) + ;
			"/blc {mt cp 0 .4 rmt .4 l2 -.4 l1} def" + CHR(13) + ;
			"/urc {mt cp 1 .6 rmt -.4 l2 .4 l1} def" + CHR(13) + ;
			"/brc {mt cp 1 .4 rmt -.4 l2 -.4 l1} def" + CHR(13) + ;
			"/trc {mt cp 0 .6 rmt .6 l2 -.6 l1} def" + CHR(13) + ;
			"/lrc {mt cp 0 .4 rmt .6 l2 .6 l1} def" + CHR(13) + ;
			"/tlc {mt cp 1 .4 rmt -.6 l2 .6 l1} def" + CHR(13)

	m.code4 = "/llc {mt cp 1 .6 rmt -.6 l2 -.6 l1} def" + CHR(13) + ;
			"/³ {cp .5 0 rmt 1 l1 gcp} def" + CHR(13) + ;
			"/´ {cp 0 .5 rmt .5 l2 0 -.5 rmt 1 l1 gcp} def" + CHR(13) + ;
			"/µ {³ -1 0 rmt cp 0 .4 rmt .5 l2 0 .2 rmt -.5 l2 gcp} def" + CHR(13) + ;
			"/¶ {º -1 0 rmt cp 0 .5 rmt .3 l2 gcp} def" + CHR(13) + ;
			"/· {cp 0 .5 rmt .6 l2 -.6 0 rmt .5 -.5 dvl gcp} def" + CHR(13) + ;
			"/¸ {cp -.5 .5 dhl .5 0 rmt -.6 l1 gcp} def" + CHR(13) + ;
			"/¹ {cp ulc blc mt cp .6 0 rmt 1 l1 0 -1 " + m.lineext + " sub rmt 0 l1 gcp} def" + CHR(13) + ;
			"/º {cp -1 1 dvl gcp} def" + CHR(13) + ;
			"/» {cp blc trc gcp} def" + CHR(13) + ;
			"/¼ {cp ulc lrc gcp} def" + CHR(13) + ;
			"/½ {cp 0 .5 rmt -.5 .5 dvl -.6 l2 gcp} def" + CHR(13) + ;
			"/¾ {cp -.5 .5 dhl .5 -.2 rmt .5 l1 gcp} def" + CHR(13)

	m.code5 = "/¿ {cp 0 .5 rmt .5 l2 -.5 l1 gcp} def" + CHR(13) + ;
			"/À {cp 1 .5 rmt -.5 l2 .5 l1 gcp} def" + CHR(13) + ;
			"/Á {cp 0 .5 rmt 1 l2 -.5 0 rmt .5 l1 gcp} def" + CHR(13) + ;
			"/Â {cp 0 .5 rmt 1 l2 -.5 0 rmt -.5 l1 gcp} def" + CHR(13) + ;
		    "/Ã {cp .5 .5 rmt .5 l2 -.5 -.5 rmt 1 l1 gcp} def" + CHR(13) + ;
			"/Ä {cp 0 .5 rmt 1 l2 gcp} def" + CHR(13) + ;
			"/Å {cp 0 .5 rmt 1 l2 -.5 -.5 rmt 1 l1 gcp} def" + CHR(13) + ;
			"/Æ {³ -1 0 rmt cp .5 .4 rmt .5 l2 0 .2 rmt -.5 l2 gcp} def" + CHR(13) + ;
			"/Ç {º -1 0 rmt cp .6 .5 rmt .4 l2 gcp} def" + CHR(13)

	m.code6 =	"/È {cp urc tlc gcp} def" + CHR(13) + ;
			"/É {cp brc llc gcp} def" + CHR(13) + ;
			"/Ê {cp urc ulc mt cp 0 .4  rmt 1 l2 gcp} def" + CHR(13) + ;
			"/Ë {cp brc blc mt cp 0 .6 rmt 1 l2 gcp} def" + CHR(13) + ;
			"/Ì {cp urc brc mt cp .4  0 rmt 1 l1 0 -1 " + m.lineext + " sub rmt 0 l1 gcp} def" + CHR(13) + ;
			"/Í {cp -1 1 dhl gcp} def" + CHR(13) + ;
			"/Î {cp ulc blc urc brc gcp} def" + CHR(13) + ;
			"/Ï {cp -1 1 dhl .5 0 rmt .4 l1 gcp} def" + CHR(13) + ;
			"/Ð {Ä -1 0 rmt cp 0 .5 rmt -.5 .5 dvl gcp} def" + CHR(13)

	m.code7 = "/Ñ {cp -1 1 dhl .5 -.2 rmt  -.4 l1 gcp} def" + CHR(13) + ;
            "/Ò {Ä -1 0 rmt cp 0 .5 rmt .5 -.5 dvl gcp} def" + CHR(13) + ;
			"/Ó {cp 0 .5 rmt -.5 .5 dvl -.2 0 rmt .6 l2 gcp} def" + CHR(13) + ;
			"/Ô {cp .5 .4 rmt .6 l1 0 -1 " + m.lineext + " sub rmt -.6 .6 dhl gcp} def" + CHR(13) + ;
			"/Õ {cp .4 0 rmt -.6 .6 dhl -.6 l1 gcp} def" + CHR(13) + ;
			"/Ö {cp .4 .5 rmt .6 l2 -1 -.5 " + m.lineext + " sub rmt -.5 .5 dvl gcp} def" + CHR(13) + ;
			"/× {cp -1 1 dvl mt Ä} def" + CHR(13) + ;
			"/Ø {cp -1 1 dhl mt ³} def" + CHR(13) + ;
			"/Ù {cp 0 .5 rmt .5 l2 .5 l1 gcp} def" + CHR(13) + ;
			"/Ú {cp 1 .5 rmt -.5 l2 -.5 l1 gcp} def" + CHR(13) + ;
			"/draw {gsave stroke grestore newpath mtxy" + CHR(13) + ;
			"      /outputflag 1 def} def" + CHR(13)
	*
	* Footer has the Postscript code for the default settings of the printer.
	* It sets the linewidth for graphical characters, it sets the orientation,
	* scale, font, pageheight, and number of copies.
	*

	m.trans_x = ALLTRIM(STR(IIF(_pdparms[1], _pdparms[11], _pdparms[7])))
	m.trans_y = ALLTRIM(STR(IIF(_pdparms[1], _pdparms[7], _pdparms[11])))

	footer = "%%EndProlog" + CHR(13) + CHR(13) + ;
			"slw" + CHR(13) + ;
			IIF(_pdparms[1], "", "-90 rotate -" + ALLTRIM(STR(_pdparms[36])) + ;
				" 0 translate" + CHR(13)) + ;
			m.trans_x + " " + m.trans_y + " translate" + CHR(13) + ;
			_pdparms[9] + " " + _pdparms[9] + " scale" + CHR(13) + ;
			_pdparms[18] + ;
 			" findfont " + _pdparms[3] + " scalefont setfont" + CHR(13) + ;
			"/pageheight " + ALLTRIM(STR(_pdparms[37] / m.valof9)) + ;
			" def" + CHR(13) + ;
			"/lineheight " + ALLTRIM(STR(_pdparms[34] + m.leading, 4,2))+ " store" + CHR(13) + ;
			"/#copies " + _pdparms[2] + " store" + CHR(13) + ;
			"/linepos pageheight " + ALLTRIM(STR((_pdparms[7] * 2) / m.valof9,4,3)) + " sub def" + CHR(13) + ;
			"/outputflag 0 def" + CHR(13) + ;
			"/setupsave save def" + CHR(13) + ;
			"/lineno 0 def" + CHR(13) + ;
			"newpath ff" + CHR(13)


	***** Patch (implemented by MarkusK 12/9/92) *****

	m.code1a="/encoding"+chr(13)+;
		"{/newcodes exch def /newfname exch def"+chr(13)+;
		" /basefname exch def /basefdict basefname findfont def"+chr(13)+;
		" /newfont basefdict maxlength dict def   "+chr(13)+;
		" basefdict"+chr(13)+;
		" { exch dup /FID ne { dup /Encoding eq"+chr(13)+;
		"   { exch dup length array copy newfont 3 1 roll put }"+chr(13)+;
		"   { exch newfont 3 1 roll put }"+chr(13)+;
		" ifelse } { pop pop } ifelse } forall"+chr(13)+;
		" newfont /FontName newfname put"+chr(13)+;
		" newcodes aload pop newcodes length 2 idiv"+chr(13)+;
		" { newfont /Encoding get 3 1 roll put} repeat"+chr(13)+;
		"newfname newfont definefont pop } def"+chr(13)

	m.code1b="/intl [ 21 /section 39 /quotesingle 96 /grave 128 /Ccedilla 129 /udieresis"+chr(13)+;
		" 130 /eacute 131 /acircumflex 132 /adieresis 133 /agrave"+chr(13)+;
		" 134 /aring 135 /ccedilla 136 /ecircumflex 137 /edieresis"+chr(13)+;
		" 138 /egrave 139 /idieresis 140 /icircumflex 141 /igrave"+chr(13)+;
		" 142 /Adieresis 143 /Aring 144 /Eacute 145 /ae 146 /AE"+chr(13)+;
		" 147 /ocircumflex 148 /odieresis 149 /ograve"+chr(13)+;
		" 150 /ucircumflex 151 /ugrave 152 /ydieresis 153 /Odieresis"+chr(13)+;
		" 154 /Udieresis 155 /cent 156 /sterling 157 /yen"+chr(13)+;
		" 158 /fi 159 /florin 160 /aacute 161 /iacute 162 /oacute 163 /uacute"+chr(13)+;
		" 164 /ntilde 165 /Ntilde 166 /ordfeminine 167 /ordmasculine"+chr(13)+;
		" 168 /questiondown 170 /logicalnot"+chr(13)+;
		" 173 /exclamdown 174 /guillemotleft 175 /guillemotright"+chr(13)+;
		" 225 /germandbls 248 /degree"+chr(13)
	m.code1c=" 226 /Gamma 228 /Sigma"+chr(13)+;
		" 224 /alpha 227 /pi 243 /lessequal 236 /infinity"+chr(13)+;
		" 241 /plusminus 242 /greaterequal 246 /divide 240 /equivalence"+chr(13)+;
		" 247 /approxequal 239 /intersection 238 /element 251 /radical"+chr(13)+;
		" ] def"+chr(13)+;
		" /Courier /Courier intl encoding"+chr(13)+;
		" /Courier-Oblique /Courier-Oblique intl encoding"+chr(13)+;
		" /Courier-Bold /Courier-Bold intl encoding"+chr(13)+;
		" /Courier-BoldOblique /Courier-BoldOblique intl encoding"+chr(13)+;
		" /Helvetica /Helvetica intl encoding"+chr(13)+;
		" /Helvetica-Oblique /Helvetica-Oblique intl encoding"+chr(13)+;
		" /Helvetica-Bold /Helvetica-Bold intl encoding"+chr(13)+;
		" /Helvetica-BoldOblique /Helvetica-BoldOblique intl encoding"+chr(13)+;
		" /Times-Roman /Times-Roman intl encoding"+chr(13)+;
		" /Times-Italic /Times-Italic intl encoding"+chr(13)+;
		" /Times-Bold /Times-Bold intl encoding"+chr(13)+;
		" /Times-BoldItalic /Times-BoldItalic intl encoding"+chr(13)

	m.ctlchars = header +m.code1+m.code1a+m.code1b+m.code1c + m.code2 + m.code3 + m.code4 + m.code5 + m.code6 + m.code7 + footer

	****** Patch End  ******

	IF NOT EMPTY(_pdparms[24])

		DO (LOCFILE(_pdparms[24], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[24] + "?")) WITH m.ctlchars
	ENDIF

RETURN m.ctlchars



*!*********************************************************************
*!
*!      Procedure: PDPAGEST
*!
*!*********************************************************************
PROCEDURE PDpagest
PRIVATE m.ctlchars, m.length

	m.ctlchars = " ff"

	m.length = LEN(m.ctlchars)
	_pdparms[33] = _pdparms[33] + m.length

	IF _pdparms[33] > 80
		m.ctlchars = m.ctlchars + CHR(13)
		_pdparms[33] = m.length
	ELSE
		m.ctlchars = m.ctlchars +  " "
	ENDIF

	IF NOT EMPTY(_pdparms[25])
		DO (LOCFILE(_pdparms[25], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[25] + "?")) WITH m.ctlchars
	ENDIF

RETURN m.ctlchars



*!*********************************************************************
*!
*!      Procedure: PDADVPRT
*!
*!*********************************************************************
PROCEDURE PDadvprt
PARAMETER fromhere, gotohere
PRIVATE m.ctlchars

	m.ctlchars = 	ALLTRIM(STR(gotohere)) + " mv"
	m.length = LEN(m.ctlchars)
	_pdparms[33] = _pdparms[33] + m.length

	IF _pdparms[33] > 80
		m.ctlchars = CHR(13) + m.ctlchars
		_pdparms[33] = m.length
	ELSE
		m.ctlchars = " " + m.ctlchars
	ENDIF

RETURN  m.ctlchars



*!*********************************************************************
*!
*!      Procedure: PDOBJECT
*!
*!          Calls: CHK_SPECIAL        (procedure in PS.PRG)
*!
*!*********************************************************************
PROCEDURE PDobject
PARAMETER text, attribs
PRIVATE m.ctlchars, m.startchars, m.endchars, m.under1, m.under2, m.super, m.sub, ;
		m.g1, m.g2, m.g3, m.g4, m.g5

	STORE "" TO m.startchars, m.endchars, m.under1, m.under2, m.super, m.sub
	STORE .F. TO m.g1, m.g2, m.g3, m.g4, m.g5

	IF LEN(attribs) > 0

		*
		* Check the attributes for the different styles and build the
		* corresponding Postscript code.
		*
		IF ATC("B",attribs) > 0			&& Is it Bold.
			IF EMPTY(_pdparms[13])
				m.startchars = _pdparms[18]
			ELSE
				m.startchars = _pdparms[12] + _pdparms[15] +_pdparms[13]
				m.g1 = .T.
			ENDIF
		ENDIF

		IF ATC("I", attribs) > 0		&& Check for Italic
			IF EMPTY(_pdparms[14])
				m.startchars = _pdparms[18]
			ELSE
				m.startchars = m.startchars + ;
					IIF(m.g1, _pdparms[14], _pdparms[12] + _pdparms[15] + ;
						IIF(_pdparms[38], _pdparms[16], "") + _pdparms[14])
				m.g1 = .T.
			ENDIF
		ENDIF

		IF ATC("U", attribs) > 0 		&& Check for Underline.
			m.g2 = .T.
		ENDIF

		IF ATC("R", attribs) > 0		&& Check for superscript.
			m.startchars = _pdparms[19] + " " + IIF(m.g1, m.startchars, " " + _pdparms[18]) + ;
				" font "
			m.super = _pdparms[19]+ " up "

			m.endchars = " norm " + ;
					_pdparms[19] + " dn "
			m.g3 = .T.
		ELSE
			IF ATC("L", attribs) > 0	&& Check for subscript.
				m.startchars = _pdparms[19] + " " + IIF(m.g1, m.startchars, " " + _pdparms[18]) + ;
					" font "
				m.sub = _pdparms[20] + " dn "

				m.endchars = " norm " + _pdparms[20] + " up "
				m.g3 = .T.
			ELSE
				IF m.g1
					m.startchars = _pdparms[3] + " " + m.startchars + " font "

					m.endchars = " norm "
				ENDIF
			ENDIF
		ENDIF

		IF ATC("J", attribs) > 0		&& Check for right justification.
			m.g4 = .T.
		ELSE

			IF ATC("C", attribs) > 0	&& Check for centering.
				m.g5 = .T.
			ENDIF

		ENDIF

	ENDIF

	*
	* Parse the object, checking for special characters and graphical
	* characters.
	*

	DO chk_special WITH text,m.g2, m.g4, m.g5

	*
	* Build the code that is to be returned.
	*

	IF m.g1 OR m.g3
		m.ctlchars = " " + m.super + m.sub + m.startchars + ;
			text + m.endchars
	ELSE
		m.ctlchars = " " + text
	ENDIF

	m.length = LEN(m.ctlchars)
	_pdparms[33] = _pdparms[33] + m.length
	IF _pdparms[33] > 80
		m.ctlchars = CHR(13) + m.ctlchars
		_pdparms[33] = m.length
	ELSE
		m.ctlchars = m.ctlchars + " "
	ENDIF


	IF NOT EMPTY(_pdparms[28])
		DO (LOCFILE(_pdparms[28], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[28] + "?")) WITH m.ctlchars
	ENDIF

RETURN m.ctlchars



*!*********************************************************************
*!
*!      Procedure: PDLINEEND
*!
*!*********************************************************************
PROCEDURE PDlineend
PRIVATE m.ctlchars

	m.ctlchars = " nl"
	m.length = LEN(m.ctlchars)
	_pdparms[33] = _pdparms[33] + m.length

	IF _pdparms[33] > 80
		m.ctlchars = m.ctlchars + CHR(13)
		_pdparms[33] = m.length
	ENDIF

	IF NOT EMPTY(_pdparms[30])
		DO (LOCFILE(_pdparms[30], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[30] + "?")) WITH m.ctlchars
	ENDIF

RETURN m.ctlchars


*!*********************************************************************
*!
*!      Procedure: PDDOCEND
*!
*!*********************************************************************
PROCEDURE PDdocend
PRIVATE m.code1

	m.code1 = " ff" + CHR(13) + ;
			"%%Trailer" + CHR(13) + ;
			"setupsave restore" + CHR(13) + ;
			IIF (_pdparms[2] <> "1", "/#copies 1 store", "") + CHR(13) + CHR(4)

	IF NOT EMPTY(_pdparms[32])
		DO (LOCFILE(_pdparms[32], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[32] + "?")) WITH m.code1
	ENDIF

RETURN m.code1


*!*********************************************************************
*!
*!      Procedure: CHK_SPECIAL
*!
*!      Called by: PDOBJECT           (procedure in DRIVER.PRG)
*!
*!*********************************************************************
PROCEDURE chk_special
PARAMETERS m.thetext, m.underline, m.rj, m.center
PRIVATE m.rj, m.curchar, m.i, m.lastaline, m.newtext, m.rjorctr, m.a_char

	m.lastaline = .F.

	IF m.rj OR m.center
		m.rjorctr = IIF(m.rj, "rj ", " ctr")
	ENDIF


	m.curchar = ASC(SUBSTR(m.thetext,1,1))
	IF m.curchar > 178 AND m.curchar < 219
		newtext = "xy "
		m.lastaline = .T.
	ELSE
		newtext = "xy "+ ;
			IIF(m.underline, "u1 (", "(")
		m.lastaline = .F.
	ENDIF

	FOR m.i = 1 to LEN(m.thetext)

		m.a_char = SUBSTR(m.thetext,m.i,1)
		m.curchar = ASC(m.a_char)

	*
	* The following checks for line drawing characters.  If found, it also checks
	* for embeded text within the object.  If there are no embeded characters,
	* just output raw code to draw the line characters, regardless of spacing.  If
	* there are embeded characters, the code is output to position the characters
	* in the correct position.
	*

		IF m.curchar > 178 AND m.curchar < 219

			IF m.lastaline

				newtext = newtext + m.a_char + " "
			ELSE
				newtext = newtext + ") " + IIF (m.rj OR m.center, IIF(m.rj, "rj ", "ctr "), "") + ;
					IIF(m.underline, "u2 ","say ") + "mtxy " + ;
					ALLTRIM(STR(m.i-1)) + " 0 rmt " + m.a_char + " "

				m.lastaline = .T.
			ENDIF

		ELSE
			IF m.lastaline
				newtext = newtext + "draw mtxy " + ;
					ALLTRIM(STR(m.i-1)) + " 0 rmt ("
			ENDIF

			*
			* Parse the object for \,(, or ) and if found, insert the \ for Postscript.
			*

			IF m.curchar = 92 OR m.curchar = 40 OR m.curchar = 41
				newtext = newtext + "\" + CHR(m.curchar)
			ELSE

				IF (m.curchar = 4) OR (m.curchar = 26)
					newtext = newtext + " "
				ELSE
					newtext = newtext + CHR(m.curchar)
				ENDIF

			ENDIF

			m.lastaline = .F.

		ENDIF

	ENDFOR

	IF m.lastaline
		m.thetext = newtext + " draw "
	ELSE
		m.thetext = newtext +  ") " + IIF (m.rj OR m.center, IIF(m.rj, "rj ", "ctr "), "") + ;
					IIF(m.underline, "u2 ","say ")

	ENDIF

RETURN
*: EOF: PS.PRG
