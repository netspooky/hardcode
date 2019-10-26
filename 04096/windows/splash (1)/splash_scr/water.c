#include "main.h"
#include "mygl.h"
#include "water.h"

i16	*pBuffer[2];
i32	waterwh,current;
f32 radius=20.0f;
i8 power=-15;

void deinitWater(void)
{
	DEALLOC(pBuffer[0]);
	DEALLOC(pBuffer[1]);
}
void initWater(void)
{
	current=0;
	pBuffer[0]=NULL;
	pBuffer[1]=NULL;
	waterwh=128;
	pBuffer[0] = (i16*)ALLOC(sizeof(i16)*waterwh*waterwh);
	pBuffer[1] = (i16*)ALLOC(sizeof(i16)*waterwh*waterwh);
	memset(pBuffer[0],0,waterwh*waterwh*2);
	memset(pBuffer[1],0,waterwh*waterwh*2);
}

/*
void drawWater2(void)
{
	int i,j;
//	i16 *dst=pBuffer[!current];
//	int	ptr=NULL;
	glBegin(GL_QUADS);
	for (j=1; j<waterwh-1; j++)
		for (i=1; i<waterwh-1; i++)
		{
			//ptr=(j*waterwh)+i;
			//x=(float)(i-waterwh/2)/waterwh;
			//y=(float)(*(src+ptr))/255.0f;
			//z=(float)(j-waterwh/2)/waterwh;

		
			edge(i,j);
//			if (y>1.0f) y=1.0f;
//			glColor3f(0.1+y*2,0.1+y*2,0.1+y*2);
//			glNormal3f(0.1f+y*2.0f,0.1f+y*2.0f,0.1f+y*2.0f);
//			glVertex3f(x,y,z);

			//ptr=(j*waterwh)+i+1;
			//x=(float)((i+1)-waterwh/2)/waterwh;
			//y=(float)(*(src+ptr))/255;
			//z=(float)((j+0)-waterwh/2)/waterwh;
			edge(i+1,j);
//
//			edge(x,y,z);

			//ptr=((j+1)*waterwh)+i+1;
			//x=(float)((i+1)-waterwh/2)/waterwh;
			//y=(float)(*(src+ptr))/255;
			//z=(float)((j+1)-waterwh/2)/waterwh;
			edge(i+1,j+1);
			//edge(x,y,z);
			//if (y>1.0f) y=1.0f;
			//glColor3f(0.1+y*2,0.1+y*2,0.1+y*2);
			//glNormal3f(0.1f+y*2.0f,0.1f+y*2.0f,0.1f+y*2.0f);
			//glVertex3f(x,y,z);

			edge(i,j+1);
			//ptr=((j+1)*waterwh)+i+0;
			//x=(float)((i+0)-waterwh/2)/waterwh;
			//y=(float)(*(src+ptr))/255;
			//z=(float)((j+1)-waterwh/2)/waterwh;
			//edge(x,y,z);
			//if (y>1.0f) y=1.0f;
			//glColor3f(0.1+y*2,0.1+y*2,0.1+y*2);
			//glNormal3f(0.1f+y*2.0,0.1f+y*2.0f,0.1f+y*2.0f);
			//glVertex3f(x,y,z);

		}
		glEnd();
}
*/

void edge(int i,int j)
{
	f32 x,y,z;
	int ptr;
	i16 *src=pBuffer[current];
	ptr=(j*waterwh)+i;
	x=(float)(i-waterwh/2)/waterwh;
	y=(float)(*(src+ptr))/255.0f;
	z=(float)(j-waterwh/2)/waterwh;
	if (y>1.0f) y=1.0f;
	glColor3f(0.1+y*2,0.1+y*2,0.1+y*2);
	glNormal3f(0.1f+y*2.0f,0.1f+y*2.0f,0.1f+y*2.0f);
	glVertex3f(x,y,z);
}

void drawWater(void)
{
	int i,j;
	glBegin(GL_QUADS);
	for (j=1; j<waterwh-1; j++)
		for (i=1; i<waterwh-1; i++)
		{
			edge(i,j);
			edge(i+1,j);
			edge(i+1,j+1);
			edge(i,j+1);
		}
		glEnd();
}

