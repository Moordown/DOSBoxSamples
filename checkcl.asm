model tiny
.386
.code
org 100h
start:
    call parse_command_line


current_max_entities dw 0
root_folder db '.', 00h
include clfunc.asm
end start