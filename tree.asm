include macrotree.asm

model tiny
.386
.code
org 100h
start:
    get_dta ; ES:BX
    mov word ptr [fcb], bx
    parse_filename filename
    cmp al, byte ptr [fails_code]
    jne end
error:
    print_range <parse_fails, new_line>
    jmp end
end:
    exit

fcb dw addr
fails_code db ffh
parse_fails db 'Parse fails', '$'
new_line db 0Ah, '$'
filename db '*'
end start