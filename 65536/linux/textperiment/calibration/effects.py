import math, random

adjust=lambda x: int(math.floor(x))
# NRM="\x1B[0m "
# RED="\x1B[31m"
# GRN="\x1B[32m"
# YEL="\x1B[33m"
# BLU="\x1B[34m"
# MAG="\x1B[35m"
# CYN="\x1B[36m"
# WHT="\x1B[37m"

meatt=1.4
meatgoo=0.95
def meatballs(context,step):

  meatang=3.14*step/150;
  mbA=[40+math.cos(meatang*5)*35,20+math.sin(meatang*2)*15]
  mbB=[40+math.sin(meatang*2.6)*35,20+math.cos(meatang*2.0)*15]
  mbC=[40+math.sin((meatang*2)+100)*35,20+math.cos(meatang+50)*15]
  for i in range(40):
    for j in range(80):
      if (5/math.pow(math.sqrt(math.pow(mbA[0]-j,2)+math.pow(mbA[1]-i,2)),meatgoo))+ \
         (9/math.pow(math.sqrt(math.pow(mbB[0]-j,2)+math.pow(mbB[1]-i,2)),meatgoo))+ \
         (3/math.pow(math.sqrt(math.pow(mbC[0]-j,2)+math.pow(mbC[1]-i,2)),meatgoo))>meatt:
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
  if step==1:
    for i in range(20): starsobj.append({"speed":1+random.randrange(10),"dir":random.random()*6.28,"step":3})
  for i in starsobj: movestar(i)

def threedcube(context,step):

  rotcubex=40;
  rotcubey=20;
  rotcubes=10;
  cubepoint1=[adjust(rotcubex+math.cos(step*0.035)*15),       adjust(rotcubey-rotcubes*0.6+math.sin(step*0.035)*3)      ]
  cubepoint2=[adjust(rotcubex+math.cos((step+45)*0.035)*15),  adjust(rotcubey-rotcubes*0.6+math.sin((step+45)*0.035)*3) ]
  cubepoint3=[adjust(rotcubex+math.cos((step+90)*0.035)*15),  adjust(rotcubey-rotcubes*0.6+math.sin((step+90)*0.035)*3) ]
  cubepoint4=[adjust(rotcubex+math.cos((step+135)*0.035)*15), adjust(rotcubey-rotcubes*0.6+math.sin((step+135)*0.035)*3)]
  cubepoint5=[cubepoint1[0],cubepoint1[1]+10]
  cubepoint6=[cubepoint2[0],cubepoint2[1]+10]
  cubepoint7=[cubepoint3[0],cubepoint3[1]+10]
  cubepoint8=[cubepoint4[0],cubepoint4[1]+10]
  context.line(cubepoint1[0],cubepoint1[1],cubepoint2[0],cubepoint2[1],".")
  context.line(cubepoint2[0],cubepoint2[1],cubepoint3[0],cubepoint3[1],".")
  context.line(cubepoint3[0],cubepoint3[1],cubepoint4[0],cubepoint4[1],".")
  context.line(cubepoint4[0],cubepoint4[1],cubepoint1[0],cubepoint1[1],".")
  context.line(cubepoint5[0],cubepoint5[1],cubepoint6[0],cubepoint6[1],".")
  context.line(cubepoint6[0],cubepoint6[1],cubepoint7[0],cubepoint7[1],".")
  context.line(cubepoint7[0],cubepoint7[1],cubepoint8[0],cubepoint8[1],".")
  context.line(cubepoint8[0],cubepoint8[1],cubepoint5[0],cubepoint5[1],".")
  context.line(cubepoint1[0],cubepoint1[1],cubepoint5[0],cubepoint5[1],".")
  context.line(cubepoint2[0],cubepoint2[1],cubepoint6[0],cubepoint6[1],".")
  context.line(cubepoint3[0],cubepoint3[1],cubepoint7[0],cubepoint7[1],".")
  context.line(cubepoint4[0],cubepoint4[1],cubepoint8[0],cubepoint8[1],".")

def scroll(context,text,y,char,step):

  context.text(81-step,y,char,text)

def euskallogo(context,logo,step):
  
  for ni,i in enumerate(logo[step:step+40]):
    for nj,j in enumerate(i):
      try: context.grid[ni][nj]=j
      except: pass

grayscale=[i for i in " `.:#"]
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
      context.putpixel(j,39-i,sign)
    previousline=actualline

parafill={"clouds":"CLOUDS"*20,"mountains":"MOUNTAINS"*12,"grass":"+= *="*24,"near":"   |"*30}
def parallax(context, step):

  for key,value in parafill.iteritems():
    if key=="clouds":y=0;rang=10;div=32;mod=6
    elif key=="mountains":y=10;rang=10;div=16;mod=9
    elif key=="grass":y=20;rang=14;div=4;mod=5
    elif key=="near":y=34;rang=6;div=1;mod=4
    for i in range(rang):
      try: context.smalltext(1,y+i,value[(step/div)%(mod):])
      except: pass

