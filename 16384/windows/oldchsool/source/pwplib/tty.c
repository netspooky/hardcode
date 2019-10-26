#include "config.h"
#ifdef DRIVE_TTY

#include "pwplib.h"

#define __TTY_C

#include "tty.h"

/****************/

#ifdef HAVE_TTYSTUFF

void tty_restore_termios()
{
   tcsetattr(STDIN,TCSADRAIN,&pwp_tty.setup);
}

void tty_init_termios()
{
   struct termios t;
   tcgetattr(STDIN,&t);
   memcpy(&pwp_tty.setup,&t,sizeof(struct termios));
   
   t.c_lflag=ISIG; /* &=~(ECHO+ECHOE+ECHOK+ECHONL+NOFLSH);*/
   
/*   t.c_lflag=t.c_oflag=0; */
   t.c_cc[VMIN]=1;
   t.c_cc[VTIME]=0;
   tcsetattr(STDIN,TCSADRAIN,&t);

   pwp_regdestr(tty_restore_termios);
}

void tty_getwinsize()
{
#  ifdef TIOCGWINSZ
  {struct winsize wsz;
  if(ioctl(0,TIOCGWINSZ,&wsz)>=0){
     pwp_tty.width=wsz.ws_col;pwp_tty.height=wsz.ws_row;
     if(pwp_tty.width>0 && pwp_tty.height>0) return;
  }}
#  endif

  {char*tmp;
  pwp_tty.height=((tmp=getenv("LINES"))?atoi(tmp):0);
  pwp_tty.width=((tmp=getenv("COLUMNS"))?atoi(tmp):0);
  if(pwp_tty.height>0 && pwp_tty.width>0)return;}

  pwp_tty.height=24;
  pwp_tty.width=80;
}

void tty_write(u8*data,int lgt)
{
   if(lgt<0)lgt=strlen(data);

   write(pwp_tty.fd,data,lgt);
   pwplib.timer_counter+=lgt;
}

/******************************************************************/

void tty_probe_raw()
{
   fd_set fdset;
   struct timeval timeout;

   tty_init_termios();

   memset((void*)&fdset,0,sizeof(fd_set));
   FD_SET(0,&fdset);
   timeout.tv_sec=0;
   timeout.tv_usec=250000;

   write(STDOUT,"\33[c",3*sizeof(char));

   usleep(250000); /* give it some time to react */

   select(0,&fdset,NULL,NULL,&timeout);

   if(FD_ISSET(STDIN,&fdset))
   {
      char buf[40],*b;
      int lgt,num;

      lgt=read(STDIN,buf,40*sizeof(char))/sizeof(char);

      if(lgt<3) return;
      if( (buf[0]!=27) ||
          (buf[1]!='[') ||
          (buf[2]!='?')) return;

      b=buf+3;lgt-=3;num=0;

      pwp_tty.type=TTY_VT1XX;
      pwp_tty.minor=0;
      pwp_tty.vtcap=0;

      while(lgt)
      {
         char c=*b++;
         if(c>='0' && c<='9')
            num=(num*10)+c-'0';
         else
         {
            /*fprintf(stderr,"NUMBAH %d\n",num);*/
            if(num>=62)
            {
               pwp_tty.type =TTY_VT2XX;
               pwp_tty.minor=20+(num-60)*100;
            }
            else
            if(num<32)pwp_tty.vtcap|=(1<<num);
            
            num=0;
         }
         lgt--;
      }

      if(pwp_tty.vtcap&(1<<3)) /* ReGIS */
      {
         if(pwp_tty.minor==220)
            pwp_tty.minor=240;
         if(pwp_tty.minor==320)
         {
            pwp_tty.minor=330;
            /* how to check 340? */
         }
         /* ... otherz */
      }

      /* protection from vt2xx wannabes - enable after lag fix */
#ifdef DRIVE_TTY_VT2XX      
/*      if( (pwp_tty.type==TTY_VT2XX) &&
          (!(pwp_tty.vtcap&(1<<7))))
      {
         pwp_tty.type=TTY_VT1XX;
      }*/
#else
	if(pwp_tty.type=TTY_VT2XX)pwp_tty.type=TTY_VT1XX;
#endif

   }
    else
         pwp_tty.type=TTY_DUMB;

   tty_restore_termios();
}

