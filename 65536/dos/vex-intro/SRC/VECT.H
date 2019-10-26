#ifndef __VECT_H
#define __VECT_H

#define MAXVERT 14

struct lightspot
{
  short n;
  unsigned char c0;
  unsigned char cn;
};

struct texturespot
{
  unsigned short x;
  unsigned short y;
};

struct plane
{
  plane *next;
  plane *b;
  plane *m;
  plane *f;

  unsigned char opt;
  unsigned char disp;
  short textnum;
  short num;
  short mid;
  short v[MAXVERT+1];
  lightspot nr;
  union
  {
    lightspot col[MAXVERT+1];
    texturespot tex[MAXVERT+1];
    unsigned long ct[MAXVERT+1];
  };
};

#define OPT_DISPLAY 0x01

#define DISP_NORM 0
#define DISP_SHADED 1
#define DISP_MIRROR 3
#define DISP_ORPUT 4
#define DISP_TEXT 5
#define DISP_TEXTX 6

extern unsigned scrpage;
extern long curtime;

class transform
{
private:
  char* events;
  char* evptr;

  vector rmd;
  long at0;
  char alev;
  vector ang[3];
  long pt0;
  char plev;
  vector pos[4];

public:
  transform(int file);
  virtual ~transform();
  virtual void parse();
  virtual void makexform(matrix& m);
};

struct objdata
{
  short id;
  objdata *next;
  objdata *sub;
  vector mid;
  long rad;
  vector *verts;
  vector *norms;
  plane *planes;
  short vertnum;
  short normnum;
  short planenum;
  matrix xform;
};

struct lightdata
{
  vector pos;
  long intens;
};

class object
{
public:
  virtual ~object() {}
  virtual void getobject(const matrix &m)=0;
};

class stdobject : public object
{
private:
  objdata o;
  transform *t;

  char* events;
  char* evptr;
  short active;

public:
  stdobject(int file);
  virtual ~stdobject();
  virtual void getobject(const matrix &m);
};

class lightobject : public object
{
private:
  long intens;
  transform *t;

public:
  lightobject(int file);
  virtual ~lightobject();
  virtual void getobject(const matrix &m);
};

class objectnode : public object
{
private:
  char objnum;
  object **o;
  transform *t;

public:
  objectnode(int file);
  virtual ~objectnode();
  virtual void getobject(const matrix &m);
};

void addobject(objdata &o);
void addlight(const vector &pos, long intens);
object *readobject(int file);

void gettexture(short num, const texturespot *text, short n, long (*vert)[2], char *&bmp, unsigned short &wid);

#endif
