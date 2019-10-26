//gozo.java - copyright baah/Arm's Tech, november 2002

import java.awt.*;

public class gozo extends java.applet.Applet implements Runnable {
  Thread MainThread=null; //Create Thread
  int width=100,height=128; //Screen size
  double sk=0.45; //StiffnessKoefficient
  double ak=0.95; //AbsorptionKoefficient
  double gravity=0.3; //Gravity
  int nbpoints=8, nbedges=20; //NbPoints & NbEdges
  double l0=28.2842712;
  double[] x ={40,l0, 0,-l0,-40,-l0,  0, l0}; //position
  double[] y ={ 0,l0,40, l0,  0,-l0,-40,-l0};
  double[] vx={0,0,0,0,0,0,0,0}; //velocity
  double[] vy={0,0,0,0,0,0,0,0};
  double[] ax={0,0,0,0,0,0,0,0}; //acceleration
  double[] ay={0,0,0,0,0,0,0,0};
  int[] start={0,1,2,3,4,5,6,7, 0,1,2,3, 0,0,1,1,2,2,3,4}; //edges' start,
  int[] end  ={1,2,3,4,5,6,7,0, 4,5,6,7, 3,5,4,6,5,7,6,7}; //end &
  double[] nl={0,0,0,0,0,0,0,0, 0,0,0,0, 0,0,0,0,0,0,0,0}; //neutral lengths
  int c,c2,s,e,s2,e2,nbnomove=0;
  double dx,dy,dist,dist2,fx,fy,forth,momentum;

  Image WorkScreen;
  Graphics WorkGfx;

//**** Initialisations ****
  public void init() {
    setBackground(Color.lightGray);
    WorkScreen=createImage(width,height); //Create work buffer
    WorkGfx=WorkScreen.getGraphics();
    WorkGfx.setColor(Color.lightGray); //Fill buffer
    WorkGfx.fillRect(1,1,width,height);
    //Recenter objet
    for(c=0;c<=nbpoints-1;c+=1) {
      x[c]+=50;
      y[c]+=64;
    }
    //Compute neutral lengths for springs
    for(c=0;c<=nbedges-1;c+=1) {
      s=start[c];
      e=end[c];
      dx=x[s]-x[e];
      dy=y[s]-y[e];
      nl[c]=Math.sqrt(dx*dx+dy*dy);
    }
  }

//**** Thread routines ****
  public void start() {
    if(MainThread==null); {
      MainThread=new Thread(this);
      MainThread.start();
    }
  }
  public void stop() {
    if(MainThread!=null) {
      MainThread.stop();
      MainThread=null;
    }
  }

//**** Spring system calculations ****
  public void run() {
    while(true) {
      //Initialise forces to 0
      for(c=0;c<=nbpoints-1;c+=1) {
        ax[c]=0;
        ay[c]=gravity;
      }
      //Compute force for each spring
      for(c=0;c<=nbedges-1;c+=1) {
        s=start[c];
        e=end[c];
        dx=x[s]-x[e];
        dy=y[s]-y[e];
        dist2=dx*dx+dy*dy;
        if (dist2>0) {
          dist=Math.sqrt(dist2);
          fx=(nl[c]-dist)*sk*dx/dist;
          fy=(nl[c]-dist)*sk*dy/dist;
          ax[s]+=fx;
          ay[s]+=fy;
          ax[e]-=fx;
          ay[e]-=fy;
        }
      }
      //Compute movements for each point & pseudo momentum
      momentum=0;
      for(c=0;c<=nbpoints-1;c+=1) {
        vx[c]=vx[c]*ak+ax[c];
        vy[c]=vy[c]*ak+ay[c];
        momentum=momentum+Math.abs(vx[c])+Math.abs(vy[c]);
        x[c]=x[c]+vx[c];
        y[c]=y[c]+vy[c];
        if(x[c]<3) {x[c]=3;vx[c]=-vx[c];vy[c]=0;} //clipping+friction
        if(x[c]>=width-3) {x[c]=width-3;vx[c]=-vx[c];vy[c]=0;}
        if(y[c]<3) {y[c]=0;vy[c]=-vy[c];vx[c]=0;}
        if(y[c]>=height-3) {y[c]=height-3;vy[c]=-vy[c];vx[c]=0;}
      }
      //Check momentum, and add random velocity if small enough
      if(momentum<3) { nbnomove+=1;}
      if(nbnomove>64) {
        forth=Math.random()*4+4;
        fx=Math.random()*6-3;
        fy=-Math.random()*4-2;
        for(c=0;c<=nbpoints-1;c+=1) {
          s=c+nbpoints/2;
          if(s>nbpoints-1) { s-=nbpoints-1;}
          e=c-nbpoints/2;
          if(e<0) { e+=nbpoints-1;}
          vx[c]=fx+forth*(x[s]-x[e])/80;
          vy[c]=fy+forth*(y[s]-y[e])/80;
        }
        nbnomove=0;
      }
      try {
        MainThread.sleep(50);
      }
      catch(InterruptedException e) {}
      repaint();
    }
  }

//**** Drawing routine ****
  public void update(Graphics g) { paint(g); }

  public void paint(Graphics g) {
    WorkGfx.setColor(Color.lightGray); //Empty WorkScreen
    WorkGfx.fillRect(0,0,width,height);
    //Draw lines
    WorkGfx.setColor(Color.black);
    for(c2=0;c2<=nbedges-1;c2+=1) {
      s2=start[c2];
      e2=end[c2];
      WorkGfx.drawLine((int)x[s2],(int)y[s2],(int)x[e2],(int)y[e2]);
    }
    //Draw circles
    for(c2=0;c2<=nbpoints-1;c2+=1) {
      s2=(int)x[c2]; //x
      e2=(int)y[c2]; //y
      WorkGfx.setColor(Color.red);
      WorkGfx.drawLine(s2-1,e2-2,s2+1,e2-2);
      WorkGfx.fillRect(s2-2,e2-1,5,3);
      WorkGfx.drawLine(s2-1,e2+2,s2+1,e2+2);
      WorkGfx.setColor(Color.white);
      WorkGfx.drawLine(s2-1,e2-1,s2-1,e2-1);
    }
    g.drawImage(WorkScreen,0,0,this);
  }
}
