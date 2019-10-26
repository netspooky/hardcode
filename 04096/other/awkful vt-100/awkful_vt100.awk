#!/usr/bin/awk -f
function t_new(n) {
 for(n=ts; n<te; n++) {
  T[n,23]=RND[R2]*1.5;R2++
  if (R2>R) R2=0
 }
}
BEGIN {
 clrscr();ws=30;col=".+@";coll=length(col);ts=30;te=60;ty=16
 M[1,0]=29;M[1,10]=1;M[1,12]=1;M[1,18]=1;M[1,20]=1;M[1,25]=1;M[1,27]=1
 M[2,0]=45;M[2,5]=1;M[2,10]=1;M[2,15]=1;M[2,20]=1;
 TEXT[1,15]="This 4k demo is written in awk..."
 TEXT[1,40]="it's running on a 486 now..."
 TEXT[1,65]="under Debian GNU/Linux..."
 TEXT[1,80]="and you are watching it on..."
 TEXT[1,99]="an Amiga 2000 with a vt100 telnet."
 TEXT[3,300]="Code by Igor2"
 TEXT[3,500]="Amiga by Charlie"
 FW_1=55;FW_hp=10;FW_SLOW=3;g=0.4/FW_SLOW
 printf "Precalc: ";fls2()
 for(n=0; n<100; n++) {
  FW_new() 
  if ((n % 16)==0) printf ".";fls2()
 }
 dm()
}
function ef_text(m,n,y) {
 if (TEXT[m,n]!="") {
  last_text=TEXT[m,n]
  last_pos=int(40-length(last_text)/2)
 }
 if (last_text!="") gotoxy(last_pos,y,last_text)
}
function clrscr() {
 printf("\033[1;25r\033[0;10m\033[4l\033[H\033[J")
}
function gotoxy(x,y,chr) {
 if ((chr=="") || (x<1) ||(y<1) || (x>79) || (y>23)) return
 printf("\033[%d;%dH%s",int(y),int(x),chr)
}
function fls2() {
 fflush("/dev/stdout")
}
function  fls() {
 gotoxy(1,1," ")
 fflush("/dev/stdout")
}
function ef1(n) {
 a=sin(n/10)*0.5
 for(x=1; x<80; x+=0.5) {
  y=(sin(x/10)*10+sin(x+a)*3)*a+12+sin((x/sin(n)*2))*2
  gotoxy(x,y,".")
 }
}
function ef2(n) {
 xx=sin(n/10)*50+20
 for(x=xx-5; x<xx+5; x++) {
  y=sin(x/5)*6;gotoxy(x,y+13,"|")
 }
}
function ef3(n) {
 a=cos(n/1000)*6+sin(n/10)*2;b=sin(n/6)*2;v=10
 for(r=0; r<v; r+=0.1) {
  x=40+cos(r+b) * a*1.3;y=12+sin(r+b) * a
  gotoxy(x,y,substr(col,int(coll*(r/v)),1))
  if (n>70)  gotoxy(x+sin(n)*3,y+cos(n/2)*2,substr(col,int(coll*(r/v)),1))
 }
}
function ef4(n) {
 for(y=23; y>ty; y--) {
  for(x=ts; x<te; x++) {
   a=int(T[x,y]/10*(coll+1));b=substr(col,a,1)
   gotoxy(x,y,b)
  }
 }
}
function ef5(n) {
 t_new()
 for(y=22; y>ty; y--) {
  for(x=ts; x<te; x++) {
   T[x,y]=int((T[x-1,y+1]+T[x,y+1]+T[x+1,y+1]+T[x,y]-1)/4)
   if (T[x,y]>10) T[x,y]=10
   if (T[x,y]<0) T[x,y]=0
  }
 }
}
function ef6(n,t) {
 for(x=0; x<ws; x++) {
  W[t,x,"x"]=W[t,x+1,"x"]
  W[t,x,"y"]=W[t,x+1,"y"]
  q=substr(col,int(x/ws*coll)+1,1)
  gotoxy(W[t,x,"x"],W[t,x,"y"],q)
 }
  r=sin(n/100)*10;sz=n/10;
  W[t,ws,"x"]=int(40+cos(sz)*r)
  W[t,ws,"y"]=int(14+sin(sz)*r)
  gotoxy(W[t,ws,"x"],W[t,ws,"y"],"%")
}
function FW_new(m,x,y,q) {
 x=int(rand()*60+10)
 y=int(rand()*15+5)
 for(m=0; m<FW_1; m++) {
  p=FV
  FV++
  F[p,"hp"]=int(rand()*FW_hp)+5
  F[p,"vx"]=(rand()*20-10)/(3*FW_SLOW)
  F[p,"vy"]=(rand()*20-10)/(2*FW_SLOW)
  F[p,"x"]=x
  F[p,"y"]=y
 }
}
function ef7(n) {
 R2++
 if (R2>=R) R2=0
 if (((RND[R2]*10)>90) || (n<3)) {
  printf "\007"
  if (FV2<FV) {
   FV2+=FW_1
   FW_curr++
   if (FW_curr>3) FV_s+=FW_1
  }
 }
 for(n=FV_s; n<FV2; n++) {
  if (F[n,"hp"]>0) {
   F[n,"hp"]--
   if (F[n,"hp"]>0) {
    F[n,"x"]+=F[n,"vx"]
    F[n,"y"]+=F[n,"vy"]
    F[n,"vy"]+=g
    q=int(((F[n,"hp"]/FW_hp)*coll)+1)
    gotoxy(F[n,"x"],F[n,"y"],substr(col,q,1))
   }
  } 
 }
}
function music(a,n) {
 n=n % M[a,0]
 if (M[a,n]>0) printf "\007"
}
function scen() {
 for(n=1; n<120; n++) {
  clrscr()
   ef_text(1,n,3)
   ef1(n)
   if (n>20) ef2(n)
   if (n>45) ef3(n)
   music(1,n);fls()
  for(m=0;m<2000;m++) {
    if (R<500) {
     RND[R]=int(rand()*12);R++
    }
    else z=int(rand()*12)
   }
 }
}
function scen2() {
 qq=1600
 for(n=1; n<830; n++) {
   clrscr();ef_text(3,n,2);ef6(n,1)     
   if (n>300)  ef6(n-300,2)     
   if (n>600)  ef6(n-600,3)     
   music(2,n);fls();q=qq
   if (n>300) q=q/10    
   if (n>600) q=1
   for(m=0;m<q;m++)
 }
 delete W
}
function scen3() {
 for(n=1; n<100; n++) {
  clrscr()
  gotoxy(30,10,"It's a fire effect in low resolution.")
  ef4(n);
  fls()
  ef5(n)
 }
}
function scen4() {
 for(n=1; n<120; n++) {
 clrscr();ef7(n);fls()
 }
}
function dm() {
 scen();last_text="";scen2();scen3();scen4();clrscr()
 gotoxy(22,10,"Sok olcso effekt kis helyen is elfer.")
 gotoxy(22,12,"Mostmar kikapcsolhatja a szamitogepet.\n")
 fls2();
 system("sleep 1")
}