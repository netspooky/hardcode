#define MAX_COLORS 256       //maximun # of colors
#define MAX_COLOR_PALETTES 8  //maximum # of pallettes

struct Color
{
  unsigned char r, g, b;  //the red,green,and blue values of each color
};

Color cur_pal[MAX_COLORS], pal[MAX_COLOR_PALETTES][MAX_COLORS];//define the
                                                               //color arrays
                                                               //of type color
void change_color(unsigned char col, unsigned char r,
                                     unsigned char g, unsigned char b)
{
  asm{                         
      mov   dx, 0x3c8   //this function changes the colors           
      mov   al, [col]     
      out   dx, al
      inc   dx
      mov   al, [r]
      out   dx, al
      mov   al, [g]
      out   dx, al
      mov   al, [b]
      out   dx, al
     }
}

void set_pal()   //this sets the current palette
{
  int index = 0, ctr;

  for(index = 0,ctr = 0;ctr < 256 ;index++,ctr++)
   change_color(index,cur_pal[index].r,cur_pal[index].g,cur_pal[index].b);
}

void set_colors()  //this function sets up all of the different color palettes
{                  
  int index = 0, ctr;

  for(index = 0,ctr = 1;ctr < 256 ;index+=4,ctr++)
  {
    cur_pal[index].r = ctr;               //this one is red
    cur_pal[index+1].r = ctr;
    cur_pal[index+2].r = ctr;
    cur_pal[index+3].r = ctr;
    cur_pal[index].g = 0;
    cur_pal[index+1].g = 0;
    cur_pal[index+2].g = 0;
    cur_pal[index+3].g = 0;
    cur_pal[index].b = 0;
    cur_pal[index+1].b = 0;
    cur_pal[index+2].b = 0;
    cur_pal[index+3].b = 0;
  }

  for (index = 0,ctr = 1;ctr < 256 ;index+=4,ctr++)
  {
    pal[0][index].r = 0;
    pal[0][index+1].r = 0;
    pal[0][index+2].r = 0;
    pal[0][index+3].r = 0;
    pal[0][index].g = ctr;         //this one is green
    pal[0][index+1].g = ctr;
    pal[0][index+2].g = ctr;
    pal[0][index+3].g = ctr;
    pal[0][index].b = 0;
    pal[0][index+1].b = 0;
    pal[0][index+2].b = 0;
    pal[0][index+3].b = 0;
  }

  for (index = 0,ctr = 1;ctr < 256 ;index+=4,ctr++)
  {
    pal[1][index].r = 0;
    pal[1][index+1].r = 0;
    pal[1][index+2].r = 0;
    pal[1][index+3].r = 0;
    pal[1][index].g = 0;
    pal[1][index+1].g = 0;
    pal[1][index+2].g = 0;
    pal[1][index+3].g = 0;
    pal[1][index].b = ctr;
    pal[1][index+1].b = ctr;        //this one is blue
    pal[1][index+2].b = ctr;
    pal[1][index+3].b = ctr;
  }

  for (index = 0,ctr = 1;ctr < 256 ;index+=4,ctr++)
  {
    pal[2][index].r = ctr;             //guess which this one is?
    pal[2][index+1].r = ctr;
    pal[2][index+2].r = ctr;
    pal[2][index+3].r = ctr;
    pal[2][index].g = ctr;
    pal[2][index+1].g = ctr;           //white
    pal[2][index+2].g = ctr;
    pal[2][index+3].g = ctr;
    pal[2][index].b = ctr;
    pal[2][index+1].b = ctr;
    pal[2][index+2].b = ctr;
    pal[2][index+3].b = ctr;
   }

   for (index = 0,ctr = 1;ctr < 256 ;index+=4,ctr++)
   {
    pal[3][index].r = ctr;                //red+green
    pal[3][index+1].r = ctr;
    pal[3][index+2].r = ctr;
    pal[3][index+3].r = ctr;
    pal[3][index].g = ctr;
    pal[3][index+1].g = ctr;
    pal[3][index+2].g = ctr;
    pal[3][index+3].g = ctr;
    pal[3][index].b = 0;
    pal[3][index+1].b = 0;
    pal[3][index+2].b = 0;
    pal[3][index+3].b = 0;
   }

   for (index = 0,ctr = 1;ctr < 64 ;index+=4,ctr++)
   {
    pal[4][index].r = ctr;           //red+blue
    pal[4][index+1].r = ctr;
    pal[4][index+2].r = ctr;
    pal[4][index+3].r = ctr;
    pal[4][index].g = 0;
    pal[4][index+1].g = 0;
    pal[4][index+2].g = 0;
    pal[4][index+3].g = 0;
    pal[4][index].b = ctr;
    pal[4][index+1].b = ctr;
    pal[4][index+2].b = ctr;
    pal[4][index+3].b = ctr;
   }  

   for (index = 0,ctr = 1;ctr < 64 ;index+=4,ctr++)
   {
    pal[5][index].r = 0;
    pal[5][index+1].r = 0;
    pal[5][index+2].r = 0;
    pal[5][index+3].r = 0;
    pal[5][index].g = ctr;
    pal[5][index+1].g = ctr;
    pal[5][index+2].g = ctr;
    pal[5][index+3].g = ctr;
    pal[5][index].b = ctr;
    pal[5][index+1].b = ctr;             //green+blue
    pal[5][index+2].b = ctr;
    pal[5][index+3].b = ctr;
   }  
}
