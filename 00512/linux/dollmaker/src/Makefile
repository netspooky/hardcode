gz:
	nasm dollmaker.asm -o dollmaker.c
	gzip -cn9 dollmaker.c > dollmaker.gz
	cat header.zipped dollmaker.gz > dollmaker
	rm dollmaker.gz dollmaker.c
	chmod +x dollmaker
