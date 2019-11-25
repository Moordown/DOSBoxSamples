
; fDDraw - Win32 example program
; Copyright (c) 2001, Tomasz Grysztar
; All rights reserved.

format PE GUI
entry start

include 'include\kernel.inc'
include 'include\user.inc'
include 'include\ddraw.inc'

include 'include\macro\stdcall.inc'
include 'include\macro\import.inc'

section '.data' data readable writeable

  newhwnd dd 0				; handle of window
  hinstance dd 0			; handle of module
  active db 0

  msg MSG
  wc WNDCLASS

  _title db 'flat assembler DirectDraw application',0
  _class db 'FDDRAW32',0

  _error db 'Error',0
  _ddraw_error db 'Direct Draw initialization failed.',0
  _open_error db 'Failed opening data file.',0

  ddsd DDSURFACEDESC
  ddscaps DDSCAPS
  lpDD dd 0
  lpDDSPrimary dd 0
  lpDDSBack dd 0

  picture db 'fddraw.gif',0
  frame db 0
  rect RECT

  lpDDSPicture dd 0
  lpDDPalette dd 0
  bytes_count dd 0

section '.bss' udata readable writeable

  last_tick dd ?
  LZW_bits db ?
  LZW_table rd (0F00h-2)*2
  buffer rb 40000h

section '.code' code readable executable

  start:

	stdcall [GetModuleHandle],NULL
	mov	[hinstance],eax

	stdcall [LoadIcon],NULL,IDI_APPLICATION
	mov	[wc.hIcon],eax

	stdcall [LoadCursor],NULL,IDC_ARROW
	mov	[wc.hCursor],eax

	mov	[wc.style],0
	mov	[wc.lpfnWndProc],WindowProc
	mov	[wc.cbClsExtra],0
	mov	[wc.cbWndExtra],0
	mov	eax,[hinstance]
	mov	[wc.hInstance],eax
	mov	[wc.hbrBackground],COLOR_BTNSHADOW
	mov	dword [wc.lpszMenuName],NULL
	mov	dword [wc.lpszClassName],_class
	stdcall [RegisterClass],wc

	stdcall [CreateWindowEx],\
		0,_class,_title,WS_POPUP+WS_VISIBLE,0,0,0,0,NULL,NULL,[hinstance],NULL
	mov	[newhwnd],eax

	stdcall [DirectDrawCreate],NULL,lpDD,NULL
	or	eax,eax
	jnz	ddraw_error

	comcall [lpDD],IDirectDraw.SetCooperativeLevel,\
		[newhwnd],DDSCL_EXCLUSIVE+DDSCL_FULLSCREEN
	or	eax,eax
	jnz	ddraw_error

	comcall [lpDD],IDirectDraw.SetDisplayMode,\
		640,480,8
	or	eax,eax
	jnz	ddraw_error

	mov	[ddsd.dwSize],ddsd.end-ddsd
	mov	[ddsd.dwFlags],DDSD_CAPS+DDSD_BACKBUFFERCOUNT
	mov	[ddsd.ddsCaps.dwCaps],DDSCAPS_PRIMARYSURFACE+DDSCAPS_FLIP+DDSCAPS_COMPLEX
	mov	[ddsd.dwBackBufferCount],1
	comcall [lpDD],IDirectDraw.CreateSurface,\
		ddsd,lpDDSPrimary,NULL
	or	eax,eax
	jnz	ddraw_error

	mov	[ddscaps.dwCaps],DDSCAPS_BACKBUFFER
	comcall [lpDDSPrimary],IDirectDrawSurface.GetAttachedSurface,\
		ddscaps,lpDDSBack
	or	eax,eax
	jnz	ddraw_error

	mov	esi,picture
	call	load_picture
	jc	open_error

	mov	esi,picture
	call	load_palette
	jc	open_error

	comcall [lpDDSPrimary],IDirectDrawSurface.SetPalette,eax

	call	[GetTickCount]
	mov	[last_tick],eax

	jmp	paint

