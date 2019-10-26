/*******************************************************************************
    Meat Fighter 4K
    Copyright (C) 2005  Michael Birken

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*******************************************************************************/

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;
import java.util.*;

public final class M extends JApplet implements ActionListener, KeyListener {
  
  BasicStroke stroke = new BasicStroke(
        4f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND);
  BufferedImage[][][] sprites = new BufferedImage[2][2][4];
  BufferedImage tree;
  BufferedImage background;
  BufferedImage hidden;
  Graphics h;
  Random random = new Random();
  int[][] fighter = new int[2][32];
  int[] jmp = new int[32];
  int fight;
  int level;
  int winning;
  boolean isPlaying;
  int frames;

  Color[] colors = { Color.RED, Color.BLACK, Color.WHITE };
  Color[] fColors = { Color.ORANGE, Color.LIGHT_GRAY, Color.PINK,  
      Color.MAGENTA, Color.CYAN, Color.YELLOW };
  int body = 0x9860;
  int seq = 0x40302120;
  int[][] D0 = {
    { 0x6d6e776b,0x6a856978,0x7a8c718c,0x7e7f },  
    { 0x6e137d10,0x59345d25,0x6f615e45,0x74a27983,0x66c969b3,0x7bd66ed2,
          0xa3bc8ad4,0xa865aa92,0x941a9e37 },
    { 0x63276a30,0x4e325227,0x5a4f534b,0x6c456a4c },
    { 0x53365c36,0x53494f39,0x5e4d594e,0x6049 },
    { 0x66466e4b,0x4c4b5446,0x4a574a50,0x555d4e5b,0x6d55615b,0x704f },
    { 0x682a762a,0x65486230,0x744d6a4d,0x7d3f7b48,0x7b2d },
    { 0x6636633a,0x72426f36,0x6a4c714c,0x6547 },
    { 0x7c5b6f60,0x875c884e,0x7b65 }
  };
  int[][][] D1 = {
    { { 0xa7f19dff,0xceffb7f0 },
    { 0xa1c690bc,0xaddcaddc,0xaeef }, 
    { 0x71fe6aed,0x56ed44fe },
    { 0x5ddd69cd,0x5cec } },
    { { 0x84ef80ff,0xacfe96ed },
    { 0x72dd72ec,0x75d4, },
    { 0x7dee7ffe,0x5bff69ed },
    { 0x98dc8dec,0x8fbc97c7 } },
    { { 0x896e9069,0x756b8269,0x73886f77,0x8e867d8e,0x967b8f7b },
    { 0xa26e9371,0xb45bae67,0xaa4bb24f,0x93509f4c } },
    { { 0x3e49364f,0x36603f64,0x1d642f64,0x174e175c,0x30451d46 },
    { 0x92503e53 } },
    { { 0x78437833,0x6c45723e,0x55395c45,0x6b255627,0x7033 },
    { 0x9a3a7839,0xb246b03e,0x934fa54d } },
    { { 0xa61d9c32,0x51127f07,0x3426532c,0x186a1840,0x339f3f7f,0xbaaf5bb1,
      0xb873d592,0xd73ad062,0xc326, },
      { 0x62ff5af5,0xa3f19bff,0xa07e9399,0x8b78936f,0x696d886d } }
  }; 
  
  private int next(int[] array, int index) {
    index >>= 1;
    int value = array[index]&0xff;
    array[index]>>=8;
    return value;
  }
  
  private int[] copy(int[] a) {
    int[] b = new int[a.length];
    System.arraycopy(a, 0, b, 0, a.length);
    return b;
  }
  
  private void drawPolygon(Graphics2D graphics, Color color, int[] p) {
    int[] polygon = copy(p);
    graphics.setColor(color);
    
    graphics.setStroke(stroke);
    int length = polygon.length << 1;
    int[] y = new int[length];
    int[] x = new int[length];
    for(int i = 0; i < length; i++) {
      y[i] = next(polygon, i);
      x[i] = next(polygon, i);
      if (x[i] == 0) {
        length--;
      }
    }
    graphics.fillPolygon(x, y, length);
    drawLine(graphics, p, true);   
  }
  
