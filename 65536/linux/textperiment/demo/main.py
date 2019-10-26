#!/usr/bin/env python

import math, os, subprocess, sys, time, traceback
import effects as ef, engine
adjust=lambda x: int(math.floor(x))
c=engine.context()
startdate=time.time()*1000
beat=0
cycle=1
auxstep1=auxstep2=0
test=0

testframe=[[33,39,33,32,28,37,26,36,19,27,19,25,17,26,15,25,14,25,14,22,13,20,15,20,14,21,16,22,17,21,17,21,19,19,21,20,21,22,22,22,27,30,32,23,34,22,35,22,36,21,36,18,35,19,34,16,32,14,32,13,30,8,31,3,35,2,41,4,44,4,48,7,49,7,50,10,49,11,50,13,50,14,52,15,53,15,50,17,49,20,48,21,47,20,44,23,49,30,54,21,55,20,54,19,54,18,54,17,55,16,57,17,58,15,59,15,59,17,61,17,61,19,62,20,61,21,57,23,58,25,53,34,51,36,49,35,50,39],
[33,39,33,33,29,38,26,36,19,28,20,26,18,26,17,25,16,25,15,21,17,20,16,22,19,22,19,21,21,20,23,21,23,23,24,23,28,30,33,23,36,23,37,21,37,20,35,20,34,17,33,15,33,15,30,8,32,3,37,3,43,5,45,5,47,7,48,8,50,8,52,11,50,13,51,14,51,16,53,15,54,17,50,18,48,19,48,18,47,20,47,21,48,22,47,23,46,24,50,30,54,23,55,22,53,20,54,18,56,19,56,18,58,16,59,17,59,18,60,18,61,19,60,21,61,21,58,23,57,25,58,27,53,36,51,37,50,36,50,39],
[33,39,33,32,28,37,24,34,19,27,19,25,17,26,15,25,14,24,14,22,13,20,15,19,14,21,16,22,18,21,17,20,19,19,21,20,21,22,22,22,27,30,32,23,34,22,35,22,36,21,36,18,35,19,34,17,32,14,33,13,30,7,31,3,36,2,41,4,44,4,45,6,46,6,48,7,50,8,51,10,49,11,50,13,50,15,52,15,53,15,52,17,50,17,48,17,47,17,46,20,47,21,45,23,49,30,54,21,55,21,54,20,55,19,54,17,55,16,57,17,58,15,60,16,59,17,61,16,62,18,60,19,61,19,62,20,58,22,57,23,59,25,53,34,51,36,49,35,50,39],
[33,39,33,33,30,37,27,37,19,27,19,26,18,26,17,25,15,25,14,21,16,20,16,21,17,22,19,21,18,21,20,19,22,21,22,22,23,23,28,30,32,23,35,23,36,23,37,21,36,20,35,20,34,17,32,15,33,14,30,6,32,3,36,2,42,4,44,5,47,7,48,8,50,8,51,11,50,12,50,13,51,14,50,15,53,17,50,18,48,18,48,19,47,20,47,21,45,24,46,24,50,30,54,22,55,21,54,21,54,19,55,18,57,18,56,18,57,16,59,17,59,18,60,17,61,18,60,20,61,20,61,22,58,23,57,24,58,27,54,34,52,36,50,36,51,39]]
rayframe=[[69,0,65,6,63,7,61,8,61,10,56,12,62,10,62,8,64,8,64,6,68,5,73,11,67,16,67,19,66,20,66,20,65,21,61,30,66,21,66,21,67,20,68,19,68,16,74,11,68,3,73,0],
[0,1,5,4,7,5,12,5,14,6,14,7,16,8,16,9,17,11,20,12,22,12,22,14,26,17,27,18,28,18,31,20,27,17,26,16,23,13,23,12,21,11,18,11,16,9,17,7,14,6,14,4,7,0,6,0,13,4,13,5,12,5,7,5,4,4,0,1]]

