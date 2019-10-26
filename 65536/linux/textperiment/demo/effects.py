import font
import math, random

adjust=lambda x: int(math.floor(x))

def floppyrainbow(context, floppy, step):
  for i in range(20): context.drawang(40,20,50,(step+(3.14*i)/10))
  for indexi,i in enumerate(floppy):
    for indexj,j in enumerate(i):
      context.putpixel(29+indexj,14+indexi,j)

def laugh(context, frame):
  for i in [z for z in range(len(frame)) if z%2==0]:
    try: context.line(frame[i],frame[i+1],frame[i+2],frame[i+3],"*")
    except IndexError: pass

pbase=[" ","\033[31m.","\033[31m:","\033[32m-","\033[32m=","\033[33m+","\033[33m*","\033[34m#","\033[35m%","\033[36m@"]
plasmapalette=pbase+pbase[::-1]
def plasma(context,step):
  for indexi,i in enumerate(context.grid):
    for indexj,j in enumerate(i):
      context.putpixel(indexj,indexi,plasmapalette[adjust(((20+10*math.sin(indexi/4.14)+10*math.sin(indexj/4.14))/2)+(step/4))%20]+"\033[0m")

copperpalette=" `.:-=*#*=-.` "
def copperbars(context,step):
  for indexi,i in enumerate(context.grid):
    for indexj,j in enumerate(i):
      context.putpixel(indexj,indexi,copperpalette[adjust((6+3*math.sin(indexi+step/60.5)+(step/10.0))%14)])

def moire(context,step):
  moivar=3.14*step/150;
  centera=[40+math.cos(moivar*5)*35,20+math.sin(moivar*2)*15]
  centerb=[40+math.sin(moivar*3)*35,20+math.cos(moivar*4)*15]
  for i in range(20):
    context.circle(centera[0],centera[1],3*i,"\033[32m*\033[0m")
    context.circle(centerb[0],centerb[1],3*i,"\033[31m*\033[0m")

meatt=1.4
meatgoo=0.95
def meatballs(context,step):

  meatang=3.14*step/150;
  mbA=[40+math.cos(meatang*5)*35,20+math.sin(meatang*2)*15]
  mbB=[40+math.sin(meatang*2.6)*35,20+math.cos(meatang*2.0)*15]
  mbC=[40+math.sin((meatang*2)+100)*35,20+math.cos(meatang+50)*15]
  for i in range(40):
    for j in range(80):
      if (5/math.pow(math.sqrt(math.pow(mbA[0]-j,2)+math.pow(mbA[1]-i,2)),meatgoo))+ (9/math.pow(math.sqrt(math.pow(mbB[0]-j,2)+math.pow(mbB[1]-i,2)),meatgoo))+ (3/math.pow(math.sqrt(math.pow(mbC[0]-j,2)+math.pow(mbC[1]-i,2)),meatgoo))>meatt:
        context.putpixel(j,i,"#")

starsobj=[]
def starfield(context,step):

  def movestar(starobj):
    starxsign=1 if math.cos(starobj["dir"])>=0 else -1
    starysign=1 if math.sin(starobj["dir"])>=0 else -1
    starymax=abs(20*math.sin(starobj["dir"])) if (2.355<starobj["dir"]<3.925 or 5.495<starobj["dir"]<7.075) else 20
    starxmax=abs(40*math.cos(starobj["dir"])) if (0.785<starobj["dir"]<2.355 or 3.925<starobj["dir"]<5.495) else 40
    starxpos=int(math.floor(40+((starxsign*starxmax*starobj["step"])/starobj["speed"]) ))
    starypos=int(math.floor(20+((starysign*starymax*starobj["step"])/starobj["speed"]) ))
    fillchar="*" if 0<starxpos<80 or 0<starypos<40 else " "
    try: context.putpixel(starxpos,starypos,fillchar)
    except: pass
    if starobj["step"]<starobj["speed"]: starobj["step"]+=0.2
    else:
      starobj["speed"]=20+random.randrange(20);
      starobj["dir"]=random.random()*6.28;
      starobj["step"]=2
  global starsobj
  if step==0:
    for i in range(15): starsobj.append({"speed":1+random.randrange(10),"dir":random.random()*6.28,"step":3})
  for i in starsobj: movestar(i)

