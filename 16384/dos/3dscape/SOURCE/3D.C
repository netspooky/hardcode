
/* 3d landscape program by D.Hedley 7/4/93 */


#include <time.h>
#include <stdlib.h>
#include <dos.h>
#include <conio.h>
#include <math.h>
#include <malloc.h>

#define GRIDSIZE 80  /* Must be bigger than VIEWSIZE */
#define VIEWSIZE 61  /* MUST be odd */

#define DIFF (GRIDSIZE-VIEWSIZE)

#define DEF_DIST -1100
#define DEF_PITCH 122
#define DEF_HEIGHT 120
#define DEF_ROLL 315

#define sine(X) ((long)(sn_tbl[X]))
#define cosine(X) ((long)(sn_tbl[((X)+90) % 360]))

#define C_Plot(X,Y,C) pokeb(0xa000, (X) + 320U*(Y), C)

#define SHIFT 14
#define MASK (GRIDSIZE*GRIDSIZE)

/*
#define GetGrid(X,Y) ((unsigned)grid[((X) + GRIDSIZE*(Y) +idx) % MASK])
#define PutGrid(X,Y,C) grid[((X) + GRIDSIZE*(Y) +idx) % MASK] = (unsigned char)(C)
*/

#define CalcAddress(X,Y) (&grid[((X) + GRIDSIZE*(Y) + idx) % MASK])

extern void far *view_screen;
extern void far *screen;
extern int sn_tbl[360];
extern unsigned char grid[GRIDSIZE*GRIDSIZE];
extern unsigned rand_seed;
unsigned idx = 0;

extern long pitch_sine;
extern long pitch_cosine;
extern long roll_sine;
extern long roll_cosine;

int num_points = GRIDSIZE*GRIDSIZE;

#define START (DIFF/2)

int gx = START,gy = START;
unsigned char *gp;

int cz = DEF_DIST;
int cy = DEF_HEIGHT;
int roll = DEF_ROLL;
int cpitch = DEF_PITCH;

extern void SetMyMode(void);
extern void ClearMyScreen(void);
extern void Project(void);
extern void SwapScreens(void);
extern void DoPlasma(int,int,int,int);
extern int GetRand(void);
extern unsigned GetGrid(void);
extern void PutGrid(void);

#define _GetGrid(X,Y) (_AX = (X), _BX = (Y), GetGrid())
#define _PutGrid(X,Y,C) { _CX = (C); _AX = (X); _BX = (Y); PutGrid(); }


void SetMode(void)
{
	struct REGPACK regs;

	regs.r_ax = 0x13;
	intr(0x10, &regs);
}


void SetTextMode(void)
{
	struct REGPACK regs;

	regs.r_ax = 0x3;
	intr(0x10, &regs);
}

void SetPalette(void)
{
	register int i;
	register int j;


#define DEPTH(X) max((((X)*(3-j))/3), 3)

	for (j = 0; j<4; j++)
		for (i = 0; i<64; i+=4)
		{
			if (i+j > 0)
			{
				disable();
				outportb(0x3c8, (i >> 2)+64*j);
				outportb(0x3c9, 0);
				outportb(0x3c9, 0);
				outportb(0x3c9, DEPTH(2*i/3));
				enable();
			}

			disable();
			outportb(0x3c8, (i >> 2)+64*j+16);
			outportb(0x3c9, DEPTH(i/2+10));
			outportb(0x3c9, DEPTH(i/4+10));
			outportb(0x3c9, DEPTH(i/6+10));
			enable();

			disable();
			outportb(0x3c8, (i >> 2)+64*j+32);
			outportb(0x3c9, DEPTH(max(63/2+10-i,0)));
			outportb(0x3c9, DEPTH(min(64/4+10+3*i/4,63)));
			outportb(0x3c9, DEPTH(max(63/6+10-i,0)));
			enable();

			disable();
			outportb(0x3c8, (i >> 2)+64*j+48);
			outportb(0x3c9, DEPTH(i));
			outportb(0x3c9, DEPTH(63));
			outportb(0x3c9, DEPTH(i));
			enable();
		}
}

