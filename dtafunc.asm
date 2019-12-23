include filefunc.asm
include clfunc.asm
include pgraph.asm
include tmacro.asm
include time.asm
include fdwcalc.asm

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
    print_range <time_space, datetime>
    ret

show_storage:
    ;
    ; print without padding
    ;
    mov dx, 0
    push dx

    ;
    ; memory for storing integer 
    ;
    lea dx, storage
    push dx

    ;
    ; move low 16 bit as integer to printing integer
    ;
    lea bx, dta
    add bx, 1Ah
    push bx
    call dadd_from
    call get_dword
    pop ax
    pop bx
    push ax

    call store_iint_to_string
    print_range <time_space, storage>
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

load_accumulative_storage:
    pop bx
    pop ax
    mov word ptr [accumulative_storage], ax
    pop ax
    mov word ptr [accumulative_storage + 2], ax
    push bx
    ret

set_accumulative_storage_from_dir:
    ;
    ; this function suppose that we count subfiles sizes from current directory
    ;

    ret

accumulative_storage dd 0
storage db 64 dup('$')
count_dta db 128 dup(0)
dta db 128 dup(0)
current_max_entities dw 0
