
; fasm example of writing 32-bit PE program using Win32 API

format PE GUI
entry start

include 'windows.inc'

section '.code' code readable executable

  start:

	push	MB_OK + MB_ICONEXCLAMATION
	push	_caption
	push	_message
	push	0
	call	[MessageBox]

	push	0
	call	[ExitProcess]

section '.data' data readable writeable

  _caption db 'Win32 assembly program',0
  _message db 'Hello World!',0

section '.idata' import data readable writeable

  dd 0,0,0,rva kernel_name,rva kernel_table
  dd 0,0,0,rva user_name,rva user_table
  dd 0,0,0,0,0

  kernel_table:
    ExitProcess dd rva _ExitProcess
    dd 0
  user_table:
    MessageBox dd rva _MessageBoxA
    dd 0

  kernel_name db 'KERNEL32.DLL',0
  user_name db 'USER32.DLL',0

  _ExitProcess dw 0
    db 'ExitProcess',0
  _MessageBoxA dw 0
    db 'MessageBoxA',0

section '.reloc' fixups data readable discardable
