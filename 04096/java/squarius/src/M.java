import java.awt.image.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.util.*;
import java.awt.geom.*;

// rect double[] 
//   0 - x
//   1 - y
//   2 - x side length
//   3 - y side length

// point double[]
//   0 - x
//   1 - y

// bullet double[]
//   0 - x
//   1 - y
//   2 - Vx
//   3 - Vy
//   4 - type (0 - human / 1 - computer / 2 - shield)
//   5 - shield angle

// ship double[]
//   0 - x
//   1 - y
//   2 - x side length
//   3 - y side length
//   4 - shoot timer
//   5 - shoot timer reset
//   6 - guns

//   7 - Vx
//   8 - sin amp
//   9 - sin y axis
//  10 - hits
//  11 - is boss (0/1)

// guns double[]
//   0 - x
//   1 - y
//   2 - 20 (side x)
//   3 - 20 (side y)
//   4 - flash (0/1)

// boom double[]
//   0 - x
//   1 - y
//   2 - radius
//   3 - flash (0/1)

// level stages
//   0 - sin wave attack
//   1 - triple attack
//   2 - solid walls
//   3 - breakable field
//   4 - boss
//   5 - shrinker
//   6 - squeeze
//   7 - fast solid walls

public class M extends JFrame {
   
  boolean[] K = new boolean[65535]; // pressed keys
  
