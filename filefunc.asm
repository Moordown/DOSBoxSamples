find_first_file:
    pop bx
    pop dx             ; filename spec
    mov cx, 0fh         ; include files
    push bx

    xor ax, ax
    mov ah, 4Eh
    int 21h
    ret

find_first_folder:
    pop bx
    pop dx              ; filename spec
    mov cx, 10h         ; include directories
    push bx

    xor ax, ax
    mov ah, 4Eh
    int 21h
    ret

find_next:
    mov ah, 4Fh
    int 21h

    ret

is_folder:
    pop bx
    pop cx
    pop ax ; dta address
    push bx

    add ax, 15h
    mov bx, ax
    mov bl, byte ptr [bx]
    and bl, 10h
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

cd:
    pop bx ; ret addr
    pop dx ; root address
    push bx ; ret addr

    load <dx>
    xor ax, ax
    mov ah, 3Bh
    int 21h

    jc cd_error
    restore <dx>
    ret
cd_error:
    print_range <cd_fails, newline>
    restore <dx>
    
	mov ah, 09h
    int 21h

    print_range <newline>
    exit
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


working_folder db 64 dup(00h)
cd_fails db 'Change directory fails.$'
newline db 0Ah, '$'