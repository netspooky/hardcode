/*
 * J-Type
 * Copyright (C) 2009 Michael Birken
 *
 * This file is part of J-Type.
 *
 * J-Type is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * J-Type is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.util.*;
import java.awt.image.*;

public class M extends JFrame {

  boolean[] K = new boolean[65535]; // pressed keys
  int[] screenBuffer = new int[76800];
  Random random = new Random();

  public M() {

    final int[][][] backgrounds = new int[8][240][2560];
    final int[] tempBackground = new int[614400];
    final BufferedImage[] backgroundImages = new BufferedImage[8];
    final ArrayList bullets = new ArrayList();
    final ArrayList explosions = new ArrayList();
    final ArrayList enemies = new ArrayList();
    final Color[] enemyColors = new Color[32];
    int playerX = 0;
    int playerY = 0;
    int cameraX = 0;
    int shootDelay = 0;
    int stage = 0;
    int playerDying = 1;
    int nextEnemyCameraX = 0;
    int fireWorks = 0;
    boolean bossCreated = false;
    boolean bossCreated2 = false;

    for(int i = 0; i < 32; i++) {
      enemyColors[i] = new Color(C(Math.PI * i / 16.0, 1, 1));
    }

// -- GENERATE BACKGROUNDS BEGIN -----------------------------------------------

    for(int i = 0; i < 8; i++) {
      for(int x = 320; x < 2240; x++) {
        for(int y = 0; y < 240; y++) {
          tempBackground[y * 2560 + x] = 0;
          switch(i) {
            case 0:
            case 4:
            case 6: {
              double center = 120 + 10 * Math.cos(Math.PI * 3.0 * x / 320)
                  + 30 * Math.sin(Math.PI * 2.0 * x / 320);
              double top = (i == 4 && ((x / 320) & 1) == 0) ? 16 : (i == 0) ? 0
                  : center - (70 + 10 * Math.cos(0.7 + Math.PI * 8.0 * x / 320));
              double bottom = (i == 4 && ((x / 320) & 1) == 1) ? 224 : center + 80;
              if (y < top || y > bottom) {
                tempBackground[y * 2560 + x] = backgrounds[i][y][x] = C(
                    Math.PI * i / 4.0,
                    Math.pow(y - center, 2) / 20000,
                    1);
              }
              break;
            }
            case 1:
            case 5: {
              int X = x % 320;
              if (X < 64 && y > 88 && y < 152) {
                tempBackground[y * 2560 + x] = backgrounds[i][y][x] = C(
                    Math.PI * i / 4.0,
                    1 + (120 - y) / 32.0,
                    1);
              }
              break;
            }
            case 2: {
              double center = 120 + 10 * Math.cos(Math.PI * 3.0 * x / 320)
                  + 30 * Math.sin(Math.PI * 2.0 * x / 320);
              int X = x % 160;
              if (X > 32 && X < 64 && (y < center - 32 || y > center + 32)) {
                tempBackground[y * 2560 + x] = backgrounds[i][y][x] = C(
                    Math.PI * i / 4.0,
                    Math.pow(y - center, 2) / 20000,
                    1);
              }
              break;
            }
            case 3: {
              if ((y < (x - 320) / 18 || y > 240 - ((x - 320) / 18))
                  && (x & 3) == 0) {
                tempBackground[y * 2560 + x] = backgrounds[i][y][x] = C(
                    Math.PI * i / 4.0,
                    Math.pow(y - 120, 2) / 20000,
                    1);
              }
              break;
            }
            case 7: {
              double center = 120 + 10 * Math.cos(Math.PI * 3.0 * x / 40)
                  + 30 * Math.sin(Math.PI * 2.0 * x / 160);
              double top = (i == 2 && ((x / 320) & 1) == 0) ? 16 : (i == 0) ? 0
                  : center
                  - (70 + 10 * Math.cos(0.7 + Math.PI * 8.0 * x / 320));
              double bottom = (i == 2 && ((x / 320) & 1) == 1)
                  ? 224 : center + 80;
              if (y < top || y > bottom) {
                tempBackground[y * 2560 + x] = backgrounds[i][y][x] = C(
                    Math.PI * i / 4.0,
                    Math.pow(y - center, 2) / 20000,
                    1);
              }
              break;
            }
          }
        }
      }
      backgroundImages[i] = new BufferedImage(
          2560, 240, BufferedImage.TYPE_INT_ARGB);
      backgroundImages[i].setRGB(0, 0, 2560, 240, tempBackground, 0, 2560);
    }

// -- GENERATE BACKGROUNDS END -------------------------------------------------

    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    pack();
    setLocationRelativeTo(null);
    setTitle("J-Type -- Stage 1");
    show();

    BufferedImage image = new BufferedImage(
        320, 240, BufferedImage.TYPE_INT_RGB);
    Graphics imageGraphics = image.getGraphics();

    long nextFrameStart = System.nanoTime();
    while(true) {
      do {
// -- UPDATE MODEL BEGIN -------------------------------------------------------

        if (stage == 8) {
          nextFrameStart += 28571429;
          break;
        }

        // advance camera
        if (cameraX < 2240) {
          cameraX++;
        }

        if (playerDying > 0) {
          if (--playerDying == 0) {
            if (bossCreated) {
              cameraX = 2240;
              playerX = 2256;
              bossCreated2 = bossCreated = false;
            } else {
              nextEnemyCameraX = cameraX = 0;
              //nextEnemyCameraX = cameraX = 2240;
              playerX = 16;
              //playerX = 2240 + 16;
            }
            playerY = 120;            
            bullets.clear();
            explosions.clear();
            enemies.clear();
          }
        } else {

          if (fireWorks > 0) {
            fireWorks--;
            if (fireWorks == 0) {
              stage++;
              if (stage == 8) {
                setTitle("WIN!");                
                break;
              }
              setTitle("J-Type -- Stage " + (stage + 1));
              nextEnemyCameraX = cameraX = -1;
              playerX -= 2240;
              bossCreated = false;
            } else if ((fireWorks & 4) == 0) {
              explosions.add(new int[] {
                0,
                25,
                0,
                cameraX + random.nextInt(320),
                random.nextInt(240)
              });
            }
          }

          // move player
          if (K[KeyEvent.VK_UP] && playerY > 10) {
            playerY -= 5;
          } else if (K[KeyEvent.VK_DOWN] && playerY < 229) {
            playerY += 5;
          }
          if (K[KeyEvent.VK_LEFT] && playerX - cameraX > 10) {
            playerX -= 5;
          } else if (K[KeyEvent.VK_RIGHT] && playerX - cameraX < 300) {
            playerX += 5;
          }

          // player hits wall?
          if (cameraX < 2240) {
            playerX++;
            for(int i = 0; i < 32; i++) {
              double angle = i * Math.PI / 16.0;
              int x = playerX + (int)(8 * Math.cos(angle));
              int y = playerY + (int)(8 * Math.sin(angle));
              if (x >= 0 && y >= 0 && x < 2560 && y < 240
                  && backgrounds[stage][y][x] != 0) {
                playerDying = 64;
                explosions.add(new int[] {
                  0,
                  25,
                  0,
                  playerX,
                  playerY
                });
                break;
              }
            }
          }

          // player shoots
          if (shootDelay > 0) {
            shootDelay--;
          } else {
            shootDelay = 10;
            for(int j = 0; j < 3; j++) {
              for(int i = 0; i < 8; i++) {
                double angle = i * Math.PI / 16.0 - Math.PI / 4.0;
                bullets.add(new double[] {
                  0,
                  (j << 3) + playerX + 20 * Math.cos(angle) - 24,
                  playerY + 20 * Math.sin(angle) + 1,
                  16,
                  0
                });
              }
            }
          }
        }

        // generate enemies
        if ((stage == 1 || stage == 5)
              && cameraX % 320 == 0 && cameraX < 1700) {
          int color = random.nextInt(32);
          int angle
              = (int)(32 * (Math.PI * random.nextDouble() - Math.PI));
          int direction = random.nextBoolean() ? 1 : 2;
          if (random.nextBoolean()) {
            direction = -direction;
          }
          for(int i = 0; i < 16; i++) {
            enemies.add(new int[] {
                1,
                cameraX + 352,
                0,
                cameraX + 352,
                i << 3,
                (stage == 5) ? i + 9 : 24 - i,
                angle + ((stage == 5) ? (i << 3) : 0),
                0,
                1024,
                direction,
                0,
                color,
                0
              });
          }
        }
        if (cameraX >= nextEnemyCameraX || (!bossCreated && cameraX == 2240)) {
          int color = random.nextInt(32);
          if (cameraX == 2240 && (stage & 1) == 0) {
            bossCreated = true;
            int count = 1;
            if (stage == 4) {
              count = 20;
            }
            int size = stage == 4 ? 16 : 32 + stage * 2;
            for(int i = 0; i < count; i++) {
              enemies.add(new int[] {
                2,
                cameraX + 336 + (i << 3) + size,
                i << 3,
                -1,
                1,
                size,
                0,
                0,
                stage == 4 ? 256 : 16,
                0,
                stage == 4 ? 64 : 512,
                color,
                0
              });
            }
          } else {
            int y = 180 - random.nextInt(120);
            int radius = 32 + random.nextInt(32);
            int offset = random.nextInt(64);
            int reshoot = 48 + random.nextInt(32);
            int length = random.nextInt(16) == 0 ? 8 : 1;
            int width = random.nextInt(4) == 0 ? random.nextInt(3) : 1;
            int size = random.nextInt(9) + 9;
            if (cameraX == 2240) {
              width = 8 + stage;
              length = width;
              bossCreated = true;
              y = 80;
              radius = 64;
              size = 16 + stage;
              reshoot += 70;
            }
            for(int j = 0; j < width; j++) {
              int Y = y + 6 * j;
              for(int i = 0; i < length; i++) {
                enemies.add(new int[] {
                  0,
                  10 * i + cameraX + 320 + size,
                  Y,
                  Y,
                  radius,
                  size,
                  offset,
                  0,
                  reshoot,
                  1,
                  length,
                  color,
                  cameraX == 2240 ? (10 * i + 2340) : -64
                });
              }
            }
          }
          nextEnemyCameraX += random.nextInt(128);
        }

        // move enemies
        for(int i = enemies.size() - 1; i >= 0; i--) {
          int[] enemy = (int[])enemies.get(i);
          if (enemy[1] + (enemy[5] << 1) < cameraX) {
            enemies.remove(i);
          } else {
            switch(enemy[0]) {
              case 0:
                if (enemy[1] > enemy[12]) {
                  enemy[1] -= enemy[9];
                } else {
                  enemy[6]--;
                }
                enemy[2] = enemy[3] + (int)(enemy[4]
                    * Math.sin((enemy[1] - cameraX + enemy[6]) / 64.0));
                break;
              case 1:
                enemy[1] = enemy[3] + (int)(enemy[4]
                    * Math.cos(enemy[6] / 64.0));
                enemy[2] = 120 + (int)(enemy[4] * Math.sin(enemy[6] / 64.0));                
                enemy[6] += enemy[9];
                break;
              case 2:
                enemy[1] += enemy[3];
                enemy[2] += enemy[4];
                if (enemy[1] <= cameraX + enemy[5]) {
                  enemy[3] = Math.abs(enemy[3]);
                } else if (enemy[1] >= cameraX + 320 - enemy[5]) {
                  enemy[3] = -Math.abs(enemy[3]);
                }
                if (enemy[2] <= enemy[5]) {
                  enemy[4] = Math.abs(enemy[4]);
                } else if (enemy[2] >= 240 - enemy[5]) {
                  enemy[4] = -Math.abs(enemy[4]);
                }
                break;
            }
            double dx = playerX - enemy[1];
            double dy = playerY - enemy[2];
            double r = enemy[5] + 9;
            if (playerDying == 0 && dx * dx + dy * dy < r * r) {
              playerDying = 64;
              explosions.add(new int[] {
                0,
                25,
                0,
                playerX,
                playerY
              });
            }
            if (enemy[7] > 0) {
              enemy[7] -= 1;
            } else if (Math.abs(dx) < 320) {
              enemy[7] = enemy[8];
              double vx = playerX - enemy[1];
              double vy = playerY - enemy[2];
              double mag = 2.5 / Math.sqrt(vx * vx + vy * vy);
              vx *= mag;
              vy *= mag;
              if (!bossCreated) {
                vx += 1;
              }
              bullets.add(new double[] {
                1,
                enemy[1],
                enemy[2],
                vx,
                vy
              });
            }
          }
        }

        // move bullets
        for(int i = bullets.size() - 1; i >= 0; i--) {
          double[] bullet = (double[])bullets.get(i);
          double dx = playerX - bullet[1];
          double dy = playerY - bullet[2];
          if (bullet[1] - cameraX  < 0 || bullet[2] < 0
              || bullet[1] - cameraX > 400 || bullet[2] >= 240
              || bullet[1] > 2559) {
            bullets.remove(i);
          } else if (backgrounds[stage][(int)bullet[2]][(int)bullet[1]] != 0) {
            bullets.remove(i);
            explosions.add(new int[] {
              5,
              15,
              0,
              (int)bullet[1],
              (int)bullet[2]
            });
          } else if (playerDying == 0 && fireWorks == 0
                && bullet[0] == 1 && dx * dx + dy * dy <= 64) {
            bullets.remove(i);
            playerDying = 64;
            explosions.add(new int[] {
              0,
              25,
              0,
              playerX,
              playerY
            });
          } else if (bullet[0] == 0) {
            for(int j = enemies.size() - 1; j >= 0; j--) {
              int[] enemy = (int[])enemies.get(j);
              dx = enemy[1] - bullet[1];
              dy = enemy[2] - bullet[2];
              if (dx * dx + dy * dy < enemy[5] * enemy[5]) {
                bullets.remove(i);
                explosions.add(new int[] {
                  0,
                  15,
                  0,
                  enemy[1],
                  enemy[2]
                });
                if (--enemy[10] == 0) {
                  enemies.remove(j);
                  explosions.add(new int[] {
                      0,
                      25,
                      0,
                      enemy[1],
                      enemy[2]
                    });
                  if (bossCreated && enemies.size() == 0) {
                    if (stage == 7 && !bossCreated2) {
                      bossCreated2 = true;
                      int color = random.nextInt(32);
                      for(int z = 0; z < 8; z++) {
                        int Y = random.nextInt(240);
                        enemies.add(new int[] {
                          0,
                          cameraX + 320 + random.nextInt(320),
                          Y,
                          Y,
                          16,
                          16,
                          random.nextInt(32),
                          0,
                          128,
                          1,
                          1,
                          random.nextInt(32),
                          -64
                        });
                      }
                      for(int z = 0; z < 24; z++) {
                        enemies.add(new int[] {
                          2,
                          cameraX + 336 + (z << 3),
                          z << 3,
                          -1,
                          1,
                          16,
                          0,
                          0,
                          256,
                          0,
                          64,
                          color,
                          0
                        });
                      }
                    } else {
                      fireWorks = 140;
                    }
                  }
                }
                break;
              }
            }
          }
          bullet[1] += bullet[3];
          bullet[2] += bullet[4];
        }

        // move explosions
        for(int i = explosions.size() - 1; i >= 0; i--) {
          int[] explosion = (int[])explosions.get(i);
          if (explosion[0] > explosion[1]) {
            explosions.remove(i);
          } else {
            explosion[0] += 5;
            explosion[2] ^= 1;
          }
        }

// -- UPDATE MODEL END ---------------------------------------------------------
        nextFrameStart += 28571429;
      } while(nextFrameStart < System.nanoTime());
// -- RENDER FRAME BEGIN -------------------------------------------------------

      imageGraphics.setColor(Color.BLACK);
      imageGraphics.fillRect(0, 0, 320, 240);

      // draw bullets
      for(int i = 0; i < bullets.size(); i++) {
        double[] bullet = (double[])bullets.get(i);
        imageGraphics.setColor(bullet[0] == 0 ? Color.GREEN : Color.YELLOW);
        imageGraphics.fillOval(
            (int)(bullet[1] - 2 - cameraX), (int)(bullet[2] - 2), 5, 5);
      }

      // draw enemies
      for(int i = 0; i < enemies.size(); i++) {
        int[] enemy = (int[])enemies.get(i);
        imageGraphics.setColor(enemyColors[enemy[11]]);
        imageGraphics.fillOval(
            enemy[1] - enemy[5] - cameraX,
            enemy[2] - enemy[5],
            enemy[5] << 1, enemy[5] << 1);
      }

      // draw explosions
      for(int i = 0; i < explosions.size(); i++) {
        int[] explosion = (int[])explosions.get(i);
        imageGraphics.setColor(explosion[2] == 0 ? Color.WHITE : Color.YELLOW);
        imageGraphics.fillOval(
            explosion[3] - cameraX - explosion[0],
            explosion[4] - explosion[0],
            explosion[0] << 1, explosion[0] << 1);
      }

      // draw player
      if (playerDying == 0) {
        imageGraphics.setColor(Color.RED);
        imageGraphics.fillOval(playerX - 9 - cameraX, playerY - 9, 18, 18);
      }

      // draw walls
      if (stage < 8) {
        imageGraphics.drawImage(backgroundImages[stage], -cameraX, 0, null);
      } else {
        imageGraphics.setColor(Color.PINK);
        imageGraphics.drawString("CONGRATULATIONS!", 100, 32);
        imageGraphics.drawString("THE END", 135, 64);
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

  public int C(double angle, double light, double dark) {
    return 0xFF000000
        | (D(angle, light, dark) << 16)
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

