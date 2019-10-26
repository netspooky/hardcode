import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.io.*;
import javax.sound.sampled.*;
import java.util.Arrays;
import java.util.Random;


public class TFps extends JFrame implements ActionListener, Runnable {
	private static final int BOX_SIZE = 25;
	private static final int FIELD_WIDTH = 11;
	private static final int FIELD_HEIGHT = 20;

	private static final int WINDOW_WIDTH = FIELD_WIDTH*BOX_SIZE * 2;
	private static final int WINDOW_HEIGHT = FIELD_HEIGHT*BOX_SIZE + 105;

	private static final int FIELD_SHIFT = 40;

	private static final int TIMER_DELAY = 20;

	private static byte[]I;
	private static Color[]C;

	static {
		try {
			ObjectInputStream is = new ObjectInputStream(TFps.class.getClassLoader().getResourceAsStream("o"));
			I = (byte[])is.readObject();
			C = (Color[])is.readObject();
//			is.close();
		} catch (final Exception ex) {
		}
	}
	private boolean tP(final int x, final int y, int St) {
		St+= item;
 		for (int i = 0;i<4;i++) {
			int x1 = x + I[St++];
			int y1 = y + I[St++];
			if (x1<0 || x1>=FIELD_WIDTH) {
				return false;
			}
			if (y1< 0) {
				return false;
			}
			if (0!=F[x1 + y1*FIELD_WIDTH]) {
				return false;
			}
		}
		return true;
	}
	
	protected void processKeyEvent(final KeyEvent ke) {
		if (KeyEvent.KEY_PRESSED==ke.getID()) {
			switch (ke.getKeyCode()) {
			case KeyEvent.VK_LEFT:
				if (tP(x-1, y, St)) {
					x--;
				}
				break;
			case KeyEvent.VK_RIGHT:
				if (tP(x+1, y, St)) {
					x++;
				}
				break;
			case KeyEvent.VK_UP:
				{
					int temp = (St+8)%32;
					if (tP(x, y, temp)) {
						St = temp;
					}
				}
				break;
			case KeyEvent.VK_DOWN:
				fD = true;
				break;
			}
			if (PL) {
				repaint(FIELD_SHIFT, FIELD_SHIFT, FIELD_WIDTH*BOX_SIZE+3, FIELD_HEIGHT*BOX_SIZE+3);
				return ;
			}
			switch (ke.getKeyCode()) {
			case KeyEvent.VK_SPACE:
				restart();
				break;
			case KeyEvent.VK_PAGE_UP:
				if(sLv>1) {
					L = --sLv;
				}
				break;
			case KeyEvent.VK_PAGE_DOWN:
				if(sLv<25) {
					L = ++sLv;
				}
				break;
			}
			repaint();
		}
	}
	
	public void actionPerformed(ActionEvent e) {
		iC++;
		repaint(FIELD_SHIFT, FIELD_SHIFT, FIELD_WIDTH*BOX_SIZE+3, BOX_SIZE*FIELD_HEIGHT+3);
		if(!PL) {
			return ;
		}

		if (0!=(++c % L) && !fD) {
			int ssub = BOX_SIZE*c/L - BOX_SIZE;
			if (0==ssub) {
				ssub = -25;
			}
			sub = ssub;
		} else {
			if (tP(x, y-1, St)) {
				y--;
				if (fD && tP(x, y-1, St)) {
					y--;
				}
			} else {
				//drop
				pS = true;
				int start = item + St;
				for (int i = start;i<start+8;i+= 2) {
					F[(x + I[i]) + (y + I[i+1])*FIELD_WIDTH] = item/32+1;
				}
outer:				for (int j = 0;j<FIELD_HEIGHT;j++) {
					for (int i = 0;i<FIELD_WIDTH;i++) {
						if (0==F[j*FIELD_WIDTH + i]) {
							continue outer;
						}
					}
					start = j*FIELD_WIDTH;
					System.arraycopy(F, start + FIELD_WIDTH ,F, start, FIELD_HEIGHT*FIELD_WIDTH-FIELD_WIDTH-start);

					rm++;
					SC+= 26-L;
					if (0==rm%10 && L>1) {
						L--;
					}
					j--;
				}

				x = FIELD_WIDTH/2;
				y = FIELD_HEIGHT;
				item = N;
				N = r.nextInt(7)*32;
				St = 0;
				fD = false;
				bD = (N%5)-2;

				if(!tP(x, y, St)) {
					PL = false;
				}
				repaint();
				iS = (int)System.currentTimeMillis();
				iC = 0;
			}
			c = 0;
			sub = -25;
		}

		int t = (int)System.currentTimeMillis();
		if (t-sT > 300) {
			fps = (int)(fC*1000/(t-sT));
		}
		if ((int)(t-iS)/TIMER_DELAY>iC) {
			actionPerformed(e);
		}
	}

