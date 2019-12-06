cd macro root_addr
    xor ax, ax
    mov ah, 3Bh
    mov dx, root_addr
    int 21h
endm

mcwd macro deviceid, buf
    xor ax, ax
    mov ah, 47h
    mov dl, deviceid
    mov si, offset buf
    int 21h
endm 

parse_filename macro fcb, filename
    xor ax, ax
    mov ah, 29h
    mov si, offset filename
    mov di, offset fcb

    int 21h
endm

parse_first macro fcb
    xor ax, ax
    mov ah, 11h
    mov dx, offset fcb
    int 21h
endm

parse_next macro fcb
    xor ax, ax
    mov ah, 12h
    mov dx, offset fcb
    int 21h
endm


set_dta macro addr
    xor ax, ax 
    mov ah, 1Ah
    mov dx, offset addr
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
    mov ax, 0
    int 21h
endm

print_range macro args
    irp d,<args>
        print <offset d>
    endm
endm

print macro buf
    xor ax, ax
	mov ah, 09h
	mov dx, buf
	int 21h
endm
