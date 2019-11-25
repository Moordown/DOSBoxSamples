model tiny
.386
.code
org 100h
start:	
l1:
    cmp [line_cnt], 17
    je l3
    cmp [row_cnt], 16
    je l2
    ; add si, offset_cnt
    mov byte ptr [buf], 0ah
    call print
    inc word ptr [offset_cnt]
    inc word ptr [line_cnt] 
    mov byte ptr [row_cnt], 00h
l2:
    mov al, [character_cnt]
    mov byte ptr [buf], al
    call print
    inc word ptr [offset_cnt]
    inc word ptr [character_cnt]
    inc byte ptr [row_cnt]
    jmp l1
l3:
    mov ah, 00h
    int 21h
print:
	mov ah, 09h
	mov dx, offset buf
	int 21h
	
	ret
buf db 2 dup("$")
line_cnt dw 0
row_cnt dw 0
character_cnt db 0
offset_cnt dw 0
new_line db 0ah
end start