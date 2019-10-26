#!/bin/sh
PACK='build/organica'
STRIP='build/organica_stripped'
UNPACK='build/organica_unpacked'
SOURCE='src/organica.c'

OPT_FLAGS="-mpreferred-stack-boundary=2 -fweb -fomit-frame-pointer -fno-peephole -fmodulo-sched -fmerge-all-constants -ffast-math -Os -march=i386"
#OPT_FLAGS="-Os"
DNLOAD_FLAGS='-DHAVE_DLFCN_H -DDNLOAD_LIBGL -DDNLOAD_LIBGLU -DDNLOAD_LIBGLUT -DDNLOAD_LIBSDL -DDISCARD_LIBC'
SDL_CFLAGS=`sdl-config --cflags`
#MAIN_FLAGS=''
LIBS_FLAGS='-nostdlib'
INCDIR_FLAGS="-I/usr/X11R6/include -I/usr/include"
LIBDIR_FLAGS="-L/usr/X11R6/lib -L/usr/local/lib"
STRIP_FLAGS="-K .bss -K .text -K .data -R .comment -R .note -R .note.ABI-tag -R .fini -R .gnu.version"

# Collect.
CC_FLAGS="${OPT_FLAGS} ${INCDIR_FLAGS} ${DNLOAD_FLAGS} `sdl-config --cflags`"
LD_FLAGS="${LIBDIR_FLAGS} -lSDL -lpthread -nostdlib"

# Get compiler.
if test "${CC}x" = "x" ; then
	CC="gcc"
fi

RUN="${CC} -o ${UNPACK} ${SOURCE} ${CC_FLAGS} ${LD_FLAGS}"

echo "Compiling with:"
echo "${RUN}"
`${RUN}` && \
cp ${UNPACK} ${STRIP} && \
strip ${STRIP_FLAGS} ${STRIP} && \
cat unpackhdr_7z > ${PACK} && \
rm -f ${PACK}.7z && \
cat ${STRIP} | 7z a -t7z -mx=8 -si ${PACK}.7z && \
cat ${PACK}.7z >> ${PACK} && \
chmod +x ${PACK}

# gzip method
#cat unpackhdr_gzip > ${PACK}
#gzip -c -f --best ${UNPACK} >> ${PACK}
