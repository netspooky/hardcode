#  This file is part of Jeeves64, an application framework for 64k
#  GNU/Linux and win32 intro development. 
#
#  Jeeves64 makes use of fxmp by Spectre of Flare and tinyptc by 
#  Gaffer, consult the README for urls. 
#  This file is Copyright (c) 2000 Kuno Woudt <warp-tmt@dds.nl>.
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

         PACKAGE = Jeeves64
         VERSION = 1.0.9a

              RM = rm -f
           STRIP = strip

              CC = gcc
             CXX = g++
          CFLAGS = -s -Wall 
        CXXFLAGS = -s -Wall 

# compiler flags which don't have too much impact on filesize:
# (try the compiler flags listed below for better performance)
             OPT = -Os -fmove-all-movables -fomit-frame-pointer          \
                   -mpentiumpro -march=pentiumpro                        \
                   -fexpensive-optimizations -finline-functions          

# the following compiler flags improves performance significantly with some
# applications on my system. however, not all flags have been included above to
# save filesize (e.g. -funroll-all-loops increases compressed binary filesize
# with approx. 3kb), feel free to experiment.  -- <warp-tmt@dds.nl>

#             OPT = -O3 -fmove-all-movables -fomit-frame-pointer         \
#                   -mpentiumpro -march=pentiumpro -malign-functions=4   \
#                   -fexpensive-optimizations -malign-double             \
#                   -fschedule-insns2 -mwide-multiply -finline-functions \
#                   -fstrict-aliasing -funroll-all-loops

    PTC_INCLUDES = -I/usr/X11R6/include/X11 -I/usr/X11R6/include -I/usr/include -I/usr/local/include
         PTC_LIB = -L/usr/X11R6/lib -L/usr/lib -L/usr/local/lib -lX11 -lXext -lXxf86dga -lXxf86vm
      JEEVES_LIB = $(PTC_LIB) -lpthread

     FXMP_CFLAGS = -pedantic -ansi
   JEEVES_CFLAGS = -Wno-conversion

          target = ../8bit
          binary = ./test
       build_dir = .
         src_dir = $(build_dir)/../src
         obj_dir = $(build_dir)/j64.d
        fxmp_dir = $(src_dir)/fxmp
        fxmp_obj = $(build_dir)/fxmp.d
        data_dir = $(src_dir)/tmp.d
     bindata_dir = $(src_dir)/../data
         ptc_dir = $(src_dir)/tinyptc-x11_8bit
         ptc_obj = $(build_dir)/ptc.d

         o_files = $(obj_dir)/test.o 
     ptc_o_files = $(ptc_obj)/convert_8bit.o $(ptc_obj)/x11_8bit.o 
    fxmp_o_files = $(fxmp_obj)/fxmp.o $(fxmp_obj)/decode_xm.o $(fxmp_obj)/drv_dsp.o 
    data_h_files = $(data_dir)/music.xm.h $(data_dir)/retro_0.jtf.h $(data_dir)/retro_1.jtf.h $(data_dir)/retro_5.jtf.h $(data_dir)/tiles.jtf.h  $(data_dir)/tiles.act.h

all: quick
release: compress

quick: $(binary)

compress: $(binary)
	cp $(binary) $(target)
	$(STRIP) --strip-all $(target)
	$(STRIP) --remove-section=".comment" $(target)
	$(STRIP) --remove-section=".note" $(target)
	upx --best --no-color --overlay=strip $(target)

jeeves64: $(obj_dir) $(o_files)
tinyptc: $(ptc_obj) $(ptc_o_files)
fxmp: $(fxmp_obj) $(fxmp_o_files)
data: $(data_dir) $(data_h_files)

%.d :
	mkdir $@

$(binary) : fxmp tinyptc jeeves64 data
	$(CXX) $(OPT) $(CXXFLAGS) $(CPPFLAGS) $(o_files) $(ptc_o_files) $(fxmp_o_files) $(JEEVES_LIB) -o $@

$(obj_dir)/%.o : $(src_dir)/%.cpp
	$(CXX) $(OPT) -c $(CXXFLAGS) $(CPPFLAGS) $(JEEVES_CFLAGS) $< -o $@

$(obj_dir)/%.o : $(src_dir)/%.c
	$(CC) $(OPT) -c $(CFLAGS) $(CPPFLAGS) $(PTC_INCLUDES) $< -o $@

$(fxmp_obj)/%.o : $(fxmp_dir)/%.c
	$(CC) $(OPT) -c $(CFLAGS) $(CPPFLAGS) $(FXMP_CFLAGS) $< -o $@

