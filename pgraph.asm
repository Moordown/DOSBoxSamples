
print_pseudographic_prefix:
    pop bx
    pop cx      ; deep level
    pop ax      ; entity count
    push bx

    cmp cx, 0
    je _print_pseudographic_prefix_zero_level
    load <cx, ax>
    mov ax, offset level_shift
    
    push cx
    push ax
    call print_string_with_length
    restore <ax, cx>
_print_pseudographic_prefix_zero_level:

    mov bx, word ptr [current_max_entities]
    cmp al, bl
    je _print_pseudographic_prefix_zero_level_end
    cmp ax, 1
    jne _print_pseudographic_prefix_zero_level_middle
    cmp cx, 0
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

set_level_shift:
    pop bx
    pop cx  ; line level
    push bx

    lea bx, level_shift
    add bx, cx
    mov al, byte ptr [space]
    mov byte ptr [bx], al

    mov ax, 1

    ret

reset_level_shift:
    pop bx
    pop cx  ; line level
    push bx

    lea bx, level_shift
    add bx, cx
    mov al, byte ptr [old_level_shift]
    mov byte ptr [bx], al

    mov ax, 1
    
    ret

;
;   pseudographic
;
old_level_shift db 179, '$'
level_shift db 10 dup(179), '$'
space db, 32, '$'

zero_first_file db 195, '$'
zero_end_file db 192, '$'

first_file_char db 194, '$'
middle_file_char db 195, '$'
end_file_char db 192, '$'
