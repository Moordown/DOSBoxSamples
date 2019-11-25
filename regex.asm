include macro.asm

model tiny
.386
.code
org 100h
start:	
    call create_D_table
    call create_C_table
    call create_B_table
    call create_A_table
    to_non_space 80h
    mov si, ax
parse_loop:
    load <si>
    xor dx, dx
    xor bx, bx
    xor ax, ax
    mov dl, byte ptr [si]
    cmp dl, 0Dh
    je l8
    mov bl, byte ptr [state]
    get_transition buf, bl, dx
    restore <si>

    mov byte ptr [state], al
    cmp al, 0
    je l9
    cmp al, byte ptr [termA]
    jle l1
    cmp al, byte ptr [termB]
    jle l3
    cmp al, byte ptr [termC]
    jle l5
    cmp al, byte ptr [termD]
    jle l7
    jmp eall
l1:
    put si, pr, prad
    mov al, byte ptr [state]
    cmp al, byte ptr [termA]
    je l2
    jmp eloop
l2:
    print_range <prmes, pr, newline>
    inc [state]
    jmp eloop
l3:
    put si, dom, domad
    mov al, byte ptr [state]
    cmp al, byte ptr [termB]
    je l4
    jmp eloop
l4:
    print_range <dommes, dom, newline>
    inc [state]
    jmp eloop
l5:
    mov al, byte ptr [state]
    cmp al, byte ptr [termC]
    je l6
    put si, pat, patad
    jmp eloop
l6:
    print_range <pathmes, pat, newline>
    put si, que, quead
    inc [state]
    jmp eloop
l7:
    put si, que, quead
    mov al, byte ptr [state]
    cmp al, byte ptr [termD]
    je l4
    jmp eloop
l8:
    print_range <querymes, que, newline>
    inc [state]
    jmp eall
l9:
    print_range <errormes, newline>
    jmp eall
eloop:
    inc si
    jmp parse_loop
eall:
    exit
create_D_table:
    set_transition_for_all buf 11 11
    ret
create_C_table:
    set_transition buf_all buf 10 10
    set_transition buf 10 11 '?'
    ret
create_B_table:
    set_transition_for_digits buf 9 9
    set_transition_for_letters buf 9 9
    set_transition buf 9 9 '.'
    set_transition buf 9 10 '/'
    set_transition buf 9 11 '/'
    ret
create_A_table:
    set_transition buf 0 1 'h'
    set_transition buf 1 2 't'
    set_transition buf 2 3 't'
    set_transition buf 3 4 'p'
    set_transition buf 4 5 's'
    set_transition buf 4 6 ':'
    set_transition buf 5 6 ':'
    set_transition buf 6 7 '/'
    set_transition buf 7 8 '/'
    ret
state db 0

termA db 8
termB db 10
termC db 11
termD db 12

pr db 128 dup('$')
dom db 128 dup('$')
pat db 128 dup('$')
que db 128 dup('$')

prmes db 'Protocol: $'
dommes db 'Domain: $'
pathmes db 'Path: $'
querymes db 'Query: $'

errormes db 'Error: incorrect format$'

newline db 0Ah, '$'

prad db 0
domad db 0
patad db 0
quead db 0

buf db 3600 dup(0) ; memory for table
end start