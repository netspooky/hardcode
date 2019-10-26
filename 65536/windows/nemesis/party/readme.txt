nemesis
version 1.01 - now without crash! (hopefully)
excess vs. kvasigen
music powered by sanestation
1st place, 64kb compo, the gathering 2004

made by

  titanstar     code          runehol@math.uio.no
  sesse         code          sgunderson@bigfoot.com
  kusma         code/design   kusma@68k.no
  gloom         design        bent@lorien.no
  lug00ber      music         g00ber@dyret.com
  optimize      music         optimize@online.no

not-quite-final version. lots of the design should still be improved and
a lot of the parts are empty, but we'd rather get it out now and be done
with it.

you need

  - a fast machine (1ghz or so, more preferred), running windows, mac os x
    (10.3 or newer) or linux.
  - opengl acceleration with support for pbuffers (for decent
    render-to-texture), multitexture and a few other minor things. most ati
    or nvidia cards (think geforce256 or newer) will do just fine, but faster
    cards = more framerate, of course. don't watch demos on crappy cards or
    with crappy drivers, please.
  - a sound card.
  - if you're running linux, you'll need the the arial black truetype font
    file in one of the following locations, or the intro will complain:

       /usr/share/fonts/msttcorefonts/Arial_Black.ttf
       /usr/share/fonts/msttcorefonts/ariblk.ttf
       /usr/share/fonts/truetype/Arial_Black.ttf
       ./ariblk.ttf

    if you're running debian, install the package msttcorefonts from contrib
    and you should be fine. other distributions probably have equivalent
    packages, or you can get the files from corefonts.sf.net.

    if you have a problem with the fact that we want the intro to look the
    same on all platforms (and thus needs that file + freetype), look at it
    as just a really small demo. we don't care; we're tired of hacking
    binutils and tweaking code to get under 64kb in the first place. (also
    remember to have 640x480 set up as a resolution in your xf86config.)

  it should be quite obvious how to run the intro. remember to chmod +x the
  appropriate binary on linux and mac os x, of course.

greets go out to

  aardbei, acme, array, bypass, cellfish, coma, contraz, darkzone, ephidrena,
  fairlight, gollum, granma, haujobb, inf, komplex, matt current, nocturnal,
  purple, progress, prone, proxima, razor1911, rebels, sorrox, skulls,
  spaceballs, the black lotus, the shrimp brigade, the lost souls, unique,
  yaphan

  special thanks to leia for letting us work on nemesis at her place before
  tg, to ati devrel for generally being friendly and helpful people and to
  sverre holm for dsp consultancy. :-)

[eof]
