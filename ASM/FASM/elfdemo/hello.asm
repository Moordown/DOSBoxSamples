
; fasm demonstration of buliding ELF file using binary output mode

include 'elf.ash'

msg db 'Hello world!',0xA
msg_size = $-msg

start:

	mov	eax,4
	mov	ebx,1
	mov	ecx,msg
	mov	edx,msg_size
	int	0x80

	mov	eax,1
	xor	ebx,ebx
	int	0x80

	end.
        
