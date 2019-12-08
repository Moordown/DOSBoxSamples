include macro.asm

model tiny
.386
.code
org 100h
start:
    call save_cwd
    mov ax, offset dta
    push ax
    call set_dta
    call parse_command_line
    
    ;
    ;   start tree 
    ;
    mov ax, offset root_folder
    mov cx, 0
    push cx
    push ax
    call list_subfiles_recursive_from

    ;
    ;   cd to start folder
    ;
    mov ax, offset working_folder
    push ax
    call cd
    exit

list_subfiles_recursive_from:
    pop bx      ; ret address
    pop ax      ; deep level
    pop cx      ; root folder offset
    push bx
    load <cx>     
    push ax
    call cd
    restore <cx>

    ;
    ; list subfolder
    ;
    mov ax, offset folder_mask
    load <cx>
    push ax
    push cx
    call list_subfiles_recursive
    restore <cx>

    ;
    ; list files
    ;
    mov ax, offset file_mask
    load <cx>
    push ax
    push cx
    call list_subfiles_recursive
    restore <cx>
    ret

list_subfiles_recursive:
    pop bx
    pop cx ; deep level
    pop ax ; filemask offset
    push bx
    ; mov ax, offset file_mask
    load <cx>
    push ax
    call find_first
    jc find_first_error
_list_subfiles_recursive_loop:
    call show_filename_from_dta
    cmp ax, 1
    jne _list_subfiles_recursive_next 
    
    ;
    ;   check if folder
    ;
    call is_folder
    cmp ax, 1
    jne _list_subfiles_recursive_next

    ;
    ;   check deep level
    ;
    restore <cx>
    load <cx>
    xor bx, bx
    mov bl, byte ptr [deep_level]
    cmp cx, bx
    jge _list_subfiles_recursive_next

    ;
    ; start new search
    ;

    ;
    ;   cd to subfolder
    ;
    load <cx>
    mov ax, offset dta + 1Eh
    push ax
    call cd
    restore <cx>

    ;
    ;   list subfiles from subfolder
    ;
    inc cx
    mov ax, offset file_mask
    push ax
    push cx
    call list_subfiles_recursive

    ;
    ;   cd to this function
    ;
    mov ax, offset parent_folder
    push ax
    call cd

_list_subfiles_recursive_next:
    call find_next
    jnc _list_subfiles_recursive_loop
    cmp al, byte ptr [no_more_files]
    jne find_next_error
_list_subfiles_recursive_end:
    restore <cx>
    ret

is_folder:
    mov bx, offset dta + 15h
    mov bl, byte ptr [bx]
    cmp bl, 10h
    je _is_folder_true
    jne _is_folder_false
_is_folder_true:
    mov ax, 1
    jmp _is_folder_end
_is_folder_false:
    mov ax, 0
    jmp _is_folder_end
_is_folder_end:
    ret



find_first_error:
    print_range <find_first_fails, newline>
    exit
find_next_error:
    print_range <find_next_fails, newline>
    exit

parse_command_line:
    ;
    ; prepare root folder
    ;
    mov si, 82h
    mov cx, 64
    push cx
    push si
    call count_no_space_no_zero_letters
    mov cx, ax
    mov si, 82h
    mov di, offset root_folder
    rep movsb

parse_args:
    inc si
    inc si
    cmp byte ptr [si], 'd'
    je parse_d
    cmp byte ptr [si], 'f'
    je parse_f
    jmp parse_end
parse_d:
    ;
    ; parse_deep level
    ;
    inc si
    inc si
    mov bl, byte ptr [si]
    sub bl, 30h             ; to number
    mov byte ptr [deep_level], bl
    jmp parse_args
parse_f:
    inc si
    inc si
    mov di, offset file_ext
    mov cx, 4
    rep movsb
    jmp parse_args
    ;
    ; parse file extension
    ;
parse_end:
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
    mov bx, offset dta + 1Eh
    cmp byte ptr [bx], '.'
    jne show_filename_from_dta_valid_name
    mov ax, 0
    ret
show_filename_from_dta_valid_name:
    mov cx, 13
    push cx
    push bx
    call count_no_space_no_zero_letters
    mov cx, ax
    mov ax, offset dta + 1Eh
    push cx
    push ax
    call print_string_with_length
    print_range <newline>
    mov ax, 1
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
    mov si, offset working_folder

    ;
    ; save driver
    ;
    mov ah, 19h                 ; GET CURRENT DEFAULT DRIVE
    int 21h
    mov dl, al
    add dl, 41h
    mov byte ptr [si], dl
    inc si
    mov byte ptr [si], ':'
    inc si
    mov byte ptr [si], '\'
    inc si

    ;
    ; save folder
    ;
    xor dl, dl                  ; Actual drive
    mov ah, 47h                 ; CWD - GET CURRENT DIRECTORY
    int 21h
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
;   parse arguments
;
deep_level db 1
file_mask db '*'
file_ext db '.*', 00h, 00h, 00h
folder_mask db '*', 00h
;
; strings
;
parent_folder db '..', 00h
working_folder db 64 dup(00h)
root_folder db 64 dup(00h)
start_mask db 64 dup(00h)
dta db 43 dup(0)
newline db 0Ah, '$'
end start