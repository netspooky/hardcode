INCLUDE =
CFLAGS = -O2 -ffast-math -funsigned-char
OBJ = radix.o vec_cam.o vec_file.o vec_lsrc.o vec_math.o vec_matr.o \
      vec_mem.o vec_pal.o vec_poly.o vecsys.o 
INC = promote.h radix.h vec_3ds.h vec_cam.h vec_def.h vec_file.h vec_kf.h \
      vec_lsrc.h vec_math.h vec_matr.h vec_mem.h vec_mtrl.h vec_pal.h \
      vec_poly.h vec_spl.h vec_type.h vecsys.h 

vecsys.a: $(OBJ)
	ar rc $@ $(OBJ)
	$(RANLIB) vecsys.a

%.o: %.c $(INC)
	$(CC) $(INCLUDE) $(CFLAGS) -c $<

clean:
	rm vecsys.a *.o
