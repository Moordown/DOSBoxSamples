load macro args
    irp d,<args>
        push d
    endm
endm

restore macro args
    irp d,<args>
        pop d
    endm
endm

exit macro
    mov ah, 00h
    int 21h
endm

print macro buf
	mov ah, 09h
	mov dx, buf
	int 21h
endm

print_range macro args
    irp d,<args>
        print <offset d>
    endm
endm

break_point macro arg
    load <arg>
    xor arg, arg
    xor arg, arg
    xor arg, arg
    xor arg, arg
    xor arg, arg
    xor arg, arg
    xor arg, arg
    xor arg, arg
    restore <arg>
endm

parse_byte_to_str macro from, to
    mov ax, to
    push ax
    xor ax, ax
    mov al, from
    push ax
    call store_iint_to_string
endm

parse_word_to_str macro from, to
    mov ax, to
    push ax
    xor ax, ax
    mov ax, from
    push ax
    call store_iint_to_string
endm