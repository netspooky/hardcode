/*
 * F-Zero 4K
 * Copyright (C) 2009 Michael Birken
 *
 * This file is part of F-Zero 4K.
 *
 * F-Zero 4K is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * F-Zero 4K is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import java.awt.event.*;
import javax.swing.*;
import java.awt.image.*;
import java.awt.*;

public class M extends JFrame {

  boolean[] K = new boolean[65535]; // pressed keys

  public M() {

    final double VIEWER_X = 159.5;
    final double VIEWER_Y = 32;
    final double VIEWER_Z = -128;    
    final double GROUND_Y = 207;    

    final int[] screenBuffer = new int[320*240];
    final int[][][] projectionMap = new int[192][320][2];
    final int[][][] wiresBitmap = new int[32][256][256];
    final int[][][] bitmaps = new int[6][32][32];
    final byte[][] raceTrack = new byte[512][512]; 
      // -1 = space
      // 0 = road
      // 1 = barrier
      // 2 = power
      // 3 = white circle
      // 4 = dark road
      // 5 = checkered road
    double playerAngle = 0;
    final double[][] vehicleMetrics = new double[10][9]; 
      // 0 = x, 1 = y
      // 2 = stunned velocity x, 3 = stunned velocity y
      // 4 = projected x, 5 = projected z
      // 6 = velocity magnitude
      // 7 = vx, 8 = vy
    final int[] powerOvalY = new int[2];
    boolean onPowerBar = false;
    boolean playing = false;

    final BufferedImage[] vehicleSprites = new BufferedImage[10];
    final int[] vehicleSpriteData = new int[64*32];
    double power = 0;
    final Color powerColor = new Color(0xFABEF1);
    final Color darkColor = new Color(0xA7000000, true);
    int wiresBitmapIndex = 0;
    double cos = 0;
    double sin = 0;
    int hitWallCount = 0;
    int rank = 0;
    int paused = 1;
    
    powerOvalY[0] = -96;
    
    
    
// -- GENERATE WIRES BITMAP BEGIN ----------------------------------------------
    
    for(int i = 0; i < 32; i++) {
      for(double t = 0; t < 2.0 * Math.PI; t += 0.001) {
        int X = 128 + (int)((256 + 64 * Math.cos(t * 3.0)) * Math.sin(t));
        int Y = 128 + (int)((256 + 64 * Math.sin(t * 3.0)) * Math.cos(t));
        int color = C(t + i * Math.PI / 16.0, 1, 1);
        for(int y = 0; y < 16; y++) {
          for(int x = 0; x < 16; x++) {
            wiresBitmap[i][0xFF & (Y + y)][0xFF & (X + x)] = color;
          }
        }
      }
    }
    
// -- GENERATE WIRES BITMAP END ------------------------------------------------
    
// -- GENERATE VEHICLE SPRITES BEGIN -------------------------------------------    

    for(int spriteIndex = 0; spriteIndex < 10; spriteIndex++) {
      vehicleSprites[spriteIndex] = new BufferedImage(
          64, 32, BufferedImage.TYPE_INT_ARGB_PRE);
      for(int y = 0, k = 0; y < 32; y++) {
        for(int x = 0; x < 64; x++, k++) {
          double dx = (x - 32.0) / 2, dy = y - 26;
          double dist1 = dx*dx + dy*dy;
          dx = (x - 31.5) / 2;
          dy = y - 15.5;
          double dist2 = dx*dx + dy*dy; 
          dy = y - 17.5;
          dx = x - 32;
          double dist3 = dx*dx + dy*dy;
          if (Math.abs(dist3 - 320) <= 24 || Math.abs(dist3 - 480) <= 24) {
            vehicleSpriteData[k] = C(
                Math.PI * spriteIndex / 1.9,
                dist1/256,
                1) | 0xff000000;
          } else if (dist2 > 256) {
            vehicleSpriteData[k] = 0;
          } else {
            vehicleSpriteData[k] = C(
                Math.PI * spriteIndex / 1.9,
                dist1/256,
                dist1/1024 + 1) | 0xff000000;
          }
        }
      }
      for(int x = 14; x < 49; x++) {
        for(int y = 21; y < 27; y++) {
          vehicleSpriteData[(y << 6) | x] = y == 21 || y == 26 || (x & 1) == 0 
              ? 0xFFCCCCCC : 0xFF000000;
        }
      }
      for(int y = 0; y < 16; y++) {
        for(int x = 0; x < 16; x++) {
          double dx = x - 7.5;
          double dy = y - 7.5;
          double dy2 = dy / 1.5;
          double dist = dx * dx + dy * dy;
          if (dx * dx + dy2 * dy2 < 64) {
            dy = y - 4;
            vehicleSpriteData[(y << 6) | (x + 24)] = C(
                3,
                dist/256,
                y > 6 && x > 3 && x < 12
                    || y > 7
                    || dx * dx + dy * dy < 8 ? 2 : 1) | 0xff000000;
          }
          if (dist < 64 || y == 0) {
            vehicleSpriteData[((16 + y) << 6) | (x + 48)] =
            vehicleSpriteData[((16 + y) << 6) | x] = C(
                Math.PI * spriteIndex / 1.9,
                dist/64,
                1) | 0xff000000;            
          }
        }
      }
      vehicleSprites[spriteIndex].setRGB(
          0, 0, 64, 32, vehicleSpriteData, 0, 64);
    }
    
// -- GENERATE VEHICLE SPRITES BEGIN -------------------------------------------

// -- GENERATE RACE TRACK BEGIN ------------------------------------------------

    for(int y = 0; y < 512; y++) {
      for(int x = 0; x < 512; x++) {
        raceTrack[y][x] = -1;
      }
    }
       
    for(int y = 0; y < 128; y++) {
      for(int x = 246; x < 261; x++) {
        raceTrack[y][x] = 0;
      }
    }
    
    for(int y = 32; y < 96; y++) {
      for(int x = 239; x < 246; x++) {        
        raceTrack[y][x] = (byte)((x < 244 && y > 33 && y < 94) ? 2 : 0);
      }
    }
    
    for(int y = 128; y < 512; y++) {
      for(int x = 243; x < 264; x++) {
        double angle = y * Math.PI / 64;
        raceTrack[y][x + (int)((8 * Math.cos(angle) + 24) * Math.sin(angle))] 
            = 0;
      }
    }
    
    for(int y = 0; y < 512; y++) {
      for(int x = 0; x < 512; x++) {
        if (raceTrack[y][x] >= 0) {
          for(int i = -1; i < 2; i++) {
            for(int j = -1; j < 2; j++) {
              if (raceTrack[0x1FF & (i + y)][0x1FF & (j + x)] == -1) {
                raceTrack[y][x] = 1;
              }
            }
          }
        }
      }
    }
    
// -- GENERATE RACE TRACK END --------------------------------------------------

// -- GENERATE BITMAPS BEGIN --------------------------------------------

    for(int y = 0; y < 32; y++) {
      for(int x = 0; x < 32; x++) {
        double dx = 15.5 - x;
        double dy = 15.5 - y;
        double dist = Math.sqrt(dx * dx + dy * dy);
        bitmaps[0][y][x] = 0xFF98A8A8;
        bitmaps[4][y][x] = 0xFF90A0A0;
        bitmaps[5][y][x] 
            = (((x >> 3) + (y >> 3)) & 1) == 0 ? 0xFF000000 : 0xFFFFFFFF;
        bitmaps[2][y][x] = C(4.5, Math.abs(dy) / 16, 1);
        if (dist < 16) {
          bitmaps[3][y][x] = 0xFFFFFFFF;
          bitmaps[1][y][x] = C(5.3, dist / 16, 1 + dist / 256);
        } else {
          bitmaps[3][y][x] = bitmaps[1][y][x] = 0xFF98A8A8;
        }
      }
    }

// -- GENERATE BITMAPS END -----------------------------------------------------

// -- COMPUTE PROJECTION MAP BEGIN ---------------------------------------------

    for(int y = 0; y < 192; y++) {
      for(int x = 0; x < 320; x++) {
        double k = (GROUND_Y - VIEWER_Y) / (48 + y - VIEWER_Y);
        projectionMap[y][x][0] = (int)(k * (x - VIEWER_X) + VIEWER_X);
        projectionMap[y][x][1] = (int)(VIEWER_Z * (1 - k));
      }
    }
    
// -- COMPUTE PROJECTION MAP END -----------------------------------------------

    setTitle("F-Zero 4K");
    setIconImage(vehicleSprites[0]);
    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    pack();
    setLocationRelativeTo(null);    
    show();

    BufferedImage image = new BufferedImage(
        320, 240, BufferedImage.TYPE_INT_RGB);
    Graphics imageGraphics = image.getGraphics();    
    Font largeFont = getFont().deriveFont(100f);
    
    long nextFrameStart = System.nanoTime();
    while(true) {
      do {
// -- UPDATE MODEL BEGIN -------------------------------------------------------

        // rotate the background colors
        wiresBitmapIndex = 0x1F & (wiresBitmapIndex + 1);

        if (paused > 0) {
          paused--;
          if (paused == 0) {
            for(int i = 0; i < 10; i++) {
              for(int j = 0; j < 9; j++) {
                vehicleMetrics[i][j] = 0;
              }
            }
            for(int i = 0; i < 4; i++) {
              vehicleMetrics[i][0] = 7984 + i * 80;
            }
            for(int i = 4; i < 10; i += 3) {
              vehicleMetrics[i][0] = 7984;
              vehicleMetrics[i][1] = 16384 * (i - 3);
              vehicleMetrics[i + 1][0] = 8144;
              vehicleMetrics[i + 1][1] = vehicleMetrics[i][1] + 2048;
              vehicleMetrics[i + 2][0] = 8144;
              vehicleMetrics[i + 2][1] = vehicleMetrics[i][1] + 3840;
            }
            power = 80;
            playerAngle = hitWallCount = 0;
            imageGraphics.setFont(getFont().deriveFont(32f));
            onPowerBar = playing = false;
          }
        } else if (vehicleMetrics[0][1] < 81984 && power > 0) {
        
          // compute rank
          rank = 1;
          for(int i = 1; i < 4; i++) {
            if (vehicleMetrics[0][1] < vehicleMetrics[i][1]) {
              rank++;
            }
          }

          // reduce power while hitting a wall
          if (hitWallCount > 0) {
            hitWallCount--;
            power -= 1;
            if (power < 0) {
              power = 0;
            }
          }

          // process player input
          if (playing) {
            if (K[KeyEvent.VK_LEFT]) {
              playerAngle += 0.075;
            } else if (K[KeyEvent.VK_RIGHT]) {
              playerAngle -= 0.075;
            }        
          }
          cos = Math.cos(playerAngle);
          sin = Math.sin(playerAngle);
          vehicleMetrics[0][4] = 0;
          vehicleMetrics[0][5] = 0;
          if (K[KeyEvent.VK_D]) {
            playing = true;
            if (vehicleMetrics[0][6] < 20) {
              vehicleMetrics[0][6] += 0.2;
            }
          } else {
            vehicleMetrics[0][6] *= 0.99;
          }

          if (playing) {
            // compute computer-controlled-vehicles velocities
            for(int i = 1; i < 10; i++) {
              if ((i < 4 && vehicleMetrics[i][6] < 20.5) 
                  || vehicleMetrics[i][6] < 10)  {
                vehicleMetrics[i][6] += 0.2 + i * 0.2;
              }
              double targetZ = 11 + vehicleMetrics[i][1];
              double tz = (targetZ / 32) % 512;
              double targetX = 7984 + (i & 0x03) * 80;
              if (i >= 4) {
                targetX += 32;
              }

              if (tz >= 128) {
                double angle = tz * Math.PI / 64;
                targetX += ((8 * Math.cos(angle) + 24) * Math.sin(angle)) * 32;
              }

              double vx = targetX - vehicleMetrics[i][0];
              double vz = targetZ - vehicleMetrics[i][1];
              double mag = Math.sqrt(vx * vx + vz * vz);
              vehicleMetrics[i][7] 
                  = vehicleMetrics[i][2] + vehicleMetrics[i][6] * vx / mag;
              vehicleMetrics[i][8] 
                  = vehicleMetrics[i][2] + vehicleMetrics[i][6] * vz / mag;
            }

            // player on power bar?
            onPowerBar = false;
            if (raceTrack[0x1FF & (((int)vehicleMetrics[0][1]) >> 5)]
                [0x1FF & (((int)vehicleMetrics[0][0]) >> 5)] == 2) {               
              onPowerBar = true;
              for(int i = 0; i < 2; i++) {
                powerOvalY[i] += 16;
                if (powerOvalY[i] >= 192) {
                  powerOvalY[i] = -32;
                }
              }
              if (power < 80) {
                power += 0.2; 
              }
            }

            vehicleMetrics[0][7] = vehicleMetrics[0][2] 
               - vehicleMetrics[0][6] * sin;
            vehicleMetrics[0][8] = vehicleMetrics[0][3] 
               + vehicleMetrics[0][6] * cos;

            // vehicle hitting something?      
            for(int j = 0; j < 10; j++) {

              // vehicle hitting another vehicle?
              for(int i = 0; i < 10; i++) {
                if (i != j) {
                  double normalX = (vehicleMetrics[j][0] 
                      - vehicleMetrics[i][0]) / 2;
                  double normalZ = vehicleMetrics[j][1] 
                      - vehicleMetrics[i][1];  
                  double dist2 = normalX * normalX + normalZ * normalZ;
                  if (dist2 < 1200) {
                    double dotProduct = normalX * vehicleMetrics[0][7] 
                        + normalZ * vehicleMetrics[0][8];
                    if (dotProduct < 0) {
                      double ratio = 2.0 * dotProduct / dist2;                  
                      vehicleMetrics[j][7] = vehicleMetrics[j][2] 
                          = vehicleMetrics[0][7] - normalX * ratio;
                      vehicleMetrics[j][8] = vehicleMetrics[j][3] 
                          = vehicleMetrics[0][8] - normalZ * ratio;

                      vehicleMetrics[i][2] = -vehicleMetrics[j][2];
                      vehicleMetrics[i][3] = -vehicleMetrics[j][3];
                      if (i == 0) {
                        power -= 10;
                        if (power < 0) {
                          power = 0;
                        }
                      }
                      break;
                    }                  
                  }
                }
              }

              // vehicle hitting a wall?
              int vehicleX = ((int)vehicleMetrics[j][0]) >> 5;
              int vehicleZ = ((int)vehicleMetrics[j][1]) >> 5;
              for(int z = -2; z <= 2; z++) {
                for(int x = -2; x <= 2; x++) {
                  if (Math.abs(raceTrack
                      [0x1FF & (z + vehicleZ)][0x1FF & (x + vehicleX)]) == 1) {
                    double normalX = vehicleMetrics[j][0] 
                        - (((x + vehicleX) << 5) + 16);
                    double normalZ = vehicleMetrics[j][1] 
                        - (((z + vehicleZ) << 5) + 16);  
                    double dist2 = normalX * normalX + normalZ * normalZ;
                    if (dist2 < 2304) {
                      double dotProduct = normalX * vehicleMetrics[j][7] 
                          + normalZ * vehicleMetrics[j][8];
                      if (dotProduct < 0) {
                        double ratio = 2.0 * dotProduct / dist2;                  
                        vehicleMetrics[j][7] = vehicleMetrics[j][2] 
                            = vehicleMetrics[0][7] - normalX * ratio;
                        vehicleMetrics[j][8] = vehicleMetrics[j][3] 
                            = vehicleMetrics[0][8] - normalZ * ratio;
                        vehicleMetrics[j][6] /= 2;
                        if (j == 0) {
                          hitWallCount = 5;
                        }
                        break;
                      }                    
                    }
                  }
                }
              }

              double velocityMag = vehicleMetrics[j][7] * vehicleMetrics[j][7] 
                  + vehicleMetrics[j][8] * vehicleMetrics[j][8];
              double velocityMaxMag = j == 0 ? 400 : 420;          
              if (velocityMag > velocityMaxMag) {
                velocityMaxMag = Math.sqrt(velocityMaxMag);
                velocityMag = Math.sqrt(velocityMag);
                vehicleMetrics[j][7] 
                    = velocityMaxMag * vehicleMetrics[j][7] / velocityMag;
                vehicleMetrics[j][8] 
                    = velocityMaxMag * vehicleMetrics[j][8] / velocityMag;
              }

              vehicleMetrics[j][0] += vehicleMetrics[j][7];
              vehicleMetrics[j][1] += vehicleMetrics[j][8];
              vehicleMetrics[j][2] *= 0.98;
              vehicleMetrics[j][3] *= 0.98;  
            }
          }
        } else {
          paused = 175;
        }
        
// -- UPDATE MODEL END ---------------------------------------------------------
        nextFrameStart += 28571429;
      } while(nextFrameStart < System.nanoTime());
// -- RENDER FRAME BEGIN -------------------------------------------------------

      // Draw sky
      double skyRed = 0x65;
      double skyGreen = 0x91;
      for(int y = 0, k = 0; y < 48; y++) {
        int skyColor = 0xFF000000
            | (((int)skyRed) << 16) | (((int)skyGreen) << 8) | 0xF2;
        for(int x = 0; x < 320; x++, k++) {
          screenBuffer[k] = skyColor;
        }
        skyRed += 1.75;
        skyGreen += 1.625;
      }

      // Draw earth
      for(int y = 0, k = 15360; y < 192; y++) {
        for(int x = 0; x < 320; x++, k++) {
          double X = projectionMap[y][x][0] - VIEWER_X;
          double Z = projectionMap[y][x][1];
          int xr = (int)(X * cos - Z * sin + vehicleMetrics[0][0]);
          int zr = (int)(X * sin + Z * cos + vehicleMetrics[0][1]);
          
          int z = 0x1FF & (zr >> 5);
          int tileIndex = raceTrack[z][0x1FF & (xr >> 5)];
          if (hitWallCount > 0 && tileIndex == 1) {
            tileIndex = 3;
          }
          if (tileIndex == 0 && z < 128 && (z & 1) == 0) {
            tileIndex = (z == 2) ? 5 : 4;
          }
          if (tileIndex < 0) {
            //screenBuffer[k] = 0;
            screenBuffer[k] 
                = wiresBitmap[wiresBitmapIndex][0xFF & zr][0xFF & xr];
          } else {
            screenBuffer[k] = bitmaps[tileIndex][0x1F & zr][0x1F & xr];
          }
        }
      }

      image.setRGB(0, 0, 320, 240, screenBuffer, 0, 320);

      // Draw vehicles
      for(int i = 0; i < 10; i++) {
        double X = vehicleMetrics[i][0] - vehicleMetrics[0][0];
        double Z = vehicleMetrics[i][1] - vehicleMetrics[0][1];     
        vehicleMetrics[i][4] = X * cos + Z * sin;
        vehicleMetrics[i][5] = (int)(Z * cos - X * sin);
      }
      for(int z = 1200; z > -127; z--) {
        for(int i = 0; i < 10; i++) {
          if (z == vehicleMetrics[i][5]) {
            double k = VIEWER_Z / (VIEWER_Z - z);
            double upperLeftX 
                = k * (vehicleMetrics[i][4] - 32) + VIEWER_X;
            double upperLeftY
                = k * (GROUND_Y - 32 - VIEWER_Y) + VIEWER_Y;
            double lowerRightX 
                = k * (vehicleMetrics[i][4] + 32) + VIEWER_X;
            double lowerRightY
                = k * (GROUND_Y - VIEWER_Y) + VIEWER_Y;            
            imageGraphics.drawImage(vehicleSprites[i], 
                (int)upperLeftX, (int)upperLeftY, 
                (int)(lowerRightX - upperLeftX), 
                (int)(lowerRightY - upperLeftY), null);
          }
        }
      }
      
      // Draw power bar
      imageGraphics.setColor(power < 20 && (wiresBitmapIndex & 8) == 0 
            ? Color.WHITE : powerColor);
      imageGraphics.fillRect(224, 20, (int)power, 10);
      imageGraphics.setColor(Color.WHITE);
      imageGraphics.drawRect(224, 20, 80, 10);
      
      // Draw recharge ovals
      if (onPowerBar) {
        imageGraphics.setColor(Color.GREEN);
        for(int i = 0; i < 2; i++) {
          imageGraphics.fillOval(96, powerOvalY[i], 128, 32);
        }
      }
            
      
      if (power <= 0 || (vehicleMetrics[0][1] >= 81984 && rank > 3)) {
        // Draw fail message  
        String failString = "FAIL";
        imageGraphics.setFont(largeFont);
        int width = imageGraphics.getFontMetrics().stringWidth(failString);
        int x = (320 - width) / 2;
        imageGraphics.setColor(darkColor);
        imageGraphics.fillRect(x, 65, width + 5, 90);
        imageGraphics.setColor(Color.RED);
        imageGraphics.drawString(failString, x, 145);
      } else if (vehicleMetrics[0][1] >= 81984) {
        // Display winning rank 
        String rankString = Integer.toString(rank);
        imageGraphics.setFont(largeFont);
        int width = imageGraphics.getFontMetrics().stringWidth(rankString);
        int x = (320 - width) / 2;
        imageGraphics.setColor(darkColor);
        imageGraphics.fillRect(x - 5, 65, width + 15, 90);
        imageGraphics.setColor((wiresBitmapIndex & 4) == 0 
            ? Color.WHITE : Color.GREEN);
        imageGraphics.drawString(rankString, x, 145);
      } else {
        // Display racing rank        
        imageGraphics.setColor((rank == 4) ? (wiresBitmapIndex & 8) == 0 
            ? Color.WHITE : Color.RED : Color.GREEN);
        imageGraphics.drawString(Integer.toString(rank), 16, 32);        
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
    return (D(angle, light, dark) << 16)
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