def threedcube(context,step):

  rotcubex=40;
  rotcubey=23;
  rotcubes=10;
  cubepoint1=[adjust(rotcubex+math.cos(step*0.035)*15),       adjust(rotcubey-rotcubes*0.6+math.sin(step*0.035)*3)      ]
  cubepoint2=[adjust(rotcubex+math.cos((step+45)*0.035)*15),  adjust(rotcubey-rotcubes*0.6+math.sin((step+45)*0.035)*3) ]
  cubepoint3=[adjust(rotcubex+math.cos((step+90)*0.035)*15),  adjust(rotcubey-rotcubes*0.6+math.sin((step+90)*0.035)*3) ]
  cubepoint4=[adjust(rotcubex+math.cos((step+135)*0.035)*15), adjust(rotcubey-rotcubes*0.6+math.sin((step+135)*0.035)*3)]
  cubepoint5=[cubepoint1[0],cubepoint1[1]+10]
  cubepoint6=[cubepoint2[0],cubepoint2[1]+10]
  cubepoint7=[cubepoint3[0],cubepoint3[1]+10]
  cubepoint8=[cubepoint4[0],cubepoint4[1]+10]
  context.line(cubepoint1[0],cubepoint1[1],cubepoint2[0],cubepoint2[1],"*")
  context.line(cubepoint2[0],cubepoint2[1],cubepoint3[0],cubepoint3[1],"*")
  context.line(cubepoint3[0],cubepoint3[1],cubepoint4[0],cubepoint4[1],"*")
  context.line(cubepoint4[0],cubepoint4[1],cubepoint1[0],cubepoint1[1],"*")
  context.line(cubepoint5[0],cubepoint5[1],cubepoint6[0],cubepoint6[1],"*")
  context.line(cubepoint6[0],cubepoint6[1],cubepoint7[0],cubepoint7[1],"*")
  context.line(cubepoint7[0],cubepoint7[1],cubepoint8[0],cubepoint8[1],"*")
  context.line(cubepoint8[0],cubepoint8[1],cubepoint5[0],cubepoint5[1],"*")
  context.line(cubepoint1[0],cubepoint1[1],cubepoint5[0],cubepoint5[1],"*")
  context.line(cubepoint2[0],cubepoint2[1],cubepoint6[0],cubepoint6[1],"*")
  context.line(cubepoint3[0],cubepoint3[1],cubepoint7[0],cubepoint7[1],"*")
  context.line(cubepoint4[0],cubepoint4[1],cubepoint8[0],cubepoint8[1],"*")

def scroll(context,text,y,char,step):

  context.text(81-step,y,char,text)

def sinescroll(context,string,y,char,step):

  for idxi,i in enumerate(string):
    context.text((81-step/2)+8*idxi,y+2*math.sin((81-step/3)+(idxi+1)),char,i)

def euskallogo(context,logo,step):
  
  for ni,i in enumerate(logo[step:step+40]):
    for nj,j in enumerate(i):
      try: context.grid[ni][nj]=j
      except: pass

def gandalf(context,data,step):

  step%=5
  for i in range(len(data[step])):
    for j in range(len(data[step][i])):
      context.grid[i][j]=data[step][i][j]

def rotozoom(context,step):

  x=adjust(40+15*math.sin(step/75.0))
  y=adjust(20+15*math.cos(step/75.0))
  ang=step/10.0
  size=abs(15*math.sin(step/30.0))
  xdiff=adjust(math.cos(ang)*size)
  ydiff=adjust(math.sin(ang)*size)
  for i in range(-4,4):
    for j in range(-4,4):
      context.drawcube(x+(i*xdiff),y+(i*ydiff),j*size,ang)
      context.drawcube(x+(i*xdiff),y+(i*ydiff),-j*size,ang)

tuncolours=["\033["+str(i)+"m" for i in range(30,37)]
def tunnel(context,step):

  global tuncolours
  step=(step/2)%5
  for i in range(10):
    context.circle(40,20,(i*4+step),tuncolours[i%7]+"#\033[0m")
  if step==0: tuncolours=[tuncolours[-1]]+tuncolours[:-1]

grayscale=[" ","\033[33;2m`","\033[33m.",":","\033[31m#"]
firebase=[128+random.randrange(128) for i in range(80)]
def fire(context):

  global firebase
  newbase=[]
  for i in firebase:
    if random.choice([0,1]): a=abs(i+math.floor(random.randrange(64)))
    else: a=abs(i-math.floor(random.randrange(32)))
    a=255 if a>255 else 0 if a<0 else a
    newbase.append(a)
  previousline=newbase
  firebase=newbase

  for i in range(40):
    actualline=[]
    for j in range(80):
      lvl=adjust((previousline[j]+previousline[j+1])/3)-3 if j==0 else adjust((previousline[j]+previousline[j-1])/3)-3 if j==79 else adjust((previousline[j-1]+previousline[j]+previousline[j+1])/3)-7
      if lvl<0:lvl=0
      actualline.append(lvl)
      sign=grayscale[adjust(lvl/(255/5))]
      context.putpixel(j,39-i,sign+"\033[0m")
    previousline=actualline

autodb=[[random.choice([" ","#"])for i in range(80)]]
def automaton(context, step):

  global autodb
  newbase=[]
  for j in range(80):
    basecell=""
    try: basecell+=autodb[-1][j-1]
    except IndexError: basecell+=" "
    basecell+=autodb[-1][j]
    try: basecell+=autodb[-1][j+1]
    except IndexError: basecell+=" "
    newcell="#" if basecell.count(" ")==2 or basecell.count("#")==2 else " "
    colour=["\033[30m","\033[31m","\033[32m","\033[33m"][basecell.count("#")]
    newcell=colour+newcell+"\033[0m"
    newbase.append(newcell)  
  autodb.append(newbase)
  for idx,i in enumerate(autodb[-40:]):
    for jdx,j in enumerate(i):
      context.grid[idx][jdx]=j

parafill={"clouds":"CLOUDS"*20,"mountains":"MOUNTAINS"*12,"grass":"PARALLAX"*20,"near":"FTW!"*30}
def parallax(context, step):

  for key,value in parafill.iteritems():
    if key=="clouds":y=0;rang=10;div=32;mod=6
    elif key=="mountains":y=10;rang=10;div=16;mod=9
    elif key=="grass":y=20;rang=14;div=4;mod=8
    elif key=="near":y=34;rang=6;div=1;mod=4
    for i in range(rang):
      try: context.smalltext(1,y+i,value[(step/div)%(mod):])
      except: pass

