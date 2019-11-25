*:*********************************************************************
*:
*: Procedure file: C:\PRO20\PDRIVERS\DRIVER.PRG
*:
*:         System: FoxPro Printer Driver Application
*:         Author: MCP
*:      Copyright (c) 1991, Fox Holdings, Inc.
*:  Last modified: 07/05/91     12:59
*:
*:  Procs & Fncts: PDONUNLOAD
*:               : PDDOCST
*:               : PDADVPRT
*:               : PDPAGEST
*:               : PDPAGEEND
*:               : PDOBJECT
*:               : PDLINEEND
*:               : PDDOCEND
*:
*:      Documented 07/09/91 at 09:27 FoxDoc  version 2.10
*:		   Updated 03/05/92	MCP		 Support for Scalable Fonts (HPLJIII)
*:*********************************************************************

*!*********************************************************************
*!
*!      Procedure: PDONLOAD
*!
*!*********************************************************************
PROCEDURE PDonload
	_pdparms[43] = _pdparms[43] + 1
RETURN


*!*********************************************************************
*!
*!      Procedure: PDONUNLOAD
*!
*!*********************************************************************
PROCEDURE PDonunload

	IF _pdparms[43] = 1
		RELEASE _pdparms
	ELSE
		_pdparms[43] = _pdparms[43] - 1
	ENDIF

RETURN


*!*********************************************************************
*!
*!      Procedure: PDDOCST
*!
*!*********************************************************************
PROCEDURE PDdocst
PARAMETER m.doc_height, m.doc_width
PRIVATE m.ctlchars, m.flen

	*
	* Build the control characters for the initialization of the printer.
	* These are stored in specific positions of the array _pdparms.
	* Also, for reports, store the page height and width.
	*

	_pdparms[28] = m.doc_height

	*
	* Check for embeded pagelength to be substitued in at runtime.
	*

	m.flen = ""
	m.first = AT("{#}",_pdparms[5])
	IF m.first > 0

		m.flen = LEFT(_pdparms[5],m.first-1) + ;
			ALLTRIM(STR(m.doc_height)) + ALLTRIM(SUBSTR(_pdparms[5], m.first+3))
	ELSE
		m.first = AT("{#B}",_pdparms[5])
		IF m.first > 0

			m.flen = LEFT(_pdparms[5],m.first-1) + ;
				CHR(m.doc_height) + ALLTRIM(SUBSTR(_pdparms[5], m.first+4))
		ENDIF

	ENDIF


	*
	* Calculate Dots per Column, if _pdparms[47] is not 0.  Otherwise,
	* the Horizontal Movement command will move by columns.
	*
	
	IF _pdparms[47] != 0
		
		*
		* In order to avoid printing in the dead space on the right side of 
		* the page we add 2 to the column width.
		*
		_pdparms[48] = _pdparms[47] / (m.doc_width +2)
	ENDIF
	
	IF _pdparms[49] != 0
		_pdparms[50] = INT(_pdparms[49] * _pdparms[44] * 300)
	ENDIF

	m.ctlchars = _pdparms[3] + _pdparms[10] + ;
		_pdparms[8] + _pdparms[25] + _pdparms[26] + _pdparms[45] + ;
		IIF(EMPTY(_pdparms[40]), REPLICATE(IIF(EMPTY(_pdparms[22]), ;
 		  CHR(13)+CHR(10), _pdparms[22]), _pdparms[41]), _pdparms[40]) + ;
		_pdparms[7] + m.flen 

	_pdparms[29] = m.doc_width
	_pdparms[21] = .F.
	_pdparms[27] = 1
    _pdparms[39] = .F.           && page eject flag

	IF NOT EMPTY(_pdparms[30])
		DO (LOCFILE(_pdparms[30], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[30] + "?")) WITH m.ctlchars
	ENDIF

RETURN m.ctlchars




*!*********************************************************************
*!
*!      Procedure: PDADVPRT
*!
*!*********************************************************************
PROCEDURE PDadvprt
PARAMETER m.fromhere, m.wheretogo
PRIVATE m.ctlchars, m.dpi_col

	*
	* Check to see if the current printer has control codes for horizontal
	* movement.  If so, then return the movement factor otherwise, use a
	* default movement scheme.
	*
	IF _pdparms[27] = 0			&& We reached the EOP, but didn't get pagest.
		m.ctlchars = IIF(EMPTY(_pdparms[22]), CHR(13)+CHR(10), _pdparms[22])
		_pdparms[27] = 1
	ELSE
		m.ctlchars = ""
	ENDIF
	
	_pdparms[21] = .T.			&& We printed an object on this page


	m.ctlchars = m.ctlchars + _pdparms[42]
	_pdparms[42]=""

	IF EMPTY(_pdparms[23])
		IF m.fromhere>m.wheretogo
			m.ctlchars = m.ctlchars + CHR(13) + SPACE(m.wheretogo)
		ELSE
			m.ctlchars = m.ctlchars + SPACE(m.wheretogo-m.fromhere)
		ENDIF
	ELSE
		IF _pdparms[47] != 0
			m.dpi_col = INT(_pdparms[48] * m.wheretogo)
		ELSE
			m.dpi_col = m.wheretogo
		ENDIF
		
		IF m.fromhere != m.wheretogo
			m.ctlchars = m.ctlchars + _pdparms[23] + ALLTRIM(STR(m.dpi_col)) + _pdparms[24]
		ENDIF
	ENDIF
	
	_pdparms[46] = m.wheretogo
	
