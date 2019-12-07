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

print macro buf
	mov ah, 09h
	mov dx, buf
	int 21h
endm

print_range macro args
    irp d,<args>
        print <offset d>
    endm
endm