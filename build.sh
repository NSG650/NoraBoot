rm *.bin
nasm boot.asm -o boot.bin
nasm stage2entry.asm -o stage2.bin
cat boot.bin stage2.bin > fun.bin