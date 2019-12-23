include bmacro.asm

.model tiny
.386
.code
org 100h
start:
    call ddiv10
    mov dx, word ptr [remainder]
    cmp dx, 2
    jne l1
    call ddiv10_get_word
    pop ax ; l
    pop dx ; h
    cmp dx, 102
    jne l1
    cmp ax, 45939
    jne l1
    print_range <ddiv10ok, ddiv10newline>
    jmp ext
l1:
    print_range <ddiv10err, ddiv10newline>
    jmp ext
ext:
    exit

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
    ; mov ax, word ptr [num]
    ; mov dx, word ptr [num + 2]
    ; push dx
    ; push ax
    call _ddiv10

    mov word ptr [remainder], dx
    call ddiv10_set_word
    ; pop ax ; l
    ; pop dx ; h
    ; mov word ptr [num], ax
    ; mov word ptr [num + 2], dx 

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

ddiv10ok db 'ok$'
ddiv10err db 'err$'
ddiv10newline db 0Ah, '$'

end start