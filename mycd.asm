include tmacro.asm

model tiny
.386
.code
org 100h
start:
    mov dx, offset root
    mov ah, 3Bh
    int 21h

    cmp al, 3
    jne l1
    print_range <error_with_cd, newline>
l1:    

    mov ah, 47h
    mov dl, 3
    mov si, offset current
    int 21h

    print_range <current, newline>

    mov ah, 00h
    int 21h
error_with_cd db 'Fails chande dirrectory$'
root db 'c:\test1\', 00h
current db 64 dup('$')
newline db 0Ah, '$'
end start