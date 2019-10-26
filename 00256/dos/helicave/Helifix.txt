FIX FOR *DOSBOX* :  c:\>hellifix.com helicave.com

Peter Ferrie has had the kindness to point out
a few flaws to the original sourcode and also
contributed a DOSBox patch to fix them. Although
I've had mixed results with it, I believe in his
knowledge for in turn I myself could not recreate
some of the problems others reported. By running
the fix I hope it will resolve some of the issues
for some people. Big thanks to him.

The bugs he pointed out are also for the xp version :

1) SIZE MISS
>dwn:test dl,128 ;poor man's clipping : y>128 ?
>jnz gen ;repeat until valid conforming terrain value
>VS.
>dwn:test dl,dl ;poor man's clipping : y>128 ?
>js gen ;repeat until valid conforming terrain value
>correct, leftover from previous versions :
in version n°249 :
    mov cl,192        ; poor man's clipping : 11000000b
    test dl,cl        ; poor man's clipping : y<64-2*level ?
or in version n°330 :
    test al,192 ; poor man's clipping : 11000000b
    jnz miss    ; redo if rnd>63

B) BIOS-SPECIFIC #1
>mov ah,0ch ;(plot) bios video api fx plot (cx,dx)=al
>dec dx ;(clipped) row-- predec accounts for scanline 0
>int 10h ;bios video api
>...
>die:int 1ah ;ah=0=fun bios get system time
>ah is still 0c after the int 10h on my system.
correct, leftover from lodsw/stosw vs. cmpsw in case of colliding.
Magically works here as expected (up to 14 seconds max so didn't notice).

C) BIOS-SPECIFIC #2
>mov al,13h ;ah=set video mode,al=chained 320*200*256 AND cls
>int 10h ;heli. sprite=ascii(236)+ascii(235)+...ascii(195)
>spr:int 29h ;dos 2.x+ fast character i/o,al=char to write
>What value are you expecting in al on return from the int 10h? On
>some systems, I see 13h, on others, it's 4fh.

correct : for all "AMIPhoenix" dating before around 1989 

D) NOT-A-BUG : a risk
I noticed that sometimes the level cannot be completed because there's
a wall drawn all the way down the screen. It looks like the terrain
split. Maybe it's a DOSBox issue. I don't know how to reproduce it
consistently.

risk taken : No it is not a dosbox issue : it's a rollover (an a bad design issue from me
but had no choice - only "bug" I actually knew about and decided to leave). 
8253 pic2/pit channel 0 is 16 bytes but you must read it twice as bytes with
the lsb first (http://wiki.osdev.org/Programmable_Interval_Timer).
The proper handling I did not have space to implement was something like :
in al,40h
mov ah,al
in al,40h
ror ax,8+4 ; xchg ah,al and divide 16bit value for continuum) 
So I thought the "wall" doesn't happen that often :
-reason I switched the interval mask from 64 to 128 (to some extent the wrap-over is avoidable but game too easy at start); 
-timespan of game is up to level 7 or 8 at max, and in that time the rollover is mostly unlikely but does happen.