
/*----------------------------------------------------------------------+
 |  DRIVER2.C - FoxPro general printer driver (C version).				|
 |                                                                      |
 |  Copyright (c) 1991, Fox Holdings, Inc.                              |
 |  Fox Software System's Group                                         |
 |  134 W. South Boundary                                               |
 |  Perrysburg, Ohio  43551                                             |
 +----------------------------------------------------------------------*/


#include <pro_ext.h>


#define BADHANDLE       0                       // Not a handle.
typedef unsigned short	USHORT;

#define LoWord(x)       ((USHORT)x)
#define HiWord(x)       ((USHORT)((unsigned long)(x)>>16))
#define P_BOLD          1                       // Bold attrib.
#define P_ITALIC        (1<<1)                  // Italic attrib.
#define P_UNDERLINE     (1<<2)                  // Underline attrib.
#define P_RAISED        (1<<3)                  // Superscript attrib.
#define P_LOWERED       (1<<4)                  // Subscript. attrib.

#define NUMWIDTH		20
#define PDALLOCSIZE		1024					// Allocation size

#define PDELEMENTS      52                      // Number of elements in _PDPARMS
#define CAPTUREBUFFSIZE 64
#define	TIMESLOADED		43						// Array position of the number times we're loaded

static Locator g_pdparms;                       // The locator of _PDPARMS
static MHANDLE g_pdElement[PDELEMENTS];         // Our local copy of _PDPARMS
static int     g_pdELen[PDELEMENTS];            // Length of individual elements
static long    g_docwidth, g_curlin;            // Document width, current line #
static TEXT    g_sendff = FALSE;                // Flag for sending a Form Feed
static TEXT    g_bop = FALSE;                   // Beginning of a page
static MHANDLE g_capture;                       // capture buffer
static int     g_caplen;                        // capture buffer length
static double  g_dots_col=0;					// dots per column
static int     g_curcolumn=0;                   // current column location
static int	   g_graph_width=0;                 // width of a graphic character
static TEXT    g_viadots=FALSE;                 // flag to show if we move by dots
												// or by columns.


/*----------------------------------------------------------------------+
 |  _fltused() is a null function so that WATCOM does not link in       |
 |  unneeded code into our library.  If there is ever a need to add     |
 |  floating point functions like sprintf() and vsprintf() this routine |
 |  should be removed.                                                  |
 +----------------------------------------------------------------------*/
void _fltused()
{

}


/*----------------------------------------------------------------------+
 |  power() will return the base parameter raised to the nth.           |
 +----------------------------------------------------------------------*/
static long power(int base, int n)
{
    long	res=base;

    if (n < 1)
        return 1;

    while (--n)
        res *= base;

    return res;
}


/*----------------------------------------------------------------------+
 |  This routine will do the xBase equivalent of a LTRIM() and return   |
 |  the length of the trimmed string.                                   |
 +----------------------------------------------------------------------*/
static long LeftTrim(Value FAR *val)
{
	TEXT	FAR	*buff;
	int		i;


	_HLock(val->ev_handle);
	buff = _HandToPtr(val->ev_handle);

	for (i=0; i <= val->ev_length && buff[i] == 0x20; i++);

	_MemMove(buff, buff+i, val->ev_length - i);
	_HUnLock(val->ev_handle);
	_SetHandSize(val->ev_handle, val->ev_length - i);

	val->ev_length  -= i;
	return (val->ev_length);

}


/*----------------------------------------------------------------------+
 |  This routine takes a long integer and returns the string equivalent |
 |  of it.                                                              |
 +----------------------------------------------------------------------*/
static NumToStr(long num, TEXT FAR *result)
{
    TEXT	buff[10], *firstch;
    long	temp;

    buff[9] = 0;
    firstch  = buff+9;

    do
    {
	temp = num / 10;
        *--firstch = (num - temp * 10) + '0';   // convert the nibble to ASCII
	num = temp;
    }
    while (num && (firstch > buff));

    _StrCpy(result, firstch);                   // copy the string into result.

    return _StrLen(result);
}

/*----------------------------------------------------------------------+
 |  RealNumToStr() will convert the double real number to a character   |
 |  string and return it in result.                                     |
 +----------------------------------------------------------------------*/
static int RealNumToStr(double d, TEXT FAR *result, int decpl)
{
    TEXT	buff[NUMWIDTH * 2];
    long	lval;
    int		reslen, i;


    lval = d * power(10, decpl) + 0.5001;

    NumToStr(lval, buff);
    reslen = _StrLen(buff);

    if (reslen <= decpl)
    {
        _StrCpy(result, "0.");

	i = decpl - reslen;
	_MemFill(result + 2, '0', i);

	_StrCpy(result + 2 + i, buff);
    }
    else
    {
	i = reslen - decpl;
	_MemMove(result, buff, i);

	if (decpl)
	{
	    result[i] = '.';
	    _MemMove(result + i + 1, buff + i, decpl);

	    i += (decpl + 1);
	}

	result[i] = 0;
    }

    return _StrLen(result);
}

