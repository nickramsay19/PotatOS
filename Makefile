default: bin/potatos.bin

iso: bin dist bin/potatos.bin
	dd if=/dev/zero of=floppy.img bs=1024 count=1440
	dd if=bin/potatos.bin of=floppy.img seek=0 count=1 conv=notrunc
	cp floppy.img dist/floppy.img
	mkisofs -quiet -V 'PotatOS' -input-charset iso8859-1 -o dist/potatos.iso -b floppy.img -hide floppy.img dist/
	rm floppy.img

bin/potatos.bin: bin src/potatos.asm
	nasm -f bin -o bin/potatos.bin src/potatos.asm

bin:
	mkdir bin

dist:
	mkdir dist

clean:
	rm bin/*
	rm dist/*