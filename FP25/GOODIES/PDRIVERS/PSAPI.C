/*----------------------------------------------------------------------+
 |  PSAPI.C - FoxPro postscript printer driver (C version).				|
 |                                                                      |
 |  Copyright (c) 1991, Fox Holdings, Inc.                              |
 |  Fox Software System's Group                                         |
 |  134 W. South Boundary                                               |
 |  Perrysburg, Ohio  43551                                             |
 +----------------------------------------------------------------------*/


#include <pro_ext.h>

#define BADHANDLE		0						// Not a handle.
typedef unsigned short	USHORT;

#define P_BOLD		1     			// Bold attrib.
#define P_ITALIC 	(1<<1)			// Italic attrib.
#define P_UNDERLINE	(1<<2)			// Underline attrib.
#define P_RAISED	(1<<3)			// Superscript attrib.
#define P_LOWERED	(1<<4)			// Subscript attrib.
#define P_RIGHT		(1<<5)			// Right justified
#define P_CENTER	(1<<6)			// Centered

#define PDELEMENTS      40          // Number of elements in _PDPARMS
#define PDLOCALELES     14			// Number of local elements
#define PDALLOCSIZE	1024			// Allocation size
#define NUMWIDTH	20

static Locator	g_pdparms;  				// The locator for _PDPARMS
static MHANDLE	g_pdElement[PDLOCALELES];		// The local copy of _PDPARMS
static int    	g_pdELen[PDLOCALELES], g_length;
static double	g_lmargin;
static TEXT     g_pdxref[] = {3, 12, 13, 14, 15, 16, 18, 19, 20,
                              24, 25, 28, 30, 32};	// A list of char. elements



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
 |  This function will return True if fchr is found within the string   |
 |  pointed to by src.                                                  |
 +----------------------------------------------------------------------*/
static mystrchr(TEXT fchr, TEXT FAR *src, int srclen)
{
    for (;srclen; src++, srclen--)
        if (toupper(*src) == fchr)
	    return TRUE;

    return FALSE;
}


/*----------------------------------------------------------------------+
 |  Return whether or not the element specified was stored in our local |
 |  copy.                                                               |
 +----------------------------------------------------------------------*/
static int FindLocalele(int element)
{
    int		i;

    for (i = 0; i < PDLOCALELES; i++)
        if (element == g_pdxref[i])
	    return i;

    return -1;
}


/*----------------------------------------------------------------------+
 |  Add one char (ch) to the string pointed to by dest.                 |
 +----------------------------------------------------------------------*/
static PDAdd1Char(TEXT FAR *dest, TEXT ch, USHORT FAR *len)
{
    dest[*len] = ch;
    *len += 1;
}

/*----------------------------------------------------------------------+
 |  Add the string pointed to by source to the end of the string        |
 |  pointed to by dest.                                                 |
 +----------------------------------------------------------------------*/
static PDAddChars(TEXT FAR *dest, TEXT FAR *source, USHORT FAR *len)
{
    _StrCpy(dest + *len, source);
    *len += _StrLen(source);
}



/*----------------------------------------------------------------------+
 |  Add the string pointed to by source to the end of the string        |
 |  pointed to by dest, plus a final carriage return                    |
 +----------------------------------------------------------------------*/
static PDAddCharsandCR(TEXT FAR *dest, TEXT FAR *source, USHORT FAR *len)
{
    PDAddChars(dest, source, len);
    PDAdd1Char(dest, 13, len);
}


/*----------------------------------------------------------------------+
 |  Convert the long integer, num, to it's ASCII equivalent.            |
 |  NOTE:  This function will not round the number.                     |
 +----------------------------------------------------------------------*/
