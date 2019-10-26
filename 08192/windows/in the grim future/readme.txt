


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
            . ..::::::         In The Grim Future       .           :::::::. .
       .. . .........:         ------------------       :.......... . ..
        '            :                                  :    .        '
  ...................:                                  :.../_  /_............
                                                             /   /

                                  .Credits.
                                  ---------
                      Code:         Seven
                      Music:        El Blanco
                      tools used:   Crinkler, Clinkster,custom editor/minifier

                                .Requirements.
                                --------------
     * Several minutes time to compile the shaders (on Nvidia, Amd takes less
	than a minute)! On my old laptop, it takes 5 minutes before the intro
	starts the first time. On later runs, the driver should have cached the
	compiled shaders.
     * A very fast video card, the compo machine has a Titan X so I focused on
       completing the intro instead of speed-optiming it.
     * 1.0 GB ram (mainly for the Crinkler decompression)
     * Developed on Windows 7, tested on Windows 10
     * 8 kb diskspace
   

                              .About the intro.
                              -----------------

The idea for this intro arrived in fragments over the years. The most obvious
piece is A Certain Game Franchise with 40K in the name, which I've never played
but that I've read about, and I always associated the 40K with an intro. The
Hello Kitty parody of  their motto "In the grim darkness of the far future, there
is only war" may also have planted a seed. Then at Assembly 2016, The Digital
Artists (TDA)  released a lovely 1K "Affinity" that demonstrated how to destroy
a raymarched object. So I could do an intro with tanks fighting, and damage them
with space deformations. Assigning each tank to a demogroup for greetings would 
give some variation and personality to the tanks.
s

I tested space deformations to cut or pierce objects, which looks quite OK
statically. I also started on a simple tank model, but the real work began after
Under Construction'16. It quickly became clear that 4K was too limited. The idea 
wouldn't work with just 2 or 3 tanks, and having more tanks meant we had to bring
some variation in how we destroyed them. So we decided on 8K. Since I wanted to
greet groups that actually compete against us in that category, we had to change
the names. I kept TDA, although they haven't made any 8Ks (yet), for the deformation
idea and the iPod-based tank design I had already (they make Mac intros). Loonies
got an Amiga tank, TRSI something based on oldskool design (checkerboards, chrome
spheres), DMAs 8Ks are made entirely by KK, so he got a tiny one-man tank, and
Alcatraz got the original tank I made that Yncke wanted to keep, from some coppery
metal based on Galvanize. Our own tank had to be "high-tech but ugly" (hey, we know
our weakness! Any designer looking for a group?)

We ran in quite some technical difficulties, both AMD and Nvidia threw their share of
internal compiler errors (out-of-memory). That's the reason that each scene has it's own
shader, from a combination of common and scene-specific parts. Unfortunately this
means the intro takes several minutes before it starts to run, as instead of one
gargantuan shader, it now has to compile 14 merely huge ones. The deformations that
I had started with ended up looking very wrong when used on a tank in motion, and
keeping all tanks stationary when being shot at was't handy, so I took them out, with
the exception of the effect of the black hole weapon.

Despite working on this intro for 3 months, and more intense than any of our previous
productions, we still ran out of time sooner than we ran out of space. Storytelling,
animation and direction take a lot of time, and I'm not an artist. I only started
the C++ to assembly conversion at Revision, and the shader code is mostly directly
used out of the minifier, with little inlining or variable reuse. El Blanco made
several great versions of what he called "Intense angry space music", and then reworked
them to be better compressible.

I learned a lot making this intro. Thanks go to IQ for his fog and lighting articles,
Mercury for their paper about epsilon based raymarching, 0x4015 for the fantastic 4K
2nd Stage Boss whose explosions I adapted for my own nefarious needs and everyone in
Pouets "How to Camera" thread for excellent advice. Also thanks to Yncke and Cosplan for
feedback on the mailing list, and last but not least my family for their patience and
moral support.

Greets,
Seven

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
ss                     ::                                ::     /     .
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
