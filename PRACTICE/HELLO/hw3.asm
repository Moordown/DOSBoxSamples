model tiny
.386
.code
org 100h
start:	
	mov ah, 09h
	mov dx, offset msg
	int 21h

	mov ah, 0Ah
	mov byte ptr [buf], 100
	mov dx, offset buf
	int 21h

	mov ah, 09h
	mov dx, offset hello
	int 21h

	mov ah, 09h
	mov dx, offset buf
	inc dx
	inc dx
	int 21h
	
	ret
msg db "Enter your name", 0ah, "$"
hello db 0ah, "Hello ", "$"
buf db 256 dup("$")
end start