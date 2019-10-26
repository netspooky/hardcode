
NF = @NFLAGS@

AM_CFLAGS = -D__COMPILE_MINIFMOD__


noinst_LIBRARIES = libminifmod.a
libminifmod_a_SOURCES = fmusic.c     mixer_clipcopy.c        music.h           system_file.h\
fsound.c     mixer_clipcopy.h        music_formatxm.c  system_memory.h\
genasminc.c  mixer_fpu_ramp.c        music_formatxm.h  xmeffects.h\
minifmod.h   mixer_fpu_ramp.h        sound.h\
mixer.h      mixer_fpu_ramp_asm.asm  system_file.c

libminifmod_a_LIBADD = mixer_fpu_ramp_asm.o
#libminifmod_a_DEPENDENCIES = mixer_fpu_ramp_asm.o


mixer_fpu_ramp_asm.o : mixer_fpu_ramp_asm.asm mixer_fpu_ramp_asm.inc
	nasm $(NF) $< -o mixer_fpu_ramp_asm.o

mixer_fpu_ramp_asm.inc : genasminc
	./genasminc >mixer_fpu_ramp_asm.inc
        
genasminc : genasminc.c
	gcc genasminc.c -o genasminc -D__COMPILE_MINIFMOD__

