from OpenGL.GL import *
from OpenGL.GLUT import *
from math import *
from time import *
from ossaudiodev import *
from threading import *
p=[]
l=q=i=j=0
R=[1]*3
f=22050
b=''
u=open('w')
u.setparameters(AFMT_S16_NE,1,f)
glutInit(0)
glutInitDisplayMode(2)
glutGameModeString("1024x768")
glutEnterGameMode()
class P:
 pass
def K(*a):
 global f;f=0;glutLeaveGameMode();sys.exit(0)
def D():
 global p,l,t,q,i,j,R;t=time()-z;d=t-l;glClear(16384);b=sin(t/1.5)*.6+sin(t*5)*.4;h=(sin(t*.77)+sin(t))*pi;x=cos(h)*b;y=sin(h)*b;r=[max(.5,min(1,R[0]+d*sin(t*4))),max(.5,min(1,R[1]+d*sin(t*7))),max(.5,min(1,R[2]+d*sin(t*9)))];q+=d*150;n=int(q)
 for c in range(n):
  a=P();h=c/q;a.x=i+h*(x-i);a.y=j+h*(y-j);a.U=sin(h*t*4)*.01;a.T=cos(h*t*7)*.01;a.s=30;a.r=R[0]+h*(r[0]-R[0]);a.g=R[1]+h*(r[1]-R[1]);a.b=R[2]+h*(r[2]-R[2]);a.a=1;p+=[a]
 i=x;j=y;R=r;q-=n
 for a in p:
  a.x+=a.U*d;a.y+=a.T*d;a.a-=d/7;a.s+=d*4;glColor4f(a.r,a.g,a.b,a.a);glPointSize(a.s);glBegin(0);glVertex2f(a.x,a.y);glEnd()
 del p[0:-1500];l=t;glutSwapBuffers();glutPostRedisplay()
glutDisplayFunc(D)
glutKeyboardFunc(K)
d=[]
for y in range(32):
 for x in range(32):
  s=sqrt((16-x)**2+(16-y)**2);d+=[1,max(1-.0625*s,0)]
glBindTexture(3553,glGenTextures(1))
glTexParameteri(3553,33169,1)
glTexImage2D(3553,0,6408,32,32,0,6410,5126,d)
glTexEnvi(34913,34914,1)
glEnable(3042)
glEnable(34913)
glEnable(3553)
glBlendFunc(770,771)
glMatrixMode(5889)
glOrtho(-1.2,1.2,-1.2,1.2,-1,1)
glMatrixMode(5888)
def k():
 while f:
  u.write(b)
o=chr(0)*5512
for n in 5,12,8,12,5,12,8,7,0,7,3,7,0,7,2,3:
 t=''
 for y in range(2756):
  v=int(f*sin(.125*1.059**n*y));t+=chr(v&0xff)+chr((v&0xff00)>>8)
 b+=t
 b+=o
Thread(target=k).start()
z=time()
glutMainLoop()
