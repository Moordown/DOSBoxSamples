include bmacro.asm

.model tiny
.386
.code
org 100h
start:
    call example_add

example_div:
    mov ax, word ptr [div_word]
    mov bx, word ptr [div_word + 2]
    push bx
    push ax
    call set_dword
    call ddiv10
    mov dx, word ptr [remainder]
    cmp dx, 2
    jne example_div_l1
    call get_dword
    pop ax ; l
    pop dx ; h
    cmp dx, 102
    jne example_div_l1
    cmp ax, 45939
    jne example_div_l1
    print_range <example_ok, example_newline>
    jmp example_div_ext
example_div_l1:
    print_range <example_err, example_newline>
    jmp example_div_ext
example_div_ext:
    exit
    ret


example_add:
    mov ax, word ptr [add_word]
    mov bx, word ptr [add_word + 2]
    push bx
    push ax
    call set_dword
    mov ax, word ptr [add_word]
    mov bx, word ptr [add_word + 2]
    push bx
    push ax
    call dadd
    call get_dword
    pop ax ; l
    pop dx ; h
    cmp dx, 1
    jne example_add_l1
    cmp ax, 65534
    jne example_add_l1
    print_range <example_ok, example_newline>
    jmp example_add_ext
example_add_l1:
    print_range <example_err, example_newline>
    jmp example_add_ext
example_add_ext:
    exit
    ret

include fdwcalc.asm

div_word dd 67306112
add_word dd 65535

example_ok db 'ok$'
example_err db 'err$'
example_newline db 0Ah, '$'

end start