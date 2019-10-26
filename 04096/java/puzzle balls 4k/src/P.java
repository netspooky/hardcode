import java.awt.*;
import java.awt.event.*;
import javax.sound.midi.MidiChannel;
import javax.sound.midi.MidiSystem;
import javax.sound.midi.MidiUnavailableException;
import javax.sound.midi.Synthesizer;
/*
 * Created on 24/01/2005
 *
 */
/**
 * @author Rafael Carvallo
 *
 */
public class P extends Frame implements Runnable, KeyListener {
  final private static int INPUT_LEFT = 1;
  final private static int INPUT_RIGHT = 2;
  final private static int INPUT_DOWN = 4;
  final private static int INPUT_ROTATE = 8;
  final private static int INPUT_START = 16;
  final private static int WIDTH = 580;
  final private static int HEIGHT = 520;
  final private static int BR = 10;
  final private static int BR2 = 17;
  final private static int SX = 10;
  final private static int SY = 13;
  //game
  private boolean gameRunning;
  private int input[] = new int[2];
  private int bestScore;
  private int state[] = new int[2]; //0:not play, 1:play, 2:hit, 3:lookballs, 4:kill balls, 5: game over.
  private long lastTime;
  //Player
  private boolean rotate[] = new boolean[2];
  private float rotateTime[] = new float[2];
  private float moveTime[] = new float[2];
  private float shiftTime[] = new float[2];
  private int[][][] current = new int[2][3][3];
  private int[][] next = new int[3][3];
  private int score[] = new int[2];
  private int level[] = new int[2];
  private int ballCount[] = new int[2];
  private int links[] = new int[2];
  private int numPlayers;
  //Balls
  private Color[] cols =
    {
      new Color(0, 0, 0),
      new Color(200, 0, 200),
      new Color(200, 0, 0),
      new Color(200, 200, 0),
      new Color(0, 200, 0),
      new Color(0, 200, 200),
      new Color(0, 0, 200),
      new Color(150, 150, 150)};
  private Color[] cols2 =
    {
      new Color(255, 255, 255),
      new Color(200, 100, 200),
      new Color(200, 100, 100),
      new Color(200, 200, 100),
      new Color(100, 200, 100),
      new Color(100, 200, 200),
      new Color(100, 100, 200),
      new Color(200, 200, 200)};
  private int[][][] balls = new int[2][SX + SX - 1][SY + SY];
  private int[][][] ballsOK = new int[2][SX + SX - 1][SY + SY];
  private float ballTime;
  //buffer
  Image bimg;
  Graphics buff;
  //Sound!
  private MidiChannel click;
  private MidiChannel turing;
  public P() {
    addKeyListener(this);
    Synthesizer synthesizer = null;
    try {
      synthesizer = MidiSystem.getSynthesizer();
      synthesizer.open();
      click = synthesizer.getChannels()[9];
      //click.programChange(113);
      turing = synthesizer.getChannels()[0];
    }
    catch (MidiUnavailableException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
      click = turing = null;
    }
  }
  public void addNotify() {
    super.addNotify();
    bimg = createImage(WIDTH, HEIGHT);
    buff = bimg.getGraphics();
    Graphics2D g2 = (Graphics2D)buff;
    g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
    g2.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
    //beginLoop();
     (new Thread(this)).start();
  }
  /*
  public void beginLoop() {
    (new Thread(this)).start();
  }
  */
  public void run() {
    while (true) {
      //System.out.println("RUN");
      long thisTime = System.currentTimeMillis();
      float dt = (thisTime - lastTime) / 1000f;
      lastTime = thisTime;
      doGame(dt);
      doRender();
      doPaint();
      /*
      try {
        Thread.sleep(50);
      }
      catch (InterruptedException e) {
        e.printStackTrace();
      }
      */
    }
  }
  /**
   * Dibuja el buffer en la pantalla
   */
  private void doPaint() {
    Graphics g = getGraphics();
    g.drawImage(bimg, 0, 0, this);
  }
  /**
   * Dibuja el juego al buffer
   */
  private void doRender() {
    buff.setColor(cols2[0]);
    buff.fillRect(0, 0, WIDTH, HEIGHT);
    //EL tablero
    buff.setColor(cols[0]);
    //player1
    int vy = 50;
    buff.fillRect(10, vy, 5, (SY - 1) * (2 * BR2) + (2 * BR + BR2));
    buff.fillRect(15 + SX * (2 * BR), vy, 5, (SY - 1) * (2 * BR2) + (2 * BR + BR2));
    buff.fillRect(10, vy + (SY - 1) * (2 * BR2) + (2 * BR + BR2), SX * (2 * BR) + 10, 5);
    //player 2
    buff.fillRect(350, vy, 5, (SY - 1) * (2 * BR2) + (2 * BR + BR2));
    buff.fillRect(355 + SX * (2 * BR), vy, 5, (SY - 1) * (2 * BR2) + (2 * BR + BR2));
    buff.fillRect(350, vy + (SY - 1) * (2 * BR2) + (2 * BR + BR2), SX * (2 * BR) + 10, 5);
    if (gameRunning) {
      for (int pyr = 0; pyr < numPlayers; pyr++) {
        //balls
        for (int i = 0; i < balls[pyr].length; i++) {
          for (int j = 0; j < balls[pyr][0].length; j++) {
            if (ballsOK[pyr][i][j] > 0) {
              buff.setColor(cols[ballsOK[pyr][i][j]]);
              buff.fillOval(BR * i + 340 * pyr + 15, BR2 * j + vy, 2 * BR, 2 * BR);
              buff.setColor(cols2[ballsOK[pyr][i][j]]);
              buff.fillOval(BR * i + 340 * pyr + 15 + 5, BR2 * j + vy + 1, 2 * BR - 7, 2 * BR - 7);
              buff.setColor(cols2[0]);
              buff.fillOval(BR * i + 340 * pyr + 15 + 10, BR2 * j + vy + 3, 2 * BR - 14, 2 * BR - 14);
            }
            else if (balls[pyr][i][j] > 0) {
              buff.setColor(cols[balls[pyr][i][j]]);
              buff.fillOval(BR * i + 340 * pyr + 15, BR2 * j + vy, 2 * BR, 2 * BR);
              buff.setColor(cols2[balls[pyr][i][j]]);
              buff.fillOval(BR * i + 340 * pyr + 15 + 5, BR2 * j + vy + 1, 2 * BR - 7, 2 * BR - 7);
              buff.setColor(cols2[0]);
              buff.fillOval(BR * i + 340 * pyr + 15 + 10, BR2 * j + vy + 3, 2 * BR - 14, 2 * BR - 14);
            }
          }
        }
        //current set
        if (state[pyr] == 1) {
          if (!rotate[pyr]) {
            for (int i = 0; i < 3; i++) {
              int[] bl = current[pyr][i];
              buff.setColor(cols[bl[2]]);
              buff.fillOval(BR * bl[0] + 340 * pyr + 15, BR2 * bl[1] + vy, 2 * BR, 2 * BR);
              buff.setColor(cols2[bl[2]]);
              buff.fillOval(BR * bl[0] + 340 * pyr + 15 + 5, BR2 * bl[1] + vy + 1, 2 * BR - 7, 2 * BR - 7);
              buff.setColor(cols2[0]);
              buff.fillOval(BR * bl[0] + 340 * pyr + 15 + 10, BR2 * bl[1] + vy + 3, 2 * BR - 14, 2 * BR - 14);
            }
          }
          else {
            buff.setColor(cols[current[pyr][0][2]]);
            buff.fillOval(BR * current[pyr][1][0] + 340 * pyr + 15, BR2 * current[pyr][0][1] + vy, 2 * BR, 2 * BR);
            buff.setColor(cols2[current[pyr][0][2]]);
            buff.fillOval(BR * current[pyr][1][0] + 340 * pyr + 15 + 5, BR2 * current[pyr][0][1] + vy + 1, 2 * BR - 7, 2 * BR - 7);
            buff.setColor(cols2[0]);
            buff.fillOval(BR * current[pyr][1][0] + 340 * pyr + 15 + 10, BR2 * current[pyr][0][1] + vy + 3, 2 * BR - 14, 2 * BR - 14);
            //            
            buff.setColor(cols[current[pyr][1][2]]);
            buff.fillOval(BR * current[pyr][0][0] + 340 * pyr + 15, BR2 * current[pyr][1][1] + vy, 2 * BR, 2 * BR);
            buff.setColor(cols2[current[pyr][1][2]]);
            buff.fillOval(BR * current[pyr][0][0] + 340 * pyr + 15 + 5, BR2 * current[pyr][1][1] + vy + 1, 2 * BR - 7, 2 * BR - 7);
            buff.setColor(cols2[0]);
            buff.fillOval(BR * current[pyr][0][0] + 340 * pyr + 15 + 10, BR2 * current[pyr][1][1] + vy + 3, 2 * BR - 14, 2 * BR - 14);
            //
            buff.setColor(cols[current[pyr][2][2]]);
            buff.fillOval(BR * current[pyr][2][0] + 340 * pyr + 15, BR2 * current[pyr][0][1] + vy, 2 * BR, 2 * BR);
            buff.setColor(cols2[current[pyr][2][2]]);
            buff.fillOval(BR * current[pyr][2][0] + 340 * pyr + 15 + 5, BR2 * current[pyr][0][1] + vy + 1, 2 * BR - 7, 2 * BR - 7);
            buff.setColor(cols2[0]);
            buff.fillOval(BR * current[pyr][2][0] + 340 * pyr + 15 + 10, BR2 * current[pyr][0][1] + vy + 3, 2 * BR - 14, 2 * BR - 14);
          }
        }
      }
      //next set
      for (int i = 0; i < 3; i++) {
        int[] bl = next[i];
        buff.setColor(cols[bl[2]]);
        buff.fillOval(BR * (bl[0] + 17) + 15, BR2 * (bl[1] + 8) + vy, 2 * BR, 2 * BR);
        buff.setColor(cols2[bl[2]]);
        buff.fillOval(BR * (bl[0] + 17) + 15 + 5, BR2 * (bl[1] + 8) + vy + 1, 2 * BR - 7, 2 * BR - 7);
        buff.setColor(cols2[0]);
        buff.fillOval(BR * (bl[0] + 17) + 15 + 10, BR2 * (bl[1] + 8) + vy + 3, 2 * BR - 14, 2 * BR - 14);
      }
      buff.setColor(cols[0]);
      //Score
      buff.drawString("Best Score: " + bestScore, 240, vy + 10);
      buff.drawString("Player 1 ", 240, vy + 30);
      buff.drawString("Score: " + score[0], 240, vy + 42);
      buff.drawString("Level: " + level[0], 240, vy + 54);
      if (links[0] > 0)
        buff.drawString("Bonus x" + links[0], 240, vy + 66);
      if (numPlayers == 2) {
        buff.drawString("Player 2 ", 240, vy + 86);
        buff.drawString("Score: " + score[1], 240, vy + 98);
        buff.drawString("Level: " + level[1], 240, vy + 110);
        if (links[1] > 0)
          buff.drawString("Bonus x" + links[1], 240, vy + 122);
      }
    }
    else {
      buff.setColor(cols[0]);
      buff.drawString("Best Score: " + bestScore, 240, vy + 10);
      buff.drawString("1 OR 2 TO START", 240, vy + 170);
    }
  }
  /**
   * Realiza los cambios al juego
   */
  private void doGame(float deltaT) {
    if (gameRunning) {
      for (int pyr = 0; pyr < numPlayers; pyr++) {
        if (state[pyr] == 1) {
          //current piece movement
          if (ballCount[pyr] >= 50) {
            level[pyr]++;
            ballCount[pyr] -= 50;
          }
          shiftTime[pyr] += deltaT;
          if ((input[pyr] & INPUT_LEFT) != 0) {
            //Ver si se puede mover a la izquierda.. por pantalla o por piezas
            if (shiftTime[pyr] > 0.04) {
              if (current[pyr][1][0] > 0) {
                if (current[pyr][1][0] > 1 && balls[pyr][current[pyr][1][0] - 2][current[pyr][1][1]] != 0) {
                }
                else {
                  current[pyr][0][0]--;
                  current[pyr][2][0]--;
                  current[pyr][1][0]--;
                  shiftTime[pyr] = 0;
                }
              }
            }
          }
          if ((input[pyr] & INPUT_RIGHT) != 0) {
            //Ver si se puede mover a la izquierda.. por pantalla o por piezas
            if (shiftTime[pyr] > 0.04) {
              if (current[pyr][2][0] < SX + SX - 2) {
                if (current[pyr][2][0] < SX + SX - 4 && balls[pyr][current[pyr][2][0] + 2][current[pyr][2][1]] != 0) {
                }
                else {
                  current[pyr][0][0]++;
                  current[pyr][2][0]++;
                  current[pyr][1][0]++;
                  shiftTime[pyr] = 0;
                }
              }
            }
          }
          //rotation
          if ((input[pyr] & INPUT_ROTATE) != 0) {
            if (!rotate[pyr] && rotateTime[pyr] > 0.08) {
              rotate[pyr] = true;
              rotateTime[pyr] = 0;
              input[pyr] &= ~INPUT_ROTATE;
            }
          }
          rotateTime[pyr] += deltaT;
          if (rotate[pyr] && rotateTime[pyr] > 0.08) {
            //change the pieces
            int tmp = current[pyr][0][2];
            current[pyr][0][2] = current[pyr][2][2];
            current[pyr][2][2] = current[pyr][1][2];
            current[pyr][1][2] = tmp;
            rotate[pyr] = false;
            rotateTime[pyr] = 0;
          }
          //if can go down do it
          moveTime[pyr] += (1 + level[pyr] * 0.3) * deltaT;
          if (((input[pyr] & INPUT_DOWN) != 0 && shiftTime[pyr] > 0.04) || (moveTime[pyr] > 0.3 && !rotate[pyr])) {
            boolean hit = false;
            int dx = 0;
            if (current[pyr][1][1] < SY + SY - 1) {
              int xi = current[pyr][0][0] - 2;
              if (xi < 0)
                xi = 0;
              int xf = current[pyr][0][0] + 2;
              if (xf > 18)
                xf = 18;
              for (int i = xi; i <= xf; i++) {
                if (balls[pyr][i][current[pyr][1][1] + 1] != 0) {
                  hit = true;
                  dx = i - current[pyr][0][0];
                  break;
                }
              }
            }
            else {
              hit = true;
              dx = current[pyr][1][0];
            }
            if (!hit) {
              current[pyr][0][1]++;
              current[pyr][2][1]++;
              current[pyr][1][1]++;
              moveTime[pyr] = 0;
              shiftTime[pyr] = 0;
            }
            else {
              //System.out.println(dx+" "+(dx%2));
              if (dx % 2 == 0) {
                balls[pyr][current[pyr][0][0]][current[pyr][0][1]] = current[pyr][0][2];
                balls[pyr][current[pyr][1][0]][current[pyr][1][1]] = current[pyr][1][2];
                balls[pyr][current[pyr][2][0]][current[pyr][2][1]] = current[pyr][2][2];
              }
              else {
                if (current[pyr][1][0] > 0) {
                  balls[pyr][current[pyr][0][0] - 1][current[pyr][0][1]] = current[pyr][0][2];
                  balls[pyr][current[pyr][1][0] - 1][current[pyr][1][1]] = current[pyr][1][2];
                  balls[pyr][current[pyr][2][0] - 1][current[pyr][2][1]] = current[pyr][2][2];
                }
                else {
                  balls[pyr][current[pyr][0][0] + 1][current[pyr][0][1]] = current[pyr][0][2];
                  balls[pyr][current[pyr][1][0] + 1][current[pyr][1][1]] = current[pyr][1][2];
                  balls[pyr][current[pyr][2][0] + 1][current[pyr][2][1]] = current[pyr][2][2];
                }
              }
              state[pyr] = 2;
            }
          }
        }
        else if (state[pyr] == 2) {
          //click sound
          click.noteOn(33, 100);
          //here the pieces are ordered, falling if necesary;
          boolean fall = false;
          for (int j = balls[pyr][0].length - 1; j > 0; j--) {
            for (int i = 0; i < balls[pyr].length; i++) {
              if (balls[pyr][i][j] == 0) {
                //caso inferior revisado
                if (i > 0 && balls[pyr][i - 1][j - 1] != 0) {
                  balls[pyr][i][j] = balls[pyr][i - 1][j - 1];
                  balls[pyr][i - 1][j - 1] = 0;
                  fall = true;
                  continue;
                }
                //caso superior revisado
                if (i < SX + SX - 2 && balls[pyr][i + 1][j - 1] != 0) {
                  balls[pyr][i][j] = balls[pyr][i + 1][j - 1];
                  balls[pyr][i + 1][j - 1] = 0;
                  fall = true;
                  continue;
                }
                if (j > 1 && balls[pyr][i][j - 2] != 0) {
                  balls[pyr][i][j] = balls[pyr][i][j - 2];
                  balls[pyr][i][j - 2] = 0;
                  fall = true;
                  continue;
                }
              }
            }
          }
          //System.out.println("HIT " + fall);
          if (!fall) {
            state[pyr] = 3;
          }
          click.noteOff(33);
        }
        else if (state[pyr] == 3) {
          boolean bonus = false;
          //revisar si hay bonus!
          int len = 0;
          int pos = 0;
          int chain = 0;
          int numBalls = 0;
          int[][] group = new int[50][2];
          for (int i = 0; i < balls[pyr].length; i++) {
            for (int j = 0; j < balls[pyr][0].length; j++) {
              if (balls[pyr][i][j] != 0 && ballsOK[pyr][i][j] == 0) {
                group[len][0] = i;
                group[len][1] = j;
                len++;
                while (pos < len) {
                  if (group[pos][0] > 0) {
                    if (group[pos][1] > 0 && balls[pyr][group[pos][0]][group[pos][1]] == balls[pyr][group[pos][0] - 1][group[pos][1] - 1]) {
                      boolean isIn = false;
                      for (int k = 0; k < len; k++) {
                        if (group[k][0] == group[pos][0] - 1 && group[k][1] == group[pos][1] - 1) {
                          isIn = true;
                          break;
                        }
                      }
                      if (!isIn) {
                        group[len][0] = group[pos][0] - 1;
                        group[len][1] = group[pos][1] - 1;
                        len++;
                      }
                    }
                    if (group[pos][1] < SY + SY - 1 && balls[pyr][group[pos][0]][group[pos][1]] == balls[pyr][group[pos][0] - 1][group[pos][1] + 1]) {
                      boolean isIn = false;
                      for (int k = 0; k < len; k++) {
                        if (group[k][0] == group[pos][0] - 1 && group[k][1] == group[pos][1] + 1) {
                          isIn = true;
                          break;
                        }
                      }
                      if (!isIn) {
                        group[len][0] = group[pos][0] - 1;
                        group[len][1] = group[pos][1] + 1;
                        len++;
                      }
                    }
                  }
                  if (group[pos][0] > 1 && balls[pyr][group[pos][0]][group[pos][1]] == balls[pyr][group[pos][0] - 2][group[pos][1]]) {
                    boolean isIn = false;
                    for (int k = 0; k < len; k++) {
                      if (group[k][0] == group[pos][0] - 2 && group[k][1] == group[pos][1]) {
                        isIn = true;
                        break;
                      }
                    }
                    if (!isIn) {
                      group[len][0] = group[pos][0] - 2;
                      group[len][1] = group[pos][1];
                      len++;
                    }
                  }
                  if (group[pos][0] < SX + SX - 2) {
                    if (group[pos][1] > 0 && balls[pyr][group[pos][0]][group[pos][1]] == balls[pyr][group[pos][0] + 1][group[pos][1] - 1]) {
                      boolean isIn = false;
                      for (int k = 0; k < len; k++) {
                        if (group[k][0] == group[pos][0] + 1 && group[k][1] == group[pos][1] - 1) {
                          isIn = true;
                          break;
                        }
                      }
                      if (!isIn) {
                        group[len][0] = group[pos][0] + 1;
                        group[len][1] = group[pos][1] - 1;
                        len++;
                      }
                    }
                    if (group[pos][1] < SY + SY - 1 && balls[pyr][group[pos][0]][group[pos][1]] == balls[pyr][group[pos][0] + 1][group[pos][1] + 1]) {
                      boolean isIn = false;
                      for (int k = 0; k < len; k++) {
                        if (group[k][0] == group[pos][0] + 1 && group[k][1] == group[pos][1] + 1) {
                          isIn = true;
                          break;
                        }
                      }
                      if (!isIn) {
                        group[len][0] = group[pos][0] + 1;
                        group[len][1] = group[pos][1] + 1;
                        len++;
                      }
                    }
                  }
                  if (group[pos][0] < SX + SX - 3 && balls[pyr][group[pos][0]][group[pos][1]] == balls[pyr][group[pos][0] + 2][group[pos][1]]) {
                    boolean isIn = false;
                    for (int k = 0; k < len; k++) {
                      if (group[k][0] == group[pos][0] + 2 && group[k][1] == group[pos][1]) {
                        isIn = true;
                        break;
                      }
                    }
                    if (!isIn) {
                      group[len][0] = group[pos][0] + 2;
                      group[len][1] = group[pos][1];
                      len++;
                    }
                  }
                  pos++;
                }
                if (len >= 4) {
                  for (int k = 0; k < len; k++) {
                    ballsOK[pyr][group[k][0]][group[k][1]] = cols.length - 1;
                    numBalls++;
                  }
                  chain++;
                  bonus = true;
                }
                len = 0;
                pos = 0;
              }
            }
          }
          if (!bonus) {
            for (int i = 0; i < current[pyr].length; i++) {
              for (int j = 0; j < current[pyr][0].length; j++) {
                current[pyr][i][j] = next[i][j];
              }
            }
            if (balls[pyr][9][0] != 0 || balls[pyr][8][1] != 0 || balls[pyr][10][1] != 0) {
              state[pyr] = 5;
              ballTime = 0;
            }
            else {
              next[0][0] = 9;
              next[0][1] = 0;
              next[0][2] = (int) (1 + Math.random() * (cols.length - 2));
              next[1][0] = 8;
              next[1][1] = 1;
              next[1][2] = (int) (1 + Math.random() * (cols.length - 2));
              next[2][0] = 10;
              next[2][1] = 1;
              next[2][2] = (int) (1 + Math.random() * (cols.length - 2));
              state[pyr] = 1;
              links[pyr] = 0;
            }
          }
          else {
            links[pyr]++;
            score[pyr] += links[pyr] * ((100 + 50 * (chain - 1)) * numBalls);
            state[pyr] = 4;
            ballTime = 0;
            turing.noteOn(60+links[pyr], 100);
          }
        }
        else if (state[pyr] == 4) {
          ballTime += deltaT;
            if(ballTime > 0.5) {
            turing.noteOff(60+links[pyr]);
            for (int i = 0; i < balls[pyr].length; i++) {
              for (int j = 0; j < balls[pyr][0].length; j++) {
                if (ballsOK[pyr][i][j] != 0) {
                  balls[pyr][i][j] = 0;
                  ballsOK[pyr][i][j] = 0;
                  ballCount[pyr]++;
                }
              }
            }
            state[pyr] = 2;
          }
        }
        else if (state[pyr] == 5) {
          if (ballTime >= balls[pyr][0].length) {
            gameRunning = false;
            if (score[pyr] > bestScore)
              bestScore = score[pyr];
          }
          else {
            for (int i = 0; i < balls[pyr].length; i++) {
              if (balls[pyr][i][(int)ballTime] != 0) {
                ballsOK[pyr][i][(int)ballTime] = cols.length - 1;
              }
            }
            ballTime++;
          }
        }
      }
    }
    else {
      if ((input[0] & INPUT_START) != 0) {
        gameRunning = true;
        numPlayers = 1;
      }
      else if ((input[1] & INPUT_START) != 0) {
        gameRunning = true;
        numPlayers = 2;
      }
      if (gameRunning) {
        for (int pyr = 0; pyr < numPlayers; pyr++) {
          input[pyr] = 0;
          score[pyr] = 0;
          state[pyr] = 1;
          moveTime[pyr] = 0;
          level[pyr] = 1;
          ballCount[pyr] = 0;
          current[pyr][0][0] = 9;
          current[pyr][0][1] = 0;
          current[pyr][0][2] = (int) (1 + Math.random() * (cols.length - 2));
          current[pyr][1][0] = 8;
          current[pyr][1][1] = 1;
          current[pyr][1][2] = (int) (1 + Math.random() * (cols.length - 2));
          current[pyr][2][0] = 10;
          current[pyr][2][1] = 1;
          current[pyr][2][2] = (int) (1 + Math.random() * (cols.length - 2));
          for (int i = 0; i < balls[pyr].length; i++) {
            for (int j = 0; j < balls[pyr][0].length; j++) {
              balls[pyr][i][j] = 0;
              ballsOK[pyr][i][j] = 0;
            }
          }
        }
        //next
        next[0][0] = 9;
        next[0][1] = 0;
        next[0][2] = (int) (1 + Math.random() * (cols.length - 2));
        next[1][0] = 8;
        next[1][1] = 1;
        next[1][2] = (int) (1 + Math.random() * (cols.length - 2));
        next[2][0] = 10;
        next[2][1] = 1;
        next[2][2] = (int) (1 + Math.random() * (cols.length - 2));
      }
    }
  }
  public void update(Graphics g) {
    paint(g);
  }
  public void paint(Graphics g) {
    g.drawImage(bimg, 0, 0, this);
  }
  public void keyTyped(KeyEvent e) {
    // Nada que hacer aqui
  }
  public void keyPressed(KeyEvent e) {
    switch (e.getKeyCode()) {
      case KeyEvent.VK_ESCAPE :
        System.exit(0);
        break;
      case KeyEvent.VK_LEFT :
        input[0] |= INPUT_LEFT;
        break;
      case KeyEvent.VK_RIGHT :
        input[0] |= INPUT_RIGHT;
        break;
      case KeyEvent.VK_UP :
        input[0] |= INPUT_ROTATE;
        break;
      case KeyEvent.VK_DOWN :
        input[0] |= INPUT_DOWN;
        break;
      case KeyEvent.VK_1 :
        input[0] |= INPUT_START;
        break;
      case KeyEvent.VK_A :
        input[1] |= INPUT_LEFT;
        break;
      case KeyEvent.VK_D :
        input[1] |= INPUT_RIGHT;
        break;
      case KeyEvent.VK_W :
        input[1] |= INPUT_ROTATE;
        break;
      case KeyEvent.VK_S :
        input[1] |= INPUT_DOWN;
        break;
      case KeyEvent.VK_2 :
        input[1] |= INPUT_START;
        break;
      default :
        break;
    }
    e.consume();
  }
  public void keyReleased(KeyEvent e) {
    switch (e.getKeyCode()) {
      case KeyEvent.VK_ESCAPE :
        System.exit(0);
        break;
      case KeyEvent.VK_LEFT :
        input[0] &= ~INPUT_LEFT;
        break;
      case KeyEvent.VK_RIGHT :
        input[0] &= ~INPUT_RIGHT;
        break;
      case KeyEvent.VK_UP :
        input[0] &= ~INPUT_ROTATE;
        break;
      case KeyEvent.VK_DOWN :
        input[0] &= ~INPUT_DOWN;
        break;
      case KeyEvent.VK_1 :
        input[0] &= ~INPUT_START;
        break;
      case KeyEvent.VK_A :
        input[1] &= ~INPUT_LEFT;
        break;
      case KeyEvent.VK_D :
        input[1] &= ~INPUT_RIGHT;
        break;
      case KeyEvent.VK_W :
        input[1] &= ~INPUT_ROTATE;
        break;
      case KeyEvent.VK_S :
        input[1] &= ~INPUT_DOWN;
        break;
      case KeyEvent.VK_2 :
        input[1] &= ~INPUT_START;
        break;
      default :
        break;
    }
    e.consume();
  }
  public static void main(String[] args) {
    /*
    Frame f = new Frame();
    f.setVisible(true);
    Insets in = f.getInsets();
    f.setVisible(false);
    f.add(new P2());
    f.setSize(P2.WIDTH + in.left + in.right, P2.HEIGHT + in.bottom + in.top);
    f.setTitle("PUZZLE BALLS 4K");
    f.setVisible(true);
    */
    P p = new P();
    p.setSize(P.WIDTH, P.HEIGHT);
    p.setTitle("PUZZLE BALLS 4K");
    p.setVisible(true);
  }
}
