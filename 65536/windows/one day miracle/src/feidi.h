/*
    Kross-feidi ja additiivinen feidi. Aina tarpeen.

    - Marq
*/

#ifndef FEIDI_H
#define FEIDI_H

/*
    Feidaa pic1+pic2 dest-puskuriin. Vaihe on 0..255 (0=pic1, 255=pic2)
*/
void cross_fade(unsigned *pic1,unsigned *pic2,unsigned *dest,int pixels,
                int phase);

/*
    Feidaa pic1+pic2 dest-puskuriin. Molempien kirkkaus 0..255.
*/
void add_fade(unsigned *pic1,unsigned *pic2,unsigned *dest,int pixels,
              int bright1,int bright2);

#endif