/*----------------------------------------------------------------------+
 |  StrToNum will convert the string passed in cp into a number.        |
 +----------------------------------------------------------------------*/
static double StrToNum(TEXT FAR *cp, int numlen)
{
    double	resnum = 0.0;
    int		j;

    for(; *cp == ' '; cp++, numlen--);

    for (; isdigit(*cp) && numlen; cp++, numlen--)
	resnum = (resnum * 10) + (*cp - '0');

    if ((*cp == '.') && numlen--)
    {
        cp++;

	for (j=10 ; isdigit(*cp) && numlen; cp++, numlen--, j *= 10)
	    resnum += ((*cp - '0') / j);
    }

    return resnum;
}


/*----------------------------------------------------------------------+
 |  Retrieve all values from _pdparms directly (except for 'C' type).   |
 +----------------------------------------------------------------------*/
static pdVal(int element, TEXT type, Value FAR *val)
{
    Locator	loc;

    loc = g_pdparms;                            // The locator of _PDPARMS.
    loc.l_sub1 = element;

    if (_Load(&loc, val) != 0)                  // Load the element
	return NO;

    if (val->ev_type != type)                   // Check if it's the type we want
    {
        if ((val->ev_type == 'C') && (val->ev_handle != BADHANDLE))
	{
            _FreeHand(val->ev_handle);          // If it's a Character type, then
            val->ev_handle = BADHANDLE;         // free the handle.
	}

	return NO;
    }

    return YES;
}


/*----------------------------------------------------------------------+
 |  Retrieve the numeric values from _PDPARMS                           |
 +----------------------------------------------------------------------*/
static double pdNval(int element)
{
    Value	val;
    double	retval;

    if (pdVal(element, 'N', &val) || pdVal(element, 'I', &val))
    {
        retval = (val.ev_type == 'N') ? val.ev_real : val.ev_long;
	return (retval);
    }

    return (double)0.0;
}

/*----------------------------------------------------------------------+
 |  Retrieve the character values from _PDPARMS                         |
 +----------------------------------------------------------------------*/
static pdCval(int element, TEXT FAR *dest, int FAR *destlen)
{
    int		len;

    --element;                          // decrement element for our copy

    len = g_pdELen[element];            // get the length of the element

    if (len == 0)                       // if the length is zero, it isn't good
        return;

                                        // move the element into the destination
    _MemMove(dest + *destlen,
             _HandToPtr(g_pdElement[element]),
	     len);

    *destlen += len;
}


/*----------------------------------------------------------------------+
 |  Store a numeric value in _PDPARMS                                   |
 +----------------------------------------------------------------------*/
static void pdStoreNVal(int element, long nval)
{
    Locator	loc;
    Value	val;

    val.ev_type = 'I';                  // Setup the Value Structure for the _Store
    val.ev_width = 10;
    val.ev_long = nval;
    val.ev_handle = BADHANDLE;

    loc = g_pdparms;                    // Specify what element we want to use
    loc.l_sub1 = element;

    _Store(&loc, &val);                 // Store the value into _PDPARMS.
}

/*----------------------------------------------------------------------+
 |  Store a numeric real value in _PDPARMS                              |
 +----------------------------------------------------------------------*/
static void pdStoreRVal(int element, double nval)
{
    Locator	loc;
    Value	val;

    val.ev_type = 'N';                  // Setup the Value Structure for the _Store
    val.ev_width = 10;
    val.ev_real = nval;
	val.ev_length = 2;
    val.ev_handle = BADHANDLE;

    loc = g_pdparms;                    // Specify what element we want to use
    loc.l_sub1 = element;

    _Store(&loc, &val);                 // Store the value into _PDPARMS.
}



static loadPDParms(int start, int end)
{
    int         element;                // the element we are addressing
    int         errcode=0;              // internal error code
    Locator     loc;                    // a locator to _PDPARMS
    Value       val;                    // the value structure for _PDPARMS

    /*  Load in the values of each element of _PDPARMS in our local
        copy.                                                       */

    for (element=start; (element < end) && (element < PDELEMENTS); element++)
    {
        loc = g_pdparms;
        loc.l_sub1 = element+1;             // Increment the element # for xBase

        if (errcode = _Load(&loc, &val))    // Load the value
            break;

        //  Check the type of the element is not character or we don't have a handle
        if ((val.ev_type != 'C') || (val.ev_handle == BADHANDLE))
        {
            g_pdElement[element] = BADHANDLE;
            g_pdELen[element]  = 0;
        }
        else                // otherwise, it's a character type
        {
            g_pdElement[element] = val.ev_handle;           // save the handle and
            g_pdELen[element]  = val.ev_length;             // and the length
        }
    }

    return (-errcode);               // Set a flag if there was an error

}

