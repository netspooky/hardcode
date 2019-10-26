/*****************************************************************************
                                  ATTENTION!
                           this source is VOTEWARE,
              you may only use it to the conditions listed below:

  -You may modify it, or use parts of it in your own source as long as
    this header stays on top of all files containing this source.
  -You must give proper credit to the author, Niklas Beisert / pascal.
  -You may not use it in commercial productions without the written
    permission of the author.
  -AND MOST IMPORTANT: you have to buy an Assembly '94 CD-ROM
    by Sound Solutions (if you don't have it already) and vote for VEX-InTrO
    in the PC-64k-Intro-Compo! (if you have already sent your voting card,
    buy another one and fill it out CORRECTLY!!!)
*****************************************************************************/



// compile an object, make a bsp-tree (binary space partitioning tree)

#include <math.h>
#include <dir.h>
#include <fstream.h>
#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>

#define MAXVERT 10

struct plane
{
  short b;
  short m;
  short f;
  unsigned char opt;
  unsigned char disp;
  unsigned char c0;
  unsigned char cn;
  short textnum;
  short mid;
  short norm;
  short vertnum;
  short v[MAXVERT+1];
  union
  {
    struct
    {
      short n;
      unsigned char c0;
      unsigned char cn;
    } col[MAXVERT+1];
    struct
    {
      unsigned short x;
      unsigned short y;
    } tex[MAXVERT+1];
  };
};

#define OPT_FRONT 1
#define OPT_BACK 2

#define DISP_NORM 0
#define DISP_SHADED 1
#define DISP_SMOOTH 1
#define DISP_ROUNDED 2
#define DISP_MIRROR 3
#define DISP_ORPUT 4
#define DISP_TEXT 5
#define DISP_TEXTX 6

#define MIN 0.00001

struct vector
{
  double v[3];
  vector() { v[0]=v[1]=v[2]=0; }
  double& operator [](int i) { return v[i]; }
  double operator [](int i) const { return v[i]; }
};

int operator ==(const vector &v1, const vector &v2)
{
  if (fabs(v1[0]-v2[0])>MIN)
    return 0;
  if (fabs(v1[1]-v2[1])>MIN)
    return 0;
  if (fabs(v1[2]-v2[2])>MIN)
    return 0;
  return 1;
}

double operator *(const vector &v1, const vector &v2)
{
  return v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2];
}

vector operator *(const vector &v, double d)
{
  vector vr=v;
  vr[0]*=d;
  vr[1]*=d;
  vr[2]*=d;
  return vr;
}

vector& operator /=(vector &v, double d)
{
  v[0]/=d;
  v[1]/=d;
  v[2]/=d;
  return v;
}

vector operator +(const vector &v1, const vector &v2)
{
  vector v;
  v[0]=v1[0]+v2[0];
  v[1]=v1[1]+v2[1];
  v[2]=v1[2]+v2[2];
  return v;
}

vector operator -(const vector &v1, const vector &v2)
{
  vector v;
  v[0]=v1[0]-v2[0];
  v[1]=v1[1]-v2[1];
  v[2]=v1[2]-v2[2];
  return v;
}

vector& operator +=(vector &v1, const vector &v2)
{
  v1[0]+=v2[0];
  v1[1]+=v2[1];
  v1[2]+=v2[2];
  return v1;
}

vector norm(const vector& v)
{
  return vector(v)/=sqrt(v*v);
}

vector vecxmul(const vector &v1, const vector &v2)
{
  vector v;
  v[0]=v1[1]*v2[2]-v1[2]*v2[1];
  v[1]=v1[2]*v2[0]-v1[0]*v2[2];
  v[2]=v1[0]*v2[1]-v1[1]*v2[0];
  return v;
}

#define MAXVERTS 256
#define MAXNORMS 256
#define MAXPLANES 256

vector* verts;
vector* norms;
plane* planes;
int planenum;
int vertnum;
int normnum;

// adds a point and checks for equal points
int addvert(const vector& v)
{
  for (int j=0; j<vertnum; j++)
    if (v==verts[j])
      return j;
  verts[vertnum]=v;
  return vertnum++;
}

// adds a vector and checks for equal points
int addnorm(const vector& v)
{
  vector v2=norm(v);
  for (int j=0; j<normnum; j++)
    if (v2==norms[j])
      return j;
  norms[normnum]=v2;
  return normnum++;
}

