
                          A  M  O  E  B  A
-------------------------------------------------------------------

H e a d e r

32 bytes MSDOS Demo Effect by HellMood / DESiRE
placed 3rd at the oldschool demo compo at Demosplash 2015
https://demosplash.club.cc.cmu.edu/

-------------------------------------------------------------------

P r o l o g u e 
(Heterochromia iridum)

The doctor looked at the young lady while she sat down on the chair. 
"What's the problem that brought you here?"
"My left eye hurts. Well it tickles. Kind of."
"Any trauma?" the doctor asked while arranging the slit-lamp microscope.
"Nothing. At least as far as I know."
"Please rest your chin here and look straight forward", the doctor 
said. "I saw that you have two different eye colors. Blue and green
are a nice combination if I may say so."
"It could be worse indeed", the young woman replied.
"Now let's see", the doctor said, looking through the microscope. He 
could not believe what he had in front of the lens. "Since when is it 
tickling?"
"Since saturday. It started in the evening."
"Anything happened on that day?"
"I visited demosplash. It's a so called demoparty."
"That can't be the reason. I don't see any cubes in there."

(thanks to Sensenstahl for this =)

-------------------------------------------------------------------

I n f o r m a t i o n

You find three versions of "amoeba" here, which just differ in
keyhandling and speed. "amoeba" is the original, quitting on
just ESC and beeing quite slow. "amoebax" (x-lerated), reacts
on "any key" and is a little bit faster. "amoebaf" (f - fast)
is the fastest (and smallest with 26 bytes, since it doesn't
check for user input and also does not quit).

YOUTUBE CAPTURE : https://www.youtube.com/watch?v=8dcRzskj7KQ

What you should see : a white noisy something which quickly
reduces to just a few small cells, looking like floating through
water. The cores of those cells then start to fluctate
resulting in a general growth that much, that all the empty
space is eaten up and transforming everything into plasma.

This is best beeing watched on DosBox or WindowsXP Dos. I noticed
strange side effects on Free Dos and from the live stream of
Demosplash (they used GUS) it also looked like not really running
as intended :/

-------------------------------------------------------------------

T e c h n i q u e 

At its heart, this is yet another cellular automaton, using a "core
free 2 neighbourhood", so to speak. That is, for one pixel, just
read the left and bottom neighbouring pixels of it, apply some math
to it, and replace the current pixel while ignoring its content
(core free). As such it's like an advanced version of "Stream"
(http://www.pouet.net/prod.php?which=66441) So, what math is
applied? Not much. When starting, i just was like "add it together,
divide by two, add some noise, and write the pixel". Depending on
what "noise" you add, it looks quite interesting already. But in
most cases it lacks proper mapping to the existent VGA standard
palette. In the next stages i desperately tried to map that
fluctuating stuff to the bright rainbow part of said palette, while
experimenting with band seperation, that is, applying slightly
different changes depending on the result of the previous
operation. All hail the carry flag! The best example for this
technique to work might be "Autumn" (SAR ??,1 then use CF for branch)
(http://www.pouet.net/prod.php?which=64159) Now, to shift that
band seperation to the "right point", you simply add an offset
, and after dividing by two, subtract half of that offset. That's
about it. I'll admit, the final touch of "wow" appeared just by
accident, while i was tuning the parameters to map the fluid
to fit precisely into the bright rainbow part. All of a sudden,
the plasma did not just appear in the right palette space, but
also that funky evolution before it finally kicks in. Well, i'll
take it! Moral of the story : in tiny intros, there is MUCH to be
done left in the cellular automaton theme. And: never stop playing =)

-------------------------------------------------------------------

C o d e

lds bx,[bx]      		; get pointer to screen
mov al,0x13       	; switch to graphic mode
int 0x10			; 320 x 320 in 256 colors
L: 
imul si,byte 0x75		; pseudorandomize position
lodsb				; get "left" pixel value
adc al,[si+0x140]		; add "bottom" pixel + "random" (carry from imul)
add al,0x32			; add offset (shift band separation)
adc al,ch			; change behaviour at threshold (ch = 0 -> add 1 more)
sar al,0x01			; average pixel value (/2)
sbb al,0x99			; sub offset (/2) & flip top bit & even/odd influence
mov [si],al			; write pixel (ignore content)
in al,0x60			; the usual way of...
dec al			; ...checking for ESC key...
jnz L				; ...and loop while not pressed...
ret				; ...otherwise exit

-------------------------------------------------------------------

G r e e t s   a n d   R e s p e c t

go to : 

homecoded, rrrola, frag, Baudsurfer, Optimus, p01
Sensenstahl, Whizart, g0blinish, Rudi, orbitaldecay,
igor, Drift, Oscar Toledo, wysiwtf
 ... and all DESiRE members =)

-------------------------------------------------------------------
