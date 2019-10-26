run: intro.sh
	./intro.sh

batch:
	W=640 H=480	make release
	W=800 H=600	make release
	W=1024 H=768	make release
	W=1024 H=640	make release
	W=1280 H=720	make release
	W=1280 H=768	make release
	W=1152 H=864	make release
	W=1280 H=800	make release
	W=1280 H=960	make release
	W=1280 H=1024	make release
	W=1360 H=768	make release
	W=1366 H=768	make release
	W=1440 H=900	make release
	W=1600 H=900	make release
	W=1600 H=1200	make release
	W=1680 H=1050	make release
	W=1920 H=1080	make release
	W=1920 H=1200	make release
	W=2560 H=1440	make release

intro.sh: intro.gz unpack_header
	cat unpack_header intro.gz > intro.sh
	wc -c intro.sh
	chmod +x intro.sh

intro.gz: intro.elf
	cat intro.elf | 7z a dummy -tGZip -mx=9 -si -so > intro.gz

intro.elf: intro.asm shaders.inc
	nasm -f bin intro.asm -DWIDTH=1280 -DHEIGHT=720 -o intro.elf

release: intro_$(W)x$(H).sh

intro_$(W)x$(H).sh: intro.asm shaders.inc
	nasm -f bin intro.asm -DWIDTH=$(W) -DHEIGHT=$(H) -DFULLSCREEN=0x80000000 -o intro_$(W)x$(H).elf
	cat intro_$(W)x$(H).elf | 7z a dummy -tGZip -mx=9 -si -so > intro_$(W)x$(H).gz
	cat unpack_header intro_$(W)x$(H).gz > intro_$(W)x$(H).sh
	wc -c intro_$(W)x$(H).sh
	chmod +x intro_$(W)x$(H).sh
	rm intro_$(W)x$(H).gz
	rm intro_$(W)x$(H).elf

