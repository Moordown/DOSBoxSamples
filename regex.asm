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
    call create_Zero_table
    to_non_space 80h
    mov si, ax
parse_loop:
    load <si>
    xor dx, dx
    xor bx, bx
    xor ax, ax
    mov dl, byte ptr [si]
    cmp dl, 0Dh
    jne l0
    mov al, byte ptr [domain_was]
    cmp al, 0
    je l11
    mov al, byte ptr [query_was]
    cmp al, 0
    je l10
    jmp l8
l0:
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
    put si, mes, mesad
    mov al, byte ptr [state]
    cmp al, byte ptr [termA]
    je l2
    jmp eloop
l2:
    print_range <prmes, mes, newline>
    clear_mes mes, mesad
    set_zero state
    jmp eloop
l3:
    mov bl, 1
    mov byte ptr [domain_was], bl
    mov al, byte ptr [state]
    cmp al, byte ptr [termB]
    je l4
    put si, mes, mesad
    jmp eloop
l4:
    print_range <dommes, mes, newline>
    clear_mes mes, mesad
    set_zero state
    dec si
    jmp eloop
l5:
    mov al, byte ptr [state]
    cmp al, byte ptr [termC]
    je l6
    put si, mes, mesad
    jmp eloop
l6:
    print_range <pathmes, mes, newline>
    clear_mes mes, mesad
    set_zero state
    dec si
    jmp eloop
l7:
    mov bl, 1
    mov byte ptr [query_was], bl
    mov al, byte ptr [state]
    cmp al, byte ptr [termD]
    je l8
    put si, mes, mesad
    jmp eloop
l8:
    print_range <querymes, mes, newline>
    clear_mes mes, mesad
    set_zero state
    jmp eall
l9:
    print_range <errormes, newline>
    jmp eall
l10:
    print_range <errormes2, newline>
    jmp eall
l11:
    print_range <errormes3, newline>
    jmp eall
eloop:
    inc si
    jmp parse_loop
eall:
    exit
create_D_table:
    set_transition_for_all buf 15 15
    ret
create_C_table:
    set_transition_for_all buf 12 13
    set_transition_for_all buf 13 13
    set_transition buf 13 14 '?'
    ret
create_B_table:
    set_transition_for_digits buf 9 9
    set_transition_for_letters buf 9 9
    set_transition buf 9 10 '.'
    set_transition_for_digits buf 10 9
    set_transition_for_letters buf 10 9
    set_transition buf 10 11 '/'
    set_transition buf 10 11 '?'
    ret
create_A_table:
    set_transition buf 0 1 'h'
    
    set_transition_for_digits buf 1 9
    set_transition_for_letters buf 1 9
    set_transition buf 1 9 '.'
    set_transition buf 1 2 't'
    
    set_transition_for_digits buf 2 9
    set_transition_for_letters buf 2 9
    set_transition buf 2 9 '.'
    set_transition buf 2 3 't'
    
    set_transition_for_digits buf 3 9
    set_transition_for_letters buf 3 9
    set_transition buf 3 9 '.'
    set_transition buf 3 4 'p'
    
    set_transition_for_digits buf 4 9
    set_transition_for_letters buf 4 9
    set_transition buf 4 9 '.'
    set_transition buf 4 5 's'
    
    set_transition buf 4 6 ':'
    
    set_transition_for_digits buf 5 9
    set_transition_for_letters buf 5 9
    set_transition buf 5 9 '.'
    set_transition buf 5 6 ':'
    set_transition buf 6 7 '/'
    set_transition buf 7 8 '/'
    ret
create_Zero_table:
    set_transition_for_digits buf 0 9
    set_transition_for_letters buf 0 9
    set_transition buf 0 9 '.'
    set_transition buf 0 12 '/'
    set_transition buf 0 15 '?'

    set_transition buf 0 1 'h'
    ret
state db 0

termA db 8
termB db 11
termC db 14
termD db 16

mesad db 0
mes db 128 dup('$')

prmes db 'Protocol: $'
dommes db 'Domain: $'
pathmes db 'Path: $'
querymes db 'Query: $'

errormes db 'Error: incorrect format$'
errormes2 db 'Error: there is no query$'
errormes3 db 'Error: there is no domain$'

newline db 0Ah, '$'

domain_was db 0
query_was db 0

buf db 4100 dup(0) ; memory for table
end start