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



// compile the scenery (movements etc.)
// a very stupid compiler, but it does its job...

#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <dir.h>
#include <fstream.h>
#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>

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

istream& operator >>(istream& i, vector& v)
{
  return i >> v[0] >> v[1] >> v[2];
}


#define CMD_POS 0
#define CMD_ANG 5


ifstream ifile;
int ofile;

char* buf;
const unsigned buflen=16384;

void updatetx(vector* tx, double& t0, double t, int lev)
{
  t-=t0;
  int fac[4]={1,1,2,6};
  for (int i=0; i<(lev-1); i++)
    for (int j=i+1; j<lev; j++)
      tx[i]+=tx[j]*(pow(t, j-i)/fac[j-i]);
  t0+=t;
}

void writevecs(char* buf, unsigned& bufpos, const vector* v, int n)
{
  for (int i=0; i<n; i++)
  {
    *(long*)(buf+bufpos)=v[i][0]*65536;
    bufpos+=4;
    *(long*)(buf+bufpos)=v[i][1]*65536;
    bufpos+=4;
    *(long*)(buf+bufpos)=v[i][2]*65536;
    bufpos+=4;
  }
}

void writeangs(char* buf, unsigned& bufpos, const vector* v, int n)
{
  for (int i=0; i<n; i++)
  {
    *(long*)(buf+bufpos)=v[i][0]*2048/360;
    bufpos+=4;
    *(long*)(buf+bufpos)=v[i][1]*2048/360;
    bufpos+=4;
    *(long*)(buf+bufpos)=v[i][2]*2048/360;
    bufpos+=4;
  }
}

void writetx(char* buf, unsigned& bufpos, vector* tx, int& lev)
{
  vector v;
  while (lev)
  {
    if (tx[lev-1]==v)
      lev--;
    else
      break;
  }
  buf[bufpos++]=CMD_POS+lev;
  writevecs(buf, bufpos, tx, lev);
}

void writetxa(char* buf, unsigned& bufpos, vector* tx, int& lev)
{
  vector v;
  while (lev)
  {
    if (tx[lev-1]==v)
      lev--;
    else
      break;
  }
  buf[bufpos++]=CMD_ANG+lev;
  writeangs(buf, bufpos, tx, lev);
}

void readpalette()
{
  double lasttime=0;
  unsigned bufpos=0;
  while (1)
  {
    double time;
    ifile >> time;
    if (time<=0)
      time=lasttime-time;
    lasttime=time;
    *(long*)(buf+bufpos)=time*65536;
    bufpos+=4;
    if (time>=10000)
      break;

    char cmd[10];
    ifile >> cmd;
    if (!stricmp(cmd, "SETPALI"))
    {
      buf[bufpos++]=0;
      short x;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      *(short*)(buf+bufpos)=x;
      bufpos+=2;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      buf[bufpos++]=x;
    }
    else
    if (!stricmp(cmd, "FADEPALI"))
    {
      buf[bufpos++]=1;
      double t;
      ifile >> t;
      *(long*)(buf+bufpos)=t*65536;
      bufpos+=4;
      short x;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      *(short*)(buf+bufpos)=x;
      bufpos+=2;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      buf[bufpos++]=x;
      ifile >> x;
      buf[bufpos++]=x;
    }
    else
    {
      cerr << "wrong command!";
      exit(1);
    }
  }
  write(ofile, &bufpos, 2);
  write(ofile, buf, bufpos);
}

void readobjact()
{
  double lasttime=0;
  unsigned bufpos=0;
  while (1)
  {
    double time;
    ifile >> time;
    if (time<=0)
      time=lasttime-time;
    lasttime=time;
    *(long*)(buf+bufpos)=time*65536;
    bufpos+=4;
    if (time>=10000)
      break;

    char cmd[10];
    ifile >> cmd;
    if (!stricmp(cmd, "ENABLE"))
      buf[bufpos++]=1;
    else
    if (!stricmp(cmd, "DISABLE"))
      buf[bufpos++]=0;
    else
    if (!stricmp(cmd, "SETCUT"))
    {
      int x;
      ifile >> x;
      buf[bufpos++]=2;
      buf[bufpos++]=x;
    }
    else
    {
      cerr << "wrong command!";
      exit(1);
    }
  }
  write(ofile, &bufpos, 2);
  write(ofile, buf, bufpos);
}