/*----------------------------------------------------------------------+
 |  This routine is called on loading of the api printer driver.  It    |
 |  checks to see if _PDPARMS has been created and if so, it then loads |
 |  in the values of the elements of the array into an internal copy.   |
 |  This is done once, so any changes made to the xBase version of      |
 |  _PDPARMS after this, will not take any effect on our copy.  This is |
 |  done so we don't continually have to call back to FoxPro to obtain  |
 |  the value of a certain element in _PDPARMS array.                   |
 +----------------------------------------------------------------------*/
FAR pdonload()
{
    Locator     loc;                    // a locator to _PDPARMS
    int         errcode;                // internal error code
    NTI         nti;                    // the Name Table Index of _PDPARMS
    Value       val;                    // the value structure for _PDPARMS
    int         element;                // the element we are addressing
    TEXT        varflag = FALSE,
                create = FALSE;
    FPFI        load_func;
    TEXT        load_elem[20];
    int         load_len=0;
    long        chksum;

    //  check if there is a Name Table Index
    if ((nti = _NameTableIndex("_PDPARMS")) >= 0)
    {
        if (_FindVar(nti, -1, &loc))            // Load the Locator for _PDPARMS
	{
            if (loc.l_subs == 0)                // If there aren't any subscripts,
                varflag = TRUE;                 // flag that there is an error with it
	    else
	    {
                g_pdparms = loc;

                varflag = loadPDParms(0, loc.l_sub1);


/*----------------------------------------------------------------------+
 |  The following line tells us how many times this api routine has been|
 |  loaded.  This is needed in case a user loads a printer drivers and  |
 |  thus the api, and then loads the api routine via the SET LIBRARY TO |
 |  command.  Without this, we would release the local copy of _PDPARMS |
 |  (which rely heavily upon.)                                          |
 +----------------------------------------------------------------------*/

				if (loc.l_subs >= TIMESLOADED)
                	pdStoreNVal(TIMESLOADED, pdNval(TIMESLOADED) + 1);
				else
					varflag = TRUE;

/*----------------------------------------------------------------------+
 |  The following code was added as and enhancement request.  It stores |
 |  the address of the procedure loadPDParms and a four byte checksum   |
 |  of this address into the last element of _PDPARMS.  If the user     |
 |  wants to update the api's internal copy of _PDPARMS, it can now     |
 |  be done by loading the library PDUDATE.PLB.                         |
 |                                                                      |
 |  Note:  The address of loadPDParms() function must be placed in the  |
 |  last element in the _PDPARMS array in order for PDUPDATE to work.   |
 +----------------------------------------------------------------------*/

                load_func = loadPDParms;
                _MemMove(load_elem, &load_func, 4);
                load_len = 4;

                chksum = ~(long) load_func;
                _MemMove(load_elem + load_len, &chksum, 4);
                load_len +=4;

                val.ev_type = 'C';
                val.ev_handle = _AllocHand(load_len);

                if (val.ev_handle != BADHANDLE)
                {
                    val.ev_length = load_len;
                    _MemMove(_HandToPtr(val.ev_handle), load_elem, load_len);
                }
                else
                    val.ev_length = 0;


                if ((loc.l_sub1 = _ALen(nti, AL_ELEMENTS)) >= 0)
                    _Store(&loc, &val);


	    }
	}
	else
	    create = TRUE;
    }
    else                                // we couldn't find the NTI of _PDPARMS
        create = TRUE;                  // so, it needs to be created.

    if (create)                 // Create FoxPro's _PDPARMS
    {
	loc.l_subs = 0;

        if (errcode = _NewVar("_PDPARMS", &loc, NV_PUBLIC) < 0)
	    _Error(errcode);
	else
	    varflag = TRUE;
    }

    if (varflag)                        // If we need to signal an error in loading
    {                                   // the printer drivers, we do so by filling
        val.ev_type = 'I';              // the first element of _PDPARMS with -1.
	val.ev_width = 10;
	val.ev_long = -1;
	_Store(&loc, &val);
    }
}

/*----------------------------------------------------------------------+
 |  Release the array of handles which we have accumulated for our copy |
 |  of _PDPARMS.  This only done if the value in _PDPARMS(43) is 1.     |
 +----------------------------------------------------------------------*/