/******************************************************************/

int tty_probe()
{
   char*tt;

   pwp_tty.type=TTY_DUMB;

   pwpwrite("* getting terminal type..\n");

   tt=pwplib.set.term;
   if(tt==NULL)
   {
      tty_probe_raw();
      tt=getenv("TERM");
      if(tt==NULL)return pwp_tty.type;
   }

   if(tt[0]=='x')pwp_tty.type=TTY_XVT_MONO;

   if( (!strcmp(tt,"xterm-color")) ||
       (!strcmp(tt,"aixterm"))
      )
   {
      return TTY_XVT_COLOR;
   }

   if( (pwp_tty.type==TTY_VT1XX) ||
       (pwp_tty.type==TTY_DUMB))
   {
      if(tt[0]=='v')
      {
         pwp_tty.minor=atoi(tt+2);

         if(pwp_tty.minor>=200 && pwp_tty.type!=TTY_VT1XX)
                  return TTY_VT2XX;
             else return TTY_VT1XX;
      }

      if(tt[0]=='a')
         return TTY_ANSISYS;

      if(tt[0]=='l')
         return TTY_LINUX;

      if(!strcmp(tt,"dumb"))
         return TTY_DUMB;
   }

   return pwp_tty.type;
}

#endif

/******************************************************************/

int tty_init()
{
#ifdef HAVE_TTYSTUFF

  int colors=2,chars=2,rasters=1;

  pwp_tty.fd=2; /* stderr */

  tty_init_termios();

  tty_getwinsize();
  pwp_tty.type=tty_probe();
#endif
  pwplib.videobuf.width=pwp_tty.width;
  pwplib.videobuf.height=pwp_tty.height;
  pwplib.videobuf.d=malloc(pwplib.videobuf.width*
    pwplib.videobuf.height*sizeof(u16));
#ifdef HAVE_TTYSTUFF
  pwp_tty.prevbuf=malloc(pwplib.videobuf.width*
    pwplib.videobuf.height*sizeof(u16));

  pwpwrite("* terminal on stdout: ");

  switch((int)pwp_tty.type)
  {
     case(TTY_DUMB):
        pwpwrite("dumb or unsupported\n");
        tty_dumb_init();
        break;

     case(TTY_VT2XX):
#ifdef DRIVE_TTY_VT2XX
        {
          char buf[40];
          sprintf(buf,"vt220/compatible (vt%d)\n",pwp_tty.minor);
          pwpwrite(buf);
        }
        tty_vt2xx_init();
        break;
#endif
     case(TTY_VT1XX):
        pwpwrite("vt100/compatible");
        if(pwp_tty.minor>=200)
        {  char buf[40];
           sprintf(buf," (a vt%d wannabe)\n",pwp_tty.minor);
           pwpwrite(buf);
        }
         else pwpwrite("\n");
        tty_vt1xx_init();
        break;


#     ifdef DRIVE_LINUXCON
     case(TTY_LINUX):
        pwpwrite("linux console\n");
        tty_linux_init();
        break;
#     endif

     case(TTY_XVT_COLOR):
        pwpwrite("xterm/compatible with color\n");
        tty_ansicol_init();
        break;

     case(TTY_XVT_MONO):
        pwpwrite("xterm (monochrome)\n");
        tty_vt1xx_init();
        break;

     case(TTY_ANSISYS):
        pwpwrite("msdos ansi or compatible\n");
        tty_ansisys_init();
        break;
   }
#endif
   return 1;
}

#endif
      
  
