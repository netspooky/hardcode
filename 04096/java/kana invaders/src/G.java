/*
 * Kana Invaders
 *
 * Created on 10 December 2005, 23:49
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
import java.awt.Image;
import javax.swing.JFrame;
import java.awt.image.BufferStrategy;

public class G extends JFrame {

    private final static int   SCREENHEIGHT   = 400;    // Screen height
    private final static int   SCREENWIDTH    = 400;    // Screen width
    
    private final static int   ROWS           = 5;      // Invader columns
    private final static int   COLS           = 10;     // Invader columns
    private final static int   HSPACE         = 30;     // Invader Hoz  spacing
    private final static int   VSPACE         = 30;     // Invader Vert spacing
    private final static int   HSIZE          = 24;     // Invader hoz  size
    private final static int   VSIZE          = 21;     // Invader vert size
    private final static float INVSPEED       = 0.1f;  // Invader speed
    
    private final static int   PLAYERY        = 340;    // Player Y position
    private final static int   LIVES          = 15;     // Player Lives
    private final static float PLAYERSPEED    = 0.2f;   // Playerspeed
    
    private final static float MISSILESPEED   = 0.1f;   // Playerspeed
    private final static int   MISSILES       = 10;     // Missile Number

    private boolean keyLeft, keyRight, keySpace;        // Keys pressed
    
    private int vowel;
    private int consenant;
    private int hiragana = -1;
    private int lastKey = 0;

    /** Creates a new instance of G */
    public G() throws Exception { 
        super("Kana Invaders");
        // Missiles
        float[] playerMissileX = new float[MISSILES];  // Player Missiles
        float[] playerMissileY = new float[MISSILES];
        float[] invaderMissileX = new float[MISSILES]; // Invader Missiles
        float[] invaderMissileY = new float[MISSILES];
        
        // Invaders
        boolean[][] alive = new boolean[COLS][ROWS+1];

        // Game state
        float invaderX = 0;                     // Invader Position
        float invaderY = 100;        
        float speed = INVSPEED;                 // Invader speed        
        int nextInvaderX = 0;                   // Next Invader to fire
        float playerX = (SCREENWIDTH-HSIZE)/2;  // Player Position
        int playerLives = LIVES;                   // Player Lives        
        int level = 0;                          // Game level
        int score = 0;                          // Player score
        boolean gameOver = true;                // No player interaction
        boolean reset = true;                   // Game reset due;
        
        // Initialise timing
        long time = System.currentTimeMillis();
        long lastTime;
        long deltaTime = 0;                     // 125u resolution
        long playerFireTime = time;
        long invaderFireTime = time;
        
        // Initialise graphics
        int row, col, i;
        Image img = getToolkit().createImage(getClass().getResource("d"));
        setResizable(false);
        setSize(SCREENWIDTH, SCREENHEIGHT);
        show();
        createBufferStrategy(2);
        BufferStrategy strategy = getBufferStrategy();

        // Enable Keyboard
        enableEvents(java.awt.AWTEvent.KEY_EVENT_MASK);

        while (isVisible()) {
            // Calculate frame time in 125 microsecond increments
            lastTime = time;
            time = System.currentTimeMillis();
            deltaTime = time - lastTime;
            
            if (reset) {
                reset = false;
                invaderX = 0f;
                invaderY = 100f;
                speed = INVSPEED;
                vowel = 0;
                consenant = -1;
                for (row=0; row<ROWS+level/8; row++) {
                    for (col=0; col<COLS; col++)
                        alive[col][row] = true;
                }               
                for (i=0; i<MISSILES; i++) {
                    playerMissileY[i] = -1f;
                    invaderMissileY[i] = SCREENHEIGHT;
                }               
            }
            
            //
            // Move Invaders
            //
            
            int leftInvader  = COLS;
            int rightInvader = -1; 
            nextInvaderX++;
            nextInvaderX %= COLS;
            for (row=ROWS+level/8-1; row>=0; row--) {
                               
                // Invaders firing
                if (alive[nextInvaderX][row] &&
                    invaderFireTime+500 < time) {
                    for (i=0; i<MISSILES; i++) {
                        if (invaderMissileY[i] >= SCREENHEIGHT) {
                            invaderFireTime = time;
                            invaderMissileX[i] = invaderX +
                                nextInvaderX*HSPACE+HSIZE/2;
                            invaderMissileY[i] = invaderY +
                                row*VSPACE + VSIZE;  
                            break;
                        }
                    }
                }
                
                // Check live invaders
                for (col=0; col<COLS; col++) {
                    // Find left and right most invaders
                    if (alive[COLS-col-1][row] && leftInvader > COLS-col-1)
                        leftInvader = COLS-col-1;
                    if (alive[col][row] && rightInvader < col) {
                        rightInvader = col;
                    
                        // Check if collided with player
                       if (playerX+VSIZE > invaderX+col*HSPACE &&
                            playerX < invaderX+col*HSPACE+HSIZE &&
                            PLAYERY < invaderY+row*VSPACE+VSIZE)
                           gameOver = true;
                    }
                }
            }
           
            // Detect when fully left and change direction
            if (invaderX+deltaTime*speed + HSPACE*leftInvader < 0 ) {
                speed *= -1f;
                if (!gameOver)
                    invaderY +=2;                
            // Detect when fully right and change direction
            } else if (invaderX+deltaTime*speed +
                HSPACE*rightInvader+HSIZE > SCREENWIDTH ) {
                speed *= -1f;
                if (!gameOver)
                    invaderY +=2;                
            // Otherwise move invader
            } else
                invaderX += deltaTime*speed;
                
            //
            // Move Player
            //
            
            if (!gameOver) {
                if (keyLeft)
                    playerX -= deltaTime*PLAYERSPEED;
                if (keyRight)
                    playerX += deltaTime*PLAYERSPEED;
                if (playerX < 0f)
                    playerX = 0;
                if (playerX > SCREENWIDTH - HSIZE)
                    playerX = SCREENWIDTH - HSIZE;
                if (keySpace && playerFireTime+300 < time) {
                    // Create new missile
                    for (i=0; i<MISSILES; i++) {
                        if (playerMissileY[i] < 0f) {
                            playerFireTime = time;
                            playerMissileX[i] = playerX+HSIZE/2;
                            playerMissileY[i] = PLAYERY;
                            break;
                        }
                    }
                }
            }

            //
            // Move missiles
            //
            
            for (i=0; i<MISSILES; i++) {                
                if (playerMissileY[i] > 0f)
                    playerMissileY[i] -= deltaTime*MISSILESPEED;
                if (invaderMissileY[i] < SCREENHEIGHT)
                    invaderMissileY[i] += deltaTime*MISSILESPEED;            
                // Check for invader collisions
                for (col=0; col<COLS; col++) {
                    for (row=0; row<ROWS+level/8; row++) {
                        if (alive[col][row]) {
                            if (playerMissileX[i] > invaderX+col*HSPACE &&
                                playerMissileX[i] < invaderX+col*HSPACE+HSIZE &&
                                playerMissileY[i] > invaderY+row*VSPACE &&
                                playerMissileY[i] < invaderY+row*VSPACE+VSIZE) {
                                    // Invader killed
                                    if (ROWS*level+row == hiragana) {
                                        alive[col][row] = false;
                                        score +=10;
                                        speed *=1.02f;
                                    }
                                    playerMissileY[i] = -1f;
                            }
                        }
                    }
                }                 
                // Check player for missile collisions
                if (invaderMissileX[i] > playerX &&
                    invaderMissileX[i] < playerX+HSIZE &&
                    invaderMissileY[i] > PLAYERY &&
                    invaderMissileY[i] < PLAYERY+VSIZE) {
                        // Player Life lost
                        if (playerLives > 0)
                            playerLives--;
                        invaderMissileY[i] = SCREENHEIGHT;
                }
            }

            //
            // Level Logic
            //
            
            // Detect level complete
            if (rightInvader < 0) {
                level = (level+1) % 9;  // Wrap back to first level
                reset = true;
            }
            
            // Detect game over
            if (playerLives == 0)
                gameOver = true;
            
            // Start game
            if (gameOver && lastKey == KeyEvent.VK_ENTER) {
                lastKey = 0;
                level = 0;
                playerLives = LIVES;
                reset = true;
                playerX = (SCREENWIDTH-HSIZE)/2;
                gameOver = false;
            }
                            
            //
            // Draw screen
            //
            
            // Clear screen
            Graphics g = strategy.getDrawGraphics();
            g.setColor(Color.black);
            g.fillRect(0,0,SCREENWIDTH,SCREENHEIGHT);
            
            // Draw invaders
            // There are some OS X bugs in drawImage to work around
            // - setting the background colour doesn't work
            // - Compositing blue seems unreliable
            g.setColor(Color.green);    // Kludge for OS X
            for (row=0; row<ROWS+level/8; row++) {
                for (col=0; col<COLS; col++) {
                    if (alive[col][row]) {
                        g.fillRect(     // Kludge for OS X
                            (int)invaderX+HSPACE*col,
                            (int)invaderY+VSPACE*row,
                            HSIZE, VSIZE);
                        g.drawImage(img,
                            (int)invaderX+HSPACE*col,
                            (int)invaderY+VSPACE*row,
                            (int)invaderX+HSPACE*col+HSIZE,
                            (int)invaderY+VSPACE*row+VSIZE,
                            HSIZE*(row+ROWS*level),    0,
                            HSIZE*(row+ROWS*level+1),  VSIZE,
                            Color.green, 
                            null);
                    }
                }
            }
                        
            // Draw player
            g.setColor(Color.orange);   // Kludge for OS X - blue is faulty
            g.fillRect(                 // Kludge for OS X
                (int)playerX, PLAYERY, HSIZE, VSIZE);
            g.drawImage(img,
                (int)playerX, PLAYERY, (int)playerX+HSIZE, PLAYERY+VSIZE,
                HSIZE*46, 0, HSIZE*47, VSIZE,
                Color.blue,
                null);
            
            // Draw missiles
            g.setColor(Color.red);
            for (i=0; i<MISSILES; i++) {
                if (invaderMissileY[i] < SCREENHEIGHT)
                    g.fillRect((int)invaderMissileX[i],
                               (int)invaderMissileY[i]-5, 1, 5);
            }
            g.setColor(Color.orange);
            for (i=0; i<MISSILES; i++) {
                if (playerMissileY[i] > 0)
                    g.fillRect((int)playerMissileX[i],
                               (int)playerMissileY[i], 1, 5);
            }
           
            // Draw current bullet type
            if (hiragana != -1) {
                g.setColor(Color.orange);     // Kludge for OS X
                g.fillRect(                   // Kludge for OS X
                    10, 60, HSIZE, VSIZE);
                g.drawImage(img,
                    10, 60, 10+HSIZE, 60+VSIZE,
                    HSIZE*hiragana, 0, HSIZE*(hiragana+1), VSIZE,
                    Color.orange,
                    null);
            }
            
            // Draw Lives
            for (i=0; i<playerLives; i++) {
                g.fillRect(SCREENWIDTH-i*8-20, 65, 2, 5);
                g.fillRect(SCREENWIDTH-i*8-22, 70, 6, 5);
            }
            
            // Draw Score
            g.drawString(""+score, 60, 75);
            
            // Game Over
            if (gameOver) {
                g.drawString("Game Over", 170, 200);
                if (time % 1000 < 500)
                    g.drawString("Press ENTER", 162, 240);
            }
            
            // Swap display buffers
            strategy.show();
            g.dispose();
            Thread.sleep(10);            
        }
        System.exit(0);
    }

    /** Process Key Event */
    protected void processKeyEvent(KeyEvent e) {
        int key, i;
        final int[] vowels = { 'A', 'I', 'U', 'E', 'O' };
        final int[] consenants = {
            'K', 'S', 'T', 'N', 'H', 'M', 'R', 'Y', 'W' };
        // Map Ya Yu Yo Wa Wo onto font
        final int[] map = {43, 1, 44, 3, 45, 41, 1, 2, 3, 42 };
        
        switch (key = e.getKeyCode()) {
            // Game Controls
            case KeyEvent.VK_LEFT:
                keyLeft = (e.getID() != KeyEvent.KEY_RELEASED);
                break;
            case KeyEvent.VK_RIGHT:
                keyRight = (e.getID() != KeyEvent.KEY_RELEASED);
                break;
            case KeyEvent.VK_SPACE:
                keySpace = (e.getID() != KeyEvent.KEY_RELEASED);
                break;
            default:
                // Hiragana Selection
                if (e.getID() == KeyEvent.KEY_RELEASED) {
                    // Special Key combos
                    if (key == 'H' && lastKey == 'S') // shi
                        key = 0;
                    if (key == 'S' && lastKey == 'T') // tsu
                        key = 0;
                    if (key == 'H' && lastKey == 'C') // chi
                        key = 'T';
                    if (key == 'F') // fu
                        key = 'H';
                    lastKey = key;

                    // Vowels
                    for (i=0; i<vowels.length; i++)
                        if (key == vowels[i]) {
                            if (vowel != -1)
                                consenant = 0;
                            vowel = i;
                        }
                    
                    // Consenants    
                    for (i=0; i<consenants.length; i++)
                        if (key == consenants[i]) {
                            vowel = -1;
                            consenant = i+1;
                        }
                    
                    // Map vowel+consenant onto font
                    if (vowel == -1 && consenant == 4) // n
                        hiragana = 40;
                    else if (vowel != -1 && consenant != -1 && key !='C') {
                        hiragana = vowel + 5*consenant;
                        if (hiragana >= 40)
                            hiragana = map[hiragana-40];
                    } else
                        hiragana = -1;
            }
        }
    }

    /** Play Kana Invaders */
    public static void main(String[] args) throws Exception {
        new G();
    }
    
}
