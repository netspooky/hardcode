#  data.inc - the variables for 'sesamstr'
#	
#  Copyright (C) 1999 Jorik Blaas and Tijs van Bakel
#  Jorik Blaas <jrk@vengeance.et.tudelft.nl> (avoozl)
#  Tijs van Bakel <smoke@casema.net> (smoke)
# 
#  This file is part of sesamstr, a 4k linux intro
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; see the file COPYING.  If not, write to
#  the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

visual:		.int	0	

road_table:	.byte	0, 1		# left
		.byte	4, 2
		.byte	4, 3
		.byte	0, 2
		.byte	4, 0		# centerline
		.byte	0, 2
		.byte	4, 3
		.byte	4, 2
		.byte	0, 1		# right

scale:	.int	127

vga_graph_mem:	.int	0		# pointer to vga memory	
graph_mem:	.int	virtual_buffer	# pointer to virtual buffer

filename_dev_dsp:	.ascii	"/dev/dsp\0"

file_dev_dsp:		.int	0

rand:		.int	0

# the first column is RED and GREEN, the second is BLUE

sin_degrees:	.int	32767
sin_scale:	.int	32767
	
zoom_coord:
zoom_u0:	.int	0
zoom_v0:	.int	0
zoom_u1:	.int	256<<8
zoom_v1:	.int	256<<8

grov_z:		.int	250
grov_diff_z:	.int	-1
grov_x:		.int	50
grov_diff_x:	.int	4


.include "font.inc"
.include "gfx.inc"

music_note:   	.int   -1
music_pos:      .int   1

.set C3, 0
.set D3, 1
.set E3, 2
.set F3, 3
.set G3, 4
.set A3, 5
.set B3, 6
.set NN, 7

.set C4, 8
.set D4, 9
.set E4, 10
.set F4, 11
.set G4, 12
.set A4, 13
.set B4, 14

.set C5, 16
.set D5, 17
.set E5, 18
.set F5, 19
.set G5, 20
.set A5, 21
.set B5, 22

melody_data:		
		.byte E4, G4, B4, E5, G5, F5, E5, B4, A4, G4, F4, D4
		.byte E4, NN, NN, NN, NN, G4, NN, NN, NN, NN, F4, D4
		.byte B3, NN, NN, NN, NN, NN, NN, NN, NN, NN, NN, NN
		.byte NN, NN, NN, NN, NN, NN, NN, NN, NN, NN, D4, NN
	
		.byte E4, G4, B4, E5, G5, F5, E5, B4, A4, G4, F4, D4
		.byte E4, NN, NN, NN, NN, G4, NN, NN, NN, NN, F4, D4
		.byte E3, NN, NN, NN, NN, NN, NN, NN, NN, NN, NN, NN
		.byte NN, NN, NN, NN, NN, NN, NN, NN, NN, NN, D4, NN
	
		 .byte D4, NN,NN,NN,D4,E4,F4,NN,NN,NN,F4,G4,A4,NN,G4, NN 
		 .byte F4, NN, A4, NN, G4, NN, F4, NN, E4, NN, NN, NN, NN, NN
		 .byte C4, NN, B3, NN, B3, C4, B3, NN, NN, NN, NN, NN
		 .byte G4, NN, F4, NN, E4, NN

		 .byte D4, NN,NN,NN,D4,E4,F4,NN,NN,NN,F4,G4,A4,NN,B4, NN
		 .byte C5, NN, B4, NN, A4, NN, F4, NN, G4, NN, NN, NN, NN, NN
		 .byte B4, NN, NN, NN, NN, NN, E5, NN, NN, NN, NN, NN
		 .byte NN, NN, NN, NN, NN, NN

bass_data:	
bass1:	.byte   E3, E4, E4, C3, C4, C4, E3, E4, E4, D3, D4, D4
	.byte 	E3, E4, E4, C3, C4, C4, E3, E4, E4, D3, D4, D4 
	.byte 	E3, E4, E4, C3, C4, C4, E3, E4, E4, D3, D4, D4
	.byte 	E3, E4, E4, C3, C4, C4, E3, E4, E4, D3, D4, D4
	
	.byte 	D3, D4, D4, A3, D4, D4, D3, D4, D4, A3, D4, D4
	.byte 	E3, E4, E4, B3, E4, E4, E3, E4, E4, B3, E3, E3
	.byte 	D3, D4, D4, A3, D4, D4, D3, D4, D4, A3, D4, D4
	.byte 	E3, E4, E4, B3, E4, E4, E3, E4, E4, B3, E3, E3


