
; fasm example of writing PE dynamic link library

format PE console DLL
entry DLL_init

macro align value { rb (value-1) - (rva $ + value-1) mod value }

section '.code' code readable executable

DLL_init:
	mov	eax,1			; successful initialization
	ret	0Ch

align 4 				; dword alignment

WriteText:				; edx must point to zero padded text
	push	-11
	call	[GetStdHandle]
	mov	ebx,eax
	mov	edi,edx
	or	ecx,-1
	xor	al,al
	repne	scasb
	neg	ecx
	sub	ecx,2
	push	0
	push	bytes_count
	push	ecx
	push	edx
	push	ebx
	call	[WriteFile]
	ret

section '.data' data readable writeable

  bytes_count dd ?

section '.idata' import data readable writeable

  dd 0,0,0,rva kernel_name,rva kernel_table
  dd 0,0,0,0,0

  kernel_table:
    GetStdHandle dd rva _GetStdHandle
    WriteFile dd rva _WriteFile
    dd 0

  kernel_name db 'KERNEL32.DLL',0

  _GetStdHandle dw 0
    db 'GetStdHandle',0
  _WriteFile dw 0
    db 'WriteFile',0

section '.edata' export data readable

  dd 0,0,0,rva dlldemo_name,1
  dd 1,1,rva addresses_table,rva names_table,rva ordinal_table

  addresses_table:
    dd rva WriteText

  names_table:
    dd rva _WriteText
  ordinal_table:
    dw 0

  dlldemo_name db 'PEDLL.DLL',0

  _WriteText db 'WriteText',0

section '.reloc' fixups data readable discardable