  private void drawLine(Graphics2D graphics, int[] l, boolean close) {
    int[] line = copy(l);
    graphics.setColor(Color.BLACK);
    graphics.setStroke(stroke);
    int length = line.length << 1;
    int y1 = next(line, 0);
    int x1 = next(line, 0);
    int y = y1;
    int x = x1;
    for(int i = 1; i < length; i++) {
      int y2 = next(line, i);
      int x2 = next(line, i);
      if (x2 == 0) {
        break;
      }
      graphics.drawLine(x1, y1, x2, y2);
      x1 = x2;
      y1 = y2;
    }
    if (close) {
      graphics.drawLine(x1, y1, x, y);
    }
  }

  public void keyTyped(KeyEvent e) {
  }
  
  public void keyPressed(KeyEvent e) {
    int k = e.getKeyCode();
    if (k == KeyEvent.VK_ENTER) {
      if (!isPlaying) {          
        isPlaying = true;
        level = 0;
        reset();
      }
    }
    if (!isPlaying || fight > 0) {
      return;
    }
        
    if (k == KeyEvent.VK_LEFT) { 
      fighter[0][2] = 1;
    } else if (k == KeyEvent.VK_RIGHT) {
      fighter[0][2] = 2;
    } else if (k == KeyEvent.VK_D) {  // D = Punch
      fighter[0][3] = 5;
    } else if (k == KeyEvent.VK_A) {  // A = Block
      fighter[0][4] = 1;
    } else if (k == KeyEvent.VK_UP) { // UP = Jump
      if (fighter[0][5] == 0) {
        fighter[0][5] = 17;
      }
    }
  }
  
  public void keyReleased(KeyEvent e) {
    int k = e.getKeyCode();
    if (k == KeyEvent.VK_LEFT || k == KeyEvent.VK_RIGHT) {
      fighter[0][2] = 0;
    } else if (k == KeyEvent.VK_A) {
      fighter[0][4] = 0;
    }
  }
  
  private void reset() {
    fighter[0][0] = -64;
    fighter[0][1] = 200;
    fighter[1][0] = 447;
    fighter[1][1] = 200; 
    for(int i = 0; i < 2; i++) {
      fighter[i][6] = 1; 
      fighter[i][7] = 128;
      fighter[i][8] = 8; 
      fighter[i][10] = random.nextInt(800); 
      fighter[i][11] = 200;
    }
    if (isPlaying) {
      fighter[0][6] = 0;
      fight = 150;
    }
    createFighter(1, fColors[level]);
  }
  
  private void createFighter(int f, Color c) {
    colors[0] = c;
    int sq = seq;
    for(int j = 0; j < 4; j++) {
      sprites[f][0][j] = new BufferedImage(
          256, 256, BufferedImage.TYPE_INT_ARGB_PRE);
      Graphics2D g = (Graphics2D)sprites[f][0][j].getGraphics();
      int b = body;
      for(int i = 0; i < 8; i++) {
        drawPolygon(g, colors[b & 3], D0[i]);
        b >>= 2;
      }
      for(int i = 0; i < 2; i++) {
        int[][] d = D1[sq&15];
        sq >>= 4;
        for(int k = 0; k < d.length; k+=2) {
          drawPolygon(g, c, d[k]);
          drawLine(g, d[k+1], false);
        }
      }
      g.dispose();
      sprites[f][1][j] = new BufferedImage(
          256, 256, BufferedImage.TYPE_INT_ARGB_PRE);
      g = (Graphics2D)sprites[f][1][j].getGraphics();
      g.drawImage(sprites[f][0][j], 255, 0, 0, 255, 0, 0, 255, 255, null);
      g.dispose();      
    }
  }

  public void init() {
    for(int i = 0, j = 256; i < 10; i++, j >>= 1) {
      jmp[i] = jmp[19 - i] = j - 56;
    }
    reset();    
    hidden = new BufferedImage(640, 480, BufferedImage.TYPE_USHORT_555_RGB);
    h = hidden.getGraphics();
    h.setFont(new Font("Serif", Font.BOLD, 32));
    tree = new BufferedImage(256, 256, BufferedImage.TYPE_INT_ARGB_PRE);
    Graphics2D g2 = (Graphics2D)tree.getGraphics();
    drawPolygon(g2, Color.WHITE, D1[5][0]);
    background = new BufferedImage(800, 480, BufferedImage.TYPE_USHORT_555_RGB);
    Graphics2D g = (Graphics2D)background.getGraphics();
    g.setColor(Color.BLUE);
    g.fillRect(0, 0, 800, 480);    
    g.drawImage(tree, 480, 64, null);
    drawPolygon(g2, Color.GREEN, D1[5][0]);
    drawPolygon(g2, new Color(191,127,0), D1[5][1]);
    g.setColor(Color.GREEN);
    g.fillRect(0, 380, 800, 100);
    g.drawImage(tree, 100, 150, null);
    g2.dispose();
    g.dispose();
    createFighter(0, Color.RED);    
    addKeyListener(this);
    new javax.swing.Timer(15, this).start();
  }
  
