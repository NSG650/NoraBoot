wine64 .i386-win32-tcc.exe -c t.c -o t.o
wine64 i386-win32-tcc.exe -nostdlib -Wl,-Ttext,0x100000 t.o -o loader.sys
cp ./loader.sys ../