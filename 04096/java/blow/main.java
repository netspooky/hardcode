import sun.audio.AudioPlayer;





































import java.awt.*;
import java.awt.image.ImageProducer;
import java.awt.image.ImageConsumer;
import java.awt.image.DirectColorModel;

public class main extends java.applet.Applet implements Runnable, java.awt.image.ImageProducer{




private void bloobs(int[] buf){
	int b1x=400/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/80)*400/3));
	int b1y=300/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/100)*300/3));

	int b2x=400/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/50+1)*400/3));
	int b2y=300/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/70)*300/3));

	int b3x=400/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/130+1)*400/3));
	int b3y=300/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/100+2)*300/3));

	for(int y=0;y<300;y++){
	    for(int x=0;x<400;x++){
		float d1=(b1x-x)*(b1x-x)+(b1y-y)*(b1y-y);
		float d2=(b2x-x)*(b2x-x)+(b2y-y)*(b2y-y);
		float d3=(b3x-x)*(b3x-x)+(b3y-y)*(b3y-y);
		
		if(d1*d1*d2*d2*d3*d3<(float)1e21){
		    buf[y*400+x]=0xFFFFFF;
		}
	    }
	}
}



private void fade(int[] buf){
	for(int i=0;i<buf.length;i++){
	    int r=(buf[i]&0xFF0000);
	    int g=(buf[i]&0xFF00);
	    int b=(buf[i]&0xFF);
	    if(r<0x80000){r=0;}else{r-=0x80000;}
	    if(g<0x800){g=0;}else{g-=0x800;}
	    if(b<0x8){b=0;}else{b-=0x8;}
	    buf[i]=r|g|b;
	}
}

private void blur(int[] src,int[] dest){
	int i=400+1;
	for(int y=300-2;y>0;y--){
	    for(int x=400-2;x>0;x--){
		int rb=(src[i-400]&0xFF00FF);
		rb+=(src[i+400]&0xFF00FF);
		rb+=(src[i-1]&0xFF00FF);
		rb+=(src[i+1]&0xFF00FF);
		rb/=4;
		rb&=0xFF00FF;
		int g=(src[i-400]&0xFF00);
		g+=(src[i+400]&0xFF00);
		g+=(src[i-1]&0xFF00);
		g+=(src[i+1]&0xFF00);
		g/=4;
		g&=0x00FF00;
		dest[i++]=rb|g;
	    }
	    i+=2;
	}
}
private void lookup(int[] src,int[] dest){
	for(int i=0;i<dest.length;i++){
	    dest[i]=src[lookupTable[i]];
	}
}





public void initLookupTable(){
	lookupTable=new int[300*400];
	for(int y=0;y<300;y++){
	    for(int x=0;x<400;x++){
		lookupTable[y*400+x]=(((int)((y-300/2)/1.05))+300/2)*400+(((int)((x-400/2)/1.05))+400/2);
		while(lookupTable[y*400+x]<0){
		    lookupTable[y*400+x]+=400;
		}
		while(lookupTable[y*400+x]>=400*300){
		    lookupTable[y*400+x]-=400;
		}
	    }
	}
    }







private void julia(int[] buf){
		    double z_r,z_i,c_r,c_i;
		    c_r=0.6+0.5*Math.sin(Math.PI*fcnt/40)+0.4*Math.sin(Math.PI*fcnt/197);
		    c_i=0.6*Math.sin(Math.PI*fcnt/11);
		    for(int y=0;y<300;y+=2){
			for(int x=0;x<400;x+=2){
			    int cnt=0;
			    z_r=((double)x/400)*4-2.3d;
			    z_i=((double)y/300)*4-2d;
			    while(cnt++<5){
				double tt=(z_r+c_r)*(z_r+c_r)-(z_i+c_i)*(z_i+c_i);
				z_i=2*(z_r+c_r)*(z_i+c_i);
				z_r=tt;
				if(z_r*z_r+z_i*z_i>4.0){
				    break;
				}
			    }

			    if(z_r*z_r+z_i*z_i<4.0){
				buf[y*400+x]=0xFFFFFF;
			    }
			}
		    }

}

private void colorize(int[] src,int[] dest){
int ar=(int)Math.round((1.0+Math.sin((float)fcnt/30))*128);
int ag=(int)Math.round((1.0+Math.sin((float)fcnt/40))*128);
int ab=(int)Math.round((1.0+Math.sin((float)fcnt/60))*128);

for(int i=0;i<400*300;i++){
   int r=((((src[i]&0xFF0000)>>8)*ar))&0xFF0000;
   int g=(((src[i]&0xFF00)*ag)>>8)&0xFF00;
   int b=(((src[i]&0xFF)*ab)>>8)&0xFF;
   dest[i]=r|g|b;
}

}


