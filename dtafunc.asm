
include filefunc.asm
include clfunc.asm
include tmacro.asm
include time.asm

count_subfiles_here:
    lea ax, file_mask
    lea si, find_first_file

    push ax
    push si
    call count_subfiles_here_by_mask
    load <ax>
    mov ax, offset folder_mask
    mov si, offset find_first_folder
    
    push ax
    push si
    call count_subfiles_here_by_mask
    mov bx, ax
    restore <ax>
    add bx, ax
    mov ax, bx
    mov word ptr [current_max_entities], ax
    ret

count_subfiles_here_by_mask:
    pop bx
    pop si              ; find_first address
    pop ax              ; mask address
    push bx

    load <ax, si>
    set_dta count_dta
    restore <si, ax>

    mov cx, 0
    load <cx>
    push ax
    call si
    jc _count_subfiles_from_end
_count_subfiles_from_loop:
    lea ax, count_dta
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

show_filename_from_dta:
    ;
    ; returns file storage
    ;
    pop bx
    pop cx  ; deep level 
    pop ax  ; entity count
    push bx

_show_filename_from_dta_valid_name:
    ;
    ;   pseudo graphic prefix
    ;
    load <ax>
    lea ax, dta
    
    add ax, 1Eh
    mov bx, ax
    restore <ax>

    load <cx, bx>
    push ax     ; entity count
    push cx     ; deep level
    call print_pseudographic_prefix
    restore <bx, cx>

    load <bx>
    mov cx, 13
    push cx
    push bx
    call count_no_space_no_zero_letters
    mov cx, ax
    restore <bx>
    push cx
    push bx
    call print_string_with_length
    
_show_filename_from_dta_datetime:
    mov al, 1
    cmp byte ptr [use_time], al
    jne _show_filename_from_dta_storage
    call show_datetime
    jmp _show_filename_from_dta_storage

_show_filename_from_dta_storage:
    mov al, 1
    cmp byte ptr [use_storage], al
    jne _show_filename_from_dta_end
    call show_storage
    jmp _show_filename_from_dta_end

 _show_filename_from_dta_end:   
    print_range <newline>
    mov ax, 1
    ret

show_datetime:
    lea bx, dta
    mov cx, word ptr [bx + 16h]
    mov dx, word ptr [bx + 18h]
    push dx
    push cx
    call print_datetimestamp
    print_range <time_space, datetime, time_space>
    ret

show_storage:
    ;
    ; print without padding
    ;
    mov dx, 1
    push dx

    ;
    ; memory for storing integer 
    ;
    lea dx, storage
    push dx

    ;
    ; move low 16 bit as integer to printing integer
    ;
    mov ax, word ptr [is_file]
    cmp ax, 0
    je _show_storage_folder
_show_storage_file:
    lea bx, dta
    add bx, 1Ah
    push bx
    jmp _print_storage
_show_storage_folder:
    lea ax, accumulative_storage
    push ax
    jmp _print_storage
_print_storage:
    call store_dword_to_string
    print_range <time_space, storage, time_space>
    ret

is_valid_name:
    pop bx
    pop cx      ; deep level
    push bx
    
    lea ax, dta
    add ax, 1Eh
    mov bx, ax
    mov ax, 1
    cmp byte ptr [bx], '.'
    jne _is_valid_name_end
    mov ax, 0
_is_valid_name_end:
    ret

add_accumulative_storage_from_dta:
    lea bx, dta
    add bx, 1Ah
    push bx
    call dadd_from
    call get_dword
    lea bx, accumulative_storage
    pop dx
    mov word ptr [bx], dx
    pop dx
    mov word ptr [bx + 2], dx

    ret

zeros_accumulative_storage:
    mov ax, 0
    mov word ptr [accumulative_storage], ax
    mov word ptr [accumulative_storage + 2], ax
    ret

zeros_dword:
    mov ax, 0
    push ax
    push ax
    call set_dword
    ret

