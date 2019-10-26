/*
    Andromedary
    Copyright (C) 2006 Jere Sanisalo, Jetro Lauha

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef GLOW_H_INCLUDED
#define GLOW_H_INCLUDED

/*
 * Usage: Configure glow in top of glow.cpp.
 *
 *   ..
 *   beginBaseTextureRender();
 *   -- render effect here (don't change viewport) --
 *   endBaseTextureRender();
 *   beginGlow();
 *   glowRender(base, glow, glowLevelsAdjust);
 *   endGlow();
 *
 *   glowRender params:
 *   - base = original image multiplier (stretched to full screen)
 *            recommended value 0.5f-1.0f
 *   - glow = additive glow layer multiplier
 *            recommended value ~0.2f
 */

//extern int glowBaseTextureWidth, glowBaseTextureHeight;
extern unsigned char g_color_table[];
extern void glowInitTextures();
extern void beginBaseTextureRender();
extern void endBaseTextureRender();
extern void beginGlow();
extern void endGlow();
extern void glowRender();

#endif // !GLOW_H_INCLUDED
