import java.awt.AWTEvent;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Transparency;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;
import java.awt.event.MouseWheelEvent;
import java.awt.geom.AffineTransform;
import java.awt.geom.Area;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.util.Random;

import javax.swing.JFrame;

public class b extends JFrame {

    private static double d=0;//zoom to
    private static double ang=java.lang.Double.MAX_VALUE;
    private static int l=-2;//level
    
    private static final int[] p= new int[512];//noise
    private static final int[] f=new int[256];//noise
    
    public static void main(String[] args) {
        b frame = new b();
        frame.setTitle("Just Get Bigger");
        Random rnd = new Random();
        
        //general vars
        int i=0;
        int j=0;
        int xx=0;
        int yy=0;
        int ct=0;
        
        //timing
        int t=0;
        int frm=0;
        
        double z=1.0;
        
        for (i = 0; i < 256; i++) {
            double d=i/256.0;
            f[i]=(int) (d * d * d * (d * (d * 6 - 15) + 10)*256);
            p[i] = rnd.nextInt(256);
            p[256 + i] = p[i];        
        }
        frame.enableEvents(AWTEvent.MOUSE_EVENT_MASK | AWTEvent.MOUSE_MOTION_EVENT_MASK | AWTEvent.MOUSE_WHEEL_EVENT_MASK | AWTEvent.KEY_EVENT_MASK);
         
        frame.setSize(800, 600);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
        frame.createBufferStrategy(2);
        frame.setResizable(false);
        
        //BufferedImage redBuffer = frame.getGraphicsConfiguration().createCompatibleImage(128, 128, Transparency.TRANSLUCENT);
        //BufferedImage blueBuffer = frame.getGraphicsConfiguration().createCompatibleImage(128, 128, Transparency.TRANSLUCENT);
        
        BufferedImage redBuffer = new BufferedImage(128,128,BufferedImage.TYPE_INT_ARGB_PRE);
        BufferedImage blueBuffer = new BufferedImage(128,128,BufferedImage.TYPE_INT_ARGB_PRE);
        
        int[] bluePalette=new int[256];
        int[] redPalette=new int[256];
        for(i=0;i<256;i++) {
            bluePalette[i]=Color.getHSBColor(0.47f, 0.3f, 0.3f-i/256.0f*0.3f).getRGB();
            
        }
        
        int bgSize=1024;
        
        //BufferedImage backgroundImage = frame.getGraphicsConfiguration().createCompatibleImage(bgSize, bgSize);
        BufferedImage backgroundImage = new BufferedImage(bgSize, bgSize,BufferedImage.TYPE_INT_RGB);
                
        int[] bgPixels=new int[bgSize*bgSize];
        
        for(i=0;i<bgSize*bgSize;i++) {
            xx=(i&0x3ff)<<2;
            yy=(i>>10)<<2;
            
            j = Math.abs(n(xx, yy, 128));
            j+=Math.abs(n(xx<<1,yy<<1,128<<1))>>1;
            j+=Math.abs(n(xx<<2,yy<<2,128<<2))>>2;
            j+=Math.abs(n(xx<<3,yy<<3,128<<3))>>3;
            j+=Math.abs(n(xx<<4,yy<<4,128<<4))>>4;
            j+=Math.abs(n(xx<<5,yy<<5,128<<5))>>5;
            j+=Math.abs(n(xx<<6,yy<<6,128<<6))>>6;

            j=Math.max(j,0);
            j=Math.min(j,0xff);
            
            bgPixels[i]=bluePalette[j];
        }
        
        backgroundImage.getRaster().setDataElements(0, 0, bgSize, bgSize, bgPixels);
        
        double[] ballX=new double[256];
        double[] ballY=new double[256];
        double[] ballSize=new double[256];
        double[] ballDx=new double[256];
        double[] ballDy=new double[256];
        
        double[] gradientMask=new double[128*128];
        for(i=0;i<128;i++) {
            for(j=0;j<128;j++) {
                gradientMask[i*128+j]=Math.max(0, (64-Math.sqrt((64-i)*(64-i)+(64-j)*(64-j)))*1.5)/50.0;
            }
        }
        
        long t1 = System.currentTimeMillis();
        long logicTime=t1;
        
        int[] redPixels=new int[128*128];
        int[] bluePixels=new int[128*128];
        
        while(true) {
            if (l<0) {
                l=-l;
                for(i=1;i<256;i++) {
                    ballX[i]=rnd.nextInt(1800)-900;
                    ballY[i]=rnd.nextInt(1800)-900;
                    if (Math.abs(ballX[i])+Math.abs(ballY[i])<200) {
                        i--;
                        continue;
                    }
                    ballSize[i]=rnd.nextInt(25+l*6)+20;
                    
                    ballDx[i]=(rnd.nextInt(10)-5)/25.0;
                    ballDy[i]=(rnd.nextInt(10)-5)/25.0;
                }
                ballX[0]=0;
                ballY[0]=0;
                ballDy[0]=0;
                ballDx[0]=0.01;
                ballSize[0]=42;
                z=1;
                
                /*
                ballX[0]=0;
                ballY[0]=0;
                ballSize[0]=400;
                ballDx[0]=0;
                ballDy[0]=0;
                */
            }
            
            //Rectangle2D.Double r = new Rectangle2D.Double(-800,300,1600,100);
            
            ct=0;
            while (logicTime<System.currentTimeMillis()) {
                
                logicTime+=1000/60;
                
                if (ct++>10) {//slow computer
                    logicTime=System.currentTimeMillis();
                    break;
                }                
                t++;
                for(i=0;i<256;i++) {
                    if (ballSize[i]<=0) continue;
                    
                    ballX[i]+=ballDx[i];
                    ballY[i]+=ballDy[i];
                    
                    //ballDy[i]+=0.004;
                    
                    if (ballX[i]-ballSize[i]/2<-1000) {
                        ballDx[i]=Math.abs(ballDx[i]);
                    }
                    if (ballX[i]+ballSize[i]/2>1000) {
                        ballDx[i]=-Math.abs(ballDx[i]);
                    }
                    if (ballY[i]-ballSize[i]/2<-1000) {
                        ballDy[i]=Math.abs(ballDy[i]);
                    }
                    if (ballY[i]+ballSize[i]/2>1000) {
                        ballDy[i]=-Math.abs(ballDy[i]);
                    }
                    /*
                    Area area = new Area(r);
                    area.intersect(new Area(new Ellipse2D.Double(ballX[i]-ballSize[i]/2,ballY[i]-ballSize[i]/2,ballSize[i],ballSize[i])));
                    if (!area.isEmpty()) {
                        if (ballX[i]<r.x) {
                            ballDx[i]=-Math.abs(ballDx[i]);
                        }
                        if (ballX[i]>r.x+r.width) {
                            ballDx[i]=Math.abs(ballDx[i]);
                        }
                        if (ballY[i]<r.y) {
                            ballDy[i]=-Math.abs(ballDy[i]);
                        }
                        if (ballY[i]>r.y+r.height) {
                            ballDy[i]=Math.abs(ballDy[i]);
                        }
                    }
                    */
                    for(j=i+1;j<256;j++) {
                        if (ballSize[j]<=0) continue;
                        
                        double dist=Math.abs(ballSize[i]/2+ballSize[j]/2);
                        double a=ballX[i]-ballX[j];
                        double b=ballY[i]-ballY[j];
                        if (a*a+b*b<dist*dist) {
                            double intersect=dist-Math.sqrt(a*a+b*b);
                            if (ballSize[i]>ballSize[j]) {
                                ballSize[i]+=intersect/7;
                                ballSize[j]-=intersect;
                            } else {
                                ballSize[i]-=intersect;
                                ballSize[j]+=intersect/7;
                            }
                            
                            if (i==0) {
                                ballDx[i]*=0.99;
                                ballDy[i]*=0.99;
                            }
                        }
                    }
                }
                if (ang!=java.lang.Double.MAX_VALUE) {
                    ballDx[0]+=Math.sin(ang)*0.02;
                    ballDy[0]+=Math.cos(ang)*0.02;
                                        
                    ballSize[0]-=ballSize[0]*0.001;
                    
                    for(i=1;i<256;i++) {
                        if (ballSize[i]<=0) {
                            ballSize[i]=ballSize[0]*0.03;
                            ballX[i]=ballX[0]-(ballSize[0]/2+ballSize[i])*Math.sin(ang+rnd.nextDouble()*0.2-0.1);
                            ballY[i]=ballY[0]-(ballSize[0]/2+ballSize[i])*Math.cos(ang+rnd.nextDouble()*0.2-0.1);
                            ballDx[i]=ballDx[0]-Math.sin(ang+rnd.nextDouble());
                            ballDy[i]=ballDy[0]-Math.cos(ang+rnd.nextDouble());
                            break;
                        }
                    }
                }
                Thread.yield();
            }
            
            for(i=0;i<128;i++) {
                redPalette[i]=Color.getHSBColor(0.13f, i/128.0f, 0.8f*i/128.0f).getRGB();
                redPalette[i]=(redPalette[i] & 0xffffff)+(i<<25);
                
                bluePalette[i]=Color.getHSBColor(0.2f+0.4f, i/128.0f*0.6f, 0.8f*i/128.0f).getRGB();
                bluePalette[i]=(bluePalette[i] & 0xffffff)+(i<<25);
            }
            for(i=128;i<256;i++) {
                redPalette[i]=Color.getHSBColor((256-i)/128.0f*0.13f, 1, 0.8f*(1-(i-128)/256.0f*0.9f)).getRGB();
                redPalette[i]|=0xff000000;
                
                bluePalette[i]=Color.getHSBColor((i)/128.0f*0.1f+0.5f, 0.6f, 0.8f*(1-(i-128)/256.0f*0.9f)).getRGB();
                bluePalette[i]|=0xff000000;
            }
            
            Graphics2D g = (Graphics2D) frame.getBufferStrategy().getDrawGraphics();
            //g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            //g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);

            if (d>0) {
                z+=Math.min(d, 0.02);
                d-=Math.min(d, 0.02);
            } else if (d<0) {
                z+=Math.max(d, -0.02);
                d-=Math.max(d, -0.02);
            }
            z=Math.max(z,0.4);
            z=Math.min(z,1.5);
            
            //g.setColor(Color.BLACK);
            //g.fillRect(0, 0, 800, 600);
            
            g.translate(400, 300);
            
            //g.rotate(t*0.001);
            
            g.scale(z, z);
            g.translate(-ballX[0], -ballY[0]);
            
            //g.rotate(t*0.001);
            g.drawImage(backgroundImage, -2000+(int)(ballX[0]*0.5),-2000+(int)(ballY[0]*0.5),4000,4000,null);
            //g.rotate(-t*0.001);
            
            g.setColor(new Color(255,255,255));
            g.drawRect(-1000, -1000, 2000, 2000);
            
            for(i=0;i<128*128;i++) {
                xx=((i&0x7f)-(t>>1))<<3;
                yy=(i>>7)<<3;
                
                j = Math.abs(n(xx, yy, t));
                j+=Math.abs(n(xx<<1,yy<<1,t<<1))>>1;
                j+=Math.abs(n(xx<<2,yy<<2,t<<2))>>2;
                j+=Math.abs(n(xx<<3,yy<<3,t<<3))>>3;
                
                j=(int)(j*gradientMask[i]);
                j=Math.max(0, j);
                j=Math.min(0xff, j);
                
                redPixels[i]=redPalette[j & 0xff];
                bluePixels[i]=bluePalette[j & 0xff];
            }
            
            redBuffer.getRaster().setDataElements(0, 0, 128, 128, redPixels);
            blueBuffer.getRaster().setDataElements(0, 0, 128, 128, bluePixels);
            
            for(i=0;i<256;i++) {
                if (ballSize[i]<=0) continue;
                BufferedImage image=blueBuffer;
                if (ballSize[i]>ballSize[0]) {
                    image=redBuffer;
                }
                
                AffineTransform xform = AffineTransform.getTranslateInstance(ballX[i]-ballSize[i]/2,ballY[i]-ballSize[i]/2);
                xform.scale(ballSize[i]/128.0, ballSize[i]/128.0);
                xform.rotate(Math.atan2(ballDy[i], ballDx[i]),64,64);
                g.drawImage(image, xform, null);
                
                if (ballSize[i]<ballSize[0] && ballSize[i]>ballSize[0]-10) {
                    double s=1-(ballSize[0]-ballSize[i])/10.0;
                    xform = AffineTransform.getTranslateInstance(ballX[i]-ballSize[i]/2*s,ballY[i]-ballSize[i]/2*s);
                    xform.scale(ballSize[i]/128.0*s, ballSize[i]/128.0*s);
                    xform.rotate(Math.atan2(ballDy[i], ballDx[i]),64,64);
                    g.drawImage(redBuffer, xform, null);
                }
            }
            
            //g.drawImage(backgroundImage, (int)r.x,(int)r.y,(int)(r.x+r.width),(int)(r.y+r.height),0,0,bgSize,bgSize,null);
            
            //g.setColor(Color.RED);
            //g.fill(r);
            
            g.setTransform(AffineTransform.getTranslateInstance(0,frame.getInsets().top));
            
            g.setColor(new Color(40,40,200));
            g.fillRect(100, 0, 600, 30);
            g.fillRect(150, 30, 500, 10);
            
            g.setColor(new Color(200,200,100));
            g.fillRect(150, 30, (int)Math.min(ballSize[0]*2,500),10);
            
            
            g.setColor(new Color(240,240,240));
            g.drawRect(100, 0, 600, 30);
            
            g.drawRect(150, 30, 500, 10);
                        
            g.setColor(new Color(255,255,255));
            g.drawString((int)Math.min(ballSize[0]*2,500)/5+"%", 390, 40);
            
            g.drawString("Click and hold mouse to go that direction, use mouse wheel to zoom!", 120, 12);
            g.drawString("Press 1-9 to restart with other difficulty", 120, 26);
            
            g.drawString("Difficulty:   "+l, 620, 12);
            g.drawString("       FPS: "+(int)(frm/((System.currentTimeMillis() - t1) / 1000.0)), 620, 26);
            
            if (ballSize[0]<=0 || ballSize[0]*2>500) {
                g.setColor(new Color(40,40,200));
                g.fillRect(300,300,200,20);
                g.setColor(new Color(240,240,240));
                g.drawRect(300,300,200,20);
                if (ballSize[0]<=0) {
                    g.drawString("Press 1-9 to restart", 350, 316);
                } else {
                    g.drawString("Congratulations!  You win!", 330, 316);
                }
            }
            
            frm++;
            if (frm>20) {
                frm=0;
                t1=System.currentTimeMillis();
            }
            
            frame.getBufferStrategy().show();
        }
        
    }
        
