#define WIN32_LEAN_AND_MEAN
#include "main.h"
#include "mygl.h"
#include "ogl.h"
#include "font.h"

sCharImage *pCharImage;
f32		fontSizeXY;

i32 initFont(void)
{
	u32 i;
	HFONT font;
	MAT2 matrix;
	memset(&matrix,0,sizeof(MAT2));
	matrix.eM11.value=1;
	matrix.eM22.value=1;
	//MAT2 matrix = { {0, 1}, {0, 0}, {0, 0}, {0, 1} };

	fontSizeXY=128;
	font=CreateFont(fontSizeXY,0,0,0,fontSizeXY,FALSE,0,0,
			ANSI_CHARSET,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,
			ANTIALIASED_QUALITY,FF_DONTCARE|DEFAULT_PITCH,
			"Arial Black");

	SelectObject(hDC,font);

	pCharImage = (sCharImage*)ALLOC(sizeof(sCharImage)*256);

	for (i=33; i<128; i++)
	{
		//identity
		sCharImage *ch=&pCharImage[i];
		GLYPHMETRICS metrics;
		u32 size;
		i8 *buffer;
		ch->w=ch->h=0;
		ch->u0=ch->v0=0.0f;
		ch->u1=ch->v1=0.0f;
		ch->data=NULL;
		ch->glTex=0;
	
		size=GetGlyphOutline(hDC,i,GGO_GRAY8_BITMAP,&metrics,0,NULL,&matrix);
		buffer=(i8*)ALLOC(sizeof(i8)*size);
		GetGlyphOutline(hDC,i,GGO_GRAY8_BITMAP,&metrics,size,buffer,&matrix);
	
		ch->w=metrics.gmBlackBoxX;
		ch->h=metrics.gmBlackBoxY;
		ch->data =(u32*)ALLOC(sizeof(u32)*ch->w*ch->h);
		{
			i32 ptr=0;
			u32 ii,jj;
			for (ii=0; ii<ch->h; ii++)
			{
				u32 pitch=((((u32)ch->w-1)>>2)+1)<<2; // data is aligned to DWORD
				for (jj=0; jj<ch->w; jj++)
				{
					u32 c8=(buffer[(ii*pitch)+jj])<<2;
					u32 c32;
					if (c8>255) c8=255;
					c32=(c8)+(c8<<8)+(c8<<16)+(c8<<24);
					ch->data[ptr]=c32;
					ptr++;
				}
			}
		}
		DEALLOC(buffer);
	}

	for (i=33; i<128; i++)
	{
		sCharImage *ch=&pCharImage[i];
		if (ch->data)
		{
			u32 xOffset=0;
			u32 np2x=findNextPower2(ch->w+4);
			u32 np2y=findNextPower2(ch->h+4);

			glGenTextures(1, &ch->glTex);
			glBindTexture(GL_TEXTURE_2D,ch->glTex);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
			glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE,GL_MODULATE);
			glTexImage2D(GL_TEXTURE_2D,0,4,np2x,np2y,0,GL_RGBA,GL_UNSIGNED_BYTE,NULL);
			glTexSubImage2D(GL_TEXTURE_2D,0,xOffset,0,ch->w,ch->h,GL_RGBA,GL_UNSIGNED_BYTE,ch->data);
			ch->u0=(f32)xOffset/(f32)np2x;
			ch->v0=0.0f;
			xOffset+=ch->w+4;
			ch->u1=(f32)xOffset/(f32)np2x;
			ch->v1=(f32)(ch->h+4)/np2y;
		}
	}

	DeleteObject(font);
	return 0;
}

void deinitFont(void)
{
	u32 i;
	for (i=33; i<128; i++)
	{
		sCharImage *ch=&pCharImage[i];
		DEALLOC(ch->data);
		ch->data=NULL;
		if (ch->glTex) 
			glDeleteTextures(1,&ch->glTex);	
		ch->glTex=NULL;
	}
	DEALLOC(pCharImage);
}

void printFont(i8 *str,f32 spacing)
{
	u32 len=strlen(str);
	u32 i;
	f32 xOffset=0.0f;
	f32 yOffset=0.0f;
	// length the whole string takes up
	f32 lenny=0.0f;

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER,0.001);

	glMatrixMode(GL_TEXTURE+0);
	glLoadIdentity();
	//glTranslatef(-0.5,-0.5,0);
	glRotatef(10,0,0,1);
	//glRotatef(90,1,1,0);
	//glTranslatef(-0.5,-0.5,0);
	//glScalef(2.1,2.1,2.1);
	//glMatrixMode(GL_MODELVIEW);

	for (i=0; i<len; i++)
	{
		i8 c=str[i];
		sCharImage *ch=&pCharImage[c];
		f32 kern=((f32)ch->w/(f32)fontSizeXY);
		lenny+=kern+spacing;

		yOffset=((f32)ch->h/(f32)fontSizeXY)*0.5f;
	}


	//center font
	xOffset-=lenny*0.5f;

	for (i=0; i<len; i++)
	{
		i8 c=str[i];
		sCharImage *ch=&pCharImage[c];

		f32 kern=((f32)ch->w/(f32)fontSizeXY);

		if (ch->data)
		{
			f32 x0=xOffset;
			f32 y0=-yOffset;
			f32 x1=x0+kern;
			f32 y1=((f32)ch->h/(f32)fontSizeXY)-yOffset;//(f32)ch->h;
			glBindTexture(GL_TEXTURE_2D,ch->glTex);
	  		glBegin(GL_QUADS);
				glTexCoord2f(ch->u0,ch->v1);
				glVertex3f(x0,y0,0.0f);
				glTexCoord2f(ch->u1,ch->v1);
				glVertex3f(x1,y0,0.0f);
				glTexCoord2f(ch->u1,ch->v0);
				glVertex3f(x1,y1,0.0f);
				glTexCoord2f(ch->u0,ch->v0);
				glVertex3f(x0,y1,0.0f);
			glEnd();
			xOffset+=kern+spacing;
		}
		else
		{
			xOffset+=0.3;
		}
	}
}

void bindChar(i8 ch)
{
	sCharImage *cht=&pCharImage[ch];
	glBindTexture(GL_TEXTURE_2D,cht->glTex);
}