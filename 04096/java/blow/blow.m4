dnl blow-m4k
dnl
dnl This is where all macros for the intro-system are defined
dnl
dnl
dnl
dnl





dnl BLOW_DEFINE_EFFECT1(name,code)
dnl defines an effect that draws in one buffer
dnl the buffer have the name buf
define(BLOW_DEFINE_EFFECT1,`private void $1(int[] buf){$2}')

dnl BLOW_CALL_EFFECT1(name,src,dest)
dnl calls a previously defined effect
define(BLOW_CALL_EFFECT1,`$1($2);')


dnl BLOW_DEFINE_EFFECT2(name,code)
dnl defines an effect that uses one buffer and renders into another
dnl code will have buffers in src and dest
define(BLOW_DEFINE_EFFECT2,`private void $1(int[] src,int[] dest){$2}')

dnl BLOW_CALL_EFFECT2(name,src,dest)
dnl calls a previously defined effect
define(BLOW_CALL_EFFECT2,`$1($2,$3);')


dnl BLOW_MAKE_BUFFER(name)
dnl creates a buffer
define(BLOW_MAKE_BUFFER,`int[] $1=new int[width*height];')
dnl BLOW_COPY_BUFFER(src,dest)
dnl copies a buffer
define(BLOW_COPY_BUFFER,`System.arraycopy($1,0,$2,0,width*height);')
dnl BLOW_DRAW(buf)
dnl displays buffer onscreen
define(BLOW_DRAW,`update($1);')

dnl BLOW_DEFINE_GLOBAL(type,name)
dnl defines a global variable - (should check for conflicts later)
define(BLOW_DEFINE_GLOBAL,`divert(17) private $1 $2 ifelse(`$3',`',`/* no init */',`=$3') ; divert(0)')

dnl BLOW_GLOBAL(name)
dnl todo: implement namemangeling
define(BLOW_GLOBAL,$1)

dnl BLOW_ADD_POSTPAINT(code)
dnl adds code in paintroutine - have the graphics as g
define(BLOW_ADD_POSTPAINT,`divert(12)$1 divert(0)')

dnl BLOW_ADD_INITIALIZER(code)
dnl adds code to be run before mainloop
define(BLOW_ADD_INITIALIZER,`divert(14)$1 divert(0)')

dnl BLOW_MAINLOOP(endt,code)
dnl creates a loop that repeats code until frame endt
define(BLOW_MAINLOOP,`while(fcnt<$1){
	$2
	fcnt++;
	}
')

dnl BLOW_MAIN(code)
dnl produces a main-routine
define(BLOW_MAIN,`long fcnt;
private void main(){
	while(true){
	fcnt=0;
	$1
	}
}
')

dnl BLOW_INTRO(name,width,height)
dnl this is a big hairy macro that produces lots of code
dnl
define(BLOW_INTRO,`
import java.awt.*;
import java.awt.image.ImageProducer;
import java.awt.image.ImageConsumer;
import java.awt.image.DirectColorModel;

public class $1 extends java.applet.Applet implements Runnable, java.awt.image.ImageProducer{
define(width,$2)dnl
define(height,$3)dnl

divert(1)
    private synchronized void update(Object p){
        if (c!=null)
        {
            c.setPixels(0,0,width,height,md,(int[])p,0,width);
            c.imageComplete(ImageConsumer.SINGLEFRAMEDONE);
        }
        paint();
    }
    private synchronized void paint(){
        Graphics g=getGraphics();
	g.drawImage(i,0,0,width,height,null);
divert(13)
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
divert(15) dnl initializers will be inserted here
        main();
    }

    public void stop(){
        if (T!=null && T.isAlive()){
            T.stop();
        }
        T = null;
    }

    public synchronized void addConsumer(ImageConsumer ic){
        c = ic;
        c.setDimensions(width,height);
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
    dnl other globals will be inserted here

divert(20)}
divert(0)
')

