ultraviolet : ultraviolet.asm syscalls.asm Makefile
	nasm -f bin -o $@ $< -l $@.list
	chmod +x $@
	wc -c $@