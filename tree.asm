include tmacro.asm

model tiny
.386
.code
org 100h
start:
    call save_cwd
    set_dta dta
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
    mov si, offset find_first_folder
    mov bx, 0
    mov ax, offset folder_mask
    load <cx>
    push si
    push bx
    push ax
    push cx
    call list_subfiles_recursive
    restore <cx>
    ;
    ; list files
    ;
    mov si, offset find_first_file
    mov bx, ax
    mov ax, offset file_mask
    load <cx>
    push si
    push bx
    push ax
    push cx
    call list_subfiles_recursive
    restore <cx>
    ret

list_subfiles_recursive:
    ;
    ;   save current files count
    ;
    call count_subfiles_here
    mov word ptr [current_max_entities], ax

    pop dx
    pop cx ; deep level
    pop ax ; filemask offset
    pop bx ; current index
    pop si ; search address
    push dx

    load <cx, ax, bx, si>
    set_dta dta
    restore <si, bx, ax, cx>

    load <bx, cx>
    push ax
    call si
    jnc _list_subfiles_recursive_loop
    jmp _list_subfiles_recursive_end
_list_subfiles_recursive_loop:
    restore <cx>
    push cx
    call is_valid_name
    load <cx>
    cmp ax, 1
    jne _list_subfiles_recursive_next
    ;
    ;   increment current index in subfiles
    ;
    restore <cx, bx>
    inc bx
    load <bx, cx>
    push bx
    push cx
    call show_filename_from_dta
    ;
    ;   check if folder
    ;
    restore <cx>
    load <cx>
    lea ax, dta
    push ax
    push cx
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
    ;   pseudographic hack
    ;
    restore <cx, bx>
    load <bx, cx>

    cmp bx, word ptr [current_max_entities]
    jne _list_subfiles_recursive_loop_pseudographic_hack_end
    load <ax, bx, cx>
    push cx
    call set_level_shift
    restore <cx, bx, ax>

_list_subfiles_recursive_loop_pseudographic_hack_end:
    mov ax, cx
    ;
    ;   save dta
    ;
    push_fragment dta, 128
    mov cx, ax
    ;
    ; start new search
    ;
    mov ax, word ptr [current_max_entities]
    load <ax>

    load <cx>
    ;
    ;   cd to subfolder
    ;
    lea ax, dta
    add ax, 1Eh

    push ax
    call cd
    restore <cx>

    inc cx
    ;
    ;   list subfiles from subfolder
    ;
    load <cx>
    mov bx, 0
    mov ax, offset file_mask
    mov si, offset find_first_file
    
    push si
    push bx
    push ax
    push cx
    call list_subfiles_recursive
    restore <cx>
    ;
    ;   list subfolders from subfolder
    ;
    load <cx>
    mov bx, ax
    mov ax, offset folder_mask
    mov si, offset find_first_folder
    
    push si
    push bx
    push ax
    push cx
    call list_subfiles_recursive
    restore <cx>
    ;
    ;   reverse pseudographic hack
    ;
    load <ax, bx, cx>
    push cx
    call reset_level_shift
    restore <cx, bx, ax>
    ;
    ;   cd back to this function
    ;
    mov ax, offset parent_folder
    push ax
    call cd

    restore <ax>
    mov word ptr [current_max_entities], ax
    ;
    ;   restore dta
    ;
    pop_fragment dta, 128
    set_dta dta
_list_subfiles_recursive_next:
    call find_next
    jnc _list_subfiles_recursive_loop
    cmp al, byte ptr [no_more_files]
    jne find_next_error
_list_subfiles_recursive_end:
    restore <cx, bx>
    mov ax, bx
    ret
find_first_error:
    print_range <find_first_fails, newline>
    ret
find_next_error:
    print_range <find_next_fails, newline>
    exit

include dtafunc.asm

;
; error codes
;
no_more_files db 18

;
; error messages
;
find_first_fails db 'find_first filenames fails.$'
find_next_fails db  'find_next filenames fails.$'

;
; int variables
;
current_id_entity dw 0


;
; strings
;
parent_folder db '..', 00h
root_folder db 64 dup(00h)
end start