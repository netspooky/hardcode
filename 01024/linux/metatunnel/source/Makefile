all:
	nasm -f bin -o intro main.asm
	nasm -f bin -o stub stub.asm
	gzip -n --best intro
	advdef -z -4 intro.gz
	cat stub intro.gz > intro
	chmod +x intro
	rm intro.gz
	rm stub

	wc -c intro