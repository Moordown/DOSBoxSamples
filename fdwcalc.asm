ddiv10_set_word:
    pop cx ; ret address
    pop ax ; word ptr [l16]
    pop dx ; word ptr [h16]

    push cx
    mov word ptr [doubleword], ax
    mov word ptr [doubleword + 2], dx

    ret

ddiv10_get_word:
    pop cx ; ret address

    mov ax, word ptr [doubleword]
    mov dx, word ptr [doubleword + 2]

    push dx
    push ax
    push cx

    ret

ddiv10:
    call ddiv10_get_word
    call _ddiv10
    mov word ptr [remainder], dx
    call ddiv10_set_word

    ret

_ddiv10:
    pop cx ; ret address
    pop ax ; word ptr [l16]
    pop dx ; word ptr [h16]

    load <ax>
    mov ax, dx
    xor dx, dx
    mov bx, 10
    div bx
    mov bx, ax ; word ptr [h16]
    restore <ax>
    push bx

    mov bx, 10
    div bx
    push ax ; word ptr [l15]

    push cx
    ret

remainder dw 0
doubleword dd 67306112