def loop(step):

  global auxstep1,auxstep2
  # DANGER ZONE
  #ef.mandelbrot(c,step)
  # ef.automaton(c,step)
  #ef.gandalf(c,gandalfdata,step/4)
  # c.text(5,4," ","brilliant")
  #ef.euskallogo(c,vscroll,55)

  if not test:
    if beat<46:
      ef.euskallogo(c,vscroll,adjust(step/3))
      if beat<18: 
        ef.scroll(c,"EUSKAL ENCOUNTER 23",5,"#",step)
      elif beat<30: 
        if beat==18: auxstep1=step
        ef.scroll(c,"STAGE7",5,"`",step-auxstep1)
      else: 
        if beat==30: auxstep2=step
        ef.scroll(c,"ACHIFAIFA",5,"`",step-auxstep2)
    elif beat<77:
      ef.copperbars(c,step)
      c.text(10,3,"#","PRESENT")
      if beat>54:
        c.text(3,13,"#","TEXT")
        c.text(13,23,"#","PERIMENT")
      if beat>60: 
        if beat==61: auxstep1=step
        ef.scroll(c,"A REALTIME ASCII INTRO",32,"#",(step-auxstep1)*2)
    elif beat<107:
      if beat==77: auxstep1=step
      ef.starfield(c,step-auxstep1)
      ef.scroll(c,"you cant use python they say",32,"#",step-auxstep1)
    elif beat<137:
      if beat==107: auxstep1=step
      ef.meatballs(c,step)
      ef.scroll(c,"you cant fit it in 64k they say",32,"*",step-auxstep1)
    elif beat<152:
      if beat==137: auxstep1=step
      ef.threedcube(c,step/2)
      c.text(7,4,"#","oh noes")
      ef.scroll(c,"what can we do",32,"#",step-auxstep1)
    elif beat<168:
      if beat==152: auxstep1=step
      ef.parallax(c,step*3)
      ef.scroll(c,"to the batcave",32," ",step-auxstep1)
    elif beat<183:
      ef.rotozoom(c,step)
    elif beat<197:
      ef.moire(c,step)
    elif beat<212:
      ef.plasma(c,step)
      c.text(2,4,"#","after")
      c.text(46,4,"#","much")    
      c.text(2,12,"#","time")
    elif beat<227:
      ef.automaton(c,step)
      c.text(7,4,"\033[34mx\033[0m","and")
      c.text(5,12,"\033[34mx\033[0m","headaches")
    elif beat<242:
      ef.tunnel(c,step)
      c.text(4,4,"#","its ready")
    elif beat<256:
      ef.floppyrainbow(c,floppy,step)
      c.text(16,4,"#","behold")
    elif beat<272:
      if beat==256:auxstep1=step
      ef.laugh(c,testframe[(step/5)%4])
      if not beat%4 and step%2: 
        ef.laugh(c,rayframe[0])
      if beat%4==1 and step%2:
        ef.laugh(c,rayframe[1])
      ef.scroll(c,"mwahahahahahahahahahaha",3,"#",(step-auxstep1)*2)
    elif beat<287:
      ef.gandalf(c,gandalfdata,step/4)
      c.text(5,4," ","brilliant")
    elif beat<302:
      ef.fire(c)
      c.text(4,3,"#", "the compo")
      c.text(4,11,"#"," is ours")
    elif beat<314:
        for i in range(40):
          for j in range(80):
            if beat<308:
              try: c.grid[i][j]=genshikenlogo[i][j]
              except IndexError: pass
            else: 
              try: c.grid[i][j]=pktteamlogo[i][j]
              except IndexError: pass
    elif beat<377:
      if beat==314: auxstep1=step
      c.text(10,5,"#","greets")
      if beat<349:ef.sinescroll(c,"marcan",20,"#",step-auxstep1)
      if 344>beat>314: ef.sinescroll(c,"bixo",30,"#",step-auxstep1-120)
      if 350>beat>330:ef.sinescroll(c,"soga",20,"#",step-auxstep1-200)
      if 360>beat>335:ef.sinescroll(c,"freddy",30,"#",step-auxstep1-290)
      if 374>beat>345:ef.sinescroll(c,"collapse",20,"#",step-auxstep1-400)
      if 487>beat>356:ef.sinescroll(c,"sfl",30,"#",step-auxstep1-540)
      if beat>360: ef.sinescroll(c,"purples",20,"#",step-auxstep1-600)
    elif beat<405: 
      ef.euskallogo(c,vscroll,55)
    else: 1/0

    
def decode(string):
  counter="";out=""
  for i in string:
    if i.isdigit():counter+=i
    else: 
      if counter:out+=(int(counter)*i)
      else:out+=i
      counter=""
  return out

def decodefile(path):

  with open(path,"r") as rlein:
    return [decode(line.rstrip('\n')) for line in rlein]

def main():
  global cycle, beat
  os.system('clear')
  os.system("./midi2beep.py -o music.sh music.mid")
  subprocess.Popen(["bash","music.sh",])
  while 1:
    c.clear()
    beat=adjust((time.time()*1000-startdate)/326)
    loop(cycle)
    cycle=adjust((time.time()*1000-startdate)/25)
    c.draw()
    time.sleep(1/30)#30

if __name__=="__main__":
  vscroll=decodefile("./rlescroll")
  floppy=decodefile("./rlefloppy")
  gdat=decodefile("./rlegandalf")
  gandalfdata=[gdat[i*40:(i+1)*40] for i in range(5)]
  logdat=decodefile("./rlelogos")
  genshikenlogo=logdat[:36]
  pktteamlogo=logdat[36:]
  try: main()
  except: 
    subprocess.call(["rm","music.sh"])
    subprocess.call(["killall","bash"])
    os.system('clear')
    traceback.print_exc()
