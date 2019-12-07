include macro.asm

model tiny
.386
.code
org 100h
start:
    mov ax, offset dta
    push ax
    call set_dta
    call parse_command_line
    ; call copy_root_from_comand_line
    mov ax, offset file_mask
    push ax
    call find_first
    jc find_first_error
find_loop:
    call show_filename_from_dta
    call find_next
    jnc find_loop
    cmp al, byte ptr [no_more_files]
    jne find_next_error
    exit

find_first_error:
    print_range <find_first_fails, newline>
    exit
find_next_error:
    print_range <find_next_fails, newline>
    exit
parse_command_line:
    ret
find_next:
    mov ah, 4Fh
    int 21h

    ret

find_first:
    pop bx
    pop dx              ; filename spec
    mov cx, 10h         ; include directories
    push bx

    xor ax, ax
    mov ah, 4Eh
    int 21h
    ret
show_filename_from_dta:
    mov ax, offset dta + 1Eh
    mov cx, 13
    push cx
    push ax
    call count_no_space_no_zero_letters
    mov cx, ax
    mov ax, offset dta + 1Eh
    push cx
    push ax
    call print_string_with_length
    print_range <newline>
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
    ret

set_dta:
    pop bx
    pop dx                      ; dta address offset
    push bx

    xor ax, ax 
    mov ah, 1Ah
    int 21h
    
    ret

save_cwd:
    pop bx
    pop si
    push bx

    xor dl, dl                  ; Actual drive
    mov ah, 47h                 ; CWD - GET CURRENT DIRECTORY
    int 21h
    ret
copy_root_from_comand_line:
    ;
    ;   copy root folder 
    ;
    xor ax, ax
    mov si, 80h
    mov al, byte ptr [si]
    dec ax                  ; remove last 0Dh byte

    mov di, offset start_mask
    mov si, 82h             ; start non space root dir
    xor cx, cx
    mov cl, al
    cld
    rep movsb

    ;
    ;   add mask for search to path
    ;
    mov ax, offset start_mask
    mov cx, 13
    push cx
    push ax
    call count_no_space_no_zero_letters
    mov si, offset start_mask
    add si, ax
    mov di, offset file_mask
    mov cx, 5
    rep movsb

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
count_no_space_no_zero_letters:
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
    cmp byte ptr [si], 00h
    je _count_non_space_symbols_end
    cmp ax, cx
    je _count_non_space_symbols_end
    inc ax
    inc si
    jmp _count_non_space_symbols_loop 
_count_non_space_symbols_end:
    ret
;
; error codes
;
no_more_files db 18
;
; error messages
;
cd_fails db 'Change directory fails.$'
find_first_fails db 'find_first filenames fails.$'
find_next_fails db  'find_next filenames fails.$'
;
; strings
;
start_mask db 64 dup(00h)
file_mask db '*.'
file_ext db 'asm', 00h

newline db 0Ah, '$'
dta db 48 dup(0)
end start