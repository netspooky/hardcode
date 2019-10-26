Jeeves64 uses a modified version of tinyptc, read below for more info.
tinyptc is available from http://www.gaffer.org/tinyptc.
---------------------------------------------------------------------

  Hi!

 [8bit?]

  Yes!. As this intro doesn't use lots of colours it will probably
  look almost as good in 8bit which should be a lot faster. So i've
  `ported' the tinyptc versions I use to accept 8bit buffers and
  introduced a ptc_setpal() call.

 [x11]

  I hacked this in a few hours with no previous X11 experience,
  so I may have made some terrible mistakes. I've only tested XShm
  in 8bpp, 16bpp and 32bpp modes on my box.

 [win]

  I only hacked ddraw.c and removed gdi.c and vfw.c from the archive
  as things seem to be working fine (again tested in 8bpp, 16bpp and
  32bp windowed, fullscreen is probably allways 8bpp and therefore
  has not been tested in other bitdepths). 

 [bye]

  Questions, suggestions, bug reports and flames are encouraged. 
  -> try <warp-tmt@dds.nl>.
  
---------------------------------------------------------------------
UPDATE: I have had some segfaults on my box with tinyptc-x11-0.4,
which I narrowed to a call to XDestroyImage() in x11.c. So i've just 
commented it now, and send a message to the tinyptc-x11 maintainer.

UPDATE: maintainer confirmed incorrect tinyptc behaviour on XF86 4.x.
---------------------------------------------------------------------
UPDATE: Gaffer posted this in nntp://news.scene.org/coders.ptc.

Ive found a bug in tinyptc that makes it run slow on some drivers - its a
very simple fix, just go to ddraw.c and change DDBLT_WAIT to 0 in the Blt
call.

this will get rid of slowness and choppiness on higher res displays in
fullscreen mode

very annoyed that drivers suddenly started going slow on DDBSL_WAIT, they
never used to ... =P
---------------------------------------------------------------------

