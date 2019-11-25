
; fasm demonstration of assembling object files

; compile the program using commands like:
;   fasm coffdemo.asm coffdemo.o
;   fasm writemsg.asm writemsg.o
;   ld coffdemo.o writemsg.o -o coffdemo
;   strip coffdemo

format COFF

section '.text' code

 public _start
 _start:

 extrn writemsg

	mov	esi,msg
	call	writemsg

	mov	eax,1
	xor	ebx,ebx
	int	0x80

section '.data' data

 msg db "Coffee time!",0xA,0

