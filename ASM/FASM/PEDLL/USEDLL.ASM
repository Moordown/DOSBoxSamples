
; fasm example of program using DLLDEMO.DLL library

format PE console

section '.code' code readable executable

	mov	edx,_message
	call	[WriteText]

	push	0
	call	[ExitProcess]

section '.data' data readable writeable

  _message db 'This message is printed using PEDLL.DLL',0Dh,0Ah,0

section '.idata' import data readable writeable

  dd rva dlldemo_table,0,0,rva dlldemo_name,rva dlldemo_table
  dd 0,0,0,rva kernel_name,rva kernel_table
  dd 0,0,0,0,0

  dlldemo_table:
    WriteText dd rva _WriteText
    dd 0
  kernel_table:
    ExitProcess dd rva _ExitProcess
    dd 0

  dlldemo_name db 'PEDLL.DLL',0
  kernel_name db 'KERNEL32.DLL',0

  _WriteText dw 0
    db 'WriteText',0
  _ExitProcess dw 0
    db 'ExitProcess',0

section '.reloc' fixups data readable discardable
