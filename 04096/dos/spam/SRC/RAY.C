#include <dos.h>
#include <math.h>
#include <stdio.h>

typedef unsigned char BYTE;
typedef signed short WORD;
typedef signed long DWORD;

#define GLASS_DENSITY 1.6
#define MAXANGLE M_PI/3.5
#define DISTANCE 2
#define WIDTH 160
#define HEIGHT 120
#define RANGE 101
#define RAD2DEG(x) ((x)*180/M_PI)
#define Check(x) /* printf("%11.7f " #x "\n", x) */
#define NewLine /* putchar ('\n') */

double AngleBetween (double, double, double, double);
void   Init();
double Intersection (double, double, double, double, int);
double Length (double, double);
double Sqr (double);

WORD aZ[RANGE],
     aDr[RANGE];

int main ()
  {
  Init();
  return 0;
  }

double AngleBetween (double dx1, double dy1, double dx2, double dy2)
  {
  return acos((dx1*dx2+dy1*dy2)/Length(dx1,dy1)/Length(dx2,dy2));
  }

void Init ()
  {
  double Alpha,
         Beta,
         Gamma,
         Delta,
         Eta,
         Lambda,
         dr,
	 temp,
         x1, z1,
         x2, z2,
         z;
  int    x;

  for (x=0, Alpha=0; x<RANGE; x++, Alpha+=MAXANGLE/RANGE)
    {
    if (Alpha < atan(1.0/DISTANCE))
      {
      NewLine;
      /* calculate 1st intersection */
      Lambda=Intersection (0,sin(Alpha), -DISTANCE,cos(Alpha), 0);
      x1=Lambda*sin(Alpha);
      z1=-DISTANCE+Lambda*cos(Alpha);
      Check (RAD2DEG(Alpha));
      Check (Lambda);
      Check (x1);
      Check (z1);
      Check (Sqr(x1)+Sqr(z1)); 

      /* calculate 2nd intersection */
      Beta=AngleBetween (0-x1,-2-z1, x1, z1);
      Delta=asin(sin(Beta)/GLASS_DENSITY);
      Gamma=atan(x1/z1)+Delta;
      Lambda=Intersection (x1,sin(Gamma), z1,cos(Gamma), 1);
      x2=x1+Lambda*sin(Gamma);
      z2=z1+Lambda*cos(Gamma);
      Check (RAD2DEG(Beta));
      Check (RAD2DEG(Gamma));
      Check (Lambda);
      Check (x2);
      Check (z2);
      Check (Sqr(x2)+Sqr(z2));
      Check (RAD2DEG(Delta));

      /* calculate the rest */
      Eta=atan(x2/z2)-Beta;
      Check(RAD2DEG(Eta));
      if (Eta==0)
        {
        dr=0;
        z=4;
        }
      else
        {
        dr=-tan(Eta);
        z=z2+x2/dr;
        }
      }
    else
      {
      z=-DISTANCE;
      dr=-tan(Alpha);
      }
    aZ[x]=z*256;
    aDr[x]=dr*256;
    }
  printf ("AZ");
  for (x=0; x<RANGE; x++)
    printf ("\t\tDW\t%d\n", aZ[x]);
  printf ("\nADR");
  for (x=0; x<RANGE; x++)
    printf ("\t\tDW\t%d\n", aDr[x]);
  }

double Length (double x, double y)
  {
  return sqrt(Sqr(x)+Sqr(y));
  }

double Sqr (double x)
  {
  return x*x;
  }

double Intersection (double a, double b, double c, double d, int i)
  {
  double x, y, z, t;

  x=Sqr(b)+Sqr(d);
  y=a*b+c*d;
  z=1-Sqr(a)-Sqr(c);
  t=sqrt(z/x+Sqr(y/x));
  if (i==1)
    return t-y/x;
  return -t-y/x;
  }
