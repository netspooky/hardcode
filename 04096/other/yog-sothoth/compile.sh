#!/bin/sh
NAME="src/yog_sothoth"
PACK="${NAME}"
STRIP="${NAME}_stripped"
UNPACK="${NAME}_unpacked"
SOURCE="src/intro.c"
ARCHIVER="lzma"
OPT_FLAGS="-ffast-math -fomit-frame-pointer -Os -fsingle-precision-constant `sdl-config --cflags`"
LD_FLAGS="-L/usr/local/lib -nostdlib -nostartfiles -lc -lGL -lGLU `sdl-config --libs`"
STRIP_FLAGS="-K .bss -K .text -K .data -R .comment -R .note -R .note.ABI-tag -R .fini -R .gnu.version -R .gnu.hash -R .eh_frame -R .eh_frame_hdr"

# Collect.
UNAME=`uname`
if test "x${UNAME}" = "xLinux" ; then
  CC="gcc -std=gnu99"
  if test `uname -m` = "x86_64" ; then
    CC_FLAGS="${OPT_FLAGS} -mpreferred-stack-boundary=4"
  else
    CC_FLAGS="${OPT_FLAGS} -mpreferred-stack-boundary=2"
  fi
  STAT_FLAGS="-c \"%s\""
elif test "x${UNAME}" = "xFreeBSD" ; then
  CC="gcc48 -std=gnu99"
  if test `uname -m` = "amd64" ; then
    CC_FLAGS="${OPT_FLAGS} -mpreferred-stack-boundary=4"
  else
    CC_FLAGS="${OPT_FLAGS} -mpreferred-stack-boundary=2"
  fi
  STAT_FLAGS="-f \"%z\""
else
  echo "${0}: unsupported fast compile system '${UNAME}'"
  exit 1
fi

while test $# -gt 0
do
  case "${1}" in
    "-f")
      ARCHIVER="${2}"
      shift
      ;;
    "--format")
      ARCHIVER="${2}"
      shift
      ;;
  esac
  shift
done

if test "${ARCHIVER}" = 'lzma' ; then
  ARCHIVER="xz --format=lzma --lzma1=preset=9e,lc=1,lp=0,pb=0 --stdout"
  UNPACKHDR="unpackhdr_lzma"
elif test "${ARCHIVER}" = 'raw' ; then
  ARCHIVER="xz -9 --extreme --format=raw --stdout"
  UNPACKHDR="unpackhdr_raw"
elif test "${ARCHIVER}" = 'xz' ; then
  ARCHIVER="xz --format=xz --lzma2=preset=9e,lc=1,pb=0 --stdout"
  UNPACKHDR="unpackhdr_xz"
else
  echo "${0}: unsupported archiver '${ARCHIVER}'"
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
COMPILE="${CC} -o ${NAME}.S -S ${SOURCE} ${CC_FLAGS}"
echo "Compiling with: ${COMPILE}"
LINK="${CC} -o ${UNPACK} ${NAME}.o ${LD_FLAGS}"
echo "Linking with: ${LINK}"
`${COMPILE}` && \
cat ${NAME}.S | grep -v "\.rodata" > "${NAME}_final.S" && \
as -o ${NAME}.o ${NAME}_final.S && \
`${LINK}` && \
cp "${UNPACK}" "${STRIP}" && \
strip ${STRIP_FLAGS} "${STRIP}" && \
cp "${UNPACKHDR}" "${PACK}" && \
${ARCHIVER} "${STRIP}" >> "${PACK}" && \
chmod +x "${PACK}"

if test "$?" -eq "0" ; then
  SIZE=`stat ${STAT_FLAGS} ${NAME}`
  echo "Binary \"${NAME}\": ${SIZE} bytes" 
fi

exit 0
