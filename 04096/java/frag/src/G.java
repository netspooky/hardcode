/*
 * Frag - Dungeon FPS
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

/** Frag */
public class G extends JFrame {
    
    private final static float ROTATESPEED     = 0.0002f;// Player rotate speed
    private final static float TRANSLATESPEED  = 0.00016f;// Player speed
    private final static float HEALTH          = 16000f; // Player health
    
    private final static int   MAZESIZE        = 10;     // Map size
    
    private final static int   NONE            = 0;      // Collision types
    private final static int   NWALL           = 1;      //  - North Wall
    private final static int   WWALL           = 2;      //  - West Wall
    private final static int   MONSTER         = 3;      //  - Monster
    
    private final static int   MONSTERS        = 10;     // Number of monsters
    private final static float MONSTERRADIUS   = 0.2f;   // Monster radius
    private final static float MONSTERSPEED    = 0.00005f;// Monster attack spd
    private final static long  MONSTERTIME     = 10000;  // Monster hunt time
    
    private final static int   DEAD            = 0;      // Monster States
    private final static int   IDLE            = 1;
    private final static int   ACTIVE          = 2;
 
    private boolean keyLeft, keyRight, keyUp, keyDown;   // Cursor keys pressed
    private boolean keySpace;                            // Keys pressed
    private int     key;   
    
    private boolean[][] nWall = new boolean[MAZESIZE][MAZESIZE]; // Maze walls
    private boolean[][] wWall = new boolean[MAZESIZE][MAZESIZE];
    private boolean[][] todo  = new boolean[MAZESIZE][MAZESIZE];
    
    private Random random = new Random();
    
