
program_base = 0x8048000

org program_base
use32

file_header:
	db	0x7F,'ELF',1,1,1
	rb	file_header+0x10-$
	dw	2,3
	dd	1,start
	dd	program_header-file_header,0,0
	dw	program_header-file_header,0x20,1,0,0,0

program_header:
	dd	1,0,program_base,0
	dd	file_end-program_base,program_end-program_base,7,0x1000

bss_defined = 0

macro .bss
 {
   file_end:
   bss_defined = 1
 }

macro end.
 {
   if ~ bss_defined
    file_end:
   end if
   program_end:
  }
