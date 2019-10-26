/******************** 

	OCSALiB, the revolutionary -- version 0.0.1alpha
	
	(c) viznut/ocsa '98  vheikkil@hytti.uku.fi
	
	use it the way you like, i don't care :)
	
***************/

typedef struct {int r,g,b; } rgb;

extern void oxl_setpalette(rgb *pal); 
extern void oxl_doframe(char *vscr);
extern int oxl_timer(void);
extern void oxl_doaudio(int*(player()));
extern void oxl_init_video(void);
extern void oxl_init_audio(int rowtix);
extern void oxl_init_timer(void);
extern void oxl_end(void);

extern int AUFREQ, TIKLGT;

/*x.

	Just in case you _may_ want to use this in your own proggie (urgh)
	let's put some documentation here :)

** FUNCTIONS **

void oxl_setpalette(rgb *pal)

	pal is a table containing three ints (r,g,b) for every color.
	the values vary 0..255. 

void oxl_doframe(char *vscr)

	blits the contents of the offscreen buffer to the screen.
	the size of the buffer is BUFW * BUFH * 8 bits.

int oxl_timer(void)

	the current timer value. the number of timer ticks per second is
	defined by the DEMOHZ constant.

void oxl_doaudio(int*(player()));

	fills the audio output buffers up to 50%.
	
	player is a user-specified function returning a pointer to some raw
   audio data (e.g. the mixer output for the next row of a pattern)

	the first int of the data is the length of the rest (in ints).

	the buffer is int* but the data is 16bit unsigned. values going out
   of the range 0..65535 will be clipped.

	AUFREQ specifies the output frequency.

void oxl_init_video(void);

   adjusts the display for the demo. 	
	oxl_doframe and oxl_setpalette need this.	

void oxl_init_audio(int rowtix);
 	
	inits the audio stuff, possibly changing the value of AUFREQ. 
   rowtix is the maximum length (in ticks) of an audio chunk produced
   by int*(player()). (the 'physical length' in samples is therefore
   rowtix*AUFREQ/DEMOHZ)

   oxl_doaudio needs this.  does nothing if nosound.

void oxl_init_timer(void);

	starts the timer. oxl_timer needs this.
	
	with sounds on, the timing is actually based on the byte counter of
   the sound device but put this in your code anyway.

void oxl_end(void);

	closes the multimedia subsystems. these things should be done
   automatically when the program terminates, so you really don't need
   this function.

** CONSTANTS REQUIRED **

	AUDIO (0/1)
	VIDEO (vga/X11)
	BUFW, BUFH (buffer size)
	DEMOHZ (timer ticks per second)

** THINGS TO DO **

	- A guard process that tries to keep up the audio even if the main
     loop is frozen. (e.g. if the svgalib screen is not active or if
     you move the window in X)

	- Make sure the window start address is properly aligned for the
     maximum performance.

	- Do not calculate the contents of the buffer if the screen/window
     is not visible.

	- A variable palette size: if the palette fits in the end of the
     default colormap, we have to be able to use it instead of rudely
     using a private map.
   
   - Support for visual depths other than 8bpp.

	- Support for 16-bit multimedia sound systems. Stereo?

	- mSDoS support (for dummies)

	- AAlib support

	- An automatical reselection of X11 gfx mode to best fit the size of
     the buffer.
     
   - X fullscreen mode
   
   - X rootwindow mode

	- Etc etc... but still trying to keep it in a relevant size ;)

.x*/
