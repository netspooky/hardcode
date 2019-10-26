#!/bin/sh
CC='gcc-4.2'
PACK='src/sae4'
STRIP='src/sae4_stripped'
UNPACK='src/sae4_unpacked'
SOURCE='src/sae4.c'
OPT_FLAGS=" -mpreferred-stack-boundary=2 -fweb -fomit-frame-pointer -fno-peephole -fmerge-all-constants -ffast-math -Os -march=pentium4"
DNLOAD_FLAGS='-DHAVE_DLFCN_H -DDNLOAD_LIBM -DSAE4_FREEGLUT'
LIBS_FLAGS='-nostdlib'
STRIP_FLAGS="-K .bss -K .text -K .data -R .comment -R .note -R .note.ABI-tag -R .fini -R .gnu.version"

# Collect.
CC_FLAGS="`sdl-config --cflags` ${OPT_FLAGS} ${DNLOAD_FLAGS}"
LD_FLAGS="`sdl-config --libs` ${LIBS_FLAGS}"

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
