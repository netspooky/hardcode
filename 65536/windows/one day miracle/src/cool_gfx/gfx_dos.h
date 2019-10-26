/*
    Header file for CoolAPI DOS graphics functions. Should not be called
    from outside CoolAPI.

    Created: 1.4.1999
    Updated: 1.4.1999

    -Marq
*/

#ifndef GFX_DOS_H
#define GFX_DOS_H

#define DOS_BLITMAX 4096    /*  Max memory buffer size for blit buffer  */
#define GFX_NOVESA 65536    /*  Don't use VESA modes even if found      */

/*  Functions for setting graphics modes according to parameter flags.
    Return GFX_OK or GFX_ERR_??? depending on success.
*/
int dos_set_320x240x32(int special);
int dos_set_320x200x32(int special);

#endif
/*  EOS */
