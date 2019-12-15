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

push_fragment macro buf, length
    local l1
    lea di, buf
    mov cx, length
    xor bx, bx
l1:
    mov bl, byte ptr [di]
    push bx
    inc di
    dec cx
    cmp cx, 0
    jne l1
endm

pop_fragment macro buf, length
    local l1
    lea di, buf
    mov cx, length
    add di, cx
    dec di
    xor bx, bx
l1:
    pop bx
    mov byte ptr [di], bl
    dec di
    dec cx
    cmp cx, 0
    jne l1
endm

set_dta macro dta
    lea dx, dta
    xor ax, ax 
    mov ah, 1Ah
    int 21h
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