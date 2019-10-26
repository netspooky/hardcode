
import java.awt.*;
import java.awt.event.*;

/*
 * Created on 24/01/2005
 *  
 */
/**
 * @author Rafael Carvallo
 *  
 */
public class T extends Canvas implements Runnable{
  final private static int W = 400;
  final private static int H = 400;
  private int[] keys = new int[256];
  Image bimg;

  public T(){
    enableEvents(AWTEvent.KEY_EVENT_MASK);
    //addKeyListener(this);
  }

  protected void processKeyEvent(KeyEvent e){
    if(e.getKeyCode() == KeyEvent.VK_ESCAPE)
      System.exit(0);
    keys[e.getKeyCode()] = (e.getID() & 1);
  }

  public void addNotify(){
    super.addNotify();
    bimg = createImage(W, H);
    (new Thread(this)).start();
  }

  public void run(){
    //game
    boolean[] flags = new boolean[4]; //{gameRunning, stageClear, hit, enemyfire}
    int[] values = new int[9]; //{stage, score, bads, eCount,boss, bestScore, clearCount, lives, nextExtend}
    float[] sins, coss;
    //Stages
    byte[][] stages = { //{du,dr,hu,fi,en}
    {100, 0, 0, 0, 10}, {50, 50, 0, 0, 14}, {20, 60, 20, 0, 18}, {10, 30, 50, 10, 22}, {0, 20, 60, 20, 24}, {0, 10, 50, 40, 26}, {0, 0, 40, 60, 28}/*, {0, 0, 0, 100, 30}*/};
    //Player and boss..
    int px , py,bossx, bossy;
    px = py = 0;
    bossx = bossy = 0;
    byte angle , bossa, bulletC;
    angle = bossa = 0;
    int[][] bullets; //Las balas van a ser de todos iguales...
    bulletC = 0;
    //enemies
    int[][] enemies;
    //clouds
    int[][] clouds;
    //Inicializacion de los campos...
    bullets = new int[50][5]; //bullet = {x,y,angle,live,tipo}
    enemies = new int[20][6]; //enemy = {x,y,angle,live,bullet,tipo}
    clouds = new int[50][2]; //cloud = {x,y}
    for(int i = 0; i < clouds.length; i++){
      clouds[i][0] = (int)(px + (Math.random() * W) - (W / 2));
      clouds[i][1] = (int)(py + (Math.random() * H) - (H / 2));
    }
    sins = new float[32];
    coss = new float[32];
    //float s = (float)Math.PI / 16;
    for(int i = 0; i < 32; i++){
      float d = (float)(i *Math.PI / 16);
      sins[i] = (float)Math.sin(d);
      coss[i] = (float)Math.cos(d);
    }
    while(true){
      //System.out.println("RUN");
      long tini = System.currentTimeMillis();
      //doGame();
      if(flags[0]){
        if(flags[1]){
          values[6]++;
          if(values[6] == 40){
            flags[1] = false;
            values[0]++;
            values[4] = 0;
            values[2] = stages[values[0]][4];
            //Limpiar las balas y los enemigos
            for(int j = 0; j < bullets.length; j++){
              bullets[j][3] = 0;
            }
            for(int j = 0; j < enemies.length; j++){
              enemies[j][3] = 0;
            }
            values[3] = 0;
          }
        }
        else{
          //input del jugador
          if(keys[KeyEvent.VK_LEFT] != 0){
            angle--;
            if(angle <= 0)
              angle = 31;
          }
          else if(keys[KeyEvent.VK_RIGHT] != 0){
            angle++;
            if(angle == 32)
              angle = 0;
          }
          //Se va enfriando el cañon
          bulletC--;
          if(keys[KeyEvent.VK_S] != 0 && bulletC <= 0){
            for(int i = 0; i < bullets.length; i++){
              if(bullets[i][3] == 0){
                bullets[i][0] = W / 2 + (int)px;
                bullets[i][1] = H / 2 + (int)py;
                bullets[i][2] = angle;
                bullets[i][3] = 1;
                bullets[i][4] = 0;
                bulletC = 3;
                break;
              }
            }
          }
          //Movimiento del Jugador
          px += 4 * coss[angle];
          py += 4 * sins[angle];
          //Actualizacion de las balas
          for(int i = 0; i < bullets.length; i++){
            if(bullets[i][3] == 1){
              if(bullets[i][4] == 1){ //Balas del Enemigo/Jefe
                bullets[i][0] += 6 * coss[bullets[i][2]];
                bullets[i][1] += 6 * sins[bullets[i][2]];
              }
              else{
                bullets[i][0] += 9 * coss[bullets[i][2]];
                bullets[i][1] += 9 * sins[bullets[i][2]];
              }
              int dx = bullets[i][0] - px;
              int dy = bullets[i][1] - py;
              //Revisar si se salio
              if(dx < 0 || dx > W || dy < 0 || dy > H){
                bullets[i][3] = 0;
              }
              if(bullets[i][4] == 1){ //Balas del Enemigo/Jefe
                //Revisar si choco con el jugador
                if(dx <= W / 2 + 2 && dx >= W / 2 - 2 && dy <= H / 2 + 2 && dy >= H / 2 - 2){
                  bullets[i][3] = 0;
                  values[7]--;
                  flags[2] = true;
                  if(values[7] == 0)
                    flags[0] = false;
                  //System.out.println("fin" + i);
                }
              }
              else{
                //Revisar si mata a algun enemigo.
                for(int j = 0; j < enemies.length; j++){
                  if(enemies[j][3] == 1){
                    int ex = bullets[i][0] - enemies[j][0];
                    int ey = bullets[i][1] - enemies[j][1];
                    if(ex <= 4 && ex >= -4 && ey <= 4 && ey >= -4){
                      enemies[j][3] = -10;
                      bullets[i][3] = 0;
                      values[1] += 50 + 25 * enemies[j][5];
                      values[2]--;
                      if(values[2] <= 0 && values[4] <= 0){
                        values[4] = stages[values[0]][4];
                        bossx = px - 10;
                        bossy = py - 10;
                        bossa = 0;
                      }
                      break;
                    }
                  }
                }
                //Revisa si mata al jefe.
                if(bullets[i][3] == 1 && values[4] > 0){
                  int ex = bullets[i][0] - bossx;
                  int ey = bullets[i][1] - bossy;
                  if(ex <= 4 && ex >= -4 && ey <= 4 && ey >= -4){
                    values[4]--;
                    values[1] += 10;
                    bullets[i][3] = 0;
                    if(values[4] == 0){
                      values[1] += 200;
                      flags[1] = true;
                      values[6] = 0;
                    }
                    break;
                  }
                }
              }
            }
          }
          //Revisar si hay extras..
          if(values[1] > values[8]){
            values[7]++;
            values[8] += 2000;
          }
          //El jefe
          if(values[4] > 0){
            //Actualiza la posicion
            bossx += 2 * coss[bossa];
            bossy += 2 * sins[bossa];
            int dx = bossx - px;
            int dy = bossy - py;
            if(dx > W){
              bossx = px - W;
            }
            else if(dx < -W){
              bossx = px + W;
            }
            if(dy > H){
              bossy = py - H;
            }
            else if(dy < -H){
              bossy = py + H;
            }
            //Si quiere disparar.
            if(Math.random() < 0.01 * (values[0] + 1)){
              dx = -dx + W / 2;
              dy = -dy + H / 2;
              float sind = (float)dy / (float)Math.sqrt(dy * dy + dx * dx);
              float cosd = (float)dx / (float)Math.sqrt(dy * dy + dx * dx);
              int beta = 0;
              if(cosd > 0){
                if(sind > 0){
                  //El valor esta entre 0 y 7
                  for(int j = 0; j < 8; j++){
                    if(coss[j] < cosd){
                      beta = j;
                      break;
                    }
                  }
                }
                else if(sind < 0){
                  //El valor esta entre 24 y 31
                  for(int j = 24; j < 32; j++){
                    if(coss[j] > cosd){
                      beta = j;
                      break;
                    }
                  }
                }
                else{
                  //El valor es 0
                  beta = 0;
                }
              }
              else if(cosd < 0){
                if(sind > 0){
                  //el valor esta entre 8 y 15
                  for(int j = 8; j < 15; j++){
                    if(coss[j] < cosd){
                      beta = j;
                      break;
                    }
                  }
                }
                else if(sind < 0){
                  //El valor esta entre 16 y 23
                  for(int j = 16; j < 24; j++){
                    if(coss[j] > cosd){
                      beta = j;
                      break;
                    }
                  }
                }
                else{
                  //EL valor es 16
                  beta = 16;
                }
              }
              else{
                if(sind > 0){
                  //el valor es 8
                  beta = 8;
                }
                else if(sind < 0){
                  //El valor es 24
                  beta = 24;
                }
              }
              for(int i = 0; i < bullets.length; i++){
                if(bullets[i][3] == 0){ //Dispara.
                  bullets[i][0] = bossx;
                  bullets[i][1] = bossy;
                  bullets[i][2] = beta;
                  bullets[i][3] = 1;
                  bullets[i][4] = 1;
                  bossa = (byte)((bossa + 1) % 32);
                  break;
                }
              }
            }
          }
          //enemigos
          //Se crea o no??
          if(Math.random() > 0.8 && values[3] < 5){
            for(int i = 0; i < enemies.length; i++){
              if(enemies[i][3] == 0){
                //4 opciones
                int o = (int)(Math.random() * 4);
                if(o == 0){
                  enemies[i][0] = px + W + 5;
                  enemies[i][1] = (int)(py + Math.random() * 2 * H - H);
                  enemies[i][2] = 8 + (int)(Math.random() * 16);
                }
                else if(o == 1){
                  enemies[i][0] = px - 5;
                  enemies[i][1] = (int)(py + Math.random() * 2 * H - H);
                  enemies[i][2] = 24 + (int)(Math.random() * 16);
                  if(enemies[i][2] >= 32)
                    enemies[i][2] -= 32;
                }
                else if(o == 2){
                  enemies[i][0] = (int)(px + Math.random() * 2 * W - W);
                  enemies[i][1] = py - 5;
                  enemies[i][2] = (int)(Math.random() * 16);
                }
                else{
                  enemies[i][0] = (int)(px + Math.random() * 2 * W - W);
                  enemies[i][1] = py + H + 5;
                  enemies[i][2] = 16 + (int)(Math.random() * 16);
                }
                enemies[i][3] = 1;
                enemies[i][4] = -1;
                //EL tipo de enemigo
                int po = 0;
                for(int j = 0; j < 4; j++){
                  po += stages[values[0]][j];
                  if(100 * Math.random() < po){
                    enemies[i][5] = j;
                    break;
                  }
                }
                values[3]++;
                break;
              }
            }
          }
          //Movimiento
          for(int i = 0; i < enemies.length; i++){
            //Los enemigos muertos.. actualizan su explosion
            if(enemies[i][3] < 0){
              enemies[i][3]++;
              if(enemies[i][3] == 0)
                values[3]--;
            }
            if(enemies[i][3] == 1){
              //LOs enemigos vivos
              int dx = enemies[i][0] - px;
              int dy = enemies[i][1] - py;
              //SI esta fuera de pantalla se mata.
              if(dx < -20 || dx > W + 20 || dy < -20 || dy > H + 20){
                enemies[i][3] = 0;
                values[3]--;
              }
              flags[3] = false;
              //Si disparo tiene que revisar si su bala se fue.
              if(enemies[i][4] >= 0 && bullets[enemies[i][4]][3] == 0){
                enemies[i][4] = -1;
              }
              //Ahora depende del tipo de enemigo
              int v = 0;
              if(enemies[i][5] == 0){
                v = 4;
                //Patron facil se mueve en una direccion, si dispara se mueve en la otra.
                if(enemies[i][4] == -1 && Math.random() < 0.2){ //Si le da por disparar:
                  dx = -dx + W / 2;
                  dy = -dy + H / 2;
                  float sind = (float)dy / (float)Math.sqrt(dy * dy + dx * dx);
                  float cosd = (float)dx / (float)Math.sqrt(dy * dy + dx * dx);
                  float ds = sind - sins[enemies[i][2]];
                  float dc = cosd - coss[enemies[i][2]];
                  //System.out.println(sind+" "+sins[enemies[i][2]]);
                  //System.out.println(cosd+" "+coss[enemies[i][2]]);
                  if(dc * dc < 0.05 && ds * ds < 0.05){ //Revisa si esta en direccion.
                    flags[3] = true;
                  }
                }
              }
              if(enemies[i][5] == 1){
                v = 4;
                //Patron facil se mueve en una direccion, si dispara se mueve en la otra.
                if(Math.random() < 0.2){ //Si le da por disparar:
                  if(enemies[i][4] == -1){
                    dx = -dx + W / 2;
                    dy = -dy + H / 2;
                    float sind = (float)dy / (float)Math.sqrt(dy * dy + dx * dx);
                    float cosd = (float)dx / (float)Math.sqrt(dy * dy + dx * dx);
                    float ds = sind - sins[enemies[i][2]];
                    float dc = cosd - coss[enemies[i][2]];
                    //System.out.println(sind+" "+sins[enemies[i][2]]);
                    //System.out.println(cosd+" "+coss[enemies[i][2]]);
                    if(dc * dc < 0.05 && ds * ds < 0.05){ //Revisa si esta en direccion.
                      flags[3] = true;
                    }
                    else{ //Rota a la izquierda
                      enemies[i][2] = (enemies[i][2] - 1 < 0)?31:enemies[i][2] - 1;
                    }
                  }
                  else{ //Rota a la derecha
                    enemies[i][2] = (enemies[i][2] + 1) % 32;
                  }
                }
              }
              else if(enemies[i][5] >= 2){ //Hunter y fighters, persiguen al enemigo...
                //Actualiza la posicion
                v = 3;
                if(enemies[i][5] == 3){ //El fighter dispara hacia donde deberia estar el jugador.
                  //Calculo del desfase con respecto a la distancia.
                  float d = (float)Math.sqrt(dy * dy + dx * dx);
                  float tt = d / 6;
                  float tx = px + tt * coss[angle];
                  float ty = py + tt * sins[angle];
                  dx = enemies[i][0] - (int)tx;
                  dy = enemies[i][1] - (int)ty;
                  //Ahhora el codigo es similar al de los hunters.
                }
                dx = -dx + W / 2;
                dy = -dy + H / 2;
                float sind = (float)dy / (float)Math.sqrt(dy * dy + dx * dx);
                float cosd = (float)dx / (float)Math.sqrt(dy * dy + dx * dx);
                int beta = 0;
                if(cosd > 0){
                  if(sind > 0){
                    //El valor esta entre 0 y 7
                    for(int j = 0; j < 8; j++){
                      if(coss[j] < cosd){
                        beta = j;
                        break;
                      }
                    }
                  }
                  else if(sind < 0){
                    //El valor esta entre 24 y 31
                    for(int j = 24; j < 32; j++){
                      if(coss[j] > cosd){
                        beta = j;
                        break;
                      }
                    }
                  }
                  else{
                    //El valor es 0
                    beta = 0;
                  }
                }
                else if(cosd < 0){
                  if(sind > 0){
                    //el valor esta entre 8 y 15
                    for(int j = 8; j < 15; j++){
                      if(coss[j] < cosd){
                        beta = j;
                        break;
                      }
                    }
                  }
                  else if(sind < 0){
                    //El valor esta entre 16 y 23
                    for(int j = 16; j < 24; j++){
                      if(coss[j] > cosd){
                        beta = j;
                        break;
                      }
                    }
                  }
                  else{
                    //EL valor es 16
                    beta = 16;
                  }
                }
                else{
                  if(sind > 0){
                    //el valor es 8
                    beta = 8;
                  }
                  else if(sind < 0){
                    //El valor es 24
                    beta = 24;
                  }
                }
                //Ya tengo el angulo esperado, ahora tengo que virar hacia el ...
                if(beta < enemies[i][2]){
                  if(beta < enemies[i][2] - 16)
                    enemies[i][2] = (enemies[i][2] + 1) % 32;
                  else
                    enemies[i][2] = (enemies[i][2] - 1 < 0)?31:enemies[i][2] - 1;
                }
                else if(beta > enemies[i][2]){
                  if(beta > enemies[i][2] + 16)
                    enemies[i][2] = (enemies[i][2] - 1 < 0)?31:enemies[i][2] - 1;
                  else
                    enemies[i][2] = (enemies[i][2] + 1) % 32;
                }
                //Ahora definir cuando disparar
                if(enemies[i][4] == -1 && Math.random() < 0.2){ //Si le da por disparar
                  float ds = sind - sins[enemies[i][2]];
                  float dc = cosd - coss[enemies[i][2]];
                  //System.out.println(sind+" "+sins[enemies[i][2]]);
                  //System.out.println(cosd+" "+coss[enemies[i][2]]);
                  if(dc * dc < 0.05 && ds * ds < 0.05){ //Revisa si esta en direccion.
                    flags[3] = true;
                  }
                }
              }
              //La actualizacion de la posicion
              enemies[i][0] += v * coss[enemies[i][2]];
              enemies[i][1] += v * sins[enemies[i][2]];
              if(flags[3]){
                for(int j = 0; j < bullets.length; j++){
                  if(bullets[j][3] == 0){ //Dispara.
                    bullets[j][0] = enemies[i][0];
                    bullets[j][1] = enemies[i][1];
                    bullets[j][2] = enemies[i][2];
                    bullets[j][3] = 1;
                    bullets[j][4] = 1;
                    enemies[i][4] = j;
                    break;
                  }
                }
              }
            }
          }
        }
      }
      else{
        px += 4 * coss[angle];
        py += 4 * sins[angle];
        if(keys[KeyEvent.VK_SPACE] != 0){
          flags[0] = true;
          values[1] = 0;
          values[0] = 0;
          values[4] = 0;
          values[7] = 3;
          values[8] = 2000;
          values[2] = stages[values[0]][4];
          //px = W / 2;
          //py = H / 2;
          bulletC = 0;
          //Limpiar las balas y los enemigos
          for(int j = 0; j < bullets.length; j++){
            bullets[j][3] = 0;
          }
          for(int j = 0; j < enemies.length; j++){
            enemies[j][3] = 0;
          }
          values[3] = 0;
        }
      }
      //Nubes
      for(int i = 0; i < clouds.length; i++){
        int dx = clouds[i][0] - px;
        int dy = clouds[i][1] - py;
        if(dx > W){
          clouds[i][0] = px - W;
          clouds[i][1] = (int)(py + Math.random() * 2 * H - H);
        }
        else if(dx < -W){
          clouds[i][0] = px + W;
          clouds[i][1] = (int)(py + Math.random() * 2 * H - H);
        }
        else if(dy > H){
          clouds[i][1] = py - H;
          clouds[i][0] = (int)(px + Math.random() * 2 * W - W);
        }
        else if(dy < -H){
          clouds[i][1] = py + H;
          clouds[i][0] = (int)(px + Math.random() * 2 * W - W);
        }
      }
      //doRender();
      int[] shipx = new int[3];
      int[] shipy = new int[3];
      Graphics buff = bimg.getGraphics();
      //buff.setFont(new Font("Arial", Font.BOLD, 12));
      if(flags[2]){
        buff.setColor(new Color(255, 0, 0));
        flags[2] = false;
      }
      else{
        buff.setColor(new Color(0, 0, 0));
      }
      buff.fillRect(0, 0, W, H);
      //The stars
      buff.setColor(new Color(255, 255, 255));
      for(int i = 0; i < clouds.length; i++){
        buff.fillRect(clouds[i][0] - px, clouds[i][1] - py, 2, 2);
      }
      //Si el juego esta corriendo:
      if(flags[0]){
        buff.setColor(new Color(200, 200, 0));
        buff.drawString("Score: " + values[1], 20, 35);
        buff.drawString("Stage: " + (values[0] + 1), 350, 35);
        if(values[4] <= 0){
          buff.drawString("Enemies: ", 20, 370);
          buff.fillRect(80, 350, values[2] * 4, 20);
        }
        else{
          buff.drawString("Boss: ", 20, 370);
          buff.fillRect(80, 350, values[4] * 4, 20);
        }
        for(int i = 0; i < values[7]; i++){
          buff.fillRect(20 + i * 10, 45, 9, 9);
        }
        if(flags[1]){ //Hacer el efecto..
          for(int i = 0; i < 10; i++){
            buff.setColor(new Color(0, 5 + 5 * i, 30 + 25 * i));
            shipx[0] = W / 2 + (int)(i * values[6] * coss[angle]) + (int)(-5 * coss[angle] - 5 * sins[angle]);
            shipx[1] = W / 2 + (int)(i * values[6] * coss[angle]) + (int)(10 * coss[angle]);
            shipx[2] = W / 2 + (int)(i * values[6] * coss[angle]) + (int)(-5 * coss[angle] + 5 * sins[angle]);
            shipy[0] = H / 2 + (int)(i * values[6] * sins[angle]) + (int)(-5 * sins[angle] + 5 * coss[angle]);
            shipy[1] = H / 2 + (int)(i * values[6] * sins[angle]) + (int)(10 * sins[angle]);
            shipy[2] = H / 2 + (int)(i * values[6] * sins[angle]) + (int)(-5 * sins[angle] - 5 * coss[angle]);
            buff.fillPolygon(shipx, shipy, 3);
          }
        }
        else{
          if(values[4] <= 0){
            buff.drawString("Enemies: ", 20, 370);
            buff.fillRect(80, 350, values[2] * 4, 20);
          }
          else{
            buff.drawString("Boss: ", 20, 370);
            buff.fillRect(80, 350, values[4] * 4, 20);
          }
          //Hay que dibujar el juego
          //bullets
          for(int i = 0; i < bullets.length; i++){
            if(bullets[i][3] == 1){
              if(bullets[i][4] == 1)
                buff.setColor(new Color(0, 255, 0));
              else{
                buff.setColor(new Color(255, 255, 0));
              }
              buff.fillRect(bullets[i][0] - px, bullets[i][1] - py, 3, 3);
            }
          }
          //The player
          buff.setColor(new Color(0, 50, 255));
          shipx[0] = W / 2 + (int)(-5 * coss[angle] - 5 * sins[angle]);
          shipx[1] = W / 2 + (int)(10 * coss[angle]);
          shipx[2] = W / 2 + (int)(-5 * coss[angle] + 5 * sins[angle]);
          shipy[0] = H / 2 + (int)(-5 * sins[angle] + 5 * coss[angle]);
          shipy[1] = H / 2 + (int)(10 * sins[angle]);
          shipy[2] = H / 2 + (int)(-5 * sins[angle] - 5 * coss[angle]);
          buff.fillPolygon(shipx, shipy, 3);
          //The enemies
          for(int i = 0; i < enemies.length; i++){
            if(enemies[i][3] < 0){
              buff.setColor(new Color(180, 0, 0));
              for(int j = 0; j < 32; j += 4){
                buff.fillRect(enemies[i][0] - (int)px + (int)((11 + enemies[i][3]) * coss[j]), enemies[i][1] - (int)py + (int)((11 + enemies[i][3]) * sins[j]), 2, 2);
              }
            }
            else if(enemies[i][3] == 1){
              shipx[0] = enemies[i][0] - px + (int)(-5 * coss[enemies[i][2]] - 5 * sins[enemies[i][2]]);
              shipx[1] = enemies[i][0] - px + (int)(10 * coss[enemies[i][2]]);
              shipx[2] = enemies[i][0] - px + (int)(-5 * coss[enemies[i][2]] + 5 * sins[enemies[i][2]]);
              shipy[0] = enemies[i][1] - py + (int)(-5 * sins[enemies[i][2]] + 5 * coss[enemies[i][2]]);
              shipy[1] = enemies[i][1] - py + (int)(10 * sins[enemies[i][2]]);
              shipy[2] = enemies[i][1] - py + (int)(-5 * sins[enemies[i][2]] - 5 * coss[enemies[i][2]]);
              if(enemies[i][5] == 0){
                buff.setColor(new Color(255, 255, 180));
              }
              if(enemies[i][5] == 1){
                buff.setColor(new Color(255, 180, 180));
              }
              if(enemies[i][5] == 2){
                buff.setColor(new Color(255, 180, 0));
              }
              if(enemies[i][5] == 3){
                buff.setColor(new Color(255, 0, 0));
              }
              buff.fillPolygon(shipx, shipy, 3);
            }
          }
          if(values[4] > 0){
            shipx[0] = (int)(bossx - px + -5 * coss[bossa] - 5 * sins[bossa]);
            shipx[1] = (int)(bossx - px + 10 * coss[bossa]);
            shipx[2] = (int)(bossx - px + -5 * coss[bossa] + 5 * sins[bossa]);
            shipy[0] = (int)(bossy - py + -5 * sins[bossa] + 5 * coss[bossa]);
            shipy[1] = (int)(bossy - py + 10 * sins[bossa]);
            shipy[2] = (int)(bossy - py + -5 * sins[bossa] - 5 * coss[bossa]);
            buff.setColor(new Color(255, 255, 255));
            buff.drawPolygon(shipx, shipy, 3);
          }
        }
      }
      else{
        buff.setColor(new Color(200, 200, 0));
        //String tmp = "Star Fighter 4K";
        //int w = (int)buff.getFont().getStringBounds(tmp, ((Graphics2D)buff).getFontRenderContext()).getWidth();
        buff.drawString("Star Fighter 4K", (W - 81) / 2, 40);
        buff.drawString("PRESS SPACE", (W - 84) / 2, 80);
        buff.drawString("LEFT,RIGHT: rotate S: shoot", (W - 154) / 2, 340);
      }
      //doPaint();
      getGraphics().drawImage(bimg, 0, 0, this);
      long tfin = System.currentTimeMillis();
      //if(tfin - tini < 30){
      try{
        Thread.sleep(30/* - (tfin - tini) */);
      }
      catch(InterruptedException e){
        e.printStackTrace();
      }
      //}
    }
  }

  public static void main(String[] args){
    Frame f = new Frame();
    f.setVisible(true);
    Insets in = f.getInsets();
    f.setVisible(false);
    f.add(new T());
    f.setSize(T.W + in.left + in.right, T.H + in.bottom + in.top);
    f.setTitle("Star Fighter 4K");
    f.setVisible(true);
  }
}