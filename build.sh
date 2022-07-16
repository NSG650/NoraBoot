rm *.bin
nasm boot.asm -o boot.bin
nasm stage2entry.asm -f elf -o stage2.o
i686-elf-ld -o stage2.bin -Ttext 0x1000 stage2.o --oformat binary
cat boot.bin stage2.bin > fun.bin