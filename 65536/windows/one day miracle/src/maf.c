/* Horizontal moving average filter 
   by Yzi/Fit 2000-07-23
*/

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 240

#define MAXBLUR (SCREEN_WIDTH*2)

#define GETRED(c) ((unsigned char)(c >> 16))
#define GETGREEN(c) ((unsigned char)(c >> 8))
#define GETBLUE(c) ((unsigned char)(c))

#define MAKERGB(r, g, b) (((unsigned int)(r) << 16) + ((unsigned int)(g) << 8) + (unsigned int)(b << 0))

static int 
  maf_divtable[MAXBLUR+1][256];

void init_maf()
{
    int i, j;

    for (i=0; i<256; i++)
        for (j=0; j<MAXBLUR; j++)
            maf_divtable[j][i] = (j ? i/j : 255);
} /* init maf */

void horiz_maf(int *srcbuf, int *destbuf,
               int srcx1, int srcy1, 
               int destx1, int desty1, 
               int width, int height,
			   int bufwidth, int bufheight,
			   int filterwidth)
{
	int y,
		av_r, av_g, av_b,
        srcpix1, srcpix2,
        *_src, *src1, *src2, 
        *_dest, *dest,
        *divtable;

    divtable = maf_divtable[filterwidth];
        
    _src = srcbuf + srcx1 + srcy1 * bufwidth;
    _dest = destbuf + destx1 + desty1 * bufwidth;

    for (y=desty1; y<desty1+height; y++)
    {
        src1 = _src - filterwidth;
        src2 = _src;
        dest = _dest - (filterwidth >> 1);

        /* Initialize the moving average */
        av_r = 0; av_g = 0; av_b = 0;

        /* Build the average for the leftmost pixel */
        for (; dest<_dest; src1++, src2++, dest++)
        {
            srcpix2 = *src2;
            av_r += divtable[GETRED(srcpix2)];
            av_g += divtable[GETGREEN(srcpix2)];
            av_b += divtable[GETBLUE(srcpix2)];            
        }

        /* Start outputting, add to avg only */
        for (; src1<_src; src1++, src2++, dest++)
        {
            srcpix2 = *src2;
            av_r += divtable[GETRED(srcpix2)];
            av_g += divtable[GETGREEN(srcpix2)];
            av_b += divtable[GETBLUE(srcpix2)];
            *dest = MAKERGB(av_r, av_g, av_b);
        }

        /* Now add and subtract */
        for (; src2<(_src+width); src1++, src2++, dest++)
        {
            srcpix1 = *src1;
            srcpix2 = *src2;
            av_r += divtable[GETRED(srcpix2)] - divtable[GETRED(srcpix1)];
            av_g += divtable[GETGREEN(srcpix2)] - divtable[GETGREEN(srcpix1)];
            av_b += divtable[GETBLUE(srcpix2)] - divtable[GETBLUE(srcpix1)];
            *dest = MAKERGB(av_r, av_g, av_b);
        }

        /* Subtract only*/
        for (; dest<(_dest+width); src1++, dest++)
        {
            srcpix1 = *src1;
            av_r -= divtable[GETRED(srcpix1)];
            av_g -= divtable[GETGREEN(srcpix1)];
            av_b -= divtable[GETBLUE(srcpix1)];
            *dest = MAKERGB(av_r, av_g, av_b);
        }

        /* Go to next line */
        _src += bufwidth;
        _dest += bufwidth;
        
    } /* for y*/

} /* horiz_maf */

void vert_maf(int *srcbuf, int *destbuf,
              int srcx1, int srcy1, 
              int destx1, int desty1, 
              int width, int height,
			  int bufwidth, int bufheight,
			  int filterheight)
{
	int x,
		av_r, av_g, av_b,
        srcpix1, srcpix2,
        *_src, *src1, *src2, 
        *_dest, *dest,
        *divtable;

    _src = srcbuf + srcx1 + srcy1 * bufwidth;
    _dest = destbuf + destx1 + desty1 * bufwidth;

    divtable = maf_divtable[filterheight];
        
    for (x=destx1; x<destx1+width; x++)
    {
        src1 = _src - filterheight * bufwidth;
        src2 = _src;
        dest = _dest - (filterheight >> 1) * bufwidth;

        /* Initialize the moving average */
        av_r = 0; av_g = 0; av_b = 0;

        /* Build the average for the first pixel */
        for (; dest<_dest; src1+=bufwidth, src2+=bufwidth, dest+=bufwidth)
        {
            srcpix2 = *src2;
            av_r += divtable[GETRED(srcpix2)];
            av_g += divtable[GETGREEN(srcpix2)];
            av_b += divtable[GETBLUE(srcpix2)];            
        }            

        /* Start outputting, add to avg only */
        for (; src1<_src; src1+=bufwidth, src2+=bufwidth, dest+=bufwidth)
        {
            srcpix2 = *src2;
            av_r += divtable[GETRED(srcpix2)];
            av_g += divtable[GETGREEN(srcpix2)];
            av_b += divtable[GETBLUE(srcpix2)];
            *dest = MAKERGB(av_r, av_g, av_b);
        }

        /* Now add and subtract */
        for (; src2<(_src+height*bufwidth); src1+=bufwidth, src2+=bufwidth, dest+=bufwidth)
        {
            srcpix1 = *src1;
            srcpix2 = *src2;
            av_r += divtable[GETRED(srcpix2)] - divtable[GETRED(srcpix1)];
            av_g += divtable[GETGREEN(srcpix2)] - divtable[GETGREEN(srcpix1)];
            av_b += divtable[GETBLUE(srcpix2)] - divtable[GETBLUE(srcpix1)];
            *dest = MAKERGB(av_r, av_g, av_b);
        }

        /* Subtract only*/
        for (; dest<(_dest+height*bufwidth); src1+=bufwidth, dest+=bufwidth)
        {
            srcpix1 = *src1;
            av_r -= divtable[GETRED(srcpix1)];
            av_g -= divtable[GETGREEN(srcpix1)];
            av_b -= divtable[GETBLUE(srcpix1)];
            *dest = MAKERGB(av_r, av_g, av_b);
        }

        /* Go to next column */
        _src++;
        _dest++;

    } /* for x */

} /* vert_maf */
