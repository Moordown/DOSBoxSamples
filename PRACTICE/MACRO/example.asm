include macro.asm

model tiny
.386
.code
org 100h
start:
    pushes cx, bx, ax
    call Foo
    pops ax, bx, cx

    ret
Foo:
    mov ax, 42
    mov bx, 42
    mov ax, 42
msg db "Hello, DOS-BOX!$"
end start