void readxflist()
{
  vector pos[4];
  vector ang[3];
  int plev=0;
  double pt0=0;
  int alev=0;
  double at0=0;
  double lasttime=0;
  unsigned bufpos=0;
  while (1)
  {
    double time;
    ifile >> time;
    if (time<=0)
      time=lasttime-time;
    lasttime=time;
    *(long*)(buf+bufpos)=time*65536;
    bufpos+=4;
    if (time>=10000)
      break;

    char cmd[10];
    ifile >> cmd;
    if (!stricmp(cmd, "POS"))
    {
      updatetx(pos, pt0, time, plev);
      plev=1;
      ifile >> pos[0];
      writetx(buf, bufpos, pos, plev);
    }
    else
    if (!stricmp(cmd, "MOVE"))
    {
      updatetx(pos, pt0, time, plev);
      plev=2;
      ifile >> pos[1];
      writetx(buf, bufpos, pos, plev);
    }
    else
    if (!stricmp(cmd, "ACCEL"))
    {
      updatetx(pos, pt0, time, plev);
      plev=3;
      ifile >> pos[2];
      writetx(buf, bufpos, pos, plev);
    }
    else
    if (!stricmp(cmd, "SMOVE"))
    {
      updatetx(pos, pt0, time, plev);
      plev=4;
      double t1;
      vector p1, v1, vp, vs;
      ifile >> t1 >> p1 >> v1;
      vp=(pos[0]-p1)*(6/t1);
      vs=(pos[1]+v1)*2;
      pos[3]=(vp*2+vs*3)*(1/(t1*t1));
      pos[2]=(vp+vs+pos[1]*2)*(-1/t1);
      writetx(buf, bufpos, pos, plev);
    }
    else
    if (!stricmp(cmd, "ANGLE"))
    {
      updatetx(ang, at0, time, alev);
      alev=1;
      ifile >> ang[0];
      writetxa(buf, bufpos, ang, alev);
    }
    else
    if (!stricmp(cmd, "ROT"))
    {
      updatetx(ang, at0, time, alev);
      alev=2;
      ifile >> ang[1];
      writetxa(buf, bufpos, ang, alev);
    }
    else
    if (!stricmp(cmd, "AACCEL"))
    {
      updatetx(ang, at0, time, alev);
      alev=3;
      ifile >> ang[2];
      writetxa(buf, bufpos, ang, alev);
    }
    else
    {
      cerr << "wrong command!";
      exit(1);
    }
  }
  write(ofile, &bufpos, 2);
  write(ofile, buf, bufpos);
}

void readobj()
{
  int type;
  ifile >> type;
  write(ofile, &type, 1);
  switch (type)
  {
  case 1:
  {
    char fname[40];
    ifile >> fname;

    char path[MAXPATH];
    char drive[MAXDRIVE];
    char dir[MAXDIR];
    char name[MAXFILE];
    char ext[MAXEXT];

    fnsplit(fname, drive, dir, name, ext);
    if (stricmp(ext, ".3do"))
    {
      strcpy(path, "makeobj ");
      strcat(path, fname);
      system(path);
    }
    fnmerge(path, drive, dir, name, ".3do");
    int objfile=open(path, O_RDONLY|O_BINARY);
    long len=filelength(objfile);
    for (long c=0; c<len;)
    {
      long r=read(objfile, buf, buflen);
      write(ofile, buf, r);
      c+=r;
    }
    close(objfile);
    readobjact();
    break;
  }
  case 0:
  {
    int num;
    ifile >> num;
    write(ofile, &num, 1);
    for (int i=0; i<num; i++)
      readobj();
    break;
  }
  case 2:
  {
    break;
  }
  default:
    cerr << "wrong object type!";
    exit(1);
  }

  readxflist();
}

