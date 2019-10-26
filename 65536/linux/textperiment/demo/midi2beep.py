#!/usr/bin/python
import midi,math,sys,os,getopt

mult=3.0
split=15
mn=mint=havetoclose=ctime=ntk=nfpause=0
comp=0.9
chord=99
try:opts,args=getopt.getopt(sys.argv[1:],'het:k:c:m:s:n:o:',['time=','kill=','compensation=','multiplier=','split=','minimum=','output='])
except getopt.GetoptError:exit()
for o,a in opts:
  if o in ("-c","--compensation"):comp=float(a)
  if o in ("-k","--kill"):chord=int(a)
  if o in ("-m","--multiplier"):mult=float(a)
  if o in ("-s","--split"):split=int(a)
  if o in ("-n","--minimum"):mn=int(a)
  if o in ("-o","--output"):sys.stdout=file(a,"w");havetoclose=1
if not args:exit()
m=midi.MidiFile()
m.open(args[0])
m.read()
m.close()
tcks=range(len(m.tracks)) if len(args)==1 else args[1:]
xt=list()
for i in tcks:xt=xt+m.tracks[int(i)].events;ntk=max(ntk,int(i))
for e in xt:
  if e.type=="NOTE_OFF":e.time+=5
concnotes=[0]
for i in range(ntk):concnotes.append(0)
def mnf_calc(n):return int(440*pow(2,(n-57.0)/12.0)) if n>=0 and n<=119 else -1
mnf_d=dict()
for i in range(120):mnf_d[i]=mnf_calc(i)
def mnf(n):return mnf_d[n-12] if n>=0 and n<=119 else -1
cnotes=list()
xt.sort(lambda x,y:x.time-y.time)
print "#!/bin/sh"
print "set -e"
for j in xt:
  if j.time>(ctime):
    c2x=cnotes
    c2=list()
    for i in range(len(c2x)):
      (np,tn)=c2x[i]
      if concnotes[tn]<=chord:c2.append(np)
    c2.sort()
    for i in range(len(c2)-1):
      if c2[i]==c2[i+1]:c2[i]=-1
      if c2[i]<mn:c2[i]=-1
    nf,ln=1,0
    for i in c2:
      if i!=(-1):
        ln+=1
        if nf==1:fn,nf=i,0
    if ln==0:
      if nfpause:print "beep -f 1 -l 0 -D "+str(int((j.time-ctime)*mult))
    elif ln==1:print "beep -f "+str(mnf(fn))+" -l "+str((j.time-ctime)*mult);nfpause=1
    else:
      nfpause=nnew=1;cmd="";xlen=int(((j.time-ctime)*mult)*comp)
      while xlen>0:
        for i in c2:
          if i==(-1):continue
          if not nnew:cmd+="-n "
          if xlen>=split:cmd=cmd+"-f "+str(mnf(i))+" -l "+str(split)+" ";xlen=xlen-split
          else:cmd=cmd+"-f "+str(mnf(i))+" -l "+str(xlen)+" ";xlen=0
          nnew=0
      print "beep "+cmd
    ctime=j.time
  if j.type=="NOTE_ON" and j.velocity>0:cnotes.append((j.pitch,j.track.index));concnotes[j.track.index]=concnotes[j.track.index]+1
  if j.type=="NOTE_OFF" or (j.velocity==0 and j.type=="NOTE_ON"):cnotes.remove((j.pitch,j.track.index));concnotes[j.track.index]=concnotes[j.track.index]-1
if havetoclose:sys.stdout.close()