long fcnt;
private void main(){
	while(true){
	fcnt=0;
	int[] fb1=new int[400*300];
        int[] fb2=new int[400*300];
	while(fcnt<128){
	fade(fb1);
        	julia(fb1);
	        blur(fb1,fb2);
		colorize(fb1,fb2);
	        update(fb2);
	
	fcnt++;
	}

	while(fcnt<256){
	fade(fb1);
        	julia(fb1);
	        blur(fb1,fb2);
	        lookup(fb2,fb1);
		colorize(fb1,fb2);
	        update(fb2);
	
	fcnt++;
	}

	while(fcnt<384){
	fade(fb1);
		bloobs(fb1);
	        blur(fb1,fb2);
	        lookup(fb2,fb1);
		colorize(fb1,fb2);
	        update(fb2);
	
	fcnt++;
	}


	}
}


    private synchronized void update(Object p){
        if (c!=null)
        {
            c.setPixels(0,0,400,300,md,(int[])p,0,400);
            c.imageComplete(ImageConsumer.SINGLEFRAMEDONE);
        }
        paint();
    }
    private synchronized void paint(){
        Graphics g=getGraphics();
	g.drawImage(i,0,0,400,300,null);






if((fcnt%24)==0){
	g.setFont(new Font("Monospaced",Font.BOLD,18));
	g.setColor(Color.black);
	g.fillRect(0,300,400,100);
	g.setColor(Color.white);
	g.drawString(txts[((int)(fcnt/24)&0xf)*2],40,320);
	g.drawString(txts[((int)(fcnt/24)&0xf)*2+1],40,340);
}
 
    }

    public void start(){
        if (T==null){
            T = new Thread(this);
            T.start();
        }
    }

    public void run(){
	md=new DirectColorModel(32,0x00FF0000,0x000FF00,0x000000FF,0);        
        i = Toolkit.getDefaultToolkit().createImage(this);
initLookupTable();          main();
    }

    public void stop(){
        if (T!=null && T.isAlive()){
            T.stop();
        }
        T = null;
    }

    public synchronized void addConsumer(ImageConsumer ic){
        c = ic;
        c.setDimensions(400,300);
        c.setHints(ImageConsumer.TOPDOWNLEFTRIGHT|ImageConsumer.COMPLETESCANLINES|ImageConsumer.SINGLEPASS|ImageConsumer.SINGLEFRAME);
        c.setColorModel(md);
    }

    public synchronized boolean isConsumer(ImageConsumer ic){
        return true;
    }

    public synchronized void removeConsumer(ImageConsumer ic){
    }

    public void startProduction(ImageConsumer ic){
        addConsumer(ic);
    }

    public void requestTopDownLeftRightResend(ImageConsumer ic) {
    }

    Image i;
    Thread T;
    ImageConsumer c;
    DirectColorModel md;
    
 private int[] lookupTable /* no init */ ;  private final String[] txts ={
/* * * * * * * * * * * * */
"    This was supposed    ",
"   to be an 4k invitro   ",
/* * * * * * * * * * * * */
"    for our demoparty    ",
"         H Y P E         ",
/* * * * * * * * * * * * */
"                         ",
"                         ",
/* * * * * * * * * * * * */
" But i guess it ended up ",
"  beeing an experiment   ",
/* * * * * * * * * * * * */
"   with using m4 as an   ",
"  preprocessor for java  ",
/* * * * * * * * * * * * */
"                         ",
"                         ",
/* * * * * * * * * * * * */
"   All code written at   ",
"    M A I N F R A M E    ",
/* * * * * * * * * * * * */
"           by            ",
"          blow           ",
/* * * * * * * * * * * * */
"   Most time was spent   ",
"     on learning m4      ",
/* * * * * * * * * * * * */
"      No time to do      ",
"         cool FX         ",
/* * * * * * * * * * * * */
"  Check the source-code  ",
" for my macros and stuff ",
/* * * * * * * * * * * * */
"Will implement obfuscator",
"     in next version     ",
/* * * * * * * * * * * * */
"     m4 is addictive     ",
"                         ",
/* * * * * * * * * * * * */
"                         ",
"                         ",
/* * * * * * * * * * * * */
"        Text will        ",
"          loop           ",
/* * * * * * * * * * * * */
"                         ",
"                         "
/* * * * * * * * * * * * */
} ; }
