include macro.asm

model tiny
.386
.code
org 100h
start:
    call save_cwd
    mov cx, 0
    push cx
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
    ;
    ;   save current files
    ;
    call count_subfiles_here
    break_point <bx>

    pop bx
    pop cx ; deep level
    pop ax ; filemask offset
    push bx

    load <cx, ax>
    push cx
    call set_dta
    restore <ax, cx>

    mov bx, 0
    load <bx, cx>
    push ax
    call find_first
    jnc _list_subfiles_recursive_loop
    call find_first_error
    jmp _list_subfiles_recursive_end
_list_subfiles_recursive_loop:
    restore <cx, bx>
    inc bx
    load <bx, cx>
    push bx
    push cx
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
    mov ax, word ptr [current_max_entities]
    load <ax>
    ;
    ;   cd to subfolder
    ;
    load <cx>
    push cx
    call move_dta
    add ax, 1Eh

    push ax
    call cd
    restore <cx>

    inc cx
    ;
    ;   list subfiles from subfolder
    ;
    load <cx>
    mov ax, offset folder_mask
    push ax
    push cx
    call list_subfiles_recursive
    restore <cx>

    
    ;
    ;   list subfolders from subfolder
    ;
    load <cx>
    mov ax, offset file_mask
    push ax
    push cx
    call list_subfiles_recursive
    restore <cx>

    ;
    ;   cd back to this function
    ;
    mov ax, offset parent_folder
    push ax
    call cd

    break_point <ax>
    restore <ax>
    mov word ptr [current_max_entities], ax

    restore <cx>
    load <cx>
    push cx
    call set_dta
_list_subfiles_recursive_next:
    call find_next
    jnc _list_subfiles_recursive_loop
    cmp al, byte ptr [no_more_files]
    jne find_next_error
_list_subfiles_recursive_end:
    restore <cx, bx>
    ret
move_dta:
    pop bx
    pop cx
    push bx

    xor ax, ax
    mov al, byte ptr [dta_len]
    mul cx

    mov bx, offset dta
    add bx, ax
    mov ax, bx
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
    ret
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
    ;
    ; parse file extension
    ;
    inc si
    inc si
    mov di, offset file_ext
    mov cx, 4
    rep movsb
    jmp parse_args
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

is_valid_name:
    pop bx
    pop cx      ; deep level
    push bx
    
    push cx
    call move_dta
    
    add ax, 1Eh
    mov bx, ax
    mov ax, 1
    cmp byte ptr [bx], '.'
    jne _is_valid_name_end
    mov ax, 0
_is_valid_name_end:
    ret

show_filename_from_dta:
    pop bx
    pop cx  ; deep level 
    pop ax  ; entity count
    push bx

    load <ax, cx>
    push cx
    call is_valid_name
    cmp ax, 1
    je _show_filename_from_dta_valid_name
    restore <cx, ax>
    mov ax, 0
    ret
_show_filename_from_dta_valid_name:
    ;
    ;   pseudo graphic prefix
    ;
    restore <cx, ax>

    load <cx, bx>
    push ax     ; entity count
    push cx     ; deep level
    break_point <cx>
    call print_pseudographic_prefix
    restore <bx, cx>

    load <bx>
    mov cx, 13
    push cx
    push bx
    call count_no_space_no_zero_letters
    mov cx, ax
    restore <bx>
    ; mov ax, offset dta + 1Eh
    push cx
    push bx
    call print_string_with_length
    print_range <newline>
    mov ax, 1
    ret
print_pseudographic_prefix:
    pop bx
    pop cx      ; deep level
    pop ax      ; entity count
    push bx

    cmp cx, 0
    je _print_pseudographic_prefix_zero_level
    print_range <level_shift>
    dec cx
    cmp cx, 0
    je _print_pseudographic_prefix_zero_level
_print_pseudographic_prefix_loop:
    print_range <space>
    dec cx
    jnz _print_string_with_length_loop
_print_pseudographic_prefix_zero_level:
    cmp ax, word ptr [current_max_entities]
    je _print_pseudographic_prefix_zero_level_end
    cmp ax, 1
    je _print_pseudographic_prefix_zero_level_first
    jmp _print_pseudographic_prefix_zero_level_middle
_print_pseudographic_prefix_zero_level_first:
    print_range <first_file_char>
    jmp _print_pseudographic_prefix_end
_print_pseudographic_prefix_zero_level_middle:
    print_range <middle_file_char>
    jmp _print_pseudographic_prefix_end
_print_pseudographic_prefix_zero_level_end:
    print_range <end_file_char>
    jmp _print_pseudographic_prefix_end
_print_pseudographic_prefix_end:
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
    pop cx                      ; deep level
    push bx

    mov dx, offset dta
    load <dx>
    xor ax, ax
    mov al, byte ptr [dta_len]
    mul cx
    
    restore <dx>
    add dx, ax

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
count_subfiles_here:
    mov ax, offset file_mask
    push ax
    call count_subfiles_here_by_mask
    load <ax>
    mov ax, offset folder_mask
    push ax
    call count_subfiles_here_by_mask
    mov bx, ax
    restore <ax>
    add bx, ax
    mov ax, bx
    mov word ptr [current_max_entities], ax
    ret
count_subfiles_here_by_mask:
    pop bx
    pop ax              ; mask address
    push bx

    load <ax>
    mov cx, 11          ; set pointer to count_dta 
    push cx
    call set_dta
    restore <ax>

    mov cx, 0
    load <cx>
    push ax
    call find_first
    jc _count_subfiles_from_end
_count_subfiles_from_loop:
    mov cx, 11
    push cx
    call move_dta
    add ax, 1Eh
    mov bx, ax
    cmp byte ptr [bx], '.' 
    je _count_subfiles_from_loop_next 
    
    restore <cx>
    inc cx
    load <cx> 
_count_subfiles_from_loop_next:
    call find_next
    jc _count_subfiles_from_end
    
    jmp _count_subfiles_from_loop
_count_subfiles_from_end:
    restore <cx>
    mov ax, cx
    ret
;
; error codes
;
no_more_files db 18
dta_len db 2bh
;
; error messages
;
cd_fails db 'Change directory fails.$'
find_first_fails db 'find_first filenames fails.$'
find_next_fails db  'find_next filenames fails.$'
;
; int variables
;
current_max_entities dw 0
;
;   parse arguments
;
deep_level db 1
file_mask db '*'
file_ext db '.*', 00h, 00h, 00h
folder_mask db '*', 00h
all_files db '*.*', 00h
;
;   pseudographic
;
level_shift db '|', '$'
space db, ' ', '$'

zero_first_file db 195, '$'
zero_end_file db 192, '$'

first_file_char db 192, '$'
middle_file_char db 195, '$'
end_file_char db 194, '$'
;
; strings
;
parent_folder db '..', 00h
working_folder db 64 dup(00h)
root_folder db 64 dup(00h)
start_mask db 64 dup(00h)
newline db 0Ah, '$'
dta db 4300 dup(0)
count_dta db 43 dup(0)
end start