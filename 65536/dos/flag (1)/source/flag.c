/* Program to model a waving flag */
/* By D.Hedley 11/7/93 */

#include <math.h>
#include <dos.h>
#include <stdlib.h>
#include <string.h>


#define MODELAS  Float2Fixed(32.0)
#define DIST 	 Float2Fixed(30.0)
#define DMODELAS Float2Fixed(32.0)
#define DDIST 	 Float2Fixed(42.42640687)  	/* sqrt(DIST*DIST+DIST*DIST) */
#define DAMPING  Float2Fixed(1.03125)

#define HEIGHT	 11
#define WIDTH	 13

#define XP (int)((320-((float)WIDTH*Fixed2Float(DIST)/Fixed2Float(XSCALE)))/2)
#define YP (43+35)
#define XSCALE Float2Fixed(2.75)
#define YSCALE Float2Fixed(3.75)


#define myabs(a) ((a) < 0 ? -(a) : (a))


typedef long Fixed;

typedef struct
{
	Fixed x,y;
	Fixed xv,yv;
} Pos;


Pos array1[HEIGHT*WIDTH];
Pos array2[HEIGHT*WIDTH];

Fixed angle[HEIGHT*WIDTH];

Fixed hforce[HEIGHT*(WIDTH-1)];
Fixed vforce[(HEIGHT-1)*WIDTH];
Fixed dforce[(HEIGHT-1)*(WIDTH-1)];

Fixed vdist[(HEIGHT-1)*WIDTH];
Fixed hdist[HEIGHT*(WIDTH-1)];
Fixed ddist[(HEIGHT-1)*(WIDTH-1)];


struct
{
	int x,y;
} psn[(HEIGHT-1)*(WIDTH-1)];


#define Int2Fixed(a)	(Fixed)((Fixed)(a) << 16)
#define Fixed2Int(a)	(int)((a) >> 16)
#define Float2Fixed(a)	((Fixed)((a) * 65536.0))
#define Fixed2Float(a)	((a) / 65536.0)

Pos *newpos = array2;
Pos *oldpos = array1;

int fps = 0;

#define RD 1
#define WT 11
#define BL 21

#define NCOLS Int2Fixed(10)

struct
{
	int col1,col2;
} colours[] =
{
	{WT,RD},{BL,WT},{BL,BL},{WT,WT},{RD,RD},{RD,RD},{WT,WT},{BL,BL},{WT,BL},{RD,WT},
	{RD,WT},{WT,RD},{BL,WT},{WT,WT},{RD,RD},{RD,RD},{WT,WT},{WT,BL},{RD,WT},{WT,RD},
	{WT,BL},{RD,WT},{WT,RD},{WT,WT},{RD,RD},{RD,RD},{WT,WT},{RD,WT},{WT,RD},{BL,WT},
	{BL,BL},{WT,BL},{RD,WT},{WT,WT},{RD,RD},{RD,RD},{WT,WT},{WT,RD},{BL,WT},{BL,BL},
	{WT,WT},{WT,WT},{WT,WT},{WT,WT},{RD,RD},{RD,RD},{WT,WT},{WT,WT},{WT,WT},{WT,WT},
	{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},
	{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},{RD,RD},
	{WT,WT},{WT,WT},{WT,WT},{WT,WT},{RD,RD},{RD,RD},{WT,WT},{WT,WT},{WT,WT},{WT,WT},
	{BL,BL},{WT,BL},{RD,WT},{WT,WT},{RD,RD},{RD,RD},{WT,WT},{WT,RD},{BL,WT},{BL,BL},
	{WT,BL},{RD,WT},{WT,RD},{WT,WT},{RD,RD},{RD,RD},{WT,WT},{RD,WT},{WT,RD},{BL,WT},
	{RD,WT},{WT,RD},{BL,WT},{WT,WT},{RD,RD},{RD,RD},{WT,WT},{WT,BL},{RD,WT},{WT,RD},
	{WT,RD},{BL,WT},{BL,BL},{WT,WT},{RD,RD},{RD,RD},{WT,WT},{BL,BL},{WT,BL},{RD,WT}

};

unsigned char pal1[256*3];
unsigned char pal2[256*3];
unsigned char c_pal[256*3];
unsigned char black_pal[256*3];
unsigned char white_pal[256*3];