FAR pdonunload()
{
    int		element;
    MHANDLE	hand;


    if (pdNval(43) == 1)
        _Release(g_pdparms.l_NTI);
    else
        pdStoreNVal(43, pdNval(43) - 1);

    for (element=0; element < PDELEMENTS; element++)
    {
        if (hand = g_pdElement[element])
	    _FreeHand(hand);
    }
}

/*----------------------------------------------------------------------+
 |  Call the FoxPro User Procedure which accompanies this element.      |
 +----------------------------------------------------------------------*/
static ParseExtern(int element, Value FAR *val)
{
    int 	created;
    Locator	loc;
    TEXT	buff[512], numtext[10];

    /* Execute the User Procedure if there is one.	*/
    if (g_pdELen[element-1] != 0)
    {
	loc.l_subs = 0;
        created = _NewVar("_ctlchars", &loc, NV_PUBLIC);        // create our parameter variable

        if (created >= 0)
	{
	    created = _Store(&loc, val);

	    if (created == 0)
	    {
		_StrCpy(buff, "DO (LOCFILE(_pdparms[");
		NumToStr(element, numtext);
		_StrCpy(buff + _StrLen(buff), numtext);
		_StrCpy(buff + _StrLen(buff), "], 'PRG;APP;SPR;FXP;SPX', 'Where is ' + _pdparms[");
		_StrCpy(buff + _StrLen(buff), numtext);
                _StrCpy(buff + _StrLen(buff), "] + '?')) WITH _ctlchars");

                created = _Execute(buff);       // Execute the User Procedure passing it
                                                // everything we have built and will be
                                                // sending to the printer.

	        if (!created)
		{
                    _FreeHand(val->ev_handle);
                    _Load(&loc, val);           // Load the parameter back in
                    _Release(loc.l_NTI);        // and release the parameter variable.
		}
	    }

	    if (val->ev_type != 'C')
	    {
                _FreeHand(val->ev_handle);
		val->ev_handle = BADHANDLE;
		val->ev_length = 0;
	    }

	}
    }
}

/*----------------------------------------------------------------------+
 |  Return a value back to FoxPro and call the User Procedure.          |
 +----------------------------------------------------------------------*/
static RetBinary(TEXT FAR *sourcechars, int sourcelen, int element)
{
    Value	retval;
    MHANDLE	mhand;

    retval.ev_type   = 'C';
    retval.ev_length = sourcelen;

    mhand = _AllocHand(sourcelen);
    if (mhand == BADHANDLE)
        _Error(182);                    /* Insufficient Memory */

    if ((mhand != BADHANDLE) && sourcelen)
        _MemMove(_HandToPtr(mhand), sourcechars, sourcelen);


    retval.ev_handle = mhand;

    if (element > 0)
        ParseExtern(element, &retval);          // Call the User Proc.

    _RetVal(&retval);                           // Pass this along to the printer
}

/*----------------------------------------------------------------------+
 |  Add a form feed to the escape codes we have put together so far.    |
 +----------------------------------------------------------------------*/
static doff(TEXT FAR *ctlchars, int FAR *ctllen)
{
    int         bufflen=0, buff2len=0;
    int         j;
    double      tmargin=0;
    TEXT        buff[1024];
    TEXT        buff2[64];

    pdCval(6, ctlchars, ctllen);                // Form feed value

    if (*ctllen == 0)                           // If the database didn't have a
    {                                           // form feed value, then use FF+CR
        ctlchars[0] = 12;   /* FF   */
        ctlchars[1] = 13;   /* CR   */
        *ctllen = 2;
    }

    pdCval(40, buff, &bufflen);                 // Take care of the top margin

    if (!bufflen)
    {
        pdCval(22, buff2, &buff2len);
        if (!buff2len)
        {
           buff2[0] = 13;
           buff2[1] = 10;
           buff2[2] = 0;
           buff2len = 2;
        }

        tmargin = pdNval(41);                   // Replicate the number of lines
        for (j=0; j < tmargin; j++)             // for the top margin.
        {
            _StrCpy(ctlchars + *ctllen, buff2);
            *ctllen += buff2len;
        }
    }
}

/*----------------------------------------------------------------------+
 |  Check for the special line characters within an object.  If the     |
 |  line characters are found, then output the correct positioning      |
 |  command which will move to the correct column.                      |
 +----------------------------------------------------------------------*/