    protected void processMouseEvent(MouseEvent mouseevent) {
        if (mouseevent.getID()==MouseEvent.MOUSE_DRAGGED || mouseevent.getID()==MouseEvent.MOUSE_PRESSED) {
            ang=Math.atan2(mouseevent.getX()-400, mouseevent.getY()-300);
        } else {
            ang=java.lang.Double.MAX_VALUE;
        }
    }
    protected void processMouseMotionEvent(MouseEvent mouseevent) {
        processMouseEvent(mouseevent);
    }
    protected void processMouseWheelEvent(MouseWheelEvent evt) {
        if (evt.getWheelRotation()>=0) {
            d=-0.2;
        } else {
            d=0.2;
        }
    }
    
    protected void processKeyEvent(KeyEvent evt) {
        if (evt.getID()==KeyEvent.KEY_TYPED && evt.getKeyChar()<='9' && evt.getKeyChar()>='1') {
            l=-(evt.getKeyChar()-'0');
        }
    }
    
    // http://mrl.nyu.edu/~perlin/noise/
    // http://www.noisemachine.com/talk1/23.html
    // 
    static int n(int x, int y, int z) {
        int X = (x>>8) & 0xff; // FIND UNIT CUBE THAT
        int Y = (y>>8) & 0xff; // CONTAINS POINT.
        int Z = (z>>8) & 0xff;
        
        x &= 0xff;
        y &= 0xff;
        z &= 0xff;
        
        int u = f[x]; // COMPUTE FADE CURVES
        int v = f[y]; // FOR EACH OF X,Y,Z.
        int w = f[z];
        
        int A = p[X] + Y;
        int AA = p[A] + Z;
        int AB = p[A + 1] + Z;
        int B = p[X + 1] + Y;
        int BA = p[B] + Z;
        int BB = p[B + 1] + Z;

        int v1=g(p[AA], x, y, z);
        int v2=g(p[BA], x - 256, y, z);
        int v3=g(p[AB], x, y - 256, z);
        
        int v4=g(p[BB], x - 256, y - 256, z);
        
        
        int j1=l(l(v1,v2,u),l(v3,v4,u),v);
        
        int v5=g(p[AA + 1], x, y, z - 256);
        int v6=g(p[BA + 1], x - 256, y, z - 256);
        int v7=g(p[AB + 1], x, y - 256, z - 256);
        int v8=g(p[BB + 1], x - 256, y - 256, z - 256);
        
        int j2=l(l(v5,v6,u),l(v7,v8,u),v);
        
        return l(j1,j2,w);
    }

    static int g(int hash, int x, int y, int z) {
        hash &= 15;
        int u = hash < 8 ? x : y;
        int v = hash < 4 ? y : hash == 0xc || hash == 0xe ? x : z;
        return ((hash & 1) == 0 ? u : -u) + ((hash & 2) == 0 ? v : -v);
    }

    static int l(int a, int b, int t) {
        return a+((t)*(b-a)>>8);
    }
    
}
