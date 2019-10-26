import java.awt.AWTEvent;
import java.awt.Color;
import java.awt.Font;
import java.awt.Frame;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.KeyEvent;

/*
 * Created on 29/11/2005
 */
/**
 * @author Rafael Carvallo
 */
public class Domino4K extends Frame implements Runnable{
  private int n1,n2; //La siguiente jugada.
  private int x, y, r; // La posicion de la pieza
  private int v1, v2; // Los valores de la pieza.
  private int level; // El nivel de dificultad.
  private int[][] tablero; // El tablero de Juego.
  private int[][] tableroR; // El tablero de Juego.
  private static int sx = 8;
  private static int sy = 15;
  private boolean playing; // Esta jugando
  private int score, bestScore; //El puntaje..
  private int chain; // Cuando se hacen combos
  private int piezas; //La cantidad de piezas muertas
  private int estado; // Estado actual del juego.
  Image bImg; // La imagen para el doble buffer
  Graphics buff; // El segundo Buffer
  private static int W = 600;
  private static int H = 600;
  private static int cs = 36; // Tamaño de bloque
  private static Color[] col = {new Color(240, 240, 180), new Color(180, 240, 240), new Color(240, 180, 240), new Color(180, 240, 180), new Color(180, 180, 240),
      new Color(240, 180, 180), new Color(180, 120, 180), new Color(180, 180, 130), new Color(120, 180, 180), new Color(220, 220, 220)};
  private static int[] keys = new int[256];
  public Domino4K(){
    super("Puzzling Dominoes 4K ");
    enableEvents(AWTEvent.KEY_EVENT_MASK);
    setSize(W, H);
    tablero = new int[sx][sy];
    tableroR = new int[sx][sy];
    // tablero[1][4] = 1;
    // tablero[2][7] = 2;
    // tablero[3][13] = 3;
    // tablero[4][2] = 4;
    // tablero[5][9] = 5;
    // tablero[7][12] = 6;
    setVisible(true);
    x = y = 0;
    r = 1;
    v1 = 2;
    v2 = 4;
    chain = 1;

  }
  public void addNotify(){
    super.addNotify();
    bImg = createImage(W, H);
    buff = bImg.getGraphics();
    (new Thread(this)).start(); // Se ejecuta el thread.
  }
  protected void processKeyEvent(KeyEvent e){
    if(e.getKeyCode() == KeyEvent.VK_ESCAPE)
      System.exit(0);
    keys[e.getKeyCode()] = (e.getID() & 1);
  }
  public void run(){
    long lastTime = System.currentTimeMillis();
    while(true){
      double dt = (System.currentTimeMillis() - lastTime) / 1000.0;
      lastTime = System.currentTimeMillis();
      doGame(dt);
      // if (reRender) {
      doRender();
      // reRender = false;
      // }
      doPaint();
    }
  }
  private void drawBlock(int i, int j, int v, int d){
    buff.setColor(col[v - 1]);
    if(d > 0){
      buff.fill3DRect(20 + i * cs, 30 + j * cs, cs, cs, true);
      // El del centro:
      if((v & 1) != 0){
        buff.setColor(new Color(100, 100, 100));
        buff.fillOval(20 + i * cs + cs / 2 - 3, 30 + j * cs + cs / 2 - 3, 6, 6);
        buff.setColor(new Color(255, 255, 255));
        buff.fillOval(20 + i * cs + cs / 2, 30 + j * cs + cs / 2, 3, 3);
      }
      // Ahora la diagonal dl->ur
      if(((v == 2 || v == 3) && (d == 1 || d == 3)) || (v > 3)){
        buff.setColor(new Color(100, 100, 100));
        buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + cs / 4 - 3, 6, 6);
        buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + 3 * cs / 4 - 3, 6, 6);
        buff.setColor(new Color(255, 255, 255));
        buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + cs / 4, 3, 3);
        buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + 3 * cs / 4, 3, 3);
      }
      // Ahora la diagonal dr->ul
      if(((v == 2 || v == 3) && (d == 2 || d == 4)) || (v > 3)){
        buff.setColor(new Color(100, 100, 100));
        buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + cs / 4 - 3, 6, 6);
        buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + 3 * cs / 4 - 3, 6, 6);
        buff.setColor(new Color(255, 255, 255));
        buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + cs / 4, 3, 3);
        buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + 3 * cs / 4, 3, 3);
      }
      // ahora la linea central hor
      if(((v == 6 || v == 7) && (d == 2 || d == 4)) || (v > 7)){
        buff.setColor(new Color(100, 100, 100));
        buff.fillOval(20 + i * cs + cs / 2 - 3, 30 + j * cs + cs / 4 - 3, 6, 6);
        buff.fillOval(20 + i * cs + cs / 2 - 3, 30 + j * cs + 3 * cs / 4 - 3, 6, 6);
        buff.setColor(new Color(255, 255, 255));
        buff.fillOval(20 + i * cs + cs / 2, 30 + j * cs + cs / 4, 3, 3);
        buff.fillOval(20 + i * cs + cs / 2, 30 + j * cs + 3 * cs / 4, 3, 3);
      }
      // ahora la linea central hor
      if(((v == 6 || v == 7) && (d == 1 || d == 3)) || (v > 7)){
        buff.setColor(new Color(100, 100, 100));
        buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + cs / 2 - 3, 6, 6);
        buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + cs / 2 - 3, 6, 6);
        buff.setColor(new Color(255, 255, 255));
        buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + cs / 2, 3, 3);
        buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + cs / 2, 3, 3);
      }
    }
    else{
      buff.fill3DRect(20 + i * cs + cs / 2 + d, 30 + j * cs + cs / 2 + d, -2 * d, -2 * d, true);
    }
    //
    // switch(v){
    // case 1:
    // buff.setColor(new Color(100, 100, 100));
    // buff.fillOval(20 + i * cs + cs / 2 - 3, 30 + j * cs + cs / 2 - 3, 6, 6);
    // buff.setColor(new Color(255, 255, 255));
    // buff.fillOval(20 + i * cs + cs / 2, 30 + j * cs + cs / 2, 3, 3);
    // break;
    // case 2:
    // buff.setColor(new Color(100, 100, 100));
    // buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + cs / 4 - 3, 6, 6);
    // buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + 3 * cs / 4 - 3,
    // 6, 6);
    // buff.setColor(new Color(255, 255, 255));
    // buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + 3 * cs / 4, 3, 3);
    // break;
    // case 3:
    // buff.setColor(new Color(100, 100, 100));
    // buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + cs / 4 - 3, 6, 6);
    // buff.fillOval(20 + i * cs + cs / 2 - 3, 30 + j * cs + cs / 2 - 3, 6, 6);
    // buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + 3 * cs / 4 - 3,
    // 6, 6);
    // buff.setColor(new Color(255, 255, 255));
    // buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + cs / 2, 30 + j * cs + cs / 2, 3, 3);
    // buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + 3 * cs / 4, 3, 3);
    // break;
    // case 4:
    // buff.setColor(new Color(100, 100, 100));
    // buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + cs / 4 - 3, 6, 6);
    // buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + 3 * cs / 4 - 3,
    // 6, 6);
    // buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + cs / 4 - 3, 6,
    // 6);
    // buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + 3 * cs / 4 - 3, 6,
    // 6);
    // buff.setColor(new Color(255, 255, 255));
    // buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + 3 * cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + 3 * cs / 4, 3, 3);
    // break;
    // case 5:
    // buff.setColor(new Color(100, 100, 100));
    // buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + cs / 4 - 3, 6, 6);
    // buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + 3 * cs / 4 - 3,
    // 6, 6);
    // buff.fillOval(20 + i * cs + cs / 2 - 3, 30 + j * cs + cs / 2 - 3, 6, 6);
    // buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + cs / 4 - 3, 6,
    // 6);
    // buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + 3 * cs / 4 - 3, 6,
    // 6);
    // buff.setColor(new Color(255, 255, 255));
    // buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + 3 * cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + cs / 2, 30 + j * cs + cs / 2, 3, 3);
    // buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + 3 * cs / 4, 3, 3);
    // break;
    // case 6:
    // buff.setColor(new Color(100, 100, 100));
    // buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + cs / 4 - 3, 6, 6);
    // buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + 3 * cs / 4 - 3,
    // 6, 6);
    // buff.fillOval(20 + i * cs + 3 * cs / 4 - 3, 30 + j * cs + cs / 4 - 3, 6,
    // 6);
    // buff.fillOval(20 + i * cs + cs / 4 - 3, 30 + j * cs + 3 * cs / 4 - 3, 6,
    // 6);
    // buff.fillOval(20 + i * cs + cs / 2 - 3, 30 + j * cs + cs / 4 - 3, 6, 6);
    // buff.fillOval(20 + i * cs + cs / 2 - 3, 30 + j * cs + 3 * cs / 4 - 3, 6,
    // 6);
    // buff.setColor(new Color(255, 255, 255));
    // buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + 3 * cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + 3 * cs / 4, 30 + j * cs + cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + cs / 4, 30 + j * cs + 3 * cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + cs / 2, 30 + j * cs + cs / 4, 3, 3);
    // buff.fillOval(20 + i * cs + cs / 2, 30 + j * cs + 3 * cs / 4, 3, 3);
    // break;
    // default:
    // break;
    // }

  }
  public void doRender(){
    buff.setColor(new Color(255, 255, 255));
    buff.fillRect(0, 0, W, H);
    buff.setColor(new Color(0, 0, 0));
    buff.fillRect(15, 30, 5, 5 + cs * sy);
    buff.fillRect(20 + cs * sx, 30, 5, 5 + cs * sy);
    buff.fillRect(20, cs * sy + 30, cs * sx, 5);
    buff.setFont(new Font("Arial",Font.BOLD,14));
    buff.drawString("HiScore: "+bestScore,20 + cs * sx+30,40);
    if(playing){
    for(int i = 0; i < sx; i++){
      for(int j = 0; j < sy; j++){
        if(tablero[i][j] > 0){
          drawBlock(i, j, tablero[i][j], tableroR[i][j]);
        }
      }
    }
    if(estado == 1){
      switch(r){
        case 1:
          drawBlock(x, y, v1, r);
          drawBlock(x, y + 1, v2, r);
          break;
        case 2:
          drawBlock(x, y + 1, v1, r);
          drawBlock(x + 1, y + 1, v2, r);
          break;
        case 3:
          drawBlock(x + 1, y, v2, r);
          drawBlock(x + 1, y + 1, v1, r);
          break;
        case 4:
          drawBlock(x, y, v2, r);
          drawBlock(x + 1, y, v1, r);
          break;
        default:
          break;
      }
    }
    //Ahora tengo que dibujar la proxima pieza.
    drawBlock(sx+3, 5, n1, 1);
    drawBlock(sx+3, 6, n2, 1);    
    buff.setColor(new Color(0,0,0));
    buff.drawString("Score: "+score,20 + cs * sx+30,60);
    buff.drawString("Level: "+level,20 + cs * sx+30,80);
    if(chain > 2)
      buff.drawString("Chain: x"+(chain-1),20 + cs * sx+30,100);
    }
    else{
      buff.drawString("Press SPACE to Start",20 + cs * sx/2-80,150);
    }
  }
  public void doPaint(){
    Graphics g = getGraphics();
    g.drawImage(bImg, 0, 0, this);
    g.dispose();
  }
  // Los contadores de tiempo estan aqui
  double moveTime = 0;
  double rotateTime = 0;
  double downTime = 0;
  int diying;
  public void doGame(double dt){
    if(playing){
      // System.out.println("estado = "+estado);
      if(estado == 1){
        // Revisar los movimientos
        moveTime += dt;
        rotateTime += dt;
        downTime += (1 +((level-1)/4.0)) * dt;
        if(keys[KeyEvent.VK_RIGHT] != 0){
          if(moveTime > 0.08){
            // Validar cuanto se puede mover
            switch(r){
              case 1:
                if(x + 1 < sx && tablero[x + 1][y] == 0 && tablero[x + 1][y + 1] == 0){
                  x++;
                  moveTime = 0;
                }
                break;
              case 2:
                if(x + 2 < sx && tablero[x + 2][y + 1] == 0){
                  x++;
                  moveTime = 0;
                }
                break;
              case 3:
                if(x + 2 < sx && tablero[x + 2][y] == 0 && tablero[x + 2][y + 1] == 0){
                  x++;
                  moveTime = 0;
                }
                break;
              case 4:
                if(x + 2 < sx && tablero[x + 2][y] == 0){
                  x++;
                  moveTime = 0;
                }
                break;
              default:
                break;
            }
          }
        }
        if(keys[KeyEvent.VK_LEFT] != 0){
          if(moveTime > 0.08){
            // Validar cuanto se puede mover
            switch(r){
              case 1:
                if(x - 1 >= 0 && tablero[x - 1][y] == 0 && tablero[x - 1][y + 1] == 0){
                  x--;
                  moveTime = 0;
                }
                break;
              case 2:
                if(x - 1 >= 0 && tablero[x - 1][y + 1] == 0){
                  x--;
                  moveTime = 0;
                }
                break;
              case 3:
                if(x >= 0 && tablero[x][y] == 0 && tablero[x][y + 1] == 0){
                  x--;
                  moveTime = 0;
                }
                break;
              case 4:
                if(x - 1 >= 0 && tablero[x - 1][y] == 0){
                  x--;
                  moveTime = 0;
                }
                break;
              default:
                break;
            }
          }
        }
        if(keys[KeyEvent.VK_UP] != 0){ // rotate
          if(rotateTime > 0.1){
            // Validar cuanto se puede mover
            switch(r){
              case 1:
                if(x + 1 < sx && tablero[x + 1][y + 1] == 0){
                  r = 2;
                  rotateTime = 0;
                  keys[KeyEvent.VK_UP] = 0;
                }
                break;
              case 2:
                r = 3;
                rotateTime = 0;
                keys[KeyEvent.VK_UP] = 0;
                break;
              case 3:
                if(x >= 0 && tablero[x][y] == 0){
                  r = 4;
                  rotateTime = 0;
                  keys[KeyEvent.VK_UP] = 0;
                }
                break;
              case 4:
                if(y + 1 < sy && tablero[x][y + 1] == 0){
                  r = 1;
                  rotateTime = 0;
                  keys[KeyEvent.VK_UP] = 0;
                }
                break;
              default:
                break;
            }
          }
        }
        // Y ahora falta que baje...
        if((keys[KeyEvent.VK_DOWN] != 0 && moveTime > 0.05) || downTime > 0.4){
          // System.out.println(downTime +" "+moveTime);
          boolean hit = false;
          switch(r){
            case 1:
              if(y + 2 == sy || tablero[x][y + 2] != 0)
                hit = true;
              break;
            case 2:
              if(y + 2 == sy || tablero[x][y + 2] != 0 || tablero[x + 1][y + 2] != 0)
                hit = true;
              break;
            case 3:
              if(y + 2 == sy || tablero[x + 1][y + 2] != 0)
                hit = true;
              break;
            case 4:
              if(y + 1 == sy || tablero[x][y + 1] != 0 || tablero[x + 1][y + 1] != 0)
                hit = true;
              break;
            default:
              break;
          }
          if(hit){
            // Debe pasar al siguiente estado.
            switch(r){
              case 1:
                tablero[x][y] = v1;
                tablero[x][y + 1] = v2;
                tableroR[x][y] = r;
                tableroR[x][y + 1] = r;
                break;
              case 2:
                tablero[x][y + 1] = v1;
                tablero[x + 1][y + 1] = v2;
                tableroR[x][y + 1] = r;
                tableroR[x + 1][y + 1] = r;
                break;
              case 3:
                tablero[x + 1][y] = v2;
                tablero[x + 1][y + 1] = v1;
                tableroR[x + 1][y] = r;
                tableroR[x + 1][y + 1] = r;
                break;
              case 4:
                tablero[x][y] = v2;
                tablero[x + 1][y] = v1;
                tableroR[x][y] = r;
                tableroR[x + 1][y] = r;
                break;
              default:
                break;
            }
            // Aqui pongo el codigo para el nuevo movimiento.
            estado = 2;
            // System.out.println("hit");
          }
          else{
            y++;
            moveTime = 0;
            downTime = 0;
          }
        }
      }
      else if(estado == 2){
        moveTime += dt;
        if(moveTime > 0.05){
          // revisar las caidas
          boolean down = false;
          for(int i = 0; i < sx; i++){
            for(int j = sy - 1; j > 0; j--){
              if(tablero[i][j - 1] > 0 && tablero[i][j] == 0){
                tablero[i][j] = tablero[i][j - 1];
                tablero[i][j - 1] = 0;
                tableroR[i][j] = tableroR[i][j - 1];
                tableroR[i][j - 1] = 0;
                down = true;
              }
            }
          }
          if(!down){
            estado = 3;
          }
          moveTime = 0;
        }
      }
      if(estado == 3){
        // revisar los hits!
        boolean bonus = false;
        int[][] group = new int[50][2];
        int pos = 0;
        int len = 0;
        for(int i = 0; i < sx; i++){
          for(int j = sy - 1; j >= 0; j--){
            if(tablero[i][j] > 1){
              int v = tablero[i][j];
              // System.out.println(v);
              group[0][0] = i;
              group[0][1] = j;
              len = 1;
              pos = 0;
              while(pos < len){
                // arriba
                if(group[pos][1] - 1 >= 0 && tablero[group[pos][0]][group[pos][1] - 1] == v && !isIn(group, len, group[pos][0], group[pos][1] - 1) && tableroR[group[pos][0]][group[pos][1] - 1] > 0){
                  group[len][0] = group[pos][0];
                  group[len][1] = group[pos][1] - 1;
                  len++;
                }
                // abajo
                if(group[pos][1] + 1 < sy && tablero[group[pos][0]][group[pos][1] + 1] == v && !isIn(group, len, group[pos][0], group[pos][1] + 1) && tableroR[group[pos][0]][group[pos][1]+ 1] > 0){
                  group[len][0] = group[pos][0];
                  group[len][1] = group[pos][1] + 1;
                  len++;
                }
                // derecha
                if(group[pos][0] + 1 < sx && tablero[group[pos][0] + 1][group[pos][1]] == v && !isIn(group, len, group[pos][0] + 1, group[pos][1]) && tableroR[group[pos][0]+1][group[pos][1]] > 0){
                  group[len][0] = group[pos][0] + 1;
                  group[len][1] = group[pos][1];
                  len++;
                }
                // izquierda
                if(group[pos][0] - 1 >= 0 && tablero[group[pos][0] - 1][group[pos][1]] == v && !isIn(group, len, group[pos][0] - 1, group[pos][1]) && tableroR[group[pos][0]-1][group[pos][1]] > 0){
                  group[len][0] = group[pos][0] - 1;
                  group[len][1] = group[pos][1];
                  len++;
                }
                pos++;
              }
              if(len >= v){
                // Hay que sacarlos
                piezas+= len;
                if(piezas >= 50){
                  level++;
                  piezas-= 50;
                }
                score += len*v*chain;
                for(int k = 0; k < len; k++){
                  int cs2 = -cs / 2;
                  tableroR[group[k][0]][group[k][1]] = cs2; // TODO: Como
                                                            // marcarlo
                  // Mato los unos que estan cerca
                  // arriba
                  if(group[k][1] - 1 >= 0 && tablero[group[k][0]][group[k][1] - 1] == 1){
                    tableroR[group[k][0]][group[k][1] - 1] = cs2;
                  }
                  // abajo
                  if(group[k][1] + 1 < sy && tablero[group[k][0]][group[k][1] + 1] == 1){
                    tableroR[group[k][0]][group[k][1] + 1] = cs2;
                  }
                  // derecha
                  if(group[k][0] + 1 < sx && tablero[group[k][0] + 1][group[k][1]] == 1){
                    tableroR[group[k][0] + 1][group[k][1]] = cs2;
                  }
                  // izquierda
                  if(group[k][0] - 1 >= 0 && tablero[group[k][0] - 1][group[k][1]] == 1){
                    tableroR[group[k][0] - 1][group[k][1]] = cs2;
                  }
                }
                bonus = true;
              }
            }
          }
        }
        if(bonus){
          chain++;
          estado = 4;
        }
        else{
          boolean ok = true;
          for(int i = 0; i < sx; i++){
            if(tablero[i][0] > 0)
              ok = false;
          }
          if(ok){
          chain = 1;
          estado = 1;
          v1 = n1;
          v2 = n2;
          n1 = (int)(Math.random() * 7 + 1);
          n2 = (int)(Math.random() * 7 + 1);
          r = 1;
          x = sx/2;
          y = 0;
          }
          else{
            estado = 5;
            diying = sy-1;
            moveTime = 0;
          }
        }
      }
      if(estado == 4){
        // destruir bloques
        boolean move = false;
        for(int i = 0; i < sx; i++){
          for(int j = 0; j < sy; j++){
            if(tableroR[i][j] < 0){
              move = true;
              tableroR[i][j]++;
              if(tableroR[i][j] == 0){
                tablero[i][j] = 0;
              }
            }
          }
        }
        if(!move){
          estado = 2;
        }
      }
      if(estado == 5){
        // Matar la pantalla.
        moveTime += dt;
        if(moveTime >= 0.05){
          for(int i = 0; i < sx; i++){
            tablero[i][diying] = 10;
            tableroR[i][diying] = -cs/2;
          }
          diying -= 1;
          if(diying < 0){
            if(score > bestScore)
              bestScore = score;
            playing = false;
          }
          moveTime = 0;
        }        
      }
    }
    else{
      // NO hay nada que hacer...
      if(keys[KeyEvent.VK_SPACE]> 0){
        for(int i = 0; i < sx; i++){
          for(int j = 0; j < sy; j++){
            tablero[i][j] = 0;
            tableroR[i][j] = 0;
          }
        }
        playing = true;
        estado = 1;
        chain = 1;
        level = 1;
        score = 0;
        x = sx/2;
        y = 0;
        r = 1;
        v1 = (int)(Math.random()*7 +1);
        v2 = (int)(Math.random()*7 +1);
        n1 = (int)(Math.random()*7 +1);
        n2 = (int)(Math.random()*7 +1);
        
      }
    }
  }
  private boolean isIn(int[][] group, int len, int i, int j){
    for(int k = 0; k < len; k++){
      if(group[k][0] == i && group[k][1] == j)
        return true;
    }
    return false;
  }
  public static void main(String[] args){
    Domino4K d = new Domino4K();
  }
}
