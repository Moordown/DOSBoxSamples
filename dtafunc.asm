include filefunc.asm
include clfunc.asm
include pgraph.asm
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
    ; print_range <newline>
    
    lea bx, dta
    mov cx, word ptr [bx + 16h]
    mov dx, word ptr [bx + 18h]
    push dx
    push cx
    call print_datetimestamp
    print_range <time_space, datetime, time_newline> 
    
    mov ax, 1
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

count_dta db 128 dup(0)
dta db 128 dup(0)
current_max_entities dw 0
