// VECTBALL.CPP
// Vector Ball routines
// coded by Tumblin / Bodies In Motion

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <conio.h>
#include "XLib_all.h"

// palette data for vector balls
char vbpalette[24*3]=
{
	 0, 0, 0, // color # 0
	 0, 0,12, // color # 1
	 4, 4,12, // color # 2
	 4, 4,16, // color # 3
	 4, 4,20, // color # 4
	 4, 4,24, // color # 5
	 8, 8,24, // color # 6
	 8, 8,28, // color # 7
	 8, 8,32, // color # 8
	 8, 8,36, // color # 9
	12,12,40, // color # 10
	12,12,44, // color # 11
	12,12,48, // color # 12
	12,12,52, // color # 13
	16,16,48, // color # 14
	16,16,52, // color # 15
	16,16,56, // color # 16
	20,20,56, // color # 17
	20,20,60, // color # 18
	24,24,60, // color # 19
	28,28,60, // color # 20
	32,32,60, // color # 21
	36,36,60, // color # 22
	60,60,60, // color # 23
};



// This is a Mode-X planar bitmap
char vbbitmap[24*31+2] =
{
	// width in bytes (4 pixel groups), height in pixels
	6,31,
	// plane 0
	0,  0,  0, 10,  0,  0,
	0,  0,  9, 12,  0,  0,
	0,  0, 10, 12, 12,  0,
	0,  5, 11, 13, 15,  0,
	0,  7, 11, 15, 15,  0,
	0,  7, 11, 15, 16,  0,
	0,  8, 11, 15, 16, 11,
	0,  8, 11, 15, 16, 12,
	0,  8, 11, 15, 16, 12,
	0,  8, 11, 15, 16, 12,
	2,  8, 11, 19, 15, 12,
	2,  8, 10, 22, 15, 12,
	2,  7, 10, 21, 13, 12,
	2,  7, 10, 15, 12, 11,
	2,  7,  9, 11, 12, 11,
	2,  7,  9, 11, 11, 10,
	2,  6,  9, 10, 11, 10,
	2,  5,  8, 10, 10,  9,
	2,  5,  8,  9, 10,  9,
	1,  4,  7,  9,  9,  8,
	1,  4,  7,  8,  9,  8,
	1,  3,  6,  8,  8,  7,
	0,  3,  5,  7,  8,  6,
	0,  3,  4,  7,  7,  4,
	0,  2,  4,  5,  6,  4,
	0,  2,  3,  4,  5,  3,
	0,  1,  3,  4,  4,  0,
	0,  1,  2,  3,  3,  0,
	0,  1,  2,  3,  3,  0,
	0,  0,  1,  2,  2,  0,
	0,  0,  1,  1,  0,  0,
	// plane 1
	0,  0,  8, 10,  0,  0,
	0,  0, 10, 12,  0,  0,
	0,  5, 11, 13, 10,  0,
	0,  7, 11, 15, 12,  0,
	0,  8, 12, 15, 15,  0,
	0,  8, 12, 16, 15,  0,
	0,  9, 12, 16, 16,  0,
	2,  9, 12, 15, 16,  8,
	3,  9, 12, 15, 16, 10,
	3,  9, 11, 16, 15, 11,
	4,  9, 11, 22, 15, 11,
	4,  8, 11, 23, 15, 11,
	4,  8, 11, 23, 13, 11,
	3,  8, 10, 20, 12, 10,
	3,  8, 10, 12, 12, 10,
	3,  7, 10, 11, 11, 10,
	3,  7,  9, 11, 11,  9,
	3,  7,  9, 10, 10,  9,
	2,  5,  8, 10, 10,  8,
	2,  5,  8,  9,  9,  7,
	2,  4,  7,  8,  9,  7,
	2,  4,  7,  8,  8,  5,
	1,  4,  6,  7,  7,  4,
	1,  3,  5,  7,  7,  3,
	1,  3,  4,  5,  5,  2,
	0,  2,  4,  5,  4,  0,
	0,  2,  3,  4,  4,  0,
	0,  1,  3,  3,  3,  0,
	0,  1,  2,  3,  2,  0,
	0,  1,  2,  2,  1,  0,
	0,  0,  1,  1,  0,  0,
	// plane 2
	0,  0,  9,  0,  0,  0,
	0,  0, 11, 12,  0,  0,
	0,  8, 11, 13,  0,  0,
	0,  9, 12, 15, 11,  0,
	0,  9, 12, 16, 12,  0,
	0,  9, 12, 16, 13,  0,
	4, 10, 12, 16, 15,  0,
	4, 10, 12, 16, 15,  0,
	5, 10, 12, 16, 15,  0,
	5,  9, 12, 16, 15,  0,
	5,  9, 12, 18, 15,  8,
	5,  9, 11, 22, 13,  9,
	5,  9, 11, 22, 12,  9,
	4,  9, 11, 17, 12,  9,
	4,  8, 10, 12, 12,  9,
	4,  8, 10, 11, 11,  8,
	4,  8, 10, 11, 11,  8,
	3,  7,  9, 10, 10,  7,
	3,  7,  9, 10, 10,  7,
	3,  6,  8,  9,  9,  5,
	3,  5,  8,  9,  8,  4,
	2,  4,  7,  8,  8,  3,
	2,  4,  7,  7,  7,  0,
	2,  4,  5,  7,  6,  0,
	1,  3,  5,  6,  5,  0,
	1,  3,  4,  5,  4,  0,
	0,  2,  3,  4,  3,  0,
	0,  2,  3,  3,  3,  0,
	0,  1,  2,  3,  2,  0,
	0,  1,  2,  2,  0,  0,
	0,  0,  1,  1,  0,  0,
	// plane 3
	0,  0, 10,  0,  0,  0,
	0,  8, 11, 11,  0,  0,
	0,  9, 12, 12,  0,  0,
	0, 10, 12, 15,  0,  0,
	4, 10, 13, 16, 10,  0,
	5, 10, 13, 16, 12,  0,
	6, 10, 13, 16, 12,  0,
	7, 10, 13, 16, 13,  0,
	7, 10, 13, 16, 13,  0,
	7, 10, 12, 16, 13,  0,
	7, 10, 12, 15, 13,  0,
	7, 10, 14, 15, 12,  0,
	6,  9, 12, 15, 12,  0,
	6,  9, 11, 12, 12,  0,
	5,  9, 11, 12, 11,  0,
	5,  8, 10, 11, 11,  0,
	4,  8, 10, 11, 10,  0,
	4,  8,  9, 10, 10,  0,
	4,  7,  9, 10,  9,  0,
	4,  7,  9,  9,  9,  0,
	3,  6,  8,  9,  8,  0,
	3,  5,  7,  8,  7,  0,
	3,  4,  7,  8,  7,  0,
	2,  4,  6,  7,  5,  0,
	2,  4,  5,  6,  4,  0,
	1,  3,  4,  5,  4,  0,
	1,  3,  4,  4,  3,  0,
	1,  2,  3,  3,  2,  0,
	0,  2,  3,  3,  0,  0,
	0,  1,  2,  2,  0,  0,
	0,  0,  1,  0,  0,  0
};



