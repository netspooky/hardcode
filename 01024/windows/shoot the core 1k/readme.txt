


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
            . ..::::::         Shoot The Core 1K        .           :::::::. .
       .. . .........:        -------------------       :.......... . ..
        '            :                                  :    .        '
  ...................:                                  :.../_  /_............
                                                             /   /

                                  .Credits.
                                  ---------
                      Code, "music": Seven
                      tools used:    Crinkler, custom tools
		      design feedback: Yncke, Coplan, El Blanco

                                .Requirements.
                                --------------
     * TL;DR: the safe version is a lot less demanding, you may want to run that.
     * For the compo version to run perfectly, it should run at very close to 60 FPS. 
 	  Otherwise it will run slower or faster than it was designed for. If your videocard
	  isn't fast enough (most likely, as even the compo machines RX580 or GTX 1070 struggle
	  with it), it's best to turn V-sync off in you graphics card driver settings, to
	  prevent the framerate from being locked to 30 FPS and the intro taking twice as
	  long as it should. If you have a GTX 1080 TI or some future AMD Vega card, turning
	  V-Sync on (and using a 60 FPS monitor) will prevent the intro from running too fast.
	  The intro runs faster on a RX 580 than a GTX 1070, despite the latter being a faster
	  card, so I guess it fits AMD hardware better. Sorry, Intel cards probably won't run
	  this.
     	- AMD Optimize Power or the equivalent Nvidia feature that limits the FPS to 30
          should be turned off in the drivers.
	- The safe version has is twice as fast due to an added early-out test, and has no
	  V-Sync requirements. Additionally, the shader has no glsl warnings, safe Crinkler
	  options were used and the more questionable hacks were removed.
     * 100 MB ram (for the Crinkler decompression)
     * Tested on Windows 7 and 10
     * 1 kb diskspace

                                  .Thank You
                                  ----------
           - Kaatje and the kids for supporting me with time and encouragement
	   - 0x4015, whose fantastic 4K trilogy was the inspirational seed for this intro.
           - Blueberry and Mentor for Crinkler 2.0
           - IQ for his neat 1K lighting trick that I abused in various ways.

   

                              .About the intro.
                              -----------------
After last year, I simply had to make another 1K intro for Assembly. Even in 8K and 4K intros,
design and direction are overtaking technical know-how in importance, so as a technical coder,
I'm really happy with Assembly's smallest Category: big enough to use shaders, but small
enough that byte-hunting matters. 

I started 2 months before the party with an idea for a fractal castle or cathedral, which
mutated a bit along the way but finally went nowhere: it was ugly, boring to watch, and
already too big to fix the other flaws. So I restarted the search for inspiration. For me, a
good 1K idea should be ambitious enough that you're not 100% sure it fits in 1K. Then, with
enough time and elbow grease, you find compromises, synergies and ways to make it work. I'm a
fan of 0x4015 and YET11's 2nd Stage Boss, so I decided to try a similar boss-fight in 1K. The
key to make it work would be to generate all the visuals (the boss, the ship and the level) 
from the same fractal. Of course, While I worked on this, Fairlight sniped this idea in their
stunning Unprogress 4K, but that's life...

I had some basic ideas on what shapes the fractal should be able to generate (ship: symmetric
and sleek, boss: big and organic, level: angular with fixed size of details). After testing
several fractals, I decided on a modified menger sponge. You can raymarch those either by
starting with a big cube and punching various sizes of holes in it, or you can fold space
over and over to map on a single small cube. The latter approach gives you a far wider
variety of shapes, when you throw some rotations in the mix, so that's what I used.

The boss and the level were designed quite fast, the ship gave me more trouble. Initially it
was a far smaller stubby tube traveling cross-section-wise with small forward points on each
end serving as "wings". Only a few days before the party did I stumble on the current design.

