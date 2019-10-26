/*
        Promottaa kuvan 8->32, paletin komponenttien oltava
        0..255. Pituus voidaan m„„r„t„.
*/

#ifndef PROMOTE_H
#define PROMOTE_H

extern void promote(unsigned char *dat,unsigned char *pal,
                    unsigned *koh,unsigned len);

#endif

/*      EOH     */
