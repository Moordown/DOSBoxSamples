include tmacro.asm

model tiny
.386
.code
org 100h
start:
    call save_cwd
    mov ax, 0
    push ax
    push ax
    call set_dword
    set_dta dta
    call parse_command_line
    ;
    ;   start tree 
    ;
    mov ax, offset root_folder
    mov cx, 0
    push cx
    push ax
    call list_subfiles_recursive_from
    ;
    ;   cd to start folder
    ;
    mov ax, offset working_folder
    push ax
    call cd
    exit

include dtafunc.asm

end start