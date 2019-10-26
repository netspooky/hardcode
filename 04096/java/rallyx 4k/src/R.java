
import java.awt.*;
import java.awt.event.*;
import java.awt.geom.Area;
import java.awt.geom.Rectangle2D;
import java.util.ArrayList;
import java.util.Random;

/*
 * Created on 28/12/2005 Last edit: 05/01/2006
 */
/**
 * @author Rafael Carvallo
 * 
 *  
 */
public class R extends Canvas{
  final static int W = 650;
  final static int H = 450;
  private static int[] keys = new int[256];

  public R(){
    setSize(W, H);
    enableEvents(AWTEvent.KEY_EVENT_MASK);
  }

  protected void processKeyEvent(KeyEvent e){
    if(e.getKeyCode() == KeyEvent.VK_ESCAPE)
      System.exit(0);
    keys[e.getKeyCode()] = (e.getID() & 1);
  }

  public static void main(String[] args) throws Exception{
    // Inicializacion de la pantalla
    String t = "RallyX 4K";
    //    Frame f = new Frame(t);
    //    f.setVisible(true);
    //    Insets in = f.getInsets();
    //    f.setVisible(false);
    //    R r = new R();
    //    f.add(r);
    //    f.setSize(W + in.left + in.right, H + in.bottom + in.top);
    //    f.setVisible(true);
    Frame f = new Frame(t);
    R r = new R();
    f.add(r);
    f.setSize(W, H);
    f.setVisible(true);
    // Ahora comienza el Juego
    // ------------------
    // variables
    // ------------------
    // Caracteristicas del Juego
    // Estado
    boolean gameRunning = false;
    // La etapa actual
    int currentStage = 0;
    // Listado de humos...
    ArrayList puffs;
    // El bonus de la letra L
    boolean fuelBonus = false;
    int tmpFuel = 0;
    //El bonus cuando se pasa la escena.
    boolean clearStage = false;
    // Si lanzo humos
    int puff = 0;
    // La bencina, contador de banderas comidas, la bandera s.
    int fuel = 0, count = 0, sfl = 0;
    // El valor de la siguiente bandera, el puntaje y el record.
    int flag = 0, score = 0, best = 0;
    // Si pierde
    boolean restart = false;
    boolean prepareStage = false;
    // Las vidas
    int lives = 0;
    // Banderas
    int[] flagx = new int[10];
    int[] flagy = new int[10];
    // Enemigos
    int[][] enemies = new int[10][6]; // {enemies[0][0],enemies[0][1],enemies[0][2],dy,enemies[0][4],nextenemies[0][4]}
    // Esta es la informacion de generacion de cada etapa
    int[][] stageData = { // {map,cars,rocks,chalenge}
    {0, 1, 3, 0}, //
        {0, 2, 3, 0}, //
        {0, 7, 7, 1}, //
        {1, 3, 4, 0}, //
        {1, 3, 5, 0}, //
        {1, 4, 5, 0}, //
        {1, 7, 8, 1}, //
    };
    // Stages: Aqui estan los mapas de cada etapa..
    int[][] stages = { // 
    { //
        8355840, //
            2138577902, //
            7937006, //
            1996554240, //
            2004361086, //
            8093696, //
            2138827760, //
            59908, //
            -1074861324, //
            -1609635308, //
            -1607595308, //
            -1347491116, //
            -1347491306, //
            -1608512554, //
            -1125718000, //
            -1125716010, //
            -1125720058, //
            -2147422210, //
            -603979584, //
            -587399458, //
            -1057169378, //
            -1665077538, //
            -1664348480, //
            -1127416067, //
            -2146697215, //
            -1124270339, //
            -1124270339, //
            -2147483647, //
            -1126375715, //
            -1126375715, //
            -1933572387, //
            -1394813219, //
            -1407401983, //
            549510893, //
            2094849773, //
            2094848001, //
            957, //
            956, //
            1828154880, //
            1828155116, //
            1827671788, //
            201813740, //
            1825595404, //
            1826061292, //
            1826061292, //
            1611661312, //
            1826061755, //
            1826061755, //
            1824522243, //
            1825920443, //
            13981115, //
            2081772592, //
            2094355846, //
            1624593910, //
            1825920502, //
            201326592 // , //
        }, //
        { //
        8191, //
            2079674369, //
            2079676349, //
            1074091013, //
            1534416309, //
            1534416149, //
            5397, //
            1608209749, //
            1079727445, //
            1599816017, //
            1096504661, //
            1543509269, //
            1096504597, //
            1599821237, //
            1079727109, //
            1608210365, //
            4097, //
            1591435199, //
            1591427072, //
            1073969077, //
            1541371829, //
            1541371829, //
            1541371829, //
            1539309573, //
            520052, //
            33652, //
            2111748868, //
            2111748980, //
            2111716212, //
            227409920, //
            1840135796, //
            1840135796, //
            1610627092, //
            1840134160, //
            1840134548, //
            227424660, //
            2111701012, //
            2111715316, //
            1978368, //
            2145269174, //
            12584374, //
            1859874816, //
            1612215734, //
            2145351094, //
            1024, //
            -570985034, //
            -570985034, //
            -574619648, //
            1398519, //
            2111132919, //
            1398263, //
            1876252032, //
            1616205238, //
            1866465334, //
            1868529078, //
            0 // , //
        } //
    };
    // Un arreglo con la informacion del mapa decodificada.
    byte[][] stage;
    // El tamaño del mapa
    int sizeX;
    int sizeY;
    // El tamaño de cada cuadro.
    int quadSize;
    // El grafico de la escena
    Area stageGraph = null;
    // En cuantos frames un enemigo pasa un cuadro
    byte stepEn = 8;
    // Cuanto avanza el jugador
    byte step = 9;
    // Doble buffer
    Image bimg;
    Graphics2D buff;
    // --------------------
    // Inicializacion
    // --------------------
    sizeX = 32;
    sizeY = 56;
    quadSize = 54;
    stage = new byte[sizeX][sizeY];
    puffs = new ArrayList();
    bimg = f.createImage(W, H);
    buff = (Graphics2D)bimg.getGraphics();
    // ------------------
    // El loop del juego
    // ------------------
    while(true){
      // ------------------------
      // Actualizacion doGame()
      // ------------------------
      long tini = System.currentTimeMillis();
      if(gameRunning){
        if(fuelBonus || clearStage){
          fuel -= 10;
          score += 10;
          if(fuel <= 0){
            fuelBonus = false;
            if(clearStage){
              prepareStage = true;
              clearStage = false;
            }
            else{
              fuel = tmpFuel;
            }
          }
        }
        else{
          // Por cada tiempo pierde un fuel
          fuel--;
          // Manejo de los autos
          for(int i = 0; i < stageData[currentStage][1] + 1; i++){
            // System.out.println(i+" "+enemies[i][4]+" "+enemies[i][5]);
            // Ahora tengo que mover al enemigo.
            int x = enemies[i][0];
            int y = enemies[i][2];
            if(i == 0){
              // Leemos el input y lo guardamos para la proxima vez que se tenga que
              // cambiar la enemies[0][4]eccion
              if(keys[KeyEvent.VK_UP] != 0){
                enemies[i][5] = KeyEvent.VK_UP;
              }
              if(keys[KeyEvent.VK_DOWN] != 0){
                enemies[i][5] = KeyEvent.VK_DOWN;
              }
              if(keys[KeyEvent.VK_LEFT] != 0){
                enemies[i][5] = KeyEvent.VK_LEFT;
              }
              if(keys[KeyEvent.VK_RIGHT] != 0){
                enemies[i][5] = KeyEvent.VK_RIGHT;
              }
              if(keys[KeyEvent.VK_SPACE] != 0){
                if(puff <= 0){
                  puff += 3;
                  keys[KeyEvent.VK_SPACE] = 0;
                }
              }
            }
            else{
              // Aqui viene la inteligencia artificial
              if(enemies[i][5] == 0){ // Si no tienen una enemies[0][4]eccion definida..
                int dex = enemies[i][0] - enemies[0][0];
                int dey = enemies[i][2] - enemies[0][2];
                if(dex * dex > dey * dey){ // horizontal
                  if(dex < 0)
                    enemies[i][5] = KeyEvent.VK_RIGHT;
                  else if(dex > 0)
                    enemies[i][5] = KeyEvent.VK_LEFT;
                  else
                    enemies[i][5] = 0;
                }
                else if(dex * dex < dey * dey){ // vertical
                  if(dey < 0)
                    enemies[i][5] = KeyEvent.VK_DOWN;
                  else if(dey > 0)
                    enemies[i][5] = KeyEvent.VK_UP;
                  else
                    enemies[i][5] = 0;
                }
                else{
                  enemies[i][5] = 0;
                }
              }
              // ahora hay que hacer que se den la vuelta cuando chican
              for(int j = 1; j < stageData[currentStage][1] + 1; j++){
                if(i != j){
                  if(enemies[i][4] == KeyEvent.VK_UP && enemies[i][0] == enemies[j][0] && enemies[i][2] == enemies[j][2] + 1){
                    enemies[i][5] = KeyEvent.VK_DOWN;
                  }
                  if(enemies[i][4] == KeyEvent.VK_DOWN && enemies[i][0] == enemies[j][0] && enemies[i][2] == enemies[j][2] - 1){
                    enemies[i][5] = KeyEvent.VK_UP;
                  }
                  if(enemies[i][4] == KeyEvent.VK_LEFT && enemies[i][0] == enemies[j][0] + 1 && enemies[i][2] == enemies[j][2]){
                    enemies[i][5] = KeyEvent.VK_RIGHT;
                  }
                  if(enemies[i][4] == KeyEvent.VK_RIGHT && enemies[i][0] == enemies[j][0] - 1 && enemies[i][2] == enemies[j][2]){
                    enemies[i][5] = KeyEvent.VK_LEFT;
                  }
                }
              }
            }
            // Solo se actualiza la direccion si estan en el cuadro exacto.
            if(enemies[i][1] == 0 && enemies[i][3] == 0){
              if(enemies[i][5] == KeyEvent.VK_UP){
                if(y > 0 && stage[x][y - 1] != 1){
                  enemies[i][4] = KeyEvent.VK_UP;
                  enemies[i][5] = 0;
                }
              }
              if(enemies[i][5] == KeyEvent.VK_DOWN){
                if(y < 55 && stage[x][y + 1] != 1){
                  enemies[i][4] = KeyEvent.VK_DOWN;
                  enemies[i][5] = 0;
                }
              }
              if(enemies[i][5] == KeyEvent.VK_LEFT){
                if(x > 0 && stage[x - 1][y] != 1){
                  enemies[i][4] = KeyEvent.VK_LEFT;
                  enemies[i][5] = 0;
                }
              }
              if(enemies[i][5] == KeyEvent.VK_RIGHT){
                if(x < 31 && stage[x + 1][y] != 1){
                  enemies[i][4] = KeyEvent.VK_RIGHT;
                  enemies[i][5] = 0;
                }
              }
            }
            // Ahora que ya tienen definida la direccion a tomar
            //Ahora tengo que ver si puede moverse.
            // Validar que no sea challenger o sino, que se le acabe el fuel.
            boolean cha = stageData[currentStage][3] == 0 || fuel <= 0;
            // Validar si esta sobre un humo.
            boolean onp = false;
            for(int j = 0; j < puffs.size(); j++){
              int[] pff = (int[])puffs.get(j);
              if(pff[0] == enemies[i][0] && pff[1] == enemies[i][2]){
                onp = true;
                break;
              }
            }
            //Finalmente el flag es solo si no es el jugador.
            //boolean okm = (i == 0)||((stageData[currentStage][3] == 0 || fuel <= 0) && !onp);
            boolean okm = (i == 0) || (cha && !onp);
            //La velocidad es ditinta para el jugadir y los enemigos.
            int st = (i == 0)?step:stepEn;
            // Por ultimo la actualizacion de la posicion.
            if(enemies[i][4] == KeyEvent.VK_UP && okm){
              if(y > 0 && stage[x][y - 1] != 1){
                enemies[i][3]--;
                if(enemies[i][3] == -st){
                  enemies[i][3] = 0;
                  enemies[i][2]--;
                }
              }
              else{
                if(x < 31 && stage[x + 1][y] != 1)
                  enemies[i][5] = KeyEvent.VK_RIGHT;
                if(x > 0 && stage[x - 1][y] != 1)
                  enemies[i][5] = KeyEvent.VK_LEFT;
              }
            }
            else if(enemies[i][4] == KeyEvent.VK_DOWN && okm){
              if(y < 55 && stage[x][y + 1] != 1){
                enemies[i][3]++;
                if(enemies[i][3] == st){
                  enemies[i][3] = 0;
                  enemies[i][2]++;
                }
              }
              else{
                if(x < 31 && stage[x + 1][y] != 1)
                  enemies[i][5] = KeyEvent.VK_RIGHT;
                if(x > 0 && stage[x - 1][y] != 1)
                  enemies[i][5] = KeyEvent.VK_LEFT;
              }
            }
            else if(enemies[i][4] == KeyEvent.VK_LEFT && okm){
              if(x > 0 && stage[x - 1][y] != 1){
                enemies[i][1]--;
                if(enemies[i][1] == -st){
                  enemies[i][1] = 0;
                  enemies[i][0]--;
                }
              }
              else{
                if(y > 0 && stage[x][y - 1] != 1)
                  enemies[i][5] = KeyEvent.VK_UP;
                if(y < 55 && stage[x][y + 1] != 1)
                  enemies[i][5] = KeyEvent.VK_DOWN;
              }
            }
            else if(enemies[i][4] == KeyEvent.VK_RIGHT && okm){
              if(x < 31 && stage[x + 1][y] != 1){
                enemies[i][1]++;
                if(enemies[i][1] == st){
                  enemies[i][1] = 0;
                  enemies[i][0]++;
                }
              }
              else{
                if(y > 0 && stage[x][y - 1] != 1)
                  enemies[i][5] = KeyEvent.VK_UP;
                if(y < 55 && stage[x][y + 1] != 1)
                  enemies[i][5] = KeyEvent.VK_DOWN;
              }
            }
            if(i == 0){ //Si es el jugador
              if(enemies[i][1] == 0 && enemies[i][3] == 0 && puff > 0){
                puffs.add(new int[]{enemies[i][0], enemies[i][2], 6 * step});
                puff--;
                fuel -= 5;
              }
              // Se come las banderas
              for(int j = 0; j < 10; j++){
                if(flagx[j] == enemies[i][0] && flagy[j] == enemies[i][2]){
                  flagx[j] = flagy[j] = -1; // Se saca la bandera.
                  if(j == 9)
                    sfl = 2;
                  count++;
                  score += flag * sfl;
                  flag += 100;
                  if(j == 0){
                    fuelBonus = true;
                    tmpFuel = fuel;
                  }
                }
              }
            }
            else{
              // Aqui hay que validar si toparon al jugador.
              if(x == enemies[0][0] && y == enemies[0][2]){
                restart = true;
              }
            }
          }
          // Ahora hay que ver como se desaparecen los puffs.
          for(int i = 0; i < puffs.size(); i++){
            int[] pff = (int[])puffs.get(i);
            pff[2]--;
            if(pff[2] == 0){
              puffs.remove(i);
              i--;
            }
          }
          if(count == 10){
            clearStage = true;
          }
        }
      }
      else{
        if(keys[KeyEvent.VK_SPACE] != 0){
          currentStage = -1;
          lives = 3;
          score = 0;
          prepareStage = true;
          gameRunning = true;
        }
      }
      //Las actualizaciones del juego van a tener que ir afuera.
      if(prepareStage || restart){
        if(restart){
          lives--;
          if(lives == 0){
            gameRunning = false;
            best = (best < score)?score:best;
          }
          else{
            restart = false;
            if(stageData[currentStage][3] == 1){
              prepareStage = true;
            }
          }
        }
        if(prepareStage){ // El mapa se genera solo si avanza en la etapa.
          currentStage++;
          // Ahora hay que generar el area con los datos.
          stageGraph = new Area();
          // Primero transformo en el arreglo de datos
          for(int i = 0; i < stage.length; i++){
            for(int j = 0; j < stage[0].length; j++){
              int val = (j * sizeX + i) / 32;
              int pos = (j * sizeX + i) % 32;
              int m2 = 1 << pos;
              if((stages[stageData[currentStage][0]][val] & m2) != 0)
                stage[i][j] = 1;
              else
                stage[i][j] = 0;
            }
          }
          // Ahora lo dibujo.
          stageGraph = new Area();
          for(int i = 0; i < sizeX; i++){
            for(int j = 0; j < sizeY; j++){
              if(stage[i][j] == 1){
                // RoundRectangle2D rec = new
                // RoundRectangle2D.Float(i*quadSize,j*quadSize,quadSize,quadSize,quadSize/3,quadSize/3);
                Rectangle2D rec = new Rectangle2D.Float(i * quadSize, j * quadSize, quadSize, quadSize);
                stageGraph.add(new Area(rec));
              }
            }
          }
        }
        // Se actualiza la posicion del jugador
        fuel = 3200;
        flag = 100;
        sfl = 1;
        // Los enemigos de la escena...
        for(int i = 0; i < stageData[currentStage][1] + 1; i++){
          int xx = 0, yy = 0, nd = 0;
          switch(i){
            case 0:
              xx = 15;
              yy = 50;
              nd = KeyEvent.VK_UP;
              break;
            case 1:
              xx = 15;
              yy = 53;
              nd = KeyEvent.VK_UP;
              break;
            case 2:
              xx = 13;
              yy = 53;
              nd = KeyEvent.VK_UP;
              break;
            case 3:
              xx = 17;
              yy = 53;
              nd = KeyEvent.VK_UP;
              break;
            case 4:
              xx = 11;
              yy = 53;
              nd = KeyEvent.VK_UP;
              break;
            case 5:
              xx = 19;
              yy = 53;
              nd = KeyEvent.VK_UP;
              break;
            case 6:
              xx = 16;
              yy = 1;
              nd = KeyEvent.VK_DOWN;
              break;
            case 7:
              xx = 18;
              yy = 1;
              nd = KeyEvent.VK_DOWN;
              break;
          }
          stage[xx][yy] = 3; // Inicio del enemigo;
          enemies[i][0] = xx;
          enemies[i][1] = 0;
          enemies[i][2] = yy;
          enemies[i][3] = 0;
          enemies[i][4] = 0;
          enemies[i][5] = nd;
        }
        if(prepareStage){
          count = 0; //Se resetea el contador de banderas
          // Ahora hay que generar las 10 banderas... la 1 es la L y la 10 es la S
          int i = 0;
          Random rand = new Random();
          while(i < 10){
            int x = rand.nextInt(32);
            int y = rand.nextInt(56);
            if(stage[x][y] == 0){
              stage[x][y] = 4; // Bandera
              flagx[i] = x;
              flagy[i] = y;
              i++;
            }
          }
          //por ultimo se desactiva el prepareStage
          prepareStage = false;
        }
        //Se limpian los puffs.
        puffs.clear();
      }
      // ------------------------
      // Render doRender()
      // ------------------------
      buff.setColor(new Color((gameRunning)?0xc8ffc8:0x000000));
      buff.fillRect(0, 0, W, H);
      if(gameRunning){
        // La escena.
        int x = enemies[0][0] * quadSize + enemies[0][1] * quadSize / step;
        int y = enemies[0][2] * quadSize + enemies[0][3] * quadSize / step;
        buff.translate(-(x - H / 2), -(y - H / 2));
        buff.setColor(new Color(0));
        buff.fillRect(0, 0, 32 * quadSize, 56 * quadSize);
        buff.setColor(new Color(0xffc8c8));
        buff.fill(stageGraph);
        buff.setStroke(new BasicStroke(2));
        buff.setColor(new Color(0x2828c8));
        buff.draw(stageGraph);
        // Las banderas
        for(int i = 0; i < 10; i++){
          if(flagx[i] >= 0){
            buff.setColor(new Color(0xdcdc00));
            buff.fillRect(flagx[i] * quadSize + 5, flagy[i] * quadSize + 5, quadSize - 10, quadSize - 10);
            if(i == 0){
              buff.setColor(new Color(0xdc0000));
              buff.drawString("L", flagx[i] * quadSize + 8, flagy[i] * quadSize + 20);
            }
            if(i == 9){
              buff.setColor(new Color(0xdc0000));
              buff.drawString("S", flagx[i] * quadSize + 8, flagy[i] * quadSize + 20);
            }
          }
        }
        // Los enemigos
        for(int i = 0; i < stageData[currentStage][1] + 1; i++){
          int st;
          if(i == 0){ //Jugoadr
            buff.setColor(new Color(0x0000ff));
            st = step;
          }
          else{ //enemigos
            buff.setColor(new Color(0xff0000));
            st = stepEn;
          }
          buff.fillRect(enemies[i][0] * quadSize + enemies[i][1] * quadSize / st, enemies[i][2] * quadSize + enemies[i][3] * quadSize / st, quadSize, quadSize);
          buff.setColor(new Color(0xffffc8));
          if(enemies[i][4] == KeyEvent.VK_UP)
            buff.fillRect(enemies[i][0] * quadSize + enemies[i][1] * quadSize / st + quadSize / 3, enemies[i][2] * quadSize + enemies[i][3] * quadSize / st + quadSize / 6,
                quadSize / 3, quadSize / 6);
          if(enemies[i][4] == KeyEvent.VK_DOWN)
            buff.fillRect(enemies[i][0] * quadSize + enemies[i][1] * quadSize / st + quadSize / 3, enemies[i][2] * quadSize + enemies[i][3] * quadSize / st + 4 * quadSize / 6,
                quadSize / 3, quadSize / 6);
          if(enemies[i][4] == KeyEvent.VK_LEFT)
            buff.fillRect(enemies[i][0] * quadSize + enemies[i][1] * quadSize / st + quadSize / 6, enemies[i][2] * quadSize + enemies[i][3] * quadSize / st + quadSize / 3,
                quadSize / 6, quadSize / 3);
          if(enemies[i][4] == KeyEvent.VK_RIGHT)
            buff.fillRect(enemies[i][0] * quadSize + enemies[i][1] * quadSize / st + 4 * quadSize / 6, enemies[i][2] * quadSize + enemies[i][3] * quadSize / st + quadSize / 3,
                quadSize / 6, quadSize / 3);
        }
        buff.setColor(new Color(0xffffff));
        for(int i = 0; i < puffs.size(); i++){
          int[] pff = (int[])puffs.get(i);
          buff.fillRect(pff[0] * quadSize, pff[1] * quadSize, quadSize, quadSize);
        }
        buff.translate((x - H / 2), (y - H / 2));
      }
      // El minimapa
      buff.setColor(new Color(0));
      buff.fillRect(H, 0, W, H);
      buff.setColor(new Color(0x000096));
      buff.fillRect(H + 20, H / 2, sizeX * 3, sizeY * 3);
      if(gameRunning){
        //Las banderas
        buff.setColor(new Color(0xdcdc00));
        for(int i = 0; i < 10; i++){
          if(flagx[i] >= 0){
            buff.fillRect(H + 20 + flagx[i] * 3, H / 2 + flagy[i] * 3, 3, 3);
          }
        }
        // El fuel
        buff.fillRect(H + 20, H / 2 - 50, (fuel / 100) * 3, 40);
        // Los autos
        for(int i = 0; i < stageData[currentStage][1] + 1; i++){
          buff.setColor(new Color((i == 0)?0xffffff:0xff0000));
          buff.fillRect(H + 20 + enemies[i][0] * 3, H / 2 + enemies[i][2] * 3, 3, 3);
        }
      }
      // Ahora hay que mostrar el score, record, etc.
      buff.setColor(new Color(0xffffff));
      if(!gameRunning)
        buff.drawString("SPACE TO START", H/2 - 50, 90);        
      buff.drawString("Score: " + score, H + 20, 50);
      buff.drawString("Hi-Score: " + best, H + 20, 70);
      buff.drawString("Stage  " + (currentStage + 1), H + 20, 90);
      // buff.drawString("Stage " + (currentStage + 1), H + 20, 90);
      buff.setColor(new Color(0x0000ff));
      for(int i = 1; i < lives; i++){
        buff.fillRect(H + i * 30, 100, 25, 25);
      }
      // ------------------------
      // A pantalla doPaint()
      // ------------------------
      Graphics g = r.getGraphics();
      g.drawImage(bimg, 0, 0, r);
      // Tiempo de Descanso entre frames..
      
      if(50 > (System.currentTimeMillis()-tini))
      Thread.sleep(50 - (System.currentTimeMillis()-tini));
    }
  }
}