RETURN m.ctlchars



*!*********************************************************************
*!
*!      Procedure: PDPAGEST
*!
*!*********************************************************************
PROCEDURE PDpagest
PRIVATE m.ctlchars

	*
	* Reset the line counter and return a the codes to go to the next line.
	*
	_pdparms[27] = 1
	_pdparms[21] = .F.
	m.ctlchars = ""
    _pdparms[39] = .T.			&& pagest encountered

	IF NOT EMPTY(_pdparms[31])
		DO (LOCFILE(_pdparms[31], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[31] + "?")) WITH m.ctlchars
	ENDIF


RETURN m.ctlchars


*!*********************************************************************
*!
*!      Procedure: PDPAGEEND
*!
*!*********************************************************************
PROCEDURE PDpageend
PRIVATE m.ctlchars

	m.ctlchars = ""

	_pdparms[42]=""			&& Clear the capture buffer

    IF _pdparms[39]
		m.ctlchars = IIF(EMPTY(_pdparms[6]), CHR(12)+CHR(13), _pdparms[6])
		IF EMPTY(_pdparms[40])
			m.ctlchars = m.ctlchars + REPLICATE(IIF(EMPTY(_pdparms[22]), ;
				CHR(13)+CHR(10), _pdparms[22]), _pdparms[41])
		ENDIF

	ELSE

        _pdparms[42] = _pdparms[42] + ;
        	IIF(EMPTY(_pdparms[6]), CHR(12)+CHR(13), _pdparms[6])

		IF EMPTY(_pdparms[40])
			_pdparms[42] = _pdparms[42] + REPLICATE(IIF(EMPTY(_pdparms[22]), ;
				CHR(13)+CHR(10), _pdparms[22]), _pdparms[41])
		ENDIF

	ENDIF

    _pdparms[39] = .F.

	IF NOT EMPTY(_pdparms[37])
		DO (LOCFILE(_pdparms[37], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[37] + "?")) WITH m.ctlchars
	ENDIF

RETURN m.ctlchars


