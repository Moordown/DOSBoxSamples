include bmacro.asm
include macro.asm

model tiny
.386
.code
org 100h
start:

    lea dx, fname
    push dx
    call parse_file_from
    print_range <first_parsed, fp, open_newline>
    print_range <middle_parsed, mp, open_newline>
    print_range <last_parsed, lp, open_newline>
    exit


hello db 'file content: $'
open_newline db 0ah, '$'
fname db 'graph.txt', 00

include parser.asm

end start