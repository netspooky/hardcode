import java.io.*;
import java.util.*;
import java.util.List;
import javax.imageio.*;

import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;
import javax.swing.*;

public class Buggaroo extends MouseAdapter implements KeyListener, MouseListener, MouseMotionListener {
   private static final int[] k=new int[65794];

   public static void main(String[] args)  throws Exception {
      Buggaroo bb=new Buggaroo();

      double[] lastDist=new double[1];

      int i=0;

      int levelCnt=6;
      int score=0;
      int lines=0;

      final JFrame w=new JFrame();
      w.setSize(640, 480);
      w.setVisible(true);
      w.createBufferStrategy(2);
      final BufferStrategy strategy=w.getBufferStrategy();

      w.addKeyListener(bb);
      w.addMouseListener(bb);
      w.addMouseMotionListener(bb);

      final BufferedImage tiles=a(Transparency.OPAQUE, w, 64, 32, null);
      final BufferedImage pl=a(Transparency.BITMASK, w, 24,24, Color.green);
      final BufferedImage en=a(Transparency.BITMASK, w, 24,24, Color.blue);

      InputStream is=bb.getClass().getResourceAsStream("/l");
      byte[][] level=new byte[40][];
      while (lines<15) {
        byte[] lii=new byte[38];
        is.read(lii);
        level[lines++]=lii;
      }

      Font arial=new Font("Arial", Font.BOLD, 12);
      int playerPower=1;
      int showUp=0;
      int downCnt=5;


      do {
         int enemyCnt=0;
         int bulletCnt=0;

         List bullets=new ArrayList();
         int xpos=11264, ypos=11264;
         int[] enemies=new int[levelCnt<<3];
         int cnt=16;
         int dd=239/levelCnt;

         while (enemyCnt<(levelCnt<<3)) {
            int x=(int) (Math.random()*34)+6;
            int y=(int) (Math.random()*lines)+6;
            try {
               if (level[y][x]==0) {
                  enemyCnt++;
                  enemies[enemyCnt++]=(x<<13)+3072; // x
                  enemies[enemyCnt++]=(y<<13)+3072; // y
                  enemies[enemyCnt++]=cnt; // Typ
                  enemies[enemyCnt++]=1;
                  enemyCnt+=3;
                  cnt+=dd;
               }
            } catch (Exception e) {}
         }
         long s=0;
         long tick=System.currentTimeMillis();
         cnt=levelCnt;
         Iterator itty=null;

         while (w.isVisible()&&(playerPower>=24||k[KeyEvent.VK_SPACE]==0) && cnt>0) {
            long b=System.currentTimeMillis();
            long tt=b-tick;
            Thread.yield();
            if (tt>8) {
               float mul=tt/10f;
               int imul=(int)(mul+0.5f);
               tick=b;
               Graphics g=strategy.getDrawGraphics();
               g.setFont(arial);
               g.setColor(Color.black);
               g.fillRect(0, 0, 640, 480);
               g.setColor(Color.white);

               // Level zeichnen:

               int ypi=ypos>>13;
               int xpi=xpos>>13;

               int xppos=xpos>>8;
               int yppos=ypos>>8;

               int dy=-(yppos-(ypi<<5))-16;
               int dx=0;

               for (i=-8; i<9; i++) {
                  int yp=ypi+i;
                  if (yp>=0&&level[yp]!=null) {
                     dx=-(xppos-(xpi<<5));
                     for (int x=-10; x<11; x++) {
                        int xp=xpi+x;
                        if (xp>=0&&xp<38) {
                           int pos=level[yp][xp]<<5;
                           g.drawImage(tiles, dx, dy,32+dx,32+dy,pos,0,32+pos,32, null);
                           //g.drawImage(tiles, dx, dy,32+dx,32+dy,32,0,64,32, null);
                        }
                        dx+=32;
                     }
                  }
                  dy+=32;
               }

               // Tasten abfragen:
               int mx=0;
               int my=0;

               if (playerPower>=24) {
                  if (k[KeyEvent.VK_LEFT]==1) {
                     mx=-1;
                  }
                  if (k[KeyEvent.VK_RIGHT]==1) {
                     mx=1;
                  }
                  if (k[KeyEvent.VK_UP]==1) {
                     my=-1;
                  }
                  if (k[KeyEvent.VK_DOWN]==1) {
                     my=1;
                  }

                  // Schiessen:
                  bulletCnt-=mul;
                  if (k[65537]==1 && bulletCnt<=0) {
                     int tx=k[65792]-320;
                     int ty=k[65793]-240;
                     double len=Math.sqrt(tx*tx+ty*ty);
                     bullets.add(new int[] {xppos<<8, yppos<<8, (int) (512*mul*tx/len), (int) (512*mul*ty/len), -1});
                     bulletCnt=20;
                  }
               }
               // Schüsse bewegen
               for (itty=bullets.iterator(); itty.hasNext(); ) {
                  int[] posDir=(int[]) itty.next();
                  i=1;
                  if (a(posDir[2]>>8, posDir[3]>>8, posDir[0]>>8, posDir[1]>>8, 1, 2, level)) {
                     posDir[0]+=posDir[2];
                     posDir[1]+=posDir[3];
                     g.fillRoundRect(316+((posDir[0]>>8)-xppos),236+((posDir[1]>>8)-yppos),6,6,3,3);
                     i=0;
                     if (posDir[i+4]!=-1 && a(xppos, yppos, posDir[0]>>8, posDir[1]>>8, 16,lastDist)) {
                       playerPower-=4;
                       i=1;
                     }
                  }
                  if (i==1) {
                     itty.remove();
                  }
               }

               // Spieler zeichnen:
               g.drawImage(pl, 308, 228, null);
               g.drawString(Integer.toHexString(playerPower).toUpperCase(), 313, 245);

               // Gegner zeichnen:
               for (i=0; i<enemyCnt; i+=8) {
                  int exs=enemies[i+1]>>8;
                  int eys=enemies[i+2]>>8;

                  dx=exs-xppos;
                  dy=eys-yppos;

                  if (enemies[i+4]>0) {
                     for (itty=bullets.iterator(); itty.hasNext(); ) {
                        int[] posDir=(int[]) itty.next();
                        if (posDir[4]==-1&&a(posDir[0]>>8, posDir[1]>>8, exs, eys, 16,lastDist)) {
                           enemies[i+3]-=4;
                           if (enemies[i+3]<16) {
                              score+=300;
                              enemies[i+3]=enemies[i+4]=0;
                              cnt--;
                           }
                           itty.remove();
                        }
                     }
                     if (enemies[i+4]>0) {
                        int ntx=enemies[i+5]>>16;
                        int nty=enemies[i+6]>>16;

                        int tx=enemies[i+5]&0x0000ffff;
                        int ty=enemies[i+6]&0x0000ffff;

                        int ex=(exs-16)>>5;
                        int ey=(eys-16)>>5;

                        // Annährung?
                        if (a(xppos, yppos, exs, eys, 64,lastDist)) {
                           if (enemies[i+7]==0) {
                              tx=enemies[i+5]=exs+(dx<<2);
                              ty=enemies[i+6]=eys+(dy<<2);
                              ntx=nty=0;
                              enemies[i+7]++;
                           }
                        } else {
                           enemies[i+7]=0;
                        }

                        // Gegner feuert?
                        if (lastDist[0]<256&&playerPower>=24) {
                           if (lastDist[0]<25&&k[65539]==1) {
                             int dr=enemies[i+3];
                              if (playerPower>dr) {
                                 playerPower+=dr;
                                 downCnt=6-(playerPower/85);
                                 if (playerPower>255) {
                                    downCnt=1;
                                    playerPower=255;
                                 }
                                 score+=dr<<3;
                                 enemies[i+4]=ex=-999;
                                 cnt--;
                              } else {
                                 if (Math.random()<0.06) {
                                    playerPower-=2;
                                    enemies[i+3]-=2;
                                    if (enemies[i+3]<16) {
                                       score+=400;
                                       enemies[i+3]=enemies[i+4]=0;
                                       cnt--;
                                    }
                                 }
                              }
                           }
                           if (Math.random()<0.00004*mul*(enemies[i+3]+playerPower)) {
                              float len=(float) Math.sqrt(dx*dx+dy*dy);
                              bullets.add(new int[] {enemies[i+1], enemies[i+2], (int) (-400*mul*dx/len), (int) (-400*mul*dy/len), i});
                           }
                        }

                        xpi=(int)(Math.random()*40);
                        ypi=(int)(Math.random()*lines);
                        int spd=enemies[i+3];

                        if (ex==ntx&&ey==nty||(ntx==0&&nty==0)) {
                           if (ntx!=tx||nty!=ty) {
                              dx=tx-ex;
                              dy=ty-ey;
                              ntx=ex;
                              nty=ey;
                              if (dx>0) {
                                 ntx++;
                              }
                              if (dx<0) {
                                 ntx--;
                              }
                              if (dy>0) {
                                 nty++;
                              }
                              if (dy<0) {
                                 nty--;
                              }
                           } else {
                              // Ziel erreicht!;
                              tx=xpi;
                              ty=ypi;
                              ntx=0;
                              nty=0;
                           }
                           enemies[i+5]=tx|(ntx<<16);
                           enemies[i+6]=ty|(nty<<16);
                        } else {
                           ntx-=ex;
                           nty-=ey;

                           if (ntx>0) {
                              ntx=1;
                           }
                           if (ntx<0) {
                              ntx=-1;
                           }
                           if (nty>0) {
                              nty=1;
                           }
                           if (nty<0) {
                              nty=-1;
                           }

                           if (nty!=0&&!a(0, nty*imul, exs, eys, 12, 9, level)) {
                              nty=0;
                           }

                           if (ntx!=0&&!a(ntx*imul, 0, exs, eys, 12, 9, level)) {
                              ntx=0;
                           }

                           if (nty==0&&ntx==0) {
                              if (Math.random()<0.0007*mul*(enemies[i+3]+playerPower)) {
                                 enemies[i+5]=xppos>>5;
                                 enemies[i+6]=yppos>>5;
                              } else {
                                 enemies[i+5]=xpi;
                                 enemies[i+6]=ypi;
                              }
                           }

                           enemies[i+1]+=ntx*spd*mul;
                           enemies[i+2]+=nty*spd*mul;
                        }

                        xpi=308+((enemies[i+1]>>8)-xppos);
                        ypi=228+((enemies[i+2]>>8)-yppos);
                        g.drawImage(en, xpi, ypi, null);
                        g.drawString(Integer.toHexString(spd).toUpperCase(), xpi+5, ypi+17);
                       // g.drawLine(xpi,ypi,308+(((enemies[i+5]&0x0000ffff)*32)-xppos),228+(((enemies[i+6]&0x0000ffff)*32)-yppos));
                     }
                  } else {
                       if (enemies[i+4]>-100) {
                          enemies[i+4]--;
                          g.drawString("BOOM!", 300+dx, 232+dy);
                       }
                    }
               }

               if (a(0, my*imul, xppos, yppos, 12, 9, level)) {
                  ypos+=(my<<8)*mul;
               }
               if (a(mx*imul, 0, xppos, yppos, 12, 9, level)) {
                  xpos+=(mx<<8)*mul;
               }

               if (k[65539]==1) {
                  g.drawOval(305, 225, 29, 29);
               }

               if (playerPower<24) {
                  g.drawString("GAME OVER - press space", 240, 220);
                  levelCnt=6;
               }
               g.drawString(String.valueOf(score), 16, 48);
               //fps++;

               if (cnt==0) {
                  levelCnt++;
                  s=System.currentTimeMillis();
               }

               if (showUp>-1) {
                  g.drawString("Level "+String.valueOf(levelCnt-5),300,200);
               }
               strategy.show();
            }

            if (b-s>1000) {
               if (downCnt<=0 && playerPower>32) {
                 playerPower-=2;
                 if (playerPower<32) {// Das *könnte* noch weg...
                   playerPower=32;
                 }
                  downCnt=4-(playerPower/85);
               }
               downCnt--;
               s=b;
               showUp--;
            }
         }
         showUp=2;
         if (playerPower<24) {
            score=0;
         }
         playerPower=32;
      } while(w.isVisible());
      System.exit(0);
   }

