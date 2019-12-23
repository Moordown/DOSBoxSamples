
store_iint_to_string:
    pop bx
    pop ax ; integer
    pop si ; memory for storing integer
    pop di ; integer max length
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
; _store_iint_to_string_leading_zeros:
;     cmp cx, 0
;     jne _store_iint_to_string_leading_zeros_start
;     mov bx, 0
;     push bx
;     inc cx
; _store_iint_to_string_leading_zeros_start:
;     load <cx>
;     and cx, 1
;     cmp cx, 0
;     restore <cx>
;     je _store_iint_to_string_inverse
;     inc cx
;     mov bx, 0
;     push bx
;     jmp _store_iint_to_string_leading_zeros_start
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