bits 16
org 0x7c00

boot:
    mov di, message
    call puts
    jmp $

puts:
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

message:
    db "Hello from real mode!", 0xa, 0

times 510-($-$$) db 0
dw 0xAA55