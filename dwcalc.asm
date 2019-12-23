include bmacro.asm


.model tiny
.386
.code
org 100h
start:
    call example_add

example_add:
    lea ax, add_word_1
    push ax
    call set_dword_from
    lea ax, add_word_2
    push ax
    call dadd_from
    mov ax, 0
    push ax
    lea ax, integer
    push ax
    lea ax, doubleword
    push ax
    call store_iint_to_string
    print_range <integer, example_newline> 
    exit

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

get_dword_addr:
    pop bx
    lea ax, doubleword
    push bx 

    ret

set_dword_from:
    pop dx
    pop bx ; address from
    push dx
    mov dx, word ptr [bx + 2]
    push dx 
    mov dx, word ptr [bx]
    push dx 
    call set_dword
    ret

dadd_from:
    pop dx
    pop bx ; address from
    push dx
    mov ax, word ptr [bx + 2]
    push ax 
    mov ax, word ptr [bx]
    push ax
    call dadd
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
    jmp _dadd_no_add_one
_dadd_add_one:
    inc bx
_dadd_no_add_one:
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

store_iint_to_string:
    pop bx
    pop ax ; dword integer address
    pop si ; memory for storing integer
    pop di ; integer min length
    push bx

    push ax
    call set_dword_from

    mov cx, 0
_store_iint_to_string_direct: 
    load <cx> 
    call get_dword
    pop ax
    pop bx
    restore <cx>
    cmp ax, 0
    jne _store_iint_to_string_direct_next_loop
    cmp bx, 0
    jne _store_iint_to_string_direct_next_loop
    jmp _store_iint_to_string_zero_padding_start

_store_iint_to_string_direct_next_loop:  
    load <cx, si, di>
    call ddiv10
    restore <di, si, cx>
    mov dx, word ptr [remainder]
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

remainder dw 0
doubleword dd 0
integer db 64 dup('$')

div_word dd 67306112
add_word_1 dd 123052
add_word_2 dd 30

example_ok db 'ok$'
example_err db 'err$'
example_newline db 0Ah, '$'

end start