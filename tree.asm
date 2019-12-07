include tmacro.asm

model tiny
.386
.code
org 100h
start:
    call save_drive
    call save_cwd
    call parse_root_from_command_line
    push ax
    call cd
    cmp al, 3
    je cd_error
    ; mcwd 3, cwd_name
    set_dta fcb
    parse_filename fcb, filename
    cmp al, byte ptr [parse_filename_function_falls]
    je parsing_error
    cmp al, byte ptr [parse_filename_function_with_wildcards]
    je parsing_wildcards
parse_root_from_command_line:
    mov si, 80h
    mov cx, 64
    push cx
    push si
    call count_letters_from_command_line
    add ax, 80h
    push ax
    call skip_spaces
    mov word ptr [root_addr], ax ; root addr here
    mov cx, 64
    push cx
    push ax
    call count_letters_from_command_line
    add ax, word ptr root_addr
    mov bx, ax
    mov byte ptr [bx], 00h ; set end of root 
    mov ax, root_addr
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
program_end:
    mov ax, offset cwd_full_name
    push ax
    call cd
    exit
print_fname_from_fcb:
    ;
    ; fname
    ;
    mov bx, offset fcb + 01h
    mov cx, 8
    push cx
    push bx
    call count_letters_from_command_line
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
    call count_letters_from_command_line
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
skip_spaces:
    xor ax, ax
    pop bx ; ret addr
    pop si ; str addr
    push bx ; ret addr
_skip_spaces_loop:
    cmp byte ptr [si], 20h
    jne _skip_spaces_end
    inc si
    jmp _skip_spaces_loop
_skip_spaces_end:
    mov ax, si
    ret
count_letters_from_command_line:
    pop bx ; ret address
    pop si ; string offset
    pop cx ; string length
    push bx ; ret address
    mov ax, 0
_count_non_space_symbols_loop:    
    cmp byte ptr [si], 20h
    je _count_non_space_symbols_end
    cmp byte ptr [si], 0Dh
    je _count_non_space_symbols_end
    cmp ax, cx
    je _count_non_space_symbols_end
    inc ax
    inc si
    jmp _count_non_space_symbols_loop 
_count_non_space_symbols_end:
    ret

cd:
    pop bx ; ret addr
    pop dx ; root address
    push bx ; ret addr

    xor ax, ax
    mov ah, 3Bh
    int 21h

    jc cd_error
    ret
cd_error:
    print_range <cd_fails, newline>
    exit
save_cwd:
    mov si, offset cwd_dir_name
    xor dl, dl                  ; Actual drive
    mov ah, 47h                 ; CWD - GET CURRENT DIRECTORY
    int 21h
    ret
save_drive:
    mov ah, 19h                 ; GET CURRENT DEFAULT DRIVE
    int 21h
    
    mov dl, al
    add dl, 41h                 ; SAVE AS CHARACTER

    mov byte ptr [cwd_full_name], dl
    ret

parse_filename_function_falls db 127
parse_filename_function_no_wildcards db 00h
parse_filename_function_with_wildcards db 01h

parse_iter_filename_found_code db 00h
parse_iter_no_filename_found_code db 127

parse_fails db 'Parse fails.$'
cd_fails db 'Change directory fails.$'
newline db 0Ah, '$'
dot db '.', '$'
filename db '*.*'
root_addr dw 0
cwd_full_name db 'c:\'
cwd_dir_name db 64 dup(00h) 
fcb db 128 dup(00h)
end start