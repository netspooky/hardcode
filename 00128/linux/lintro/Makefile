PROD=lintro

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

release: $(PROD)_$(W)x$(H)x32

$(PROD)_$(W)x$(H)x32: $(PROD).asm
	nasm -f bin $(PROD).asm -DW=$(W) -DH=$(H) -o $(PROD)_$(W)x$(H)x32
	chmod +x $(PROD)_$(W)x$(H)x32

