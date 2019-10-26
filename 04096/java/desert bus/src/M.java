/*
 * Desert Bus
 * Copyright (C) 2009 Michael Birken
 *
 * This file is part of Desert Bus.
 *
 * Desert Bus is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Desert Bus is distributed in the hope that it will be useful,
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
 
  public M() {

    double VIEWER_DISTANCE = 320;
    double HORIZON_HEIGHT = 205;
    double GROUND_Y = 240;
    double VEHICLE_Z = 320;

    int[][][] projectionMap = new int[240][320][2];
    int[] screenBuffer = new int[320*240];
    int[][] roadBitmap = new int[512][960];
    int[][] sandBitmap = new int[256][256];

    double driverX = 240;
    double driverZ = 0;
    double driverAngle = 0;
    double driverVelocity = 0;
    double sin = 0;
    double cos = 0;
    Random random = new Random();
    int score = 0;
    double miles = 0;
    boolean neverMoved = true;
    Color darkColor = new Color(0xB0000000, true);
    //boolean inFullScreenMode = false;

// -- GENERATE ROAD BITMAP BEGIN -----------------------------------------------

    for(int y = 0; y < 512; y++) {
      double colorAngle = 0;
      for(int x = 0; x < 960; x++, colorAngle += 0.02618) {
        double colorScale = (Math.cos(colorAngle) + 1) / 2;
        roadBitmap[y][x] = 0xFF000000
            | (((int)(0x47 + colorScale * 0x36)) << 16)
            | (((int)(0x20 + colorScale * 0x4e)) << 8)
            | (int)(0x3f + colorScale * 0x42);
        if ((x > 20 && x < 40 || x > 920 && x < 940)
            || (x > 470 && x < 490 && y < 256)) {
          roadBitmap[y][x] = 0xFFFBFFFF;
        } else if (x == 20 || x == 40 || x == 920 || x == 940) {
          roadBitmap[y][x] = 0xFFA18F9F;
        }
      }
    }
    for(int i = 0; i < 45000; i++) {
      int x = random.nextInt(955);
      int y = random.nextInt(512);
      for(int j = 0; j < 32; j++) {
        for(int k = 0; k < 3; k++) {
          int pixelColor = roadBitmap[(y + j) & 0x1FF][x + k];
          int red = 0xFF & (pixelColor >> 16);
          int green = 0xFF & (pixelColor >> 8);
          int blue = 0xFF & pixelColor;
          red = (int)(red * 0.99);
          green = (int)(green * 0.99);
          blue = (int)(blue * 0.99);
          roadBitmap[(y + j) & 0x1FF][x + k] = 0xFF000000
              | (red << 16) | (green << 8) | blue;
        }
      }
    }

// -- GENERATE ROAD BITMAP END -------------------------------------------------

// -- GENERATE SAND BITMAP BEGIN -----------------------------------------------

    for(int y = 0; y < 256; y += 8) {
      for(int x = 0; x < 256; x += 8) {
        int sandColor = 0xFFE3B790;
        switch(random.nextInt(4)) {
          case 0:
            sandColor = 0xFFD9AC85;
            break;
          case 1:
            sandColor = 0xFFDDB18E;
            break;
          case 2:
            sandColor = 0xFFD9AB87;
            break;
        }
        for(int i = 0; i < 8; i++) {
          for(int j = 0; j < 8; j++) {
            sandBitmap[y + j][x + i] = sandColor;
          }
        }
      }
    }

// -- GENERATE SAND BITMAP END -------------------------------------------------

// -- COMPUTE PROJECTION MAP BEGIN ---------------------------------------------

    double aboveHorizonHeight = HORIZON_HEIGHT - 120;
    double viewerDistance2 = VIEWER_DISTANCE * VIEWER_DISTANCE;
    double parallelDistance = Math.sqrt(viewerDistance2
        + aboveHorizonHeight * aboveHorizonHeight);
    double centerScreenZ = viewerDistance2 / parallelDistance;
    double centerScreenY = Math.sqrt(viewerDistance2 
        - centerScreenZ * centerScreenZ);
    double tiltVectorZ = parallelDistance - centerScreenZ;
    double tiltVectorMagnitude = Math.sqrt(tiltVectorZ * tiltVectorZ
        + centerScreenY * centerScreenY);
    double unitTiltVectorZ = -tiltVectorZ / tiltVectorMagnitude;
    double unitTiltVectorY = centerScreenY / tiltVectorMagnitude;
    double screenZ = centerScreenZ - 120 * unitTiltVectorZ;
    double screenY = centerScreenY - 120 * unitTiltVectorY;

    for(int y = 0; y < 240; y++,
        screenZ += unitTiltVectorZ, screenY += unitTiltVectorY) {
      for(int x = 0; x < 320; x++) {
        double screenX = x - 160;
        double scale = GROUND_Y / screenY;
        projectionMap[y][x][0] = (int)(scale * screenX);
        projectionMap[y][x][1] = (int)(scale * screenZ);
      }
    }

// -- COMPUTE PROJECTION MAP END -----------------------------------------------
    
    setTitle("Desert Bus");
    JPanel panel = (JPanel)getContentPane();
    panel.setPreferredSize(new Dimension(640, 480));
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    pack();
    setLocationRelativeTo(null);
    show();
       
    BufferedImage image = new BufferedImage(
        320, 240, BufferedImage.TYPE_INT_RGB);    
    Graphics imageGraphics = image.getGraphics();
    
    long nextFrameStart = System.nanoTime();  
    while(true) {
      do {        
// -- UPDATE MODEL BEGIN -------------------------------------------------------

        /*if (K[KeyEvent.VK_Z] && !inFullScreenMode) {
          inFullScreenMode = true;

          dispose();
          setUndecorated(true);
          show();

          try {
            Thread.sleep(0xFF);
          } catch(Throwable t) {
          }

          GraphicsDevice graphicsDevice
              = GraphicsEnvironment.getLocalGraphicsEnvironment()
                  .getDefaultScreenDevice();
          DisplayMode[] modes = graphicsDevice.getDisplayModes();
          DisplayMode best = null;

          for(int i = 0; i < modes.length; i++) {
            if (modes[i].getWidth() == 640 && modes[i].getHeight() == 480
                && (best == null
                    || modes[i].getBitDepth() > best.getBitDepth()
                    || (modes[i].getBitDepth() == best.getBitDepth()
                        && modes[i].getRefreshRate() > best.getRefreshRate()))){
              best = modes[i];
            }
          }

          setLayout(null);
          setCursor(Toolkit.getDefaultToolkit().createCustomCursor(
              new BufferedImage(1, 1, BufferedImage.TYPE_4BYTE_ABGR),
              new Point(0, 0), "empty"));
          graphicsDevice.setFullScreenWindow(this);
          graphicsDevice.setDisplayMode(best);

          nextFrameStart = System.nanoTime();
        }*/

        if (K[KeyEvent.VK_ESCAPE]) {
          System.exit(0);
        }

        if (K[KeyEvent.VK_D] || K[KeyEvent.VK_ENTER]) {
          neverMoved = false;
          if (!K[KeyEvent.VK_LEFT] && !K[KeyEvent.VK_RIGHT]) {
            driverAngle -= 0.0001;
          }
          if (driverX < -480 || driverX > 480) {
            if (driverVelocity < 10) {
              driverVelocity += 0.5;
            } else {
              driverVelocity -= 1.0;
            }
          } else {
            driverVelocity += 1;
            if (driverVelocity > 60) {
              driverVelocity = 60;
            }
          }
        } else {
          driverVelocity -= 0.75;
        }       
        if (driverVelocity < 0) {
          driverVelocity = 0;
        }

        if (K[KeyEvent.VK_LEFT]) {
          driverAngle += 0.025;
        } else if (K[KeyEvent.VK_RIGHT]) {
          driverAngle -= 0.025;
        } 

        sin = Math.sin(driverAngle);
        cos = Math.cos(driverAngle);

        driverX -= driverVelocity * sin;
        driverZ += driverVelocity * cos;

        if (driverX >= -480 && driverX <= 480) {
          miles += driverVelocity / 168000;
          if (miles > 360) {
            miles = 0;
            score++;
          }
        }
      
