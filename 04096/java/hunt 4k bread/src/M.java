/*
 * Hunt 4k Bread
 * Copyright (C) 2009 Michael Birken
 *
 * This file is part of Hunt 4k Bread.
 *
 * Hunt 4k Bread is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Hunt 4k Bread is distributed in the hope that it will be useful,
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

  final boolean[] K = new boolean[65535]; // pressed keys

  public M() {

    Color pink = new Color(0xAFFFAFAF, true);
    Color blue = new Color(0xAFAFAFFF, true);
    Color white = new Color(0xAFFFFFFF, true);
        
    int playerX = 0;
    int playerY = 0;
    double bulletX = 0;
    double bulletY = 0;
    double bulletVx = 0;
    double bulletVy = 0;
    int cameraX = 0;
    int cameraY = 0;
    int spriteStep = 0;
    int playerHealth = 0; 
    int maxCameraX = 0;
    int maxCameraY = 0;
    int light = 0;
    int blinking = 0;
    int freeze = 0;
    int stage = 1;

    Point point = null;
    ArrayList slices = null;
    Random random = null;
    int[][] map = null;
    int[][] slicesMap = null;
    int[] pixels = new int[65536];

    // decompress sprites
    int[][][] sprites = new int[9][16][16];
    int[][] spriteColors = {
      { 0x406870, 0x305860 },
      { 0, 0xFF0000 },
      { 0xFFFFFF, 0xFF0000 },
      { 0x87D2F1, 0x1F8ABE },
      { 0x9F6B6F, 0x8F5B5F },
      { 0xFE050D, 0xCB0907 },
      { 0xBDA05A, 0xAE914B },
      { 0xECE6D4, 0 },
      { 0xFFEF9A, 0 },
    };
    for(int i = 0; i < 9; i++) {
      for(int y = 0; y < 16; y++) {
        int c = "\ue0c0\ub870\ueedc\ufbf7\uf7fb\udcee\u70b8\uc0e0\u60c0\u1830\uc6ec\uc4fc\u1424\ua616\ufcfc\uf8fe\u18e0\u0204\u8182\uf181\u81f1\u8281\u0402\ue018\u03fe\u05fd\u55af\u05af\uaf05\uaf55\ufd05\ufe03\ue0c0\ub870\ueedc\ufbf7\uf7fb\udcee\u70b8\uc0e0\u701c\u0002\u071c\ue183\u0800\u7e00\ue0f8\u4600\ue0c0\ub870\ueedc\ufbf7\uf7fb\udcee\u70b8\uc0e0\u030f\u0101\u0000\u0100\u0000\u0000\u0000\u0100\u070f\u0101\u0000\u0000\u0001\u0000\u0000\u2301".charAt((y >> 1) + (i << 3));
        if ((y&1) == 1) {
          c >>= 8;
        }
        for(int x = 0; x < 8; x++) {
          sprites[i][y][15 - x] = sprites[i][y][x]
              = spriteColors[i][(c & (1 << x)) == 0 ? 0 : 1];
        }
      }
    }

    BufferedImage image = new BufferedImage(
        256, 256, BufferedImage.TYPE_INT_RGB);
    Graphics imageGraphics = image.getGraphics();

    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(512, 512));
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    enableEvents(AWTEvent.MOUSE_EVENT_MASK|AWTEvent.MOUSE_MOTION_EVENT_MASK
        |AWTEvent.KEY_EVENT_MASK);
    pack();
    setLocationRelativeTo(null);
    show();

    long nextFrameStart = System.nanoTime();
    while(true) {
      do {
// -- UPDATE MODEL BEGIN -------------------------------------------------------

        spriteStep++;

        if (stage == 9) {
          setTitle("Congratulations!");
        } else if (blinking > 0) {
          blinking--;
          if (blinking == 0) {
            playerHealth = 0;
            stage++;
          }
        } else {

          if (playerHealth <= 0) {
            setTitle("Hunt 4k Bread -- Stage " + stage);
            int size = stage + 4;

            playerX = 64;
            playerY = 64;
            bulletX = -1;
            playerHealth = 100;
            maxCameraX = ((1 + (size << 3)) << 4) - 257;
            maxCameraY = ((1 + (size << 3)) << 4) - 257;
            light = 32;
            freeze = 0;

            // generate maze
            random = new Random(stage + 1);
            map = new int[256][256];
            for(int y = 0; y < size; y++) {
              for(int x = 0; x < size; x++) {
                for(int i = 0; i < 8; i++) {
                  map[(y << 3)][(x << 3) + i] = map[(y << 3) + i][(x << 3)] = 1;
                }
              }
            }
            int[][] offsets = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } };
            ArrayList queue = new ArrayList();
            int[][] marks = new int[size][size];
            int count = 0;
            marks[0][0] = ++count;
            queue.add(new int[] { 0, 0 });
            while(queue.size() > 0) {
              int[] point2 = (int[])queue.remove(random.nextInt(queue.size()));
              for(int i = 0; i < 4; i++) {
                int x = point2[0] + offsets[i][0];
                int y = point2[1] + offsets[i][1];
                if (x >= 0 && y >= 0 && x < size && y < size && marks[y][x] == 0) {
                  for(int p = 1; p < 8; p++) {
                    for(int q = 1; q < 8; q++) {
                      map[p + (point2[1] << 3) + offsets[i][1]]
                         [q + (point2[0] << 3) + offsets[i][0]] = 0;
                    }
                  }
                  queue.add(point2);
                  queue.add(new int[] { x, y } );
                  marks[y][x] = ++count;
                  break;
                }
              }
            }
            for(int i = 0; i < 1 + (size << 3); i++) {
              map[size << 3][i] = map[i][size << 3] = 1;
            }

            for(int j = 0; j < 2; j++) {
              for(int i = 0; i < stage << 1; ) {
                int x = 1 + random.nextInt(size - 2);
                int y = 1 + random.nextInt(size - 2);
                if (marks[y][x] > 0) {
                  marks[y][x] = -1;
                  i++;
                  for(int a = 0; a < 3; a++) {
                    for(int b = 0; b < 3; b++) {
                      map[(y << 3) + a + 3][(x << 3) + b + 3] = j + 6;
                    }
                  }
                }
              }
            }

            for(int i = 0; i < stage << 1; ) {
              int x = 1 + random.nextInt(size - 2);
              int y = 1 + random.nextInt(size - 2);
              if (marks[y][x] > 0) {
                marks[y][x] = -1;
                i++;
                for(int a = 0; a < 7; a++) {
                  for(int b = 0; b < 7; b++) {
                    map[(y << 3) + a + 1][(x << 3) + b + 1] = 5;
                  }
                }
              }
            }

            for(int i = 0; i < 3; i++) {
              int total = 0;
              while(total < stage + 4) {
                int x = random.nextInt(1 + (size << 3));
                int y = random.nextInt(1 + (size << 3));
                if (map[y][x] == 0 && x > 8 && y > 8) {
                  total++;
                  map[y][x] = i + 2;
                }
              }
            }
            
            slices = new ArrayList();
            slicesMap = new int[512][512];
            outter: while(slices.size() < 25 * size) {
              int[] slice = { random.nextInt(size << 3) << 4, random.nextInt(size << 3) << 4 };
              if (slice[0] < 350 && slice[1] < 270) {
                continue;
              }
              for(int y = 0; y <= 16; y += 8) {
                for(int x = 0; x <= 16; x += 8) {
                  if (map[(slice[1] + y) >> 4][(slice[0] + x) >> 4] != 0
                      || slicesMap[(slice[1] + y) >> 3][(slice[0] + x) >> 3] != 0) {
                    continue outter;
                  }
                }
              }
              for(int y = 0; y <= 16; y += 8) {
                for(int x = 0; x <= 16; x += 8) {
                  slicesMap[(slice[1] + y) >> 3][(slice[0] + x) >> 3] = 1;
                }
              }
              slices.add(slice);
            }
            nextFrameStart = System.nanoTime();
          }

          // move player
          if (light > 32) {
            light--;
          }
          if (freeze > 0) {
            freeze--;
          }
          int newPlayerX = playerX;
          int newPlayerY = playerY;
          Point _point = panel.getMousePosition();
          point = _point == null ? point : _point;
          if (point != null && bulletX < 0 && (K[KeyEvent.VK_SPACE] || K[0])) {
            K[0] = false;
            double tailX = playerX - cameraX + 8;
            double tailY = playerY - cameraY + 8;
            double ux = (point.x >> 1) - tailX;
            double uy = (point.y >> 1) - tailY;
            double mag = Math.sqrt(ux * ux + uy * uy);
            bulletX = playerX + 8;
            bulletY = playerY + 8;
            bulletVx = 6 * ux / mag;
            bulletVy = 6 * uy / mag;
          }
          int speed = 2;
          if (map[(playerY + 8) >> 4][(playerX + 8) >> 4] == 5) {
            speed = 1;
          }
          if (K[KeyEvent.VK_W]) {
            newPlayerY = playerY - speed;
          } else if (K[KeyEvent.VK_S]) {
            newPlayerY = playerY + speed;
          }
          if (K[KeyEvent.VK_A]) {
            newPlayerX = playerX - speed;
          } else if (K[KeyEvent.VK_D]) {
            newPlayerX = playerX + speed;
          }
          outter: {
            for(int i = 0; i <= 16; i += 8) {
              for(int j = 0; j <= 16; j += 8) {
                int value = map[(i + newPlayerY) >> 4][(j + newPlayerX) >> 4];
                if (value == 1) {
                  break outter;
                } else if (value == 2) {
                  map[(i + newPlayerY) >> 4][(j + newPlayerX) >> 4] = 0;
                  light = 600;
                  break outter;
                } else if (value == 3) {
                  map[(i + newPlayerY) >> 4][(j + newPlayerX) >> 4] = 0;
                  playerHealth = 100;
                  break outter;
                } else if (value == 4) {
                  map[(i + newPlayerY) >> 4][(j + newPlayerX) >> 4] = 0;
                  freeze = 300;
                  break outter;
                } else if (value == 6) {
                  playerHealth--;
                }
              }
            }
            playerX = newPlayerX;
            playerY = newPlayerY;
          }

          // move camera
          cameraX = playerX - 128;
          cameraY = playerY - 128;
          if (cameraX < 0) {
            cameraX = 0;
          }
          if (cameraY < 0) {
            cameraY = 0;
          }
          if (cameraX > maxCameraX) {
            cameraX = maxCameraX;
          }
          if (cameraY > maxCameraY) {
            cameraY = maxCameraY;
          }

          // move slices
          for(int i = slices.size() - 1; i >= 0; i--) {
            int[] slice = (int[])slices.get(i);
            if (slice[0] >= cameraX - 16 && slice[0] < cameraX + 336
                && slice[1] >= cameraY - 16 && slice[1] < cameraY + 256) {
              int newsliceX = slice[0];
              int newsliceY = slice[1];
              if ((playerX >= newsliceX && playerX < newsliceX + 16
                 && playerY >= newsliceY && playerY < newsliceY + 16)
                 || (playerX + 16 >= newsliceX && playerX < newsliceX
                 && playerY + 16 >= newsliceY && playerY < newsliceY)) {
                playerHealth--;
              }
              for(int y = 0; y <= 16; y += 8) {
                for(int x = 0; x <= 16; x += 8) {
                  slicesMap[(slice[1] + y) >> 3][(slice[0] + x) >> 3] = 0;
                }
              }
              if (bulletX >= newsliceX && bulletY >= newsliceY
                  && bulletX < newsliceX + 16 && bulletY < newsliceY + 16) {
                bulletX = -1;
                slices.remove(i);
                if (slices.size() == 0) {
                  blinking = 180;
                }
              } else {
                if (freeze == 0) {
                  if (newsliceY > playerY) {
                    newsliceY--;
                  } else if (newsliceY < playerY) {
                    newsliceY++;
                  }
                  if (newsliceX > playerX) {
                    newsliceX--;
                  } else if (newsliceX < playerX) {
                    newsliceX++;
                  }
                  outter: {
                    for(int y = 0; y <= 16; y += 8) {
                      for(int x = 0; x <= 16; x += 8) {
                        int value = map[(y + slice[1]) >> 4][(x + newsliceX) >> 4];
                        if ((value > 0 && value != 5)
                            || slicesMap[(y + slice[1]) >> 3][(x + newsliceX) >> 3] != 0) {
                          break outter;
                        }
                      }
                    }
                      slice[0] = newsliceX;
                  }
                  outter: {
                    for(int y = 0; y <= 16; y += 8) {
                      for(int x = 0; x <= 16; x += 8) {
                        int value = map[(y + newsliceY) >> 4][(x + slice[0]) >> 4];
                        if ((value > 0 && value != 5)
                            || slicesMap[(y + newsliceY) >> 3][(x + slice[0]) >> 3] != 0) {
                          break outter;
                        }
                      }
                    }
                    slice[1] = newsliceY;
                  }
                }
                for(int y = 0; y <= 16; y += 8) {
                  for(int x = 0; x <= 16; x += 8) {
                    slicesMap[(slice[1] + y) >> 3][(slice[0] + x) >> 3] = 1;
                  }
                }
              }
            }
          }

          // move bullet
          if (bulletX >= 0) {
            int value = map[(int)bulletY >> 4][(int)bulletX >> 4];
            if ((value == 0 || value == 5 || value == 7)
                && bulletX >= cameraX && bulletX < cameraX + 256
                && bulletY >= cameraY && bulletY < cameraY + 256) {
              bulletX += bulletVx;
              bulletY += bulletVy;
            } else {
              bulletX = -1;
            }
          }
        }

// -- UPDATE MODEL END ---------------------------------------------------------
        nextFrameStart += 16666667;
      } while(nextFrameStart < System.nanoTime());
// -- RENDER FRAME BEGIN -------------------------------------------------------

      int offsetX = (cameraX & 15);
      int offsetY = (cameraY & 15);

      Arrays.fill(pixels, 0);
      Point _point = panel.getMousePosition();
      point = _point == null ? point : _point;
      if (point != null) {
        for(int i = 0; i < 1024; i++) {
          double tailX = playerX - cameraX + 8;
          double tailY = playerY - cameraY + 8;
          double headX = 0;
          double headY = 0;
          if (i < 256) {
            headX = i;
          } else if (i < 512) {
            headX = i - 256;
            headY = 255;
          } else if (i < 768) {
            headY = i - 512;
          } else {
            headY = i - 768;
            headX = 255;
          }
          double vx = headX - tailX;
          double vy = headY - tailY;
          double ux = (point.x >> 1) - tailX;
          double uy = (point.y >> 1) - tailY;
          double mag = Math.sqrt(ux * ux + uy * uy);
          ux /= mag;
          uy /= mag;
          mag = Math.sqrt(vx * vx + vy * vy);
          vx /= mag;
          vy /= mag;
          boolean inBeam = vx * ux + vy * uy > 0.7;
          vx *= 0.7;
          vy *= 0.7;
          double x = tailX;
          double y = tailY;
          while(x >= 0 && y >= 0 && x < 256 && y < 256) {
            if (!inBeam) {
              double dx = x - tailX;
              double dy = y - tailY;
              if (dx * dx + dy * dy > light * light) {
                break;
              }
            }
            int value = map[((int)(cameraY + y)) >> 4][((int)(cameraX + x)) >> 4];
            if (value == 1) {
              break;
            }
            int Y = 15 & (((int)y) + offsetY);
            int X = 15 & (((int)x) + offsetX);
            int pixel = sprites[0][Y][X];
            if ((X == 0 && map[((int)(cameraY + y)) >> 4][((int)(cameraX + x - 1)) >> 4] == 1)
                  || (X == 15 && map[((int)(cameraY + y)) >> 4][((int)(cameraX + x + 1)) >> 4] == 1)
                  || (Y == 0 && map[((int)(cameraY + y - 1)) >> 4][((int)(cameraX + x)) >> 4] == 1)
                  || (Y == 15 && map[((int)(cameraY + y + 1)) >> 4][((int)(cameraX + x)) >> 4] == 1)) {
              pixel = 0xFFCB3E;
            }
            if (value > 1 && sprites[value - 1][Y][X] > 0 && !(value == 5 && pixel == 0xFFCB3E)) {
              pixel = sprites[value - 1][Y][X];
            }
            pixels[(((int)y) << 8) + (int)x] = pixel;
            x += vx;
            y += vy;
          }
        }
      }

      for(int y = 0; y < 16; y++) {
        for(int x = 0; x < 16; x++) {
          if (sprites[8][y][x] != 0) {
            int X = playerX - cameraX + x;
            int Y = playerY - cameraY + y;
            if (X >= 0 && X < 256 && Y >= 0 && Y < 256
                && pixels[(Y << 8) + X] != 0) {
              pixels[(Y << 8) + X] = sprites[8][y][x];
            }
          }
        }
      }

      for(int i = 0; i < slices.size(); i++) {
        int[] slice = (int[])slices.get(i);
        if (slice[0] >= cameraX - 16 && slice[0] < cameraX + 272
            && slice[1] >= cameraY - 16 && slice[1] < cameraY + 272) {
          for(int y = 0; y < 16; y++) {
            for(int x = 0; x < 16; x++) {
              if (sprites[7][y][x] != 0) {
                int X = slice[0] - cameraX + x;
                int Y = slice[1] - cameraY + y;
                if (X >= 0 && X < 256 && Y >= 0 && Y < 256
                    && pixels[(Y << 8) + X] != 0) {
                  pixels[(Y << 8) + X] = sprites[7][y][x];
                }
              }
            }
          }
        }
      }
      
      if (bulletX > 0) {
        for(int y = 0; y < 5; y++) {
          for(int x = 0; x < 5; x++) {
            int X = (int)bulletX - cameraX - 2 + x;
            int Y = (int)bulletY - cameraY - 2 + y;
            if (X >= 0 && X < 256 && Y >= 0 && Y < 256
                && pixels[(Y << 8) + X] != 0) {
              pixels[(Y << 8) + X] = 0xFFEF9A;
            }
          }
        }
      }

      image.setRGB(0, 0, 256, 256, pixels, 0, 256);

      imageGraphics.setColor(
          playerHealth < 25 && (spriteStep&8) == 0 ? white : pink);
      imageGraphics.fillRect(153, 2, playerHealth, 12);
      imageGraphics.setColor((blinking > 0 && (spriteStep&8) == 0) ? white : blue);
      imageGraphics.fillRect(2, 2, 100 - 100 * slices.size() / (25 * (stage + 4)), 12);
      imageGraphics.setColor(white);
      imageGraphics.drawRect(153, 2, 100, 12);
      imageGraphics.drawRect(2, 2, 100, 12);

      Graphics panelGraphics = panel.getGraphics();
      if (panelGraphics != null) {
        panelGraphics.drawImage(image, 0, 0, 512, 512, null);
        panelGraphics.dispose();
      }

// -- RENDER FRAME END ---------------------------------------------------------
      long remaining = nextFrameStart - System.nanoTime();
      if (remaining > 0) {
        try {
          Thread.sleep(remaining / 1000000);
        } catch(Throwable t) {
        }
      } else {
        Thread.yield();
      }
    }
  }

  public void processEvent(AWTEvent e) {
    int id = e.getID();
    if (id == KeyEvent.KEY_PRESSED || id == KeyEvent.KEY_RELEASED) {
      K[((KeyEvent)e).getKeyCode()] = (id == 401);
    }
    K[0] |= (id == MouseEvent.MOUSE_PRESSED);
    if (id == WindowEvent.WINDOW_CLOSING
        || (id == KeyEvent.KEY_PRESSED
            && ((KeyEvent)e).getKeyCode() == KeyEvent.VK_ESCAPE)) {
      System.exit(0);
    }
  }

  public static void main(String[] args) {
    new M();
  }
}

