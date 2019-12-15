include filefunc.asm
include clfunc.asm
include tmacro.asm


count_subfiles_here_by_mask:
    pop bx
    pop si              ; find_first address
    pop ax              ; mask address
    push bx

    load <ax, si>
    set_dta count_dta
    restore <si, ax>

    mov cx, 0
    load <cx>
    push ax
    call si
    jc _count_subfiles_from_end
_count_subfiles_from_loop:
    lea ax, count_dta
    add ax, 1Eh
    mov bx, ax
    cmp byte ptr [bx], '.' 
    je _count_subfiles_from_loop_next 
    
    restore <cx>
    inc cx
    load <cx> 
_count_subfiles_from_loop_next:
    call find_next
    jc _count_subfiles_from_end
    
    jmp _count_subfiles_from_loop
_count_subfiles_from_end:
    restore <cx>
    mov ax, cx
    ret

count_dta db 128 dup(0)