include bmacro.asm
include pnum.asm

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
    parse_word_to_str dx, si, 4
    restore <si, dx, cx>
    break_point ax
    add si, 4
    mov byte ptr [si], '.'
    inc si

    load <cx, dx, si>
    and dx, 32 + 64 + 128 + 256 
    sar dx, 5
    parse_byte_to_str dl, si, 2
    restore <si, dx, cx>
    add si, 2
    mov byte ptr [si], '.'
    inc si

    load <cx, dx, si>
    and dl, 1 + 2 + 4 + 8 + 16
    parse_byte_to_str dl, si, 2
    restore <si, dx, cx>
    add si, 2
    mov byte ptr [si], ' '
    inc si

    ;
    ; time format
    ;
    load <cx, dx, si>
    sar cx, 11
    parse_byte_to_str cl, si, 2
    restore <si, dx, cx>
    add si, 2
    mov byte ptr [si], ':'
    inc si

    load <cx, dx, si>
    and cx, 2016
    sar cx, 5
    parse_byte_to_str cl, si, 2
    restore <si, dx, cx>
    add si, 2
    mov byte ptr [si], ':'
    inc si

    load <cx, dx, si>
    and cl, 15
    sal cl, 1
    parse_byte_to_str cl, si, 2
    restore <si, dx, cx>
    add si, 2
    mov byte ptr [si], '$'
    inc si

    ret

hello_time db 'Current time is: $'
hello_date db 'Current date is: $'
datetime db 20 dup('$')
time_semicolon db ':', '$'
time_space db ' ', '$'
time_newline db 0Ah, '$'
num db 128 dup('$')