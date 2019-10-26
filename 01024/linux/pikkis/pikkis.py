import curses
import time
import os
import wave
import math
import random
L=15
F=44800
st=0
stdscr=curses.initscr()
curses.start_color()
curses.curs_set(0)
curses.init_pair(1,curses.COLOR_RED,curses.COLOR_BLACK);
curses.init_pair(2,curses.COLOR_GREEN,curses.COLOR_BLACK);
curses.init_pair(3,curses.COLOR_YELLOW,curses.COLOR_BLACK);
curses.init_pair(4,curses.COLOR_BLUE,curses.COLOR_BLACK);
xs=range(0,200)
ys=range(0,200)
for i in range(0,200):
	xs[i] = random.randint(1,78)
	ys[i] = random.randint(1,20)
def seq(t):
	stdscr.clear()
	for i in range(0,int((t-st)*10)):
		stdscr.attron(curses.color_pair(int(t*8)%4));
		stdscr.addstr(ys[i],xs[i],"?")
		stdscr.attroff(curses.color_pair(int(t*8)%4));
	stdscr.attron(curses.color_pair(int(t*10)%4));
	stdscr.addstr(5,28,"Hello Instanssi 2011!")
	stdscr.attroff(curses.color_pair(int(t*10)%4));
	stdscr.addstr(7,32,str(ct))
	stdscr.attron(curses.color_pair(int(t)%2));
	stdscr.addstr(7,50,"<- steady framerate")
	stdscr.attroff(curses.color_pair(int(t)%2));
	stdscr.attron(curses.color_pair(int(t*5)%4));
	stdscr.addstr(9,24,"Under 1k Python & mplayer fun")
	stdscr.attroff(curses.color_pair(int(t*5)%4));
	stdscr.attron(curses.color_pair(int(t*2)%4));
	stdscr.addstr(11,34,"by zipola")
	stdscr.attroff(curses.color_pair(int(t*2)%4));
	stdscr.attron(curses.color_pair(int(t*2)%4));
	x=int(-t*10)%80
	stdscr.addstr(13,x,"greetz: #instanssi sam6seek"[0:(80-x)])
	stdscr.attroff(curses.color_pair(int(t*2)%4));
	stdscr.refresh()
ct=time.time()
T=0.02
f=wave.open('a','w')
f.setparams((1,1,F,0,'NONE','NONE'))
m=[]
for i in range(1,L*F):
	m.append(math.sin(math.pi*440.0/F*i))
f.writeframesraw(str(m))
f.close()
os.system('mplayer -really-quiet ./a &')
stdscr.clear()
t=time.time()
st=t
while ct<(t+L):
	tn=0
	nt=ct+T
	ct=time.time()
	if ct < nt:
		tn=nt-ct
	seq(ct)
	time.sleep(tn)
	nt+=T
os.system('rm ./a')
os.system('killall mplayer')