// function prototypes
void draw_vector_balls(void);
void create_lookup_tables(void);
void create_vector_object(void);
int main(void);

// sin and cos lookup tables
float cosine[360];
float sine[360];

// structure for one vector ball
typedef struct
{
	int x;
	int y;
	int z;
	int color;
} VectBallType;

// maximum number of balls in this demo's object
int maxballs=8;

// start off demo with some random initial angles
int xangle=random(360);
int yangle=random(360);
int zangle=random(360);

// the z distance from the center of the universe (0, 0, 0 :-)
int distance=256;
// flag to tell when the object is moving towards or away from you
int direction=1;

// origional vector ball object
VectBallType object[8];
// working copy of vector ball object
VectBallType temp[8];
// single dummy vector ball used for swaping
VectBallType dummy;

//---------------------------------------------------------------
void create_lookup_tables(void)
{
	int i;
	for(i=0; i<360; i++)
	{
		cosine[i] = cos(i * 3.14159265 / 180);
		sine[i] = sin(i * 3.14159265 / 180);
	}
}


//---------------------------------------------------------------
void create_vector_object(void)
{
	// This object will look like a cube
	// back top left
	object[0].x=-30;
	object[0].y=-30;
	object[0].z=30;
	// back top right
	object[1].x=30;
	object[1].y=-30;
	object[1].z=31;
	// back bottom left
	object[2].x=-30;
	object[2].y=30;
	object[2].z=32;
	// back bottom right
	object[3].x=30;
	object[3].y=30;
	object[3].z=33;
	// front top left
	object[4].x=-30;
	object[4].y=-30;
	object[4].z=-30;
	// front top right
	object[5].x=30;
	object[5].y=-30;
	object[5].z=-31;
	// front bottom left
	object[6].x=-30;
	object[6].y=30;
	object[6].z=-32;
	// front bottom right
	object[7].x=30;
	object[7].y=30;
	object[7].z=-33;
}