For the story, I was hoping to do 5 scenes: the empty level, the ship flying, lasers
shooting at the ship, the ship returning fire at the boss, and the ship flying away. That
was easiest done with the boss at the center of the coordinate system, the ship flying in
a straight line and the camera following an offset line, but with a parabolic speed, so it
moved slowest when nearest to the boss. It also alternates looking left and right, and also
jumps through space. Tweaking the various parameters (ship speed, cam speed, cam angle, cam
jump distance/frequency) to have no long periods where only the level is onscreen was a
slog, and had to be redone several times due to feedback from the other Fulcrum members
who served as Guinea pigs. For example, it was unclear if the lasers where coming from
behind the ship or from the front, so I made them start earlier, in a shot where the camera
looks forward.

Size-wise, it become obvious there was no room for music, or even sound effects, unless I
cut something. I removed my normal-based lighting and used a trick from IQ to do diffuse
lighting with a single distance-function lookup. By tweaking the distance where this
distance was evaluated, and due to the fixed-size details of the level fractal, I managed
an extremely fake soft shadow on the level walls. I also found a way to fake a light flash
when the laser fired, but commented it out as I didn't think I'd have the space for it.

For the music, I had extended my MidiHack prototype with tracks, and tried to organize the
notes and velocity in the most compact way. At that stage I was still hoping to maybe
shove it to on of our musicians and have him suffer a tune out of it, but as the visuals
got more complex (boss explodes at the end! ship outruns explosion!), the remaining space
for the music shrank until I decided to go for sound effects only, and the most simple one
that would work somewhat: a hi-pitched telephone for the laser sound, and a simple 3-note
background drone. With so little note data (2 tracks of 8 slots, 3 notes bass and one note
on/off combo for the laser), it was smaller to store the complete midi commands directly in
memory, instead of combining them in code. This also allowed me to store the instrument-
setting commands inside the track, so I could cut the channel initialization code.

This gave enough room for the laser flash to make a simplified comeback, the colors were
decided, and the intro was in almost done. I wanted to if add an explosion sound, at the
end, when Coplan asked for some way (color, frequency, sound) to differentiate the boss
laser from the ship laser. A side effect of storing entire midi commands in tracks is that
any track can play notes, or more generally commands, on any channel. So I added a third
and fourth channel (which start at different delays) to change the instruments used in
the first two channels. So the laser sound switches to a rock organ for the ship, and then
to a timpani because that is silent at that high tone, and the bass switches to a 
harpsicord (well-known for their explosive sound). This requires careful syncing because
the first two tracks still set their channel to their original instrument with every loop,
so the new instruments must be set after that and before notes are played. The resulting
note shuffling caused the first bass note to be played with the default instrument,
which is a piano, which actually sounded OK.

In the last days, the ship changed to its final shape. At the party, I found a way to fold
the laser flash approximation in the laser code, so it could use the real code and the
light/shadow pattern moves correctly (less so on the ship, which has details on a
different scale than the level walls). Also Yncke's suggestion to make the lasers
propagate so you can see it's the boss firing towards the ship was doable in the most
minimal way, with a moving sine pattern on the boss beam. Inbetween all this, hour-long
re-ordering sessions repeatedly pushed the size from +- 10 bytes above the limit to just
below it. I checked which instructions the Crinkler link code uses (which is compressed
together with the intro) so I could use the same instructions as much as possible. The
note data was stored backwards and in reverse channel order, because then I could use
some old 8-bit instructions that were smaller (CMP AH for the win!)


Two days before the party I had seen that the GTX 1080 in the compo machine had been changed
to a 1070, which caused some stress, but at the partyplace it turned out the RX 580 actually
ran it better. While I'm very happy with how much I managed to cram in the intro, the
system requirements are not something to be proud of. As atonement, I made a faster safe
version that doesn't require any V-sync or other driver setting changes. I hope this way,
most people can still watch it realtime (it runs 20-30 FPS on my GT 765 laptop).



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
                    :   yncke.................graphics   :    
                    :   miss.saigon..............music   :
                    :   kneebiter.................code   :    .
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
