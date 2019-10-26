import sun.audio.AudioPlayer;

include(blow.m4)

BLOW_INTRO(main,400,300)
include(`Bloobs.java.m4')
include(`Fade.java.m4')
include(`Blur.java.m4')
include(`Lookup.java.m4')
dnl include(`Logo.java.m4')
include(`Text.java.m4')
include(`Julia.java.m4')
include(`Colorize.java.m4')

BLOW_MAIN(

        BLOW_MAKE_BUFFER(fb1)
        BLOW_MAKE_BUFFER(fb2)
	BLOW_MAINLOOP(128,
	        BLOW_CALL_EFFECT1(fade,fb1)
        	BLOW_CALL_EFFECT1(julia,fb1)
	        BLOW_CALL_EFFECT2(blur,fb1,fb2)
		BLOW_CALL_EFFECT2(colorize,fb1,fb2)
	        BLOW_DRAW(fb2)
	)
	BLOW_MAINLOOP(256,
	        BLOW_CALL_EFFECT1(fade,fb1)
        	BLOW_CALL_EFFECT1(julia,fb1)
	        BLOW_CALL_EFFECT2(blur,fb1,fb2)
	        BLOW_CALL_EFFECT2(lookup,fb2,fb1)
		BLOW_CALL_EFFECT2(colorize,fb1,fb2)
	        BLOW_DRAW(fb2)
	)
	BLOW_MAINLOOP(384,
	        BLOW_CALL_EFFECT1(fade,fb1)
		BLOW_CALL_EFFECT1(bloobs,fb1)
	        BLOW_CALL_EFFECT2(blur,fb1,fb2)
	        BLOW_CALL_EFFECT2(lookup,fb2,fb1)
		BLOW_CALL_EFFECT2(colorize,fb1,fb2)
	        BLOW_DRAW(fb2)
	)
)
