#ifndef _Bitmap_h_
#define _Bitmap_h_

typedef int Color;

#define rgb(r,g,b) (((r)<<16) + ((g)<<8) + (b))
#define mix(c1,c2) (((c1 & 0x00FEFEFE) + (c2 & 0x00FEFEFE))>>1)
// Ei jaksa miettiä, mut mix4 voi optimoida, jos on tarvetta joskus siihen
#define mix4(c1,c2,c3,c4) ((((c1)>>2) & 0x003F3F3F) + (((c2)>>2) & 0x003F3F3F) + (((c3)>>2) & 0x003F3F3F) + (((c4)>>2) & 0x003F3F3F))

typedef struct {
  int x,y,r,g,b;
} Triangle2DVertex;

typedef struct {
  Triangle2DVertex v1,v2,v3;
} Triangle2D;

#define BLIT_NONE 0
#define BLIT      1
#define BLIT_MASK 2
#define BLIT_MIX  3
#define BLIT_ADD  4

class Bitmap
{
public:
  Bitmap();
  Bitmap(int w,int h);
  void create(int w,int h);
  void free();
  void createMask();
  void addMask(int c);
  void clear(int c);
  void getBorders(int &l,int &r,int &t,int &b);
  void grayScale();
  void putPixel(int x,int y,int c);
  int getPixel(int x,int y);
  void circle(int x,int y,int r1,int r2,int c); // Hitaampi, kuin vois odottaa

// Seuraavat saattaa olla reaaliaikasia jopa
  void smooth();
  void smooth256x256(); // Myös reunat smoothataan
  void antialias(Bitmap &src);
  void filter(int t);
  void filterColors(float r,float g,float b);
  void addNoise(int m);

  void copy(Bitmap &dest);
  int clip(const Bitmap &dest,int &x,int &y,int &left,int &right,int &top,int &bottom);
  void blit(Bitmap &dest,int x,int y);
  void blitex(Bitmap &dest,int x,int y); // Parempia nimiä tälle? =)
  void maskedBlit(Bitmap &dest,int x,int y);
  void mixBlit(Bitmap &dest,int x,int y);
  void addBlit(Bitmap &dest,int x,int y);
  void transparencyBlit(Bitmap &dest,int t,int x,int y); // t on kai väärin, laita 255-t

// Ikkunointia varten
  void drawBorders(int p);
  void drawRectangle(int x1,int y1,int x2,int y2);

  void line(int x1,int y1,int x2,int y2,int w1,int w2,int c);
  void flatTriangle(Triangle2D *t);

// Texture.cpp
  void generateSin();
  void generateNoise();
  void generateFractal();

  int width,height,**data;//,**mask;
  int blittype;
};

#endif