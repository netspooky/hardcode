/*
 * Invaders
 * Copyright (C) 2009 Michael Birken
 *
 * This file is part of Invaders.
 *
 * Invaders is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Invaders is distributed in the hope that it will be useful,
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
    int playerDirection = 0;
    int bulletX = 0;
    int bulletY = 0;
    int bulletVx = 0;
    int bulletVy = 0;
    int cameraX = 0;
    int cameraY = 0;
    int spriteStep = 0;
    int playerHealth = 0;
    int diamonds = 0;    
    int keys = 0;
    int maxCameraX = 0;
    int maxCameraY = 0;
    int shields = 0;
    int boom = 0;
    int blinking = 0;
    int stagePoints = 0;
    int score = 0;
    int stage = 1;

    ArrayList invaders = null;
    ArrayList generators = null;
    Random random = null;
    int[][] map = null;
    int[][] invaderMap = null;

    // decompress sprites
    BufferedImage[][] sprites = new BufferedImage[11][4];
    int[][] pixels = new int[4][256];
    int[][] spriteColors = {
      { 0, 0xFF00FF00 },
      { 0, 0xFF00FF00 },
      { 0xFF777777, 0xFFAAAAAA },
      { 0, 0xFFFF0000 },
      { 0, 0xFF00FFF0 },
      { 0, 0xFFFFD700 },
      { 0xFFFFFFFF, 0xFFFF0000 },
      { 0xFFC0C0C0, 0xFFFFD700 },
      { 0, 0xFFFFD700 },
      { 0xFFC07000, 0xFF623900 },
      { 0, 0xFFD53014 },
    };
    for(int i = 0; i < 11; i++) {
      for(int y = 0; y < 16; y++) {
        int c = "\uc204\ufaf2\u89f9\uc88f\uf478\u50e3\uf878\u42e4\uc000\ufcf4\u89fa\ucb8d\uf778\u50e0\uf678\u40e1\u619f\u2a11\u4102\u0981\u0216\u1182\u2121\uc33d\uffde\uffff\u754b\u3b45\ufe7f\u1e1e\uf87c\u80e0\u18f0\u2214\u29c7\u1111\u1111\uc729\u1422\uf018\u221c\u4141\u2241\u081c\u0808\u0808\u0878\u7808\u01ff\u0101\u8181\uf181\u81f1\u8181\u0101\uff01\ue5fe\u79f9\ue751\u79f5\u8fc9\uf989\uf3fb\ufec3\uc381\ubfff\u8383\uffc3\uc6fe\u988c\uf0b8\u80c0\u41fe\u4931\u0555\u2901\u6111\u4d93\u3141\ufe01\uf8f8\u8080\ufffe\uff03\u63f7\ub7b7\uffb7\ufe03".charAt((y >> 1) + (i << 3));
        if ((y&1) == 1) {
          c >>= 8;
        }
        for(int x = 0; x < 8; x++) {
          int value = pixels[0][(y << 4) + x]
              = spriteColors[i][(c & (1 << x)) == 0 ? 0 : 1];
          pixels[0][(y << 4) + 15 - x] = (i != 5) ? value : 0;
        }
      }
      for(int y = 0; y < 16; y++) {
        for(int x = 0; x < 16; x++) {
          pixels[1][(x << 4) + 15 - y] = pixels[2][((15 - y) << 4) + 15 - x]
              = pixels[3][((15 - x) << 4) + y] = pixels[0][(y << 4) + x];
        }
      }
      for(int j = 0; j < 4; j++) {
        sprites[i][j] = new BufferedImage(16, 16, BufferedImage.TYPE_INT_ARGB);
        sprites[i][j].setRGB(0, 0, 16, 16, pixels[j], 0, 16);
      }
    }

    BufferedImage image = new BufferedImage(
        320, 240, BufferedImage.TYPE_INT_RGB);
    Graphics imageGraphics = image.getGraphics();

    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    setIconImage(sprites[0][0]);
    pack();
    setLocationRelativeTo(null);
    show();

    long nextFrameStart = System.nanoTime();
    while(true) {
      do {
// -- UPDATE MODEL BEGIN -------------------------------------------------------

        spriteStep++;

        if (stage == 9) {
          setTitle("WIN! " + score);
        } else if (blinking > 0) {
          blinking--;
          if (blinking == 0) {
            score += stagePoints;
            stagePoints = playerHealth = 0;
            stage++;
          }
        } else {

          if (playerHealth <= 0) {
            setTitle("Stage " + stage);
            int size = stage + 4;

            playerX = 64;
            playerY = 64;
            bulletX = -1;
            playerHealth = 100;
            diamonds = stage + 3;
            maxCameraX = ((1 + (size << 3)) << 4) - 321;
            maxCameraY = ((1 + (size << 3)) << 4) - 241;
            stagePoints = 0;
            boom = 0;
            shields = 0;

            // generate maze
            random = new Random(stage);
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
              int[] point = (int[])queue.remove(random.nextInt(queue.size()));
              for(int i = 0; i < 4; i++) {
                int x = point[0] + offsets[i][0];
                int y = point[1] + offsets[i][1];
                if (x >= 0 && y >= 0 && x < size && y < size && marks[y][x] == 0) {
                  for(int p = 1; p < 8; p++) {
                    for(int q = 1; q < 8; q++) {
                      map[p + (point[1] << 3) + offsets[i][1]]
                         [q + (point[0] << 3) + offsets[i][0]] = 0;
                    }
                  }
                  queue.add(point);
                  queue.add(new int[] { x, y } );
                  marks[y][x] = ++count;
                  break;
                }
              }
            }
            for(int i = 0; i < 1 + (size << 3); i++) {
              map[size << 3][i] = map[i][size << 3] = 1;
            }
            keys = 0;
            while (keys < stage) {
              int x = random.nextInt(size);
              int y = random.nextInt(size);
              if (marks[y][x] > 2) {
                keys++;
                for(int i = 1; i < 8; i++) {
                  for(int j = 1; j < 8; j++) {
                    map[(y << 3) + i][(x << 3) + j] = 8;
                  }
                }
                marks[y][x] = -1;
              }
            }

            keys = 0;
            while(keys < (stage + 3)) {
              int x1 = random.nextInt(size);
              int y1 = random.nextInt(size);
              int x2 = random.nextInt(size);
              int y2 = random.nextInt(size);
              int x3 = random.nextInt(size);
              int y3 = random.nextInt(size);
              if (marks[y1][x1] < 2 || marks[y2][x2] < 2 || marks[y3][x3] < 2) {
                continue;
              }
              if (marks[y1][x1] < marks[y2][x2] && marks[y2][x2] < marks[y3][x3]) {
                keys++;
                map[(y1 << 3) + random.nextInt(6) + 1][(x1 << 3) + random.nextInt(6) + 1] = 3;
                map[(y3 << 3) + random.nextInt(6) + 1][(x3 << 3) + random.nextInt(6) + 1] = 2;
                for(int i = 1; i < 8; i++) {
                  for(int j = 1; j < 8; j++) {
                    map[(y2 << 3) + i][(x2 << 3) + j] = 4;
                  }
                }
                marks[y1][x1] = marks[y2][x2] = marks[y3][x3] = -1;
              }
            }

            while(true) {
              int x = random.nextInt(1 + (size << 3));
              int y = random.nextInt(1 + (size << 3));
              if (map[y][x] == 0) {
                map[y][x] = 9;
                break;
              }
            }

            keys = 0;
            while(keys < stage) {
              int x = random.nextInt(1 + (size << 3));
              int y = random.nextInt(1 + (size << 3));
              if (map[y][x] == 0) {
                keys++;
                map[y][x] = 7;
              }
            }

            generators = new ArrayList();
            keys = 0;
            while(keys < stage) {
              int x = random.nextInt(1 + (size << 3));
              int y = random.nextInt(1 + (size << 3));
              if (map[y][x] == 0) {
                keys++;
                map[y][x] = 6;
                generators.add(new int[] { x << 4, y << 4 });
              }
            }

            keys = 0;
            while(keys < 5) {
              int x = random.nextInt(1 + (size << 3));
              int y = random.nextInt(1 + (size << 3));
              if (map[y][x] == 0) {
                keys++;
                map[y][x] = 5;
              }
            }
            keys = 0;

            invaders = new ArrayList();
            invaderMap = new int[512][512];
            outter: while(invaders.size() < 25 * size) {
              int[] invader = { random.nextInt(size << 3) << 4, random.nextInt(size << 3) << 4, 0 };
              if (invader[0] < 350 && invader[1] < 270) {
                continue;
              }
              for(int y = 0; y <= 16; y += 8) {
                for(int x = 0; x <= 16; x += 8) {
                  if (map[(invader[1] + y) >> 4][(invader[0] + x) >> 4] != 0
                      || invaderMap[(invader[1] + y) >> 3][(invader[0] + x) >> 3] != 0) {
                    continue outter;
                  }
                }
              }
              for(int y = 0; y <= 16; y += 8) {
                for(int x = 0; x <= 16; x += 8) {
                  invaderMap[(invader[1] + y) >> 3][(invader[0] + x) >> 3] = 1;
                }
              }
              invaders.add(invader);
            }
            nextFrameStart = System.nanoTime();
          }

          // move player
          if (shields > 0) {
            shields--;
          }
          if (boom > 0) {
            boom--;
          }
          int newPlayerX = playerX;
          int newPlayerY = playerY;
          if (K[KeyEvent.VK_UP]) {
            playerDirection = 2;
            newPlayerY = playerY - 2;
          } else if (K[KeyEvent.VK_DOWN]) {
            playerDirection = 0;
            newPlayerY = playerY + 2;
          }
          if (K[KeyEvent.VK_LEFT]) {
            playerDirection = 1;
            newPlayerX = playerX - 2;
          } else if (K[KeyEvent.VK_RIGHT]) {
            playerDirection = 3;
            newPlayerX = playerX + 2;
          }
          if (K[KeyEvent.VK_X]) {
            playerHealth = 0;
          }
          outter: {
            for(int i = 0; i <= 16; i += 8) {
              for(int j = 0; j <= 16; j += 8) {
                int value = map[(i + newPlayerY) >> 4][(j + newPlayerX) >> 4];
                if (value == 1 || value == 6 || value == 8) {
                  break outter;
                } else if (value == 2) {
                  map[(i + newPlayerY) >> 4][(j + newPlayerX) >> 4] = 0;
                  diamonds--;
                  stagePoints += 2500;
                  if (diamonds == 0) {
                    stagePoints += 10000;
                    blinking = 180;
                  }
                  break outter;
                } else if (value == 3) {
                  map[(i + newPlayerY) >> 4][(j + newPlayerX) >> 4] = 0;
                  keys++;
                  stagePoints += 75;
                  break outter;
                } else if (value == 4) {
                  if (keys > 0) {
                    keys--;
                    int y = ((i + newPlayerY) >> 7) << 3;
                    int x = ((j + newPlayerX) >> 7) << 3;
                    for(int p = 1; p < 8; p++) {
                      for(int q = 1; q < 8; q++) {
                        map[y + p][x + q] = 0;
                      }
                    }
                    break outter;
                  } else {
                    break outter;
                  }
                } else if (value == 5) {
                  playerHealth = 100;
                  stagePoints += 750;
                  map[(i + newPlayerY) >> 4][(j + newPlayerX) >> 4] = 0;
                  break outter;
                } else if (value == 7) {
                  map[(i + newPlayerY) >> 4][(j + newPlayerX) >> 4] = 0;
                  shields = 600;
                  stagePoints += 500;
                  break outter;
                } else if (value == 9) {
                  map[(i + newPlayerY) >> 4][(j + newPlayerX) >> 4] = 0;
                  boom = 6;
                  break outter;
                }
              }
            }
            playerX = newPlayerX;
            playerY = newPlayerY;
          }
          if (K[KeyEvent.VK_D] && bulletX < 0) {
            bulletX = playerX + 7;
            bulletY = playerY + 7;
            if (playerDirection == 0) {
              bulletVx = 0;
              bulletVy = 6;
            } else if (playerDirection == 1) {
              bulletVx = -6;
              bulletVy = 0;
            } else if (playerDirection == 2) {
              bulletVx = 0;
              bulletVy = -6;
            } else if (playerDirection == 3) {
              bulletVx = 6;
              bulletVy = 0;
            }
          }

          // move camera
          cameraX = playerX - 144;
          cameraY = playerY - 104;
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

          // update generators
          outter: for(int i = generators.size() - 1; i >= 0; i--) {
            int[] generator = (int[])generators.get(i);
            if (generator[0] >= cameraX - 16 && generator[0] < cameraX + 336
                && generator[1] >= cameraY - 16 && generator[1] < cameraY + 256) {
              if (bulletX >= generator[0] && bulletY >= generator[1]
                  && bulletX < generator[0] + 16 && bulletY < generator[1] + 16) {
                bulletX = -1;
                map[generator[1] >> 4][generator[0] >> 4] = 0;
                generators.remove(i);
                stagePoints += 1000;
                continue;
              }

              if (spriteStep % 30 == 0) {
                for(int y = 0; y <= 16; y += 8) {
                  for(int x = 0; x <= 16; x += 8) {
                    if (invaderMap[(generator[1] + y) >> 3][(generator[0] + x) >> 3] != 0) {
                      continue outter;
                    }
                  }
                }
                invaders.add(new int[] { generator[0], generator[1], 0 });
                for(int y = 0; y <= 16; y += 8) {
                  for(int x = 0; x <= 16; x += 8) {
                    invaderMap[(generator[1] + y) >> 3][(generator[0] + x) >> 3] = 1;
                  }
                }
              }
            }
          }

          // move invaders
          for(int i = invaders.size() - 1; i >= 0; i--) {
            int[] invader = (int[])invaders.get(i);
            if (invader[0] >= cameraX - 16 && invader[0] < cameraX + 336
                && invader[1] >= cameraY - 16 && invader[1] < cameraY + 256) {
              int newInvaderX = invader[0];
              int newInvaderY = invader[1];
              if ((playerX >= newInvaderX && playerX < newInvaderX + 16
                 && playerY >= newInvaderY && playerY < newInvaderY + 16)
                 || (playerX + 16 >= newInvaderX && playerX < newInvaderX
                 && playerY + 16 >= newInvaderY && playerY < newInvaderY)) {
                playerHealth--;
              }
              for(int y = 0; y <= 16; y += 8) {
                for(int x = 0; x <= 16; x += 8) {
                  invaderMap[(invader[1] + y) >> 3][(invader[0] + x) >> 3] = 0;
                }
              }
              if (shields > 0) {
                int dx = invader[0] - playerX;
                int dy = invader[1] - playerY;
                if (dx * dx + dy * dy <= 1024) {
                  invaders.remove(i);
                  stagePoints += 50;
                  continue;
                }
              }
              if (boom > 0) {
                invaders.remove(i);
                stagePoints += 10;
                continue;
              }
              if (bulletX >= newInvaderX && bulletY >= newInvaderY
                  && bulletX < newInvaderX + 16 && bulletY < newInvaderY + 16) {
                bulletX = -1;
                invaders.remove(i);
                stagePoints += 100;
              } else {
                if (Math.abs(playerX - newInvaderX) > Math.abs(playerY - newInvaderY)) {
                  if (newInvaderY > playerY) {
                    newInvaderY--;
                    invader[2] = 2;
                  } else if (newInvaderY < playerY) {
                    newInvaderY++;
                    invader[2] = 0;
                  }
                  if (newInvaderX > playerX) {
                    newInvaderX--;
                    invader[2] = 1;
                  } else if (newInvaderX < playerX) {
                    newInvaderX++;
                    invader[2] = 3;
                  }
                } else {
                  if (newInvaderX > playerX) {
                    newInvaderX--;
                    invader[2] = 1;
                  } else if (newInvaderX < playerX) {
                    newInvaderX++;
                    invader[2] = 3;
                  }
                  if (newInvaderY > playerY) {
                    newInvaderY--;
                    invader[2] = 2;
                  } else if (newInvaderY < playerY) {
                    newInvaderY++;
                    invader[2] = 0;
                  }
                }
                outter: {
                  for(int y = 0; y <= 16; y += 8) {
                    for(int x = 0; x <= 16; x += 8) {
                      int value = map[(y + invader[1]) >> 4][(x + newInvaderX) >> 4];
                      if ((value > 0 && value < 6 || value >= 8)
                          || invaderMap[(y + invader[1]) >> 3][(x + newInvaderX) >> 3] != 0) {
                        break outter;
                      }
                    }
                  }
                  invader[0] = newInvaderX;
                }
                outter: {
                  for(int y = 0; y <= 16; y += 8) {
                    for(int x = 0; x <= 16; x += 8) {
                      int value = map[(y + newInvaderY) >> 4][(x + invader[0]) >> 4];
                      if ((value > 0 && value < 6 || value >= 8)
                          || invaderMap[(y + newInvaderY) >> 3][(x + invader[0]) >> 3] != 0) {
                        break outter;
                      }
                    }
                  }
                  invader[1] = newInvaderY;
                }
                for(int y = 0; y <= 16; y += 8) {
                  for(int x = 0; x <= 16; x += 8) {
                    invaderMap[(invader[1] + y) >> 3][(invader[0] + x) >> 3] = 1;
                  }
                }
              }
            }
          }

          // move bullet
          if (bulletX >= 0) {
            if (map[bulletY >> 4][bulletX >> 4] == 0
                && bulletX >= cameraX && bulletX < cameraX + 320
                && bulletY >= cameraY && bulletY < cameraY + 240) {
              bulletX += bulletVx;
              bulletY += bulletVy;
            } else {
              if (map[bulletY >> 4][bulletX >> 4] == 8) {
                map[bulletY >> 4][bulletX >> 4] = 0;
                stagePoints += 5;
              }
              bulletX = -1;
            }
          }
        }

// -- UPDATE MODEL END ---------------------------------------------------------
        nextFrameStart += 16666667;
      } while(nextFrameStart < System.nanoTime());
// -- RENDER FRAME BEGIN -------------------------------------------------------

      imageGraphics.setColor(boom == 0 ? Color.BLACK : Color.WHITE);
      imageGraphics.fillRect(0, 0, 320, 240);
      
      int offsetX = (cameraX & 15);
      int offsetY = (cameraY & 15);
      imageGraphics.setColor(Color.WHITE);
      if (bulletX > 0) {        
        imageGraphics.fillRect(bulletX - cameraX - 2, bulletY - cameraY - 2, 5, 5);
      }
      for(int y = 0; y < 16; y++) {
        for(int x = 0; x < 21; x++) {
          int value = map[y + (cameraY >> 4)][x + (cameraX >> 4)];
          if (value > 0) {
            if (value == 4) {
              imageGraphics.fillRect(
                  (x << 4) - offsetX, (y << 4) - offsetY, 16, 16);
            } else {
              imageGraphics.drawImage(
                  sprites[value >= 5 ? value + 1 : value == 3 ? 5 : value == 1 ? 2 : 4]
                         [value == 3 ? 1 : 0],
                      (x << 4) - offsetX, (y << 4) - offsetY, null);
            }
          }
        }
      }
      for(int i = 0; i < invaders.size(); i++) {
        int[] invader = (int[])invaders.get(i);
        if (invader[0] >= cameraX - 16 && invader[0] < cameraX + 336
            && invader[1] >= cameraY - 16 && invader[1] < cameraY + 256) {
          imageGraphics.drawImage(sprites[(spriteStep >> 4)&1][invader[2]],
              invader[0] - cameraX, invader[1] - cameraY, null);
        }
      }
      imageGraphics.drawImage(sprites[3][playerDirection],
          playerX - cameraX, playerY - cameraY, null);
      if (shields > 0) {
        imageGraphics.setColor(blue);
        imageGraphics.fillOval(playerX - cameraX - 24, playerY - cameraY - 24, 64, 64);
      }

      imageGraphics.setColor(
          playerHealth < 25 && (spriteStep&8) == 0 ? white : pink);
      imageGraphics.fillRect(217, 2, playerHealth, 12);
      imageGraphics.setColor((blinking > 0 && (spriteStep&8) == 0) ? white : blue);
      imageGraphics.fillRect(2, 2, 100 * (stage + 3 - diamonds) / (stage + 3), 12);
      imageGraphics.setColor(white);
      imageGraphics.drawRect(217, 2, 100, 12);
      imageGraphics.drawRect(2, 2, 100, 12);
      imageGraphics.drawString(Integer.toString(score + stagePoints), 130, 13);

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

  protected void processKeyEvent(KeyEvent e) {
    K[e.getKeyCode()] = e.getID() == 401;
  }

  public static void main(String[] args) {
    new M();
  }
}