// -- UPDATE MODEL END ---------------------------------------------------------        
        nextFrameStart += 28571429;
      } while(nextFrameStart < System.nanoTime());     
// -- RENDER FRAME BEGIN ------------------------------------------------------- 

      // Draw sky

      double skyRed = 0x52;
      double skyGreen = 0x88;
      double skyBlue = 0xC6;
      for(int y = 0, k = 0; y < 48; y++) {
        int skyColor = 0xFF000000
            | (((int)skyRed) << 16) | (((int)skyGreen) << 8) | (int)skyBlue;
        for(int x = 0; x < 320; x++, k++) {
          screenBuffer[k] = skyColor;
        }
        skyRed += 1.583;
        skyGreen += 0.875;
        skyBlue += 0.27083;
      }

      // Draw earth
      for(int y = 48, k = 15360; y < 240; y++) {
        for(int x = 0; x < 320; x++, k++) {
          screenBuffer[k] = 0xFFE8B07F;
          
          double groundX = projectionMap[y][x][0];
          double groundZ = projectionMap[y][x][1] - VEHICLE_Z;
          double groundXRotated = groundX * cos - groundZ * sin + driverX;
          double groundZRotated 
              = groundX * sin + groundZ * cos + VEHICLE_Z + driverZ;

          int intGroundXRotated = (int)groundXRotated;
          if (intGroundXRotated >= -480 && intGroundXRotated < 480) {
            screenBuffer[k] = roadBitmap
                [((int)(groundZRotated)) & 0x1FF][intGroundXRotated + 480];
          } else {
            screenBuffer[k] = sandBitmap
                [(int)(groundZRotated) & 0xFF][intGroundXRotated & 0xFF];
          }
        }
      }

      image.setRGB(0, 0, 320, 240, screenBuffer, 0, 320);
      
      if (neverMoved) {
        imageGraphics.setColor(darkColor);
        imageGraphics.fillRect(0, 0, 640, 480);
        imageGraphics.setColor(Color.YELLOW);
        imageGraphics.drawString("D E S E R T   B U S", 105, 32);
        imageGraphics.drawString("Experience the thrill of driving a bus from ", 52, 84);
        imageGraphics.drawString("Tucson, Arizona to Las Vegas, Nevada in real-time.", 23, 100);
        imageGraphics.drawString("D = Gas Pedal", 120, 134);
        imageGraphics.drawString("Arrow Keys = Steering Wheel", 80, 150);
        imageGraphics.drawString("Esc = Exit", 132, 166);
        //imageGraphics.drawString("Z = Full-Screen Mode", 102, 182);
        imageGraphics.drawString("Score increases every 360 miles.", 69, 214);
        imageGraphics.setColor(Color.WHITE);
      } else {
        imageGraphics.drawString("Score: 00000000" + score, 5, 16);
        imageGraphics.drawString("Miles: " + ((int)(miles * 10)) / 10.0, 5, 32);
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
     
  protected void processKeyEvent(KeyEvent e) {
    K[e.getKeyCode()] = e.getID() == 401;
  }

  public static void main(String[] args) {
    new M();
  }
}
