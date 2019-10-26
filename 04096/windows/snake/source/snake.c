#define WINDOWED
#define KEYBOARD_SIMPLE

#ifdef WINDOWED
#define SETTITLE
#endif

#include "tinyptc\graph.h"
#include <time.h>

#define WIDTH 320
#define HEIGHT 240
#define SIZE 320*240
#define dot(a,b) pixel[(a)+(b)*320]
#define bit(x) (1<<((x)-1))

static int pixel[SIZE];
unsigned int full[22];
unsigned int elma;
#ifdef SETTITLE
unsigned char title[40]="(apple: ";
#endif

struct snake { char dest; int x,y; struct snake *prev, *next; } *head, *last, *use, apple;

int xx, yy, i,j;
unsigned char game=1, direction;
long long int t1,t2;

#ifdef SETTITLE
void maketitle(void)
{
	xx=8;
	if(elma>99)
	{
		title[9]=elma/100+'0';
		xx++;
	}
	if(elma>9)
	{
		title[xx]=(elma%100)/10+'0';
		xx++;
	}
	title[xx]=elma%10+'0';
	title[xx+1]=')';
	title[xx+2]=0;
	settitle(title);
	return;
}
#endif


void place(struct snake *tug, int color)
{
	if(tug==NULL) return;
	for(yy=tug->y*10+1; yy<tug->y*10+9; yy++) for(xx=tug->x*10+1; xx<tug->x*10+9; xx++) dot(xx,yy)=color;
	if(tug!=head) switch(tug->dest)
	{
		case K_UP:
		for(yy=tug->y*10-1; yy<tug->y*10+1; yy++) for(xx=tug->x*10+1; xx<tug->x*10+9; xx++) dot(xx,yy)=color;
		break;
		case K_DOWN:
		for(yy=tug->y*10+9; yy<tug->y*10+11; yy++) for(xx=tug->x*10+1; xx<tug->x*10+9; xx++) dot(xx,yy)=color;
		break;
		case K_LEFT:
		for(yy=tug->y*10+1; yy<tug->y*10+9; yy++) for(xx=tug->x*10-1; xx<tug->x*10+1; xx++) dot(xx,yy)=color;
		break;
		case K_RIGHT:
		for(yy=tug->y*10+1; yy<tug->y*10+9; yy++) for(xx=tug->x*10+9; xx<tug->x*10+11; xx++) dot(xx,yy)=color;
	}
	return;
}


void placeborders(void)
{
	for(yy=0; yy<10; yy++) for(xx=0; xx<10; xx++) dot(xx,yy)=0x8400;
	for(yy=0; yy<10; yy++) for(xx=310; xx<320; xx++) dot(xx,yy)=0x8400;
	for(yy=230; yy<240; yy++) for(xx=0; xx<10; xx++) dot(xx,yy)=0x8400;
	for(yy=230; yy<240; yy++) for(xx=310; xx<320; xx++) dot(xx,yy)=0x8400;
	for(yy=0; yy<10; yy++) for(xx=10; xx<310; xx++) dot(xx,yy)=0x8400;
	for(yy=230; yy<240; yy++) for(xx=10; xx<310; xx++) dot(xx,yy)=0x8400;
	for(yy=10; yy<230; yy++) for(xx=0; xx<10; xx++) dot(xx,yy)=0x8400;
	for(yy=10; yy<230; yy++) for(xx=310; xx<320; xx++) dot(xx,yy)=0x8400;
	return;
}

void createsnake(void)
{
	head=(struct snake*)malloc(sizeof(struct snake));
	use=(struct snake*)malloc(sizeof(struct snake));
	last=(struct snake*)malloc(sizeof(struct snake));
	head->next=use;
	use->next=last;
	last->prev=use;
	use->prev=head;
	head->x=26;
	head->y=20;
	use->x=27;
	use->y=20;
	last->x=28;
	last->y=20;
	head->dest=use->dest=last->dest=K_LEFT;
	full[19]=0xE000000;
	place(head, 0x84A000);
	place(use, 0x848400);
	place(last, 0x848400);
}

void createapple(void)
{
	do
	{
		apple.x=rand()%29+1;
		apple.y=rand()%21+1;
	}
	while(full[apple.y-1]&bit(apple.x));
	place(&apple, 0xA00000);
	return;
}

int move(void)
{
	use=(struct snake*)malloc(sizeof(struct snake));
	use->next=head;
	head->prev=use;
	use->dest=head->dest;
	head=use;

	use=head->next;
	head->dest=direction;
	use->dest=direction;
	place(use,0x848400);

	switch(direction)
	{
		case K_UP:
			head->y=use->y-1;
			head->x=use->x;
			if(!head->y) return 1;
			break;
		case K_DOWN:
			head->y=use->y+1;
			head->x=use->x;
			if(head->y==23) return 1;
			break;
		case K_LEFT:
			head->y=use->y;
			head->x=use->x-1;
			if(!head->x) return 1;
			break;
		case K_RIGHT:
			head->y=use->y;
			head->x=use->x+1;
			if(head->x==31) return 1;
	}
	if(head->x-apple.x||head->y-apple.y)
	{
		full[last->y-1]=full[last->y-1]&~(bit(last->x));
		place(last, 0);
		use=last;
		last=last->prev;
		free(use);
	}
	else
	{
		createapple();
		elma++;
		#ifdef SETTITLE
		maketitle();
		#endif
	}
	if(full[head->y-1]&bit(head->x)) return 1;
	full[head->y-1]=full[head->y-1]|(bit(head->x));
	place(head, 0x84A000);
	return 0;
}

void keypressed(unsigned int key)
{
	switch(key)
	{
		case K_SPACE: game=!game; break;
		case K_UP: if(head->dest-K_DOWN) direction=K_UP; break;
		case K_DOWN: if(head->dest-K_UP) direction=K_DOWN; break;
		case K_LEFT: if(head->dest-K_RIGHT) direction=K_LEFT; break;
		case K_RIGHT: if(head->dest-K_LEFT) direction=K_RIGHT;
	}
	return;
}

int main(void)
{
	srand(time(NULL));
	if (!createscreen("snake",320,240)) return 1;
	while(1)
	{
		direction=K_LEFT;
		placeborders();
		createsnake();
		createapple();
		elma=0;
		#ifdef SETTITLE
		maketitle();
		#endif

		t1=GetTickCount();

		while(1)
		{
			t2=GetTickCount();
			if(t2-t1>=50)
			{
				screen(pixel);
				if(game)
				{
					if(move())
					{
						place(head, 0x840064);
						game=0;
						break;
					}
				}
				t1=GetTickCount();
			}
		}
		while(!game) screen(pixel);
		for(xx=0; xx<SIZE; xx++) pixel[xx]=0;
		for(xx=0; xx<22; xx++) full[xx]=0;
	}
	return 0;
}
