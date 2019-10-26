import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;

import javax.sound.sampled.*;

public class Robotron implements KeyListener
{
    private static final String data = "$hexdata";

    private static GraphicsDevice device = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice();
    private static GraphicsConfiguration gconfig = device.getDefaultConfiguration();

    private static final boolean[] keys = new boolean[256];

    public static void main(String[] args) throws Exception
    {
        BufferedImage[] images = loadImages();
        Frame frame = new Frame();

        BufferStrategy strategy;
        Graphics g;

        int[] robot = new int[256];
        int[] robotx = new int[256];
        int[] roboty = new int[256];
        int[] robotLife = new int[256];
        int robots = 0;
        int alive = 0;

        int x = 127;
        int y = 127;
        int angle = 0;
        int level = 0;

        int x1;
        int x2;
        int y1;
        int y2;

        int[] distance = new int[256];
        double[] scale = new double[256];
        int[] distx = new int[256];
        int[] disty = new int[256];

        int tempx;
        int tempy;
        int width;
        int height;
        int image;
        int counter = 0;
        boolean walk = false;
        boolean gameover = false;
        int firing = 0;
        int random = 69069;
        int score = 0;
        int explode = -1;

        int[] sort = new int[256];
        
        double stepx = 0.0;
        double stepy = 0.0;
        
        long time = System.currentTimeMillis();
        
        
/*       //Sound Support
        AudioFormat format = new AudioFormat(8000.0f, 8 , 1, true, false);
        //DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
        SourceDataLine line = (SourceDataLine) AudioSystem.getLine(new DataLine.Info(SourceDataLine.class, format));  
        byte[][] sounds = new byte[2][2000];
        int sound = 0;
        long time = System.currentTimeMillis();
        
        //Generate some sounds!
        int step;
        
        //Laser
        step = 10;
        for(int i=0; i<2000; i++)
        {
            sounds[1][i] = ((i%step > 0) ? 32 : (byte)0);
            
            if(i%250 == 0) step += 2;
        }*/
        
        
        frame.setUndecorated(true);
        //frame.setIgnoreRepaint(true);
        frame.addKeyListener(new Robotron());

        device.setFullScreenWindow(frame);
        device.setDisplayMode(new DisplayMode(640, 480, 32, 0));

        frame.createBufferStrategy(2);
        strategy = frame.getBufferStrategy();
        
/*        line.open(format);
        line.start();*/

        while(true)
        {
            if(alive == 0)
            {
                level++;
                robots = (level < 64) ? level << 2 : 256;
                alive = robots;
                counter = 0;
                
                for(int i=0; i<robots; i++) 
                {
                    random = (69069 * random + 1) % 1024;
                    robotx[i] = random;
                    random = (69069 * random + 1) % 1024;
                    roboty[i] = random;
                    robot[i] = i%2;
                    
                    robotLife[i] = robot[i]+1;
                }
            }

            g = strategy.getDrawGraphics();

            g.setColor(new Color(0x00));
            g.fillRect(0, 0, 640, 240);
            g.setColor(new Color(0x553300));
            g.fillRect(0, 240, 640, 480);
            
            g.setColor(new Color(0x00FF00));
            g.fillRect(50, 50, 2, 2);
            
            g.setColor(new Color(0xFF0000));

            
            for(int i=0; i<robots; i++)
            {
                x1 = robotx[i] - x;
                y1 = roboty[i] - y;
                
                tempx = (int)(x1 * Math.cos(Math.toRadians(-angle)) - y1 * Math.sin(Math.toRadians(-angle)));
                tempy = (int)(y1 * Math.cos(Math.toRadians(-angle)) + x1 * Math.sin(Math.toRadians(-angle)));

                distx[i] = tempx;
                disty[i] = tempy;
                distance[i] = (int)Math.sqrt(distx[i] * distx[i] + disty[i] * disty[i]);
                scale[i] = 64.0/distance[i];

                sort[i] = i;
           }
           
           for(int j=0; j<robots; j++)
           {
               for(int i=1; i<robots; i++)
               {
                   if(distance[sort[i-1]] < distance[sort[i]])
                   {
                       tempx = sort[i];
                       sort[i] = sort[i-1];
                       sort[i-1] = tempx;
                   }
               }
           }

           if((counter % 10) == 0) walk = !walk;

           for(int j=robots,i=0; j>=0; j--)
           {
                i = sort[j];

                if(robotLife[i] < 1 || disty[i] == 0) continue;
                

                tempx = (int)((robotx[i] - x) * Math.cos(Math.toRadians(-angle)) - (roboty[i] - y) *  Math.sin(Math.toRadians(-angle)));
                tempx = tempx * 512;
                tempx = tempx / distance[i] + 320;

                width = (int)(256 * scale[i]);
                
                tempx = tempx-width/2;
                
                if(disty[i] <=  0) continue;
                
                if(firing == 1 && tempx < 312 && tempx+width > 328)
                {
                    robotLife[i]--;
                    firing++;
                    
                    if(robotLife[i] == 0) 
                    {
                        alive--;
                        score += (robot[i] + 1) * 100;
                    }
                    
                    explode = i;
                }
           }
           
           for(int j=0,i=0; j<robots; j++)
           {
                i = sort[j];

                if((robotLife[i] < 1 && explode != i) || disty[i] == 0) continue;

                tempx = (int)((robotx[i] - x) * Math.cos(Math.toRadians(-angle)) - (roboty[i] - y) *  Math.sin(Math.toRadians(-angle)));
                tempx = tempx * 512;
                tempx = tempx / distance[i] + 320;

                width = (int)(256 * scale[i]);
                image = robot[i];

                if(image == 1 && walk) image++; 
                
                tempx = tempx-width/2;
                tempy = 240-width/2;
                
                
                if(distance[i] < 50*8) g.fillRect(distx[i]/10+50, 50-disty[i]/10, 2, 2); 
                if(disty[i] <=  0) continue;

                g.drawImage(images[image], tempx, tempy, width, width, null);
                
                if(explode == i)
                {
                    g.drawImage(images[3], tempx, tempy, width, width, null);
                    explode = -1;
                }
                
                if(x < robotx[i]) robotx[i]--;
                if(y < roboty[i]) roboty[i]--;
                if(x > robotx[i]) robotx[i]++;
                if(y > roboty[i]) roboty[i]++;
                
                if(distance[i] < 25 && distance[i] > -25) gameover = true;
            }
            
            //Targetting reticle
            g.setColor(new Color(0xFFFFFF));
            g.fillRect(314, 230, 14, 2);
            g.fillRect(320, 224, 2, 14);
            
            if(counter < 100)
            {
                g.drawString("Level "+level, 300, 220);
            }
            
            
            g.drawString("Score "+score, 520, 20);
            
            if(!gameover)
            {          
                //Key Handling
                if(keys[KeyEvent.VK_LEFT]) angle++;
                if(keys[KeyEvent.VK_RIGHT]) angle--;
                if(angle >= 360) angle -= 360;
                if(angle < 0) angle += 360;
    
                
    
                stepx = Math.cos(Math.toRadians(angle+90));
                stepy = Math.sin(Math.toRadians(angle+90));
                
                if(keys[KeyEvent.VK_UP])
                {
                    x += stepx * 6.0; 
                    y += stepy * 6.0;
                }
    
                if(keys[KeyEvent.VK_DOWN])
                {
                    x -= stepx * 6.0;
                    y -= stepy * 6.0;
                }
                
                if(x < 0) x = 0;
                if(x > 1024) x = 1024;
                if(y < 0) y = 0;
                if(y > 1024) y = 1024;
                
                if(keys[KeyEvent.VK_CONTROL] || firing > 0)
                {
                    g.fillRect(313+firing, 225+firing, 15-(firing*2), 15-(firing*2));
                    firing = (firing + 1) % 10;
                    //if(firing == 0) sound = 1;
                }
            }
            else
            {
                g.drawString("Game Over", 300, 220);
            }
            
            
            if(keys[KeyEvent.VK_ESCAPE]) 
            {
                System.exit(0);
            }
            
/*            //Render Sound
            if(System.currentTimeMillis() >= time+255)
            {
                line.flush();
                line.write(sounds[sound], 0, 2000);
                
                sound = 0;
                time += 255;
            }*/
            
            counter++;

            strategy.show();
            
            while(time+25 > System.currentTimeMillis()); // Thread.yield();
            time += 25;
        }
    }

