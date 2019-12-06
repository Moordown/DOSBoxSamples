include tmacro.asm

model tiny
.386
.code
org 100h
start:
    set_dta fcb
    call parse_command_line
    mov si, word ptr [filename_addr] ; root address string
    push si
    call parse_filename
    cmp al, byte ptr [parse_filename_function_falls]
    je parsing_error
    cmp al, byte ptr [parse_filename_function_with_wildcards]
    je parsing_wildcards
parse_command_line:
    mov si, 80h
    mov cx, 10
    push cx
    push si
    call count_non_space_symbols_with_length
    add ax, 80h
    mov word ptr [filename_addr], ax
    ret
parsing_error:
    print_range <parse_fails, newline>
    jmp program_end
parsing_wildcards:
    parse_first fcb
parsing_wildcards_loop:
    cmp al, byte ptr [parse_iter_filename_found_code]
    jne program_end
    call print_fname_from_fcb
    parse_next fcb
    jmp parsing_wildcards_loop

print_fname_from_fcb:
    ;
    ; fname
    ;
    mov bx, offset fcb + 01h
    mov cx, 8
    push cx
    push bx
    call count_non_space_symbols_with_length
    mov bx, offset fcb + 01h
    push ax
    push bx
    call print_string_with_length

    print_range <dot>
    ;
    ; ext
    ;
    mov bx, offset fcb + 09h
    mov cx, 3
    push cx
    push bx
    call count_non_space_symbols_with_length
    mov bx, offset fcb + 09h
    push ax
    push bx
    call print_string_with_length
    print_range <newline>
    ret

print_string_with_length: 
    pop bx ; ret address
    pop si ; string offset
    pop cx ; string length
    push bx; ret address
    xor ax, ax
_print_string_with_length_loop:
    mov ah, 02h
    mov dl, byte ptr [si]
    int 21h
    dec cx
    inc si
    cmp cx, 00h
    je _print_string_with_length_end
    jmp _print_string_with_length_loop
_print_string_with_length_end:
    ret

count_non_space_symbols_with_length:
    pop bx ; ret address
    pop si ; string offset
    pop cx ; string length
    push bx ; ret address
    mov ax, 0
_count_non_space_symbols_loop:    
    cmp byte ptr [si], 20h
    je _count_non_space_symbols_end
    cmp ax, cx
    je _count_non_space_symbols_end
    inc ax
    inc si
    jmp _count_non_space_symbols_loop 
_count_non_space_symbols_end:
    ret
parse_filename:
    pop bx ; ret addr
    pop si ; filename offset
    push bx; ret addr
    xor ax, ax
    mov ah, 29h
    mov di, offset fcb

    int 21h
    ret
program_end:
    exit


parse_filename_function_falls db 127
parse_filename_function_no_wildcards db 00h
parse_filename_function_with_wildcards db 01h

parse_iter_filename_found_code db 00h
parse_iter_no_filename_found_code db 127

parse_fails db 'Parse fails.$'
newline db 0Ah, '$'
dot db '.', '$'
filename db '*.*'
filename_addr dw 0 
fcb db 128 dup(00h)
end start