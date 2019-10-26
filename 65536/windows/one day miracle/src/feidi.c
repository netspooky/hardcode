/*
    Pari feidiä. Aina tarpeen.

    - Marq
*/

/* Kross-feidi */
void cross_fade(unsigned *pic1,unsigned *pic2,unsigned *dest,int pixels,
                int phase)
{
    unsigned char   mul1[256],
                    mul2[256],
                    *bytes1,
                    *bytes2,
                    *destc;

    int n;

    /*  Siitä kertolaskutaulukot */
    for(n=0;n<256;n++)
    {
        mul1[n]=(255-phase)*n/255;
        mul2[n]=phase*n/255;
    }

    bytes1=(unsigned char *)pic1;
    bytes2=(unsigned char *)pic2;
    destc=(unsigned char *)dest;

    /*  Tavu kerrallaan niin on endian clean (muka) ja alphakin tulee
        käsiteltyä */
    for(n=0;n<pixels*sizeof(unsigned);n++)
        destc[n]=mul1[bytes1[n]]+mul2[bytes2[n]];
}

/* Additiivinen feidi */
void add_fade(unsigned *pic1,unsigned *pic2,unsigned *dest,int pixels,
                int bright1,int bright2)
{
    unsigned char   *bytes1,
                    *bytes2,
                    *destc;

    int n,c,
        mul1[256],mul2[256];

    /*  Siitä kertolaskutaulukot */
    for(n=0;n<256;n++)
    {
        mul1[n]=bright1*n/255;
        if(mul1[n]>255)
            mul1[n]=255;	
        mul2[n]=bright2*n/255;
        if(mul2[n]>255)
            mul2[n]=255;	
    }

    bytes1=(unsigned char *)pic1;
    bytes2=(unsigned char *)pic2;
    destc=(unsigned char *)dest;

    /*  Tavu kerrallaan niin on endian clean (muka) ja alphakin tulee
        käsiteltyä */
    for(n=0;n<pixels*sizeof(unsigned);n++)
    {
        c=mul1[bytes1[n]]+mul2[bytes2[n]];
        if(c<256)
            destc[n]=c;
        else
            destc[n]=255;
    }
}

/* EOS */
