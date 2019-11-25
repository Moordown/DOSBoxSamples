Interrupt List, part 2 of 4
This compilation is Copyright (c) 1989,1990,1991 Ralf Brown
----------20---------------------------------
INT 20 - Minix - SEND/RECEIVE MESSAGE
	AX = process ID of other process
	BX -> message
	CX = 1 send
	     2 receive
	     3 send&receive
Note:	the message contains the system call number (numbered as in V7 
	  Unix(tm)) and the call parameters
----------20---------------------------------
INT 20 - DOS - PROGRAM TERMINATION
returns to DOS--identical to INT 21/AH=00h
Note:	IBM and Microsoft recommend using INT 21/AH=4Ch for DOS 2+
SeeAlso: INT 21/AH=00h, INT 21/AH=4Ch
----------2100-------------------------------
INT 21 - DOS - PROGRAM TERMINATION
	AH = 00h
Return: never
Note:	execution continues at address pointed to by INT 22 after DOS performs
	  whatever cleanup it needs to do
SeeAlso: AH=31h,AH=4Ch,INT 20,INT 22
----------2101-------------------------------
INT 21 - DOS - KEYBOARD INPUT
	AH = 01h
Return: AL = character read
Note:	^C/^Break are checked, and INT 23h executed if read
	character is echoed to standard output
SeeAlso: AH=06h,AH=07h,AH=08h,AH=0Ah
----------2102-------------------------------
INT 21 - DOS - DISPLAY OUTPUT
	AH = 02h
	DL = character to send to standard output
Note:	^C/^Break are checked, and INT 23h executed if pressed
SeeAlso: AH=06h,AH=09h
----------2103-------------------------------
INT 21 - DOS - AUX INPUT
	AH = 03h
Return: AL = character read
SeeAlso: AH=04h,INT 14/AH=02h
----------2104-------------------------------
INT 21 - DOS - AUX OUTPUT
	AH = 04h
	DL = character to send
SeeAlso: AH=03h,INT 14/AH=01h
----------2105-------------------------------
INT 21 - DOS - PRINTER OUTPUT
	AH = 05h
	DL = character to print
SeeAlso: INT 17/AH=00h
----------2106-------------------------------
INT 21 - DOS - DIRECT CONSOLE I/O CHARACTER OUTPUT
	AH = 06h
	DL = character <> FFh
SeeAlso: AH=02h,AH=09h
----------2106--DLFF-------------------------
INT 21 - DOS - DIRECT CONSOLE I/O CHARACTER INPUT
	AH = 06h
	DL = FFh
Return: ZF set	 = no character
	ZF clear = character recieved
		  AL = character
Notes:	character is echoed to STDOUT if received.
	^C/^Break are NOT checked
SeeAlso: AH=0Bh
----------2107-------------------------------
INT 21 - DOS - DIRECT STDIN INPUT, NO ECHO
	AH = 07h
Note:	same as function 06h for input but char not echoed
SeeAlso: AH=01h,AH=06h,AH=08h,AH=0Ah
----------2108-------------------------------
INT 21 - DOS - KEYBOARD INPUT, NO ECHO
	AH = 08h
Return: AL = character
Note:	same as function 07h, but ^C/^Break are checked
SeeAlso: AH=01h,AH=06h,AH=07h,AH=0Ah,AH=64h
----------2109-------------------------------
INT 21 - DOS - PRINT STRING
	AH = 09h
	DS:DX -> string terminated by "$"
Note:	^C/^Break checked, and INT 23h called if pressed
SeeAlso: AH=02h,AH=06h"OUTPUT"
----------210A-------------------------------
INT 21 - DOS - BUFFERED KEYBOARD INPUT
	AH = 0Ah
	DS:DX -> buffer
Notes:	first byte of buffer must contain maximum length
	on entry, second byte contains actual length of previous line which may
	  be recalled with the DOS line-editing commands
	on return the second byte contains actual length, third and
	  subsequent bytes contain the input line
----------210B-------------------------------
INT 21 - DOS - CHECK STANDARD INPUT STATUS
	AH = 0Bh
Return: AL = FFh if character available
	     00h if no character
Note:	^C/^Break checked, and INT 23h called if pressed
SeeAlso: AH=06h"INPUT"
----------210C-------------------------------
INT 21 - DOS - CLEAR KEYBOARD BUFFER
	AH = 0Ch
	AL must be 01h, 06h, 07h, 08h, or 0Ah.
Notes:	flushes all typeahead input, then executes function specified by AL
	  (effectively moving it to AH and repeating the INT 21 call).
	if AL contains a value not in the list above, the keyboard buffer is
	  flushed and no other action is taken.
SeeAlso: AH=01h,AH=06h"INPUT",AH=07h,AH=08h,AH=0Ah
----------210D-------------------------------
INT 21 - DOS - DISK RESET
	AH = 0Dh
Note:	flushes all disk buffers
SeeAlso: INT 13/AH=00h, INT 2F/AX=1120h
----------210E-------------------------------
INT 21 - DOS - SELECT DISK
	AH = 0Eh
	DL = new default drive number (0 = A, 1 = B, etc.)
Return: AL = number of logical drives
Notes:	under Novell NetWare, the return value is always 32, the number of
	  drives that NetWare supports
	under DOS 3+, the return value is the greatest of 5, the value of
	  LASTDRIVE= in CONFIG.SYS, and the number of drives actually present
	otherwise, the return value is the highest drive actually present
SeeAlso: AH=19h, AH=DBh
----------210F-------------------------------
INT 21 - DOS - OPEN DISK FILE
	AH = 0Fh
	DS:DX -> FCB (see below)
Return: AL = 00h file found
	     FFh file not found
Note:	(DOS 3+) file opened in compatibility mode
SeeAlso: AH=3Dh

Format of File Control Block:
Offset	Size	Description
 -7	BYTE	extended FCB if FFh
 -6   5 BYTEs	reserved
 -1	BYTE	file attribute if extended FCB
 00h	BYTE	drive number (0 = default, 1 = A, etc)
 01h  8 BYTEs	blank-padded file name 
 09h  3 BYTEs	blank-padded file extension
 0Ch	WORD	current block number
 0Eh	WORD	logical record size
 10h	DWORD	file size
 14h	WORD	date of last write (see AX=5700h)
 16h	WORD	time of last write (see AX=5700h)
 18h  8 BYTEs	reserved (see below)
 20h	BYTE	record within current block
 21h	DWORD	random access record number (if record size is > 64 bytes, high
		byte is omitted)
Note:	to use an extended FCB, you must specify the address of the FFh flag at
	  offset -7, rather than the address of the drive number field

Format of reserved field for DOS 1.x:
Offset	Size	Description
 18h	BYTE	bit 7: set if logical device
		bit 6: set if open???
		bits 5-0: disk number or logical device ID
 19h	WORD	absolute current cluster number
 1Bh	WORD	starting cluster number
 1Dh	WORD	relative current cluster number
 1Fh	BYTE	unused???

Format of reserved field for DOS 2.x:
Offset	Size	Description
 18h	BYTE	bit 7: set if logical device
		bit 6: set if open???
		bits 5-0: ???
 19h	WORD	starting cluster number
 1Bh	WORD	???
 1Dh	BYTE	???
 1Eh	BYTE	???
 1Fh	BYTE	???

Format of reserved field for DOS 3.x:
Offset	Size	Description
 18h	BYTE	number of system file table entry for file
 19h	BYTE	attributes
		bits 7,6: 00 = SHARE.EXE not loaded, disk file
			  01 = SHARE.EXE not loaded, character device
			  10 = SHARE.EXE loaded, remote file
			  11 = SHARE.EXE loaded, local file
		bits 5-0: low six bits of device attribute word
---SHARE.EXE loaded, local file---
 1Ah	WORD	starting cluster of file
 1Ch	WORD	offset within SHARE of sharing record (see AH=52h)
 1Eh	BYTE	file attribute
 1Fh	BYTE	???
---SHARE.EXE loaded, remote file---
 1Ah	WORD	number of sector containing directory entry
 1Ch	WORD	relative cluster within file of last cluster accessed
 1Eh	BYTE	absolute cluster number of last cluster accessed
 1Fh	BYTE	???
---SHARE.EXE not loaded---
 1Ah	BYTE	(low byte of device attribute word AND 0Ch) OR open mode
 1Bh	WORD	starting cluster of file
 1Dh	WORD	number of sector containing directory entry
 1Fh	BYTE	number of directory entry within sector
Note:	if FCB opened on character device, DWORD at 1Ah is set to the address
	  of the device driver header, then the BYTE at 1Ah is overwritten.
----------2110-------------------------------
INT 21 - DOS - CLOSE DISK FILE
	AH = 10h
	DS:DX -> FCB (see AH=0Fh)
Return: AL = 00h directory update successful
	     FFh file not found in directory
SeeAlso: AH=3Eh
----------2111-------------------------------
INT 21 - DOS - SEARCH FIRST USING FCB
	AH = 11h
	DS:DX -> FCB (see AH=0Fh)
Return: AL = status
	    00h file found
		[DTA] = unopened FCB for file that was found
	    FFh file not found
SeeAlso: AH=1Ah,AH=4Eh, INT 2F/AX=111Bh
----------2112-------------------------------
INT 21 - DOS - SEARCH NEXT USING FCB
	AH = 12h
	DS:DX -> FCB (see AH=0Fh)
Return: AL = status
	    00h file found
		[DTA] = unopened FCB for file that was found
	    FFh file not found
SeeAlso: AH=1Ah,AH=4Fh, INT 2F/AX=111Ch
----------2113-------------------------------
INT 21 - DOS - DELETE FILE via FCB
	AH = 13h
	DS:DX -> FCB (see AH=0Fh) with filename field filled with template for
		 deletion ('?' wildcard allowed, but not '*')
Return: AL = status
	    00h file found
	    FFh file not found
Note:	deletes everything in the current directory (including subdirectories)
	  and sets the first byte of the name to 00h (entry never used)
	  instead of E5h if called on an extended FCB with filename
	  '???????????' and bits 0-4 of the attribute set (bits 1 and 2 for
	  DOS 1).  This may have originally been an optimization to minimize
	  directory searching after a mass deletion, but can corrupt the
	  filesystem under DOS 2+ because subdirectories are removed without
	  deleting the files they contain.
SeeAlso: AH=41h, INT 2F/AX=1113h
----------2114-------------------------------
INT 21 - DOS - SEQUENTIAL DISK FILE READ
	AH = 14h
	DS:DX -> FCB (see AH=0Fh)
Return: AL = status
	    00h successful read
	    01h end of file
	    02h data transfer area too small
	    03h partial record, EOF
SeeAlso: AH=3Fh, INT 2F/AX=1108h
----------2115-------------------------------
INT 21 - DOS - SEQUENTIAL DISK RECORD WRITE
	AH = 15h
	DS:DX -> FCB (see AH=0Fh)
Return: AL = status
	    00h successful write
	    01h disk full
	    02h data transfer area too small
SeeAlso: AH=40h, INT 2F/AX=1109h
----------2116-------------------------------
INT 21 - DOS - CREATE A DISK FILE
	AH = 16h
	DS:DX -> FCB (see AH=0Fh)
Return: AL = status
	    00h successful creation
	    FFh directory full
Note:	if file already exists, it is truncated to zero length
SeeAlso: AH=3Ch
----------2117-------------------------------
INT 21 - DOS - RENAME FILE via FCB
	AH = 17h
	DS:DX -> FCB (see AH=0Fh)
	FCB contains new name starting at byte 17h.
Return: AL = status
	    00h file found
	    FFh file not found
SeeAlso: AH=56h, INT 2F/AX=1111h
----------2118-------------------------------
INT 21 - DOS internal - UNUSED
	AH = 18h
Return: AL = 00h
----------2119-------------------------------
INT 21 - DOS - GET DEFAULT DISK NUMBER
	AH = 19h
Return: AL = current drive number (letter - 'A')
SeeAlo: AH=0Eh
----------211A-------------------------------
INT 21 - DOS - SET DISK TRANSFER AREA ADDRESS
	AH = 1Ah
	DS:DX -> disk transfer buffer
SeeAlso: AH=2Fh
----------211B-------------------------------
INT 21 - DOS - GET ALLOCATION TABLE INFORMATION FOR DEFAULT DRIVE
	AH = 1Bh
Return: DS:BX -> FAT ID byte for default drive
	DX = number of allocation units on disk
	AL = number of sectors per allocation unit (cluster)
	CX = number of bytes per sector
Note:	under DOS 1.x, DS:BX points at an actual copy of the FAT
SeeAlso: AH=1Ch,AH=36h
----------211C-------------------------------
INT 21 - DOS - GET ALLOCATION TABLE INFORMATION FOR SPECIFIC DRIVE
	AH = 1Ch
	DL = drive number to check (0=default, 1=A, etc)
Return: DS:BX -> FAT ID byte for specified drive
	DX = number of allocation units on disk
	AL = number of sectors per allocation unit (cluster)
	CX = number of bytes per sector
Note:	under DOS 1.x, DS:BX points at an actual copy of the FAT
SeeAlso: AH=1Bh,AH=36h
----------211D-------------------------------
INT 21 - DOS internal - UNUSED
	AH = 1Dh
Return: AL = 00h
----------211E-------------------------------
INT 21 - DOS internal - UNUSED
	AH = 1Eh
Return: AL = 00h
----------211F-------------------------------
INT 21 - DOS internal - GET DEFAULT DRIVE PARAMETER BLOCK
	AH = 1Fh
Return: AL = 00h No Error
	     FFh Error
	DS:BX -> drive parameter block (see below for DOS 1.x, AH=32h others)
Note:	for DOS 2+, this just invokes function 32h with DL = 00h
SeeAlso: AH=32h

Format of Eagle MSDOS 1.25 drive parameter block:
Offset	Size	Description
 00h	BYTE	entry number
 01h	BYTE	physical drive number
 02h	WORD	bytes per sector
 04h	BYTE	number of sectors per cluster - 1
 05h	BYTE	???
 06h	WORD	starting sector number of first FAT
 08h	BYTE	number of copies of FAT
 09h	WORD	number of directory entries
 0Bh	WORD	number of first data sector
 0Dh	WORD	number of clusters on disk
 0Fh	BYTE	sectors per FAT
 10h	WORD	starting sector of directory
 12h	WORD	address of allocation table
----------2120-------------------------------
INT 21 - DOS internal - UNUSED
	AH = 20h
Return: AL = 00h
----------2121-------------------------------
INT 21 - DOS - RANDOM DISK RECORD READ
	AH = 21h
	DS:DX -> FCB (see AH=0Fh)
Return: AL = status
	    00h successful read
	    01h end of file
	    02h data transfer area too small
	    03h partial record, EOF
SeeAlso: AH=3Fh
----------2122-------------------------------
INT 21 - DOS - RANDOM DISK RECORD WRITE
	AH = 22h
	DS:DX -> FCB (see AH=0Fh)
Return: AL = status
	    00h successful write
	    01h disk full
	    02h data transfer area too small
SeeAlso: AH=40h
----------2123-------------------------------
INT 21 - DOS - GET FILE SIZE
	AH = 23h
	DS:DX -> unopened FCB (see AH=0Fh) with filename and record size
		 fields initialized
Return: AL = status
	    00h file found
	    FFh file not found
Note:	FCB's random-record field set to number of records (rounded up)
SeeAlso: AH=42h
----------2124-------------------------------
INT 21 - DOS - SET RANDOM RECORD FIELD
	AH = 24h
	DS:DX -> open FCB (see AH=0Fh)
Return: Random Record Field of FCB is set to be same as Current Block
	and Current Record.
SeeAlso: AH=42h
----------2125-------------------------------
INT 21 - DOS - SET INTERRUPT VECTOR
	AH = 25h
	AL = interrupt number
	DS:DX = new vector to be used for specified interrupt
SeeAlso: AH=35h
----------212501-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - RESET 386/DOS-EXTENDER DATA STRUCTURES 
	AX = 2501h
Return: CF clear
Note:	Phar Lap uses INT 21/AH=25h as the entry point for all 386/DOS-Extender
	  system calls.  Only available when directly using 386/DOS-Extender,
	  or when using a product that was created using 386-DOS/Extender
----------212502-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - GET PROTECTED-MODE INTERRUPT VECTOR
	AX = 2502h
	CL = interrupt number
Return: ES:EBX -> 48-bit address of protected-mode interrupt handler
	CF clear
----------212503-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - GET REAL-MODE INTERRUPT VECTOR
	AX = 2503h
	CL = interrupt number
Return: EBX = 32-bit address of real-mode interrupt handler
	CF clear
SeeAlso: AX=2502h,2504h
----------212504-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - SET PROTECTED-MODE INTERRUPT VECTOR
	AX = 2504h
	CL = interrupt number
	DS:EDX -> 48-bit address of protected-mode interrupt handler
Return: CF clear
SeeAlso: AX=2502h,2505h
----------212505-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - SET REAL-MODE INTERRUPT VECTOR
	AX = 2505h
	CL = interrupt number
	EBX = 32-bit address of real-mode interrupt handler
Return: CF clear
SeeAlso: AX=2503h,2504h
----------212506-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - SET INT TO ALWAYS GAIN CONTRL IN PROT MODE
	AX = 2506h
	CL = interrupt number
	DS:EDX -> 48-bit address of protected-mode interrupt handler
Return: CF clear
Note:	This function modifies both the real-mode low-memory interrupt
	  vector table and the protected-mode Interrupt Descriptor Table (IDT)
	Interrupts occurring in real mode are resignaled in protected mode.
----------212507-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - SET REAL- & PROTECTED-MODE INT VECTORS
	AX = 2507h
	CL = interrupt number
	DS:EDX -> 48-bit address of protected-mode interrupt handler
	EBX = 32-bit address of real-mode interrupt handler
Return: CF clear
Note:	interrupts are disabled until both vectors have been modified
SeeAlso: AX=2504h,2505h
----------212508-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - GET SEGMENT LINEAR BASE ADDRESS
	AX = 2508h
	BX = segment selector
Return: CF clear if successful
	    ECX = linear base address of segment
	CF set if invalid segment selector
----------212509-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - CONVERT LINEAR TO PHYSICAL ADDRESS
	AX = 2509h
	EBX = linear address to convert
Return: CF clear if successful
	    ECX = physical address (carry flag clear)
	CF set if linear address not mapped in page tables
----------21250A-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - MAP PHYSICAL MEMORY AT END OF SEGMENT
	AX = 250Ah
	ES = segment selector in the Local Descriptor Table (LDT) of segment
	     to modify
	EBX = physical base address of memory to map (multiple of 4K)
	ECX = number of physical 4K pages to map
Return: CF clear if successful
	    EAX = 32-bit offset in segment of mapped memory
	CF set on error
	    EAX = error code
		08h insufficient memory to create page tables
		09h invalid segment selector
----------21250C-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - GET HARDWARE INTERRUPT VECTORS
	AX = 250Ch
Return: CF clear
	AL = base interrupt vector for IRQ0-IRQ7
	AH = base interrupt vector for IRQ8-IRQ15
	BL = interrupt vector for BIOS print screen function
----------21250D-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - GET REAL-MODE LINK INFORMATION
	AX = 250Dh
Return: CF clear
	EAX = 32-bit address of real-mode 386/DOS-Extender proc that will call
	      through from real mode to a protected-mode routine
	EBX = 32-bit real-mode address of intermode call data buffer
	ECX = size in bytes of intermode call data buffer
	ES:EDX -> protected-mode address of intermode call data buffer
----------21250E-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - CALL REAL-MODE PROCEDURE
	AX = 250Eh
	EBX = 32-bit address of real-mode procedure to call
	ECX = number of two-byte words to copy from protected-mode stack
	      to real-mode stack
Return: CF clear if successful
	    all segment registers unchanged
	    all general registers contain values set by real-mode procedure
	    all other flags set as they were left by real-mode procedure
	CF set on error
	    EAX = error code
		01h not enough real-mode stack space
----------21250F-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - CONVERT PROTECTED-MODE ADDRESS TO MS-DOS
	AX = 250Fh
	ES:EBX -> 48-bit protected-mode address to convert
	ECX = length of data, in bytes
Return: CF clear if successful
	    ECX = 32-bit MS-DOS address
	CF set on error
	    ECX destroyed
SeeAlso: AX=2510h
----------212510-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - CALL REAL-MODE PROCEDURE, REGISTERS
	AX = 2510h
	EBX = 32-bit address of real-mode procedure to call
	ECX = number of two-byte words to copy to protected-mode stack to
	      real-mode stack
	DS:EDX -> pointer to parameter block (see below)
Return: CF clear if successful
	    all segment registers unchanged,
	    EDX unchanged
	    all other general registers contain values set by real-mode proc
	    all other flags are set as they were left by real-mode procedure
	    real-mode register values are returned in the parameter block
	CF set on error
	    EAX = error code
		01h not enough real-mode stack space
SeeAlso: AX=250Fh

Format of parameter block:
Offset	Size	Description
 00h	WORD	real-mode DS value
 02h	WORD	real-mode ES value
 04h	WORD	real-mode FS value
 06h	WORD	real-mode GS value
 08h	DWORD	real-mode EAX value
 0Ch	DWORD	real-mode EBX value
 10h	DWORD	real-mode ECX value
 14h	DWORD	real-mode EDX value
----------212511-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - ISSUE REAL-MODE INTERRUPT
	AX = 2511h
	DS:EDX -> pointer to parameter block (see below)
Return: all segment registers unchanged
	EDX unchanged
	all other registers contain values set by the real-mode int handler
	the flags are set as they were left by the real-mode interrupt handler
	real-mode register values are returned in the parameter block
SeeAlso: AX=2503h,2505h

Format of parameter block:
Offset	Size	Description
 00h	WORD	interrupt number
 02h	WORD	real-mode DS value
 04h	WORD	real-mode ES value
 06h	WORD	real-mode FS value
 08h	WORD	real-mode GS value
 0Ah	DWORD	real-mode EAX value
 0Eh	DWORD	real-mode EDX value
Note: all other real-mode values set from protected-mode registers
----------212512-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - LOAD PROGRAM FOR DEBUGGING
	AX = 2512h
	DS:EDX -> pointer to ASCIIZ program name
	ES:EBX -> pointer to parameter block (see below)
	ECX = size in bytes of LDT buffer
Return: CF clear if successful
	    EAX = number of segment descriptors in LDT
	CF set on error
	    EAX = error code
		02h file not found or path invalid
		05h access denied
		08h insufficient memory
		0Ah environment invalid
		0Bh invalid file format
		80h LDT too small

Format of parameter block:
Offset	Size	Description
Input:
 00h	DWORD	32-bit offset of environment string
 04h	WORD	segment of environment string
 06h	DWORD	32-bit offset of command-tail string
 0Ah	WORD	segment of command-tail string
 0Ch	DWORD	32-bit offset of LDT buffer (size in ECX)
 10h	WORD	segment of LDT buffer
Output:
 12h	WORD	real-mode paragraph address of PSP (see also AH=26h)
 14h	WORD	real/protected mode flag
		0000h  real mode
		0001h  protected mode
 16h	DWORD	initial EIP value
 1Ah	WORD	initial CS value
 1Ch	DWORD	initial ESP value
 20h	WORD	initial SS value
 22h	WORD	initial DS value
 24h	WORD	initial ES value
 26h	WORD	initial FS value
 28h	WORD	initial GS value
----------212513-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - ALIAS SEGMENT DESCRIPTOR
	AX = 2513h
	BX = segment selector of descriptor in GDT or LDT
	CL = access-rights byte for alias descriptor
	CH = use-type bit (USE16 or USE32) for alias descriptor
