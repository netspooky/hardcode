//Brian Tomkins / Kable
//Finished 11-13-96

#include <conio.h>
#include <dos.h>
#include <iostream.h>
#include <randomiz.h>
#include <math.h>
#include <mem.h>
#include "pal.h"

#define SPEED 3      //speed of points
#define PLUS 1       //used for direction handling
#define MINUS 0      //same
#define MAXX 320     //maximum x value 
#define MAXY 200     //maximum y value
#define MOUSE_INTERRUPT 0x33  //Mouse interrupt number

//Globals

unsigned char * screen = (unsigned char *)0xA0000000L;   //the vga screen
unsigned char * fire;  //the fire array
int ytab[MAXY];         //for the lookup table
int chkflg = 1;  //used for checking if palette transformation is complete

int randd1 = (rand()%4)+1,     //random variables used for speed
    randd2 = (rand()%1)+1,
    randd3 = (rand()%2)+1,
    randd4 = (rand()%3)+1,
    randd5 = (rand()%3)+1,
    randd6 = (rand()%4)+1,
    randd7 = (rand()%2)+1,
    randd8 = (rand()%3)+1;

struct Point
{
 int x, y, x1, y1;  //the points 
 int dirx, diry;    //Used for the direction of the points
 int dirx1, diry1;  //same
};

Point point;        //One point

void g_mode()
{
 asm mov ax ,0x0013       //this gets us into mode 13
 asm int 10h
}

void t_mode()
{
 asm mov ax ,0x0003      //this sets text mode
 asm int 10h
}

void mouse_controller(int *x, int *y, int *buttons)
{
  union REGS inregs, outregs;

  inregs.x.ax = 0x03;
  int86(MOUSE_INTERRUPT, &inregs, &outregs);
  *x = outregs.x.cx;
  *y = outregs.x.dx;
  *buttons = outregs.x.bx;
}

void make_tables(void)
{
  for(int ctr = 0;ctr < MAXY;ctr++)        //(lookup table) so i don't have to
    ytab[ctr] = ctr * MAXX;                //calculate Y*MAXX every iteration
}                                          //of the averaging loop

void change_pals(int pal_num)
{
  for(int ctr = 0;ctr < MAX_COLORS;ctr++)
  {             //check to see if the current palette color is greater than or
                //less than the desired palette color and change apropriatly
    if(cur_pal[ctr].r < pal[pal_num][ctr].r)
       change_color(ctr,++cur_pal[ctr].r,cur_pal[ctr].g,cur_pal[ctr].b);
    if(cur_pal[ctr].r > pal[pal_num][ctr].r)
       change_color(ctr,--cur_pal[ctr].r,cur_pal[ctr].g,cur_pal[ctr].b);

    if(cur_pal[ctr].g < pal[pal_num][ctr].g)
       change_color(ctr,cur_pal[ctr].r,++cur_pal[ctr].g,cur_pal[ctr].b);
    if(cur_pal[ctr].g > pal[pal_num][ctr].g)
       change_color(ctr,cur_pal[ctr].r,--cur_pal[ctr].g,cur_pal[ctr].b);

    if(cur_pal[ctr].b < pal[pal_num][ctr].b)
       change_color(ctr,cur_pal[ctr].r,cur_pal[ctr].g,++cur_pal[ctr].b);
    if(cur_pal[ctr].b > pal[pal_num][ctr].b)
       change_color(ctr,cur_pal[ctr].r,cur_pal[ctr].g,--cur_pal[ctr].b);

    if((cur_pal[ctr].r == pal[pal_num][ctr].r) &&
           (cur_pal[ctr].g == pal[pal_num][ctr].g) &&
               (cur_pal[ctr].b == pal[pal_num][ctr].b))
    {
      chkflg = 0;  //set chkflg to 0 if the palette is done with it transformation
    }
    else
      chkflg = 1;  //set it to 1 if it is not done
    }
}


void line(int x1, int y1, int x2, int y2, unsigned char Col){
  int dx,dy,incr1,incr2,d,x,y,xend,yend,yinc,xinc;

  dx=abs(x2-x1);
  dy=abs(y2-y1);

  if(dx>=dy) // slope < 1
  {
    if(x1>x2)
	{
	  x=x2; y=y2; xend=x1;
	  if(dy==0) yinc=0;
	  else { if(y2>y1) yinc=-1; else yinc=1;}
	}
	else
	{
	  x=x1; y=y1; xend=x2;
	  if(dy==0) yinc=0;
	  else { if(y2>y1) yinc=1; else yinc=-1;}
	}
    incr1=2*dy; d=incr1-dx; incr2=2*(dy-dx);
  fire[ytab[y]+x] = Col;
    while(x<xend)
    {
      x++;
      if(d<0) d+=incr1;
      else { y+=yinc; d+=incr2;}
    fire[ytab[y]+x] = Col;
    }
  }
  else
  {
    if(y1>y2)
	{
	  x=x2; y=y2; yend=y1;
	  if(dx==0) xinc=0;
	  else { if(x2>x1) xinc = -1; else xinc = 1;}
    }
	else
	{
	  x=x1; y=y1; yend=y2;
	  if(dx==0) xinc=0;
	  else { if(x2>x1) xinc=1; else xinc = -1;}
	}
	incr1=2*dx; d=incr1-dy; incr2=2*(dx-dy);
  fire[ytab[y]+x] = Col;
	while(y<yend)
	{
	  y++;
	  if(d<0) d+=incr1;
	  else { x+=xinc; d+=incr2; }
    fire[ytab[y]+x] = Col;
	}
   }
}

