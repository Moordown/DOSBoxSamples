Interrupt List, part 3 of 4
This compilation is Copyright (c) 1989,1990,1991 Ralf Brown
----------28---------------------------------
INT 28 - DOS 2+ internal - KEYBOARD BUSY LOOP
   This interrupt is called from inside the "get input from keyboard" routine
   in DOS, if and only if it is safe to use INT 21 to access the disk at that
   time.  It is used primarily by the PRINT.COM routines and TSR programs, but
   any number of other routines could be chained to it by saving the original
   vector, and calling it with a FAR call (or just JMPing to it) at the end of
   the new routine.

   The INT 28h handler may invoke any INT 21h function except functions 00h
   through 0Ch (and 50h/51h under DOS 2.xx unless DOS CriticalErr flag is set).
   Calls to functions 3Fh and 40h may not use a handle which refers to CON.

   Until some program installs its own routine, this interrupt vector simply
   points to an IRET opcode.

Note:	supported in OS/2 compatibility box
SeeAlso: INT 2A/AH=84h
----------29---------------------------------
INT 29 - DOS 2+ internal - FAST PUTCHAR
	AL = character to display
Return: nothing
Notes:	this interrupt is called from the DOS output routines if output is
	  going to a device rather than a file, and the device driver's
	  attribute word has bit 4 (10h) set.
	COMMAND.COM v3.2 and v3.3 compare the INT 29 vector against the INT 20
	  vector and assume that ANSI.SYS is installed if the segment is larger
	the default handler under DOS 2.x and 3.x simply calls INT 10/AH=0Eh
	the default handler under DESQview 2.2 understands the <Esc>[2J
	  screen-clearing sequence, calls INT 10/AH=0Eh for all others
SeeAlso: INT 79
----------2A00-------------------------------
INT 2A - Microsoft/LANtastic NETWORK - INSTALLATION CHECK
	AH = 00h
Return: AH <> 00h if installed
SeeAlso: INT 5C
----------2A0000-----------------------------
INT 2A - AT&T Starlan Extended NetBIOS (var length names) - INSTALLATION CHECK
	AX = 0000h
Return: AH = DDh
SeeAlso: INT 5B
----------2A01-------------------------------
INT 2A - Microsoft/LANtastic NETWORK - EXECUTE NETBIOS REQUEST, NO ERROR RETRY
	AH = 01h
	ES:BX -> NCB (see INT 5C)
Return: AL = NetBIOS error code
	AH = 00h if no error
	   = 01h on error
SeeAlso: AH=04h, INT 5C
----------2A02-------------------------------
INT 2A - Microsoft Networks - SET NET PRINTER MODE
	AH = 02h
	???
Return: ???
----------2A0300-----------------------------
INT 2A - Microsoft Networks - CHECK DIRECT I/O
	AX = 0300h
	DS:SI -> ASCIZ disk device name (may be full path or only drive
		specifier--must include the colon)
Return: CF clear if absolute disk access allowed
Notes:	do not use direct disk accesses if this function returns CF set or the
	  device is redirected (INT 21/AX=5F02h)
	may take some time to execute
SeeAlso: INT 13, INT 25, INT 26, INT 21/AX=5F02h
----------2A04-------------------------------
INT 2A - Microsoft/LANtastic NETWORK - EXECUTE NETBIOS REQUEST
	AH = 04h
	AL = 00h for error retry, 01h for no retry
	ES:BX -> NCB (see INT 5C)
Return: AX = 0000h for no error
	AH = 01h, AL = error code
Note:	request automatically retried (if AL=00h) on errors 09h, 12h, and 21h
SeeAlso: AH=01h, INT 5C
----------2A0500-----------------------------
INT 2A - Microsoft/LANtastic NETWORK - GET NETWORK RESOURCE INFORMATION
	AX = 0500h
Return: AX = reserved
	BX = number of network names available
	CX = number of commands (NCBs) available
	DX = number of sessions available
----------2A06-------------------------------
INT 2A - NETBIOS - NETWORK PRINT-STREAM CONTROL
	AH = 06h
	AL = 01h set concatenation mode (all printer output put in one job)
	     02h set truncation mode (default)
		 printer open/close starts new print job
	     03h flush printer output and start new print job
Return: CF set on error
	    AX = error code
	CF clear if successful
Note:	subfunction 03h is equivalent to Ctrl/Alt/keypad-*
SeeAlso: INT 21/AX=5D08h,5D09h, INT 2F/AX=1125h
----------2A2001-----------------------------
INT 2A - MS Networks or NETBIOS - ???
	AX = 2001h
	???
Return: ???
Note:	intercepted by DESQview 2.x
----------2A2002-----------------------------
INT 2A - Network - ???
	AX = 2002h
	???
Return: ???
Note:	called by MSDOS 3.30 APPEND
----------2A2003-----------------------------
INT 2A - Network - ???
	AX = 2003h
	???
Return: ???
Note:	called by MSDOS 3.30 APPEND
----------2A80-------------------------------
INT 2A - Microsoft Networks - BEGIN DOS CRITICAL SECTION
	AH = 80h
	AL = critical section number (00h-0Fh)
	    01h DOS kernel, SHARE.EXE
		apparently for maintaining the integrity of DOS/SHARE/NET
		  data structures
	    02h DOS kernel
		ensures that no multitasking occurs while DOS is calling an
		  installable device driver
	    05h DOS 4+ IFSFUNC
	    06h DOS 4+ IFSFUNC
	    08h ASSIGN.COM
Notes:	normally hooked to avoid interrupting a critical section, rather than
	  called
	the handler should ensure that none of the critical sections are
	  reentered, usually by suspending a task which attempts to reenter
	  an active critical section
SeeAlso: AH=81h, AH=82h, AH=87h, INT 21/AX=5D06h,5D0Bh
----------2A81-------------------------------
INT 2A - Microsoft Networks - END DOS CRITICAL SECTION
	AH = 81h
	AL = critical section number (00h-0Fh) (see AH=80h)
Notes:	normally hooked rather than called
	the handler should reawaken any tasks which were suspended due to an
	  attempt to enter the specified critical section
SeeAlso: AH=80h, AH=82h, AH=87h
----------2A82-------------------------------
INT 2A - Microsoft Networks - END DOS CRITICAL SECTIONS 0 THROUGH 7
	AH = 82h
Notes:	called by the INT 21h function dispatcher for function 0 and functions
	  greater than 0Ch except 59h, and on process termination
	the handler should reawaken any tasks which were suspended due to an
	  attempt to enter one of the critical sections 0 through 7
SeeAlso: AH=81h
----------2A84-------------------------------
INT 2A - Microsoft Networks - KEYBOARD BUSY LOOP
	AH = 84h
Note:	similar to DOS's INT 28h
SeeAlso: INT 28
----------2A87-------------------------------
INT 2A - ??? - CRITICAL SECTION
	AH = 87h
	AL = start/end
	    00h start
	    01h end
Note:	called by PRINT.COM
SeeAlso: AH=80h,81h
----------2A89-------------------------------
INT 2A - Network - ???
	AH = 89h
	AL = ???  (ASSIGN uses 08h)
	???
Return: ???
----------2AC2-------------------------------
INT 2A - Network - ???
	AH = C2h
	AL = subfunction
	    07h ???
	    08h ???
	BX = 0001h
	???
Return: ???
Note:	called by DOS 3.30 APPEND
----------2B---------------------------------
INT 2B - Internal routine for MSDOS (IRET)
----------2C---------------------------------
INT 2C - Internal routine for MSDOS (IRET)
----------2C---------------------------------
INT 2C - STARLITE architecture - KERNEL API
Note:	STARLITE is an architecture by General Software for a series of MS-DOS
	  compatible operating systems (OEM DOS, NETWORK DOS, and SMP DOS) to
	  be released in 1991.  The interrupt number is subject to change
	  before the actual release.
----------2C1B04-----------------------------
INT 2C - MS Windows??? - ???
	AX = 1B04h
	???
Return: ???
Note:	called by QEMM-386 v5.11 when Windows makes the INT 2F/AX=1605h or
	  INT 2F/AX=1606h initialization and exit broadcast calls
SeeAlso: INT 2F/AX=1605h,INT 2F/AX=1606h
----------2D---------------------------------
INT 2D - Internal routine for MSDOS (IRET)
----------2E---------------------------------
INT 2E - DOS 2+ internal - EXECUTE COMMAND
	DS:SI -> counted CR-terminated command string
Notes:	the top-level command.com executes the command
	results are unpredictable if invoked by a program run from a batch file
	all registers including SS and SP are destroyed as in INT 21/AH=4Bh
	Since COMMAND.COM processes the string as if typed from the keyboard,
	  the transient portion needs to be present, and the calling program
	  must ensure that sufficient memory to load the transient portion can
	  be allocated by DOS if necessary.
	hooked but ignored by 4DOS v3.0 COMMAND.COM replacement
----------2F---------------------------------
INT 2F - Multiplex - NOTES
	AH = identifier of program which is to handle the interrupt
	   00h-7Fh reserved for DOS
	   C0h-FFh reserved for applications
	AL is the function code
This is a general mechanism for verifying the presence of a TSR and 
communicating with it.
----------2F----DIBEBE-----------------------
INT 2F - Multiplex - BMB Compuscience Canada Utilities Interface
	AH = xx (dynamically assigned based upon a search for a multiplex
		 number which doesn't answer installed)
	AL = 00h install check
	ES:DI = EBEB:BEBE
Return: AL = 00h not installed
	     01h not installed, not OK to install
	     FFh installed and if ES:DI != EBEB:BEBE then ES:DI will point
		 to a string 'BMB xxxx' where xxxx is a product name and
		 version
----------2F00-------------------------------
INT 2F - Multiplex - DOS 2.x PRINT.COM - ???
	AH = 00h
	???
Return: ???
Notes:	DOS 2.x PRINT.COM does not chain to previous INT 2F handler
	values in AH other than 00h or 01h cause PRINT to return the number of
	  files in the queue in AH
SeeAlso: AH=01h
----------2F0080-----------------------------
INT 2F - Multiplex - DOS 3.1+ PRINT.COM - GIVE PRINT A TIME SLICE
	AX = 0080h
Return: after PRINT executes
----------2F01-------------------------------
INT 2F - Multiplex - DOS 2.x PRINT.COM - ???
	AH = 01h
	???
Return: ???
Notes:	DOS 2.x PRINT.COM does not chain to previous INT 2F handler
	values in AH other than 00h or 01h cause PRINT to return the number of
	  files in the queue in AH
SeeAlso: AH=00h
----------2F0100-----------------------------
INT 2F - Multiplex - DOS 3+ PRINT.COM - INSTALLATION CHECK
	AX = 0100h
Return: AL =
	    00h not installed, OK to install
	    01h not installed, not OK to install
	    FFh installed
----------2F0101-----------------------------
INT 2F - Multiplex - DOS 3+ PRINT.COM - SUBMIT FILE
	AX = 0101h
	DS:DX -> packet (see below)
Return: CF set on error
	    AX = error code
	CF clear if successful
	    AL = 01h added to queue
		 9Eh now printing
SeeAlso: AX=0102h

Format of submit packet:
Offset	Size	Description
 00h	BYTE	level (must be 0)
 01h	DWORD	pointer to ASCIZ filename (no wildcards)
----------2F0102-----------------------------
INT 2F - Multiplex - DOS 3+ PRINT.COM - REMOVE FILE
	AX = 0102h
	DS:DX -> ASCIZ file name (wildcards allowed)
Return: CF set on error
	    AX = error code
	CF clear if successful
SeeAlso: AX=0103h
----------2F0103-----------------------------
INT 2F - Multiplex - DOS 3+ PRINT.COM - REMOVE ALL FILES
	AX = 0103h
Return: CF set on error
	    AX = error code
	CF clear if successful
SeeAlso: AX=0102h
----------2F0104-----------------------------
INT 2F - Multiplex - DOS 3+ PRINT.COM - HOLD QUEUE/GET STATUS
	AX = 0104h
Return: CF set on error
	    AX = error code
		01h function invalid
		02h file not found
		03h path not found
		04h too many open files
		05h access denied
		08h queue full
		09h spooler busy
		0Ch name too long
		0Fh drive invalid
	DX = error count
	DS:SI -> print queue (null-string terminated list of 64-byte ASCIZ 
		 file names)
SeeAlso: AX=0105h
----------2F0105-----------------------------
INT 2F - Multiplex - DOS 3+ PRINT.COM - RESTART QUEUE
	AX = 0105h
Return: CF set on error
	   AX = error code
	CF clear if successful
SeeAlso: AX=0104h
----------2F0106-----------------------------
INT 2F - Multiplex - DOS 3.3+ PRINT.COM - CHECK IF ERROR ON OUTPUT DEVICE
	AX = 0106h
Return: CF set on error
	    AX = error code
	    DS:SI -> device driver header
	CF clear if successful
	    AX = 0000h
Note:	eventually calls device driver for spooled device with request 0Ah,
	  looping until not busy or timeout
SeeAlso: AX=0104h
----------2F0200-----------------------------
INT 2F - Multiplex - PC LAN PROGRAM REDIR/REDIRIFS internal - INSTALL CHECK
	AX = 0200h
Return: AL = FFh if installed
----------2F0201-----------------------------
INT 2F - Multiplex - PC LAN PROGRAM REDIR/REDIRIFS internal - ???
	AX = 0201h
Return: nothing???
Notes:	called by DOS 3.3+ PRINT.COM
	AX=0202h appears to be the opposite function
SeeAlso: AX=0202h
----------2F0202-----------------------------
INT 2F - Multiplex - PC LAN PROGRAM REDIR/REDIRIFS internal - ???
	AX = 0202h
	???
Return: nothing???
Note:	called by DOS 3.3+ PRINT.COM
SeeAlso: AX=0201h
----------2F0203-----------------------------
INT 2F - Multiplex - PC LAN PROGRAM REDIR/REDIRIFS internal - ???
	AX = 0203h
Return: nothing???
Notes:	called by DOS 3.3+ PRINT.COM
	AX=0204h appears to be the opposite function
SeeAlso: AX=0204h
----------2F0204-----------------------------
INT 2F - Multiplex - PC LAN PROGRAM REDIR/REDIRIFS internal - ???
	AX = 0204h
	???
Return: nothing???
Note:	called by DOS 3.3 PRINT.COM
----------2F02xx-----------------------------
INT 2F - Multiplex - PC LAN PROGRAM REDIR/REDIRIFS internal - ???
	AX = 02xxh
	???
Return: ???
----------2F0500-----------------------------
INT 2F - Multiplex - DOS 3+ CRITICAL ERROR HANDLER - INSTALLATION CHECK
	AX = 0500h
Return: AL = 00h not installed, OK to install
	     01h not installed, can't install
	     FFh installed
Note:	this set of functions allows a user program to partially or completely
	  override the default critical error handler in COMMAND.COM
SeeAlso: INT 24
----------2F05-------------------------------
INT 2F - Multiplex - DOS 3+ CRITICAL ERROR HANDLER - EXPAND ERROR INTO STRING
	AH = 05h
---DOS 3.x---
	AL = extended error code (not zero)
---DOS 4.x---
	AL = error type
	    01h DOS extended error code
	    02h parameter error
	BX = error code
Return: CF clear if successful
	    ES:DI -> ASCIZ error message (read-only)
	    AL = ???
	CF set if error code can't be converted to string
Notes:	called at start of COMMAND.COM's default critical error handler if 
	  installed by a user program, allowing partial or complete overriding
	  of the default error message
	subfunction 02h called by many DOS 4 external programs
SeeAlso: AX=122Eh, INT 24
----------2F0600-----------------------------
INT 2F - Multiplex - ASSIGN - INSTALLATION CHECK
	AX = 0600h
Return: AL <> 00h if installed
----------2F0601-----------------------------
INT 2F - Multiplex - ASSIGN - GET MEMORY SEGMENT
	AX = 0601h
Return: ES = segment of ASSIGN work area and assignment table
Note:	under DOS 3+, the 26 bytes starting at ES:0103h specify which drive
	  each of A: to Z: is mapped to.  Initially set to 01h 02h 03h....
----------2F0800-----------------------------
INT 2F - Multiplex - DRIVER.SYS support - INSTALLATION CHECK
	AX = 0800h
Return:	AL = 00h not installed, OK to install
	     01h not installed, not OK to install
	     FFh installed
----------2F0801-----------------------------
INT 2F - Multiplex - DRIVER.SYS support - ADD NEW BLOCK DEVICE
	AX = 0801h
	DS:DI -> drive data table (see AX=0803h)
Notes:	moves down internal list of drive data tables, copying and modifying
	  the drive description flags word for tables referencing same physical
	  drive
	data table appended to chain of tables
SeeAlso: AX=0803h
----------2F0802-----------------------------
INT 2F - Multiplex - DRIVER.SYS support - EXECUTE DEVICE DRIVER REQUEST
	AX = 0802h
	ES:BX -> device driver request header (see below)
Return: request header updated as per requested operation

Format of device driver request header:
Offset	Size	Description
 00h	BYTE	length of request header
 01h	BYTE	subunit within device driver
 02h	BYTE	command code (see below)
 03h	WORD	status (filled in by device driver)
		bit 15: error
		bits 14-10: reserved
		bit 9: busy
		bit 8: done
		bits 7-0: error code if bit 15 set (see below)
---DOS---
 05h  8 BYTEs	reserved (unused in DOS 2.x and 3.x)
---STARLITE architecture---
 05h	DWORD	pointer to next request header
 09h  4 BYTEs	reserved
---command code 00h---
 0Dh	BYTE	number of units (set by driver)
 0Eh	DWORD	address of first free byte following driver (set by driver)
 12h	DWORD	pointer to BPB array (set by block drivers only)
 16h	BYTE	(DOS 3+) drive number for first unit of block driver (0=A)
---command code 01h---
 0Dh	BYTE	media descriptor
 0Eh	BYTE	returned status
		00h don't know
		01h media has not changed
		FFh media has been changed
 0Fh	DWORD	(DOS 3+) pointer to previous volume ID if OPEN/CLOSE/RM bit in
		  device header set and disk changed (set by driver)
---command code 02h---
 0Dh	BYTE	media descriptor
 0Eh	DWORD	transfer address
		-> scratch sector if NON-IBM FORMAT bit in device header set
		-> first FAT sector otherwise
 12h	DWORD	pointer to BPB (set by driver)
---command codes 03h,0Ch---
 0Dh	BYTE	media descriptor (block devices only)
 0Eh	DWORD	transfer address
 12h	WORD	byte count (character devices) or sector count (block devices)
 14h	WORD	starting sector number (block devices only)
---command codes 04h,08h,09h---
 0Dh	BYTE	media descriptor (block devices only)
 0Eh	DWORD	transfer address
 12h	WORD	byte count (character devices) or sector count (block devices)
 14h	WORD	starting sector number (block devices only)
 16h	DWORD	(DOS 3+) pointer to volume ID if error 0Fh returned
---command code 05h---
 0Dh	BYTE	byte read from device if BUSY bit clear on return
---command codes 06h,07h,0Ah,0Bh,0Dh,0Eh,0Fh---
 no further fields
---command code 10h---
 0Dh	BYTE	unused
 0Eh	DWORD	transfer address
 12h	WORD	byte count
---command code 13h---
 0Dh	BYTE	category code
		00h unknown
		01h COMn:
		03h CON
		05h LPTn:
		08h disk
		9Eh (STARLITE) Media Access Control driver
 0Eh	BYTE	function code
 		00h (STARLITE) MAC Bind request
 0Fh	WORD	copy of DS at time of IOCTL call (apparently unused in DOS 3.3)
 11h	WORD	offset of device driver header
 13h	DWORD	pointer to parameter block from INT 21/AX=440Dh

Values for command code:
	00h INIT
	01h MEDIA CHECK (block devices)
	02h BUILD BPB (block devices)
	03h IOCTL INPUT
	04h INPUT
	05h NONDESTRUCTIVE INPUT, NO WAIT (character devices)
	06h INPUT STATUS (character devices)
	07h INPUT FLUSH (character devices)
	08h OUTPUT
	09h OUTPUT WITH VERIFY
	0Ah OUTPUT STATUS (character devices)
	0Bh OUTPUT FLUSH (character devices)
	0Ch IOCTL OUTPUT
	0Dh (DOS 3+) DEVICE OPEN
	0Eh (DOS 3+) DEVICE CLOSE
	0Fh (DOS 3+) REMOVABLE MEDIA (block devices)
	10h (DOS 3+) OUTPUT UNTIL BUSY (character devices)
	11h unused
	12h unused
	13h (DOS 3.2+) GENERIC IOCTL
	14h unused
	15h unused
	16h unused
	17h (DOS 3.2+) GET LOGICAL DEVICE
	18h (DOS 3.2+) SET LOGICAL DEVICE
	80h (CD-ROM) READ LONG
	81h (CD-ROM) reserved
	82h (CD-ROM) READ LONG PREFETCH
	83h (CD-ROM) SEEK
	84h (CD-ROM) PLAY AUDIO
	85h (CD-ROM) STOP AUDIO
	86h (CD-ROM) WRITE LONG
	87h (CD-ROM) WRITE LONG VERIFY
	88h (CD-ROM) RESUME AUDIO

Values for error code:
	00h write-protect violation
	01h unknown unit
	02h drive not ready
	03h unknown command
	04h CRC error
	05h bad drive request structure length
	06h seek error
	07h unknown media
	08h sector not found
	09h printer out of paper
	0Ah write fault
	0Bh read fault
	0Ch general failure
	0Dh reserved
	0Eh reserved
	0Fh invalid disk change
----------2F0803-----------------------------
INT 2F - Multiplex - DOS 4.x DRIVER.SYS support - GET DRIVE DATA TABLE LIST
	AX = 0803h
Return: DS:DI -> first drive data table in list
SeeAlso: AX=0801h

Format of DOS 3.3 drive data table:
Offset	Size	Description
 00h	DWORD	pointer to next table
 04h	BYTE	physical unit number (for INT 13)
 05h	BYTE	logical drive number
 06h 19 BYTEs	BIOS Parameter Block (see also INT 21/AH=53h)
		Offset	Size	Description
		 00h	WORD	bytes per sector
		 02h	BYTE	sectors per cluster, FFh if unknown
		 03h	WORD	number of reserved sectors
		 05h	BYTE	number of FATs
		 06h	WORD	number of root dir entries
		 08h	WORD	total sectors
		 0Ah	BYTE	media descriptor, 00h if unknown
		 0Bh	WORD	sectors per FAT
		 0Dh	WORD	sectors per track
		 0Fh	WORD	number of heads
		 11h	WORD	number of hidden sectors
 19h  	BYTE	???
 1Ah	WORD	number of DEVICE OPEN calls without corresponding DEVICE CLOSE
 1Ch 11 BYTEs	volume label or "NO NAME    " if none
 27h	BYTE	terminating null for volume label???
 28h	BYTE	device type (see INT 21/AX=440Dh)
 29h	WORD	bit flags describing drive
		bit 0: fixed media
		bit 1: door lock supported
		bit 2: ??? (used in determining BPB to set for INT 21/AX=440Dh)
		bit 3: all sectors in a track are the same size
		bit 4: physical drive has multiple logical units
		bit 5: current logical drive for physical drive
		bit 6: ???
		bit 7: ???
		bit 8: ??? (related to disk change detection)
 2Bh	WORD	number of cylinders
 2Dh 19 BYTEs	BIOS Parameter Block for highest capacity supported
 40h  3 BYTEs	???
 43h  9 BYTEs	filesystem type???, default = "NO NAME	"
 4Ch	BYTE	terminating null for filesystem type???
 4Dh	DWORD	time of last access in clock ticks (FFFFFFFFh if never)
		removable media only???

Format of DOS 4.01 drive data table:
Offset	Size	Description
 00h	DWORD	pointer to next table
 04h	BYTE	physical unit number (for INT 13)
 05h	BYTE	logical drive number
 06h 19 BYTEs	BIOS Parameter Block (see also INT 21/AH=53h)
		Offset	Size	Description
		 00h	WORD	bytes per sector
		 02h	BYTE	sectors per cluster, FFh if unknown
		 03h	WORD	number of reserved sectors
		 05h	BYTE	number of FATs
		 06h	WORD	number of root dir entries
		 08h	WORD	total sectors
		 0Ah	BYTE	media descriptor, 00h if unknown
		 0Bh	WORD	sectors per FAT
		 0Dh	WORD	sectors per track
		 0Fh	WORD	number of heads
		 11h	WORD	number of hidden sectors
 19h  9	BYTEs	???
 22h	BYTE	device type (see INT 21/AX=440Dh)
 23h	WORD	bit flags describing drive
		bit 0: fixed media
		bit 1: door lock supported
		bit 2: ???
		bit 3: all sectors in a track are the same size
		bit 4: physical drive has multiple logical units
		bit 5: current logical drive for physical drive
		bit 6: ???
		bit 7: ???
		bit 8: ???
 25h	WORD	number of cylinders
 27h 19 BYTEs	BIOS Parameter Block for highest capacity supported
 3Ah 13 BYTEs	???
 47h	DWORD	time of last access in clock ticks (FFFFFFFFh if never)
 4Bh 11 BYTEs	volume label or "NO NAME    " if none
 56h	BYTE	terminating null for volume label???
 57h	DWORD	serial number
 5Bh  8 BYTEs	filesystem type ("FAT12   " or "FAT16	")
 63h	BYTE	terminating null for filesystem type???
----------2F1000-----------------------------
INT 2F - Multiplex - SHARE - INSTALLATION CHECK
	AX = 1000h
Return: AL = 00h  not installed, OK to install
	     01h  not installed, not OK to install
	     FFh  installed
BUG:	values of AL other than 00h put DOS 3.x SHARE into an infinite loop
	  (08E9: OR  AL,AL
	   08EB: JNZ 08EB) <- the buggy instruction (DOS 3.3)
	values of AL other than described here put PCDOS 4.00 into the same
	  loop (the buggy instructions are the same)
SeeAlso: INT 21/AH=52h
----------2F1040-----------------------------
INT 2F - Multiplex - DOS 4.0 SHARE internal - ???
	AX = 1040h
	???
Return: ???
----------2F1080-----------------------------
INT 2F - Multiplex - DOS 4.0 SHARE internal - CLEAR ??? FLAG
	AX = 1080h
Return: AL = F0h function supported
----------2F1081-----------------------------
INT 2F - Multiplex - DOS 4.0 SHARE internal - SET ??? FLAG
	AX = 1081h
Return: AL = F0h function supported
----------2F1100-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - INSTALLATION CHECK
	AX = 1100h
Return: AL = 00h  not installed, OK to install
	     01h  not installed, not OK to install
	     FFh  installed
Notes:	called by DOS 3.1+ kernel
	In DOS 4+, the 11xx calls are all in IFSFUNC.EXE, not in the PC LAN
	  Program redirector. 
----------2F1100STDADA-----------------------
INT 2F - Multiplex - MSCDEX (MS CD-ROM Extensions) - INSTALLATION CHECK
	AX = 1100h
	STACK: WORD DADAh
Return: AL = 00h not installed, OK to install
		STACK unchanged
	   = 01h not installed, not OK to install
		STACK unchanged
	   = FFh installed
		STACK: WORD ADADh
----------2F1101-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - REMOVE REMOTE DIRECTORY
	AX = 1101h
	SS = DOS CS
	SDA first filename pointer -> fully-qualified directory name
	SDA CDS pointer -> current directory structure for drive with dir
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=1103h, AX=1105h, INT 21/AH=3Ah, INT 21/AH=60h
----------2F1102-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - REMOVE REMOTE DIRECTORY
	AX = 1102h
	SS = DOS CS
	SDA first filename pointer -> fully-qualified directory name
	SDA CDS pointer -> current directory structure for drive with dir
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	appears to be identical to AX=1101h
SeeAlso: AX=1101h
----------2F1103-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - MAKE REMOTE DIRECTORY
	AX = 1103h
	SS = DOS CS
	SDA first filename pointer -> fully-qualified directory name
	SDA CDS pointer -> current directory structure for drive with dir
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=1101h, AX=1105h, INT 21/AH=39h, INT 21/AH=60h
----------2F1104-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - MAKE REMOTE DIRECTORY
	AX = 1104h
	SS = DOS CS
	SDA first filename pointer -> fully-qualified directory name
	SDA CDS pointer -> current directory structure for drive with dir
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	appears to be identical to AX=1103h
SeeAlso: AX=1103h
----------2F1105-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - CHDIR
	AX = 1105h
	SS = DOS CS
	SDA first filename pointer -> fully-qualified directory name
	SDA CDS pointer -> current directory structure for drive with dir
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=1101h, AX=1103h, INT 21/AH=3Bh, INT 21/AH=60h
----------2F1106-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - CLOSE REMOTE FILE
	AX = 1106h
	ES:DI -> SFT
	    SFT DPB field -> DPB of drive containing file
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=1201h,1227h, INT 21/AH=3Eh
----------2F1107-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - COMMIT REMOTE FILE
	AX = 1107h
	ES:DI -> SFT
	    SFT DPB field -> DPB of drive containing file
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	called by DOS 3.1+ kernel
SeeAlso: INT 21/AH=68h, INT 21/AX=5D01h
----------2F1108-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - READ FROM REMOTE FILE
	AX = 1108h
	ES:DI -> SFT
	    SFT DPB field -> DPB of drive containing file
	CX = number of bytes
	SS = DOS CS
	SDA DTA field -> user buffer
Return: CF set on error
	CF clear if successful
	    CX = number of bytes read
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=1109h,1229h, INT 21/AH=3Fh, INT 21/AX=5D06h
----------2F1109-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - WRITE TO REMOTE FILE
	AX = 1109h
	ES:DI -> SFT
	    SFT DPB field -> DPB of drive containing file
	CX = number of bytes
	SS = DOS CS
	SDA DTA field -> user buffer
Return: CF set on error
	CF clear if successful
	    CX = number of bytes written
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=1107h, AX=1108h, INT 21/AH=40h, INT 21/AX=5D06h
----------2F110A-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - LOCK REGION OF FILE
	AX = 110Ah
	BX = file handle
	CX:DX = starting offset
	SI = high word of size
	STACK: WORD low word of size
	ES:DI -> SFT
	    SFT DPB field -> DPB of drive containing file
	SS = DOS CS
Return: CF set on error
	   AL = DOS error code (see INT 21/AH=59h)
	STACK unchanged
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=110Bh, INT 21/AH=5Ch
----------2F110B-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - UNLOCK REGION OF FILE
	AX = 110Bh
	BX = file handle
	CX:DX = starting offset
	SI = high word of size
	STACK: WORD low word of size
	ES:DI -> SFT for file
	    SFT DPB field -> DPB of drive containing file
Return: CF set on error
	   AL = DOS error code (see INT 21/AH=59h)
	STACK unchanged
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=110Ah, INT 21/AH=5Ch
----------2F110C-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - GET DISK SPACE
	AX = 110Ch
	ES:DI -> current directory structure for desired drive
Return: AL = sectors per cluster
	AH = ???
	BX = total clusters
	CX = bytes per sector
	DX = number of available clusters
Note:	called by DOS 3.1+ kernel
SeeAlso: INT 21/AH=36h
----------2F110D-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 110Dh
	SDA first filename pointer -> name of file
	???
Return: ???
Note:	appears to be similar to AX=110Fh
SeeAlso: AX=110Fh
----------2F110E-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - SET REMOTE FILE'S ATTRIBUTES
	AX = 110Eh
	SS = DOS CS
	SDA first filename pointer -> fully-qualified name of file
	SDA CDS pointer -> current directory structure for drive with file
	STACK: WORD new file attributes
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
	STACK unchanged
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=110Fh,INT 21/AX=4301h,INT 21/AH=60h
----------2F110F-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - GET REMOTE FILE'S ATTRIBUTES
	AX = 110Fh
	SS = DOS CS
	SDA first filename pointer -> fully-qualified name of file
	SDA CDS pointer -> current directory structure for drive with file
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
	    AX = file attributes
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=110Eh,INT 21/AX=4300h,INT 21/AH=60h
----------2F1110-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 1110h
	SDA first filename pointer -> name of file
	???
Return: ???
Note:	appears to be similar to AX=110Eh
SeeAlso: AX=110Eh
----------2F1111-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - RENAME REMOTE FILE
	AX = 1111h
	SS = DS = DOS CS
	SDA first filename pointer = offset of fully-qualified old name
	SDA second filename pointer = offset of fully-qualified new name
	SDA CDS pointer -> current directory structure for drive with file
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	called by DOS 3.1+ kernel
SeeAlso: INT 21/AH=56h,INT 21/AH=60h
----------2F1112-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 1112h
	SS = DS = DOS CS
	SDA first filename pointer -> name of file
	???
Return: ???
SeeAlso: AX=1111h
----------2F1113-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - DELETE REMOTE FILE
	AX = 1113h
	SS = DS = DOS CS
	SDA first filename pointer -> fully-qualified filename in DOS CS
	SDA CDS pointer -> current directory structure for drive with file
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	called by DOS 3.1+ kernel
SeeAlso: INT 21/AH=41h,INT 21/AH=60h
----------2F1114-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 1114h
	SDA first filename pointer -> name of file
	???
Return: ???
SeeAlso: AX=1113h
----------2F1115-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 1115h
	SS = DOS CS
	ES:DI -> SFT ???
	???
Return: ???
SeeAlso: AX=112Eh
----------2F1116-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - OPEN EXISTING REMOTE FILE
	AX = 1116h
	ES:DI -> uninitialized SFT
	SS = DOS CS
	SDA first filename pointer -> fully-qualified name of file to open
	STACK: WORD file open mode (see INT 21/AH=3Dh)
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
	    SFT filled
	STACK unchanged
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=1106h,AX=1117h,AX=1118h, INT 21/AH=3Dh, INT 21/AH=60h
----------2F1117-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - CREATE/TRUNCATE REMOTE FILE
	AX = 1117h
	ES:DI -> uninitialized SFT
	SS = DOS CS
	SDA first filename pointer -> fully-qualified name of file to open
	SDA CDS pointer -> current directory structure for drive with file
	STACK: WORD file creation mode???
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
	    SFT filled
	STACK unchanged
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=1106h,AX=1116h,AX=1118h,INT 21/AH=3Ch,INT 21/AH=60h
----------2F1118-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - CREATE/TRUNCATE FILE
	AX = 1118h
	ES:DI -> uninitialized SFT
	SS = DOS CS
	SDA first filename pointer -> fully-qualified name of file
	STACK: WORD file creation mode???
Return: ???
	STACK unchanged
Note:	called by DOS 3.1+ kernel when creating a file on a drive for which the
	  SDA CDS pointer has offset FFFFh
SeeAlso: AX=1106h,AX=1116h,AX=1117h, INT 21/AH=60h
----------2F1119-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - ???
	AX = 1119h
	???
Return: ???
Notes:	called by DOS 3.1+ kernel
	DOS 4.0 IFSFUNC returns CF set, AX=0003h	
----------2F111A-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 111Ah
	???
Return: CF set
	    AX = error code (03h for DOS 4.01 IFSFUNC)
----------2F111B-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - FINDFIRST
	AX = 111Bh
	SS = DS = DOS CS
	[DTA] = uninitialized 21-byte findfirst search data (see INT 21/AH=4Eh)
	SDA first filename pointer -> fully-qualified search template
	SDA CDS pointer -> current directory structure for drive with file
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
	    [DTA] = updated findfirst search data
		    (bit 7 of first byte must be set)
	    [DTA+15h] = standard directory entry for file
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=111Ch, INT 21/AH=4Eh, INT 21/AH=60h
----------2F111C-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - FINDNEXT
	AX = 111Ch
	SS = DS = DOS CS
	[DTA] = 21-byte findfirst search data (see INT 21/AH=4Eh)
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
	    [DTA] = updated findfirst search data
		    (bit 7 of first byte must be set)
	    [DTA+15h] = standard directory entry for file
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=111Bh, INT 21/AH=4Fh
----------2F111D-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - CLOSE ALL REMOTE FILES FOR PROCESS
	AX = 111Dh
	DS???
	SS = DOS CS
Return: ???
Notes:	called by DOS 3.1+ kernel
	closes all FCBs opened by process
----------2F111E-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - DO REDIRECTION
	AX = 111Eh
	SS = DOS CS
	STACK: WORD function to execute
		5F00h  get redirection mode
			BL = type (03h printer, 04h disk)
			Return: BH = state (00h off, 01h on)
		5F01h  set redirection mode
			BL = type (03h printer, 04h disk)
			BH = state (00h off, 01h on)
		5F02h  get redirection list entry
			BX = redirection list index
			DS:SI -> 16-byte local device name buffer
			ES:DI -> 128-byte network name buffer
		5F03h  redirect device
			BL = device type (see INT 21/AX=5F03h)
			CX = stored parameter value
			DS:SI -> ASCIZ source device name
			ES:DI -> destination ASCIZ network path + ASCIZ passwd
		5F04h  cancel redirection
			DS:SI -> ASCIZ device name or network path
		5F05h  get redirection list extended entry
			BX = redirection list index
			DS:SI -> buffer for ASCIZ source device name
			ES:DI -> buffer for destination ASCIZ network path
			Return: BH = status flag
				BL = type (03h printer, 04h disk)
				CX = stored parameter value
				BP = NETBIOS local session number
		5F06h  similar to 5F05h???
Return: CF set on error
	    AX = error code (see INT 21/AH=59h)
	STACK unchanged
Note:	called by DOS 3.1+ kernel
SeeAlso: INT 21/AX=5F00h,5F01h,5F02h,5F03h,5F04h,5F05h,5F06h
----------2F111F-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - PRINTER SETUP
	AX = 111Fh
	STACK: WORD function
		5E02h  set printer setup
		5E03h  get printer setup
		5E04h  set printer mode
		5E05h  get printer mode
Return: CF set on error
	    AX = error code (see INT 21/AH=59h)
	STACK unchanged
Note:	called by DOS 3.1+ kernel
SeeAlso: INT 21/AX=5E02h,5E03h,5E04h,5E05h
----------2F1120-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - FLUSH ALL DISK BUFFERS
	AX = 1120h
	DS = DOS CS
	???
Return: CF clear (successful)
Notes:	called by DOS 3.1+ kernel
	uses CDS array pointer and LASTDRIVE= entries in DOS list of lists
SeeAlso: INT 21/AH=0Dh, INT 21/AX=5D01h
----------2F1121-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - SEEK FROM END OF REMOTE FILE
	AX = 1121h
	CX:DX = offset (in bytes) from end
	ES:DI -> SFT
	    SFT DPB field -> DPB of drive with file
	SS = DOS CS
Return: CF set on error
	    AL = DOS error code (see INT 21/AH=59h)
	CF clear if successful
	    DX:AX = new file position
Note:	called by DOS 3.1+ kernel
SeeAlso: AX=1228h, INT 21/AH=42h
----------2F1122-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - PROCESS TERMINATION HOOK
	AX = 1122h
	SS = DOS CS
	???
Return: ???
Note:	called by DOS 3.1+ kernel
----------2F1123-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - QUALIFY REMOTE FILENAME
	AX = 1123h
	DS:SI -> ASCIZ filename to canonicalize
	ES:DI -> 128-byte buffer for qualified name
Return: CF set if not resolved
Notes:	called by DOS 3.1+ kernel
	called first when DOS attempts to resolve a filename (unless inside an
	  AX=5D00h server call); if this fails, DOS resolves the name locally
SeeAlso: AX=1221h, INT 21/AH=60h
----------2F1124-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - ???
	AX = 1124h
	ES:DI -> SFT
	SS = DOS CS
	???
Return: CX = ???
Note:	called by DOS 3.1+ kernel
----------2F1125-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - REDIRECTED PRINTER MODE
	AX = 1125h
	STACK: WORD subfunction
		5D07h get print stream state
			Return: DL = current state
		5D08h set print stream state
			DL = new state
		5D09h finish print job
Return: CF set on error
	    AX = error code (see INT 21/AH=59h)
	STACK unchanged
Note:	called by DOS 3.1+ kernel
SeeAlso: INT 21/AX=5D07h,5D08h,5D09h
----------2F1126-----------------------------
INT 2F - Multiplex - NETWORK REDIRECTOR - ???
	AX = 1126h
	???
Return: CF set on error???
Note:	called by DOS 3.1+ kernel
----------2F1127-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - UNUSED
	AX = 1127h
Return: CF set
	    AX = 0001h (invalid function) (see INT 21/AH=59h)
----------2F1128-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - UNUSED
	AX = 1128h
Return: CF set
	    AX = 0001h (invalid function) (see INT 21/AH=59h)
----------2F1129-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - UNUSED
	AX = 1129h
Return: CF set
	    AX = 0001h (invalid function) (see INT 21/AH=59h)
----------2F112A-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 112Ah
	DS = DOS CS
	???
Return: ???
Note:	does something to each IFS driver
----------2F112B-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 112Bh
	SS = DOS CS
	CX = ???
	DX = ???
	STACK: WORD low byte contains function???
		0Dh ???
	???
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	called by DOS 4.0 kernel
----------2F112C-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 112Ch
	SS = DOS CS
	SDA current SFT pointer -> SFT for file
	???
Return: CF set on error
----------2F112D-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 112Dh
	BL = subfunction
	    04h ???
		Return: CF clear
	    else ???
		Return: CX = ??? (00h or 02h for DOS 4.01)
	SS = DOS CS
Return: DS = DOS CS
Note:	called by DOS 4.0 kernel
----------2F112E-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 112Eh
	SS = DS = DOS CS
	STACK: WORD ???   low byte = ???
Return: CF set on error
	CF clear if successful
	    CX = ???
Note:	called by DOS 4.0 kernel
SeeAlso: AX=1115h
----------2F112F-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - ???
	AX = 112Fh
	SS = DOS CS
	STACK: WORD function in low byte
		00h ???
		    DS:SI -> Current Directory Structure???
		    CL = drive (1=A:)
		01h ???
		    DS:SI -> ???
		    CL = file handle???
		02h ???
		    DS:SI -> Current Directory Structure???
		    DI = ???
		    CX = drive (1=A:)
	???
Return: CF set on error
	    AX = DOS error code (see INT 21/AH=59h)
	CF clear if successful
Note:	called by DOS 4.0 kernel
SeeAlso: INT 21/AH=6Bh
----------2F1130-----------------------------
INT 2F - Multiplex - DOS 4 IFSFUNC.EXE - GET IFSFUNC SEGMENT
	AX = 1130h
Return: ES = CS of resident IFSFUNC
----------2F1200-----------------------------
INT 2F - Multiplex - DOS 3+ internal - INSTALLATION CHECK
	AX = 1200h
Return: AL = FFh (for compatibility with other INT 2F functions)
----------2F1201-----------------------------
INT 2F - Multiplex - DOS 3+ internal - CLOSE CURRENT FILE
	AX = 1201h
	SS = DOS CS
	SDA current SFT pointer -> SFT of file to close
Return: BX???
	CX???
	ES:DI -> SFT for file
SeeAlso: AX=1106h,1227h, INT 21/AH=3Eh
----------2F1202-----------------------------
INT 2F - Multiplex - DOS 3+ internal - GET INTERRUPT ADDRESS
	AX = 1202h
	STACK: WORD vector number
Return: ES:BX -> interrupt vector
	STACK unchanged
----------2F1203-----------------------------
INT 2F - Multiplex - DOS 3+ internal - GET DOS DATA SEGMENT
	AX = 1203h
Return: DS = segment of IBMDOS.COM/MSDOS.SYS
----------2F1204-----------------------------
INT 2F - Multiplex - DOS 3+ internal - NORMALIZE PATH SEPARATOR
	AX = 1204h
	STACK: WORD character to normalize
Return: AL = normalized character (forward slash turned to backslash, all
		others unchanged)
	ZF set if path separator
	STACK unchanged
----------2F1205-----------------------------
INT 2F - Multiplex - DOS 3+ internal - OUTPUT CHARACTER TO STANDARD OUTPUT
	AX = 1205h
	STACK: WORD character to output
Return: STACK unchanged
Note:	can be called only from within DOS
----------2F1206-----------------------------
INT 2F - Multiplex - DOS 3+ internal - INVOKE CRITICAL ERROR
	AX = 1206h
	DI = error code
	BP:SI -> device driver header
	SS = DOS CS
	STACK: WORD value to be passed to INT 24 in AX
Return: AL = 0-3 for Abort, Retry, Ignore, Fail
	STACK unchanged
SeeAlso: INT 24
----------2F1207-----------------------------
INT 2F - Multiplex - DOS 3+ internal - MAKE DISK BUFFER MOST-RECENTLY USED
	AX = 1207h
	DS:DI -> disk buffer
Return: buffer moved to end of buffer list (least-recently used is first)
Note:	can be called only from within DOS
SeeAlso: AX=120Fh
----------2F1208-----------------------------
INT 2F - Multiplex - DOS 3+ internal - DECREMENT SFT REFERENCE COUNT
	AX = 1208h
	ES:DI -> SFT
Return: AX = new value of reference count
Note:	if the reference count was 1, it is set to FFFFh (since 0 indicates
	  that the SFT is not in use).	It is the caller's responsibility to
	  set the reference count to zero after cleaning up.
----------2F1209-----------------------------
INT 2F - Multiplex - DOS 3+ internal - FLUSH AND FREE DISK BUFFER
	AX = 1209h
	DS:DI -> disk buffer
Return: disk buffer marked unused, contents written to disk if buffer dirty
Note:	can be called only from within DOS
SeeAlso: AX=120Eh,1215h
----------2F120A-----------------------------
INT 2F - Multiplex - DOS 3+ internal - PERFORM CRITICAL ERROR INTERRUPT
	AX = 120Ah
	DS = SS = DOS CS
	STACK: WORD extended error code
Return: AL = user response (0=ignore, 1=retry, 2=abort, 3=fail)
	CF clear if retry, set otherwise
	STACK unchanged
Note:	can only be called during a DOS function call, as it uses various
	  fields in the SDA to set up the registers for the INT 24
SeeAlso: INT 24
----------2F120B-----------------------------
INT 2F - Multiplex - DOS 3+ internal - SIGNAL SHARING VIOLATION TO USER
	AX = 120Bh
	ES:DI -> system file table entry for previous open of file
	STACK: WORD extended error code (should be 20h--sharing violation)
Return: CF clear if operation should be retried
	CF set if operation should not be retried
	    AX = error code (20h) (see AH=59h)
	STACK unchanged
Notes:	can only be called during a DOS function call
	should only be called if an attempt was made to open an already-open
	  file contrary to the sharing rules
	invokes INT 24 if SFT file opened via FCB or in compatibility mode with
	  inheritance allowed
----------2F120C-----------------------------
INT 2F - Multiplex - DOS 3+ internal - SET FCB FILE'S OWNER???
	AX = 120Ch
	SDA current SFT pointer -> SFT for file
	DS = SS = DOS CS
Return: ES, DI, AX destroyed
Note:	seems to change owner of last-accessed file to calling process
----------2F120D-----------------------------
INT 2F - Multiplex - DOS 3+ internal - GET DATE AND TIME
	AX = 120Dh
	SS = DOS CS
Return: AX = current date in packed format (see INT 21/AX=5700h)
	DX = current time in packed format (see INT 21/AX=5700h)
SeeAlso: INT 21/AH=2Ah,2Ch
----------2F120E-----------------------------
INT 2F - Multiplex - DOS 3+ internal - MARK ALL DISK BUFFERS UNREFERENCED
	AX = 120Eh
	SS = DOS CS
Return: DS:DI -> first disk buffer
Note:	clears "referenced" flag on all disk buffers
SeeAlso: AX=1209h,1210h, INT 21/AH=0Dh
----------2F120F-----------------------------
INT 2F - Multiplex - DOS 3+ internal - MAKE BUFFER MOST RECENTLY USED
	AX = 120Fh
	DS:DI -> disk buffer
	SS = DOS CS
Return: DS:DI -> next buffer in buffer list
Note:	indicated buffer moved to end of chain
SeeAlso: AX=1207h
----------2F1210-----------------------------
INT 2F - Multiplex - DOS 3+ internal - FIND UNREFERENCED DISK BUFFER
	AX = 1210h
	DS:DI -> first disk buffer to check
Return: ZF clear if found
	    DS:DI -> first unreferenced disk buffer
	ZF set if not found
SeeAlso: AX=120Eh
----------2F1211-----------------------------
INT 2F - Multiplex - DOS 3+ internal - NORMALIZE ASCIZ FILENAME
	AX = 1211h
	DS:SI -> ASCIZ filename to normalize
	ES:DI -> buffer for normalized filename
Return: destination buffer filled with uppercase filename, with slashes turned
	to backslashes
SeeAlso: AX=121Eh,1221h
----------2F1212-----------------------------
INT 2F - Multiplex - DOS 3+ internal - GET LENGTH OF ASCIZ STRING
	AX = 1212h
	ES:DI -> ASCIZ string
Return: CX = length of string
SeeAlso: AX=1225h
----------2F1213-----------------------------
INT 2F - Multiplex - DOS 3+ internal - UPPERCASE CHARACTER
	AX = 1213h
	STACK: WORD character to convert to uppercase
Return: AL = uppercase character
	STACK unchanged
----------2F1214-----------------------------
INT 2F - Multiplex - DOS 3+ internal - COMPARE FAR POINTERS
	AX = 1214h
	DS:SI = first pointer
	ES:DI = second pointer
Return: ZF set if pointers are equal, ZF clear if not equal
----------2F1215-----------------------------
INT 2F - Multiplex - DOS 3+ internal - FLUSH BUFFER
	AX = 1215h
	DS:DI -> disk buffer
	SS = DOS CS
	STACK: WORD drives for which to skip buffer
		ignore buffer if drive same as high byte, or bytes differ and
		the buffer is for a drive OTHER than that given in low byte
Return: STACK unchanged
Note:	can be called only from within DOS
SeeAlso: AX=1209h
----------2F1216-----------------------------
INT 2F - Multiplex - DOS 3+ internal - GET ADDRESS OF SYSTEM FILE TABLE
	AX = 1216h
	BX = system file table entry number
Return: CF clear if successful
	    ES:DI -> system file table entry
	CF set if BX greater than FILES=
SeeAlso: AX=1220h
----------2F1217-----------------------------
INT 2F - Multiplex - DOS 3+ internal - SET WORKING DRIVE
	AX = 1217h
	SS = DOS CS
	STACK: WORD drive (0 = A:, 1 = B:, etc)
Return: CF set on error
	    (drive > LASTDRIVE)
	CF clear if successful
	    DS:SI -> current directory structure for specified drive
	STACK unchanged
SeeAlso: AX=1219h
----------2F1218-----------------------------
INT 2F - Multiplex - DOS 3+ internal - GET CALLER'S REGISTERS
	AX = 1218h
Return: DS:SI -> saved caller's AX,BX,CX,DX,SI,DI,BP,DS,ES (on stack)
Note:	only valid while within DOS
----------2F1219-----------------------------
INT 2F - Multiplex - DOS 3+ internal - SET DRIVE???
	AX = 1219h
	SS = DOS CS
	STACK: WORD drive (0 = default, 1 = A:, etc)
Return: ???
	STACK unchanged
Notes:	calls AX=1217h
	builds a current directory structure if inside server call
	  (INT 21/AX=5D00h)
SeeAlso: AX=1217h,121Fh
----------2F121A-----------------------------
INT 2F - Multiplex - DOS 3+ internal - GET FILE'S DRIVE
	AX = 121Ah
	DS:SI -> filename
Return: AL = drive (0 = default, 1 = A:, etc, FFh = invalid)
SeeAlso: INT 21/AH=19h,60h
----------2F121B-----------------------------
INT 2F - Multiplex - DOS 3+ internal - SET YEAR/LENGTH OF FEBRUARY
	AX = 121Bh
	CL = year - 1980
Return: AL = number of days in February
Note:	requires DS to be set to the DOS code segment
SeeAlso: INT 21/AH=2Bh
----------2F121C-----------------------------
INT 2F - Multiplex - DOS 3+ internal - CHECKSUM MEMORY
	AX = 121Ch
	DS:SI -> start of memory to checksum
	CX = number of bytes
	DX = initial checksum
	SS = DOS CS
Return: AX, CX destroyed
	DX = checksum
	DS:SI -> first byte after checksummed range
SeeAlso: AX=121Dh
----------2F121D-----------------------------
INT 2F - Multiplex - DOS 3+ internal - SUM MEMORY
	AX = 121Dh
	DS:SI -> memory to add up
	CX = 0000h
	DX = limit
Return: AL = byte which exceeded limit
	CX = number of bytes before limit exceeded
	DX = remainder after adding first CX bytes
	DS:SI -> byte beyond the one which exceeded the limit
SeeAlso: AX=121Ch
----------2F121E-----------------------------
INT 2F - Multiplex - DOS 3+ internal - COMPARE FILENAMES
	AX = 121Eh
	DS:SI -> first ASCIZ filename
	ES:DI -> second ASCIZ filename
Return: ZF set if filenames equivalent, ZF clear if not
SeeAlso: AX=1211h,1221h
----------2F121F-----------------------------
INT 2F - Multiplex - DOS 3+ internal - BUILD CURRENT DIRECTORY STRUCTURE
	AX = 121Fh
	SS = DOS CS
	STACK: WORD drive letter
Return: ES:DI -> current directory structure (will be overwritten by next call)
	STACK unchanged
----------2F1220-----------------------------
INT 2F - Multiplex - DOS 3+ internal - GET JOB FILE TABLE ENTRY
	AX = 1220h
	BX = file handle
Return: CF set on error
	    AL = 6 (invalid file handle)
	CF clear if successful
	    ES:DI -> JFT entry for file handle in current process
Note:	the byte pointed at by ES:DI contains the number of the SFT for the
	  file handle, or FFh if the handle is not open
SeeAlso: AX=1216h,1229h
----------2F1221-----------------------------
INT 2F - Multiplex - DOS 3+ internal - CANONICALIZE FILE NAME
	AX = 1221h
	DS:SI -> file name to be fully qualified
	ES:DI -> 128-byte buffer for resulting canonical file name
	SS = DOS CS
Return: (see INT 21/AH=60h)
Note:	identical to INT 21/AH=60h
SeeAlso: AX=1123h, INT 21/AH=60h
----------2F1222-----------------------------
INT 2F - Multiplex - DOS 3+ internal - SET EXTENDED ERROR INFO
	AX = 1222h
	SS = DOS data segment
	SS:SI -> 4-byte records
		BYTE	error code, FFh = last record
		BYTE	error class, FFh = don't change
		BYTE	suggested action, FFh = don't change
		BYTE	error locus, FFh = don't change
	SDA error code set
Return: SI destroyed
	SDA error class, error locus, and suggested action fields set
Note:	can be called only from within DOS
SeeAlso: AX=122Dh,INT 21/AH=59h
----------2F1223-----------------------------
INT 2F - Multiplex - DOS 3+ internal - CHECK IF CHARACTER DEVICE
	AX = 1223h
	SDA+218h (DOS 3.10-3.30) = eight-character blank-padded name
	SDA+22Bh (DOS 4.0x) = eight-character blank-padded name
Return: CF set if no character device by that name found
	CF clear if found
	    BH = low byte of device attribute word
Note:	can only be called from within DOS (assumes DS=SS=DOS CS)
SeeAlso: INT 21/AX=5D06h,5D0Bh
----------2F1224-----------------------------
INT 2F - Multiplex - DOS 3+ internal - DELAY
	AX = 1224h
	SS = DOS CS
Return: after delay set by INT 21/AX=440Bh, unless in server call
	  (INT 21/AX=5D00h)
Note:	delay is dependent on the processor speed, and is skipped entirely if
	  inside a server call
SeeAlso: INT 21/AX=440Bh, INT 21/AH=52h
----------2F1225-----------------------------
INT 2F - Multiplex - DOS 3+ internal - GET LENGTH OF ASCIZ STRING
	AX = 1225h
	DS:SI -> ASCIZ string
Return: CX = length of string
SeeAlso: AX=1212h
----------2F1226-----------------------------
INT 2F - Multiplex - DOS 3.3+ internal - OPEN FILE
	AX = 1226h
	CL = access mode
	DS:DX -> ASCIZ filename
Return: CF set on error
	    AL = error code (see INT 21/AH=59h)
	CF clear if successful
	    AX = file handle
Notes:	can only be called from within DOS (assumes SS=DOS CS)
	equivalent to INT 21/AH=3Dh	
SeeAlso: AX=1227h,INT 21/AH=3Dh
----------2F1227-----------------------------
INT 2F - Multiplex - DOS 3.3+ internal - CLOSE FILE
	AX = 1227h
	BX = file handle
Return: CF set on error
	    AL = 06h invalid file handle
	CF clear if successful
Notes:	can only be called from within DOS (assumes SS=DOS CS)
	equivalent to INT 21/AH=3Eh
SeeAlso: AX=1106h,1201h,1226h, INT 21/AH=3Eh
----------2F1228-----------------------------
INT 2F - Multiplex - DOS 3.3+ internal - MOVE FILE POINTER
	AX = 1228h
	BP = 4200h, 4201h, 4202h (see INT 21/AH=42h)
	BX = file handle
	CX:DX = offset in bytes
	SS = DOS CS
Return: as for INT 21/AH=42h
Notes:	equivalent to INT 21/AH=42h, but may only be called from inside a DOS
	  function call
	sets user stack frame pointer to dummy buffer, moves BP to AX, performs
	  LSEEK, and restores frame pointer
SeeAlso: INT 21/AH=42h
----------2F1229-----------------------------
INT 2F - Multiplex - DOS 3.3+ internal - READ FROM FILE
	AX = 1229h
	BX = file handle
	CX = number of bytes to read
	DS:DX -> buffer
	SS = DOS CS
Return: as for INT 21/AH=3Fh
Note:	equivalent to INT 21/AH=3Fh, but may only be called when already inside
	  a DOS function call
SeeAlso: AX=1226h,INT 21/AH=3Fh
----------2F122A-----------------------------
INT 2F - Multiplex - DOS 3.3+ internal - SET FASTOPEN ENTRY POINT
	AX = 122Ah
	BX = entry point to set (0001h or 0002h)
	DS:SI -> FASTOPEN entry point
		(entry point not set if SI = FFFFh for DOS 4+)
Return: CF set if specified entry point already set
Notes:	entry point in BX is ignored under DOS 3.30
	both entry points set to same handler by DOS 4.01

DOS 3.30 FASTOPEN is called with:
	AL = 01h  ???
	    CX = ??? seems to be offset
	    DI = ??? seems to be offset
	    SI = offset in DOS CS of filename
	AL = 02h  ???
	AL = 03h  open file???
	    SI = offset in DOS CS of filename
	AL = 04h  ???
	    AH = subfunction (00h,01h,02h)
	    ES:DI -> ???
	    CX = ??? (subfunctions 01h and 02h only)
Returns: CF set on error or not installed
Note: function 03h calls function 01h first

PCDOS 4.01 FASTOPEN is additionally called with:
	AL = 04h ???
	    AH = 03h
	    ???
	AL = 05h ???
	AL = 0Bh ???
	AL = 0Ch ???
	AL = 0Dh ???
	AL = 0Eh ???
	AL = 0Fh ???
	AL = 10h ???
----------2F122B-----------------------------
INT 2F - Multiplex - DOS 3.3+ internal - IOCTL
	AX = 122Bh
	BP = 44xxh
	SS = DOS CS
	additional registers as appropriate for INT 21/AX=44xxh
Return: as for INT 21/AH=44h
Notes:	equivalent to INT 21/AH=44h, but may only be called when already inside
	  a DOS function call
	sets user stack frame pointer to dummy buffer, moves BP to AX, performs
	  IOCTL, and restores frame pointer
SeeAlso: INT 21/AH=44h
----------2F122C-----------------------------
INT 2F - Multiplex - DOS 3.3+ internal - GET DEVICE CHAIN
	AX = 122Ch
Return: BX:AX -> header of second device driver (NUL is first) in driver chain
SeeAlso: INT 21/AH=52h
----------2F122D-----------------------------
INT 2F - Multiplex - DOS 3.3+ internal - GET EXTENDED ERROR CODE
	AX = 122Dh
Return: AX = current extended error code
SeeAlso: AX=1222h,INT 21/AH=59h
----------2F122E-----------------------------
INT 2F - Multiplex - DOS 4.00 internal - GET OR SET ERROR TABLE ADDRESSES
	AX = 122Eh
	DL = subfunction
	    00h get standard DOS error table (errors 00h-12h,50h-5Bh)
		Return: ES:DI -> error table
	    01h set standard DOS error table
		ES:DI -> error table
	    02h get parameter error table (errors 00h-0Ah)
		Return: ES:DI -> error table
	    03h set parameter error table
		ES:DI -> error table
	    04h get critical/SHARE error table (errors 13h-2Bh)
		Return: ES:DI -> error table
	    05h set critical/SHARE error table
		ES:DI -> error table
	    06h get ??? error table
		Return: ES:DI -> error table
	    07h set ??? error table
		ES:DI -> error table
	    08h get ??? error table
		Return: ES:DI -> error table
	    09h set ??? error table
		ES:DI -> error table
SeeAlso: INT 21/AH=59h

Format of error table:
Offset	Size	Description
 00h	BYTE	FFh
 01h  2 BYTEs	04h,00h (DOS version???)
 03h	BYTE	number of error headers following
 04h 2N WORDs	table of all error headers for table
		Offset	Size	Description
		 00h	WORD	error message number
		 02h	WORD	offset of error message from start of header
				error messages are count byte followed by msg
----------2F122F-----------------------------
INT 2F - Multiplex - DOS 4.0 internal - SET ???
	AX = 122Fh
	DX = ???
----------2F13-------------------------------
INT 2F - Multiplex - DOS 3.3+ - SET DISK INTERRUPT HANDLER
	AH = 13h
	DS:DX -> interrupt handler disk driver calls on read/write
	ES:BX = address to restore INT 13 to on system halt (exit from root
		 shell)
Return: DS:DX from previous invocation of this function
	ES:BX from previous invocation of this function
Notes:	most DOS 3.3+ disk access is via the vector in DS:DX, although a few
	  functions are still invoked via an INT 13 instruction
	this is a dangerous security loophole for any virus-monitoring software
	  which does not trap this call (at least two viruses are known to use
	  it to get the original ROM entry point)
----------2F1400-----------------------------
INT 2F - Multiplex - NLSFUNC.COM - INSTALLATION CHECK
	AX = 1400h
Return: AL = 00h not installed, OK to install
	     01h not installed, not OK
	     FFh installed
Note:	called by DOS v3.3+ kernel
----------2F1401-----------------------------
INT 2F - Multiplex - NLSFUNC.COM - CHANGE CODE PAGE
	AX = 1401h
	DS:SI -> internal code page structure (see below)
	BX = new code page
	DX = country code???
Return: AL = status
	     00h successful
	     else DOS error code
Note:	called by DOS v3.3+ kernel
SeeAlso: INT 21/AH=66h

Format of DOS 3.30 internal code page structure:
Offset	Size	Description
 00h  8 BYTEs	???
 08h 64 BYTEs	name of country information file
 48h	WORD	system code page
 4Ah	WORD	number of supported subfunctions
 4Ch  5 BYTEs	data to return for INT 21/AX=6502h
 51h  5 BYTEs	data to return for INT 21/AX=6504h
 56h  5 BYTEs	data to return for INT 21/AX=6505h
 5Bh  5 BYTEs	data to return for INT 21/AX=6506h
 60h 41 BYTEs	data to return for INT 21/AX=6501h
----------2F1402-----------------------------
INT 2F - Multiplex - NLSFUNC.COM - GET COUNTRY INFO
	AX = 1402h
	BP = subfunction (same as AL for INT 21/AH=65h)
	BX = code page
	DX = country code
	DS:SI -> internal code page structure (see AX=1401h)
	ES:DI -> user buffer
	CX = size of user buffer
Return: AL = status
	    00h successful
	    else DOS error code
Notes:	called by DOS v3.3+ kernel on INT 21/AH=65h
	code page structure apparently only needed for COUNTRY.SYS pathname
SeeAlso: AX=1403h,1404h, INT 21/AH=65h
----------2F1403-----------------------------
INT 2F - Multiplex - NLSFUNC.COM - SET COUNTRY INFO
	AX = 1403h
	DS:SI -> internal code page structure (see AX=1401h)
	BX = code page
	DX = country code
Return: AL = status 
	     ???
Note:	called by DOS v3.3+ kernel on INT 21/AH=38h
SeeAlso: AX=1402h,1404h, INT 21/AH=38h"SET"
----------2F1404-----------------------------
INT 2F - Multiplex - NLSFUNC.COM - GET COUNTRY INFO
	AX = 1404h
	BX = code page
	DX = country code
	DS:SI -> internal code page structure (see AX=1401h)
	ES:DI -> user buffer
Return: AL = status
	     ???
Notes:	called by DOS v3.3+ kernel on INT 21/AH=38h
	code page structure apparently only needed for COUNTRY.SYS pathname
SeeAlso: AX=1402h,1403h, INT 21/AH=38h"GET"
----------2F1500-----------------------------
INT 2F - Multiplex - DOS 4+ GRAPHICS.COM - INSTALLATION CHECK
	AX = 1500h
Return: AX = FFFFh
	ES:DI -> ??? (graphics data?)
Note:	this installation check conflicts with the CDROM Extensions
	  installation check
----------2F1500BX0000-----------------------
INT 2F - Multiplex - CDROM - INSTALLATION CHECK
	AX = 1500h
	BX = 0000h
Return: BX = number of CDROM drive letters used
	CX = starting drive letter (0=A:)
Notes:	this installation check DOES NOT follow the format used by other
	  software
	this installation check conflicts with the DOS 4.x GRAPHICS.COM
	  installation check
----------2F1501-----------------------------
INT 2F - Multiplex - CDROM - GET DRIVE DEVICE LIST
	AX = 1501h
	ES:BX -> buffer to hold drive letter list (5 bytes per drive letter)
Return: buffer filled, for each drive letter
	  BYTE	subunit number in driver
	  DWORD address of device driver header
----------2F1502-----------------------------
INT 2F - Multiplex - CDROM - GET COPYRIGHT FILE NAME
	AX = 1502h
	ES:BX -> 38-byte buffer for name of copyright file
	CX = drive number (0=A:)
Return: CF set if drive is not a CDROM drive
	    AX = 15 (invalid drive)
	CF clear if successful
SeeAlso: AX=1503h
----------2F1503-----------------------------
INT 2F - Multiplex - CDROM - GET ABSTRACT FILE NAME
	AX = 1503h
	ES:BX -> 38-byte buffer for name of abstract file
	CX = drive number (0=A:)
Return: CF set if drive is not a CDROM drive
	    AX = 15 (invalid drive)
	CF clear if successful
SeeAlso: AX=1502h
----------2F1504-----------------------------
INT 2F - Multiplex - CDROM - GET BIBLIOGRAPHIC DOC FILE NAME
	AX = 1504h
	ES:BX -> 38-byte buffer for name of bibliographic documentation file
	CX = drive number (0=A:)
Return: CF set if drive is not a CDROM drive
	    AX = 15 (invalid drive)
	CF clear if successful
----------2F1505-----------------------------
INT 2F - Multiplex - CDROM - READ VTOC
	AX = 1505h
	ES:BX -> 2048-byte buffer
	CX = drive number (0=A:)
	DX = sector index (0=first volume descriptor,1=second,...)
Return: CF set on error
	    AX = error code (15=invalid drive,21=not ready)
	CF clear if successful
	    AX = volume descriptor type (1=standard,FFh=terminator,0=other)
----------2F1506-----------------------------
INT 2F - Multiplex - CDROM - TURN DEBUGGING ON
	AX = 1506h
	BX = debugging function to enable
Note:	reserved for development
SeeAlso: AX=1507h
----------2F1507-----------------------------
INT 2F - Multiplex - CDROM - TURN DEBUGGING OFF
	AX = 1507h
	BX = debugging function to disable
Note:	reserved for development
SeeAlso: AX=1506h
----------2F1508-----------------------------
INT 2F - Multiplex - CDROM - ABSOLUTE DISK READ
	AX = 1508h
	ES:BX -> buffer
	CX = drive number (0=A:)
	SI:DI = starting sector number
	DX = number of sectors to read
Return: CF set on error
	    AL = error code (15=invalid drive,21=not ready)
	CF clear if successful
SeeAlso: AX=1509h
----------2F1509-----------------------------
INT 2F - Multiplex - CDROM - ABSOLUTE DISK WRITE
	AX = 1509h
	ES:BX -> buffer
	CX = drive number (0=A:)
	SI:DI = starting sector number
	DX = number of sectors to write
Note:	corresponds to INT 26h and is currently reserved and nonfunctional
SeeAlso: AX=1508h
----------2F150A-----------------------------
INT 2F - Multiplex - CDROM - RESERVED
	AX = 150Ah
----------2F150B-----------------------------
INT 2F - Multiplex - CDROM 2.00 - DRIVE CHECK
	AX = 150Bh
	CX = drive number (0=A:)
Return: BX = ADADh if MSCDEX.EXE installed
	    AX = 0000h if drive not supported
		nonzero if supported
SeeAlso: AX=150Dh
----------2F150C-----------------------------
INT 2F - Multiplex - CDROM 2.00 - GET MSCDEX.EXE VERSION
	AX = 150Ch
Return: BH = major version
	BL = minor version
Note:	MSCDEX.EXE versions prior to 1.02 return BX=0
----------2F150D-----------------------------
INT 2F - Multiplex - CDROM 2.00 - GET CDROM DRIVE LETTERS
	AX = 150Dh
	ES:BX -> buffer for drive letter list (1 byte per drive)
Return: buffer filled with drive numbers (0=A:).  Each byte corresponds
	to the drive in the same position for function 1501h
SeeAlso: AX=150Bh
----------2F150E-----------------------------
INT 2F - Multiplex - CDROM 2.00 - GET/SET VOLUME DESCRIPTOR PREFERENCE
	AX = 150Eh
	BX = subfunction
	    00h get preference
		DX = 0000h
		Return: DX = preference settings
	    01h set preference
		DH = volume descriptor preference
		    01h = primary volume descriptor
		    02h = supplementary volume descriptor
		DL = supplementary volume descriptor preference
		    01h = shift-Kanji
	CX = drive number (0=A:)
Return: CF set on error
	    AX = error code (15=invalid drive,1=invalid function)
	CF clear if successful
----------2F150F-----------------------------
INT 2F - Multiplex - CDROM 2.00 - GET DIRECTORY ENTRY
	AX = 150Fh
	CX = drive number (0=A:)
	ES:BX -> ASCIZ path name
	SI:DI -> 255-byte buffer for directory entry
Return: CF set on error
	    AX = error code
	CF clear if succesful
	    AX = disk format (0=High Sierra,1=ISO 9660)

Format of directory entry:
Offset	Size	Description
 00h	BYTE  length of directory entry
 01h	BYTE  length of XAR in LBN's (don't ask me what that means...)
 02h	DWORD LBN of data, Intel (little-endian) format
 06h	DWORD LBN of data, Motorola (big-endian) format
 0Ah	DWORD length of file, Intal format
 0Eh	DWORD length of file, Motorola format
---High Sierra---
 12h  6 BYTEs date and time
 18h	BYTE  bit flags
 19h	BYTE  reserved
---ISO 9660---
 12h  7 BYTEs date and time
 19h	BYTE  bit flags
---both formats---
 1Ah	BYTE  interleave size
 1Bh	BYTE  interleave skip factor
 1Ch	WORD  volume set sequence number, Intel format
 1Eh	WORD  volume set sequence number, Motorola format
 20h	BYTE  length of file name
 21h  N BYTEs file name
	BYTE (optional) padding if filename is odd length
      N BYTEs system data
----------2F1510-----------------------------
INT 2F - Multiplex - CDROM 2.10 - SEND DEVICE DRIVER REQUEST
	AX = 1510h
	CX = CD-ROM drive letter (0 = A, 1 = B, etc)
	ES:BX -> CD-ROM device driver request header (see AX=0802h)
----------2F1600-----------------------------
INT 2F - Multiplex - MS WINDOWS - ENHANCED WINDOWS INSTALLATION CHECK
	AX = 1600h
Return: AL = 00h if Enhanced Windows 3.x or Windows/386 2.x not running
	AL = 80h if Enhanced Windows 3.x or Windows/386 2.x not running
	AL = 01h if Windows/386 2.x running
	AL = FFh if Windows/386 2.x running
	AL = anything else
	    AL = Windows major version number >= 3
	    AH = Windows minor version number
Note:	INT 2F/AH=16h comprises an API for non-Windows programs (DOS device
	  drivers, TSRs, and applications) to cooperate with multitasking
	  Windows/386 2.x and Windows 3.x and higher enhanced mode.
	certain calls are also supported in the Microsoft 80286 DOS extender in
	  Windows standard mode
SeeAlso: AX=4680h
----------2F1602-----------------------------
INT 2F - Multiplex - MS WINDOWS/386 2.x - GET API ENTRY POINT
	AX = 1602h
Return: ES:DI -> Windows/386 2.x API procedure entry point
Notes:	this interface is supported in Windows 3.x only for 2.x compatibility
	to get the current virtual machine (VM) ID in Windows/386 2.x:
	    AX = 0000h
	    ES:DI -> return address
	    JUMP to address returned from INT 2F/AX=1602h
	After JUMP, at return address:
	    BX = current VM ID.
----------2F1605-----------------------------
INT 2F - Multiplex - MS WINDOWS - ENHANCED WINDOWS & 286 DOSX INIT BROADCAST
	AX = 1605h
	ES:BX = 0000h:0000h
	DS:SI = 0000h:0000h
	CX = 0000h
	DX = flags
	    bit 0 = 0 if enhanced Windows initialization
	    bit 0 = 1 if Microsoft 286 DOS extender initialization
	    bits 1-15 reserved (undefined)
	DI = version number (major in upper byte, minor in lower)
Return: CX = 0000h if okay for Windows to load
	CX <> 0 if Windows should not load
	ES:BX -> startup info structure (see below)
	DS:SI -> virtual86 mode enable/disable callback or 0000h:0000h
Notes:	the enhanced Windows loader and Microsoft 286 DOS extender will
	  broadcast an INT 2F/AX=1605h call when initializing.	Any DOS device
	  driver or TSR can watch for this broadcast and return the appropriate
	  values.  If the driver or TSR returns CX <> 0, it is also its
	  responsibility to display an error message.
	each handler must first chain to the prior INT 2F handler with
	  registers unchanged before processing the call
	if the handler requires local data on a per-VM basis, it must store the
	  returned ES:BX in the "next" field of a startup info structure and
	  return a pointer to that structure in ES:BX
	a single TSR may set the V86 mode enable/disable callback; if DS:SI is
	  already nonzero, the TSR must fail the initialization by setting CX
	  nonzero
SeeAlso: AX=1606h,AX=1608h

Format of Startup Information Structure:
Offset	Size	Description
 00h  2 BYTEs	major, minor version of info structure
 02h	DWORD	pointer to next startup info structure
 06h	DWORD	pointer to ASCIZ name of virtual device file or 0000h:0000h
 0Ah	DWORD	virtual device reference data (only used if above nonzero)
 0Eh	DWORD	pointer to instance data records or 0000h:0000h

Format of one Instance Item in array:
Offset	Size	Description
 00h	DWORD	address of instance data (end of array if 0000h:0000h)
 04h	WORD	size of instance data

Virtual mode enable/disable procedure called with:
	AX = 0000h disable V86 mode
	AX = 0001h enable V86 mode
	interrupts disabled
Return: CF set on error
	CF clear if successful
	interrupts disabled
----------2F1606-----------------------------
INT 2F - Multiplex - MS WINDOWS - ENHANCED WINDOWS & 286 DOSX EXIT BROADCAST
	AX = 1606h
	DX = flags
	    bit 0 = 0 if enhanced Windows exit
	    bit 0 = 1 if Microsoft 286 DOS extender exit
	    bits 1-15 reserved (undefined)
Return: CX = 0000h if okay for Windows to load
	CX <> 0 if Windows should not load
Notes:	if the init broadcast fails (AX=1605h returned CX <> 0), then this
	  broadcast will be issued immediately.
	this call will be issued in real mode
SeeAlso: AX=1605h,1609h
----------2F1607-----------------------------
INT 2F - Multiplex - MS WINDOWS - VIRTUAL DEVICE CALL OUT API
	AX = 1607h
	BX = virtual device ID (see INT 2F/AX=1684h)
Note:	more of a convention than an API, this call specifies a standard
	  mechanism for enhanced Windows virtual devices (VxD's) to talk to DOS
	  device drivers and TSRs
SeeAlso: AX=1605h,AX=1684h
----------2F1608-----------------------------
INT 2F - Multiplex - MS WINDOWS - ENHANCED WINDOWS INIT COMPLETE BROADCAST
	AX = 1608h
Notes:	called after all installable devices have been initialized
	real-mode software may be called between the enhanced Windows init call
	  (AX=1605h) and this call; the software must detect this situation
SeeAlso: AX=1605h,AX=1609h
----------2F1609-----------------------------
INT 2F - Multiplex - MS WINDOWS - ENHANCED WINDOWS BEGIN EXIT BROADCAST
	AX = 1609h
Note:	called at the beginning of a normal exit sequence; not made in the
	  event of a fatal system crash
SeeAlso: AX=1606h,AX=1608h
----------2F1680-----------------------------
INT 2F - Multiplex - MS WINDOWS - RELEASE CURRENT VIRTUAL MACHINE TIME-SLICE
	AX = 1680h
Return: AL = 00h if the call is supported
	AL = 80h (unchanged) if the call is not supported
Notes:	programs can use this function, even when not running under Windows in
	  386 enhanced mode, because OS/2 can use the call to detect idleness
	  even though it does not support the complete enhanced Windows API. 
	this call will be supported in OS/2 2.0 for multitasking DOS
	  applications
	does not block the program; it just gives up the remainder of the time
	  slice
	should only be used by non-Windows programs
SeeAlso: INT 15/AX=1000h
----------2F1681-----------------------------
INT 2F - Multiplex - MS WINDOWS 3+ - BEGIN CRITICAL SECTION
	AX = 1681h
Notes:	used to prevent a task switch from occurring
	should be followed by an INT 2F/AX=1682h call as soon as possible
	nested calls are allowed, and must be followed by an appropriate number
	  of "end critical section" calls
	not supported in Windows/386 2.x. Get INDOS flag with INT 21/AH=34h and
	  and increment by hand.
SeeAlso: AX=1682h,INT 15/AX=101Bh,INT 21/AH=34h
----------2F1682-----------------------------
INT 2F - Multiplex - MS WINDOWS 3+ - END CRITICAL SECTION
	AX = 1682h
Notes:	not supported in Windows/386 2.x.  Get InDOS flag with INT 21/AH=34h
	  and decrement by hand, taking care not to decrement InDOS flag
	  through zero
SeeAlso: AX=1681h,INT 15/AX=101Ch,INT 21/AH=34h
----------2F1683-----------------------------
INT 2F - Multiplex - MS WINDOWS 3+ - GET CURRENT VIRTUAL MACHINE ID
	AX = 1683h
Return: BX = current virtual machine (VM) ID
Notes:	Windows itself currently runs in VM 1, but this can't be relied upon
	VM IDs are reused when VMs are destroyed
	an ID of 0 will never be returned
SeeAlso: AX=1684h, AX=1685h
----------2F1684-----------------------------
INT 2F - Multiplex - MS WINDOWS - GET DEVICE API ENTRY POINT
	AX = 1684h
	BX = virtual device (VxD) ID (see below)
	ES:DI = 0000h:0000h
Return: ES:DI -> VxD API entry point, or 0:0 if the VxD does not support an API
Note:	some enhanced Windows virtual devices provide services that
	  applications can access.  For example, the Virtual Display Device
	  (VDD) provides an API used in turn by WINOLDAP.
SeeAlso: AX=1683h

Values for VxD ID:
 01h	VMM		Virtual Machine Manager
 02h	Debug
 03h	VPICD		Virtual Prog. Interrupt Controller (PIC) Device
 04h	VDMAD		Virtual Direct Memory Access (DMA) Device
 05h	VTD		Virtual Timer Device
 06h	V86MMGR		Virtual 8086 Mode Device
 07h	PAGESWAP	Paging Device
 08h	Parity
 09h	Reboot
 0Ah	VDD		Virtual Display Device (GRABBER)
 0Bh	VSD		Virtual Sound Device
 0Ch	VMD		Virtual Mouse Device
 0Dh	VKD		Virtual Keyboard Device
 0Eh	VCD		Virtual COMM Device
 0Fh	VPD		Virtual Printer Device
 10h	VHD		Virtual Hard Disk Device
 11h	VMCPD
 12h	EBIOS		Reserve EBIOS page (e.g., on PS/2)
 13h	BIOSXLAT	Map ROM BIOS API between prot & V86 mode
 14h	VNETBIOS	Virtual NetBIOS Device
 15h	DOSMGR
 16h	WINLOAD
 17h	SHELL
 18h	VMPoll
 19h	VPROD
 1Ah	DOSNET		assures network integrity across VMs
 1Bh	VFD		Virtual Floppy Device
 1Ch	VDD2		Secondary display adapter
 1Dh	WINDEBUG
 1Eh	TSRLoad		TSR instance utility
Note:	The high bit of the VxD ID is reserved for future use. The
	next 10 bits are the OEM # which is assigned by Microsoft. The
	low 5 bits are the device number. 
----------2F1685-----------------------------
INT 2F - Multiplex - MS WINDOWS - SWITCH VMs AND CALLBACK
	AX = 1685h
	BX = VM ID of virtual machine to switch to
	CX = flags
		bit 0 wait until interrupts enabled
		bit 1 wait until critical section unowned
		bits 2-15 reserved (zero)
	DX:SI = priority boost (see VMM.INC)
	ES:DI -> FAR procedure to callback
Return: CF set on error
	    AX = error code
		01h invalid VM ID
		02h invalid priority boost
		03h invalid flags
	CF clear if successful
	    event will be or has been called
Notes:	some DOS devices, such as networks, need to call functions in a
	  specific VM. This call forces the appropriate VM to be installed.
	the callback procedure must preserve all registers and return with IRET
SeeAlso: AX=1683h, INT 15/AX=1117h
----------2F1686-----------------------------
INT 2F - Multiplex - DOS Protected-Mode Interface - DETECT MODE
	AX = 1686h
Return: AX = 0000h if operating in protected mode under DPMI (INT 31 available)
	AX nonzero if in real/V86 mode or no DPMI (INT 31 not available)
SeeAlso: AX=1687h
----------2F1687-----------------------------
INT 2F - Multiplex - DOS Protected-Mode Interface - INSTALLATION CHECK
	AX = 1687h
Return: AX = 0000h if installed
	    BX = flags
		bit 0: 32-bit programs supported
	    CL = processor type (02h=80286, 03h=80386, 04h=80486)
	    DH = DPMI major version
	    DL = DPMI minor version
	    SI = number of paragraphs of DOS extender private data
	    ES:DI -> DPMI mode-switch entry point
SeeAlso: AX=1686h

Call mode switch entry point with:
	AX = flags
	    bit 0: set if 32-bit program
	ES = real mode segment of buffer for DPMI private data (ignored if
		SI was zero)
Return: CF set on error
	    program still in real mode
	CF clear if successful
	    CS = 16-bit selector corresponding to real-mode CS
	    SS = selector corresponding to real-mode SS (64K limit)
	    DS = selector corresponding to real-mode DS (64K limit)
	    ES = selector to program's PSP (100h byte limit)
	    FS = GS = 0
	    high word of ESP = 0 if 32-bit program
	    program now in protected mode
----------2F1700-----------------------------
INT 2F - Multiplex - MS WINDOWS "WINOLDAP" - IDENTIFY WinOldAp VERSION
	AX = 1700h
Return: AX = 1700h if this version of WINOLDAP doesn't support clipboard
	AX <> 1700h
		AL = WINOLDAP major version
		AH = WINOLDAP minor version
Notes:	WinOldAp (WINOLDAP.MOD) is a Microsoft Windows extension supporting
	  "old" (character-mode) application access to Dynamic Data Exchange,
	  menus, and the Windows clipboard.
	this installation check DOES NOT follow the format used by other
	  software
----------2F1701-----------------------------
INT 2F - Multiplex - MS WINDOWS "WINOLDAP" - OPEN CLIPBOARD
	AX = 1701h
Return:	AX <> 0  success
	AX = 0	 clipboard is already open
----------2F1702-----------------------------
INT 2F - Multiplex - MS WINDOWS "WINOLDAP" - EMPTY CLIPBOARD
	AX = 1702h
Return: AX <> 0  clipboard has been emptied
	AX = 0	 failure
----------2F1703-----------------------------
INT 2F - Multiplex - MS WINDOWS "WINOLDAP" - SET CLIPBOARD DATA
	AX = 1703h
	DX = clipboard format supported by WinOldAp:
		01h text
		02h bitmap
		03h metafile picture
		04h SYLK
		05h DIF
		06h TIFF
		07h OEM text
	ES:BX -> data (see below for formats)
	SI:CX = size of data
Return: AX <> 0 data copied into the Clipboard
	AX = 0 failure

Format of bitmap:
Offset	Size	Description
 00h	WORD	type (0000h)
 02h	WORD	width of bitmap in pixels
 04h	WORD	height of bitmap in pixels
 06h	WORD	bytes per line
 08h	BYTE	number of color planes
 09h	BYTE	number of adjacent color bits in pixel
 0Ah	DWORD	pointer to start of data
 0Eh	WORD	width in 0.1mm units
 10h	WORD	height in 0.1mm units
 12h  N BYTEs	bitmap data

Format of metafile picture:
Offset	Size	Description
 00h	WORD	mapping mode
 02h	WORD	X extent
 04h	WORD	Y extent
 06h	WORD	picture data
----------2F1704-----------------------------
INT 2F - Multiplex - MS WINDOWS "WINOLDAP" - GET CLIPBOARD DATA SIZE
	AX = 1704h
	DX = clipboard format supported by WinOldAp (see AX=1703h)
Return:  DX:AX = size of data in bytes, including any headers
Failure: DX:AX = 0  no data in this format in the Clipboard
----------2F1705-----------------------------
INT 2F - Multiplex - MS WINDOWS "WINOLDAP" - GET CLIPBOARD DATA
	AX = 1705h
	DX = clipboard format supported by WinOldAp (see AX=1703h)
	ES:BX -> buffer
Return: AX <> 0  success
	AX = 0	 error, or no data in this format in Clipboard
----------2F1708-----------------------------
INT 2F - Multiplex - MS WINDOWS "WINOLDAP" - CloseClipboard
	AX = 1708h
Return: AX <> 0 success
	AX = 0 failure
----------2F1709-----------------------------
INT 2F - Multiplex - MS WINDOWS "WINOLDAP" - COMPACT CLIPBOARD
	AX = 1709h
	SI:CX = desired size in bytes
Return: DX:AX = number of bytes in largest block of free memory
Note:	WinOldAp is responsible for including the size of any headers
----------2F170A-----------------------------
INT 2F - Multiplex - MS WINDOWS "WINOLDAP" - GET DEVICE CAPABILITIES
	AX = 170Ah
	DX = GDI information index
	    00h device driver version
	    02h device classification
	    04h width in mm
	    06h height in mm
	    08h width in pixels
	    0Ah height in pixels
	    0Ch bits per pixel
	    0Eh number of bit planes
	    10h number of brushes supported by device
	    12h number of pens supported by device
	    14h number of markers supported by device
	    16h number of fonts supported by device
	    18h number of colors
	    1Ah size required for device descriptor
	    1Ch curve capabilities
	    1Eh line capabilities
	    20h polygon capabilities
	    22h text capabilities
	    24h clipping capabilities
	    26h bitblt capabilities
	    28h X aspect
	    2Ah Y aspect
	    2Ch length of hypotenuse of aspect
	    58h logical pixels per inch of width
	    5Ah logical pixels per inch of height
Return:  AX = integer value of the desired item
		device classification
		    00h vector plotter
		    01h raster display
		    02h raster printer
		    03h raster camera
		    04h character-stream, PLP
		    05h Metafile, VDM
		    06h display-file
		curve capabilities
		    bit 0  circles
		    bit 1  pie wedges
		    bit 2  chord arcs
		    bit 3  ellipses
		    bit 4  wide lines
		    bit 5  styled lines
		    bit 6  wide styled lines
		    bit 7  interiors
		line capabilities
		    bit 1  polylines
		    bit 2  markers
		    bit 3  polymarkers
		    bit 4  wide lines
		    bit 5  styled lines
		    bit 6  wide styled lines
		    bit 7  interiors
		polygon capabilities
		    bit 0  polygons
		    bit 1  rectangles
		    bit 2  trapezoids
		    bit 3  scanlines
		    bit 4  wide borders
		    bit 5  styled borders
		    bit 6  wide styled borders
		    bit 7  interiors
		text capabilities
		    bit 0  output precision character
		    bit 1  output precision stroke
		    bit 2  clippping precision stroke
		    bit 3  90-degree character rotation
		    bit 4  arbitrary character rotation
		    bit 5  independent X and Y scaling
		    bit 6  double-size
		    bit 7  integer scaling
		    bit 8  continuous scaling
		    bit 9  bold
		    bit 10 italic
		    bit 11 underline
		    bit 12 strikeout
		    bit 13 raster fonts
		    bit 14 vector fonts
		    bit 15 reserved
		clipping capabilities
		    00h none
		    01h clipping to rectangles
		raster capabilities
		    bit 0  simple bitBLT
		    bit 1  device requires banding support
		    bit 2  device requires scaling support
		    bit 3  supports >64K bitmap
Note:  This function returns the device-capability bits for the given display
----------2F1900-----------------------------
INT 2F - Multiplex - DOS 4.x only SHELLB.COM - INSTALLATION CHECK
	AX = 1900h
Return: AL = 00h  not installed
	     FFh  installed
----------2F1901-----------------------------
INT 2F - Multiplex - DOS 4.x only SHELLB.COM - SHELLC.EXE INTERFACE
	AX = 1901h
	BL = 00h if SHELLC transient
	     01h if SHELLC resident
	DS:DX -> far call entry point for resident SHELLC.EXE
Return: ES:DI -> SHELLC.EXE workspace within SHELLB.COM
Note:	SHELLB.COM and SHELLC.EXE are parts of the DOS 4.x shell
----------2F1902-----------------------------
INT 2F - Multiplex - DOS 4.x only SHELLB.COM - COMMAND.COM INTERFACE
	AX = 1902h
	ES:DI -> ASCIZ full filename of current batch file, with at least the
		 final filename element uppercased
	DS:DX -> buffer for results
Return: AL = 00h  failed, either
		  (a) final filename element quoted at ES:DI does not match
		      identity of shell batch file quoted as parameter of most
		      recent call of SHELLB command, or
		  (b) no more Program Start Commands available.
	AL= FFh  success, then:
		memory at DS:[DX+1] onwards filled as:
		DX+1:	BYTE	count of bytes of PSC
		DX+2: N BYTEs	Program Start Command text
			BYTE	0Dh terminator 
Explanation: COMMAND.COM executes the result of this call in preference to 
	reading a command from a batch file. Thus the batch file does not
	advance in execution for so long as SHELLB provides PSCs from its
	workspace. The PSCs are planted in SHELLB workspace by SHELLC, the user
	menu interface. The final PSC of a sequence is finished with a 
	GOTO COMMON, which causes a loop back in the batch file which called
	SHELLC so as to execute SHELLC again. The check on batch file name
	permits PSCs to CALL nested batch files while PSCs are still stacked
	up for subsequent execution.
----------2F1903-----------------------------
INT 2F - Multiplex - DOS 4.x only SHELLB.COM - COMMAND.COM interface
	AX = 1903h
	ES:DI -> ASCIZ batch file name as for AX=1902h
Return: AL = FFh if quoted batch file name matches last SHELLB parameter
	AL = 00h if it does not
----------2F1904-----------------------------
INT 2F - Multiplex - DOS 4.x only SHELLB.COM - SHELLB transient to TSR intrface
	AX = 1904h
Return: ES:DI -> name of current shell batch file:
		WORD	number of bytes of name following
		BYTEs	(8 max) uppercase name of shell batch file
----------2F1A00-----------------------------
INT 2F - Multiplex - DOS 4+ ANSI.SYS internal - INSTALLATION CHECK
	AX = 1A00h
Return: AL = FFh if installed
Note:	AVATAR.SYS also responds to this call
----------2F1A00BX4156-----------------------
INT 2F - Multiplex - AVATAR.SYS - INSTALLATION CHECK
	AX = 1A00h
	BX = 4156h ('AV')
	CX = 4154h ('AT')
	DX = 4152h ('AR')
Return: AL = FFh if installed
	    CF clear
	    BX = AVATAR protocol level supported
	    CX = driver type
		0000h AVATAR.SYS
		4456h DVAVATAR.COM inside DESQview window
	    DX = 0016h
Notes:	AVATAR also identifies itself as ANSI.SYS if BX, CX, or DX differ from
	  the magic values
	AVATAR.SYS is a CON replacement by George Adam Stanislav which
	  interprets AVATAR command codes in the same way that ANSI interprets
	  ANSI command codes
----------2F1A01-----------------------------
INT 2F - Multiplex - DOS 4+ ANSI.SYS internal - GET/SET DISPLAY INFORMATION
	AX = 1A01h
	CL = 7Fh for GET
	   = 5Fh for SET
	DS:DX -> parm block as for INT 21,AX=440Ch,CX=037Fh/035Fh respectively
Return: CF set on error
	    AX = error code (many non-standard)
	CF clear if successful
	    AX destroyed
Note:	presumably this is the DOS IOCTL interface to ANSI.SYS
SeeAlso: AX=1A02h, INT 21/AX=440Ch
----------2F1A02-----------------------------
INT 2F - Multiplex - DOS 4+ ANSI.SYS internal - MISC REQUESTS
	AX = 1A02h
	DS:DX -> parameter block (see below)
SeeAlso: AX=1A01h

Format of parameter block:
Offset	Size	Description
 00h	BYTE	subfunction
		00h set/reset interlock
		01h get /L flag
 01h	BYTE	interlock state
		00h=reset, 01h=set
		  This interlock prevents some of the ANSI.SYS post-processing
		  in its hook onto INT 10, AH=00h mode set
 02h	BYTE	(returned)
		00h if /L not in effect
		01h if /L in effect
----------2F1A21-----------------------------
INT 2F - Multiplex - AVATAR.SYS - SET DRIVER STATE
	AX = 1A21h (AL='!')
	DS:SI -> command string with one or more state characters
	CX = length of command string
Return: CF set on error (invalid subfunction)
	CF clear if successful
Note:	the characters in the state string are interpreted left to right, and
	  need not be in any particular order
SeeAlso: AX=1A3Fh

Values of state characters:
 'a'	activate driver
 'd'	disable driver
 'f'	use fast screen output
 'g'	always convert gray keys (+ and -) to function keys
 'G'	never convert gray keys
 'l'	convert gray keys only when ScrollLock active
 's'	use slow screen output
 't'	Tandy 1000 keyboard (not yet implemented)
----------2F1A3F-----------------------------
INT 2F - Multiplex - AVATAR.SYS - QUERY DRIVER STATE
	AX = 1A3Fh (AL='?')
	ES:DI -> buffer
	CX = length of buffer in bytes
Return: CF clear
	CX = actual size of returned info
Note:	the returned information consists of multiple letters whose meanings
	  are described under AX=1A21h
SeeAlso: AX=1A21h
----------2F1B00-----------------------------
INT 2F - Multiplex - DOS 4+ XMA2EMS.SYS extension internal - INSTALLATION CHECK
	AX = 1B00h
Return: AL = FFh if installed
Note:	XMA2EMS.SYS extension is only installed if DOS has page frames to hide.
	This extension hooks onto INT 67/AH=58h and returns from that call data
	  which excludes the physical pages being used by DOS.
SeeAlso: AX=1B01h
----------2F1B01-----------------------------
INT 2F - Multiplex - DOS 4+ XMA2EMS.SYS extens internal - GET HIDDEN FRAME INFO
	AX = 1B01h
	DI = hidden physical page number
Return: AX = FFFFh if failed (no such hidden page)
	AX = 0000h if OK, then
	     ES = segment of page frame
	     DI = physical page number
Note:	this corresponds to the data edited out of the INT 67/AH=58h call
SeeAlso: AX=1BFFh
----------2F1BFF-----------------------------
INT 2F - Multiplex - DOS 4+ XMA2EMS.SYS internal??? - ???
	AX = 1BFFh
	DI = ???
Return: AH = ???
	ES:DI -> ???
Note:	called by FASTOPEN
SeeAlso: AX=1B01h
----------2F4001-----------------------------
INT 2F - Multiplex - OS/2 compatibility box - SWITCH DOS TO BACKGROUND
	AX = 4001h
SeeAlso: AX=4002h
----------2F4002-----------------------------
INT 2F - Multiplex - OS/2 compatibility box - SWITCH DOS TO FOREGROUND
	AX = 4002h
SeeAlso: AX=4001h
----------2F4300-----------------------------
INT 2F - Multiplex - XMS - INSTALLATION CHECK
	AX = 4300h
Return: AL = 80h XMS driver installed
	AL <> 80h no driver
Notes:	XMS gives access to extended memory and noncontiguous/nonEMS memory
	  above 640K
	this installation check DOES NOT follow the format used by other
	  software
SeeAlso: AX=4310h
----------2F4310-----------------------------
INT 2F - Multiplex - XMS - GET DRIVER ADDRESS
	AX = 4310h
Return: ES:BX -> driver entry point
SeeAlso: AX=4300h

Perform a FAR call to the driver entry point with AH set to the function code
	AH	function
	00h  Get XMS version number
	     Return: AX = XMS version (in BCD)
		     BX = internal revision number
		     DX = 0001h if HMA (1M to 1M + 64K) exists
			  0000h if HMA does not exist
	01h  Request High Memory Area (1M to 1M + 64K)
	     DX = memory in bytes (for TSR or device drivers)
		  FFFFh if application program
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
	02h  Release High Memory Area
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
	03h  Global enable A20, for using the HMA
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
	04h  Global disable A20
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
	05h  Local enable A20, for direct access to extended memory
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
	06h  Local disable A20
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
	07h  Query A20 state
	     Return: AX = 0001h enabled
			= 0000h disabled
		     BL = error code (0 = successful)
	08h  Query free extended memory, not counting HMA
	     Return: AX = size of largest extended memory block in K
		     DX = total extended memory in K
		     BL = error code (see below)
	09h  Allocate extended memory block
	     DX = Kbytes needed
	     Return: AX = 0001h success
			   DX = handle for memory block
			= 0000h failure
			   BL = error code (see below)
	0Ah  Free extended memory block
	     DX = handle of block to free
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
	0Bh  Move extended memory block
	     DS:SI -> EMM structure (see below)
	     Note: if either handle is 0000h, the corresponding offset is
		   considered to be an absolute segment:offset address in
		   directly addressable memory
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
	0Ch  Lock extended memory block
	     DX = handle of block to lock
	     Return: AX = 0001h success
			   DX:BX = 32-bit linear address of locked block
			= 0000h failure
			   BL = error code (see below)
	0Dh  Unlock extended memory block
	     DX = handle of block to unlock
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
	0Eh  Get handle information
	     DX = handle for which to get info
	     Return: AX = 0001h success
			   BH = block's lock count
			   BL = number of free handles left
			   DX = block size in K
			= 0000h failure
			   BL = error code (see below)
	0Fh  Reallocate extended memory block
	     DX = handle of block
	     BX = new size of block in K
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
	10h  Request upper memory block (nonEMS memory above 640K)
	     DX = size of block in paragraphs
	     Return: AX = 0001h success
			   BX = segment address of UMB
			   DX = actual size of block
			= 0000h failure
			   BL = error code (see below)
			   DX = largest available block
	11h  Release upper memory block
	     DX = segment address of UMB to release
	     Return: AX = 0001h success
			= 0000h failure
			   BL = error code (see below)
Note:	HIMEM.SYS requires at least 256 bytes free stack space

Format of EMM structure:
Offset	Size	Description
 00h	DWORD	number of bytes to move (must be even)
 04h	WORD	source handle
 06h	DWORD	offset into source block
 0Ah	WORD	destination handle
 0Ch	DWORD	offset into destination block

Error codes returned in BL:
	80h Function not implemented
	81h Vdisk was detected
	82h An A20 error occurred
	8Eh a general driver error
	8Fh unrecoverable driver error
	90h HMA does not exist
	91h HMA is already in use
	92h DX is less than the /HMAMIN= parameter
	93h HMA is not allocated
	94h A20 line still enabled
	A0h all extended memory is allocated
	A1h all available extended memory handles are allocated
	A2h Invalid handle
	A3h Source handle is invalid
	A4h Source offset is invalid
	A5h Destination handle is invalid
	A6h Destination offset is invalid
	A7h Length is invalid
	A8h Move has an invalid overlap
	A9h Parity error occurred
	AAh Block is not locked
	ABh Block is locked
	ACh Block lock count overflowed
	ADh Lock failed
	B0h Only a smaller UMB is available
	B1h No UMB's are available
	B2h UMB segment number is invalid
----------2F4653CX0002-----------------------
INT 2F - Multiplex - F-LOCK.EXE 
	AX = 4653h
	CX = 0002h
	BX = subfunction
	    0000h  installation check
		Return: AX = FFFFh
	    0001h  uninstall
	    0002h  disable (v1.08 and below only)
	    0003h  enable (v1.08 and below only)
Note:	F-LOCK is part of the F-PROT virus/trojan protection package by Fridrik
	  Skulason
----------2F4653CX0003-----------------------
INT 2F - Multiplex - F-XCHK.EXE
	AX = 4653h
	CX = 0003h
	BX = subfunction
	    0000h  installation check
		Return: AX = FFFFh
	    0001h  uninstall
Note:	F-XCHK is part of the F-PROT virus/trojan protection package by Fridrik
	  Skulason
----------2F4653CX0004-----------------------
INT 2F - Multiplex - F-POPUP.EXE
	AX = 4653h
	CX = 0004h
	BX = subfunction
	    0000h  installation check
		Return: AX = FFFFh
	    0001h  uninstall
	    0002h  disable (v1.08 and below only)
	    0003h  enable (v1.08 and below only)
Note:	F-POPUP is part of the F-PROT virus/trojan protection package by
	  Fridrik Skulason
----------2F4653CX0005-----------------------
INT 2F - Multiplex - F-DLOCK.EXE
	AX = 4653h
	CX = 0005h
	BX = subfunction
	    0000h installation check
		Return: AX = FFFFh
	    0001h uninstall
Note:	F-DLOCK is part of the F-PROT virus/trojan protection package by
	  Fridrik Skulason
----------2F4680-----------------------------
INT 2F - Multiplex - MS Windows 3 - INSTALLATION CHECK
	AX = 4680h
Return: AX = 0000h MS Windows 3.0 running in real (/R) or standard (/S) mode
	   nonzero  no Windows, Windows prior to 3.0, or Windows3 in enhanced
		    mode
Note:	not officially documented, but Microsoft has indicated that they
	  intend to provide an installation check which works in all modes
SeeAlso: AX=1600h
----------2F5453-----------------------------
INT 2F - Multiplex - TesSeRact RAM-RESIDENT PROGRAM INTERFACE
	AX = 5453h
	BX = subfunction
	    00h installation check
		DS:SI -> 8-char blank-padded name
		Return: AX = FFFFh installed
				CX = ID number of already-installed copy
			   = anything else, not installed
				CX = ID number for TSR when installed
	    01h get user parameters
		CX = TSR ID number
		Return: AX = 0000h successful
			   ES:BX -> user parameter block (see below)
			   = nonzero failed
	    02h check if hotkey in use
		CL = scan code of hot key
		Return: AX = FFFFh hot key conflicts with another TSR
			     otherwise safe to use the hotkey
	    03h replace default critical error handler
		CX = TSR ID number
		DS:SI -> new routine for INT 24h
		Return: AX = nonzero, unable to install new handler
	    04h get internal data area
		CX = TSR ID number
		Return: AX = 0000h
			    ES:BX -> TSR's internal data area (see below)
			   = nonzero, TSR not found
	    05h set multiple hot keys
		CX = TSR ID number
		DL = number of additional hot keys to allocate
		DS:SI -> table of hot keys
			BYTE  hotkey scan code
			BYTE  hotkey shift state
			BYTE  flag value to pass to TSR (nonzero)
		Return: AX = nonzero, unable to install hot keys
	    06h - 0Fh reserved
	    10h enable TSR
		CX = TSR ID number
		Return: AX = nonzero, unable to enable
	    11h disable TSR
		CX = TSR ID number
		Return: AX = nonzero, unable to disable
	    12h unload TSR
		CX = TSR ID number
		Return: AX = nonzero, invalid TSR number
		Note: if any interrupts used by TSR have been grabbed by
			another TSR, the TesSeRact routines will wait until
			it is safe to remove the indicated TSR from memory
	    13h restart TSR
		CX = TSR ID number of TSR which was unloaded but is still in
		     memory
		Return: AX = nonzero, unable to restart TSR
	    14h get status word
		CX = TSR ID number
		Return: AX = FFFFh invalid ID number
			   = other, successful
				BX = bit flags
	    15h set status word
		CX = TSR ID number
		DX = new bit flags
		Return: AX = nonzero, unable to set status word
	    16h get INDOS state at popup
		CX = TSR ID number
		Return: AX = 0000h successful
			    BX = value of INDOS flag
	    17h - 1Fh reserved
	    20h call user procedure
		CX = TSR ID number
		ES:DI -> user-defined data
		Return: AX = 0000h successful
	    21h stuff keystrokes into keyboard buffer
		CX = TSR ID number
		DL = speed
		    00h stuff keystrokes only when buffer is empty
		    01h stuff up to four keystrokes per clock tick
		    02h stuff up to 15 keystrokes per clock tick
		DH = scan code flag
		    if zeor, buffer contains alternating ASCII and scan codes
		    if nonzero, buffer contains only ASCII codes
		SI = number of keystrokes
		ES:DI -> buffer to stuff
		Return: AX = 0000h success
			     F0F0h user aborted with ^C or ^Break
			     other unable to stuff keystrokes
	    22h (v1.10) trigger popup
		CX = TSR ID number
		Return: AX = 0000h success, TSR will either pop up or beep to
				   indicate that it is unable to pop up
			     nonzero invalid ID number
	    23h (v1.10) invoke TSR's background function
		CX = TSR ID number
		Return: AX = 0000h success
			     FFFFh not safe to call background function
			     nonzero invalid ID number
	    24h - 2Fh reserved
Note:	Borland's THELP.COM popup help system for Turbo Pascal and Turbo C
	  fully supports the TesSeRact API, as do the SWAP?? programs by 
	  Innovative Data Concepts.

Format of User Parameter Block:
Offset	Size	Description
 00h  8 BYTEs	blank-padded TSR name
 08h	WORD	TSR ID number
 0Ah	DWORD	bitmap of supported functions
 0Eh	BYTE	scan code of primary hotkey
		    00h = pop up when shift states match
		    FFh = no popup (if shift state also FFh)
 0Fh	BYTE	shift state of primary hotkey
		    FFh = no popup (if scan code also FFh)
 10h	BYTE	number of secondary hotkeys
 11h	DWORD	pointer to extra hotkeys set by func 05h
 15h	WORD	current TSR status flags
 17h	WORD	PSP segment of TSR
 19h	DWORD	DTA for TSR
 1Dh	WORD	default DS for TSR
 1Fh	DWORD	stack at popup
 23h	DWORD	stack at background invocation

Format of TSR internal data area:
Offset	Size	Description
 00h	BYTE	revision level of TesSeRact library
 01h	BYTE	type of popup in effect
 02h	BYTE	INT 08 occurred since last invocation
 03h	BYTE	INT 13 occurred since last invocation
 04h	BYTE	active interrupts
 05h	BYTE	active soft interrupts
 06h	BYTE	DOS major version
 07h	BYTE	how long to wait before popping up
 08h	DWORD	pointer to INDOS flag
 0CH	DWORD	pointer to DOS critical error flag
 10h	WORD	PSP segment of interrupted program
 12h	WORD	PSP segment of prog interrupted by INT 28
 14h	DWORD	DTA of interrupted program
 18h	DWORD	DTA of program interrupted by INT 28
 1Ch	WORD	SS of interrupted program
 1Eh	WORD	SP of interrupted program
 20h	WORD	SS of program interrupted by INT 28
 22h	WORD	SP of program interrupted by INT 28
 24h	DWORD	INT 24 of interrupted program
 28h  3 WORDs	DOS 3+ extended error info
 2Eh	BYTE	old BREAK setting
 2Fh	BYTE	old VERIFY setting
 30h	BYTE	were running MS WORD 4.0 before popup
 31h	BYTE	MS WORD 4.0 special popup flag
 32h	BYTE	enhanced keyboard call in use
 33h	BYTE	delay for MS WORD 4.0
11 times:
	DWORD	old interrupt vector
	BYTE	interrupt number
	DWORD	new interrupt vector
----------2F6400-----------------------------
INT 2F - Multiplex - SCRNSAV2.COM - INSTALLATION CHECK
	AX = 6400h
Return: AL = 00h not installed
	     FFh installed
Note:	SCRNSAV2.COM is a screen saver for PS/2's with VGA by Alan Ballard
----------2F7A00-----------------------------
INT 2F - Multiplex - Novell NetWare - LOW-LEVEL API (IPX) INSTALLATION CHECK
	AX = 7A00h
Return: AL = 00h not installed
	   = FFh installed
		ES:DI -> FAR entry point for routines accessed through INT 7Ah
			in NetWare versions through 2.0a
SeeAlso: INT 64"Novell",INT 7A"Novell"
----------2F7A80-----------------------------
INT 2F - Multiplex - Novell NetWare shell 3.01d - ???
	AX = 7A80h
Return: nothing
Note:	apparently called on abnormal exit of the shell
----------2F7A81-----------------------------
INT 2F - Multiplex - Novell NetWare shell 3.01d - ???
	AX = 7A81h
	CX:DX -> ??? in shell's CS (may be callback address or data structure)
Return: nothing???
----------2F7A85-----------------------------
INT 2F - Multiplex - Novell NetWare shell 3.01 - BROADCAST INFORM
	AX = 7A85h
	CX = broadcast server number
Return: CX = 0000h if broadcast message handled by another program
	CX unchanged if broadcast not handled
----------2F7AFE-----------------------------
INT 2F - Multiplex - Novell NetWare shell 3.01d - ???
	AX = 7AFEh
Return: AL = FFh ???
	     other ???
----------2F7AFF-----------------------------
INT 2F - Multiplex - Novell NetWare shell 3.01d - ???
	AX = 7AFFh
	BX = 0001h
	CX = offset of ???
	DX = offset of ???
Return: CX unchanged if ???
----------2F8000-----------------------------
INT 2F - Multiplex - EASY-NET - INSTALLATION CHECK
	AX = 8000h
Return: AL = 00h not installed
	     FFh installed
Note:	EASY-NET is a shareware two-machine serial-port network
----------2F8900-----------------------------
INT 2F - Multiplex - WHOA!.COM - INSTALLATION CHECK
	AX = 8900h
Return: AL = 00h not installed
	   = FFh installed
Note:	WHOA!.COM is a system slow-down utility by Brad D Crandall
----------2F8901-----------------------------
INT 2F - Multiplex - WHOA!.COM - UNINSTALL
	AX = 8901h
Return: AL = FDh successful
	   = FEh error
Note:	WHOA!.COM is a system slow-down utility by Brad D Crandall
----------2F8902-----------------------------
INT 2F - Multiplex - WHOA!.COM - SET DELAY COUNT
	AX = 8902h
	BX = delay count (larger values slow system down more)
Return: AL = FDh successful
	   = FEh error
Note:	WHOA!.COM is a system slow-down utility by Brad D Crandall
----------2F90-------------------------------
INT 2F - Multiplex - RAID - ???
	AH = 90h
	???
Return: ???
Note:	RAID is a TSR utility program that resides mostly in EMS
----------2FAA00-----------------------------
INT 2F - Multiplex - VIDCLOCK.COM - INSTALLATION CHECK
	AX = AA00h
Return: AL = 00h not installed
	     FFh installed
Note:	VIDCLOCK.COM is a memory-resident clock by Thomas G. Hanlin III
----------2FAD00-----------------------------
INT 2F - Multiplex - DOS 3.3+ DISPLAY.SYS internal - INSTALLATION CHECK
	AX = AD00h
Return: AL = FFh if installed
	    BX = ??? (0100h in MS-DOS 3.30, PCDOS 4.01)
----------2FAD01-----------------------------
INT 2F - Multiplex - DOS 3.3+ DISPLAY.SYS internal - SET ???
	AX = AD01h
	BX = ???
Return: ???
	CF set on error
----------2FAD02-----------------------------
INT 2F - Multiplex - DOS 3.3+ DISPLAY.SYS internal - GET ???
	AX = AD02h
Return: BX = ??? (value set with AX=AD01h)
----------2FAD03-----------------------------
INT 2F - Multiplex - DOS 3.3+ DISPLAY.SYS internal - GET ???
	AX = AD03h
	ES:DI -> user buffer
	CX = size of buffer
Return: CF set if buffer too small
	CF clear if successful
----------2FAD04-----------------------------
INT 2F - Multiplex - DOS 4+ DISPLAY.SYS internal - ???
	AX = AD04h
	???
Return: ???
----------2FAD10-----------------------------
INT 2F - Multiplex - DOS 4+ DISPLAY.SYS internal - INSTALLATION CHECK???
	AX = AD10h
	???
Return: AX = FFFFh
	BX = ??? (0100h in PCDOS 4.01)
----------2FAD40-----------------------------
INT 2F - Multiplex - DOS 4.0 - ???
	AX = AD40h
	DX = ???
	???
Return: ???
Note:	called by PCDOS 4.01 PRINT.COM
----------2FAD80-----------------------------
INT 2F - Multiplex - DOS 3.3+ KEYB.COM internal - INSTALLATION CHECK
	AX = AD80h
Return: AL = FFh if installed
	    BX = ??? (0100h in MSDOS 3.30 and PCDOS 4.01)
	    ES:DI -> internal data (see below)

Format of KEYB internal data:
Offset	Size	Description
 00h	DWORD	original INT 09
 04h	DWORD	original INT 2F
 08h  6 BYTEs	???
 0Eh	WORD	flags
 10h	BYTE	???
 11h	BYTE	???
 12h  4 BYTEs	???
 16h  2 BYTEs	country ID letters
 18h	WORD	current code page
---DOS 3.3---
 1Ah	WORD	pointer to first item in list of code page tables???
 1Ch	WORD	pointer to ??? item in list of code page tables
 1Eh  2 BYTEs	???
 20h	WORD	pointer to key translation data
 22h	WORD	pointer to last item in code page table list (see below)
 24h  9 BYTEs	???
---DOS 4.01---
 1Ah  2 BYTEs	???
 1Ch	WORD	pointer to first item in list of code page tables???
 1Eh	WORD	pointer to ??? item in list of code page tables
 20h  2 BYTEs	???
 22h	WORD	pointer to key translation data
 24h	WORD	pointer to last item in code page table list (see below)
 26h  9 BYTEs	???

Format of code page table list entries:
Offset	Size	Description
 00h	WORD	pointer to next item, FFFFh = last
 02h	WORD	code page
 04h  2 BYTEs	???

Format of translation data:
Offset	Size	Description
 00h	WORD	size of data in bytes, including this word
 02h N-2 BYTEs	???
----------2FAD81-----------------------------
INT 2F - Multiplex - DOS 3.3+ KEYB.COM internal - SET KEYBOARD CODE PAGE
	AX = AD81h
	BX = code page
Return: CF set on error
	    AX = 0001h (code page not available)
	CF clear if successful
Note:	called by DISPLAY.SYS
SeeAlso: AX=AD82h
----------2FAD82-----------------------------
INT 2F - Multiplex - DOS 3.3+ KEYB.COM internal - SET KEYBOARD MAPPING
	AX = AD82h
	BL = 00h US keyboard (Control-Alt-F1)
	   = FFh foreign keyboard (Control-Alt-F2)
Return: CF set on error (BL not 00h or FFh)
	CF clear if successful
SeeAlso: AX=AD81h
----------2FAE00DXFFFF-----------------------
INT 2F - Multiplex - DOS 3.3+ internal - INSTALLABLE COMMAND - INSTALL CHECK
	AX = AE00h
	DX = FFFFh
	DS:BX -> command line
Return: AL = FFh if this command is a TSR extension to COMMAND.COM
	AL = 00h if the command should be executed as usual
Notes:	This call provides a mechanism for TSRs to install permanent extensions
	  to the command repertoire of COMMAND.COM.  It appears that
	  COMMAND.COM makes this call before executing the current command
	  line,	and does not execute it itself if the return is FFh.
	APPEND hooks this call, to allow subsequent APPEND commands to execute
	  without re-running APPEND

Format of command line:
Offset	Size	Description
 00h	BYTE	max length of command line, as in INT 21/AH=0Ah
 01h	BYTE	count of bytes to follow
      N BYTEs	command line text, terminated by 0Dh
----------2FAE01DXFFFF-----------------------
INT 2F - Multiplex - DOS 3.3+ internal - INSTALLABLE COMMAND - EXECUTE
	AX = AE01h
	DX = FFFFh
	DS:SI -> buffer
Return: buffer at DS:SI filled with a length byte followed by the uppercase
	  internal command to execute (if length not 0)
Notes:	this call requests execution of the command which a previous call to
	  AX=AE00h indicated was resident
	APPEND hooks this call
	if the buffer is filled with a nonempty string, COMMAND.COM will
	  attempt to execute it as an internal command
----------2FB000-----------------------------
INT 2F - Multiplex - DOS 3.3+ GRAFTABL.COM - INSTALLATION CHECK
	AX = B000h
Return: AL = 00h not installed, OK to install
	   = 01h not installed, not OK to install
	   = FFh installed
Note:	called by DISPLAY.SYS
----------2FB001-----------------------------
INT 2F - Multiplex - DOS 3.3+ GRAFTABL.COM - GET ???
	AX = B001h
	DS:DX -> 4-byte buffer (see below)
Return: buffer filled
	AL = FFh

Format of buffer:
Offset	Size	Description
 00h	WORD	??? (PCDOS 3.30/4.01 fill in 0130h, MSDOS 3.30 fills in 0030h)
 02h	WORD	CS of resident code
----------2FB400-----------------------------
INT 2F - Multiplex - IBM PC3270 EMUL PROG v3 - INSTALLATION CHECK
	AX = B400h
Return: AL = FFh if installed
----------2FB401-----------------------------
INT 2F - Multiplex - IBM PC3270 EMUL PROG v3 - GET HOST BUFFER ADDRESS
	AX = B401h
Return: ES -> host screen buffer (PC ASCII format)
	ES unchanged if communications not started
----------2FB402-----------------------------
INT 2F - Multiplex - IBM PC3270 EMUL PROG v3 - ???
	AX = B402h
	BX = ???
Return: ???
----------2FB403-----------------------------
INT 2F - Multiplex - IBM PC3270 EMUL PROG v3 - ???
	AX = B403h
	???
Return: ???
----------2FB404-----------------------------
INT 2F - Multiplex - IBM PC3270 EMUL PROG v3 - ???
	AX = B404h
	???
Return: ???
----------2FB405-----------------------------
INT 2F - Multiplex - IBM PC3270 EMUL PROG v3 - ???
	AX = B405h
	???
Return: ???
----------2FB700-----------------------------
INT 2F - Multiplex - APPEND - INSTALLATION CHECK
	AX = B700h
Return: AL = 00h not installed
	     FFh if installed
Note:	MSDOS 3.30 APPEND refuses to install itself when run inside TopView or
	  a TopView-compatible environment
----------2FB701-----------------------------
INT 2F - Multiplex - APPEND - ???
	AX = B701h
	???
Note:	MSDOS 3.30 APPEND displays "Incorrect APPEND Version" and aborts caller
----------2FB702-----------------------------
INT 2F - Multiplex - APPEND - VERSION CHECK
	AX = B702h
Return: AX = FFFFh if not DOS 4.0 APPEND
	AL = major version number
	AH = minor version number, otherwise
SeeAlso: AX=B710h
----------2FB703-----------------------------
INT 2F - Multiplex - DOS 3.3 APPEND - HOOK INT 21
	AX = B703h
	ES:DI -> INT 21 handler APPEND should chain to
Return: ES:DI -> APPEND's INT 21 handler
Note:	each invocation of this function toggles a flag which APPEND uses to
	  determine whether to chain to the user handler or the original
	  INT 21
----------2FB704-----------------------------
INT 2F - Multiplex - DOS 3.3+ APPEND - GET APPEND PATH
	AX = B704h
Return: ES:DI -> active APPEND path (128 bytes max)
----------2FB706-----------------------------
INT 2F - Multiplex - DOS 4.0 APPEND - GET APPEND FUNCTION STATE
	AX = B706h
Return: BX = APPEND state
	    bit 0: set if APPEND enabled
	    bits 1-12 reserved
	    bit 13: set if /PATH flag active
	    bit 14: set if /E flag active (environment var APPEND exists)
	    bit 15: set if /X flag active
----------2FB707-----------------------------
INT 2F - Multiplex - DOS 4.0 APPEND - SET APPEND FUNCTION STATE
	AX = B707h
	BX = APPEND state bits (see AX=B706h)
----------2FB710-----------------------------
INT 2F - Multiplex - DOS 3.3+ APPEND - GET VERSION INFO
	AX = B710h
Return: AX = ???
	BX = ??? (0000h in MSDOS 3.30)
	CX = ??? (0000h in MSDOS 3.30)
	DL = major version
	DH = minor version
SeeAlso: AX=B702h
----------2FB711-----------------------------
INT 2F - Multiplex - DOS 4.0 APPEND - SET RETURN FOUND NAME STATE
	AX = B711h
Note:	if the next INT 21h call (and ONLY the next) is function 3Dh, 43h, or
	6Ch, the fully qualified filename is written over top of the filename
	passed to the INT 21h call.  The application must provide a 
	sufficiently large buffer.  This state is reset after next INT 21h
	call processed by APPEND.
----------2FB800-----------------------------
INT 2F - Multiplex - Network - INSTALLATION CHECK
	AX = B800h
Return: AL = 00h not installed
	    nonzero installed
	      BX = installed component flags (test in this order!)
		   bit 6   server
		   bit 2   messenger
		   bit 7   receiver
		   bit 3   redirector
----------2FB803-----------------------------
INT 2F - Multiplex - Network - GET CURRENT POST HANDLER ADDRESS
	AX = B803h
Return: ES:BX = post address
SeeAlso: AX=B804h,B903h
----------2FB804-----------------------------
INT 2F - Multiplex - Network - SET NEW POST HANDLER ADDRESS
	AX = B804h
	ES:BX -> new FAR post handler
Notes:	used in conjunction with AX=B803h to hook into the network event post
	  routine.
	The specified handler is called on any network event.  Two events are
	  defined: message received and critical network error.
SeeAlso: AX=B803h,B904h

Values post routine is called with:
	AX = 0000h single block message
	    DS:SI -> ASCIZ originator name
	    DS:DI -> ASCIZ destination name
	    ES:BX -> text header (see below)
	AX = 0001h start multiple message block
	    CX = block group ID
	    DS:SI -> ASCIZ originator name
	    DS:DI -> ASCIZ destination name
	AX = 0002h multiple block text
	    CX = block group ID
	    ES:BX -> text header (see below)
	AX = 0003h end multiple block message
	    CX = block group ID
	AX = 0004h message aborted due to error
	    CX = block group ID
	AX = 0101h server received badly formatted network request
	    Return: AX = FFFFh (PC LAN will process error)
	AX = 0102h unexpected network error
	    ES:BX -> NCB (see INT 5C)
	AX = 0103h server received INT 24 error
	    other registers as for INT 24, except AH is in BH
	    Return: as below, but only 0000h and FFFFh allowed
Return:	AX = response code
	    0000h user post routine processed message
	    0001h PC LAN will process message, but message window not displayed
	    FFFFh PC LAN will process message
	
Format of text header:
Offset	Size	Description
 00h	WORD	length of text (maximum 512 bytes)
 02h  N BYTEs	text of message
Note:	all CRLF sequences in message text are replaced by 14h
----------2FB807-----------------------------
INT 2F - Multiplex - Network - GET NetBIOS NAME NUMBER OF MACHINE NAME
	AX = B807h
Return: CH = NetBIOS name number of the machine name
SeeAlso: INT 21/AX=5E00h
----------2FB808-----------------------------
INT 2F - Multiplex - Network - ???
	AX = B808h
	???
Return: ???
----------2FB809-----------------------------
INT 2F - Multiplex - LANtastic Network - VERSION CHECK
	AX = B809h
Return: AH = major version
	AL = minor version
----------2FB900-----------------------------
INT 2F - PC Network RECEIVER.COM - INSTALLATION CHECK
	AX = B900h
Return: AL = 00h if not installed
	     FFh if installed
----------2FB901-----------------------------
INT 2F - PC Network RECEIVER.COM - GET RECEIVER.COM INT 2F HANDLER ADDRESS
	AX = B901h
Return: AL = ???
	ES:BX -> RECEIVER.COM INT 2F handler
Note:	allows more efficient execution by letting the caller bypass any other
	  INT 2F handlers which have been added since RECEIVER.COM was
	  installed
----------2FB903-----------------------------
INT 2F - PC Network RECEIVER.COM - GET RECEIVER.COM POST ADDRESS
	AX = B903h
Return: ES:BX -> POST handler
SeeAlso: AX=B803h,B904h
----------2FB904-----------------------------
INT 2F - PC Network RECEIVER.COM - SET RECEIVER.COM POST ADDRESS
	AX = B904h
	ES:BX -> new POST handler
SeeAlso: AX=B804h,B903h
----------2FB905-----------------------------
INT 2F - PC Network RECEIVER.COM - GET FILENAME
	AX = B905h
	DS:BX -> 128-byte buffer for filename 1
	DS:DX -> 128-byte buffer for filename 2
Return: buffers filled from RECEIVER.COM internal buffers
Note:	use of filenames is unknown, but one appears to be for storing messages
SeeAlso: AX=B906h
----------2FB906-----------------------------
INT 2F - PC Network RECEIVER.COM - SET FILENAME
	AX = B906h
	DS:BX -> 128-byte buffer for filename 1
	DS:DX -> 128-byte buffer for filename 2
Return: RECEIVER.COM internal buffers filled from user buffers
Note:	use of filenames is unknown, but one appears to be for storing messages
SeeAlso: AX=B905h
----------2FB908-----------------------------
INT 2F - PC Network RECEIVER.COM - UNLINK KEYBOARD HANDLER
	AX = B908h
	ES:BX -> INT 09 handler RECEIVER should call after it finishes INT 09
Note:	this call replaces the address to which RECEIVER.COM chains on an
	  INT 09 without preserving the original value.  This allows a prior
	  handler to unlink, but does not allow a new handler to be added
	  such that RECEIVER gets the INT 09 first.
----------2FBC00-----------------------------
INT 2F - Multiplex - Windows 3.0 EGA.SYS - INSTALLATION CHECK
	AX = BC00h
Return: AL = 00h not installed, OK to install
	   = 01h not installed, not OK to install
	   = FFh installed
		BX = 5456h ("TV")
Note:	AH=BCh is the default value, which may be changed by a command line
	  parameter
----------2FBC06-----------------------------
INT 2F - Multiplex - MS Windows 3.0 EGA.SYS - ???
	AX = BC06h
Return: CX = 020Ah
	DL = 12h
----------2FBF00-----------------------------
INT 2F - Multiplex - PC LAN PROGRAM REDIRIFS.EXE internal - INSTALLATION CHECK
	AX = BF00h
Return: AL = FFh if installed
----------2FBF01-----------------------------
INT 2F - Multiplex - PC LAN PROGRAM REDIRIFS.EXE internal - ???
	AX = BF01h
	???
Return: ???
----------2FBF80-----------------------------
INT 2F - Multiplex - PC LAN PROG REDIR.SYS internal - SET REDIRIFS ENTRY POINT
	AX = BF80h
	ES:DI -> FAR entry point to IFS handler in REDIRIFS
Return: AL = FFh if installed
	    ES:DI -> internal workspace
Note:	all future IFS calls to REDIR.SYS are passed to the ES:DI entry point
----------2FCB00-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - INSTALLATION CHECK
	AX = CB00h
Return: AL = 00h not installed, OK to install
	     01h not installed, not OK to install
	     FFh installed
Note:	AH = CBh is the default identifier, but may be reconfigured
----------2FCB01-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - SUBMIT A TASK
	AX = CB01h
	DS:DX -> ASCIZ name of task control file
Return: AX >= 0: event handle
	   < 0: error code
Note:	files needed for an event must be kept until task is complete or error
SeeAlso: AX=CB0Bh

Error codes (AH = class, AL = subcode, value passed back is 2's complement):
  Class 00h	--- FAX warnings
	Subcode 00h	no error
		02h	bad scanline count
		03h	page sent with errors, could not retransmit
		04h	received data lost
		05h	invalid or missing logo file
		06h	filename does not match nonstandard format (NSF) header
		07h	file size does not match NSF header
  Class 01h	--- DOS warnings (data was sent)
	Subcode 01h	invalid function
		05h	access denied
		06h	invalid handle
		others	see INT 21/AH=59h
  Class 02h	--- fatal errors (data not sent)
	Subcode	00h	multiplex handler failed
		01h	unknown command
		02h	bad event handle
		03h	FIND NEXT attempted before FIND FIRST
		04h	no more events
		07h	invalid queue type
		08h	bad control file
		09h	communication board busy
		0Ah	invalid command parameter
		0Bh	can't uninstall resident code
		0Ch	file exists
		80h	unknown task type
		81h	bad phone number
		82h	bad .PCX file header
		83h	unexpected EOF
		84h	unexpected disconnect
		85h	too many dialing retries
		86h	no file specified for send
		87h	communication board timeout
		88h	received too many pages (>1023) of data
		89h	manual connect initiated too long ago
		8Ah	hardware command set error
		8Bh	bad NonStandard Format (NSF) header file
  Class 03h	--- fatal DOS errors
	Subcode 02h	file not found
		03h	path not found
		others	see INT 21/AH=59h
  Class 04h	--- FAX errors
	Subcode 03h	other FAX machine incompatible
		5Eh	other FAX machine jammed
----------2FCB02-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - ABORT CURRENT EVENT
	AX = CB02h
Return: AX >= 0: event handle of aborted event (>= 0)
	   < 0: error code (see AX=CB01h)
SeeAlso: AX=CB10h
----------2FCB05-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - FIND FIRST QUEUE ENTRY
	AX = CB05h
	CX = status of events to find
	    0000h successful completion
	    0001h waiting to be processed
	    0002h number has been dialed
	    0003h connection established, sending
	    0004h connection established, receiving
	    0005h even aborted
	    FFFFh find any event, regardless of status
	    other negative values, match error code
	DH = direction
	    00h chronological order, earliest to latest
	    01h reverse chronological order, latest to earliest
	DL = queue to search
	    00h task queue
	    01h receive queue
	    02h log queue
Return: AX = 0000h successful
	    BX = event handle for found event
	   < 0	   error code (see AX=CB01h)
SeeAlso: AX=CB06h
----------2FCB06-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - FIND NEXT QUEUE ENTRY
	AX = CB06h
	DL = queue to search
	    00h task queue
	    01h receive queue
	    02h log queue
Return: AX = 0000h successful
	    BX = event handle for found event
	   < 0	   error code (see AX=CB01h)
Note:	direction of search is same as preceding FIND FIRST call
SeeAlso: AX=CB05h
----------2FCB07-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - OPEN FILE
	AX = CB07h
	BX = event handle
	CX = receive file number (ignored for task queue and log queue)
	    0000h  open receive control file
	    N	   open Nth received data file
	DL = queue
	    00h task queue
	    01h receive queue control file or received file, as given by CX
	    02h log queue
Return: AX = 0000h successful
	    BX = DOS file handle for requested file
	   < 0	   error code (see AX=CB01h)
----------2FCB08-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - DELETE FILE
	AX = CB08h
	BX = event handle
	CX = receive file number
	    0000h delete ALL received files and receive control file
	    N	  delete Nth received file
	DL = queue
	    00h delete control file in task queue
	    01h delete file in receive queue, as given by CX
	    02h delete control file in log queue (individual deletions not
		recommended, to maintain integrity of log)
Return: AX = 0000h successful
	   < 0	   error code (see AX=CB01h)\
SeeAlso: AX=CB09h
----------2FCB09-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - DELETE ALL FILES IN Q
	AX = CB09h
	DL = queue
	    00h delete all control files in task queue
	    01h delete all files in receive queue
	    02h delete all control files in log queue
Return: AX = 0000h successful
	   < 0	   error code (see AX=CB01h)
SeeAlso: AX=CB08h
----------2FCB0A-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - GET EVENT DATE
	AX = CB0Ah
	BX = event handle
	DL = queue
	    00h task queue
	    01h receive queue
	    02h log queue
Return: AX = 0000h successful
		CX = year
		DH = month
		DL = day
	   < 0	   error code (see AX=CB01h)
SeeAlso: AX=CB0Ch
----------2FCB0B-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - SET TASK DATE
	AX = CB0Bh
	BX = event handle (task event only)
	CX = year
	DH = month
	DL = day
Return: AX = 0000h successful
	   < 0	   error code (see AX=CB01h)
Note:	setting a task's date and time to before the current date and time
	  causes it to execute immediately
SeeAlso: AX=CB01h,CB0Dh
----------2FCB0C-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - GET EVENT TIME
	AX = CB0Ch
	BX = event handle
	DL = queue
	    00h task queue
	    01h receive queue
	    02h log queue
Return: AX = 0000h successful
		CH = hour
		CL = minute
		DH = second
		DL = 00h
	   < 0	   error code (see AX=CB01h)
SeeAlso: AX=CB0Ah,CB0Dh
----------2FCB0D-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - SET TASK TIME
	AX = CB0Dh
	BX = event handle (task events only)
	CH = hour
	CL = minute
	DH = second
	DL unused
Return: AX = 0000h successful
	   < 0	   error code (see AX=CB01h)
Note:	setting a task's date and time to before the current date and time
	  causes it to execute immediately
SeeAlso: AX=CB0Bh,CB0Ch,CB10h
----------2FCB0E-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - GET EXTERNAL DATA BLOCK
	AX = CB0Eh
	DS:DX -> 256-byte buffer
Return: AX = 0000h successful
		buffer filled
	   < 0	   error code (see AX=CB01h)

Format of external data block:
Offset	Size	Description
 00h	BYTE	CAS major version
 01h	BYTE	CAS minor version
 02h 68 BYTEs	ASCIZ path to directory containing CAS software, ends in slash
 46h 13 BYTEs	ASCIZ name of current phonebook (in CAS directory)
 53h 13 BYTEs	ASCIZ name of current logo file (in CAS directory)
 60h 32 BYTEs	ASCIZ default sender name
 80h 21 BYTEs	ASCIZ CCITT identification of fax device
 95h 107 BYTEs	reserved
----------2FCB0F-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - GET/SET AUTORECEIVE
	AX = CB0Fh
	DL = subfunction
	    00h get current autoreceive state
	    01h set autoreceive state
		DH = number of rings before answer, 00h = never
Return: AX = 0000h autoreceive disabled
	   = N	   number of rings before answer
	   < 0	   error code (see AX=CB01h)
----------2FCB10-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - GET EVENT STATUS
	AX = CB10h
	DS:DX -> 511-byte buffer
Return: AX = 0000h successful
		BX = event handle of current event
		buffer filled
	   < 0	   error code (see AX=CB01h)
SeeAlso: AX=CB02h,CB0Dh

Format of status area:
Offset	Size	Description
 00h	BYTE	event type
		00h send
		01h receive
		02h polled send
		03h polled receive
		04h to 7Fh reserved
		FFh serious hardware error
 01h	BYTE	transfer type
		00h 200x200 dpi, FAX mode
		01h 100x200 dpi, FAX mode
		02h file transfer mode
		03h to 7Fh reserved
 02h	WORD	event status 
		0000h completed successfully
		0001h waiting
		0002h number dialed
		0003h connected, sending
		0004h connected, receiving
		0005h aborted
		0006h to 007Fh reserved
		0080h to 7FFFh application-specific events
		8000h to FFFFh error codes
 04h	WORD	event time (packed DOS time format, see INT 21/AX=5700h)
 06h	WORD	event date (packed DOS date format, see INT 21/AX=5700h)
 08h	WORD	number of files to transfer, max 7FFFh
 0Ah	WORD	offset of file transfer record
 0Ch 47 BYTEs	ASCIZ phone number to call
 3Bh 64 BYTEs	ASCIZ application-specific tag string
 7Bh	BYTE	reserved (00h)
 7Ch	BYTE	connect time, seconds
 7Dh	BYTE	connect time, minutes
 7Eh	BYTE	connect time, hours
 7Fh	DWORD	total number of pages in all files
 83h	DWORD	pages already transmitted 
 87h	WORD	number of files already transmitted
 89h	BYTE	cover page flag
		00h don't transmit cover page
		01h transmit cover page
		02h to 7Fh reserved
 8Ah	WORD	total number of transmission errors
 8Ch 78 BYTEs	reserved (zeros)
 DAh 21 BYTEs	ASCIZ remote FAX's CCITT identification
 EFH 32 BYTEs	ASCIZ destination name
10Fh 32 BYTEs	ASCIZ sender name
12Fh 80 BYTEs	filename of PCX logo file (max 1780x800 pixels)
17Fh 128 BYTEs	file transfer record for current event (see below)

Format of file transfer record:
Offset	Size	Description
 00h	BYTE	file type (ignored unless FAX)
		00h ASCII
		01h PCX
		02h DCX
		03h to 7Fh reserved
 01h	BYTE	text size for ASCII FAX file
		00h = 80 columns by 66 lines (11 inches)
		01h = 132 columns by 88 lines (11 inches)
		02h to 7Fh reserved
 02h	BYTE	status of file
		00h untouched
		01h opened
		02h moved
		03h deleted
		04h not yet received
		05h to 7Fh reserved
 03h	DWORD	bytes already transmitted
 07h	DWORD	file size in bytes
 0Bh	WORD	pages alread transmitted
 0Dh	WORD	number of pages in file
 0Fh 80 BYTEs	ASCIZ filename
 5Fh	BYTE	1/8 inch page length
		if page length below set to 01h through 7Fh, this value 
		specifies additional 1/8 inch increments to page length
 60h	BYTE	page length
		00h = 11 inches
		01h to 7Fh = page length is this number of inches plus value of
			1/8 inch field above
		80h to FEh reserved
		FFh = ASCII pages ending with formfeed
 61h 31 BYTEs	reserved (zeros)
----------2FCB11-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - GET QUEUE STATUS
	AX = CB11h
	DL = queue to get status of
	    00h task queue
	    01h receive queue
	    02h log queue
Return: AX >= 0  total number of changes made to queue, modulo 32768
		BX = number of control files currently in queue
		CX = number of received files (zero for task and log queues)
	   < 0	 error code (see AX=CB01h)
SeeAlso: AX=CB12h
----------2FCB12-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - GET HARDWARE STATUS
	AX = CB12h
	DS:DX -> 128-byte status buffer
Return: AX = 0000h successful
		buffer filled with hardware-dependent status information
	   < 0	   error code (see AX=CB01h)
SeeAlso: AX=CB11h

Format of status buffer for Intel Connection CoProcessor:
Offset	Size	Description
 00h	BYTE	bit flags
		bit 7: hardware busy sending or receiving
		bit 6: last page of data
		bit 5: no data on current page
		bit 4: retransmit request for current page being transmitted
		bit 3: NSF mode active
		bits 2-0: reserved
 01h	BYTE	number of kilobytes of free buffer space
 02h	BYTE	page buffer status
		bit 7: Connection CoProcessor has documents to send
		bits 6-0: number of pages in buffer
 03h	BYTE	number of retries left for dialing number
 04h	BYTE	page number to retransmit
 05h	BYTE	communications status
		bit 7: originating call
		bit 6: FAX message to be sent
		bit 5: on line
		bit 4: ring detected and receive enabled
		bit 3: buffer dumped on receive
		bits 2-0: hardware sequence state
			000 idle
			001 dial
			010 answer
			011 transmit
			100 receive
			101 pre-message
			110 post-message
			111 disconnect
 06h	BYTE	baud rate
		bit 7: reserved
		bits 6-4: baud rate
			000 = 300 baud (SDLC mode)
			100 = 2400 baud
			101 = 4800 baud
			110 = 7200 baud
			111 = 9600 baud
		bits 3-0: reserved, should be 0110
 07h  3 BYTEs	reserved
 0Ah	BYTE	hardware status
		bit 7: modem option installed
		bit 6: Connection CoProcessor has control of DAA (not latched)
		bit 5: on line (not latched)
		bit 4: ring detected (not latched)
		bit 3: data in command buffer (not latched)
		bit 2: set if using DMA channel 1, clear if using DMA channel 3
		bit 1: line length compensation bit 1 set (not latched)
		bit 0: line length compensation bit 0 set (not latched)
 0Bh	BYTE	switch states
		bit 7: reserved
		bit 6: unused
		bit 5: spare switch open
		bit 4: FAX ADR1 switch open
		bit 3: FAX ADR0 switch open
		bit 2: alternate interrupt switch open
		bit 1: COM SEL 1 switch open
		bit 0: COM SEL 0 switch open
 0Ch	BYTE	bit flags
		bit 7: reserved
		bit 6: auxiliary relay forced ON
		bit 5: modem select relay forced ON
		bit 4: offhook relay forced ON
		bit 3: 9600 bps enabled
		bit 2: 7200 bps enabled
		bit 1: 4800 bps enabled
		bit 0: 2400 bps enabled
 0Dh	BYTE	reserved
 0Eh	WORD	error count
 10h	DWORD	size of nonstandard format (NSF) file in bytes
 14h 10 BYTEs	reserved
 1Eh 21 BYTEs	ASCIZ CCITT identification
 33h 77 BYTEs	reserved
----------2FCB13DL00-------------------------
INT 2F - Multiplex - Communicating Applications Spec - GET DIAGNOSTICS RESULTS
	AX = CB13h
	DL = 00h
Return: AX = 0040h in progress
	   > 0	   passed
	   < 0	   failure code
Note:	diagnostics return values are hardware dependent
SeeAlso: AX=CB13h/DL=01h

Intel Connection CoProcessor failure codes:
	bit 3: 9600 bps FAX modem module failed
	bit 2: SDLC chip failed
	bit 1: RAM failed
	bit 0: ROM checksum failed
----------2FCB13DL01-------------------------
INT 2F - Multiplex - Communicating Applications Spec - START DIAGNOSTICS
	AX = CB13h
	DL = 01h
Return: AX = 0000h successfully started
	   < 0	   error code (see AX=CB01h)
SeeAlso: AX=CB13h/DL=00h
----------2FCB14-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - MOVE RECEIVED FILE
	AX = CB14h
	BX = event handle
	CX = receive file number
	     0001h first received file
	     N	   Nth received file
	DS:DX -> ASCIZ string specifying new name for file
Return: AX = 0000h successful
	   < 0	   error code (see AX=CB01h)
----------2FCB15-----------------------------
INT 2F - Multiplex - Communicating Applications Spec - SUBMIT FILE TO SEND
	AX = CB15h
	DS:DX -> variable-length data area
Return: AX >= 0	event handle
	   < 0	error code (see AX=CB01h)

Format of data area:
Offset	Size	Description
 00h	BYTE	transfer type
		00h = 200x200 dpi, fax mode
		01h = 100x200 dpi, fax mode
		02h = file transfer mode
		03h to 7Fh reserved
 01h	BYTE	text size
		00h = 80 columns
		01h = 132 columns
		02h to 7Fh reserved
 02h	WORD	time to send (DOS packed time format, see INT 21/AX=5700h)
 04h	WORD	date to send (DOS packed date format, see INT 21/AX=5700h)
 06h 32 BYTEs	ASCIZ destination name
 26h 80 BYTEs	ASCIZ name of file to send
 76h 47 BYTEs	ASCIZ phone number to dial
 A5h 64 BYTEs	ASCIZ application-specific tag string
 E5h	BYTE	reserved (00h)
 E6h	BYTE	cover page
		00h don't send cover page
		01h send cover page
		02h to 7Fh reserved
 E7h 23 BYTEs	reserved (zeros)
 FEh variable	ASCIZ string containing text of cover page (if cover page flag
		set to 01h)
----------2FCD00-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - INSTALLATION CHECK
	AX = CD00h
Return: AL = 00h not installed, OK to install
	     01h not installed, not OK to install
	     FFh installed
----------2FCD00-----------------------------
INT 2F - Multiplex - SWELL.EXE - INSTALLATION CHECK
	AX = CD00h
Return: AX = 00FFh installed
	    BH = major version
	    BL = minor version
Note:	SWELL.EXE is a TSR which swaps programs to disk when they EXEC a child
	  process with INT 21/AH=4Bh
----------2FCD01-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - SET DEVICE NAME
	AX = CD01h
	CX:BX -> ASCIZ character device name ("LPTn", "COMn", "PRN")
Return: AL = 00h successful
		CX:BX -> internal character device name
	   = 80h error
----------2FCD01-----------------------------
INT 2F - Multiplex - SWELL.EXE - SUSPEND ONCE
	AX = CD01h
Return: AX = 0000h
SeeAlso: AX=CD02h"SWELL"
----------2FCD02-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - GET VERSION NUMBER
	AX = CD02h
Return: AL = 00h/01h successful
		BH = major version number (BCD)
		BL = minor version number (BCD)
	   = 80h error
Note:	if return AL = 01h, the IPI supports network redirection
----------2FCD02-----------------------------
INT 2F - Multiplex - SWELL.EXE - SUSPEND
	AX = CD02h
Return: AX = 0000h
SeeAlso: AX=CD03h"SWELL"
----------2FCD03-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - SELECT SCAN LINE
	AX = CD03h
	BX = scan line
	CX = requested density in dots per inch (300, 600, or 1200)
Return: AL = 00h succesful
		CX = density at which scan line was mapped
		ES:DI -> start of scan line
	AL = 80h unsuccessful
	   = 81h scan line out of range
	   = 82h unsupported scan line density
	   = 83h out of memory
----------2FCD03-----------------------------
INT 2F - Multiplex - SWELL.EXE - ACTIVATE
	AX = CD03h
Return: AX = 0000h
SeeAlso: AX=CD02h"SWELL"
----------2FCD04-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - MOVE BITMAP TO SCANLINE
	AX = CD04h
	CX:BX -> structure (see below)
Return: AL = 00h successful
	   = 80h unsuccessful
	   = 81h scan line out of range
	   = 82h unsupported scan line density
	   = 83h out of memory
	   = 84h unrecognized source
	   = 85h initialization error

Format of structure:
Offset	Size	Description
 00h	WORD	image source (0 = conventional memory, 1 = expanded memory)
 02h	DWORD	pointer to image data
 06h	WORD	scan line on which to place
 08h	WORD	bit offset from start of scan line at which to place
 0Ah	WORD	density of bitmap data (300, 600, or 1200 dpi)
 0Ch	WORD	width in bits of data
 0Eh	WORD	source logical page number
 10h	WORD	source handle (only if source in expanded memory)
 12h	WORD	source offset (only if source in expanded memory)
----------2FCD04-----------------------------
INT 2F - Multiplex - SWELL.EXE - TURN OFF VERBOSE MODE
	AX = CD04h
Return: AX = 0000h
SeeAlso: AX=CD05h"SWELL"
----------2FCD05-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - PRINT PAGE
	AX = CD05h
Return: AL = 00h successful
	   = 80h unsuccessful
Note:	page image is retained, so multiple calls will print multiple copies of
	  the page
----------2FCD05-----------------------------
INT 2F - Multiplex - SWELL.EXE - TURN ON VERBOSE MODE
	AX = CD05h
Return: AX = 0000h
SeeAlso: AX=CD04h"SWELL"
----------2FCD06-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - CLEAR PAGE
	AX = CD06h
Return: AL = 00h successful
	   = 80h unsuccessful
Note:	palette is reset to default
----------2FCD06-----------------------------
INT 2F - Multiplex - SWELL.EXE - UNINSTALL
	AX = CD06h
Return: AX = 0000h uninstalled
	   = 8002h programs still swapped, not uninstalled
----------2FCD07-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - reserved
	AX = CD07h
----------2FCD07-----------------------------
INT 2F - Multiplex - SWELL.EXE - GET INFO
	AX = CD07h
	ES:BX -> 32-byte buffer for info
Return: AX = 0000h successful
	    ES:BX buffer filled
	   = 8001h buffer wrong size

Format of info buffer:
Offset	Size	Description
 00h	WORD	20h  (total size of buffer)
 02h	BYTE	suspend-once mode active if nonzero
 03h	BYTE	00h active, 01h suspended
 04h	BYTE	00h quiet, 01h verbose
 05h	BYTE	"Borland support" (allowing INT 21/AX=4B01h) on if nonzero
 06h 26 BYTEs	unused???
----------2FCD08-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - SCREEN IMAGE
	AX = CD08h
	CX:BX -> structure (see below)
Return: AL = 00h successful
	   = 80h unsuccessful
	   = 81h scan line out of range
	   = 82h unsupported scan line density
	   = 83h out of memory
	   = 84h unrecognized source
	   = 85h initialization error

Format of structure:
Offset	Size	Description
 00h	WORD	image source (0 = conventional memory, 1 = expanded memory)
 02h	DWORD	pointer to image data
 06h	WORD	horizontal position on paper of left edge (in 1200 dpi units)
 08h	WORD	vertical position on paper of top edge (in 1200 dpi units)
 0Ah	WORD	left cropping (currently must be zero)
 0Ch	WORD	top cropping (currently must be zero)
 0Eh	WORD	width (currently must be 8000h)
 10h	WORD	height (currently must be 8000h)
 12h	WORD	horizontal size of image in 1200 dpi units
 14h	WORD	vertical size of image in 1200 dpi units
 16h	WORD	aspect ratio (currently reserved)
 18h	WORD	initialization flag (if 01h, initialization is performed)
 1Ah	WORD	pixels per line of source data
 1Ch	WORD	number of scan lines in source data
 1Eh	WORD	number of scan lines in packet
 20h	WORD	bits per pixel (1,2,4,6, or 8)
 22h	WORD	pixels per byte (1,2,4, or 8)
 24h	WORD	compression type (currently only 00h [uncompressed] supported)
 26h	WORD	source page number (if in expanded memory)
 28h	WORD	source handle (if in expanded memory)
 2Ah	WORD	source offset (if in expanded memory)
----------2FCD08-----------------------------
INT 2F - Multiplex - SWELL.EXE - UNUSED
	AX = CD08h
Return: AX = FFFFh (error)
----------2FCD09-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - LOAD SCREEN
	AX = CD09h
	CX:BX -> structure (see below)
Return: AL = 00h successful
	   = 80h unsuccessful
SeeAlso: AX=CD0Ah"Image Processing"

Format of structure:
Offset	Size	Description
 00h	BYTE	style
		44h ('D') diamond style
		4Ch ('L') line style
 01h	BYTE	reserved (00h)
 02h	WORD	frequency in lines per inch [sic]
		currently, coerced to nearest of 50, 60, 68, 70, 75, 85, or 100
 04h	WORD	screen angle in degrees (-360 to 360)
		currently coerced to nearest of -45, 0, 45, or 90
----------2FCD09-----------------------------
INT 2F - Multiplex - SWELL.EXE - TURN OFF "BORLAND SUPPORT"
	AX = CD09h
Return: AX = 0000h
SeeAlso: AX=CD0Ah"SWELL"
----------2FCD0A-----------------------------
INT 2F - Multiplex - Intel Image Processing Interface - LOAD PALETTE
	AX = CD0Ah
	CX:BX -> palette structure (see below)
Return: AL = 00h successful
	   = 80h unsuccessful
SeeAlso: AX=CD09h"Image Processing"

Format of palette structure:
Offset	Size	Description
 00h	BYTE	bits per pixel for which palette is to be used (1,2,4,6, or 8)
 01h	2**N	palette translation values, one per possible pixel value
----------2FCD0A-----------------------------
INT 2F - Multiplex - SWELL.EXE - TURN ON "BORLAND SUPPORT"
	AX = CD0Ah
Return: AX = 0000h
SeeAlso: AX=CD09h"SWELL"
----------2FD200BX5144-----------------------
INT 2F - Multiplex - Quarterdeck QEMM/QRAM/MFT 5.0 - INSTALLATION CHECK
	AX = D200h
	BX = 5144h ("QD")
	CX = 4D45h ("ME")
	DX = 4D30h ("M0")
Return: AL = FFh installed	  
	if BX,CX,DX registers were as specified on entry:
	    BX = 4D45h ("ME")
	    CX = 4D44h ("MD")
	    DX = 5652h ("VR")
Notes:	QEMM/QRAM/VIDRAM/MANIFEST will search for a free AH value from D2h
	  through FFh, then C0h through D1h
	QEMM and QRAM both responded the same
	for AL <> 0, if the BX/CX/DX values don't match a the identifier of a
	  Quarterdeck product, it just chains to the previous INT 2F handler
----------2FD201BX4849-----------------------
INT 2F - Multiplex - Quarterdeck QEMM/QRAM 5.0 - GET HIRAM MEMORY CHAIN
	AX = D201h
	BX = 4849h ("HI")
	CX = 5241h ("RA")
	DX = 4D30h ("M0")
Return: BX = 4F4Bh ("OK")
	CX = segment of start of HIRAM chain
	DX = QEMM/QRAM code segment
Notes:	QEMM/QRAM/VIDRAM/MANIFEST will search for a free AH value from D2h
	  through FFh, then C0h through D1h
	QEMM and QRAM both responded the same
	the HIRAM memory chain has the same format as the regular DOS 4.0
	  memory chain (see INT 21/AH=52h), except that XMS Upper Memory Blocks
	  have the block header program name field set to "UMB"
----------2FD201BX5145-----------------------
INT 2F - Multiplex - Quarterdeck QEMM/QRAM 5.0 - INSTALLATION CHECK???
	AX = D201h
	BX = 5145h ("QE")
	CX = 4D4Dh ("MM")
	DX = 3432h ("42")
Return: BX = 4F4Bh ("OK")
	DI = ???
	ES = QEMM/QRAM code segment
Note:	QEMM/QRAM/VIDRAM/MANIFEST will search for a free AH value from D2h
	  through FFh, then C0h through D1h
	QEMM and QRAM both responded the same
----------2FD201BX5649-----------------------
INT 2F - Multiplex - Quarterdeck VIDRAM 5.0 - INSTALLATION CHECK
	AX = D201h
	BX = 5649h ("VI")
	CX = 4452h ("DR")
	DX = 414dh ("AM")
Return: BX = 4F4Bh ("OK")
	DI = ???
	ES = VIDRAM code segment
Note:	QEMM/QRAM/VIDRAM/MANIFEST will search for a free AH value from D2h
	  through FFh, then C0h through D1h
----------2FD201BX4D41-----------------------
INT 2F - Multiplex - Quarterdeck MANIFEST 5.0 - INSTALLATION CHECK
	AX = D201h
	BX = 4D41h ("MA")
	CX = 4E49h ("NI")
	DX = 4645h ("FE")
Return: BX = 5354h ("ST")
Note:	QEMM/QRAM/VIDRAM/MANIFEST will search for a free AH value from D2h
	  through FFh, then C0h through D1h
----------2FD44D-----------------------------
INT 2F - Multiplex - 4DOS.COM v2.1+
	AX = D44Dh
	BH = function
	    00h installation check
		Return: AX = 44DDh
			BL = minor version number
			BH = major version number
			CX = PSP segment address for current invocation
			DL = 4DOS shell number (0 for the first (root) shell,
			     updated each time a new copy is loaded)
	    01h (internal) terminate current copy of 4DOS
	    02h ???
		DX = ???
	    03h EXEC program
		CX:DX -> EXEC record
	    FEh deallocate shell number (passed through to root shell)
		???
	    FFh allocate shell number (passed through to root shell)
Note:	bug in v3.00 will crash system if unrecognized value in BH

Format of EXEC record:
Offset	Size	Description
 00h	WORD	offset of ASCIZ program name in same segment as EXEC record
 02h	WORD	offset of DOS commandline in same segment as EXEC record
 04h	WORD	segment of environment for child process (see INT 21/AH=26h)
----------2FD44E-----------------------------
INT 2F - Multiplex - 4DOS.COM v3.0+ - AWAITING USER INPUT
	AX = D44Eh
---4DOS v3.01+---
	BX = 0000h 4DOS is ready to display prompt
	   = 0001h 4DOS has displayed the prompt, about to accept user input
Return: handler must preserve SI, DI, BP, SP, DS, ES, and SS
Note:	v3.00 only makes the call corresponding to BX=0001h, does not set BX
----------2FD701-----------------------------
INT 2F - Multiplex - BANYAN VINES v4+ - GET BANV INTERRUPT NUMBER
	AX = D701h
Return: AX = 0000h installed
	    BX = interrupt number (60h to 66h)
	   nonzero not present
Note:	if AX is nonzero, VINES 3.x or earlier may be installed, thus it is
	  necessary to examine the four bytes preceding the handlers for
	  INT 60 through INT 66 for the string "BANV"
----------2FDA55-----------------------------
INT 2F - Multiplex - TRAP.COM - INSTALLATION CHECK
	AX = DA55h
	DL = interrupt number
	DH = ???
Return: if installed
	    AH = interrupt number
	    AL = ???
	    ES:BX -> ???
Notes:	TRAP is an interrupt call tracer by Patrick Phillipot/Udo Chrosziel
	a separate copy of TRAP is loaded for each interrupt to be traced; thus
	  the interrupt number is part of the installation check
----------2FDE00BX4445-----------------------
INT 2F - Multiplex - DESQview 2.26 External Dev Interface - INSTALLATION CHECK
	AX = DE00h
	BX = 4445h ("DE")
	CX = 5844h ("XD")
	DX = 4931h ("I1")
Return: AL = FFh if installed (even if other registers do not match)
	if BX,CX, and DX were as specified on entry,
	    BX = 4845h ("HE")
	    CX = 5245h ("RE")
	    DX = 4456h ("DV")
Notes:	AH=DEh is the default XDI multiplex number, but may range from C0h-FFh
	programs should check for XDI starting at DEh to FFh, then C0h to DDh
	the XDI handler should not issue any DOS or BIOS calls, nor should it
	  issue DESQview API calls other than those allowed from hardware ints
----------2FDE01-----------------------------
INT 2F - Multiplex - DESQview 2.26 External Dev Itrface - DRIVER CUSTOM SUBFUNC
	AX = DE01h
	BX = driver ID
	other registers as needed by driver
Notes:	XDI drivers should pass this call through to previous handler if ID
	  does not match
	DESQview never calls this function
----------2FDE01BX7474-----------------------
INT 2F - Multiplex - DESQview 2.26 XDI - DVTree DVTXDI.COM
	AX = DE01h
	BX = 7474h
	CL = function
	    00h installation check
		Return: AL = FFh
	    01h get process handle
		DX = keys on Open Window menu (DL = first, DH = second)
		Return: AX = process handle or 0000h if not running
Return: BX = 4F4Bh ("OK")
	DL = ???
Note:	DVTree is a shareware DOS shell/DESQview process manager by Mike Weaver
----------2FDE01BXFFFE-----------------------
INT 2F - Multiplex - DESQview 2.26 XMS XDI - ???
	AX = DE01h
	BX = FFFEh
	CX = 4D47h
	DX = 0052h
Return: AL = FFh
	DX = 584Dh
----------2FDE02-----------------------------
INT 2F - Multiplex - DESQview 2.26 External Device Interface - DV INIT COMPLETE
	AX = DE02h
	BX = mapping context of DESQview
	DX = handle of DESQview system task
SeeAlso: AX=DE03h
Note:	driver should pass this call to previous handler after doing its work
----------2FDE03-----------------------------
INT 2F - Multiplex - DESQview 2.26 External Device Interface - DV TERMINATION
	AX = DE03h
	BX = mapping context of DESQview
	DX = handle of DESQview system task
SeeAlso: AX=DE02h
Notes:	driver should pass this call to previous handler before doing its work
	DESQview makes this call when it is exiting, but before unhooking any
	  interrupt vectors
----------2FDE04-----------------------------
INT 2F - Multiplex - DESQview 2.26 External Device Interface - ADD PROCESS
	AX = DE04h
	BX = mapping context of new process
	DX = handle of process
Return: nothing
Notes:	XMS XDI handler (installed by default) allocates a 22-byte record
	  (see below) from "common" memory to control access to XMS memory
	all DOS, BIOS, and DV API calls are valid in handler
	driver should pass this call to previous handler after processing it
SeeAlso: AX=DE05h

Format of XMS XDI structure:
Offset	Size	Description
 00h	DWORD	pointer to 10-byte record???
 04h	DWORD	pointer to next XMS XDI structure
 08h	WORD	mapping context
 0Ah	BYTE	???
 0Bh  5 BYTEs	XMS entry point to return for INT 2F/AX=4310h
		(FAR jump to next field)
 10h  6 BYTEs	FAR handler for XMS driver entry point
		(consists of a FAR CALL followed by RETF)
----------2FDE05-----------------------------
INT 2F - Multiplex - DESQview 2.26 External Device Interface - REMOVE PROCESS
	AX = DE05h
	BX = mapping context of process
	DX = handle of last task in process
Return: nothing
Notes:	XMS XDI handler releases the structure allocated by AX=DE04h
	driver should pass this call to previous handler before processing it
	all DOS, BIOS, and DV API calls except those generating a task switch
	  are valid in handler
SeeAlso: AX=DE04h
----------2FDE06-----------------------------
INT 2F - Multiplex - DESQview 2.26 XDI - CREATE TASK
	AX = DE06h
	BX = mapping context of process containing task
	DX = handle of new task
Notes:	driver should pass this call to previous handler after processing it
	all DOS, BIOS, and DV API calls are valid in handler
----------2FDE07-----------------------------
INT 2F - Multiplex - DESQview 2.26 XDI - TERMINATE TASK
	AX = DE07h
	BX = mapping context of process containing task
	DX = handle of task
Notes:	driver should pass this call to previous handler before processing it
	all DOS, BIOS, and DV API calls except those generating a task switch
	  are valid in handler
----------2FDE08-----------------------------
INT 2F - Multiplex - DESQview 2.26 XDI - SAVE STATE
	AX = DE08h
	BX = mapping context of task being switched from
	DX = handle of task being switched from
Notes:	invoked prior to task swap, interrupts, etc
	driver should pass this call to previous handler after processing it
----------2FDE09-----------------------------
INT 2F - Multiplex - DESQview 2.26 XDI - RESTORE STATE
	AX = DE09h
	BX = mapping context of task being switched to
	DX = handle of task being switched to
Notes:	state is restored except for interrupts
	driver should pass this call to previous handler before processing it
----------2FDE0A-----------------------------
INT 2F - Multiplex - DESQview 2.26 XDI - CHANGE KEYBOARD FOCUS
	AX = DE0Ah
	BX = mapping context of task receiving focus
	DX = handle of running task
Notes:	driver should pass this call to previous handler before processing it
	this call often occurs inside a keyboard interrupt
----------2FDE0B-----------------------------
INT 2F - Multiplex - DESQview 2.26 XDI - DVP PROCESSING COMPLETE
	AX = DE0Bh
	BX = mapping context of DESQview system task
	CX = number of system memory paragraphs required for the use of all
		XDI drivers (DV will add this to system memory in DVP buffer)
	DX = handle of DESQview system task
	SI = mapping context of new process if it starts
	ES:DI -> DVP buffer
Return: CX incremented as needed
Notes:	once DV invokes this function, the DVP buffer contents may be changed
	driver should pass this call to previous handler before processing it
----------2FDE0C-----------------------------
INT 2F - Multiplex - DESQview 2.26 XDI - SWAP OUT PROCESS
	AX = DE0Ch
	BX = mapping context of task being swapped out
	DX = handle of DESQview system task
Note:	driver should pass this call to previous handler after processing it
----------2FDE0D-----------------------------
INT 2F - Multiplex - DESQview 2.26 XDI - SWAP IN PROCESS
	AX = DE0Dh
	BX = mapping context of process just swapped in
	DX = handle of DESQview system task
Note:	driver should pass this call to previous handler before processing it
----------2FDE0E-----------------------------
INT 2F - Multiplex - DESQview 2.26 XDI - DVP START FAILED
	AX = DE0Eh
	BX = mapping context of DESQview system task
	DX = handle of DESQview system task
	SI = mapping context of failed process (same as for call to AX=DE0Bh)
Note:	driver should pass this call to previous handler after processing it
----------2FE300-----------------------------
INT 2F - Multiplex - ANARKEY.COM - INSTALLATION CHECK
	AX = E300h
Return: AL = 00h not installed
	     FEh if installed but suspended (v3.0+)
	     FFh installed
Notes:	ANARKEY.COM is a commandline recall program by Steven Calwas
	E3h is the default function number, but can be set to any value from
	  C0h to FFh.
----------2FE301-----------------------------
INT 2F - Multiplex - ANARKEY.COM v2+ - GET ???
	AX = E301h
Return: DX:BX -> ???
Note:	ANARKEY.COM is a commandline recall program by Steven Calwas

Format of returned data structure for ANARKEY v2.0:
Offset	Size	Description
 -7   7 BYTEs	signature ('ANARKEY')
 00h	WORD	??? (I see 0001h in v2.0)
 02h	WORD	??? (I see 0001h in v2.0)
 04h	WORD	??? (I see 0 in v2.0)
 06h	WORD	PSP segment of next program loaded

Format of returned data structure for ANARKEY v3.0:
Offset	Size	Description
 -1	BYTE	multiplex number
 00h	WORD	??? (I see 0001h in v3.0)
 02h	WORD	??? (I see 0001h in v3.0)
 04h	BYTE	??? (I see 0 in v3.0)
 05h	WORD	PSP segment of next program loaded
----------2FE302-----------------------------
INT 2F - Multiplex - ANARKEY.COM v3.0 - ???
	AX = E302h
	BL = ???
Return: ???
Note:	ANARKEY.COM is a commandline recall program by Steven Calwas
----------2FE303-----------------------------
INT 2F - Multiplex - ANARKEY.COM v3.0 - ANARKMD API
	AX = E303h
	BL = function
	    01h  toggle insert mode
	    02h  display contents of history buffer
	    03h  write history buffer to file
		ES:DX -> file name
	    04h  clear history buffer
	    05h  undefine all aliases
	    06h  show aliases
	    07h	 list programs using Unix switchar
	    08h	 jump to bottom of history buffer	
Return: ???
Note:	ANARKEY.COM is a commandline recall program by Steven Calwas
----------2FE304-----------------------------
INT 2F - Multiplex - ANARKEY.COM v2.0 - ???
	AX = E304h
	BL = ???
Return: ???
Note:	ANARKEY.COM is a commandline recall program by Steven Calwas
----------2FE305-----------------------------
INT 2F - Multiplex - ANARKEY.COM v3.0 - SUSPEND ANARKEY
	AX = E305h
	BL = 01h suspend
	     00h enable
Note:	ANARKEY.COM is a commandline recall program by Steven Calwas
----------2FF700-----------------------------
INT 2F - Multiplex - AUTOPARK.COM - INSTALLATION CHECK
	AX = F700h
Return: AL = 00h not installed
	     FFh installed
Note:	AUTOPARK.COM is a resident hard disk parker by Alan D. Jones
----------2FF701-----------------------------
INT 2F - Multiplex - AUTOPARK.COM - SET PARKING DELAY
	AX = F701h
	BX:CX = 32 bit count of 55ms timer ticks
----------2FFB-------------------------------
INT 2F - Multiplex - RESERVED BY BORLAND INTERNATIONAL
	AH = FBh
----------2FFB42-----------------------------
INT 2F - Multiplex - Borland DPMI LOADER
	AX = FB42h
	details not yet available
----------2FFF00-----------------------------
INT 2F - Multiplex - Topware Network Operating System - INSTALLATION CHECK
	AX = FF00h
Return: AL = 00h not installed, OK to install
	   = 01h not installed, not OK to install
	   = FFh installed
----------2FFF01-----------------------------
INT 2F - Multiplex - Topware Network Operating System - GET VERSION
	AX = FF01h
Return: AX = version
----------30---------------------------------
INT 30 - (NOT A VECTOR!) FAR JMP instruction for CP/M-style calls
   the CALL 5 entry point does a FAR jump to here
Note:	under DOS 2+, the instruction at PSP:0005 points two bytes too low in
	  memory
SeeAlso: INT 21/AH=26h
----------31---------------------------------
INT 31 - overwritten by CP/M jump instruction in INT 30
----------310000-----------------------------
INT 31 - DOS Prot-Mode Interface 0.9 API - protected mode - ALLOCATE LDT DESCRS
	AX = 0000h
	CX = number of descriptors to allocate
Return: CF set on error
	CF clear if successful
	    AX = base selector
Notes:	the base and limit of the returned descriptors will be 0
	add the value returned by INT 31/AX=0003h to move to subsequent
	  descriptors if multiple descriptors were allocated
SeeAlso: AX=0001h,AX=000Dh
----------310001-----------------------------
INT 31 - DPMI 0.9 API - protected mode - FREE LDT DESCRIPTOR
	AX = 0001h
	BX = selector to free
Return: CF set on error
	CF clear if successful
Notes:	only one descriptor is freed per call
	the program's initial CS, DS, and SS descriptors may be freed
SeeAlso: AX=0000h,AX=000Ah,AX=000Dh
----------310002-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SEGMENT TO DESCRIPTOR
	AX = 0002h
	BX = real mode segment
Return: CF set on error
	CF clear if successful
	    AX = selector corresponding to real mode segment (64K limit)
Notes:	multiple calls for the same real mode segment return the same selector
	the returned descriptor should never be modified or freed
----------310003-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET NEXT SELECTOR INCREMENT VALUE
	AX = 0003h
Return: CF clear
	    AX = value to add to get next sequential selector
Note:	the increment will be a power of two
----------310004-----------------------------
INT 31 - DPMI 0.9 API - protected mode - RESERVED
	AX = 0004h
----------310005-----------------------------
INT 31 - DPMI 0.9 API - protected mode - RESERVED
	AX = 0005h
----------310006-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET SEGMENT BASE ADDRESS
	AX = 0006h
	BX = selector
Return: CF set on error
	CF clear if successful
	    CX:DX = linear base address of segment
SeeAlso: AX=0007h
----------310007-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SET SEGMENT BASE ADDRESS
	AX = 0007h
	BX = selector
	CX:DX = linear base address
Return: CF set on error
	CF clear if successful
Notes:	only modify descriptors allocated with INT 31/AX=0000h
	only the low 24 bits of the address will be used by 16-bit DPMI
	  implementations even on a 386 or higher
SeeAlso: AX=0006h,AX=0008h,AX=0009h,AX=000Ch
----------310008-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SET SEGMENT LIMIT
	AX = 0008h
	BX = selector
	CX:DX = segment limit
Return: CF set on error
	CF clear if successful
Notes:	CX must be zero for 16-bit DPMI implementations
	limits greater than 1MB must be page aligned (low 12 bits set)
	only modify descriptors allocated with INT 31/AX=0000h
SeeAlso: AX=0007h,AX=0009h,AX=000Ch
----------310009-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SET DESCRIPTOR ACCESS RIGHTS
	AX = 0009h
	BX = selector
	CL = access rights/type byte
	CH = 80386 extended rights/type byte (32-bit DPMI implementations only)
Return: CF set on error
	CF clear if successful
SeeAlso: AX=0007h,AX=0008h,AX=000Ch
----------31000A-----------------------------
INT 31 - DPMI 0.9 API - protected mode - CREATE CODE SEGMENT ALIAS DESCRIPTOR
	AX = 000Ah
	BX = code segment selector
Return: CF set on error
	CF clear if successful
	    AX = new data selector
Notes:	fails if selector in BX is not a code segment or is invalid
	use INT 31/AX=0001h to free new selector
	future changes to the code segment will not be reflected in the data
	  segment
SeeAlso: AX=0001h
----------31000B-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET DESCRIPTOR
	AX = 000Bh
	BX = selector
	ES:DI / ES:EDI -> 8-byte buffer for copy of descriptor
Return: CF set on error
	CF clear if successful
Note:	16-bit programs use ES:DI as pointer, 32-bit must use ES:EDI
SeeAlso: AX=000Ch
----------31000C-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SET DESCRIPTOR
	AX = 000Ch
	BX = selector
	ES:DI / ES:EDI -> 8-byte buffer containing descriptor
Return: CF set on error
	CF clear if successful
Notes:	16-bit programs use ES:DI as pointer, 32-bit must use ES:EDI
	only modify descriptors allocated with INT 31/AX=0000h
SeeAlso: AX=000Bh
----------31000D-----------------------------
INT 31 - DPMI 0.9 API - protected mode - ALLOCATE SPECIFIC LDT DESCRIPTOR
	AX = 000Dh
	BX = selector
Return: CF set on error
	CF clear if successful
	    descriptor allocated
Notes:	free descriptor with INT 31/AX=0001h
	16 descriptors are reserved for this function, but some may already be
	  in use by other applications
SeeAlso: AX=0000h,AX=0001h
----------310100-----------------------------
INT 31 - DPMI 0.9 API - protected mode - ALLOCATE DOS MEMORY BLOCK
	AX = 0100h
	BX = number of paragraphs to allocate
Return: CF set on error
	    AX = DOS error code (07h,08h) (see INT 21/AH=59h)
	    BX = size (in paragraphs) of largest available block
	CF clear if successful
	    AX = real mode segment of allocated block
	    DX = first selector for allocated block
Notes:	multiple contiguous selectors are allocated for blocks of more than 64K
	never modify or deallocate returned descriptors
SeeAlso: AX=0101h,AX=0501h
----------310101-----------------------------
INT 31 - DPMI 0.9 API - protected mode - FREE DOS MEMORY BLOCK
	AX = 0101h
	DX = selector of block
Return: CF set on error
	    AX = DOS error code (07h,09h) (see INT 21/AH=59h)
	CF set if successful
SeeAlso: AX=0100h,AX=0102h,AX=0502h
Note:	all descriptors allocated for the block are automatically freed
----------310102-----------------------------
INT 31 - DPMI 0.9 API - protected mode - RESIZE DOS MEMORY BLOCK
	AX = 0102h
	BX = new block size in paragraphs
	DX = selector of block
Return: CF set on error
	    AX = DOS error code (07h,08h,09h) (see INT 21/AH=59h)
	    BX = maximum block size (in paragraphs) possible
	CF clear if successful
Notes:	increasing the size of a block past a 64K boundary will fail if the
	  next descriptor in the LDT is already in use
	shrinking a block past a 64K boundary will cause some selectors to be
	  freed
SeeAlso: AX=0100h
----------310200-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET REAL MODE INTERRUPT VECTOR
	AX = 0200h
	BL = interrupt number
Return: CF clear
	CX:DX = segment:offset of real mode interrupt handler
Note:	the DPMI implementation is required to support all 256 vectors
SeeAlso: AX=0201h,AX=0204h
----------310201-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SET REAL MODE INTERRUPT VECTOR
	AX = 0201h
	BL = interrupt number
	CX:DX = segment:offset of real mode handler
Return: CF set on error
	CF clear if successful
Note:	all memory that may be touched by a hardware interrupt handler must be
	  locked down with INT 31/AX=0600h	
SeeAlso: AX=0200h,AX=0205h,AX=0600h
----------310202-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET PROCESSOR EXCEPTION HANDLER VECTOR
	AX = 0202h
	BL = exception number (00h-1Fh)
Return: CF set on error
	CF clear if successful
	    CX:DX / CX:EDX = selector:offset of handler
Note:	16-bit programs receive the pointer in CX:DX, 32-bit programs in CX:EDX
SeeAlso: AX=0203h
----------310203-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SET PROCESSOR EXCEPTION HANDLER VECTOR
	AX = 0203h
	BL = exception number (00h-1Fh)
	CX:DX / CX:EDX = selector:offset of handler
Return: CF set on error
	CF clear if successful
Notes:	32-bit programs must supply an offset in EDX and use a 32-bit interrupt
	  stack frame on chaining to the next exception handler
	the handler should return using a FAR return
	all fault stack frames contain an error code, but it is only valid for
	  exceptions 08h and 0Ah-0Eh
	handlers will only be called if the exception occurs in protected mode
	the handler may change certain values on the stack frame (see below)
SeeAlso: AX=0202h

Format of stack frame for 16-bit programs: (offset from SS:SP)
Offset	Size	Description
 00h	DWORD	return CS:IP (do not change)
 04h	WORD	error code
 06h	DWORD	CS:IP of exception
 0Ah	WORD	flags
 0Ch	DWORD	SS:SP

Format of stack frame for 32-bit programs: (offset from SS:ESP)
Offset	Size	Description
 00h	DWORD	return EIP (do not change)
 04h	WORD	return CS selector (do not change)
 06h	WORD	reserved (do not change)
 08h	DWORD	error code
 0Ch	DWORD	EIP of exception
 10h	WORD	CS selector of exception
 12h	WORD	reserved (do not change)
 14h	DWORD	EFLAGS
 18h	DWORD	ESP
 1Ch	WORD	SS
 1Eh	WORD	reserved (do not change)
----------310204-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET PROTECTED MODE INTERRUPT VECTOR
	AX = 0204h
	BL = interrupt number
Return: CF set on error
	CF clear if successful
	    CX:DX / CX:EDX = selector:offset of handler
Notes:	16-bit programs use CX:DX, 32-bit programs use CX:EDX
	DPMI implementations are required to support all 256 vectors
SeeAlso: AX=0200h,AX=0205h
----------310205-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SET PROTECTED MODE INTERRUPT VECTOR
	AX = 0205h
	BL = interrupt number
	CX:DX / CX:EDX = selector:offset of handler
Return: CF set on error
	CF clear if successful
Notes:	16-bit programs use CX:DX, 32-bit programs use CX:EDX
	32-bit programs must use a 32-bit interrupt stack frame when chaining
	  to the next handler
	DPMI implementations are required to support all 256 vectors
----------310300-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SIMULATE REAL MODE INTERRUPT
	AX = 0300h
	BL = interrupt number
	BH = flags
	    bit 0: reset the interrupt controller and A20 line
	    others must be 0
	CX = number of words to copy from protected mode to real mode stack
	ES:DI / ES:EDI = selector:offset of real mode call structure
			(see below)
Return: CF set on error
	CF clear if successful
	    real mode call structure modified (all fields except SS:SP, CS:IP
	      filled with return values from real mode interrupt)
	protected mode stack unchanged
Notes:	16-bit programs use ES:DI as pointer, 32-bit programs use ES:EDI
	CS:IP in the real mode call structure is ignored for this call,
	  instead, the indicated interrupt vector is used for the address
	the flags in the call structure are pushed on the real mode stack to
	  form an interrupt stack frame, and the trace and interrupt flags are
	  clear on entry to the handler
	DPMI will provide a small (30 words) real mode stack if SS:SP is zero
	the real mode handler must return with the stack in the same state as
	  it was on being called
SeeAlso: AX=0302h

Format of real mode call structure:
Offset	Size	Description
 00h	DWORD	EDI
 04h	DWORD	ESI
 08h	DWORD	EBP
 0Ch	DWORD	reserved
 10h	DWORD	EBX
 14h	DWORD	EDX
 18h	DWORD	ECX
 1Ch	DWORD	EAX
 20h	WORD	flags
 22h	WORD	ES
 24h	WORD	DS
 26h	WORD	FS
 28h	WORD	GS
 2Ah	WORD	IP
 2Ch	WORD	CS
 2Eh	WORD	SP
 30h	WORD	SS
----------310301-----------------------------
INT 31 - DPMI 0.9 API - protected mode - CALL REAL MODE PROC WITH FAR RET FRAME
	AX = 0301h
	BH = flags
	    bit 0: reset the interrupt controller and A20 line
	    others must be 0
	CX = number of words to copy from protected mode to real mode stack
	ES:DI / ES:EDI = selector:offset of real mode call structure
			(see INT 31/AX=0300h)
Return: CF set on error
	CF clear if successful
	    real mode call structure modified (all fields except SS:SP, CS:IP
	      filled with return values from real mode interrupt)
	protected mode stack unchanged
Notes:	16-bit programs use ES:DI as pointer, 32-bit programs use ES:EDI
	the real mode procedure must exit with a FAR return
	DPMI will provide a small (30 words) real mode stack if SS:SP is zero
	the real mode handler must return with the stack in the same state as
	  it was on being called
SeeAlso: AX=0302h
----------310302-----------------------------
INT 31 - DPMI 0.9 API - protected mode - CALL REAL MODE PROC WITH IRET FRAME
	AX = 0302h
	BH = flags
	    bit 0: reset the interrupt controller and A20 line
	    others must be 0
	CX = number of words to copy from protected mode to real mode stack
	ES:DI / ES:EDI = selector:offset of real mode call structure
			(see INT 31/AX=0300h)
Return: CF set on error
	CF clear if successful
	    real mode call structure modified (all fields except SS:SP, CS:IP
	      filled with return values from real mode interrupt)
	protected mode stack unchanged
Notes:	16-bit programs use ES:DI as pointer, 32-bit programs use ES:EDI
	the flags in the call structure are pushed on the real mode stack to
	  form an interrupt stack frame, and the trace and interrupt flags are
	  clear on entry to the handler
	the real mode procedure must exit with an IRET
	DPMI will provide a small (30 words) real mode stack if SS:SP is zero
	the real mode handler must return with the stack in the same state as
	  it was on being called
SeeAlso: AX=0300h
----------310303-----------------------------
INT 31 - DPMI 0.9 API - protected mode - ALLOCATE REAL MODE CALL-BACK ADDRESS
	AX = 0303h
	DS:SI / DS:ESI = selector:offset of procedure to call
	ES:DI / ES:EDI = selector:offset of real mode call structure
			(see AX=0300h)
Return: CF set on error
	CF clear if successful
	    CX:DX = segment:offset of real mode call address
Notes:	the real mode call structure is static, causing reentrancy problems
	the called procedure must modify the real mode CS:IP before returning
	values are returned to real mode by modifying the real mode call struc
	DPMI hosts should provide for at least 16 call-backs per task
SeeAlso: AX=0304h

Values call-back procedure is called with:
	DS:SI / DS:ESI = selector:offset of real mode SS:SP
	ES:DI / ES:EDI = selector:offset of real mode call structure
	SS:SP / SS:ESP = locked protected omde API stack
	interrupts disabled
Return: (with IRET)
	ES:DI / ES:EDI = selector:offset of real mode call structure to restore
----------310304-----------------------------
INT 31 - DPMI 0.9 API - protected mode - FREE REAL MODE CALL-BACK ADDRESS
	AX = 0304h
	CX:DX = real mode call-back address
Return: CF set on error
	CF clear if successful
SeeAlso: AX=0303h
----------310305-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET STATE SAVE/RESTORE ADDRESSES
	AX = 0305h
Return: CF set on error
	CF clear if successfule
	    AX = size in bytes of state buffer
	    BX:CX = real mode address of procedure to save/restore state
	    SI:DI / SI:EDI = protected mode procedure to save/restore state
Notes:	the buffer size will be zero if it is not necessary to preserve state
	16-bit programs should call SI:DI, 32-bit programs should call SI:EDI
	this function is only needed if using the raw mode switch service
SeeAlso: AX=0306h

Values to call state-save procedures with:
	AL = direction
	    00h save state
	    01h restore state
	ES:DI / ES:EDI -> state buffer
Return: all registers preserved
----------310306-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET RAW MODE SWITCH ADDRESSES
	AX = 0306h
Return: CF set on error
	CF clear if successful
	    BX:CX -> procedure to switch from real to protected mode
	    SI:DI / SI:EDI -> procedure to switch from protected to real mode
Notes:	16-bit programs should jump to SI:DI, 32-bit programs should use SI:EDI
	the caller must save and restore the state of the task with AX=0305h
SeeAlso: AX=0305h

Values to JUMP at mode-switch procedures with:
	AX = new DS
	CX = new ES
	DX = new SS
	BX / EBX = new SP / ESP
	SI = new CS
	DI / EDI = new IP / EIP
Note:	BP/EBP is preserved across the call, but AX/EAX, BX/EBX, CX/ECX,
	  DX/EDX, SI/ESI, and DI/EDI will be undefined
----------310400-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET DPMI VERSION
	AX = 0400h
Return: CF clear
	AH = major version
	AL = minor version
	BX = flags
	    bit 0: running under an 80386 implementation
	    bit 1: processor returns to real mode for reflected interrupts
		   instead of V86 mode
	    bit 2: virtual memory supported
	    bit 3: reserved (undefined)
	    others reserved (zero)
	CL = processor type (02h=80286, 03h=80386, 04h=80486)
	DH = curr value of virtual master interrupt controller base interrupt
	DL = curr value of virtual slave interrupt controller base interrupt
----------310500-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET FREE MEMORY INFORMATION
	AX = 0500h
	ES:DI / ES:EDI -> buffer for memory information (see below)
Return: CF clear
Notes:	16-bit programs use ES:DI, 32-bit programs use ES:EDI
	this function must be considered advisory because other applications
	  may affect the results at any time after the call
	fields not supported by the DPMI implementation are filled with
	  FFFFFFFFh
SeeAlso: AX=0501h, AX=0604h

Format of memory information:
Offset	Size	Description
 00h	DWORD	largest available block in bytes
 04h	DWORD	maximum unlocked page allocation
 08h	DWORD	maximum locked page allocation
 0Ch	DWORD	linear address space in pages
 10h	DWORD	total unlocked pages
 14h	DWORD	free pages
 18h	DWORD	total physical pages
 1Ch	DWORD	free linear address space in pages
 20h	DWORD	size of paging file/partition in pages
 24h 12 BYTEs	reserved
----------310501-----------------------------
INT 31 - DPMI 0.9 API - protected mode - ALLOCATE MEMORY BLOCK
	AX = 0501h
	BX:CX = size in bytes
Return: CF set on error
	CF clear if successful
	    BX:CX = linear address of block
	    SI:DI = memory block handle
Notes:	no selectors are allocated
	the memory block is allocated unlocked
	allocations are often page granular
SeeAlso: AX=0000h, AX=0100h, AX=0500h, AX=0502h, AX=0503h
----------310502-----------------------------
INT 31 - DPMI 0.9 API - protected mode - FREE MEMORY BLOCK
	AX = 0502h
	SI:DI = handle of memory block
Return: CF set on error
	CF clear if successful
Note:	any selectors allocated for the memory block must also be freed
SeeAlso: AX=0001h, AX=0101h, AX=0501h
----------310503-----------------------------
INT 31 - DPMI 0.9 API - protected mode - RESIZE MEMORY BLOCK
	AX = 0503h
	BX:CX = new size in bytes
	SI:DI = handle of memory block
Return: CF set on error
	CF clear if successful
	    BX:CX = new linear address
	    SI:DI = new handle of memory block
Note:	any selectors pointing at the block must be updated
	an error is returned if the new size is 0
SeeAlso: AX=0102h, AX=0501h
----------310600-----------------------------
INT 31 - DPMI 0.9 API - protected mode - LOCK LINEAR REGION
	AX = 0600h
	BX:CX = starting linear address
	SI:DI = size of region in bytes
Return: CF set on error
	    none of the memory is locked
	CF clear if successful
Note:	pages at beginning and end will be locked if the region overlaps them
SeeAlso: AX=0601h
----------310601-----------------------------
INT 31 - DPMI 0.9 API - protected mode - UNLOCK LINEAR REGION
	AX = 0601h
	BX:CX = starting linear address
	SI:DI = size of region in bytes
Return: CF set on error
	    none of the memory is unlocked
	CF clear if successful
Notes:	pages at beginning and end will be unlocked if the region overlaps them
	memory whose lock count has not reached zero remains locked
SeeAlso: AX=0600h
----------310602-----------------------------
INT 31 - DPMI 0.9 API - protected mode - MARK REAL MODE REGION AS PAGEABLE
	AX = 0602h
	BX:CX = starting linear address
	SI:DI = size of region in bytes
Return: CF set on error	
	    none of the memory is made pageable
	CF clear if successful
Notes:	relock all unlocked real mode memory before terminating process
	pages at beginning and end will be unlocked if the region overlaps them
	pageability of real mode pages is binary, not a count
SeeAlso: AX=0600h,AX=0603h
----------310603-----------------------------
INT 31 - DPMI 0.9 API - protected mode - RELOCK REAL MODE REGION
	AX = 0603h
	BX:CX = starting linear address
	SI:DI = size of region in bytes
Return: CF set on error	
	    none of the memory is relocked
	CF clear if successful
Note:	pages at beginning and end will be relocked if the region overlaps them
SeeAlso: AX=0602h
----------310604-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET PAGE SIZE
	AX = 0604h
Return: CF set on error
	CF clear if successful
	    BX:CX = page size in bytes
----------310700-----------------------------
INT 31 - DPMI 0.9 API - protected mode - RESERVED
	AX = 0700h
----------310701-----------------------------
INT 31 - DPMI 0.9 API - protected mode - RESERVED
	AX = 0701h
----------310702-----------------------------
INT 31 - DPMI 0.9 API - protected mode - MARK PAGE AS DEMAND PAGING CANDIDATE
	AX = 0702h
	BX:CX = starting linear address
	SI:DI = number of bytes to mark as paging candidates
Return: CF set on error
	CF clear if successful
Notes:	this function is advisory, and does not force immediate paging
	partial pages will not be discarded
SeeAlso: AX=0703h
----------310703-----------------------------
INT 31 - DPMI 0.9 API - protected mode - DISCARD PAGE CONTENTS
	AX = 0703h
	BX:CX = starting linear address
	SI:DI = number of bytes to mark as paging candidates
Return: CF set on error
	CF clear if successful
Notes:	this function is advisory, and may be ignored by DPMI implementations
	partial pages will not be discarded
SeeAlso: AX=0702h
----------310800-----------------------------
INT 31 - DPMI 0.9 API - protected mode - PHYSICAL ADDRESS MAPPING
	AX = 0800h
	BX:CX = physical address
	SI:DI = size in bytes
Return: CF set on error
	CF clear if successful
	    BX:CX = linear address which maps the requested physical memory
Notes:	implementations may refuse this call because it can circumvent protects
	the caller must build an appropriate selector for the memory
	do not use for memory mapped in the first megabyte
----------310900-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET AND DISABLE VIRTUAL INTERRPT STATE
	AX = 0900h
Return: CF clear
	virtual interrupts disabled
	AL = 00h if previously disabled
	   = 01h if previously enabled
	AH preserved
Note:	the previous state may be restored simply by executing an INT 31
SeeAlso: AX=0901h,AX=0902h
----------310901-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET AND ENABLE VIRTUAL INTERRUPT STATE
	AX = 0901h
Return: CF clear
	virtual interrupts enabled
	AL = 00h if previously disabled
	   = 01h if previously enabled
	AH preserved
Note:	the previous state may be restored simply by executing an INT 31
SeeAlso: AX=0900h, AX=0902h
----------310902-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET VIRTUAL INTERRUPT STATE
	AX = 0902h
Return: CF clear
	AL = 00h if disabled
	   = 01h if enabled
SeeAlso: AX=0900h, AX=0901h
----------310A00-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET VENDOR SPECIFIC API ENTRY POINT
	AX = 0A00h
	DS:SI / DS:ESI -> case-sensitive ASCIZ vendor name or identifier
Return: CF set on error
	CF clear if successful
	    ES:DI / ES:EDI -> FAR extended API entry point
	    DS, FS, GS, EAX, EBX, ECX, EDX, ESI, EBP destroyed
Note:	extended API parameters are vendor-specific
----------310B00-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SET DEBUG WATCHPOINT
	AX = 0B00h
	BX:CX = linear address
	DL = size (1,2,4 bytes)
	DH = type (00h execute, 01h write, 02h read/write)
Return: CF set on error
	CF clear if successful
	    BX = watchpoint handle
SeeAlso: AX=0601h
----------310B01-----------------------------
INT 31 - DPMI 0.9 API - protected mode - CLEAR DEBUG WATCHPOINT
	AX = 0B01h
	BX = watchpoint handle
Return: CF set on error
	CF clear if successful
Note:	the watchpoint handle is freed
SeeAlso: AX=0B00h
----------310B02-----------------------------
INT 31 - DPMI 0.9 API - protected mode - GET STATE OF DEBUG WATCHPOINT
	AX = 0B02h
	BX = watchpoint handle
Return: CF set on error
	CF clear if successful
	    AX = status flags
		bit 0: watch point has been executed since AX=0B00h or AX=0B03h
SeeAlso: AX=0B00h, AX=0B03h
----------310B03-----------------------------
INT 31 - DPMI 0.9 API - protected mode - RESET DEBUG WATCHPOINT
	AX = 0B03h
	BX = watchpoint handle
Return: CF set on error
	CF clear if successful
SeeAlso: AX=0B02h
----------32---------------------------------
INT 32 - reportedly used by "Tiny" Viruses
SeeAlso: INT 60"Virus"
----------330000-----------------------------
INT 33 - MS MOUSE - RESET DRIVER AND READ STATUS
	AX = 0000h
Return: AX = status
	    0000h hardware/driver not installed
	    FFFFh hardware/driver installed
	BX = number of buttons
	    FFFFh two buttons
	    0000h other than two
	    0003h Mouse Systems/Logitech mouse
Notes:	to use mouse on a Hercules-compatible monographics card in graphics
	  mode, you must first set 0040h:0049h to 6 for page 0 or 5 for page 1,
	  and then call this function.
	the Logitech mouse driver contains the signature string "LOGITECH"
SeeAlso: INT 74
----------330001-----------------------------
INT 33 - MS MOUSE - SHOW MOUSE CURSOR
	AX = 0001h
SeeAlso: AX=0002h, INT 16/AX=FFFEh
----------330002-----------------------------
INT 33 - MS MOUSE - HIDE MOUSE CURSOR
	AX = 0002h
Note:	multiple calls to hide the cursor will require multiple calls to
	  function 01h to unhide it.
SeeAlso: AX=0001h, INT 16/AX=FFFFh
----------330003-----------------------------
INT 33 - MS MOUSE - RETURN POSITION AND BUTTON STATUS
	AX = 0003h
Return: BX = button status
	   bit 0  left button pressed if 1
	   bit 1  right button pressed if 1
	   bit 2  middle button pressed if 1 (Mouse Systems/Logitech mouse)
	CX = column
	DX = row
SeeAlso: AX=0004h
----------330004-----------------------------
INT 33 - MS MOUSE - POSITION MOUSE CURSOR
	AX = 0004h
	CX = column
	DX = row
Note:	the row and column are truncated to the next lower multiple of the cell
	  size; however, some versions of the Microsoft documentation
	  incorrectly state that the coordinates are rounded
SeeAlso: AX=0003h
----------330005-----------------------------
INT 33 - MS MOUSE - RETURN BUTTON PRESS DATA
	AX = 0005h
	BX = button
	    0000h left
	    0001h right
	    0002h middle (Mouse Systems/Logitech mouse)
Return: AX = button states
	    bit 0 left button pressed if 1
	    bit 1 right button pressed if 1
	    bit 2 middle button pressed if 1 (Mouse Systems/Logitech mouse)
	BX = number of times specified button has been pressed since last call
	CX = column at time specified button was last pressed
	DX = row at time specified button was last pressed
SeeAlso: AX=0006h
----------330006-----------------------------
INT 33 - MS MOUSE - RETURN BUTTON RELEASE DATA
	AX = 0006h
	BX = button
	    0000h left
	    0001h right
	    0002h middle (Mouse Systems/Logitech mouse)
Return: AX = button states
	    bit 0 left button pressed if 1
	    bit 1 right button pressed if 1
	    bit 2 middle button pressed if 1 (Mouse Systems/Logitech mouse)
	BX = number of times specified button has been released since last call
	CX = column at time specified button was last released
	DX = row at time specified button was last released
SeeAlso: AX=0005h
----------330007-----------------------------
INT 33 - MS MOUSE - DEFINE HORIZONTAL CURSOR RANGE
	AX = 0007h
	CX = minimum column
	DX = maximum column
SeeAlso: AX=0008h
----------330008-----------------------------
INT 33 - MS MOUSE - DEFINE VERTICAL CURSOR RANGE
	AX = 0008h
	CX = minimum row
	DX = maximum row
SeeAlso: AX=0007h
----------330009-----------------------------
INT 33 - MS MOUSE - DEFINE GRAPHICS CURSOR
	AX = 0009h
	BX = column of cursor hot spot in bitmap (-16 to 16)
	CX = row of cursor hot spot (-16 to 16)
	ES:DX -> bitmap
		16 words screen mask
		16 words cursor mask
		    each word defines the sixteen pixels of a row, low bit
		    rightmost
SeeAlso: AX=000Ah
----------33000A-----------------------------
INT 33 - MS MOUSE - DEFINE TEXT CURSOR
	AX = 000Ah
	BX = hardware/software text cursor
	    0000h software
		CX = screen mask
		DX = cursor mask
	    0001h hardware
		CX = start scan line
		DX = end scan line
Note:	when the software cursor is selected, the char/attribute data at the
	  current screen position is ANDed with the screen mask and then XORed
	  with the cursor mask
SeeAlso: AX=0009h
----------33000B-----------------------------
INT 33 - MS MOUSE - READ MOTION COUNTERS
	AX = 000Bh
Return: CX = number of mickeys mouse moved horizontally since last call
	DX = number of mickeys mouse moved vertically
Notes:	a mickey is the smallest increment the mouse can sense
	positive values indicate down/right
----------33000C-----------------------------
INT 33 - MS MOUSE - DEFINE INTERRUPT SUBROUTINE PARAMETERS
	AX = 000Ch
	CX = call mask
	     bit 0 call if mouse moves
	     bit 1 call if left button pressed
	     bit 2 call if left button released
	     bit 3 call if right button pressed
	     bit 4 call if right button released
	     bit 5 call if middle button pressed (Mouse Systems/Logitech mouse)
	     bit 6 call if middle button released (Mouse Sys/Logitech mouse)
	ES:DX -> FAR routine
Notes:	when the subroutine is called, it is passed the following values:
	  AX = condition mask (same bit assignments as call mask)
	  BX = button state
	  CX = cursor column
	  DX = cursor row
	  SI = horizontal mickey count
	  DI = vertical mickey count
	some versions of the Microsoft documentation incorrectly state that CX
	  bit 0 means call if mouse cursor moves, and swap the meanings of SI
	  and DI
----------33000D-----------------------------
INT 33 - MS MOUSE - LIGHT PEN EMULATION ON
	AX = 000Dh
SeeAlso: AX=000Eh
----------33000E-----------------------------
INT 33 - MS MOUSE - LIGHT PEN EMULATION OFF
	AX = 000Eh
SeeAlso: AX=000Dh
----------33000F-----------------------------
INT 33 - MS MOUSE - DEFINE MICKEY/PIXEL RATIO
	AX = 000Fh
	CX = number of mickeys per 8 pixels horizontally (default 8)
	DX = number of mickeys per 8 pixels vertically (default 16)
----------330010-----------------------------
INT 33 - MS MOUSE - DEFINE SCREEN REGION FOR UPDATING
	AX = 0010h
	CX,DX = X,Y coordinates of upper left corner
	SI,DI = X,Y coordinates of lower right corner
Note:	mouse cursor is hidden during updating, and needs to be explicitly
	  turned on again
----------330012-----------------------------
INT 33 - MS MOUSE - SET LARGE GRAPHICS CURSOR BLOCK
	AX = 0012h
	BH = cursor width in words
	CH = rows in cursor
	BL = horizontal hot spot (-16 to 16)
	CL = vertical hot spot (-16 to 16)
	ES:DX -> bit map of screen and cursor maps
Return: AX = FFFFh if successful
----------330013-----------------------------
INT 33 - MS MOUSE - DEFINE DOUBLE-SPEED THRESHOLD
	AX = 0013h
	DX = threshold speed in mickeys/second, 0000h = default of 64/second
Note:	if speed exceeds threshold, the cursor's on-screen motion is doubled
----------330014-----------------------------
INT 33 - MS MOUSE - EXCHANGE INTERRUPT SUBROUTINES
	AX = 0014h
	CX = call mask (see AX=000Ch)
	ES:DX -> FAR routine 
Return: CX = call mask of previous interrupt routine
	ES:DX = FAR address of previous interrupt routine
----------330015-----------------------------
INT 33 - MS MOUSE - RETURN DRIVER STORAGE REQUIREMENTS
	AX = 0015h
Return: BX = size of buffer needed to store driver state
----------330016-----------------------------
INT 33 - MS MOUSE - SAVE DRIVER STATE
	AX = 0016h
	ES:DX -> buffer for driver state
SeeAlso: AX=0017h
----------330017-----------------------------
INT 33 - MS MOUSE - RESTORE DRIVER STATE
	AX = 0017h
	ES:DX -> buffer containing saved state
SeeAlso: AX=0016h
----------330018-----------------------------
INT 33 - MS MOUSE - SET ALTERNATE MOUSE USER HANDLER
	AX = 0018h
	CX = call mask
	     bit 0 call if alt key pressed during event
	     bit 1 call if ctrl key pressed during event
	     bit 2 call if shift button pressed during event
	     bit 3 call if right button released
	     bit 4 call if right button pressed
	     bit 5 call if left button released
	     bit 6 call if left button pressed
	     bit 7 call if mouse moves
	ES:DX = address of FAR routine
Return: AX = 0018h if successful
	   = FFFFh on error
Notes:	when the subroutine is called, it is passed the following values:
	  AX = condition mask (same bit assignments as call mask)
	  BX = button state
	  CX = cursor column
	  DX = cursor row
	  DI = horizontal mickey count
	  SI = vertical mickey count
	up to three handlers can be defined by separate calls to this function
----------330019-----------------------------
INT 33 - MS MOUSE - RETURN USER ALTERNATE INTERRUPT VECTOR
	AX = 0019h
	CX = call mask
Return: BX:DX = user interrupt vector
	CX = call mask (0 if not found)
Note:	attempts to find a user event handler (defined by function 18h)
	  whose call mask matches CX
----------33001A-----------------------------
INT 33 - MS MOUSE - SET MOUSE SENSITIVITY
	AX = 001Ah
	BX = horizontal speed \
	CX = vertical speed   / (see AX=000Fh)
	DX = double speed threshold (see AX=0013h)
SeeAlso: AX=001Bh
----------33001B-----------------------------
INT 33 - MS MOUSE - RETURN MOUSE SENSITIVITY
	AX = 001Bh
Return: BX = horizontal speed
	CX = vertical speed
	DX = double speed threshold
SeeAlso: AX=001Ah
----------33001C-----------------------------
INT 33 - MS MOUSE - SET INTERRUPT RATE
	AX = 001Ch
	BX = rate
	    00h no interrupts allowed
	    01h 30 per second
	    02h 50 per second
	    03h 100 per second
	    04h 200 per second
Notes:	only available on InPort mouse
	values greater than 4 may cause unpredictable driver behavior
----------33001D-----------------------------
INT 33 - MS MOUSE - DEFINE DISPLAY PAGE NUMBER
	AX = 001Dh
	BX = display page number
Note:	the cursor will be displayed on the specified page
----------33001E-----------------------------
INT 33 - MS MOUSE - RETURN DISPLAY PAGE NUMBER
	AX = 001Eh
Return: BX = display page number
----------33001F-----------------------------
INT 33 - MS MOUSE - DISABLE MOUSE DRIVER
	AX = 001Fh
Return: AX = 001Fh successful
	     FFFFh unsuccessful
	ES:BX = vector for INT 33h before mouse driver was first installed
Note:	restores vectors for Int 10h and Int 71h (8086) or Int 74h (286/386)
	if you restore Int 33h to ES:BX, driver will be completely disabled
----------330020-----------------------------
INT 33 - MS MOUSE - ENABLE MOUSE DRIVER
	AX = 0020h
Note:	restores vectors for Int 10h and Int 71h (8086) or Int 74h (286/386)
	  which were removed by function 1Fh
----------330021-----------------------------
INT 33 - MS MOUSE - SOFTWARE RESET
	AX = 0021h
Return: AX = FFFFh if mouse driver installed
	     0021h if mouse driver not installed
	BX = 2 if mouse driver is installed
Note:	identical to funtion 00h, but does not reset the mouse
----------330022-----------------------------
INT 33 - MS MOUSE - SET LANGUAGE FOR MESSAGES
	AX = 0022h
	BX = language
	    00h English
	    01h French
	    02h Dutch
	    03h German
	    04h Swedish
	    05h Finnish
	    06h Spanish
	    07h Portugese
	    08h Italian
Note:	only available on international versions of the driver, US versions
	  ignore this call
SeeAlso: AX=0023h
----------330023-----------------------------
INT 33 - MS MOUSE - GET LANGUAGE FOR MESSAGES
	AX = 0023h
Return:	BX = language (see AX=0022h)
Note:	the US version of the driver always returns zero 
SeeAlso: AX=0022h
----------330024-----------------------------
INT 33 - MS MOUSE - GET SOFTWARE VERSION AND MOUSE TYPE
	AX = 0024h
Return: AX = FFFFh on error
	otherwise,
	    BH = major version
	    BL = minor version
	    CH = type (1=bus, 2=serial, 3=InPort, 4=PS/2, 5=HP)
	    CL = interrupt (0=PS/2, 2=IRQ2, 3=IRQ3,...,7=IRQ7)
----------330042-----------------------------
INT 33 - PCMOUSE - GET MSMOUSE STORAGE REQUIREMENTS
	AX = 0042h
Return: AX = FFFFh successful
		BX = buffer size in bytes for functions 50h and 52h
	   = 0000h MSMOUSE not installed
	   = 0042h functions 42h, 50h, and 52h not supported
SeeAlso: AX=0050h
----------33004D-----------------------------
INT 33 - LOGITECH - RETURN POINTER TO MICROSOFT COPYRIGHT
	AX = 004Dh
Return: ES:DI -> "Copyright 1983 Microsoft ***"
----------330050-----------------------------
INT 33 - PCMOUSE - SAVE MSMOUSE STATE
	AX = 0050h
	BX = buffer size
	ES:DX -> buffer
Return: AX = FFFFh if successful
SeeAlso: AX=0042h,0052h
----------330052-----------------------------
INT 33 - PCMOUSE - RESTORE MSMOUSE STATE
	AX = 0052h
	BX = buffer size
	ES:DX -> buffer
Return: AX = FFFFh if successful
SeeAlso: AX=0050h
----------33006D-----------------------------
INT 33 - LOGITECH - ???
	AX = 006Dh
Return: ES:DI -> 06 02 40 08
----------331D6C-----------------------------
INT 33 - LOGITECH - GET COMPASS PARAMETER
	AX = 1D6Ch
Return: BX = direction (0=north, 1=south, 2=east, 3=west)
SeeAlso: AX=1E6Ch
----------331E6C-----------------------------
INT 33 - LOGITECH - SET COMPASS PARAMETER
	AX = 1E6Ch
	BX = direction (0=north, 1=south, 2=east, 3=west)
SeeAlso: AX=1D6Ch
----------331F6C-----------------------------
INT 33 - LOGITECH - GET BALLISTICS INFORMATION
	AX = 1F6Ch
Return: BX = 0=off, 1=on
	CX = 1=low, 2=high
SeeAlso: AX=236Ch
----------33206C-----------------------------
INT 33 - LOGITECH - SET LEFT OR RIGHT PARAMETER
	AX = 206Ch
	BX = parameter (00h = right, FFh = left)
SeeAlso: AX=216Ch
----------33216C-----------------------------
INT 33 - LOGITECH - GET LEFT OR RIGHT PARAMETER
	AX = 216Ch
Return: BX = parameter (00h = right, FFh = left)
SeeAlso: AX=206Ch
----------33226C-----------------------------
INT 33 - LOGITECH - REMOVE DRIVER FROM MEMORY
	AX = 226Ch
Note:	this only frees memory; does not restore hooked interrupts
----------33236C-----------------------------
INT 33 - LOGITECH - SET BALLISTICS INFORMATION
	AX = 236Ch
	BX = 0=off, 1=on
	CX = 1=low, 2=high
SeeAlso: AX=1F6Ch
----------33246C-----------------------------
INT 33 - LOGITECH - GET PARAMETERS AND RESET SERIAL MOUSE
	AX = 246Ch
	ES:DX -> parameter table buffer (see below)
Return: AX = FFFFh if driver installed for serial mouse
SeeAlso: AX=256Ch

Format of parameter table:
Offset	Size	Description
 00h	WORD	baud rate divided by 100  (serial mouse only)
 02h	WORD	emulation		  (serial mouse only)
 04h	WORD	report rate		  (serial mouse only)
 06h	WORD	firmware revision	  (serial mouse only)
 08h	WORD	0			  (serial mouse only)
 0Ah	WORD	port			  (serial mouse only)
 0Ch	WORD	physical buttons
 0Eh	WORD	logical buttons
----------33256C-----------------------------
INT 33 - LOGITECH - SET PARAMETERS
	AX = 256Ch
	BX = 00h set baud rate (serial mouse only)
		CX = rate (0=1200, 1=2400, 2=4800, 3=9600)
	   = 01h set emulation (serial mouse only)
		CX = emulation
		    0 = 5 byte packed binary
		    1 = 3 byte packed binary
		    2 = hexadecimal
		    3 = relative bid pad
		    4 = not supported
		    5 = MM Series
		    6 = not supported
		    7 = Microsoft
	   = 02h set report rate (serial mouse only)
		CX = rate (0=10, 1=20, 2=35, 3=50, 4=70, 5=100, 6=150)
	   = 03h set port (serial mouse only)
		CX = port (1, 2)
	   = 04h set mouse logical buttons
		CX = buttons (2, 3)
Return: AX = FFFFh if driver installed for serial mouse
SeeAlso: AX=246Ch
----------33266C-----------------------------
INT 33 - LOGITECH - GET VERSION???
	AX = 266Ch
Return: BX = 'SS'
	CH = '4'  major version number
	CL = '1'  minor version number
----------33276C-----------------------------
INT 33 - LOGITECH - ??? Tries MMSeries, Baud 2400
	AX = 276Ch
----------34---------------------------------
INT 34 - Borland/Microsoft languages - Floating Point emulation
	This interrupt emulates opcode D8h
----------35---------------------------------
INT 35 - Borland/Microsoft languages - Floating Point emulation
	This interrupt emulates opcode D9h
----------36---------------------------------
INT 36 - Borland/Microsoft languages - Floating Point emulation
	This interrupt emulates opcode DAh
----------37---------------------------------
INT 37 - Borland/Microsoft languages - Floating Point emulation
	This interrupt emulates opcode DBh
----------38---------------------------------
INT 38 - Borland/Microsoft languages - Floating Point emulation
	This interrupt emulates opcode DCh
----------39---------------------------------
INT 39 - Borland/Microsoft languages - Floating Point emulation
	This interrupt emulates opcode DDh
----------3A---------------------------------
INT 3A - Borland/Microsoft languages - Floating Point emulation
	This interrupt emulates opcode DEh
----------3B---------------------------------
INT 3B - Borland/Microsoft languages - Floating Point emulation
	This interrupt emulates opcode DFh
----------3C---------------------------------
INT 3C - Borland/Microsoft languages - Floating Point emulation
	This interrupt emulates instructions with a segment override
Note:	the generated code is  CD 3C xy mm ....
	where xy is a modified ESC instruction and mm is the modR/M byte.  The
	xy byte appears to be encoded as
	    s s 0 1 1 x x x
	where "ss" specifies the segment override:
		00 -> DS:
		01 -> SS:
		10 -> CS:
		11 -> ES:
----------3D---------------------------------
INT 3D - Borland/Microsoft languages - Floating Point emulation
	This interrupt emulates a standalone FWAIT instruction
----------3E---------------------------------
INT 3E - Borland languages - Floating Point emulation "shortcut" call
	The two bytes following the INT 3E instruction are the subcode and
	a NOP (90h)

Subcode		Function
 DCh	load 8086 stack with 8087 registers
 DEh	load 8087 registers from 8086 stack
 E0h	round TOS and R1 to single precision, compare, pop twice
 E2h	round TOS and R1 to double precision, compare, pop twice
	Note: apparently buggy in TPas5.5, actually rounding to single prec.
 E4h	compare TOS/R1 with two POP's
 E6h	compare TOS/R1 with POP
 E8h	FTST (check TOS value)
 EAh	FXAM (check TOS value)
 ECh	sine
 EEh	cosine
 F0h	tangent
 F2h	arctangent
 F4h	Ln (FLDLN2 to TOS)
 F6h	Log2 (FLDLG2 to TOS)
 F8h	Log10 (FLDLG10 to TOS
 FAh	Exp (FLDL2E to TOS)
 FCh	TOS = 2**TOS
 FEh	TOS = 10**TOS
----------3F---------------------------------
INT 3F - Overlay manager interrupt (Microsoft LINK.EXE, Borland TLINK VROOMM)
Note:	INT 3F is the default, and may be overridden while linking
----------3F---------------------------------
INT 3F - Microsoft Dynamic Link Library manager
----------40---------------------------------
INT 40 - Hard disk - Relocated Floppy Handler (original INT 13h)
SeeAlso: INT 63
----------40---------------------------------
INT 40 - Z100 - Master 8259 - Parity error or S100 error
----------41---------------------------------
INT 41 - (NOT a vector!) FIXED DISK PARAMS (XT,AT,XT2,XT286,PS except ESDI)
SeeAlso: INT 1E,INT 46

Format of fixed disk parameters:
Offset	Size	Description
 00h	WORD	cylinders
 02h	BYTE	heads
 03h	WORD	starting reduced write current cylinder (XT only, 0 for others)
 05h	WORD	starting write pre-comp cylinder
 07h	BYTE	maximum ECC burst length
 08h	BYTE	control byte
		   bits 0-2: drive option (XT only, 0 for others)
		   bit 3:    set if more than 8 heads
		   bit 4:    always 0
		   bit 5:    set if manufacturer's defect map on max cylinder+1
		   bit 6:    disable ECC retries
		   bit 7:    disable access retries
 09h	BYTE	standard timeout (XT only, 0 for others)
 0Ah	BYTE	formatting timeout (XT only, 0 for others)
 0Bh	BYTE	timeout for checking drive (XT only, 0 for others)
 0Ch	WORD	landing zone (AT/PS2)
 0Eh	BYTE	sectors/track (AT/PS2)
 0Fh	BYTE	00h
----------41---------------------------------
INT 41 - Z100 - Master 8259 - Processor Swap
----------42---------------------------------
INT 42 - EGA/VGA/PS - Relocated (by EGA) Video Handler (original INT 10h)
----------42---------------------------------
INT 42 - Z100 - Master 8259 - Timer
----------43---------------------------------
INT 43 - EGA/VGA/PS - User font table
SeeAlso: INT 1F,INT 44
----------43---------------------------------
INT 43 - Z100 - Master 8259 - Slave 8259 input
Note:	slave runs in special fully nested mode
----------44---------------------------------
INT 44 - EGA/VGA/CONV/PS - EGA/PCjr fonts, characters 00h to 7Fh
SeeAlso: INT 1F,INT 43
----------44---------------------------------
INT 44 - Novell NetWare - HIGH-LEVEL LANGUAGE API
----------44---------------------------------
INT 44 - IBM 3270-PC High Level Language API
	DS:SI -> parameter control block
----------44---------------------------------
INT 44 - Z100 - Master 8259 - Serial A
----------45---------------------------------
INT 45 - Z100 - Master 8259 - Serial B
----------46---------------------------------
INT 46 - Secondary Fixed Disk Params (AT,XT286,PS except ESDI)
SeeAlso: INT 41
----------46---------------------------------
INT 46 - Z100 - Master 8259 - Keyboard, Retrace, and Light Pen
----------47---------------------------------
INT 47 - Z100 - Master 8259 - Printer
----------478000-----------------------------
INT 47 - SQL Base - DATABASE ENGINE API
	AX = 8000h
	DS:BX -> parameter block, first word is function number
Note:	SQL Base is a network-oriented database engine by Gupta Technologies

Values for function number:
 01h	"SQLFINI" initalialize application's use of the database
 02h	"SQLFDON" application is done using the database
 03h	"SQLFCON" connect to a cursor/database
 04h	"SQLFDIS" disconnect from a cursor/database
 05h	"SQLFCOM" compile a SQL command
 06h	"SQLFEXE" execute a SQL command
 07h	"SQLFCEX" compile and execute a SQL command
 08h	"SQLFCMT" commit a transaction to the database
 09h	"SQLFDES" describe the items of a SELECT statement
 0Ah	"SQLFGFI" get fetch information
 0Bh	"SQLFFBK" fetch previous result row from SELECT statement
 0Ch	"SQLFFET" fetch next result row from SELECT statement
 0Dh	"SQLFEFB" enable fetch backwards
 0Eh	"SQLFPRS" position in result set
 0Fh	"SQLFURS" undo result set
 10h	"SQLFNBV" get number of bind variables
 11h	"SQLFBND" bind data variables
 12h	"SQLFBNN" bind numerics
 13h	"SQLFBLN" bind long number
 14h	"SQLFBLD" bind long data variables
 15h	"SQLFSRS" start restriction set processing
 16h	"SQLFRRS" restart restriction set processing
 17h	"SQLFCRS" close restriction set
 18h	"SQLFDRS" drop restriction set
 19h	"SQLFARF" apply Roll Forward journal
 1Ah	"SQLFERF" end Roll Forward journal
 1Bh	"SQLFSRF" start Roll Forward journal
 1Ch	"SQLFSTO" store a compiled SQL command
 1Dh	"SQLFRET" retrieve a compiled SQL command
 1Eh	"SQLFDST" drop a stored command
 1Fh	"SQLFCTY" get command type
 20h	"SQLFEPO" get error position
 21h	"SQLFGNR" get number of rows
 22h	"SQLFNSI" get number of select items
 23h	"SQLFRBF" get Roll Back flag
 24h	"SQLFRCD" get return code
 25h	"SQLFROW" get number of ROWs
 26h	"SQLFSCN" set cursor name
 27h	"SQLFSIL" set isolation level
 28h	"SQLFSLP" set log parameters
 29h	"SQLFSSB" set select buffer
 2Ah	"SQLFSSS" set sort space
 2Bh	"SQLFRLO" read long
 2Ch	"SQLFWLO" write long
 2Dh	"SQLFLSK" long seek
 2Eh	"SQLFGLS" get long size
 2Fh	"SQLFELO" end long operation
 30h	"SQLFRBK" roll back a transaction from the database
 31h	"SQLFERR" error message
 32h	"SQLFCPY" copy
 33h	"SQLFR01" reserved
 34h	"SQLFSYS" system
 35h	"SQLFSTA" statistics
 36h	"SQLFR02" reserved
 37h	"SQLFXAD" extra add
 38h	"SQLFXCN" extra character to number
 39h	"SQLFXDA" extra date add
 3Ah	"SQLFXDP" extra date picture
 3Bh	"SQLFXDV" extra divide
 3Ch	"SQLFXML" extra multiply
 3Dh	"SQLFXNP" extra number picture
 3Eh	"SQLFXPD" extra picture date
 3Fh	"SQLFXSB" extra subtract
 40h	"SQLFINS" install database
 41h	"SQLFDIN" deinstall database
 42h	"SQLFDIR" directory of databases
 43h	"SQLFTIO" timeout
 44h	"SQLFFQN" get fully qualified column name
 45h	"SQLFEXP" explain execution plan
 46h	"SQLFFER" get full error
 47h	"SQLFBKP" begin online backup
 48h	"SQLFRDC" read backup data chunk
 49h	"SQLFEBK" end backup
 4Ah	"SQLFRES" begin restore from backup
 4Bh	"SQLFWDC" write backup data chunk for restore
 4Ch	"SQLFRRD" recover restored database to consistent state
 4Dh	"SQLFERS" end restore
 4Eh	"SQLFNRR" return number of result set rows
 4Fh	"SQLFSTR" start restriction mode
 50h	"SQLFSPR" stop restriction mode
 51h	"SQLFCNC" connect 2
 52h	"SQLFCNR" connect with no recovery
 53h	"SQLFOMS" set output message size
 54h	"SQLFIMS" set input message size
 55h	"SQLFSCP" set cache pages
 56h	"SQLFDSC" describe items of a SELECT statement (external)
 57h	"SQLFLAB" get label info for items in SELECT statement
 58h	"SQLFCBV" clear bind variables
 59h	"SQLFGET" get database information
 5Ah	"SQLFSET" set database information
 5Bh	"SQLFTEC" translate error code
----------478001-----------------------------
INT 47 - SQL Base - GET VERSION NUMBER
	AX = 8001h
Return: ???
Note:	SQL Base is a network-oriented database engine by Gupta Technologies
----------48---------------------------------
INT 48 - PCjr - Cordless Keyboard Translation
----------48---------------------------------
INT 48 - Z100 - Slave 8259 - S100 vectored line 0
----------49---------------------------------
INT 49 - PCjr - Non-keyboard Scan Code Translation Table

Format of translation table:
Offset	Size	Description
 00h	BYTE	number of nonkeyboard scancodes in the table
 01h  N WORDs	high byte 00h (NUL) byte scancode with low order byte
		representing the scancode mapped values relative to their
		input values within the range of 56h through 7Eh
----------49---------------------------------
INT 49 - Z100 - Slave 8259 - S100 vectored line 1
----------49---------------------------------
INT 49 - Texas Instruments PC - VIDEO I/O???
	apparently provides direct video display on the TI Professional PC
----------4A---------------------------------
INT 4A - AT/CONV/PS - User Alarm
	Invoked by BIOS when real-time clock alarm occurs
SeeAlso: INT 1A/AH=06h
----------4A---------------------------------
INT 4A - Z100 - Slave 8259 - S100 vectored line 2
----------4B---------------------------------
INT 4B - Common Access Method SCSI interface (draft revision 1.9)
Notes:	the CAM committee moved the interface to INT 4F to avoid a conflict
	  with the Virtual DMA spec
	it is not known whether any drivers actually implemented this interface
	  on INT 4B instead of INT 4F
SeeAlso: INT 4F
----------4B8102DX0000-----------------------
INT 4B - Virtual DMA Specification (VDS) - GET VERSION
	AX = 8102h
	DX = 0000h
Return: CF clear if successful
	    AH = major version number
	    AL = minor version number
	    BX = product number
	    CX = product revision number
	    SI:DI = maximum DMA buffer size
	    DX = flags
		bit 0: PC/XT bus (DMA in first megabyte only)
		    1: physical buffer/remap region in first megabyte
		    2: automatic remap enabled
		    3: all memory is physically contiguous
		 4-15: reserved (zero)
	CF set on error
	    AL = error code (see below)
Note:	bit 5 of 0040h:007Bh is supposed to be set if VDS is supported; this is
	  apparently not always the case
SeeAlso: INT 31

Values for error code:
 01h	region not in contiguous memory
 02h	region crossed a physical alignment boundary
 03h	unable to lock pages
 04h	no buffer available
 05h	region too large for buffer
 06h	buffer currently in use
 07h	invalid memory region
 08h	region was not locked
 09h	number of physical pages greater than table length
 0Ah	invalid buffer ID
 0Bh	copy out of buffer range
 0Ch	invalid DMA channel number
 0Dh	disable count overflow
 0Eh	disable count underflow
 0Fh	function not supported
 10h	reserved flag bits set in DX

Format of DMA descriptor structure (DDS):
Offset	Size	Description
 00h	DWORD	region size
 04h	DWORD	offset
 08h	WORD	segment/selector
 0Ah	WORD	buffer ID
 0Ch	DWORD	physical address

Format of Extended DMA descriptor structure (EDDS):
Offset	Size	Description
 00h	DWORD	region size
 04h	DWORD	offset
 08h	WORD	segment/selector
 0Ah	WORD	reserved
 0Ch	WORD	number available
 0Eh	WORD	number used
 10h	DWORD	region 0 physical address
 14h	DWORD	region 0 size in bytes
 18h	DWORD	region 1 physical address
 1Ch	DWORD	region 1 size in bytes
	...

Format of Extended DMA descriptor structure (EDDS) with page table entries:
Offset	Size	Description
 00h	DWORD	region size
 04h	DWORD	offset
 08h	WORD	segment/selector
 0Ah	WORD	reserved
 0Ch	WORD	number available
 0Eh	WORD	number used
 10h	DWORD	page table entry 0 (same as 80386 page table entry)
 14h	DWORD	page table entry 1
	...
Note:	bits 1-12 of the page table entries should be zero; bit 0 set if page
	  is present and locked
----------4B8103-----------------------------
INT 4B - Virtual DMA Specification - LOCK DMA REGION
	AX = 8103h
	DX = flags
	    bit 0: reserved (zero)
		1: data should be copied into buffer (ignored if bit 2 set)
		2: buffer should not be allocated if region noncontiguous or
		   crosses physical alignment boundary specified by bits 4-5
		3: don't attempt automatic remap
		4: region must not cross 64K physical alignment boundary
		5: region must not cross 128K physical alignment boundary
	     6-15: reserved (zero)
	DS:SI -> DMA descriptor structure (see AX=8102h)
Return:	CF clear if successful
	    DDS physical address field filled in
	    DDS buffer ID field filled (0000h if no buffer allocated)
	CF set on error
	    AL = error code (see AX=8102h)
	    DDS region size field filled wth maximum contiguous length in bytes
SeeAlso: AX=8104h,AX=8105h
----------4B8104-----------------------------
INT 4B - Virtual DMA Specification - UNLOCK DMA REGION
	AX = 8104h
	DX = flags
	    bit 0: reserved (zero)
		1: data should be copied out of buffer
	     2-15: reserved (zero)
	ES:DI -> DMA descriptor structure (see AX=8102h) with region size,
		physical address, and buffer ID fields set
Return: CF clear if successful
	    DDS physical address field set
	    DDS buffer ID field set (0000h if no buffer allocated)
	CF set on error
	    AL = error code (see AX=8102h)
	    DDS region size field filled wth maximum contiguous length in bytes
SeeAlso: AX=8103h,AX=8106h
----------4B8105-----------------------------
INT 4B - Virtual DMA Specification - SCATTER/GATHER LOCK REGION
	AX = 8105h
	DX = flags
	    bits 0-5: reserved (zero)
		   6: EDDS should be returned with page table entries
		   7: only present pages should be locked (not-present pages
			receive entry of 0000h)
		8-15: reserved (zero)
	ES:DI -> Extended DMA descriptor structure (see AX=8102h)
		region size, linear segment, linear offset, and number avail
		fields set
Return: CF clear if successful
	    EDDS number used field set
	    if DX bit 6 set, lower 12 bits of BX = offset in first page
	CF set on error
	    AL = error code (see AX=8102h)
	    EDDS region size field filled with max length in bytes that can be
		locked and described in the EDDS table
SeeAlso: AX=8103h,AX=8106h
----------4B8106-----------------------------
INT 4B - Virtual DMA Specification - SCATTER/GATHER UNLOCK REGION
	AX = 8106h
	DX = flags
	    bits 0-5: reserved (zero)
		   6: EDDS contains page table entries
		   7: EDDS may contain not-present pages (entry = 0000h)
		8-15: reserved (zero)
	ES:DI -> Extended DMA descriptor structure (see AX=8102h) returned
		by AX=8105h	
Return: CF clear if successful
	CF set on error
	    AL = error code (see AX=8102h)
SeeAlso: AX=8104h,AX=8105h
----------4B8107-----------------------------
INT 4B - Virtual DMA Specification - REQUEST DMA BUFFER
	AX = 8107h
	DX = flags
	    bit 0: reserved (zero)
		1: data should be copied into buffer
	     2-15: reserved (zero)
	ES:DI -> DMA descriptor structure (see AX=8102h) with region size set
		(also region offset and region segment if DX bit 1 set)
Return: CF clear if successful
	    DDS physical address and buffer ID set
	    DDS region size filled with length of buffer
	CF set on error
	    AL = error code (see AX=8102h)
SeeAlso: AX=8108h
----------4B8108-----------------------------
INT 4B - Virtual DMA Specification - RELEASE DMA BUFFFER
	AX = 8108h
	DX = flags
	    bit 0: reserved (zero)
		1: data should be copied out of buffer
	     2-15: reserved (zero)
	ES:DI -> DMA descriptor structure (see AX=8102h) with buffer ID set
		(also region size/region offset/segment if DX bit 1 set)
Return: CF clear if successful
	CF set on error
	    AL = error code (see AX=8102h)
SeeAlso: AX=8107h
----------4B8109-----------------------------
INT 4B - Virtual DMA Specification - COPY INTO DMA BUFFER
	AX = 8109h
	DX = 0000h
	ES:DI -> DMA descriptor structure (see AX=8102h) with buffer ID,
		region segment/offset, and region size fields set
	BX:CX = starting offset into DMA buffer
Return: CF clear if successful
	CF set on error
	    AL = error code (see AX=8102h)
SeeAlso: AX=810Ah
----------4B810A-----------------------------
INT 4B - Virtual DMA Specification - COPY OUT OF DMA BUFFER
	AX = 810Ah
	DX = 0000h
	ES:DI -> DMA descriptor structure (see AX=8102h) with buffer ID,
		region segment/offset, and region size fields set
	BX:CX = starting offset into DMA buffer
Return: CF clear if successful
	CF set on error
	    AL = error code (see AX=8102h)
SeeAlso: AX=8109h
----------4B810B-----------------------------
INT 4B - Virtual DMA Specification - DISABLE DMA TRANSLATION
	AX = 810Bh
	BX = DMA channel number
	DX = 0000h
Return: CF clear if successful
	CF set on error
	    AL = error code (see AX=8102h)
SeeAlso: AX=810Ch
----------4B810C-----------------------------
INT 4B - Virtual DMA Specification - ENABLE DMA TRANSLATION
	AX = 810Ch
	BX = DMA channel number
	DX = 0000h
Return: CF clear if successful
	    ZF set if disable count decremented to zero
	CF set on error
	    AL = error code (see AX=8102h)
SeeAlso: AX=810Bh
----------4B---------------------------------
INT 4B - Z100 - Slave 8259 - S100 vectored line 3
----------4C---------------------------------
INT 4C - Z100 - Slave 8259 - S100 vectored line 4
----------4D---------------------------------
INT 4D - Z100 - Slave 8259 - S100 vectored line 5
----------4E---------------------------------
INT 4E - TI Professional PC - DISK I/O
	used instead of INT 13 on the TI Professional PC
SeeAlso: INT 13
----------4E---------------------------------
INT 4E - Z100 - Slave 8259 - S100 vectored line 6
----------4F---------------------------------
INT 4F - Z100 - Slave 8259 - S100 vectored line 7
----------4F---------------------------------
INT 4F - Common Access Method SCSI interface
	ES:BX -> CAM Control Block (CCB)
Return: nothing
Notes:	the installation check for the driver is the string "SCSI_CAM" eight
	  bytes past the INT 4Bh handler
	this information is based on the 1.9 draft version of the
	  specification, except that the interrupt was changed after that versn
SeeAlso: INT 4B

Format of CAM Control Block:
Offset	Size	Description
 00h	WORD	CAM control block length
 02h	BYTE	function code
 03h	BYTE	CAM status
 04h	BYTE	SCSI status
 05h	BYTE	path ID
 06h	BYTE	target ID
 07h	BYTE	logical unit number
 08h	BYTE	CAM flags
		bits 7-6: direction
			00 reserved
			01 in
			10 out
			11 no data transfer
		bit 5: disable autosense
		bit 4: scatter/gather
		bit 3: disable callback on completion
		bit 2: linked CDB
		bit 1: queue action enable
		bit 0: CDB is a pointer
 09h	BYTE	CAM flags
		bit 7: disable disconnect
		bit 6: initiate synchronous transfers  \ mutually
		bit 5: disable synchronous transfers   / exclusive
		bit 4: SIM queue priority
			1 head insertion
			0 tail insertion (normal)
		bits 3-0: reserved
 0Ah	BYTE	CAM flags
		bit 7: reserved
		bit 6: CDB pointer    (bits 6-1: 0=VA, 1=PA)
		bit 5: SG list/data
		bit 4: sense buffer
		bit 3: message buffer
		bit 2: next CCB
		bit 1: callback on completion
		bit 0: reserved
 0Bh	BYTE	target-mode flags
		bit 7: data buffer valid
		bit 6: status valid
		bit 5: message buffer valid
		bits 4-3: reserved
		bit 2: target CCB available
		bit 1: disable autodisconnect
		bit 0: disable autosave/restore
 0Ch  N BYTEs	function-dependent data
----------50---------------------------------
INT 50 - TIL Xpert AIM (X.25)
	AH = function
----------50---------------------------------
INT 50 - through 57 - IRQ0-IRQ7 relocated by DESQview
----------50---------------------------------
INT 50 - through 57 - IRQ0-IRQ7 relocated by IBM 3278 emulation control program
----------58---------------------------------
INT 58 - IRQ8 relocated by DESQview 2.26+
SeeAlso: INT 70
----------59---------------------------------
INT 59 - IRQ9 relocated by DESQview 2.26+
SeeAlso: INT 71
----------59---------------------------------
INT 59 - GSS Computer Graphics Interface (GSS*CGI)
	DS:DX -> block of 5 array pointers
Return:	CF set on error
	    AX = error code
	CF clear if successful
	    AX = return code
Note:	INT 59 is the means by which GSS*CGI language bindings communicate with
	  GSS*CGI device drivers and the GSS*CGI device driver controller.
	also used by the IBM Graphic Development Toolkit
----------5A---------------------------------
INT 5A - IRQ10 relocated by DESQview 2.26+
SeeAlso: INT 72
----------5A---------------------------------
INT 5A - Cluster adapter BIOS entry address
	???
----------5B---------------------------------
INT 5B - IRQ11 relocated by DESQview 2.26+
SeeAlso: INT 73
----------5B---------------------------------
INT 5B - Used by cluster adapter
----------5B---------------------------------
INT 5B - AT&T Starlan Extended NetBIOS (variable length names)
	ES:BX -> Network Control Block (see below)
Return: AL = status (see INT 5C)
SeeAlso: INT 5C

Format of Network Control Block
Offset	Size	Description
 00h	BYTE	ncb_command (see below)
 01h	BYTE	ncb_retcode
 02h	BYTE	ncb_lsn
 03h	BYTE	ncb_num
 04h	DWORD	-> ncb_buffer
 08h	WORD	ncb_length
 0Ah 16 BYTEs	ncb_callname
 1Ah 16 BYTEs	ncb_name
 2Ah	BYTE	ncb_rto
 2Bh	BYTE	ncb_sto
 2Ch	DWORD	-> ncb_post  	/* int (far *ncb_post)(); */
 30h	BYTE	ncb_lana_num
 31h	BYTE	ncb_cmd_cplt
 32h	DWORD	-> ncb_vname
 36h	BYTE	ncb_vnamelen
 37h  9 BYTEs	ncb_reserve
Note: fields 00h-31h are the same as for a standard NetBIOS NCB (see INT 5C)

Values for ncb_command field same as for INT 5C, except
	70h	send net Break
----------5B---------------------------------
INT 5B - Microsoft Network Transport Layer Interface
----------5C---------------------------------
INT 5C - IRQ12 relocated by DESQview 2.26+
SeeAlso: INT 74
----------5C---------------------------------
INT 5C - NETBIOS INTERFACE
	ES:BX -> Network Control Block (see below)
Return: AL = status
	    00h successful
	    01h bad buffer size
	    03h invalid NETBIOS command
	    05h timeout
	    06h receive buffer too small
	    08h bad session number
	    09h LAN card out of memory
	    0Ah session closed
	    0Bh command has been cancelled
	    0Dh name already exists
	    0Eh local name table full
	    0Fh name still in use, can't delete
	    11h local session table full
	    12h remote PC not listening
	    13h bad NCB_NUM field
	    14h no answer to CALL or no such remote
	    15h name not in local name table
	    16h duplicate name
	    17h bad delete
	    18h abnormal end
	    19h name error, multiple identical names in use
	    1Ah bad packet
	    21h network card busy
	    22h too many commands queued
	    23h bad LAN card number
	    24h command finished while cancelling
	    26h command can't be cancelled
	    FFh NETBIOS busy
Note:	Sytek PCnet card uses DMA 3.
SeeAlso: INT 5B

Format of Network Control Block:
Offset	Size	Description
 00h	BYTE	ncb_command (see below)
 01h	BYTE	ncb_retcode
 02h	BYTE	ncb_lsn
 03h	BYTE	ncb_num
 04h	DWORD	-> ncb_buffer
 08h	WORD	ncb_length
 0Ah 16 BYTEs	ncb_callname
 1Ah 16 BYTEs	ncb_name
 2Ah	BYTE	ncb_rto
 2Bh	BYTE	ncb_sto
 2Ch	DWORD	-> ncb_post  	/* int (far *ncb_post)(); */
 30h	BYTE	ncb_lana_num
		00h-03h IBM NetBIOS specs
		F0h-FFh Eicon NABios interface
 31h	BYTE	ncb_cmd_cplt
 32h 14 BYTEs	ncb_reserve

Values for "ncb_command" field in NCB (or with 80h for non-waiting call):
	10h start session with NCB_NAME name (call)
	11h listen for call
	12h end session with NCB_NAME name (hangup)
	14h send data via NCB_LSN
	15h receive data from a session
	16h receive data from any session
	17h send multiple data buffers
	20h send unACKed message (datagram)
	21h receive datagram
	22h send broadcast datagram
	23h receive broadcast datagram
	30h add name to name table
	31h delete name from name table
	32h reset adapter card and tables
	33h get adapter status (see structure "astatus" below)
	34h status of all sessions for name (see structure "sstatus" below)
	35h cancel
	36h add group name to name table
	70h unlink from IBM remote program (no F0h function)
	71h send data without ACK
	72h send multiple buffers without ACK
	78h find name
	79h token-ring protocol trace

Format of structure "name":
Offset	Size	Description
 00h 16 BYTEs nm_name
 10h	BYTE  nm_num
 11h	BYTE  nm_status

Format of structure "astatus":
Offset	Size	Description
 00h  6 BYTEs as_id
 06h	BYTE  as_jumpers
 07h	BYTE  as_post
 08h	BYTE  as_major
 09h	BYTE  as_minor
 0Ah	WORD  as_interval
 0Ch	WORD  as_crcerr
 0Eh	WORD  as_algerr
 10h	WORD  as_colerr
 12h	WORD  as_abterr
 14h	DWORD as_tcount
 18h	DWORD as_rcount
 1Ch	WORD  as_retran
 1Eh	WORD  as_xresrc
 20h  8 BYTEs as_res0
 28h	WORD  as_ncbfree
 2Ah	WORD  as_ncbmax
 2Ch	WORD  as_ncbx
 2Eh  4 BYTEs as_res1
 32h	WORD  as_sespend
 34h	WORD  as_msp
 36h	WORD  as_sesmax
 38h	WORD  as_bufsize
 3Ah	WORD  as_names
 3Ch 16 name structures  as_name

Format of structure "sstatus":
Offset	Size	Description
 00h	BYTE	number of sessions being reported
 01h	BYTE	number of sessions with this name
 02h	BYTE	number of outstanding receive datagrams
 03h	BYTE	number of outstanding ReceiveAnys
 04h	var	session structures (see below)

Format of structure "session":
Offset	Size	Description
 00h	BYTE	local session number
 01h	BYTE	state
		01h listen pending
		02h call pending
		03h session established
		04h hangup pending
		05h hangup done
		06h session aborted
 02h 16 BYTEs	local name
 12h 16 BYTEs	remote name
 22h	BYTE	number of outstanding receives
 23h	BYTE	number of outstanding sends/chainsends
----------5C---------------------------------
INT 5C - TOPS INTERFACE
	ES:BX -> Network Control Block
Note:	TOPS card uses DMA 1, 3 or none.
----------5C---------------------------------
INT 5C - ATALK.SYS - AppleTalk INTERFACE
	DX:BX -> control block (see below)
Return: none
Notes:	this driver can use any interrupt from 5Ch to 70h
	the signature 'AppleTalk' appears 16 bytes prior to the interrupt
	  handler; this serves as the installation check

Format of AppleTalk control block:
Offset	Size	Description
 00h	WORD	command code
		01h "AT_INIT"	    initialize the driver
		03h "AT_GETNETINFO" get current network info incl init status
		20h "DDP_OPENSOCKET"
		21h "DDP_CLOSESOCKET"
		22h "DDP_WRITE"
		23h "DDP_READ"
		24h "DDP_CANCEL"
		30h "NBP_REGISTER"
		31h "NBP_REMOVE"
		32h "NBP_LOOKUP"
		33h "NBP_CONFIRM"
		34h "NBP_CANCEL"
		42h "ATP_SEND_REQUEST"
		or with the following flags
		8000h start command then return
		4000h wait for interrupt service to complete
 02h	WORD	returned status
		0000h success (already initialized if func 01h)
 04h	DWORD	pointer to completion function
 08h	WORD	network number
 0Ah	BYTE	node ID
---if general func (01h,03h), control block continues:
 0Bh	BYTE	"inf_abridge"
 0Ch	WORD	"inf_config"
 0Eh	DWORD	pointer to buffer
 12h	WORD	buffer size
---if DDP function (20h-24h), control block continues:
 0Bh	BYTE	"ddp_addr_socket"
 0Ch	BYTE	"ddp_socket"
 0Dh	BYTE	"ddp_type"
 0Eh	DWORD	pointer to buffer
 12h	WORD	buffer size
 14h	BYTE	"ddp_chksum"
---if Name Binding Protocol (30h-34h), control block continues:
 0Bh	BYTE	"nbp_addr_socket"
 0Ch	WORD	"nbp_toget"
 0Eh	DWORD	pointer to buffer
 12h	WORD	buffer size
 14h	BYTE	"nbp_interval"
 15h	BYTE	"nbp_retry"
 16h	DWORD	"nbp_entptr"
---if AppleTalk Transaction Protocol (42h), control block continues:
 0Bh	BYTE	"atp_addr_socket"
 0Ch	WORD	"atp_socket"
 0Eh	DWORD	pointer to buffer
 12h	WORD	buffer size
 14h	BYTE	"atp_interval"
 15h	BYTE	"atp_retry"
 16h	BYTE	ATP flags
		bit 5: exactly one transaction
 17h	BYTE	"atp_seqbit"
 18h	BYTE	transaction ID
 19h  4 BYTEs	ATP user bytes
 1Dh	BYTE	number of BDS buffers
 1Eh	BYTE	number of BDS responses
 1Fh	DWORD	pointer to BDS buffers (see below)

Format of Name Binding Protocol Name-to-Address binding entries for NBP_LOOKUP:
Offset	Size	Description
 00h	WORD	"tup_address_network"
 02h	BYTE	"tup_address_notid"
 03h	BYTE	"tup_address_socket"
 04h	BYTE	"tup_enum"
 05h 99 BYTEs	name

Format of BDS entries:
Offset	Size	Description
 00h	DWORD	pointer to buffer
 04h	WORD	size of buffer
 06h	WORD	BDS data size
 08h  4 BYTEs	"bds_userbytes"
----------5C---------------------------------
INT 5C - IBM 802.2 INTERFACE (LLC)
	ES:BX -> CCB
Return: none

Format of CCB:
Offset	Size	Description
 00h	BYTE	adapter
 01h	BYTE	command code
 02h	BYTE	return code
 03h	BYTE	work
 04h	DWORD	pointer to ???
 08h	DWORD	pointer to completion function???
 0Ch	DWORD	pointer to parameters???
----------5C---------------------------------
INT 5C - $25 LAN - INSTALLATION CHECK
Notes:	current versions only check whether the vector is 0000h:0000h or not
	future versions are supposed to have the signature "NET" in the three
	  bytes preceding the INT 5C handler
----------5C04-------------------------------
INT 5C - $25 LAN - CHECK IF CONNECTION ALIVE
	AH = 04h
	AL = COM port (0 = default)
	CX = wait count in character times (should be at least 100)
Return: ZF set if link alive
----------5D---------------------------------
INT 5D - IRQ13 relocated by DESQview 2.26+
SeeAlso: INT 75
----------5E---------------------------------
INT 5E - IRQ14 relocated by DESQview 2.26+
SeeAlso: INT 76
----------5F---------------------------------
INT 5F - IRQ15 relocated by DESQview 2.26+
SeeAlso: INT 77
----------60---------------------------------