/*
int RandPixel(int x,int y,int x1,int y1,int x2,int y2)
{
	int col;

	col = (GetRand()%200 - 100) * (abs(x-x1)+abs(y-y1)) / (GRIDSIZE/6)
			+((_GetGrid(x1,y1)+_GetGrid(x2,y2)) >> 1);

	if (col < 1) col = 1;
	if (col > 255) col = 255;

	_PutGrid(x,y,col);

	return col;
}
*/
/*
void DoPlasma(int x1, int y1, int x2, int y2)
{
	int x,y,s,p;


	if (x2-x1 <= 1 && y2-y1 <= 1)
		return;

	x = (x1+x2) >> 1;
	y = (y1+y2) >> 1;

	if ((p = _GetGrid(x, y1)) == 0)
		p = RandPixel(x,y1,x1,y1,x2,y1);
	s = p;

	if ((p = _GetGrid(x2,y)) == 0)
		p = RandPixel(x2,y,x2,y1,x2,y2);
	s += p;

	if ((p = _GetGrid(x,y2)) == 0)
		p = RandPixel(x,y2,x1,y2,x2,y2);
	s += p;

	if ((p = _GetGrid(x1,y)) == 0)
		p = RandPixel(x1,y,x1,y1,x1,y2);
	s += p;

	if (_GetGrid(x,y) == 0)
		_PutGrid(x,y,s >> 2);

	DoPlasma(x1,y1,x,y);
	DoPlasma(x,y1,x2,y);
	DoPlasma(x1,y,x,y2);
	DoPlasma(x,y,x2,y2);
}
*/

void BlankGrid(int x1,int y1,int x2,int y2)
{
	register int x,y;

	for (y = y1; y <= y2; y++)
		for (x = x1; x <= x2; x++)
			_PutGrid(x,y,0);
}


void NewLand(int x1,int y1,int x2,int y2)
{
	unsigned av = 0;
	int val;
	int num = 0;

	if ((val = _GetGrid(x1,y1)) > 0)
	{
		av += val;
		num++;
	}

	if ((val = _GetGrid(x2,y1)) > 0)
	{
		av += val;
		num++;
	}

	if ((val = _GetGrid(x2,y2)) > 0)
	{
		av += val;
		num++;
	}

	if ((val = _GetGrid(x1,y2)) > 0)
	{
		av += val;
		num++;
	}

	if (!av || GetRand() % 32 == 0)
		av = GetRand() % 256;
	else
		av /= num;

	if (_GetGrid(x1,y1) == 0)
		_PutGrid(x1,y1, av + (GetRand() % 80 -40));

	if (_GetGrid(x2,y1) == 0)
		_PutGrid(x2,y1, av + (GetRand() % 80 -40));

	if (_GetGrid(x2,y2) == 0)
		_PutGrid(x2,y2, av + (GetRand() % 80 -40));

	if (_GetGrid(x1,y2) == 0)
		_PutGrid(x1,y2, av + (GetRand() % 80 -40));

	DoPlasma(x1,y1,x2,y2);
}


void Test(void)
{
	register int p;
	register int x;
	int y;


	for (y = 0,p = idx; y < GRIDSIZE; y++)
		for (x = 0; x < GRIDSIZE; x++, p = (p+1) % MASK)
			C_Plot(x,y,max(grid[p],63) >> 2);


	for (x = 0; x < VIEWSIZE; x++)
	{
		C_Plot(gx+x, gy, 0);
		C_Plot(gx+x, gy+VIEWSIZE, 0);
		C_Plot(gx, gy+x, 0);
		C_Plot(gx+VIEWSIZE, gy+x, 0);
	}

/*
	for (y = 0, p = gp; y < VIEWSIZE; y++, p += DIFF)
		for (x = 0; x < VIEWSIZE; x++,p++)
			C_Plot(gx+x,gy+y,*p >> 3);
*/
}


void ClearScr(void)
{
	register unsigned i;

	for (i = 0; i < (320U*150); i++)
		pokeb(0xa000,i,0);
}


void check_gx(void)
{
	if (gx < 0)
	{
		idx = (idx-DIFF/2 + MASK) % MASK;
		gx = START-1;

		BlankGrid(0,0, DIFF/2-1, GRIDSIZE-1);

		NewLand(0,0,DIFF/2,GRIDSIZE/4);
		NewLand(0,GRIDSIZE/4,DIFF/2,2*GRIDSIZE/4);
		NewLand(0,2*GRIDSIZE/4,DIFF/2,3*GRIDSIZE/4);
		NewLand(0,3*GRIDSIZE/4,DIFF/2,GRIDSIZE-1);
	}
	else if (gx >= DIFF)
	{
		idx = (idx+DIFF/2) % MASK;
		gx = START+1;

		BlankGrid(GRIDSIZE-DIFF/2,0, GRIDSIZE-1, GRIDSIZE-1);

		NewLand(GRIDSIZE-DIFF/2-1,0,GRIDSIZE-1,GRIDSIZE/4);
		NewLand(GRIDSIZE-DIFF/2-1,GRIDSIZE/4,GRIDSIZE-1,
												2*GRIDSIZE/4);
		NewLand(GRIDSIZE-DIFF/2-1,2*GRIDSIZE/4,GRIDSIZE-1,
												3*GRIDSIZE/4);
		NewLand(GRIDSIZE-DIFF/2-1,3*GRIDSIZE/4,GRIDSIZE-1,
												GRIDSIZE-1);
	}
}