static void chk_special(MHANDLE srchand, int FAR *srclen)
{
    MHANDLE		reshand;					// The resultant handle
    TEXT FAR	*restext;
    TEXT FAR	*srctext;
    TEXT FAR	*srcend;
    int			i, reslen=0;

    reshand = _AllocHand(PDALLOCSIZE);		// Allocate memory for the result
    if (reshand == BADHANDLE)
        _Error(182);						// Insufficient memory

    _HLock(reshand);						// We must lock the handle in order
    restext = _HandToPtr(reshand);			// To use it as a pointer.

    _HLock(srchand);			   			// The handle to the object
    srctext = _HandToPtr(srchand);
    srcend = srctext + *srclen;

    for (i=0; srctext < srcend; srctext++, i++)
	{
		if ((*srctext > 178) && (*srctext < 219))	// It's a graphic character!
		{
			pdCval(23, restext, &reslen);
			reslen += NumToStr(g_graph_width * g_curcolumn, restext + reslen);
			pdCval(24, restext, &reslen);
		}

		*(restext + reslen) = *srctext;
		reslen++;
		if (reslen >= PDALLOCSIZE)
		{
			_HUnLock(reshand);
			if (!_SetHandSize(reshand, reslen + PDALLOCSIZE))
				_Error(182);				// Insufficient memory.

			_HLock(reshand);
			restext = _HandToPtr(reshand);
		}
		g_curcolumn++;

	}

	_HUnLock(reshand);
    _HUnLock(srchand);

	_SetHandSize(srchand, reslen);
	_MemMove(_HandToPtr(srchand), _HandToPtr(reshand), reslen);
    *srclen = reslen;

	_FreeHand(reshand);

	return;
}


/*----------------------------------------------------------------------+
 |  PDObject is the procedure which gets called everytime FoxPro is     |
 |  about to print any kind of object.  This includes fields, text,     |
 |  boxes, numbers, etc.  Each object can have an attribute associated  |
 |  with it.  This printer driver does not take into account if a user  |
 |  has enclosed his own attribute characters in the style code box.    |
 |  Thus, if it encounters any that are meaningful to himself, he will  |
 |  use them.                                                           |
 |                                                                      |
 |  This routine also builds the starting and ending codes that would   |
 |  normally be sent on object start and object end.  This is done for  |
 |  efficiency reasons.                                                 |
 +----------------------------------------------------------------------*/

