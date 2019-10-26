/*
   
   generic rotozoomer for sprites
   
   struct
   {
      char*colors;
      char*mask;
      int width,height;
   }sprite;

   rotozoom(char* int du,int dv,int dui)

   
   texttri
  
  
  
  dim/4 padding to every end
  
  22x22 pelulamu => padding 6

struct
{
   char*buf;
   int w,h;
}demobuf;

void rotozoom(int x0,int y0,
              char*map,int dim,int angle,int zoom)
{
  int du,dv,u,v,x,y;
  char*d=demobuf.buf;

  /* coordinate clipping */

  {int xp0,yp0;
  dim=(dim*zoom)>>8;

  if(x0+dim>bufw)xdim=demobuf.w-x0;else xdim=dim;
  if(y0+dim>bufh)ydim=demobuf.h-y0;else ydim=dim;

  if(x0<0){xdim+=x0;xp0=-dim-x0; x0=0;}else xp0=-dim;
  if(y0<0){ydim+=y0;yp0=-dim-y0; y0=0;}else yp0=-dim;

  if(xdim<=0 || ydim<=0)return;

  /* init rotations */
  
  /* ...test here: if angle==0 => if zoom==256 etc */

  du=sin(angle/256.0)*zoom;
  dv=cos(angle/256.0)*zoom;

  u=-du*xp0-dv*yp0;
  v=-dv*xp0+du*yp0;
  }

  /** innerl00p ***/

  {int duo=-dv-du*xdim,
       dvo= du-dv*xdim,
       mod=demobuf.w-xdim;

   d+=ydim*demobuf.w+xdim;

  for(y=ydim;y;y--)
  {
     for(x=xdim;x;x--)
     {
        int ptr=(u&0xff00)+(v>>8);

        *d=(*d&map[ptr])|map[ptr+128];
        d++;
        u+=du;
        v+=dv;
     }
     
     u+=duo;
     v+=dvo;
     d+=mod;
  }
  }
}

void pelulamu_animate()
{
  /* - draw torso: thick lines & rectangles
     - draw head
  */
}



Cvoid drawtext()
{
   
}

/*

  buf,bufw,bufh

  x0,y0,dim,angle,zoom		bufw,bufh


  put a 50% safebox around the stuff
  
  
  128: 64
  
  256x256
  
  for 8x8 texture (font!): 16x16 space
 
  font: 5x5 textures
 
  7x5 => 14x10 space   280 bytes/char => abt 10k of font data

  aspectratio adjustment


   *****
  **   **
  *******
  **   **
  **   **

  ******
  **   **
  ******
  **   **
  ******
  
   *****
  **   **
  **
  **   **
   *****

  ******
  **   **
  **   **
  **   **
  ******
  
  *******
  **
  ****
  **
  *******
  
  *******
  **
  ****
  **
  **
  
  for 16x16 texture: 32x32 space
  for 32x32 texture: 64x64 space
  for 64x64 texture: 128x128 space - no bigger possible here
  

  -------------
  -------------
  --.........--
  --.........--
  --.........--
  --.........--
  --....o....--
  --.........--
  --.........--
  --.........--
  --.........--
  -------------
  -------------

 
  sqrt(2)*width,sqrt(2)*height
  
  1.5*width,1.5*height

  
  
  delta always constant
  
  
  innerloop has constant du,dv
  
  outerloop: dv,-du + 
  
    
        
  -------.--------
  ------....------
  -----.......----
  ----..........--
  ---............- ________
  --..............
  -..............-
  ..............-- ________
  -............---
  ---.........----
  -----......-----
  -------...------
  --------.--------
  
	

          ____________ 
         .
        ...
       .....
      .......
     .........
    ........... ______
    -...........
      ........... ____
       .........
        .......
         .....
          ...
           . _________

                __-- sqrt ( (a/2)**2 + (a/sqrt(2))**2)
  ------.-----/        == sqrt(aa/4 + aa/2) == sqrt(3aa/4) == sqrt(3)/4 * a ==~ 0.433a
  -----...---/-
  ----.....-/--
  ---.......---  a/sqrt(2)
  --.........--
  -...........-
  ......o......
  -...........-
  --.........--
  ---.......---
  ----.....----
  -----...-----
  ------.------

  square sprites


     |\  (a*sqrt(2))/2
 a/2 | \
     |__\  

      a/2

*/

/*

<#linux.fi:Goblet> mä tiedän tuon xazturin, se on sellanen about 140cm
                   saatananpalvojapelle millä on pitkä musta takki ja
                   tukka ja siitä tulee mulle aina mieleen addams family :D

*/