unsigned char bits_pal[256*3] =
{
	 0,0,0,32,0,0,0,32,0,32,32,0,0,0,32,32,
	 0,32,0,32,32,32,32,32,48,48,48,63,0,0,0,63,
	 0,63,63,0,0,0,63,63,0,63,0,63,63,63,63,63,
	 63,63,63,59,59,59,54,54,54,50,50,50,46,46,46,42,
	 42,42,38,38,38,33,33,33,29,29,29,25,25,25,21,21,
	 21,17,17,17,13,13,13,8,8,8,4,4,4,0,0,0,
	 16,0,0,23,0,0,29,0,0,36,0,0,43,0,0,49,
	 0,0,56,0,0,63,0,0,63,8,8,63,16,16,63,24,
	 24,63,32,32,63,39,39,63,47,47,63,55,55,63,63,63,
	 63,55,55,63,47,47,63,39,39,63,32,32,63,24,24,63,
	 16,16,63,8,8,63,0,0,57,0,0,51,0,0,45,0,
	 0,39,0,0,33,0,0,28,0,0,22,0,0,16,0,0,
	 39,39,63,38,38,63,36,37,63,35,36,63,34,35,63,33,
	 33,63,32,32,63,31,31,63,30,30,63,28,29,63,27,28,
	 63,26,27,63,25,25,63,24,24,63,22,23,63,21,22,63,
	 20,21,63,19,19,63,17,18,63,16,17,63,15,16,63,14,
	 15,63,13,14,63,12,13,63,11,12,63,9,10,63,8,9,
	 63,7,8,63,6,7,63,5,6,63,3,4,63,2,3,63,
	 0,1,63,0,1,61,0,1,59,0,1,57,0,1,55,0,
	 1,53,0,1,51,0,1,48,0,0,47,0,0,45,0,0,
	 43,0,0,41,0,0,38,0,0,36,0,0,34,0,0,32,
	 0,0,30,0,0,28,0,0,26,0,0,24,0,0,22,0,
	 0,20,0,0,18,0,0,16,0,0,14,0,0,12,0,0,
	 10,0,0,8,0,0,6,0,0,4,0,0,2,0,0,0,
	 54,59,63,46,56,63,39,53,63,31,50,63,23,47,63,16,
	 44,63,8,42,63,0,39,63,0,35,57,0,31,51,0,27,
	 45,0,23,39,0,19,33,0,16,28,0,12,22,0,9,16,
	 54,54,63,46,47,63,39,39,63,31,32,63,23,24,63,16,
	 16,63,8,9,63,0,1,63,0,1,57,0,1,51,0,0,
	 45,0,0,39,0,0,33,0,0,28,0,0,22,0,0,16,
	 60,54,63,57,46,63,54,39,63,52,31,63,50,23,63,47,
	 16,63,45,8,63,42,0,63,38,0,57,32,0,51,29,0,
	 45,24,0,39,20,0,33,17,0,28,13,0,22,10,0,16,
	 63,54,63,63,46,63,63,39,63,63,31,63,63,23,63,63,
	 16,63,63,8,63,63,0,63,56,0,57,50,0,51,45,0,
	 45,39,0,39,33,0,33,27,0,28,22,0,22,16,0,16,
	 63,58,55,63,56,52,63,54,49,63,53,47,63,51,44,63,
	 49,41,63,47,39,63,46,36,63,44,32,63,41,28,63,39,
	 24,60,37,23,58,35,22,55,34,21,52,32,20,50,31,19,
	 47,30,18,45,28,17,42,26,16,40,25,15,39,24,14,36,
	 23,13,34,22,12,32,20,11,29,19,10,27,18,9,23,16,
	 8,21,15,7,18,14,6,16,12,6,14,11,5,10,8,3,
	 55,0,0,53,6,0,52,13,0,50,19,0,49,24,0,48,
	 29,0,47,35,0,45,39,0,44,43,0,32,43,0,19,42,
	 0,7,42,0,0,41,5,0,40,16,0,40,28,0,40,37,
	 0,35,41,0,27,42,0,18,42,0,10,43,19,0,46,27,
	 0,46,33,0,46,41,0,46,46,0,43,46,0,35,46,0,
	 29,46,0,22,46,0,14,47,0,8,47,0,0,63,63,63
};



