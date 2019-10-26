import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.util.*;
import java.awt.image.*;

import java.io.*;

// brick types
// 0 - empty space
// 1 - solid
// 2 - gold

// creatures
// 0 - x
// 1 - y
// 2 - type (0 = scorpion, 1 = croc)
// 3 - Vx

public class M extends JFrame {
   
  boolean[] K = new boolean[65535]; // pressed keys
 
  public M() {
    
    int[][] creatures = new int[256][16];
    int[][] boardMap = new int[15][320];
    int[][] flakes = new int[1024][2];
    Color SKY = null;
    Color BRICK_TOP = null;
    Color BRICK = null;
    int levelState = 2;
    int level = 1;
    double harryX = 0;
    double harryY = 0;
    double harryVx = 0;
    double harryVy = 0;
    int harryDirection = 0;
    int cameraX = 0;
    int jumping = 0;
    int jumpCount = 0;
    int jumpID = 0;
    int creatureCount = 0;
    int clock = 0;
    int bluring = 0;
    int flakesCount = 0;
    double blur = 0;
    double blurRate = 0;
    boolean killed = false;
    boolean foundTreasure = false;
    boolean running = false;
    boolean snowing = false;
    
    //creatures[0] = new int[] { 280, 193, 0, -1 };
    //creatures[1] = new int[] { 280, 113, 0, -1 };
    //creatures[2] = new int[] { 240, 197, 1, 0 };
    
// -- DECOMPRESS SPRITES BEGIN -------------------------------------------------    
    int[] spriteData = new int[1024];
    BufferedImage[][] sprites = new BufferedImage[10][2];
    String GRAPHICS_DATA = "\u1800\u1818\u1810\u1a18\u1c1e\u1818\u1818\u1818\u1818\u1818\u1c18\u1800\u1818\u1810\u3818\u3e3a\u183c\u1818\u1c1c\u7414\u4344\u0002\u1800\u1818\u1810\u1818\u1818\u1c1c\u1818\u0e1c\u3e0a\u2828\u0c08\u1800\u1818\u1810\u1818\u1c18\u181c\u1c18\u161e\u3432\u2224\u1020\u1800\u1818\u1810\u3818\u3e3a\u183c\u1c18\u363e\u6262\u80c3\u0080\u1800\u1818\u1810\u3e1a\u587c\u1858\u1e1c\u72da\u0033\u0000\u0000\u0000\ud870\u9288\ufac4\u3c78\u4933\u7000\u88d8\u8290\uf8c6\u3d78\u8532\u0000\u0000\u0604\u55ff\uffab\u8000\ubae0\u0b2e\u0303\uffab";    
    for(int s = 0, dataIndex = 0; s < 10; s++) {
      int height = (s < 6) ? 11 : (s < 8) ? 6 : 5;
      int off = 0;
      for(int y = 0; y < height; y++, dataIndex++) {
        int data = GRAPHICS_DATA.charAt(dataIndex);
        for(int j = 0; j < 2; j++, off += 32) {
          int row = data & 0xff;
          data >>= 8;
          int Y = (y << 1) + j;
          for(int k = 0; k < 8; k++) {
            int color = (row&1) == 0 ? 0 : 
                (s < 6) ? ((Y < 2) ? 0xFF887000 : 
                    (Y < 5) ? 0xFFFC9838 : 
                        (Y < 12) ? 0xFF80D010 : 0xFF2A5F00) : 
                (s < 8) ? 0xFFFFFFFF : 0xFF80FF10;                  
            int off2 = off + (k << 1);
            spriteData[off2] = spriteData[off2 + 1]
                = spriteData[off2 + 16] = spriteData[off2 + 17] = color;
            row >>= 1;            
          }
        }
      }
      for(int i = 0; i < 2; i++) {
        int hi = height << 2;
        for(int y = 0; y < hi; y++) {
          for (int left = y << 4, right = left + 15; 
              left < right; left++, right--) {
            int temp = spriteData[left]; 
            spriteData[left]  = spriteData[right]; 
            spriteData[right] = temp;
          }
        }        
        BufferedImage image = new BufferedImage(
            16, hi, BufferedImage.TYPE_INT_ARGB_PRE);
        image.setRGB(0, 0, image.getWidth(), image.getHeight(), 
            spriteData, 0, image.getWidth());   
        sprites[s][i] = image;
      }
    }
    
// -- DECOMPRESS SPRITES END --------------------------------------------------- 
    
    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    pack();
    setLocationRelativeTo(null);
    setIconImage(sprites[6][0]);
    show();
       
    BufferedImage image = new BufferedImage(
        320, 240, BufferedImage.TYPE_INT_RGB);    
    Graphics imageGraphics = image.getGraphics();
       
    long nextFrameStart = System.nanoTime();      
    while(true) {
      do {        
// -- UPDATE MODEL BEGIN -------------------------------------------------------
        
        if (bluring > 0) {
          if (bluring == 1) {
            if (killed) {
              levelState = 1;
            } else if (foundTreasure) {
              levelState = 2;
              level++;
              if (level == 17) {
                setTitle("Superb!");                 
              }
            }
          } 
          bluring--;
          blur += blurRate;
        } else {
          clock++;
        }
        
        if (level == 17) {
          continue;
        }
        
        if (levelState > 0) {
// -- CREATE BOARD BEGIN -------------------------------------------------------
          setTitle(new StringBuffer("Pitfall: Scorpion Island -- Stage ")
              .append(level).toString());
          Random random = new Random(level);
          random.nextInt();
          boolean isNight = random.nextBoolean();
          if (isNight) {
            SKY = Color.BLACK;
            BRICK_TOP = Color.CYAN;
            BRICK = new Color(0x008088);
            snowing = false;
          } else {          
            snowing = random.nextBoolean();
            SKY = snowing ? Color.LIGHT_GRAY : new Color(0x5C94FC);
            BRICK_TOP = new Color(0xFCBCB0);
            BRICK = new Color(0xC84C0C);
          }

          for(int y = 0; y < boardMap.length; y++) {
            for(int x = 0; x < boardMap[y].length; x++) {
              boardMap[y][x] = (y < 13) ? (isNight && y == 0 ? 1 : 0) : 
                  snowing ? 3 : 1;
            }
          }            

          int goldPile = (random.nextInt(7) << 1) + 1;           
          for(int i = goldPile; i >= 0; i--) {
            for(int j = 12 - (goldPile >> 1) 
                + Math.abs(i - (goldPile >> 1)); j < 13; j++) {
              boardMap[j][302+i] = 2;
            }
          }

          for(int i = 0; i < flakes.length; i++) {
            flakes[i][0] = random.nextInt(320);
            flakes[i][1] = random.nextInt(240);
          }

          creatureCount = 0;
          for(int i = 1; i < 19; i++) {
            int off = i << 4;
            int height1 = 12 - random.nextInt(5);
            int height2 = height1 - random.nextInt(5);
            int width = random.nextInt(5) + 3;
            boolean platform = random.nextBoolean();
            boolean addCreature = random.nextInt(3) != 0;
            int[] creature = creatures[creatureCount];
            switch(random.nextInt(8)) {
              case 7:
                // L's
                for(int j = 0; j < 9; j++) {
                  boardMap[4][off+13-j] = boardMap[9][off+j] 
                    = boardMap[12-j][off+13] = boardMap[j][off] = 1;
                }
                if (random.nextBoolean()) {
                  // add scorpion
                  creature[0] = (off+2) << 4;
                  creature[1] = 128;
                  creature[2] = 0;
                  creature[3] = -1;
                  creatureCount++;
                }
                break;
              case 0:
                for(int j = random.nextInt(3) + 1; j >= 0; j--) {
                  // add scorpion
                  creature[0] = (off+j) << 4;
                  creature[1] = 193;
                  creature[2] = 0;
                  creature[3] = -1;
                  creatureCount++;
                  creature = creatures[creatureCount];
                }
                break;
              case 5: 
                if (random.nextInt(8) == 0) {
                  // large pit
                  height1 = 13 - random.nextInt(5);
                  for(int j = 1; j < 15; j++) {
                    boardMap[13][off + j] = boardMap[14][off + j] = 0;
                    if (j % 4 == 0) {                      
                      boardMap[height1][off + j 
                              + (random.nextBoolean() ? 1 : -1)] 
                          = boardMap[height1][off + j] = 1;
                      height1 += 5 - random.nextInt(8);
                      if (height1 < 8) {
                        height1 = 8;
                      } else if (height1 > 13) {
                        height1 = 13;
                      }
                    }
                  }
                } else { 
                  // pit
                  for(int j = random.nextInt(4) + 1; j >= 0; j--) {
                    boardMap[13][off + j] = boardMap[14][off + j] = 0;  
                  }
                  boardMap[13][off - 1] = 1;
                  if (addCreature) {
                    creature[0] = (off << 4) + 80;
                    creature[1] = 192;
                    creature[2] = 0;
                    creature[3] = -1;
                    creatureCount++;
                  } 
                }
                break;
              case 3: // tunnel
                for(int j = width; j >= 0; j--) {
                  for(int k = height2 - 5; k > 0; k--) {
                    boardMap[platform ? height2 - 5: k][off + j + width] = 1;
                  }
                }
                // no break by intent
              case 6:
              case 4:
              case 2: // stumps/platforms
                for(int j = width; j >= 0; j--) {
                  for(int k = height2; k < 13; k++) {
                    boardMap[platform ? height2 : k][off + j + width] = 1;
                  }
                }
                // no break by intent
              case 1: // stump/platform                  
                for(int j = width; j >= 0; j--) {
                  for(int k = height1; k < 13; k++) {
                    boardMap[platform ? height1 : k][off + j] = 
                        snowing ? 3 : 1;
                  }
                }
                if (isNight && random.nextBoolean()) {
                  // add fire chain
                  creature[0] = (off << 4) + 8;
                  creature[1] = ((height1+1) << 4);
                  creature[2] = 2;
                  creature[3] = 6 + random.nextInt(6);
                  creature[4] = random.nextInt(256);
                  creatureCount++;
                  creature = creatures[creatureCount];
                }
                if (addCreature) {
                  if (random.nextBoolean()) {
                    // add scorpion
                    creature[0] = off << 4;
                    creature[1] = ((height1-1) << 4);
                    creature[2] = 0;
                    creature[3] = -1;
                    creatureCount++;
                  } else {
                    // add crocs
                    for(int j = width - 1; j >= 0; j--) {
                      if (random.nextBoolean()) {
                        creature = creatures[creatureCount];
                        creature[0] = (off + j) << 4;
                        creature[1] = ((height1-1) << 4) + 5;
                        creature[2] = 1;
                        creatureCount++;
                      }  
                    }                      
                  }                    
                }
                break;
            }
          }
                        
// -- CREATE BOARD END ---------------------------------------------------------         
          blur = jumpID = jumpCount = jumping = harryDirection = levelState 
              = flakesCount = 0;
          harryY = harryX = 32;
          harryVy = harryVx = 0;
          bluring = 50;
          blurRate = 0.02;
          foundTreasure = killed = false;
          nextFrameStart = System.nanoTime();
        }
        
        if (bluring == 0) {
                
// -- MOVE HARRY BEGIN ---------------------------------------------------------          
          for(int i = 0; i < 8; i++) {

            int nextHarryX = ((int)(harryX + harryVx 
                + ((harryVx < 0) ? 6 : 9))) >> 4;
            boolean hitWall = false;
            if (nextHarryX >= 0 && nextHarryX < 319) {                    
              for(int y = (int)harryY - 8; y < (int)harryY + 35; y++) {
                int Y = y >> 4;
                if (Y >= 0 && Y < 15 && boardMap[Y][nextHarryX] > 0) {
                  if (boardMap[Y][nextHarryX] == 2) {
                    foundTreasure = true;
                  }
                  hitWall = true;              
                  break;
                }
              }
              if (!hitWall) {
                harryX += harryVx;
              }
            }
            hitWall = false;
            int nextHarryY = ((int)(harryY + harryVy 
                + ((harryVy < 0) ? -8 : 35))) >> 4;
            boolean touchingIce = false;
            for(int x = (int)harryX + 6; x < (int)harryX + 9; x++) {
              int X = x >> 4;
              if (nextHarryY >= 0 && nextHarryY < 15 && X >= 0 && X < 319 
                  && boardMap[nextHarryY][X] > 0) {
                foundTreasure = (boardMap[nextHarryY][X] == 2);
                touchingIce = (boardMap[nextHarryY][X] == 3);
                hitWall = true;
                break;
              } 
            } 
            boolean onGround = false;
            if (hitWall) {
              if (harryVy < 0) {
                jumping = 1024;
                harryVy = Math.min(1, -harryVy);
              } else {
                harryVy = 0;
                onGround = true;
              }
            } else if (harryVy < 1) {
              harryVy += 0.0078125;
            }
            harryY += harryVy;  
            if (harryY > 240) {
              killed = true;
              bluring = 50;
              blur = 1;
              blurRate = -0.02;              
            }            
            if (foundTreasure) {
              bluring = 50;
              blur = 1;
              blurRate = -0.02;  
              running = false;
              harryVy = 0;
              break;
            }

            touchingIce &= onGround;
            running = false;
            if (K[KeyEvent.VK_LEFT]) {
              if (onGround) {
                harryVx = Math.max(-0.25, 
                    harryVx - (touchingIce ? 0.0005 : 0.25));
              } else {
                harryVx = -Math.abs(harryVx);
              }
              harryDirection = 1;
              running = true;
            } else if (K[KeyEvent.VK_RIGHT]) {
              if (onGround) {
                harryVx = Math.min(0.25, 
                    harryVx + (touchingIce ? 0.0005 : 0.25));
              } else {
                harryVx = Math.abs(harryVx);
              }
              harryDirection = 0;
              running = true;
            } else {
              if (touchingIce) {
                harryVx *= 0.998;  
              } else if (onGround) {
                harryVx = 0;
              }
            } 

            if (K[KeyEvent.VK_D]) {                
              if (jumping == 0 && onGround) {
                jumpID = jumpCount;
                harryVy = -0.5;
              } 
              if (jumpID == jumpCount && jumping < 150) {
                harryVy = -0.5;
              }
              jumping++;            
            } else {
              if (jumpID == jumpCount) {
                jumpCount++;
              }
              if (jumping > 0 && onGround) {
                jumping = 0;
              }
            }
          }
// -- MOVE HARRY END -----------------------------------------------------------          

// -- MOVE CREATURES BEGIN -----------------------------------------------------         
          for(int i = 0; i < creatureCount; i++) {
            int[] creature = creatures[i];
            if (Math.abs(creature[0] - cameraX) < 512) {
              boolean hit = (((int)harryX + 6 >= creature[0] 
                      && (int)harryX < creature[0] + 10)
                  || ((int)harryX + 8 >= creature[0] 
                      && (int)harryX < creature[0] + 8))
                  && ((creature[1] >= (int)harryY 
                      && creature[1] < (int)harryY + 30)
                  || (creature[1] + 24 >= (int)harryY 
                      && creature[1] < (int)harryY + 6));
              if (creature[2] == 0) {
                int nextX = (creature[0] + creature[3] + 8) >> 4;
                int Y = creature[1] >> 4;
                if (Y >= 0 && Y < 14 && nextX >= 0 && nextX < 320
                    && boardMap[Y][nextX] == 0
                    && boardMap[Y+1][nextX] > 0) {
                  creature[0] += creature[3];
                } else {
                  creature[3] = -creature[3];
                }
                if (hit) {
                  killed = true;
                  bluring = 50;
                  blur = 1;
                  blurRate = -0.02;
                }
              } else if (creature[2] == 1) {
                if (((clock>>7)&1) == 1 && hit) {
                  killed = true;
                  bluring = 50;
                  blur = 1;
                  blurRate = -0.02;
                }
              } else {
                creature[4] = 0xff & (creature[4] + 1);
                double angle = 2.0 * Math.PI * creature[4] / 255.0;
                double cos = Math.cos(angle), sin = Math.sin(angle);
                for(int j = 0; j < creature[3]; j++) {
                  int fireX = (int)(creature[0] + 8 * j * cos) - 3; 
                  int fireY = (int)(creature[1] + 8 * j * sin) - 3;
                  if (fireX >= harryX + 6 && fireX <= harryX + 8
                      && fireY >= harryY && fireY <= harryY + 30) {
                    killed = true;                    
                    bluring = 50;
                    blur = 1;
                    blurRate = -0.02;
                  }
                }                
              }
            }
          }  
        }
// -- MOVE CREATURES END ------------------------------------------------------- 
        
// -- MOVE SNOW FLAKES BEGIN ---------------------------------------------------
        for(int i = 0; snowing && i < flakes.length && i < flakesCount; i++) {
          int[] flake = flakes[i];
          if (i < 768) {
            flake[0]--;
            flake[1]++;
          } else {
            flake[0] -= 4;
            flake[1] += 8;
          }
          if (flake[0] < 0) {
            flake[0] += 320;
          }
          if (flake[1] >= 240) {
            flake[1] -= 240;
          }
        }
        if (flakesCount < flakes.length && (clock&4) == 4) {
          flakesCount++;
        }
// -- MOVE SNOW FLAKES END -----------------------------------------------------
        
        cameraX = (int)harryX - 156; 
        if (cameraX < 0) {
          cameraX = 0;
        } else if (cameraX > 4784) {
          cameraX = 4784;
        }
      
// -- UPDATE MODEL END ---------------------------------------------------------        
        nextFrameStart += 16666667;
      } while(nextFrameStart < System.nanoTime());      
// -- RENDER FRAME BEGIN ------------------------------------------------------- 
               
      imageGraphics.setColor(SKY);
      imageGraphics.fillRect(0, 0, 640, 480);

      imageGraphics.setColor(Color.WHITE);
      for(int i = 0; snowing && i < 768 && i < flakesCount; i++) {
        imageGraphics.fillRect(flakes[i][0], flakes[i][1], 1, 1);
      }
      
      int cameraDividend = cameraX >> 4;
      int cameraRemainder = cameraX & 15;
      for(int y = 0; y < 15; y++) {
        for(int x = 0; x < 21; x++) {
          int element = boardMap[y][x + cameraDividend];
          if (element > 0) {
            int X = (x << 4) - cameraRemainder;
            int Y = (y << 4) + 8;    
            imageGraphics.setColor(element == 3 ? Color.CYAN 
                : element == 1 ? BRICK
                : (clock&4) == 0 ? Color.YELLOW : Color.WHITE);
            imageGraphics.fillRect(X, Y, 16, 16);
            imageGraphics.setColor(element == 3 ? Color.WHITE : BRICK_TOP);
            imageGraphics.drawLine(X + 1, Y, X + 14, Y);
            imageGraphics.drawLine(X, Y + 1, X, Y + 14);
            imageGraphics.setColor(Color.BLACK);
            imageGraphics.drawLine(X + 1, Y + 15, X + 14, Y + 15);
            imageGraphics.drawLine(X + 15, Y + 1, X + 15, Y + 14);
          }
        }
      }
      
      imageGraphics.drawImage(sprites[harryVy != 0 ? 5 : 
          running ? ((clock>>2)%5)+1 : 0][harryDirection], 
          (int)harryX - cameraX, (int)harryY, null);
      for(int i = 0; i < creatureCount; i++) {
        int[] creature = creatures[i];
        if (Math.abs(creature[0] - cameraX) < 512) {
          if (creature[2] == 2) {
            double angle = 2.0 * Math.PI * creature[4] / 255.0;
            double cos = Math.cos(angle), sin = Math.sin(angle);
            for(int j = 0; j < creature[3]; j++) {
              imageGraphics.setColor((clock&1) == 1 ? Color.RED : Color.YELLOW);
              imageGraphics.fillOval(
                  (int)(creature[0] - cameraX + 8 * j * cos) - 3, 
                  (int)(creature[1] + 8 * j * sin) - 3, 6, 6);
            }
          } else {
            imageGraphics.drawImage(
              creature[2] == 0 ? 
                    sprites[6 + ((clock>>3)&1)][creature[3] < 0 ? 1 : 0]
                  : sprites[8 + ((clock>>7)&1)]
                        [creature[0] - (int)harryX < 0 ? 1 : 0],
                creature[0] - cameraX, creature[1], null);
          }
        }
      }
      
      imageGraphics.setColor(Color.WHITE);
      for(int i = 768; snowing && i < flakes.length && i < flakesCount; i++) {
        imageGraphics.fillRect(flakes[i][0], flakes[i][1], 3, 3);
      }
      
      Graphics panelGraphics = panel.getGraphics();
      if (panelGraphics != null) {
        if (bluring > 0) {
          int bx = (int)(320*blur*blur);
          int by = (int)(240*blur*blur);
          imageGraphics.drawImage(image, 0, 0, bx, by, 0, 0, 320, 240, null);
          panelGraphics.drawImage(image, 0, 0, 640, 480, 0, 0, bx, by, null);
        } else {
          panelGraphics.drawImage(image, 0, 0, 640, 480, null);
        }
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
  
  public static void main(String[] args) {
    new M();
    
    /*LinkedList list = new LinkedList();
    try {
      BufferedReader br = new BufferedReader(new FileReader("graphics.txt"));
      String input = null;
      while(((input = br.readLine())) != null) {
        if (input.contains("|")) {
          int index = input.indexOf("|");
          list.addFirst(input.substring(index + 1, index + 9));
        }
      }
      br.close();
      for(int i = 0; i < list.size(); i+=2) {
        String str1 = (String)list.get(i);
        String str2 = (String)list.get(i+1);
        //System.out.println(str1);
        //System.out.println(str2);
        int byte1 = 0;
        int byte2 = 0;
        for(int j = 0; j < 8; j++) {
          byte1 <<= 1;
          byte2 <<= 1;
          if (str1.charAt(j) == 'X') {
            byte1 |= 1;
          }
          if (str2.charAt(j) == 'X') {
            byte2 |= 1;
          }
        }
        int u = (byte2 << 8) | byte1;
        String str = Integer.toString(u, 16);
        while(str.length() < 4) {
          str = "0" + str;
        }
        System.out.print("\\u" + str);
      }
    } catch(Throwable t) {
      t.printStackTrace();
    }*/
  }

  protected void processKeyEvent(KeyEvent e) {
    K[e.getKeyCode()] = e.getID() == 401;
  }
}
