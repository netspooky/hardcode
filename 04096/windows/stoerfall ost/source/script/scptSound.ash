comment #+

    This is the source-release of "Stoerfall Ost", our winning 4kb
    multimedia presentation that was first shown at Dialogos 2000.
    If you have any questions concerning the sourcecode drop us a
    line at freestyle@freestylas.org. Feel free to visit our
    webpage at http://www.freestylas.org.
    Copyright (C) 2001 freestyle
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
    
+#



scriptAlpha0	Label byte
	
	scptCopy	0,	pattern_play_alpha,		pattern_alpha2
	scptCopy	02,	alpha_freq,note_c4
	;scptCopy	05,	alpha_freq,note_c6
	scptCopy	12,	alpha_freq,note_f5
	
	scptLoop	32,	32
		
	scptCopy	256+00,	pattern_play_alpha,		pattern_alpha1
	scptCopy	256+02,	alpha_freq,note_c5
	scptCopy	256+04,	alpha_freq,note_f_5
	scptCopy	256+08,	alpha_freq,note_d_5
	scptCopy	256+14,	alpha_freq,note_c6
	scptCopy	256+20,	alpha_freq,note_a_5
	scptCopy	256+24,	alpha_freq,note_f_5
	scptCopy	256+30,	alpha_freq,note_c5
	
	scptLoop	256+32,	32	
	
	scptLinear	896+32,	20,1,1
	scptDelay	896+72
	
	;scptEnd
	
scriptPerc	Label byte
	
	scptCopy	0,	pattern_play_alpha_slide,	pattern_alpha_slide1
	
	scptCopy	2,	overdrive_val,			1

	scptCopy	128-1,	pattern_play_ch,		pattern_ch1
	scptCopy	128+0,	pattern_play_sd,		pattern_sd1

	scptCopy	375,	fto+60,				fto+56
	scptCopy	376,	overdrive_val,			fto+85

	scptCopy	384-1,	pattern_play_bd,		pattern_bd1
	
	scptCopy	512-1,	pattern_play_bd,		pattern_bd2
	scptCopy	512+0,	pattern_play_sd,		0

	scptCopy	640-1,	pattern_play_bd,		pattern_bd1
	scptCopy	640+0,	pattern_play_sd,		pattern_sd1
	
	scptCopy	768-1,	pattern_play_bd,		0

	scptCopy	832-1,	pattern_play_ch,		0
	scptCopy	832+0,	pattern_play_sd,		0

	scptCopy	896,	pattern_play_alpha,		0

	scptEnd
	