*!*********************************************************************
*!
*!      Procedure: PDOBJECT
*!
*!*********************************************************************
PROCEDURE PDobject
PARAMETERS m.textline, m.attribs
PRIVATE m.char, m.ctlchars, m.endchars, m.i, m.bold, m.italic, m.super, m.sub, m.under, ;
		m.startchars, m.text_len, m.num_len, m.num_move


	IF _pdparms[27] = 0			&& We reached the EOP, but didn't get pagest.
		m.startchars = IIF(EMPTY(_pdparms[22]), CHR(13)+CHR(10), _pdparms[22])
		_pdparms[27] = 1
	ELSE
		m.startchars = ""
	ENDIF
	m.endchars = ""
	m.ctlchars = _pdparms[42] 
	_pdparms[42] = ""
	_pdparms[21] = .T.
    _pdparms[39] = .F.


	IF LEN(m.attribs) > 0			&& check to see if the object has any attributes
		STORE .F. TO m.bold, m.italic, m.super, m.sub, m.under
		m.attribs = UPPER(m.attribs)
		FOR m.i = 1 to LEN(m.attribs)	&& parse the attribute string

			m.char = SUBSTR(m.attribs, m.i, 1)

			*
			* Build the control characters for the current object's
			* attributes.  Build both the turning on and off of the
			* style.
			*
			DO CASE
				CASE m.char = "B" AND NOT m.bold
					IF NOT EMPTY(_pdparms[26])
						m.startchars = m.startchars + _pdparms[11]
						m.endchars = m.endchars + _pdparms[12]
					ENDIF
					m.bold = .T.

				CASE m.char = "I" AND NOT m.italic
					IF NOT EMPTY(_pdparms[25])
						m.startchars = m.startchars + _pdparms[15]
						m.endchars = m.endchars + _pdparms[16]
					ENDIF
					m.italic = .T.

				CASE m.char = "R" AND NOT m.super AND NOT m.sub
					m.startchars = m.startchars + _pdparms[17]
					m.endchars = m.endchars +  _pdparms[8] + _pdparms[18]
					m.super = .T.
				CASE m.char = "L" AND NOT m.sub AND NOT m.super
					m.startchars = m.startchars + _pdparms[19]
					m.endchars = m.endchars + _pdparms[8] + _pdparms[20]
					m.sub = .T.
				CASE m.char = "U" AND NOT m.under
					m.startchars = m.startchars + _pdparms[13]
					m.endchars = m.endchars + _pdparms[14]
					m.under = .T.
				CASE m.char = "J"
					IF _pdparms[49] != 0
						m.text_len = LEN(m.textline)
						m.num_len = LEN(ALLTRIM(m.textline))
						m.num_move = (m.text_len - m.num_len) * _pdparms[51]
						
						IF m.sub OR m.super
							m.num_move = m.num_move / 2
						ENDIF
						
						IF m.num_move > 0
							m.startchars = m.startchars + _pdparms[23] + "+" + ALLTRIM(STR(m.num_move,7,2)) + ;
									_pdparms[24]
							m.textline = ALLTRIM(m.textline)
						ENDIF
					ENDIF
				CASE m.char = "C"
					IF _pdparms[49] != 0
						m.text_len = LEN(m.textline)
						m.num_len = LEN(ALLTRIM(m.textline))
						m.num_move = (m.text_len - m.num_len) / 2 * _pdparms[51]

						IF m.sub OR m.super
							m.num_move = m.num_move / 2
						ENDIF
						
						IF m.num_move > 0
							m.startchars = m.startchars + _pdparms[23] + "+" + ALLTRIM(STR(m.num_move,7,2)) + ;
									_pdparms[24]
							m.textline = ALLTRIM(m.textline)
						ENDIF
					ENDIF
			ENDCASE

		ENDFOR

	ENDIF
	
	IF _pdparms[49] != 0
		m.textline = chk_special(m.textline)
	ENDIF
	
	m.ctlchars = m.ctlchars + m.startchars + m.textline + m.endchars

	IF NOT EMPTY(_pdparms[34])
		DO (LOCFILE(_pdparms[34], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[34] + "?")) WITH m.ctlchars
	ENDIF

RETURN m.ctlchars



*!*********************************************************************
*!
*!      Procedure: PDLINEEND
*!
*!*********************************************************************
PROCEDURE PDlineend
PRIVATE m.ctlchars

	*
	* Check to see if the line number is greater than the page length.
	* If so, don't return anything and let the page start handle the movement.
	*
	m.ctlchars = ""
	IF _pdparms[27] >= _pdparms[28]
		_pdparms[27] = 0
		_pdparms[21] = .F.
	ELSE
		IF _pdparms[21]			&& Output text yet?
			m.ctlchars = IIF(EMPTY(_pdparms[22]), CHR(13)+CHR(10), _pdparms[22])
		ELSE
			_pdparms[42] = _pdparms[42] + IIF(EMPTY(_pdparms[22]), CHR(13)+CHR(10), _pdparms[22])
		ENDIF

		_pdparms[27] = _pdparms[27] + 1
	ENDIF

	IF NOT EMPTY(_pdparms[36])
		DO (LOCFILE(_pdparms[36], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[36] + "?")) WITH m.ctlchars
	ENDIF

RETURN m.ctlchars


*!*********************************************************************
*!
*!      Procedure: PDDOCEND
*!
*!*********************************************************************
PROCEDURE PDdocend			&& Return any reset printer characters.
PRIVATE m.ctlchars

	m.ctlchars = IIF(EMPTY(_pdparms[3]), "", _pdparms[3])

	_pdparms[42] =""

	IF NOT EMPTY(_pdparms[38])
		DO (LOCFILE(_pdparms[38], "PRG;APP;SPR;FXP;SPX", ;
			"Where is " + _pdparms[38] + "?")) WITH m.ctlchars
	ENDIF

RETURN m.ctlchars



PROCEDURE chk_special
PARAMETER m.object
PRIVATE m.ctlchars, m.i, m.ascii_char, m.curchar

	m.ctlchars = ""
		
	FOR m.i = 1 to LEN(m.object)
		
		m.curchar = SUBSTR(m.object,m.i,1)
		m.ascii_char = ASC(m.curchar)
		IF m.ascii_char > 178 AND m.ascii_char < 219

			m.ctlchars = m.ctlchars + _pdparms[23] + ;
				ALLTRIM(STR(_pdparms[50] * _pdparms[46])) +;
				_pdparms[24] + m.curchar
		ELSE
			m.ctlchars = m.ctlchars + m.curchar
		ENDIF
		
		_pdparms[46] = _pdparms[46] + 1;
		
	ENDFOR

RETURN m.ctlchars
*: EOF: DRIVER.PRG


