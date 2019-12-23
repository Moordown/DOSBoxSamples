parse_file_from:
    call create_first_transition_table
    call create_middle_transition_table
    call create_last_transition_table

    pop bx  ; ret address
    pop dx  ; filename pointer
    push bx
    push dx
    call open_read
    jc ext
    load <ax>
    push ax
    call parse_file
    restore <ax>
    push ax
    call close_file
    jc ext
ext:
    ret

parse_file:
    pop bx
    pop ax ; file handler
    push bx

    load <ax>
_parse_file_loop:
    mov cx, 1
    lea dx, buf
    restore <ax>
    load <ax>
    push dx
    push cx
    push ax
    call read_from_file
    jc _parse_file_ext
    cmp ax, 0
    je _parse_file_ext
    xor dx, dx
    mov dl, byte ptr [buf]
    mov bl, byte ptr [state]
    get_transition transition_table, bl, dx
    cmp dl, 0
    jne _parse_file_next
    cmp al, 0
    jne _parse_file_next
    print_range <parse_error, open_newline>
    jmp _parse_file_ext 
_parse_file_next:
    mov byte ptr [state], al
    cmp al, byte ptr [first_terminal]
    jne _parse_file_next_terminal_1
    mov al, byte ptr [buf]
    mov byte ptr [fp], al
    ; print_range <first_parsed, buf, open_newline>
    jmp _parse_file_loop
_parse_file_next_terminal_1:
    cmp al, byte ptr [middle_terminal]
    jne _parse_file_next_terminal_2
    mov al, byte ptr [buf]
    mov byte ptr [mp], al
    ; print_range <middle_parsed, buf, open_newline>
    jmp _parse_file_loop
_parse_file_next_terminal_2:
    cmp al, byte ptr [last_terminal]
    jne _parse_file_loop
    mov al, byte ptr [buf]
    mov byte ptr [lp], al
    ; print_range <last_parsed, buf, open_newline>
    jmp _parse_file_loop
_parse_file_ext:
    restore <bx>
    ret

create_first_transition_table:
    set_transition transition_table 0 1 'f'
    set_transition transition_table 1 2 'i'
    set_transition transition_table 2 3 'r'
    set_transition transition_table 3 4 's'
    set_transition transition_table 4 5 't'
    set_transition transition_table 5 6 '_'
    set_transition transition_table 6 7 'm'
    set_transition transition_table 7 8 'e'
    set_transition transition_table 8 9 'm'
    set_transition transition_table 9 10 'b'
    set_transition transition_table 10 11 'e'
    set_transition transition_table 11 12 'r'
    set_transition transition_table 12 13 ':'
    set_transition transition_table 13 14 ' '
    set_transition_for_all transition_table 14 15
    set_transition transition_table 15 0 0ah
    ret

create_middle_transition_table:
    set_transition transition_table 0 16 'm'
    set_transition transition_table 16 17 'i'
    set_transition transition_table 17 18 'd'
    set_transition transition_table 18 19 'd'
    set_transition transition_table 19 20 'l'
    set_transition transition_table 20 21 'e'
    set_transition transition_table 21 22 '_'
    set_transition transition_table 22 23 'm'
    set_transition transition_table 23 24 'e'
    set_transition transition_table 24 25 'm'
    set_transition transition_table 25 26 'b'
    set_transition transition_table 26 27 'e'
    set_transition transition_table 27 28 'r'
    set_transition transition_table 28 29 ':'
    set_transition transition_table 29 30 ' '
    set_transition_for_all transition_table 30 31
    set_transition transition_table 31 0 0ah
    ret

create_last_transition_table:
    set_transition transition_table 0 32 'l'
    set_transition transition_table 32 33 'a'
    set_transition transition_table 33 34 's'
    set_transition transition_table 34 35 't'
    set_transition transition_table 35 36 '_'
    set_transition transition_table 36 37 'm'
    set_transition transition_table 37 38 'e'
    set_transition transition_table 38 39 'm'
    set_transition transition_table 39 40 'b'
    set_transition transition_table 40 41 'e'
    set_transition transition_table 41 42 'r'
    set_transition transition_table 42 43 ':'
    set_transition transition_table 43 44 ' '
    set_transition_for_all transition_table 44 45
    set_transition transition_table 45 0 0ah
    ret

include ffile.asm

;
; errors
;
parse_error db 'parse error: incorrect format$'

;
; terminal states
;
first_terminal db 15
middle_terminal db 31
last_terminal db 45

;
; info messages
;
first_parsed db 'first parsed: $'
middle_parsed db 'middle parsed: $'
last_parsed db 'last parsed: $'

;
; parsed symbols
;
fp db '$$'
mp db '$$'
lp db '$$'

state db 0
buf db '$$'
transition_table db 11475 dup(0)