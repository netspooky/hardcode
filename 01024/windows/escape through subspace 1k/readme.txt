


                                 .:- - - - -:.
                                 .: FULCRUM :.
                       : _____.:\|\_________/|/:.____ :
    _    ._      _  _._:_\   ___ '           '___   /_:_._  _      _.    _
          ...  . .....\| \\:.  .    . :: .    .   :// |/..... .  ...
    .      \           |  \: :..  .         . ..: :/  |           /
  _/|___  _/|____    _/|__ '    _/|____   _/|____ ' _/|____     _/|_____  _
__\_ ._/__\  \  /____\   /     _\  ___/___\  __ /___\  \  /_____\_.    /____  _
\ `    __/ `  \'    \ `   \ ___\ ` \     \   |/    \ `  \'    \ ` .   ' .   \
_\     \  \   |\     \_   |\    \  |\     \_ '.     \_  |\     \_ |\     \   \_
 /__    \ /______     /____     /__        /___\     /_____     /___\     \___/
    \  __\fulcrum\ ___\|   \ ___\  \ ______\    \ ___\|sim1\ ___\2o14\ ____\
  _  \|:::::::::::\|  ':    \|  '   \|     '     \|   ::    \|::::::::\|   '
      '         ::::.:.:     '       '            '   :.:.::::         '
                     :         .p.r.e.s.e.n.t.s.        .
                     :                                  :
                     .                                  .
            . ..::::::    Escape Through Subspace 1K    .           :::::::. .
       .. . .........:    --------------------------    :.......... . ..
        '            :                                  :    .        '
  ...................:                                  :.../_  /_............
                                                             /   /

                                  .Credits.
                                  ---------
                      Code, "music": Seven
                      tools used:    Crinkler, custom tools

                                .Requirements.
                                --------------
     * To run perfectly, this 1K should run at exactly 60 FPS. Otherwise it will run slower
          or faster than it was designed for. To ensure this, you need:
        - A very fast video card with lots of Pixel Shader 4.0 compatible shader pipelines.
          It was designed to run in 1280*720 mode on a GTX 970, but the organisers changed
          the hardware and beamer resolution in the week before the party. I don't expect
          the 1920*1080 to run correctly on anything slower than a GTX 1080. For AMD, the
          RX 480 is plenty fast for the 1280*720 version. And intel cards won't run this.
          Sorry for the high hardware requirements but a 1K doesn't leave much space for
          speed-optimisations.... The intro has been tested on AMD and NVidia cards with
          recent drivers. 
     	- V-Sync set to Always On in the drivers
     	- AMD Optimize Power or the equivalent Nvidia feature that limits the FPS to 30
          should be turned off in the drivers.
	- The safe versions have the same requirements. The only differences are the shader
          without glsl warnings, safe Crinkler options and less questionable hacks.
     * 200 MB ram (for the Crinkler decompression)
     * Tested on Windows 7 and 10, might even run on Windows XP
     * 1 kb diskspace

                                  .Thank You
                                  ----------
           - Kaatje and the kids for giving me time to work on this release
           - Blueberry and Mentor for Crinkler 2.0. Most people have no
             idea how amazing this tool is, and the new features are a lifesaver!
           - Tom Lowe for discovering the Mandelbox fractal
           - Knighty for the Cosmos fractal
           - IQ for creating Shadertoy
           - Sir GarbageTruck and Johan Burell for quality-checking the name.
           - Las/Mercury for a certain optimisation that caused me a lot of pain
             on the compomachine, but that I still needed in the end.

   

                              .About the intro.
                              -----------------
This 1K was made for the Assembly 2016 party. It's been a few years since I visited Assembly,
and I wanted to make a high-quality release. 2 months before the party, we started investigating
various music strategies (CPU waveout, Midi, GPU waveout) but Midi is still king for 1K sound
generation.

I wanted to the visuals to be something more than the usual 1K abstract fractal art,
but a quick port of our previous 1K (Dystaxia, from 2013) from 1KPack to OpenGl + Clinkster 2.0,
showed that even with the nice new TINYINTRO and TINYHEADER features, we simply didn't have the
space to show any realistic objects. So, 1 month before the party, back to fractals it was. You
simply can't beat them for compactness, nice looks and combining large-scale features and details.
When looking at fractals on the net, I came upon a really nice-looking castle created by
intersecting a Mandelay fractal with a heightmap, and so got the idea of a spaceship-mandelbox
hybrid. A first version with the camera flying straight ahead over the ship was easily done,
and adding Knighty's Cosmos fractal gave a nice background.

