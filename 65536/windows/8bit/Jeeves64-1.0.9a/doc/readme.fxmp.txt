../src/fxmp contains a modified version of fxmp-0.0.20.
basically tailored for use in 64k intro's, but also some fixes
were done to make things work on win32, including waveOut support.

perhaps more changes have been made, check ../ChangeLog for details.

The most important changes for 64k intro development are:
  - the load_xm.c has been adapted to read an .xm from memory and not from a file. 
  - most printf's have been commented out or removed entirely.
  - only drv_dsp is included, drv_seq has been removed (sorry smoke :)

Warp of Bliss (aka Kuno Woudt)
<warp-tmt@dds.nl>

ps. last I checked fxmp was available at
http://www.linuxstart.com/~spectre/fxmp/fxmp-0.0.20.tar.gz

Original README contents:
-------------------------------------------------------------------

Development version of Flare XM Player.

Test it, learn from it, etc.


Spectre of Flare (aka Osman Keskin)
spectre@winterland.net
