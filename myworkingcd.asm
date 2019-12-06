include tmacro.asm

model tiny
.386
.code
org 100h
start:
    call show_drive
    call show_cwd

    mov dx,offset _cd            ; DS:DX -> ASCIZ pathname to become current directory (max 64 bytes)
    mov ah,3Bh                  ; CHDIR - SET CURRENT DIRECTORY
    int 21h
    jc err_chdir
    call show_drive
    call show_cwd

    mov dx, offset dir          ; DS:DX -> ASCIZ pathname
    mov ah, 39h                 ; MKDIR - CREATE SUBDIRECTORY
    int 21h
    jc err_mkdir

    mov dx,offset dir           ; DS:DX -> ASCIZ pathname to become current directory 
    mov ah,3Bh                  ; CHDIR - SET CURRENT DIRECTORY
    int 21h
    jc err_chdir
    call show_cwd

    mov ax,4c00h
    int 21h

err_chdir:
    mov [temp], ax
    mov dx, OFFSET errchdir
    mov ah, 09h
    int 21h
    mov ax, [temp]
    mov dl, al
    or dl, 30h
    mov ah, 02
    int 21h
    mov ax,4c01h
    int 21h


err_mkdir:
    mov [temp], ax
    mov dx, OFFSET errmkdir
    mov ah, 09h
    int 21h

    mov ax, [temp]
    mov dl, al
    or dl, 30h
    mov ah, 02
    int 21h

    mov ax,4c02h
    int 21h

show_drive:
    mov ah, 19h                 ; GET CURRENT DEFAULT DRIVE
    int 21h
    mov dl, al
    add dl, 41h
    mov ah, 02h
    int 21h
    mov dl, ':'
    int 21h

    call crlf
    ret
show_cwd:
    mov si, OFFSET buf
    xor dl, dl                  ; Actual drive
    mov ah, 47h                 ; CWD - GET CURRENT DIRECTORY
    int 21h

    mov si, OFFSET buf          ; Print buf until '\0'
L1:
    lodsb
    test al, al
    jz L2
    mov dl, al
    mov ah, 02h
    int 21h
    jmp L1

L2:
    call crlf

    ret
crlf:
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    ret

temp dw ?
_cd db 'c:\test1\', 00h
dir db 'c:\test1\test2', 00h
buf db 64 DUP ('$')
errchdir db 'ERROR CHDIR $'
errmkdir db 'ERROR MKDIR $'
error_with_cd db 'Fails chande dirrectory$'
root db 'C:'
current db 64 dup('$')
newline db 0Ah, '$'
end start