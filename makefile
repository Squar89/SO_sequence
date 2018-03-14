all: sequence.o
	ld --fatal-warnings -o sequence sequence.o
sequence.o: sequence.asm
	nasm -f elf64 -o sequence.o sequence.asm

clean:
	rm -rf sequence sequence.o