void check_gy(void)
{
	if (gy < 0)
	{
		idx = (idx-DIFF/2*GRIDSIZE + MASK) % MASK;
		gy = START-1;

		BlankGrid(0,0, GRIDSIZE-1, DIFF/2-1);

		NewLand(0,0,GRIDSIZE/4,DIFF/2);
		NewLand(GRIDSIZE/4,0,2*GRIDSIZE/4,DIFF/2);
		NewLand(2*GRIDSIZE/4,0,3*GRIDSIZE/4,DIFF/2);
		NewLand(3*GRIDSIZE/4,0,GRIDSIZE-1,DIFF/2);
	}
	else if (gy >= DIFF)
	{
		idx = (idx+DIFF/2*GRIDSIZE) % MASK;
		gy = START+1;

		BlankGrid(0,GRIDSIZE-DIFF/2,GRIDSIZE-1, GRIDSIZE-1);

		NewLand(0,GRIDSIZE-DIFF/2-1,GRIDSIZE/4,GRIDSIZE-1);
		NewLand(GRIDSIZE/4,GRIDSIZE-DIFF/2-1,
								2*GRIDSIZE/4,GRIDSIZE-1);
		NewLand(2*GRIDSIZE/4,GRIDSIZE-DIFF/2-1,
								3*GRIDSIZE/4, GRIDSIZE-1);
		NewLand(3*GRIDSIZE/4,GRIDSIZE-DIFF/2-1,
								GRIDSIZE-1,GRIDSIZE-1);
	}
}


void main(void)
{
	int rollspeed = 0;
	int xspeed = 0, yspeed = 0;
	int i;

	rand_seed = (unsigned) time(NULL);

/*	rand_seed = 2; */

	for (i = 0; i<(360+90); i++)
		sn_tbl[i]=(int)(sin((double)i / 180.0*3.14159265) * (double)(1<<SHIFT));


	NewLand(0,0,GRIDSIZE-1,GRIDSIZE-1);

	SetMode();
	SetPalette();

//	goto skip;

	for (;;)
	{
		Test();

		switch(getch())
		{
			case 27:
				SetTextMode();
				exit(0);
			case 'e':
				gx--;
				check_gx();
				break;
			case 'r':
				gx++;
				check_gx();
				break;
			case 'w':
				gy--;
				check_gy();
				break;
			case 's':
				gy++;
				check_gy();
				break;
			case ' ':
				goto skip;
		}
		gp = CalcAddress(gx,gy);
		while (kbhit())
			getch();

	}
skip:
	;

	SetMyMode();
	SetPalette();

	gp = CalcAddress(gx,gy);

//	yspeed = -1;
//	rollspeed = (rollspeed+358) % 360;

	for (;;)
	{
		if (kbhit())
		{
			switch(getch())
			{
			case 27:
				SetTextMode();
				exit(0);
			case 'q':
				cz += 50;
				break;
			case 'a':
				cz -= 50;
				break;
			case 'u':
				cy -= 50;
				break;
			case 'j':
				cy += 50;
				break;
			case 'Q':
				cpitch = (cpitch+1) % 360;
				break;
			case 'A':
				cpitch = (cpitch+359) % 360;
				break;
			case 'E':
				if (xspeed > -1) xspeed--;
				break;
			case 'R':
				if (xspeed < 1) xspeed++;
				break;
			case 'e':
				gx--;
				break;
			case 'r':
				gx++;
				break;
			case 'W':
				if (yspeed > -1) yspeed--;
				break;
			case 'S':
				if (yspeed < 1) yspeed++;
				break;
			case 'w':
				gy--;
				break;
			case 's':
				gy++;
				break;
			case 'i':
				roll = (roll+1) % 360;
				break;
			case 'o':
				roll = (roll+359) % 360;
				break;
			case 'I':
				rollspeed = (rollspeed+1) % 360;
				break;
			case 'O':
				rollspeed = (rollspeed+359) % 360;
				break;
			case ' ':
				rollspeed = 0;
				xspeed = yspeed = 0;
				cz = DEF_DIST;
				cy = DEF_HEIGHT;
				roll = DEF_ROLL;
				cpitch = DEF_PITCH;
				break;
			}
			while (kbhit())
				getch();
		}
		gy += yspeed;
		gx += xspeed;

		check_gx();
		check_gy();

		gp = CalcAddress(gx,gy);
		roll = (roll+rollspeed) % 360;

		roll_sine = sine(roll);
		roll_cosine = cosine(roll);
		pitch_sine = sine(cpitch);
		pitch_cosine = cosine(cpitch);

		ClearMyScreen();
		Project();
		SwapScreens();
	}

}
