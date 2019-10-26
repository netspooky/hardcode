;                             
;     *//.
;           *//.               *//.
;               *//.        *//.    *//.
;                  *//.   *//.         *//.
;    \\\\\\\\\\      *//.  *//.          *//.   \\\\\\\\\\
;    ---------- *//.   *//.  *//.    *//.  *//. ----------
;    \\\\\\\\\\  *//. *//.     *//.  *//.*//.   \\\\\\\\\\
;                  *//.         *//. *//. *//.
;                             *//.         *//.
;                         *//.               *//.
;                                               *//.
;                                                    *//.
;
;                  P    A    R    T    Y    !
;
;                     a 32 b msdos intro										
;                     textmode/pcspeaker
;                     by HellMood/DESiRE
;                     at "Deadline" 2017
;
;
;                        G r e e t s 
;
;             sensenstahl, homecoded, rrrola, frag
;             Optimus, Trixter, igor, gargaj, VileR
;            Whizart,g0blinish,Rudi,ryg,Orby a.k.a.
;            orbitaldecay,wysiwtf,Kuemmel,p01,Elias
;            Oscar Toledo,Drift +all DESIRE members 
;
;                      youtube capture
;         https://www.youtube.com/watch?v=jGDjS5PjnKk
;
;--------------------------------------------------------------
;
;      this has been tested on FreeDos on real hardware
;			        works on DosBox as well
;         the default textmode is used for animation
;           the sound is generated with pc speaker
;                please read - and contribute!
;           http://www.sizecoding.org/wiki/Output
;
;--------------------------------------------------------------
;
les dx,[si]				
; get an adress to the screen for direct output in textmode
; this is self referential, [SI] points to "stosw" + "pop ds"
; which translates to Segment ES = 0xAB1F, DX is not relevant
; while writing to 0xAB1F and above, the screen region at
; 0xB800 (or 0xB000) will be reached eventually, (64k)
pop ds
; top stack contains 0x0000, we need a zero segment to access
; the timer, to grant equal execution speed and sync on all
; systems, DS is used because it's the default MOV segment
; allowing to access the timer in the shortest possible way
L: stosw
; writing two bytes to the screen, the actual char AL with
; related color information in AH.  DI is even at start
mov ax,[046ch]
; get the timer word value, incremented 18.2 times/second
imul bx,ax,byte -80h
or al,bh
; secret way of combining melody and rythm in 5 bytes ;) 
and al,7fh
; not neccessary, but cutting of "too high" divisors results
; in higher frequencies, without the cut, the sound is
; sometimes too deep and also not pleasant to listen to
out 61h,al
; activating the speaker if both last bits of AL are set
; thus, creating a small groove pattern when turned off
out 42h,al
; setting the divisor for the pc speaker in a two path way
; (high byte, low byte), thus, allowing about 255 different
; frequencies, which are enough for a tiny speaker tune
mov ax,di
; getting the screen counter in AX
and al,bh
; directly combining melody (time) and screen position
aam 4
; retrieving color information (AH) from the effect
add al,176
; offsetting the char to special graphic chars ░ ▒ ▓
; which resemble tiny XOR patterns for viewing pleasure
and ah,1+4+64+8
; mask the color mess to just select some red, blue and
; gray channels in foreground and background nibbles
jmp short L
; rinse and repeat, sorry for the little explanation
; on actual sound and graphic generation, but i only
; have so much time and my girl wants some of that, too
