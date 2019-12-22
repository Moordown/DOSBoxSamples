include bmacro.asm

; model tiny
; .386
; .code
; org 100h


; start:
;     mov cx, 31296
;     mov dx, 20374
;     push dx
;     push cx
;     call print_datetimestamp

;     print_range <datetime, time_newline>
;     exit

print_datetimestamp:
    pop bx
    pop cx ; time
    pop dx ; date
    push bx

    lea si, datetime

    ;
    ; date format
    ;
    load <cx, dx, si>
    sar dx, 9
    add dx, 1980
    parse_word_to_str dx, si
    restore <si, dx, cx>
    break_point ax
    add si, 4
    mov byte ptr [si], ':'
    inc si

    load <cx, dx, si>
    and dx, 32 + 64 + 128 + 256 
    sar dx, 5
    parse_byte_to_str dl, si
    restore <si, dx, cx>
    add si, 2
    mov byte ptr [si], ':'
    inc si

    load <cx, dx, si>
    and dl, 1 + 2 + 4 + 8 + 16
    parse_byte_to_str dl, si
    restore <si, dx, cx>
    add si, 2
    mov byte ptr [si], ' '
    inc si

    ;
    ; time format
    ;
    load <cx, dx, si>
    sar cx, 11
    parse_byte_to_str cl, si
    restore <si, dx, cx>
    add si, 2
    mov byte ptr [si], ':'
    inc si

    load <cx, dx, si>
    and cx, 2016
    sar cx, 5
    parse_byte_to_str cl, si
    restore <si, dx, cx>
    add si, 2
    mov byte ptr [si], ':'
    inc si

    load <cx, dx, si>
    and cl, 15
    sal cl, 1
    parse_byte_to_str cl, si
    restore <si, dx, cx>
    add si, 2
    mov byte ptr [si], '$'
    inc si

    ret

store_iint_to_string:
    pop bx
    pop ax ; integer
    pop si ; memory for integer storage
    push bx

    mov cx, 0
    mov bx, 10
_store_iint_to_string_direct:
    cmp ax, 0
    je _store_iint_to_string_leading_zeros
    
    xor dx, dx
    div bx
    push dx
    inc cx

    jmp _store_iint_to_string_direct

_store_iint_to_string_leading_zeros:
    cmp cx, 0
    jne _store_iint_to_string_leading_zeros_start
    mov bx, 0
    push bx
    inc cx
_store_iint_to_string_leading_zeros_start:
    load <cx>
    and cx, 1
    cmp cx, 0
    restore <cx>
    je _store_iint_to_string_inverse
    inc cx
    mov bx, 0
    push bx
    jmp _store_iint_to_string_leading_zeros_start
_store_iint_to_string_inverse:
    load <si>
    add si, cx
    mov byte ptr [si], '$'
    restore <si>
_store_iint_to_string_inverse_loop:
    cmp cx, 0
    je _store_iint_to_string_end
    
    pop dx
    add dl, 30h
    mov byte ptr [si], dl
    inc si
    dec cx

    jmp _store_iint_to_string_inverse_loop

_store_iint_to_string_end:
    ret

hello_time db 'Current time is: $'
hello_date db 'Current date is: $'
datetime db 20 dup('$')
time_semicolon db ':', '$'
time_space db ' ', '$'
time_newline db 0Ah, '$'
num db 128 dup('$')

; end start