  public M() {
    
    Random R = new Random(); // random
    ArrayList B = new ArrayList(); // bullets
    ArrayList S = new ArrayList(); // ships
    ArrayList G = new ArrayList(); // guns
    ArrayList O = new ArrayList(); // booms
    int[][] L = { // levels   
      { 25, 25, 10, 10, 10, 25, 1000 },
      { 25, 15, 20, 5, 5, 15, 15, 18, 25 },
      { 40, 25, 5, 5, 20, 25, 25 },
      { 40, 25, 25, 15, 25, 15, 15, 25, 5, 5, 15, 40 },
      { 30, 30, 40, 10, 40, 40, 40, 15, 40, 50 },
      { 65, 5, 5, 25, 40, 10, 20 },
      { 30, 30, 40, 40, 40, 5, 5, 40, 50, 25, 60, 25 },
    };
    long[] V = {
      0x4011100L,
      0x422211220L,
      0x4200023L,
      0x410122252005L,
      0x4110511006L,
      0x4200117L,
      0x480300022555L,
    };
    // level, phase, phaseCount, deadDelay, blowUp
    int E = 0, P, C, D, U;   
    int introPhase = 5; 
    String introStr = "The Square Wars begin !";    
    
    U = D = P = C = 0;
    for(int i = B.size() - 1; i >= 0; i--) {
      double[] bullet = (double[])B.get(i);
      if (bullet[4] != 2) {
        B.remove(i);
      }
    }
    S.clear();
    G.clear();
    O.clear();        
    B.clear();
    S.add(new double[] { 63, 223, 32, 32, 0, 16, 1 });    
        
    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));    
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    pack();
    setLocationRelativeTo(null);
    show();
    
    Image image = createImage(640, 480);
    Graphics imageGraphics = image.getGraphics();
    imageGraphics.setColor(Color.LIGHT_GRAY);
    imageGraphics.fillRect(0, 0, 640, 480);
    setIconImage(image);    
    FontMetrics fontMetrics = null;
    float fontSize = 480;
    do {
      imageGraphics.setFont(imageGraphics.getFont().deriveFont(fontSize));
      fontSize -= 1;
      fontMetrics = imageGraphics.getFontMetrics();
    } while(fontMetrics.getHeight() > 480);   
    int textWidth = -fontMetrics.stringWidth(introStr);
    int textY = ((480 - fontMetrics.getHeight()) >> 1) +  fontMetrics.getAscent();   
    int textX = 640;
    int introShipX = 640;
    int introClock = 25;
    
    long nextFrameStart = System.nanoTime();
    while(true) {
      do {
// -- UPDATE MODEL BEGIN -------------------------------------------------------
        if (K[KeyEvent.VK_ENTER] && introPhase > 0) {
          introPhase = 0;
          t(E);
        }
        if (introPhase == 0) {
          if (C == 0) {
            if (U == 0) {
              switch(P < L[E].length ? (int)(15 & (V[E] >> (P * 4))) : R.nextInt(2)) {
                case 0:
                  for(int i = 0, k = R.nextInt(90)+10, j = R.nextInt(448-k*2)+k; i < 8 + E; i++) {
                    S.add(new double[] { 
                      640 + i * 64, 
                      0, 
                      32, 
                      32, 
                      0, 
                      100, 
                      1, 
                      -4, 
                      k, 
                      j, 
                      1,
                      0 });
                  }
                  break;
                case 1:
                  for(int i = 0, j = R.nextInt(208); i < 3; i++) {
                    S.add(new double[] { 
                      640, 
                      0, 
                      32, 
                      32, 
                      0, 
                      100, 
                      1, 
                      -4, 
                      0, 
                      i * 120 + j, 
                      1,
                      0});
                  } 
                  break;
                case 2: {
                  int y = R.nextInt(480);
                  S.add(new double[] { 
                      640, 
                      0, 
                      128, 
                      y - 64, 
                      0, 
                      100, 
                      1, 
                      -2, 
                      0, 
                      0, 
                      -1,
                      0 });
                  S.add(new double[] { 
                      640, 
                      0, 
                      128, 
                      416 - y, 
                      0, 
                      100, 
                      1, 
                      -2, 
                      0, 
                      y + 64, 
                      -1,
                      0});                       
                  }
                  break;
                case 3:
                  for(int i = 0; i < 480; i += 32) {
                    for(int j = 640; j < 1280; j += 32) {
                      S.add(new double[] { 
                          j, 
                          0, 
                          32, 
                          32, 
                          0, 
                          150, 
                          1, 
                          -2, 
                          0, 
                          i, 
                          1,
                          0});
                    }
                  }
                  break;        
                case 4: {
                  int size = 128 + E * 35;
                  S.add(new double[] {
                    640,
                    0,
                    size,
                    size,
                    0,
                    10,
                    1,
                    -1,
                    20,
                    240 - size / 2,
                    500 + E * 100,
                    1
                  });           
                  }
                 break;
                case 5:
                  for(int i = 0; i < 16; i++) {
                    int size = 256 - 12 * i;
                    S.add(new double[] {
                      640 + 6 * i,
                      0,
                      size,
                      size,
                      0,
                      10,
                      1,
                      -2,
                      20,
                      240 - size / 2,
                      10,
                      0
                    });
                  }
                  break;
                case 6:
                  for(int i = 1; i < 10; i++) {
                    int x = i * 640;
                    int y = i * 12;
                    S.add(new double[] { 
                        x, 
                        0, 
                        640, 
                        y, 
                        0, 
                        100, 
                        1, 
                        -2, 
                        0, 
                        0, 
                        -1,
                        0 });
                    S.add(new double[] { 
                        x, 
                        0, 
                        640, 
                        y, 
                        0, 
                        100, 
                        1, 
                        -2, 
                        0, 
                        479 - y, 
                        -1,
                        0}); 
                  }
                  break;
                case 7: 
                  for(int i = 0; i < 32; i++) {
                    S.add(new double[] { 
                        640 + 320 * i, 
                        0, 
                        128, 
                        240, 
                        0, 
                        100, 
                        1, 
                        -15, 
                        0, 
                        R.nextBoolean() ? 0 : 240, 
                        -1,
                        0 });                       
                  }
                  break;           
                case 8:
                  for(int i = 0; i < 128; i++) {
                    S.add(new double[] { 
                        640 + 16 * i, 
                        0, 
                        R.nextInt(128) + 32, 
                        R.nextInt(128) + 32, 
                        0, 
                        R.nextInt(256) + 64, 
                        1, 
                        -(R.nextInt(5)+1), 
                        R.nextInt(100), 
                        R.nextInt(480), 
                        1+R.nextInt(3),
                        0 });        
                  }
                  break;
              }
            }
            C = 10 * L[E][Math.min(P, L[E].length - 1)];
            P++;       
          } else {
            C--;
          }

          double[] ship = (double[])S.get(0);   
          for(int i = B.size() - 1; i >= 0; i--) {
            double[] bullet = (double[])B.get(i);
            if (bullet[4] != 2 && (bullet[0] < 0 || bullet[0] >= 640 
                  || bullet[1] < 0 || bullet[1] >= 480)) {
              B.remove(i);
            } else {
              if (bullet[4] == 2) {
                bullet[0] = 16 + ship[0] + 64 * Math.cos(bullet[5]); 
                bullet[1] = 16 + ship[1] + 64 * Math.sin(bullet[5]); 
                bullet[5] += 0.1;
              } else {
                bullet[0] += bullet[2];
                bullet[1] += bullet[3];
              }
              if (bullet[4] != 1) {
                for(int j = S.size() - 1; j > 0; j--) {
                  double[] enemy = (double[])S.get(j);
                  if (p(bullet[0], bullet[1], enemy)) {
                    B.remove(i);
                    enemy[10] = (int)(enemy[10] - 1);
                    if (enemy[10] == 0) {
                      S.remove(j);
                      if (enemy[11] == 1) {
                        if (E == 6) {
                          setTitle("Congratulations!!!!");
                          D = U = Integer.MAX_VALUE;                    
                        } else {
                          U = 200;
                        }
                      }
                      O.add(new double[] {
                        enemy[0] + enemy[2]/2,
                        enemy[1] + enemy[3]/2,
                        0,
                        0,
                      });
                      if (R.nextDouble() < 0.1) {
                        G.add(new double[] {
                          enemy[0] + enemy[2]/2 - 10,
                          enemy[1] + enemy[3]/2 - 10,
                          20,
                          20,
                          0
                        });
                      }
                    } else {
                      O.add(new double[] {
                        bullet[0],
                        bullet[1],
                        0,
                        0,
                      });
                    }
                    break;
                  }
                }
              } else if (D == 0 && p(bullet[0], bullet[1], ship)) {
                D = 75;
                O.add(new double[] {
                  ship[0] + ship[2]/2,
                  ship[1] + ship[3]/2,
                  0,
                  0,
                });
                B.remove(i);
              }
            }
          }
          for(int i = O.size() - 1; i >= 0; i--) {
            double[] boom = (double[])O.get(i);
            boom[0] -= 2;
            if (boom[2] > 64) {
              O.remove(i);
            } else {
              boom[2] += 8;
            }
            boom[3] = (boom[3] == 0) ? 1 : 0;
          }
          if (D == 0) {
            if (K[KeyEvent.VK_UP] && ship[1] - 10 >= 0) {
              ship[1] -= 10;
            } else if (K[KeyEvent.VK_DOWN] && ship[1] + ship[3] + 10 < 480) {
              ship[1] += 10;
            }
            if (K[KeyEvent.VK_LEFT] && ship[0] - 10 >= 0) {
              ship[0] -= 10;
            } else if (K[KeyEvent.VK_RIGHT] && ship[0] + ship[2] + 10 < 640) {
              ship[0] += 10;
            }
            if (ship[4] > 0) {
              ship[4] = (int)(ship[4] - 1);
            } else if (K[KeyEvent.VK_D]) {
              ship[4] = ship[5];
              for(int j = Math.min(4, (int)ship[6] - 1); j >= 0; j--) {
                for(int i = 0; i < 5; i++) {
                  for(int k = 0; k < 2; k++) {
                    B.add(new double[] {
                      ship[0] + ship[2] + i * 16,
                      ship[1] + ship[3]/2 - j * 10 * (k == 0 ? 1 : -1),
                      20,
                      0,
                      0,
                      0,
                    });
                  }
                }
                if (ship[6] == 6) {
                  B.add(new double[] {
                      ship[0] + ship[2]/2 + j * 7,
                      ship[1] - j * 7,
                      14,
                      -14,
                      0,
                      0,
                  });
                  B.add(new double[] {
                      ship[0] + ship[2]/2 + j * 7,
                      ship[1] + ship[3] + j * 7,
                      14,
                      14,
                      0,
                      0,
                  });            
                }
              }
            }
          } else if (D == 1) {
            t(E);
            for(int i = B.size() - 1; i >= 0; i--) {
              double[] bullet = (double[])B.get(i);
              if (bullet[4] != 2) {
                B.remove(i);
              }
            }
            S.clear();
            G.clear();
            O.clear();    
            U = D = P = C = 0;
            B.clear();
            S.add(new double[] { 63, 223, 32, 32, 0, 16, 1 });          
          } else {
            D--;
          }
          for(int i = G.size() - 1; i >= 0; i--) {
            double[] gun = (double[])G.get(i);
            gun[4] = (gun[4] == 0) ? 1 : 0;
            gun[0] -= 2;
            if (gun[0] < -20) {
              G.remove(i);
            } else if (s(gun, ship)) {
              G.remove(i);
              if (ship[6] < 6) {
                ship[6] = (int)(ship[6] + 1);
              } else {
                B.add(new double[] {
                  ship[0] + 80,
                  ship[1] + ship[3]/2,
                  0,
                  0,
                  2,
                  0,
                });
              }
            }
          }
          for(int i = S.size() - 1; i > 0; i--) {
            double[] enemy = (double[])S.get(i);
            if (enemy[11] == 0 || enemy[0] > 320) {
              enemy[0] += enemy[7];
            }
            enemy[1] = enemy[9] + enemy[8] * Math.sin(Math.PI * enemy[0] / 160);
            if (enemy[4] == 0) {
              enemy[4] = enemy[5];
              double tx = ship[0] + ship[2]/2 - enemy[0], 
                  ty = ship[1] + ship[3]/2 - enemy[1] - enemy[3]/2;
              double mag = Math.sqrt(tx * tx + ty * ty);
              tx /= mag;
              ty /= mag;
              B.add(new double[] {
                enemy[0],
                enemy[1] + enemy[3]/2,
                tx * 5,
                ty * 5,
                1,
                0,
              });
            } else {
              enemy[4] = (int)(enemy[4] - 1);
            }
            if (enemy[0] < -enemy[2]) {
              S.remove(i);
            } else if (D == 0 && s(ship, enemy)) {
              D = 75;
              O.add(new double[] {
                ship[0] + ship[2]/2,
                ship[1] + ship[3]/2,
                0,
                0,
              });
            }
          }

          if (U > 0) {
            U--;
            if (U == 1) {
              E++;
              t(E);
              for(int i = B.size() - 1; i >= 0; i--) {
                double[] bullet = (double[])B.get(i);
                if (bullet[4] != 2) {
                  B.remove(i);
                }
              }
              S.clear();
              G.clear();
              O.clear();    
              U = D = P = C = 0;
              S.add(ship);  
            } else if (U % 4 == 0) {
              O.add(new double[] {
                R.nextInt(640),
                R.nextInt(480),
                0,
                0,
              });
            }
          }     
        } else if (introPhase == 5) {
          // ship moves from right-to-left
          if (introShipX > 255) {
            introShipX -= 2;
          } else {
            introPhase = 4;
          }
        } else if (introPhase == 4) {
          // ship pauses
          if (introClock > 0) {
            introClock--;
          } else {
            introPhase = 3;
            introClock = 24;
          }
        } else if (introPhase == 3) {
          // ship shoots
          if (introClock < 400) {
            introClock += 64;
          } else {
            introPhase = 2;
            introClock = 20;
          }          
        } else if (introPhase == 2) {
          // kaboom!
          if (introClock < 800) {
            introClock += 61;
          } else {
            introPhase = 1;
          }          
        } else if (introPhase == 1) {
          if (textX > textWidth) {
            textX -= 16;
          } else {
            introPhase = 0;
            t(E);
          }
        }      
// -- UPDATE MODEL END ---------------------------------------------------------
        nextFrameStart += 40000000;
      } while(nextFrameStart < System.nanoTime());     
// -- RENDER FRAME BEGIN -------------------------------------------------------
      imageGraphics.setColor(Color.BLACK);
      imageGraphics.fillRect(0, 0, 640, 480);
      if (introPhase > 1) {
        if (introPhase == 3) {
          imageGraphics.setColor(Color.YELLOW);
          for(int i = 0; i < 160; i += 24) {
            imageGraphics.fillOval(315, introClock + i, 8, 8);
          }  
        } 
        imageGraphics.setColor(Color.RED);
        imageGraphics.fillRect(0, 416, 640, 64);
        imageGraphics.setColor(Color.LIGHT_GRAY);
        imageGraphics.fillRect(introShipX, 16, 128, 128);
        if (introPhase == 2) {
          imageGraphics.setColor(
              (introClock&1) == 0 ? Color.WHITE : Color.YELLOW);
          imageGraphics.fillOval(319 - (introClock << 3), 416 - introClock, 
              introClock << 4, introClock << 1);
        }
      } else if (introPhase == 1) {
        imageGraphics.setColor(Color.RED);
        imageGraphics.drawString(introStr, textX, textY);
      } else {
        for(int i = S.size() - 1; i >= 0; i--) {
          if (D > 0 && i == 0) {
            continue;
          }
          double[] ship = (double[])S.get(i);
          imageGraphics.setColor(i == 0 ? Color.RED : Color.LIGHT_GRAY);
          imageGraphics.fillRect(
              (int)ship[0], (int)ship[1], (int)ship[2], (int)ship[3]);
        }    
        for(int i = G.size() - 1; i >= 0; i--) {
          double[] gun = (double[])G.get(i);
          imageGraphics.setColor(gun[4] == 0 ? Color.WHITE : Color.MAGENTA);
          imageGraphics.fillRect(
              (int)gun[0], (int)gun[1], 20, 20);
        }
        for(int i = O.size() - 1; i >= 0; i--) {
          double[] boom = (double[])O.get(i);
          imageGraphics.setColor(boom[3] == 0 ? Color.WHITE : Color.YELLOW);
          imageGraphics.fillOval((int)(boom[0] - boom[2]/2), 
            (int)(boom[1] - boom[2]/2), (int)boom[2], (int)boom[2]);
        }
        for(int i = B.size() - 1; i >= 0; i--) {
          double[] bullet = (double[])B.get(i);
          imageGraphics.setColor(bullet[4] == 1 ? Color.YELLOW : Color.GREEN);
          int size = bullet[4] == 2 ? 16 : 6, half = size / 2;
          imageGraphics.fillOval((int)bullet[0] - half, (int)bullet[1] - half, size, size);
        }
      }
      Graphics panelGraphics = panel.getGraphics();
      if (panelGraphics != null) {
        panelGraphics.drawImage(image, 0, 0, null);
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
  
  public void t(int level) {
    setTitle(new StringBuffer("Squarius -- Stage ")
        .append(level + 1).toString());
  }
 
  // do the squares overlap?
  public boolean s(double[] rect1, double[] rect2) {
    return S(rect1, rect2) || S(rect2, rect1);
  }
  
  // called by s() for overlapping
  public boolean S(double[] rect1, double[] rect2) {
    return p(rect1[0], rect1[1], rect2)
      || p(rect1[0] + rect1[2], rect1[1], rect2)
      || p(rect1[0], rect1[1] + rect1[3], rect2)
      || p(rect1[0] + rect1[2], rect1[1] + rect1[3], rect2);
  }
  
  // does the rect contain the point?
  public boolean p(double x, double y, double[] rect) {
    return x >= rect[0] && x <= rect[0] + rect[2]
        && y >= rect[1] && y <= rect[1] + rect[3];
  }
  
  public void processKeyEvent(KeyEvent e) {
    K[e.getKeyCode()] = e.getID() == 401;
  }
  
  public static void main(String[] args) {
    new M();
  }
}
