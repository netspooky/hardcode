/*
 * Ultimate Tic-Tac-Toe
 * Copyright (C) 2009 Michael Birken
 *
 * This file is part of Ultimate Tic-Tac-Toe.
 *
 * Ultimate Tic-Tac-Toe is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Ultimate Tic-Tac-Toe is distributed in the hope that it will be useful,
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

  private boolean M;

  public M() {

    BufferedImage image = new BufferedImage(
        640, 640, BufferedImage.TYPE_INT_RGB);
    Graphics2D imageGraphics = image.createGraphics();
    imageGraphics.setRenderingHint(
        RenderingHints.KEY_TEXT_ANTIALIASING,
        RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
    imageGraphics.setRenderingHint(
        RenderingHints.KEY_ANTIALIASING,
        RenderingHints.VALUE_ANTIALIAS_ON);
    imageGraphics.setRenderingHint(
        RenderingHints.KEY_INTERPOLATION,
        RenderingHints.VALUE_INTERPOLATION_BICUBIC);
    imageGraphics.setStroke(new BasicStroke(
        10, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND));

    JPanel panel = (JPanel)getContentPane();
    panel.setBackground(Color.BLACK);
    panel.setPreferredSize(new Dimension(640, 640));
    enableEvents(AWTEvent.MOUSE_EVENT_MASK|AWTEvent.MOUSE_MOTION_EVENT_MASK
        |AWTEvent.KEY_EVENT_MASK);
    setTitle("Ultimate Tic-Tac-Toe");
    JLabel label = new JLabel("LOADING...", SwingConstants.CENTER);
    label.setForeground(Color.WHITE);
    label.setFont(imageGraphics.getFont().deriveFont(64f));
    panel.add(label);
    pack();
    setLocationRelativeTo(null);
    show();

    int[][] wins = new int[5][5];
    int[][][][][] winPaths = new int[5][5][9][4][2];
    int[] result = new int[5];
    int score = 0;
    int totalMoves = 0;
    int[][][] evaluationPath = new int[4][25][2];
    int[][] board = new int[5][5];
    boolean lastPlayer = true;

    for(int y = 0; y < 5; y++) {
      for(int x = 0; x < 5; x++) {
        for(int i = 0; i < 8; i++) {
          double angle = i * Math.PI / 4.0;
          int dx = Math.cos(angle) > 0.5 ? 1 : Math.cos(angle) < -0.5 ? -1 : 0;
          int dy = Math.sin(angle) > 0.5 ? 1 : Math.sin(angle) < -0.5 ? -1 : 0;
          for(int k = -1; k <= 0; k++) {
            int count = 0;
            for(int j = 0; j < 4; j++) {
              int X = (j + k) * dx + x;
              int Y = (j + k) * dy + y;
              if (X >= 0 && Y >= 0 && X < 5 && Y < 5) {
                count++;
              }
              int index = wins[y][x];
              winPaths[y][x][index][j][0] = X;
              winPaths[y][x][index][j][1] = Y;
            }
            if (count == 4) {
              wins[y][x]++;
            }
          }
        }
      }
    }

    int pathIndex = 0;
    for(int i = 8; i >= 3; i--) {
      for(int y = 0; y < 5; y++) {
        for(int x = 0; x < 5; x++) {
          if (wins[y][x] == i) {
            evaluationPath[0][pathIndex][0] = x;
            evaluationPath[0][pathIndex][1] = y;
            pathIndex++;
          }
        }
      }
    }
    pathIndex = 0;
    for(int i = 8; i >= 3; i--) {
      for(int y = 4; y >= 0; y--) {
        for(int x = 0; x < 5; x++) {
          if (wins[y][x] == i) {
            evaluationPath[1][pathIndex][0] = x;
            evaluationPath[1][pathIndex][1] = y;
            pathIndex++;
          }
        }
      }
    }
    pathIndex = 0;
    for(int i = 8; i >= 3; i--) {
      for(int y = 4; y >= 0; y--) {
        for(int x = 4; x >= 0; x--) {
          if (wins[y][x] == i) {
            evaluationPath[2][pathIndex][0] = x;
            evaluationPath[2][pathIndex][1] = y;
            pathIndex++;
          }
        }
      }
    }
    pathIndex = 0;
    for(int i = 8; i >= 3; i--) {
      for(int y = 0; y < 5; y++) {
        for(int x = 4; x >= 0; x--) {
          if (wins[y][x] == i) {
            evaluationPath[3][pathIndex][0] = x;
            evaluationPath[3][pathIndex][1] = y;
            pathIndex++;
          }
        }
      }
    }

    BufferedImage[][][][] sphereImages = new BufferedImage[2][2][3][3];
    int[] pixels = new int[16384];
    for(int outterIndex = 0; outterIndex < 2; outterIndex++) {
      for(int innerIndex = 0; innerIndex < 2; innerIndex++) {
        for (int I = 0; I < 3; I++) {
          for (int J = 0; J < 3; J++) {

            sphereImages[outterIndex][innerIndex][I][J]
                    = new BufferedImage(128, 128, BufferedImage.TYPE_INT_ARGB);

            for (int y = 0, k = 0; y < 128; y++) {
              for (int x = 0; x < 128; x++, k++) {

                pixels[k] = 0;

                double red = 0;
                double green = 0;
                double blue = 0;

                double a = 0;
                double b = 0;
                double c = -334;

                double d = x - 64;
                double e = y - 64;
                double f = 320;

                boolean hit = false;
                int maxDepth = I == 1 && J == 1 ? 1 : 5;

                for (int depth = 0; depth < maxDepth; depth++) {

                  double kr = outterIndex == 0 ? 255 : 0;
                  double kg = 0;
                  double kb = outterIndex == 0 ? 0 : 255;

                  double g = 0;
                  double h = 0;
                  double i = 0;

                  if ((depth & 1) == 1) {
                    kr = innerIndex == 0 ? 255 : 0;
                    kg = 0;
                    kb = innerIndex == 0 ? 0 : 255;

                    g = 128 * (J - 1);
                    h = 128 * (I - 1);
                  }

                  double p = a - g;
                  double q = b - h;
                  double r = c - i;

                  double A = d * d + e * e + f * f;
                  double B = 2 * (p * d + q * e + r * f);
                  double C = p * p + q * q + r * r - 4096;

                  double discriminant = B * B - 4 * A * C;
                  if (discriminant >= 0) {

                    discriminant = Math.sqrt(discriminant);
                    double t1 = (-B + discriminant) / (2 * A);
                    double t2 = (-B - discriminant) / (2 * A);
                    double t = Math.min(t1, t2);
                    if (t < 0) {
                      break;
                    }

                    double X = a + d * t;
                    double Y = b + e * t;
                    double Z = c + f * t;

                    double nx = X - g;
                    double ny = Y - h;
                    double nz = Z - i;
                    double mag = Math.sqrt(nx * nx + ny * ny + nz * nz);
                    nx /= mag;
                    ny /= mag;
                    nz /= mag;

                    double lx = 128 - X;
                    double ly = -128 - Y;
                    double lz = -320 - Z;
                    double d2 = lx * lx + ly * ly + lz * lz;
                    mag = Math.sqrt(d2);
                    lx /= mag;
                    ly /= mag;
                    lz /= mag;

                    double lDOTn = nx * lx + ny * ly + nz * lz;
                    if (lDOTn < 0) {
                      lDOTn = 0;
                    }

                    double vx = -X;
                    double vy = -Y;
                    double vz = -334 - Z;
                    mag = Math.sqrt(vx * vx + vy * vy + vz * vz);
                    vx /= mag;
                    vy /= mag;
                    vz /= mag;

                    double rx = -lx + 2 * lDOTn * nx;
                    double ry = -ly + 2 * lDOTn * ny;
                    double rz = -lz + 2 * lDOTn * nz;

                    double rDOTv = rx * vx + ry * vy + rz * vz;
                    if (rDOTv < 0) {
                      rDOTv = 0;
                    }

                    double id = 90000 / d2;
                    double is = 90000 / d2;

                    red += (kr / 3) + kr * id * lDOTn + 255 * is * Math.pow(rDOTv, 15);
                    green += (kg / 3) + kg * id * lDOTn + 255 * is * Math.pow(rDOTv, 15);
                    blue += (kb / 3) + kb * id * lDOTn + 255 * is * Math.pow(rDOTv, 15);

                    a = X;
                    b = Y;
                    c = Z;

                    if (maxDepth == 1 || depth > 0) {
                      hit = true;
                    }

                    double bounce = 2.0 * (d * nx + e * ny + f * nz);
                    if (bounce > 0) {
                      break;
                    }

                    d -= bounce * nx;
                    e -= bounce * ny;
                    f -= bounce * nz;

                  } else {
                    break;
                  }
                }

                red = Math.min(255, red);
                green = Math.min(255, green);
                blue = Math.min(255, blue);

                if (hit) {
                  pixels[k] = 0xFF000000 | (((int) red) << 16) | (((int) green) << 8) | (int) blue;
                }
              }
              sphereImages[outterIndex][innerIndex][I][J].setRGB(
                  0, 0, 128, 128, pixels, 0, 128);
            }
          }
        }
      }
    }
    
    BufferedImage image2 = new BufferedImage(
        320, 320, BufferedImage.TYPE_INT_ARGB);
    pixels = new int[102400];
    Random random = new Random();
    for(int b = 40, c = 5120; b <= 320; b <<= 1, c >>= 1) {
      for(int i = 0, k = 0; i < b; i++) {
        for(int j = 0; j < b; j++, k++) {
          int intensity = random.nextInt(256);
          pixels[k] = 0x3F000000 | (intensity << 16) | (intensity << 8) | intensity;
        }
      }
      image2.setRGB(0, 0, b, b, pixels, 0, b);

      imageGraphics.drawImage(image2, 0, 0, c, c, null);
    }    
    for(int i = 0; i < 5; i++) {
      for(int j = 0; j < 5; j++) {
        imageGraphics.setColor(new Color(
            ((i + j) & 1) == 0 ? 0x7FFFB592 : 0x4F5A604B, true));
        imageGraphics.fillRect(i << 7, j << 7, 128, 128);
      }
    }

    image2 = null;
    BufferedImage image3 = new BufferedImage(
        640, 640, BufferedImage.TYPE_INT_RGB);
    Graphics image3Graphics = image3.getGraphics();
    image3Graphics.drawImage(image, 0, 0, null);
    image3Graphics.dispose();
    image3Graphics = null;
    panel.remove(label);
    setIconImage(sphereImages[0][0][1][1]);

    boolean repaint = false;
    boolean playing = true;
    int winner = 0;
    while(true) {
      boolean moved = false;
      if (M) {
        M = false; 
        if (playing) {
          Point point = panel.getMousePosition();
          if (point != null) {
            int x = point.x >> 7;
            int y = point.y >> 7;
            if (board[y][x] == 0) {
              totalMoves++;
              score += wins[y][x];
              board[y][x] = 1;
              moved = repaint = true;
              outter: for(int i = wins[y][x] - 1; i >= 0; i--) {
                for(int j = 0; j < 4; j++) {
                  if (board[winPaths[y][x][i][j][1]][winPaths[y][x][i][j][0]]
                      != board[y][x]) {

                    continue outter;
                  }
                }
                result[1] = 1;
                result[2] = x;
                result[3] = y;
                result[4] = i;
                playing = false;
                break;
              }
              if (totalMoves == 25) {
                playing = false;
                result[1] = 0;
              }
            }
          }
        } else {
          playing = true;
          for(int y = 0; y < 5; y++) {
            for(int x = 0; x < 5; x++) {
              board[y][x] = 0;
            }
          }
          score = totalMoves = 0;
          imageGraphics.drawImage(image3, 0, 0, null);
          repaint = true;
          moved = false;
          if (lastPlayer) {
            board[2][2] = -1;
            totalMoves = 1;
          }
          lastPlayer = !lastPlayer;
        }
      }
      if (repaint) {
        for(int i = 0; i < 5; i++) {
          for(int j = 0; j < 5; j++) {
            if (board[i][j] != 0) {
              int outterIndex = (board[i][j] > 0) ? 0 : 1;
              imageGraphics.drawImage(sphereImages[outterIndex][0][1][1],
                  j << 7, i << 7, null);
              for(int p = 1; p >= 0; p--) {
                for(int y = 0; y < 3; y++) {
                  for(int x = 0; x < 3; x++) {
                    if (x == 1 && y == 1 || (((x + y) & 1) == p)) {
                      continue;
                    }
                    int X = x + j - 1;
                    int Y = y + i - 1;
                    if (X >= 0 && Y >= 0 && X < 5 && Y < 5) {
                      if (board[Y][X] != 0) {
                        int innerIndex = (board[Y][X] > 0) ? 0 : 1;
                        imageGraphics.drawImage(
                            sphereImages[outterIndex][innerIndex][y][x],
                                j << 7, i << 7, null);
                      }
                    }
                  }
                }
              }
            }
          }
          if (playing == false && result[1] != 2) {
            if (result[1] != 0) {
              imageGraphics.setColor(new Color(0x5F00FF00, true));
              int[][] path = winPaths[result[3]][result[2]][result[4]];
              imageGraphics.drawLine(
                  (path[0][0] << 7) + 64,
                  (path[0][1] << 7) + 64,
                  (path[3][0] << 7) + 64,
                  (path[3][1] << 7) + 64);
            }
            imageGraphics.setFont(imageGraphics.getFont().deriveFont(30f));
            imageGraphics.setColor(Color.GREEN);
            imageGraphics.fillOval(10, 20, 190, 40);
            imageGraphics.setColor(Color.RED);
            imageGraphics.drawString("RESET", 58, 51);
          }
        }
        repaint = false;
      }
      Graphics panelGraphics = panel.getGraphics();
      if (panelGraphics != null) {
        panelGraphics.drawImage(image, 0, 0, null);
        panelGraphics.dispose();
      }
      if (playing && moved) {
        setIconImage(sphereImages[1][0][1][1]);
        M(board, wins, winPaths, -1024, 1024, -1, 0, totalMoves, score, result,
            evaluationPath[random.nextInt(4)], 
            totalMoves < 4 || random.nextDouble() < 0.75 ? 5 : 2);
        score = result[0];
        totalMoves++;        
        board[result[3]][result[2]] = -1;
        if (result[1] != 2) {
          playing = false;
        } 
        repaint = true;
        setIconImage(sphereImages[0][0][1][1]);
      } else {
        try {
          Thread.sleep(100);
        } catch(InterruptedException e) {
        }
      }
    }
  }

  // result
  // 0 = score
  // 1 = state (0 = tie, -1 = p-1 wins, 1 = p1 wins, 2 = other)
  // 2 = last move x
  // 3 = last move y
  // 4 = win path index

  private void M(int[][] board, int[][] wins, int[][][][][] winPaths,
      int alpha, int beta, int player, int depth, int totalMoves,
      int score, int[] result, int[][] evaluationPath, int maxDepth) {

    int bestScore = player > 0 ? -512 : 512;
    int bestX = -1;
    int bestY = -1;
    loop: for(int p = 0; p < 25; p++) {
      int x = evaluationPath[p][0];
      int y = evaluationPath[p][1];
      if (board[y][x] == 0) {
        board[y][x] = player;

        outter: for(int i = wins[y][x] - 1; i >= 0; i--) {
          for(int j = 0; j < 4; j++) {
            if (board[winPaths[y][x][i][j][1]][winPaths[y][x][i][j][0]]
                != board[y][x]) {
              continue outter;
            }
          }

          result[0] = 256 * player;
          result[1] = player;
          result[2] = x;
          result[3] = y;
          result[4] = i;
          board[y][x] = 0;
          return;
        }

        int newScore = score + player * wins[y][x];
        if (depth < maxDepth && totalMoves < 24) {
          M(board, wins, winPaths, alpha, beta, -player, depth + 1,
              totalMoves + 1, newScore, result, evaluationPath, maxDepth);
          newScore = result[0];
        }

        if (bestX < 0 || (player > 0 && newScore > bestScore)
            || (player < 0 && newScore < bestScore)) {
          bestScore = newScore;
          bestX = x;
          bestY = y;
        }

        board[y][x] = 0;

        if (player > 0) {
          alpha = Math.max(alpha, bestScore);
          if (bestScore > beta) {
            break loop;
          }
        } else {
          beta = Math.min(beta, bestScore);
          if (bestScore < alpha) {
            break loop;
          }
        }
      }
    }

    result[0] = bestScore;
    result[1] = totalMoves == 24 ? 0 : 2;
    result[2] = bestX;
    result[3] = bestY;
  }

  public void processEvent(AWTEvent e) {
    int id = e.getID();
    M |= (id == MouseEvent.MOUSE_PRESSED);
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

