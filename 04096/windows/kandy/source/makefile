audio.wav: audio
	./audio

audio: audio.c math.o synth.o
	gcc -o audio audio.c math.o synth.o

synth.o: synth.asm math.inc music.inc
	nasm -felf -dlinux synth.asm

math.o:  math.asm  math.inc
	nasm -felf -dlinux math.asm

