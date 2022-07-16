bits 16
org 0x7c00

xor ax, ax
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax

mov esp, 0x7C00
mov ebp, esp

BootEntry:
    mov di, file
    call BootPrint
    call BootEnableA20
    jmp $

BootPrint:
    mov si, di
    mov ah, 0x0e
    loop0:
        lodsb
        cmp al, 0
        je end0
        cmp al, 0xa
        je lb
        int 0x10
        jmp loop0
    lb:
        mov al, 0xd
        int 0x10
        mov al, 0xa
        int 0x10
        jmp loop0
    end0:
        ret
    
BootEnableA20:
	push ax
	in al, 0x92
	or al, 0x02
	out 0x92, al
	pop ax
	ret

message db "Hello from real mode!", 0xa, 0
file incbin "file.txt"
filesize equ $ - file

times 510-($-$$) db 0
dw 0xAA55