FAR pdobject(ParamBlk FAR *pblk)
{
    TEXT        startchars[256], endchars[256];         // start and end esc codes
    int		startlen=0, endlen=0, i, j;
    TEXT        FAR *attribs;                   // the objects attributes
    Value	retval;
    MHANDLE     mhand, mhand2;                  // handles for the object and attrib.
    unsigned    styles=0;                       // flag if any styles have been used
	double		num_len=0;


    g_sendff = TRUE;                    // Set flag to say we have output text
    mhand = pblk->p[1].val.ev_handle;           // The handle for the attribs.
    i = pblk->p[1].val.ev_length;               // length of the attribs.

	if (!g_curlin)
	{
        pdCval(22, startchars, &startlen);

        if (startlen == 0)
        {
            startchars[0] = 13;   /* CR   */
            startchars[1] = 10;   /* LF   */
            startlen = 2;
        }
		g_curlin = 1;
	}


    g_bop = FALSE;

    if (g_caplen)               // output capture buffer
    {
        _MemMove((TEXT FAR *)startchars + startlen,
            ((TEXT FAR *)_HandToPtr(g_capture)), g_caplen);
        startlen += g_caplen;
        g_caplen = 0;
    }

    if (i || startlen)          // If there are attributes or we have already built text
    {
        if (i)                  // attributes?
        {
            _HLock(mhand);
            attribs = ((TEXT FAR *)_HandToPtr(mhand));

            for (j = 0; j < i; j++)             // parse the attributes string
            {
                switch(attribs[j])
                {
                case 'B':
                                            /* The object is BOLD         */
                    if (!(styles & P_BOLD))
                    {
                        pdCval(11, startchars, &startlen);

                        pdCval(12, endchars, &endlen);

                        styles |= P_BOLD;
                    }

                    break;

                case 'I':
                                            /* The object is ITALIC        */
                    if (!(styles & P_ITALIC))
                    {
                        pdCval(15, startchars, &startlen);

                        pdCval(16, endchars, &endlen);

                        styles |= P_ITALIC;
                    }

                    break;

                case 'R':
                                            /* The object is SUPERSCRIPT   */
                    if (!(styles & P_RAISED) && !(styles & P_LOWERED))
                    {
                        pdCval(17, startchars, &startlen);

                        pdCval(8,  endchars, &endlen);
                        pdCval(18, endchars, &endlen);

                        styles |= P_RAISED;
                    }

                    break;

                case 'L':
                                            /* The object is SUBSCRIPT     */
                    if (!(styles & P_RAISED) && !(styles & P_LOWERED))
                    {
                        pdCval(19, startchars, &startlen);

                        pdCval(8,  endchars, &endlen);
                        pdCval(20, endchars, &endlen);

                        styles |= P_LOWERED;
                    }

                    break;

                case 'U':
                                            /* The object is UNDERLINED    */
                    if (!(styles & P_UNDERLINE))
                    {
                        pdCval(13, startchars, &startlen);

                        pdCval(14, endchars, &endlen);

                        styles |= P_UNDERLINE;
                    }

                    break;

				case 'J':
											/* The object is Right Justified. 	*/
					if (pdNval(49))
					{
						num_len = ((double) (pblk->p[0].val.ev_length - LeftTrim( & (pblk->p[0].val) )))
										 * pdNval(51);

						if (styles & (P_RAISED + P_LOWERED))
							num_len /= 2;

						if (num_len)
						{
							pdCval(23, startchars, &startlen);
							startchars[startlen] = '+';
							startlen++;

        					startlen += RealNumToStr(num_len, startchars + startlen, 2);
							pdCval(24, startchars, &startlen);
						}
					}
					break;

				case 'C':
											/* The object is Centered.	*/
					if (pdNval(49))
					{
						num_len = ((double) (pblk->p[0].val.ev_length - LeftTrim( & (pblk->p[0].val) )) / 2)
										 * pdNval(51);

						if (styles & (P_RAISED + P_LOWERED))
							num_len /= 2;

						if (num_len)
						{
							pdCval(23, startchars, &startlen);
							startchars[startlen] = '+';
							startlen++;

        					startlen += RealNumToStr(num_len, startchars + startlen, 2);
							pdCval(24, startchars, &startlen);
						}

					}
                    }
                }

            _HUnLock(mhand);
        }

    		  /* Prepare to return the resultant codes and string	*/
		i      = pblk->p[0].val.ev_length;
		mhand2 = pblk->p[0].val.ev_handle;


		mhand = _AllocHand(i + startlen + endlen);

		if (mhand == BADHANDLE)
			_Error(182);			// Insufficient memory.

        if (startlen)
		{							// Move the starting ctlchars for the object
		    _MemMove(_HandToPtr(mhand),
			startchars,
		    startlen);
		}

		if (g_graph_width)
			chk_special(mhand2, &i);

		_MemMove(((TEXT FAR *)_HandToPtr(mhand)) + startlen,
			_HandToPtr(mhand2),
		 	i);

		if (endlen)                            // Move the ending ctlchars for the object
	 	{
	    	_MemMove(((TEXT FAR *)_HandToPtr(mhand)) + startlen + i,
		    	endchars,
		    	endlen);
	 	}

		retval.ev_type = 'C';
		retval.ev_length = startlen + i + endlen;
	 	retval.ev_handle = mhand;
     }
     else
	 {
		if (g_graph_width)
		{
			retval.ev_type = 'C';
			i = pblk->p[0].val.ev_length;
			retval.ev_handle = pblk->p[0].val.ev_handle;
			chk_special(retval.ev_handle, &i);
			retval.ev_length = i;
		}
		else		/* Quickly return merely the object		*/
        	_MemMove(&retval, &(pblk->p[0].val), sizeof(Value));
	 }

     ParseExtern(34, &retval);                  // Call the User Procedure

     _RetVal(&retval);							// Return the string back to FoxPro

}

/*----------------------------------------------------------------------+
 |  This routine sets up everything for the document. It parses any     |
 |  elements which have '{#}' or '{#B}' in them and replaces it with    |
 |  the correct information which was not available until now.			|
 +----------------------------------------------------------------------*/
