import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class nano_test extends PApplet {

int c,i,x,y,z,w=1280,h=720,u;float f,r;public void settings(){size(w,h);}public void draw(){u+=f/h;f%=h;f+=sq(sin(r+=.01f))+1;for(i=1;i<w*h;i++)a();}
public void a(){x=i/h;y=i%h;z=PApplet.parseInt(f*h)+abs(x-w/2);c=(i*z*y%h)/16;if(u<2)c=z%(w/8)-z+y;if(u<1)c=z%(y+1);set(x,y,color(c));}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "nano_test" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
