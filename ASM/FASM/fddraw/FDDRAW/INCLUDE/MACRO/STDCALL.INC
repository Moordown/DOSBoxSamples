
; macroinstructions for defining and invoking stdcall HLL procedures

macro proc name,[arg]			; define procedure
 { common
    name:
    virtual at ebp+8
   forward
     local ..arg
     ..arg dd ?
     arg equ ..arg
   common
     ..ret = $ - (ebp+8)
    end virtual
    enter 0,0 }

macro return				; return from procedure
 { leave
   ret ..ret }

macro stdcall proc,[arg]		; call procedure
 { reverse
    push arg
   common
    call proc }

macro invoke proc,[arg] 		; invoke procedure (indirect)
 { common
    if arg eq
     call [proc]
    else
     stdcall [proc],arg
    end if }

macro comcall object,proc,[arg] 	; invoke COM method
 { common
    if ~ arg eq
   reverse
    push arg
   common
    end if
    mov eax,object
    mov ebx,[eax]
    push eax
    call [ebx+proc] }
