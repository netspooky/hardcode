#!/bin/sh
NAME="src/dirty_garden"
PACK="${NAME}"
STRIP="${NAME}_stripped"
UNPACK="${NAME}_unpacked"
SOURCE="src/main.c"
OPT_FLAGS="-ffast-math -fomit-frame-pointer -mpreferred-stack-boundary=2 -Os -march=pentium4 -fweb"
LIBS_FLAGS="-L/usr/local/lib -nostdlib -nostartfiles"
STRIP_FLAGS="-K .bss -K .text -K .data -R .comment -R .note -R .note.ABI-tag -R .fini -R .gnu.version -R .gnu.hash"

# Collect.
CC_FLAGS="`sdl-config --cflags` ${OPT_FLAGS}"
UNAME=`uname`
if test "x${UNAME}" = "xLinux" ; then
	CC="gcc -std=gnu99"
	LD_FLAGS="${LIBS_FLAGS} -ldl"
elif test "x${UNAME}" = "xFreeBSD" ; then
	CC="gcc44 -std=gnu99"
	LD_FLAGS="${LIBS_FLAGS} -lthr" 
else
	echo "Unsupported fast compile system."
	exit 1
fi

if test -f '/usr/local/bin/lzma' ; then
	LZMA='/usr/local/bin/lzma e -a1 -fb90 -d13 -lc0 -mfbt2 -so'
else
	LZMA='lzma -9 --stdout'
fi

if test "${CC}x" = "x" ; then
	CC="gcc"
fi

if test -f ${NAME}.o ; then
	rm ${NAME}.o
fi
if test -f ${PACK} ; then
	rm ${PACK}
fi
if test -f ${STRIP} ; then
	rm ${STRIP}
fi
if test -f ${UNPACK} ; then
	rm ${UNPACK}
fi

# Get compiler.
COMPILE="${CC} -o ${NAME}.o -c ${SOURCE} ${CC_FLAGS}"
echo "Compiling with: ${COMPILE}"
LINK="${CC} -o ${UNPACK} ${NAME}.o ${LD_FLAGS}"
echo "Linking with: ${LINK}"
`${COMPILE}` && \
`${LINK}` && \
cp ${UNPACK} ${STRIP} && \
strip ${STRIP_FLAGS} ${STRIP} && \
cp unpackhdr_lzma ${PACK} && \
${LZMA} ${STRIP} >> ${PACK} && \
chmod +x ${PACK}

if test "$?" -eq "0" ; then
	SIZE=`stat -f "%z" ${NAME}`
	echo "Binary \"${NAME}\": ${SIZE} bytes" 
fi

# gzip method
#cat unpackhdr_gzip > ${PACK}
#gzip -c -f --best ${UNPACK} >> ${PACK}