$(ptc_obj)/%.o : $(ptc_dir)/%.c
	$(CC) $(OPT) -c $(CFLAGS) $(CPPFLAGS) $(PTC_INCLUDES) $< -o $@

# $(data_dir)/tiles.act.h : 
#	cd $(bindata_dir) && bin2h_unsigned tiles.act > $@

$(data_dir)/%.h : 
# obviously, this requires a compiled version of ../tools/bin2h.cpp 
# in the path. (i'm too lazy to write a test for that though :)
	cd $(bindata_dir) && bin2h $* > $@

distclean: clean clean-win32
realclean: clean-data clean

clean: clean-obj clean-fxmp clean-ptc

clean-obj:
	$(RM) $(o_files) $(binary)

clean-ptc:
	$(RM) $(ptc_o_files)

clean-fxmp:
	$(RM) $(fxmp_o_files)

clean-data:
	$(RM) $(data_h_files)

clean-win32:
	$(RM) ../VisualC/release/*
	$(RM) ../VisualC/debug/*
	$(RM) ../VisualC/*.ncb
	$(RM) ../VisualC/*.opt
	$(RM) ../VisualC/*.aps
	$(RM) ../VisualC/*.plg

dist: compress distclean backup

backup:
	rm -rf /tmp/$(PACKAGE)-$(VERSION)
	rm -f /tmp/$(PACKAGE)-$(VERSION).tar
	rm -f /tmp/$(PACKAGE)-$(VERSION).tar.gz
	mkdir -p /tmp/$(PACKAGE)-$(VERSION)
	cp --archive ../* /tmp/$(PACKAGE)-$(VERSION)
	tar --directory=/tmp --create --exclude="*~" --file /tmp/$(PACKAGE)-$(VERSION).tar ./$(PACKAGE)-$(VERSION) 
	gzip /tmp/$(PACKAGE)-$(VERSION).tar

crlf: 
# this stuff requires hany's dos2unix - which I found at
# http://www.megaloman.com/%7Ehany/_data/hd2u/

# gcc doesn't like files with dos-style line termination.
# (and Visual C++ doesn't complain about them).
	find ../ -type f -name "*.cpp" -exec dos2unix --d2u {} \;
	find ../ -type f -name "*.h" -exec dos2unix --d2u {} \;
	find ../ -type f -name "*.c" -exec dos2unix --d2u {} \;
	dos2unix --d2u ./Makefile
# notepad doesn't like unix-style line termination.
# (and less/vi/emacs/etc,... can cope with it).
	dos2unix --u2d ../ChangeLog
	dos2unix --u2d ../readme.txt
	dos2unix --u2d ../todo.txt

render: get-font get-pattern
# this definitely only works on my system, it consists
# of the font decoder and pattern boundary decoder ;-)
#
# recommended use is `make render data' to make sure the header
# files are updated too.
#
# here goes:

get-pattern:
# [PATTERN BOUNDARY DECODER]
# - use a modified fxmp-0.0.20 to get the pattern boundaries
#	to be used with my crappy fxmp_get_bytes kludge for waveOut timing.
	/home/warp/code/fxmp-0.0.20-v5-bytes-v2/player $(bindata_dir)/music.xm
	cat /tmp/music.xm_patterns.h > $(data_dir)/music.xm_patterns.h
	$(RM) /tmp/music.xm_patterns.h

get-font:
# [FONT DECODER]
# - fetch font data files from deluxe paint directory.
# - make a copy of it for the (adapted) fontripper.
# - execute the fontripper.
# - fetch the result.
#
	$(RM) $(bindata_dir)/rexim.lbm
	$(RM) $(bindata_dir)/tiles.lbm
	cp /mnt/art/archive/Graphics/oud/dp/rexim.lbm $(bindata_dir)
	cp /mnt/art/archive/Graphics/oud/dp/tiles.lbm $(bindata_dir)
	cp $(bindata_dir)/rexim.lbm /home/warp/code/fontripper-0.2-jeeves64/data
	cp $(bindata_dir)/tiles.lbm /home/warp/code/fontripper-0.2-jeeves64/data
	cd /home/warp/code/fontripper-0.2-jeeves64 && src/koek
	cp /tmp/retro_0.act $(bindata_dir)/retro.act
	cp /tmp/retro_0.jtf $(bindata_dir)
	cp /tmp/retro_1.jtf $(bindata_dir)
	cp /tmp/retro_5.jtf $(bindata_dir)
	cp /tmp/tiles_0.jtf $(bindata_dir)/tiles.jtf
	cp /tmp/tiles_0.act $(bindata_dir)/tiles.act
	$(RM) /tmp/retro_*