   private static final boolean a(int xs, int ys, int xd, int yd, int r, double[] lastDist) {
      int dx=xd-xs;
      int dy=yd-ys;
      lastDist[0]=Math.sqrt(dx*dx+dy*dy);
      return lastDist[0]<=r;
   }

   private static final boolean a(int x, int y, int xpos, int ypos, int halfSize, int maxIt, byte[][] level) {
      byte[] COL_MASK= {1, 6, 9, 11, 12, 11, 9, 6, 1};
      for (int yi=-halfSize; maxIt-->0; yi+=halfSize>>2) {
         for (int p=-1; p<2; p+=2) {
            if (level[((yi+y+ypos)>>5)][((xpos+x+p*COL_MASK[maxIt])>>5)]!=0) {
               return false;
            }
         }
      }
      return true;
   }


   private static final BufferedImage a(int mode, JFrame w, int wi,int hi, Color col) throws Exception {
      // InputStream wird nicht mehr geschlossen...dreckig, aber kürzer...:-)
      BufferedImage  bi=((Graphics2D)w.getGraphics()).getDeviceConfiguration().createCompatibleImage(wi, hi, mode);
      Graphics2D g=(Graphics2D)bi.getGraphics();
      if (wi!=24) {
         g.setPaint(new GradientPaint(16, 8, Color.gray, 32, 8, Color.darkGray, true));
         g.fillRect(0, 0, 32, 32);
         g.setPaint(new GradientPaint(72, 16, new Color(0x0808018), 32, 0, new Color(0xc0c000)));
         g.fillRect(32, 0, 32, 32);
      } else {
         g.setPaint(new GradientPaint(0, 0, col, 24, 24, Color.black));
         g.fillOval(0, 0, 24, 24);
      }
      return bi;
   }


   public void keyTyped(KeyEvent e) {}

   public void keyPressed(KeyEvent e) {
      k[e.getKeyCode()]=1;
   }

   public void keyReleased(KeyEvent e) {
      k[e.getKeyCode()]=0;
   }

   public void mousePressed(MouseEvent m) {
      k[m.getButton()+65536]=1;
   }

   public void mouseReleased(MouseEvent m) {
      k[m.getButton()+65536]=0;
   }

   public void mouseMoved(MouseEvent m) {
      k[65792]=m.getX();
      k[65793]=m.getY();
   }

    public void mouseDragged(MouseEvent m) {
      mouseMoved(m);
  }

}