	/** Start a new game. */
	private void restart () {
		Arrays.fill(F, 0);
		x = FIELD_WIDTH/2;
		y = FIELD_HEIGHT;
		item = N;
		N = r.nextInt(7)*32;
		fD = false;
		St = 0;
		SC = 0;
		rm = 0;
		L = sLv;
		PL = true;
	}
	
	private void drawSquare(Graphics2D g,int x, int y, int color, int sub) {
		g.setColor(Color.black);
		g.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.5f));
		g.fillRect(FIELD_SHIFT + 8 + x*BOX_SIZE, FIELD_SHIFT + 8 + (FIELD_HEIGHT-1)*BOX_SIZE-y*BOX_SIZE + sub, BOX_SIZE-1, BOX_SIZE-1);
		g.setPaintMode();
		g.fillRect(FIELD_SHIFT + x*BOX_SIZE, FIELD_SHIFT + (FIELD_HEIGHT-1)*BOX_SIZE - y*BOX_SIZE + sub, BOX_SIZE-1, BOX_SIZE-1);
		g.setColor(C[color]);
		g.fillRect(FIELD_SHIFT + 2 + x*BOX_SIZE, FIELD_SHIFT + 2 + (FIELD_HEIGHT-1)*BOX_SIZE-y*BOX_SIZE + sub, BOX_SIZE-5, BOX_SIZE-5);
	}

	public void paint(final Graphics gr) {
		fC++;
		Graphics2D g;
		if (null==oB) {
			oB = createImage(WINDOW_WIDTH, WINDOW_HEIGHT);
			bG = createImage(WINDOW_WIDTH + (FIELD_WIDTH+2)*BOX_SIZE, WINDOW_HEIGHT);
			g = (Graphics2D)bG.getGraphics();

			g.setColor(C[8]);
			g.fillRect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
			
			g.setColor(C[10]);
			g.fillRect(FIELD_SHIFT + 10, FIELD_SHIFT + 10, BOX_SIZE*FIELD_WIDTH+3, BOX_SIZE*FIELD_HEIGHT+3);
			g.fillRect(FIELD_WIDTH*BOX_SIZE + 130, BOX_SIZE*4 + 10, 90, 70);
			g.fillRect(FIELD_WIDTH*BOX_SIZE + 130, BOX_SIZE*8 + 10, 90, BOX_SIZE*6);

			g.setColor(Color.black);
			g.fillRect(FIELD_WIDTH*BOX_SIZE + 119, BOX_SIZE*4-1, 92, 72);
			g.fillRect(FIELD_WIDTH*BOX_SIZE + 119, BOX_SIZE*8-1, 92, BOX_SIZE*6 + 2);
			g.fillRect(FIELD_SHIFT - 3, FIELD_SHIFT - 3, BOX_SIZE*FIELD_WIDTH+5, BOX_SIZE*FIELD_HEIGHT+5);

			g.setColor(C[9]);
			g.fillRect(FIELD_WIDTH*BOX_SIZE + 121, BOX_SIZE*4+1, 88, 68);
			g.fillRect(FIELD_WIDTH*BOX_SIZE + 121, BOX_SIZE*8+1, 88, BOX_SIZE*6 - 2);
			g.fillRect(FIELD_SHIFT -1 , FIELD_SHIFT - 1, BOX_SIZE*FIELD_WIDTH+1, BOX_SIZE*FIELD_HEIGHT+1);

			g.fillRect(WINDOW_WIDTH, 0, FIELD_WIDTH*BOX_SIZE, (FIELD_HEIGHT+2)*BOX_SIZE);
			for (int i = WINDOW_WIDTH+ 8; i<WINDOW_WIDTH + FIELD_WIDTH*BOX_SIZE; i+= 25) {
				for (int j = 6; j<(FIELD_HEIGHT+5)*BOX_SIZE; j+= 25) {
					g.setColor(C[2]);
					g.drawRect(i, j, 10, 8);
					g.setColor(C[7]);
					g.drawRect(i+4, j+4, 8, 10);
				}
			}
		}
		g = (Graphics2D)oB.getGraphics();

		g.drawImage(bG, 0, 0, this);
		bY = (bY + bD + 50) % 50;

		g.setClip(FIELD_SHIFT, FIELD_SHIFT, BOX_SIZE*FIELD_WIDTH, BOX_SIZE*FIELD_HEIGHT);
		g.drawImage(bG, FIELD_SHIFT - WINDOW_WIDTH, bY/2, this);

		int start = item + St;
		for (int i = start;i<start+8;i+= 2) {
			drawSquare(g, x+I[i], y+I[i+1], item/32+1, sub);
		}
		for (int j = FIELD_HEIGHT-1;j>=0; j--) {
			for (int i = 0;i<FIELD_WIDTH; i++) {
				if(0!=F[j*FIELD_WIDTH+i]) {
					drawSquare(g, i, j, F[j*FIELD_WIDTH+i], 0);
				}
			}
		}

		g.setClip(0, FIELD_SHIFT, WINDOW_WIDTH, WINDOW_HEIGHT);

		for (int i = N;i<N+8;i+= 2) {
			drawSquare(g, FIELD_WIDTH + 5 + I[i], 10 + I[i+1], N/32+1, 0);
		}

		g.setColor(Color.black);
		g.drawString("Score: " + SC, FIELD_WIDTH*BOX_SIZE + 140, BOX_SIZE * 5);
		g.drawString("Level: " + (26-L), FIELD_WIDTH*BOX_SIZE + 140, BOX_SIZE * 6);
		g.drawString("FPS: " + fps, WINDOW_WIDTH - 70, WINDOW_HEIGHT - 60);
		if(!PL) {
//			g.drawString("Game Over", FIELD_WIDTH*BOX_SIZE + 130, BOX_SIZE*16);
			g.drawString("Press SPACE to start", FIELD_WIDTH*BOX_SIZE + 130, BOX_SIZE*17);
			g.drawString("PgUp/DN adjust Level", FIELD_WIDTH*BOX_SIZE + 130, BOX_SIZE*18);
		}
		gr.drawImage(oB, 0, 0, this);
	}

	public void run() {
		try {
			SourceDataLine line = (SourceDataLine)AudioSystem.getLine(
					new DataLine.Info(
						SourceDataLine.class,
						new AudioFormat(7500.0f, 8, 1, false, true)
					)
			);
			line.open();
			line.start();
			for(;;) {
				Thread.sleep(20);
				if(pS) {
					pS = false;
					line.write(I, 224, 42);
				}
			}
		} catch (final Exception ex) {
		}
	}

	/** Offscreen buffer for double-buffering. */
	static private Image oB;
	/** The main background. */
	static private Image bG;
	
	/** Field of I that have been layed down. */
	static private int[]F = new int[FIELD_WIDTH*(FIELD_HEIGHT+5)];

	/** Base x and y coordinates of the item currently falling. */
	static private int x;
	static private int y;
	/** The St of item's "rotation". */
	static private int St;
	/** Item's index multiplied by 32. */
	static private int item;
	/** Current L = 26-L. */
	static private int L;
	/** Current score. */
	static private int SC;
	/** Rows rm. */
	static private int rm;
	/** Next item to go. */
	static private int N;
	/** Still PL or game over? */
	static private boolean PL;
	/** User pressed down arrow. */
	static private boolean fD;
	/** Starting level. */
	static private int sLv;

	/** Helps smooth animation of background. */
	static private int c;
	static private int sub;
	static private int bY;
	static private int bD;

	/** Maintaining constant Interrupts per second. */
	static private int iS;
	static private int iC;


	/** Random number generator. */
	static private Random r;

	/** FPS and IPS cs. */
	static private int fC;
	static private int sT;
	static private int fps;

	/** PlaySong */
	static private boolean pS;

	TFps() {
		super("4k-tris");

		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setSize(WINDOW_WIDTH, WINDOW_HEIGHT);

		sLv = 25;
		iS = sT = (int)System.currentTimeMillis();
		r = new Random(iS);
		restart();

		new Thread(this).start();
		
		new Timer(TIMER_DELAY, this).start();
		show();
	}
	public static void main(String[]args) {
		new TFps();
	}
}