extern void SetGraphicsMode(void);
extern void draw_filled_triangle(int,int,int,int,int,int,int);
extern void SwapScreens(void);
extern void SetTextMode(void);
extern void SetPalette(unsigned char *);
extern void FadePalette(unsigned char *,unsigned char *);
extern void DrawText(int, int, char *);
extern void BlankScreen(void);
extern void Sync(void);
extern void StartASM(void);
extern void EndASM(void);

extern void PutBits(void);

extern Fixed FixedAdd(Fixed,Fixed);
extern Fixed FixedMul(Fixed,Fixed);
extern Fixed FixedDiv(Fixed,Fixed);

extern Fixed Distance(int,int);

extern unsigned char OKtoblank;
extern unsigned long FrameNum;

void CalcForces(void)
{
	int i,j,cpos;
	register Fixed *f,*d;

	for (j = 0,cpos = 0,f = &hforce[0],d = &hdist[0]; j < HEIGHT; j++,cpos++)
		for (i = 0; i < WIDTH-1 ; i++,f++,d++,cpos++)
		{
			*d = Distance(cpos,cpos+1);
			if ((*f = -FixedDiv(FixedMul(*d-DIST,MODELAS),DIST)) > 0)
				*f = 0;
		}


	for (j = 0,f = &vforce[0],d = &vdist[0]; j < (HEIGHT-1)*WIDTH; j++,f++,d++)
	{
		*d = Distance(j,j+WIDTH);
		if ((*f = -FixedDiv(FixedMul(*d-DIST,MODELAS),DIST)) > 0)
			*f = 0;
	}


	for (j = 0,cpos = 0, f = &dforce[0],d = &ddist[0]; j<HEIGHT-1; j++,cpos++)
		for (i = 0; i < WIDTH-1; i++,f++,d++,cpos++)
		{
			*d = Distance(cpos,cpos+WIDTH+1);
			if ((*f = -FixedDiv(FixedMul(*d-DDIST,DMODELAS),DDIST)) > 0)
				*f = 0;
		}

}


#define ChangePos(pos) \
	{ \
		if ((newpos[pos].xv = FixedDiv(oldpos[pos].xv+hf, DAMPING))\
					> Float2Fixed(25.0))\
			newpos[pos].xv = Float2Fixed(25.0); \
		if((newpos[pos].yv = FixedDiv(oldpos[pos].yv+vf+Float2Fixed(1.0), DAMPING))\
					> Float2Fixed(15.0)) \
			newpos[pos].yv = Float2Fixed(15.0); \
		newpos[pos].x = oldpos[pos].x + newpos[pos].xv; \
		newpos[pos].y = oldpos[pos].y + newpos[pos].yv; \
	}


#define AddForces(posx1,posy1,posx2,posy2) \
	{ \
	hf += FixedMul(oldpos[(posy1)*WIDTH+(posx1)].x - oldpos[(posy2)*WIDTH+(posx2)].x,\
			temp >> 1); \
	vf += FixedMul(oldpos[(posy1)*WIDTH+(posx1)].y - oldpos[(posy2)*WIDTH+(posx2)].y,\
			temp >> 1); \
	}

#define CalcHoriz(posx,posy,which) \
	{ \
		temp = FixedDiv(hforce[(posy)*(WIDTH-1)+(posx)], \
				hdist[(posy)*(WIDTH-1)+(posx)]);\
		AddForces((posx)+which,posy,(posx)+(1-which),(posy)) \
	}


#define CalcVert(posx,posy,which) \
	{ \
		temp = FixedDiv(vforce[(posy)*WIDTH+(posx)], \
				vdist[(posy)*WIDTH+(posx)]);\
		AddForces(posx,posy+which,posx,posy+(1-which)) \
	}


#define CalcDiag(posx,posy,which) \
	{ \
		temp = FixedDiv(dforce[(posy)*(WIDTH-1)+(posx)], \
				ddist[(posy)*(WIDTH-1)+(posx)]);\
		AddForces((posx)+which,(posy)+which,(posx)+(1-which),(posy)+(1-which)) \
	}



