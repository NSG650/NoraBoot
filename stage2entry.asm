bits 32

mov esi, loader

; dos header check
mov ax, word [esi] ; e_magic
cmp ax, 0x5A4D
jne .dos_header_check_fail

; nt header check
mov ebx, dword [esi+0x3c] ; e_lfanew
add ebx, esi
cmp dword [ebx], 0x00004550
jne .nt_header_check_fail

; check if the pe binary is for us
cmp word [ebx+0x04], 0x014C
jne .arch_check_fail

; copy headers
mov ecx, dword [ebx+0x18+0x28] ; OptionalHeader.SizeofHeaders
mov edi, dword [ebx+0x18+0x1c] ; OptionalHeader.ImageBase
pushad
rep movsb
popad

; get number of sections
movzx edx, word [ebx+0x04+0x02] ; FileHeader.NumberOfSections
mov eax, 0x28 ; SizeOfSectionHeader
imul eax, edx
xor edx, edx

.load_section:
%define SectionHeader edx+0xF8 
	; Copy raw data to image base
	pushad
	mov ecx, dword [ebx+SectionHeader+0x10] ; SectionHeader.SizeOfRawData
	add esi, dword [ebx+SectionHeader+0x14] ; SectionHeader.PointerToRawData
	add edi, dword [ebx+SectionHeader+0xC] ; SectionHeader.VirtualAddress

	; Check if virtual size is smaller than raw data size
	cmp ecx, [ebx+SectionHeader+0x08] ; SectionHeader.0x08
	jge .virtual_smaller
	rep movsb

	; Pad the remainder of virtual size with zeros
	mov ecx, dword [ebx+SectionHeader+0x08] ; SectionHeader.0x08
	sub ecx, dword [ebx+SectionHeader+0x10] ; SectionHeader.SizeOfRawData
	xor al, al
	rep stosb
	jmp .next_section
.virtual_smaller:
	; Copy virtual size amount of bytes instead
	mov ecx, [ebx+SectionHeader+0x08] ; SectionHeader.0x08
	rep movsb
%undef SectionHeader
.next_section:
	popad
	add edx, 0x28 ; Go to next section and check if we reached the last section
	cmp edx, eax
	jge .end
	jmp .load_section

.dos_header_check_fail:
    mov ecx, msg_dos_fail
    call BootPrint32
    hlt 

.nt_header_check_fail:
    mov ecx, msg_nt_fail
    call BootPrint32
    hlt

.arch_check_fail:
    mov ecx, msg_arch_fail
    call BootPrint32
    hlt

.end:
    mov eax, dword [ebx+0x18+0x1c] ; OptionalHeader.BaseAddress
	add eax, dword [ebx+0x18+0x10] ; OptionalHeader.AddressOfEntryPoint
	jmp eax

jmp $


BootPrint32:
    mov edi, 0xB8000
    loopA:
        mov eax, [ecx]
        cmp eax, 0
        je endA
        mov [edi], eax
        inc edi
        mov word [edi], 0x1f
        inc edi
        inc ecx
        jmp loopA
    endA:
        ret



msg_dos_fail db "DOS Header check fail!", 0x0
msg_nt_fail db "NT Header check fail!", 0x0
msg_arch_fail db "Not an i386 binary", 0x0
loader incbin "loader.sys"
loader_size equ $ - loader + 1