bass2:	
	.byte 	NN, G4, G4, NN, E4, E4, NN, G4, G4, NN, F4, F4
	.byte 	NN, G4, G4, NN, E4, E4, NN, G4, G4, NN, F4, F4
	.byte 	NN, G4, G4, NN, E4, E4, NN, G4, G4, NN, F4, F4
	.byte 	NN, G4, G4, NN, E4, E4, NN, G4, G4, NN, F4, F4

	.byte 	NN, F4, F4, NN, F4, F4, NN, F4, F4, NN, F4, F4
	.byte 	NN, G4, G4, NN, G4, G4, NN, G4, G4, NN ,G4, G4
	.byte 	NN, F4, F4, NN, F4, F4, NN, F4, F4, NN, F4, F4
	.byte 	NN, G4, G4, NN, G4, G4, NN, G4, G4, NN ,G4, G4

bass3:	
	.byte 	NN, B4, B4, NN, G4, G4, NN, B4, B4, NN, A4, A4
	.byte 	NN, B4, B4, NN, G4, G4, NN, B4, B4, NN, A4, A4
	.byte 	NN, B4, B4, NN, G4, G4, NN, B4, B4, NN, A4, A4
	.byte 	NN, B4, B4, NN, G4, G4, NN, B4, B4, NN, A4, A4
	
	.byte 	NN, A4, A4, NN, A4, A4, NN, A4, A4, NN, A4, A4
	.byte 	NN, B4, B4, NN, B4, B4, NN, B4, B4, NN ,B4, B4
	.byte 	NN, A4, A4, NN, A4, A4, NN, A4, A4, NN, A4, A4
	.byte 	NN, B4, B4, NN, B4, B4, NN, B4, B4, NN ,B4, B4

		
step_lookup:	.word 1147 # 4589/4
		.word 1287 # 5151/4
		.word 1445 # 5782/4
		.word 1622 # 6490/4
		.word 1718 # 6876/4
		.word 1929 # 7718/4
		.word 2165 # 8663/4
		.word 0

event_palette_function:			.int	grover_bounce_pal
event_function:			
		.int	road_to_nowhere
event_table:
		.word	128*4-1
		.int	leader
		.int	road_to_nowhere_pal
	
		.word   1600	
		.int	road_to_nowhere
		.int	road_to_nowhere_pal

		.word	128
		.int	leader
		.int	road_to_nowhere_pal

		.word	64
		.int	clear
		.int	clear
		.word	64
		.int	lightning
		.int	lightning_pal
		.word	1
		.int	clear
		.int	clear
		.word   256	
		.int	graaf_dup0
		.int	graaf_dup_pal

		.word	64
		.int	clear
		.int	clear
	
		.word   180 	
		.int	lightning
		.int	lightning_pal
	
		.word	64
		.int	clear
		.int	clear
	
		.word   256	
		.int	graaf_dup1
		.int	graaf_dup_pal
		.word   32	
		.int	clear
		.int	clear
		.word	168
		.int	graaf_dup1
		.int	graaf_dup_pal
		.word	32
		.int	clear
		.int	clear
		.word	74
		.int	graaf_dup1
		.int	graaf_dup_pal
		.word	32
		.int	clear
		.int	clear
		.word	32
		.int	graaf_dup1
		.int	graaf_dup_pal
		.word	32	
		.int	clear
		.int	clear
	
		.word	128*4
		.int	leader
		.int	road_to_nowhere_pal

		.word	70
		.int	clear
		.int	clear
	
		.word	600
		.int	grover_bounce
		.int	grover_bounce_pal
	
		.word	128
		.int	leader
		.int	road_to_nowhere_pal
	
		.word	1
		.int	quit
		.int	0

zoom_bgcol:	.byte	2

road_text:	.byte 62, 4, 4, 13, 26, 21, 4, 19, 19, 4, 26, 14, 11, 3, 18, 2, 7, 14, 14, 11, 26, 21, 8, 4, 17, 26, 10, 26, 8, 13, 19, 17, 14, 26, 21, 14, 14, 17, 26, 4, 4, 13, 26, 21, 4, 17, 11, 4, 15, 19, 26, 13, 4, 22, 18, 2, 7, 14, 14, 11, 26, 14, 18

lght_pal:
		.byte	0,0,0
		.byte	0,50,0
		.byte	0,0,50
		.byte	0,50,50
		.byte	50,0,50

lght_fade:	.int	1
lght_x:		.int	0

weather_base_pos:	.word	0
weather_amplify_pos:	.word	0

lightning_noise:	.word   65535	
lead_text_ptr:		.int	lead_text

sound_outsize:		.int	0
sound_event_ptr:	.int	sound_next_frame
sound_next_frame:	
			.int	58400, sound_init_wind
			.int	241257, sound_init_tune # moet later
			.int	262742, sound_init_lightning
			.int	307800, sound_init_lightning
			.int	316514, sound_init_lightning
			.int	322828, sound_init_lightning
			.int	476800, sound_init_tune
			.int	476801, sound_init_wind
			.int	476802, sound_init_grover
			.int	476802+68571, sound_init_grover
			.int	-1
sound_wind_on:		.byte	0
sound_lightning_on:	.byte	0
sound_grover_on:	.byte	0
sound_tune_on:		.byte	0
