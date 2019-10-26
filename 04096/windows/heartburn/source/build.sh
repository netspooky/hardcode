#!/bin/bash

[ -d "release/linux" ] || mkdir -p release/linux

TEMP=`mktemp -d`
as --32 -o $TEMP/heartburn_footer.o heartburn_footer.S
nasm -o $TEMP/music.o -f elf32 clinkster-linux.asm

{ cat <<EOF
640 480
800 600
1024 768
1280 720
1280 1024
1366 768
1680 1050
1920 1080
EOF
} | while read w h; do
	r=$( perl -e 'printf "%x" , unpack( "V" ,  pack( "f" , '$w'/'$h' ) );' )

	for f in 0 1; do
		if [ $f -eq 1 ]; then
			fs='fullscreen'
			fsd='-DFULLSCREEN'
			sdl=0x80000002
		else
			fs='window'
			sdl=0x2
			fsd=''
		fi

		bn="release/linux/heartburn-${w}x${h}-${fs}"

		gcc -m32 -O1 -ffast-math -mfpmath=387 \
			$fsd -DS_WIDTH=$w -DS_HEIGHT=$h \
			-c -o $TEMP/safe.o heartburn.c
		gcc -m32 -lSDL -lGL -o ${bn}-safe \
			$TEMP/safe.o $TEMP/music.o

		gcc -m32 -c -o $TEMP/min.o heartburn.S \
			-DS_WIDTH=$w -DS_HEIGHT=$h \
			-DS_RATIO=0x$r -DSDL_FLAGS=$sdl
		ld -Theartburn.ld -o $TEMP/min \
			$TEMP/min.o $TEMP/music.o $TEMP/heartburn_footer.o
		lzma -9 $TEMP/min
		cat header.sh $TEMP/min.lzma > $bn
		chmod +x $bn
		rm $TEMP/min.lzma
	done
done

rm -rf $TEMP