    /** Creates a new instance of Frag */
    private G() {
        super("Frag");
  
        float playerX = 0;                          // Player position
        float playerZ = 0;                     
        float angleY = 0;                           // Player rotation
        float cosAngleY, sinAngleY;                 // Unit Vector
        int level = 1;                              // Level
        float health = HEALTH;                      // Player Health
        int score = 0;                              // Player Score
        boolean updateScore = true;                 // Update score due
        int firing = 0;                             // Player firing
        int hitSize = 0;                            // Explosion size
        boolean reset = true;                       // Game reset
        boolean levelOver = true;                   // Level over
       
        float[] monsterX = new float[MONSTERS];     // Monster positions
        float[] monsterZ = new float[MONSTERS];
        long[]  monsterSeen = new long[MONSTERS];   // Time last saw player
        int[]   monsterState = new int[MONSTERS];   // Monster state

        BufferedImage screen = null;                // Screen buffer
        int[] screenData = null;                    // Screen buffer data
        BufferedImage[] monster = new BufferedImage[2]; // Monster image
        int[][] monsterData = new int[2][];         // Monster image data
        BufferedImage scoreImage;                   // Score image
        int[] scoreData;                            // Score image data

        Graphics g;
        int width = 0;                              // Screen dimensions
        int height = 0;
        Color lightBlue = new Color(0,0,112);       // Colours
        Color midBlue   = new Color(0,0,96);
        Color darkBlue  = new Color(0,0,80);
        int x, y, z, m;
        
        //
        // Initialisation
        //
        
        // Create monster image
        for (m=0; m<2; m++) {
            monster[m] = new BufferedImage(32,32,BufferedImage.TYPE_INT_ARGB_PRE);
            monsterData[m] = ((DataBufferInt)monster[m].
                getRaster().getDataBuffer()).getData();
            for (x=0; x<1024; x++)              // Clear image to White
                monsterData[m][x] = 0;
            g = monster[m].getGraphics();
            // Head
            g.setColor(lightBlue);
            g.fillOval(0,0,32,10);
            g.setColor(midBlue);
            g.fillOval(0,1,32,10);
            g.setColor(darkBlue);
            g.fillOval(0,2,32,10);
            // Body
            g.fillOval(3,8,26,22);
            g.setColor(midBlue);
            g.fillOval(5,10,22,18);
            g.setColor(lightBlue);
            g.fillOval(7,12,18,14);
            for (x=-1; x<2; x+=2) {
                // Arms
                g.setColor(darkBlue);
                g.drawLine(16+x*10,16,16+x*2,20);
                g.drawLine(16+x*10,17,16+x*2,21);
                // Legs
                g.fillRect(14+x*6,27,4,(9+(2*m-1)*x)/2);
                // Eyes
                g.setColor(Color.yellow);
                g.fillRect(14+x*11,0,5,3);
                g.drawLine(13+x*11,1,19+x*11,1);                
                g.setColor(Color.black);
                g.drawLine(16+x*11,0,16+x*11,2);
            }
            // Mouth
            g.setColor(Color.red);
            g.drawLine(14,6,17,6);
            g.drawLine(10-m,7,21+2*m,7);
            g.drawLine(10,7+m,21,7+m);                
            g.dispose();
        }
                
        // Create score image (speeds up drawing)
        scoreImage = new BufferedImage(100,20, BufferedImage.TYPE_INT_RGB);
        scoreData =
            ((DataBufferInt)scoreImage.getRaster().getDataBuffer()).getData();
                       
        // Create Window
        setSize(640, 480);
        setIconImage(monster[0]);        
        show();

        // Enable Keyboard
        enableEvents(java.awt.AWTEvent.KEY_EVENT_MASK);
                
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
        
        while (isVisible()) {
            // Calculate frame time in 125 microsecond increments
            lastTime = time;
            time = System.currentTimeMillis();
            deltaTime = ((7*deltaTime)/8 + (time - lastTime));

            // Determine current animation image
            int animation = (int)((time/500) % 2);
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
                playerX = 0.5f;
                playerZ = 8.5f;
                angleY = 0f;
                // Initialise maze
                for (x=0; x<MAZESIZE; x++)
                    for (z=0; z<MAZESIZE; z++) {
                        nWall[x][z] = wWall[x][z] = todo[x][z] = true;
                    }
                random.setSeed(level);
                visit(0,8);
                // Create monsters avoiding player & other monsters
                todo[0][8] = true;
                for (m=0; m<MONSTERS; m++) {
                    do {
                        x = random.nextInt(MAZESIZE-1);
                        z = random.nextInt(MAZESIZE-1);
                    } while (todo[x][z]);
                    todo[x][z] = true;
                    monsterX[m] = x + 0.5f;
                    monsterZ[m] = z + 0.5f;
                    monsterState[m] = IDLE;
                }
            }
            
            // Update remaining player parameters
            cosAngleY = (float)Math.cos(angleY);
            sinAngleY = (float)Math.sin(angleY);
                        
            //
            // Draw Maze
            //
            
            // Create screen image (double buffer)
            x = getContentPane().getWidth();
            if (x < 400)
                x = 400;
            // For some reason, screen widths that are a multiple of 512
            // render very slowly. Adding 1 kludges around it.
            if ((x & 0x1ff) == 0) x++; // Kludge
            y = getContentPane().getHeight();
            if (y < 400)
                y = 400;
            if (x != width || y != height) {
                width = x;
                height = y;
                screen = new BufferedImage(width, height,
                    BufferedImage.TYPE_INT_RGB);
                screenData = ((DataBufferInt)
                    screen.getRaster().getDataBuffer()).getData();
            }
            
            // Initialise data on nearest collision in forward/back direction
            float fwdCollisionRange2 = Float.MAX_VALUE;
            int   fwdCollisionType = NONE;
            int   fwdEnemyNumber = 0;
            float fwdEnemyZ = 0;
            float bckCollisionRange2 = Float.MAX_VALUE;
            
            // Do ray casting
            for (int ray=0; ray<width; ray++) {
                
                // Initialise data on nearest obstruction
                float obstructionRange2 = Float.MAX_VALUE;
                float obstructionX = 0f;
                float obstructionZ = 0f;
                int   obstructionType = NONE;

                // Calculate ray x and z components
                
                // angleY = 0 is looking along -ve Z axis
                // angleY increases as player turns to the left
                // ray = 0 is the left edge of the screen
                
                // For a unit vector along the ray:
                // cosRayAngle is component along -ve z axis
                // sinRayAngle is component along -ve x axis
                
                // Using 'ray' for the x coordinate is an approximation
                // since this is proportion to the angle, while we really
                // need sin(angle).  However, it is good enough provided
                // we limit the angle to +/-30 degrees.
                
                float rayAngle = angleY + (width/2f - ray)/width;
                float cosRayAngle = (float)Math.cos(rayAngle);
                float sinRayAngle = (float)Math.sin(rayAngle);
                
                // Look for intersections in maze rows (north walls)
                if (cosRayAngle != 0f) {
                    // Gradient x/z
                    float gradient = sinRayAngle/cosRayAngle;
                    for (z=0; z<MAZESIZE; z++) {
                        // X intersect at x = az + c
                        float dz = z-playerZ;
                        float dx = gradient*dz;
                        
                        // Check that the intersection is in front of us
                        x = (int)(playerX+dx);
                        if (x>=0 && x<MAZESIZE && nWall[x][z]) {
                            // The ray hit a wall
                            float distance2 = dx*dx + dz*dz;
                            // Use dot product to determine if ray is in view
                            if (sinAngleY*dx+cosAngleY*dz < 0f){ // In view
                                if (distance2 < obstructionRange2) {
                                    obstructionX = dx;
                                    obstructionZ = dz;
                                    obstructionRange2 = distance2;
                                    obstructionType = NWALL;
                                    if (ray == width/2) { // Forward ray
                                        fwdCollisionRange2 = distance2;
                                        fwdCollisionType = NWALL;
                                    }
                                }
                            } else if (ray == width/2  &&
                                       distance2 < bckCollisionRange2) {
                                // Back ray
                                bckCollisionRange2 = distance2;
                            }
                        }
                    }
                }
                
                // Look for intersections in maze columns (west walls)
                if (sinRayAngle != 0f) {
                    float gradient = cosRayAngle/sinRayAngle;
                    for (x=0; x<MAZESIZE; x++) {
                        // Y intersect at y = ax + c
                        float dx = x-playerX;
                        float dz = gradient*dx;
                        
                        // Check that the intersection is in front of us
                        z = (int)(playerZ+dz);
                        if (z>=0 && z<MAZESIZE && wWall[x][z]) {
                            // The ray hit a wall
                            float distance2 = dx*dx + dz*dz;
                            // Use dot product to determine if ray is in view
                            if (sinAngleY*dx+cosAngleY*dz < 0f){ // In view
                                if (distance2 < obstructionRange2) {
                                    obstructionX = dx;
                                    obstructionZ = dz;
                                    obstructionRange2 = distance2;
                                    obstructionType = WWALL;
                                    if (ray == width/2) { // Foward ray
                                        fwdCollisionRange2 = distance2;
                                        fwdCollisionType = WWALL;
                                    }
                                }
                            } else if (ray == width/2  &&
                                       distance2 < bckCollisionRange2) {
                                // Back ray
                                bckCollisionRange2 = distance2;
                            }
                        }
                    }
                }

                // Rotate ray unit vector into the viewing plane
                // and calculate gradient = rx/rz                
                float gradient =
                    (cosAngleY*-sinRayAngle - sinAngleY*-cosRayAngle) / // rx
                    (sinAngleY*-sinRayAngle + cosAngleY*-cosRayAngle);  // rz             

                // Look for collisions with Monsters
                float enemyRange2 = obstructionRange2;
                float enemyZ = 0f;
                float enemyR = 0f;
                int   enemyType = NONE;
                
                for (m=0; m<MONSTERS; m++) {
                    
                    // The monster is an always facing sprite
                    // centred on it's nominal location.
                    
                    // First find relative x,z to the monster
                    float dx = monsterX[m]-playerX;
                    float dz = monsterZ[m]-playerZ;
                    
                    // Now rotate this into the viewing plane
                    float lz = sinAngleY*dx + cosAngleY*dz;
                                   
                    // Determine where ray intersects lz
                    float xi = gradient * lz;
                    
                    // Determine column of sprite
                    float r = cosAngleY*dx - sinAngleY*dz - xi;
                    
                    // Only in view if we are within the radius
                    if (r*r < MONSTERRADIUS*MONSTERRADIUS &&
                        monsterState[m] > DEAD) {
                        
                        // Rotate back into world model
                        dx =  cosAngleY*xi + sinAngleY*lz;
                        dz = -sinAngleY*xi + cosAngleY*lz;

                        // Check that the intersection is in front of us                        
                        // Use dot product to determine if ray is in view
                        float distance2 = dx*dx + dz*dz;
                        if (sinAngleY*dx+cosAngleY*dz < 0f){ // In view
                            if (distance2 < enemyRange2) {
                                enemyZ = lz;
                                enemyR = r;
                                enemyRange2 = distance2;
                                enemyType = MONSTER;
                                monsterState[m] = ACTIVE;
                                monsterSeen[m] = time;
                                if (ray == width/2  && // Foward ray
                                    distance2 < fwdCollisionRange2) {
                                    fwdCollisionRange2 = distance2;
                                    fwdCollisionType = MONSTER;
                                    fwdEnemyNumber = m;
                                    fwdEnemyZ = lz;
                                }
                            }
                        } else if (ray == width/2  &&
                                   distance2 < bckCollisionRange2) {
                            // Back ray
                            bckCollisionRange2 = distance2;
                            monsterState[m] = ACTIVE;
                            monsterSeen[m] = time;
                        }
                    }
                }
                
                // Draw walls
                int h0, h1, scale, dst;
                if (obstructionType != NONE) {                    
                    // When angleY = 0, we look down the -ve Z axis
                    // When angleY = 90, we look down the -ve X axis
                    float obsZ = sinAngleY*obstructionX+cosAngleY*obstructionZ;                    
                    if (obsZ < 0f) {                                
                        
                        // Overall Wall colour and x wall position
                        
                        int w, wx;
                        if (obstructionType == NWALL) {
                            w =  (int)(playerX+obstructionX);
                            wx = (int)(16f*((playerX+obstructionX) - w));
                        } else {
                            w =  (int)(playerZ+obstructionZ);
                            wx = (int)(16f*((playerZ+obstructionZ) - w));
                        }
                        w = w % 8;

                        
                        // Wall y segments 0 - 15
                        // Add a small offset to prevent integer overflow later
                        scale = (int)(width/(0.01f-4*obsZ));
                        for (int wy=0; wy<16; wy++) {
                            h1 = height/2 + scale - wy    *scale/8;
                            h0 = height/2 + scale - (wy+1)*scale/8;
                            if (h1 > height-1)
                                h1 = height-1;
                            if (h0 < 0)
                                h0 = 0;
                            
                            int colour =
                                (((wy*wx) % ( 4 + 12*(level % 2)))<<19) + // R
                                (((wy*wx) % (16 - 12*(level % 2)))<<11) + // G
                                ((w/2 + (wy*wx) % 4)<<3);                 // B
                            
                            dst = ray + h0*width;
                            for (y=h0; y<h1; y++) {
                                screenData[dst] = colour;
                                dst += width;
                            }
                        }
                        
                        // Draw Ceiling and Floor
                        h0 = ray+height/2*width;
                        h1 = h0-width;
                        for (y=scale*width; y<height/2*width; y+=width) {
                            screenData[h1 - y] = 0x00802020; // Ceiling RGB
                            screenData[h0 + y] = 0x00201008; // Floor RGB
                        }
                    }
                }
                
                // Draw monster
                if (enemyType != NONE && obstructionRange2 > enemyRange2) {
                    // Add a small offset to prevent integer overflow later
                    scale = (int)(width/(0.01f-2*enemyZ));                   
                    int colour = (16+(int)(enemyR*16f/MONSTERRADIUS));
                    
                    // Draw one line from monster image
                    if (colour>=0 && colour<32 && enemyZ < 0f) {
                        int top = height/2 - scale/2;
                        int bottom = height/2 + scale/2;
                        h0 = (top>0)?0:-top;
                        h1 = (bottom<height)?scale:height-top;
                        dst = ray + width*(h0+top);
                        for (int dy=h0; dy<h1; dy++) {
                            int src = colour + 32*((dy*32)/scale);
                            int data = monsterData[animation][src];
                            if (data !=0)
                                screenData[dst] = data;
                            dst +=width;
                        }
                    }
                }
            }

            //
            // User Interface
            //
            
            if (!levelOver) {
                if (keyLeft)
                    angleY+=ROTATESPEED*deltaTime;

                if (keyRight)
                    angleY-=ROTATESPEED*deltaTime;

                float travel = TRANSLATESPEED*deltaTime;
                if (keyUp && travel*travel < fwdCollisionRange2) {
                    // When AngleY = 0, forward is -ve z axis
                    // When AngleY = 90, forward is -ve x axis
                    playerX -= sinAngleY*travel;
                    playerZ -= cosAngleY*travel;
                }
                if (keyDown && travel*travel < bckCollisionRange2) {
                    playerX += sinAngleY*travel;
                    playerZ += cosAngleY*travel;
                }
                if (keySpace) {
                    if (firing == 0) {
                        if (fwdCollisionType == MONSTER) {
                            monsterState[fwdEnemyNumber] = DEAD;
                            score+=10;
                            updateScore = true;
                            // Ensure hitSize < height/2
                            hitSize = (int)(height/8f/(0.26f-fwdEnemyZ));
                        }
                    }
                    if (firing < 800) {
                        // Draw gun fire
                        for (z=0; z<height/2; z++) {
                            int t = width/2 + (z>>2) + width*(height/2+z);
                            screenData[t] = 0xffff00;
                            if (z>75)
                                screenData[t-1]= 0xffff00;
                            if (z>125)
                                screenData[t+1]= 0xffff00;
                        }
                        // Draw Explosion
                        int size = (hitSize*firing)/800;
                        for (y=0; y<size; y++ )
                            for (x=y-size; x<size-y; x++) {
                                screenData[width/2+x + (height/2+y)*width]
                                    = 0xff0000;
                                screenData[width/2+x + (height/2-y)*width]
                                    = 0xff0000;
                            }
                        firing+=deltaTime;
                    }
                } else {
                    firing = 0;
                    hitSize = 0;
                }
            }
            
            //
            // Draw Mini-map
            //
            
            // Draw walls
            int xo = 45-(int)(16*playerX);
            int zo = 45-(int)(16*playerZ);
            for (z=0; z<MAZESIZE; z++) {
                for (x=0; x<MAZESIZE; x++) {
                    if (nWall[x][z] && x<MAZESIZE-1) {
                        int zz = zo+16*z;
                        for (int xx = xo+16*x; xx<xo+16*(x+1); xx++)
                            if (xx>20 && xx<70 && zz>20 && zz<70)
                                screenData[xx+width*zz] = 0xffffff;
                    }
                    if (wWall[x][z] && z<MAZESIZE-1) {
                        int xx = xo+16*x;
                        for (int zz = zo+16*z; zz<zo+16*(z+1); zz++)
                            if (xx>20 && xx<70 && zz>20 && zz<70)
                                screenData[xx+width*zz] = 0xffffff;                        
                    }
                }
            }
            
            // Draw player position
            for (z=44; z<47; z++)
                for (x=44; x<47; x++)
                    screenData[x+width*z] = 0x00ff00;
            
            // Draw player directional indicator
            screenData[45-(int)(2.999f*sinAngleY) +
                width*(45-(int)(2.999f*cosAngleY))] = 0x00ff00;
              
            //
            // Monster logic
            //
            
            // Active Monsters move directly towards player
            // Monsters must clear walls by 0.2f            
            float move = deltaTime*MONSTERSPEED*(1f+level/2f);
            for (m=0; m<MONSTERS; m++) {
                if (monsterState[m] == ACTIVE &&
                    time-monsterSeen[m]> MONSTERTIME)
                    monsterState[m] = IDLE;
                
                float dx = monsterX[m]-playerX;
                float dz = monsterZ[m]-playerZ;
                if (monsterState[m] == ACTIVE) {
                    // Damage player if close, otherwise move
                    if (dx*dx+dz*dz<MONSTERRADIUS*MONSTERRADIUS) {
                        health-=deltaTime;
                    } else {
                        x = (int)monsterX[m];
                        z = (int)monsterZ[m];
                        float f, mon;

                        // Move in X
                        f = monsterZ[m] - (int)monsterZ[m];
                        if (monsterX[m] > playerX) {
                            mon = monsterX[m] - move;
                            if ((mon-(int)mon > 0.2f || !wWall[x][z]) &&
                                 f > 0.2f && f < 0.8f)
                                monsterX[m] = mon;                        
                        }
                        if (monsterX[m] < playerX) {
                            mon = monsterX[m] + move;
                            if ((mon-(int)mon < 0.8f || !wWall[x+1][z]) &&
                                 f > 0.2f && f < 0.8f)
                                monsterX[m] = mon;                        
                        }

                        // Move in Z
                        f = monsterX[m] - (int)monsterX[m];
                        if (monsterZ[m] > playerZ) {
                            mon = monsterZ[m] - move;
                            if ((mon-(int)mon > 0.2f || !nWall[x][z]) &&
                                 f > 0.2f && f < 0.8f)
                                monsterZ[m] = mon;                        
                        }
                        if (monsterZ[m] < playerZ) {
                            mon = monsterZ[m] + move;
                            if ((mon-(int)mon < 0.8f || !nWall[x][z+1]) &&
                                 f > 0.2f && f < 0.8f)
                                monsterZ[m] = mon;                        
                        }
                    }            
                }
                
                // Display Monsters on Mini-Map
                int mx = 45+(int)(16*(monsterX[m]-playerX));
                int mz = 45+(int)(16*(monsterZ[m]-playerZ));
                if (monsterState[m] != DEAD) {
                    int colour = (monsterState[m] == IDLE)?0xffff00:0xff0000;
                    for (z=mz; z<mz+2; z++)
                        for (x=mx; x<mx+2; x++)
                            if (x>20 && x<70 && z>20 && z<70)
                                screenData[x+width*z] = colour;
                }
            }
            
            //
            // Start/End Level logic
            //

            // Detect level start
            if (key == KeyEvent.VK_ENTER && levelOver) {
                reset = true;
                if (score == 0 || health == 0) {
                    level = 1;
                    health = HEALTH;
                    score = 0;
                    updateScore = true;
                } else
                    level++;
                levelOver = false;
            }
            
            // Detect level over
            if (score % 200 == 100) {
                score += 100;
                levelOver = true;
            }
            if (health <= 0) {
                health = 0;
                levelOver = true;
            }
            
            //
            // Display overlay
            //

            // Display score
            if (updateScore) {
                // Update score image
                updateScore = false;
                for (x=0; x<2000; x++)
                    scoreData[x] = 0; // Clear image
                Graphics g2 = scoreImage.getGraphics();
                g2.drawString(""+score,0,20);
                g2.dispose();
            }
            // Copy score image to screen buffer 
            for (z=0; z<20; z++)
                for (x=0; x<100; x++) {
                    int colour = scoreData[x+100*z];
                    if ((colour & 0xffffff) != 0)
                        screenData[125+x+width*(10+z)] = colour;
                }
            
            // Display health
            m = width - 150 + (int)(100f*health/HEALTH);
            for (z=20; z<30; z++)
                for (x=width - 150; x<m; x++)
                    screenData[x+width*z] = 0x00ff00;

            // Display level over
            if (levelOver) {
                g = screen.getGraphics();                
                // Start message
                if (time % 1000 < 500)
                    g.drawString("Press ENTER to start",
                        width/2-59, height/2+50);
                // Display game over or current level
                if (health <= 0)
                    g.drawString("Game Over", width/2 - 31, height/2 );
                else
                    g.drawString("Level "+((score > 0)?level+1:1),
                        width/2-20,height/2);
                g.dispose();
            }
            
            //
            // Draw Display Buffer
            //
            
            g = getContentPane().getGraphics();
            g.drawImage(screen, 0, 0, null);
            g.dispose();
            
            // Yield to higher priority threads
//            try { Thread.sleep(10); } catch (Exception e) {};
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
        switch (key = e.getKeyCode()) {
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
            case KeyEvent.VK_SPACE:
                keySpace = pressed;
            default:
        }
    }
    