void copytgatexture(char* name)
{
  short fi=open(name, O_BINARY|O_RDONLY);

  lseek(fi, 12, SEEK_SET);
  short x,y;
  read(fi, &x, 2);
  read(fi, &y, 2);
  write(ofile, &x, 2);
  write(ofile, &y, 2);
  lseek(fi, 786, SEEK_SET);
  long len=filelength(fi)-786;
  for (long c=0; c<len;)
  {
    long r=read(fi, buf, buflen);
    write(ofile, buf, r);
    c+=r;
  }
  close(fi);
}

void readtextures()
{
  short texturenum;
  ifile >> texturenum;
  write(ofile, &texturenum, 2);
  short i;
  for (i=0; i<texturenum; i++)
  {
    short type;
    ifile >> type;
    char filename[40];
    write(ofile, &type, 2);
    short resbit, xabits, yabits, colbits, p;
    long seed;
    short x, y, maxcol, oper, i;
    switch (type)
    {
    case 0:
      ifile >> filename;
      copytgatexture(filename);
      break;
    case 1:
      ifile >> resbit >> xabits >> yabits >> colbits >> p >> seed;
      write(ofile, &resbit, 2);
      write(ofile, &xabits, 2);
      write(ofile, &yabits, 2);
      write(ofile, &colbits, 2);
      write(ofile, &p, 2);
      write(ofile, &seed, 4);
      break;
    case 2:
      ifile >> x >> y >> maxcol >> oper;
      write(ofile, &x, 2);
      write(ofile, &y, 2);
      write(ofile, &maxcol, 1);
      write(ofile, &oper, 1);
      for (i=0; i<oper; i++)
      {
        double pd, fd, ftd, ad, wd;
        ifile >> pd >> fd >> ftd >> ad >> wd;
        long p, f, ft;
        short a, w;
        p=pd*2048.0*65536/360;
        f=fd*2048.0*65536/360;
        ft=ftd*2048.0*65536/360;
        a=ad*2048.0/360;
        w=wd*2048.0/360;
        write(ofile, &p, 4);
        write(ofile, &f, 4);
        write(ofile, &ft, 4);
        write(ofile, &a, 2);
        write(ofile, &w, 2);
      }
      break;
    }
  }
}

void readstars()
{
  double lasttime=0;
  unsigned bufpos=0;
  while (1)
  {
    double time;
    ifile >> time;
    if (time<=0)
      time=lasttime-time;
    lasttime=time;
    *(long*)(buf+bufpos)=time*65536;
    bufpos+=4;
    if (time>=10000)
      break;

    char cmd[12];
    ifile >> cmd;
    if (!stricmp(cmd, "ENABLE"))
      buf[bufpos++]=1;
    else
    if (!stricmp(cmd, "DISABLE"))
      buf[bufpos++]=0;
    else
    if (!stricmp(cmd, "SETSPEED"))
    {
      double x;
      ifile >> x;
      buf[bufpos++]=2;
      *(long*)(buf+bufpos)=x*65536;
      bufpos+=4;
    }
    else
    if (!stricmp(cmd, "SETMAXCOL"))
    {
      short x;
      ifile >> x;
      buf[bufpos++]=3;
      *(long*)(buf+bufpos)=x*65536;
      bufpos+=4;
    }
    else
    {
      cerr << "wrong command!";
      exit(1);
    }
  }
  write(ofile, &bufpos, 2);
  write(ofile, buf, bufpos);

  readxflist();
}

void main(int argn, char** argv)
{
  buf=new char[buflen];
  if (!buf)
    return;

  if (argn!=2)
    return;

// read

  ifile.open(argv[1]);
  if (!ifile)
    return;

  char path[MAXPATH];
  char drive[MAXDRIVE];
  char dir[MAXDIR];
  char name[MAXFILE];
  char ext[MAXEXT];

  fnsplit(argv[1], drive, dir, name, ext);
  fnmerge(path, drive, dir, name, ".3ds");

  ofile=open(path, O_BINARY|O_WRONLY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
//  write(ofile, "3ds\x00", 4);

  readobj();

  readtextures();

  readstars();

  readpalette();

  double endtime;
  ifile >> endtime;
  long et=endtime*65536;
  write(ofile, &et, 4);

  close(ofile);
  ifile.close();

  cout << argv[1] << " compiled.\n";
}
