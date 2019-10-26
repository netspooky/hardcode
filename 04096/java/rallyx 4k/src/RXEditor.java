
import java.awt.*;
import java.awt.event.*;
import java.awt.geom.Arc2D;
import java.awt.geom.Area;
import java.awt.geom.Rectangle2D;
import java.awt.geom.RoundRectangle2D;

/*
 * Created on 24/01/2005
 *  
 */
/**
 * @author Rafael Carvallo
 *  
 */
public class RXEditor extends Canvas implements Runnable, TextListener{
  final private static int WIDTH = 800;
  final private static int PLR = 5;
  final private static byte SELECT = 1;
  final private static byte BULLET = 2;
  final private static byte HIT = 3;
  //Board
  private byte[][] stage;
  private int sizeX;
  private int sizeY;
  private int quadSize;
  private int[] data;
  boolean draw;
  //buffer
  Image bimg;
  Graphics2D buff;
  public TextArea text;

  public RXEditor(){
    enableEvents(AWTEvent.MOUSE_EVENT_MASK | AWTEvent.MOUSE_MOTION_EVENT_MASK);
    sizeX = 32;
    sizeY = 56;
    quadSize = 10;
    stage = new byte[sizeX][sizeY];
    data = new int[(sizeX * sizeY) / 32];
    //El arreglo tiene tamaño 56!!.
    setSize(sizeX * quadSize, sizeY * quadSize);
    text = new TextArea();
    text.addTextListener(this);
  }

  protected void processMouseEvent(MouseEvent e){
    if(e.getID() == MouseEvent.MOUSE_PRESSED){
      int px = e.getX();
      int py = e.getY();
      int x = px / quadSize;
      int y = py / quadSize;
      int t;
      if(x >= 0 && y >= 0 && x < sizeX && y < sizeY){
        if(e.getButton() == MouseEvent.BUTTON1){
          t = stage[x][y];
          stage[x][y] = 1;
          draw = true;
          if(t == 0){
            repaint();
            updateData(x, y);
            text.setText(generateString(data));            
          }
        }
        else{
          t = stage[x][y];
          stage[x][y] = 0;
          draw = false;
          if(t == 1){
            repaint();
            updateData(x, y);
            text.setText(generateString(data));            
          }
        }
      }
    }
  }

  protected void processMouseMotionEvent(MouseEvent e){
    if(e.getID() == MouseEvent.MOUSE_DRAGGED){
      int px = e.getX();
      int py = e.getY();
      int x = px / quadSize;
      int y = py / quadSize;
      int t;
      if(x >= 0 && y >= 0 && x < sizeX && y < sizeY){
        t = stage[x][y];
        stage[x][y] = (byte)((draw)?1:0);
        if((draw && t == 0) || (!draw && t == 1)){
          repaint();
          updateData(x, y);
          text.setText(generateString(data));          
        }
      }
    }
  }

  public void addNotify(){
    super.addNotify();
    bimg = createImage(sizeX * quadSize, sizeY * quadSize);
    buff = (Graphics2D)bimg.getGraphics();
    // beginLoop();
  }

  public void beginLoop(){
    (new Thread(this)).start();
  }

  public void run(){
    while(true){
      //     doGame(deltaT);
      doRender();
      doPaint();
      /*
       * try { Thread.sleep(20); } catch (InterruptedException e) { e.printStackTrace(); }
       */
    }
  }

  /**
   * Dibuja el buffer en la pantalla
   */
  private void doPaint(){
    Graphics g = getGraphics();
    g.drawImage(bimg, 0, 0, this);
  }

  private void updateData(int x, int y){
    int val = (y * sizeX + x) / 32;
    int pos = (y * sizeX + x) % 32;
    int m2 = 1 << pos;
    //System.out.println(val+" "+pos);
    if(stage[x][y] == 0){
      data[val] &= ~m2;
    }
    else{
      data[val] |= m2;      
    }
  }

  private void doRender(){
    Color col = new Color(255, 255, 255);
    buff.setColor(col);
    buff.fillRect(0, 0, WIDTH, WIDTH);
    col = new Color(100, 100, 100);
    buff.setColor(col);
    buff.setStroke(new BasicStroke(1));
    for(int i = 0; i <= sizeX; i++){
      for(int j = 0; j <= sizeY; j++){
        buff.drawRect(i * quadSize, j * quadSize, quadSize, quadSize);
      }
    }
    Area figura = new Area();
    for(int i = 0; i < sizeX; i++){
      for(int j = 0; j < sizeY; j++){
        if(stage[i][j] == 1){
          //RoundRectangle2D rec = new RoundRectangle2D.Float(i*quadSize,j*quadSize,quadSize,quadSize,quadSize/3,quadSize/3);
          Rectangle2D rec = new Rectangle2D.Float(i * quadSize, j * quadSize, quadSize, quadSize);
          figura.add(new Area(rec));
        }
      }
    }
    buff.setColor(new Color(200, 0, 0));
    buff.fill(figura);
    buff.setStroke(new BasicStroke(2));
    buff.setColor(new Color(0, 0, 0));
    buff.draw(figura);
  }

  /**
   * Realiza los cambios al juego
   */
  private void doGame(float deltaT){
  }

  public void update(Graphics g){
    paint(g);
  }

  private String generateString(int[] d){
    StringBuffer b = new StringBuffer();
    for(int i = 0; i < d.length; i++){
      b.append(d[i]+", //\n");
    }
    return b.toString();
  }

  public void paint(Graphics g){
    doRender();
    g.drawImage(bimg, 0, 0, this);
  }

  public static void main(String[] args){
    Frame f = new Frame();
    f.setLayout(new GridLayout(1, 2));
    f.addWindowListener(new WindowAdapter(){
      public void windowClosing(WindowEvent we){
        System.exit(0);
      }
    });
    RXEditor rx = new RXEditor();
    f.add(rx);
    f.add(rx.text);
    f.setVisible(true);
    Insets in = f.getInsets();
    f.setVisible(false);
    f.setSize(RXEditor.WIDTH + in.left + in.right, RXEditor.WIDTH + in.bottom + in.top);
    f.setTitle("FagoCite!");
    f.setVisible(true);
  }

  /* (non-Javadoc)
   * @see java.awt.event.TextListener#textValueChanged(java.awt.event.TextEvent)
   */
  public void textValueChanged(TextEvent e){
    //Tengo que rellenar el arreglo data con el string!
    String texto = text.getText();
    for(int i = 0; i < data.length; i++){
      int p= texto.indexOf(", //\n");
      if(p < 0){
        data[i] = 0;  
      }
      else{
        try{
          data[i] = Integer.parseInt(texto.substring(0,p));
        }
        catch(NumberFormatException nfe){
          data[i] = 0;  
        }
        texto = texto.substring(p+5);
      }
    }
    //Ahora tengo que actualizar el arreglo de bits
    for(int i = 0; i < stage.length; i++){
      for(int j = 0; j < stage[0].length; j++){
        int val = (j * sizeX + i) / 32;
        int pos = (j * sizeX + i) % 32;
        int m2 = 1 << pos;
        if((data[val] & m2) != 0)
          stage[i][j] = 1;
        else
          stage[i][j] = 0;
      }
    }
    repaint();
  }
}