    /** Recursive depth first maze creation algorithm */
    private void visit(int x, int y) { 
        // Mark this cell as visited
        todo[x][y] = false;
        // Look at the four surrounding cells in random order
        boolean[] triedSide = new boolean[4];
        for (int s=0; s<4; s++)
            triedSide[s] = false;
        int sides = 4;
        int currentSide;
        while (sides-- > 0) {
            do {
                currentSide = random.nextInt(4);
            } while (triedSide[currentSide]);
            triedSide[currentSide] = true;
            
            // If adjacent cell hasn't yet been visited then open a passage
            // and then recursively visit that cell (i.e. Depth first)
            switch (currentSide) {
                case 0: // North
                    if (y > 0 && todo[x][y-1]) {
                        nWall[x][y] = false;
                        visit(x, y-1);
                    }
                    break;
                case 1: // West
                    if (x > 0 && todo[x-1][y]) {
                        wWall[x][y] = false;
                        visit(x-1, y);
                    }
                    break;
                case 2: // South
                    if (y < MAZESIZE-2 && todo[x][y+1]) {
                        nWall[x][y+1] = false;
                        visit(x, y+1);
                    }
                    break;
                case 3: // East
                    if (x < MAZESIZE-2 && todo[x+1][y]) {
                        wWall[x+1][y] = false;
                        visit(x+1, y);
                    }                   
            }
        }
    }
        
    /** Play Frag */
    public static void main(String[] args) {
        new G();        
    }    
}
