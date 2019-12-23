include fdwcalc.asm

store_iint_to_string:
    pop bx
    pop ax ; dword integer address
    pop si ; memory for storing integer
    pop di ; integer min length
    push bx

    mov cx, 0
    mov bx, 10
_store_iint_to_string_direct:
    cmp ax, 0
    je _store_iint_to_string_zero_padding_start
    
    xor dx, dx
    div bx
    push dx
    inc cx

    jmp _store_iint_to_string_direct

_store_iint_to_string_zero_padding_start:
    sub di, cx
_store_iint_to_string_zero_padding_loop:
    cmp di, 0
    jle _store_iint_to_string_zero_padding_end
    mov bx, 0
    push bx
    dec di
    inc cx
    jmp _store_iint_to_string_zero_padding_loop
_store_iint_to_string_zero_padding_end:
_store_iint_to_string_inverse:
    load <si>
    add si, cx
    mov byte ptr [si], '$'
    restore <si>
_store_iint_to_string_inverse_loop:
    cmp cx, 0
    je _store_iint_to_string_end
    
    pop dx
    add dl, 30h
    mov byte ptr [si], dl
    inc si
    dec cx

    jmp _store_iint_to_string_inverse_loop

_store_iint_to_string_end:
    ret


store_dword_to_string:
    pop bx
    pop ax ; dword integer address
    pop si ; memory for storing integer
    pop di ; integer min length
    push bx

    push ax
    call set_dword_from

    mov cx, 0
_store_dword_to_string_direct: 
    load <cx> 
    call get_dword
    pop ax
    pop bx
    restore <cx>
    cmp ax, 0
    jne _store_dword_to_string_direct_next_loop
    cmp bx, 0
    jne _store_dword_to_string_direct_next_loop
    jmp _store_dword_to_string_zero_padding_start

_store_dword_to_string_direct_next_loop:  
    load <cx, si, di>
    call ddiv10
    restore <di, si, cx>
    mov dx, word ptr [remainder]
    push dx
    inc cx

    jmp _store_dword_to_string_direct

_store_dword_to_string_zero_padding_start:
    sub di, cx
_store_dword_to_string_zero_padding_loop:
    cmp di, 0
    jle _store_dword_to_string_zero_padding_end
    mov bx, 0
    push bx
    dec di
    inc cx
    jmp _store_dword_to_string_zero_padding_loop
_store_dword_to_string_zero_padding_end:
_store_dword_to_string_inverse:
    load <si>
    add si, cx
    mov byte ptr [si], '$'
    restore <si>
_store_dword_to_string_inverse_loop:
    cmp cx, 0
    je _store_dword_to_string_end
    
    pop dx
    add dl, 30h
    mov byte ptr [si], dl
    inc si
    dec cx

    jmp _store_dword_to_string_inverse_loop

_store_dword_to_string_end:
    ret