/*
void drawWater(void)
{
	int i,j;
	f32 x,y,z;
	i16 *src=pBuffer[current];
	i16 *dst=pBuffer[!current];
	int	ptr=NULL;
	glBegin(GL_QUADS);
	for (j=1; j<waterwh-1; j++)
		for (i=1; i<waterwh-1; i++)
		{
			ptr=(j*waterwh)+i;
			x=(float)(i-waterwh/2)/waterwh;
			y=(float)(*(src+ptr))/255.0f;
			z=(float)(j-waterwh/2)/waterwh;
			if (y>1.0f) y=1.0f;
			glColor3f(0.1+y*2,0.1+y*2,0.1+y*2);
			glNormal3f(0.1f+y*2.0f,0.1f+y*2.0f,0.1f+y*2.0f);
			glVertex3f(x,y,z);
			
			ptr=(j*waterwh)+i+1;
			x=(float)((i+1)-waterwh/2)/waterwh;
			y=(float)(*(src+ptr))/255;
			z=(float)((j+0)-waterwh/2)/waterwh;
			if (y>1.0f) y=1.0f;
			glColor3f(0.1+y*2,0.1+y*2,0.1+y*2);
			glNormal3f(0.1f+y*2.0f,0.1f+y*2.0f,0.1f+y*2.0f);
			glVertex3f(x,y,z);
			
			
			ptr=((j+1)*waterwh)+i+1;
			x=(float)((i+1)-waterwh/2)/waterwh;
			y=(float)(*(src+ptr))/255;
			z=(float)((j+1)-waterwh/2)/waterwh;
			if (y>1.0f) y=1.0f;
			glColor3f(0.1+y*2,0.1+y*2,0.1+y*2);
			glNormal3f(0.1f+y*2.0f,0.1f+y*2.0f,0.1f+y*2.0f);
			glVertex3f(x,y,z);
			
			ptr=((j+1)*waterwh)+i+0;
			x=(float)((i+0)-waterwh/2)/waterwh;
			y=(float)(*(src+ptr))/255;
			z=(float)((j+1)-waterwh/2)/waterwh;
			if (y>1.0f) y=1.0f;
			glColor3f(0.1+y*2,0.1+y*2,0.1+y*2);
			glNormal3f(0.1f+y*2.0,0.1f+y*2.0f,0.1f+y*2.0f);
			glVertex3f(x,y,z);
			
		}
		glEnd();
}
*/
void updateWater(void)
{
	int i,j;
	i16 *src=pBuffer[current];
	i16 *dst=pBuffer[!current];
	i16 c0,c1,c2,c3,c4,c5;
	int	ptr=NULL;
	for (j=1; j<waterwh-1; j++)
		for (i=1; i<waterwh-1; i++)
		{
			ptr=(j*waterwh)+i;
			
			c0=*(src+(ptr-1));		//x+1,y+0
			c1=*(src+(ptr+1));		//x-1,y+0
			c2=*(src+(ptr+waterwh));		//x+0,y+1
			c3=*(src+(ptr-waterwh));		//x+0,y-1
			c4=*(dst+ptr);			//x+0,y+0
			c5=((c0+c1+c2+c3)>>1)-c4;

			//c5=c5-(c5/32);
			c5-=c5>>21;
			
			*(dst+ptr)=c5;
		}
		current=!current;
}

#define DEG2RAD 0.0174532925f

void hitWater(void)
{
	int x,y,a,b;
	int m;
	i16 *p;
	int offset;
	x=rand()%128;
	y=rand()%128;
	p=pBuffer[0];
	for (m=0; m<360; m+=1)
	{
		a=sinf((float)m*DEG2RAD)*radius;
		b=cosf((float)m*DEG2RAD)*radius;
		offset=((y+a)<<7)+x+b;
		if (offset>=0 && offset<128*128)
		{
			p[offset]+=power;
		}
	}
}