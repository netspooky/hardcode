#  This file is part of bob, a 32k game for Mekka Symposium 2001.
#  Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; see the file COPYING; if not, write to
#  the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
#  Boston, MA  02111-1307  USA
#

              RM = rm -f
           RMDIR = rm -rf
           STRIP = strip

              CC = gcc
          CFLAGS = -s -Wall -DLINUX -g
            LIBS = -lm -lggi -lggimisc -lpthread

# compiler flags which don't have too much impact on filesize:
             OPT = -Os -fmove-all-movables -fomit-frame-pointer          \
                   -mpentiumpro -march=pentiumpro                        \
                   -fexpensive-optimizations -finline-functions          

        bob_root = ..
          target = $(bob_root)/../bob
          binary = $(bob_root)/GNU/bob
         bob_src = $(bob_root)/bob.src
         bob_tmp = $(bob_root)/bob.tmp
        fxmp_src = $(bob_root)/fxmp.src
        fxmp_tmp = $(bob_root)/fxmp.tmp
        data_src = $(bob_root)/data.src
        data_tmp = $(bob_root)/data.tmp
       tools_src = $(bob_root)/tools.src
       tools_tmp = $(bob_root)/tools.tmp

     bob_o_files = $(bob_tmp)/bob_game.o $(bob_tmp)/bob_ggi.o                  \
                   $(bob_tmp)/bob_text.o $(bob_tmp)/gettime.o                  \
                   $(bob_tmp)/main.o                                           \
                   $(bob_tmp)/typeface.o $(bob_tmp)/bob_data.o
    fxmp_o_files = $(fxmp_tmp)/fxmp.o $(fxmp_tmp)/load_xm.o $(fxmp_tmp)/freq.o \
                   $(fxmp_tmp)/drv_dsp.o $(fxmp_tmp)/ticker.o
    data_h_files = $(data_tmp)/drbob2.pal.h $(data_tmp)/drbob20.jrs.h          \
                   $(data_tmp)/drbob20.jtf.h $(data_tmp)/drbob21.jrs.h         \
                   $(data_tmp)/drbob21.jtf.h $(data_tmp)/game.xm.h             \
                   $(data_tmp)/menu.xm.h
     fxmp_h_file = $(fxmp_src)/config.h $(fxmp_src)/drv_dsp.h $(fxmp_src)/freq.h  \
                   $(fxmp_src)/fxmp.h $(fxmp_src)/load_xm.h $(fxmp_src)/ticker.h  \
                   $(fxmp_src)/types.h
     bob_h_files = $(bob_src)/bob_data.h $(bob_src)/bob_game.h                 \
                   $(bob_src)/bob_ggi.h $(bob_src)/bob_text.h                  \
                   $(bob_src)/gettime.h $(bob_src)/typeface.h
 

all: quick
release: compress

quick: $(binary)

compress: $(binary)
	cp --preserve $(binary) $(target)
	$(STRIP) --strip-all $(target)
	$(STRIP) --remove-section=".comment" $(target)
	$(STRIP) --remove-section=".note" $(target)
	upx --best --no-color --overlay=strip $(target)

bob: $(bob_tmp) $(bob_o_files)
fxmp: $(fxmp_tmp) $(fxmp_o_files)

%.tmp :
	mkdir $@

$(binary) : bob fxmp
	$(CC) $(OPT) $(CFLAGS) -o $(binary) $(bob_o_files) $(fxmp_o_files) $(LIBS)

$(bob_tmp)/%.o : $(bob_src)/%.c
	$(CC) $(OPT) -c $(CFLAGS) $< -o $@

$(fxmp_tmp)/%.o : $(fxmp_src)/%.c
	$(CC) $(OPT) -c $(CFLAGS) $< -o $@

$(tools_tmp)/%.o : $(tools_src)/%.c
	$(CC) $(OPT) -c $(CFLAGS) $< -o $@


data:
	cd ../tools.src && ./rip.sh

clean:
	$(RM) $(binary) $(bob_o_files) $(fxmp_o_files) $(tools_bin_files)
	$(RMDIR) $(bob_tmp) $(fxmp_tmp)


tools-clean:
	cd ../tools.src && make clean

data-clean:
	$(RM) $(data_h_files)
	$(RMDIR) $(data_tmp)