void CalcPos(void)
{
	Fixed hf,vf,temp;
	register int i,cpos;
	int j;

		/* Top right corner */

	hf = vf = 0;

	CalcHoriz(WIDTH-2,0,1);
	CalcVert(WIDTH-1,0,0);

	ChangePos(WIDTH-1);


		/* Bottom right corner */

	hf = vf = 0;

	CalcHoriz(WIDTH-2,HEIGHT-1,1);
	CalcVert(WIDTH-1,HEIGHT-2,1);
	CalcDiag(WIDTH-2,HEIGHT-2,1);

	ChangePos((WIDTH-1)+WIDTH*(HEIGHT-1));


		/* Right edge */

	for (i = 1,cpos = WIDTH+WIDTH-1; i < HEIGHT-1; i++,cpos+=WIDTH)
	{
		hf = vf = 0;

		CalcHoriz(WIDTH-2, i, 1);
		CalcVert(WIDTH-1, i-1, 1);
		CalcVert(WIDTH-1, i, 0);
		CalcDiag(WIDTH-2, i-1, 1);
		ChangePos(cpos);
	}


		/* Top edge */

	for (i = 1,cpos = 1; i < WIDTH-1; i++,cpos++)
	{
		hf = vf = 0;

		CalcHoriz(i-1, 0, 1);
		CalcHoriz(i, 0, 0);
		CalcVert(i, 0, 0);
		CalcDiag(i, 0, 0);

		ChangePos(cpos);
	}

		/* Middle */

	for (j = 1,cpos = 1+WIDTH; j < HEIGHT-1; j++,cpos+=2)
		for (i = 1; i < WIDTH-1; i++,cpos++)
		{
			hf = vf = 0;

			CalcHoriz(i-1,j,1);
			CalcHoriz(i,j,0);
			CalcVert(i,j-1,1);
			CalcVert(i,j,0);
			CalcDiag(i-1,j-1,1);
			CalcDiag(i,j,0);

			ChangePos(cpos);
		}

		/* Bottom edge */

	for (i = 1,cpos = (HEIGHT-1)*WIDTH+1; i < WIDTH-1; i++,cpos++)
	{
		hf = vf = 0;

		CalcHoriz(i-1,HEIGHT-1,1);
		CalcHoriz(i,HEIGHT-1,0);
		CalcVert(i,HEIGHT-2,1);
		CalcDiag(i-1,HEIGHT-2,1);

		ChangePos(cpos);
	}


		/* Left edge */

	for (j = 1,cpos = WIDTH; j < HEIGHT-1; j++,cpos+=WIDTH)
	{
//		if (j == HEIGHT/2) continue;

		hf = vf = 0;

		CalcHoriz(0,j,0);
		CalcVert(0,j,0);
		CalcVert(0,j-1,1);
		CalcDiag(0,j,0);

		ChangePos(cpos);
	}


}


void CalcAngle(void)
{
	register int i,j;

	for (j = 0; j < HEIGHT; j++)
		for (i = 0; i < WIDTH-1; i++)
		{
			if((angle[j*WIDTH+i]=DIST-myabs(newpos[j*WIDTH+i+1].x-newpos[j*WIDTH+i].x))
					 < 0)
				angle[j*WIDTH+i] = 0;
		}
}


#define x1 psn[cpos].x
#define	y1 psn[cpos].y
#define	x2 psn[cpos+1].x
#define	y2 psn[cpos+1].y
#define	x3 psn[cpos+WIDTH+1].x
#define	y3 psn[cpos+WIDTH+1].y
#define	x4 psn[cpos+WIDTH].x
#define	y4 psn[cpos+WIDTH].y


