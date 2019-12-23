set_dword:
    pop cx ; ret address
    pop ax ; word ptr [l16]
    pop dx ; word ptr [h16]

    push cx
    mov word ptr [doubleword], ax
    mov word ptr [doubleword + 2], dx

    ret

get_dword:
    pop cx ; ret address

    mov ax, word ptr [doubleword]
    mov dx, word ptr [doubleword + 2]

    push dx
    push ax
    push cx

    ret

dadd:
    pop si
    ;
    ; on stack lay pair (l,h) of one dword, then we load second
    ;
    call get_dword

    pop ax ; our low
    pop bx ; our hight
    pop cx ; their low
    pop dx ; their hight

    adc ax, cx
    jc _dadd_add_one
_dadd_add_one:
    inc bx
    add bx, dx
    push bx
    push ax
    call set_dword
    push si
    ret

ddiv10:
    call get_dword
    call _ddiv10
    mov word ptr [remainder], dx
    call set_dword

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
doubleword dd 0