import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation
from matplotlib.colors import LinearSegmentedColormap
import itertools, math, random

cdict={'red': ((0.0, 0.0, 0.15),(0.25, 0.15, 0.48),(0.50, 0.48, 0.139),(0.75, 0.139, 0.155),(1.00, 0.155, 0.155)), 'green': ((0.0, 0.0, 0.56),(0.25, 0.56, 0.98),(0.50, 0.98, 0.172),(0.75, 0.172, 0.188),(1.00, 0.188, 0.188)), 'blue':  ((0.0, 0.0, 0.15),(0.25, 0.15, 0.48),(0.50, 0.48, 0.15),(0.75, 0.15, 0.15),(1.00, 0.15, 0.15)),}
grid=[[0 for i in range(50)] for j in range(50)]
text="SVatG | SOGA | Euskal Encounter crew, scene people & friends"
text_vert="<3 matplotlib! This qualifies as 4k intro, right?"
needed_frames=(len(text)*3)+150
cube=[[(i,j,k),(i,k,j),(k,i,j)] for i in [-10, 10] for j in [-10, 10] for k in range(-10,11)]
cube=list(set(list(itertools.chain(*cube))))
cube=[(i[0], i[1], i[2]+10) for i in cube]

def rotate_3dpoint(p, angle, ax):
  r=[0, 0, 0]
  ca=math.cos(angle)
  sa=math.sin(angle)
  r[0]+=(ca+(1-ca)*ax[0]*ax[0])*p[0]
  r[0]+=((1-ca)*ax[0]*ax[1]-ax[2]*sa)*p[1]
  r[0]+=((1-ca)*ax[0]*ax[2]+ax[1]*sa)*p[2]
  r[1]+=((1-ca)*ax[0]*ax[1]+ax[2]*sa)*p[0]
  r[1]+=(ca+(1-ca)*ax[1]*ax[1])*p[1]
  r[1]+=((1-ca)*ax[1]*ax[2]-ax[0]*sa)*p[2]
  r[2]+=((1-ca)*ax[0]*ax[2]-ax[1]*sa)*p[0]
  r[2]+=((1-ca)*ax[1]*ax[2]+ax[0]*sa)*p[1]
  r[2]+=(ca+(1-ca)*ax[2]*ax[2])*p[2]
  return r

def rotate(obj, angle, axis):
  for n,i in enumerate(obj): obj[n] = rotate_3dpoint(i, angle, axis)

def rotcube(step):
  step=int(math.floor(step/5))
  global cube, grid
  rotate(cube, (0.6+0.5*math.sin(step/35))/35, (1,1,1))
  rotate(cube, (0.85+0.75*math.cos((step+7)/50))/30, (1,0,0))
  rotate(cube, (1.1+math.sin((step+43)/20))/30, (0,1,1))
  oldgrid=grid
  grid=[[0 for i in range(50)] for j in range(50)]
  tempvert=[tuple(j+23 for j in i) for i in cube]
  try:
    for i in tempvert: grid[int(i[0])][int(i[1])]=i[2]
  except: grid=oldgrid
  return grid

meatt=1.4
meatgoo=0.95
def meatballs(step):
  grid=[[0 for i in range(50)] for j in range(50)]
  step+=1
  meatang=3.14*step/150;
  mbA=[25+math.cos(meatang*5)*20,25+math.sin(meatang*2)*20]
  mbB=[25+math.sin(meatang*2.6)*20,25+math.cos(meatang*2.0)*20]
  mbC=[25+math.sin((meatang*2)+100)*20,25+math.cos(meatang+50)*20]
  for i in range(50):
    for j in range(50):
      if (5/math.pow(math.sqrt(math.pow(mbA[0]-j,2)+math.pow(mbA[1]-i,2)),meatgoo))+ (9/math.pow(math.sqrt(math.pow(mbB[0]-j,2)+math.pow(mbB[1]-i,2)),meatgoo))+ (3/math.pow(math.sqrt(math.pow(mbC[0]-j,2)+math.pow(mbC[1]-i,2)),meatgoo))>meatt: grid[j][i]="10"
      else: grid[j][i]="0"
  return grid

plt.register_cmap(name='gbmap', data=cdict)
fig=plt.figure()
ax=plt.axes(xlim=(0, 50), ylim=(0,50))
line,=ax.plot([], [], lw=2)
plt.title('Graphtro :D')
plt.xlabel('Greets go to')

def init():
  line.set_data([], [])
  return line,

def animate(i):
  global grid
  if i<150: grid=meatballs(i)
  else: grid=rotcube(i)
  Z=np.array(grid).astype(np.int)
  c=plt.pcolor(Z, cmap='gbmap')
  scstep=int(math.floor(i/3))
  plt.xticks(range(50), ["" for j in range(50-scstep)]+[j for j in text[0 if scstep-50<0 else scstep-50:scstep]])
  plt.yticks(range(1,50), (["" for j in range(50-scstep)]+[j for j in text_vert[0 if scstep-50<0 else scstep-50:scstep]])[::-1])
  return c

anim = animation.FuncAnimation(fig, animate, init_func=init, frames=350, interval=20, blit=True)
anim.save('./output/graphtro-v.mp4', fps=25, extra_args=['-vcodec', 'libx264'])
#ffmpeg -i ./output/graphtro-v.mp4 -i graphtro-m.mp3 -c copy -map 0:0 -map 1:0 ./output/graphtro-final.mp4