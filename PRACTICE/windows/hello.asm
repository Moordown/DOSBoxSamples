option casemap:none
extern GetStdHandler : proc
extern WriteFile : proc
extern ExitProcess : proc

.data
messg db 0dh, 0ah, 'Hello, WinAsm!', 0dh, 0ah, 0
lmessg dd $ - messg

.code
_start proc
    mov ecx, -11
    call GetStdHandler      ; стек на 16 выравнивать не надо, она не использует 4 слова в стеке
    test eax, eax
    jz error1
;
    mov rcx, rax
    lea rdx, messg
    mov r8d, lmessg
    lea r9, lmessg
    push 0
    sub rsp, 32
    call WriteFile
    add rsp, 40
    test eax, eax
    jz error2

    mov ecx, 0
_exit:
    call ExitProcess
error1:
    mov ecx, 1
    jmp _exit
error2:
    mov ecx, 2
    jmp _exit
_start endp
