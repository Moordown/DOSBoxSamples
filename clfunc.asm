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
    inc si
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

;
;   parse arguments
;
deep_level db 1
file_mask db '*'
file_ext db '.*', 00h, 00h, 00h
folder_mask db '*', 00h
all_files db '*.*', 00h