set_accumulative_storage_from_dir:
    ;
    ; this function suppose that we count subfiles sizes from current directory
    ;
    call zeros_dword
    call zeros_accumulative_storage
    mov bx, 1
    mov word ptr [is_silent], bx
    mov word ptr [skip_storage_accumulating], bx
    ;
    ;   save dta
    ;
    push_fragment dta, 128
    ;
    ; start new search
    ;
    mov ax, word ptr [current_max_entities]
    load <ax>
    ;
    ;   cd to subfolder
    ;
    lea ax, dta
    add ax, 1Eh

    push ax
    call cd
    ;
    ;   list subfiles from subfolder
    ;
    mov bx, 0
    mov cx, 0
    mov ax, offset file_mask
    mov si, offset find_first_file
    
    push si
    push bx
    push ax
    push cx
    call list_subfiles_recursive
    ;
    ;   list subfolders from subfolder
    ;
    mov cx, 0
    mov bx, ax
    mov ax, offset folder_mask
    mov si, offset find_first_folder
    
    push si
    push bx
    push ax
    push cx
    call list_subfiles_recursive
    ;
    ;   cd back to this function
    ;
    mov ax, offset parent_folder
    push ax
    call cd

    restore<ax>
    mov word ptr [current_max_entities], ax
    ;
    ;   restore dta
    ;
    pop_fragment dta, 128
    set_dta dta

    mov bx, 0
    mov word ptr [is_silent], bx
    mov word ptr [skip_storage_accumulating], bx
    ret

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
    je _list_subfiles_recursive_folder

    call add_accumulative_storage_from_dta

    mov ax, word ptr [is_silent]
    cmp ax, 1
    je _list_subfiles_recursive_next

    mov bx, 1
    mov word ptr [is_file], bx
    ;
    ;   show filename 
    ;
    restore <cx, bx>
    load <bx, cx>
    push bx
    push cx
    call show_filename_from_dta

    mov bx, 0
    mov word ptr [is_file], bx

    jmp _list_subfiles_recursive_next
_list_subfiles_recursive_folder:
    mov ax, word ptr [skip_storage_accumulating]
    cmp ax, 1
    je _list_subfiles_recursive_folder_check_silence

    ;
    ;   count storages
    ;
    call set_accumulative_storage_from_dir
_list_subfiles_recursive_folder_check_silence:
    mov ax, word ptr [is_silent]
    cmp ax, 1
    je _list_subfiles_recursive_folder_serach_logic

    ;
    ;   show folder name
    ;
    restore <cx, bx>
    load <bx, cx>
    push bx
    push cx
    call show_filename_from_dta

    call zeros_dword
    call zeros_accumulative_storage

_list_subfiles_recursive_folder_serach_logic:

    ;
    ;   check deep level
    ;
    restore <cx>
    load <cx>
    xor bx, bx
    mov bl, byte ptr [deep_level]
    cmp cx, bx
    jge _list_subfiles_recursive_next
    
    restore <cx, bx>
    load <bx, cx>
    
    mov ax, word ptr [is_silent]
    cmp ax, 1
    je _list_subfiles_recursive_loop_pseudographic_hack_end
    ;
    ;   pseudographic hack
    ;
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

    mov ax, word ptr [is_silent]
    cmp ax, 1
    je list_subfiles_recursive_loop_cd_back
    ;
    ;   reverse pseudographic hack
    ;
    load <ax, bx, cx>
    push cx
    call reset_level_shift
    restore <cx, bx, ax>

list_subfiles_recursive_loop_cd_back:
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
current_folder db '.', 00h
root_folder db 64 dup(00h)

;
; mode variables
;
is_silent dw 0
is_file dw 0
skip_storage_accumulating dw 0

;
; storages
;
accumulative_storage dd 0
storage db 64 dup('$')
count_dta db 128 dup(0)
dta db 128 dup(0)
current_max_entities dw 
