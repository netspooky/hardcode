/*
 * Run Over Zombies
 * Copyright (C) 2009 Michael Birken
 *
 * This file is part of Run Over Zombies.
 *
 * Run Over Zombies is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Run Over Zombies is distributed in the hope that it will be useful,
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

public class M extends JFrame implements Comparator<double[]> {

  final boolean[] K = new boolean[65535]; // pressed keys

  public M() {

    ArrayList bloodSpots = new ArrayList();

    int[][][] lineTable = {
      { { 0, 0 }, { 1, 0 } },
      { { 1, 0 }, { 1, 1 } },
      { { 1, 1 }, { 0, 1 } },
      { { 0, 1 }, { 0, 0 } },
    };
    double[][] zombies = new double[1024][4];
    double zombieAngle = 0;
    double zombieSin = 0;
    double[][][] points = new double[2][2][2];
    int[] xs = new int[4];
    int[] ys = new int[4];

    double[][] lines = new double[8192][32];
    double playerX = 1.5;
    double playerZ = 1.5;
    double playerAngle = 0;
    double playerVelocity = 0;
    long score = 0;
    int scientists = 8;
    int seconds = 3600;

    BufferedImage groundImage = new BufferedImage(
        640, 240, BufferedImage.TYPE_INT_RGB);
    BufferedImage image = new BufferedImage(
        640, 480, BufferedImage.TYPE_INT_RGB);
    Graphics2D imageGraphics = image.createGraphics();
    BasicStroke bloodStroke = new BasicStroke(
        16, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND);
    BasicStroke compassStroke = new BasicStroke(
        4, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER);
    imageGraphics.setFont(imageGraphics.getFont().deriveFont(32f));

    // create floor image
    int[] pixels = new int[153600];
    for(int y = 0, p = 0; y < 240; y++) {
      for(int x = 0; x < 640; x++, p++) {
        double k = 240.0 / y;
        double b = (x - 320) / k;
        double c = 640 * k;
        double d2 = b * b + c * c + 57600;
        int intensity = (int)(255 * Math.min(1.0, 500000 / d2));
        pixels[p] = 0xFF000000
            | (intensity << 16) | (intensity << 8) | intensity;
      }
    }
    groundImage.setRGB(0, 0, 640, 240, pixels, 0, 640);

    // create color table
    Color[][] colors = new Color[16][256];
    for(int i = 0; i < 16; i++) {
      for(int j = 0; j < 256; j++) {
        double angle = i * Math.PI / 8.0;
        double scale = (255 - j) / 256.0;
        colors[i][j] = new Color((float)(scale * (0.5 + 0.5 * Math.sin(angle))),
            (float)(scale * (0.5 + 0.5 * Math.sin(angle + 2.0 * Math.PI / 3.0))),
            (float)(scale * (0.5 + 0.5 * Math.sin(angle - 2.0 * Math.PI / 3.0))));
      }
    }

    // create map
    Random random = new Random(0);
    int[][][] map = new int[32][32][3];
    for(int y = 0; y < 32; y++) {
      for(int x = 0; x < 32; x++) {
        map[y][x][0] = 1;
        map[y][x][1] = -512 - random.nextInt(4096);
        map[y][x][2] = random.nextInt(16);
      }
    }
    M(map, 1, 1, 30, 30, random);

    // add zombies
    int zombieIndex = 0;
    while(zombieIndex < 1024) {
      int x = random.nextInt(32);
      int y = random.nextInt(32);
      if (map[y][x][0] == 0) {
        double angle = 6.28 * random.nextDouble();
        zombies[zombieIndex++] = new double[] {
          x + 0.2 + 0.6 * random.nextDouble(),
          y + 0.2 + 0.6 * random.nextDouble(),
          0.001 * Math.cos(angle),
          0.001 * Math.sin(angle),
        };
      }
    }

    // print out map
    /*for(int y = 0; y < 32; y++) {
      for(int x = 0; x < 32; x++) {
        if (map[y][x][0] == 0) {
          System.out.print(" ");
        } else {
          System.out.print("X");
        }
      }
      System.out.println();
    }*/

    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    pack();
    setLocationRelativeTo(null);
    setTitle("Run Over Zombies");
    show();

    long nextFrameStart = System.nanoTime();
    while(true) {
      do {
// -- UPDATE MODEL BEGIN -------------------------------------------------------

        if (K[KeyEvent.VK_ESCAPE]) {
          System.exit(0);
        }
        if (scientists > 0) {

          // process input
          playerVelocity *= 0.97;
          if (K[KeyEvent.VK_LEFT]) {
            playerAngle += 0.02;
          } else if (K[KeyEvent.VK_RIGHT]) {
            playerAngle -= 0.02;
          }
          if (K[KeyEvent.VK_UP]) {
            playerVelocity = Math.min(0.05, playerVelocity + 0.02);
          } else if (K[KeyEvent.VK_DOWN]) {
            playerVelocity = Math.max(-0.05, playerVelocity - 0.02);
          }
          double newX = playerX + playerVelocity * -Math.sin(playerAngle);          
          if (map[(int)playerZ][(int)newX][0] == 0) {
            playerX = newX;
          }
          double newZ = playerZ + playerVelocity * Math.cos(playerAngle);
          if (map[(int)newZ][(int)playerX][0] == 0) {
            playerZ = newZ;
          }

          // move zombies
          zombieAngle += 0.1;
          zombieSin = 32 * Math.sin(zombieAngle);
          for(int i = 0; i < 1024; i++) {
            double[] zombie = zombies[i];
            double a = playerX - zombie[0];
            double b = playerZ - zombie[1];
            if (a * a + b * b < 0.01) {
              score += 100;
              if (i == 0) {
                score += 1000;
                seconds = 3600;
                scientists--;
              }
              while(true) {
                int x = random.nextInt(32);
                int y = random.nextInt(32);
                if (map[y][x][0] == 0) {
                  zombie[0] = x + 0.2 + 0.6 * random.nextDouble();
                  zombie[1] = y + 0.2 + 0.6 * random.nextDouble();
                  break;
                }
              }
              bloodSpots.add(new double[] {
                random.nextInt(640),
                random.nextInt(480),
                64,
              });
            } else {
              double x = zombie[0] + zombie[2];
              double z = zombie[1] + zombie[3];
              if (map[(int)(z + 512 * zombie[3])][(int)(x + 512 * zombie[2])][0] == 0) {
                zombie[0] = x;
                zombie[1] = z;
              } else {
                double angle = 6.28 * random.nextDouble();
                zombie[2] = 0.001 * Math.cos(angle);
                zombie[3] = 0.001 * Math.sin(angle);
              }
            }
          }

          // update blood
          for(int i = bloodSpots.size() - 1; i >= 0; i--) {
            double[] bloodSpot = (double[])bloodSpots.get(i);
            if (bloodSpot[2] < bloodSpot[1] - 480) {
              bloodSpots.remove(i);
            } else {
              bloodSpot[2] -= 0.25;
            }
          }

          if (--seconds == 0) {
            seconds = 3600;
            scientists = 8;
            score = 0;
          }
        }

// -- UPDATE MODEL END ---------------------------------------------------------
        nextFrameStart += 16666667;
      } while(nextFrameStart < System.nanoTime());
// -- RENDER FRAME BEGIN -------------------------------------------------------

      imageGraphics.setColor(Color.BLACK);
      imageGraphics.fillRect(0, 0, 640, 240);
      imageGraphics.drawImage(groundImage, 0, 240, null);

      double rotateX = Math.cos(playerAngle);
      double rotateZ = -Math.sin(playerAngle);
      int lineCount = 0;
      for(int i = 0; i < 32; i++) {
        for(int j = 0; j < 32; j++) {
          if (map[i][j][0] == 1) {
            for(int k = 0; k < 4; k++) {
              boolean validFound = true;
              double dist = 0;
              for(int m = 0; m < 2; m++) {
                double a = j + 0.9 * lineTable[k][m][0] - playerX;
                double b = i + 0.9 * lineTable[k][m][1] - playerZ;
                double x = 2048 * (a * rotateX - b * rotateZ);
                double z = 2048 * (a * rotateZ + b * rotateX);
                dist = a * a + b * b;

                if (z < -639) {
                  validFound = false;
                  break;
                } else {
                  double k1 = 640 / (640 + z);
                  points[0][m][0] = k1 * x + 320;
                  points[0][m][1] = k1 * 240 + 240;
                  points[1][m][0] = points[0][m][0];
                  points[1][m][1] = k1 * map[i][j][1] + 240;
                }
              }

              if (validFound && points[0][0][0] - points[0][1][0] <= 0) {
                double[] line = lines[lineCount++];
                line[0] = points[0][0][0];
                line[1] = points[0][0][1];
                line[2] = points[0][1][0];
                line[3] = points[0][1][1];
                line[4] = Math.min(line[0], line[2]);
                line[5] = Math.max(line[0], line[2]);
                line[6] = Math.min(line[1], line[3]);
                line[7] = Math.max(line[1], line[3]);
                line[8] = line[2] - line[0];
                line[9] = line[3] - line[1];
                line[10] = points[1][0][0];
                line[11] = points[1][0][1];
                line[12] = points[1][1][0];
                line[13] = points[1][1][1];
                line[14] = 0;
                line[15] = map[i][j][2];
                line[16] = 64 + 191 * (1.0 - Math.min(1.0, 16 / dist));
              }
            }
          }
        }
      }
      for(int i = 0; i < 1024; i++) {
        double[] zombie = (double[])zombies[i];
        double a = zombie[0] - playerX;
        double b = zombie[1] - playerZ;
        double x = 2048 * (a * rotateX - b * rotateZ);
        double z = 2048 * (a * rotateZ + b * rotateX);
        double dist = a * a + b * b;
        if (z >= -639) {
          double[] line = lines[lineCount++];
          double k = 640 / (640 + z);

          line[0] = k * (x - 48) + 320;
          line[1] = k * 240 + 240;
          line[2] = k * (x + 48) + 320;
          line[3] = line[1];
          line[4] = Math.min(line[0], line[2]);
          line[5] = Math.max(line[0], line[2]);
          line[6] = Math.min(line[1], line[3]);
          line[7] = Math.max(line[1], line[3]);
          line[8] = line[2] - line[0];
          line[9] = line[3] - line[1];
          line[10] = line[0];
          line[11] = k * -10 + 240;
          line[12] = line[2];
          line[13] = line[11];
          line[14] = 1 + i;
          line[15] = i == 0 ? 5 : 0;
          line[16] = 64 + 191 * (1.0 - Math.min(1.0, 16 / dist));
        }
      }
      if (lineCount > 0) {
        Arrays.sort(lines, 0, lineCount, this);
        /*for(int i = Math.max(0, lineCount - 64); i < lineCount; i++) {
          for(int j = i + 1; j < lineCount; j++) {
            if (compare(lines[i], lines[j]) > 0) {
              double[] temp = lines[i];
              lines[i] = lines[j];
              lines[j] = temp;
            }
          }
        }*/
      }

      // draw polygons
      for(int i = 0; i < lineCount; i++) {
        double[] line = lines[i];
        imageGraphics.setColor(colors[(int)line[15]][(int)line[16]]);
        if (line[14] == 0) {
          // draw building wall
          xs[0] = (int)line[0];
          ys[0] = (int)line[1];
          xs[1] = (int)line[2];
          ys[1] = (int)line[3];
          xs[2] = (int)line[12];
          ys[2] = (int)line[13];
          xs[3] = (int)line[10];
          ys[3] = (int)line[11];
          imageGraphics.fillPolygon(xs, ys, 4);
        } else {
          // draw zombie
          double s = (line[2] - line[0]) / 96;

          // head
          imageGraphics.fillOval(
              (int)(line[10] + 32 * s),
              (int)(line[11]),
              (int)(32 * s), (int)(32 * s));

          // torso
          xs[0] = (int)(line[10] + 20 * s);
          ys[0] = (int)(line[11] + 32 * s);
          xs[1] = (int)(line[10] + 75 * s);
          ys[1] = ys[0];
          xs[2] = xs[1];
          ys[2] = (int)(line[11] + 150 * s);
          xs[3] = xs[0];
          ys[3] = ys[2];
          imageGraphics.fillPolygon(xs, ys, 4);

          // shoulders
          xs[0] = (int)(line[10]);
          ys[0] = (int)(line[11] + 32 * s);
          xs[1] = (int)(line[10] + 96 * s);
          ys[1] = ys[0];
          xs[2] = xs[1];
          ys[2] = (int)(line[11] + 64 * s);
          xs[3] = xs[0];
          ys[3] = ys[2];
          imageGraphics.fillPolygon(xs, ys, 4);

          // left arm
          xs[0] = (int)(line[10]);
          ys[0] = (int)(line[11] + 32 * s);
          xs[1] = (int)(line[10] + 16 * s);
          ys[1] = ys[0];
          xs[2] = xs[1];
          ys[2] = (int)(line[11] + (104 + 0.5 * zombieSin) * s);
          xs[3] = xs[0];
          ys[3] = ys[2];
          imageGraphics.fillPolygon(xs, ys, 4);

          // right arm
          xs[0] = (int)(line[10] + 80 * s);
          ys[0] = (int)(line[11] + 32 * s);
          xs[1] = (int)(line[10] + 96 * s);
          ys[1] = ys[0];
          xs[2] = xs[1];
          ys[2] = (int)(line[11] + (104 - 0.5 * zombieSin) * s);
          xs[3] = xs[0];
          ys[3] = ys[2];
          imageGraphics.fillPolygon(xs, ys, 4);

          // left leg
          xs[0] = (int)(line[10] + 20 * s);
          ys[0] = (int)(line[11] + 150 * s);
          xs[1] = (int)(line[10] + 44 * s);
          ys[1] = ys[0];
          xs[2] = xs[1];
          ys[2] = (int)(line[11] + (218 - zombieSin) * s );
          xs[3] = xs[0];
          ys[3] = ys[2];
          imageGraphics.fillPolygon(xs, ys, 4);

          // right leg
          xs[0] = (int)(line[10] + 51 * s);
          ys[0] = (int)(line[11] + 150 * s);
          xs[1] = (int)(line[10] + 75 * s);
          ys[1] = ys[0];
          xs[2] = xs[1];
          ys[2] = (int)(line[11] + (218 + zombieSin) * s);
          xs[3] = xs[0];
          ys[3] = ys[2];
          imageGraphics.fillPolygon(xs, ys, 4);
        }
      }

      // draw blood
      imageGraphics.setColor(Color.RED);
      imageGraphics.setStroke(bloodStroke);
      for(int i = 0; i < bloodSpots.size(); i++) {
        double[] bloodSpot = (double[])bloodSpots.get(i);
        double size = bloodSpot[2];
        if (size > 0) {
          imageGraphics.fillOval(
              (int)(bloodSpot[0] - size),
              (int)(bloodSpot[1] - size),
              (int)(size * 2),
              (int)(size * 2));
        }
        size *= 2;
        imageGraphics.drawLine(
            (int)bloodSpot[0],
            (int)(bloodSpot[1] + ((size > 0) ? 0 : -size)),
            (int)bloodSpot[0],
            (int)(bloodSpot[1] + (192 - size)));
      }

      // draw compass
      double vx = Math.cos(playerAngle);
      double vy = Math.sin(playerAngle);

      double cx = zombies[0][0] - playerX;
      double cy = zombies[0][1] - playerZ;
      double mag = Math.sqrt(cx * cx + cy * cy);
      cx /= mag;
      cy /= mag;
      double compassX = vx * cx + vy * cy;
      double compassY = vx * cy - vy * cx;
      imageGraphics.setColor(Color.WHITE);
      imageGraphics.setStroke(compassStroke);
      imageGraphics.drawLine(565, 405,
          (int)(565 + compassX * 60), (int)(405 - compassY * 60));
      imageGraphics.drawOval(502, 342, 128, 128);
      
      //display color table
      /*for(int j = 0; j < 16; j++) {
        for(int i = 0; i < 255; i++) {
          imageGraphics.setColor(colors[j][i]);
          imageGraphics.drawLine(i, j << 4, i, (j << 4) + 16);
        }
      }*/

      imageGraphics.drawString(Long.toString(score), 16, 32);
      if (scientists == 0) {
        imageGraphics.drawString("Congratulations!", 395, 32);
      } else {
        imageGraphics.drawString(Integer.toString(scientists), 590, 32);
      }
      imageGraphics.fillRect(624 - (seconds >> 6), 40, (seconds >> 6), 32);

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

  // map[y][x][0 = (0 = empty, 1 = building), 1 = height, 2 = color]
  private void M(int[][][] map, int x1, int y1, int x2, int y2,
      Random random) {
    for(int x = x1; x <= x2; x++) {
      map[y2][x][0] = map[y1][x][0] = 0;
    }
    for(int y = y1; y <= y2; y++) {
      map[y][x2][0] = map[y][x1][0] = 0;
    }
    if ((random.nextDouble()) < 0.2 ^ (x2 - x1 > y2 - y1)) {
      if (x2 - x1 >= 4) {
        int pivot = x1 + 2 + random.nextInt(x2 - x1 - 3);
        M(map, x1, y1, pivot, y2, random);
        M(map, pivot, y1, x2, y2, random);
      }
    } else {
      if (y2 - y1 >= 4) {
        int pivot = y1 + 2 + random.nextInt(y2 - y1 - 3);
        M(map, x1, y1, x2, pivot, random);
        M(map, x1, pivot, x2, y2, random);
      }
    }
  }

  protected void processKeyEvent(KeyEvent e) {
    K[e.getKeyCode()] = e.getID() == 401;
  }

  public static void main(String[] args) {
    new M();
  }

  // 0 = x1
  // 1 = y1
  // 2 = x2
  // 3 = y2
  // 4 = min x
  // 5 = max x
  // 6 = min y
  // 7 = max y
  // 8 = dx
  // 9 = dy
  // 10 = x3
  // 11 = y3
  // 12 = x4
  // 13 = y4
  // 14 = type (0 = wall)
  // 15 = color index 1
  // 16 = color index 2

  public int compare(double[] line1, double[] line2) {

    if (line1[6] >= line2[7]) {
      return 1;
    }
    if (line1[7] <= line2[6]) {
      return -1;
    }
    if (line1[0] > line2[4] && line1[0] < line2[5]) {
      return line2[1] + line2[9] * ((line1[0] - line2[0]) / line2[8])
          < line1[1] ? 1 : -1;
    }
    if (line1[2] > line2[4] && line1[2] < line2[5]) {
      return line2[1] + line2[9] * ((line1[2] - line2[0]) / line2[8])
          < line1[3] ? 1 : -1;
    }
    if (line2[0] > line1[4] && line2[0] < line1[5]) {
      return line1[1] + line1[9] * ((line2[0] - line1[0]) / line1[8])
          > line2[1] ? 1 : -1;
    }
    if (line2[2] > line1[4] && line2[2] < line1[5]) {
      return line1[1] + line1[9] * ((line2[2] - line1[0]) / line1[8])
          > line2[3] ? 1 : -1;
    }
    return Double.compare(line1[7], line2[7]);
  }
}