FAR pddocst(ParamBlk FAR *pblk)
{
    int         ctllen=0, bufflen=0, buff2len=0;
    int         j, phlen=0, numlen;
    double      tmargin=0;
    TEXT        ctlchars[1024], buff[1024], numstr[4], pgheight[64];
    TEXT        buff2[64];
    TEXT        found=FALSE, binary=FALSE;


    pdStoreNVal(28, pblk->p[0].val.ev_long);		// Store the document height

    pdCval(5, buff, &bufflen);

    for (j = 0; j < bufflen; j++)					// Replace the form length with
    {                                               // the number of lines per page.
        switch(buff[j])
        {
            case '{':
                found = TRUE;
                break;

            case '}':
                if (found)
                {
                    if (binary)
                    {
                        pgheight[phlen] = pdNval(28);
                        phlen++;
                    }
                    else
                    {
                        numlen = NumToStr(pdNval(28), numstr );

                        _StrCpy(pgheight + phlen, numstr);
                        phlen += numlen;
                    }
                }
                else
                {
                    pgheight[phlen] = buff[j];
                    phlen++;
                }
                found = FALSE;
                break;

            case '#':
                if (found)
                    break;


            case 'B':
                if (found)
                {
                    binary = TRUE;
                    break;
                }

            default:
                pgheight[phlen] = buff[j];
                phlen++;
                break;
        }
    }

	//
	// Calculate Dots per Column, if _pdparms[47] is not 0.  Otherwise,
	// the Horizontal Movement command will move by columns.
	//

	if (pdNval(47))
	{
	    g_viadots = TRUE;

		//
		// The column size is adjusted by two columns here in order to avoid
		// printing in the dead space on the right side of the page.
		//

	    g_dots_col = (double) pdNval(47) / (double) (pblk->p[1].val.ev_long + 2);
	    pdStoreRVal(48, g_dots_col);
	}
	else
	    g_viadots = FALSE;

	if (pdNval(49))
	{
	    bufflen = 0;
		g_graph_width = (int) ((double) pdNval(49) * pdNval(44) * (double) 300);
	    pdStoreNVal(50, g_graph_width);
	}
	else
		g_graph_width = 0;



    pdCval(3,  ctlchars, &ctllen);			// Reset printer
    pdCval(10, ctlchars, &ctllen);          // Orientation
    pdCval(8,  ctlchars, &ctllen);          // Characters Per Inch (CPI)
    pdCval(25, ctlchars, &ctllen);          // Global Style
    pdCval(26, ctlchars, &ctllen);          // Global Stroke
	pdCval(45, ctlchars, &ctllen);			// Font Command

    bufflen = 0;
    pdCval(40, buff, &bufflen);				// Top Margin command

    if (!bufflen)
    {
        pdCval(22, buff2, &buff2len);
        if (!buff2len)
        {
           buff2[0] = 13;
           buff2[1] = 10;
           buff2len = 2;
        }

/*----------------------------------------------------------------------+
 |  If there isn't a Top Margin Command, then output CR+LF for the 		|
 |  number of lines of the top margin.									|
 +----------------------------------------------------------------------*/

        tmargin = pdNval(41);

        for (j=0; j < tmargin; j++)
        {
            _StrCpy(ctlchars+ctllen, buff2);
            ctllen += buff2len;
        }
    }
    else
    {
        _StrCpy(ctlchars+ctllen, buff);
        ctllen += bufflen;
    }

    pdCval(7,  ctlchars, &ctllen);          // Lines Per Inch (LPI)
    _StrCpy(ctlchars + ctllen, pgheight);   // Form length
    ctllen += phlen;



    g_docwidth = pblk->p[1].val.ev_long;
    pdStoreNVal(29, g_docwidth);				// Store the document width

    pdStoreNVal(39, FALSE);						// Set the Bottom of Page flag
    g_bop = FALSE;

    pdStoreNVal(21, FALSE);						// Set the Object printed flag
    pdStoreNVal(27, 1);                         // Set the Line printed flag
    g_sendff = FALSE;
    g_curlin = 1;

    RetBinary(ctlchars, ctllen, 30);			// Call the user procedure.
}


/*----------------------------------------------------------------------+
 |  On completion of the document, this routine gets called.  It does   |
 |  a little cleanup and returns the Reset characters to the printer.	|
 +----------------------------------------------------------------------*/
FAR pddocend()
{
    int		ctllen=0;
    TEXT	ctlchars[1024];

    pdCval(3, ctlchars, &ctllen);		// Reset printer
    g_sendff = g_bop = FALSE;
    if (g_capture != BADHANDLE)
    {
        _FreeHand(g_capture);			// Free the capture buffer handle
        g_capture = BADHANDLE;
    }
    g_caplen = 0;

    RetBinary(ctlchars, ctllen, 38);
}


/*----------------------------------------------------------------------+
 |  On page start, this routine gets called.							|
 +----------------------------------------------------------------------*/
FAR pdpagest()
{
    int         ctllen=0;
    TEXT	ctlchars[1024];

    g_curlin = 1;        				// Reset line counter
    g_sendff = FALSE;
    g_bop = TRUE;                       // We encountered a pagest

    RetBinary(ctlchars, ctllen, 31);	// Call the user procedure.
}



/*----------------------------------------------------------------------+
 |  When the end of page is encountered, pdpageend gets called.  It     |
 |  then decides if is necessary to send out a form feed or to capture  |
 |  the form feed until later.                                          |
 +----------------------------------------------------------------------*/
FAR pdpageend()
{
    int         ctllen=0;
    TEXT	ctlchars[1024];


    g_caplen = 0;           // Clear the capture buffer.


    doff(ctlchars, &ctllen);            // Send the form feed
    if (!g_bop)                         // Capture it?
    {
        if (g_capture == BADHANDLE)
            g_capture = _AllocHand(ctllen);

		else
		{
			if (ctllen > _GetHandSize(g_capture))
				_SetHandSize(g_capture, ctllen);
		}

        _MemMove((TEXT FAR *)_HandToPtr(g_capture),
                    ctlchars, ctllen);

        g_caplen = ctllen;
        ctllen = 0;
    }

    g_bop = FALSE;

    RetBinary(ctlchars, ctllen, 37);		// Call the user procedure.
}


