### platform-specific stuff ######################

AR = ar

### Linux/i386
CC = gcc -DDRIVE_VCSA -DDRIVE_OSS

### SunOS/SPARC
#CC = gcc -O2 -DBIG_ENDIAN

##################################################

LIBOBJS=pwplib/pwplib.o pwplib/vcsa.o pwplib/oss.o pwplib/gb.o \
        pwplib/convert.o pwplib/tty.o pwplib/lossy.o pwplib/pvp.o \
        pwplib/init.o

FISIOBJS= final_isi/fisimain.o final_isi/fisidemo.o final_isi/fisieffu.o \
          final_isi/fisifont.o final_isi/fisi3d.o \
          final_isi/fisitime.o final_isi/fiscroll.o \
          final_isi/wrapper.o pwplib.a

# PVPOBJS= playpvp.o pwplib.a

all: peluce

### pwplib #######################################

pwplib.a: $(LIBOBJS)
	$(AR) r $@ $(LIBOBJS)

### pwplib stuff #################################

peluce: pwplib.a
	cd peluce; make

# playpvp: $(PVPOBJS)
# 	$(CC) $(PVPOBJS) -s -o playpvp -lm

### generic ######################################

%.o: %.c
	$(CC) $(@:.o=.c) -c -o $@

clean:
	rm -f *.o *~ pwplib/*.o pwplib/*~ pwpzax/*~ final_isi/*.o final_isi/*~ peluce/*.o peluce/*~ pwplib.a
