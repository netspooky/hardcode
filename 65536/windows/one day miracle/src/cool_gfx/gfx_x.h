/*
    Header file for CoolAPI X11-version. None of the functions
    declared here should be called directly.

    Created: 20.5.1999
    Updated: 20.5.1999

    -Marq
*/

#ifndef GFX_X_H
#define GFX_X_H

/*  (Un)define these if necessary. Should be done from cmdline.
#define X_SHM
#define X_DGA
*/

#define X_BLITMAX 640*480*4 /*  Max memory buffer size for blit buffer */

/*  Sets X mode according to "special" parameter.
    x,y = resolution of the window
*/
int x_init(int x,int y,int special);

#endif
/*  EOS */

