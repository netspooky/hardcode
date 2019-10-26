import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.util.*;
import java.awt.image.*;

public class M extends JFrame {
   
  boolean[] K = new boolean[65535]; // pressed keys
 
  public M() {
    
    //final int FRAME_RATE = 35;
    //final int ITERATIONS = 16;
    final double FREEDOM = 32;
    final double FREEDOM_2 = FREEDOM * FREEDOM;
    final double TERMINAL_V = 48;
    final double TERMINAL_V2 = TERMINAL_V * TERMINAL_V;
    final double SMASH_V2 = 1600;
    final double RECIP_320 = 1 / 320.0;
    final double RECIP_240 = 1 / 240.0;
    final double G = 20;
    final double DT = 0.01;
    final double DAMP = 0.9982;
    final double HALF_PI = 0.5 * Math.PI;
    final Color DUST = new Color(0x26873e);
    
    Random random = new Random();
    int[] screenBuffer = new int[320*240];
    int[][] background = new int[240][320];
    int[][][] tiles = new int[32][32][32];
    int[] ballData = new int[16*16];
    int[][] boardMap = new int[64][64];
    BufferedImage[] balls = new BufferedImage[32];
    double[][] sparkles = new double[256][4];
    double[][] ballEdges = new double[64][2];
    double boardX = 0, boardY = 0, boardAngle = 0;
    double ballX = 0, ballY = 0;
    double ballVx = 0, ballVy = 0;
    double ballAx = 0, ballAy = 0;
    int time = 0;
    int level = 0;
    int zooming = 0;
    int levelState = 2;
    double zoom = 0;
    double startX = 0, startY = 0;
    int ouch = 0;
    int smashX = -1, smashY = 0;
    int smashing = 0;
    boolean playing = true;
    int down = 0;
    
    for(int i = 0; i < ballEdges.length; i++) {
      double angle = i * 2.0 * Math.PI / ballEdges.length;
      ballEdges[i][0] = 8 * Math.cos(angle);
      ballEdges[i][1] = 8 * Math.sin(angle);
    }
           
//-- GENERATE SPRITES AND TILES BEGIN ------------------------------------------
    
    for(int i = 0; i < 32; i++) {
      for(int j = 0; j < 32; j++) {
        int dx = j - 15, dy = i - 15;
        int dist = dx*dx + dy*dy;
        int color = C(300 - (int)(Math.sqrt(dist + 64)*6), 
            92 + random.nextInt(8), 255);                
        tiles[1][i][j] = color;
        tiles[2][i][j] = (dist < 256) ? color : 0;
        tiles[3][i][j] = (dist < 144) ? color : 0;
        tiles[4][i][j] = (dist < 81) ? color : 0;
        tiles[5][i][j] = (dist < 25) ? color : 0;
        tiles[9][31-i][31-j] = tiles[8][i][31-j] = tiles[7][31-i][j] 
            = tiles[6][i][j] = (i*i + j*j < 1024) ? 0 : color;
        tiles[10][i][j] = C(255 - (int)(10*(22 - Math.sqrt(dist))), 
            -45, 255);
        tiles[11][i][j] = (((i+j) >> 3)&1) == 0 ? 1 : 0xffffff;
        tiles[12][i][j] = (color << 1) | 0xff000000;
      }
    }    
    for(int i = 4; i < 29; i++) {
      for(int j = 0; j < 8; j++) {
        if (i+j > 6 && i+j < 33) {
          tiles[10][i][35 - (j + i)] = tiles[10][i][j + i - 4] 
              = (255 - random.nextInt(8)) << 16;           
        }
      }
    }
    for(int k = 0; k < 32; k++) {
      for(int i = 0; i < 16; i++) {
        for(int j = 0; j < 16; j++) {
          double dx = j - 7.5, dy = i - 7.5;
          double dist1 = dx*dx + dy*dy;
          dx = j - 4;
          dy = i - 4;
          ballData[(i<<4)+j] = dist1 > 64 ? 0 : 
              C(255 - (int)(dist1*2), 
              (85 * (31 - k) / 31 - 85), 
              k == 0 ? 0 : (int)(dx*dx + dy*dy) << 3);
        }
      }
      balls[k] = new BufferedImage(16, 16, BufferedImage.TYPE_INT_ARGB_PRE);
      balls[k].setRGB(0, 0, 16, 16, ballData, 0, 16);
    }    
//-- GENERATE SPRITES AND TILES END --------------------------------------------    
       
    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    pack();
    setLocationRelativeTo(null);
    setIconImage(balls[31]);
    show();
       
    BufferedImage image = new BufferedImage(
        320, 240, BufferedImage.TYPE_INT_RGB);    
    Graphics imageGraphics = image.getGraphics();
    
    long nextFrameStart = System.nanoTime();  
    while(true) {
      do {        
// -- UPDATE MODEL BEGIN -------------------------------------------------------
      
        if (playing) {
          if (levelState > 0) {        
            if (levelState == 2) {

//-- GENERATE BACKGROUND BEGIN -------------------------------------------------   
              double Cr = (random.nextDouble() - 0.5) * 2;
              double Ci = random.nextDouble() - 0.5;
              int angleOffset = random.nextInt(256);
              int A = 2 + random.nextInt(2);
              int B = 1 + random.nextInt(2);
              boolean C = random.nextBoolean();
              boolean D = random.nextBoolean();
              boolean E = random.nextBoolean();
              for(int i = 0; i < 240; i++) {
                for(int j = 0; j < 320; j++) {        
                  double Zi = (i - 120) / 120.0, Zr = (j - 160) / 120.0;
                  int angle = random.nextInt(16);
                  while(angle < 4096 && Zi*Zi + Zr*Zr < 4.0) {
                    double nextZr = Zr*Zr - Zi*Zi + Cr;
                    Zi = A*Zr*Zi*(C ? Zr : 1)*(D ? Zi : 1) + Ci;
                    if (E) {
                      Zi = Math.sqrt(Zi);
                    }
                    Zr = B*nextZr;
                    angle += 24;
                  }
                  background[i][j] = C(96, angleOffset + angle, 255);                  
                }
              }    
//-- GENERATE BACKGROUND END ---------------------------------------------------
            }

//-- GENERATE BOARD BEGIN ------------------------------------------------------

            for(int i = 0; i < 64; i++) {
              for(int j = 0; j < 64; j++) {
                boardMap[i][j] = (level < 7) ? 1 : level - 5;
              }
              boardMap[i][63] = 11;
            }
            for(double a = 1; true; a += 0.001) {
              int y = 32 + (int)(30 * Math.sin(a/(15-level)));
              int x = (int)(a + 5 * Math.sin((a - 1) * 2));
              if (x < 1) {
                x = 1;
              }      
              if (x < 62) {
                boardMap[y][x] = boardMap[y+1][x] 
                    = boardMap[y][x+1] = boardMap[y+1][x+1] = 0;
              } else {
                break;
              }
              if (a == 1) {
                startX = (x << 5) + 16;
                startY = (y << 5) + 16;
              }
            }
            for(int i = 1; i < 63; i++) {
              for(int j = 2; j < 63; j++) {
                if (boardMap[i][j] == 0) {
                  if (level > 2 && random.nextInt(30 - level) == 0) {
                    boardMap[i][j] = 5;
                  } else if (level > 3 && random.nextInt(4) == 0) {
                    if (boardMap[i+1][j] == 1
                        && boardMap[i][j+1] == 1
                        && boardMap[i+1][j+1] == 1) {
                      boardMap[i][j] = 6;
                    } else if (boardMap[i-1][j] == 1
                        && boardMap[i][j+1] == 1
                        && boardMap[i-1][j+1] == 1) {
                      boardMap[i][j] = 7;
                    } else if (boardMap[i][j-1] == 1
                        && boardMap[i+1][j] == 1
                        && boardMap[i+1][j-1] == 1) {
                      boardMap[i][j] = 8;
                    } else if (boardMap[i][j-1] == 1
                        && boardMap[i-1][j] == 1
                        && boardMap[i-1][j-1] == 1) {
                      boardMap[i][j] = 9;
                    }
                  } else if (level > 4 && random.nextInt(5) == 0
                      && boardMap[i+1][j] == 0
                      && boardMap[i+2][j] == 0
                      && boardMap[i][j+1] == 0
                      && boardMap[i+1][j+1] == 0
                      && boardMap[i+2][j+1] == 0
                      && boardMap[i][j+2] == 0
                      && boardMap[i+1][j+2] == 0
                      && boardMap[i+2][j+2] == 0) {
                    boardMap[i+1][j+1] = random.nextInt(3) + 2;
                  }  
                } else if (level > 1 && random.nextInt(30 - level) == 0) {
                  boardMap[i][j] = 10;
                }
              }
            }
            if (level > 0) {
              int x = random.nextInt(58) + 4;
              for(int j = 1; j < 63; j++) {
                if (boardMap[j][x] == 0) {
                  boardMap[j][x] = 12;
                }
              }
            }            

            /*for(int i = 63; i >= 0; i--) {
              for(int j = 0; j < 64; j++) {
                System.out.print((boardMap[i][j] == 0) ? "." : "X");
              }
              System.out.println();
            }*/

//-- GENERATE BOARD END --------------------------------------------------------        

            ballX = boardX = startX;
            ballY = boardY = startY;
            boardAngle = ballVx = ballVy = 0;
            time = 4000;
            smashX = -1;
            smashing = ouch = levelState = zooming = 0;
            zoom = 1;    

            setTitle(new StringBuffer("On The Ball -- Maze ")
                .append(level + 1).toString());
            nextFrameStart = System.nanoTime();
          } 

          // ITERATIONS
          for(int u = 16; u > 0 && time > 0 && zooming == 0; u--) {  

            if (K[KeyEvent.VK_LEFT]) {
              boardAngle += 0.01;
            } else if (K[KeyEvent.VK_RIGHT]) {
              boardAngle -= 0.01;
            } 

            double normalX = 0;
            double normalY = 0;  
            for(int i = 0; i < ballEdges.length; i++) {
              double edgeX = ballX + ballEdges[i][0];
              double edgeY = ballY + ballEdges[i][1];     
              int x = ((int)edgeX) >> 5;
              int y = ((int)edgeY) >> 5;
              if (x >= 0 && x < 64 && y >= 0 && y < 64) {
                int tile = boardMap[y][x];
                if (tile > 0 
                    && tiles[tile][((int)edgeY) & 31][((int)edgeX) & 31] != 0) {
                  normalX += ballEdges[i][0];
                  normalY += ballEdges[i][1];
                  if (tile == 10 && ouch == 0) {
                    ouch = 32;
                    time = Math.max(1, time - 175);
                  }
                  if (tile == 12) {
                    smashX = x;
                    smashY = y;
                  }
                }
              }
            }

            ballAx = -G * Math.cos(boardAngle - HALF_PI);
            ballAy = G * Math.sin(boardAngle - HALF_PI);
            if (K[KeyEvent.VK_DOWN]) {
              if (--down > 0) {
                ballAx *= 6;
                ballAy *= 6;
              }
            } else {
              down = 512;
            }
            double newVx = DAMP * (ballVx + ballAx * DT);
            double newVy = DAMP * (ballVy + ballAy * DT);
            double newV2 = newVx*newVx + newVy*newVy;
            if (newV2 > TERMINAL_V2) {
              double scale = TERMINAL_V / Math.sqrt(newV2);
              newVx *= scale;
              newVy *= scale;
            }
            ballVx = newVx;
            ballVy = newVy;

            if (normalX != 0 || normalY != 0) {
              // (1/|w|^2) (v . w) w

              double scale = -Math.abs((ballVx*normalX + ballVy*normalY) 
                  / (normalX*normalX + normalY*normalY));
              double perpX = normalX * scale;
              double perpY = normalY * scale;
              double rightX = normalY;
              double rightY = -normalX;
              scale = (ballVx*rightX + ballVy*rightY) 
                  / (rightX*rightX + rightY*rightY);
              ballVx = perpX + rightX * scale;
              ballVy = perpY + rightY * scale;

              if (smashX >= 0 && perpX*perpX + perpY*perpY > SMASH_V2) {
                boardMap[smashY][smashX] = 0; 
                final double cosA = -Math.cos(boardAngle);
                final double sinA = -Math.sin(boardAngle);
                final double rX = (smashX << 5) - ballX + 16;
                final double rY = (smashY << 5) - ballY + 16;
                final double smashCenterX = ballX + cosA * rX + sinA * rY;
                final double smashCenterY = ballY - sinA * rX + cosA * rY; 
                smashing = 128;
                for(int i = sparkles.length - 1; i >= 0; i--) {
                  double ang = 2 * random.nextDouble() * Math.PI;
                  double vel = 4 + (random.nextDouble() * 12);
                  double[] sparkle = sparkles[i];
                  sparkle[0] = 159 + smashCenterX - boardX;
                  sparkle[1] = 119 + boardY - smashCenterY;
                  sparkle[2] = vel * Math.cos(ang);
                  sparkle[3] = -vel * Math.sin(ang);
                }            
              }
              smashX = -1;
            } 
            ballX += ballVx * DT;
            ballY += ballVy * DT;

            if (ballX > 2007) {
              zooming = 128;
              boardX = ballX;
              boardY = ballY;
            }

            double centerDx = ballX - boardX;
            double centerDy = ballY - boardY;
            double centerDist = centerDx*centerDx + centerDy*centerDy;
            if (centerDist > FREEDOM_2) {
              double scale = FREEDOM / Math.sqrt(centerDist);
              boardX += centerDx - scale * centerDx;
              boardY += centerDy - scale * centerDy;
            } else {
              boardX += 0.001 * centerDx;
              boardY += 0.001 * centerDy;
            }        
          }

          if (zooming == 0 && --time == 0) {
            smashing = 0;
            for(int i = sparkles.length - 1; i >= 0; i--) {
              double ang = 2 * random.nextDouble() * Math.PI;
              double vel = 4 + (random.nextDouble() * 12);
              double[] sparkle = sparkles[i];
              sparkle[0] = 159 + ballX - boardX;
              sparkle[1] = 119 + boardY - ballY;
              sparkle[2] = vel * Math.cos(ang);
              sparkle[3] = -vel * Math.sin(ang);
            }  
          } else if (time < 0 || smashing > 0) {
            for(int i = sparkles.length - 1; i >= 0; i--) {
              double[] sparkle = sparkles[i];
              sparkle[3] += 0.5;
              sparkle[0] += sparkle[2];
              sparkle[1] += sparkle[3];
            }
            if (smashing == 0 && time < -127) {
              levelState = 1;
            } else if (smashing > 0) {
              smashing--;
            }
          }

          if (zooming > 0) {
            zooming--;
            if (zooming == 0) {
              levelState = 2;
              if (level == 9) {
                playing = false;
                setTitle("Congratulations!");
              } else {
                level++;
              }
            }
            zoom -= 0.0078125;
            boardAngle -= 0.25;
          }

          if (ouch > 0) {
            ouch--;
          }
        }
      
// -- UPDATE MODEL END ---------------------------------------------------------        
        nextFrameStart += 28571429;
      } while(nextFrameStart < System.nanoTime());     
// -- RENDER FRAME BEGIN ------------------------------------------------------- 
           
      final double cosA = Math.cos(boardAngle), sinA = Math.sin(boardAngle);
      double upperLeftX = boardX - 160 * zoom, upperLeftY = boardY + 120 * zoom;
      double upperRightX = boardX + 160 * zoom, upperRightY = upperLeftY;
      double lowerLeftX = upperLeftX, lowerLeftY = boardY - 120 * zoom;

      double rX = upperLeftX - ballX;
      double rY = upperLeftY - ballY;
      upperLeftX = ballX + cosA * rX + sinA * rY;
      upperLeftY = ballY - sinA * rX + cosA * rY; 
      
      rX = upperRightX - ballX;
      rY = upperRightY - ballY;
      upperRightX = ballX + cosA * rX + sinA * rY;
      upperRightY = ballY - sinA * rX + cosA * rY;
      
      rX = lowerLeftX - ballX;
      rY = lowerLeftY - ballY;
      lowerLeftX = ballX + cosA * rX + sinA * rY;
      lowerLeftY = ballY - sinA * rX + cosA * rY;      
      
      final double acrossVx = (upperRightX - upperLeftX) * RECIP_320;
      final double acrossVy = (upperRightY - upperLeftY) * RECIP_320;
      final double downVx = (lowerLeftX - upperLeftX) * RECIP_240;
      final double downVy = (lowerLeftY - upperLeftY) * RECIP_240;
      
      double screenX = upperLeftX;  
      double screenY = upperLeftY;
      for(int i = 0, k = 0; i < 240; i++) {
        double sX = screenX;
        double sY = screenY;
        for(int j = 0; j < 320; j++, k++) {
          int x = ((int)sX) >> 5;
          int y = ((int)sY) >> 5;
          if (x < 0 || x > 63 || y < 0 || y > 63) {
            screenBuffer[k] = background[i][j];
          } else {           
            int tile = boardMap[y][x];            
            if (tile > 0) {
              int color = tiles[tile][((int)sY) & 31][((int)sX) & 31];
              screenBuffer[k] = (color == 0) ? background[i][j] : color;
            } else {
              screenBuffer[k] = background[i][j];
            }
          } 
          sX += acrossVx;
          sY += acrossVy;
        }
        screenX += downVx;
        screenY += downVy;
      }      
      image.setRGB(0, 0, 320, 240, screenBuffer, 0, 320);
      if (time > 0) {
        imageGraphics.setColor(Color.white);
        imageGraphics.drawString(Integer.toString(time), 8, 16);
        int ball = (time > 3967) ? 31 : Math.max(1, time >> 7);
        if (ouch > 0 && (ouch&2) == 0) {
          ball = 0;
        }
        imageGraphics.drawImage(balls[ball], 
            151 + (int)(ballX - boardX), 
            111 + (int)(boardY - ballY), null);
      } 
      if (time <= 0 || smashing > 0) {
        imageGraphics.setColor((time&1) == 0 ? Color.white : 
            (smashing > 0) ? DUST : Color.red);
        for(int i = sparkles.length - 1; i >= 0; i--) {
          imageGraphics.drawRect(
              (int)sparkles[i][0], (int)sparkles[i][1], 0, 0);
        }
      }     
      Graphics panelGraphics = panel.getGraphics();
      if (panelGraphics != null) {
        panelGraphics.drawImage(image, 0, 0, 640, 480, null);
        panelGraphics.dispose();
      }
      
// -- RENDER FRAME END ---------------------------------------------------------      
      long remaining = nextFrameStart - System.nanoTime();
      if (remaining > 0) {
        try {
          Thread.sleep(remaining / 1000000);
        } catch(Throwable t) {          
        }
      }
    }
  }
   
  public int C(int magnitude, int angle, int light) {
    return (D(magnitude, angle, light) << 16) 
        | (D(magnitude, angle + 85, light) << 8) 
        | (D(magnitude, angle - 85, light))
        | 0xff000000;
  }
  
  public int D(int magnitude, int angle, int light) {
    return (int)(magnitude 
        * Math.pow((Math.cos(Math.PI * angle / 127.5) + 1) / 2, 
        light / 255.0));
  }
     
  protected void processKeyEvent(KeyEvent e) {
    K[e.getKeyCode()] = e.getID() == 401;
  }

  public static void main(String[] args) {
    new M();
  }
}
