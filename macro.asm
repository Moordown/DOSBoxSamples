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

get_offset macro state
    xor dx, dx
    xor ax, ax
    mov al, state
    shl ax, 8
endm get_offset

to_non_space macro addr
    local l1, l2
    mov si, addr
l1:
    mov byte ptr al, [si]
    cmp al, 20h
    je l2
    cmp al, 0
    je l2
    inc si
    jmp l1
l2:
    inc si
    mov ax, si
endm

set_transition macro buf, from, to, char
    load<bx, dx>
    get_offset from

    add ax, offset buf
    add ax, char

    mov bx, ax
    mov byte ptr [bx], to
    restore<dx, bx>
endm

set_transition_length_from_start macro buf, from, to, start, iterations
    local l1, end
    mov bx, start
    mov cx, iterations
l1:
    cmp cx, 0
    je end

    load <bx,cx>
    set_transition buf from to bx
    restore <cx,bx>

    inc bx
    dec cx
    jmp l1
end:
endm

set_zero macro state
    mov al, 0
    mov byte ptr [state], al
endm

set_transition_for_all macro buf, from, to
    set_transition_length_from_start buf, from, to, 0, 255
endm

set_transition_for_digits macro buf, from, to
    set_transition_length_from_start buf, from, to, 30, 10
endm

set_transition_for_letters macro buf, from, to
    set_transition_length_from_start buf, from, to, 97, 26
    set_transition_length_from_start buf, from, to, 65, 26
endm

get_transition macro buf, from, char
    load <dx>  
    get_offset from
    restore <dx>

    add ax, offset buf
    add ax, char

    mov bx, ax
    xor ax, ax
    mov al, byte ptr [bx]
endm

put macro from, to, position
    xor dx, dx
    xor bx, bx

    mov dx, offset to
    mov bl, byte ptr [position]
    add dx, bx

    mov bl, byte ptr [from]
    mov byte ptr [edx], bl
    inc [position]
endm

clear_mes macro mes, lastidx
    local l1, end
    mov bx, offset mes
    mov cl, byte ptr [lastidx]
    inc cl
l1:
    cmp cl, 0
    je end
    mov byte ptr [bx], '$'
    inc bx
    dec cl
    jmp l1
end:
    mov bl, 0
    mov byte ptr [lastidx], bl
endm