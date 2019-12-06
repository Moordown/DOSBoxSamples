set_dta macro
    mov ah, 1Ah
    int 21h
endm

first_match macro
    mov ah, 11h

endm

parse_filename macro fname
    get_dta
    mov     di, bx
    mov     si, offset fname
    mov     ax, 2901h
    int 21h
endm

get_dta macro
    mov ah, 2fh
    int 21h
endm

load macro args
    irp d,<args>
        push d
    endm
endm

restore macro args
    irp d,<args>
        pop d
    endm
endm

exit macro
    mov ah, 00h
    int 21h
endm