    private static final BufferedImage[] loadImages()
    {
        int[] colors = new int[256];
        int colorCount;
        int color;
        int temp;
        int counter;
        int bits;
        int pos = 0;
        
        int width;
        int height;
        int image = 0;
        
        
        //Ajust this value to the number of images in your file 
        BufferedImage[] images = new BufferedImage[25];

        while(pos < data.length()-1)
        {
            colorCount = (Character.digit(data.charAt(pos++), 16) << 4) + Character.digit(data.charAt(pos++), 16);

            for(int i=0; i<colorCount; i++)
            {
                temp = (Character.digit(data.charAt(pos++), 16) << 20) | 
                       (Character.digit(data.charAt(pos++), 16) << 16) |
                       (Character.digit(data.charAt(pos++), 16) << 12) |
                       (Character.digit(data.charAt(pos++), 16) << 8)  | 
                       (Character.digit(data.charAt(pos++), 16) << 4)  |
                       Character.digit(data.charAt(pos++), 16);
    
                colors[i+1] = temp;
            }

            width  = (Character.digit(data.charAt(pos++), 16) << 4)  | Character.digit(data.charAt(pos++), 16) + 1;
            height = (Character.digit(data.charAt(pos++), 16) << 4)  | Character.digit(data.charAt(pos++), 16) + 1;

            images[image] = gconfig.createCompatibleImage(width, height, Transparency.BITMASK);

            temp = 1;
            bits = 1;
            while((temp <<= 1) <= colorCount && bits < 8) bits++;

            counter = 0;
            temp = Character.digit(data.charAt(pos++), 16);

            for(int y=0; y<height; y++)
            {
                for(int x=0; x<width; x++)
                {
                    color = 0;
                
                    for(int i=0; i<bits; i++)
                    {
                        color >>= 1;
                    
                        if(counter == 4)
                        {
                            temp = Character.digit(data.charAt(pos++), 16);
                            counter = 0;
                        }
                    
                        if((temp & 0x8) > 0) color |= 0x80;

                        temp <<= 1;
                        counter++;
                    }
    
                    color >>= (8 - bits);
                    if(color != 0) images[image].setRGB(x, y, 0xFF000000 | colors[color]);
                }
            }

            image++;

            if(pos % 2 == 1) pos++;
        }

        return images;
    }

    public void keyPressed(KeyEvent e)
    {
        keys[e.getKeyCode()] = true;
    }

    public void keyReleased(KeyEvent e)
    {
        keys[e.getKeyCode()] = false;
    }

    public void keyTyped(KeyEvent e) {}
}
