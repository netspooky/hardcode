/*
    Header file of CoolAPI V2 graphics functions.
    Compile with LINUX/DOS/W32 defined for different platforms.
    Supports only 32bpp internally.

    Created: 31.3.1999
    Updated: 31.3.1999
    
    -Marq
*/

#ifndef COOL_GFX_H
#define COOL_GFX_H

#ifdef LINUX
#ifdef X11
#include "gfx_x.h"
#else
#include "gfx_svga.h"
#endif
#endif

#ifdef DOS
#include "gfx_dos.h"
#endif

#ifdef MAC
#include "gfx_mac.h"
#endif

#ifdef SDL
#include "gfx_sdl.h"
#endif

#ifdef W32
#endif

/*  Supported graphics modes.   */
#define GFX_320x240x32 1
#define GFX_320x200x32 2

/*  Return values   */
#define GFX_OK 0
#define GFX_ERR_MODE 1      /*  Invalid mode        */
#define GFX_ERR_EXT 2       /*  Invalid extension   */

/*  Global special flags. Platform-dependent flags should use numbers
    starting from 65536
*/
#define GFX_NOASK 1         /*  Don't prompt the user for parameters    */
#define GFX_FULL 2          /*  Set fullscreen (if possible)    */
#define GFX_GRAY 4          /*  Prefer grayscale over color     */

/*  Initializes the graphics engine.
    mode   : Graphics mode
    special: Platform-dependent parameter
*/
int gfx_init(int mode,int special);

/*  Copies buffer to screen. Handles the conversion and page flips
    if necessary.
*/
int gfx_blit(unsigned int *buffer);

/*  Returns non-zero if there was a quit event (eg. ESC pressed or window
    close)
*/
int gfx_exitevent(void);

/*  Shuts down the graphics engine  */
void gfx_close(void);

#endif
/*  EOS */
