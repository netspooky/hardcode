/*
        VESA.H DJGPP-version
        (c) Marq 1996-1999

        Note: VESA pointers are usually realmode pointers except
        physbaseptr, which points to the LFB.
*/

#ifndef VESA_H
#define VESA_H

#define VBE_OK 0                /*      Return value if no error        */
#define VBE_FOUND 0x4f          /*      Return value if VESA found      */
#define VBE_A 0                 /*      A- and B-windows                */
#define VBE_B 1
#define VBE_RETRACE 0x80        /*      Wait for VRT when page flipping? */

#define VBEINFO 512             /*      VBEinfoblock size               */
#define VBEMODE 256             /*      VBEmodeblock size               */

#define VBE_SUPPORTED 1
#define VBE_LINEAR 0x80         /*      modeattributes bit linear       */

#define PK __attribute__((packed))

struct VBEinfoblock
{
        char    VBEsignature[4] PK;        /*      "VESA"          */
        short   VBEversion PK;
        char    *OEMstringptr PK;
        int     capabilities PK;
        unsigned short
                *videomodeptr PK,          /*      Pointer to a modelist */
                totalmemory PK,
                OEMsoftwarerev PK;
        char    *OEMvendornameptr PK,
                *OEMproductnameptr PK,
                *OEMproductrevptr PK;
        char    reserved[222] PK,
                OEMdata[256] PK;
};

struct VBEmodeblock
{
        short   modeattributes PK;         /*      Info about the mode  */
        char    winaattributes PK,
                winbattributes PK;
        short   wingranularity PK,
                winsize PK,
                winasegment PK,
                winbsegment PK;
        void    *winfuncptr PK;            /*      Function pointer     */
        short   bytesperscanline PK;

        short   xresolution PK,            /*      Resolutions          */
                yresolution PK;
        char    xcharsize PK,
                ycharsize PK,
                numberofplanes PK,
                bitsperpixel PK,
                numberofbanks PK,
                memorymodel PK,            /*      Pixel organization   */
                banksize PK,
                numberofimagepages PK,
                reserved PK;

        char    redmasksize PK,            /*      Hi- ja Realcolor modes */
                redfieldposition PK,
                greenmasksize PK,
                greenfieldposition PK,
                bluemasksize PK,
                bluefieldposition PK,
                rsvdmasksize PK,
                rsvdfieldposition PK,
                directcolormodeinfo PK;

        char    *physbaseptr PK,           /*      LFB address  */
                *offscreenmemoffset PK;

        int     offscreenmemsize PK;

        char    reservoir_dogs[206] PK;
};

/*      Gets the VBEinfoblock information. Returns VBE_FOUND if a
        valid VESA driver is found.
*/
extern int VBEinfo(struct VBEinfoblock *plog);

/*      Gets info about a certain mode to VBEmodeblock.
*/
extern int VBEmodeinfo(int num,struct VBEmodeblock *plog);

/*      Inits a VESA mode. If linear!=0 then tries to set up a
        linear mode.
*/
extern int VBEmode(int num,int linear);

/*      Sets bank 'name' address to number*granularity.
*/
extern int VBEwindow(int name,int number);

/*      Sets the starting address to (x,y). If how==VBE_RETRACE
        then wait for VRT.
*/
extern int VBEstart(int x,int y,int how);

/*      Converts a realmode address to linear.
*/
extern void *VBEr2p(void *hieno);

/*      Checks whether a mode with specified parameters exists
        and returns its number eg. VBE_query(320,200,8,VBE_LINEAR)
*/
int VBEquery(int xr,int yr,int bp,int type);

/*      VESA made easy: init a LFB mode with specified parameters.
        Returns the LFB descriptor or -1 if failed.
*/
int VBEeasymodel(int x,int y,int bp);

/*      This should be called at exit with the LFB descriptor if
        VBEeasymodel is used.
*/
void VBEfree(int selector);

#endif

/*      EOS: VESA.H     */
