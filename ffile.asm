read_from_file:
    pop ax
    pop bx ; file handler
    pop cx ; read count
    pop dx ; buffer for writing
    push ax

    mov ah, 3fh
    int 21h
    jnc _read_form_file_end
    cmp ax, 5
    je ll5
    cmp ax, 6
    je ll6
    jmp _read_form_file_end
ll5:
    print_range <read_err_5, file_newline>
    jmp _read_form_file_end
ll6:
    print_range <read_err_6, file_newline>
    jmp _read_form_file_end
_read_form_file_end:
    ret

close_file:
    pop ax
    pop bx ; file handler
    push ax
    mov ah, 3eh
    int 21h
    jnc _close_file_end
    print_range <close_err_6, file_newline> 
_close_file_end:
    ret

open_read:
    pop bx
    pop dx ; filename pointer
    push bx
    mov ah, 3Dh
    mov al, 0
    int 21h
    jnc _open_read_end
    cmp ax, 1
    je l1
    cmp ax, 2
    je l2
    cmp ax, 3
    je l3
    cmp ax, 4
    je l4
    cmp ax, 5
    je l5
    cmp ax, 12
    je l12
    jmp _open_read_end
l1:
    print_range <open_err_1, file_newline>
    jmp _open_read_end
l2:
    print_range <open_err_2, file_newline>
    jmp _open_read_end
l3:
    print_range <open_err_3, file_newline>
    jmp _open_read_end
l4:
    print_range <open_err_4, file_newline>
    jmp _open_read_end
l5:
    print_range <open_err_5, file_newline>
    jmp _open_read_end
l12:
    print_range <open_err_12, file_newline>
    jmp _open_read_end

_open_read_end:
    ret
;
; error codes
;
open_err_1 db 'function number invalid$'
open_err_2 db 'file not found$'
open_err_3 db 'path not found$'
open_err_4 db 'no handle avaiable$'
open_err_5 db 'access denied$'
open_err_12 db 'open mode invalid$'

close_err_6 db 'invalid handle$'

read_err_5 db 'access denied$'
read_err_6 db 'invalid handle$'
;
; constants
;
file_newline db 0ah, '$'