void draw_vector_object(void)
{
	int i,j,k,a,b,nx,ny,nz;

	// first we have to do all the rotations
	for(i=0;i<8;i++)
	{
		// rotate around the x-axis
		ny=(int)(object[i].y*cosine[xangle]-object[i].z*sine[xangle]);
		nz=(int)(object[i].y*sine[xangle]+object[i].z*cosine[xangle]);
		nx=(int)(object[i].x);
		temp[i].x=nx;
		temp[i].y=ny;
		temp[i].z=nz;

		// rotate around the y-axis
		nx=(int)(temp[i].x * cosine[yangle] +temp[i].z * sine[yangle]);
		nz=(int)(-temp[i].x * sine[yangle]+temp[i].z * cosine[yangle]);
		temp[i].x=nx;
		temp[i].z=nz;

		// rotate around the z-axis
		nx=(int)(temp[i].x * cosine[zangle]-temp[i].y * sine[zangle]);
		ny=(int)(temp[i].x * sine[zangle]+temp[i].y * cosine[zangle]);
		temp[i].x=nx;
		temp[i].y=ny;

		// now we have to push the z coordinates into the view area
		temp[i].z-=distance;

		// finally we project & copy the new x,y,z to a temporary array
		temp[i].x=(int)((temp[i].x*256)/temp[i].z+160);
		temp[i].y=(int)((temp[i].y*256)/temp[i].z+120);
		temp[i].color=object[i].color;
	}

	// now we need to do z-buffering
	// the z with most positive value should be in lowest index
	// I used bubble sort here because there are only 8 balls :-)
	for(j=0;j<7;j++)
	{
		for(k=j+1;k<8;k++)
		{
			a=temp[j].z;
			b=temp[k].z;
			if(a >= b)
			{
				// swap the two vector balls
				dummy=temp[j];
				temp[j]=temp[k];
				temp[k]=dummy;
			}
		}
	}

	// we're done everything, so draw the object!
	// first we erase the old stuff off the drawing zone
	x_rect_fill(160-70,120-70,160+70,120+70,HiddenPageOffs,0);
	for(i=0;i<8;i++)
	{
		x_put_masked_pbm(temp[i].x-11,temp[i].y-15,HiddenPageOffs,vbbitmap);
	}
}


//---------------------------------------------------------------
int main(void)
{
	randomize();
	x_text_mode();
	printf("\n\n\nV E C T O R   B A L L S");
	printf("\ncoded by Tumblin / Bodies In Motion  (a.k.a.  Terry Sznober)");
	printf("\n\n\nPress any key to begin demo.  Press a key again to quit demo.");
	getch();
	x_set_mode(X_MODE_320x240,320);
	create_lookup_tables();
	create_vector_object();
	x_put_pal_raw(vbpalette,24,0);
	x_set_doublebuffer(240);
	for(;;)	// do an infinite loop until user hits a key
	{
		if(kbhit())
			break;
		if(direction==1)	// if object is moving away from you,
		{
			distance++;	// move it even further
			if(distance>=600)	// if at the limit, make it come back
			{
				direction=0;
				distance=600;
			}
		}
		else	// no, object is moving towards you
		{
			distance--;	// bring it a little closer
			if(distance<=256)	// if at limit, make it go away again
			{
				direction=1;
				distance=256;
			}
		}
		// update the angles
		xangle+=3;
		if(xangle>=360)
			xangle=0;
		yangle+=3;
		if(yangle>=360)
			yangle=0;
		zangle-=2;
		if(zangle<=0)
			zangle=359;
		// draw the vector ball object on the hidden screen
		draw_vector_object();
		// show what we just did
		x_page_flip(0,0);
	}
	getch();
	x_text_mode();

	// show the greets                                                                   |
	printf("                     Tumblin / Bodies In Motion  greets:\n\n");
	printf("                             The Future Crew\n");
	printf("                                Avalanche\n");
	printf("                         The Emulator Institute\n");
	printf("                                 Triton\n");
	printf("                                 Witan\n");
	printf("                                Silents\n\n");
	printf("                                 Shades\n");
	printf("                              Shadow Hunter\n");
	printf("                                 Gravis\n");
	printf("                     all the guys that helped me on IRC\n");
	printf("                  every coder who ever released source code\n");
	printf("                       and Themie Gouthas for XLib06\n");

	return(0);
}
