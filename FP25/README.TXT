                       README.TXT
**********************************************************
                   Release Notes for
 
    Microsoft(R) FoxPro(R) for MS-DOS (R) Version 2.5b

    (C)1993 Microsoft Corporation. All Rights Reserved.

Information in the FoxPro online Help is more current than
information in the printed documentation. This README
provides information not contained in the FoxPro online
help or documentation, and provides corrections to both.
**********************************************************
========
CONTENTS
========

Part   Description
----   -----------
1      Installation
2      WAIT...WINDOW Enhancements
3      New Commands and Functions
4      New Transporter and Screen Directives
5      International and Cross-Platform Recommendations

----------------------------------------------------------
====================
Part 1: Installation 
====================

There are three types of installation for FoxPro for
MS-DOS: Normal Installation, Administrative Installation
and Workstation Installation. Instructions for Normal
Installation are in the FoxPro Installation and
Configuration manual. For information about Administrative
and Workstation Installation, see INSTALL.TXT on FoxPro 
for MS-DOS Disk 1.
----------------------------------------------------------
================================
Part 2: WAIT WINDOW Enhancements 
================================

WAIT WINDOW now supports multiple line messages. Use a
carriage return (CHR(13)) to move portions of your message
to additional lines. The message window is automatically
expanded to accommodate additional lines. For example, this
command creates a message window that contains two lines:

WAIT WINDOW "This is the 1st line" + CHR(13) + ;
    "This is the 2nd line"

The width of the message window is adjusted to fit the
longest line in the message. All lines in the message are
left justified in the message window. Line feeds (CHR(10))
following CHR(13) are ignored.
----------------------------------------------------------
==================================
Part 3: New Commands and Functions 
==================================

Several new commands and functions are added to
FoxPro 2.5b. For additional information about these
commands and functions, see the "International and Cross
Platform Recommendations" section below and the
corresponding topics in Help.

New Commands
------------

SET NOCPTRANS
SET COLLATE

New Functions
-------------

CPCURRENT( )
CPDBF( )
CPCONVERT( )
IDXCOLLATE( )
----------------------------------------------------------
=============================================
Part 4: New Transporter and Screen Directives 
=============================================

Several new Transporter and screen directives have been
added.

The #DOSOBJ, #MACOBJ, #UNIXOBJ and #WINOBJ  
Transporter directives allow you to transport objects
created in the Screen Builder and Report Writer to 
specific FoxPro platforms. For additional information 
about these Transporter directives, see the Transporting 
Files topic in Help.

#TRAN SNIPPET ONLY, a new screen directive, is available
in FoxPro 2.5b. This screen directive affects how screen
objects are transported, and is not discussed in Help.
#TRAN SNIPPET ONLY is designed to limit the Transporter's
changes to just screen snippets, and is placed in
a screen's Setup snippet.

When screen objects are transported to a different FoxPro
platform, only the screen snippets for updated screen
objects are transported if #TRAN SNIPPET ONLY is included.
All other screen object attributes are not transported to
the different platform. 

Note that #TRAN SNIPPET ONLY only affects updated screen
objects; it does not affect new or unchanged screen
objects or screen objects being transported for the first
time.
----------------------------------------------------------
=========================================================
Part 5: International and Cross Platform Recommendations 
========================================================= 

                   *** IMPORTANT ***

*******************************************************
*  Be sure to read this section completely before you *
*  change code pages or collation sequences!          *
*******************************************************

Overview of topics

1   FoxPro Collation Sequences
2   Case-Insensitive Collation Sequences
3   Case-Sensitive Collation Sequences
4   How do the SEEK and SKIP commands work?
5   Alternatives to SEEK and SKIP
6   Additional Recommendations
7   New Code Pages
8   CPZERO Program
9   Corrections to the Help File

FoxPro 2.5b gives international developers and users
powerful new features for handling accented characters
across different FoxPro platforms, and provides 
accurate sorting in many languages.

For international FoxPro users, this section describes
how code pages and collation sequences affect sorting,
seeking and comparisons using the SORT and SEEK commands,
and also provides recommendations for taking advantage
of these features.

U.S. FoxPro users whose applications don't contain
accented characters may not need any of the new
international 2.5b features. In this case, you can
disregard this section of the README and the
International/X-Platform topic in Help. FoxPro 2.5b is
100% percent compatible with FoxPro 2.5.  

1 FoxPro Collation Sequences
----------------------------

