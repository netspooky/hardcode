/*
 * Super Marble World
 * Copyright (C) 2009 Michael Birken
 *
 * This file is part of Super Marble World.
 *
 * Super Marble World is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Super Marble World is distributed in the hope that it will be useful,
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

    Color SKY_COLOR = null;
    Color BRICK_TOP_COLOR = null;
    Color BRICK_COLOR = null;

    final Color FLAG_POLE_COLOR = new Color(0x80D010);

    final Color[] BALL_COLORS = {
      new Color(0xD82800),
      new Color(0xC84C0C),
      new Color(0x00A800),
      new Color(0xA81F00),
      Color.BLACK,
    };
    final Color[] BALL_WEDGE_COLORS = {
      new Color(0xFC9838),
      new Color(0xFCBCB0),
      new Color(0xFC9838),
      new Color(0xFC9838),
      new Color(0xFC9838),
    };

    final ArrayList marbles = new ArrayList();
    // 0 = x
    // 1 = y
    // 2 = color index / enemy type
    // 3 = last y
    // 4 = active
    // 5 = vx

    final ArrayList sparkles = new ArrayList();
    // 0 = x
    // 1 = y
    // 2 = color index
    // 3 = vx
    // 4 = vy

    Random random = new Random();

    final int[] flagXs = { 10065, 10065, 10033 };
    final int[] flagYs = { 132, 164, 132 };
    final int[] flagXs2 = new int[3];
    final int[] flagYs2 = new int[3];
    int flagY = 0;
    int stage = 0;

    boolean releasedJump = true;
    int cameraX = 0;
    int blackRadius = 0;
    boolean won = false;

    final int[][] stageMap = new int[32][320];
    // y: 0-7 hidden, 8-22 visible, 23-31 hidden
    // x: 0 hidden, 1-318 visible, 319 hidden
    // 0 = sky
    // 1 = solid brick

    for(int i = 0; i < 32; i++) {
      stageMap[i][0] = stageMap[i][319] = 1;
    }

    // initialize player
    final double[] playerMarble = new double[4];
    // 0 = x
    // 1 = y
    // 2 = color index
    // 3 = last y

    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    pack();
    setLocationRelativeTo(null);
    show();    

    BufferedImage image = new BufferedImage(
        640, 480, BufferedImage.TYPE_INT_RGB);
    Graphics imageGraphics = image.getGraphics();
    imageGraphics.setFont(getFont().deriveFont(56f));

    long nextFrameStart = System.nanoTime();
    while(true) {
      do {
// -- UPDATE MODEL BEGIN -------------------------------------------------------

        if (won) {
        } else if (blackRadius > -400) {
          // modify black radius
          if (blackRadius == 0) {

            // reset stage
            marbles.clear();
            sparkles.clear();
            random = new Random(stage);
            cameraX = 32;
            playerMarble[0] = 128;
            //playerMarble[0] = 7500;
            playerMarble[3] = playerMarble[1] = 192;
            flagY = 0;                  
            marbles.add(playerMarble);

            for(int x = 1; x < 319; x++) {
              for(int y = 0; y < 32; y++) {
                stageMap[y][x] = 0;
              }
              stageMap[0][x] = stageMap[22][x] = 1;
            }
            
            for(int x = 20; x < 300; x += 20) {
              switch(random.nextInt(10)) {
                case 0:
                  // pit
                  for(int i = 3 + random.nextInt(3); i >= 0; i--) {
                    stageMap[22][x + i] = 0;
                  }
                  break;
                case 1:
                case 2: {
                  // platforms
                  int height = 16 + random.nextInt(6);
                  int thickness = height >= 18 || random.nextBoolean() ? 7 : 1;
                  int start = 2 + Math.min(2, random.nextInt(5));
                  for(int i = 0, length = 5 + random.nextInt(10);
                      i < length; i++) {
                    for(int j = 0; j < thickness; j++) {
                      stageMap[height + j][start + x + i] = 1;
                    }
                  }
                  if (random.nextBoolean()) {
                    marbles.add(new double[] {
                      64 + ((start + x) << 5),
                      (height << 5) - 66,
                      2 + random.nextInt(1),
                      (height << 5) - 66,
                      0,
                      -2
                    });
                  }
                  if ((stage & 1) == 0 && random.nextBoolean()) {
                    height -= 4 + random.nextInt(2);
                    start += random.nextInt(5);
                    for(int i = 0, length = 5 + random.nextInt(10);
                        i < length; i++) {
                      stageMap[height][start + x + i] = 1;
                    }
                    marbles.add(new double[] {
                      64 + ((start + x) << 5),
                      (height << 5) - 66,
                      2 + random.nextInt(1),
                      (height << 5) - 66,
                      0,
                      -2
                    });
                  }
                  break;
                }
                case 3:
                  // stairs
                  for(int i = 4 + random.nextInt(4); i < 12; i++) {
                    for(int j = 0; j < i; j++) {
                      stageMap[10 + i][18 + x - j] = 1;
                    }
                  }
                  break;
                case 4: {
                  // floating black marble
                  int height = 19 + random.nextInt(1);
                  for(int i = 3; i < 16; i++) {
                    stageMap[height][x + i] = 2;
                    stageMap[22][x + i] = stage < 4 ? ((x + i) & 1) : 0;
                  }
                  marbles.add(new double[] {
                    128 + (x << 5),
                    (height << 5) - 66,
                    4,
                    (height << 5) - 66,
                    1,
                    -2
                  });
                  if ((stage & 1) == 0 
                      && (stage >= 24 || random.nextInt(3) == 0)) {
                    height -= 4;
                    for(int i = 3; i < 16; i++) {
                      stageMap[height][x + i]  = 2;
                    }
                    for(int i = height - 1; i < 23; i++) {
                      stageMap[i][x + 19] = 1;
                    }
                    marbles.add(new double[] {
                      256 + (x << 5),
                      (height << 5) - 66,
                      4,
                      (height << 5) - 66,
                      1,
                      2
                    });
                  }
                  break;
                }
                case 5: {
                  // tiny platforms
                  int height = 16 + random.nextInt(5);
                  for(int i = 0; i < 15; i++) {
                    stageMap[22][x + i] = 0;
                  }                  
                  for(int i = 3; i < 15; i += 3 + random.nextInt(3)) {
                    stageMap[height][x + i]
                        = stageMap[height][x + i + 1] = 1;
                    height = Math.max(Math.min(18, height
                        + random.nextInt(7) - 4), (stage & 1) == 0 ? 9 : 12);
                  }
                  break;
                }
                case 6: {
                  int radius = 5 + random.nextInt(5);
                  for(int i = 0; i < 20; i++) {
                    for(int j = 0; j < 15; j++) {
                      int rx = 10 - i;
                      int ry = 15 - j;
                      if (rx * rx + ry * ry < radius * radius) {
                        stageMap[j + 8][i + x] = 1;
                      }
                    }
                  }
                  break;
                }
                case 7: {
                  int high = 16 + random.nextInt(5);
                  int low = Math.max(7, high - 4 - random.nextInt(3));
                  int width = 1 + random.nextInt(10);
                  for(int i = 8; i < 23; i++) {
                    for(int j = 0; j < width; j++) {
                      if (i <= low || i >= high) {
                        stageMap[i][x + 5 + j] = 1;
                      }
                    }
                  }
                  stageMap[6][x + 7] = 1;
                  break;
                }
                case 8: {
                  int high = 17 - random.nextInt(5);
                  int width = 1 + random.nextInt(10);
                  for(int i = 0; i < width; i++) {
                    stageMap[high][x + 5 + i] = 1;
                  }
                  if (random.nextBoolean()) {
                    for(int i = 8; i < high; i++) {
                      stageMap[i][x + 4 + width] = 1;
                    }
                  } else {
                    for(int i = 8; i < high; i++) {
                      stageMap[i][x + 5] = 1;
                    }
                  }
                  break;
                }
                case 9: {
                  int high = 18 - random.nextInt(5);
                  int low = Math.max(13, high - 4);
                  int width = 1 + random.nextInt(10);
                  for(int i = 8; i < 23; i++) {
                    for(int j = 0; j < width; j++) {
                      if (i >= low && i <= high) {
                        stageMap[i][x + 5 + j] = 1;
                      }
                    }
                  }
                  stageMap[6][x + 7] = 1;
                  break;
                }
              }
            }

            // generate flag stairs
            switch(stage & 3) {
              case 0:
                for(int i = 2; i < 12; i++) {
                  for(int j = 0; j < i; j++) {
                    stageMap[10 + i][304 - j] = 1;
                  }
                }
                break;
              case 1:
                for(int i = 12; i < 22; i++) {
                  stageMap[i][303] = stageMap[i][304] = 1;
                }
                stageMap[16][302] = stageMap[16][301] = 1;
                break;
              case 2:
                for(int i = 0; i < 14; i++) {
                  stageMap[22][304 - i] = 0;
                }
                stageMap[12][303] = stageMap[12][304] = 1;
                stageMap[14][299] = stageMap[14][300] = 1;
                stageMap[17][295] = stageMap[17][296] = 1;
                break;
              case 3:
                for(int i = 2; i < 12; i++) {
                  if (i != 5 && i != 6 && i != 7) {
                    for(int j = 0; j < i; j++) {
                      stageMap[10 + i][304 - j] = 1;
                    }
                  }
                }
                marbles.add(new double[] {
                  9664,
                  560,
                  3,
                  560,
                  1,
                  -2
                });
                break;
            }

            for(int i = 0; i < 16; i++) {
              marbles.add(new double[] {
                640 + i * 560,
                320,
                1 + random.nextInt(1 + Math.min(stage, 3)),
                320,
                0,
                -2
              });
            }
             

            if ((stage & 1) == 0) {
              SKY_COLOR = new Color(0x5C94FC);
              BRICK_TOP_COLOR = new Color(0xFCBCB0);
              BRICK_COLOR = new Color(0xC84C0C);
            } else {
              SKY_COLOR = Color.BLACK;
              BRICK_TOP_COLOR = Color.CYAN;
              BRICK_COLOR = new Color(0x008088);
              for(int x = 18; x < 288; x++) {
                stageMap[8][x] = 1;
              }
            }

            setTitle("Super Marble World "
                + ((stage >> 2) + 1) + "-" + ((stage & 3) + 1));
            nextFrameStart = System.nanoTime();
          }
          blackRadius -= 6;
        } else if (flagY > 0 && flagY < 280) {
          // lower flag
          flagY += 3;
          if (flagY == 280) {
            blackRadius = 402;
            stage++;
            if (stage == 32) {
              setTitle("Win!");
              won = true;
            }
          }
        } else {

          // process keyboard input
          if (K[KeyEvent.VK_RIGHT]) {
            playerMarble[0] += 6;
          } else if (K[KeyEvent.VK_LEFT]) {
            playerMarble[0] -= 6;
          }
          if (K[KeyEvent.VK_D] || K[KeyEvent.VK_UP]) {
            if (releasedJump) {
              for(double angle = 0.5236; angle < 2.618; angle += 0.1309) {
                if (stageMap[(int)(playerMarble[1] + 34 * Math.sin(angle)) >> 5]
                    [(int)(playerMarble[0] + 34 * Math.cos(angle)) >> 5] == 1) {
                  playerMarble[1] -= 16;
                  releasedJump = false;
                  break;
                }
              }
            }
          } else {
            releasedJump = true;
          }

          // end of stage?
          if (playerMarble[0] > 10032) {
            flagY = 1;
          }

          // move marbles
          for(int i = marbles.size() - 1; i >= 0; i--) {
            double[] marble = (double[])marbles.get(i);

            // apply gravity
            double dy = marble[1] - marble[3] + 0.7;
            if (dy > 16) {
              dy = 16;
            }
            if (dy < -16) {
              dy = -16;
            }
            marble[3] = marble[1];
            marble[1] += dy;

            if (i > 0) {
              // remove enemy if off camera
              if (cameraX - marble[0] > 640 || marble[1] > 768) {
                marbles.remove(i);
                continue;
              }

              // active enemy if on camera
              if (marble[0] - cameraX < 960) {
                marble[4] = 1;
              }

              // move enemies
              if (marble[4] == 1) {
                boolean removeMarble = false;
                for(int j = 1; j < marbles.size(); j++) {
                  if (i != j) {
                    // enemies bound off each other?
                    double[] enemy = (double[])marbles.get(j);
                    double ex = marble[0] - 33 - enemy[0];
                    double ey = marble[1] - enemy[1];
                    if (ex * ex + ey * ey < 1024) {
                      if (Math.abs(marble[5]) != 8) {
                        marble[5] = Math.abs(marble[5]);
                      }
                      if (Math.abs(enemy[5]) == 8) {
                        removeMarble = true;
                      } else {
                        enemy[5] = -Math.abs(enemy[5]);
                      }
                    }
                    ex = marble[0] + 33 - enemy[0];
                    ey = marble[1] - enemy[1];
                    if (ex * ex + ey * ey < 1024) {
                      if (Math.abs(marble[5]) != 8) {
                        marble[5] = -Math.abs(marble[5]);
                      }
                      if (Math.abs(enemy[5]) == 8) {
                        removeMarble = true;
                      } else {
                        enemy[5] = Math.abs(enemy[5]);
                      }
                    }
                  }
                }
                if (stageMap[((int)marble[1] + 16) >> 5]
                    [((int)marble[0] - 33) >> 5] != 0
                      || (marble[2] >= 3 && stageMap[((int)marble[1] + 34) >> 5]
                    [((int)marble[0] - 33) >> 5] == 0
                      && Math.abs(marble[5]) < 8)) {
                  marble[5] = Math.abs(marble[5]);
                } else if (stageMap[((int)marble[1] + 16) >> 5]
                    [((int)marble[0] + 33) >> 5] != 0
                      || (marble[2] >= 3 && stageMap[((int)marble[1] + 34) >> 5]
                    [((int)marble[0] + 33) >> 5] == 0
                      && Math.abs(marble[5]) < 8)) {
                  marble[5] = -Math.abs(marble[5]);
                }
                marble[0] += marble[5];

                double nx = marble[0] - playerMarble[0];
                double ny = marble[1] - playerMarble[1];
                double mag = nx * nx + ny * ny;
                if (mag < 4096) {
                  mag = Math.sqrt(mag);
                  if (ny / mag > 0.5) {
                    playerMarble[1] -= 24;
                    if (marble[2] == 1) {
                      removeMarble = true;
                    } else if (marble[5] == 0) {
                      // jump on shell
                      if (playerMarble[0] < marble[0]) {
                        marble[5] = 8;
                        playerMarble[0] -= 12;
                      } else {
                        marble[5] = -8;
                        playerMarble[0] += 12;
                      }
                    } else if (marble[2] < 4) {
                      // turn into shell
                      marble[5] = 0;
                    }
                  } else if (marble[5] == 0) {
                    // jump on shell
                    marble[5] = (playerMarble[0] < marble[0]) ? 8 : -8;
                    marble[0] += marble[5];
                  } else {
                    blackRadius = 402;
                  }
                }

                if (removeMarble) {
                  // enemy explodes in sparkles
                  marbles.remove(i);
                  for(int j = 0; j < 64; j++) {
                    double angle = 6.28 * random.nextDouble();
                    double radius = 32 * random.nextDouble();
                    sparkles.add(new double[] {
                      marble[0] + radius * Math.cos(angle),
                      marble[1] + radius * Math.sin(angle) + 32,
                      marble[2],
                      8 * random.nextDouble() - 4,
                      -6 * random.nextDouble() - 6
                    });
                  }
                }
              }
            }

            // remove from walls
            boolean hitWall = false;
            do {
              hitWall = false;
              double totalNormalX = 0;
              double totalNormalY = 0;           
              for(double angle = 2.0 * Math.PI; angle > 0; angle -= 0.0982) {
                double normalX = 32 * Math.cos(angle);
                double normalY = 32 * Math.sin(angle);
                int tile = stageMap[(int)(marble[1] + normalY) >> 5]
                    [(int)(marble[0] + normalX) >> 5];
                if (tile == 1 || (marble[2] == 4 && tile == 2)) {
                  hitWall = true;
                  totalNormalX -= normalX;
                  totalNormalY -= normalY;
                }
              }
              if (hitWall) {
                double magnitude = Math.sqrt(totalNormalX * totalNormalX
                    + totalNormalY * totalNormalY);
                marble[0] += totalNormalX / magnitude;
                marble[1] += totalNormalY / magnitude;
              }
            } while(hitWall);
          }

          // move camera
          cameraX = (int)(playerMarble[0] - 320);
          if (cameraX < 32) {
            cameraX = 32;
          } else if (cameraX > 9568) {
            cameraX = 9568;
          }

          // player fell down pit?
          if (playerMarble[1] > 768) {
            blackRadius = 402;
          }

          // move sparkles
          for(int i = sparkles.size() - 1; i >= 0; i--) {
            double[] sparkle = (double[])sparkles.get(i);
            sparkle[0] += sparkle[3];
            sparkle[1] += sparkle[4];
            sparkle[4] += 0.7;
            if (sparkle[1] > 768) {
              sparkles.remove(i);
            }
          }
        }

// -- UPDATE MODEL END ---------------------------------------------------------
        nextFrameStart += 16666667;
      } while(nextFrameStart < System.nanoTime());
// -- RENDER FRAME BEGIN -------------------------------------------------------

      // draw sky
      imageGraphics.setColor(SKY_COLOR);
      imageGraphics.fillRect(0, 0, 640, 480);      

      // draw flag
      imageGraphics.setColor(FLAG_POLE_COLOR);
      imageGraphics.fillRect(10063 - cameraX, 128, 4, 320);
      imageGraphics.fillOval(10057 - cameraX, 115, 15, 15);
      imageGraphics.setColor(Color.WHITE);
      for(int i = 0; i < 3; i++) {
        flagXs2[i] = flagXs[i] - cameraX;
        flagYs2[i] = flagYs[i] + flagY;
      }
      imageGraphics.fillPolygon(flagXs2, flagYs2, 3);

      // draw marbles
      for(int i = marbles.size() - 1; i >= 0; i--) {
        double[] marble = (double[])marbles.get(i);
        int x = (int)marble[0] - 32 - cameraX;
        int y = (int)marble[1] - 288;
        imageGraphics.setColor(BALL_COLORS[(int)marble[2]]);
        imageGraphics.fillOval(x, y, 64, 64);
        imageGraphics.setColor(BALL_WEDGE_COLORS[(int)marble[2]]);
        imageGraphics.fillArc(x, y, 64, 64,
            -(int)(45 * (marble[0] % (64 * Math.PI)) / (8 * Math.PI)),
            45);
        imageGraphics.drawOval(x, y, 64, 64);
      }

      // draw tiles
      int columnX = cameraX >> 5;
      int leftPaintX = cameraX & 0x1F;
      for(int y = 0; y < 15; y++) {
        for(int x = 0; x < 21; x++) {
          if (stageMap[y + 8][columnX + x] == 1) {
            int X = (x << 5) - leftPaintX;
            int Y = y << 5;
            imageGraphics.setColor(BRICK_COLOR);
            imageGraphics.fillRect(X, Y, 32, 32);
            imageGraphics.setColor(BRICK_TOP_COLOR);
            imageGraphics.drawLine(X + 1, Y, X + 30, Y);
            imageGraphics.drawLine(X, Y + 1, X, Y + 30);
            imageGraphics.setColor(Color.BLACK);
            imageGraphics.drawLine(X + 1, Y + 31, X + 30, Y + 31);
            imageGraphics.drawLine(X + 31, Y + 1, X + 31, Y + 30);
          }
        }
      }

      // draw sparkles
      for(int i = 0; i < sparkles.size(); i++) {
        double[] sparkle = (double[])sparkles.get(i);
        imageGraphics.setColor(BALL_COLORS[(int)sparkle[2]]);
        imageGraphics.fillOval(
            (int)sparkle[0] - cameraX, (int)sparkle[1] - 288, 5, 5);
      }

      // draw inverse black circle
      if (blackRadius > -400) {
        imageGraphics.setColor(Color.BLACK);
        for(int y = 0; y < 480; y++) {
          double dy = 240 - y;
          double value = blackRadius * blackRadius - dy * dy;
          if (value < 0) {
            value = 0;
          }
          value = Math.sqrt(value);
          imageGraphics.drawLine(0, y, (int)(320 - value), y);
          imageGraphics.drawLine(640, y, (int)(320 + value), y);
        }
      }

      if (won) {
        imageGraphics.setColor(Color.PINK);
        imageGraphics.drawString("Congratulations!", 118, 96);
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

  protected void processKeyEvent(KeyEvent e) {
    K[e.getKeyCode()] = e.getID() == 401;
  }

  public static void main(String[] args) {
    new M();
  }
}

