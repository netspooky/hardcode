/*
        Radix-ort.

        J„rjestelee taulukon radix-sortilla 1..4 tavun mukaan.
        Poonuksena counting sort, joka vaatii ty”tilaa vain l„hde*2
        ja on nopeampikin.
*/

#ifndef RADIX_H
#define RADIX_H

#define RANGE 1024      /*      Counting sortin et„isyyksien max. m„„r„ */
                        /*      Oltava kahden potenssi ja >=256         */

/*      m„„r„,l„hde,ty”alue (l„hde*4), tavut    */
extern unsigned *byte_radix(unsigned num,unsigned *etat,unsigned *nelja,int maara);

/*      On siin„ counting-sorttikin, mutta el„ t„t„ k„yt„...    */
extern unsigned *byte_counting_sort(int num,int tavu,unsigned *lahe,unsigned *kohe);

/*      T„ss„ on RANGElla toimiva counting sort */
extern unsigned *counting_sort(int num,unsigned *etat,unsigned *kaksi);

#endif

/*      EOH     */
