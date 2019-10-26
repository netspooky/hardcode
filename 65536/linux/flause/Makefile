all: flause

flause: ./src/demo.c ./src/demo.h ./src/main.c ./src/minifmod.c ./src/minifmod.h ./src/effects.c ./src/opengl.c ./src/opengl.h ./src/minifmod/fmusic.c ./src/minifmod/fsound.c ./src/minifmod/genasminc.c ./src/minifmod/minifmod.h ./src/minifmod/mixer.h ./src/minifmod/mixer_clipcopy.c ./src/minifmod/mixer_clipcopy.h ./src/minifmod/mixer_fpu_ramp.c ./src/minifmod/mixer_fpu_ramp.h ./src/minifmod/music.h ./src/minifmod/music_formatxm.c ./src/minifmod/music_formatxm.h ./src/minifmod/sound.h ./src/minifmod/system_file.c ./src/minifmod/system_file.h ./src/minifmod/system_memory.h ./src/minifmod/xmeffects.h ./src/util/bin2h.c ./src/jpeg.c ./src/scenes.c ./src/effects.h ./src/scenes.h ./src/tekst.h ./src/jpeg.h ./src/data/WEIRD2.XM
	make -C src/
	cp src/flause ./
	strip  flause
	upx -9 flause


clean:
	make -C src/ clean
	rm -f flause
