gcc -Os -ffast-math -fomit-frame-pointer -c 4k.c
ld -dynamic-linker /lib/ld-linux-x86-64.so.2 4k.o /usr/lib/libGL.so.1 /usr/lib/libSDL.so  /usr/lib/libGLU.so.1 -o 4k
strip -s -R .comment -R .gnu.version 4k
sstrip 4k
7z a -tGZip -mx=9 4k.gz 4k
cat unpack.header 4k.gz > 4k
chmod a+x 4k
rm 4k.gz 4k.o
wc -c 4k