void init_fire()                   //initialize all the points
{
  memset(fire, 0, 64001);

  point.x = (rand()%158)+1;
  point.y = (rand()%98)+1;
  point.x1 = (rand()%158)+1;
  point.y1 = (rand()%98)+1;
}

void main()
{
 int mx, my, x, y, buttons, var = 0;
 int temp = 0,temp1 = 00, temp2 = 00, temp3 = 00;

 if((fire = (unsigned char *)malloc(64000)) == NULL)    //alloc mem for array
 {
   cout << "\nError allocating memory";
   exit(1);
 }

 make_tables();      

 init_fire();        //initialize the points

 randomiz();

 mouse_controller(&mx,&my,&buttons);    //get mouse position

 x = mx;
 y = my;

 g_mode();

 set_colors();      //setup the different color palettes

 set_pal();         //sets the current palette
 
 while((!kbhit()) && (x == mx) && (y == my)) //check and see if keyboard was
 {                                           //hit or if the mouse was moved
   if(chkflg == 0)
     var = rand()%6;

   change_pals(var);
   set_pal();

//check direction of points and change them appropriatly
 if(point.x > 310)
 {
   point.dirx = MINUS;
   randd1 = (rand()%SPEED)+1;
 }
 if(point.x < 10)
 {
   point.dirx = PLUS;
   randd2 = (rand()%SPEED)+1;
 }
 if(point.y > 190)
 {
   point.diry = MINUS;
   randd3 = (rand()%SPEED)+1;
 }
 if(point.y < 10)
 {
   point.diry = PLUS;
   randd4 = (rand()%SPEED)+1;
 }

 if(point.x1 > 310)
 {
   point.dirx1 = MINUS;
   randd5 = (rand()%SPEED)+1;
 }
 if(point.x1 < 10)
 {
   point.dirx1 = PLUS;
   randd6 = (rand()%SPEED)+1;
 }
 if(point.y1 > 190)
 {
   point.diry1 = MINUS;
   randd7 = (rand()%SPEED)+1;
 }
 if(point.y1 < 10)
 {
   point.diry1 = PLUS;
   randd8 = (rand()%SPEED)+1;
 }

                       //move the points
 if(point.dirx == PLUS)
   point.x+= randd1;
 if(point.dirx == MINUS)
   point.x-= randd2;
 if(point.diry == PLUS)
   point.y+=randd3;
 if(point.diry == MINUS)
   point.y-=randd4;

 if(point.dirx1 == PLUS)
   point.x1+=randd5;
 if(point.dirx1 == MINUS)
   point.x1-=randd6;
 if(point.diry1 == PLUS)
   point.y1+=randd7;
 if(point.diry1 == MINUS)
   point.y1-=randd8;

                          //draw the line into the array
 if(point.x < 319 && point.x > 1)
   if(point.y > 1 && point.y < 199)
     if(point.x1 < 319 && point.x1 > 1)
       if(point.y1 > 1 && point.y1 < 199)
       {
         line(point.x,point.y,point.x1,point.y1,245);
         line(point.x+1,point.y+1,point.x1+1,point.y1+1,245);
       }

  for(int ctr1 = 1;ctr1 < MAXY;ctr1++)
  {
    temp1 = ytab[ctr1];       //don't need to calculate these inside the loop   
    temp2 = ytab[ctr1+1];     
    temp3 = ytab[ctr1-1];   
    for(int ctr = 1;ctr < MAXX;ctr++)
    {
      temp = fire[temp1+(ctr+1)] + fire[temp2+ctr] +  //get the values of the
             fire[temp1+(ctr-1)] + fire[temp3+ctr];   //4 surrounding pixels
                                                      //then divide by 4
      temp >>= 2;

      fire[temp1+ctr] = (temp >= 0 && temp <= 255)?temp:0;
    }
  }
   memmove(screen, fire, 64000);  //move the array to the vga screen
   mouse_controller(&mx,&my,&buttons);   //get mouse position again
 }
 if(fire)         //free the memory associated with the array
  free(fire);

 t_mode();   //set text mode
 cout<<"\nC'ya\n";      //say goodby
 delay(500);           //leave it there for a second or 2
 exit(0);   //Later
}