void swapplanes(plane& p1, plane& p2)
{
  if (&p1==&p2)
    return;
  plane p;
  memmove(&p, &p1, sizeof (plane));
  memmove(&p1, &p2, sizeof (plane));
  memmove(&p2, &p, sizeof (plane));
}

// cuts the plane p2 by plane p1 into plane p2 and p3
void splitplane(const plane& p1, plane& p2, plane& p3)
{
  int n=p2.vertnum;
  vector& v=verts[p1.v[0]];
  vector& nr=norms[p1.norm];
  int ff, fb;
  int l=((verts[p2.v[n-1]]-v)*nr)<-MIN;
  for (int i=0; i<n; i++)
  {
    int c=((verts[p2.v[i]]-v)*nr)<-MIN;
    if (c^l)
      if (c)
        fb=i;
      else
        ff=i;
    l=c;
  }
  plane po=p2;
  p3=po;
  vector& v1=verts[po.v[fb]];
  vector& v2=verts[po.v[(fb-1+n)%n]];
  vector& v3=verts[po.v[ff]];
  vector& v4=verts[po.v[(ff-1+n)%n]];
  double a=(((v-v1)*nr)/((v2-v1)*nr));
  double b=(((v-v3)*nr)/((v4-v3)*nr));

  int va=addvert(v1*(1-a)+v2*a);
  int vb=addvert(v3*(1-b)+v4*b);

  p2.vertnum=(ff-fb+n)%n;
  for (i=0; i<p2.vertnum; i++)
    p2.v[i]=po.v[(fb+i)%n];
  p2.v[p2.vertnum++]=vb;
  p2.v[p2.vertnum++]=va;

  p3.vertnum=(fb-ff+n)%n;
  for (i=0; i<p3.vertnum; i++)
    p3.v[i]=po.v[(ff+i)%n];
  p3.v[p3.vertnum++]=va;
  p3.v[p3.vertnum++]=vb;

  switch (po.disp)
  {
  case DISP_SHADED:
  {
    int na=addnorm(norms[po.v[fb]]*(1-a)+norms[po.v[(fb-1+n)%n]]*a);
    unsigned char c0a=po.col[fb].c0*(1-a)+po.col[(fb-1+n)%n].c0*a;
    unsigned char cna=po.col[fb].cn*(1-a)+po.col[(fb-1+n)%n].cn*a;
    int nb=addnorm(norms[po.v[ff]]*(1-b)+norms[po.v[(ff-1+n)%n]]*b);
    unsigned char c0b=po.col[ff].c0*(1-b)+po.col[(ff-1+n)%n].c0*b;
    unsigned char cnb=po.col[ff].cn*(1-b)+po.col[(ff-1+n)%n].cn*b;

    for (i=0; i<(p2.vertnum-2); i++)
    {
      p2.col[i].n=po.col[(fb+i)%n].n;
      p2.col[i].c0=po.col[(fb+i)%n].c0;
      p2.col[i].cn=po.col[(fb+i)%n].cn;
    }
    p2.col[i].n=nb;
    p2.col[i].c0=c0b;
    p2.col[i++].cn=cnb;
    p2.col[i].n=na;
    p2.col[i].c0=c0a;
    p2.col[i].cn=cna;

    for (i=0; i<(p3.vertnum-2); i++)
    {
      p3.col[i].n=po.col[(ff+i)%n].n;
      p3.col[i].c0=po.col[(ff+i)%n].c0;
      p3.col[i].cn=po.col[(ff+i)%n].cn;
    }
    p3.col[i].n=na;
    p3.col[i].c0=c0a;
    p3.col[i++].cn=cna;
    p3.col[i].n=nb;
    p3.col[i].c0=c0b;
    p3.col[i].cn=cnb;
    break;
  }
  case DISP_TEXT:
  case DISP_TEXTX:
  {
    short txa=po.tex[fb].x*(1-a)+po.tex[(fb-1+n)%n].x*a;
    short tya=po.tex[fb].y*(1-a)+po.tex[(fb-1+n)%n].y*a;
    short txb=po.tex[ff].x*(1-b)+po.tex[(ff-1+n)%n].x*b;
    short tyb=po.tex[ff].y*(1-b)+po.tex[(ff-1+n)%n].y*b;

    for (i=0; i<(p2.vertnum-2); i++)
    {
      p2.tex[i].x=po.tex[(fb+i)%n].x;
      p2.tex[i].y=po.tex[(fb+i)%n].y;
    }
    p2.tex[i].x=txb;
    p2.tex[i++].y=tyb;
    p2.tex[i].x=txa;
    p2.tex[i].y=tya;

    for (i=0; i<(p3.vertnum-2); i++)
    {
      p3.tex[i].x=po.tex[(ff+i)%n].x;
      p3.tex[i].y=po.tex[(ff+i)%n].y;
    }
    p3.tex[i].x=txa;
    p3.tex[i++].y=tya;
    p3.tex[i].x=txb;
    p3.tex[i].y=tyb;
    break;
  }
  }
}

