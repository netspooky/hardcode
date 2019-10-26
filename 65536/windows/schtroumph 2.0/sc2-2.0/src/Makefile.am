
DIR = @MUSICDIR@
LIB = @MUSICLIB@
SRC = 	bitmap.h  dejong.c     ifs.c      ifstext.h \
	introsystem.c  logo.c   perlin.c  scale2x.c \
	data.h    harmonics.c  ifstext.c  interference.c\
	introsystem.h  noise.c  sc2.c
	
SUBDIRS = data	$(DIR)
DIST_SUBDIRS = data mikmod minifmod


noinst_PROGRAMS = sc2
sc2_SOURCES = $(SRC)
sc2_LDADD = data/libdata.a $(LIB) 
sc2_DEPENDENCIES = data/libdata.a $(LIB)
