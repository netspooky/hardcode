


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
            . ..::::::           .8K Reality.           :::::::. .
       .. . .........:       --------------------       :.......... . ..
        '            :                                  :    .        '
  ...................:                                  :.../_  /_............
                                                             /   /

                                  .Credits.
                                  ---------
                      Code:         Seven
                      Music:        El Blanco (original: Purple Motion and Skaven) 
                      tools used:   Crinkler, Shader Minifier and mutant Clinkster

                                .Requirements.
                                --------------
     * A fast video card with lots of Pixel Shader 4.0 compatible shader pipelines.
       The intro has been tested on AMD and NVidia cards with recent drivers. If you have
	  a slower GPU, try the low-resolution version
     * 1.5 GB ram (mainly for the Crinkler decompression)
     * Developed on Windows 7, compo machine was 8.1 (might run on XP, but that's untested)
     * 8 kb diskspace
     * If it seems your computer hangs, give Clinkster some time to generate the music.
	  It's 9 minutes of music, so this can easily take 30 seconds to a minute if your
	  CPU is not very fast. And the versions with high-quality music take even longer!
	* The first minute of the intro shows a black screen. Don't try to adjust your set.

                              .About the intro.
                              -----------------

You can find a longer and illustrated version of this on: 
http://www.fulcrum-demo.org/2015/8k-reality/

And a very detailed writeup about the music can be found here:
http://elblancosdigitaldreams.blogspot.be/2015/04/getting-real-pt-1-are-we-crazy.html

Seven at the keys here. I had the idea to make a size-limited version of Second Reality
for a long time, but 4K is obviously too limited. Las had been bugging me at GhettoScene
2014 to make an 8K for Revision. When Second Reality was 20 years old, Future Crew open-
sourced the code and the music under an unlicense (do whatever you want). While the code
was of little use (indexed mode tricks, finnish comments,...), the permisive license for
the music meant we could adhere to the GEMA-rules at Revision. Since I had no other ideas,
I gently tested the willingness of our musicians to try something this crazy. El Blanco
volunteered to give it a shot.

Luckily, he was busy selling a house, and I had forgotten to mention to him that Clinkster
came with a set of example instruments, so his progress was slow. Luckily because, if he
had immediately delivered the first cut of the soundtrack, I'd have said: "SEVEN KILOBYTES?
Let's forget this and focus on finishing our demo for Revision." Instead, I started working
on minimalistic versions of various scenes, trying to get an idea how much space the
shaders would need. I hoped to have about 3 KB shaders, 1 KB images, 0.5 KB init code, which
would leave 3.5 KB for the music. We decided from the start not to do the endscroller, and
the end credits could be dropped if needed. We knew we would exceed the 8 minute time limit
from the Revision comporules, but having seen in the past how the organisers go out of their
way to make things work (the Limp Ninja "our entry broke the beamer" stunt comes to mind),
I hoped they would be flexible.

Besides the music, which is the part of Second Reality that has aged the best and that we
knew we had to get right, there was also the issue of the graphics. Second Reality has a
number of showcase graphics that we couldn't just drop. Some of those were trivial to
create with a raytracer/marcher, such as the spheres over water and the hexagonal nuts at
the end. But the title screen, the mountain troll, the demon face and the amazon-on-icebear
posed a problem. Since they are not nearly as important as the music, I decided to use a
random generation approach inspired by the fantastic Mona 256 byte intro, but with
triangles instead of lines. I wrote a generator that compared the original image with a
set of randomly-generated triangles colored with a palette of 4-8 handpicked colors. I had
hoped about 100 triangles per image would give something recognisable, which was the bar
we hoped to pass. 4 images, with 100 2-byte random seeds plus palttes and generator code
would fit nicely in 1KB. The results were mixed, images with big areas of similar color 
were OK, like the demon face, but the others looked like abstract art at best. Much
experimentation with triangle size and color strategies ensued.

Meanwhile, Work on the demo was halted completely, as my brain couldn't stop focussing on
the intro. More scenes were converted to shaders with varying levels of authenticity. Using
the Windows Speech API to add the "Get down", "I am not an atomic playboy" and "10 seconds
to transmission" samples was trivial, and took only 210 bytes (default female voice only).
I wasn't sure about the final size of any of the code/music/images, and anything that went
over its size budget could end the production. So feelings fluctuated constantly between
"Hey, we can do this if we try hard enough" and "it'll never work ands we're crazy for even
trying", occasionally veering into "this idea is so obvious that someone else will also try
it at NVscene/Tokyo Demofest/Revision" paranoia. El Blanco checked in longer and longer
versions of the music, doing his best to imitate the sound of the original to a T. Skaven
made instruments hop around channels like crazy, intentionally using the side-effects to
shape the sound. And while Purple Motions composing was much closer to the modern 1 instrument
1 track norm, he used untunes samples so converting those to Clinkster was time-consuming.
I had a bad feeling about the speed with which the music grew (500 bytes for 20 extra seconds),
but  I rationalized that by now, he must have created all instruments and anything new would
be note data only. 

10 days before the party, the music was ready. Together with the extremely minimal shaders
(for example, the hexahedrons on the chessboard just rotated, without bouncing, swaying,
appearing or disappearing), it clocked in at 12 KB. We clearly had a problem, and since there
wasn't enough time to finish the demo (which has lots of missing art, and a busy graphician),
we had to fix it (hard), release it in the 64K compo (disappointing) or release nothing at all
(even more disappointing).  

I ditched the random-generator approach to the images, since Crinkler actually increased the
size of the random seeds to 110-115 % during compression. In contrast, shaders compress to
20-40% of their original size, and having more shaders benefit the compression ratio of all
shaders. I also started reading the Clinkster code and manual, hoping to find ways to make
the music smaller. It turns out the oldskool "1 instrument, many tracks" meshes really badly
with Clinkster. It includes the instrument definition once per track that uses that instrument,
plus enumerates all the note/velocity/length combinations that are played in that track. So El
Blanco started shuffling instruments and notes around, dropping the amount of instruments that
Clinkster generated from 69 to below 30. That also cut the precalc time (more than a minute) in
half. Too bad it also triggered a Clinkster bug: if you have more than 127 note/velocity/length
combinations, Clinkster stops generating notes prematurely and the music sounds corrupt. Once
we knew the cause the fix was easy, but it took a few days of panic before we got that far...

Despite all reordering, the music was still too big, so El Blanco started to cut down on notes,
reusing some instruments and other measures that lowered the quality. Meanwhile I let Shader
Minifier run on the biggest shader, and fixed the other shaders by hand, since we use shader
stitching with a common prefix part containing the RNG, rotations, 2D noise etc, and a common
postfix part with the render loop. One day before the party, and with some more cuts to the
music, we were sure we would have an 8K version to release, albeit without the voices, and some
parts that were rather boring. At the partyplace, I tested the intro on the compomachine with
Las/Mercury, who was extremely helpful. He agreed that, as there weren't that many 8Ks, the
timelimit could be stretched a bit, and he helped me find a quiet spot to continue coding
without having to worry that people would see my screen and know what I'm working on. I kept
optimizing the shaders, converted the intro to assembler and managed to find enough to put back
in the voices, plus some improvements to the scenes. Unfortunately, when I finally handed a
finished version to Las, it crashed on the compomachine... Some panicked debugging later, the
culprit turned out to be ... the voices, which the compo machine doesn't support. No idea why,
since SAPI has been delivered with windows since XP! Anyway, we were so close to the compo (well
beyond the deadline) that I had to make a version without the voices :( Luckily, the public
liked it anyway.

After the compo we got lots of feedback on Pouet. Many people didn't like the absence of the
transitions, while the voices were not popular, or even seen as a bad point. Hence, the final
version does not have voices, and in the remaining space I packed as much transitions as I
could. I think the result is indeed superior, and I regret that I couldn't show this version
at the party...

Greetings to all the people at Revision that I could only briefly talk to, due to too
much coding: Skyrunner, Blueberry, Crm, Deeper, Las and any others I forgot. Thank you to
everyone who liked the entry and told me so, it's the main reason to keep spending a lot more
time on this than is healthy. A big thank you to El Blanco for being the Goldilock musician
this intro needed: any faster and I'd have aborted the project, any less skilled and we
wouldn't have been able to fit the music in at the end. And a final huge thanks to Kaatje
and the kids, for having so much patience when daddy is on a coding binge again.

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
