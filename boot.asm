bits 16
org 0x7c00

BootEntry:
    mov si, message
    call BootPrint
    call BootEnableA20
    mov bp, 0x9000 ; set the stack
    mov sp, bp
    cli
    lgdt [BootGdt]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:BootProtectedEntry
    jmp $


BootPrint:
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

bits 32
BootProtectedEntry:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    mov edi, 0xB8000
    mov ebx, filesize
    mov ecx, file

    loopA:
        dec ebx
        cmp ebx, 0
        je endA
        mov eax, [ecx]
        mov [edi], eax
        inc edi
        mov word [edi], 0x1f
        inc edi
        inc ecx
        jmp loopA
    endA:
        jmp $

message db "Hello from real mode!", 0xa, 0
file incbin "file.txt"
filesize equ $ - file + 1

BootGdtStart:
    dd 0x0 ; 4 byte
    dd 0x0 ; 4 byte

; GDT for code segment. base = 0x00000000, length = 0xfffff
BootGdtCode: 
    dw 0xffff    ; segment length, bits 0-15
    dw 0x0       ; segment base, bits 0-15
    db 0x0       ; segment base, bits 16-23
    db 10011010b ; flags (8 bits)
    db 11001111b ; flags (4 bits) + segment length, bits 16-19
    db 0x0       ; segment base, bits 24-31

; GDT for data segment. base and length identical to code segment
BootGdtData:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

BootGdtEnd:

; GDT descriptor
BootGdt:
    dw BootGdtEnd - BootGdtStart - 1 ; size (16 bit), always one less of its true size
    dd BootGdtStart ; address (32 bit)

CODE_SEG equ BootGdtCode - BootGdtStart
DATA_SEG equ BootGdtData - BootGdtStart

times 510-($-$$) db 0
dw 0xAA55