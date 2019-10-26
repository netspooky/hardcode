/*
    Header file for CoolAPI Mac-version. None of the functions
    declared here should be called directly.

    Created: 19.1.2000
    Updated: 19.1.2000

    -Marq
*/

#ifndef GFX_MAC_H
#define GFX_MAC_H

#define MAC_BLITMAX 4096   /*  Max memory buffer size for blit buffer */

/*  Functions for setting graphics mode according to parameters.
    Return GFX_OK or GFX_ERR_??? depending on success.
*/
int mac_init(int x,int y,int depth,int special);

#endif
/*  EOS */