// is plane p2 before, behind or on both sides of plane p1
int testplane(const plane& p1, const plane& p2)
{
  int r=0;
  int n=p2.vertnum;
  vector& v=verts[p1.v[0]];
  vector& nr=norms[p1.norm];
  for (int j=0; (j<n)&&(r!=3); j++)
  {
    double x=(verts[p2.v[j]]-v)*nr;
    if (x<-MIN)
      r|=1;
    if (x>MIN)
      r|=2;
  }
  return r;
}

int checksplit(int p, int s, int e)
{
  for (int i=s; i<e; i++)
    if (testplane(planes[p], planes[i])==3)
      return 1;
  return 0;
}

// make a bsp tree from planes s to e recursively
int splitplanes(int s, int e)
{
  planes[s].m=-1;
  for (int i=s; i<e; i++)
    if (!checksplit(i, s, e))
      break;
  if (i!=e)
    swapplanes(planes[i], planes[s]);
  int splits=0;
  int ff=s+1;
  for (i=s+1; i<(e+splits); i++)
  {
    int r=testplane(planes[s], planes[i]);
    if (r==3)
    {
      swapplanes(planes[e+splits], planes[planenum++]);
      splitplane(planes[s], planes[i], planes[e+splits]);
      swapplanes(planes[i], planes[ff+splits++]);
    }
    if (!(r&2))
      swapplanes(planes[i], planes[splits+ff++]);
  }
  if ((ff+splits)!=(s+1))
  {
    planes[s].b=s+1;
    splits+=splitplanes(s+1, ff+splits);
  }
  else
    planes[s].b=-1;
  if (ff!=e)
  {
    planes[s].f=ff+splits;
    splits+=splitplanes(ff+splits, e+splits);
  }
  else
    planes[s].f=-1;
  return splits;
}

int readvert(istream& s)
{
  char c;
  s >> c;
  if (c=='<')
  {
    vector v;
    s >> v[0] >> v[1] >> v[2];
    s >> c;
    return addvert(v);
  }
  else
  {
    s.putback(c);
    int i;
    s >> i;
    return i;
  }
}

int readnorm(istream& s)
{
  char c;
  s >> c;
  if (c=='<')
  {
    vector v;
    s >> v[0] >> v[1] >> v[2];
    s >> c;
    return addnorm(v);
  }
  else
  {
    s.putback(c);
    int i;
    s >> i;
    return i;
  }
}