  public void actionPerformed(ActionEvent e) {
    Graphics g = getGraphics();
    int offset = -160*(fighter[0][0]+64)/640;
    h.drawImage(background, offset, 0, null);
    if (fight == 0) {
      for(int i = 1; i >= 0; i--) {
        int[] f = fighter[i];
        if (f[2] == 1) {
          if (f[0] > -64) {
            f[0] -= 4;
          }
        } else if (f[2] == 2) {
          if (f[0] < 447) {
            f[0] += 4;
          }     
        }
        f[1] = jmp[f[5]];
        if (f[5] > 0) {
          f[5]--;
        }
        int x = f[0];
        int s = 0;
        if (i == 1) {
          x += offset;
        }
        s = ((fighter[0][0] < fighter[1][0]-128) ? 1 : 0) ^ i;
        if (f[4] > 0) {
          h.drawImage(sprites[i][s][3], x, f[1], null);
          f[3] = 0;
        } else if (f[3] > 0) {
          h.drawImage(sprites[i][s][2], x, f[1], null);
          if (--f[3] == 0) {
            if (Math.abs(fighter[0][0] - fighter[1][0]) < 100) {
              int other = i ^ 1;
              if (fighter[other][4] == 0 && fighter[other][11] >= 0) {
                fighter[other][11] -= 10;
                if (fighter[other][11] == 0) {
                  if (++fighter[i][12] == 2) {
                    fighter[0][12] = fighter[1][12] = 0;
                    if (i == 0) {
                      if (++level == 6) {
                        level = 0;
                        if (isPlaying) {
                          fight = winning = 300;
                          isPlaying = false;                          
                        } 
                      }
                    } else {
                      isPlaying = false;
                      level = 0;
                    }
                  }
                  reset();
                }
              }
            }  
          }
        } else {
          h.drawImage(sprites[i][s][(f[0]/20)&1], x, f[1], null);
        }

        if (f[6] > 0) {
          int div = level + 1;
          if (--f[7] == 0) {
            f[7] = 64 + random.nextInt(128);
            f[5] = 17;
          }
          if (--f[9] > 64) {
            if (--f[8] == 0) {
              f[8] = 6 + random.nextInt(128 / div);
              f[3] = 5;
            }
            f[4] = 0;
          } else {
            if (f[9] < 0) {
              f[9] = 128 + random.nextInt(128 / div);
            }
            f[4] = 1;
          }
          int diff = f[0] - f[10];
          if (Math.abs(diff) < 16) {
            f[10] = random.nextInt(800) - 128;
          } else {
            f[0] += (diff > 0) ? -(4+level) : 4+level;
          }
        }
      }
    } else {
      h.drawImage(sprites[0][1][0], fighter[0][0], fighter[0][1], null);
      h.drawImage(sprites[1][0][0], fighter[1][0]+offset, fighter[1][1], null);
      if (((--fight/10)&1) == 1) {        
        h.drawString("FIGHT", 290, 240);        
      }      
    }
    h.setColor(Color.YELLOW);
    h.fillRect(10, 10, fighter[0][11], 32);
    h.fillRect(629 - fighter[1][11], 10, fighter[1][11], 32);
    h.drawString(Integer.toString(fighter[0][12]), 235, 37);
    h.drawString(Integer.toString(fighter[1][12]), 395, 37);
    if (--winning > 0) {
      h.drawImage(background, offset, 0, null);
      h.drawString("THE END", 265, 140);
      h.drawString("-- Mike Birken", 350, 370);      
    } else if (!isPlaying) {
      if (((++frames/20)&1) == 1) {
        String str = "press enter";
        h.setColor(Color.BLACK);
        h.drawString(str, 247, 442);
        h.setColor(Color.WHITE);
        h.drawString(str, 245, 440);
      }
      String mf = "Meat Fighter 4K";
      h.setColor(Color.BLACK);
      h.drawString(mf, 207, 112);
      h.setColor(Color.RED);
      h.drawString(mf, 205, 110);
    }    
    g.drawImage(hidden, 0, 0, null);
    g.dispose();
  }
}
