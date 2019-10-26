; "Descent OST", a 62 byte MIDI music player for MSDOS
; created by HellMood/DESiRE (C)2015
; this is the extracted music routine used in "Descent" 
; it is a procedural MIDI algorithm which sticks a
; subroutine to the DOS timer (interrupt 0x1C)
; the registered routine is called ~18.2 times per second

; developed for use with "NASM", 
; see http://sourceforge.net/projects/nasm/files/

%define		 	rhythmPattern			0b11
; with "rhythmPattern", you define how often a note is played
; generally, higher values and values containing many "ones"
; in binary representation, will result in faster play
; for example "0b11" will play every 4th note
%define 		baseInstrument			9
; defines the number of the first instrument used.
; see http://www.midi.org/techspecs/gm1sound.php for a full list
; keep in mind, that there are only a few instrument blocks
; whose sounds stop after a while. You won't get good results
; from strings etc. just a mess of overlayed sounds
%define 		numInstruments			7
; defines how many instrument are used. keep in mind, that "rhythm-
; Pattern" has influence on the picked instrument. the instruments
; from 9 to 9+7 are called "chromatic percussion"
%define 		noteStep 				5
; defines the basic difference from on note to the next. recommended
; values here are (mainly) 3,4 and 5 for music theoretic reasons
; but feel free to play around =)
%define 		noteRange				12
; after adding the noteStep, the note value is "mod"ded with
; the "noteRange". 12 means octave, which results in very harmonic
; scales
%define 		noteSpread				3
; the third step spreads the notes over the tonal spectrum, you may
; want to keep "noteSpread" * "noteRange" round about 30-60.
%define 		baseNote				40
; the general tone height of everything. some instruments don't play
; arbitrary deep notes correctly, and too high notes cause ear bleeding
; adjust with care ;)

; WARNING : after exiting the program, the timer interrupt is still active
; i strongly recommend to reboot or restart DOSBOX!

; ADVISE : Yes, there are music- and math-related things going on here
; if you're not into music theory, cycle of fifth, and the like, it maybe
; better to just play around with the parameters, rather then understanding them
; just change stuff slowly, and eventually you will get "there"
; wherever that is ;)

org 0x100
xchg cx,ax					; set our second counter to zero
mov dx,music			
mov ax,0x251C				; mode "0x25" , "0x1C" = change address of timer interrupt
int 0x21					; see http://mprolab.teipir.gr/vivlio80X86/dosints.pdf
S:
in ax,0x60					; wait for "ESC" press, then exit
dec al						; music plays on anyway, this is just for
jnz S						; keeping the music exactly as in "Descent"
ret							; return to prompt
music:
inc bx						; increment our first counter (starts at zero)
test bl,byte rhythmPattern	; play a note every 4th time tick
jnz nomusic					; otherwise do nothing
mov dx,0x331
mov al,0x3F
out dx,al
dec dx
mov al,0xC0					; change instrument on channel 0...
out dx,al
mov ax,bx					
aam byte numInstruments
add al,byte baseInstrument	; ...to this instrument
out dx,al
mov al,0x90					; play note on channel 0 ...
out dx,al
add cl,byte noteStep			 
mov al,cl
aam byte noteRange
imul ax,noteSpread
add al,baseNote				; ... play THIS note
out dx,al
neg al						; (play deeper notes louder = add bass)
add al,127+39				; ... play it THAT loud
out dx,al
nomusic:
iret
