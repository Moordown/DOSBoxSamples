
; fasm example of using the C library in linux

; compile the source with commands like:
;   fasm libcdemo.asm libcdemo.o
;   gcc libcdemo.o -o libcdemo
;   strip libcdemo

format COFF

include 'ccall.inc'

section '.text' code

 public main
 extrn printf
 extrn getpid
 
 main:
	call	getpid
	ccall   printf, msg,eax
	ret

section '.data' data

 msg db "Current process ID is %d.",0xA,0
