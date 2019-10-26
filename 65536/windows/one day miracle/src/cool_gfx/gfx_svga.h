/*
    Header file for CoolAPI SVGALib-version. None of the functions
    declared here should be called directly.

    Created: 31.3.1999
    Updated: 1.4.1999

    -Marq
*/

#ifndef GFX_SVGA_H
#define GFX_SVGA_H

#define SVGA_BLITMAX 4096   /*  Max memory buffer size for blit buffer */

/*  Functions for setting graphics modes according to parameter flags.
    Return GFX_OK or GFX_ERR_??? depending on success.
*/
int svga_set_320x240x32(int special);
int svga_set_320x200x32(int special);

#endif
/*  EOS */