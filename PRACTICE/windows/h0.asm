option casemap : none

extrn ExitProcess : proc

.code
_start proc

    ; rcx, rdx, r8x, r9x
    xor ecx, ecx
    call ExitProcess

_start endp
end