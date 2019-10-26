                - stupid scroller -

	64k intro : 	entry for Edison 2011
	      code:	lnd
	     music:	lnd
            packer: 	crinkler12
	   contact:	scene@lnd.nu


Technical details:

Beat synced scroller put together at the party.
It uses a software rendering system and the hypersin2
soft synth. Both written by myself. 

The software renderer uses a texturing triangle 
rasterizer that in turn renders argb textures 
perspective correct on a designated target texture. 

Music is generated in a separate thread that renders 
to the wav out buffer continuously effectively 
avoiding precalc.

The synth is a non-modularized soft synth that uses 
simple waveforms in lookup tables in its sound 
synthesis. On every channel there's a modular effect 
stage that has the usual effects like delay, reverb, 
compressor, distorsion, mono to stereo and stereo 
separation width.

All come together in perfect harmony 
(i'm almost crying)

Greetz to all of scene.


lnd