With a MACHINE collation sequence, which earlier FoxPro
versions use (and to which FoxPro 2.5b still defaults),
each character in the code page, whether it's a Roman
character, an accented character, or a line-drawing
character, has a unique "sort weight" determined by its
position in the code page. In a majority of code
pages, all accented characters appear after the unaccented
characters. In this situation an � sorts after z, which
isn't correct in most languages (although it is true in
Swedish, for instance).

Furthermore, in most languages accented characters sort
after their unaccented counterparts, but only if the
unaccented versions of all characters being compared are
the same. For example, in German, � sorts after the
unaccented a, but the string �a sorts before the string ab
because the second character a is less than the second
character b. In this way, characters are interleaved in
many cultures.

FoxPro 2.5b supports a number of new collation sequences
to correctly sort in many languages. These sequences take
into account all the complex rules of the language
(including two-to-one, three-to-one and one-to-two
mappings). The following collation sequences were
available when this README was created. The code pages
for which these collation sequences are defined are also
included.

Collation Sequence   Friendly Name    Code Pages
------------------   -------------    ----------
CZECH                Czech            852, 895, 1250			
DUTCH                Dutch            437, 850, 1252
GREEK                Greek            737, 1253			
GENERAL              General          437, 620, 850,
                                      852, 861, 865,
                                      895, 1250, 1252,
                                      10000			
HUNGARY              Hungarian        852, 1250			
ICELAND              Icelandic        437, 850, 861,
                                      1252
MACHINE              Machine          All			
NORDAN               Norwegian/Danish 437, 850, 865,
                                      1252	
POLISH               Polish           620, 852, 1250			
RUSSIAN              Russian          866, 1251			
SLOVAK               Slovak           852, 895, 1250			
SPANISH              Spanish          437, 850, 1252
SWEFIN               Swedish/Finnish  437, 850, 1252
UNIQWT               Unique Weight    437, 850, 1252,
                                      10000	

If you specify a collation sequence in the SET COLLATE
command as a string literal, enclose the collation
sequence in quotation marks. Don't enclose the collation
sequence in quotation marks if you specify a collation
sequence in your FoxPro configuration file (CONFIG.FP or
CONFIG.FPW).

If you use the SET COLLATE command to specify a collation 
sequence that isn't supported by the current code page, 
FoxPro generates an error. If you specify a collation 
sequence in your FoxPro configuration file that isn't 
supported by the current code page, the collation sequence 
defaults to MACHINE.

If you specify a collation sequence in the International
panel in the View window, the collation sequence names 
appear in longer forms. For example, the NORDAN option 
appears as Norwegian & Danish, and the SWEFIN option 
appears as Swedish & Finnish.

For additional information about collation sequences, see
SET COLLATE in Help.

3 Case-Sensitive Collation Sequences
------------------------------------

Two case-sensitive collation sequences are available in
FoxPro: the familiar MACHINE sequence, the default
sequence in earlier FoxPro versions, and the sequence
named UNIQWT. UNIQWT is a "unique weight" sort in which 
each accented character sorts strictly after its 
unaccented counterpart (unlike the interleaving of 
accented characters described earlier).

While the collation sequence with UNIQWT isn't strictly
culturally correct as with GENERAL, it may aid developers
in migrating their applications from earlier FoxPro
versions. One reason is that upper- and lower-case letter
are treated distinctly as they were in earlier FoxPro
versions. Another reason is described in the section
titled "How do the SEEK and SKIP commands work?"

4 How do the SEEK and SKIP commands work?
-----------------------------------------

The SEEK command accepts an expression. FoxPro transforms
that expression into a sort key which it compares to
keys in the master index or tag. SEEK then positions the 
record pointer at the first index entry that's greater 
than or equal to ( >= ) the supplied key.

With a machine sort, SEEK finds a match if there is one.
The UNIQWT sort has the same property. But when FoxPro
uses the new language-specific collation sequences to
create indexes, only the alphabetic part of the key is
considered and any diacritical marks are ignored. In other
words, even if you SEEK "�bc" you may find "abc". Note
that partial searches (where you search for part of the
field) using SEEK may not return the results you expect
when the current collation sequence is not MACHINE or
UNIQWT.

FoxPro behaves this way for the following three reasons:

1) Performance.

2) Consistency with the SKIP command.

3) Consistency with the SET NEAR command.

To have SEEK and SKIP find only those records that exactly
match accented characters, you must either SET EXACT ON or
use an index tag created with the MACHINE or UNIQWT
collation sequences. 

