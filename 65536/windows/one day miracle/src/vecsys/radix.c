/*
        Radix-ort.
        ™rt.

        num=j„rjestett„vien m„„r„
        etat=et„isyystaulukko
        nelja=ty”alue, nelj„ kertaa niin suuri kuin j„rjestett„v„
        maara=monenko alemman tavun mukaan j„rjestell„„n (0..3)
        Palauttaa osoitteen j„rjestettyjen tasojen indekseihin

        Bonuksena counting sort!
        num=j„rjestett„vien m„„r„
        etat=et„isyystaulukko
        kaksi=ty”alue, kaksi kertaa niin suuri kuin j„rjestett„v„
        Palauttaa osoitteen j„rjestettyjen tasojen indekseihin
*/

#include <string.h>
#include "radix.h"

static unsigned         maara[RANGE];

unsigned *byte_radix(unsigned num,unsigned *etat,unsigned *nelja,int maara)
{
        unsigned        n,of=0;

        for(n=0;n<num;n++)
        {
                nelja[of++]=etat[n];
                nelja[of++]=n;
        }
        switch(maara)
        {
                case 1 : return(byte_counting_sort(num,0,nelja,&nelja[num*2]));
                case 2 : byte_counting_sort(num,0,nelja,&nelja[num*2]);
                         return(byte_counting_sort(num,1,&nelja[num*2],nelja));
                case 3 : byte_counting_sort(num,0,nelja,&nelja[num*2]);
                         byte_counting_sort(num,1,&nelja[num*2],nelja);
                         return(byte_counting_sort(num,2,nelja,&nelja[num*2]));
                case 4 : byte_counting_sort(num,0,nelja,&nelja[num*2]);
                         byte_counting_sort(num,1,&nelja[num*2],nelja);
                         byte_counting_sort(num,2,nelja,&nelja[num*2]);
                         return(byte_counting_sort(num,3,&nelja[num*2],nelja));
                default: return(NULL);
        }
}

/*      Radixin k„ytt„m„ tavun mukaan sorttaava counting sort   */
unsigned *byte_counting_sort(int num,int tavu,unsigned *lahe,unsigned *kohe)
{
        unsigned        sift=tavu*8,of;

        int     n;

        memset(maara,0,256*sizeof(unsigned));
        for(n=0;n<num*2;n+=2)
                maara[(lahe[n]>>sift)&0xff]+=2;

        for(n=1;n<256;n++)
                maara[n]+=maara[n-1];

        for(n=num*2-2;n>=0;n-=2)
        {
                of=(lahe[n]>>sift)&0xff;
                kohe[maara[of]-2]=lahe[n];
                kohe[maara[of]-1]=lahe[n+1];
                maara[of]-=2;
        }
        return(kohe);
}

/*      RANGE:lla toimiva counting sort         */
unsigned *counting_sort(int num,unsigned *etat,unsigned *kaksi)
{
        unsigned        of;

        int     n;

        memset(maara,0,RANGE*sizeof(unsigned));
        for(n=0;n<num;n++)
                maara[etat[n]&(RANGE-1)]+=2;

        for(n=1;n<RANGE;n++)
                maara[n]+=maara[n-1];

        for(n=num-1;n>=0;n--)
        {
                of=etat[n]&(RANGE-1);
                kaksi[maara[of]-2]=etat[n];
                kaksi[maara[of]-1]=n;
                maara[of]-=2;
        }
        return(kaksi);
}

/*      EOS     */
