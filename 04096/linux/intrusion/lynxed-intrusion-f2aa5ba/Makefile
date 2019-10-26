CC = clang
CPP = cpp
LD = ld
NASM = nasm
STRIP = sstrip -z
SCREW_ELF_HEADER = tools/screw_elf_header.py
SHADER_MINIFIER = shader_minifier.exe
BUILD_GLYPHS = tools/build_glyphs.py
CFLAGS = -m32 -std=c99 -Wall -Os -ffast-math -fomit-frame-pointer -march=i686 $(shell pkg-config --cflags sdl) $(shell pkg-config --cflags gl)
LDFLAGS = -melf_i386 -dynamic-linker /lib/ld-linux.so.2 -lc
NASMFLAGS = -f elf -idata/ -w-orphan-labels

SOURCES = main.c
HEADERS = clib.h gl_functions.h linker.h shader.h vector.h defines.h keypoint.h sdl_functions.h shader_defines.h sound.h console.h scene_state.h
ASM_SOURCES = data/4klang.asm
LINKER_SCRIPT = linker.ld
OBJECTS = $(notdir $(SOURCES:.c=.o) $(ASM_SOURCES:.asm=.o))
SHADERS = vertex.glsl fragment.glsl
SHADERS_PREPROCESSED = $(SHADERS:.glsl=.glsl.i)
SHADER_HEADER = shader_code.h
GLYPHS_IMAGE = data/glyphs.png
GLYPHS_HEADER = glyphs.h
EXECUTABLE = intrusion.elf
COMPRESSED = intrusion

all: $(COMPRESSED)

$(COMPRESSED): $(EXECUTABLE)
	echo '#!/bin/sh\ntail -n+3 "$$0"|unxz>i;chmod +x i;./i;rm -f i;exit' > $@
	xz -c6 --format=lzma $< >> $@
	chmod +x $@

$(EXECUTABLE): $(LINKER_SCRIPT) $(OBJECTS) $(MAKEFILE_LIST)
	$(LD) $(LDFLAGS) -o $@ -dT $(LINKER_SCRIPT) $(OBJECTS)
	$(STRIP) $@
	$(SCREW_ELF_HEADER) $@

$(SHADER_HEADER): $(SHADERS_PREPROCESSED)
	$(SHADER_MINIFIER) --preserve-externals -o $@ $^
	sed -i 's/glsl_i/glsl/g' $@

$(GLYPHS_HEADER): $(GLYPHS_IMAGE) $(SOURCES) $(HEADERS)
	$(BUILD_GLYPHS) $^ $@

%.glsl.i: %.glsl
	$(CPP) -C -P $< > $@

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

%.o: %.c %.d $(SHADER_HEADER)
	$(CC) -c $(CFLAGS) $< -o $@

%.d: %.c $(SHADER_HEADER) $(GLYPHS_HEADER)
	@$(SHELL) -ec '$(CC) -M $(CFLAGS) $< \
		| sed '\''s/\($*\)\.o[ :]*/\1.o $@ : /g'\'' > $@; \
		[ -s $@ ] || rm -f $@'

clean:
	rm -rf *.o *.d $(EXECUTABLE) $(COMPRESSED) *.glsl.i $(SHADER_HEADER) $(GLYPHS_HEADER)

-include $(SOURCES:.c=.d)