void main(int argn, char** argv)
{
  if (argn!=2)
    return;

  verts=new vector[MAXVERTS];
  norms=new vector[MAXNORMS];
  planes=new plane[MAXPLANES];
  if (!verts||!norms||!planes)
    return;

// read

  ifstream ifile(argv[1]);
  if (!ifile)
    return;

  ifile >> vertnum;
  for (int i=0; i<vertnum; i++)
    for (int j=0; j<3; j++)
      ifile >> verts[i][j];

  ifile >> normnum;
  for (i=0; i<normnum; i++)
    for (int j=0; j<3; j++)
      ifile >> norms[i][j];

  ifile >> planenum;
  for (i=0; i<planenum; i++)
  {
    plane &p=planes[i];
    for (int j=0; j<MAXVERT; j++)
    {
      p.v[j]=-1;
      p.col[j].n=-1;
    }
    planes[i].mid=-1;
    int x;
    ifile >> x;
    p.opt=x;
    ifile >> x;
    p.disp=x;
    ifile >> x;
    p.c0=x;
    ifile >> x;
    p.cn=x;
    if (p.opt&0x80)
      p.mid=readvert(ifile);
    short n;
    ifile >> n;
    p.vertnum=n;
    for (j=0; j<n; j++)
      p.v[j]=readvert(ifile);
    p.norm=addnorm(vecxmul(verts[p.v[1]]-verts[p.v[0]], verts[p.v[2]]-verts[p.v[0]]));
    if (!(p.opt&0x80))
    {
      if (p.disp==DISP_SMOOTH||p.disp==DISP_ROUNDED||p.disp==DISP_MIRROR||!p.cn)
        p.mid=p.v[0];
      else
      {
        vector v;
        for (j=0; j<n; j++)
          v+=verts[p.v[j]];
        p.mid=addvert(v/=n);
      }
    }
    p.opt&=~0x80;
    switch(p.disp)
    {
    case DISP_SMOOTH:
      for (j=0; j<n; j++)
      {
        p.col[j].n=p.norm;
        p.col[j].c0=p.c0;
        p.col[j].cn=p.cn;
      }
      p.disp=DISP_SHADED;
      break;
    case DISP_ROUNDED:
      for (j=0; j<n; j++)
      {
        p.col[j].c0=p.c0;
        p.col[j].cn=p.cn;
      }
      break;
    case DISP_TEXT:
    case DISP_TEXTX:
      ifile >> p.textnum;
      for (j=0; j<n; j++)
      {
        double tx, ty;
        ifile >> tx >> ty;
        p.tex[j].x=tx*65535;
        p.tex[j].y=ty*65535;
      }
    }
  }
  ifile.close();

//calc

  for (i=0; i<planenum; i++)
    if (planes[i].disp==DISP_ROUNDED)
    {
      for (int j=0; j<planes[i].vertnum; j++)
      {
        vector v;
        for (int k=0; k<planenum; k++)
          for (int l=0; l<planes[k].vertnum; l++)
            if (planes[k].v[l]==planes[i].v[j])
              v+=norms[planes[k].norm];
        planes[i].col[j].n=addnorm(v);
        planes[i].disp=DISP_SHADED;
      }
    }

  if (planenum)
    splitplanes(0, planenum);

  double maxextent=0;
  for (i=0; i<vertnum; i++)
    if (verts[i]*verts[i]>maxextent)
      maxextent=verts[i]*verts[i];
  long maxext=sqrt(maxextent)*65536;

// write

  char path[MAXPATH];
  char drive[MAXDRIVE];
  char dir[MAXDIR];
  char name[MAXFILE];
  char ext[MAXEXT];

  fnsplit(argv[1], drive, dir, name, ext);
  fnmerge(path, drive, dir, name, ".3do");

  int file=open(path, O_BINARY|O_WRONLY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);

//  write(file, "3do\x00", 4);

  write(file, &vertnum, 2);
  write(file, &normnum, 2);
  write(file, &planenum, 2);
  write(file, &maxext, 4);

  for (i=0; i<vertnum; i++)
    for (int j=0; j<3; j++)
    {
      long p=verts[i][j]*65536;
      write(file, &p, 4);
    }

  for (i=0; i<normnum; i++)
    for (int j=0; j<3; j++)
    {
      long p=norms[i][j]*65536;
      write(file, &p, 4);
    }

//  int rootplane=planenum?0:-1;
//  write(file, &rootplane, 2);

  for (i=0; i<planenum; i++)
  {
    write(file, &planes[i].b, 2);
    write(file, &planes[i].m, 2);
    write(file, &planes[i].f, 2);
    write(file, &planes[i].opt, 1);
    write(file, &planes[i].disp, 1);
    write(file, &planes[i].c0, 1);
    write(file, &planes[i].cn, 1);
    write(file, &planes[i].mid, 2);
    write(file, &planes[i].norm, 2);
    write(file, &planes[i].vertnum, 2);
    write(file, &planes[i].v, 2*planes[i].vertnum);
    switch (planes[i].disp)
    {
    case DISP_SMOOTH:
      write(file, &planes[i].col, 4*planes[i].vertnum);
      break;
    case DISP_TEXT:
    case DISP_TEXTX:
      write(file, &planes[i].textnum, 2);
      write(file, &planes[i].tex, 4*planes[i].vertnum);
      break;
    }
  }

  close(file);

  cout << argv[1] << " compiled: " << vertnum << " points, " << normnum << " norms, " << planenum << " planes.\n";
}
