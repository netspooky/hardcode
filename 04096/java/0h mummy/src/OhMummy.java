/*
 * OhMummy 4k implementation
 * Copyright (c) 2007, Luis Javier López Arredondo (luisjavier.lopez@gmail.com)
 * All rights reserved.
 *  
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *        This product includes software developed by Luis Javier López Arredondo
 *        and contributors.
 * 4. Neither the name of copyright holders nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL COPYRIGHT HOLDERS OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.event.KeyEvent;
import java.awt.image.BufferedImage;
import java.io.ObjectInputStream;

import javax.swing.JFrame;
import javax.swing.JPanel;

@SuppressWarnings("serial")
public class OhMummy extends JPanel implements Runnable {

  private static final int RIGHT = 0;

  private static final int LEFT = 1;

  private static final int UP = 2;

  private static final int DOWN = 3;

  private static final boolean[] pressedKeys = new boolean[65536];

  // Board
  private static final int spritesSide = 16;

  private static final int boardUnit = spritesSide / 2;

  private static final int xBoard = 15;

  private static final int yBoard = 80;

  private static final int unitsColumns = 74;

  private static final int unitsRows = 44;

  private static final int widthBoard = unitsColumns * boardUnit / 2;

  private static final int heightBoard = unitsRows * boardUnit / 2;

  // Double buffering
  private static final BufferedImage background = new BufferedImage(630, 500, 3);

  private static final Graphics backgroundGraphics = background.getGraphics();
  static {
    backgroundGraphics
        .setFont(new Font("Courier", Font.BOLD, 2 * (spritesSide)));
  }

  private static final BufferedImage[][][] sprites = new BufferedImage[3][4][2];

  static {
    for (int i = 0; i < 24; ++i) {
      sprites[i % 3][(i % 12) / 3][i / 12] = new BufferedImage(spritesSide,
          spritesSide, 3);
    }
  }

  private static final int maxLifes = 7;

  private static int lifes = maxLifes;

  // Blocks
  private static final int blocksColumns = 5;

  private static final int blocksRows = 4;

  private static int[][] blocksState = new int[blocksRows][blocksColumns];

  private static int[] unitsState = new int[unitsColumns];

  // Objects to search
  // if <0 --> found
  // byte blocksToExit;
  private static int numBlocksFound = 0;

  // byte[] blocksFound; // x (0) (000) (000) --> (1 bit)found (1 bit)trash (3
  // bits)row (3 bits) column
  // private static byte[][] blocksFound = new byte[2][2];
  private static int blocksFound;

  // Score
  private static int score = 0;

  private static final int xScore = 4 * spritesSide;

  private static final int yScore = -spritesSide - 5;

  // Life
  private static final int xLifes = widthBoard - maxLifes * spritesSide;

  private static final int yLifes = yScore;

  // Mummies
  // mummy[0] represents the player 
  private static final int maxMummys = 31;

  private static int[] xMummy = new int[maxMummys + 1];

  private static int[] yMummy = new int[maxMummys + 1];

  private static int[] nextXMummy = new int[maxMummys + 1];

  private static int[] nextYMummy = new int[maxMummys + 1];

  private static int[] stepMummy = new int[maxMummys + 1];

  private static int[] directionMummy = new int[maxMummys + 1];

  private static int[] indexStepMummy = new int[maxMummys + 1];

  private static int aliveMummys = 0;

  // game control
  private static int playing;

  private static int stage;


  public OhMummy() throws Exception {

    JFrame f = new JFrame("Oh Mummy!");
    f.add(this);
    f.setBounds(0, 0, 630, 500);
    f.setResizable(false);
    f.setVisible(true);
    f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    this.requestFocus();

    draw();

    nextStage();

    new Thread(this).start();
  }


  private static void nextStage() {

    int i;

    ++stage;

    Graphics backgroundGraphics = OhMummy.backgroundGraphics;
    backgroundGraphics.setColor(Color.yellow);
    backgroundGraphics.fillRect(0, 0, 630, 500);

    backgroundGraphics.setColor(Color.black);
    backgroundGraphics.fillRect(xBoard, yBoard, 2 * (widthBoard),
        2 * (heightBoard));
    backgroundGraphics.fillRect(xBoard + 2
        * (spritesSide * 2 + 5 * boardUnit * 2), yBoard - 2 * (spritesSide),
        2 * (spritesSide), 2 * (spritesSide));

    // Lives
    backgroundGraphics.fillRect(xBoard + 2 * (xLifes), yBoard + 2 * (yLifes),
        2 * (lifes * spritesSide), 2 * (spritesSide));

    backgroundGraphics.setColor(Color.gray);

    for (i = 0; i < blocksRows * blocksColumns; ++i) {

      backgroundGraphics.fill3DRect(xBoard + 2 * (spritesSide)
          * ((i % blocksColumns) + 1) + 2 * (boardUnit) * (i % blocksColumns)
          * 5, yBoard + 2 * (spritesSide) * ((i / blocksColumns) + 1) + 2
          * (boardUnit) * (i / blocksColumns) * 3, 2 * (boardUnit) * 5,
          2 * (boardUnit) * 3, true);
    }

    backgroundGraphics.setColor(Color.orange);

    backgroundGraphics.drawString("SCORE", xBoard + 2
        * (xScore - 4 * spritesSide), yBoard + 2 * (yScore + spritesSide));
    backgroundGraphics.drawString("MEN", xBoard + 2
        * (xLifes - 2 * spritesSide), yBoard + 2 * (yLifes + spritesSide));

    backgroundGraphics.drawString(String.format("STAGE %d", stage), xBoard + 2
        * (xScore - 4 * spritesSide), yBoard + 2 * (yScore));

    // Lives
    for (i = 0; i < lifes; ++i) {
      backgroundGraphics.drawImage(sprites[0][RIGHT][i & 1], xBoard + 2
          * (xLifes + i * spritesSide), yBoard + 2 * (yLifes),
          2 * (spritesSide), 2 * (spritesSide), null);
    }

    blocksFound = aliveMummys = numBlocksFound = 0;
    blocksFound = ((byte) (Math.random() * blocksRows) << 24)
        | ((byte) (Math.random() * blocksColumns) << 16);

    do {
      i = ((byte) (Math.random() * blocksRows) << 24)
          | ((byte) (Math.random() * blocksColumns) << 16);
    } while ((blocksFound ^ i) == 0);
    blocksFound |= i >> 16;
    xMummy[0] = nextXMummy[0] = 28;
    yMummy[0] = nextYMummy[0] = -4;

    for (i = 0; i < blocksRows * blocksColumns; ++i) {
      blocksState[i / blocksColumns][i % blocksColumns] = 0;
    }

    for (i = 0; i < unitsState.length; ++i) {
      unitsState[i] = 0;
    }

    for (i = 1; i <= stage && i <= maxMummys; ++i) {

      aliveMummys |= 1 << i;
      xMummy[i] = nextXMummy[i] = (int) (Math.random() * (blocksColumns + 1)) * 14;
      yMummy[i] = nextYMummy[i] = (int) (Math.random() * (blocksRows + 1)) * 10;

      directionMummy[i] = RIGHT;
    }

  }


  private static void draw() throws Exception {

    // Decodes sprite codified file
    // Codification:
    //  1 bit to set transparency: 
    //    0 = transparent
    //    1 = colored
    //  if no transparent, 2 bits
    //    2 bits = color index in the palette (0-based)
    
    int i, row, column, c, colorNum;
    byte[] bytesRead = new byte[8 * 144 * 3]; // 16*144*3 / 2

    // The colors used to paint sprites, 0-based, 4 colors
    final int[] palette = new int[] { 0xFF000000, 0xFFFFFF00, 0xFF0000FF,
        0xFFFF9900 };

    // Sprite size is hard-coded: 144 x 16
    BufferedImage imagenCuadrado = new BufferedImage(144, 16, 3);

    // (new
    // ObjectInputStream(ClassLoader.getSystemResourceAsStream("o"))).read(bytesRead);
    (new ObjectInputStream(OhMummy.class.getResourceAsStream("sprites.cod")))
        .read(bytesRead);

    for (c = 0; c < 16 * 16; ++c) {
      column = c & 15;
      row = c >> 4;
      // 
      if (((bytesRead[c >> 3] >> (7 - c & 7)) & 1) != 0) {
        for (i = 0; i < 2; ++i) {
          sprites[2][RIGHT][i].setRGB(column, i * 15 + (-2 * i + 1) * row,
              0xFFFFAA11);
          sprites[2][LEFT][i].setRGB(15 - column, i * 15 + (-2 * i + 1) * row,
              0xFFFFAA11);
          sprites[2][DOWN][i].setRGB(i * 15 + (-2 * i + 1) * row, column,
              0xFFFFAA11);
          sprites[2][UP][i].setRGB(i * 15 + (-2 * i + 1) * row, 15 - column,
              0xFFFFAA11);
        }
      }
    }

    // MUMMY
    for (; c < 1280; ++c) {
      if ((bytesRead[c >> 3] & (1 << (7 - c & 7))) != 0) {
        imagenCuadrado
            .setRGB(16 + ((c - 256) & 63), (c - 256) >> 6, 0xFFFFFF00);
      }
    }

    // MAN
    // c = 1280;
    for (i = 0; i < 64 * 16; ++i) {
      if ((bytesRead[c / 8] & (1 << (7 - c % 8))) != 0) {

        colorNum = 0;

        // ++bitCounter;
        // row = (++bitCounter) / 8;
        // column = 7 - (bitCounter & 7);
        if ((bytesRead[(++c) / 8] & (1 << (7 - (c & 7)))) != 0) {
          colorNum |= 1 << 1;
        }

        // ++bitCounter;
        // row = ++bitCounter / 8;
        // column = 7 - (bitCounter % 8);
        if ((bytesRead[++c / 8] & (1 << (7 - (c & 7)))) != 0) {
          colorNum |= 1;
        }
        imagenCuadrado.setRGB(80 + (i & 63), i >> 6, palette[colorNum]);
      }

      ++c;
    }

    for (c = 0; c < 16 * 16 * 2; ++c) {
      i = c / 256;
      row = c % 16;
      column = (c / 16) % 16;

      // MAN
      sprites[0][RIGHT][i].setRGB(column, row, imagenCuadrado.getRGB(i
          * spritesSide + 80 + column, row));
      sprites[0][LEFT][i].setRGB(spritesSide - column - 1, row, imagenCuadrado
          .getRGB(i * spritesSide + 80 + column, row));

      sprites[0][UP][i].setRGB(i * spritesSide + (-2 * i + 1) * column - i,
          row, imagenCuadrado.getRGB(112 + column, row));
      sprites[0][DOWN][i].setRGB(i * spritesSide + (-2 * i + 1) * column - i,
          row, imagenCuadrado.getRGB(112 + spritesSide + column, row));

      // MUMMY
      sprites[1][RIGHT][i].setRGB(column, row, imagenCuadrado.getRGB(i
          * spritesSide + 16 + column, row));
      sprites[1][LEFT][i].setRGB(spritesSide - column - 1, row, imagenCuadrado
          .getRGB(i * spritesSide + 16 + column, row));
      //                    
      sprites[1][UP][i].setRGB(i * spritesSide + (-2 * i + 1) * column - i,
          row, imagenCuadrado.getRGB(48 + column, row));
      sprites[1][DOWN][i].setRGB(i * spritesSide + (-2 * i + 1) * column - i,
          row, imagenCuadrado.getRGB(48 + spritesSide + column, row));
    }

    for (c = 0; c < 16 * 16; ++c) {
      column = c & 15;
      row = c >> 4;
      if ((bytesRead[c >> 3] & (1 << (7 - c & 7))) != 0) {
        for (i = 0; i < 2; ++i) {
          sprites[2][RIGHT][i].setRGB(column, i * 15 + (-2 * i + 1) * row,
              0xFFFFAA11);
          sprites[2][LEFT][i].setRGB(15 - column, i * 15 + (-2 * i + 1) * row,
              0xFFFFAA11);
          sprites[2][DOWN][i].setRGB(i * 15 + (-2 * i + 1) * row, column,
              0xFFFFAA11);
          sprites[2][UP][i].setRGB(i * 15 + (-2 * i + 1) * row, 15 - column,
              0xFFFFAA11);
        }
      }
    }

  }


  public void run() {

    long t = 0;
    while (true) {
      try {

        t = System.nanoTime();
        if (playing != 0) {
          update();
          collisions();
        }
        repaint();

        Thread.sleep(8 - (System.nanoTime() - t) / 1000000);

      } catch (Exception e) {
      }

    }

  }


  /**
   * Moves and does collisions.
   * 
   */
  private static final void update() {

    if (++stepMummy[0] == Math.max(6 - (stage / 3), 3)) {

      stepMummy[0] = 0;

      // Player moving
      if (pressedKeys[KeyEvent.VK_LEFT]) {
        --nextXMummy[0];// = xMummy[0] - 1;
      }

      if (pressedKeys[KeyEvent.VK_RIGHT]) {
        ++nextXMummy[0];// = xMummy[0] + 1;
      }

      if (pressedKeys[KeyEvent.VK_UP]) {
        --nextYMummy[0];// = yMummy[0] - 1;
      }

      if (pressedKeys[KeyEvent.VK_DOWN]) {
        ++nextYMummy[0];// = yMummy[0] + 1;
      }

    }

    // Mummys
    for (int i = 1; i <= maxMummys; ++i)
      if ((aliveMummys & 1 << i) != 0
          && ++stepMummy[i] == Math.max(6 - (i / 3), 3)) {

        stepMummy[i] = 0;

        if (directionMummy[i] == RIGHT)
          ++nextXMummy[i];
        if (directionMummy[i] == LEFT)
          --nextXMummy[i];
        if (directionMummy[i] == UP)
          --nextYMummy[i];
        if (directionMummy[i] == DOWN)
          ++nextYMummy[i];

        ++indexStepMummy[i];
        indexStepMummy[i] %= 2;

      }
  }


  public void paint(Graphics g) {

    g.drawImage(background, 0, 0, null);

    g.drawImage(sprites[0][directionMummy[0]][indexStepMummy[0]], xBoard
        + (xMummy[0] * boardUnit), yBoard + yMummy[0] * boardUnit,
        2 * (spritesSide), 2 * (spritesSide), null);

    g.setFont(new Font("Courier", Font.BOLD, 2 * (spritesSide)));
    g.setColor(Color.blue);
    g.drawString(String.format("%05d", score * 10), xBoard + 2 * (xScore),
        yBoard + 2 * (yScore + spritesSide));

    for (int i = 0; i < maxMummys; ++i)
      if ((aliveMummys & 1 << i) != 0) {
        g.drawImage(sprites[1][directionMummy[i]][indexStepMummy[i]], xBoard
            + xMummy[i] * boardUnit, yBoard + yMummy[i] * boardUnit,
            2 * (spritesSide), 2 * (spritesSide), null);
      }

    if (playing == 0) {

      g.fill3DRect(xBoard + 2 * (3 * spritesSide), yBoard + 2
          * (6 * spritesSide - 5) - 24, 385, 32, true);
      g.setColor(Color.orange);
      g.drawString("[S]TART - [C]ONTINUE", xBoard + 2 * (3 * spritesSide),
          yBoard + 2 * (6 * spritesSide - 5));
    }

  }


  protected void processKeyEvent(KeyEvent e) {

    if (e.getID() == KeyEvent.KEY_PRESSED) {
      pressedKeys[e.getKeyCode()] = true;
    }

    if (e.getID() == KeyEvent.KEY_RELEASED) {
      pressedKeys[e.getKeyCode()] = false;
      if (playing == 0) {
        if (e.getKeyCode() == KeyEvent.VK_S) {
          score = stage = 0;
          lifes = maxLifes;
          nextStage();
          playing = 1;

        }
        if (e.getKeyCode() == KeyEvent.VK_C) {
          score = 0;
          lifes = maxLifes;
          --stage;
          nextStage();
          playing = 1;
        }
      }

    }
  }


  private static final void collisions() {

    // Collisions 
    int[] nextXMummy = OhMummy.nextXMummy;
    int[] nextYMummy = OhMummy.nextYMummy;
    int[] xMummy = OhMummy.xMummy;
    int[] yMummy = OhMummy.yMummy;

    if (xMummy[0] == 28) {
      if (nextYMummy[0] < 0) {
        nextXMummy[0] = xMummy[0];
        if (nextYMummy[0] < -4) {
          nextYMummy[0] = yMummy[0];
        }
      }
      if (nextYMummy[0] + 4 > unitsRows) {
        nextYMummy[0] = yMummy[0];
        if (nextYMummy[0] % 10 != 0) {
          nextXMummy[0] = xMummy[0];
        }
      }
    } else {
      if (nextXMummy[0] < 0 || nextXMummy[0] + 4 > unitsColumns) {
        nextXMummy[0] = xMummy[0];
      }
      if (nextYMummy[0] < 0 || nextYMummy[0] + 4 > unitsRows) {
        nextYMummy[0] = yMummy[0];
      }
    }

    if (nextXMummy[0] % 14 != 0 && nextYMummy[0] % 10 != 0) {
      if (yMummy[0] % 10 != 0) {
        nextXMummy[0] = xMummy[0];
      } else {
        nextYMummy[0] = yMummy[0];
      }

      if (xMummy[0] % 14 != 0) {
        nextYMummy[0] = yMummy[0];
      } else {
        nextXMummy[0] = xMummy[0];
      }
    }

    for (int i = 1; i < maxMummys + 1; ++i)
      if ((aliveMummys & 1 << i) != 0) {
        boolean decission = false;
        if (nextXMummy[i] < 0 || nextXMummy[i] + 4 > unitsColumns) {
          nextXMummy[i] = xMummy[i];
          decission = true;
        }
        if (nextYMummy[i] < 0 || nextYMummy[i] + 4 > unitsRows) {
          nextYMummy[i] = yMummy[i];
          decission = true;
        }

        // Intelligence of the mummies
        // Uses simple probabilistic heuristic to the player position
        // Higher the mummy index, higher the probability to change direction
        // Direction only changed in board crosses
        if (stepMummy[0] == 0
            && (decission || (nextXMummy[i] % 14 == 0
                && nextYMummy[i] % 10 == 0 && (Math.random() * 100) < 20 + 10 * i))) {

          byte[] percentage = new byte[] { 8, 8, 8, 8 };

          byte horizontalWin = RIGHT;
          byte verticalWin = UP;

          if (xMummy[0] - xMummy[i] > 0) {
            percentage[RIGHT] += 6;
            percentage[LEFT] -= 6;
          } else {
            horizontalWin = LEFT;
            percentage[RIGHT] -= 6;
            percentage[LEFT] += 6;
          }

          if (yMummy[0] - yMummy[i] > 0) {
            verticalWin = DOWN;
            percentage[DOWN] += 6;
            percentage[UP] -= 6;
          } else {
            percentage[DOWN] -= 6;
            percentage[UP] += 6;
          }

          if (Math.abs(xMummy[0] - xMummy[i]) < Math.abs(yMummy[0] - yMummy[i])) {
            percentage[horizontalWin] -= 6;
            percentage[verticalWin] += 6;
          } else {
            percentage[horizontalWin] += 6;
            percentage[verticalWin] -= 6;
          }

          long ldecission = 0;

          for (int j = 0; j < 4; ++j) {
            for (int k = 0; k < percentage[j]; ++k) {
              ldecission <<= 2;
              ldecission |= j;
            }
          }

          directionMummy[i] = (byte) ((ldecission >> ((int) (Math.random() * 31) * 2)) & 3);

        }
        xMummy[i] = nextXMummy[i];
        yMummy[i] = nextYMummy[i];

        // Collision player-mummy[i]
        if (Math.abs(xMummy[i] - xMummy[0]) < 4
            && Math.abs(yMummy[i] - yMummy[0]) < 4) {
          --lifes;
          aliveMummys ^= 1 << i;
          backgroundGraphics.setColor(Color.yellow);
          backgroundGraphics.fillRect(xBoard + 2
              * (xLifes + lifes * spritesSide), yBoard + 2 * (yLifes),
              2 * (spritesSide), 2 * (spritesSide));

          if (lifes == 0) {
            playing = 0;
          }
        }

      }

    if ((nextXMummy[0] & nextXMummy[0] & 1) == 0) {

      int column = nextXMummy[0] >> 1;
      int row = nextYMummy[0] >> 1;

      if ((unitsState[column] & 1 << row) == 0) {
        unitsState[column] |= 1 << row;

        if (row % 5 != 0 || column % 7 != 0) {
          for (int r = (row % 5 == 0) ? -1 : 0; r <= 0; ++r) {
            for (int c = (column % 7 == 0) ? -1 : 0; c <= 0; ++c) {
              int bR = row / 5 + r;
              int bC = column / 7 + c;
              if (bR >= 0 && bR < blocksRows && bC >= 0 && bC < blocksColumns) {

                if (blocksState[bR][bC] < 20) {
                  ++blocksState[bR][bC];

                  if (blocksState[bR][bC] == 20) {
                    ++score;

                    if ((blocksFound ^ (bR << 24 | bC << 16)) >> 16 == 0
                        || (blocksFound & ((1 << 16) - 1) ^ (bR << 8 | bC)) == 0) {
                      ++numBlocksFound;
                      ++score;
                      backgroundGraphics.setColor(Color.green);
                    } else {
                      backgroundGraphics.setColor(Color.red);
                    }
                    backgroundGraphics.fill3DRect(xBoard + boardUnit
                        * (bC * 14 + 4), yBoard + boardUnit * (bR * 10 + 4),
                        boardUnit * 10, boardUnit * 6, true);
                  }
                }
              }
            }
          }
        }
      }
    }

    if (nextXMummy[0] > xMummy[0]) {
      directionMummy[0] = RIGHT;
    }
    if (nextXMummy[0] < xMummy[0]) {
      directionMummy[0] = LEFT;
    }

    if (nextYMummy[0] > yMummy[0]) {
      directionMummy[0] = DOWN;
    }
    if (nextYMummy[0] < yMummy[0]) {
      directionMummy[0] = UP;
    }

    if ((nextXMummy[0] != xMummy[0] || nextYMummy[0] != yMummy[0])
        && ((nextXMummy[0] | nextYMummy[0]) & 1) == 0) {

      ++indexStepMummy[0];
      indexStepMummy[0] %= 2;

      backgroundGraphics.setColor(Color.black);
      backgroundGraphics.fillRect(xBoard + nextXMummy[0] * boardUnit, yBoard
          + nextYMummy[0] * boardUnit, 32, 32);
      backgroundGraphics.drawImage(
          sprites[2][directionMummy[0]][indexStepMummy[0]], xBoard
              + nextXMummy[0] * boardUnit, yBoard + nextYMummy[0] * boardUnit,
          32, 32, null);

    }

    xMummy[0] = nextXMummy[0];
    yMummy[0] = nextYMummy[0];

    if (yMummy[0] == -4 && numBlocksFound == 2) {
      score += 3;
      nextStage();
    }
  }


  public static void main(String[] args) throws Exception {

    new OhMummy();
  }
}
