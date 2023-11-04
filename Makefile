all:
	nasm -f elf start.asm
	ld -melf_i386 start.o -o start
	./start
	rm -rf start start.o
