#!/bin/sh
CC="gcc43 -std=gnu99"
NAME="src/swamp_fly"
PACK="${NAME}"
STRIP="${NAME}_stripped"
UNPACK="${NAME}_unpacked"
SOURCE="${NAME}.c"
OPT_FLAGS="-mpreferred-stack-boundary=2 -fweb -funsafe-loop-optimizations -ftracer -fomit-frame-pointer -fno-peephole -fno-keep-static-consts -fno-inline -fmodulo-sched -fmerge-all-constants -fgcse-sm -fgcse-las -fforce-addr -ffast-math -Os -march=pentium4"
LIBS_FLAGS="-L/usr/local/lib -nostdlib"
STRIP_FLAGS="-K .bss -K .text -K .data -R .comment -R .note -R .note.ABI-tag -R .fini -R .gnu.version -R .gnu.hash"

# Collect.
CC_FLAGS="`sdl-config --cflags` -DMODE_REL ${OPT_FLAGS}"
UNAME=`uname`
if test "x${UNAME}" = "xLinux" ; then
	LD_FLAGS="${LIBS_FLAGS} -ldl"
elif test "x${UNAME}" = "xFreeBSD" ; then
	LD_FLAGS="${LIBS_FLAGS} -lpthread" 
else
	echo "Unsupported fast compile system."
	exit 1
fi

# Get compiler.
if test "${CC}x" = "x" ; then
	CC="gcc"
fi

COMPILE="${CC} -o ${NAME}.o -c ${SOURCE} ${CC_FLAGS}"
echo "Compiling with: ${COMPILE}"
LINK="${CC} -o ${UNPACK} ${NAME}.o ${LD_FLAGS}"
echo "Linking with: ${LINK}"
`${COMPILE}` && \
`${LINK}` && \
cp ${UNPACK} ${STRIP} && \
strip ${STRIP_FLAGS} ${STRIP} && \
cat unpackhdr_7z > ${PACK} && \
rm -f ${PACK}.7z && \
cat ${STRIP} | 7z a -bd -t7z -mx=8 -si ${PACK}.7z && \
cat ${PACK}.7z >> ${PACK} && \
chmod +x ${PACK}

if test "$?" -eq "0" ; then
	SIZE=`stat -f "%z" ${NAME}`
	echo "Binary \"${NAME}\": ${SIZE} bytes" 
fi

# gzip method
#cat unpackhdr_gzip > ${PACK}
#gzip -c -f --best ${UNPACK} >> ${PACK}
