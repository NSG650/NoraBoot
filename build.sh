rm *.bin
nasm boot.asm -o boot.bin
i686-elf-gcc -c -ffreestanding stage2.c -o stage2.o
nasm stage2entry.asm -f elf -o stage2e.o
i686-elf-ld -o stage2.bin -Ttext 0x1000 stage2e.o stage2.o --oformat binary
cat boot.bin stage2.bin > fun.bin