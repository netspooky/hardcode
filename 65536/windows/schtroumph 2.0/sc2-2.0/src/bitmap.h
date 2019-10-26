/* Schtroumpf - the intro - (c) 2004 Gautier Portet < kassoulet @ no-log . org >
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 *	Bitmap definition, shared between importer and the intro
 */

#ifndef BITMAP_H
#define BITMAP_H

#ifndef _SDL_types_h
typedef unsigned char	Uint8;
typedef signed char	Sint8;
typedef unsigned short	Uint16;
typedef signed short	Sint16;
typedef unsigned int	Uint32;
typedef signed int	Sint32;
#endif

typedef Uint8 SCPalette[3];
typedef Uint8 SCPixel;

typedef struct RLEBitmap
{
	Uint16 width,height;
	Uint8 nbColors;
	SCPalette *palette;
	SCPixel *pixels;
} RLEBitmap;

#endif
