#  zero_data.inc - variables that are initialized to zero by default
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

.equ road_pal_len, 256*3
.equ road_pal, zeroes

.equ texture_len, 4
.equ texture, zeroes+road_pal_len

.equ dsp_buf, texture+texture_len
.equ dsp_buf_len, 64000*4

.equ frame_count, dsp_buf+dsp_buf_len
.equ frame_count_len, 4

.equ sin_x, frame_count+frame_count_len
.equ sin_x_len, 4

.equ sin_temp, sin_x+sin_x_len
.equ sin_temp_len, 4

.equ audio_buf_info, sin_temp+sin_temp_len
.equ audio_buf_info_len, 16

.equ lightning_level_data, audio_buf_info+audio_buf_info_len
.equ lightning_level_data_len, 80	

.equ coords, lightning_level_data+lightning_level_data_len
.equ coords_len, 16

.equ graaf_dup_coords, coords+coords_len
.equ graaf_dup_coords_len, 16

.equ zoom_width, graaf_dup_coords+graaf_dup_coords_len
.equ zoom_height, zoom_width+4
.equ zoom_u, zoom_height+4
.equ zoom_v, zoom_u+4
.equ zoom_v_step, zoom_v+4
.equ zoom_u_step, zoom_v_step+4
.equ zoom_src, zoom_u_step+4
	
.equ grov_coord, zoom_src+4
.equ channel, grov_coord+16		# 12 words

.equ font_blocks, channel+24
.equ rendered_font, font_blocks+64*32*6
.equ sine, rendered_font+256*256*27	# 65536*4

.equ grover_texture, sine+65536*4
.equ graaf_texture, grover_texture+256*256

.equ virtual_buffer, graaf_texture+256*256
.equ einde, virtual_buffer+320*200

