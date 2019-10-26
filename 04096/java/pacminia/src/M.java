import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.util.*;
import java.awt.image.*;
import java.awt.geom.*;

//tiles
//0,0 - empty
//0,1 - pellot
//1,x - solid dark
//2,x - solid light
//3,x - super pellot

//sprites
//0,0 - pacman
//0,1->31 - deadly ghost monsters
//1,x - vulnerable ghost monsters

//creatures
//0 - x
//1 - y
//2 - can jump (0 = no / 1 = yes)
//3 - Vx
//4 - Vy

public class M extends JFrame {
   
  boolean[] K = new boolean[65535]; // pressed keys
 
  public M() {
    
    final double A = 240;
    final double B = 320;
    final double H = 320;
    final double gamma = Math.atan(2*H / A);
    final double theta = gamma - Math.asin(A * Math.sin(gamma) / B); 
    final double S = Math.sqrt(H*H + (A*A) / 4);
    
    final double Y0 = S * Math.cos(theta + gamma);
    final double Z0 = -S * Math.sin(theta + gamma);
    final double Y1 = A * Math.cos(theta);
    final double Z1 = -A * Math.sin(theta);
    
    final double SUY = -Math.cos(theta);
    final double SUZ = Math.sin(theta);  
    final double CY = (Y1/2 - Y0) / H, CZ = (Z1/2 - Z0) / H;
    
    //System.out.println((-SUY * A / 2) + " " + (-SUZ * A / 2));
    //System.out.println(Y1/2 + " " + Z1/2);
    
    int pacmanX = 0, pacmanY = 0;
    
    //System.out.println(Y0 + " " + Z0 + " " + Y1 + " " + Z1);
    //System.out.println(SUY + " " + SUZ + " " + CY + " " + CZ + " " + CL);
    
    int[] screen = new int[320 * 240];
    int[][][] screenMap = new int[240][320][2];
    int[][] boardMap = null;
    int[][][][] tiles = new int[4][32][32][32];
    int[] spriteData = new int[32*32];
    BufferedImage[][] sprites = new BufferedImage[2][32];
    int superPellotCount = 0;
    int[] jumpHeights = new int[16];
    int[][] creatures = new int[32][3];
    int jumpCount = 0;
    int creatureCount = 0;
    int vulnerableCount = 0;
    int level = 0;
    int score = 0;
    int lives = 5;
    int boardBlinking = 0;
    int dying = 0;
    int pellotCount = 0;
    int newBoard = 2;
    int boardSize = 16;
    int killPoints = 0;
    int highScore = 0;
    final StringBuffer sb = new StringBuffer();
    boolean attractMode = true;
    final String title = "PacMinia";
    int attractGridOffset = 0;
    final String enter = "INSERT COIN";
    int attractClock = 0;
    
    for(int i = 0; i < 16; i++) {
      jumpHeights[i] = i * i - 16 * i;
    }

// -- CREATE TILES AND SPRIES BEGIN --------------------------------------------
    for(int a = 0; a < 2; a++) {
      for(int s = 0; s < 32; s++) {
        sprites[a][s] = new BufferedImage(
            32, 32, BufferedImage.TYPE_INT_ARGB_PRE);
        for(int i = 0, k = 0; i < 32; i++) {
          for(int j = 0; j < 32; j++, k++) {          
            double dx = i - 10, dy = j - 21;
            double dist1 = dx*dx + dy*dy;
            dx = i - 15.5; 
            dy = j - 15.5;
            double dist2 = dx*dx + dy*dy;
            dx = i + 15.5;
            double dist3 = dx*dx + dy*dy;
            tiles[0][0][i][j] = 0;
            tiles[0][1][i][j] = C(0, 0, Math.exp(dist2/8));                      
            tiles[1][s][i][j] = C(1.75 - s , 1, dist2/1024 + 1);
            tiles[2][s][i][j] = C(1.75 - s, 0.5, dist2/1024 + 1);
            tiles[3][s][i][j] = C(0, 0, Math.exp(dist2/32)/(5 
                + 4 * Math.sin(2.0 * Math.PI * s/32)) + 0.9);            
            if (dist2 > 256 && ((a == 0 && s == 0) || i < 15 || dist3 > 2304)) {
              spriteData[k] = 0;
            } else {
              spriteData[k] = C(
                  (a == 0) ? ((s == 0) ? 5.25 : 10 + s) : 1.75, 
                  dist1/256 * ((a == 0) ? 1 : Math.pow(Math.sin(Math.PI * s / 8), 2)), 
                  dist1/1024 + 1) | 0xff000000;
            }            
          }
        }
        sprites[a][s].setRGB(0, 0, 32, 32, spriteData, 0, 32);
      }
    }
// -- CREATE TILES AND SPRIES END ----------------------------------------------        
    
// -- CREATE BOARD BEGIN -------------------------------------------------------

      
    /*for(int i = 0; i < 32; i++) {
      for(int j = 0; j < 32; j++) {          
        System.out.print(boardMap[i][j] == 0 ? "X" : boardMap[i][j] == 2 ? "-" : "*");
      }
      System.out.println();
    }*/
// -- CREATE BOARD END ---------------------------------------------------------     
    
// -- CREATE SCREEN MAP BEGIN --------------------------------------------------
    for(int i = 0; i < 240; i++) {
      for(int j = 0; j < 320; j++) {
        double x = j - 160;
        double y = Y1 + SUY * i;
        double z = Z1 + SUZ * i;
        double k = Z0 / (Z0 - z); 
        double xp = k * x;
        double yp = k * (y - Y0) + Y0;
        screenMap[i][j][0] = (int)xp;
        screenMap[i][j][1] = (int)-yp;
      }
    }
    
    /*System.out.println(screenMap[0][0][0] + " " + screenMap[0][0][1] + " " 
        + screenMap[0][319][0] + " " + screenMap[0][319][1]);
    System.out.println(screenMap[239][0][0] + " " + screenMap[239][0][1] + " " 
        + screenMap[239][319][0] + " " + screenMap[239][319][1]);  */
// -- CREATE SCREEN MAP END ----------------------------------------------------
    
    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));
    setTitle(title);    
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    pack();
    setLocationRelativeTo(null);
    show();
       
    BufferedImage image = new BufferedImage(
        320, 240, BufferedImage.TYPE_INT_RGB);    
    Graphics imageGraphics = image.getGraphics();
    Font titleFont = panel.getFont().deriveFont(64f);
    FontMetrics fontMetrics = imageGraphics.getFontMetrics(titleFont);
    int textX = (320 - fontMetrics.stringWidth(title)) >> 1;
    int textY = ((180 - fontMetrics.getHeight()) >> 1) 
        + fontMetrics.getAscent();
    fontMetrics = imageGraphics.getFontMetrics(panel.getFont());
    int textX2 = (320 - fontMetrics.stringWidth(enter)) >> 1;
    
    Random random = null;
    long nextFrameStart = System.nanoTime();
    outer: while(true) {
      do {        
// -- UPDATE MODEL BEGIN -------------------------------------------------------
                
        if (attractMode) {
          attractGridOffset -= 4;
          if (attractGridOffset < -64) {
            attractGridOffset = 0;
          }
          if (K[KeyEvent.VK_ENTER]) {
            attractMode = false;
            continue outer;
          }
          attractClock++;
        } else {
          if (dying > 0) {
            if (dying == 1) {
              if (--lives == 0) {
                lives = 5;
                score = level = 0;             
                newBoard = 2;
                boardSize = 16;
                attractMode = true;
              } else {
                newBoard = 1;
              }           
            }
            dying--;
          }
          if (boardBlinking > 0) {
            if (boardBlinking == 1) {
              level++;
              boardSize = Math.min(30, 16 + (level>>1));
              lives = Math.min(19, lives + 1);
              score += 10000;
              newBoard = 2;
            }
            boardBlinking--;
          }
          if (newBoard > 0) {          
            jumpCount = vulnerableCount = 0;          
            pacmanX = (boardSize + 2) * 16;
            pacmanY = 16 + boardSize * 32;
            creatures[0][2] = 1;
            creatureCount = Math.min(31, (level>>1) + 4);
            random = new Random(level);
            setIconImage(sprites[0][level&31]);
            for(int i = 1; i < creatureCount; i++) {
              creatures[i] = new int[] { 
                  32*(random.nextInt(boardSize-6)+3), 
                  48, 
                  (i&3) == 0 ? 1 : 0, 
                  random.nextBoolean() ? 4 : -4, 0 
              };
            }
            if (newBoard == 2) {
              boardMap = new int[32][32];
              B(1, 1, boardSize, boardSize, boardMap, random);
              pellotCount = 0;
              for(int i = 0; i < 32; i++) {
                for(int j = 0; j < 32; j++) {
                  if (boardMap[i][j] > 0) {
                    pellotCount++;
                  }
                }
              }
              boardMap[3][1] = boardMap[3][boardSize]
                  = boardMap[boardSize-2][1] = boardMap[boardSize-2][boardSize] = 3;
            }
            newBoard = 0;
            nextFrameStart = System.nanoTime();
          }

          if (++superPellotCount == 32) {
            superPellotCount = 0;
          }

          if (boardBlinking == 0 && dying == 0) {

            if (K[KeyEvent.VK_UP] || K[KeyEvent.VK_DOWN]) {
              if ((pacmanX&31) == 16) {
                if (K[KeyEvent.VK_UP] /*&& pacmanY - 20 >= 0*/
                    && boardMap[(pacmanY-20)>>5][pacmanX>>5] > 0) {
                  pacmanY -= 4;        
                } else if (K[KeyEvent.VK_DOWN] /*&& pacmanY + 16 < 1024*/
                    && boardMap[(pacmanY+16)>>5][pacmanX>>5] > 0) {
                  pacmanY += 4;    
                } 
              } else if (!(K[KeyEvent.VK_LEFT] || K[KeyEvent.VK_RIGHT])) {
                if ((pacmanX&31) < 16) {
                  pacmanX += 4;
                } else {
                  pacmanX -= 4;
                }
              }
            }
            boolean canEat = jumpCount == 0 && (pacmanX&31) == 16 
                && (pacmanY&31) == 16;
            if (K[KeyEvent.VK_LEFT] || K[KeyEvent.VK_RIGHT]) {
              if ((pacmanY&31) == 16) {
                if (K[KeyEvent.VK_RIGHT] /*&& pacmanX + 16 < 1024*/
                    && boardMap[pacmanY>>5][(pacmanX+16)>>5] > 0) {
                  pacmanX += 4;
                } else if (K[KeyEvent.VK_LEFT] /*&& pacmanX - 20 >= 0*/
                    && boardMap[pacmanY>>5][(pacmanX-20)>>5] > 0) {
                  pacmanX -= 4;      
                }
              } else if (!(K[KeyEvent.VK_UP] || K[KeyEvent.VK_DOWN])) {
                if ((pacmanY&31) < 16) {
                  pacmanY += 4;
                } else {
                  pacmanY -= 4;
                }
              }
            }
            if (canEat | (jumpCount == 0 && (pacmanX&31) == 16 
                && (pacmanY&31) == 16)) {
              int spaceType = boardMap[pacmanY>>5][pacmanX>>5];
              if (spaceType == 2) { // dot
                score += 10;
              } else if (spaceType == 3) { // power pellot
                for(int i = 1; i < creatureCount; i++) { // reverse directions
                  int[] creature = creatures[i];
                  creature[3] = (creature[3] == 0) ? 0 : (creature[3] < 0) ? 2 : -2;
                  creature[4] = (creature[4] == 0) ? 0 : (creature[4] < 0) ? 2 : -2;
                }
                if (vulnerableCount == 0) {
                  killPoints = 100;  
                }
                vulnerableCount = 256;              
                score += 50;
              }
              boardMap[pacmanY>>5][pacmanX>>5] = 1; // empty space
              if (spaceType > 1 && --pellotCount == 0) {
                boardBlinking = 64;  
              }
            }      
            if (jumpCount > 0) {
              jumpCount--;
            } else if (K[KeyEvent.VK_D]) {
              jumpCount = 15;
            }

            creatures[0][0] = pacmanX;
            creatures[0][1] = pacmanY;

  // -- MOVE GHOST MONSTERS BEGIN ------------------------------------------------
            int ghostSpeed = (vulnerableCount > 0) ? 2 : 4;
            for(int i = 1; i < creatureCount; i++) {
              int[] creature = creatures[i];
              int x = creature[0];
              int y = creature[1];
              int Vx = creature[3];
              int Vy = creature[4];
              if ((x&31) == 16 && (y&31) == 16) {
                //System.out.println(x + " " + y);
                boolean canGoUp = /*(y - 20 >= 0) &&*/ boardMap[(y-20)>>5][x>>5] > 0;
                boolean canGoDown = /*(y + 16 < 1024) &&*/ boardMap[(y+16)>>5][x>>5] > 0;
                boolean canGoLeft = /*(x - 20 >= 0) &&*/ boardMap[y>>5][(x-20)>>5] > 0;
                boolean canGoRight = /*(x + 16 < 1024) &&*/ boardMap[y>>5][(x+16)>>5] > 0;
                boolean canContinue = (Vx > 0 && canGoRight) 
                    || (Vx < 0 && canGoLeft)
                    || (Vy < 0 && canGoUp)
                    || (Vy > 0 && canGoDown);
                if (!canContinue || (canContinue && random.nextDouble() < 0.75)) {
                  if (Vx != 0) {            
                    if (canGoUp && !canGoDown) {
                      Vy = -ghostSpeed;
                      Vx = 0;
                    } else if (!canGoUp && canGoDown) {
                      Vy = ghostSpeed;
                      Vx = 0;
                    } else if (canGoUp && canGoDown) {
                      if ((Math.abs(pacmanY - y + ghostSpeed) 
                          > Math.abs(pacmanY - y - ghostSpeed))
                              ^ (vulnerableCount == 0)) {
                        Vy = -ghostSpeed;
                      } else {
                        Vy = ghostSpeed;
                      }
                      Vx = 0;
                    }
                  } else if (Vy != 0) {
                    if (canGoLeft && !canGoRight) {
                      Vx = -ghostSpeed;
                      Vy = 0;
                    } else if (!canGoLeft && canGoRight) {
                      Vx = ghostSpeed;
                      Vy = 0;
                    } else if (canGoLeft && canGoRight) {
                      if (Math.abs(pacmanX - x + ghostSpeed) 
                          > Math.abs(pacmanX - x - ghostSpeed)
                              ^ (vulnerableCount == 0)) {
                        Vx = -ghostSpeed;
                      } else {
                        Vx = ghostSpeed;
                      }
                      Vy = 0;
                    }
                  }
                }
              }
              creature[0] += Vx;
              creature[1] += Vy;
              creature[3] = Vx;
              creature[4] = Vy;

              int dx = x - pacmanX;
              int dy = y - pacmanY; 
              int dz = (creature[2] == 0) ? jumpHeights[jumpCount] : 0;
              if (dx*dx + dy*dy + dz*dz < 1024) {
                // COLLISION BETWEEN PAC-MAN AND GHOST MONSTER DETECTED
                if (vulnerableCount > 0) {
                  score += killPoints;
                  if (killPoints < 6400) {
                    killPoints <<= 1;
                  }
                  creature[0] = boardSize*16;
                  creature[3] = random.nextBoolean() ? ghostSpeed : -ghostSpeed;
                  creature[4] = 0;
                  if (pacmanY < boardSize*16) {
                    creature[1] = 16 + boardSize * 32;    
                  } else {
                    creature[1] = 48;
                  }
                } else {
                  dying = 32;
                }
              }
            }
            if (vulnerableCount > 0) {
              vulnerableCount--;
            }
          }
// -- MOVE GHOST MONSTERS END --------------------------------------------------      
        
          highScore = Math.max(highScore, score);
        } 
// -- UPDATE MODEL END ---------------------------------------------------------        
        nextFrameStart += 40000000;
      } while(nextFrameStart < System.nanoTime());     
// -- RENDER FRAME BEGIN ------------------------------------------------------- 
      
// -- RENDER FLOOR BEGIN -------------------------------------------------------
      if (attractMode) {
        boolean white = false;
        for(int i = 0; i < 240; i += 32) {
          for(int j = attractGridOffset; j < 384 + attractGridOffset; j += 32) {
            imageGraphics.setColor(white ? Color.GRAY : Color.DARK_GRAY);
            imageGraphics.fillRect(j, i, 32, 32);
            white ^= true;
          }
          white ^= true;
        }
        imageGraphics.setFont(titleFont);
        imageGraphics.setColor(Color.BLACK);
        imageGraphics.drawString(title, textX + 2, textY + 2);
        imageGraphics.setColor(Color.YELLOW);
        imageGraphics.drawString(title, textX, textY);
        if (((attractClock>>4)&1) == 0) {          
          imageGraphics.setFont(panel.getFont());
          imageGraphics.setColor(Color.BLACK);
          imageGraphics.drawString(enter, textX2 + 1, 201);
          imageGraphics.setColor(Color.WHITE);
          imageGraphics.drawString(enter, textX2, 200);
        }
      } else {      
        int floorTiles = ((boardBlinking>>3)&1) == 0 ? 1 : 2;
        for(int k = 0, i = 0; i < 240; i++) {
          for(int j = 0; j < 320; j++, k++) {
            int x = screenMap[i][j][0] + pacmanX;
            int y = screenMap[i][j][1] + pacmanY + 160;
            int boardX = x >> 5;
            int boardY = y >> 5;
            int tile = (boardX >= 0 && boardY >= 0 && boardX < 32 && boardY < 32) 
                ? boardMap[boardY][boardX] : 0; 
            if (tile == 0) {
              screen[k] = tiles[floorTiles][level&31][y&31][x&31];
            } else if (tile == 3) {
              screen[k] = tiles[3][superPellotCount][y&31][x&31];
            } else {
              screen[k] = tiles[0][tile-1][y&31][x&31];
            }          
          }
        }
// -- RENDER FLOOR END -------------------------------------------------------      
      
// -- RENDER SPITES BEGIN ------------------------------------------------------ 

        image.setRGB(0, 0, 320, 240, screen, 0, 320);      
        for(int i = 0; i < 1024; i += 2) {
          for(int j = creatureCount - 1; j >= 0; j--) {
            int[] creature = creatures[j];
            if (creature[1] == i) {
              int pacmanHalfSize = (j == 0 && dying > 0) ? (dying >> 1) : 16;
              double x = -pacmanHalfSize + (creature[0] - pacmanX);
              double y = 160 + (pacmanY - creature[1]);
              double z = (pacmanHalfSize - 16) + ((creature[2] == 0) ? 0 : jumpHeights[jumpCount]);
              double Vx = x;
              double Vy = y - Y0;
              double Vz = z - Z0;            
              double l = Vy * CY + Vz * CZ;
              double s = H / l;
              x = s * Vx;
              y = Y0 + s * Vy;
              z = Z0 + s * Vz;
              Vy = y - Y1;
              Vz = z - Z1;
              l = Vy * SUY + Vz * SUZ;
              int leftLowerX = (int)x + 160;
              int leftLowerY = (int)l;

              x = pacmanHalfSize - 1 + (creature[0] - pacmanX);
              y = 160 + (pacmanY - creature[1]);
              z = (pacmanHalfSize - 16) + ((creature[2] == 0) ? 0 : jumpHeights[jumpCount]);
              Vx = x;
              Vy = y - Y0;
              Vz = z - Z0;
              l = Vy * CY + Vz * CZ;
              s = H / l;
              x = s * Vx;
              int rightLowerX = (int)x + 160;

              imageGraphics.drawImage(
                  (vulnerableCount > 0 && j > 0) ? sprites[1][vulnerableCount&31] 
                      : sprites[0][j], 
                  leftLowerX, 
                  leftLowerY - (rightLowerX - leftLowerX), 
                  rightLowerX, 
                  leftLowerY, 
                  0, 0, 32, 32, null);
            }
          }
        }
// -- RENDER SPITES END --------------------------------------------------------  
      
        for(int i = 0; i < lives-1; i++) {
          imageGraphics.drawImage(sprites[0][0], 10 + (i << 4), 220, 20 + (i << 4), 
              230, 0, 0, 32, 32, null);
        }
      }
      sb.setLength(0);
      imageGraphics.setFont(panel.getFont());
      imageGraphics.setColor(Color.WHITE);
      imageGraphics.drawString(sb.append(highScore).append("    ").append(score)
          .toString(), 8, 16);
      
      //for(int i = 0; i < 32; i++) {
      //  imageGraphics.drawImage(sprites[i], i*32, 0, 32, 32, null);
      //}
      Graphics panelGraphics = panel.getGraphics();
      if (panelGraphics != null) {
        panelGraphics.drawImage(image, 0, 0, 640, 480, null);
        panelGraphics.dispose();
      }
      
      /*panelGraphics.setColor(Color.BLACK);
      panelGraphics.fillRect(0, 0, 640, 480);
      panelGraphics.setColor(Color.GREEN);
      double OX = 100;
      double OY = 400;
      panelGraphics.drawLine((int)OX, (int)OY, (int)(OX + B), (int)OY);
      panelGraphics.drawLine((int)OX, (int)OY, (int)(OX + Y0), (int)(OY + Z0));
      panelGraphics.drawLine((int)(OX + Y0), (int)(OY + Z0), (int)(OX + Y1), (int)(OY + Z1));
      panelGraphics.drawLine((int)(OX), (int)(OY), (int)(OX + Y1), (int)(OY + Z1));
      panelGraphics.drawLine((int)(OX + B), (int)(OY), (int)(OX + Y1), (int)(OY + Z1));*/
      
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
  
  public void B(int x, int y, int endX, int endY, 
      int[][] boardMap, Random random) {
    if (endX - x < 4 || endY - y < 4) {
      return;
    }
    for(int i = x; i <= endX; i++) {
      boardMap[y][i] = boardMap[endY][i] = 2;
    }
    for(int i = y; i <= endY; i++) {
      boardMap[i][x] = boardMap[i][endX] = 2;
    }
    if (random.nextBoolean()) {
      int pivot = random.nextInt(endX - x - 3) + x + 2;
      B(x, y, pivot, endY, boardMap, random);
      B(pivot, y, endX, endY, boardMap, random);
    } else {
      int pivot = random.nextInt(endY - y - 3) + y + 2;
      B(x, y, endX, pivot, boardMap, random);
      B(x, pivot, endX, endY, boardMap, random);      
    }
  }
  
  public int C(double angle, double light, double dark) {
    return (D(angle, light, dark) << 16) 
        | (D(angle + 2 * Math.PI / 3, light, dark) << 8) 
        | (D(angle - 2 * Math.PI / 3, light, dark));
  }
  
  public int D(double angle, double light, double dark) {
    return (int)(255 * Math.pow((Math.cos(angle) + 1) / 2, light) / dark);
  }
     
  protected void processKeyEvent(KeyEvent e) {
    K[e.getKeyCode()] = e.getID() == 401;
  }

  public static void main(String[] args) {
    new M();
  }
}