/*----------------------------------------------------------------------+
 |  When the end of a line is encountered, we need to check where we    |
 |  are on the page and send a form feed if necessary.                  |
 +----------------------------------------------------------------------*/
FAR pdlineend()
{
    int		ctllen=0;
    TEXT	ctlchars[1024];

    if (g_curlin >= pdNval(28))		// Last line of the page?
    {
        ctlchars[0] = 0;
        g_curlin = 0;
        g_sendff = FALSE;
    }
    else
    {
        pdCval(22, ctlchars, &ctllen);

        if (ctllen == 0)
        {
            ctlchars[0] = 13;   /* CR   */
            ctlchars[1] = 10;   /* LF   */
            ctllen = 2;
        }

        if (!g_sendff)		// Capture the form feed for now.
        {

           if (g_capture == BADHANDLE)
                g_capture = _AllocHand(ctllen);

           else if ((g_caplen + ctllen) > _GetHandSize(g_capture))
                _SetHandSize(g_capture, ctllen + g_caplen);

           _MemMove(((TEXT FAR *)_HandToPtr(g_capture)) + g_caplen,
                ctlchars, ctllen);

           g_caplen += ctllen;

           ctllen = 0;
        }

        g_curlin++;
    }

    RetBinary(ctlchars, ctllen, 36);		// Call the user procedure
}


/*----------------------------------------------------------------------+
 |  Advance the printer horizontally to the appropriate column.         |
 +----------------------------------------------------------------------*/
FAR pdadvprt(ParamBlk FAR *pblk)
{
    int		ctllen=0, numlen;
    TEXT	ctlchars[1024], numstr[7];
    int		fromcol, tocol;


    tocol = pblk->p[1].val.ev_long;			// Going to this column
    fromcol = pblk->p[0].val.ev_long;		// From this column
    g_curcolumn = tocol;

    g_sendff = TRUE;            // Object was printed

	if (g_curlin)
		ctlchars[0] = 0;
	else
	{
        pdCval(22, ctlchars, &ctllen);

        if (ctllen == 0)
        {
            ctlchars[0] = 13;   /* CR   */
            ctlchars[1] = 10;   /* LF   */
            ctllen = 2;
        }
		g_curlin = 1;
	}



    if (g_caplen)			// Did we capture anything previously?
    {
        _MemMove((TEXT FAR *)ctlchars + ctllen,
            ((TEXT FAR *)_HandToPtr(g_capture)), g_caplen);
        ctllen += g_caplen;
        g_caplen = 0;
    }

    if (tocol != fromcol)
    {
        numlen = ctllen;
        pdCval(23, ctlchars, &ctllen);
        if (!(ctllen == numlen))		// Is there a HMI command?
		{
	    	if (g_viadots)
  				numlen = NumToStr(g_dots_col * (double) tocol, numstr);
			else
            	numlen = NumToStr(tocol, numstr);

	    	_StrCpy(ctlchars + ctllen, numstr);
	    	ctllen += numlen;

            pdCval(24, ctlchars, &ctllen);
        }
	else
	{

            if (fromcol <= tocol)		// Move to the column with spaces.
	    {
		numlen = tocol - fromcol;
		tocol = 0;
	    }
	    else
	    {
		numlen = tocol + 1;
                ctlchars[ctllen] = 0x0D;             /* Carriage Return      */
                tocol = 1;
	    }


            _MemFill(ctlchars+ctllen+tocol, ' ', numlen - tocol);
            ctllen += numlen;

	}
    }
    RetBinary(ctlchars, ctllen, -1);		// Return the string to FoxPro.
}



FoxInfo myFoxInfo[] = {
	{"PDOBJECT",pdobject,2,"C,C"},
	{"PDDOCST",pddocst,2,"I,I"},
	{"PDDOCEND",pddocend,0,""},
	{"PDPAGEST",pdpagest,0,""},
	{"PDPAGEEND",pdpageend,0,""},
	{"PDLINEEND",pdlineend,0,""},
	{"PDADVPRT",pdadvprt,2,"I,I"},
	{"PDONLOAD", pdonload, CALLONLOAD, ""},
        {"PDUNONLOAD", pdonunload, CALLONUNLOAD, ""}
};

FoxTable _FoxTable = {
	(FoxTable FAR *)0, sizeof(myFoxInfo) / sizeof(FoxInfo), myFoxInfo
};
