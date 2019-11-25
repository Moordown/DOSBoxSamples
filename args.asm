model tiny
.386
.code
org 100h
start:	
    mov si, 80h
fspase:
    mov byte ptr al, [si]
    cmp al, 20h
    je fspace_end
    inc si
fspace_end:
    inc si
l1:
    cmp si, 100h
    je exit
    mov byte ptr al, [si]
    cmp al, 22h
    jne next_char_space
    mov byte ptr bl, [flag]
    xor bl, 1
    mov byte ptr [flag], bl
    cmp bl, 1
    je l1_end
    call print_newline
    jmp l1_end
next_char_space:
    cmp al, 20h
    jne next_char_any
    mov byte ptr bl, [flag]
    cmp bl, 1
    je print_next
    call print_newline
    jmp l1_end
next_char_any:
    cmp al, 0dh
    jne print_next 
    call print_newline
    call exit
print_next:
    cmp al, 65
    jl print2
    cmp al, 90
    jg next
    add al, 32
    jmp print2
next:
    cmp al, 97
    jl print2
    cmp al, 122
    jg print2
    sub al, 32
    jmp print2
print2:
    mov byte ptr [buf], al
    call print
l1_end:
    inc si
    jmp l1
exit:
    mov ah, 00h
    int 21h
    ret
print:
	mov ah, 09h
	mov dx, offset buf
	int 21h
	ret
print_newline:
    mov byte ptr [buf], 0ah
    call print
    ret
buf db 2 dup("$")
flag_symbol db "\""
flag db 0
end start