static void NumToStr(long num, TEXT FAR *result)
{
    TEXT	buff[NUMWIDTH+1], FAR *firstch;
    long	temp;

    buff[NUMWIDTH] = 0;
    firstch  = buff+NUMWIDTH;

    do
    {
	temp = num / 10;
	*--firstch = (num - temp * 10) + '0';		// Store the ASCII value for this digit
	num = temp;
    }
    while (num && (firstch > buff));

    _StrCpy(result, firstch);				// Return the result
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
 | Retrieve value from Local copy of _pdparms element.                  |
 +----------------------------------------------------------------------*/
static LocalpdCval(int element, TEXT FAR *dest, USHORT FAR *destlen)
{
    int		len;

    if ((element = FindLocalele(element)) == -1)	// Check if this is a local element
        return NO;

    len = g_pdELen[element];

    if (len == 0)
        return NO;

    _MemMove(dest + *destlen,
             _HandToPtr(g_pdElement[element]),
	     len);

    *destlen += len;

    return YES;   		// We retrieved the element alright.
}


/*----------------------------------------------------------------------+
 |  Retrieve Character value from _pdparms directly.                    |
 +----------------------------------------------------------------------*/
static pdCval(int element, TEXT FAR *dest, int FAR *destlen)
{
    Locator	loc;
    Value	val;

    loc = g_pdparms;			// Our Locator for _PDPARMS.
    loc.l_sub1 = element;

    if ((_Load(&loc, &val) != 0) || (val.ev_type != 'C'))
    {
        *destlen = 0;
        return NO;   			// This element was not a character type.
    }

    if (val.ev_handle != BADHANDLE)
	_MemMove(dest,
		 _HandToPtr(val.ev_handle),
		 val.ev_length);

    *destlen = val.ev_length;

    _FreeHand(val.ev_handle);		// Free the handle we got from _Load.

    return YES;
}


/*----------------------------------------------------------------------+
 |  Retrieve values from _pdparms directly (except for 'C' type).       |
 +----------------------------------------------------------------------*/
static pdVal(int element, TEXT type, Value FAR *val)
{
    Locator	loc;

    loc = g_pdparms;			// Our Locator for _PDPARMS
    loc.l_sub1 = element;

    if (_Load(&loc, val) != 0)
	return NO;

    if (val->ev_type != type)
    {
        if ((val->ev_type == 'C') && (val->ev_handle != BADHANDLE))
	{
	    _FreeHand(val->ev_handle);	// Free the handle from the _Load()
	    val->ev_handle = BADHANDLE;
	}

	return NO;
    }

    return YES;
}


/*----------------------------------------------------------------------+
 |	Get a Logical value from _PDPARMS                                   |
 +----------------------------------------------------------------------*/
static pdLVal(int element)
{
    Value	val;

    if (!pdVal(element, 'L', &val))
        return TRUE;

    return val.ev_length;
}


/*----------------------------------------------------------------------+
 |	Get a Numeric or Integer value from _PDPARMS                        |
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
 |	Store a numeric value into an _PDPARMS element.                     |
 +----------------------------------------------------------------------*/
static void pdStoreNVal(int element, double nval)
{
    Locator	loc;
    Value	val;

    val.ev_type = 'N';				// Setup our Value Structure.
    val.ev_width = 10;
    val.ev_length = 4;
    val.ev_real = nval;
    val.ev_handle = BADHANDLE;

    loc = g_pdparms;
    loc.l_sub1 = element;

    _Store(&loc, &val);				// Store the new value.
}


/*----------------------------------------------------------------------+
 |  Store a character value in our local copy of _PDPARMS               |
 +----------------------------------------------------------------------*/
static void LocalpdStoreCVal(int element, TEXT FAR *string, USHORT slen)
{
    MHANDLE	handle;

    if ((element = FindLocalele(element)) == -1)	// Is it a local element?
        return;

    handle = _AllocHand(slen);
    if (handle   == BADHANDLE)
        _Error(182);          			// Insufficient Memory


    if (g_pdElement[element])
        _FreeHand(g_pdElement[element]);	// Free the old handle

    if (handle != BADHANDLE)
    {
	_MemMove((TEXT FAR *)_HandToPtr(handle), string, slen);

	g_pdElement[element] = handle;		// Save the new value's handle
	g_pdELen[element] = slen;
    }
    else
    {
	g_pdElement[element] = BADHANDLE;
	g_pdELen[element]  = 0;
    }
}


/*----------------------------------------------------------------------+
 |  Store a character type to an element in the actual _PDPARMS array   |
 +----------------------------------------------------------------------*/
static void pdStoreCVal(int element, TEXT FAR *string, USHORT slen, TEXT stlocal)
{
    Locator	loc;
    Value	val;

    if (stlocal)
        LocalpdStoreCVal(element, string, slen);  // Store a local copy.

    val.ev_type = 'C';               		// Setup the Value structure.
    val.ev_handle = _AllocHand(slen);

    if (val.ev_handle != BADHANDLE)
    {
        val.ev_length = slen;
	_MemMove(_HandToPtr(val.ev_handle), string, slen);
    }
    else
        val.ev_length = 0;

    loc = g_pdparms;         		       // Our Locator of _PDPARMS
    loc.l_sub1 = element;

    _Store(&loc, &val);			       	// Store the element
}



/*----------------------------------------------------------------------+
 |  Call the FoxPro User Procedure which accompanies this element.      |
 +----------------------------------------------------------------------*/
static void ParseExtern(int element, Value FAR *val)
{
    int 	created, lelement;
    Locator	loc;
    TEXT	buff[512], numtext[10];

    /* Execute the User Procedure if there is one.	*/
    if (((lelement = FindLocalele(element)) != -1)
        && (g_pdELen[lelement] != 0))
    {
	loc.l_subs = 0;
        created = _NewVar("_ctlchars", &loc, NV_PUBLIC);	// create our parameter variable

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

		created = _Execute(buff);	// Execute the User Procedure passing it
                                            	// everything we have built and will be
                                            	// sending to the printer.

	        if (!created)
		{
                    _FreeHand(val->ev_handle);
		    _Load(&loc, val);		// Load the parameter back in
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
static void RetBinary(TEXT FAR *sourcechars, USHORT sourcelen, int element)
{
     Value	retval;
     MHANDLE	mhand;

     retval.ev_type   = 'C';
     retval.ev_length = sourcelen;

     mhand = _AllocHand(retval.ev_length);
     if (mhand == BADHANDLE)
        _Error(182);			// Insufficient Memory.

     if ((mhand != BADHANDLE) && sourcelen)
         _MemMove(_HandToPtr(mhand), sourcechars, sourcelen);

     retval.ev_handle = mhand;

    if (element > 0)
     	ParseExtern(element, &retval);		// Call the User Procedure

     _RetVal(&retval);                          // Pass this along to the printer
}


/*----------------------------------------------------------------------+
 |  mydiv() checks for division by zero and returns a zero if an attempt|
 |  was made to do so. otherwise, it returns d1 divided by d2.          |
 +----------------------------------------------------------------------*/
static double mydiv(double d1, double d2)
{

    if (d2 == 0)
    	return 0;
    else
    	return d1/d2;

}

/*----------------------------------------------------------------------+
 |  Check for the special line characters within an object.  If the     |
 |  line characters are found, then output the correct Postscript       |
 |  procedure code which will draw the correct character.  This is done |
 |  for the soul purpose that Postscript does not handle the graphic    |
 |  symbols correctly.                                                  |
 +----------------------------------------------------------------------*/
static MHANDLE chk_special(MHANDLE srchand, int FAR *srclen, USHORT styles)
{
    MHANDLE	reshand;			// The resultant handle
    TEXT FAR	*restext;
    TEXT FAR	*srctext;
    TEXT FAR	*srcend;
    TEXT  	numstr[4];
    TEXT	buff[PDALLOCSIZE], buff2[PDALLOCSIZE];
    USHORT	i, reslen=0, x;
    TEXT	lastaline=FALSE, rjorctr[5];

    reshand = _AllocHand(PDALLOCSIZE);		// Allocate memory for the result
    if (reshand == BADHANDLE)
        _Error(182);				// Insufficient memory

    _HLock(reshand);				// We must lock the handle in order
    restext = _HandToPtr(reshand);		// To use it as a pointer.

    _HLock(srchand);				// The handle to the object
    srctext = _HandToPtr(srchand);
    srcend = srctext + *srclen;

    if (styles & P_CENTER)			// Centered?
        _StrCpy(rjorctr, "ctr ");
    else if (styles & P_RIGHT)			// Right justified?
        _StrCpy(rjorctr, "rj ");
    else
        rjorctr[0] = 0;

    PDAddChars(restext, "xy ", &reslen);

    if ((*srctext > 178) && (*srctext < 219))
	lastaline = TRUE;			// Flag the last char. as a line.
    else
    {
	if (styles & P_UNDERLINE)		// Underline the object
	    PDAddChars(restext, "u1 (",	&reslen);
	else
	    PDAddChars(restext, "(", 	&reslen);

	lastaline = FALSE;
    }

/*----------------------------------------------------------------------+
 |  Parse the object's characters one at a time checking for a graphic  |
 |  character.  If one is found, then output the correct Postscript     |
 |  code for showing the text and for drawing the graphic character.    |
 |                                                                      |
 |  Note:  All graphic characters (ASCII 179 - 219) are drawn through   |
 |  procedures written in Postscript.  These procedures are output to   |
 |  the Postscript printer at document start time.  The procedure's name|
 |  that is to be called is the actual graphic character.               |
 +----------------------------------------------------------------------*/
    for (i=0; srctext < srcend; srctext++, i++)
    {
	if ((*srctext > 178) && (*srctext < 219))	// It's a Line!
	{
	    if (lastaline)				// Was the last one a line?
                PDAdd1Char(restext, *srctext, &reslen);
	    else
	    {
		PDAddChars(restext, ") ", &reslen);
		PDAddChars(restext, rjorctr, &reslen);

		if (styles & P_UNDERLINE)
		    PDAddChars(restext, "u2 ",	&reslen);
		else
		    PDAddChars(restext, "say ",	&reslen);

		PDAddChars(restext, "mtxy ", &reslen);

		NumToStr(i, buff2);
		PDAddChars(restext, buff2, &reslen);
		PDAddChars(restext, " 0 rmt ", &reslen);
                PDAdd1Char(restext, *srctext, &reslen);

		lastaline = TRUE;
	    }

	    PDAdd1Char(restext, ' ', &reslen);
	}
	else				// It's a text char.
	{
	    if (lastaline)		// But did we have a line last?
	    {
		PDAddChars(restext, "draw mtxy ", &reslen);

		NumToStr(i, buff);
		PDAddChars(restext, buff, &reslen);

		PDAddChars(restext, " 0 rmt (", &reslen);
	    }

/*----------------------------------------------------------------------+
 |  Certain characters other than graphic characters need to be checked |
 |  for.  These characters are ones in which they have special meaning  |
 |  to the Postscript language.  These characters are Ctrl-Z Ctrl-D     |
 |  \ ( ).  When these are encountered, they are dealt with accordingly.|
 +----------------------------------------------------------------------*/

	    switch (*srctext)
	    {

            case 0x04:		// Ctrl-D and Ctrl-Z would normally tell
            case 0x1A:		// Postscript to end the job.  We replace with a space
                PDAdd1Char(restext, 32, &reslen);
            	break;

	    case '(':		// Parenthesis and the backslash have special
	    case ')':		// meaning in Postscript.  So, we need to add
	    case '\\':		// another backslach too make Postscript not eval. it
		PDAdd1Char(restext, 92,	&reslen);


	    default:		// Add the current character
	        PDAdd1Char(restext, *srctext, &reslen);
	    }

	    lastaline = FALSE;
	}
    }

    if (lastaline)
    {
	PDAdd1Char(restext, ' ', &reslen);
	PDAddChars(restext, "draw ", &reslen);
    }
    else			// Add the styles
    {
	PDAddChars(restext, ") ", &reslen);
	PDAddChars(restext, rjorctr, &reslen);

	if (styles & P_UNDERLINE)
	    PDAddChars(restext, "u2 ", &reslen);
	else
	    PDAddChars(restext, "say ", &reslen);
    }

    PDAdd1Char(restext, ' ', &reslen);

    _HUnLock(reshand);
    _HUnLock(srchand);

    *srclen = reslen;
    _SetHandSize(reshand, reslen);	// Resize the handle to the correct size

    return reshand;	    		// Return the string we put together
}



static loadPDParms(int start, int end)
{
    int         element, lelement;      // the element we are addressing
    int         errcode=0, i;           // internal error code
    Locator     loc;                    // a locator to _PDPARMS
    Value       val;                    // the value structure for _PDPARMS


    //  Load in certain element of _PDPARMS in our local copy.

    for (element=start; element < end; element++)
    {
        if (((lelement = FindLocalele(element + 1)) != -1)
                                            && (lelement < PDLOCALELES))
        {
            loc = g_pdparms;
            loc.l_sub1 = element + 1;

            if (errcode = _Load(&loc, &val))
                break;

            // Only save character types
            if ((val.ev_type != 'C') || (val.ev_handle == BADHANDLE))
            {
                g_pdElement[lelement] = BADHANDLE;
                g_pdELen[lelement]    = 0;
            }
            else
            {
                g_pdElement[lelement] = val.ev_handle;
                g_pdELen[lelement]    = val.ev_length;
            }

        }
    }

    return (-errcode);
}

/*----------------------------------------------------------------------+
 |  This routine is called on loading of the api printer driver.  It    |
 |  checks to see if _PDPARMS has been created and if so, it then loads |
 |  in certain elements of the array into an internal copy.             |
 |  This is done once, so any changes made to the xBase version of      |
 |  _PDPARMS after this, will not take any effect on our copy.  This is |
 |  done so we don't continually have to call back to FoxPro to obtain  |
 |  the value of a certain element in _PDPARMS array.                   |
 +----------------------------------------------------------------------*/
FAR pdonload()
{
    Locator     loc;                    // Locator for _PDPARMS
    int         errcode;                // internal error code
    NTI         nti;                    // Name Table Index for _PDPARMS
    Value	val;
    int         element;
    TEXT        varflag = FALSE,
                create = FALSE;
    FPFI        load_func;
    TEXT        load_elem[20];
    int         load_len=0;
    long        chksum;


    if ((nti = _NameTableIndex("_PDPARMS")) >= 0)
    {
        if (_FindVar(nti, -1, &loc))		// Is _PDPARMS around?
	{
	    if (loc.l_subs == 0)
		varflag = TRUE;
	    else
	    {
		g_pdparms = loc;		// Save the Locator to it.

                varflag = loadPDParms(0, loc.l_sub1);

	        g_lmargin = pdNval(11);			// Get the Left Margin
		g_length = 0;

/*----------------------------------------------------------------------+
 |  The following line tells us how many times this api routine has been|
 |  loaded.  This is needed in case a user loads a printer drivers and  |
 |  thus the api, and then loads the api routine via the SET LIBRARY TO |
 |  command.  Without this, we would release the local copy of _PDPARMS |
 |  (which rely heavily upon.)                                          |
 +----------------------------------------------------------------------*/

                pdStoreNVal(39, pdNval(39) + 1);

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
    else
        create = TRUE;

    if (create)			// Create _PDPARMS
    {
	loc.l_subs = 0;

        if (errcode = _NewVar("_PDPARMS", &loc, NV_PUBLIC) < 0)
                _Error(errcode);
        else
            varflag = TRUE;
    }

    if (varflag)		// Setup the Value Structure to return the -1
    {				// signifying an error occured.
	val.ev_type = 'I';
	val.ev_width = 10;
	val.ev_long = -1;
	_Store(&loc, &val);
    }
}


/*----------------------------------------------------------------------+
 |  Release the array of handles which we have accumulated for our copy |
 |  of _PDPARMS.  This only done if the value in _PDPARMS(39) is 1.     |
 +----------------------------------------------------------------------*/
FAR pdonunload()
{
    int		lelement;
    MHANDLE	hand;

    if (pdNval(39) == 1)
        _Release(g_pdparms.l_NTI);
    else
        pdStoreNVal(39, pdNval(39) - 1);


    for (lelement=0; lelement < PDLOCALELES; lelement++)
    {
	if (hand = g_pdElement[lelement])
	    _FreeHand(hand);
    }
}

/*----------------------------------------------------------------------+
 |  Put together the strings which we have built separately.  This      |
 |  in three strings (Beginning, Middle, and End) and put's them in     |
 |  the correct order.                                                  |
 +----------------------------------------------------------------------*/
static void BldStMidEnd(int element,
            TEXT FAR *startchars,  USHORT FAR *stlen,
      	    TEXT FAR *midchars, USHORT FAR *midlen,
	    TEXT FAR *endchars, USHORT FAR *endlen,
	    int flag)
{
    TEXT	buff[512];
    USHORT	bufflen;

    if (flag)
    {
        _MemMove(buff, startchars, *stlen);
	bufflen = *stlen;
    }
	     			/* Build startchars		*/
    *stlen = *midlen = *endlen = 0;
    LocalpdCval(19, startchars, stlen);
    PDAdd1Char(startchars, ' ', stlen);

    if (flag)
    {
        _MemMove(startchars + *stlen, buff, bufflen);
	*stlen += bufflen;
    }
    else
    {
        PDAdd1Char(startchars, ' ', stlen);
	LocalpdCval(18, startchars, stlen);
    }

    PDAddChars(startchars, " font ", stlen);

	     			/* Build middle chars		*/
    LocalpdCval(element, midchars, midlen);
    PDAddChars(midchars, (element == 19) ? " up " : " dn ", midlen);

	     			/* Build endchars		*/
    PDAdd1Char(endchars, ' ', endlen);
    PDAddChars(endchars, "norm ", endlen);
    LocalpdCval(element, endchars, endlen);
    PDAddChars(endchars, (element == 19) ? " dn " : " up ", endlen);
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
    TEXT   	startchars[512], buff[512], endchars[512];
    USHORT	stlen=0, bufflen=0, endlen=0, reslen;
    MHANDLE	srchand, mhand, reshand=BADHANDLE;
    int 	srclen, attrlen=0;
    TEXT 	FAR *attribs;
    TEXT 	FAR *srctext;
    TEXT 	FAR *restext;
    unsigned	styles=0;
    Value	retval;

    srchand = pblk->p[0].val.ev_handle;		// The object
    srclen = pblk->p[0].val.ev_length;

    if ((srchand != BADHANDLE) && (srclen > 0))
    {
	mhand = pblk->p[1].val.ev_handle;       // The attributes
	attrlen = pblk->p[1].val.ev_length;

	if ((mhand != BADHANDLE) && (attrlen > 0))
	{
	    _HLock(mhand);
	    attribs = ((TEXT FAR *)_HandToPtr(mhand));

	    if (mystrchr('B', attribs, attrlen))
	    {
			    		/* The object is BOLD		*/
                LocalpdCval(13, buff, &bufflen);
                if (bufflen)
                {
                    LocalpdCval(12, startchars, &stlen);
                    LocalpdCval(15, startchars, &stlen);
                    LocalpdCval(13, startchars, &stlen);
                    bufflen=0;

                }
                else
                    LocalpdCval(18,startchars, &stlen);

                styles |= P_BOLD;
	    }

	    if (mystrchr('I', attribs, attrlen))
	    {
				    	/* The object is ITALIC		*/
		if (styles)
		    LocalpdCval(14, startchars, &stlen);
		else
		{
                    LocalpdCval(14, buff, &bufflen);
                    if (bufflen)
                    {
                        LocalpdCval(12, startchars, &stlen);
                        LocalpdCval(15, startchars, &stlen);

                        if (pdLVal(38))
                            LocalpdCval(16, startchars, &stlen);

                        LocalpdCval(14, startchars, &stlen);
                        bufflen=0;
                    }
                    else
                        LocalpdCval(18, startchars, &stlen);
		}

		styles |= P_ITALIC;
	    }

	    if (mystrchr('U', attribs, attrlen)) 	/* The object is UNDERLINED	*/
		styles |= P_UNDERLINE;

	    if (mystrchr('R', attribs, attrlen))
	    {
				    	/* SUPERSCRIPT the object	*/
		BldStMidEnd(19, startchars, &stlen, buff, &bufflen,
		                endchars, &endlen, styles & (P_BOLD|P_ITALIC));

		styles |= P_RAISED;
	    }
	    else if (mystrchr('L', attribs, attrlen))
	    {
				    	/* SUBSCRIPT the object		*/
		BldStMidEnd(20, startchars, &stlen, buff, &bufflen,
		                endchars, &endlen, styles & (P_BOLD|P_ITALIC));

		styles |= P_LOWERED;
	    }
	    else if (styles & (P_BOLD | P_ITALIC))
	    {
	        			/* Build startchars (in buff)	*/
		LocalpdCval(3, buff, &bufflen);
		PDAdd1Char(buff, ' ', &bufflen);

		_MemMove(buff + bufflen, startchars, stlen);
		bufflen += stlen;

		PDAddChars(buff, " font ", &bufflen);

		stlen = startchars[0] = 0;

					/* Build endchars		*/
		PDAddChars(endchars, " norm ", &endlen);
	    }

	    _HUnLock(mhand);		// Since we're done with the handle, UnLock it
	}

	if (mystrchr('J', attribs, attrlen))
	    styles |= P_RIGHT;       	/* Check for right justification. */
	else if (mystrchr('C', attribs, attrlen))
	    styles |= P_CENTER;       	/* Check for centering.		  */

					// Check for the special characters
	mhand = chk_special(srchand, &srclen,
	                    (styles & (P_UNDERLINE|P_CENTER|P_RIGHT)));

	_HLock(mhand);
	srctext = _HandToPtr(mhand);

	if ((reshand = _AllocHand(PDALLOCSIZE)) == BADHANDLE)
        {
           _HUnLock(mhand);
           _FreeHand(mhand);
	   _Error(182);			// Insufficient memory
        }

	_HLock(reshand);
	restext = _HandToPtr(reshand);

	reslen = 0;

	if (styles && !(styles == P_UNDERLINE))
	    attrlen = (bufflen + stlen + endlen);
        else
            attrlen = 0;
	attrlen += srclen;

	if ((g_length + attrlen) > 80)		// Only output 80 chars/line
	{
	    PDAdd1Char(restext, 13, &reslen);
	    g_length = attrlen;
	}
	else
	{
	    g_length += attrlen;
	    PDAdd1Char(restext, ' ', &reslen);
	}

	if (styles && !(styles == P_UNDERLINE))
	{
	    if (bufflen)
	    {
	        _MemMove(restext + reslen, buff, bufflen);
		reslen += bufflen;
	    }
	    if (stlen)
	    {
	        _MemMove(restext + reslen, startchars, stlen);
		reslen += stlen;
	    }
	}

	if (srclen)
	{
	    _MemMove(restext + reslen, srctext, srclen);
	    reslen += srclen;
	}

	if (styles && !(styles == P_UNDERLINE))
	{
	    if (endlen)
	    {
	        _MemMove(restext + reslen, endchars, endlen);
		reslen += endlen;
	    }
	}

	_HUnLock(mhand);
	_FreeHand(mhand);

	_HUnLock(reshand);

	_SetHandSize(reshand, reslen);

	retval.ev_type   = 'C';			// Setup the value structure
	retval.ev_handle = reshand;		// for the returning string
	retval.ev_length = reslen;
    }
    else
    {
	retval.ev_type   = 'C';			// Return a handle to Nothing
	retval.ev_handle = _AllocHand(0);
        if (retval.ev_handle == BADHANDLE)
            _Error(182);

	retval.ev_length = 0;
    }

    ParseExtern(28, &retval);			// Call the object's User Proc.

    _RetVal(&retval);				// Return the object and code.
}


/*----------------------------------------------------------------------+
 |  At the beginning of each document, this procedure must be called.   |
 |  This procedure is what initializes the global variables, and        |
 |  sends the supporting code (Postscript procedures) which will be     |
 |  used throughout the printing of the document.  If this procedure    |
 |  is never called, then the Postscript procedures which are referenced|
 |  in outputting text will not be defined and thus, will cause an      |
 |  error in the report.                                                |
 +----------------------------------------------------------------------*/
FAR pddocst(ParamBlk FAR *pblk)
{
    int		i=0;
    TEXT        buff[PDALLOCSIZE], lineext[5];
    double	rval, doclen, scale, lineheight, leading;
    MHANDLE	reshand;
    TEXT FAR	*restext;
    USHORT	reslen=0;
    Value	val;

    g_length = 0;
    g_lmargin = pdNval(11);		// Get the Left Margin

    pdCval(21, buff, &i);		// Get the actual font size

/*----------------------------------------------------------------------+
 |  Determine the line height and the amount of leading.                |
 +----------------------------------------------------------------------*/
    lineheight = StrToNum(buff, i) + pdNval(35);

    rval = pdNval(36) - (g_lmargin * 2);
    lineheight =  pdNval(37) - (pdNval(7) * 2);;

    rval = mydiv(rval,((double)(pblk->p[1].val.ev_long)));
    lineheight = mydiv(lineheight, ((double)pblk->p[0].val.ev_long));

    if (rval < lineheight)
        lineheight = rval;


    i = RealNumToStr(lineheight, buff, 4);
    pdStoreCVal(9, buff, i, NO);

    leading = pdNval(4);

    pdCval(21, buff, &i);
    rval = StrToNum(buff, i);

    leading = mydiv(leading, rval);

/*----------------------------------------------------------------------+
 |  Store the Scaled Superscript fontsize and Scaled Subscript fontsize |
 +----------------------------------------------------------------------*/
    i = RealNumToStr(mydiv(pdNval(22), lineheight), buff, 1);
    pdStoreCVal(19, buff, i, YES);

    i = RealNumToStr(mydiv(pdNval(23), lineheight), buff, 1);
    pdStoreCVal(20, buff, i, YES);

    pdCval(21, buff, &i);
    rval = StrToNum(buff, i);
    rval = mydiv(rval,lineheight);
    pdStoreNVal(34, rval);		// Store the Scaled fontsize

    if ((rval + leading) > 1)		// Store the value to extend lines by
        RealNumToStr(rval + leading - 1, lineext, 3);
    else
    {
        lineext[0] = 48;
        lineext[1] = 00;
    }

    i = RealNumToStr(rval, buff, 4);
    pdStoreCVal(3, buff, i, YES);	// Store the character Scaled fontsize

    if ((reshand = _AllocHand(PDALLOCSIZE * 5)) == BADHANDLE)
        _Error(182);			// Insufficient memory

/* PATCH  :   22/4/92    Enable high ASCII characters to be printed
      by  :   Justin Nye
              Fox Software (UK) Ltd.
*/
    if ((reshand = _AllocHand(PDALLOCSIZE * 10)) == BADHANDLE)
        _Error(182);            // Insufficient memory
/*  <<<< End of Patch >>>> */

/*----------------------------------------------------------------------+
 |  Begin putting together the string which make up the PostScript      |
 |  procedures which will be used later.                                |
 +----------------------------------------------------------------------*/
    _HLock(reshand);
    restext = _HandToPtr(reshand);

    PDAddCharsandCR(restext, "%!PS-Adobe-1.0",				&reslen);
    PDAddCharsandCR(restext, "%%Creator: FoxPro Postscript driver, C Version 1.0", &reslen);
    PDAddCharsandCR(restext, "%%Title:", 				&reslen);

    PDAddChars(restext, "%%Creation Date: ",			   	&reslen);
    if (!_Evaluate(&val, "DTOC(DATE())"))
    {
        _MemMove(restext + reslen, _HandToPtr(val.ev_handle), val.ev_length);
	reslen += val.ev_length;

	_FreeHand(val.ev_handle);
    }

    PDAddChars(restext, "         ",			   	   	&reslen);
    if (!_Evaluate(&val, "TIME()"))
    {
        _MemMove(restext + reslen, _HandToPtr(val.ev_handle), val.ev_length);
	reslen += val.ev_length;

	_FreeHand(val.ev_handle);
	val.ev_handle = BADHANDLE;
    }
    PDAdd1Char(restext, 13, 			         	   	&reslen);


/*----------------------------------------------------------------------+
 |  First the Postscript codes for formfeeds, new lines,                |
 |  displaying an object, and resetting of the font to the default	|
 |  font.                                                               |
 +----------------------------------------------------------------------*/

    PDAddCharsandCR(restext, "/ff {outputflag 0 ne {showpage} if",	&reslen);
    PDAddCharsandCR(restext, "            setupsave restore",		&reslen);
    PDAddCharsandCR(restext, "            /setupsave save def ",	&reslen);
    PDAddCharsandCR(restext, "            0 linepos moveto",            &reslen);
    PDAddCharsandCR(restext, "            /lineno 0 def} def",            &reslen);

    PDAddChars(restext, "/nl {newpath linepos ", 		   	&reslen);
    RealNumToStr((pdNval(10) * rval), buff, 0);
    PDAddChars(restext, buff,						&reslen);
    PDAddCharsandCR(restext, " lt",					&reslen);

    PDAddCharsandCR(restext, "         {ff}",				&reslen);
    PDAddChars(restext, "     {lineno ",                             &reslen);
    NumToStr(pblk->p[0].val.ev_long, buff);
    PDAddChars(restext, buff,						&reslen);
    PDAddCharsandCR(restext, " ge {ff} {/linepos linepos lineheight sub def} ifelse}", &reslen);
    PDAddCharsandCR(restext, "     ifelse",				&reslen);
    PDAddCharsandCR(restext, "     /lineno lineno 1 add def",             &reslen);
    PDAddCharsandCR(restext, "     0 linepos moveto} def",		&reslen);

    PDAddCharsandCR(restext, "/say { show",				&reslen);
    PDAddCharsandCR(restext, "      /outputflag 1 def} def",		&reslen);

    PDAddChars(restext, "/norm {", 			           	&reslen);
    LocalpdCval(18, restext, 						&reslen);
    PDAddCharsandCR(restext, " findfont ",				&reslen);

    PDAddChars(restext, "     ",					&reslen);
    LocalpdCval(3, restext, 						&reslen);
    PDAddCharsandCR(restext, " scalefont setfont} def",			&reslen);

    PDAddCharsandCR(restext, "/slw {0 setlinewidth} def",		&reslen);
    PDAddCharsandCR(restext, "/rmt {rmoveto} def",			&reslen);
    PDAddCharsandCR(restext, "/xy {/objx cp pop def /objy cp exch pop def} def", &reslen);
    PDAddCharsandCR(restext, "/mtxy {objx objy moveto} def",		&reslen);
/* PATCH  :   22/4/92    Enable high ASCII characters to be printed
      by  :   Justin Nye
              Fox Software (UK) Ltd.
*/
    PDAddCharsandCR(restext, "/encoding", &reslen );
    PDAddCharsandCR(restext, "{/newcodes exch def /newfname exch def", &reslen );
    PDAddCharsandCR(restext, " /basefname exch def /basefdict basefname findfont def", &reslen );
    PDAddCharsandCR(restext, " /newfont basefdict maxlength dict def   ", &reslen );
    PDAddCharsandCR(restext, " basefdict", &reslen );
    PDAddCharsandCR(restext, " { exch dup /FID ne { dup /Encoding eq", &reslen );
    PDAddCharsandCR(restext, "   { exch dup length array copy newfont 3 1 roll put }", &reslen );
    PDAddCharsandCR(restext, "   { exch newfont 3 1 roll put }", &reslen );
    PDAddCharsandCR(restext, " ifelse } { pop pop } ifelse } forall", &reslen );
    PDAddCharsandCR(restext, " newfont /FontName newfname put", &reslen );
    PDAddCharsandCR(restext, " newcodes aload pop newcodes length 2 idiv", &reslen );
    PDAddCharsandCR(restext, " { newfont /Encoding get 3 1 roll put} repeat", &reslen );
    PDAddCharsandCR(restext, "newfname newfont definefont pop } def", &reslen );

    PDAddCharsandCR(restext, "/intl [ 21 /section 39 /quotesingle 96 /grave 128 /Ccedilla 129 /udieresis", &reslen );
    PDAddCharsandCR(restext, " 130 /eacute 131 /acircumflex 132 /adieresis 133 /agrave", &reslen );
    PDAddCharsandCR(restext, " 134 /aring 135 /ccedilla 136 /ecircumflex 137 /edieresis", &reslen );
    PDAddCharsandCR(restext, " 138 /egrave 139 /idieresis 140 /icircumflex 141 /igrave", &reslen );
    PDAddCharsandCR(restext, " 142 /Adieresis 143 /Aring 144 /Eacute 145 /ae 146 /AE", &reslen );
    PDAddCharsandCR(restext, " 147 /ocircumflex 148 /odieresis 149 /ograve", &reslen );
    PDAddCharsandCR(restext, " 150 /ucircumflex 151 /ugrave 152 /ydieresis 153 /Odieresis", &reslen );
    PDAddCharsandCR(restext, " 154 /Udieresis 155 /cent 156 /sterling 157 /yen", &reslen );
    PDAddCharsandCR(restext, " 158 /fi 159 /florin 160 /aacute 161 /iacute 162 /oacute 163 /uacute", &reslen );
    PDAddCharsandCR(restext, " 164 /ntilde 165 /Ntilde 166 /ordfeminine 167 /ordmasculine", &reslen );
    PDAddCharsandCR(restext, " 168 /questiondown 170 /logicalnot", &reslen );
    PDAddCharsandCR(restext, " 173 /exclamdown 174 /guillemotleft 175 /guillemotright", &reslen );
    PDAddCharsandCR(restext, " 225 /germandbls 248 /degree", &reslen );

    PDAddCharsandCR(restext, " 226 /Gamma 228 /Sigma", &reslen );
    PDAddCharsandCR(restext, " 224 /alpha 227 /pi 243 /lessequal 236 /infinity", &reslen );
    PDAddCharsandCR(restext, " 241 /plusminus 242 /greaterequal 246 /divide 240 /equivalence", &reslen );
    PDAddCharsandCR(restext, " 247 /approxequal 239 /intersection 238 /element 251 /radical", &reslen );
    PDAddCharsandCR(restext, " ] def", &reslen );
    PDAddCharsandCR(restext, " /Courier /Courier intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Courier-Oblique /Courier-Oblique intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Courier-Bold /Courier-Bold intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Courier-BoldOblique /Courier-BoldOblique intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Helvetica /Helvetica intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Helvetica-Oblique /Helvetica-Oblique intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Helvetica-Bold /Helvetica-Bold intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Helvetica-BoldOblique /Helvetica-BoldOblique intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Times-Roman /Times-Roman intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Times-Italic /Times-Italic intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Times-Bold /Times-Bold intl encoding", &reslen );
    PDAddCharsandCR(restext, " /Times-BoldItalic /Times-BoldItalic intl encoding", &reslen );
/****** end Patch *********/

    PDAddCharsandCR(restext, "/trim {{( ) anchorsearch {pop} {exit} ifelse} loop} def",	&reslen);

    PDAddCharsandCR(restext, "/strw {dup length /strwidth exch def} def",&reslen);

/*----------------------------------------------------------------------+
 |  Second, will be the Postscript codes for pushing the 		|
 |  currentpoint on the stack, moving to a point on the page, 	        |
 |  changing the font, manipulating the stack, and underlining 	        |
 |  an object. Some of these are one command procedures which is 	|
 |  done inorder to minimize the output of the printer driver.	        |
 +----------------------------------------------------------------------*/

    PDAddCharsandCR(restext, "/numwidth {dup stringwidth pop strwidth exch sub} def", &reslen);
    PDAddCharsandCR(restext, "/jfy {strw trim numwidth} def",				&reslen);
    PDAddCharsandCR(restext, "/rj {jfy 0 rmt xy} def",				&reslen);
    PDAddCharsandCR(restext, "/ctr {jfy 2 div 0 rmt xy} def",				&reslen);
    PDAddCharsandCR(restext, "/cp {currentpoint} def", 			&reslen);
    PDAddCharsandCR(restext, "/mt {moveto} def", 			&reslen);
    PDAddCharsandCR(restext, "/font {findfont exch scalefont setfont} def", &reslen);
    PDAddCharsandCR(restext, "/rol {cp 3 -1 roll} def", 			&reslen);
    PDAddCharsandCR(restext, "/mv {rol exch mt pop} def", 		&reslen);
    PDAddCharsandCR(restext, "/up {rol add mt} def", 			&reslen);
    PDAddCharsandCR(restext, "/dn {rol sub mt} def", 			&reslen);

    PDAddChars(restext, "/u1 {xy 0 ",			 		&reslen);
    LocalpdCval(3, restext, 						&reslen);
    PDAddCharsandCR(restext, " -.1 mul rmt} def", 			&reslen);

    PDAddCharsandCR(restext, "/u2 {dup stringwidth",			&reslen);

    PDAddChars(restext, "     ", 			        	&reslen);
    RealNumToStr(pdNval(34) * 0.04, buff, 2);
    PDAddChars(restext, buff, 						&reslen);
    PDAddCharsandCR(restext, " setlinewidth", 				&reslen);

    PDAddCharsandCR(restext, "      rlineto gsave stroke grestore", 	&reslen);
    PDAddCharsandCR(restext, "      mtxy slw say} def", 		&reslen);


/*----------------------------------------------------------------------+
 |  Third will be the Postscript codes to handle the graphical 	        |
 |  characters in range of ASCII 179 to 218.  Each character is	        |
 |  handled sepearately.						|
 +----------------------------------------------------------------------*/

    PDAddCharsandCR(restext, "/gcp {mt 1 0 rmt} def", 			&reslen);

    PDAddChars(restext, "/l1 {dup 0 le {",                              &reslen);
    PDAddChars(restext, lineext,                                        &reslen);
    PDAddChars(restext, " sub} {",						&reslen);
    PDAddChars(restext, lineext,                                        &reslen);
    PDAddCharsandCR(restext, " add} ifelse 0 exch rlineto} def",	&reslen);

    PDAddCharsandCR(restext, "/l2 {0 rlineto} def", 			&reslen);
    PDAddCharsandCR(restext, "/dhl {0 .4 rmt l2 0 .2 rmt l2} def", 	&reslen);
    PDAddCharsandCR(restext, "/dvl {.4 0 rmt l1 .2 0 rmt l1} def", 	&reslen);
    PDAddCharsandCR(restext, "/lm {rol 0 rmt} def", 			&reslen);
    PDAddCharsandCR(restext, "/ulc {mt cp 0 .6 rmt .4 l2 .4 l1} def", 	&reslen);
    PDAddCharsandCR(restext, "/blc {mt cp 0 .4 rmt .4 l2 -.4 l1} def", 	&reslen);
    PDAddCharsandCR(restext, "/urc {mt cp 1 .6 rmt -.4 l2 .4 l1} def", 	&reslen);
    PDAddCharsandCR(restext, "/brc {mt cp 1 .4 rmt -.4 l2 -.4 l1} def",	&reslen);
    PDAddCharsandCR(restext, "/trc {mt cp 0 .6 rmt .6 l2 -.6 l1} def", 	&reslen);
    PDAddCharsandCR(restext, "/lrc {mt cp 0 .4 rmt .6 l2 .6 l1} def", 	&reslen);
    PDAddCharsandCR(restext, "/tlc {mt cp 1 .4 rmt -.6 l2 .6 l1} def", 	&reslen);

    PDAddCharsandCR(restext, "/llc {mt cp 1 .6 rmt -.6 l2 -.6 l1} def",	&reslen);
    PDAddCharsandCR(restext, "/³ {cp .5 0 rmt 1 l1 gcp} def", 		&reslen);
    PDAddCharsandCR(restext, "/´ {cp 0 .5 rmt .5 l2 0 -.5 rmt 1 l1 gcp} def", 	&reslen);
    PDAddCharsandCR(restext, "/µ {³ -1 0 rmt cp 0 .4 rmt .5 l2 0 .2 rmt -.5 l2 gcp} def", 	&reslen);
    PDAddCharsandCR(restext, "/¶ {º -1 0 rmt cp 0 .5 rmt .3 l2 gcp} def", &reslen);
    PDAddCharsandCR(restext, "/· {cp 0 .5 rmt .6 l2 -.6 0 rmt .5 -.5 dvl gcp} def", &reslen);
    PDAddCharsandCR(restext, "/¸ {cp -.5 .5 dhl .5 0 rmt -.6 l1 gcp} def", &reslen);
    PDAddChars(restext, "/¹ {cp ulc blc mt cp .6 0 rmt 1 l1 0 -1 ",&reslen);
    PDAddChars(restext, lineext,                                        &reslen);
    PDAddCharsandCR(restext, " sub rmt 0 l1 gcp} def",                  &reslen);
    PDAddCharsandCR(restext, "/º {cp -1 1 dvl gcp} def",               &reslen);
    PDAddCharsandCR(restext, "/» {cp blc trc gcp} def", 		&reslen);
    PDAddCharsandCR(restext, "/¼ {cp ulc lrc gcp} def", 		&reslen);
    PDAddCharsandCR(restext, "/½ {cp 0 .5 rmt -.5 .5 dvl -.6 l2 gcp} def", &reslen);
    PDAddCharsandCR(restext, "/¾ {cp -.5 .5 dhl .5 -.2 rmt .5 l1 gcp} def",&reslen);

    PDAddCharsandCR(restext, "/¿ {cp 0 .5 rmt .5 l2 -.5 l1 gcp} def", &reslen);
    PDAddCharsandCR(restext, "/À {cp 1 .5 rmt -.5 l2 .5 l1 gcp} def", &reslen);
    PDAddCharsandCR(restext, "/Á {cp 0 .5 rmt 1 l2 -.5 0 rmt .5 l1 gcp} def", 	&reslen);
    PDAddCharsandCR(restext, "/Â {cp 0 .5 rmt 1 l2 -.5 0 rmt -.5 l1 gcp} def", 	&reslen);
    PDAddCharsandCR(restext, "/Ã {cp .5 .5 rmt .5 l2 -.5 -.5 rmt 1 l1 gcp} def",      &reslen);
    PDAddCharsandCR(restext, "/Ä {cp 0 .5 rmt 1 l2 gcp} def", 	&reslen);
    PDAddCharsandCR(restext, "/Å {cp 0 .5 rmt 1 l2 -.5 -.5 rmt 1 l1 gcp} def", 	&reslen);
    PDAddCharsandCR(restext, "/Æ {³ -1 0 rmt cp .5 .4 rmt .5 l2 0 .2 rmt -.5 l2 gcp} def", 	&reslen);
    PDAddCharsandCR(restext, "/Ç {º -1 0 rmt cp .6 .5 rmt .4 l2 gcp} def", &reslen);

    PDAddCharsandCR(restext, "/È {cp urc tlc gcp} def", 		&reslen);
    PDAddCharsandCR(restext, "/É {cp brc llc gcp} def", 		&reslen);
    PDAddCharsandCR(restext, "/Ê {cp urc ulc mt cp 0 .4  rmt 1 l2 gcp} def", &reslen);
    PDAddCharsandCR(restext, "/Ë {cp brc blc mt cp 0 .6 rmt 1 l2 gcp} def",  &reslen);

    PDAddChars(restext, "/Ì {cp urc brc mt cp .4  0 rmt 1 l1 0 -1 ",  &reslen);
    PDAddChars(restext, lineext,                                        &reslen);
    PDAddCharsandCR(restext, " sub rmt 0 l1 gcp} def",                  &reslen);
    PDAddCharsandCR(restext, "/Í {cp -1 1 dhl gcp} def", 		&reslen);
    PDAddCharsandCR(restext, "/Î {cp ulc blc urc brc gcp} def", 	&reslen);
    PDAddCharsandCR(restext, "/Ï {cp -1 1 dhl .5 0 rmt .4 l1 gcp} def", &reslen);
    PDAddCharsandCR(restext, "/Ð {Ä -1 0 rmt cp 0 .5 rmt -.5 .5 dvl gcp} def", 	&reslen);

    PDAddCharsandCR(restext, "/Ñ {cp -1 1 dhl .5 -.2 rmt  -.4 l1 gcp} def", &reslen);
    PDAddCharsandCR(restext, "/Ò {Ä -1 0 rmt cp 0 .5 rmt .5 -.5 dvl gcp} def", &reslen);
    PDAddCharsandCR(restext, "/Ó {cp 0 .5 rmt -.5 .5 dvl -.2 0 rmt .6 l2 gcp} def", 	&reslen);

    PDAddChars(restext, "/Ô {cp .5 .4 rmt .6 l1 0 -1 ",               &reslen);
    PDAddChars(restext, lineext,                                        &reslen);
    PDAddCharsandCR(restext, " sub rmt -.6 .6 dhl gcp} def",            &reslen);

    PDAddCharsandCR(restext, "/Õ {cp .4 0 rmt -.6 .6 dhl -.6 l1 gcp} def",   &reslen);
    PDAddChars(restext, "/Ö {cp .4 .5 rmt .6 l2 -1 -.5 ",            &reslen);
    PDAddChars(restext, lineext,                                        &reslen);
    PDAddCharsandCR(restext, " sub rmt -.5 .5 dvl gcp} def",            &reslen);

    PDAddCharsandCR(restext, "/× {cp -1 1 dvl mt Ä} def",           &reslen);
    PDAddCharsandCR(restext, "/Ø {cp -1 1 dhl mt ³} def", 		&reslen);
    PDAddCharsandCR(restext, "/Ù {cp 0 .5 rmt .5 l2 .5 l1 gcp} def", 	&reslen);
    PDAddCharsandCR(restext, "/Ú {cp 1 .5 rmt -.5 l2 -.5 l1 gcp} def", 	&reslen);
    PDAddCharsandCR(restext, "/draw {gsave stroke grestore newpath mtxy",       &reslen);
    PDAddCharsandCR(restext, "      /outputflag 1 def} def", 		&reslen);


/*----------------------------------------------------------------------+
 |  Finally will be the Postscript codes for the default settings of	|
 |  the printer.  It sets the linewidth for graphical characters, it	|
 |  sets the orientation, scale, font, pageheight, and number of	|
 |  copies.	                                                        |
 +----------------------------------------------------------------------*/

    PDAddCharsandCR(restext, "%%EndProlog",				&reslen);
    PDAdd1Char(restext, 13, 			      			&reslen);

    PDAddCharsandCR(restext, "slw",                 			&reslen);

    if (pdLVal(1))				// Set the orientation
    {
	RealNumToStr(g_lmargin, buff, 0);
	PDAddChars(restext, buff,					&reslen);
	PDAdd1Char(restext, 32, 					&reslen);
	RealNumToStr(pdNval(7), buff, 0);
	PDAddChars(restext, buff,					&reslen);
    }
    else					// Landscape printing
    {
	PDAddChars(restext, "-90 rotate -",      			&reslen);
	RealNumToStr(pdNval(36), buff, 0);
	PDAddChars(restext, buff,                   			&reslen);
	PDAddCharsandCR(restext, " 0 translate",    			&reslen);
	RealNumToStr(pdNval(7), buff, 0);
	PDAddChars(restext, buff,					&reslen);
        PDAdd1Char(restext, 32,                 			&reslen);
	RealNumToStr(g_lmargin, buff, 0);
	PDAddChars(restext, buff,					&reslen);
    }

    PDAddCharsandCR(restext, " translate",				&reslen);
    pdCval(9, buff, &i);
    _MemMove(restext + reslen, buff, i);
    reslen += i;
    PDAdd1Char(restext, ' ',						&reslen);
    _MemMove(restext + reslen, buff, i);
    reslen += i;
    PDAddCharsandCR(restext, " scale",		     			&reslen);

    pdCval(18, buff, &i);
    _MemMove(restext + reslen, buff, i);
    reslen += i;

    PDAddChars(restext, " findfont ", 					&reslen);
    pdCval(3, buff, &i);
    _MemMove(restext + reslen, buff, i);
    reslen += i;
    PDAddCharsandCR(restext, " scalefont setfont",			&reslen);

    PDAddChars(restext, "/pageheight ", 				&reslen);
    rval = mydiv(pdNval(37), ((double)lineheight));
    RealNumToStr(rval, buff, 0);
    PDAddChars(restext, buff, 						&reslen);
    PDAddCharsandCR(restext, " def", 					&reslen);

    PDAddChars(restext, "/lineheight ",		 			&reslen);
    RealNumToStr(pdNval(34) + leading, buff, 2);
    PDAddChars(restext, buff, 						&reslen);
    PDAddCharsandCR(restext, " store",		 			&reslen);

    PDAddChars(restext, "/#copies ", 		      			&reslen);
    pdCval(2, buff, &i);
    _MemMove(restext + reslen, buff, i);
    reslen += i;
    PDAddCharsandCR(restext, " store", 					&reslen);

    PDAddChars(restext, "/linepos pageheight ", 			&reslen);
    RealNumToStr(mydiv((pdNval(7) * 2), lineheight), buff, 3);
    PDAddChars(restext, buff, 						&reslen);
    PDAddCharsandCR(restext, " sub def", 					&reslen);

    PDAddCharsandCR(restext, "/outputflag 0 def", 			&reslen);
    PDAddCharsandCR(restext, "/setupsave save def", 			&reslen);
    PDAddCharsandCR(restext, "/lineno 0 def",                           &reslen);
    PDAddCharsandCR(restext, "newpath ff", 				&reslen);


    _HUnLock(reshand);
    _SetHandSize(reshand, reslen);

    val.ev_type = 'C';			// Setup the Value structure to return
    val.ev_length = reslen;

    val.ev_handle = reshand;		// Handle to the return value

    ParseExtern(24, &val);		// Call the User Procedure

    _RetVal(&val);
}


/*----------------------------------------------------------------------+
 |  On completion of the document, this routine gets called.  It does   |
 |  a little cleanup and returns the jobend code to the printer.	|
 +----------------------------------------------------------------------*/
FAR pddocend()
{
    USHORT	ctllen=0;
    int		i=0;
    TEXT	ctlchars[PDALLOCSIZE], buff[10];

    PDAddCharsandCR(ctlchars, " ff", &ctllen);
    PDAddCharsandCR(ctlchars, "%%Trailer", &ctllen);
    PDAddCharsandCR(ctlchars, "setupsave restore", &ctllen);

    if (pdCval(2, buff, &i) && ((i != 1) || _MemCmp(buff, "1", 1)))
        PDAddChars(ctlchars, "/#copies 1 store", &ctllen);
    PDAdd1Char(ctlchars, 13, &ctllen);
    PDAdd1Char(ctlchars,  4, &ctllen);

    RetBinary(ctlchars, ctllen, 32);
}


/*----------------------------------------------------------------------+
 |  On page start, this routine gets called.							|
 +----------------------------------------------------------------------*/
FAR pdpagest()
{
    USHORT	ctllen=0;
    TEXT	ctlchars[5];

    PDAddChars(ctlchars, " ff", &ctllen);

    if ((g_length += ctllen) > 80)
    {
        g_length = ctllen;
	PDAdd1Char(ctlchars, 13, &ctllen);
    }
    else
        PDAdd1Char(ctlchars, ' ', &ctllen);

    RetBinary(ctlchars, ctllen, 25);
}


/*----------------------------------------------------------------------+
 |  This routine gets called at the end of every line.  It returs the   |
 |  Postscript code which will move to the next line.                   |
 +----------------------------------------------------------------------*/
FAR pdlineend()
{
    USHORT	ctllen=0;
    TEXT	ctlchars[5];

    PDAddChars(ctlchars, " nl", &ctllen);

    if ((g_length += ctllen) > 80)
    {
        g_length = ctllen;
	PDAdd1Char(ctlchars, 13, &ctllen);
    }

    RetBinary(ctlchars, ctllen, 30);		// Call the User Procedure
}


/*----------------------------------------------------------------------+
 |  Advance the printer horizontally to the appropriate column.	        |
 +----------------------------------------------------------------------*/
FAR pdadvprt(ParamBlk FAR *pblk)
{
    USHORT	ctllen=0, i;
    TEXT	ctlchars[PDALLOCSIZE], numstr[NUMWIDTH];
    double	rval;

    rval = (pblk->p[1].val.ev_long);		// What column to go to

    NumToStr(rval, numstr);
    i = _StrLen(numstr);

    if ((g_length += i) > 80)
    {
	PDAdd1Char(ctlchars, 13, &ctllen);
	g_length = i;
    }
    else
        PDAdd1Char(ctlchars, ' ', &ctllen);

    PDAddChars(ctlchars, numstr, &ctllen);
    PDAddChars(ctlchars, " mv", &ctllen);

    RetBinary(ctlchars, ctllen, -1);
}


FoxInfo myFoxInfo[] = {
	{"PDOBJECT",pdobject,2,"C,C"},
	{"PDDOCST",pddocst,2,"I,I"},
	{"PDDOCEND",pddocend,0,""},
	{"PDPAGEST",pdpagest,0,""},
	{"PDLINEEND",pdlineend,0,""},
	{"PDADVPRT",pdadvprt,2,"I,I"},
	{"PDONLOAD", pdonload, CALLONLOAD, ""},
	{"PDONUNLOAD", pdonunload, CALLONUNLOAD, ""}
};

FoxTable _FoxTable = {
	(FoxTable FAR *)0, sizeof(myFoxInfo) / sizeof(FoxInfo), myFoxInfo
};