Return: CF clear if successful
	    AX = segment selector for created alias
	CF set on error
	    EAX = error code
		08h insufficient memory (can't grow LDT)
		09h invalid segment selector in BX
----------212514-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - CHANGE SEGMENT ATTRIBUTES
	AX = 2514h
	BX = segment selector of descriptor in GDT or LDT
	CL = new access-rights byte 
	CH = new use-type bit (USE16 or USE32)
Return: CF clear if successful
	CF set on error
	    EAX = error code
		09h invalid selector in BX
SeeAlso: AX=2515h
----------212515-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - GET SEGMENT ATTRIBUTES
	AX = 2515h
	BX = segment selector of descriptor in GDT or LDT
Return: CF clear if successful
	    CL = access-rights byte for segment
	    CH = use-type bit (USE16 or USE32)
	ECX<16-31> destroyed
	CF set on error
	    EAX = error code
		09h invalid segment selector in BX
SeeAlso: AX=2514h
----------212516-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - FREE ALL MEMORY OWNED BY LDT
	AX = 2516h
	???
Return: ???
----------212517-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - GET INFO ON DOS DATA BUFFER
	AX = 2517h
	???
Return: ???
----------212518-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - SPECIFY HANDLER FOR MOVED SEGMENTS
	AX = 2518h
	???
Return: ???
----------212519-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - GET ADDITIONAL MEMORY ERROR INFO
	AX = 2519h
Return: CF clear
	EAX = error code
	    0000h  no error
	    0001h  out of physical memory
	    0002h  out of swap space (unable to grow swap file)
	    0003h  out of LDT entries and unable to grow LDT
	    0004h  unable to change extended memory allocation mark
	    FFFFFFFFh	paging disabled
Note:	VMM is the Virtual Memory Manager option
----------21251A-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - LOCK PAGES IN MEMORY
	AX = 251Ah
	EDX = number of 4k pages to lock
	if BL = 00h
	    ECX = linear address of first page to lock
	if BL = 01h
	    ES:ECX -> pointer to first page to lock
Return: CF clear if successful
	CF set on error
	    EAX = error code
		08h insufficient memory
		09h invalid address range
SeeAlso: AX=251Bh
----------21251B-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - UNLOCK PAGES
	AX = 251Bh
	EDX = number of pages to unlock
	if BL = 00h
	    ECX = linear address of first page to unlock
	if BL = 01h
	    ES:ECX -> pointer to first page to unlock
Return: CF clear if successful
	CF set on error
	    EAX = error code
		09h invalid address range
SeeAlso: AX=251Ah
----------21251D-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - READ PAGE-TABLE ENTRY
	AX = 251Dh
	???
Return: ???
----------21251E-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - WRITE PAGE-TABLE ENTRY
	AX = 251Eh
	???
Return: ???
----------21251F-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - EXHANGE TWO PAGE-TABLE ENTRIES
	AX = 251Fh
	???
Return: ???
----------212520-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - GET MEMORY STATISTICS
	AX = 2520h
	DS:EDX -> pointer to buffer at least 100 bytes in size (see below)
	BL = 0 (don't reset VM stats), 1 (reset VM stats)
Return: carry flag clear    

Format of VM stats buffer:
Offset	Size	Description
 00h	DWORD	VM status
		0001h VM subsystem is present
		0000h VM not present
 04h	DWORD	"nconvpg" number of conventional memory pages available
 08h	DWORD	"nbimpg" number of Compaq built-in memory pages available
 0Ch	DWORD	"nextpg" total number of extended memory pages
 10h	DWORD	"extlim" extender memory pages limit
 14h	DWORD	"aphyspg" number of physical memory pages allocated to appl
 18h	DWORD	"alockpg" number of locked pages owned by application
 1Ch	DWORD	"sysphyspg" number physical memory pages allocated to system
 20h	DWORD	"nfreepg" number of free physical pages; approx if EMS VCPI
 24h	DWORD	linear address of beginning of application address space
 28h	DWORD	linear address of end of application address space
 2Ch	DWORD	number of seconds since last time VM stats were reset
 30h	DWORD	number of page faults since last time
 34h	DWORD	number of pages written to swap file since last time
 38h	DWORD	number of reclaimed pages (page faults on swapped pages)
 3Ch	DWORD	number of virtual pages allocated to the application
 40h	DWORD	size in pages of swap file
 44h	DWORD	number of system pages allocated with EMS calls
 48h	DWORD	minimum number of conventional memory pages
 4Ch	DWORD	maximum size in bytes to which swap file can be increased
 50h	DWORD	"vmflags" bit 0 = 1 if page fault in progress
 54h 16 BYTEs	reserved for future expansion (set to zero)
----------212521-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - LIMIT PROGRAM'S EXTENDED MEMORY USAGE
	AX = 2521h
	EBX = max 4k pages of physical extended memory which program may use
Return: CF clear if successful
	   EBX = maximum limit in pages
	   ECX = minimum limit in pages
	CF set on error
	    EAX = error code
		08h insufficient memory or -nopage switch used
SeeAlso: AX=2522h
----------212522-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - SPECIFY ALTERNATE PAGE-FAULT HANDLER
	AX = 2522h
	???
Return: ???
----------212523-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - SPECIFY OUT-OF-SWAP-SPACE HANDLER
	AX = 2523h
	???
Return: ???
----------212524-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - INSTALL PAGE-REPLACEMENT HANDLERS
	AX = 2524h
	???
Return: ???
----------212525-----------------------------
INT 21 - Phar Lap 386/DOS-Extender VMM - LIMIT PROGRAM'S CONVENTIONAL MEM USAGE
	AX = 2525h
	EBX = limit in 4k pages of physical conventional memory which program 
	      may use
Return: CF clear if successful
	    EBX = maximum limit in pages
	    ECX = minimum limit in pages
	CF set on error
	    EAX = error code
		08h insufficient memory or -nopage switch used
SeeAlso: AX=2521h
----------212526-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - GET CONFIGURATION INFORMATION
	AX = 2526h
	???
Return: ???
----------2125C0-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - ALLOCATE MS-DOS MEMORY BLOCK
	AX = 25C0h
	BX = number of 16-byte paragraphs of MS-DOS memory requested
Return: CF clear if successful
	    AX = real-mode paragraph address of memory
	CF set on error
	    AX = error code
		07h MS-DOS memory control blocks destroyed
		08h insufficient memory
	    BX = size in paragraphs of largest available memory block
SeeAlso: AX=25C1h,25C2h
----------2125C1-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - RELEASE MS-DOS MEMORY BLOCK
	AX = 25C1h
	CX = real-mode paragraph address of memory block to free
Return: CF clear if successful
	    EAX destroyed
	CF set on error
	    AX = error code
		07h MS-DOS memory control blocks destroyed
		09h invalid memory block address in CX
SeeAlso: AX=25C0h,25C2h
----------2125C2-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - MODIFY MS-DOS MEMORY BLOCK
	AX = 25C2h
	BX = new requested block size in paragraphs
	CX = real-mode paragraph address of memory block to modify
Return: CF clear if successful
	    EAX destroyed
	CF set on error
	    AX = error code
		07h MS-DOS memory control blocks destroyed
		08h insufficient memory
		09h invalid memory block address in CX
	    BX = size in paragraphs of largest available memory block
SeeAlso: AX=25C0h,25C1h
----------2125C3-----------------------------
INT 21 - Phar Lap 386/DOS-Extender - EXECUTE PROGRAM
	AX = 25C3h
	ES:EBX -> pointer to parameter block (see below)
	DS:EDX -> pointer to ASCIIZ program filename
Return: CF clear if successful
	    all registers unchanged
	CF set on error
	    EAX = error code
		01h function code in AL is invalid ???
		02h file not found or path invalid
		05h access denied
		08h insufficient memory to load program
		0Ah environment invalid
		0Bh invalid file format

Format of parameter block:
Offset	Size	Description
 00h	DWORD	32-bit offset of environment string
 04h	WORD	segment selector of environment string
 06h	DWORD	32-bit offset of command-tail string
 0Ah	WORD	segment selector of command-tail string
----------2126-------------------------------
INT 21 - DOS - CREATE PSP
	AH = 26h
	DX = segment number at which to set up PSP
Return: current PSP is copied to specified segment
Notes:	new PSP is updated with memory size information; INTs 22h, 23h, 24h
	  taken from interrupt vector table
	(DOS 2+) DOS assumes that the caller's CS is the segment of the PSP to
	  copy
SeeAlso: AH=50h,AH=51h,AH=55h,AH=62h,AH=67h

Format of PSP:
Offset	Size	Description
 00h  2 BYTEs	program exit point (INT 20h instruction)
 02h  	WORD	memory size in paragraphs
 04h	BYTE	unused
 05h  5 BYTEs	CP/M entry point (FAR jump to 000C0h)
		BUG: (DOS 2+) PSPs created by INT 21/AH=4Bh point at 000BEh
 06h	WORD	CP/M compatibility--size of first segment for .COM files
 0Ah	DWORD	terminate address (old INT 22h)
 0Eh	DWORD	break address (old INT 23h)
 12h	DWORD	critical error handler (old INT 24h)
 16h	WORD	parent PSP segment
 18h 20 BYTEs	DOS 2+ open file table, FFh = unused
 2Ch	WORD	DOS 2+ environment segment (see below)
 2Eh	DWORD	DOS 2+ process's SS:SP on entry to last INT 21 call
 32h	WORD	DOS 3+ max open files
 34h	DWORD	DOS 3+ open file table address
 38h	DWORD	DOS 3+ pointer to previous PSP (default FFFFFFFFh in 3.x)
		used by SHARE in DOS 3.3
 3Ch 20 BYTEs	unused by DOS versions <= 4.01
 50h  3 BYTEs	DOS function dispatcher (FAR routine)--CDh 21h CBh
 53h  9 BYTEs	unused
 5Ch 16 BYTEs	FCB #1 (see AH=0Fh), filled in from first commandline argument
		(when opened, overwrites following FCB)
 6Ch 20 BYTEs	FCB #2 (see AH=0Fh), filled in from second commandline argument
		(when opened, overwrites part of command tail)
 80h 128 BYTEs	command tail / default DTA buffer
		command tail is BYTE for length of tail, N BYTEs for the tail,
		followed by a BYTE containing 0Dh
Notes:	in DOS versions 3.0 and up, the limit on simultaneously open files may
	  be increased by allocating memory for a new open file table, filling
	  it with FFh, copying the first 20 bytes from the default table, and
	  adjusting the pointer and count at 34h and 32h.  However, DOS
	  versions through  at least 3.30 will only copy the first 20 file
	  handles into a child PSP (including the one created on EXEC).
	network redirectors based on the original MS-Net implementation use
	  values of 80h-FEh in the open file table to indicate remote files

Format of environment block:
Offset	Size	Description
 00h  N BYTEs	first environment variable, ASCIZ string of form "var=value"
      N BYTEs	second environment variable, ASCIZ string
	...
      N BYTEs	last environment variable, ASCIZ string of form "var=value"
	BYTE	00h
---DOS 3+---
	WORD	number of strings following environment (normally 1)
      N BYTEs	ASCIZ full pathname of program owning this environment
		other strings may follow
----------2127-------------------------------
INT 21 - DOS - RANDOM BLOCK READ
	AH = 27h
	DS:DX -> FCB (see AH=0Fh)
	CX = number of records to be read
Return: AL = status
	    00h successful read
	    01h end of file
	    02h data transfer area too small
	    03h partial record, EOF
SeeAlso: AH=3Fh
----------2128-------------------------------
INT 21 - DOS - RANDOM BLOCK WRITE
	AH = 28h
	DS:DX -> FCB (see AH=0Fh)
	CX = number of records to be written
	     if zero, truncate file to current random file position
Return: AL = status
	    00h successful write
	    01h disk full
	    02h data transfer area too small
SeeAlso: AH=40h
----------2129-------------------------------
INT 21 - DOS - PARSE FILENAME
	AH = 29h
	DS:SI -> string to parse
	ES:DI -> buffer to fill with unopened FCB (see AH=0Fh)
	AL = bit mask to control parsing
	    0 = 0: parsing stops if file separator found
		1: leading separators ignored
	    1 = 0: drive number in FCB set to default drive if not present
		   in string
		1: drive number in FCB not changed
	    2 = 0: filename in FCB set to blanks if no filename in string
		1: filename in FCB not changed if string does not contain
		   a filename
	    3 = 0: extension in FCB set to blanks if no extension in string
		1: extension left unchanged
Return: AL = 00h no wildcards in name or extension
	     01h wildcards appeared
	     FFh drive specifier invalid
	DS:SI -> first byte after parsed string
	ES:DI buffer filled with unopened FCB
Notes:	asterisks expanded to question marks in the FCB
	all processing stops when a filename terminator is encountered
	cannot be used with filespecs which include a path (DOS 2+)
----------212A-------------------------------
INT 21 - DOS - GET CURRENT DATE
	AH = 2Ah
Return: DL = day
	DH = month
	CX = year
	AL = day of the week (0=Sunday, 1=Monday, etc.)
SeeAlso: AH=2Bh"DOS",AH=2Ch,AH=E7h,INT 1A/AH=04h
----------212B-------------------------------
INT 21 - DOS - SET CURRENT DATE
	AH = 2Bh
	DL = day
	DH = month
	CX = year
Return: AL = 00h if no error
	   = FFh if bad value sent to routine
Note:	DOS 3.3+ also sets CMOS clock
SeeAlso: AH=2Ah,AH=2Dh,INT 1A/AH=05h
----------212B--CX4445-----------------------
INT 21 - DESQview - INSTALLATION CHECK
	AH = 2Bh
	AL = subfunction (DV v2.00+)
	    01h get version
		Return: BX = version (BH = major, BL = minor)
		Note: early copies of v2.00 return 0002h
	    02h get shadow buffer info, and start shadowing
		Return: BH = rows in shadow buffer
			BL = columns in shadow buffer
			DX = segment of shadow buffer
	    04h get shadow buffer info
		Return: BH = rows in shadow buffer
			BL = columns in shadow buffer
			DX = segment of shadow buffer
	    05h stop shadowing
	CX = 4445h ('DE')
	DX = 5351h ('SQ')
Return: AL = FFh if DESQview not installed
Note:	in DESQview v1.x, there were no subfunctions; this call only identified
	whether or not DESQview was loaded
SeeAlso: INT 10/AH=FEh,FFh
----------212B--CX4358-----------------------
INT 21 - PC Tools v5.1 PC-CACHE - INSTALLATION CHECK
	AH = 2Bh
	CX = 4358h ('CX')
Return: AL = FFh if PC-CACHE not installed
	AL = 00h if installed
	    CX = 6378h ('cx')
	    BX = ???
	    DX = ???
----------212B01CX5441-----------------------
INT 21 - TAME v2.10 - INSTALLATION CHECK
	AX = 2B01h
	CX = 5441h ('TA')
	DX = 4D45h ('ME')
Return: AL = 02h if installed
	ES:DX -> data area in TAME-RES (see below)
Note:	TAME is a shareware program by David G. Thomas which gives up CPU time
	  to other partitions under a multitasker when the current partition's
	  program incessantly polls the keyboard or system time

Format of TAME 2.10-2.20 data area:
Offset	Size	Description
 00h	BYTE	data structure minor version number (01h in TAME 2.20)
 01h	BYTE	data structure major version number (07h in TAME 2.20)
 02h	DWORD	number of task switches
 06h	DWORD	number of keyboard polls
 0Ah	DWORD	number of time polls
 0Eh	DWORD	number of times DESQview told program runs only in foreground
 12h	DWORD	original INT 10h
 16h	DWORD	original INT 14h
 1Ah	DWORD	original INT 15h
 1Eh	DWORD	original INT 16h
 22h	DWORD	original INT 17h
 26h	DWORD	original INT 21h
 2Ah	DWORD	original INT 28h
 2Eh	WORD	offset of TAME INT 10h handler
 30h	WORD	offset of TAME INT 14h handler
 32h	WORD	offset of TAME INT 15h handler
 34h	WORD	offset of TAME INT 16h handler
 36h	WORD	offset of TAME INT 17h handler
 38h	WORD	offset of TAME INT 21h handler
 3Ah	WORD	offset of TAME INT 28h handler
 3Ch	WORD	X in /max:X,Y or /freq:X,Y
 3Eh	WORD	Y in /max:X,Y or /freq:X,Y
 40h	WORD	number of polls remaining before next task switch
 42h	WORD	/KEYIDLE value
 44h	BYTE	flags for interrupts already grabbed by TAME
		bit 0: INT 10h
		    1: INT 14h
		    2: INT 15h
		    3: INT 16h
		    4: INT 17h
		    5: INT 21h
		    6: INT 28h
 45h	BYTE	flags for interrupts which may be acted on (same bits as above)
 46h	BYTE	TAME enabled (01h) or disabled (00h)
 47h	BYTE	/TIMEPOLL (01h) or /NOTIMEPOLL (00h)
 48h	BYTE	/NOTIMER (01h) or /TIMER (00h)
 49h	BYTE	window or task number for this task
 4Ah	BYTE	multitasker type ???
		01h DESQview
		02h DoubleDOS
		03h TopView
		???
 4Bh	BYTE	type of task switching selected
		bit 0: DESQview???
		    1: DoubleDOS???
		    2: TopView???
		    3: KeySwitch
		    4: HLT instruction
 4Ch	BYTE	???
 4Dh	BYTE	flags
		bit 1: /FREQ instead of /MAX
 4Eh	BYTE	/FG: value
 4Fh	BYTE	task switches left until next FGONLY DESQview API call
 50h	BYTE	???

Format of TAME 2.30 data area:
Offset	Size	Description
 00h	BYTE	data structure minor version number (02h in TAME 2.30)
 01h	BYTE	data structure major version number (0Ah in TAME 2.30)
 02h	DWORD	number of task switches
 06h	DWORD	number of keyboard polls
 0Ah	DWORD	number of time polls
 0Eh	DWORD	number of times DESQview told program runs only in foreground
 12h	DWORD	time of last /CLEAR or TAME-RES load
 16h	DWORD	time yielded
 1Ah	DWORD	time spent polling
 1Eh	DWORD	time spent waiting on key input with INT 16/AH=01h,11h
 22h	DWORD	original INT 10h
 26h	DWORD	original INT 14h
 2Ah	DWORD	original INT 15h
 2Eh	DWORD	original INT 16h
 32h	DWORD	original INT 17h
 36h	DWORD	original INT 21h
 3Ah	DWORD	original INT 28h
 3Eh	WORD	offset of TAME INT 10h handler
 40h	WORD	offset of TAME INT 14h handler
 42h	WORD	offset of TAME INT 15h handler
 44h	WORD	offset of TAME INT 16h handler
 46h	WORD	offset of TAME INT 17h handler
 48h	WORD	offset of TAME INT 21h handler
 4Ah	WORD	offset of TAME INT 28h handler
 4Ch	WORD	X in /max:X,Y or /freq:X,Y
 4Eh	WORD	Y in /max:X,Y or /freq:X,Y
 50h	WORD	number of polls remaining before next task switch
 52h	WORD	/KEYIDLE value
 54h	WORD	/FG: value
 56h	WORD	task switches left until next FGONLY DESQview API call
 58h	WORD	multitasker version
 5Ah	WORD	virtual screen segment
 5Ch	BYTE	flags for interrupts already grabbed by TAME
		bit 0: INT 10h
		    1: INT 14h
		    2: INT 15h
		    3: INT 16h
		    4: INT 17h
		    5: INT 21h
		    6: INT 28h
 5Dh	BYTE	flags for interrupts which may be acted on (same bits as above)
 5Eh	BYTE	window or task number for this task
 5Fh	BYTE	multitasker type
		01h DESQview
		02h DoubleDOS
		03h TopView
		04h OmniView
		05h VM/386
 60h	BYTE	type of task switching selected (bit flags)
		bit 0: DESQview
		    1: DoubleDOS
		    2: TopView
		    3: OmniView
		    4: KeySwitch
		    5: HLT instruction
 61h	BYTE	watch_DOS
 62h	BYTE	bit flags
		bit 0: TAME enabled
		    1: /FREQ instead of /MAX (counts in 3Ch and 3Eh per tick)
		    2: /TIMEPOLL
		    3: /KEYPOLL
		    4: inhibit timer
		    5: enable status monitoring
 63h	BYTE	old status
 64h	WORD	signature DA34h
----------212C-------------------------------
INT 21 - DOS - GET CURRENT TIME
	AH = 2Ch
Return: CH = hours
	CL = minutes
	DH = seconds
	DL = hundredths of seconds
Note:	time is updated approximately every 5/100 second
SeeAlso: AH=2Ah,AH=2Dh,AH=E7h,INT 1A/AH=00h,02h,FEh
----------212D-------------------------------
INT 21 - DOS - SET CURRENT TIME
	AH = 2Dh
	CH = hours
	CL = minutes
	DH = seconds
	DL = hundredths of seconds
Return: AL = 00h if no error
	   = FFh if bad value sent to routine
Note:	DOS 3.3+ also sets CMOS clock
SeeAlso: AH=2Bh"DOS",AH=2Ch,INT 1A/AH=01h,03h,FFh
----------212E-------------------------------
INT 21 - DOS - SET VERIFY FLAG
	AH = 2Eh
	DL = 00h
	AL = 01h VERIFY on
	     00h VERIFY off
Note:	when ON, all disk writes are verified
SeeAlso: AH=54h
----------212F-------------------------------
INT 21 - DOS 2+ - GET DISK TRANSFER AREA ADDRESS
	AH = 2Fh
Return: ES:BX -> DTA
SeeAlso: AH=1Ah
----------2130-------------------------------
INT 21 - DOS 2+ - GET DOS VERSION
	AH = 30h
Return: AL = major version number (00h for DOS 1.x)
	AH = minor version number
	BH = OEM number
	    00h IBM
	    16h DEC
	    99h	STARLITE architecture (OEM DOS, NETWORK DOS, SMP DOS)
	    FFh Phoenix
	BL:CX = 24-bit user number
Notes:	the OS/2 Compatibility Box returns 0Ah for the major version
	DOS 4.01 and 4.02 identify themselves as version 4.00
----------2130-------------------------------
INT 21 - Phar Lap 386/DOS-Extender - GET VERSION
	AH = 30h
	EBX = 50484152h ("PHAR")
Return: ???
----------213000BX1234-----------------------
INT 21 - CTask 2.0 - INSTALLATION CHECK
	AX = 3000h
	BX = 1234h
	DS:DX -> version string??? (8 bytes)
Return: AL = DOS major version
	AH = DOS minor version
	CX:BX -> ???
Notes:	if first eight bytes of returned data block equal eight bytes passed
	  in, CTask is resident
	CTask is a multitasking kernel for C written by Thomas Wagner
----------2131-------------------------------
INT 21 - DOS 2+ - TERMINATE BUT STAY RESIDENT
	AH = 31h
	AL = exit code
	DX = program size, in paragraphs
Note:	most TSRs can save some memory by releasing their environment block
	  before terminating (see AH=26h,AH=49h)
SeeAlso: AH=00h,AH=4Ch,INT 20, INT 22, INT 27
----------2132-------------------------------
INT 21 - DOS 2+ internal - GET DRIVE PARAMETER BLOCK
	AH = 32h
	DL = drive number
	    0 = default, 1 = A, etc.
Return: AL = FFh if invalid drive number, else
	DS:BX -> drive parameter block (see below)
Note:	the OS/2 compatibility box supports the DOS 3.3 version of this call
	  except for the DWORD at offset 12h
SeeAlso: AH=1Fh

Format of DOS Drive Parameter Block:
Offset	Size	Description
 00h	BYTE	drive number (0 = A, etc.)
 01h	BYTE	unit number within device driver
 02h	WORD	number of bytes per sector
 04h	BYTE	largest sector number in cluster (one less than sect/clust)
 05h	BYTE	log base two of the cluster size
 06h	WORD	number of reserved (boot) sectors
 08h	BYTE	number of copies of the FAT
 09h	WORD	number of root directory entries
 0Bh	WORD	first data sector on medium
 0Dh	WORD	largest possible cluster number (one more than # data clust)
---DOS 2.x---
 0Fh	BYTE	number of sectors in one FAT copy
 10h	WORD	first sector of root directory
 12h	DWORD	address of device driver for this drive
 16h	BYTE	media descriptor byte for medium
 17h	BYTE	FFh indicates block must be rebuilt
 18h	DWORD	address of next device block, offset = FFFFh indicates last
 1Ch	WORD	starting cluster of current directory (0 = root directory)
 1Eh 64 BYTEs	ASCIZ current directory path string
---DOS 3.x---
 0Fh	BYTE	number of sectors in one FAT copy
 10h	WORD	first sector of root directory
 12h	DWORD	address of device driver for this drive
 16h	BYTE	media descriptor byte for medium
 17h	BYTE	FFh = block must be rebuilt, 00h indicates block accessed
 18h	DWORD	address of next device block, offset = FFFFh indicates last
 1Ch	WORD	cluster at which to start search for free space when writing
 1Eh	WORD	number of free clusters on drive, FFFFh = unknown
---DOS 4.0---
 0Fh	WORD	number of sectors in one FAT copy
 11h	WORD	first sector of root directory
 13h	DWORD	address of device driver for this drive
 17h	BYTE	media descriptor byte for medium
 18h	BYTE	FFh = block must be rebuilt, 00h indicates block accessed
 19h	DWORD	address of next device block, offset = FFFFh indicates last
 1Dh	WORD	cluster at which to start search for free space when writing
 1Fh	WORD	number of free clusters on drive, FFFFh = unknown
----------2133-------------------------------
INT 21 - DOS 2+ - EXTENDED CONTROL-BREAK CHECKING
	AH = 33h
	AL = subfunction
	    00h get state
		Return: DL = current BREAK setting
			    00h BREAK=OFF
			    01h BREAK=ON
	    01h set state
		DL = 00h for OFF or 01h for ON
Return:	AL = FFh if error
Note:	under DOS 3+, this function does not use any of the DOS-internal stacks
	  and is thus fully reentrant
SeeAlso: AX=3302h
----------213302-----------------------------
INT 21 - DOS 3.x internal - GET AND SET EXTENDED CONTROL-BREAK CHECKING STATE
	AX = 3302h
	DL = new state
	     00h for OFF or 01h for ON
Return: DL = old state of extended BREAK checking
Note:	this function does not use any of the DOS-internal stacks and is thus
	  fully reentrant
SeeAlso: AH=33h
----------213305-----------------------------
INT 21 - DOS 4.0 - GET BOOT DRIVE
	AX = 3305h
Return: DL = boot drive (1=A:,...)
----------2134-------------------------------
INT 21 - DOS 2+ internal - RETURN CritSectFlag (InDOS) POINTER
	AH = 34h
Return: ES:BX -> 1-byte DOS "Critical Section Flag", also known as InDOS flag
Notes:	when the critical section flag is nonzero, code within DOS is being
	  executed.  It is safe to enter DOS when both the critical section
	  flag and the critical error flag are zero.
	The critical error flag is the byte after the critical section flag in
	  DOS 2.x, and the byte BEFORE the critical section flag in DOS 3.x 
	  (except COMPAQ DOS 3.0, where the critical error flag is located 1AAh
	  bytes BEFORE the critical section flag)
	For DOS 3.1+, an undocumented call exists to get the address of the
	  critical error flag (see AX=5D06h)
SeeAlso: AX=5D06h, AX=5D0Bh
----------2135-------------------------------
INT 21 - DOS 2+ - GET INTERRUPT VECTOR
	AH = 35h
	AL = interrupt number
Return: ES:BX = value of interrupt vector
SeeAlso: AH=25h
----------2136-------------------------------
INT 21 - DOS 2+ - GET DISK SPACE
	AH = 36h
	DL = drive code (0 = default, 1 = A, 2 = B, etc.)
Return: AX = number of sectors per cluster
	     or FFFFh if invalid drive
	BX = number of available clusters
	CX = bytes per sector
	DX = total clusters
Notes:	multiply AX * CX * BX for free space on disk
	multiply AX * CX * DX for total disk space
	according to Dave Williams' MSDOS reference, the value in DX is
	  incorrect for non-default drives after ASSIGN is run
SeeAlso: AH=1Bh,AH=1Ch
----------213700-----------------------------
INT 21 - DOS 2+ internal - GET SWITCHAR
	AX = 3700h
Return: AL = FFh unsupported subfunction
	DL = current switch character
Notes:	documented in some OEM versions of some releases of DOS
	supported by OS/2 compatibility box
SeeAlso: AX=3701h
----------213701-----------------------------
INT 21 - DOS 2+ internal - SET SWITCHAR
	AX = 3701h
	DL = new switch character
Return: AL = FFh unsupported subfunction
Notes:	documented in some OEM versions of some releases of DOS
	supported by OS/2 compatibility box
SeeAlso: AX=3700h
----------2137-------------------------------
INT 21 - DOS 2.x and 3.3+ internal - AVAILDEV
	AH = 37h
	AL = subfunction
	   02h read device availability (as set by AL=03h)
		Return: DL = device availability (always FFh under DOS 4.0)
	   03h set device availability, where:
		DL = 00h means \DEV\ must preceed device names
		DL <> 00h means \DEV\ need not preceed device names
Return: AL = FFh if invalid subfunction
Notes:	all versions of DOS from 2.00 allow \DEV\ to be prepended to device
	  names without generating an error even if the directory \DEV does
	  not actually exist (other paths generate an error if they do not
	  exist).
	although DOS 3.3+ accepts these calls, they have no effect
----------2138-------------------------------
INT 21 - DOS 2+ - GET COUNTRY-DEPENDENT INFORMATION
	AH = 38h
--DOS 2.x--
	AL = 00h get current-country info
	DS:DX -> buffer for returned info (see below)
Return: AX = country code (MSDOS 2.11 only)
	buffer at DS:DX filled
--DOS 3+--
	AL = 00h for current country
	AL = 01h thru 0FEh for specific country with code <255
	AL = 0FFh for specific country with code >= 255
	   BX = 16-bit country code
	DS:DX -> buffer for returned info (see below)
Return:	CF set on error
	    AX = error code (02h)
	CF clear if successful
	    BX = country code
	    DS:DX buffer filled
SeeAlso: AH=65h, INT 2F/AX=110Ch,1404h

Format of PCDOS 2.x country info:
Offset	Size	Description
 00h	WORD	date format  0 = USA	mm dd yy
			     1 = Europe dd mm yy
			     2 = Japan	yy mm dd
 02h	BYTE	currency symbol
 03h	BYTE	00h
 04h	BYTE	thousands separator char
 05h	BYTE	00h
 06h	BYTE	decimal separator char
 07h	BYTE	00h
 08h 24 BYTEs	reserved

Format of MSDOS 2.x, DOS 3+ country info:
Offset	Size	Description
 00h	WORD	date format (see above)
 02h  5 BYTEs	ASCIZ currency symbol string
 07h	BYTE	thousands separator char
 08h	BYTE	00h
 09h	BYTE	decimal separator char
 0Ah	BYTE	00h
 0Bh	BYTE	date separator char
 0Ch	BYTE	00h
 0Dh	BYTE	time separator char
 0Eh	BYTE	00h
 0Fh	BYTE	currency format
		bit 2 = set if currency symbol replaces decimal point
		bit 1 = number of spaces between value and currency symbol
		bit 0 = 0 if currency symbol precedes value
			1 if currency symbol follows value
 10h	BYTE	number of digits after decimal in currency
 11h	BYTE	time format
		bit 0 = 0 if 12-hour clock
			1 if 24-hour clock
 12h	DWORD	address of case map routine
		(FAR CALL, AL = char to map to upper case [>= 80h])
 16h	BYTE	data-list separator char
 17h	BYTE	00h
 18h 10 BYTEs	reserved
----------2138--DXFFFF-----------------------
INT 21 - DOS 3+ - SET COUNTRY CODE
	AH = 38h
	AL = 01h thru 0FEh for specific country with code <255
	AL = FFh for specific country with code >= 255
	   BX = 16-bit country code
	DX = FFFFh
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
SeeAlso: INT 2F/AX=1403h
----------2139-------------------------------
INT 21 - DOS 2+ - CREATE A SUBDIRECTORY (MKDIR)
	AH = 39h
	DS:DX -> ASCIZ pathname (may include drive)
Return: CF set on error
	    AX = error code (03h,05h) (see AH=59h)
	CF clear if successful
	    AX destroyed
Note:	all directories in the given path except the last must exist
SeeAlso: AH=3Ah,AH=3Bh, INT 2F/AX=1103h
----------213A-------------------------------
INT 21 - DOS 2+ - REMOVE A DIRECTORY ENTRY (RMDIR)
	AH = 3Ah
	DS:DX -> ASCIZ pathname (may include drive)
Return: CF set on error
	    AX = error code (03h,05h,06h,10h) (see AH=59h)
	CF clear if successful
	    AX destroyed
SeeAlso: AH=39h,AH=3Bh, INT 2F/AX=1101h
----------213B-------------------------------
INT 21 - DOS 2+ - CHANGE THE CURRENT DIRECTORY (CHDIR)
	AH = 3Bh
	DS:DX -> ASCIZ directory name (may include drive)
Return: CF set on error
	    AX = error code (03h) (see AH=59h)
	CF clear if successful
	    AX destroyed
Note:	if new directory name includes a drive letter, the default drive is
	  not changed, only the current directory on that drive
SeeAlso: AH=47h, INT 2F/AX=1105h
----------213C-------------------------------
INT 21 - DOS 2+ - CREATE A FILE WITH HANDLE (CREAT)
	AH = 3Ch
	CX = attributes for file
	    bit 0: read-only
		1: hidden
		2: system
		3: volume label (ignored)
		4: reserved, must be zero (directory)
		5: archive bit
		7: if set, file is shareable under Novell NetWare
	DS:DX -> ASCIZ filename (may include drive and path)
Return: CF set on error
	    AX = error code (03h,04h,05h) (see AH=59h)
	CF clear if successful
	    AX = file handle
Note:	if a file with the given name exists, it is truncated to zero length
SeeAlso: AH=16h,AH=3Dh,AH=5Ah,AH=5Bh
----------213D-------------------------------
INT 21 - DOS 2+ - OPEN DISK FILE WITH HANDLE
	AH = 3Dh
	AL = access mode
	    00h read only
	    01h write only
	    02h read/write
	AL bits 7-3 = file-sharing modes (DOS 3+)
	    bit 7    = inheritance flag, set for no inheritance
	    bits 4-6 = sharing mode
		      000 compatibility mode
		      001 exclusive (deny all)
		      010 write access denied (deny write)
		      011 read access denied (deny read)
		      100 full access permitted (deny none)
		      111 used internally by SHARE
	    bit 3    = reserved, should be zero
	DS:DX -> ASCIZ filename
Return: CF set on error
	    AX = error code (01h,02h,03h,04h,05h,0Ch) (see AH=59h)
	CF clear if successful
	    AX = file handle
Notes:	file pointer is set to start of file
	file handles which are inherited from a parent also inherit sharing
	  and access restrictions
SeeAlso: AH=0Fh,AH=3Ch,INT 2F/AX=1226h

File sharing behavior:
	  |	Second and subsequent Opens
 First	  |Compat  Deny	  Deny	 Deny	Deny
 Open	  |	   All	  Write	 Read	None
	  |R W RW R W RW R W RW R W RW R W RW
 - - - - -| - - - - - - - - - - - - - - - - -
 Compat	R |Y Y Y  N N N  1 N N	N N N  1 N N
	W |Y Y Y  N N N  N N N	N N N  N N N
	RW|Y Y Y  N N N  N N N	N N N  N N N
 - - - - -|
 Deny	R |C C C  N N N  N N N	N N N  N N N
 All	W |C C C  N N N  N N N	N N N  N N N
	RW|C C C  N N N  N N N	N N N  N N N
 - - - - -|
 Deny	R |2 C C  N N N  Y N N	N N N  Y N N 
 Write	W |C C C  N N N  N N N	Y N N  Y N N 
	RW|C C C  N N N  N N N	N N N  Y N N
 - - - - -|
 Deny	R |C C C  N N N  N Y N	N N N  N Y N
 Read	W |C C C  N N N  N N N	N Y N  N Y N
	RW|C C C  N N N  N N N	N N N  N Y N
 - - - - -|
 Deny	R |2 C C  N N N  Y Y Y	N N N  Y Y Y
 None	W |C C C  N N N  N N N	Y Y Y  Y Y Y
	RW|C C C  N N N  N N N	N N N  Y Y Y
Legend: Y = open succeeds, N = open fails with error code 05h
	C = open fails, INT 24 generated
	1 = open succeeds if file read-only, else fails with error code
	2 = open succeeds if file read-only, else fails with INT 24
----------213E-------------------------------
INT 21 - DOS 2+ - CLOSE A FILE WITH HANDLE
	AH = 3Eh
	BX = file handle
Return: CF set on error
	    AX = error code (06h) (see AH=59h)
	CF clear if successful
	    AX destroyed
Note:	if the file was written to, the time and date stamps are set to the
	  current time
SeeAlso: AH=10h,AH=3Ch,AH=3Dh,INT 2F/AX=1106h,1227h
----------213F-------------------------------
INT 21 - DOS 2+ - READ FROM FILE WITH HANDLE
	AH = 3Fh
	BX = file handle
	CX = number of bytes to read
	DS:DX -> buffer
Return: CF set on error
	    AX = error code (05h,06h) (see AH=59h)
	CF clear if successful
	    AX = number of bytes read (0 if at EOF before call)
Notes:	the returned AX may be smaller than the request in CX if a partial
	  read occurred
	if reading from CON, read stops at first CR
SeeAlso: AH=27h,AH=40h,INT 2F/AX=1108h,1229h
----------2140-------------------------------
INT 21 - DOS 2+ - WRITE TO FILE WITH HANDLE
	AH = 40h
	BX = file handle
	CX = number of bytes to write
	DS:DX -> buffer
Return: CF set on error
	    AX = error code (05h,06h) (see AH=59h)
	CF clear if successful
	    AX = number of bytes actually written
Notes:	if CX is zero, no data is written, and the file is truncated or
	  extended to the current position
	the usual cause for AX < CX on return is a full disk
SeeAlso: AH=28h,AH=3Fh,INT 2F/AX=1109h
----------2141-------------------------------
INT 21 - DOS 2+ - DELETE A FILE (UNLINK)
	AH = 41h
	DS:DX -> ASCIZ pathname of file to delete (no wildcards allowed)
Return: CF set on error
	    AX = error code (02h,05h) (see AH=59h)
	CF clear if successful
	    AX destroyed (DOS 3.3) AL seems to be drive of deleted file
Notes:	(DOS 3.1+) wildcards are allowed if invoked via AX=5D00h, in which case
	  the filespec must be canonical (as returned by AH=60h)
	deleting a file which is currently open may lead to filesystem
	  corruption.  Unless SHARE is loaded, DOS does not close the handles
	  referencing the deleted file, thus allowing writes to a nonexistent
	  file.
SeeAlso: AH=13h,AX=5D00h,AH=60h,INT 2F/AX=1113h
----------2142-------------------------------
INT 21 - DOS 2+ - MOVE FILE READ/WRITE POINTER (LSEEK)
	AH = 42h
	AL = method
	    00h offset from beginning of file
	    01h offset from present location
	    02h offset from end of file
	BX = file handle
	CX:DX = offset in bytes
Return: CF set on error
	    AX = error code (01h,06h) (see AH=59h)
	CF clear if successful
	    DX:AX = new absolute offset from beginning of file
SeeAlso: AH=24h,INT 2F/AX=1228h
----------214300-----------------------------
INT 21 - DOS 2+ - GET FILE ATTRIBUTES
	AX = 4300h
	DS:DX -> ASCIZ file name or directory name without trailing slash
Return: CF set on error
	    AX = error code (01h,02h,03h,05h) (see AH=59h)
	CF clear if successful
	    CX = file attributes (see AX=4301h)
SeeAlso: AX=4301h,AH=B6h,INT 2F/AX=110Fh
----------214301-----------------------------
INT 21 - DOS 2+ - PUT FILE ATTRIBUTES (CHMOD)
	AX = 4301h
	CX = file attribute bits
	    bit 0 = read only
		1 = hidden file
		2 = system file
		3 = volume label
		4 = subdirectory
		5 = written since backup ("archive" bit)
		8 = shareable (Novell NetWare)
	DS:DX -> ASCIZ file name
Return: CF set on error
	    AX = error code (01h,02h,03h,05h) (see AH=59h)
	CF clear if successful
Note:	will not change volume label or directory attributes
SeeAlso: AX=4300h,INT 2F/AX=110Eh
----------214400-----------------------------
INT 21 - DOS 2+ - IOCTL - GET DEVICE INFORMATION
	AX = 4400h
	BX = file or device handle
Return: CF set on error
	   AX = error code (see AH=59h)
	CF clear if successful
	   DX = device info
	   If bit 7 set: (character device)
	       bit 0: console input device
		   1: console output device
		   2: NUL device
		   3: CLOCK$ device
		   4: device is special (uses INT 29)
		   5: binary (raw) mode
		   6: Not EOF
		  11: media not removable???
		  12: network device (DOS 3+)
		  14: can process IOCTL control strings (see AL = 02h-05h)
	   If bit 7 clear: (file)
	       bits 0-5 are block device number
		   6: file has not been written
		  11: media not removable
		  12: network device (DOS 3+)
		  14: don't set file date/time on closing (DOS 3+)
		  15: file is remote (DOS 3+)
SeeAlso: AX=4401h,INT 2F/AX=122Bh
----------214401-----------------------------
INT 21 - DOS 2+ - IOCTL - SET DEVICE INFORMATION
	AX = 4401h
	BX = device handle
	DH = 0
	DL = device information to set (bits 0-7 from function 0)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
SeeAlso: AX=4400h,INT 2F/AX=122Bh
----------214402-----------------------------
INT 21 - DOS 2+ - IOCTL - READ CHARACTER DEVICE CONTROL STRING
	AX = 4402h
	BX = device handle
	CX = number of bytes to read
	DS:DX -> buffer
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    AX = number of bytes read
SeeAlso: AX=4403h,AX=4404h,INT 2F/AX=122Bh
----------214402-----------------------------
INT 21 - Network Driver Interface Spec 2.0.1 - PROTOCOL MANAGER
	AX = 4402h
	BX = file handle for device "PROTMAN$"
	DS:DX -> request block (see below)
	CX = 000Eh (size of request block)

Format of request block for GetProtocolManagerInfo:
Offset	Size	Description
 00h	WORD	01h
 02h	WORD	returned status (see below)
 04h	DWORD	returned pointer to structure representing parsed user config
 08h	DWORD	unused
 0Ch	WORD	returned BCD version of NDIS on which Protocol Manager is based

Format of request block for RegisterModule:
Offset	Size	Description
 00h	WORD	02h
 02h	WORD	returned status (see below)
 04h	DWORD	pointer to module's common characteristics table (see below)
 08h	DWORD	pointer to list of modules to which the module is to be bound
 0Ch	WORD	unused

Format of request block for BindAndStart:
Offset	Size	Description
 00h	WORD	03h
 02h	WORD	returned status (see below)
 04h	DWORD	caller's virtual address in FailingModules structure
 08h	DWORD	unused
 0Ch	WORD	unused

Format of request block for GetProtocolManagerLinkage:
Offset	Size	Description
 00h	WORD	04h
 02h	WORD	returned status (see below)
 04h	DWORD	returned dispatch point
 08h	DWORD	unused
 0Ch	WORD	returned protocol manager DS
Note:	the dispatch point may be called as follows instead of using this IOCTL
	STACK: WORD  protocol manager DS
	       DWORD pointer to request block
	Return: AX = returned status
		STACK popped

Format of request block for GetProtocolIniPath:
Offset	Size	Description
 00h	WORD	05h
 02h	WORD	returned status (see below)
 04h	DWORD	pointer to a buffer for the ASCIZ pathname of PROTOCOL.INI
 08h	DWORD	unused
 0Ch	WORD	buffer length

Format of request block for RegisterProtocolManagerInfo:
Offset	Size	Description
 00h	WORD	06h
 02h	WORD	returned status (see below)
 04h	DWORD	pointer to structure containing parsed user config file
 08h	DWORD	unused
 0Ch	WORD	length of structure

Format of request block for InitAndRegister:
Offset	Size	Description
 00h	WORD	07h
 02h	WORD	returned status (see below)
 04h	DWORD	unused
 08h	DWORD	poitner to ASCIZ name of the module to be prebind initialized
 0Ch	WORD	unused

Format of request block for UnbindAndStop:
Offset	Size	Description
 00h	WORD	08h
 02h	WORD	returned status (see below)
 04h	DWORD	failing modules as for BindAndStart
 08h	DWORD	if not 0000h:0000h, pointer to ASCIZ name of module to unbind
		if 0000h:0000h, terminate a set of previously dynamically
		  bound protocol modules
 0Ch	WORD	unused

Format of request block for BindStatus:
Offset	Size	Description
 00h	WORD	09h
 02h	WORD	returned status (see below)
 04h	DWORD	must be 0000h:0000h
		on return, points to root tree
 08h	DWORD	0000h:0000h
 0Ch	WORD	unused under DOS

Format of request block for RegisterStatus:
Offset	Size	Description
 00h	WORD	0Ah
 02h	WORD	returned status (0000h, 0008h, 002Ch) (see below)
 04h	DWORD	0000h:0000h
 08h	DWORD	pointer to 16-byte ASCIZ module name
 0Ch	WORD	0000h

Values of status code:
 0000h success
 0001h wait for release--protocol has retained control of the data buffer
 0002h request queued
 0003h frame not recognized
 0004h frame rejected
 0005h frame should be forwarded
 0006h out of resource
 0007h invalid parameter
 0008h invalid function
 0009h not supported
 000Ah hardware error
 000Bh transmit error
 000Ch unrecognized destination
 000Dh buffer too small
 0020h already started
 0021h binding incomplete
 0022h driver not initialized
 0023h hardware not found
 0024h hardware failure
 0025h configuration failure
 0026h interrupt conflict
 0027h MAC incompatible
 0028h initialization failed
 0029h no binding
 002Ah network may be disconnected
 002Bh incompatible OS version
 002Ch already registered
 002Dh path not found
 002Eh insufficient memory
 002Fh info not found
 00FFh general failure
 F000h-FFFFh reserved for vendor-specific codes, treated as general failure

Format of common characteristics table:
Offset	Size	Description
 00h	WORD	size of table in bytes
 02h	BYTE	NDIS major version
 03h	BYTE	NDIS minor version
 04h	WORD	reserved
 06h	BYTE	module major version
 07h	BYTE	module minor version
 08h	DWORD	module function flag bits
		bit 0: binding at upper boundary supported
		bit 1: binding at lower boundary supported
		bit 2: dynamically bound
		bits 3-31 reserved, must be 0
 0Ch 16 BYTEs	ASCIZ module name
 1Ch	BYTE	upper boundary protocol level
		01h Media Access Control
		02h Data link
		03h network
		04h transport
		05h session
		FFh not specified
 1Dh	BYTE	upper boundary interface type
		for MACs: 1 = MAC
		for data links and transports: to be defined
		for session: 1 = NCB
		any level: 0 = private (ISV-defined)
 1Eh	BYTE	lower boundary protocol level
		00h physical
		01h Media Access Control
		02h Data link
		03h network
		04h transport
		05h session
		FFh not specified
 1Fh	BYTE	lower boundary interface type
		same as offset 1Dh
 20h	WORD	module ID filled in by protocol manager
 22h	WORD	module DS
 24h	DWORD	system request entry point
 28h	DWORD	pointer to service-specific characteristics
		0000h:0000h if none
 2Ch	DWORD	pointer to service-specific status
		0000h:0000h if none
 30h	DWORD	pointer to upper dispatch table (see below)
		0000h:0000h if none
 34h	DWORD	pointer to lower dispatch table (see below)
		0000h:0000h if none
 38h	DWORD	reserved, must be 0
 3Ch	DWORD	reserved, must be 0
Note:	for compatibility with NDIS 1.x.x, a major version of 00h is
	  interpreted as 01h

Format of MAC Service-Specific Characteristics Table:
Offset	Size	Description
 00h	WORD	length of table in bytes
 02h 16 BYTEs	ASCIZ MAC type name, "802.3", "802.4", "802.5", "802.6", "DIX",
		"DIX+802.3", "APPLETALK", "ARCNET", "FDDI", "SDLC", "BSC",
		"HDLC", or "ISDN"
 12h	WORD	length of station addresses in bytes
 14h 16 BYTEs	permanent station address
 24h 16 BYTEs	current station address
 34h	DWORD	current functional adapter address (00000000h if none)
 38h	DWORD	pointer to multicast address list
 3Ch	DWORD	link speed in bits/sec
 40h	DWORD	service flags
		bit 0: supports broadcast
		    1: supports multicast
		    2: supports functional/group addressing
		    3: supports promiscuous mode
		    4: station address software settable
		    5: statistics always current
		    6: supports InitiateDiagnostics
		    7: supports loopback
		    8: MAC does primarily ReceiveChain indications instead of
		       ReceiveLookahead indications
		    9: supports IBM source routing
		   10: supports MAC reset
		   11: supports Open/Close adapter
		   12: supports interrupt request
		   13: supports source routing bridge
		   14: supports GDT virtual addresses (OS/2 version)
		   15: multiple TransferDatas allowed durign a single
		       indication
		   16: MAC normally sets FrameSize = 0 in ReceiveLookahead
		   17-31: reserved, must be 0
 44h	WORD	maximum frame size which may be both sent and received
 46h	DWORD	total transmit buffer capacity in bytes
 4Ah	WORD	transmit buffer allocation block size in bytes
 4Ch	DWORD	total receive buffer capacity in bytes
 50h	WORD	receive buffer allocation block size in bytes
 52h  3 BYTEs	IEEE vendor code
 55h	BYTE	vendor adapter code
 56h	DWORD	pointer to ASCIZ vendor adapter description
 5Ah	WORD	IRQ used by adapter
 5Ch	WORD	transmit queue depth
 5Eh	WORD	maximum supported number of data blocks in buffer descriptors
 60h  N BYTEs	vendor-specific info

Format of NetBIOS Service-Specific Characteristics Table
Offset	Size	Description
 00h	WORD	length of table in bytes
 02h 16 BYTEs	ASCIZ type name of NetBIOS module
 12h	WORD	NetBIOS module code
 14h  N BYTEs	vendor-specific info

Format of MAC Service-Specific Status Table:
Offset	Size	Description
 00h	WORD	length of table in bytes
 02h	DWORD	seconds since 0:00 1/1/70 when diagnostics last run
		(FFFFFFFFh = never)
 06h	DWORD	MAC status bits
		bits 0-2: 000 hardware not installed
			  001 hardware failed startup diagnostics
			  010 hardware configuration problem
			  011 hardware fault
			  100 operating marginally due to soft faults
			  101 reserved
			  110 reserved
			  111 hardware fully operational
		bit 3:	  MAC bound
		    4:	  MAC open
		    5:	  diagnostics in progress
		    6-31: reserved
 0Ah	WORD	current packet filter flags
		bit 0: directed/multicast or group/functional
		    1: broadcast
		    2: promiscuous
		    3: all source routing
		    4-15: reserved, must be zero
 0Ch	DWORD	pointer to media-specific status table or 0000h:0000h
 10h	DWORD	seconds past 0:00 1/1/70 of last ClearStatistics
 14h	DWORD	total frames received (FFFFFFFFh = not counted)
 18h	DWORD	frames with CRC error (FFFFFFFFh = not counted)
 1Ch	DWORD	total bytes received (FFFFFFFFh = not counted)
 20h	DWORD	frames discarded--no buffer space (FFFFFFFFh = not counted)
 24h	DWORD	multicast frames received (FFFFFFFFh = not counted)
 28h	DWORD	broadcast frames received (FFFFFFFFh = not counted)
 2Ch	DWORD	frames with errors (FFFFFFFFh = not counted)
 30h	DWORD	overly large frames (FFFFFFFFh = not counted)
 34h	DWORD	frames less than minimum size (FFFFFFFFh = not counted)
 38h	DWORD	multicast bytes received (FFFFFFFFh = not counted)
 3Ch	DWORD	broadcast bytes received (FFFFFFFFh = not counted)
 40h	DWORD	frames discarded--hardware error (FFFFFFFFh = not counted)
 44h	DWORD	total frames transmitted (FFFFFFFFh = not counted)
 48h	DWORD	total bytes transmitted (FFFFFFFFh = not counted)
 4Ch	DWORD	multicast frames transmitted (FFFFFFFFh = not counted)
 50h	DWORD	broadcast frames transmitted (FFFFFFFFh = not counted)
 54h	DWORD	broadcast bytes transmitted (FFFFFFFFh = not counted)
 58h	DWORD	multicast bytes transmitted (FFFFFFFFh = not counted)
 5Ch	DWORD	frames not transmitted--timeout (FFFFFFFFh = not counted)
 60h	DWORD	frames not transmitted--hardware error (FFFFFFFFh = not countd)
 64h  N BYTEs	vendor-specific info
----------214402-----------------------------
INT 21 - IBM SYSTEM 36/38 WORKSTATION EMULATION - VDI.SYS - GET ???
	AX = 4402h
	BX = handle for character device "GDMS"
	CX = number of bytes to read (>= 4)
	DS:DX -> buffer (see below)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    AX = number of bytes read

Format of returned data:
Offset	Size	Description
 00h  4 BYTEs	???
 04h	DWORD	pointer to ???
 08h  4 BYTEs	???
----------214402-----------------------------
INT 21 - HIGHUMM.SYS - IOCTL - GET API ADDRESS
	AX = 4402h
	BX = handle for device "KSP$UMM"
	CX = 0004h
	DS:DX -> DWORD to hold entry point
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    AX = number of bytes read
Note:	HIGHUMM.SYS is part of "The Last Byte" by Key Software Products

Call HIGHUMM.SYS entry point with:
	AH = 00h allocate UMB (same as XMS function 10h) (see INT 2F/AX=4310h)
	    DX = size in paragraphs
	    Return: BX = segment number (if successful)
	    	    DX = size of requested block/size of largest block
	AH = 01h deallocate UMB (same as XMS func 11h) (see INT 2F/AX=4310h)
	    DX = segment number of UMB
	AH = 02h request a bank-switched memory block
	    DX = size in paragraphs
	    Return: BX = segment number (if successful)
	    	    DX = size of requested block/size of largest block
	AH = 03h release a bank-switched memory block
	    DX = segment number
	AH = 04h transfer data to/from high memory
	    DS:SI -> source
	    ES:DI -> destination
	    CX = length in bytes
	    Note: enables bank-switched memory, does the copy, then disables
	    	bank-switched memory
	AH = 05h get a word from bank-switched memory
	    ES:DI -> word to read
	    Return: DX = word
	AH = 06h put a word to bank-switched memory
	    ES:DI -> word to write
	    DX = word
	AH = 07h put a byte to bank-switched memory
	    ES:DI -> byte to write
	    DL = byte
	AH = 08h enable bank-switched memory
	    DS:SI -> 6-byte status save area
	AH = 09h disable bank-switched memory
	    DS:SI -> 6-byte save area from enable call (AH=08h)
	AH = 0Ah assign name to UMB of bank-switched block
	    DX = segment number
	    DS:SI -> 8-byte blank-padded name
	AH = 0Bh locate UMB block by name
	    DS:SI -> 8-byte blank-padded name
	    Return: BX = segment number (if successful)
	    	    DX = size of block
	AH = 0Ch locate bank-switched block by name
	    DS:SI -> 8-byte blank-padded name
	    Return: BX = segment number (if successful)
	    	    DX = size of block
Return: AX = status code
	    0001h successful
	    0000h failed
	    	BL = error code
		    80h not implemented
		    B0h insufficient memory, smaller block available
		    B1h insufficient memory, no blocks available
		    B2h invalid segment number
----------214403-----------------------------
INT 21 - DOS 2+ - IOCTL - WRITE CHARACTER DEVICE CONTROL STRING
	AX = 4403h
	BX = device handle
	CX = number of bytes to write
	DS:DX -> buffer
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    AX = number of bytes written
SeeAlso: AX=4402h,AX=4405h,INT 2F/AX=122Bh
----------214404-----------------------------
INT 21 - DOS 2+ - IOCTL - READ BLOCK DEVICE CONTROL STRING
	AX = 4404h
	BL = drive number (0=default)
	CX = number of bytes to read
	DS:DX -> buffer
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    AX = number of bytes read
SeeAlso: AX=4402h,AX=4405h,INT 2F/AX=122Bh
----------214405-----------------------------
INT 21 - DOS 2+ - IOCTL - WRITE BLOCK DEVICE CONTROL STRING
	AX = 4405h
	BL = drive number (0=default)
	CX = number of bytes to write
	DS:DX -> buffer
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    AX = number of bytes written
SeeAlso: AX=4403h,AX=4404h,INT 2F/AX=122Bh
----------214406-----------------------------
INT 21 - DOS 2+ - IOCTL - GET INPUT STATUS
	AX = 4406h
	BX = file or device handle
Return: AL = FFh device ready
	     00h device not ready (or file at EOF)
SeeAlso: AX=4407h,INT 2F/AX=122Bh
----------214407-----------------------------
INT 21 - DOS 2+ - IOCTL - GET OUTPUT STATUS
	AX = 4407h
	BX = file or device handle
Return: AL = FFh device ready
	     00h device not ready
Note:	for DOS 2.x, files are always ready for output
SeeAlso: AX=4406h,INT 2F/AX=122Bh
----------214408-----------------------------
INT 21 - DOS 3+ - IOCTL - BLOCK DEVICE CHANGEABLE
	AX = 4408h
	BL = drive number (0=default)
Return:	CF set on error
	    AX = error code (0Fh invalid drive) (see AH=59h)
	CF clear if successful
	    AX = 00h removable
		 01h fixed
SeeAlso: AX=4400h,AX=4409h,INT 2F/AX=122Bh
----------214409-----------------------------
INT 21 - DOS 3+ - IOCTL - BLOCK DEVICE LOCAL
	AX = 4409h
	BL = drive number (0=default)
Return: DX = attribute word, bit 12 set if device is remote
SeeAlso: AX=4400h,AX=4408h,AX=440Ah,INT 2F/AX=122Bh
----------21440A-----------------------------
INT 21 - DOS 3+ - IOCTL - HANDLE LOCAL
	AX = 440Ah
	BX = file handle
Return: DX = attribute word, bit 15 set if file is remote
Note:	if file is remote, Novell Advanced NetWare 2.0 returns the number of
	  the file server on which the handle is located in CX
SeeAlso: AX=4400h,AX=4409h,INT 2F/AX=122Bh
----------21440B-----------------------------
INT 21 - DOS 3+ - IOCTL - SET SHARING RETRY COUNT
	AX = 440Bh
	CX = delay (default 1)
	DX = retry count (default 3)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Note:	delay is dependent on processor speed (value in CX specifies number of
	  64K-iteration empty loops to execute)
SeeAlso: AH=52h,INT 2F/AX=1224h,INT 2F/AX=122Bh
----------21440C-----------------------------
INT 21 - DOS 3.2+ - IOCTL - GENERIC CHARACTER DEVICE REQUEST
	AX = 440Ch
	BX = device handle
	CH = category code
	    00h unknown (DOS 3.3+)
	    01h COMn: (DOS 3.3+)
	    03h CON (DOS 3.3+)
	    05h LPTn:
	    9Eh Media Access Control driver (STARLITE)
	CL = function
	    00h MAC driver Bind (STARLITE)
	    45h set iteration count
	    4Ah select code page
	    4Ch start code-page preparation
	    4Dh end code-page preparation
	    5Fh set display information (DOS 4.0)
	    65h get iteration count
	    6Ah query selected code page
	    6Bh query prepare list
	    7Fh get display information (DOS 4.0)
	DS:DX -> (DOS) parameter block (see below)
	SI:DI -> (OS/2 comp box) parameter block (see below)
Return: CF set on error
	    AX = error code (see AH=59h)
	DS:DX -> (OS/2 comp box) data block
SeeAlso: AX=440Dh,INT 2F/AX=0802h,INT 2F/AX=122Bh,INT 2F/AX=1A01h

Format of parameter block for function 00h:
Offset	Size	Description
 00h  8 BYTEs	ASCIZ signature "STARMAC"
 08h	WORD	version
 0Ah	WORD	flags
 		bit 0: media requires connect or listen request before use
		bit 1: network is a LAN (broadcast/multicast supported)
		bit 2: point-to-point network
 0Ch	WORD	handle for use with MAC driver's private interface (filled in
 		by MAC driver)
 0Eh	WORD	context
 10h	WORD	approximate speed in KB/sec (filled in by MAC driver)
 12h	WORD	approximate cost in cents per hour (filled in by MAC driver)
 14h	WORD	maximum packet size in bytes (filled in by MAC driver)
 16h	WORD	addressing format (filled in by MAC driver)
 		0000h general addressing
		0001h Ethernet addressing
		0002h Token Ring addressing
		0003h Token Bus addressing
 18h	DWORD	Send entry point (filled in by MAC driver)
 1Ch	DWORD	RegisterEventHandler entry point (filled in by MAC driver)
 20h	DWORD	SetPacketFilter entry point (filled in by MAC driver)
 24h	DWORD	UnBind entry point (filled in by MAC driver)

Format of parameter block for function 45h:
Offset	Size	Description
 00h	WORD	number of times output is attempted before driver assumes
		device is busy

Format of parameter block for functions 4Ah and 6Ah:
Offset	Size	Description
 00h	WORD	length of data
 02h	WORD	code page ID
 04h 2N BYTEs	DCBS (double byte character set) lead byte range
		  start/end for each of N ranges (DOS 4.0)
	WORD	0000h  end of data (DOS 4.0)

Format of parameter block for function 4Dh:
Offset	Size	Description
 00h	WORD	length of data
 02h	WORD	code page ID

Format of parameter block for function 4Ch:
Offset	Size	Description
 00h	WORD	flags
		DISPLAY.SYS = 0000h
		PRINTER.SYS bit 0 clear to prepare downloaded font, set to
			prepare cartridge selection
 02h	WORD	length of remainder of parameter block
 04h	WORD	number of code pages following
 06h  N WORDs	code page 1,...,N

Format of parameter block for functions 5Fh and 7Fh:
Offset	Size	Description
 00h	BYTE	level (0 for DOS 4.0)
 01h	BYTE	reserved (0)
 02h	WORD	length of following data (14)
 04h	WORD	control flags
		  bit 0 set for blink, clear for intensity
		  bits 1 to 15 reserved
 06h	BYTE	mode type (1=text, 2=graphics)
 07h	BYTE	reserved (0)
 08h	WORD	colors
		   0 = monochrome
		   else N bits per pixel
 0Ah	WORD	pixel columns
 0Ch	WORD	pixel rows
 0Eh	WORD	character columns
 10h	WORD	character rows

Format of parameter block for function 6Bh:
Offset	Size	Description
 00h	WORD	length of following data
 02h	WORD	number of hardware code pages
 04h  N WORDs	hardware code pages 1,...,N
	WORD	number of prepared code pages
      N WORDs	prepared code pages 1,...,N
----------21440D-----------------------------
INT 21 - DOS 3.2+ - IOCTL - GENERIC BLOCK DEVICE REQUEST
	AX = 440Dh
	BL = drive number (0=default)
	CH = category code
	    08h disk drive
	CL = function
 	    40h set device parameters
	    41h write logical device track
	    42h format and verify logical device track
	    46h (DOS 4.0) set volume serial number (see also AH=69h)
	    47h (DOS 4.0) set access flag
	    60h get device parameters
	    61h read logical device track
	    62h verify logical device track
	    66h (DOS 4.0) get volume serial number (see also AH=69h)
	    67h (DOS 4.0) get access flag
	DS:DX -> (DOS) parameter block (see below)
	SI:DI -> (OS/2 comp box) parameter block (see below)
Return: CF set on error
	   AX = error code (see AH=59h)
	DS:DX -> (OS/2 comp box) data block
Note:	DOS 4.01 seems to ignore the high byte of the number of directory
	  entries in the BPB for diskettes.
SeeAlso: AX=440Ch,AH=69h,INT 2F/AX=0802h,INT 2F/AX=122Bh

Format of parameter block for functions 40h, 60h:
Offset	Size	Description
 00h	BYTE	special functions
		bit 0 set if function to use current BPB, clear if Device BIOS
			Parameter Block field contains new default BPB
		bit 1 set if function to use track layout fields only
			must be clear if CL=60h
		bit 2 set if all sectors in track same size (should be set)
		bits 3-7 reserved
 01h	BYTE	device type
		00h  320K/360K disk
		01h  1.2M disk
		02h  720K disk
		03h  single-density 8-inch disk
		04h  double-density 8-inch disk
		05h  fixed disk
		06h  tape drive
		07h  1.44M disk
		08h  other type of block device
 02h	WORD	device attributes
		bit 0 set if nonremovable medium
		bit 1 set if door lock supported
		bits 2-15 reserved
 04h	WORD	number of cylinders
 06h	BYTE	media type
		00h 1.2M disk (default)
		01h 320K/360K disk
 07h 31 BYTEs	device BPB (see AH=53h)
 26h	WORD	number of sectors per track (start of track layout field)
 28h  N word pairs: number,size of each sector in track

Format of parameter block for functions 41h, 61h:
Offset	Size	Description
 00h	BYTE	reserved, must be zero
 01h	WORD	number of disk head
 03h	WORD	number of disk cylinder
 05h	WORD	number of first sector to read/write
 07h	WORD	number of sectors
 09h	DWORD	transfer address

Format of parameter block for functions 42h, 62h:
Offset	Size	Description
 00h	BYTE	reserved, must be zero (DOS <3.2)
		  bit 0=0: format/verify track
			1: format status call (DOS 3.2+)
		  bits 1-7 reserved, must be zero
		on return (DOS 4.0):
		  bit 0: set if specified tracks, sectors/track supported
		  bit 1: set if function not supported by BIOS
		  bit 2: set if specified tracks, sectors/track not supported
		  bit 3: set if no disk in drive
 01h	WORD	number of disk head
 03h	WORD	number of disk cylinder

Format of parameter block for functions 46h, 66h:
Offset	Size	Description
 00h	WORD	info level (00h)
 02h	DWORD	disk serial number (binary)
 06h 11 BYTEs	volume label or "NO NAME    "
 11h  8 BYTEs	filesystem type "FAT12	 " or "FAT16   " (CL=66h only)

Format of parameter block for functions 47h, 67h:
Offset	Size	Description
 00h	BYTE	special-function field (must be zero)
 01h	BYTE	disk-access flag, nonzero if access allowed by driver
----------21440E-----------------------------
INT 21 - DOS 3.2+ - IOCTL - GET LOGICAL DRIVE MAP
	AX = 440Eh
	BL = drive number (0=default)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    AL = 00h block device has only one logical drive assigned
		 1..26 the last letter used to reference the drive (1=A:,etc)
SeeAlso: AX=440Fh,INT 2F/AX=122Bh
----------21440F-----------------------------
INT 21 - DOS 3.2+ - IOCTL - SET LOGICAL DRIVE MAP
	AX = 440Fh
	BL = physical drive number (0=default)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Note:	maps logical drives to physical drives, similar to DOS's treatment of
	  a single physical floppy drive as both A: and B:
SeeAlso: AX=440Eh,INT 2F/AX=122Bh
----------214451-----------------------------
INT 21 - Concurrent DOS v3.2+ - INSTALLATION CHECK
	AX = 4451h
Return: CF set if not Concurrent DOS
	    AX = error code (see AH=59h)
	CF clear if successful
	    AH = 14h
	    AL = version (high nybble = major version, low nybble = minor ver)
SeeAlso: AX=4452h
----------214452-----------------------------
INT 21 - DR DOS 3.41-5.0 - IOCTL - DETERMINE DOS TYPE
	AX = 4452h
	CF set
Return: CF set if not DR DOS
	    AX = error code (see AH=59h)
	CF clear if DR DOS
Notes:	the DR DOS version is stored in the environment variable VER
	Digital Research indicates that this call may change in future
	  versions, making the installation check unreliable.  DR DOS 3.41+ is
	  supposedly sufficiently compatible with MSDOS that programs need not
	  decide which of the two they are running under.
SeeAlso: AX=4451h
----------2145-------------------------------
INT 21 - DOS 2+ - CREATE DUPLICATE HANDLE (DUP)
	AH = 45h
	BX = file handle to duplicate
Return: CF set on error
	    AX = error code (04h,06h) (see AH=59h)
	CF clear if successful
	    AX = new file handle
Note:	moving file pointer for either handle will also move it for the other,
	  because both will refer to the same system file table
SeeAlso: AH=3Dh,AH=46h
----------2146-------------------------------
INT 21 - DOS 2+ - FORCE DUPLICATE HANDLE (FORCDUP,DUP2)
	AH = 46h
	BX = existing file handle
	CX = new file handle
Return: CF set on error
	    AX = error code (04h,06h) (see AH=59h)
	CF clear if successful
	    AX = new file handle (undocumented)
Notes:	closes file with handle BX if it is still open
	DOS 3.30 hangs if BX=CX on entry
	moving file pointer for either handle will also move it for the other,
	  because both will refer to the same system file table
SeeAlso: AH=3Dh,AH=45h
----------2147-------------------------------
INT 21 - DOS 2+ - GET CURRENT DIRECTORY
	AH = 47h
	DL = drive (0=default, 1=A, etc.)
	DS:SI points to 64-byte buffer area
Return: CF set on error
	    AX = error code (0Fh) (see AH=59h)
	CF clear if successful
	    AX destroyed (0100h)
Notes:	the returned path does not include a drive or the initial backslash
	many Microsoft products for Windows rely on AX being 0100h on success
SeeAlso: AH=3Bh
----------2148-------------------------------
INT 21 - DOS 2+ - ALLOCATE MEMORY
	AH = 48h
	BX = number of 16-byte paragraphs desired
Return: CF set on error
	    AX = error code (07h,08h) (see AH=59h)
	    BX = size of largest available block
	CF clear if successful
	    AX = segment of allocated memory block
Note:	DOS 3.30 coalesces free blocks while scanning for a block to allocate
SeeAlso: AH=49h,AH=4Ah,AH=58h
----------2149-------------------------------
INT 21 - DOS 2+ - FREE MEMORY
	AH = 49h
	ES = segment address of area to be freed
Return: CF set on error
	    AX = error code (07h,09h) (see AH=59h)
	CF clear if successful
Notes:	apparently never returns an error 07h, despite official docs; DOS 3.30
	  code contains only an error 09h exit
	DOS 3.30 does not coalesce adjacent free blocks when a block is freed,
	  only when a block is allocated or resized
SeeAlso: AH=48h,AH=4Ah
----------214A-------------------------------
INT 21 - DOS 2+ - ADJUST MEMORY BLOCK SIZE (SETBLOCK)
	AH = 4Ah
	ES = segment address of block to change
	BX = new size in paragraphs
Return: CF set on error
	    AX = error code (07h,08h,09h) (see AH=59h)
	    BX = maximum size possible for the block (if AX=08h)
	CF clear if successful
Notes:	under PCDOS 2.1 and 3.1 and MSDOS 3.2 and 3.3, if there is insufficient
	  memory to expand the block as much as requested, the block will be
	  made as large as possible
	DOS 3.30 coalesces any free blocks immediately following the block to
	  be resized
SeeAlso: AH=48h,AH=49h
----------214B-------------------------------
INT 21 - DOS 2+ - LOAD OR EXECUTE (EXEC)
	AH = 4Bh
	AL = subfunction
	    00h load and execute program
	    01h load but do not execute (internal)
	    03h load overlay; do not create PSP
	    04h called by MSC spawn(P_NOWAIT,...) when running DOS 4.x.
		returns unsuccessfully under DOS 4.0 (but may be successful
		  in the original European OEM MSDOS 4.0, which has limited
		  multitasking built in)
	DS:DX -> ASCIZ filename
	ES:BX -> parameter block (see below)
Return: CF set on error
	    AX = error code (01h,02h,05h,08h,0Ah,0Bh) (see AH=59h)
	CF clear if successful
	    if subfunction 01h, process ID set to new program's PSP; get with
		INT 21/AH=62h
Notes:	DOS 2.x destroys all registers, including SS:SP
	for functions 00h and 01h, the calling process must ensure that there
	  is enough unallocated memory available; if necessary, by releasing
	  memory with AH=49h or AH=4Ah
BUG:	DOS 2.00 assumes that DS points at the current program's PSP
SeeAlso: AH=4Ch,AH=4Dh,INT 2E

Format of EXEC parameter block for AL=00h,01h:
Offset	Size	Description
 00h	WORD	segment of environment (0 = use current) (see AH=26h)
 02h	DWORD	pointer to command line
 06h	DWORD	pointer to first FCB (see AH=0Fh)
 0Ah	DWORD	pointer to second FCB (see AH=0Fh)
 0Eh	DWORD	(AL=01h) will hold subprogram's initial SS:SP on return
 12h	DWORD	(AL=01h) will hold entry point (CS:IP) on return

Format of EXEC parameter block for AL=03h:
Offset	Size	Description
 00h	WORD	segment load address
 02h	WORD	segment relocation factor

Format of .EXE file header:
Offset	Size  Description
 00h	WORD  4Dh, 5Ah signature (sometimes 5Ah, 4Dh)
 02h	WORD  image size remainder (program size mod 512, not including header)
 04h	WORD  number of 512-byte pages needed to hold .EXE file (incl header)
 06h	WORD  number of relocation items
 08h	WORD  header size in paragraphs
 0Ah	WORD  minimum extra paragraphs needed
 0Ch	WORD  maximum extra paragraphs needed
 0Eh	WORD  stack segment
 10h	WORD  stack offset
 12h	WORD  word checksum of entire file
 14h	DWORD initial CS:IP
 18h	WORD  offset of relocation table 
 1Ah	WORD  overlay number
Note:	if word at offset 02h is 4, it should be treated as 00h, since pre-1.10
	  versions of the MS linker set it that way
----------214C-------------------------------
INT 21 - DOS 2+ - QUIT WITH EXIT CODE (EXIT)
	AH = 4Ch
	AL = exit code
Return: never returns
Note:	unless the process is its own parent (see AH=26h, offset 16h in PSP),
	  all open files are closed
SeeAlso: AH=26h,AH=4Bh,AH=4Dh, INT 22
----------214D-------------------------------
INT 21 - DOS 2+ - GET EXIT CODE OF SUBPROGRAM (WAIT)
	AH = 4Dh
Return: AL = exit code of subprogram (from AH=31h or AH=4Ch)
	AH = circumstance which caused termination
	    00h Terminate/abort
	    01h Control-C/Control-Break
	    02h Hard error
	    03h Terminate and stay resident
SeeAlso: AH=4Bh,AH=4Ch
----------214E-------------------------------
INT 21 - DOS 2+ - FIND FIRST ASCIZ (FINDFIRST)
	AH = 4Eh
	CX = search attributes (see AX=4301h)
	DS:DX -> ASCIZ filespec (drive, path, and wildcards allowed)
Return: CF set on error
	    AX = error code (02h,12h) (see AH=59h)
	CF clear if successful
	    [DTA] = data block (see below)
Notes:	for search attributes other than 08h, all files with at MOST the
	  specified attribute bits, the archive (20h) bit, and the read-only
	  (01h) bits set will be returned.  Under DOS 2.x, searching for
	  attribute 08h (volume label) will also return normal files, while
	  under DOS 3+ only the volume label (if any) will be returned.
	this call also returns successfully if given the name of a character
	  device without wildcards.  DOS 2.x returns attribute 00h, size 0,
	  and the current date and time.  DOS 3+ returns attribute 40h and the
	  current date and time.
	under LANtastic, this call may be used to obtain a list of a server's
	  shared resources by searching for "\\SERVER\*.*"; a list of printer
	  resources may be obtained by searching for "\\SERVER\@*.*"
BUG:	under DOS 3.x and 4.x, the second and subsequent calls to this function
	  with a character device name (no wildcards) and search attributes
	  which include the volume-label bit (08h) will fail unless there is
	  an intervening DOS call which implicitly or explicity performs a
	  directory search without the volume-label bit.  Such implicit
	  searches are performed by CREATE (AH=3Ch), OPEN (AH=3Dh), UNLINK
	  (AH=41h), and RENAME (AH=56h)
SeeAlso: AH=11h,AH=4Fh,AX=4301h,INT 2F/AX=111Bh

Format of FindFirst data block:
Offset	Size	Description
---PCDOS 3.10, PCDOS 4.01, MSDOS 3.2/3.3---
 00h	BYTE	drive letter
 01h 11 BYTEs	search template
 0Ch	BYTE	search attributes
---DOS 2.x (and some DOS 3.x???)---
 00h	BYTE	search attributes
 01h	BYTE	drive letter
 02h 11 BYTEs	search template
---WILDUNIX.COM---
 00h 12 BYTEs	15-character wildcard search pattern and drive letter (packed)
 0Ch	BYTE	search attributes
---DOS 2.x and most 3.x---
 0Dh	WORD	entry count within directory
 0Fh	DWORD	pointer to DTA???
 13h	WORD	cluster number of start of parent directory
---PCDOS 4.01, MSDOS 3.2/3.3---
 0Dh	WORD	entry count within directory
 0Fh	WORD	cluster number of start of parent directory
 11h  4 BYTEs	reserved
---all versions, documented fields---
 15h	BYTE	attribute of file found
 16h	WORD	file time
		    bits 11-15: hour
		    bits 5-10:	minute
		    bits 0-4:	seconds/2
 18h	WORD	file date
		    bits 9-15:	year-1980
		    bits 5-8:	month
		    bits 0-4:	day
 1Ah	DWORD	file size
 1Eh 13 BYTEs	ASCIZ filename+extension
----------214E--DS0000-----------------------
INT 21 - WILDUNIX.COM internal - INSTALLATION CHECK
	AH = 4Eh
	DS:DX = 0000h:0000h
Return:	AH = 99h if installed
Note:	WILDUNIX.COM is a resident Unix-style wildcard expander by Steve
	  Hosgood and Terry Barnaby
----------214F-------------------------------
INT 21 - DOS 2+ - FIND NEXT ASCIZ (FINDNEXT)
	AH = 4Fh
	[DTA] = data block from last AH = 4Eh/4Fh call
Return: CF set on error
	    AX = error code (12h) (see AH=59h)
	CF clear if successful
	    [DTA] = data block (see AH=4Eh)
SeeAlso: AH=12h,AH=4Eh
----------2150-------------------------------
INT 21 - DOS 2+ internal - SET PSP SEGMENT
	AH = 50h
	BX = segment address of new PSP (see AH=26h for format)
Notes:	under DOS 2.x, this function cannot be invoked inside an INT 28h
	  handler without setting the Critical Error flag
	under DOS 3+, this function does not use any of the DOS-internal stacks
	  and is thus fully reentrant
	supported by OS/2 compatibility box
SeeAlso: AH=26h,AH=51h,AH=62h
----------2151-------------------------------
INT 21 - DOS 2+ internal - GET PSP SEGMENT
	AH = 51h
Return: BX = current PSP segment (see AH=26h for format)
Notes:	under DOS 2.x, this function cannot be invoked inside an INT 28h
	  handler without setting the Critical Error flag
	under DOS 3+, this function does not use any of the DOS-internal stacks
	  and is thus fully reentrant
	supported by OS/2 compability box
	identical to the documented AH=62h
SeeAlso: AH=26h,AH=50h,AH=62h
----------2152-------------------------------
INT 21 - DOS 2+ internal - GET LIST OF LISTS
	AH = 52h
Return: ES:BX -> DOS list of lists
Note:	partially supported by OS/2 v1.1 compatibility box (however, most
	  pointers are FFFFh:FFFFh, LASTDRIVE is FFh, and the NUL header "next"
	  pointer is FFFFh:FFFFh).

Format of List of Lists:
Offset	Size	Description
 -12	WORD	(DOS 3.1-3.3) sharing retry count (see AX=440Bh)
 -10	WORD	(DOS 3.1-3.3) sharing retry delay (see AX=440Bh)
 -8	DWORD	(DOS 3.x) pointer to current disk buffer
 -4	WORD	(DOS 3.x) pointer in DOS code segment of unread CON input
		when CON is read via a handle, DOS reads an entire line,
		  and returns the requested portion, buffering the rest
		  for the next read.  0000h indicates no unread input
 -2	WORD	segment of first memory control block
 00h	DWORD	pointer to first DOS Drive Parameter Block (see AH=32h)
 04h	DWORD	pointer to list of DOS file tables (see below)
 08h	DWORD	pointer to CLOCK$ device driver, resident or installable
 0Ch	DWORD	pointer to actual CON device driver, resident or installable
---DOS 2.x---
 10h	BYTE	number of logical drives in system
 11h	WORD	maximum bytes/block of any block device
 13h	DWORD	pointer to first disk buffer (see below)
 17h 18 BYTEs	actual NUL device driver header (not a pointer!)
		This is the first device on DOS's linked list of device 
		drivers. (see below for format)
---DOS 3.0---
 10h	BYTE	number of block devices
 11h	WORD	maximum bytes/block of any block device
 13h	DWORD	pointer to first disk buffer (see below)
 17h	DWORD	pointer to array of current directory structures (see below)
 1Bh	BYTE	value of LASTDRIVE command in CONFIG.SYS (default 5)
 1Ch	DWORD	pointer to STRING= workspace area
 20h	WORD	size of STRING area (the x in STRING=x from CONFIG.SYS)
 22h	DWORD	pointer to FCB table
 26h	WORD	the y in FCBS=x,y from CONFIG.SYS
 28h 18 BYTEs	actual NUL device driver header (not a pointer!)
		This is the first device on DOS's linked list of device 
		drivers. (see below for format)
---DOS 3.1-3.3---
 10h	WORD	maximum bytes/block of any block device
 12h	DWORD	pointer to first disk buffer (see below)
 16h	DWORD	pointer to array of current directory structures (see below)
 1Ah	DWORD	pointer to FCB table (if CONFIG.SYS contains FCBS=)
 1Eh	WORD	number of protected FCBs (the y in FCBS=x,y)
 20h	BYTE	number of block devices
 21h	BYTE	value of LASTDRIVE command in CONFIG.SYS (default 5)
 22h 18 BYTEs	actual NUL device driver header (not a pointer!)
		This is the first device on DOS's linked list of device 
		drivers. (see below for format) (see also INT 2F/AX=122Ch)
 34h	BYTE	number of JOIN'ed drives
---DOS 4.x---
 10h	WORD	maximum bytes/block of any block device
 12h	DWORD	pointer to disk buffer info (see below)
 16h	DWORD	pointer to array of current directory structures (see below)
 1Ah	DWORD	pointer to FCB table (if CONFIG.SYS contains FCBS=)
 1Eh	WORD	number of protected FCBs (the y in FCBS=x,y)
 20h	BYTE	number of block devices
 21h	BYTE	value of LASTDRIVE command in CONFIG.SYS (default 5)
 22h 18 BYTEs	actual NUL device driver header (not a pointer!)
		This is the first device on DOS's linked list of device 
		drivers. (see below for format) (see also INT 2F/AX=122Ch)
 34h	BYTE	number of JOIN'ed drives???
 35h	WORD	pointer within IBMDOS code segment to list of special program
		names (see below)
 37h	DWORD	pointer to FAR routine for resident IFS utility functions
		(see below)
		may be called by any IFS driver which does not wish to
		service functions 20h or 24h-28h itself
 3Bh	DWORD	pointer to chain of IFS (installable file system) drivers
 3Fh	WORD	the x in BUFFERS x,y (rounded up to multiple of 30 if in EMS)
 41h	WORD	the y in BUFFERS x,y
 43h	BYTE	boot drive (1=A:)
 44h	BYTE	01h if 80386+, 00h otherwise???
 45h	WORD	extended memory size in K

Format of memory control block (see also below):
Offset	Size	Description
 00h	BYTE	block type: 5Ah if last block in chain, otherwise 4Dh
 01h	WORD	PSP segment of owner, 0000h if free, 0008h if belongs to DOS
 03h	WORD	size of memory block in paragraphs
 05h  3 BYTEs	unused
---DOS 2.x,3.x---
 08h  8 BYTEs	unused
---DOS 4.x---
 08h  8 BYTEs	ASCII program name if PSP memory block, else garbage
		null-terminated if less than 8 characters
Notes:	under DOS 3.1+, the first memory block is the DOS data segment,
	  containing installable drivers, buffers, etc.
	under DOS 4.x it is divided into subsegments, each with its own memory
	  control block (see below), the first of which is at offset 0000h

Format of STARLITE memory control block:
Offset	Size	Description
 00h	BYTE	block type: 5Ah if last block in chain, otherwise 4Dh
 01h	WORD	PSP segment of owner, 0000h if free, 0008h if belongs to DOS
 03h	WORD	size of memory block in paragraphs
 05h	BYTE	unused
 06h	WORD	segment address of next memory control block (0000h if last)
 08h	WORD	segment address of previous memory control block or 0000h
 0Ah  6 BYTEs	reserved

Format of DOS 4.x data segment subsegment control blocks:
Offset	Size	Description
 00h	BYTE	subsegment type (blocks typically appear in this order)
		"D"  device driver
		"E"  device driver appendage
		"I"  IFS (Installable File System) driver
		"F"  FILES=  control block storage area (for FILES>5)
		"X"  FCBS=   control block storage area, if present
		"C"  BUFFERS EMS workspace area (if BUFFERS /X option used)
		"B"  BUFFERS=  storage area
		"L"  LASTDRIVE=  current directory structure array storage area
		"S"  STACKS=  code and data area, if present (see below)
 01h	WORD	paragraph of subsegment start (usually the next paragraph)
 03h	WORD	size of subsegment in paragraphs
 05h  3 BYTEs	unused
 08h  8 BYTEs	for types "D" and "I", base name of file from which the driver
		  was loaded (unused for other types)

Format of data at start of STACKS code segment (if present):
Offset	Size	Description
 00h	WORD	???
 02h	WORD	number of stacks (the x in STACKS=x,y)
 04h	WORD	size of stack control block array (should be 8*x)
 06h	WORD	size of each stack (the y in STACKS=x,y)
 08h	DWORD	ptr to STACKS data segment
 0Ch	WORD	offset in STACKS data segment of stack control block array
 0Eh	WORD	offset in STACKS data segment of last element of that array
 10h	WORD	offset in STACKS data segment of the entry in that array for
		the next stack to be allocated (initially same as value in 0Eh
		and works its way down in steps of 8 to the value in 0Ch as
		hardware interrupts pre-empt each other)
Note:	the STACKS code segment data may, if present, be located as follows:
    DOS 3.2:	The code segment data is at a paragraph boundary fairly early
		in the IBMBIO segment (seen at 0070:0190h)
    DOS 3.3:	The code segment is at a paragraph boundary in the DOS data
		segment, which may be determined by inspecting the segment
		pointers of the vectors for those of interrupts 02h, 08h-0Eh,
		70h, 72-77h which have not been redirected by device drivers or
		TSRs.
    DOS 4.x:	Identified by sub-segment control block type "S" within the DOS
		data segment.

Format of array elements in STACKS data segment:
Offset	Size	Description
 00h	BYTE	status: 00h=free, 01h=in use, 03h=corrupted by overflow of
		higher stack.
 01h	BYTE	not used
 02h	WORD	previous SP
 04h	WORD	previous SS
 06h	WORD	ptr to word at top of stack (new value for SP). The word at the
		top of the stack is preset to point back to this control block.

SHARE.EXE hooks (DOS 3.1-4.01):
(offsets from first system file table--pointed at by ListOfLists+04h)
Offset	Size	Description
-3Ch	DWORD	pointer to FAR routine for ???
		Note: not called by MSDOS 3.3, set to 0000h:0000h by SHARE 3.3
-38h	DWORD	pointer to FAR routine called on opening file
		on call, internal DOS location points at filename(see AX=5D06h)
		Return: CF clear if successful
			CF set on error
			    AX = DOS error code (24h) (see AH=59h)
		Note: SHARE assumes DS=SS=DOS CS, direct-accesses DOS internals
			to get name of file just opened
-34h	DWORD	pointer to FAR routine called on closing file
		ES:DI -> system file table
		Note: SHARE assumes SS=DOS CS, directly accesses DOS internals
			does something to every lock record for file
-30h	DWORD	pointer to FAR routine to close all files for given computer
		(called by AX=5D03h)
		Note: SHARE assumes SS=DOS CS, directly accesses DOS internals
-2Ch	DWORD	pointer to FAR routine to close all files for given process
		(called by AX=5D04h)
		Note: SHARE assumes SS=DOS CS, directly accesses DOS internals
-28h	DWORD	pointer to FAR routine to close file by name
		(called by AX=5D02h)
		DS:SI -> DOS parameter list (see AX=5D00h)
		   DPL's DS:DX -> name of file to close
		Return: CF clear if successful
			CF set on error
			    AX = DOS error code (03h) (see AH=59h)
		Note: SHARE assumes SS=DOS CS, directly accesses DOS internals
-24h	DWORD	pointer to FAR routine to lock region of file
		call with BX = file handle
			  CX:DX = starting offset
			  SI:AX = size
		Return: CF set on error
			    AL = DOS error code (21h) (see AH=59h)
		Note: only called if file is marked as remote
		Note: SHARE assumes SS=DOS CS, directly accesses DOS internals
-20h	DWORD	pointer to FAR routine to unlock region of file
		call with BX = file handle
			  CX:DX = starting offset
			  SI:AX = size
		Return: CF set on error
			    AL = DOS error code (21h) (see AH=59h)
		Note: only called if file is marked as remote
		Note: SHARE assumes SS=DOS CS, directly accesses DOS internals
-1Ch	DWORD	pointer to FAR routine to check if file region is locked
		call with ES:DI -> system file table entry for file
			CX = length of region from current position in file
		Return: CF set if any portion of region locked
			    AX = 0021h
		Note: SHARE assumes SS=DOS CS, directly accesses DOS internals
-18h	DWORD	pointer to FAR routine to get open file list entry
		(called by AX=5D05h)
		call with DS:SI -> DOS parameter list (see AX=5D00h)
			DPL's BX = index of sharing record
			DPL's CX = index of SFT in SFT chain of sharing rec
		Return: CF set on error or not loaded
			    AX = DOS error code (12h) (see AH=59h)
			CF clear if successful
			    ES:DI -> filename
			    CX = number of locks owned by specified SFT
			    BX = network machine number
			    DX destroyed
		Note: SHARE assumes SS=DOS CS, directly accesses DOS internals
-14h	DWORD	pointer to FAR routine for updating FCB from SFT???
		call with DS:SI -> unopened FCB
			  ES:DI -> system file table entry
		Return: BL = C0h???
		Note: copies following fields from SFT to FCB:
		   starting cluster of file	  0Bh	 1Ah
		   sharing record offset	  33h	 1Ch
		   file attribute		  04h	 1Eh
-10h	DWORD	pointer to FAR routine to get first cluster of FCB file ???
		call with ES:DI -> system file table entry
			  DS:SI -> FCB
		Return: CF set if SFT closed or sharing record offsets
				mismatched
			CF clear if successful
			    BX = starting cluster number from FCB
-0Ch	DWORD	pointer to FAR routine to close file if duplicate for process
		DS:SI -> system file table
		Return: AX = number of handle in JFT which already uses SFT
		Note: called during open/create of a file
		Note: SHARE assumes SS=DOS CS, directly accesses DOS internals
		Note: if SFT was opened with inheritance enabled and sharing
			mode 111, does something to all other SFTs owned by
			same process which have the same file open mode and
			sharing record
-08h	DWORD	pointer to FAR routine for ???
		Note: SHARE assumes SS=DS=DOS CS, direct-accesses DOS internals
		Note: closes various handles referring to file most-recently
			opened
-04h	DWORD	pointer to FAR routine to update directory info in related SFT
		  entries
		call with ES:DI -> system file table entry for file (see below)
			  AX = subfunction (apply to each related SFT)
				00h: update time stamp (offset 0Dh) and date
				     stamp (offset 0Fh)
				01h: update file size (offset 11h) and starting
				     cluster (offset 0Bh).  Sets last-accessed
				     cluster fields to start of file if file
				     never accessed
				02h: as function 01h, but last-accessed fields
				     always changed
				03h: do both functions 00h and 02h
		Note: follows ptr at offset 2Bh in system file table entries
		Note: NOP if opened with no-inherit or via FCB

Format of sharing record:
Offset	Size	Description
 00h	BYTE	flag
		00h free block
		01h allocated block
		FFh end marker
 01h	WORD	size of block
 03h	BYTE	checksum of pathname (including NUL)
		if sum of ASCII values is N, checksum is (N/256 + N%256)
 04h	WORD	offset in SHARE's DS of lock record (see below)
 06h	DWORD	pointer to start of system file table chain for file
 0Ah	WORD	unique sequence number
 0Ch	var	ASCIZ full pathname

Format of SHARE.EXE lock record:
Offset	Size	Description
 00h	WORD	offset in SHARE's DS of next lock table in list
 02h	DWORD	offset in file of start of locked region
 06h	DWORD	offset in file of end of locked region
 0Ah	DWORD	pointer to System File Table entry for this file
 0Eh	WORD	PSP segment of lock's owner

Format of DOS 2.x system file tables:
Offset	Size	Description
 00h	DWORD	pointer to next file table
 04h	WORD	number of files in this table
 06h  28h bytes per file
	Offset	Size	Description
	 00h	BYTE	number of file handles referring to this file
	 01h	BYTE	file open mode (see AH=3Dh)
	 02h	BYTE	file attribute
	 03h	BYTE	drive (0 = character device, 1 = A, 2 = B, etc)
	 04h 11 BYTEs	filename in FCB format (no path,no period,blank-padded)
	 0Fh	WORD	???
	 11h	WORD	???
	 13h	DWORD	file size???
	 17h	WORD	file date in packed format (see AX=5700h)
	 19h	WORD	file time in packed format (see AX=5700h)
	 1Bh	BYTE	device attribute (see AX=4400h)
	---character device---
	 1Ch	DWORD	pointer to device driver
	---block device---
	 1Ch	WORD	starting cluster of file
	 1Eh	WORD	relative cluster in file of last cluster accessed
	------
	 20h	WORD	absolute cluster number of current cluster
	 22h	WORD	???
	 24h	DWORD	current file position???

Format of DOS 3.x system file tables and FCB tables:
Offset	Size	Description
 00h	DWORD	pointer to next file table
 04h	WORD	number of files in this table
 06h  35h bytes per file
	Offset	Size	Description
	 00h	WORD	number of file handles referring to this file
	 02h	WORD	file open mode (see AH=3Dh)
			bit 15 set if this file opened via FCB
	 04h	BYTE	file attribute
	 05h	WORD	device info word (see AX=4400h)
			bit 15 set if remote file
			bit 14 set means do not set file date/time on closing
	 07h	DWORD	pointer to device driver header if character device
			else pointer to DOS Drive Parameter Block (see AH=32h)
	 0Bh	WORD	starting cluster of file
	 0Dh	WORD	file time in packed format (see AX=5700h)
	 0Fh	WORD	file date in packed format (see AX=5700h)
	 11h	DWORD	file size
	 15h	DWORD	current offset in file
	 19h	WORD	relative cluster within file of last cluster accessed
	 1Bh	WORD	absolute cluster number of last cluster accessed
			0000h if file never read or written???
	 1Dh	WORD	number of sector containing directory entry
	 1Fh	BYTE	number of dir entry within sector (byte offset/32)
	 20h 11 BYTEs	filename in FCB format (no path/period, blank-padded)
	 2Bh	DWORD	(SHARE.EXE) pointer to previous SFT sharing same file
	 2Fh	WORD	(SHARE.EXE) network machine number which opened file
	 31h	WORD	PSP segment of file's owner (see AH=26h)
	 33h	WORD	offset within SHARE.EXE code segment of 
			sharing record (see below)  0000h = none

Format of DOS 4+ system file tables and FCB tables:
Offset	Size	Description
 00h	DWORD	pointer to next file table
 04h	WORD	number of files in this table
 06h  3Bh bytes per file
	Offset	Size	Description
	 00h	WORD	number of file handles referring to this file
	 02h	WORD	file open mode (see AH=3Dh)
			bit 15 set if this file opened via FCB
	 04h	BYTE	file attribute
	 05h	WORD	device info word (see AX=4400h)
			bit 15 set if remote file
			bit 14 set means do not set file date/time on closing
	 07h	DWORD	pointer to device driver header if character device
			else pointer to DOS Drive Parameter Block (see AH=32h)
			or REDIR data
	 0Bh	WORD	starting cluster of file
	 0Dh	WORD	file time in packed format (see AX=5700h)
	 0Fh	WORD	file date in packed format (see AX=5700h)
	 11h	DWORD	file size
	 15h	DWORD	current offset in file
	---local file---
	 19h	WORD	relative cluster within file of last cluster accessed
	 1Bh	DWORD	number of sector containing directory entry
	 1Fh	BYTE	number of dir entry within sector (byte offset/32)
	---network redirector---
	 19h	DWORD	pointer to REDIRIFS record
	 1Dh  3 BYTEs	???
	------
	 20h 11 BYTEs	filename in FCB format (no path/period, blank-padded)
	 2Bh	DWORD	(SHARE.EXE) pointer to previous SFT sharing same file
	 2Fh	WORD	(SHARE.EXE) network machine number which opened file
	 31h	WORD	PSP segment of file's owner (see AH=26h)
	 33h	WORD	offset within SHARE.EXE code segment of 
			sharing record (see below)  0000h = none
	 35h	WORD	(local) absolute cluster number of last clustr accessed
			(redirector) ???
	 37h	DWORD	pointer to IFS driver for file, 0000000h if native DOS

Format of current directory structure (array, 51h bytes [58h for DOS 4.x] per
drive):
Offset	Size	Description
 00h 67 BYTEs	current path as ASCIZ, starting with 'x:\'
 43h	WORD	bit flags
		bit 15: network drive	\ installable file system if both set
		bit 14: physical drive	/ invalid drive if neither bit set
		bit 13: JOIN'ed, current path is actual path without JOIN
			drive letter in path may differ from logical drive name
		bit 12: SUBST'ed, current path is actual path without SUBST
			drive letter in path may differ from logical drive name
 45h	DWORD	pointer to DOS Disk Block for this drive
---local drives---
 49h	WORD	starting cluster of current directory
		0000h = root, FFFFh never accessed
 4Bh	WORD	??? seems always to be FFFFh
 4Dh	WORD	??? seems always to be FFFFh
---network drives---
 49h	DWORD	pointer to a redirector/REDIRIFS record, else FFFFFFFFh
 4Dh	WORD	stored parameter from INT 21/AX=5F03h???
------
 4Fh	WORD	Offset of '\' in current path field representing root directory 
		of logical drive (2 if not SUBST'ed or JOIN'ed, otherwise 
		number of bytes in SUBST/JOIN path)
---DOS 4.x---
 51h	BYTE	??? used by network
 52h	DWORD	pointer to IFS driver for this drive, 00000000h if native DOS
 56h	WORD	???

Format of device driver header:
Offset	Size	Description
 00h	DWORD	pointer to next driver, offset=FFFFh if last driver
 04h	WORD	device attributes
		Character device:
		   bit 15  set
		   bit 14  IOCTL supported (see AH=44h)
		   bit 13  (DOS 3+) output until busy supported
		   bit 12  reserved
		   bit 11  (DOS 3+) OPEN/CLOSE/RemMedia calls supported
		   bits 10-7 reserved
		   bit 6  (DOS 3.2+) Generic IOCTL call supported (command 13h)
				(see AX=440Ch,440Dh)
		   bit 5  reserved
		   bit 4  device is special (use INT 29 "fast console output")
		   bit 3  device is CLOCK$ (all reads/writes use transfer
				record described below)
		   bit 2  device is NUL
		   bit 1  device is standard output
		   bit 0  device is standard input
		Block device:
		   bit 15  clear
		   bit 14  IOCTL supported
		   bit 13  non-IBM format
		   bit 12  reserved
		   bit 11  (DOS 3+) OPEN/CLOSE/RemMedia calls supported
		   bit 10  reserved
		   bit 9   ??? set by DOS 3.3 DRIVER.SYS for "new" drives
		   bit 8   ??? set by DOS 3.3 DRIVER.SYS for "new" drives
		   bit 7   reserved
		   bit 6  (DOS 3.2+) Generic IOCTL call supported (command 13h)
				implies support for commands 17h and 18h
				(see AX=440Ch,440Dh,440Eh,440Fh)
		   bits 5-2 reserved
		   bit 1   driver supports 32-bit sector addressing
		   bit 0   reserved
 06h	WORD	device strategy entry point
		call with ES:BX -> request header (see INT 2F/AX=0802h)
 08h	WORD	device interrupt entry point
---character device---
 0Ah  8 BYTEs	blank-padded character device name
---block device---
 0Ah	BYTE	number of subunits (drives) supported by driver
 0Bh  7 BYTEs	unused
---
 12h	WORD	(CD-ROM driver) reserved, must be 0000h
 14h	BYTE	(CD-ROM driver) drive letter (must initially be 00h)
 15h	BYTE	(CD-ROM driver) number of units
 16h  6 BYTEs	(CD-ROM driver) signature 'MSCDnn' where 'nn' is version 
			(currently '00')

Format of CLOCK$ transfer record:
Offset	Size	Description
 00h	WORD	number of days since 1-Jan-1980
 02h	BYTE	minutes
 03h	BYTE	hours
 04h	BYTE	hundredths of second
 05h	BYTE	seconds

Format of DOS 2.x disk buffer:
Offset	Size	Description
 00h	DWORD	pointer to next disk buffer, offset = FFFFh if last
		least-recently used buffer is first in chain
 04h	BYTE	drive (0=A, 1=B, etc), FFh if not in use
 05h  3 BYTEs	unused??? (seems always to be 00h 00h 01h)
 08h	WORD	logical sector number
 0Ah	BYTE	number of copies to write (1 for non-FAT sectors)
 0Bh	BYTE	sector offset between copies if multiple copies to be written
 0Ch	DWORD	pointer to DOS Drive Parameter Block (see AH=32h)
 10h		buffered data

Format of DOS 3.x disk buffer:
Offset	Size	Description
 00h	DWORD	pointer to next disk buffer, offset = FFFFh if last
		least-recently used buffer is first in chain
 04h	BYTE	drive (0=A,1=B, etc), FFh if not in use
 05h	BYTE	flags
		bit 7: ???
		bit 6: buffer dirty
		bit 5: buffer has been referenced
		bit 4: ???
		bit 3: sector in data area
		bit 2: sector in a directory, either root or subdirectory
		bit 1: sector in FAT
		bit 0: boot sector??? (guess)
 06h	WORD	logical sector number
 08h	BYTE	number of copies to write (1 for non-FAT sectors)
 09h	BYTE	sector offset between copies if multiple copies to be written
 0Ah	DWORD	pointer to DOS Drive Parameter Block (see AH=32h)
 0Eh	WORD	unused??? (almost always 0)
 10h		buffered data

Format of DOS 4.00 (pre UR 25066) disk buffer info:
Offset	Size	Description
 00h	DWORD	pointer to array of disk buffer hash chain heads (see below)
 04h	WORD	number of disk buffer hash chains (referred to as NDBCH below)
 06h	DWORD	pointer to lookahead buffer, zero if not present
 0Ah	WORD	number of lookahead sectors, else zero (the y in BUFFERS=x,y)
 0Ch	BYTE	00h if buffers in EMS (/X), FFh if not
 0Dh	WORD	EMS handle for buffers, zero if not in EMS
 0Fh	WORD	EMS physical page number used for buffers (usually 255)
 11h	WORD	??? seems always to be 0001h
 13h	WORD	segment of EMS physical page frame
 15h	WORD	??? seems always to be zero
 17h  4 WORDs	EMS partial page mapping information???

Format of DOS 4.01 (from UR 25066 Corrctive Services Disk on) disk buffer info:
Offset	Size	Description
 00h	DWORD	pointer to array of disk buffer hash chain heads (see below)
 04h	WORD	number of disk buffer hash chains (referred to as NDBCH below)
 06h	DWORD	pointer to lookahead buffer, zero if not present
 0Ah	WORD	number of lookahead sectors, else zero (the y in BUFFERS=x,y)
 0Ch	BYTE	01h, possibly to distinguish from pre-UR 25066 format
 0Dh	WORD	??? EMS segment for BUFFERS (only with /XD)
 0Fh	WORD	??? EMS physical page number of EMS seg above (only with /XD)
 11h	WORD	??? EMS segment for ??? (only with /XD)
 13h	WORD	??? EMS physical page number of above (only with /XD)
 15h	BYTE	??? number of EMS page frames present (only with /XD)
 16h	WORD	segment of one-sector workspace buffer allocated in main memory
		  if BUFFERS/XS or /XD options in effect, possibly to avoid DMA
		  into EMS
 18h	WORD	EMS handle for buffers, zero if not in EMS
 1Ah	WORD	EMS physical page number used for buffers (usually 255)
 1Ch	WORD	??? appears always to be 0001h
 1Eh	WORD	segment of EMS physical page frame
 20h	WORD	??? appears always to be zero
 22h	BYTE	00h if /XS, 01h if /XD, FFh if BUFFERS not in EMS

Format of DOS 4.x disk buffer hash chain head (array, one entry per chain):
Offset	Size	Description
 00h	WORD	EMS logical page number in which chain is resident, -1 if not
		in EMS
 02h	DWORD	pointer to least recently used buffer header.  All buffers on
		this chain are in the same segment.
 06h	BYTE	number of dirty buffers on this chain
 07h	BYTE	reserved (00h)
Notes:	buffered disk sectors are assigned to chain N where N is the sector's
	  address modulo NDBCH,  0 <= N <= NDBCH-1
	each chain resides completely within one EMS page
	this structure is in main memory even if buffers are in EMS

Format of DOS 4.x disk buffer:
Offset	Size	Description
 00h	WORD	forward ptr, offset only, to next least recently used buffer
 02h	WORD	backward ptr, offset only
 04h	BYTE	drive (0=A,1=B, etc), FFh if not in use
 05h	BYTE	flags
		bit 7: remote buffer
		bit 6: buffer dirty
		bit 5: buffer has been referenced
		bit 4: search data buffer (only valid if remote buffer)
		bit 3: sector in data area
		bit 2: sector in a directory, either root or subdirectory
		bit 1: sector in FAT
		bit 0: reserved
 06h	DWORD	logical sector number
 0Ah	BYTE	number of copies to write
		for FAT sectors, same as number of FATs
		for data and directory sectors, usually 1
 0Bh	WORD	offset in sectors between copies to write for FAT sectors
 0Dh	DWORD	pointer to DOS Drive Parameter Block (see AH=32h)
 11h	WORD	buffer use count if remote buffer (see flags above)
 13h	BYTE	reserved
 14h		buffered data
Note:	all buffered sectors which have the same hash value (computed as the
	  sum of high and low words of the logical sector number divided by
	  NDBCH) are on the same doubly-linked circular chain
	the links consist of offset addresses only, the segment being the same
	  for all buffers in the chain.

Format of IFS driver list:
Offset	Size	Description
 00h	DWORD	pointer to next driver header
 04h  8 BYTEs	IFS driver name (blank padded), as used by FILESYS command
 0Ch  4 BYTEs	???
 10h	DWORD	pointer to IFS utility function entry point (see below)
		call with ES:BX -> IFS request (see below)
 14h	WORD	offset in header's segment of driver entry point
	???

Call IFS utility function entry point with:
	AH = 20h miscellaneous functions
	    AL = 00h get date
		Return: CX = year
			DH = month
			DL = day
	    AL = 01h get process ID and computer ID
		Return: BX = current PSP segment
			DX = active network machine number
	    AL = 05h get file system info
		ES:DI -> 16-byte info buffer
		Return: buffer filled
			Offset	Size	Description
			 00h  2 BYTEs	unused
			 02h	WORD	number of SFTs (actually counts only
					the first two file table arrays)
			 04h	WORD	number of FCB table entries
			 06h	WORD	number of proctected FCBs
			 08h  6 BYTEs	unused
			 0Eh	WORD	largest sector size supported
	    AL = 06h get machine name
		ES:DI -> 18-byte buffer for name
		Return: buffer filled with name starting at offset 02h
	    AL = 08h get sharing retry count
		Return: BX = sharing retry count
	    AL = other
		Return: CF set
	AH = 21h get redirection state
		BH = type (03h disk, 04h printer)
		Return: BH = state (00h off, 01h on)
	AH = 22h ??? some sort of time calculation
		AL = 00h ???
		    nonzero ???
	AH = 23h ??? some sort of time calculation
	AH = 24h compare filenames
	    DS:SI -> first ASCIZ filename
	    ES:DI -> second ASCIZ filename
	    Return: ZF set if files are same ignoring case and / vs \
	AH = 25h normalize filename
	    DS:SI -> ASCIZ filename
	    ES:DI -> buffer for result
	    Return: filename uppercased, forward slashes changed to backslashes
	AH = 26h get DOS stack
	    Return: DS:SI -> top of stack
		    CX = size of stack in bytes
	AH = 27h increment InDOS flag
	AH = 28h decrement InDOS flag
Note:	IFS drivers which do not wish to implement functions 20h or 24h-28h may
	  pass them on to the default handler pointed at by [LoL+37h]

Format of IFS request block:
Offset	Size	Description
 00h	WORD	total size in bytes of request
 02h	BYTE	class of request
		02h ???
		03h redirection
		04h ???
		05h file access
		06h convert error code to string
		07h ???
 03h	WORD	returned DOS error code
 05h	BYTE	IFS driver exit status
		00h success
		01h ???
		02h ???
		03h ???
		04h ???
		FFh internal failure
 06h 16 BYTEs	???
---request class 02h---
 16h	BYTE	function code
		04h ???
 17h	BYTE	unused???
 18h	DWORD	pointer to ???
 1Ch	DWORD	pointer to ???
 20h  2 BYTEs	???
---request class 03h---
 16h	BYTE	function code
 17h	BYTE	???
 18h	DWORD	pointer to ???
 1Ch	DWORD	pointer to ???
 22h	WORD	returned ???
 24h	WORD	returned ???
 26h	WORD	returned ???
 28h	BYTE	returned ???
 29h	BYTE	unused???
---request class 04h---
 16h	DWORD	pointer to ???
 1Ah	DWORD	pointer to ???
---request class 05h---
 16h	BYTE	function code
		01h flush disk buffers
		02h get disk space
		03h MKDIR
		04h RMDIR
		05h CHDIR
		06h delete file
		07h rename file
		08h search directory
		09h file open/create
		0Ah LSEEK
		0Bh read from file
		0Ch write to file
		0Dh lock region of file
		0Eh commit/close file
		0Fh get/set file attributes
		10h printer control
		11h ???
		12h process termination
		13h ???
	---class 05h function 01h---
	 17h  7	BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h  4 BYTEs	???
	 26h	BYTE	???
	 27h	BYTE	???
	---class 05h function 02h---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h  4 BYTEs	???
	 26h	WORD	returned total clusters
	 28h	WORD	returned sectors per cluster
	 2Ah	WORD	returned bytes per sector
	 2Ch	WORD	returned available clusters
	 2Eh	BYTE	returned ???
	 2Fh	BYTE	???
	---class 05h functions 03h,04h,05h---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h  4 BYTEs	???
	 26h	DWORD	pointer to directory name
	---class 05h function 06h---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h  4 BYTEs	???
	 26h	WORD	attribute mask
	 28h	DWORD	pointer to filename
	---class 05h function 07h---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h  4 BYTEs	???
	 26h	WORD	attribute mask
	 28h	DWORD	pointer to source filespec
	 2Ch	DWORD	pointer to destination filespec
	---class 05h function 08h---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h  4 BYTEs	???
	 26h	BYTE	00h FINDFIRST
			01h FINDNEXT
	 28h	DWORD	pointer to FindFirst search data + 01h if FINDNEXT
	 2Ch	WORD	search attribute if FINDFIRST
	 2Eh	DWORD	pointer to filespec if FINDFIRST
	---class 05h function 09h---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h	DWORD	pointer to IFS open file structure (see below)
	 26h	WORD	???  \ together, specify open vs. create, whether or
	 28h	WORD	???  / not to truncate
	 2Ah  4 BYTEs	???
	 2Eh	DWORD	pointer to filename
	 32h  4 BYTEs	???
	 36h	WORD	file attributes on call
			returned ???
	 38h	WORD	returned ???
	---class 05h function 0Ah---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h	DWORD	pointer to IFS open file structure (see below)
	 26h	BYTE	seek type (02h = from end)
	 28h	DWORD	offset on call
			returned new absolute position
	---class 05h functions 0Bh,0Ch---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h	DWORD	pointer to IFS open file structure (see below)
	 28h	WORD	number of bytes to transfer
			returned bytes actually transferred
	 2Ah	DWORD	transfer address
	---class 05h function 0Dh---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h	DWORD	pointer to IFS open file structure (see below)
	 26h	BYTE	file handle???
	 27h	BYTE	unused???
	 28h	WORD	???
	 2Ah	WORD	???
	 2Ch	WORD	???
	 2Eh	WORD	???
	---class 05h function 0Eh---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h	DWORD	pointer to IFS open file structure (see below)
	 26h	BYTE	00h commit file
			01h close file
	 27h	BYTE	unused???
	---class 05h function 0Fh---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h  4 BYTEs	???
	 26h	BYTE	02h GET attributes
			03h PUT attributes
	 27h	BYTE	unused???
	 28h 12 BYTEs	???
	 34h	WORD	search attributes???
	 36h	DWORD	pointer to filename
	 3Ah	WORD	(GET) returned ??? 
	 3Ch	WORD	(GET) returned ???
	 3Eh	WORD	(GET) returned ???
	 40h	WORD	(GET) returned ???
	 42h	WORD	(PUT) new attributes
			(GET) returned attributes
	---class 05h function 10h---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h	DWORD	pointer to IFS open file structure (see below)
	 26h	WORD	???
	 28h	DWORD	pointer to ???
	 2Ch	WORD	???
	 2Eh	BYTE	???
	 2Fh	BYTE	subfunction
			01h get printer setup
			03h ???
			04h ???
			05h ???
			06h ???
			07h ???
			21h set printer setup
	---class 05h function 11h---
	 17h  7 BYTEs	???
	 1Eh	DWORD	pointer to ???
	 22h	DWORD	pointer to IFS open file structure (see below)
	 26h	BYTE	subfunction
	 27h	BYTE	unused???
	 28h	WORD	???
	 2Ah	WORD	???
	 2Ch	WORD	???
	 2Eh	BYTE	???
	 2Fh	BYTE	???
	---class 05h function 12h---
	 17h 15 BYTEs	unused???
	 26h	WORD	PSP segment
	 28h	BYTE	type of process termination
	 29h	BYTE	unused???
	---class 05h function 13h---
	 17h 15 BYTEs	unused???
	 26h	WORD	PSP segment
---request class 06h---
 16h	DWORD	returned pointer to string corresponding to error code at 03h
 1Ah	BYTE	returned ???
 1Bh	BYTE	unused
---request class 07h---
 16h	DWORD	pointer to IFS open file structure (see below)
 1Ah	BYTE	???
 1Bh	BYTE	unused???

Format of IFS open file structure:
Offset	Size	Description
 00h	WORD	???
 02h	WORD	device info word
 04h	WORD	file open mode
 06h	WORD	???
 08h	WORD	file attributes
 0Ah	WORD	owner's network machine number
 0Ch	WORD	owner's PSP segment
 0Eh	DWORD	file size
 12h	DWORD	current offset in file
 16h	WORD	file time
 18h	WORD	file date
 1Ah 11 BYTEs	filename in FCB format
 25h	WORD	???
 27h	WORD	hash value of SFT address
		(low word of linear address + segment&F000h)
 29h  3 WORDs	network info from SFT
 2Fh	WORD	???

Format of one item in DOS 4 list of special program names:
Offset	Size	Description
 00h	BYTE	length of name (00h = end of list)
 01h  N BYTEs	name in format name.ext
 N    3 BYTEs	???
----------2153-------------------------------
INT 21 - DOS 2+ internal - TRANSLATE BIOS PARAMETER BLOCK
	AH = 53h
	DS:SI -> BPB (BIOS Parameter Block)
	ES:BP -> buffer for DOS Drive Parameter Block (see below)
Note:	translates BPB into a DOS Drive Parameter Block (see AH=32h)

Format of BIOS Parameter Block:
Offset	Size	Description
 00h	WORD	bytes/sector
 02h	BYTE	sectors/cluster. Get from (DPB byte 4) + 1
 03h	WORD	number of reserved sectors
 05h	BYTE	number of FATs
 06h	WORD	number of root directory entries
 08h	WORD	total number of sectors. Get from:
		  ((DPB bytes 0Dh-0Eh) - 1) * (sectors/cluster (BPB byte 2))
		    + (DPB Bytes 0Bh-0Ch)
		for DOS 4.0, set to zero if partition >32M, then set DWORD at
		  15h to actual number of sectors
 0Ah	BYTE	media descriptor byte
 0Bh	WORD	number of sectors per FAT
---DOS 3+---
 0Dh	WORD	number of sectors per track
 0Fh	WORD	number of heads
 11h	DWORD	number of hidden sectors
 15h 11 BYTEs	reserved	
---DOS 4.0---
 15h	DWORD	total number of sectors if word at 08h contains zero
 19h  6 BYTEs	???
 1Fh	WORD	number of cylinders
 21h	BYTE	device type
 22h	WORD	device attributes (removable or not, etc)
----------2154-------------------------------
INT 21 - DOS 2+ - GET VERIFY FLAG
	AH = 54h
Return: AL = 00h if flag OFF
	AL = 01h if flag ON
SeeAlso: AH=2Eh
----------2155-------------------------------
INT 21 - DOS 2+ internal - CREATE PSP
	AH = 55h
	DX = segment number at which to set up PSP (see AH=26h)
	SI = (DOS 3+) value to place in memory size field at DX:[0002h]
Notes:	like AH=26h but creates "child" PSP rather than copying existing one,
	  incrementing the reference count for each inherited file
	(DOS 2+) sets current PSP to DX
	(DOS 3+) marks "no inherit" file handles as closed in child PSP
SeeAlso: AH=26h,AH=50h
----------2156-------------------------------
INT 21 - DOS 2+ - RENAME A FILE
	AH = 56h
	DS:DX -> ASCIZ old name (drive and path allowed, no wildcards)
	ES:DI -> ASCIZ new name
Return: CF set on error
	    AX = error code (02h,03h,05h,11h) (see AH=59h)
	CF clear if successful
Notes:	allows move between directories on same logical volume
	does not set the archive attribute (see AX=4300h), which results in
	  incremental backups not backing up the file under its new name
	(DOS 3+) allows renaming of directories
	(DOS 3.1+) wildcards are allowed if invoked via AX=5D00h, in which case
	  error 12h (no more files) is returned on success, and both source and
	  destination specs must be canonical (as returned by AH=60h).
	  Wildcards in the destination are replaced by the corresponding char
	  of each source file being renamed.  Under DOS 3.x, the call will fail
	  if the destination wildcard is *.* or equivalent.
SeeAlso: AH=17h,AH=60h,AX=5D00h
----------215700-----------------------------
INT 21 - DOS 2+ - GET FILE'S DATE/TIME
	AX = 5700h
	BX = file handle
Return: CF set on error
	    AX = error code (01h,06h) (see AH=59h)
	CF clear if successful
	    CX = time of last write
		bits 11-15: hour
		     5-10:  minute
		     0-4:   seconds/2
	    DX = date of last write
		bits 9-15:   year-1980 (max 119 = 2099)
		     5-8:    month
		     0-4:    day
SeeAlso: AX=5701h
----------215701-----------------------------
INT 21 - DOS 2+ - SET FILE'S DATE/TIME
	AX = 5701h
	BX = file handle
	CX = time to be set (see AX=5700h)
	DX = date to be set (see AX=5700h)
Return: CF set on error
	    AX = error code (01h,06h) (see AH=59h)
	CF clear if successful
SeeAlso: AX=5700h
----------215702-----------------------------
INT 21 - DOS 4.0 - GET ???
	AX = 5702h
	BX = ??? (0000h through 0004h)
	DS:SI -> ???
	ES:DI -> result buffer
	CX = size of result buffer
Return: CX = size of returned data
SeeAlso: AX=5703h,AX=5704h
----------215703-----------------------------
INT 21 - DOS 4.0 - GET ???
	AX = 5703h
	BX = ??? (0000h through 0004h)
	DS:SI -> ???
	ES:DI -> result buffer
	CX = size of result buffer
Return: CX = size of returned data
SeeAlso: AX=5702h,AX=5704h
----------215704-----------------------------
INT 21 - DOS 4.0 - ???
	AX = 5704h
	BX = ??? (0000h through 0004h)
	DS:SI -> ???
	ES:DI -> result buffer
	CX = size of result buffer
Return: nothing???
SeeAlso: AX=5702h,AX=5703h
----------2158-------------------------------
INT 21 - DOS 3+ - GET/SET MEMORY ALLOCATION STRATEGY
	AH = 58h
	AL = function code
	    00h get allocation strategy
	    01h set allocation strategy
	       BL = strategy code
		   00h first fit (use first memory block large enough)
		   01h best fit (use smallest memory block large enough)
		   02h last fit (use high part of last usable memory block)
		   bit 7 set (DOS 5beta) to allow use of upper memory blocks
	    02h (DOS 5beta) get UMB link state
		Return: AL = 00h UMBs not part of DOS memory chain
			   = 01h UMBs in DOS memory chain
	    03h (DOS 5beta) set UMB link state
		BX = 0000h remove UMBs from DOS memory chain
		   = 0001h add UMBs to DOS memory chain
Return: CF set on error
	    AX = error code (01h) (see AH=59h)
	CF clear if successful
	    AX = strategy code if AL was 00h
	       = UMB link state if AL was 02h
Note: 	the Set subfunction accepts any value in BL; 2 or greater means last
	  fit under DOS 2 through DOS 4.x
	the Get subfunction returns the last value set, so programs should
	  check whether the value is >= 2, not just equal to 2.
	a program which changes the allocation strategy should restore it
	  before terminating
SeeAlso: AH=48h,AH=49h,AH=4Ah
----------2159-------------------------------
INT 21 - DOS 3+ - GET EXTENDED ERROR CODE
	AH = 59h
	BX = version code (0000h for DOS 3.x)
Return: AX = extended error code (see below)
	BH = class of error (see below)
	BL = suggested action (see below)
	CH = locus (where error occurred) (see below)
	CL, DX, SI, DI, BP, DS, and ES destroyed
Notes:	functions available under DOS 2.x map the true DOS 3+ error code into
	  one supported under DOS 2.x
	you should call this function to retrieve the true error code when an
	  FCB or DOS 2.x call returns an error
SeeAlso: AX=5D0Ah,INT 2F/AX=122Dh

Values for extended error code:
	01h function number invalid
	02h file not found
	03h path not found
	04h too many open files (no handles available)
	05h access denied
	06h invalid handle
	07h memory control block destroyed
	08h insufficient memory
	09h memory block address invalid
	0Ah environment invalid (usually >32K in length)
	0Bh format invalid
	0Ch access code invalid
	0Dh data invalid
	0Fh invalid drive
	10h attempted to remove current directory
	11h not same device
	12h no more files
---DOS 3+---
	13h disk write-protected
	14h unknown unit
	15h drive not ready
	16h unknown command
	17h data error (CRC)
	18h bad request structure length
	19h seek error
	1Ah unknown media type (non-DOS disk)
	1Bh sector not found
	1Ch printer out of paper
	1Dh write fault
	1Eh read fault
	1Fh general failure
	20h sharing violation
	21h lock violation
	22h disk change invalid
	    ES:DI -> ASCIZ volume label of required disk
	23h FCB unavailable
	24h sharing buffer overflow
	25h reserved
	26h (LANtastic) cannot complete file operation
	27h-31h reserved
	32h network request not supported
	33h remote computer not listening
	34h duplicate name on network
	35h network name not found
	36h network busy
	37h network device no longer exists
	38h network BIOS command limit exceeded
	39h network adapter hardware error
	3Ah incorrect response from network
	3Bh unexpected network error
	3Ch incompatible remote adapter
	3Dh print queue full
	3Eh queue not full
	3Fh not enough space to print file
	40h network name was deleted
	41h network: Access denied
	42h network device type incorrect
	43h network name not found
	44h network name limit exceeded
	45h network BIOS session limit exceeded
	46h temporarily paused
	47h network request not accepted
	48h network print/disk redirection paused
	49h (LANtastic) invalid network version
	4Ah (LANtastic) account expired
	4Bh (LANtastic) password expired
	4Ch (LANtastic) login attempt invalid at this time
	4Dh (LANtastic v3+) disk limit exceeded on network node
	4Eh (LANtastic v3+) not logged in to network node
	4Fh reserved
	50h file exists
	51h reserved
	52h cannot make directory
	53h fail on INT 24h
	54h (DOS 3.3+) too many redirections
	55h (DOS 3.3+) duplicate redirection
	56h (DOS 3.3+) invalid password
	57h (DOS 3.3+) invalid parameter
	58h (DOS 3.3+) network write fault
	59h (LANtastic) function not supported on network
	5Ah (LANtastic) required system component not installed

Values for Error Class:
	01h out of resource (storage space or I/O channels)
	02h temporary situation (file or record lock)
	03h authorization (denied access)
	04h internal (system software bug)
	05h hardware failure
	06h system failure (configuration file missing or incorrect)
	07h application program error
	08h not found
	09h bad format
	0Ah locked
	0Bh media error
	0Ch already exists
	0Dh unknown

Values for Suggested Action:
	01h retry
	02h delayed retry
	03h prompt user to reenter input
	04h abort after cleanup
	05h immediate abort
	06h ignore
	07h retry after user intervention

Values for Error Locus:
	01h unknown or not appropriate
	02h block device (disk error)
	03h network related
	04h serial device (timeout)
	05h memory related
----------215A-------------------------------
INT 21 - DOS 3+ - CREATE UNIQUE FILE
	AH = 5Ah
	DS:DX -> ASCIZ directory path name ending with a '\' + 13 bytes to
		 receive generated filename
	CX = file attributes (only bits 0,1,2,5 may be set)
Return: CF set on error
	    AX = error code (03h,05h) (see AH=59h)
	CF clear if successful
	    AX = file handle
	DS:DX -> path name
Notes:	the file created is not truly temporary; it MUST be removed by the user
	COMPAQ DOS 3.31 hangs if the pathname is at XXXXh:0000h; it apparently
	  wraps around to the end of the segment
SeeAlso: AH=3Ch,AH=5Bh
----------215B-------------------------------
INT 21 - DOS 3+ - CREATE NEW FILE
	AH = 5Bh
	DS:DX -> ASCIZ directory path name
	CX = file attribute (see AX=4301h)
Return: CF set on error
	    AX = error code (03h,04h,05h,50h) (see AH=59h)
	CF clear if successful
	    AX = file handle
Note:	unlike function 3Ch, function 5Bh will fail if the file already exists
SeeAlso: AH=3Ch,AH=5Ah
----------215C-------------------------------
INT 21 - DOS 3+ - LOCK/UNLOCK FILE ACCESS
	AH = 5Ch
	AL = 00h lock
	     01h unlock
	BX = file handle
	CX:DX = starting offset of region to lock
	SI:DI = size of region to lock
Return: CF set on error
	    AX = error code (01h,06h,21h) (see AH=59h)
	CF clear if successful
Note:	error returned unless SHARE or network installed
SeeAlso: AX=440Bh, INT 2F/AX=110Ah,110Bh
----------215D00-----------------------------
INT 21 - DOS 3.1+ internal - SERVER FUNCTION CALL
	AX = 5D00h
	DS:DX -> DOS parameter list (see below)
	DPL contains all register values for a call to INT 21h
Return: as appropriate for function being called
Notes:	does not check AH.  Out of range values will crash the system
	executes using specified computer ID and process ID
	sharing delay loops skipped
	a special sharing mode is enabled
	wildcards are enabled for DELETE (AH=41h) and RENAME (AH=56h)
	functions which take filenames require canonical names (as returned by
	  AH=60h); this is apparently to prevent multi-hop file forwarding
SeeAlso: AH=60h

Format of DOS parameter list:
Offset	Size	Description
 00h	WORD	AX 
 02h	WORD	BX
 04h	WORD	CX
 06h	WORD	DX
 08h	WORD	SI
 0Ah	WORD	DI
 0Ch	WORD	DS
 0Eh	WORD	ES
 10h	WORD	reserved (0)
 12h	WORD	computer ID (0 = current system)
 14h	WORD	process ID (PSP segment on specified computer)
----------215D01-----------------------------
INT 21 - DOS 3.1+ internal - COMMIT ALL FILES FOR SPECIFIED COMPUTER/PROCESS
	AX = 5D01h
	DS:DX -> DOS parameter list (see AX=5D00h), only computer ID and
		process ID fields used
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Notes:	flushes buffers and updates directory entries for each file which has
	  been written to; if remote file, calls INT 2F/AX=1107h
	the computer ID and process ID are stored but ignored under DOS 3.3
SeeAlso: AH=68h, INT 2F/AX=1107h
----------215D02-----------------------------
INT 21 - DOS 3.1+ internal - SHARE.EXE - CLOSE FILE BY NAME
	AX = 5D02h
	DS:DX -> DOS parameter list (see AX=5D00h), only fields DX, DS,
		computer ID, and process ID used
	DPL's DS:DX -> ASCIZ name of file to close
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Notes:	error unless SHARE is loaded (calls [SysFileTable-28h]) (see AH=52h)
	name must be canonical fully-qualified, such as returned by AH=60h
SeeAlso: AX=5D03h,5D04h,AH=3Eh,60h
----------215D03-----------------------------
INT 21 - DOS 3.1+ internal - SHARE.EXE - CLOSE ALL FILES FOR GIVEN COMPUTER
	AX = 5D03h
	DS:DX -> DOS parameter list (see AX=5D00h), only computer ID used
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Note:	error unless SHARE is loaded (calls [SysFileTable-30h]) (see AH=52h)
SeeAlso: AX=5D02h,5D04h
----------215D04-----------------------------
INT 21 - DOS 3.1+ internal - SHARE.EXE - CLOSE ALL FILES FOR GIVEN PROCESS
	AX = 5D04h
	DS:DX -> DOS parameter list (see AX=5D00h), only computer ID and
		process ID fields used
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Note:	error unless SHARE is loaded (calls [SysFileTable-2Ch]) (see AH=52h)
SeeAlso: AX=5D02h,AX=5D03h
----------215D05-----------------------------
INT 21 - DOS 3.1+ internal - SHARE.EXE - GET OPEN FILE LIST ENTRY
	AX = 5D05h
	DS:DX -> DOS parameter list (see AX=5D00h)
	DPL's BX = index of sharing record
	DPL's CX = index of SFT in sharing record's SFT list
Return: CF clear if successful
	    ES:DI -> ASCIZ filename
	    BX = network machine number of SFT's owner
	    CX = number of locks held by SFT's owner
	CF set if either index out of range
	    AX = 0012h (no more files)
Notes:	error unless SHARE is loaded (calls [SysFileTable-18h]) (see AH=52h)
	names are always canonical fully-qualified, such as returned by AH=60h
SeeAlso: AH=5Ch,AH=60h 
----------215D06-----------------------------
INT 21 - DOS 3.0+ internal - GET ADDRESS OF DOS SWAPPABLE DATA AREA
	AX = 5D06h
Return: CF set on error
	   AX = error code (see AH=59h)
	CF clear if successful
	    DS:SI -> nonreentrant data area (includes all three DOS stacks)
		(critical error flag is first byte)
	    CX = size in bytes of area which must be swapped while in DOS
	    DX = size in bytes of area which must always be swapped
Notes:	the Critical Error flag is used in conjunction with the InDOS flag
	  (see AH=34h) to determine when it is safe to enter DOS from a TSR
	setting CritErr flag allows use of functions 50h/51h from INT 28h under
	  DOS 2.x by forcing use of correct stack
	swapping the data area allows reentering DOS unless DOS is in a
	  critical section delimited by INT 2A/AH=80h and INT 2A/AH=81h,82h
	under DOS 4.0, AX=5D0Bh should be used instead of this function
SeeAlso: AX=5D0Bh, INT 2A/AH=80h,81h,82h

Format of DOS 3.10-3.30 Swappable Data Area:
Offset	Size	Description
 00h	BYTE	critical error flag
 01h	BYTE	InDOS flag (count of active INT 21 calls)
 02h	BYTE	drive on which current critical error occurred, or FFh
 03h	BYTE	locus of last error
 04h	WORD	extended error code of last error
 06h	BYTE	suggested action for last error
 07h	BYTE	class of last error
 08h	DWORD	ES:DI pointer for last error
 0Ch	DWORD	current DTA
 10h	WORD	current PSP
 12h	WORD	stores SP across an INT 23
 14h	WORD	return code from last process termination (zerod after reading
		with AH=4Dh)
 16h	BYTE	current drive
 17h	BYTE	extended break flag
---remainder need only be swapped if in DOS---
 18h	WORD	value of AX on call to INT 21
 1Ah	WORD	PSP segment for sharing/network
 1Ch	WORD	network machine number for sharing/network (0000h = us)
 1Eh	WORD	first usable memory block found when allocating memory
 20h	WORD	best usable memory block found when allocating memory
 22h	WORD	last usable memory block found when allocating memory
 24h	WORD 	memory size in paragraphs (used only during initialization)
 26h	WORD	???
 28h	BYTE	???
 29h	BYTE	???
 2Ah	BYTE	???
 2Bh	BYTE	FFh if Ctrl-Break termination, 00h otherwise
 2Ch	BYTE	??? flag of some kind
 2Dh	BYTE	??? (doesn't seem to be referenced)
 2Eh	BYTE	day of month
 2Fh	BYTE	month
 30h	WORD	year - 1980
 32h	WORD	number of days since 1-1-1980
 34h	BYTE	day of week (0 = Sunday)
 35h	BYTE	???
 36h	BYTE	??? flag
 37h	BYTE	??? flag
 38h 26 BYTEs	device driver request header
 52h	DWORD	pointer to device driver entry point (used in calling driver)
 56h 22 BYTEs	device driver request header
 6Ch 22 BYTEs	device driver request header
 82h	BYTE	type of PSP copy (00h=simple for INT 21/AH=26h, FFh=make child)
 83h	BYTE	??? apparently not reference by kernel
 84h  3 BYTEs	24-bit user number (see AH=30h)
 87h	BYTE	OEM number (see AH=30h)
 88h  2 BYTEs	???
 8Ah  6 BYTEs	CLOCK$ transfer record (see AH=52h)
 90h  2 BYTEs	???
 92h 128 BYTEs	buffer for filename
112h 128 BYTEs	buffer for filename
192h 21 BYTEs	findfirst/findnext search data block (see AH=4Eh)
1A7h 32 BYTEs	directory entry for found file
1C7h 81 BYTEs	copy of current directory structure for drive being accessed
218h 11 BYTEs	??? FCB-format filename
223h	BYTE	unused???
224h 11 BYTEs	wildcard destination specification for rename (FCB format)
22Fh  2 BYTEs	???
231h	WORD	???
233h  5 BYTEs	???
238h	BYTE	directory search attributes
239h	BYTE	type of FCB (00h regular, FFh extended)
23Ah	BYTE	extended FCB file attribute
23Bh	BYTE	file open mode???
23Ch	BYTE	??? flag bits
23Dh	BYTE	??? flag or counter
23Eh	BYTE	??? flag
23Fh	BYTE	flag indicating how DOS function was invoked
		(00h = direct INT 20/INT 21, FFh = server call AX=5D00h)
240h	WORD	???
242h	BYTE	???
243h	BYTE	???
244h	BYTE	???
245h	BYTE	??? flag or counter
246h	BYTE	??? flag
247h	BYTE	??? flag
248h	BYTE	??? flag
249h	BYTE	type of process termination (00h-03h) (see AH=4Dh)
24Ah	BYTE	??? flag
24Bh	BYTE	value with which to replace first byte of deleted file's name
		(normally E5h, but 00h as described under INT 21/AH=13h)
24Ch	DWORD	pointer to Drive Parameter Block for critical error invocation
250h	DWORD	pointer to stack frame containing user registers on INT 21
254h	WORD	stores SP???
256h	DWORD	pointer to DOS Drive Parameter Block for ???
25Ah	WORD	???
25Ch	WORD	???
25Eh	WORD	??? flag
260h	WORD	???
262h	BYTE	Media ID byte returned by AH=1Bh,1Ch
263h	BYTE	??? (doesn't seem to be referenced)
264h	DWORD	pointer to ???
268h	DWORD	pointer to current SFT
26Ch	DWORD	pointer to current directory structure for drive being accessed
270h	DWORD	pointer to caller's FCB
274h	WORD	???
276h	WORD	temporary storage for file handle
278h	DWORD	pointer to a JFT entry in process handle table (see AH=26h)
27Ch	WORD	offset in DOS CS of first filename argument
27Eh	WORD	offset in DOS CS of second filename argument
280h	WORD	???
282h	WORD	???
284h	WORD	???
286h	WORD	???
288h	WORD	???
28Ah	WORD	???
28Ch	WORD	???
28Eh  2 BYTEs	???
290h	WORD	???
292h	DWORD	current offset in file
296h	WORD	???
298h	WORD	???
29Ah	WORD	???
29Ch	WORD	???
29Eh	WORD	???
2A0h	WORD	???
2A2h	DWORD	number of bytes appended to file
2A6h	DWORD	pointer to ??? disk buffer
2AAh	DWORD	pointer to ??? SFT
2AEh	WORD	used by INT 21 dispatcher to store caller's BX
2B0h	WORD	used by INT 21 dispatcher to store caller's DS
2B2h	WORD	temporary storage while saving/restoring caller's registers
2B4h	DWORD	pointer to prev call frame (offset 250h) if INT 21 reentered
		also switched to for duration of INT 24
2B8h 21 BYTEs	FindFirst search data for source file(s) of a rename operation
		(see AH=4Eh)
2CDh 32 BYTEs	directory entry for file being renamed
2EDh 331 BYTEs	critical error stack
438h 384 BYTEs	disk stack (functions greater than 0Ch, INT 25, INT 26)
5B8h 384 BYTEs	character I/O stack (functions 01h through 0Ch)
---DOS 3.3 only---
738h	BYTE	flag affecting AH=08h (see AH=64h)
739h	BYTE	??? looks like a drive number
73Ah	BYTE	??? flag of some kind
73Ah	BYTE	???
----------215D07-----------------------------
INT 21 - DOS 3.1+ network - GET REDIRECTED PRINTER MODE
	AX = 5D07h
Return: DL = mode
	    00h redirected output is combined
	    01h redirected output in separate print jobs
SeeAlso: AX=5D08h,AX=5D09h, INT 2F/AX=1125h
----------215D08-----------------------------
INT 21 - DOS 3.1+ network - SET REDIRECTED PRINTER MODE
	AX = 5D08h
	DL = mode
	    00h redirected output is combined
	    01h redirected output placed in separate jobs, start new print job
		now
SeeAlso: AX=5D07h,AX=5D09h, INT 2F/AX=1125h
----------215D-------------------------------
INT 21 - DOS 3.1+ network - FLUSH REDIRECTED PRINTER OUTPUT
	AH = 5D09h
Note:	forces redirected printer output to be printed, and starts a new print
	  job
SeeAlso: AX=5D07h,AX=5D08h, INT 2F/AX=1125h
----------215D0A-----------------------------
INT 21 - DOS 3.1+ internal - SET EXTENDED ERROR INFORMATION
	AX = 5D0Ah
	DS:DX -> 11-word DOS parameter list (see AX=5D00h)
Return: nothing.  next call to AH=59h will return values from fields AX,BX,CX,
	  DX,DI, and ES in corresponding registers
SeeAlso: AH=59h
----------215D0B-----------------------------
INT 21 - DOS 4.x internal - GET DOS SWAPPABLE DATA AREAS
	AX = 5D0Bh
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    DS:SI -> swappable data area list (see below)
Note:	copying and restoring the swappable data areas allows DOS to be
	  reentered unless it is in a critical section delimited by calls to
	  INT 2A/AH=80h and INT 2A/AH=81h,82h
SeeAlso: AX=5D06h, INT 2A/AH=80h,81h,82h

Format of swappable data area list:
Offset	Size	Description
 00h	WORD	count of data areas
 02h  N BYTEs	"count" copies of data area record
		Offset	Size	Description
		 00h	DWORD	address
		 04h	WORD	length and type
				bit 15 set if swap always, clear if swap in DOS
				bits 14-0: length in bytes

Format of PCDOS 4.01 swappable data area:
Offset	Size	Description
 00h	BYTE	critical error flag
 01h	BYTE	InDOS flag (count of active INT 21 calls)
 02h	BYTE	??? drive number or FFh
 03h	BYTE	locus of last error
 04h	WORD	extended error code of last error
 06h	BYTE	suggested action for last error
 07h	BYTE	class of last error
 08h	DWORD	ES:DI pointer for last error
 0Ch	DWORD	current DTA
 10h	WORD	current PSP
 12h	WORD	stores SP across an INT 23
 14h	WORD	return code from last process termination (zerod after reading
		with AH=4Dh)
 16h	BYTE	current drive
 17h	BYTE	extended break flag
 18h  2 BYTEs	???
---remainder need only be swapped if in DOS---
 1Ah	WORD	value of AX on call to INT 21
 1Ch	WORD	PSP segment for sharing/network
 1Eh	WORD	network machine number for sharing/network (0000h = us)
 20h	WORD	first usable memory block found when allocating memory
 22h	WORD	best usable memory block found when allocating memory
 24h	WORD	last usable memory block found when allocating memory
 26h  2 BYTEs	??? (don't seem to be referenced)
 28h	WORD	???
 2Ah	BYTE	???
 2Bh	BYTE	???
 2Ch	BYTE	???
 2Dh	BYTE	???
 2Eh	BYTE	???
 2Fh	BYTE	??? (doesn't seem to be referenced)
 30h	BYTE	day of month
 31h	BYTE	month
 32h	WORD	year - 1980
 34h	WORD	number of days since 1-1-1980
 36h	BYTE	day of week (0 = Sunday)
 37h	BYTE	???
 38h	BYTE	???
 39h	BYTE	???
 38h 30 BYTEs	device driver request header
 58h	DWORD	pointer to device driver entry point (used in calling driver)
 5Ch 22 BYTEs	device driver request header
 72h 30 BYTEs	device driver request header
 90h  6	BYTEs	???
 96h  6 BYTEs	CLOCK$ transfer record (see AH=52h)
 9Ch  2 BYTEs	???
 9Eh 128 BYTEs	buffer for filename
11Eh 128 BYTEs	buffer for filename
19Eh 21 BYTEs	findfirst/findnext search data block (see AH=4Eh)
1B3h 32 BYTEs	directory entry for found file
1D3h 88 BYTEs	copy of current directory structure for drive being accessed
22Bh 11 BYTEs	??? FCB-format filename
236h	BYTE	???
237h 11 BYTEs	wildcard destination specification for rename (FCB format)
242h  2 BYTEs	???
244h	WORD	???
246h  5 BYTEs	???
24Bh	BYTE	???
24Ch	BYTE	???
24Dh	BYTE	attribute mask for directory search???
24Eh	BYTE	???
24Fh	BYTE	??? flag bits
250h	BYTE	???
251h	BYTE	???
252h	BYTE	flag indicating how DOS function was invoked
		(00h = direct INT 20/INT 21, FFh = server call AX=5D00h)
253h	BYTE	???
254h	BYTE	???
255h	BYTE	???
256h	BYTE	???
257h	BYTE	???
258h	BYTE	???
259h	BYTE	???
25Ah	BYTE	???
25Bh	BYTE	???
25Ch	BYTE	type of process termination (00h-03h)
25Dh	BYTE	???
25Eh	BYTE	???
25Fh	BYTE	???
260h	DWORD	pointer to Drive Parameter Block for critical error invocation
264h	DWORD	pointer to stack frame containing user registers on INT 21
268h	WORD	stores SP???
26Ah	DWORD	pointer to DOS Drive Parameter Block for ???
26Eh	WORD	segment of disk buffer
270h	WORD	???
272h	WORD	???
274h	WORD	???
276h	WORD	???
278h	BYTE	Media ID byte returned by AH=1Bh,1Ch
279h	BYTE	??? (doesn't seem to be referenced)
27Ah	DWORD	pointer to ???
27Eh	DWORD	pointer to current SFT
282h	DWORD	pointer to current directory structure for drive being accessed
286h	DWORD	pointer to caller's FCB
28Ah	WORD	???
28Ch	WORD	???
28Eh	DWORD	pointer to a JFT entry in process handle table (see AH=26h)
292h	WORD	offset in DOS CS of first filename argument
294h	WORD	offset in DOS CS of second filename argument
296h	WORD	???
298h	WORD	???
29Ah	WORD	???
29Ch	WORD	???
29Eh	WORD	???
2A0h	WORD	???
2A2h	WORD	??? directory cluster number???
2A4h	DWORD	???
2A8h	DWORD	???
2ACh	WORD	???
2AEh	DWORD	offset in file???
2B2h	WORD	???
2B4h	WORD	bytes in partial sector
2B6h	WORD	number of sectors
2B8h	WORD	???
2BAh	WORD	???
2BCh	WORD	???
2BEh	DWORD	number of bytes appended to file
2C2h	DWORD	pointer to ??? disk buffer
2C6h	DWORD	pointer to ??? SFT
2CAh	WORD	used by INT 21 dispatcher to store caller's BX
2CCh	WORD	used by INT 21 dispatcher to store caller's DS
2CEh	WORD	temporary storage while saving/restoring caller's registers
2D0h	DWORD	pointer to prev call frame (offset 264h) if INT 21 reentered
		also switched to for duration of INT 24
2D4h	WORD	???
2D6h	BYTE	???
2D7h	WORD	???
2D9h	DWORD	pointer to ???
2DDh	WORD	???
2DFh	WORD	???
2E1h	WORD	???
2E3h	DWORD	???
2E7h	WORD	???
2E9h	WORD	???
2EBh	BYTE	???
2ECh	WORD	stores DS during call to [List-of-Lists + 37h]
2EEh	WORD	???
2F0h	BYTE	???
2F1h	WORD	??? bit flags
2F3h	DWORD	pointer to user-supplied filename
2F7h	DWORD	pointer to ???
2FBh	WORD	stores SS during call to [List-of-Lists + 37h]
2FDh	WORD	stores SP during call to [List-of-Lists + 37h]
2FFh	BYTE	flag, nonzero if stack switched in calling [List-of-Lists+37h]
300h 21 BYTEs	FindFirst search data for source file(s) of a rename operation
		(see AH=4Eh)
315h 32 BYTEs	directory entry for file being renamed
335h 331 BYTEs	critical error stack
480h 384 BYTEs	disk stack (functions greater than 0Ch, INT 25, INT 26)
600h 384 BYTEs	character I/O stack (functions 01h through 0Ch)
780h	BYTE	flag affecting AH=08h (see AH=64h)
781h	BYTE	??? looks like a drive number
782h	BYTE	??? flag of some kind
783h	BYTE	???
784h	WORD	???
786h	WORD	???
788h	WORD	???
78Ah	WORD	???
----------215E00-----------------------------
INT 21 - DOS 3.1 + Microsoft Networks - GET MACHINE NAME
	AX = 5E00h
	DS:DX -> buffer for blank-padded ASCIZ name (16 bytes)
Return: CF set on error
	    AX = error code (01h) (see AH=59h)
	CH = 00h if name not defined
	  <> 00h defined
		CL = NETBIOS name number
		DS:DX buffer filled with ASCIZ machine name
SeeAlso: AX=5E01h
----------215E01-----------------------------
INT 21 - DOS 3.1 + Microsoft Networks - SET MACHINE NAME
	AX = 5E01h
	CH = 00h undefine name
	   <> 0  define name
	CL = name number
	DS:DX -> 15-character blank-padded ASCIZ name
SeeAlso: AX=5E00h
----------215E02-----------------------------
INT 21 - DOS 3.1 + Microsoft Networks - SET PRINTER SETUP
	AX = 5E02h
	BX = redirection list index
	CX = length of setup string (<= 64)
	DS:SI -> string buffer
Return: CF set on error
	    AX = error code (01h) (see AH=59h)
	CF clear if successful
SeeAlso: AX=5E03h, INT 2F/AX=111Fh
----------215E03-----------------------------
INT 21 - DOS 3.1 + Microsoft Networks - GET PRINTER SETUP
	AX = 5E03h
	BX = redirection list index
	ES:DI -> string buffer
Return: CF set on error
	    AX = error code (01h) (see AH=59h)
	CX = length of setup string (<= 64)
SeeAlso: AX=5E02h, INT 2F/AX=111Fh
----------215E04-----------------------------
INT 21 - DOS 3.1 + Microsoft Networks - SET PRINTER MODE
	AX = 5E04h
	BX = redirection list index
	DX = mode
	    bit 0: set if binary, clear if text (tabs expanded to blanks)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Note:	calls INT 2F/AX=111Fh with 5E04h on stack
SeeAlso: AX=5E05h, INT 2F/AX=111Fh
----------215E05-----------------------------
INT 21 - DOS 3.1 + Microsoft Networks - GET PRINTER MODE
	AX = 5E05h
	BX = redirection list index
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    DX = printer mode (see AX=5E04h)
Note:	calls INT 2F/AX=111Fh with 5E05h on stack
SeeAlso: AX=5E04h, INT 2F/AX=111Fh
----------215F00-----------------------------
INT 21 - DOS 3.1+ network - GET REDIRECTION MODE
	AX = 5F00h
	BL = redirection type
	    03h printer
	    04h disk drive
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    BH = redirection state
		00h off
		01h on
SeeAlso: AX=5F01h
----------215F01-----------------------------
INT 21 - DOS 3.1+ network - SET REDIRECTION MODE
	AX = 5F01h
	BL = redirection type
	    03h printer
	    04h disk drive
	BH = redirection state
	    00h off
	    01h on
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Note:	when redirection is off, the local device (if any) rather than the
	  remote device is used
SeeAlso: AX=5F00h, INT 2F/AX=111Eh
----------215F02-----------------------------
INT 21 - DOS 3.1 + Microsoft Networks, VINES - GET REDIRECTION LIST ENTRY
	AX = 5F02h
	BX = redirection list index
	DS:SI -> 16 char local device name buffer
	ES:DI -> 128 char network name buffer
Return: CF set on error
	    AX = error code (01h,12h) (see AH=59h)
	CF clear if successful
	    BH = device status flag (bit 0 = 0 if valid)
	    BL = device type (03h if printer, 04h if drive)
	    CX = stored parameter value (user data)
	    DS:SI and ES:DI buffers filled
Notes:	DX and BP are destroyed by this call!
	error code 12h is returned if BX is greater than the size of the list
SeeAlso: AX=5F03h, INT 2F/AX=111Eh
----------215F03-----------------------------
INT 21 - DOS 3.1 + Microsoft Networks, Banyan VINES - REDIRECT DEVICE
	AX = 5F03h
	BL = device type
		03h = printer device
		04h = file device
	CX = stored parameter value
	DS:SI -> ASCIZ source device name
	ES:DI -> destination ASCIZ network path + ASCIZ password
Return: CF set on error
	    AX = error code (01h,03h,05h,08h,54h,55h,57h) (see AH=59h)
	CF clear if successful
SeeAlso: AX=5F02h,AX=5F04h, INT 2F/AX=111Eh
----------215F04-----------------------------
INT 21 - DOS 3.1 + Microsoft Networks, Banyan VINES - CANCEL REDIRECTION
	AX = 5F04h
	DS:SI -> ASCIZ device name or network path
Return: CF set on error
	    AX = error code (01h,0Fh,57h) (see AH=59h)
	CF clear if successful
SeeAlso: AX=5F03h, INT 2F/AX=111Eh
----------215F05-----------------------------
INT 21 - DOS 4.x + Microsoft Networks - GET REDIRECTION LIST EXTENDED ENTRY
	AX = 5F05h
	BX = redirection list index
	DS:SI -> buffer for ASCIZ source device name
	ES:DI -> buffer for destination ASCIZ network path
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    BH = device status flag (bit 0 clear if valid)
	    BL = device type (03h if printer, 04h if drive)
	    CX = stored parameter value (user data)
	    BP = NETBIOS local session number
	    DS:SI buffer filled
	    ES:DI buffer filled
Notes:	the local session number allows sharing the redirector's session number
	if an error is caused on the NETBIOS LSN, the redirector may be unable
	  to correctly recover from errors
SeeAlso: AX=5F06h"Network",INT 2F/AX=111Eh
----------215F05-----------------------------
INT 21 - STARLITE architecture - MAP LOCAL DRIVE LETTER TO REMOTE FILE SYSTEM
	AX = 5F05h
	DL = drive number (0=A:)
	DS:SI -> ASCIZ name of the object to map the drive to
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
SeeAlso: AX=5F06h"STARLITE"
----------215F06-----------------------------
INT 21 - Network - GET REDIRECTION LIST???
	AX = 5F06h
	???
Return: ???
Note:	appears to be similar to AX=5F02h and AX=5F05h
SeeAlso: AX=5F05h"DOS", INT 2F/AX=111Eh
----------215F06-----------------------------
INT 21 - STARLITE architecture - UNMAP DRIVE LETTER
	AX = 5F06h
	DL = drive to be unmapped (0=A:)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
SeeAlso: AX=5F05h"STARLITE"
----------215F07-----------------------------
INT 21 - STARLITE architecture - MAKE NAMED OBJECT AVAILABLE ON NETWORK
	AX = 5F07h
	DS:SI -> ASCIZ name of object to offer to network
	ES:DI -> ASCIZ name under which object will be known on the network
		MUST begin with three slashes
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
SeeAlso: AX=5F08h
----------215F08-----------------------------
INT 21 - STARLITE architecture - REMOVE GLOBAL NETWORK NAME OF OBJECT
	AX = 5F08h
	DS:SI -> ASCIZ network name (not local name) of object to unshare
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
SeeAlso: AX=5F07h
----------215F09-----------------------------
INT 21 - STARLITE architecture - BIND TO NETWORK DEVICE
	AX = 5F09h
	DS:DX -> ASCIZ name of the device driver to attach to
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Note:	the STARLITE distributed file system can attach to multiple networks
	  simultaneously
SeeAlso: AX=5F0Ah
----------215F0A-----------------------------
INT 21 - STARLITE architecture - DETACH FROM NETWORK DEVICE
	AX = 5F0Ah
	DS:DX -> ASCIZ name of device driver to detach from
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
SeeAlso: AX=5F09h
----------215F80-----------------------------
INT 21 - LANtastic - GET LOGIN ENTRY
	AX = 5F80h
	BX = login entry index (0-based)
	ES:DI -> 16-byte buffer for machine name
Return: CF clear if successful
	    buffer filled with machine name ("\\" prefix removed)
	    DL = adapter number (v3+)
	CF set on error
	    AX = error code
	BX = next login entry index (BX-1 is current index)
----------215F81-----------------------------
INT 21 - LANtastic - LOGIN TO SERVER
	AX = 5F81h
	ES:DI -> ASCIZ login path followed immediately by ASCIZ password
	BL = adapter number
	    FFh try all valid adapters
	    00h-03h try only specified adapter
Return: CF clear if successful
	CF set on error
	    AX = error code
Note:	login path is of form "\\machine\username"
SeeAlso: AX=5F82h,AX=5F84h
----------215F82-----------------------------
INT 21 - LANtastic - LOGOUT FROM SERVER
	AX = 5F82h
	ES:DI -> ASCIZ server name (in form "\\machine")
Return: CF clear if successful
	CF set on error
	    AX = error code
SeeAlso: AX=5F81h
----------215F83-----------------------------
INT 21 - LANtastic - GET USERNAME ENTRY
	AX = 5F83h
	BX = login entry index (0-based)
	ES:DI -> 16-byte buffer for username currently logged into
Return: CF clear if successful
	    DL = adapter number (v3+)
	CF set on error
	    AX = error code
	BX = next login entry index (BX-1 is current index)
----------215F84-----------------------------
INT 21 - LANtastic - GET INACTIVE SERVER ENTRY
	AX = 5F84h
	BX = server index not currently logged into
	ES:DI -> 16-byte buffer for server name which is available for logging
		in to ("\\" prefix omitted)
Return: CF clear if successful
	    DL = adapter number to non-logged in server is on
	CF set on error
	    AX = error code
SeeAlso: AX=5F81h
----------215F85-----------------------------
INT 21 - LANtastic - CHANGE PASSWORD
	AX = 5F85h
	ES:DI -> buffer containing "\\machine\oldpassword" 00h "newpassword"00h
Return: CF clear if successful
	CF set on error
	    AX = error code
Note:	must be logged into the named machine
----------215F86-----------------------------
INT 21 - LANtastic - DISABLE ACCOUNT
	AX = 5F86h
	ES:DI -> ASCIZ machine name and password in form "\\machine\password"
Return: CF clear if successful
	CF set on error
	    AX = error code
Note:	must be logged into the named machine and concurrent logins set to 1
	  by NET_MGR.  Requires system manager to re-enable account.
----------215F87-----------------------------
INT 21 - LANtastic v3+ - GET ACCOUNT
	AX = 5F87h
	DS:SI -> 128-byte buffer for account information (see below)
	ES:DI -> ASCIZ machine name in form "\\machine"
Return:	CF clear if successful
	CF set on error
	    AX = error code
	BX destroyed
Note:	must be logged into the specified machine

Format of user account structure:
Offset	Size	Description
 00h 16 BYTEs	blank-padded username
 10h 16 BYTEs	reserved (00h)
 20h 32 BYTEs	user description
 40h	BYTE	privilege bits
		bit 7: bypass access control lists
		    6: bypass queue protection
		    5: treat as local process
		    4: bypass mail protection
		    3: allow audit entry creation
		    2: system manager
 41h	BYTE	maximum concurrent users
 42h 42 BYTEs	bit map for disallowed half hours, beginning on Sunday
		(bit set if half-hour not an allowed time)
 6Ch	WORD	internal (0002h)
 6Eh  2 WORDs	last login time
 72h  2 WORDs	account expiration date (MSDOS-format year/month:day)
 76h  2 WORDs	password expiration date (0 = none)
 7Ah	BYTE	number of days to extend password after change (1-31)
 7Bh  5 BYTEs	reserved
----------215F97-----------------------------
INT 21 - LANtastic - COPY FILE
	AX = 5F97h
	CX:DX = number of bytes to copy (FFFFFFFFh = entire file)
	SI = source file handle
	DI = destination file handle
Return: CF clear if successful
	    AX:DX = number of bytes copied
	CF set on error
	    AX = error code
Note:	copy is performed by server
----------215F98-----------------------------
INT 21 - LANtastic - SEND UNSOLICITED MESSAGE
	AX = 5F98h
	DS:SI -> message buffer (see below)
Return: CF clear if successful
	CF set on error
	    AX = error code
SeeAlso: AX=5F99h

Format of message buffer:
Offset	Size	Description
 00h	BYTE	reserved
 01h	BYTE	message type
		00h general 
		01h server warning
		02h-7Fh reserved
		80h-FFh user-defined
 02h 16 BYTEs	ASCIZ destination machine name
 12h 16 BYTEs	ASCIZ server name which user must be logged into
 22h 16 BYTEs	ASCIZ user name
 32h 16 BYTEs	ASCIZ originating machine name (filled in when received)
 42h 80 BYTEs	message text
----------215F99-----------------------------
INT 21 - LANtastic - GET LAST RECEIVED UNSOLICITED MESSAGE
	AX = 5F99h
	ES:DI -> messsage buffer (see AX=5F98h for format)
Return: CF clear if successful
	CF set on error
	    AX = error code
SeeAlso: AX=5F98h
----------215F9A-----------------------------
INT 21 - LANtastic - GET MESSAGE PROCESSING FLAG
	AX = 5F9Ah
Return: CF clear if successful
	    DL = bits describing processing for received unsolicited messages
		bit 0: beep before message is delivered
		    1: deliver message to message service
		    2: pop up message automatically (v3+)
	CF set on error
	    AX = error code
SeeAlso: AX=5F9Bh,AX=5F9Ch
----------215F9B-----------------------------
INT 21 - LANtastic - SET MESSAGE PROCESSING FLAG
	AX = 5F9Bh
	DL = bits describing processing for received unsolicited messages
	     (see AX=5F9Ah)
Return: CF clear if successful
	CF set on error
	    AX = error code
SeeAlso: AX=5F9Ah
----------215F9C-----------------------------
INT 21 - LANtastic v3+ - POP UP LAST RECEIVED MESSAGE
	AX = 5F9Ch
	CX = time to leave on screen in clock ticks
	DH = 0-based screen line on which to place message
Return:	CF clear if successful
	CF set on error
	    AX = error code (0Bh)
Note:	the original screen contents are restored when the message is removed
SeeAlso: AX=5F9Ah
----------215FA0-----------------------------
INT 21 - LANtastic - GET QUEUE ENTRY
	AX = 5FA0h
	BX = queue entry index (0000h is first entry)
	DS:SI -> buffer for queue entry (see below)
	ES:DI -> ASCIZ server name in form "\\name"
Return: CF clear if successful
	CF set on error
	    AX = error code
	BX = entry index for next queue entry (BX-1 is current index)
SeeAlso: AX=5FA1h,5FA2h

Format of queue entry:
Offset	Size	Description
 00h	BYTE	status of entry
		00h empty
		01h being updated
		02h being held
		03h waiting for despool
		04h being despooled
		05h canceled
		06h spooled file could not be accessed
		07h destination could not be accessed
		08h rush job
 01h	DWORD	size of spooled file
 05h	BYTE	type of entry
		00h printer queue file
		01h message
		02h local file
		03h remote file
		04h to remote modem
		05h batch processor file
 06h	BYTE	output control
		bit 6: don't delete (for mail)
		bit 5: mail file contains voice mail (v3+)
 07h	WORD	number of copies
 09h	DWORD	sequence number of queue entry
 0Dh 48 BYTEs	pathname of spooled file
 3Dh 16 BYTEs	user who spooled file
 4Dh 16 BYTEs	name of machine from which file was spooled
 5Dh	WORD	date file was spooled (see AX=5700h)
 5Fh	WORD	time file was spooled (see AX=5700h)
 61h 17 BYTEs	ASCIZ destination device or user name
 72h 48 BYTEs	comment field
----------215FA1-----------------------------
INT 21 - LANtastic - SET QUEUE ENTRY
	AX = 5FA1h
	BX = handle of opened queue entry
	DS:SI -> queue entry (see AX=5FA0h)
Return: CF clear if successful
	CF set on error
	    AX = error code
Note:	the only queue entry fields which may be changed are output control,
	  number of copies, destination device, and comment
SeeAlso: AX=5FA0h,5FA2h
----------215FA2-----------------------------
INT 21 - LANtastic - CONTROL QUEUE
	AX = 5FA2h
	BL = control command
	    00h start despooling (privileged)
	    01h halt despooling (privileged)
	    02h halt despooling at end of job (privileged)
	    03h pause despooler at end of job (privileged)
	    04h print single job (privileged)
	    05h restart current job (privileged)
	    06h cancel the current job
	    07h hold queue entry
	    08h release a held queue entry
	    09h make queue entry a rushed job (privileged)
	CX:DX = sequence number to control (commands 06h-09h)
	DX = physical printer number (commands 00h-05h)
	    00h-02h LPT1-LPT3
	    03h,04h COM1,COM2
	    other	all printers
	ES:DI -> ASCIZ computer name
Return: CF clear if successful
	CF set on error
	    AX = error code
----------215FA3-----------------------------
INT 21 - LANtastic v3+ - GET PRINTER STATUS
	AX = 5FA3h
	BX = physical printer number (00h-02h = LPT1-LPT3, 03h-04h = COM1-COM2)
	DS:SI -> buffer for printer status (see below)
	ES:DI -> ASCIZ server name in form "\\machine"
Return: CF clear if successful
	CF set on error
	    AX = error code
	BX = next physical printer number

Format of printer status:
Offset	Size	Description
 00h	BYTE	printer state
		bit 7: printer paused
		bits 0-6: 0 printer disabled
			  1 will stop at end of job
			  2 print multiple jobs
 01h	WORD	queue index of print job being despooled
		FFFFh if not despooling--ignore all following fields
 03h	WORD	actual characters per second being output
 05h	DWORD	number of characters actually output so far
 09h	DWORD	number of bytes read from spooled file so far
 0Dh	WORD	copies remaining to print
----------215FA4-----------------------------
INT 21 - LANtastic v3+ - GET STREAM INFO
	AX = 5FA4h
	BX = 0-based stream index number
	DS:SI -> buffer for stream information (see below)
	ES:DI -> ASCIZ machine name in form "\\machine"
Return: CF clear if successful
	CF set on error
	    AX = error code
	BX = next stream number
SeeAlso: AX=5FA5h

Format of stream information:
Offset	Size	Description
 00h	BYTE	queueing of jobs for logical printer (0=disabled,other=enabled)
 01h 11 BYTEs	logical printer resourse template (may contain ? wildcards)
----------215FA5-----------------------------
INT 21 - LANtastic v3+ - SET STREAM INFO
	AX = 5FA5h
	BX = 0-based stream index number
	DS:SI -> buffer containing stream information (see AX=5FA4h)
	ES:DI -> ASCIZ machine name in form "\\machine"
Return: CF clear if successful
	CF set on error
	    AX = error code
SeeAlso: AX=5FA4h
----------215FA7-----------------------------
INT 21 - LANtastic - CREATE USER AUDIT ENTRY
	AX = 5FA7h
	DS:DX -> ASCIZ reason code (max 8 bytes)
	DS:SI -> ASCIZ variable reason code (max 128 bytes)
	ES:DI -> ASCIZ machine name in form "\\machine"
Return: CF clear if successful
	CF set on error
	    AX = error code
----------215FB0-----------------------------
INT 21 - LANtastic - GET ACTIVE USER INFORMATION
	AX = 5FB0h
	BX = server login entry index
	DS:SI -> buffer for active user entry (see below)
	ES:DI -> ASCIZ machine name in form "\\server"
Return: CF clear if successful
	CF set on error
	    AX = error code
	BX = next login index

Format of active user entry:
Offset	Size	Description
 00h	WORD	virtual circuit number
 02h	BYTE	login state
		bit 0: fully logged in
		    1: remote program load login
		    3: user can create audit entries
		    4: bypass mail protection
		    5: treat as local process
		    6: bypass queue protection
		    7: bypass access control lists
 03h	BYTE	last command issued (see below)
 04h  5 BYTEs	number of I/O bytes (40-bit unsigned number)
 09h  3 BYTEs	number of server requests (24-bit unsigned)
 0Ch 16 BYTEs	name of user who is logged in
 1Ch 16 BYTEs	name of remote logged in machine

Values for last command:
 00h	login
 01h	process termination
 02h	open file
 03h	close file
 04h	create file
 05h	create new file
 06h	create unique file
 07h	commit data to disk
 08h	read file
 09h	write file
 0Ah	delete file
 0Bh	set file attributes
 0Ch	lock byte range
 0Dh	unlock byte range
 0Eh	create subdirectory
 0Fh	remove subdirectory
 10h	rename file
 11h	find first matching file
 12h	find next matching file
 13h	get disk free space
 14h	get a queue entry
 15h	set a queue entry
 16h	control the queue
 17h	return login information
 18h	return link description
 19h	seek on file
 1Ah	get server's time
 1Bh	create audit entry
 1Ch	open file in multitude of modes
 1Dh	change password
 1Eh	disable account
 1Fh	local server file copy
---v3+---
 20h	get username from account file
 21h	translate server's logical path
 22h	make indirect file
 23h	get indirect file contents
 24h	get physical printer status
 25h	get logical print stream info
 26h	set logical print stream info
 27h	get user's account record
----------215FB1-----------------------------
INT 21 - LANtastic - GET SHARED DIRECTORY INFORMATION
	AX = 5FB1h
	DS:SI -> 64-byte buffer for link description
	ES:DI -> ASCIZ machine and shared directory name in form
		 "\\machine\shared-resource"
Return: CF clear if successful
	    CX = access control list privilege bits for requesting user
		bit 5: allow attribute changing
		    6: allow physical access to device
		    7: allow program execution
		    8: allow file renaming
		    9: allow directory deletion
		   10: allow file deletion
		   11: allow file/directory lookups
		   12: allow directory creation
		   13: allow file creation
		   14: allow open for write and writing
		   15: allow open for read and reading
	CF set on error
	    AX = error code
----------215FB2-----------------------------
INT 21 - LANtastic v3+ - GET USERNAME FROM ACCOUNT FILE
	AX = 5FB2h
	BX = username entry index (0 for first)
	DS:SI -> 16-byte buffer for username
	ES:DI -> ASCIZ server name in form "\\machine"
Return: CF clear if successful
	CF set on error
	    AX = error code
	BX = next queue entry index
----------215FB3-----------------------------
INT 21 - LANtastic v3+ - TRANSLATE PATH
	AX = 5FB3h
	DS:SI -> 128-byte buffer for ASCIZ result
	ES:DI -> full ASCIZ path, including server name
	DX = types of translation to be performed
	    bit 0: expand last component as indirect file
		1: return actual path relative to server's physical disk
Return: CF clear if successful
	CF set on error
	    AX = error code
Note:	always expands any indirect files along the path
SeeALso: AX=5FB4h
----------215FB4-----------------------------
INT 21 - LANtastic v3+ - CREATE INDIRECT FILE
	AX = 5FB4h
	DS:SI -> 128-byte buffer containing ASCIZ contents of indirect file
	ES:DI -> full ASCIZ path of indirect file to create, incl machine name
Return: CF clear if successful
	CF set on error
	    AX = error code
Note:	the contents of the indirect file may be any valid server-relative path
----------215FB5-----------------------------
INT 21 - LANtastic v3+ - GET INDIRECT FILE CONTENTS
	AX = 5FB5h
	DS:SI -> 128-byte buffer for ASCIZ indirect file contents
	ES:DI -> full ASCIZ path of indirect file
Return: CF clear if successful
	CF set on error
	    AX = error code
----------215FC0-----------------------------
INT 21 - LANtastic - GET TIME FROM SERVER
	AX = 5FC0h
	DS:SI -> time block (see below)
	ES:DI -> ASCIZ server name to get time from
Return: CF clear if successful
	CF set on error
	    AX = error code

Format of time block:
Offset	Size	Description
 00h	WORD	year
 02h	BYTE	day
 03h	BYTE	month
 04h	BYTE	minutes
 05h	BYTE	hour
 06h	BYTE	hundredths of second
 07h	BYTE	second
----------215FD0-----------------------------
INT 21 - LANtastic - GET REDIRECTED PRINTER TIMEOUT
	AX = 5FD0h
Return: CF clear if successful
	    CX = redirected printer timeout in clock ticks of 55ms
		0000h if timeout disabled
	CF set on error
	    AX = error code
SeeAlso: AX=5FD1h
----------215FD1-----------------------------
INT 21 - LANtastic - SET REDIRECTED PRINTER TIMEOUT
	AX = 5FD1h
	CX = printer timeout in clock ticks of 55ms, 0000h to disable timeouts
Return: CF clear if successful
	CF set on error
	    AX = error code
SeeAlso: AX=5FD0h
----------215FE0-----------------------------
INT 21 - LANtastic - GET DOS SERVICE VECTOR
	AX = 5FE0h
Return: CF clear if successful
	    ES:BX -> current FAR service routine
	CF set on error
	    AX = error code
SeeAlso: AX=5FE1h
----------215FE1-----------------------------
INT 21 - LANtastic - SET DOS SERVICE VECTOR
	AX = 5FE1h
	ES:BX -> FAR routine to call for DOS service
Return: CF clear if successful
	CF set on error
	    AX = error code
Note:	new handler must chain to previous handler as its first action
SeeAlso: AX=5FE0h
----------215FE2-----------------------------
INT 21 - LANtastic - GET MESSAGE SERVICE VECTOR
	AX = 5FE2h
Return: CF clear if successful
	    ES:BX -> current FAR message service routine
	CF set on error
	    AX = error code
SeeAlso: AX=5FE3h
----------215FE3-----------------------------
INT 21 - LANtastic - SET MESSAGE SERVICE VECTOR
	AX = 5FE3h
	ES:BX -> FAR routine for processing network messages
Return: CF clear if successful
	CF set on error
	    AX = error code
Notes:	handler must chain to previous handler as its first action
	on invocation, ES:BX -> Network Control Block
SeeAlso: AX=5FE2h
----------2160-------------------------------
INT 21 - DOS 3+ internal - RESOLVE PATH STRING TO CANONICAL PATH STRING
	AH = 60h
	DS:SI -> ASCIZ relative path string or directory name
	ES:DI -> 128-byte buffer for ASCIZ canonical fully qualified name
Return: CF set on error
	    AX = error code 
		02h invalid source name
		03h invalid drive or malformed path
		others???
	CF clear if successful
	    AH = 00h
	    AL = destroyed (00h or 5Ch or last char of current dir on drive)
	    buffer filled with qualified name of form D:\PATH\FILE.EXT or
	      \\MACHINE\PATH\FILE.EXT
Notes:	the input path need not actually exist
	letters are uppercased, forward slashes converted to backslashes,
	  asterisks converted to appropriate number of question marks, and
	  file and directory names are truncated to 8.3 if necessary.
	'.' and '..' in the path are resolved
	filespecs on local drives always start with "d:", those on network
	  drives always start with "\\"
	if path string is on a JOINed drive, the returned name is the one that
	  would be needed if the drive were not JOINed; similarly for a
	  SUBSTed, ASSIGNed, or network drive letter.	Because of this, it is
	  possible to get a qualified name that is not legal under the current
	  combination of SUBSTs, ASSIGNs, JOINs, and network redirections
	functions which take pathnames require canonical paths if invoked via
	  INT 21/AX=5D00h
	supported by OS/2 v1.1 compatibility box
SeeAlso: INT 2F/AX=1123h,1221h
----------2161-------------------------------
INT 21 - DOS 3+ internal - UNUSED
	AH = 61h
Return: AL = 00h
----------2162-------------------------------
INT 21 - DOS 3+ - GET PSP ADDRESS
	AH = 62h
Return: BX = current PSP segment address (see AH=26h for format)
Notes:	under DOS 3+, this function does not use any of the DOS-internal stacks
	  and is thus fully reentrant
	identical to the undocumented AH=51h
SeeAlso: AH=50h, AH=51h
----------2163-------------------------------
INT 21 - DOS 2.25 only - GET LEAD BYTE TABLE (2-BYTE CHARACTER SUPPORT)
	AH = 63h
	AL = subfunction
	     00h get system lead byte table
		Return:	DS:SI -> lead byte table
	     01h set/clear interim console flag (determine whether interim
			bytes are returned on some console functions)
		DL = 01h/00h to set/clear interim console flag
	     02h get interim console flag
		Return:	DL = interim console flag
Return: CF set on error
	    AX = error code (01h) (see AH=59h)
	CF clear if successful
Note:	does not preserve any registers other than SS:SP
----------216300-----------------------------
INT 21 - Asian DOS 3.2+ only - GET DOUBLE BYTE CHARACTER SET LEAD TABLE
	AX = 6300h
Return: AL = error code
	    00h successful
		DS:SI -> DBCS table (see below)
		BX, CX, DX, BP, DI, and ES destroyed
	    FFh not supported
Notes:	probably identical to AX=6300h for DOS 2.25
	The US version of DOS 4.0 accepts this function, but returns an empty
	  list

Format of DBCS table:
Offset	Size	Description
 00h  2 BYTEs	low/high ends of a range of leading byte of double-byte chars
 02h  2 BYTEs	low/high ends of a range of leading byte of double-byte chars
	...
  N   2 BYTEs	00h,00h end flag
----------216301-----------------------------
INT 21 - Asian DOS 3.2+ only - SET KOREAN (HONGEUL) INPUT MODE
	AX = 6301h
	DL = new mode
	    00h return only full characters on DOS keyboard input functions
	    01h	return partially-formed characters also
Return: AL = status
	    00h successful
	    FFh invalid mode
SeeAlso: AX=6302h
----------216302-----------------------------
INT 21 - Asian DOS 3.2+ only - GET KOREAN (HONGEUL) INPUT MODE
	AX = 6302h
Return: AL = status
	    00h successful
		DL = current input mode
		    00h return only full characters
		    01h return partial characters
	    FFh not supported
SeeAlso: AX=6301h
----------2164-------------------------------
INT 21 - DOS 3.2 internal - GET/SET ???
	AH = 64h
	AL = subfunction
	    00h get ???
		Return: DL = ???
	    01h set ???
		DL = ???
	    02h get and set ???
		DL = new ???
		Return: DL = old ???
----------2164-------------------------------
INT 21 - DOS 3.3+ internal - SET ???
	AH = 64h
	AL = flag
		00h  ??? 
	    nonzero  ??? 
Return: nothing
Notes:	affects operation of AH=08h
	called by DOS 3.3+ PRINT.COM
----------2165-------------------------------
INT 21 - DOS 3.3+ - GET EXTENDED COUNTRY INFORMATION
	AH = 65h
	AL = info ID
	    01h get general internationalization info
	    02h get pointer to uppercase table
	    04h get pointer to filename uppercase table
	    05h (DOS 3.3+ internal) get pointer to filename terminator table
	    06h get pointer to collating sequence table
	    07h (DOS 4.x) get pointer to Double-Byte Character Set table
	BX = code page (-1=global code page)
	DX = country ID (-1=current country)
	ES:DI -> country information buffer (see below)
	CX = size of buffer (>= 5)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if succesful
	    CX = size of country information returned
	    ES:DI -> country information
Notes:	AL=05h appears to return same info for all countries and codepages
	NLSFUNC must be installed to get info for countries other than the
	  default
SeeAlso: AH=38h,INT 2F/AX=1401h,1402h

Format of country information:
Offset	Size	Description
 00h	BYTE	info ID
---if info ID = 01h---
 01h	WORD	size
 03h	WORD	country ID
 05h	WORD	code page
 07h 34 BYTEs	country-dependent info (see AH=38h)
---if info ID = 02h---
 01h	DWORD	pointer to uppercase table (see below)
---if info ID = 04h---
 01h	DWORD	pointer to filename uppercase table (see below)
---if info ID = 05h---
 01h	DWORD	pointer to filename character table (see below)
---if info ID = 06h---
 01h	DWORD	pointer to collating table (see below)
---if info ID = 07h (DOS 4.x)---
 01h	DWORD	pointer to DBCS lead byte table (see below)

Format of uppercase table:
Offset	Size	Description
 00h	WORD	table size
 02h 128 BYTEs	uppercase equivalents (if any) of chars 80h to FFh

Format of collating table:
Offset	Size	Description
 00h	WORD	table size
 02h 256 BYTEs	values used to sort characters 00h to FFh

Format of filename terminator table:
Offset	Size	Description
 00h	WORD	table size
 02h  7 BYTEs	???  (01h 00h FFh 00h 00h 20h 02h in MSDOS 3.30)
 09h	BYTE	length of following data
 0Ah  N BYTES	characters which terminate a filename:	."/\[]:|<>+=;,

Format of filename uppercase table:
Offset	Size	Description
 00h	WORD	table size
 02h 128 BYTEs	uppercase equivalents (if any) of chars 80h to FFh

Format of DBCS lead byte table:
Offset	Size	Description
 00h	WORD	length
 02h 2N BYTEs	start/end for N lead byte ranges
	WORD	0000h	(end of table)
----------2165-------------------------------
INT 21 - DOS 4.x internal - COUNTRY-DEPENDENT CHARACTER CAPITALIZATION
	AH = 65h
	AL = function
	    20h capitalize character
		DL = character to capitalize
		Return: DL = capitalized character
	    21h capitalize string
		DS:DX -> string to capitalize
		CX = length of string
	    22h capitalize ASCIZ string
		DS:DX -> ASCIZ string to capitalize
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
----------216523-----------------------------
INT 21 - DOS 4.x internal - DETERMINE IF CHARACTER REPRESENTS YES/NO RESPONSE
	AX = 6523h
	DL = character
	DH = second character of double-byte character (if applicable)
Return: CF set on error
	CF clear if successful
	    AX = type
		00h no
		01h yes
		02h neither yes nor no
----------2165-------------------------------
INT 21 - DOS 4.x internal - COUNTRY-DEPENDENT FILENAME CAPITALIZATION
	AH = 65h
	AL = function
	    A0h capitalize filename character
		DL = character to capitalize
		Return: DL = capitalized character
	    A1h capitalize counted filename string
		DS:DX -> filename string to capitalize
		CX = length of string
	    A2h capitalize ASCIZ filename
		DS:DX -> ASCIZ filename to capitalize
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Note:	nonfunctional in DOS 4.00 and 4.01 due to a bug
----------216601-----------------------------
INT 21 - DOS 3.3+ - GET GLOBAL CODE PAGE TABLE
	AX = 6601h
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    BX = active code page
	    DX = system code page
SeeAlso: AX=6602h
----------216602-----------------------------
INT 21 - DOS 3.3+ - SET GLOBAL CODE PAGE TABLE
	AX = 6602h
	BX = active code page
	    437  US
	    850  Multilingual
	    860  Portugal
	    863  Canada (French)
	    865  Norway/Denmark
	DX = system code page (active page at boot time)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
SeeAlso: AX=6601h
----------2167-------------------------------
INT 21 - DOS 3.3+ - SET HANDLE COUNT
	AH = 67h
	BX = desired number of handles (max 255)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Notes:	if BX <= 20, no action is taken
	only the first 20 handles are copied to child processes in DOS 3.3
BUG:	the original release of DOS 3.30 allocates a full 64K for the handle
	  table on requests for an even number of handles
SeeAlso: AH=26h
----------2168-------------------------------
INT 21 - DOS 3.3+ - COMMIT FILE, WRITE ALL BUFFERED DATA TO DISK
	AH = 68h
	BX = file handle
Return: CF set on error 
	    AX = error code (see AH=59h)
	CF clear if successful
SeeAlso: AX=5D01h, INT 2F/AX=1107h
----------2169-------------------------------
INT 21 - DOS 4.0 internal - GET/SET DISK SERIAL NUMBER
	AH = 69h
	AL = subfunction
	    00h	get serial number
	    01h set serial number
	BL = drive (0=default, 1=A, 2=B, etc)
	DS:DX -> disk info (see below)
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
	    AX destroyed
	    (AL = 00h) buffer filled with appropriate values from extended BPB
	    (AL = 01h) extended BPB on disk set to values from buffer
Notes:	does not generate a critical error; all errors are returned in AX
	error 0005h given if no extended BPB on disk
	does not work on network drives (error 0001h)
	buffer after first two bytes is exact copy of bytes 27h thru 3Dh of
	   extended BPB on disk
SeeAlso: AX=440Dh

Format of disk info:
Offset	Size	Description
 00h	WORD	info level (zero)
 02h	DWORD	disk serial number (binary)
 06h 11 BYTEs	volume label or "NO NAME    " if none present
 11h  8 BYTEs	(AL=00h only) filesystem type--string "FAT12   " or "FAT16   "
----------216A-------------------------------
INT 21 - DOS 4.0 internal - ???
	AH = 6Ah
	???
Return: ???
Note:	may be equivalent to INT 21/AH=48h
----------216B-------------------------------
INT 21 - DOS 4.0 internal - ???
	AH = 6Bh
	AL = subfunction
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
	    AX = error code (see INT 21/AH=59h)
	CF clear if successful
Return: ???
Note:	passed through to INT 2F/AX=112Fh with AX on top of stack
SeeAlso: INT 2F/AX=112Fh
----------216C00-----------------------------
INT 21 - DOS 4.0 - EXTENDED OPEN/CREATE
	AX = 6C00h
	BL = open mode as in AL for normal open (INT 21h/AH=3Dh)
	    bit 7: inheritance
	    bits 4-6: sharing mode
	    bit 3 reserved
	    bits 0-2: access mode
	BH = flags
	    bit 6 = auto commit on write
	    bit 5 = return error rather than doing INT 24h
	CX = create attribute
	    bits 6-15 reserved
	    bit 5: archive
	    bit 4: reserved
	    bit 3: volume label
	    bit 2: system
	    bit 1: hidden
	    bit 0: readonly
	DL = action if file exists/does not exists
	    bits 7-4 action if file does not exist
		    0000 fail
		    0001 create
	    bits 3-0 action if file exists
		    0000 fail
		    0001 open
		    0010 replace/open
	DH = 00h (reserved)
	DS:SI -> ASCIZ file name
Return: CF set on error
	   AX = error code (see AH=59h)
	CF clear if successful
	   AX = file handle
	   CX = 1 file opened
		2 file created
		3 file replaced
Note:	the PC LAN Program only supports DL=01h, DL=10h/sharing=compatibility,
	  and DL=12h
SeeAlso: AH=3Ch,3Dh
----------2189-------------------------------
INT 21 - ???
	AH = 89h
	???
Note:	reportedly called by Microsoft C 4.0 startup code
----------21A0-------------------------------
INT 21 - Attachmate Extra - GET 3270 DISPLAY STATE
	AH = A0h
Return: AL = display status
	    bit  7  : 0=windowed, 1=enlarged
	    bits 6-3: current screen profile number 0-9
	    bits 2-0: active window number
			0=PC, 1-4=host B-E, 5-6=notepad F-G
	BX = host window status
	    bit 15:  reserved
	    bit 14:  0=host E window installed, 1=not
	    bit 13:  0=host E terminal on, 1=off
	    bit 12:  0=host E window displayed, 1=not
	    bit 11:  reserved
	    bit 10:  0=host D window installed, 1=not
	    bit  9:  0=host D terminal on, 1=off
	    bit  8:  0=host D window displayed, 1=not
	    bit  7:  reserved
	    bit  6:  0=host C window installed, 1=not
	    bit  5:  0=host C terminal on, 1=off
	    bit  4:  0=host C window displayed, 1=not
	    bit  3:  reserved
	    bit  2:  0=host B window installed, 1=not
	    bit  1:  0=host B terminal on, 1=off
	    bit  0:  0=host B window displayed, 1=not
Note:	Attachmate Extra is a 3270 emulator by Attachmate Corporation
SeeAlso: AH=A1h
----------21A1-------------------------------
INT 21 - Attachmate Extra - SET 3270 DISPLAY STATE
	AH = A1h
	AL = set status byte
	    bit  7  : 0=windowed, 1=enlarged
	    bits 6-3: current screen profile number 0-9
	    bits 2-0: active window number
			0=PC, 1-4=host B-E, 5-6=notepad F-G
SeeAlso: AH=A0h,AH=A2h
----------21A2-------------------------------
INT 21 - Attachmate Extra - SET HOST WINDOW STATE
	AH = A2h
	AL = set status byte
	    bit  7  : 0=power off, 1=power on
	    bit  6  : 0=not installed, 1=installed
	    bits 5-3: reserved
	    bits 2-0: window number 1-4=host B-E
SeeAlso: AH=A1h
----------21A3-------------------------------
INT 21 - Attachmate Extra - SEND KEYSTROKES TO HOST WINDOW
	AH = A3h
	AL = window number (1-4=host B-E)
	CX = 0001h
	DS:BX -> keystroke buffer
	DL = zero if keystroke buffer contains host function code,
	     non-zero if keystroke buffer contains ASCII character
Return: CX = zero if character sent, non-zero if not
	BX incremented if CX=0

Values for host function code:
	00h=reserved	10h=PF16	20h=Clear	30h=SysRq
	01h=PF1		11h=PF17	21h=Print	31h=ErInp
	02h=PF2		12h=PF18	22h=Left	32h=ErEof
	03h=PF3		13h=PF19	23h=Right	33h=Ident
	04h=PF4		14h=PF20	24h=Up		34h=Test
	05h=PF5		15h=PF21	25h=Down	35h=Reset
	06h=PF6		16h=PF22	26h=Home	36h=DevCncl
	07h=PF7		17h=PF23	27h=Fast Left	37h=Dup
	08h=PF8		18h=PF24	28h=Fast Right	38h=FldMark
	09h=PF9		19h=Alt on	29h=Bksp	39h=Enter
	0Ah=PF10	1Ah=Alt off	2Ah=Insert	3Ah=CrSel
	0Bh=PF11	1Bh=Shift on	2Bh=Delete
	0Ch=PF12	1Ch=Shift off	2Ch=Backtab
	0Dh=PF13	1Dh=PA1		2Dh=Tab
	0Eh=PF14	1Eh=PA2		2Eh=Newline
	0Fh=PF15	1Fh=PA3		2Fh=Attn
----------21A4-------------------------------
INT 21 - Attachmate Extra - GET HOST WINDOW BUFFER ADDRESS
	AH = A4h
	AL = window number (1-4=host B-E)
Return: DS:BX -> 3270 display buffer
SeeAlso: AH=A5h,AH=B8h
----------21A5-------------------------------
INT 21 - Attachmate Extra - GET HOST WINDOW CURSOR POSITION
	AH = A5h
	AL = window number (1-4=host B-E)
Return: BX = cursor position (80 * row + column, where 0:0 is upper left)
Note:	if the host window is configured with the Extended Attribute (EAB)
	  feature, multiply the cursor position by 2 to obtain the byte offset
	  into the display buffer
SeeAlso: AH=A4h
----------21AF-------------------------------
INT 21 - Attachmate Extra - GET TRANSLATE TABLE ADDRESS
	AH = AFh
Return: DS:BX -> translate tables

Format of translate tables:
Offset	Size	Description
 00h 256 BYTEs	ASCII to 3270 buffer code translate table
100h 256 BYTEs	3270 buffer code to ASCII translate table
200h 256 BYTEs	3270 buffer code to EBCDIC translate table
300h 256 BYTEs	EBCDIC to 3270 buffer code translate table
----------21B5-------------------------------
INT 21 - Novell NetWare shell 3.01 - TASK MODE CONTROL
	AH = B5h
	AL = subfunction
	    03h get task mode
		Return: AH = 00h
			AL = current task mode byte
	    04h get task mode pointer
		Return: ES:BX -> task mode byte
Notes:	the task mode byte specifies how task cleanup should be performed, but
	  is declared to be version-dependent
	allows a program to disable the automatic cleanup for programs managing
	  task swapping, etc.

Values for task mode byte in version 3.01:
 00h-03h reserved
 04h	 no task cleanup
----------21B6-------------------------------
INT 21 - Novell NetWare SFT Level II - EXTENDED FILE ATTRIBUTES
	AH = B6h
	AL = subfunction
	    00h get extended file attributes
	    01h set extended file attributes
	CL = attributes
	    bit 4: transaction tracking file
		5: indexing file (to be implemented)
		6: read audit (to be implemented)
		7: write audit (to be implemented)
	DS:DX -> ASCIZ pathname
Return: CF set on error
	    AL = error code
		FFh file not found
		8Ch caller lacks privileges
	CL = current extended file attributes
SeeAlso: AX=4300h
----------21B8-------------------------------
INT 21 - Novell Advanced NetWare 2.0+ - PRINT JOBS
	AH = B8h
	AL = subfunction
	    00h get default print job flags
	    01h set default capture flags
	    02h get specific capture flags
	    03h set specific print job flags
	    04h get default local printer
	    05h set default local printer
	    06h set capture print queue
	    07h set capture print job
	    08h get banner user name
	    09h set banner user name
	CX = buffer size
	ES:BX -> buffer
Return: none
----------21B8-------------------------------
INT 21 - Attachmate Extra - DISABLE HOST BUFFER UPDATES
	AH = B8h
	AL = window number (1-4=host B-E)
	DL = 01h
Notes:	only valid in CUT mode
	next AID keystroke (eg Enter) enables host buffer updates
SeeAlso: AH=A4h
----------21BB-------------------------------
INT 21 - Novell NetWare 4.0 - SET END OF JOB STATUS
	AH = BBh
	AL = new EOJ flag
	    00h disable EOJs
	    otherwise enable EOJs
Return: AL = old EOJ flag
SeeAlso: AH=D6h
----------21BC-------------------------------
INT 21 - Novell NetWare 4.6 - LOG/LOCK PHYSICAL RECORD
	AH = BCh
	AL = flags
	    bit 0: lock as well as log record
		1: non-exclusive lock
	BX = file handle
	CX:DX = offset
	BP = timeout in timer ticks (1/18 sec)
	SI:DI = length
Return: AL = error code
SeeAlso: AH=BFh
----------21BD-------------------------------
INT 21 - Novell NetWare 4.6 - RELEASE PHYSICAL RECORD
	AH = BDh
	BX = file handle
	CX:DX = offset
Return: AL = error code
SeeAlso: AH=C0h
----------21BE-------------------------------
INT 21 - Novell NetWare 4.6 - CLEAR PHYSICAL RECORD
	AH = BEh
	BX = file handle
	CX:DX = offset
Return: AL = error code
SeeAlso: AH=C1h
----------21BF-------------------------------
INT 21 - Novell NetWare 4.6 - LOG/LOCK RECORD (FCB)
	AH = BFh
	AL = flags
	    bit 0: lock as well as log record
		1: non-exclusive lock
	DS:DX -> FCB
	BX:CX = offset
	BP = timeout in timer ticks (1/18 sec)
	SI:DI = length
Return: AL = error code
SeeAlso: AH=BCh,C2h
----------21C0-------------------------------
INT 21 - Novell NetWare 4.6 - RELEASE RECORD (FCB)
	AH = C0h
	DS:DX -> FCB
	BX:CX = offset
Return: AL = error code
SeeAlso: AH=BDh,C3h
----------21C1-------------------------------
INT 21 - Novell NetWare 4.6 - CLEAR RECORD (FCB)
	AH = C1h
	DS:DX -> FCB
	BX:CX = offset
Return: AL = error code
SeeAlso: AH=BEh,C4h
----------21C2-------------------------------
INT 21 - Novell NetWare 4.6 - LOCK PHYSICAL RECORD SET
	AH = C2h
	AL = flags
	    bit 1: non-exclusive lock
	BP = timeout in timer ticks (1/18 sec)
Return: AL = error code
SeeAlso: AH=BFh
----------21C3-------------------------------
INT 21 - Novell NetWare 4.6 - RELEASE PHYSICAL RECORD SET
	AH = C3h
Return: AL = error code
SeeAlso: AH=C0h
----------21C4-------------------------------
INT 21 - Novell NetWare 4.6 - CLEAR PHYSICAL RECORD SET
	AH = C4h
Return: AL = error code
SeeAlso: AH=C1h
----------21C5-------------------------------
INT 21 - Novell NetWare 4.6 - SEMAPHORES
	AH = C5h
	AL = subfunction
	    00h open semaphore
		DS:DX -> semaphore name
		CL = initial value
	    01h examine semaphore
		Return: CX = semaphore value (sign extended)
			DL = open count
	    02h wait on semaphore
		BP = timeout in timer ticks (1/18 sec)
	    03h signal semaphore
	    04h close semaphore
	CX:DX = semaphore handle (except function 00h)
Return: AL = error code
	if function 00h
	   CX:DX = semaphore handle
	   BL = open count
----------21C6-------------------------------
INT 21 - Novell NetWare 4.6 - GET OR SET LOCK MODE
	AH = C6h
	AL = subfunction
	    00h set old "compatibility" mode
	    01h set new extended locks mode 
	    02h get lock mode
Return: AL = current lock mode
----------21C7-------------------------------
INT 21 - Novell NetWare 4.0 - TTS
	AH = C7h
	AL = subfunction
	    00h begin transaction (NetWare SFT level II)
		Return: AL = error code
	    01h end transaction (NetWare SFT level II)
		Return: AL = error code
			CX:DX = transaction reference number
	    02h TTS available (NetWare SFT level II)
		Return: AL = completion code
			    00h TTS not available
			    01h TTS available
			    FDh TTS available but disabled
	    03h abort transaction (NetWare SFT level II)
		Return: AL = error code
	    04h transaction status
	    05h get application thresholds
	    06h set application thresholds
	    07h get workstation thresholds
	    08h set workstation thresholds
Return: ???
----------21C8-------------------------------
INT 21 - Novell NetWare 4.0 - BEGIN LOGICAL FILE LOCKING
	AH = C8h
	if function C6h lock mode 00h:
	    DL = mode
		00h no wait
		01h wait
	if function C6h lock mode 01h:
	    BP = timeout in timer ticks (1/18 sec)
Return: AL = error code
SeeAlso: AH=C9h
----------21C9-------------------------------
INT 21 - Novell NetWare 4.0 - END LOGICAL FILE LOCKING
	AH = C9h
Return: AL = error code
SeeAlso: AH=C8h
----------21CA-------------------------------
INT 21 - Novell NetWare 4.0 - LOG/LOCK PERSONAL FILE (FCB)
	AH = CAh
	DS:DX -> FCB
	if function C6h lock mode 01h:
	    AL = log and lock flag
		00h log file only
		01h lock as well as log file
	    BP = timeout in timer ticks (1/18 sec)
Return: AL = error code
SeeAlso: AH=CBh
----------21CB-------------------------------
INT 21 - Novell NetWare 4.0 - LOCK FILE SET
	AH = CBh
	if function C6h lock mode 00h:
	    DL = mode
		00h no wait
		01h wait
	if function C6h lock mode 01h:
	    BP = timeout in timer ticks (1/18 sec)
Return: AL = error code
SeeAlso: AH=CAh
----------21CC-------------------------------
INT 21 - Novell NetWare 4.0 - RELEASE FILE (FCB)
	AH = CCh
	DS:DX -> FCB
Return: none
SeeAlso: AH=CDh
----------21CD-------------------------------
INT 21 - Novell NetWare 4.0 - RELEASE FILE SET
	AH = CDh
Return: none
SeeAlso: AH=CCh
----------21CE-------------------------------
INT 21 - Novell NetWare 4.0 - CLEAR FILE (FCB)
	AH = CEh
	DS:DX -> FCB
Return: AL = error code
SeeAlso: AH=CFh
----------21CF-------------------------------
INT 21 - Novell NetWare 4.0 - CLEAR FILE SET
	AH = CFh
Return: AL = 00h
SeeAlso: AH=CEh
----------21D0-------------------------------
INT 21 - Novell NetWare 4.6, Banyan VINES - LOCK LOGICAL RECORD
	AH = D0h
	DS:DX -> record string
	if function C6h lock mode 01h: (Novell only)
	    AL = flags
		bit 0: lock as well as log the record
		bit 1: non-exclusive lock
	    BP = timeout in timer ticks (1/18 sec)
Return: AL = error code
	    00h successful
	    FFh unsuccessful
SeeAlso: AH=D1h,D2h
----------21D1-------------------------------
INT 21 - Novell NetWare 4.6, Banyan VINES - LOCK LOGICAL RECORD SET
	AH = D1h
	if function C6h lock mode 00h:
	    DL = mode
		00h no wait
		01h wait
	if function C6h lock mode 01h: (Novell only)
	   BP = timeout in timer ticks (1/18 sec)
Return: AL = error code (see AH=D0h)
SeeAlso: AH=D0h,D3h
----------21D2-------------------------------
INT 21 - Novell NetWare 4.0, Banyan VINES - UNLOCK LOGICAL RECORD
	AH = D2h
	DS:DX -> semaphore identifier (counted string up to 100 chars long)
Return: AL = error code (see AH=D0h)
SeeAlso: AH=D0h,D3h
----------21D3-------------------------------
INT 21 - Novell NetWare 4.0, Banyan VINES - UNLOCK LOGICAL RECORD SET
	AH = D3h
Return: AL = error code (see AH=D0h)
Note:	unlocks all semaphores logged in the semaphore set of the requesting PC
SeeAlso: AH=D1h,D2h
----------21D4-------------------------------
INT 21 - Novell NetWare 4.0, Banyan VINES - CLEAR LOGICAL RECORD
	AH = D4h
	DS:DX -> semaphore identifier (counted string up to 100 chars long)
Return: AL = error code
	    00h successful
	    FFh not successful
SeeAlso: AH=D5h
----------21D5-------------------------------
INT 21 - Novell NetWare 4.0, Banyan VINES - CLEAR LOGICAL RECORD SET
	AH = D5h
Return: AL = error code (see AH=D4h)
Note:	unlocks and clears all semaphores associated with the semaphore set
	  of the requesting PC
SeeAlso: AH=D4h
----------21D6-------------------------------
INT 21 - Novell NetWare 4.0 - END OF JOB
	AH = D6h
Return: AL = error code
SeeAlso: AH=BBh
----------21D7-------------------------------
INT 21 - Novell NetWare 4.0 - SYSTEM LOGOUT
	AH = D7h
Return: AL = error code
----------21D8-------------------------------
INT 21 - Novell NetWare, Banyan VINES - ALLOCATE RESOURCE
	AH = D8h
	DL = resource number
Return: AL = status
	    00h successful
	    FFh unsucessful
SeeAlso: AH=D9h
----------21D9-------------------------------
INT 21 - Novell NetWare, Banyan VINES - DEALLOCATE RESOURCE
	AH = D9h
	DL = resource number
Return:	AL = status (see AH=D8h)
SeeAlso: AH=D8h
----------21DA-------------------------------
INT 21 - Novell NetWare 4.0 - GET VOLUME STATISTICS
	AH = DAh
	DL = volume number
	ES:DI -> reply buffer (see below)
Return: AL = 00h
SeeAlso: AH=36h

Format of reply buffer:
Offset	Size	Description
 00h	WORD	sectors/block
 02h	WORD	total blocks
 04h	WORD	unused blocks
 06h	WORD	total directory entries
 08h	WORD	unused directory entries
 0Ah 16 BYTEs	volume name, null padded
 1Ah	WORD	removable flag, 0000h = not removable
----------21DB-------------------------------
INT 21 - Novell NetWare 4.0 - GET NUMBER OF LOCAL DRIVES
	AH = DBh
Return: AL = number of local disks
SeeAlso: AH=0Eh
----------21DC-------------------------------
INT 21 - Novell NetWare 4.0, Banyan VINES - GET STATION NUMBER
	AH = DCh
Return: AL = station number
	    00h if NetWare not loaded or this machine is a non-dedicated server
	CX = station number in ASCII
Note:	station number only unique for those PCs connected to same semaphore
	  service
----------21DC-------------------------------
INT 21 - PCMag PCMANAGE/DCOMPRES - TURN ON/OFF
	AH = DCh
	DX = state
	    0000h turn on
	    0001h turn off
SeeAlso: AX=FEDCh
----------21DD-------------------------------
INT 21 - Novell NetWare 4.0 - SET ERROR MODE
	AH = DDh
	DL = error mode
	    00h display critical I/O errors
	    01h extended errors for all I/O in AL
	    02h extended errors for critical I/O in AL
Return: AL = previous error mode
----------21DE-------------------------------
INT 21 - Novell NetWare 4.0 - SET BROADCAST MODE
	AH = DEh
	AL = broadcast mode
	    00h receive console and workstation broadcasts
	    01h receive console broadcasts only
	    02h receive no broadcasts
	    03h store all broadcasts for retrieval
	    04h get broadcast mode
	    05h disable shell timer interrupt checks
	    06h enable shell timer interrupt checks
Return: AL = old broadcast mode
----------21DF-------------------------------
INT 21 - Novell NetWare 4.0 - CAPTURE
	AH = DFh
	AL = subfunction
	    00h start LPT capture
	    01h end LPT capture
	    02h cancel LPT capture
	    03h flush LPT capture
	    04h start specific capture
	    05h end specific capture
	    06h cancel specific capture
	    07h flush specific capture
Return: AL = error code
----------21E0-------------------------------
INT 21 - Novell NetWare 4.0 - PRINT SPOOLING
	AH = E0h
	DS:SI -> request buffer
	ES:DI -> reply buffer
	subfunction in third byte of request buffer
	    00h spool data to a capture file
	    01h close and queue capture file
	    02h set spool flags
	    03h spool existing file
	    04h get spool queue entry
	    05h remove entry from spool queue
	    06h get printer status
	    09h create a disk capture file
Return: AL = error code
----------21E0-------------------------------
INT 21 - OS/286, OS/386 - INITIALIZE REAL PROCEDURE
	AH = E0h
	???
Return: ???
----------21E1-------------------------------
INT 21 - Novell NetWare 4.0 - BROADCAST MESSAGES
	AH = E1h
	DS:SI -> request buffer
	ES:DI -> reply buffer
	subfunction in third byte of request buffer
	    00h send broadcast message
	    01h get broadcase message
	    02h disable station broadcasts
	    03h enable station broadcasts
	    04h send personal message
	    05h get personal message
	    06h open message pipe
	    07h close message pipe
	    08h check pipe status
	    09h broadcast to console
Return: AL = error code
----------21E1-------------------------------
INT 21 - OS/286, OS/386 - ISSUE REAL PROCEDURE CALL
	AH = E1h
	???
Return: ???
Note:	protected mode only???
----------21E2-------------------------------
INT 21 - Novell NetWare 4.0 - DIRECTORY FUNCTIONS
	AH = E2h
	DS:SI -> request buffer
	ES:DI -> reply buffer
	subfunction in third byte of request buffer
	    00h set directory handle
	    01h get directory path
	    02h scan directory information
	    03h get effective directory rights
	    04h modify maximum rights mask
	    05h get volume number
	    06h get volume name
	    0Ah create directory
	    0Bh delete directory
	    0Ch scan directory for trustees
	    0Dh add trustee to directory
	    0Eh delete trustee from directory
	    0Fh rename directory
	    10h purge erased files
	    11h restore erased file
	    12h allocate permanent directory handle
	    13h allocate temporary directory handle
	    14h deallocate directory handle
	    15h get volume info with handle
	    16h allocate special temporary directory handle
	    17h retrieve a short base handle (Advanced NetWare 2.0)
	    18h restore a short base handle (Advanced NetWare 2.0)
	    19h set directory information
Return: AL = error code
----------21E2-------------------------------
INT 21 - OS/286, OS/386 - SET REAL PROCEDURE SIGNAL HANDLER
	AH = E2h
	???
Return: ???
----------21E3-------------------------------
INT 21 - Novell NetWare 4.0 - CONNECTION CONTROL
	AH = E3h
	DS:SI -> request buffer
	ES:DI -> reply buffer
	subfunction in third byte of request buffer
	    00h login
	    01h change password
	    02h map user to station set
	    03h map object to number
	    04h map number to object
	    05h get station's logged information
	    06h get station's root mask (obsolete)
	    07h map group name to number
	    08h map number to group name
	    09h get memberset M of group G
	    0Ah enter login area
	    0Bh ???
	    0Ch ???
	    0Dh log network message
	    0Eh get disk utilization (Advanced NetWare 1.0)
	    0Fh scan file information (Advanced NetWare 1.0)
	    10h set file information (Advanced NetWare 1.0)
	    11h get file server information (Advanced NetWare 1.0)
	    12h ???
	    13h get internet address (Advanced NetWare 1.02)
	    14h login to file server (Advanced NetWare 2.0)
	    15h get object connection numbers (Advanced NetWare 2.0)
	    16h get connection information (Advanced NetWare 1.0)
	    32h create object (Advanced NetWare 1.0)
	    33h delete object (Advanced NetWare 1.0)
	    34h rename object (Advanced NetWare 1.0)
	    35h get object ID (Advanced NetWare 1.0)
	    36h get object name (Advanced NetWare 1.0)
	    37h scan object (Advanced NetWare 1.0)
	    38h change object security (Advanced NetWare 1.0)
	    39h create propery (Advanced NetWare 1.0)
	    3Ah delete property (Advanced NetWare 1.0)
	    3Bh change property security (Advanced NetWare 1.0)
	    3Ch scan property (Advanced NetWare 1.0)
	    3Dh read property value (Advanced NetWare 1.0)
		request buffer contains the property name in all caps
		property "IDENTIFICATION" returns the user's name
	    3Eh write property value (Advanced NetWare 1.0)
	    3Fh verify object password (Advanced NetWare 1.0)
	    40h change object password (Advanced NetWare 1.0)
	    41h add object to set (Advanced NetWare 1.0)
	    42h delete object from set (Advanced NetWare 1.0)
	    43h is object in set? (Advanced NetWare 1.0)
	    44h close bindery (Advanced NetWare 1.0)
	    45h open bindery (Advanced NetWare 1.0)
	    46h get bindery access level (Advanced NetWare 1.0)
	    47h scan object trustee paths (Advanced NetWare 1.0)
	    C8h check console priviledges
	    C9h get file server description strings
	    CAh set file server date and time
	    CBh disable file server login
	    CCh enable file server login
	    CDh get file server login status
	    CEh purge all erased files
	    CFh disable transaction tracking
	    D0h enable transaction tracking
	    D1h send console broadcast
	    D2h clear connection number
	    D3h down file server
	    D4h get file system statistics
	    D5h get transaction tracking statistics
	    D6h read disk cache statistics
	    D7h get drive mapping table
	    D8h read physical disk statistics
	    D9h get disk channel statistics
	    DAh get connection's task information
	    DBh get list of connection's open files
	    DCh get list of connections using a file
	    DDh get physical record locks by connection and file
	    DEh get physical record locks by file
	    DFh get logical records by connection
	    E0h get logical record information
	    E1h get connection's semaphores
	    E2h get semaphore information
	    E3h get LAN driver's configuration information
	    E5h get connection's usage statistics
	    E6h get object's remaining disk space
	    E7h get server LAN I/O statistics
	    E8h get server miscellaneous information
	    E9h get volume information
Return: AL = error code
----------21E3-------------------------------
INT 21 - OS/286, OS/386 - ISSUE REAL INTERRUPT
	AH = E3h
	AL = interrupt number
	???
Return: ???
Note:	protected mode only???
----------21E4-------------------------------
INT 21 - Novell NetWare 4.0 - SET FILE ATTRIBUTES (FCB)
	AH = E4h
	CL = file attributes
	    bit 0: read only
		1: hidden
		2: system
		7: shareable
	DX:DX -> FCB
Return: AL = error code
SeeAlso: AX=4301h
----------21E400-----------------------------
INT 21 - DoubleDos - INSTALLATION CHECK
	AX = E400h
Return: AL <> 00h if DoubleDos is active
	AL = 02h if caller is running in the invisible partition
----------21E400-----------------------------
INT 21 - OS/286, OS/386 - CHAIN TO REAL-MODE HANDLER
	AX = E400h
	???
Return: ???
Note:	protected mode only???
----------21E402-----------------------------
INT 21 - OS/286, OS/386 - SET PROTECTED-MODE TASK GATE
	AX = E402h
	???
Return: ???
Note:	protected mode only???
----------21E403-----------------------------
INT 21 - OS/286, OS/386 - REMOVE PROTECTED-MODE TASK GATE
	AX = E403h
	???
Return: ???
Note:	protected mode only???
----------21E5-------------------------------
INT 21 - Novell NetWare 4.0 - UPDATE FILE SIZE (FCB)
	AH = E5h
	DS:DX -> FCB
Return: AL = error code
----------21E500-----------------------------
INT 21 - OS/286, OS/386 - HEAP MANAGEMENT STRATEGY
	AX = E500h
	???
Return: ???
----------21E501-----------------------------
INT 21 - OS/286, OS/386 - FORCE HEAP COMPACTION
	AX = E501h
	???
Return: ???
----------21E6-------------------------------
INT 21 - Novell NetWare 4.0 - COPY FILE TO FILE (FCB)
	AH = E6h
	CX:DX = number of bytes to copy
	DS:SI -> source FCB
	ES:DI -> destination FCB
Return: AL = error code
----------21E6-------------------------------
INT 21 - OS/286, OS/386 - ISSUE REAL PROCEDURE SIGNAL FROM PROTECTED MODE
	AH = E6h
	???
Return: ???
Note:	protected mode only???
----------21E7-------------------------------
INT 21 - Novell NetWare 4.0, Banyan VINES - GET FILE SERVER DATE AND TIME
	AH = E7h
	DS:DX -> reply buffer
		BYTE  year - 1900
		BYTE  month
		BYTE  day
		BYTE  hours
		BYTE  minutes
		BYTE  seconds
		BYTE  day of week (0 = Sunday) (Novell only)
Return: AL = error code
	    00h successful
	    FFh unsuccessful
SeeAlso: AH=2Ah,2Ch
----------21E7-------------------------------
INT 21 - OS/286, OS/386 - CREATE CODE SEGMENT
	AH = E7h
	???
Return: ???
----------21E8-------------------------------
INT 21 - Novell NetWare 4.6 - SET FCB RE-OPEN MODE
	AH = E8h
	DL = mode
	    00h no automatic re-open
	    01h auto re-open
Return: AL = error code
----------21E8-------------------------------
INT 21 - OS/286, OS/386 - SEGMENT CREATION
	AH = E8h
	AL = type
	    00h data segment
	    01h data window/alias
	    02h real segment
	    03h real window/alias
	    06h shareable segment
	???
Return: ???
----------21E9-------------------------------
INT 21 - OS/286, OS/386 - CHANGE SEGMENTS
	AH = E9h
	AL = function
	    01h change code segment parameters
	    02h	change data segment parameters
	    05h adjust segment limit
	    06h change segment base address
	???
Return: ???
Note:	protected mode only???
----------21E900-----------------------------
INT 21 - Novell NetWare 4.6 - SHELL'S "GET BASE STATUS"
	AX = E900h
	DX = drive number to check (0 = A:)
Return: AL = network pathbase
	AH = base flags
	    00h drive not currently mapped to a base
	    01h drive is mapped to a permanent base
	    02h drive is mapped to a temporary base
	    03h drive exists locally
----------21E905-----------------------------
INT 21 - Novell NetWare shell 3.01 - MAP A FAKE ROOT DIRECTORY
	AX = E905h
	BL = drive number (0=default, 1=A:, ...)
	DS:DX -> ASCIZ path for fake root (may include server name or be empty)
Return: CF set on error
	    AL = error code (03h,0Fh,11h) (see AH=59h)
	CF clear if successful
Note:	if drive is not currently mapped, a drive mapping will be created
SeeAlso: AX=E906h
----------21E906-----------------------------
INT 21 - Novell NetWare shell 3.01 - DELETE FAKE ROOT DIRECTORY
	AX = E906h
	BL = drive number (0=default, 1=A:, ...)
Note:	drive remains mapped
SeeAlso: AX=E905h
----------21E907-----------------------------
INT 21 - Novell NetWare shell 3.01 - GET RELATIVE DRIVE DEPTH
	AX = E907h
	BL = drive number (0=default, 1=A:, ...)
Return: AL = number of directories below the fake root
	    FFh if no fake root assigned
SeeAlso: AX=E905h
----------21E908-----------------------------
INT 21 - Novell NetWare shell 3.01 - SET SHOW DOTS
	AX = E908h
	BL = 00h	don't return '.' or '..' during directory scans
	   = nonzero	directory scans will return '.' or '..' entries
Return: BL = previous show-dots setting
----------21EA-------------------------------
INT 21 - Novell NetWare 4.6 - RETURN SHELL VERSION
	AH = EAh
	AL = return version environment string
	    00h		don't return string
	    nonzero	return string in 40-byte buffer pointed to by ES:DI
		Return: buffer filled with three null-terminated entries:
			major operating system
			version
			hardware type
Return: AH = operating system (00h = MSDOS)
	AL = hardware type
	    00h IBM PC
	    01h Victor 9000
	BH = major shell version
	BL = minor shell version
	CH = (v3.01+) shell type
	    00h conventional memory
	    01h expanded memory
	    02h extended memory
	CL = shell revision number
----------21EA-------------------------------
INT 21 - DoubleDOS - TURN OFF TASK SWITCHING
	AH = EAh
Return: task switching turned off
SeeAlso: AH=EBh"DoubleDOS"
----------21EA-------------------------------
INT 21 - OS/286, OS/386 - ALLOCATE HUGE SEGMENT
	AH = EAh
	???
Return: ???
Note:	protected mode only???
----------21EB-------------------------------
INT 21 - Novell NetWare 4.6 - LOG FILE
	AH = EBh
	DS:DX -> ASCIZ filename
	if function C6h lock mode 01h:
	    AL = flags
		00h log file only
		01h lock as well as log file
	    BP = timeout in timer ticks (1/18 second)
Return: AL = error code
----------21EB-------------------------------
INT 21 - DoubleDOS - TURN ON TASK SWITCHING
	AH = EBh
Return: task switching turned on
SeeAlso: AH=EAh"DoubleDOS"
----------21EB00-----------------------------
INT 21 - OS/386 VMM - GET A PAGE TABLE ENTRY BY LINEAR ADDRESS
	AX = EB00h
	???
Return: ???
Note:	protected mode only???
----------21EB02-----------------------------
INT 21 - OS/386 VMM - GET A PAGE TABLE ENTRY BY 16-BIT SEGMENT:OFFSET
	AX = EB02h
	???
Return: ???
Note:	protected mode only???
----------21EB03-----------------------------
INT 21 - OS/386 VMM - FREE MAPPED PAGES
	AX = EB03h
	???
Return: ???
Note:	protected mode only???
----------21EB04-----------------------------
INT 21 - OS/386 VMM - GET A PAGE TABLE ENTRY BY 32-BIT SEGMENT:OFFSET
	AX = EB04h
	???
Return: ???
Note:	protected mode only???
----------21EB05-----------------------------
INT 21 - OS/386 VMM - MAP PAGES
	AX = EB05h
	???
Return: ???
Note:	protected mode only???
----------21EB06-----------------------------
INT 21 - OS/386 VMM - LOCK PAGES IN MEMORY
	AX = EB06h
	???
Return: ???
Note:	protected mode only???
----------21EB07-----------------------------
INT 21 - OS/386 VMM - UNLOCK MEMORY PAGES
	AX = EB07h
	???
Return: ???
Note:	protected mode only???
----------21EC-------------------------------
INT 21 - Novell NetWare 4.6 - RELEASE FILE
	AH = ECh
	DS:DX -> ASCIZ filename
Return: none
----------21EC-------------------------------
INT 21 - DoubleDOS - GET VIRTUAL SCREEN ADDRESS
	AH = ECh
Return: ES = segment of virtual screen
Note:	screen address can change if task-switching is on!!
----------21EC-------------------------------
INT 21 - OS/286, OS/386 - BLOCK TRANSFER
	AH = ECh
	???
Return: ???
----------21ED-------------------------------
INT 21 - Novell NetWare - CLEAR FILE
	AH = EDh
	DS:DX -> ASCIZ filename
Return: AL = error code
----------21ED-------------------------------
INT 21 - OS/286, OS/386 - GET SEGMENT OR WINDOW DESCRIPTOR
	AH = EDh
	???
Return: ???
Note:	protected mode only???
----------21EE-------------------------------
INT 21 - Novell NetWare 4.6 - GET PHYSICAL STATION NUMBER
	AH = EEh
Return: CX:BX:AX = six-byte address
----------21EE-------------------------------
INT 21 - DoubleDOS - GIVE AWAY TIME TO OTHER TASKS
	AH = EEh
	AL = number of 55ms time slices to give away
Return: returns after giving away time slices
----------21EF-------------------------------
INT 21 - Novell Advanced NetWare 1.0+ - GET DRIVE INFO
	AH = EFh
	AL = subfunction
	    00h get drive handle table
	    01h get drive flag table
	    02h get drive connection ID table
	    03h get connection ID table
	    04h get file server name table
Return: ES:DI -> shell status table
----------21F0-------------------------------
INT 21 - Novell Advanced NetWare 1.0+ - CONNECTION ID
	AH = F0h
	AL = subfunction
	    00h set preferred connection ID
	    01h get preferred connection ID
	    02h get default connection ID
	    03h LPT capture active
	    04h set primary connection ID
	    05h get primary connection ID
	DL = preferred file server
Return: AL = selected file server
----------21F1-------------------------------
INT 21 - Novell Advanced NetWare 1.0+ - FILE SERVER CONNECTION
	AH = F1h
	AL = subfunction
	    00h attach to file server
		DL = preferred file server
	    01h detach from file server
	    02h logout from file server
Return: AL = completion code
----------21F2-------------------------------
INT 21 - Novell NetWare - ???
	AH = F2h
	???
Return: ???
----------21F3-------------------------------
INT 21 - Novell Advanced NetWare 2.0+ - FILE SERVER FILE COPY
	AH = F3h
	ES:DI -> request string (see below)
Return: AL = status/error code
	CX:DX = number of bytes copied

Format of request string:
Offset	Size	Description
 00h	WORD	source file handle
 02h	WORD	destination file handle
 04h	DWORD	starting offset in source
 08h	DWORD	starting offset in destination
 0Ch	DWORD	number of bytes to copy
----------21F8-------------------------------
INT 21 - DOS v??? - SET OEM INT 21 HANDLER
	AH = F8h
	DS:DX -> OEM INT 21 handler for functions F9h to FFh
		 FFFFh:FFFFh resets to original handlers

Notes:	calls to AH=F9h through AH=FFH will return CF set and AX=1 (invalid
	  function) if no handler set
	handler is called with all registers exactly as set by caller, and
	  should exit with IRET
----------21F9-------------------------------
INT 21 - DOS v??? - OEM FUNCTION
	AH = F9h
----------21FA-------------------------------
INT 21 - DOS v??? - OEM FUNCTION
	AH = FAh
----------21FB-------------------------------
INT 21 - DOS v??? - OEM FUNCTION
	AH = FBh
----------21FC-------------------------------
INT 21 - DOS v??? - OEM FUNCTION
	AH = FCh
----------21FD-------------------------------
INT 21 - DOS v??? - OEM FUNCTION
	AH = FDh
----------21FE-------------------------------
INT 21 - DOS v??? - OEM FUNCTION
	AH = FEh
----------21FEDC-----------------------------
INT 21 - PCMag PCMANAGE/DCOMPRES - INSTALLATION CHECK
	AX = FEDCh
Return: AX = CDEFh if installed
SeeAlso: AH=DCh
----------21FF-------------------------------
INT 21 - DOS v??? - OEM FUNCTION
	AH = FFh
----------21FF-------------------------------
INT 21 - CED - INSTALLABLE COMMANDS
	AH = FFh
	AL = 00h add installable command
	       BL = mode - bit 0 = 1 callable from DOS prompt
			   bit 1 = 1 callable from application
	       DS:SI -> CR-terminated command name
	       ES:DI -> FAR routine entry point
	AL = 01h remove installable command
	       DS:SI -> CR-terminated command name
	AL = 02h reserved, may be used to test for CED installation
Return: CF set on error
	    AX = 01h invalid function
		 02h command not found (subfunction 01h only)
		 08h insufficient memory (subfunction 00h only)
		 0Eh bad data (subfunction 00h only)
	AH = 0FFh if CED not installed
----------21FF-------------------------------
INT 21 - Topware Network Operating System - ???
	AH = FFh
	???
Return: ???
----------22---------------------------------
INT 22 - DOS - TERMINATE ADDRESS
   FAR (DWORD) address to jump to when program "returns to DOS".  Normally
   points at the instruction immediately following INT 21/AH=4Bh call which
   loaded the current program.	Should NEVER be called directly.
SeeAlso: INT 20, INT 21/AH=00h,31h,4Ch
----------23---------------------------------
INT 23 - DOS - CONTROL "C" EXIT ADDRESS
   When DOS detects Ctrl-C or Ctrl-Break, it sends the string "^C" followed by
   CRLF to the calling process's standard output, then invokes this interrupt.
---DOS 1.x---
Return: AH = 00h abort program
	if all registers preserved, restart DOS call
---DOS 2+---
Return: return via RETF 2 with CF set
	    DOS will abort program with errorlevel 0
	else
	    interrupted DOS call continues
Note:	MSDOS 1.25 also invokes INT 23 on a divide overflow (INT 00)
SeeAlso: INT 1B
----------24---------------------------------
INT 24 - DOS - FATAL ERROR HANDLER ADDRESS
   Automatically called upon detection of unrecoverable I/O error.
   Normally points to routine in resident part of COMMAND.COM that prints
   "Abort, Retry, Ignore?" message and takes the reply, but may be overridden
   if desired.

Provides the following values in registers on entry to interrupt handler:
	AH: bit 7 = 0 disk I/O error
		  = 1 other error -- if block device, bad FAT
				  -- if char device, code in DI
	    bit 6  unused
	    bit 5 = 1 if Ignore allowed, 0 if not (DOS 3+)
	    bit 4 = 1 if Retry allowed, 0 if not (DOS 3+)
	    bit 3 = 1 if Fail allowed, 0 if not (DOS 3+)
	    bit 2 \ disk area of error	00 = DOS area  01 = FAT
	    bit 1 /			10 = root dir  11 = data area
	    bit 0 = 1 if write, 0 if read
	AL = drive number if AH bit 7 = 1, otherwise undefined
	BP:SI -> header of device driver for which error occurred
	    block device if high bit of BP:[SI+4] set
	low byte of DI:
	   00h write-protect error
	   01h unknown unit
	   02h drive not ready
	   03h unknown command
	   04h data error (bad CRC)
	   05h bad request structure length
	   06h seek error
	   07h unknown media type
	   08h sector not found
	   09h printer out of paper
	   0Ah write fault
	   0Bh read fault
	   0Ch general failure
	   0Dh (DOS 3+) sharing violation
	   0Eh (DOS 3+) lock violation
	   0Fh (DOS 3+) invalid disk change
	   10h (DOS 3+) FCB unavailable
	   11h (DOS 3+) sharing buffer overflow
Handler must return
	AL = 00h ignore error
	   = 01h retry operation
	   = 02h terminate program through INT 22h
	   = 03h fail system call in progress (DOS 3+)
Notes:	for DOS 3.1+, IGNORE (AL=00h) is turned into FAIL (AL=03h) on network
	  critical errors
	if IGNORE specified but not allowed, it is turned into FAIL
	if RETRY specified but not allowed, it is turned into FAIL
	if FAIL specified but not allowed, it is turned into ABORT
----------25---------------------------------
INT 25 - DOS - ABSOLUTE DISK READ (except DOS 4.0/COMPAQ DOS 3.31 >32M partitn)
	AL = drive number (0=A, 1=B, etc)
	DS:BX = Disk Transfer Address (buffer)
	CX = number of sectors to read
	DX = first relative sector to read
Return: CF set on error
	    AL = error code issued to INT 24h in low half of DI
	    AH = 80h if attachment failed to respond
		 40h if seek operation failed
		 20h if controller failed
		 10h if data error (bad CRC)
		 08h if DMA failure
		 04h if requested sector not found
		 03h if write-protected disk (INT 26 only)
		 02h if bad address mark
		 01h if bad command
	CF clear if successful
	    AL = 00h
Notes:	ORIGINAL FLAGS ON STACK!  Must be popped or discarded by adjusting SP
	May destroy all registers except segment regs
BUG:	DOS 3.1 through 3.3 set the word at ES:[BP+1Eh] to FFFFh if AL is an
	invalid drive number
SeeAlso: INT 26, INT 13/AH=02h
----------25----CXFFFF-----------------------
INT 25 - DOS 4.0/COMPAQ DOS 3.31 - ABSOLUTE DISK READ (>32M hard-disk partitn)
	AL = drive number (0=A, 1=B, etc)
	CX = FFFFh
	DS:BX -> disk read packet (see below)
Return: same as above
Notes:	partition is potentially >32M (and requires this form of the call) if
	  bit 1 of device attribute word in device driver is set
	ORIGINAL FLAGS LEFT ON STACK! Must be popped or discarded by adj SP
SeeAlso: INT 26, INT 13/AH=02h

Format of disk read packet:
Offset	Size	Description
 00h	DWORD	sector number
 04h	WORD	number of sectors to read
 06h	DWORD	transfer address
----------26---------------------------------
INT 26 - DOS - ABSOLUTE DISK WRITE (except DOS 4.0/COMPAQ DOS 3.31 >32M partn)
	AL = drive number (0=A, 1=B, etc)
	DS:BX = Disk Transfer Address (buffer)
	CX = number of sectors to write
	DX = first relative sector to write
Return: CF set on error
	    AL = error code issued to INT 24h in low half of DI
	    AH = same error codes as for INT 25h
	CF clear if successful
	    AL = 00h
Note:	ORIGINAL FLAGS ON STACK!  Must be popped or discarded by adjusting SP
BUG:	DOS 3.1 through 3.3 set the word at ES:[BP+1Eh] to FFFFh if AL is an
	invalid drive number
SeeAlso: INT 25, INT 13/AH=03h
----------26----CXFFFF-----------------------
INT 26 - DOS 4.0/COMPAQ DOS 3.31 - ABSOLUTE DISK WRITE (>32M hard-disk partitn)
	AL = drive number (0=A, 1=B, etc)
	CX = FFFFh
	DS:BX -> disk write packet (see below)
Return: same as above
Notes:	partition is potentially >32M (and requires this form of the call) if
	  bit 1 of device attribute word in device driver is set
	ORIGINAL FLAGS LEFT ON STACK!  Must be popped or discarded by adj SP
SeeAlso: INT 25, INT 13/AH=03h

Format of disk write packet:
Offset	Size	Description
 00h	DWORD	sector number
 04h	WORD	number of sectors to read
 06h	DWORD	transfer address
----------27---------------------------------
INT 27 - DOS - TERMINATE BUT STAY RESIDENT
	CS = current program segment
	DX = last program byte + 1
Return: never
Note:	this is an obsolete call
SeeAlso: INT 21/AH=31h
---------------------------------------------