main_loop:

	stdcall [PeekMessage],msg,NULL,0,0,PM_NOREMOVE
	or	eax,eax
	jz	no_message
	stdcall [GetMessage],msg,NULL,0,0
	or	eax,eax
	jz	end_loop
	stdcall [TranslateMessage],msg
	stdcall [DispatchMessage],msg

	jmp	main_loop

    no_message:

	cmp	[active],0
	je	sleep

	comcall [lpDDSPrimary],IDirectDrawSurface.IsLost
	or	eax,eax
	jz	paint
	cmp	eax,DDERR_SURFACELOST
	jne	end_loop

	comcall [lpDDSPrimary],IDirectDrawSurface.Restore

paint:

	mov	[rect.top],0
	mov	[rect.bottom],480
	mov	[rect.left],0
	mov	[rect.right],640

	comcall [lpDDSBack],IDirectDrawSurface.BltFast,\
		0,0,[lpDDSPicture],rect,DDBLTFAST_SRCCOLORKEY

	movzx	eax,[frame]
	xor	edx,edx
	mov	ebx,10
	div	ebx

	sal	eax,6
	add	eax,480
	mov	[rect.top],eax
	add	eax,64
	mov	[rect.bottom],eax
	sal	edx,6
	mov	[rect.left],edx
	add	edx,64
	mov	[rect.right],edx

	comcall [lpDDSBack],IDirectDrawSurface.BltFast,\
		288,200,[lpDDSPicture],rect,DDBLTFAST_SRCCOLORKEY

	comcall [lpDDSPrimary],IDirectDrawSurface.Flip,0,0

	call	[GetTickCount]
	mov	ebx,eax
	sub	ebx,[last_tick]
	cmp	ebx,20
	jb	main_loop
	mov	[last_tick],eax

	inc	[frame]
	cmp	[frame],60
	jb	main_loop
	mov	[frame],0
	jmp	main_loop

sleep:
	call	[WaitMessage]
	jmp	main_loop

ddraw_error:
	mov	eax,_ddraw_error
	jmp	error
open_error:
	mov	eax,_open_error
    error:
	stdcall [MessageBox],[newhwnd],eax,_error,MB_OK
	stdcall [DestroyWindow],[newhwnd]
	stdcall [PostQuitMessage],1
	jmp	main_loop

end_loop:
	stdcall [ExitProcess],[msg.wParam]

include 'gif87a.inc'

proc WindowProc, hwnd,wmsg,wparam,lparam
	push	ebx esi edi
	cmp	[wmsg],WM_CREATE
	je	wmcreate
	cmp	[wmsg],WM_DESTROY
	je	wmdestroy
	cmp	[wmsg],WM_ACTIVATE
	je	wmactivate
	cmp	[wmsg],WM_SETCURSOR
	je	wmsetcursor
    defwindowproc:
	stdcall [DefWindowProc],[hwnd],[wmsg],[wparam],[lparam]
	jmp	finish
    wmcreate:
	xor	eax,eax
	jmp	finish
    wmdestroy:
	stdcall [PostQuitMessage],0
	xor	eax,eax
	jmp	finish
    wmactivate:
	mov	eax,[wparam]
	mov	[active],al
	jmp	finish
    wmsetcursor:
	stdcall [SetCursor],0
	xor	eax,eax
	jmp	finish
    finish:
	pop	edi esi ebx
	return

section '.idata' import data readable

  library kernel,'KERNEL32.DLL',\
	  user,'USER32.DLL',\
	  ddraw,'DDRAW.DLL'

  kernel:
  import GetModuleHandle,'GetModuleHandleA',\
	 CreateFile,'CreateFileA',\
	 ReadFile,'ReadFile',\
	 CloseHandle,'CloseHandle',\
	 GetTickCount,'GetTickCount',\
	 ExitProcess,'ExitProcess'

  user:
  import RegisterClass,'RegisterClassA',\
	 CreateWindowEx,'CreateWindowExA',\
	 DestroyWindow,'DestroyWindow',\
	 DefWindowProc,'DefWindowProcA',\
	 GetMessage,'GetMessageA',\
	 PeekMessage,'PeekMessageA',\
	 TranslateMessage,'TranslateMessage',\
	 DispatchMessage,'DispatchMessageA',\
	 LoadCursor,'LoadCursorA',\
	 LoadIcon,'LoadIconA',\
	 SetCursor,'SetCursor',\
	 MessageBox,'MessageBoxA',\
	 PostQuitMessage,'PostQuitMessage',\
	 WaitMessage,'WaitMessage'

  ddraw:
  import DirectDrawCreate,'DirectDrawCreate'
