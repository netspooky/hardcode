
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "vec_file.h"
#include "vec_cam.h"
#include "vec_matr.h"
#include "vec_mtrl.h"
#include "vec_mem.h"
#include "vec_pal.h"

#define OGE     1
#define BPP     32
#define BBP     32

#define XREZ    320
#define YREZ    240


extern char	pallo[];
/*
extern char	mater[];
extern char	env2[];
extern char	env4[];
extern char	ruska[];
*/

// uint32	smurffi[XREZ*YREZ];

vec_fp  korpa[10];
int	nurpo[10];

vec_world   world;
vec_cam     cam;
vec_obj     *obj,*oobj;
vec_nod     *node;

void ranta_init(uint8 *smurffi)
{
    int n;

    char    *oname[]={pallo};

    /* ---------- Kameroiden alustus ---------- */

    vec_init(&world);
    vec_init_cam(&cam,&world);
    vec_set_camres(&cam,XREZ,YREZ,BPP);
    cam.dbuf=smurffi;

    if(vec_get_camera(oname[0],1,&cam)==VEC_ERR)
    {
        exit(0);
    }

    // cam.dirmode=VEC_CAM_AXIS;
    cam.w[Zi]=390;

    /* ---- Objektien ja keyframejen lataus --- */
    if(vec_get_objects(oname[0],&world)==VEC_ERR)
    //if(vec_load_objects("data/pallo2.3ds",&world)==VEC_ERR)
    {
        exit(0);
    }

/*    if(vec_get_kf(oname[0],&cam)==VEC_ERR)
    {
        printf("Kaamea virhe?\n");
        exit(0);
    }*/

    // vec_get_materials(mname[0],&world);

    vec_set_range(0,255);    

    vec_seek_set(&cam);
    for(n=0; (obj=vec_seek_obj(&cam)); n++)
    {	    
	// obj->colour=0xef>>n<<16;
	oobj=obj;
    }

    for(n=0; n<9; n++)
	vec_copy_object(&world,oobj,1);
    
    for(n=0; n<10; n++)
    {
	korpa[n]=rand()%30000+25000;
	nurpo[n]=rand()%350+100;
    }

    vec_set_zbuffer(&cam,0);
}

void ranta_effect(int p_time1)
{
	int 	n;	
	vec_fp	l[3]={1000,50000,180000},paso;

        //memset(cam.dbuf,0,320*240*4);

	// if(p_time1 < 1000)

	vec_set_range(128-48,128+48);

	cam.w[Zi]=145000;
	cam.w[Xi]=0;

	vec_set_lsrc(l);
	
	vec_seek_set(&cam);
	for(n=0; (obj=vec_seek_obj(&cam)); n++)
    	{
		obj->ax=n;
	
		if(n<5)
		{    				
			obj->w[Yi]=36000*(n-2);
			obj->w[Xi]=-20000-korpa[n]*(float)(nurpo[n]*nurpo[n]-(p_time1%(2*nurpo[n])-nurpo[n])*(p_time1%(2*nurpo[n])-nurpo[n]))/(nurpo[n]*nurpo[n]);
			obj->w[Zi]=-48600;				
			obj->colour=0x5f0000;			
		}
		else if(n<7)
		{
			obj->w[Yi]=36000*(n-5.5);
			obj->w[Xi]=12000-korpa[n]*(float)(nurpo[n]*nurpo[n]-(p_time1%(2*nurpo[n])-nurpo[n])*(p_time1%(2*nurpo[n])-nurpo[n]))/(nurpo[n]*nurpo[n]);
			obj->w[Zi]=0;
			obj->colour=0x9f0000;
		}
		else if(n<10)
		{
			obj->w[Yi]=36000*(n-8);
			obj->w[Xi]=52000-korpa[n]*(float)(nurpo[n]*nurpo[n]-(p_time1%(2*nurpo[n])-nurpo[n])*(p_time1%(2*nurpo[n])-nurpo[n]))/(nurpo[n]*nurpo[n]);
			obj->w[Zi]=48600;
			obj->colour=0xff0000;
		}
	}
	
	// vec_get_frame(&cam,(vec_fp)(p_time1%1000)/10);		
				
        vec_render_world(&cam);
}
