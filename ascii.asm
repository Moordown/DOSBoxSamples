model tiny
.386
.code
org 100h
start:	
l1:
    cmp [row_cnt], 16
    jl l2
    mov byte ptr [buf], 0ah
    call print
    inc byte ptr [line_cnt] 
    mov byte ptr [row_cnt], 0
    cmp [line_cnt], 16
    je exit
l2:
    mov al, [character_cnt]
    cmp al, 31
    jg l4
    cmp al, 128
    jl l4
l3: 
    mov al, "."
l4:
    mov byte ptr [buf], al
    call print
    inc byte ptr [character_cnt]
    inc byte ptr [row_cnt]
    jmp l1
exit:
    mov ah, 00h
    int 21h
    
    ret
print:
	mov ah, 09h
	mov dx, offset buf
	int 21h
	
	ret
buf db 2 dup("$")
line_cnt db 0
row_cnt db 0
character_cnt db 0
new_line db 0ah
end start