Note that SEEK and SKIP use the collation sequence of the
master index or tag, and ignore the current collation
sequence. SEEK can't be used unless there is an index is
active.  

5 Alternatives to SEEK and SKIP
-------------------------------

If you use accented characters, use one of the following
methods to search a table:

1) Construct a loop with SCAN FOR ... ENDSCAN.

2) Use LOCATE FOR ... CONTINUE. 

LOCATE and SCAN use an index if one is active, and
they have two very significant advantages over SEEK when
data contains accented characters.

First, both LOCATE and SCAN remember the condition with
which they were invoked, so they can be used for looping
on a condition. SEEK, on the other hand, simply positions
you somewhere in the index, and SKIP continues down the
index from that point. With international data, this may
not give you the results you want.

Second, LOCATE and SCAN are diacritically-sensitive,
whereas SEEK isn't. In addition, both LOCATE and SCAN can
be fully optimized by Rushmore if the current collation
sequence is MACHINE or UNIQWT; otherwise partial
optimization will occur.

The ORDER BY clause of the SQL SELECT command uses the
current collating sequence, which is returned by
SET("COLLATE")).

6 Additional Recommendations
----------------------------

1) If you aren't concerned with indexing accented
characters in a language-specific way, feel free to
continue to use machine indexes. For many U.S. users,
this is appropriate.

2) For the best performance when using a collation
sequence other than MACHINE or UNIQWT, be sure that the
current collation sequence is the same as the collation
sequence of any indexes you are using.

3) Most international users will want accented characters
in all fields to be translated automatically by FoxPro
when running cross-platform applications. However, if you
have a table with a character field that's actually 
storing binary information (data), the SET NOCPTRANS 
command allows you to inform FoxPro that characters
in such a field should not be translated. 

Binary data might otherwise be changed, because of
FoxPro's "nearest" character mapping.  For characters such
as the MS-DOS line-drawing characters, FoxPro maps to the
"nearest" character in the destination code page.

If you choose to use SET NOCPTRANS, you must do so
immediately after issuing the USE command. From that
point on, FoxPro's automatic character translation is
not in effect for any fields you designate. In particular, 
you must issue the SET NOCPTRANS command before issuing 
a SQL SELECT command -- you cannot let SQL SELECT open
tables for you if the tables contain fields which should
not be translated.

Note that SET NOCPTRANS only operates on fields for the
table open in the currently selected work area.  If you
close a table and then open the table again, you must
reissue SET NOCPTRANS and designate the fields which
should not be translated.

4) If you create cross platform applications, you should
avoid using FoxFont. FoxFont is an OEM MS-DOS font that
you may find useful in some situations. But if you use
FoxFont in an application you create in FoxPro for
Windows, some of the characters in the application may
not transport correctly to other FoxPro platforms.

Furthermore, FoxFont won't correctly display characters
typed on international Windows keyboards. If you have
automatic code page translation enabled, FoxPro will
display accented characters correctly.

FoxFont is the installed default font for the FoxPro
desktop. FoxFont is the default font for user-defined
windows created with DEFINE WINDOW when the FONT clause
is omitted. Be sure to include the FONT clause when
creating user-defined windows in FoxPro for Windows.

FixedSys is the default font for the Command, Trace and
Debug windows if you're using Windows 3.1. Text editor
windows default to the current Command window font. 

5) FoxPro 2.5b can automatically translate accented
characters in most files types such as .DBF, .SCX, and
.FXP files. However, program (.PRG) and text (.TXT)
files don't have a header and can't be marked with a code
page. Therefore, FoxPro must assume that a program or text
file was designed for use on the platform on which it is
opened.

It's important that you compile each program on the 
platform on which it was written. Since compiled programs 
(.FXP files) have a header, once you compile a program, it 
can be run on any FoxPro platform and accented characters 
in the original source program are automatically 
translated when automatic code page translation is in 
effect.

6) Do not mix programs created on different FoxPro
platforms in a project. The Project Manager assumes that
all programs in a project are native to the current FoxPro
platform. If you create an application or an executable
from a project that contains programs created on different
FoxPro platforms, translation of accented characters in
the programs might not be translated properly.

Also, within the Project Manager you can't specify the
platform on which a program or text file was created.
Therefore, in the Project Manager don't edit programs or
tables created on a FoxPro platform other than the current 
platform.  This means that you shouldn't double-click on a
file to open it in the Project Manager if you've enabled
automatic translation by including CODEPAGE = AUTO in 
your FoxPro configuration file.

