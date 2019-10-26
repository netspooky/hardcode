/*
 * Speed
 *
 * @author Alan Waddington
 */

/*
 * Copyright © 2005, Alan Waddington
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * The names of its contributors may not be used to endorse or promote products
 * derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import java.awt.Color;
import java.awt.Graphics;
import java.awt.event.KeyEvent;
import java.awt.image.BufferedImage;
import java.awt.image.DataBufferInt;
import javax.swing.JFrame;
import java.util.Random;

/** Speed */
public class G extends JFrame {

    private final static float ROTATESPEED    = 8e-9f;// Player rotate speed
    private final static float TRANSLATESPEED = 5e-8f;// Player speed

    private final static int   SCREENHEIGHT   = 480;    // Screen height
    private final static int   SCREENWIDTH    = 640;    // Screen width

    private final static int   KA             = 1;
    private final static int   KB             = 5;
    private final static int   DEPTH          = 200;
    private final static float CARRADIUS1     = 10.08f;
    private final static float CARRADIUS2     = 9.92f;
    
    private boolean keyLeft, keyRight, keyUp, keyDown;  // Cursor keys pressed
    private int key;                                    // Last Key pressed

    /** Creates a new instance of Speed */
    private G() {
        super("Speed");
        
        float[] heightX = new float[100000];// Terrain Height map
        float[] heightZ = new float[100000];
    
        float[] treeX = new float[500];     // Tree positions
        float[] treeY = new float[500];
        float[] treeZ = new float[500];

        float[] carX = new float[20];       // Car positions
        float[] carZ = new float[20];
        float[] carAngle = new float[20];
    
        float[] zMap = new float[DEPTH];    // Non-linear z function
    
        float playerX = 0;                  // Player position
        float playerY = 0;
        float playerZ = 0;                     
        float angleY = 0;
        float cosAngleY, sinAngleY;
        
        boolean reset = true;               // Game reset
        boolean gameOver = true;            // Game over
        
        float speed;                        // Player max speed               
        float velocity = 0f;                // Player velocity
        float steering = 0f;                // Player steering
       
        long clock = 0;                     // Race clock in milliseconds
        long lastClock = 0;                 // Race clock to last second (ms)
        long startTime = 0;                 // Time race started in ms
        long lapStart = 0;                  // Time lap started in ms
        long lapTime = 0;                   // Time to complete last lap in ms
        long bestLapTime = 0;               // Best lap time in ms
        
        int lap = 1;                        // Current lap
        int maxLap = 1;                     // Highest achieved lap
        
        BufferedImage screen;                       // Screen buffer
        int[] screenData;                           // Screen buffer data

        BufferedImage scoreImage;                   // Score image
        int[] scoreData;                            // Score image data

        BufferedImage[] carImage = new BufferedImage[3]; // Car images
        int[][] carData = new int[3][];             // Car image data

        Graphics g;                                 // Misc use
        int i;
        float x, y, z, r;
        
        //
        // Initialisation
        //
        
        // Create height map in increments of 0.01 units
        for (i=0; i<0x10000; i++) {
            float angle = 2f*3.142f/0x10000*i;
            heightX[i] = 25f*(float)(0.1*Math.sin(angle*5f) +
                0.2*Math.sin(angle*2f) + 0.2*Math.sin(angle));
            heightZ[i] = 25f*(float)(0.1*Math.sin(angle*7f) +
                0.2*Math.sin(angle*3f) + 0.2*Math.sin(angle));
        }
        
        // Trees
        for (int tree=0; tree<500; tree++) {
            do {
                treeX[tree] = x = 200f*(float)Math.random() - 100f;
                treeZ[tree] = z = 200f*(float)Math.random() - 100f;
                int txx = (int)(1000f*x) & 0xffff;
                int tzz = (int)(1000f*z) & 0xffff;
                treeY[tree]  = heightX[txx]+heightZ[tzz];
                r = x*x/(KA*KA) + z*z/(KB*KB);
            } while (!((r>80f && r<85f) || (r>115f && r<120f)));
        }
        
        // Non-linear Z function        
        for (i=0; i<DEPTH; i++)
            zMap[i] = DEPTH*1.1f/(DEPTH*1.1f-i) - 1f;
        
        //
        // Car front and back images
        //
        
        // Create arrays of image data
        Color darkBlue = new Color(0,0,64);
        for (int car=0; car<3; car++) {
            carImage[car] =
                new BufferedImage(32,32,BufferedImage.TYPE_INT_ARGB_PRE);
            carData[car] = ((DataBufferInt)carImage[car].
                getRaster().getDataBuffer()).getData();
            for (i=0; i<1024; i++)     // Clear image as Java > 1.1
                carData[car][i] = 0;   // doesn't guarantee state

            // Draw common parts
            g = carImage[car].getGraphics();
            g.setColor(Color.blue);
            g.fillRect(6,8,20,3);
            g.fillRect(5,11,22,4);
            g.fillRect(4,15,24,9);
            g.setColor(Color.black);
            g.fillRect(4,24,24,4);
            g.setColor(darkBlue);
            g.fillRect(4,15,24,1);
            g.fillRect(4,23,24,1);
            switch (car) {
                case 0: // Back
                    g.fillRect(6,16,20,1);
                    g.setColor(Color.gray);
                    g.fillRect(7,9,18,3);
                    g.fillRect(6,12,20,3);
                    g.setColor(Color.yellow);
                    g.fillRect(11,19,10,3);
                    g.setColor(Color.red);
                    g.fillRect(6,17,3,4);
                    g.fillRect(23,17,3,4);
                    break;
                case 1: // Front
                    g.fillRect(6,16,20,1);
                    g.setColor(Color.gray);
                    g.fillRect(7,9,18,3);
                    g.fillRect(6,12,20,3);
                    g.fillRect(11,19,10,3);
                    g.setColor(Color.white);
                    g.fillRect(6,18,4,3);
                    g.fillRect(22,18,4,3);
                default:
            }
            g.dispose();                
        }
                
        // Create score image (speeds up drawing)
        scoreImage = new BufferedImage(
            SCREENWIDTH,30, BufferedImage.TYPE_INT_RGB);
        scoreData =
            ((DataBufferInt)scoreImage.getRaster().getDataBuffer()).getData();
               
        // Create screen image (double buffer)
        screen = new BufferedImage(
            SCREENWIDTH, SCREENHEIGHT, BufferedImage.TYPE_INT_RGB);
        screenData =
            ((DataBufferInt)screen.getRaster().getDataBuffer()).getData();
        
        // Create screen z buffer
        float[] zBuffer = new float[SCREENWIDTH*SCREENHEIGHT];
        
        // Enable Keyboard
        enableEvents(java.awt.AWTEvent.KEY_EVENT_MASK);

        // Create Window
        setIconImage(carImage[1]);
        setResizable(false);
        
        show();
        setSize(SCREENWIDTH  + getWidth()  - getContentPane().getWidth(),
                SCREENHEIGHT + getHeight() - getContentPane().getHeight());
        show();
                        
        // Initialise timing
        long time = System.currentTimeMillis();
        long lastTime;
        long deltaTime = 0; // 125u resolution
/*
        int cnt = 0;            // Frame counter
        long fpsTime = time;    // Frame time for fps calcs
*/
        //
        // Main game loop
        //
        
        while (isVisible() && key != KeyEvent.VK_ESCAPE) {
            // Calculate frame time in 125 microsecond increments
            lastTime = time;
            time = System.currentTimeMillis();
            deltaTime = ((7*deltaTime)/8 + (time - lastTime));
/*
            // Every 100 frames, print the frame time in milliseconds
            if (cnt++ % 100 == 0) {
                System.out.println((time-fpsTime)/100);
                fpsTime = time;
            }
*/                        
            // Perform game reset
            if (reset) {
                reset = false;
                playerX = 10f*KA;       // Player initial position
                playerZ = 0f;
                angleY = 0f;
                velocity = 0f;          // Player velocity & steering angle
                steering = 0f;
                startTime = time;       // Start time clock
                lapStart = time;
                lapTime = 0;            // Zero lap times
                bestLapTime = 0;
                lap = 1;                // First lap
                maxLap = 1;
            }
                        
            // Update remaining player parameters
            if (angleY <0)
                angleY += 2f*3.142f;
            if (angleY > 2f*3.142f)
                angleY -= 2f*3.142f;
            cosAngleY = (float)Math.cos(angleY);
            sinAngleY = (float)Math.sin(angleY);
            int px = (int)(1000f*playerX) & 0xffff;
            int pz = (int)(1000f*playerZ) & 0xffff;
            playerY = heightX[px] + heightZ[pz];

            // Modify terrain to include elliptical race track
            r = playerX*playerX/(KA*KA) + playerZ*playerZ/(KB*KB);           
            
            speed = 0.1f;     // In the rough
            if (r>94f && r<106f) {
                playerY = 0f;
                speed = 1f;   // Road + border
            } else if (r>85f && r<=94f) {
                playerY = playerY * (1f - (r - 85f)/9f);
                speed = 0.3f; // Bank
            } else if (r>=106f && r<115f) {
                playerY = playerY * (1f - (115f-r)/9f);
                speed = 0.3f; // Bank
            }
            playerY+=2;

            //
            // Draw Terrain
            //
            
            int s1, s2;
            int col = 0;
            for (int ray=0; ray<SCREENWIDTH; ray+=2) {
                                
                float rayAngle = angleY +
                    (float)Math.atan2((SCREENWIDTH/2 - ray),693f);
                float cosRayAngle = (float)Math.cos(rayAngle);
                float sinRayAngle = (float)Math.sin(rayAngle);
                
                int lsy = SCREENHEIGHT-1;
                
                // Time critical loop!
                for (int p0=1; p0<DEPTH; p0++) {
                    float p = zMap[p0];
                    x = playerX - sinRayAngle*p;
                    z = playerZ - cosRayAngle*p;
                    
                    // Detect Road
                    r = x*x/(KA*KA) + z*z/(KB*KB);
                                        
                    // Order the 'if' statements for maximum speed
                    if (r>97f && r<103f) { // on road
                        y = 0;
                        if (r>97.35f && r<102.65f) { // Carriageway
                            if (r>99.8f & r<100.2f) {
                                if (r>99.9f & r<100.1f)                              
                                    col = 0x010101*(int)(4f*p); // Tarmac
                                else  // Centre Lines
                                    col = 0xe0e000 - 0x010100*(int)(19f*p);
                            } else { // Tarmac
                                    col = 0x010101*(int)(4f*p);
                            }
                        } else { // Road Edge
                            if (r>97.25f && r<102.75) // Edge lines
                                col = 0xe0e0e0 - 0x010101*(int)(19f*p);
                            else
                                col = 0x010101*(int)(8f*p); // Tarmac
                        }
                    } else { // In the rough
                        int xx = (int)(1000f*x) & 0xffff;
                        int zz = (int)(1000f*z) & 0xffff;
                        if (r>94f && r<106f) { // on top bank
                            y = 0;
                        } else {
                            y = heightX[xx] + heightZ[zz];
                        }
                        s1 = (int)(4*p);
                        s2 = 40-s1;

                        col = 0x000300*s2 + 0x010101*s1;
                        if ((xx & 0x400) == 0)
                            col += 0x010101*(s2>>2);
                        if ((zz & 0x400) == 0)
                            col += 0x040100*(s2>>2);
                                                
                        if (r>85f && r<=94f) { // Bank
                            y = y * (1f - (r - 85f)/9f);
                        } else if (r>=106f && r<115f) { // Bank
                            y = y * (1f - (115f-r)/9f);
                        }
                    }
                                        
                    // Calculate screen position
                    int sy = SCREENHEIGHT/2 - (int)(20f*(y-playerY)/p);
                    if (sy<0)
                        sy = 0;
                    if (sy>SCREENHEIGHT-1)
                        sy = SCREENHEIGHT-1;
                    if (sy<lsy) {
                        int dst = ray+lsy*SCREENWIDTH;
                        for (i=lsy; i>sy; i--) {
                            screenData[dst] = screenData[dst+1] = col;
                            zBuffer[dst] = zBuffer[dst+1] = -p;
                            dst-=SCREENWIDTH;
                        }
                        lsy = sy;
                    }
 
                }
                // Draw sky
                int dst2 = ray+lsy*SCREENWIDTH;
                for (i=lsy; i>=0; i--) {
                    screenData[dst2] = screenData[dst2+1] =
                        0x200080 + 0x010101*(i/3);
                    zBuffer[dst2] = zBuffer[dst2+1] = -Float.MAX_VALUE;
                    dst2-=SCREENWIDTH;
                }
            }

            // Draw some trees
            for (int tree=0; tree<500; tree++) {
                float dx = treeX[tree] - playerX;
                float dy = treeY[tree] - playerY;
                float dz = treeZ[tree] - playerZ;
                
                // rotate
                float lx = cosAngleY*dx - sinAngleY*dz;
                float lz = sinAngleY*dx + cosAngleY*dz;
                s1 = (int)(-lz*4f);
                s2 = 40 - s1;
                col = 0x000100*s2 + 0x010101*s1;

                // project
                if (lz <0f && lz>-9f) {
                    int tx = SCREENWIDTH/2 + (int)(693f*(lx)/-lz);
                    int ty = SCREENHEIGHT/2 - (int)(20f*(dy)/-lz);
                    int size = (int)(200/-lz);
                    if (size <4) size = 4;
                    if (size>400) size = 400;
                    for (int w=0; w<size/4;w++) {
                        for (int h=0; h<size-w*4; h++) {
                            if ((tx+w)>=0 && (tx+w)<SCREENWIDTH &&
                                (ty-h)>=0 && (ty-h)<SCREENHEIGHT) {
                                if (zBuffer[tx+w+SCREENWIDTH*(ty-h)] < lz) {
                                    zBuffer[tx+w+SCREENWIDTH*(ty-h)] = lz;
                                    screenData[tx+w+SCREENWIDTH*(ty-h)] = col;
                                }
                            }
                            if ((tx-w)>=0 && (tx-w)<SCREENWIDTH &&
                                (ty-h)>=0 && (ty-h)<SCREENHEIGHT) {
                                if (zBuffer[tx-w+SCREENWIDTH*(ty-h)] < lz) {
                                    zBuffer[tx-w+SCREENWIDTH*(ty-h)] = lz;
                                    screenData[tx-w+SCREENWIDTH*(ty-h)] = col;
                                }
                            }
                        }
                    }
                }
            }
           
            // Move some cars about            
            float angle = (clock % 200000)/200000f*2f*3.142f;            
            for (int car=0; car<10;car+=2) {                
                // Back End
                carAngle[car] = angle + car/10f*2f*3.142f;
                carX[car] = -CARRADIUS1*KA*(float)Math.sin(carAngle[car]);
                carZ[car] = -CARRADIUS1*KB*(float)Math.cos(carAngle[car]);
                // Front End
                carAngle[car+1] = angle + car/10f*2f*3.142f + 0.00005f*
                    (float)Math.sqrt(carX[car]*carX[car]+carZ[car]*carZ[car]);
                carX[car+1] = -CARRADIUS1*KA*(float)Math.sin(carAngle[car+1]);
                carZ[car+1] = -CARRADIUS1*KB*(float)Math.cos(carAngle[car+1]);               
            }
            
            // Move cars the other way
            for (int car=10; car<20;car+=2) {                
                // Back End
                carAngle[car] = -angle + (car-10)/10f*2f*3.142f;
                carX[car] = -CARRADIUS2*KA*(float)Math.sin(carAngle[car]);
                carZ[car] = -CARRADIUS2*KB*(float)Math.cos(carAngle[car]);
                // Front End
                carAngle[car+1] = -angle + (car-10)/10f*2f*3.142f - 0.00005f*
                    (float)Math.sqrt(carX[car]*carX[car]+carZ[car]*carZ[car]);
                carX[car+1] = -CARRADIUS2*KA*(float)Math.sin(carAngle[car+1]);
                carZ[car+1] = -CARRADIUS2*KB*(float)Math.cos(carAngle[car+1]);                
            }
            
            // Draw vehicles
            for (int car=0; car<20; car++) {
                float dx = carX[car] - playerX;
                float dz = carZ[car] - playerZ;
                
                if (!gameOver && dx*dx+dz*dz < 0.01f) {
                    angleY+=(float)Math.random()/2f;
                    for (int b=0; b<SCREENWIDTH*SCREENHEIGHT; b++) {
                        screenData[b] = 0xff0000;
                    }
                }
                
                // rotate
                float lx = cosAngleY*dx - sinAngleY*dz;
                float lz = sinAngleY*dx + cosAngleY*dz;

                // Select front or back image

                // Calculate distance other image
                dx = carX[car^1] - playerX;
                dz = carZ[car^1] - playerZ;
                float lz2 = sinAngleY*dx + cosAngleY*dz;
               
                int img;
                if ((car & 1) == 0)
                    img = 0; // Back
                else
                    img = 1; // Front
                if (lz < lz2)
                    img = 2; // Shadow
                
                // project
                if (lz <0f && lz>-9f) {
                    int size = (int)(100f/(0.001f-lz));
                    if (size <4) size = 4;
                    if (size>400) size = 400;
                    int tx = SCREENWIDTH/2 + (int)(693f*(lx)/-lz) - size/2;
                    int ty = SCREENHEIGHT/2-(int)(20f*(-playerY)/-lz) - size/2;
                    for (int yy=0; yy<size/2;yy++) {
                        for (int xx=0; xx<size; xx++) {
                            int dst = tx + xx + SCREENWIDTH*(ty + yy);
                            if (tx+xx>=0 && tx+xx<SCREENWIDTH && ty+yy>=0 &&
                                ty+yy<SCREENHEIGHT) {
                                if (zBuffer[dst] < lz) {
                                    int src = (xx*32)/size+32*(8+(yy*32)/size);
                                    if (carData[img][src] != 0){
                                        zBuffer[dst] = lz;
                                        screenData[dst] = carData[img][src];
                                        }
                                }
                            }
                        }
                    }
                }
            }
                             
            //
            // User Interface
            //
            
            float lastPlayerZ = playerZ;
            if (!gameOver) {
                float gain = 3f*(1f-velocity*1000f) + 2f;
                if (keyUp) {
                    velocity+=TRANSLATESPEED*deltaTime;
                    gain *= 1.1f;
                }
                if (keyDown) {
                    velocity-=TRANSLATESPEED*deltaTime;
                    gain *= 0.9f;
                }
                velocity-=TRANSLATESPEED*deltaTime/10f;
                if (velocity < 0f) velocity =  0f;
                if (velocity > 0.0009f*speed) velocity = 0.0009f*speed;
                playerX -= sinAngleY*velocity*deltaTime;
                playerZ -= cosAngleY*velocity*deltaTime;

                if (keyLeft) {
                    if (steering < 0) steering = 0;
                    steering+=ROTATESPEED*deltaTime;
                } else
                if (keyRight) {
                    if (steering > 0) steering = 0;
                    steering-=ROTATESPEED*deltaTime;
                } else
                    steering = 0f;
                
                if (steering < -0.00005f) steering = -0.00005f;
                if (steering >  0.00005f) steering =  0.00005f;
                angleY+=steering*deltaTime*gain;

            }
            
            //
            // Misc game logic
            //

            // Detect level start
            if (gameOver && key == KeyEvent.VK_ENTER) {
                key = 0;
                reset = true;
                gameOver = false;
            }

            // Race time
            clock = (int)(time-startTime);
                
            // Wrong Way detector
            float xp = playerX*cosAngleY - playerZ*sinAngleY;
            
            // Lap detector
            if (lastPlayerZ*playerZ < 0 && playerX > 0) {
                // Update lap counter
                lap += (xp<0)?-1:1;
                if (lap > maxLap) {
                    if (lap == 11) {
                        gameOver = true;
                        lastClock = clock;
                    } else
                        maxLap++;
                    // Update lap time
                    lapTime = time - lapStart;
                    if (lapTime < bestLapTime || bestLapTime == 0)
                        bestLapTime = lapTime;
                    lapStart = time;
                }                
            }
            
            //
            // Draw Display
            //
                                   
            // Create overlay
            if (!gameOver && clock/1000 != lastClock/1000) {
                lastClock = clock;
                // Update score image
                for (i=0; i<SCREENWIDTH*30;i++)
                    scoreData[i] = 0; // Clear image
                Graphics g2 = scoreImage.getGraphics();
                g2.drawString("Time: "+lastClock/1000, 10, 20);
                g2.drawString("Last Lap: "+
                    (float)(lapTime/10)/100f, 160, 20);
                g2.drawString("Best Lap: "+
                    (float)(bestLapTime/10)/100f, 360, 20);
                g2.drawString("Lap: "+maxLap, 560, 20);
                g2.dispose();
            }
            
            // Copy score image to screen buffer 
            for (i=0; i<30*SCREENWIDTH; i++) {
                col = scoreData[i];
                if ((col & 0xffffff) != 0)
                    screenData[i] = col;
            }
            
            // Draw Speedometer
            x = (float)Math.sin((-velocity*200000-45f)*3.142f/180f);
            y = (float)Math.cos((-velocity*200000-45f)*3.142f/180f);
            for (i=0; i<36; i++) {
                screenData[580+(int)(36f*(float)Math.sin(i*3.142f/18f)) +
                    SCREENWIDTH*(420+(int)(36f*(float)Math.cos(i*3.142f/18f)))
                    ] = 0xffffff;
                screenData[580 + (int)(i*x) +
                    SCREENWIDTH*(420+(int)(i*y))] = 0xff0000;
            }

            g = getContentPane().getGraphics();
            g.drawImage(screen, 0, 0, null);            
            if (gameOver) {
                g.setColor(Color.white);            
                if (lap > 1)
                    g.drawString("Finish Time: "+(float)(lastClock/10)/100f,
                    SCREENWIDTH/2-55, SCREENHEIGHT/2);
                if (time % 1000 < 500)
                    g.drawString("Press ENTER to start",
                        SCREENWIDTH/2-60, SCREENHEIGHT/2+50);
            } else {
                if (xp<0f) {
                    g.setColor(Color.yellow);            
                    g.drawString("Wrong Way",
                        SCREENWIDTH/2-31, SCREENHEIGHT/2 );       
                }
            }
            g.dispose();
            
            // Yield to higher priority threads
//            try { Thread.sleep(41); } catch (Exception e) {};
            Thread.yield();
        }
        
        //
        // Exit Game
        //        
        System.exit(0);
    }
        
    /** Process Key Event */
    protected void processKeyEvent(KeyEvent e) {
        boolean pressed = (e.getID() != KeyEvent.KEY_RELEASED);
        key = 0;
        switch (e.getKeyCode()) {
            case KeyEvent.VK_LEFT:
                keyLeft = pressed;
                break;
            case KeyEvent.VK_RIGHT:
                keyRight = pressed;
                break;
            case KeyEvent.VK_UP:
                keyUp = pressed;
                break;
            case KeyEvent.VK_DOWN:
                keyDown = pressed;
                break;
            default:
                key = e.getKeyCode();
        }
    }

    /** Play Speed */
    public static void main(String[] args) {
        new G();        
    }    
}