void DrawFlag(void)
{
	register int j,cpos;
	int i;

	for (j = 0; j < HEIGHT*WIDTH; j++)
	{
		psn[j].x = XP+Fixed2Int(FixedDiv(newpos[j].x,XSCALE));
		psn[j].y = YP+Fixed2Int(FixedDiv(newpos[j].y,YSCALE));
	}

	for (i = WIDTH-2, cpos = WIDTH-2; i >= WIDTH/2; cpos = --i)
	{
		for (j = 0; j < HEIGHT-1; j++,cpos += WIDTH)
		{
			if (j >= HEIGHT/2)
			{
				draw_filled_triangle(x1,y1,x3,y3,x4,y4,
					colours[i*(HEIGHT-1)+j].col1+Fixed2Int(FixedMul(
					FixedDiv(angle[cpos+WIDTH],DIST),NCOLS)));

				draw_filled_triangle(x1,y1,x2,y2,x3,y3,
					colours[i*(HEIGHT-1)+j].col2+Fixed2Int(FixedMul(
					FixedDiv(angle[cpos],DIST),NCOLS)));
			}
			else
			{
				draw_filled_triangle(x4,y4,x2,y2,x3,y3,
					colours[i*(HEIGHT-1)+j].col1+Fixed2Int(FixedMul(
					FixedDiv(angle[cpos+WIDTH],DIST),NCOLS)));

				draw_filled_triangle(x1,y1,x2,y2,x4,y4,
					colours[i*(HEIGHT-1)+j].col2+Fixed2Int(FixedMul(
					FixedDiv(angle[cpos],DIST),NCOLS)));
			}
		}
	}


	for (i = WIDTH/2-1, cpos = WIDTH/2-1; i >= 0; cpos = --i)
	{
		for (j = 0; j < HEIGHT-1; j++, cpos += WIDTH)
		{
			if (j < HEIGHT/2)
			{
				draw_filled_triangle(x1,y1,x3,y3,x4,y4,
					colours[i*(HEIGHT-1)+j].col1+Fixed2Int(FixedMul(
					FixedDiv(angle[cpos+WIDTH],DIST),NCOLS)));

				draw_filled_triangle(x1,y1,x2,y2,x3,y3,
					colours[i*(HEIGHT-1)+j].col2+Fixed2Int(FixedMul(
					FixedDiv(angle[cpos],DIST),NCOLS)));
			}
			else
			{
				draw_filled_triangle(x4,y4,x2,y2,x3,y3,
					colours[i*(HEIGHT-1)+j].col1+Fixed2Int(FixedMul(
					FixedDiv(angle[cpos+WIDTH],DIST),NCOLS)));

				draw_filled_triangle(x1,y1,x2,y2,x4,y4,
					colours[i*(HEIGHT-1)+j].col2+Fixed2Int(FixedMul(
					FixedDiv(angle[cpos],DIST),NCOLS)));
			}
		}
	}
}


#define c(a) (((a) >= 'A' && (a) <= 'Z') ? (a)-'A'+2 : \
				((a) >= '1' && (a) <= '9') ? (a)-'1'+26+2 : \
				(a) == '0' ? 35+2 : (a) == '!' ? 36+2 : (a) == ',' ? 37+2 : \
				(a) == ':' ? 38+2 : (a) == '-' ? 39+2 : 1)


int numlines[]= { 1, 3, 4, 4, 0 };

char t_blank[] = { 0 };

char t_bits[] = { c('B'), c('I'), c('T'), c('S'), 0 };
char t_computer[] = { c('C'), c('O'), c('M'), c('P'), c('U'),
											c('T'), c('E'), c('R'),0 };
char t_society[]={ c('S'), c('O'), c('C'), c('I'), c('E'), c('T'), c('Y'), 0};

char t_is[] = { c('I'), c('S'), 0 };
char t_proud[] = { c('P'), c('R'), c('O'), c('U'), c('D'), 0 };
char t_to[] = { c('T'), c('O'), 0 };
char t_present[] = { c('P'), c('R'), c('E'), c('S'), c('E'),
											c('N'), c('T'),0 };
char t_a[] = { c('A'), 0 };
char t_david[] = 	{ c('D'), c('A'), c('V'), c('I'), c('D'), 0 };
char t_hedley[] = { c('H'), c('E'), c('D'), c('L'), c('E'), c('Y'), 0 };
char t_production[] = 	{ c('P'), c('R'), c('O'), c('D'), c('U'),
					c('C'), c('T'), c('I'), c('O'), c('N'),0 };

char *String[]=
{
	t_blank,
	t_bits,t_computer,t_society,
	t_is,t_proud,t_to,t_present,
	t_a,t_david,t_hedley,t_production,
};

char **string = String;

int textpos = 0;