If you create an application that contains files created
on different FoxPro platforms, do not open the files for
editing from within the Project Manager.

However, once you build an application (.APP file), it
will run on any FoxPro platform and FoxPro can
automatically translate accented characters.

7) If you have a project created in FoxPro for MS-DOS
version 2.0 and the files within the project contain 
accented characters, you can share the project and 
its files across different FoxPro platforms by performing
the  following steps to convert the project and its files.
This conversion is required just once, and enables cross 
platform sharing of all the elements of the project.

a) Open the project in FoxPro for MS-DOS 2.5b or FoxPro
   for Windows 2.5b. A dialog appears, asking if you would 
   like to convert the project to a 2.5 format. Choose 
   Yes, then close the project.
  
b) Open every screen, report, label, menu and table
   contained in the project with the USE command. You are 
   prompted for the code page (437, 850 and so on) on 
   which each was created. Specify the MS-DOS code page 
   on which each was built and then choose Yes.

c) Use MODIFY COMMAND or MODIFY FILE and include the
   AS clause to open EVERY program, query, format file
   or text file contained in the project. In the AS
   clause, specify the code page (437, 850 and so on)
   of the FoxPro platform on which each was created.
   Choose the Save As option from the File menu and choose
   the Change Code Page check box.  In the dialog that
   appears after you choose Save, specify the code page
   for the FoxPro platform on which the file will be used.

8) If you're developing a cross-platform application,
avoid using characters that appear in one code page and
not another. For example, the MS-DOS line drawing
characters aren't supported under Windows, so avoid using
them in screens you plan to transport between FoxPro for
MS-DOS and FoxPro for Windows.

You can use CHR() if your application absolutely requires
line drawing and accented characters. Output from CHR()
isn't translated when the function is executed, allowing
you to output any character.

9) The MS-DOS file system is case-insensitive and requires
uppercase file names. If your applications run on FoxPro
for MS-DOS, be sure to restrict file names to those
characters that have uppercase equivalents in your MS-DOS
code page.

For example, code page 437 doesn't contain uppercase
versions of several accented vowels. These characters
can't be safely used in a FoxPro file name. It's best
to avoid accented characters in file names.

7 New Code Pages
----------------

The following code pages are now supported:

Code Page       Platform
---------       --------
437             U.S. MS-DOS
737             Greek MS-DOS (437G)
620             Mazovia (Polish) MS-DOS
850             International MS-DOS
852             EE MS-DOS (Latin II)
861             Icelandic MS-DOS
865             Nordic MS-DOS
866             Russian MS-DOS
895             Kamenicky (Czech) MS-DOS
1250            Windows EE
1251            Russian Windows
1252            Windows ANSI
1253            Greek Windows
10000           Standard Macintosh

Byte 29 in table headers contains the code page identifier.
The following table lists the code page and the
corresponding code page identifier in hex.

Code Page       Code Page Identifier
---------       --------------------
437             x01
737             x6A
620             x69
850             x02
852             x64
861             x67
865             x66
866             x65
895             x68
1250            xC8
1251            xC9
1252            x03
1253            xCA
10000           x04

8 CPZERO Program
----------------

If you accidentally specify the wrong code page when
you open a table that isn't marked with a code page, run
CPZERO.PRG to reset the table's code page to zero. CPZERO
is a FoxPro program that is automatically installed in
your FoxPro directory. Before you run CPZERO, make sure
that the table whose code page you'll reset isn't open.
When you run CPZERO, you are prompted for the name of the 
table to modify.  

9 Corrections to the Help File
------------------------------

Configuring FoxPro and International/X-Platform Topics
------------------------------------------------------

These FoxPro 2.5b help file topics contain the following
line:

"Note that MODIFY STRUCTURE also marks a table with the
current code page."  

This line is incorrect and should read:

"Note that MODIFY STRUCTURE doesn't mark a table with the
current code page. Rather, it preserves the table's 
existing code page mark." 

International/X-Platform Topic
------------------------------

This help file topic contains the following line:

For example, if the current collation sequence is GENERAL,
both of these return true (.T.):

	"Stra�e" = "Strasse"

	and

	"Stra�e" == "Strasse"

"Stra�e" == "Strasse" will always return .F., not .T. as
it states in this topic. A strict machine comparison is
performed by ==. All characters in each string are
compared, including trailing blanks. For more information
about comparisons using = and ==, see SET EXACT in the
Language Reference or the FoxPro help facility.
----------------------------------------------------------
                   =================
                   End of README.TXT
                   =================