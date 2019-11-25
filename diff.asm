include macro.asm

model tiny
.386
.code
org 100h
start:
    mov si, 80h
    skipnospace
    read_name si, fname1
    print fname1
fname1 db 128 dup("$")
fname2 db 128 dup("$")
end start