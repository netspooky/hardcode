      ____
   . /    \  Jeeves64. (c)2000 by bliss  
 .:: \__/ /__  ________  ______  ______ 
 _____/   __ \/ __  __ \/   __ \/_  __/ 
 \    / /   _/\  __/_\ /  /  __/_\  \   
  \____/ \__________/ /__/ \________/ 64.   

[last updated: 2000/09/28] 

  Hi!

 [intro]

  You're reading the README for Jeeves64, an application framework for
  64k GNU/Linux and win32 intro development. 

  Jeeves64 makes use of fxmp by Spectre of Flare and tinyptc by Gaffer.
  Have a look at their readme.* in the doc/ directory for more info.

  (during development, some changes have been made to both tinyptc and
   fxmp, most (if not all) of these changes have been documented in the
   ChangeLog or in their respective readme.* in the doc/ directory)

  The provided binaries have been compressed with `The Ultimate Packer
  for eXecutables' by Markus Oberhumer & Laszlo Molnar.

  Abovementioned tools and libraries are available from these URLs:      
  
  fxmp:       http://www.linuxstart.com/~spectre/fxmp
  tinyptc:    http://www.gaffer.org/tinyptc
  upx:        http://wildsau.idv.uni-linz.ac.at/mfx/upx.html,
              http://www.nexus.hu/upx, http://upx.tsx.org

 [license]

    Jeeves64 v1.0.9, Copyright (C) 2000 Bliss

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; see the file COPYING; if not, write to 
    the Free Software Foundation, Inc.,
    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

 [quickstart]

   windows and linux binaries should be available in the previous
   directory, look for ./8bit and 8bit*.exe.

 [build]

   build instructions:

   -> Linux
        cd into the ./GNU-Linux directory and type `make'.
        (resulting binary is ./test)

        type `make release' if you want to compress the binary.
        (resulting binary is ../8bit)
     
   -> Win32
        open the test.dsw workspace in the VisualC directory
        with Microsoft VisualC++ 5. (6 should probably work with
        some small adjustments, but has not been tested at all).

        choose `Rebuild All' from the build menu.
        (resulting binary is VisualC/release/test.exe)

        edit and run scripts/compress.bat to produce a compressed
        compo version (8bit.exe).

   There are some more options in the Makefile mostly for converting
   the data files in ./data. These options however, have been tailored
   for my linux box and will not be of any use without modifications.
   (however, look in the ./tools directory for some of the tools used 
    before doing that).
     
 [support]

   Don't hesitate to mail me if any problem should arise.

   -- kuno <warp-tmt@dds.nl>

 [ps]
   ow. and in case your wondering, Jeeves is a recursive acronym:

   "Jeeves Establishes an Experimental Visual Expression System".
