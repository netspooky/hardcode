/* Rumaa koodia */

#include "Clouds.h"

/*
Perlin Noise pilville, aika paljon karsittu tosin :)
y:ss‰ arvoa ei oteta bilineaarisesti, sen kyll‰ huomaa, mutta toimii paljon
nopeammin
*/

inline int getRandom(int x,int y,int z)
{
  register unsigned int n = x + y*64 - z*128*64;
  n = (n<<13) ^ n;
  return (n*(n*n*16834 + 789221) >> 20);
}

inline int getPerlinNoise3D(int x,int y,int z)
{
  register unsigned int n1=x,n3=z;

  x = x & 0xFFFFFF00;
  y = y & 0xFFFFFF00;
  z = z & 0xFFFFFF00;
  n1-=x;
  n3-=z;

  return (((getRandom(x  ,y    ,z  )&255)   *(255-n1)*(255-n3)) +
          ((getRandom(x+256,y  ,z  )&255)   *n1      *(255-n3)) +
          ((getRandom(x  ,y    ,z+256)&255) *(255-n1)*n3) +
          ((getRandom(x+256,y  ,z+256)&255) *n1      *n3))>>16;
}

/* End of Perlin Noise */

void Clouds::draw(Bitmap &dest)
{
  camera.createCameraMatrix();

  int xs=(int)camera.position.x;
  int ys=(int)camera.position.y;
  int zs=(int)camera.position.z;

  int m[3][3];
  m[0][0] = (int)(camera.cameramatrix.m[0][0]*256);
  m[0][1] = (int)(camera.cameramatrix.m[1][0]*256);
  m[0][2] = (int)(camera.cameramatrix.m[2][0]*256);
  m[1][0] = (int)(camera.cameramatrix.m[0][1]*256);
  m[1][1] = (int)(camera.cameramatrix.m[1][1]*256);
  m[1][2] = (int)(camera.cameramatrix.m[2][1]*256);
  m[2][0] = (int)(camera.cameramatrix.m[0][2]*256);
  m[2][1] = (int)(camera.cameramatrix.m[1][2]*256);
  m[2][2] = (int)(camera.cameramatrix.m[2][2]*256);

  int tza = 90;
  int tza1 = (m[0][2]*tza>>8);
  int tza2 = (m[1][2]*tza>>8);
  int tza3 = (m[2][2]*tza>>8);
  int centery = dest.height / 2;
  int centerx = dest.width / 2;

  int *data = dest.data[0];

  for(int sy=0; sy<dest.height; sy+=2)
  {
    int tya=(sy-centery);
    int tya1 = (m[0][1]*tya>>8) + tza1;
    int tya2 = (m[1][1]*tya>>8) + tza2;
    int tya3 = (m[2][1]*tya>>8) + tza3;

    for(int sx=0; sx<dest.width; sx+=2)
    {
      int txa=(sx-centerx);

      int xa = (m[0][0]*txa>>8) + tya1;
      int ya = (m[1][0]*txa>>8) + tya2;
      int za = (m[2][0]*txa>>8) + tya3;

      int c=0, x=xs, y=ys, z=zs;
 
      for(int i=0; i<92;)
      {
        int a = (x*x + y*y*8 + z*z)>>15;

        if(a<350)
        {
          a+=getPerlinNoise3D(x,y,z);
          if(a<400)
          {
            c+=3;
            if(c>=125) break;
          }
          x += xa;
          y += ya;
          z += za;
          i++;
        } else {
          if(a>3000)
          {
            x += xa*32;
            y += ya*32;
            z += za*32;
            i+=32;
          }
          else if(a>1400)
          {
            x += xa*16;
            y += ya*16;
            z += za*16;
            i+=16;
          }
          else if(a>1000)
          {
            x += xa*8;
            y += ya*8;
            z += za*8;
            i+=8;
          }
          else if(a>600)
          {
            x += xa*4;
            y += ya*4;
            z += za*4;
            i+=4;
          }
          else if(a>500)
          {
            x += xa*2;
            y += ya*2;
            z += za*2;
            i+=2;
          }
          else
          {
            x += xa;
            y += ya;
            z += za;
            i+=1;
          }
        }
      }
      
      *data = 0x8080FF + (c&0xFC)*256 + c*256*256;
      data+=2;
    }
    data+=dest.width;
  }

// Blurrataan v‰h‰n :)

  int x,y;

  for(y=0; y<dest.height-2; y+=2)
  {
    for(x=0; x<dest.width-2; x+=2)
    {
      register int opt=((dest.data[y][x]>>1)&0x007F7F7F);
      dest.data[y][x+1] = opt + ((dest.data[y][x+2]>>1)&0x007F7F7F);
      dest.data[y+1][x] = opt + ((dest.data[y+2][x]>>1)&0x007F7F7F);
      dest.data[y+1][x+1] = opt + ((dest.data[y+2][x+2]>>1)&0x007F7F7F);
    }
  }

// Venytet‰‰n viel‰ bugireunat :)
  y=dest.height-2;

  for(x=0; x<dest.width-2; x+=2)
  {
    dest.data[y][x+1] = dest.data[y][x];
    dest.data[y+1][x] = dest.data[y][x];
    dest.data[y+1][x+1] = dest.data[y][x];
  }

  x=dest.width-2;

  for(y=0; y<dest.height; y+=2)
  {
    dest.data[y+1][x] = dest.data[y][x];
    dest.data[y][x+1] = dest.data[y][x];
    dest.data[y+1][x+1] = dest.data[y][x];
  }
}
