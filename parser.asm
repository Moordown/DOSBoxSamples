include macro.asm
include ffile.asm

parse_file_from:
    call create_first_transition_table
    call create_middle_transition_table
    call create_last_transition_table
    call create_level_shift_transition_table
    call create_space_transition_table

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
    print_range <parse_error, parse_newline>
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
    jne _parse_file_next_terminal_3
    mov al, byte ptr [buf]
    mov byte ptr [lp], al
    ; print_range <last_parsed, buf, open_newline>
    jmp _parse_file_loop
_parse_file_next_terminal_3:
    cmp al, byte ptr [level_shift_terminal]
    jne _parse_file_next_terminal_4
    mov al, byte ptr [buf]
    mov byte ptr [lhp], al
    ; print_range <last_parsed, buf, open_newline>
    jmp _parse_file_loop
_parse_file_next_terminal_4:
    cmp al, byte ptr [space_terminal]
    jne _parse_file_loop
    mov al, byte ptr [buf]
    mov byte ptr [spac], al
    ; print_range <last_parsed, buf, open_newline>
    jmp _parse_file_loop
    
_parse_file_ext:
    restore <bx>
    ret

create_first_transition_table:
    set_transition transition_table 0 1 'f'
    set_transition transition_table 1 2 ':'
    set_transition transition_table 2 3 ' '
    set_transition_for_all transition_table 3 4
    set_transition transition_table 4 0 0ah
    ret

create_middle_transition_table:
    set_transition transition_table 0 5 'm'
    set_transition transition_table 5 6 ':'
    set_transition transition_table 6 7 ' '
    set_transition_for_all transition_table 7 8
    set_transition transition_table 8 0 0ah
    ret

create_last_transition_table:
    set_transition transition_table 0 9 'l'
    set_transition transition_table 9 10 ':'
    set_transition transition_table 10 11 ' '
    set_transition_for_all transition_table 11 12
    set_transition transition_table 12 0 0ah
    ret

create_level_shift_transition_table:
    set_transition transition_table 9 14 'h'
    set_transition transition_table 14 15 ':'
    set_transition transition_table 15 16 ' '
    set_transition_for_all transition_table 16 17
    set_transition transition_table 17 0 0ah
    ret

create_space_transition_table:
    set_transition transition_table 0 18 's'
    set_transition transition_table 18 19 ':'
    set_transition transition_table 19 20 ' '
    set_transition_for_all transition_table 20 21
    set_transition transition_table 21 0 0ah
    ret




;
; errors
;
parse_error db 'parse error: incorrect format$'

;
; terminal states
;
first_terminal db 4
middle_terminal db 8
last_terminal db 12
level_shift_terminal db 17
space_terminal db 21

;
; info messages
;
first_parsed db 'first parsed: $'
middle_parsed db 'middle parsed: $'
last_parsed db 'last parsed: $'
level_shift_parsed db 'level shift parsed: $'
parse_newline db 0ah, '$'

;
; parsed symbols
;
fp db 194, '$'
mp db 195, '$'
lp db 192, '$'
lhp db 179, '$'
spac db 32, '$'

state db 0
buf db '$$'
transition_table db 5610 dup(0)