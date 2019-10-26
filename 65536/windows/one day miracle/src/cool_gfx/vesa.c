/*
        VESA.C DJGPP-version
        (c) Marq 1996-1999
*/

#include <sys/farptr.h>
#include <sys/nearptr.h>
#include <go32.h>
#include <dpmi.h>
#include <stdio.h>
#include "vesa.h"

int VBEinfo(struct VBEinfoblock *plog)  /*      Gets VESA info  */
{
        __dpmi_regs      vbecallback;

        dosmemput(plog,VBEINFO,__tb);   /*      Copy parameters to dosmem */
        vbecallback.d.eax=0x4F00;       /*      Get info        */
        vbecallback.x.es=__tb>>4;
        vbecallback.d.edi=__tb&0xf;
        __dpmi_int(0x10,&vbecallback);  /*      Call int 10h    */

        dosmemget(__tb,VBEINFO,plog);   /*      Copy parameters from dosmem */
        return(vbecallback.d.eax);
}

int VBEmodeinfo(int num,struct VBEmodeblock *plog)
{
        __dpmi_regs      vbecallback;

        dosmemput(plog,VBEMODE,__tb);
        vbecallback.d.eax=0x4F01;       /*      Get mode info   */
        vbecallback.x.es=__tb>>4;
        vbecallback.d.edi=__tb&0xf;
        vbecallback.d.ecx=num;
        __dpmi_int(0x10,&vbecallback);

        dosmemget(__tb,VBEMODE,plog);
        return(vbecallback.d.eax);
}

int VBEmode(int num,int linear)
{
        __dpmi_regs      vbecallback;

        vbecallback.d.eax=0x4f02;       /*      Set VESA mode   */
        vbecallback.d.ebx=num | ((linear) ? 0x4000:0);
        __dpmi_int(0x10,&vbecallback);
        return(vbecallback.d.eax);
}

int VBEwindow(int name,int number)
{
        __dpmi_regs      vbecallback;

        vbecallback.d.eax=0x4f05;       /*      Set window location */
        vbecallback.d.ebx=name;
        vbecallback.d.edx=number;
        __dpmi_int(0x10,&vbecallback);
        return(vbecallback.d.eax);
}

int VBEstart(int x,int y,int how)
{
        __dpmi_regs      vbecallback;

        vbecallback.d.eax=0x4f07;       /*      Set starting address    */
        vbecallback.d.ebx=how;
        vbecallback.d.ecx=x;
        vbecallback.d.edx=y;
        __dpmi_int(0x10,&vbecallback);
        return(vbecallback.d.eax);
}

void *VBEr2p(void *hieno)       /*      linear=segment*16+offset+base   */
{
        unsigned        naggi=(int)hieno;

        return((void *)((naggi&0xffff)+(naggi>>16)*16
               +__djgpp_conventional_base));
}

int VBEquery(int xr,int yr,int bp,int type)
{
        int     n=0,l,lippu=0;

        struct VBEinfoblock     luu;

        struct VBEmodeblock     jaa;

        unsigned short  *modelist;

        if(VBEinfo(&luu)!=VBE_FOUND)    /*      No VESA         */
                return(0);

        __djgpp_nearptr_enable();
        modelist=VBEr2p(luu.videomodeptr);      /*   Scan through the modes */
        while(modelist[n]!=0xffff && !lippu)
        {
                VBEmodeinfo(modelist[n],&jaa);

                if(jaa.xresolution==xr)         /*      Check attributes */
                        if(jaa.yresolution==yr)
                                if(jaa.bitsperpixel==bp)
                                        if(type) /*     Linear? */
                                        {
                                                if(jaa.modeattributes&VBE_LINEAR)
                                                        lippu=modelist[n];
                                        }
                                        else    /*      Banked  */
                                        {
                                                if(!(jaa.modeattributes&VBE_LINEAR))
                                                        lippu=modelist[n];
                                        }
                n++;
        }

        __djgpp_nearptr_disable();
        return(lippu);
}

int VBEeasymodel(int x,int y,int bp)
{
        struct VBEinfoblock     info;

        struct VBEmodeblock     mote;
        
        int     a,selector;

        __dpmi_meminfo  mi;

        a=VBEquery(x,y,bp,VBE_LINEAR);
        if(!a)
                return(-1);     /*      No such mode    */

        VBEmodeinfo(a,&mote);
        VBEmode(a,VBE_LINEAR);
        
        VBEinfo(&info);
                                /*      Get the actual address of LFB   */
        mi.address=(int)mote.physbaseptr;
        mi.size=info.totalmemory*65536;
        __dpmi_physical_address_mapping(&mi);

                                        /*      Get a selector to LFB   */
        selector=__dpmi_allocate_ldt_descriptors(1);
        __dpmi_set_segment_base_address(selector,mi.address);
        __dpmi_set_segment_limit(selector,mi.size-1);

        return(selector);
}

void VBEfree(int selector)
{
        __dpmi_free_ldt_descriptor(selector);
}

/*      EOS: VESA.C     */
