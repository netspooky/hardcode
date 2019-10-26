#!/usr/bin/env python

import font
import math, os

adjust=lambda x: int(math.floor(x))
sign=lambda x: cmp(x,0) #Python doesn't have this and that's dumb

class context:

  def __init__(self):

    x,y=80,40
    self.grid=[[" " for i in range(x)] for i in range(y)]
    self.xsize=x
    self.ysize=y

  def draw(self):

    self.rectangle(0,0,79,39,"#")
    print "\x1B[1;1H"
    for i in self.grid: print "".join(i)

  def putpixel(self,x,y,char):

    if x>=0 and y>=0:
      try:self.grid[adjust(y)][adjust(x)]=char
      except IndexError:pass

  def line(self,x0,y0,x1,y1,char):
    
    deltax=x1-x0;deltay=y1-y0
    if deltax==0:
      for i in range(abs(deltay)): self.putpixel(x0, y0+i*sign(deltay), char) 
    elif abs(deltax)>abs(deltay):
      if x0>x1: x0,y0,x1,y1=x1,y1,x0,y0
      for i in range(abs(deltax)): self.putpixel(x0+i, y0+deltay*i/deltax, char)
    else:
      if y0>y1: x0,y0,x1,y1=x1,y1,x0,y0
      for i in range(abs(deltay)): self.putpixel(x0+deltax*i/deltay, y0+i, char)

  def drawang(self,x,y,leng,ang):

    xd=adjust(math.sin(ang)*leng)
    yd=adjust(math.cos(ang)*leng)
    self.line(x,y,x+xd,y+yd,"*");


  def rectangle(self,x,y,xsize,ysize,char):

    self.line(x,y,x+xsize,y,char)
    self.line(x,y,x,y+ysize,char)
    self.line(x+xsize,y,x+xsize,y+ysize,char)
    self.line(x,y+ysize,x+xsize+1,y+ysize,char)

  def drawcube(self,x,y,side,rot):

    vs=adjust(math.sin(rot)*side)
    hs=adjust(math.cos(rot)*side)
    dy=adjust(math.sin(rot*side)/2.0)
    dx=adjust(math.cos(rot*side)/2.0)
    x=x-dx; y=y-dy;

    self.line(x,y,x+hs,y+vs,".");
    self.line(x+hs,y+vs,x+hs-vs,y+hs+vs,".");
    self.line(x+hs-vs,y+hs+vs,x-vs,y+hs,".");
    self.line(x-vs,y+hs,x,y,".");

  def circle(self,xc,yc,b,char):

    a=b*2;a2=a*a;b2=b*b;twoa2=2*a2;twob2=2*b2;x=0;y=b;px=0;py=twoa2*y

    def plotpoints (xc,yc,x,y):
      self.putpixel(xc+x, yc+y, char)
      self.putpixel(xc-x, yc+y, char)
      self.putpixel(xc+x, yc-y, char)
      self.putpixel(xc-x, yc-y, char)

    plotpoints(xc,yc,x,y)
    p=round(b2-(a2*b)+(0.25*a2))
    while px<py:
      x+=1
      px+=twob2
      if p<0: p+=b2+px
      else:
        y-=1
        py-=twoa2
        p+=b2+px-py
      plotpoints (xc,yc, x, y)
    p=round(b2*(x+0.5)*(x+0.5)+a2*(y-1)*(y-1)-a2*b2)
    while y>0:
      y-=1
      py-=twoa2
      if p>0: p+=a2-py
      else:
        x+=1
        px+=twob2
        p+=a2-py+px
      plotpoints(xc,yc,x,y)

  def text(self,x,y,char,string):

    for i in range(7): #Height of the font
      line="".join([eval("font."+letter+"[i]") for letter in string.lower().replace(" ","_").replace("2","B").replace("3","C").replace("4","D").replace("6","F").replace("7","G")])
      for j in range(79-x): #total space left
        try: 
          if line[j]=="#" and x+j>0: self.putpixel(x+j,y+i,char)
        except IndexError: pass

  def smalltext(self,x,y,string):

    for i in range(len(string)):
      self.putpixel(x+i,y,string[i])

  def clear(self):

    self.grid=[[" " for i in range(self.xsize)] for i in range(self.ysize)]
