/*
 * Coffee Shop Puzzle
 * Copyright (C) 2009 Michael Birken
 *
 * This file is part of Coffee Shop Puzzle.
 *
 * Coffee Shop Puzzle is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Coffee Shop Puzzle is distributed in the hope that it will be useful,
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

  private final int[] M = new int[4];

  public M() {

    final double VIEWER_Z = -1024;
    final double FLOOR_Y = 208;
    final double WALL_Z = 320;    
    final double SQUARE_SIDE = 64;
    final double ARC_RADIUS = 6 * SQUARE_SIDE / Math.PI;
    final double MAX_CUP_RADIUS = 640 / 6 - 10;
    final Stack<Integer>[] stacks = new Stack[3];
    final Color DARK_COLOR = new Color(0x90000000, true);

    int heldCup = -1;
    int pressedX = 0;
    int pressedY = 0;
    int sourceStack = 0;
    int dropIndex = 4;
    int dropY = -174;
    boolean started = false;
    int moves = 0;

    for(int i = 0; i < 3; i++) {
      stacks[i] = new Stack<Integer>();
    }

    // render background
    BufferedImage backgroundImage = new BufferedImage(
        640, 480, BufferedImage.TYPE_INT_RGB);
    int[] pixels = new int[307200];
    for(int y = 0, index = 0; y < 480; y++) {
      for(int x = 0; x < 640; x++, index++) {
        double R = 0;
        double G = 0;
        for(double q = 0; q < 1; q += 0.5) {
          for(double p = 0; p < 1; p += 0.5) {
            double b = x - 319.5 + p;
            double c = y - 239.5 + q;
            double k = FLOOR_Y / c;
            double g = FLOOR_Y - ARC_RADIUS;
            double h = WALL_Z - ARC_RADIUS;
            double X = k * b;
            double Z = VIEWER_Z - k * VIEWER_Z;
            double length = h - Z;
            if (k > 0 && Z <= h) {
              int red = 0x63;
              int green = 0x20;
              if ((((int)(X / SQUARE_SIDE)
                  + (int)(length / SQUARE_SIDE)) & 1)
                      == (X < 0 ? 0 : 1)) {
                red = 0xC6;
                green = 0x61;
              }
              double power = (0.75 - 0.5 * Math.atan(640 / 6 - 10 - Math.hypot(X, Z)) / Math.PI)
                  * (0.75 - 0.5 * Math.atan(640 / 6 - 10 - Math.hypot(X - 640 / 3, Z)) / Math.PI)
                  * (0.75 - 0.5 * Math.atan(640 / 6 - 10 - Math.hypot(X + 640 / 3, Z)) / Math.PI);
              green /= power;
              if (x < 435) {
                red /= power;
              }
              R += I(X, FLOOR_Y, Z, 0, -1, 0, red, false);
              G += I(X, FLOOR_Y, Z, 0, -1, 0, green, false);
            } else {
              k = (VIEWER_Z - WALL_Z) / VIEWER_Z;
              X = k * b;
              double Y = k * c;
              double dy = Y - g;
              if (Y <= g) {
                int red = 0x63;
                int green = 0x20;
                if ((((int)(X / SQUARE_SIDE)
                    + (int)(dy / SQUARE_SIDE)) & 1)
                        == (X < 0 ? 0 : 1)) {
                  red = 0xC6;
                  green = 0x61;
                }
                R += I(X, Y, WALL_Z, 0, 0, -1, red, false);
                G += I(X, Y, WALL_Z, 0, 0, -1, green, false);
              } else {
                double A = VIEWER_Z * VIEWER_Z + c * c;
                double B = 2 * (c * g + VIEWER_Z * (VIEWER_Z - h));
                double C = g * g + (VIEWER_Z - h) * (VIEWER_Z - h)
                    - ARC_RADIUS * ARC_RADIUS;
                double discriminant = B * B - 4 * A * C;
                if (discriminant >= 0) {
                  discriminant = Math.sqrt(discriminant);
                  double t1 = (B + discriminant) / (2 * A);
                  double t2 = (B - discriminant) / (2 * A);
                  double t = Math.max(t1, t2);
                  X = t * b;
                  Y = t * c;
                  Z = VIEWER_Z - t * VIEWER_Z;
                  double arcLength = Math.atan2(Y - g, Z - h) * ARC_RADIUS;
                  if (Z > h && Y > g) {
                    int red = 0x63;
                    int green = 0x20;
                    if ((((int)(X / SQUARE_SIDE)
                        + (int)(arcLength / SQUARE_SIDE)) & 1)
                            == (X >= 0 ? 0 : 1)) {
                      red = 0xC6;
                      green = 0x61;
                    }
                    R += I(X, FLOOR_Y, Z, 0, g - Y, h - Z, red, true);
                    G += I(X, FLOOR_Y, Z, 0, g - Y, h - Z, green, true);
                  }
                }
              }
            }
          }
        }
        R /= 4;
        G /= 4;
        pixels[index] = 0xFF000000 | (((int)R) << 16) | (((int)G) << 8);
      }
    }
    backgroundImage.setRGB(0, 0, 640, 480, pixels, 0, 640);

    // render cups
    // 224 296 192 174
    BufferedImage[] cupImages = new BufferedImage[5];
    for(int i = 0; i < 5; i++) {      
      double angle = 2.0 * Math.PI * i / 5.0;
      double red = 128 + 127 * Math.cos(angle);
      double green = 128 + 127 * Math.cos(angle + 2.0 * Math.PI / 3.0);
      double blue = 128 + 127 * Math.cos(angle - 2.0 * Math.PI / 3.0);
      int minX = Integer.MAX_VALUE, maxX = 0;
      int minY = Integer.MAX_VALUE, maxY = 0;
      for(int y = 0, index = 0; y < 174; y++) {
        for(int x = 0; x < 192; x++, index++) {
          double Red = 0;
          double Green = 0;
          double Blue = 0;
          int hits = 0;
          for(double q = 0; q < 1; q += 0.25) {
            for(double p = 0; p < 1; p += 0.25) {
              pixels[index] = 0;
              double b = x - 95.5 + p;
              double c = y + 56.5 + q;

              double d = -350;
              double R = MAX_CUP_RADIUS - i * 16;
              double top = FLOOR_Y - R * (FLOOR_Y - 60) / MAX_CUP_RADIUS;
              double W = R / (FLOOR_Y - d);
              W *= W;
              double A = b * b + VIEWER_Z * VIEWER_Z - W * c * c;
              double B = 2 * VIEWER_Z * VIEWER_Z - 2 * W * d * c;
              double C = VIEWER_Z * VIEWER_Z - W * d * d;
              double discriminant = B * B - 4 * A * C;
              if (discriminant >= 0) {
                discriminant = Math.sqrt(discriminant);
                double t1 = (B + discriminant) / (2 * A);
                double t2 = (B - discriminant) / (2 * A);
                double t = Math.min(t1, t2);
                double X = t * b;
                double Y = t * c;
                double Z = VIEWER_Z - t * VIEWER_Z;
                if (Y >= top && Y <= FLOOR_Y) {
                  minX = Math.min(minX, x);
                  maxX = Math.max(maxX, x);
                  minY = Math.min(minY, y);
                  maxY = Math.max(maxY, y);
                  Red += I(X, Y, Z, X, (X * X + Z * Z) / (d - Y), Z, red, true);
                  Green += I(X, Y, Z, X, (X * X + Z * Z) / (d - Y), Z, green,
                      true);
                  Blue += I(X, Y, Z, X, (X * X + Z * Z) / (d - Y), Z, blue,
                      true);
                  hits++;
                }
              }

              double k = top / c;
              double X = k * b;
              double Z = VIEWER_Z - k * VIEWER_Z;
              double r = R * (top - d) / (FLOOR_Y - d);
              if (k > 0 && X * X + Z * Z <= r * r) {
                Red += I(X, top, Z, 0, -1, 0, red, true);
                Green += I(X, top, Z, 0, -1, 0, green, true);
                Blue += I(X, top, Z, 0, -1, 0, blue, true);
                hits++;
              }
            }
          }

          Red /= hits;
          Green /= hits;
          Blue /= hits;          
          pixels[index] = ((int)(255 * hits / 16.0) << 24) | (((int)Red) << 16)
              | (((int)Green) << 8) | (int)Blue;
        }
      }
      cupImages[i] = new BufferedImage(192, 174, BufferedImage.TYPE_INT_ARGB_PRE);
      cupImages[i].setRGB(0, 0, 192, 174, pixels, 0, 192);
    }

    BufferedImage image = new BufferedImage(
        640, 480, BufferedImage.TYPE_INT_RGB);
    Graphics2D imageGraphics = image.createGraphics();
    imageGraphics.setRenderingHint(
        RenderingHints.KEY_TEXT_ANTIALIASING,
        RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
    imageGraphics.setRenderingHint(
        RenderingHints.KEY_ANTIALIASING,
        RenderingHints.VALUE_ANTIALIAS_ON);
    final Font largeFont = imageGraphics.getFont().deriveFont(40f);
    final Font smallFont = imageGraphics.getFont().deriveFont(30f);
    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));
    enableEvents(AWTEvent.MOUSE_EVENT_MASK);
    enableEvents(AWTEvent.MOUSE_MOTION_EVENT_MASK);
    enableEvents(AWTEvent.KEY_EVENT_MASK);
    setTitle("Coffee Shop Puzzle");
    setIconImage(cupImages[0]);
    pack();
    setLocationRelativeTo(null);
    show();

    long nextFrameStart = System.nanoTime();
    while(true) {
      do {
// -- UPDATE MODEL BEGIN -------------------------------------------------------

        if (started) {
          if (dropIndex >= 0) {
            dropY += 20;
            if (dropY >= 296) {
              stacks[0].push(dropIndex);
              dropIndex--;
              dropY = -174;
            }
          } else {
            if (heldCup < 0 && M[2] > 0 && M[1] > 296) {
              int stackIndex = 1;
              int px = M[0] - 224;
              int py = M[1] - 296;
              if (M[0] < 224) {
                stackIndex = 0;
                px = M[0] - 8;
              } else if (M[0] >= 440) {
                stackIndex = 2;
                px = M[0] - 440;
              }
              if (stacks[stackIndex].size() > 0) {
                heldCup = stacks[stackIndex].pop();
                pressedX = px;
                pressedY = py;
                sourceStack = stackIndex;
              }
            } else if (heldCup >= 0 && M[2] == 0) {
              int stackIndex = 1;
              if (M[0] < 224) {
                stackIndex = 0;
              } else if (M[0] >= 440) {
                stackIndex = 2;
              }
              if (stacks[stackIndex].size() > 0
                    && stacks[stackIndex].peek() < heldCup) {
                stackIndex = sourceStack;
              }
              stacks[stackIndex].push(heldCup);
              heldCup = -1;
              if (stackIndex != sourceStack) {
                moves++;
              }
              if (stacks[2].size() == 5) {
                started = false;
                dropIndex = 4;
                dropY = -174;
              }
            }
          }
        } else if (M[2] > 0) {
          started = true;
          stacks[0].clear();
          stacks[1].clear();
          stacks[2].clear();
          moves = 0;
        }

// -- UPDATE MODEL END ---------------------------------------------------------
        nextFrameStart += 16666667;
      } while(nextFrameStart < System.nanoTime());
// -- RENDER FRAME BEGIN -------------------------------------------------------

      imageGraphics.drawImage(backgroundImage, 0, 0, null);

      if (stacks[0].size() > 0) {
        imageGraphics.drawImage(cupImages[stacks[0].peek()], 8, 296, null);
      }
      if (stacks[1].size() > 0) {
        imageGraphics.drawImage(cupImages[stacks[1].peek()], 224, 296, null);
      }
      if (stacks[2].size() > 0) {
        imageGraphics.drawImage(cupImages[stacks[2].peek()], 440, 296, null);
      }

      if (heldCup >= 0) {
        imageGraphics.drawImage(cupImages[heldCup], M[0] - pressedX,
            M[1] - pressedY, null);
      }
      if (dropIndex >= 0) {
        imageGraphics.drawImage(cupImages[dropIndex], 8, dropY, null);
      }

      if (!started) {
        imageGraphics.setColor(DARK_COLOR);
        imageGraphics.fillRoundRect(25, 100, 592, 125, 32, 32);
        imageGraphics.setColor(Color.WHITE);
        imageGraphics.setFont(largeFont);
        if (stacks[2].size() > 0) {
          if (moves == 31) {            
            imageGraphics.drawString("Perfect!", 250, 175);
          } else {            
            imageGraphics.drawString("You can do it in fewer moves.", 65, 150);
            imageGraphics.drawString("Try again.", 235, 200);
          }
          
          imageGraphics.setFont(smallFont);        
          imageGraphics.setColor(Color.RED);
          imageGraphics.fillOval(10, 430, 190, 40);
          imageGraphics.setColor(Color.GREEN);
          imageGraphics.drawString("RESET", 55, 460);
        } else {          
          imageGraphics.drawString("Move all cups to the green circle.",
              35, 150);
          imageGraphics.drawString("Keep larger over smaller.", 100, 200);
          imageGraphics.setFont(smallFont);
          imageGraphics.setColor(Color.GREEN);
          imageGraphics.fillOval(440, 430, 190, 40);
          imageGraphics.setColor(Color.RED);
          imageGraphics.drawString("START", 487, 460);
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

  public int C(double x, double y, double z, double nx, double ny, double nz,
      double red, double green, double blue, boolean specularHighlight) {
    return 0xFF000000
        | (I(x, y, z, nx, ny, nz, red, specularHighlight) << 16)
        | (I(x, y, z, nx, ny, nz, green, specularHighlight) << 8)
        | I(x, y, z, nx, ny, nz, blue, specularHighlight);
  }

  public int I(double x, double y, double z, double nx, double ny, double nz,
      double color, boolean specularHighlight) {

    final double VIEWER_Z = -1024;
    final double LIGHT_X = 320;
    final double LIGHT_Y = -240;
    final double LIGHT_Z = VIEWER_Z;
    final double AMBIENT = 0.3;
    final double DIFFUSE = 1500000;
    final double SPECULAR = 200000000;
    final double SHININESS = 60;

    double magnitude = Math.sqrt(nx * nx + ny * ny + nz * nz);
    nx /= magnitude;
    ny /= magnitude;
    nz /= magnitude;
    double lx = LIGHT_X - x;
    double ly = LIGHT_Y - y;
    double lz = LIGHT_Z - z;
    double d2 = lx * lx + ly * ly + lz * lz;
    magnitude = Math.sqrt(d2);
    lx /= magnitude;
    ly /= magnitude;
    lz /= magnitude;
    double vx = -x;
    double vy = -y;
    double vz = VIEWER_Z - z;
    magnitude = Math.sqrt(vx * vx + vy * vy + vz * vz);
    vx /= magnitude;
    vy /= magnitude;
    vz /= magnitude;

    double k = 2 * (nx * lx + ny * ly + nz * lz);
    double rx = k * nx - lx;
    double ry = k * ny - ly;
    double rz = k * nz - lz;

    double total = AMBIENT * color;
    double diffuse = DIFFUSE * (lx * nx + ly * ny + lz * nz) * color / d2;
    if (diffuse > 0) {
      total += diffuse;
    }
    if (specularHighlight) {
      double specular = rx * vx + ry * vy + rz * vz;
      if (specular > 0) {
        total += SPECULAR * Math.pow(specular, SHININESS) / d2;
      }
    }

    return (int)Math.min(255, total);
  }

  public void processEvent(AWTEvent e) {
    int id = e.getID();
    if (id == MouseEvent.MOUSE_PRESSED || id == MouseEvent.MOUSE_RELEASED) {
      M[2] = 502 - id;
    } else if (id == MouseEvent.MOUSE_MOVED || id == MouseEvent.MOUSE_DRAGGED) {
      M[0] = ((MouseEvent) e).getX();
      M[1] = ((MouseEvent) e).getY();
    }
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