Due to family circumstances, Coplan had to drop out, and our other musicians were busy. So, I
decided that ambient space noise would do, and I could do that myself. (Yes, I know there's no
sound in space. Sometimes reality would make a poor compo experience). I delayed working on the
music, though, and improved the visuals with fake reflections, the green Borg glow (Thanks to
Yncke for the idea) and some camera motion. The green glow caused a visual artefact outside the
ship that looked like a purple glow at low raymarching precision, so I co-opted that in a warp-effect.

2 weeks before the party, while working on the intro, my videocard gave up the ghost (Radeon HD
7870, rest in peace). That caused an involuntary 4-day break while I waited for an RX480 to arrive.
On one hand, I was happy that this didn't occur a month before, when the new high/midrange 14nm
cards from Nvidia and AMD were announced but not available, or a week later and closer to the party,
but I had really preferred to wait for the prizes in Euro to drop a bit. But at least the new card
gave me similar performance as the compo-machine spec.

At this point the music consisted of a single midi note, just to include the midi initialisation code
so I had a rough approximation of how big the intro was. I figured reserving 30 bytes extra would be
enough for some extra midi-noise. But when I started adding the music I was negatively surprised...
With the camera flying over the ship, I wanted to have sound fading in and then fading out, and adding
this already consumed all space. Adding some more variation in instruments, tone and fading speed pushed
that up to 50 bytes over the limit :( 

The final week was spend looking over both the shader code and the assembler part again and again,
looking for tricks and hacks to save space. The camera motion could be simplified, some register
values are in a known state after Crinkler decompression, instructions were re-ordered and countless
shader variations were tested. The improved stability of Crinkler 2.0 was really a life-saver here,
it used to be that a simple re-ordering or a 1-byte change could the Crinkler result to vary by plus
or minus 5 bytes, whereas you now get stable results on the fractions-of-a-byte level. That really
helps to separate the good changes from the bad.

The size slowly dropped to the 1K limit. Inbetween I found a way to colorize the Cosmos fractal with
just 2 bytes that I really wanted to keep. Much re-tweaking of parameters ensued, because while it	
looks 3D, the stars are actually a 2D fractal, and a discrete one at that: if you drop the speed of
the stars too much, the fractal behaves like a slideshow, with stars jumping from position to position.
And you cannot change the size, amount and brightness independently either, any change influences everything.

I had expected having to cut *something* to make the cut, but 2 days before the party, I managed to
remove the final byte. Then I noticed the Assembly website had upgraded the supported beamer resolution
to full HD, with a videocard upgrade to match (GTX 1080), so I made a full HD version as well, which was
1K without any changes. And so, for I think the first time, I got an entry entirely done before the party.
It worked on AMD and Nvidia, and I upgraded the laptop just to test it on Windows 10. Unlike the past
Revision parties, I wouldn't have to spend days in the compo room to get my entry working.

Queue Friday, by which time the compo crew pretty much regarded me as an intermittent part of the furniture
in the comporoom. While the 720p version ran fine on the AMD compomachine (albeit slower than on an RX480),
the NVidia machine refused to run any version. Much detective work later (Was it the shader? The assembly
hacks? The dual-screen setup? The driver version? The driver settings? The attached hardware? Unsafe Crinkler
options?), it turned out to be a combination of a driver change and an assembly hack, although I still have
no idea why it didn't happen on at least two other nvidia machines. Anyway, the fix was literally 1 bit, and
the final 1080p version even dropped one byte to 1023.

Now, lets's hope the audience likes it...

                      .                                  .
                   .:._\  _\.............................:..
                    : \   \                              :
                   ::  '   \ Fulcrum memberstatus:       ::
                    :      ------------------------      :
                   :.   seven.....................code   .:
                    :   coplan...................music   :
                    :   el.blanco................music   : 
                    :   ranger.rick..............music   :
                    :   the.watcher.........code,music   :
                    :   yncke.................graphics   :     .
                     ::                                ::     /     .
  ....................::......... . . . . . ..........::...../_    /_.......
                     :                                  :     /     /
       .: . .........:          visit us at :           :..../..... . :.
                    .:         ---------------          :.  '
           ' ''::::::: . http://www.fulcrum-demo.org/ . :::::::' '
                  .  :       .          .             . :
                _/|__:     _/|___     _/|_____      _/|_:_
               _\ _   \_ __\_ ._/__ __\_.    /______\.__ /__        -
         _     \  |\    \\ ` .____/_\   .   ' .   \ ` \|    \ -    _
      _    -   _\ |_\    \\_  \|    \\  |\     \   \_  '     \_         _
                /____      /_  '     /____\     \___/____     /
                 demo\ ____\ \ ______\sim:1\ ____\tlp.ttn\  __\
                      \|    ::\|            \|  ::     .wt\|
                       '   .::.':.   DEMO   .: .::.        '
                                / - - - - - -\
                   ascii:..sim1/theloop,.titan,.wanted.team

                                    - - -

                       : use AMIGA TOPAZ fonts, please :

                                      -
