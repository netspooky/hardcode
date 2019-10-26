------------------------------
[B-Clopd] - a 32kb Jump'n'Run
------------------------------
a release at Mekka & Symposium 2k2 (with TP7 source)
made in 01/02 by


                John Trapolka Memorial Krew
                         [ JTMK ]



contact:apc_pap@gmx.de
NOTE:please, don't send any questions concerning the sourcecode !
     due to 32kb-optimizing many structures got lost, so probably
     even i don't know anymore what some lines of code actually do !
     the source is release
   
      

JTMK is :
---------
   - Pap          [CODE]
   - Starbuck     [MUSIC]
   - Skyrunner    [MUSIC]
   - Bartix       [GFX]
   - Ghettobitch  [GFX]
   - Melog        [GFX] 

Beta-Tester :
-------------

    Golem  ,  Blender  ,  Paasch  ,  Andz  ,  Starbuck  ,  BartiX






Releases so far:
----------------

 - Das Polkatro (Demo, came 4th out of 15 at Dialogos'01 [www.dialogos.cc])


Troubleshooting and FAQ:
------------------------
Q:I've got no music
A:you got to have a soundcard with hardware-wavetable
  softwarewavetables are not supported (weil->DosProg)

Q:How do I build the exe from the TP7-Source
A:1. Run MakeDatF.pas  (it compiles data.pas)
  2. Compile B-Clopd.pas
  3. Run "UPX.EXE -9 b-clopd.exe"
  4. finished, now you should have a b-clopd.exe with 32768 bytes in total

Q:Why do you release the source
A:DOS is Dead, so as i'm moving to windows, i quit coding in TP7 ;
  and therefor, the sources get useless for me, but may be useful
  for someone else

Q:During the game, i get a black screen. Music is still playing,
  but i can't see anything. ESC doesn't work,too.
A:I know this bug. I tried to fix it, but it might still happen.