void DoText(void)
{
	int i,vpos;

	vpos = 43-20+((240-numlines[textpos]*32)>>1);

	for (i = 0; i < numlines[textpos]; i++)
		DrawText((20-(strlen(string[i])<<1))<<1,vpos+32*i,string[i]);

}


void Update(void)
{
	Pos *temp;
	static unsigned long c_frame;

	CalcForces();
	CalcPos();
	CalcAngle();

	while (OKtoblank);

	DrawFlag();
	DoText();

	while (FrameNum-c_frame < fps);

	c_frame = FrameNum;

	SwapScreens();

	temp = oldpos;
	oldpos = newpos;
	newpos = temp;
}


void SetInitialPos(void)
{
	int i,j;
	Pos *p;


	for (j = 0; j < HEIGHT; j++)
		for (i = 0; i < WIDTH; i++)
		{
			p = &array1[j*WIDTH+i];

			p->x = FixedMul(Int2Fixed(i),DIST);
			p->y = FixedMul(Int2Fixed(j),DIST);
			p->xv = p->yv = 0;

			array2[j*WIDTH+i] = *p;
		}


}



void SetInitialPalette(void)
{
	register int i;
	register int p;

	p = RD*3;

	for (i = 10; i >0 ; i--)
	{
		pal1[p] = pal2[p] = pal1[p+32*3] = pal1[p+64*3] = pal1[p+96*3] =
			pal1[p+128*3] = pal1[p+160*3] = pal1[p+192*3] = pal1[p+224*3] = i*3+20;
		p++;
		pal1[p] = pal2[p] = pal1[p+32*3] = pal1[p+64*3] = pal1[p+96*3] =
			pal1[p+128*3] = pal1[p+160*3] = pal1[p+192*3] = pal1[p+224*3] = 0;
		p++;
		pal1[p] = pal2[p] = pal1[p+32*3] = pal1[p+64*3] = pal1[p+96*3] =
			pal1[p+128*3] = pal1[p+160*3] = pal1[p+192*3] = pal1[p+224*3] = 0;
		p++;
	}

	p = BL*3;

	for (i = 10; i >0 ; i--)
	{
		pal1[p] = pal2[p] = pal1[p+32*3] = pal1[p+64*3] = pal1[p+96*3] =
			pal1[p+128*3] = pal1[p+160*3] = pal1[p+192*3] = pal1[p+224*3] = 0;
		p++;
		pal1[p] = pal2[p] = pal1[p+32*3] = pal1[p+64*3] = pal1[p+96*3] =
			pal1[p+128*3] = pal1[p+160*3] = pal1[p+192*3] = pal1[p+224*3] = 0;
		p++;
		pal1[p] = pal2[p] = pal1[p+32*3] = pal1[p+64*3] = pal1[p+96*3] =
			pal1[p+128*3] = pal1[p+160*3] = pal1[p+192*3] = pal1[p+224*3] = i*3+20;
		p++;
	}

	p = WT*3;

	for (i = 10; i >0 ; i--)
	{
		pal1[p] = pal2[p] = pal1[p+32*3] = pal1[p+64*3] = pal1[p+96*3] =
			pal1[p+128*3] = pal1[p+160*3] = pal1[p+192*3] = pal1[p+224*3] = i*3+20;
		p++;
		pal1[p] = pal2[p] = pal1[p+32*3] = pal1[p+64*3] = pal1[p+96*3] =
			pal1[p+128*3] = pal1[p+160*3] = pal1[p+192*3] = pal1[p+224*3] = i*3+20;
		p++;
		pal1[p] = pal2[p] = pal1[p+32*3] = pal1[p+64*3] = pal1[p+96*3] =
			pal1[p+128*3] = pal1[p+160*3] = pal1[p+192*3] = pal1[p+224*3] = i*3+20;
		p++;
	}

	p = 32*3;

	for (i = 0; i < 32 ; i++,p+=3)
		pal2[p] = pal2[p+1] = pal2[p+2] = 56;

	p = 64*3;

	for (i = 0; i < 32 ; i++,p+=3)
		pal2[p] = pal2[p+1] = pal2[p+2] = 40;

	p = 96*3;

	for (i = 0; i < 32 ; i++,p+=3)
		pal2[p] = pal2[p+1] = pal2[p+2] = 32;

	p = 128*3;

	for (i = 0; i < 32 ; i++,p+=3)
		pal2[p] = pal2[p+1] = pal2[p+2] = 20;

	p = 160*3;

	for (i = 0; i < 32 ; i++,p+=3)
		pal2[p] = pal2[p+1] = pal2[p+2] = 12;

	p = 192*3;

	for (i = 0; i < 32 ; i++,p+=3)
	{
		pal2[p] = 55;
		pal2[p+1] = 44;
		pal2[p+2] = 0;
	}

	p = 224*3;

	for (i = 0; i < 32*3; i+=3,p+=3)
	{
		pal2[p] = pal1[i]>>2;
		pal2[p+1] = pal1[i+1]>>2;
		pal2[p+2] = pal1[i+2]>>1;
	}

	pal2[224*3+2] = 20;

	for (i = 0; i < 256*3; i++)
		white_pal[i] = 63;
}


