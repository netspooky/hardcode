CC = gcc
COPT = -march=pentium3 -Os -fno-inline -fmove-all-movables \
	-fexpensive-optimizations -fpeephole2 -fshort-double \
	-I/usr/X11R6/include \
	-I. \
	-fomit-frame-pointer \
	-mpreferred-stack-boundary=2 -falign-functions=0 -falign-jumps=0 \
	-Wall \
	-fdata-sections -ffunction-sections \
	-fstrength-reduce \
	-frerun-loop-opt \
	-mfpmath=387 \
	
#,sse and fast-math waste space	
#	-ffast-math \

SOPT = -R .comment -R .note -R .note.ABI-tag -R .fini -R .gnu.version
# -R .gnu.version_r

all: fake-glpong1k
	ls -l $^

glpong1k: glpong1k.o
	$(CC) -o $@ -nostartfiles -nostdlib $^ -ldl
	ls -l glpong1k

glpong1k-stripped: glpong1k
	cp $< $@
	strip $(SOPT) $@
	-./count $@|sort -n
	-elfls -di -w 50 $@	

# elfls is in elfkickers

fake-glpong1k: glpong1k-stripped
	cp	$< T
	-sstrip T
	gzip --best -f T
	cat unpack.header T.gz > $@
	rm T.gz
	chmod a+rx $@
	ls -l fake-glpong1k

glpong1k.o: glpong1k.asm
	nasm -f elf -o $@ $<

clean:
	-rm *.o
	-rm fake-glpong1k glpong1k glpong1k-stripped