#define FADEON  	130
#define FADEOFF 	70


int main(void)
{
	register int cpos,i;
	int animate = 0, wind = 0,mag;
	int j,windstart = 150,animstart = 200;
	int fadestate,fadecount;

	srand(1);

	StartASM();
	SetGraphicsMode();

	SetPalette(black_pal);
	Sync();

	SetInitialPalette();
	memcpy(c_pal,black_pal,sizeof black_pal);
	SetInitialPos();
	Update();

	for(;;)
	{
		if (animstart > 0)
			if (--animstart == 0)
			{
				animate = 1;
				fadestate = 0;
				fadecount = FADEON;
			}
			else
			{
				if (animstart % 3 == 0)
				{
					FadePalette(c_pal,pal1);
					SetPalette(c_pal);
				}
				Sync();
			}


		if (animate)
		{
			switch(fadestate)
			{
			case 0:		/* No fade yet... */
				if (--fadecount == 0)
				{
					fadestate = 1;
					fadecount = FADEON;
				}
				break;
			case 1:		/* Fade on... */
				if (--fadecount == 0)
				{
					fadestate = 2;
					fadecount = FADEOFF;
				}
				else
				{
					FadePalette(c_pal,pal2);
					SetPalette(c_pal);
				}

				break;
			case 2:		/* Fade off... */
				if (--fadecount == 0)
					if (numlines[textpos+1] > 0)
					{
						string += numlines[textpos++];
						fadestate = 1;
						fadecount = FADEON;
					}
					else
					{
bits93:
						memcpy(c_pal,white_pal,sizeof white_pal);

						OKtoblank = 1;
						Sync();

						while (OKtoblank);

						OKtoblank = 128;
						PutBits();
						SetPalette(c_pal);
						Sync();
						SwapScreens();

						for (j = 0; j < 100; j++)
						{
							FadePalette(c_pal,bits_pal);
							FadePalette(c_pal,bits_pal);
							SetPalette(c_pal);
							Sync();
							if (inportb(0x60) == 1) goto quit;
						}

						for (j = 0; j < 260; j++)
							Sync();

						for (j = 0; j < 50; j++)
						{
							FadePalette(c_pal,black_pal);
							FadePalette(c_pal,black_pal);
							FadePalette(c_pal,black_pal);
							FadePalette(c_pal,black_pal);
							SetPalette(c_pal);
							Sync();
							if (inportb(0x60) == 1) goto quit;
						}

						goto quit;
					}
				else
				{
					FadePalette(c_pal,pal1);
					SetPalette(c_pal);
				}
			}


			Update();
			if (windstart > 0)
				if (--windstart == 0)
					wind = 1;
		}


		if (animate && wind && random(10) > 3)
		{
			mag = random(4);

			for (j = 0, cpos = 1; j < HEIGHT; j++,cpos++)
			{
				for (i = 1; i < WIDTH; i++,cpos++)
				{
					Fixed temp;

					temp = FixedDiv(angle[cpos],DIST);

					oldpos[cpos].xv += FixedMul(Int2Fixed(mag+random(2)),temp);
					oldpos[cpos].yv -= Float2Fixed(1.2)+temp;
				}
			}
		}

		if (inportb(0x60) == 1)
		{
			outportb(0x60,1|128);
			goto bits93;
		}

	}
quit:
	EndASM();
	SetTextMode();
	return 0;
}


