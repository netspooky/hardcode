import javax.swing.*;
import javax.imageio.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;
import java.awt.geom.*;
import java.io.*;
import java.util.*;
public class A extends JFrame {
	public static JPanel p = new JPanel();
	protected static boolean keys[] = new boolean[256];
	public A() {
		super("Goomba4K");
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setResizable(false);
		p.setPreferredSize(new Dimension(640,480));
		getContentPane().add(p,BorderLayout.CENTER);
		enableEvents(AWTEvent.KEY_EVENT_MASK);
		//Dimension d = getToolkit().getScreenSize();
		pack();
		setLocation(100,100);
		//setLocation((getWidth()>>1)-(d.width>>1),(getHeight()>>1)-(d.height>>1));
		show();
	}
	public void processKeyEvent(KeyEvent e) {
		if (e.getID() == KeyEvent.KEY_PRESSED) keys[e.getKeyCode()&0xff] = true;
		else if (e.getID() == KeyEvent.KEY_RELEASED) keys[e.getKeyCode()&0xff] = false;
	}
	public static void main(String args[]) {
		A a = new A();
		Arrays.fill(keys,false);
		int w = a.p.getWidth();
		int h = a.p.getHeight();
		int state = 0; // game state. 0 = title; 1 = level start; 2 = playing
		int score = 0;
		int num = 0; // max number of goombas on field at once
		float actor[][] = null;
		int p[][] = null; // particles for goomba guts
		Rectangle bullet[][] = null; // bullet bill!
		int j,n;
		final Random rand = new Random();
		Rectangle r[] = null; // collision rectangles; r[0] = mario
		Image buffer = a.createImage(w,h);
		Color bg,done = new Color(175,231,255);
		/* load images */
		BufferedImage b[] = new BufferedImage[7];
		try {
			// frame info:
			// b[0] = mario facing right
			// b[1] = mario facing left
			// b[2] = goomba facing right
			// b[3] = goomba facing left
			// b[4] = bullet bill facing right
			// b[5] = bullet bill facing left
			// b[6] = ground
			BufferedImage sprite = new BufferedImage(128,32,BufferedImage.TYPE_INT_ARGB);
			sprite.createGraphics().drawImage(ImageIO.read(a.getClass().getResource("a.png")),0,0,128,32,null);
			Graphics2D g;
			for (j = 0;j < 6;j+=2) {
				//b[j] = sprite.getSubimage(Math.max(0,j-1)*32,0,32,32);
				b[j] = sprite.getSubimage(Math.max(0,j/2)*32,0,32,32);
				b[j+1] = new BufferedImage(32,32,BufferedImage.TYPE_INT_ARGB);
				g = b[j+1].createGraphics();
				g.scale(-1,1);
				g.translate(-32,0);
				g.drawImage(b[j],0,0,null);
			}
			b[6] = new BufferedImage(w,32,BufferedImage.TYPE_INT_RGB);
			b[6].createGraphics().drawImage(sprite.getSubimage(96,0,32,32),0,0,null);
		}
		catch (IOException e) {}
		// setup some clouds
		int c[][] = new int[5][4];
		for (j = 0;j < c.length;j++) {
			// all clouds are 25px tall
			c[j][0] = rand.nextInt(w); // x
			c[j][1] = rand.nextInt(75); // y
			c[j][2] = 50+rand.nextInt(50); // width
			c[j][3] = -1-rand.nextInt(2); // xvel
		}
		/* game loop */
		long lastFrame=System.currentTimeMillis();
		float yield=10000f;
		float frameAverage=16f;
		int frame = 0;
		while (!keys[KeyEvent.VK_ESCAPE&0xff]) {
			frame++;
			/* update */
			// clouds are updated no matter what the game state is
			for (j = 0;j < c.length;j++) {
				c[j][0]+=c[j][3];
				if (c[j][0] < -c[j][2]) { // cloud went off screen
					c[j][0] = w;
					c[j][1] = rand.nextInt(75); // y
					c[j][2] = 50+rand.nextInt(50); // width
					c[j][3] = -1-rand.nextInt(2); // xvel
				}
			}
			if (state == 0 && keys[KeyEvent.VK_SPACE&0xff]) {
				state++;
				score = 0;
				/* mario/goomba setup (actor[0] = mario) */
				p = new int[100][5];
				for (j = 0;j < p.length;j++) {
					// p[j][0] = x
					// p[j][1] = y
					// p[j][2] = xvel
					// p[j][3] = yvel
					// p[j][4] = life
					p[j][4] = 0;
				}
				actor = new float[16][3];
				r = new Rectangle[actor.length];
				num = actor.length;
				for (j = 0;j < actor.length;j++) {
					r[j] = new Rectangle(rand.nextInt(w-32),-32-rand.nextInt(50),32,32);
					actor[j][0] = 0;
					while (actor[j][0] == 0) actor[j][0] = -4+rand.nextInt(8); // x velocity
					actor[j][1] = -rand.nextInt(15); // y velocity
					actor[j][2] = 2.0f+rand.nextInt(1); // frame in image array
				}
				// setup mario
				r[0] = new Rectangle(w>>1,h>>1,32,32);
				actor[0][0] = 0;
				actor[0][1] = -10;
				actor[0][2] = rand.nextInt(1);
				// setup bullet bills
				bullet = new Rectangle[2][1];
				for (j = 0;j < bullet.length;j++) {
					for (n = 0;n < bullet[j].length;n++) {
						bullet[j][n] = new Rectangle(0,0,32,32);
						if (j == 0) bullet[j][n].x = -w-rand.nextInt(w<<1);
						else bullet[j][n].x = w+rand.nextInt(w<<1);
						bullet[j][n].y = h-(h>>2);
					}
				}
			}
			else if (state == 1) {
				boolean ready = true;
				for (j = 1;j < actor.length;j++) {
					if (r[j].y < h-64) {
						ready = false;
						break;
					}
				}
				if (ready) state++;
			}
			if (state > 0) {
				for (j = (state > 1?0:1);j < num;j++) {
					if (j == 0) { // mario movements
						if (keys[KeyEvent.VK_LEFT&0xff]) {
							actor[j][2] = 1;
							actor[j][0] = Math.max(-5.0f,actor[j][0]-.25f);
						}
						else if (keys[KeyEvent.VK_RIGHT&0xff]) {
							actor[0][2] = 0;
							actor[j][0] = Math.min(5.0f,actor[j][0]+.25f);
						}
						else {
							if (actor[j][0] < 0) actor[j][0] = Math.min(actor[j][0]+.125f,0);
							else if (actor[j][0] > 0) actor[j][0] = Math.max(actor[j][0]-.125f,0);
						}
					}
					// if hit left wall and moving left
					if (r[j].x <= 0 && actor[j][0] < 0.0f) {
						r[j].x = 0; // keep inside window
						actor[j][0]*=-1; // turn around
					}
					// if hit right wall and moving right
					else if (r[j].x >= w-32 && actor[j][0] > 0.0f) {
						r[j].x = w-32; // keep inside window
						actor[j][0]*=-1; // turn around
					}
					r[j].x+=(int)actor[j][0];
					// gravity now pulls
					actor[j][1]+=0.25f;
					r[j].y+=(int)actor[j][1];
					// bounce on top of ground
					if (r[j].y > h-64) {
						r[j].y = h-64;
						if (j > 0) actor[j][1]*=-.5; // negative half velocity
						else state = 0;
					}
					if (frame == 20 && j > 0) actor[j][2] = ((int)actor[j][2] == 2?3:2);
				}
				// update particles
				for (j = 0;j < p.length;j++) {
					if (p[j][4] > 0) {
						p[j][0]+=p[j][2];
						p[j][1]+=p[j][3];
						p[j][4]--;
					}
				}
				// update bullet bills
				if (score >= 10) for (j = 0;j < bullet.length;j++) {
					for (n = 0;n < bullet[j].length;n++) {
						if (j == 0) bullet[j][n].x+=2;
						else bullet[j][n].x-=2;
						if (j == 0 && bullet[j][n].x > w+32) {
							bullet[j][n].x = -w-rand.nextInt(w<<1);
							bullet[j][n].y = h-(h>>2);
						}
						else if (j > 0 && bullet[j][n].x < -32) {
							bullet[j][n].x = w+rand.nextInt(w<<1);
							bullet[j][n].y = h-(h>>2);
						}
					}
				}			
				// collision detection
				if (state > 1) {
					// first check for collision with goomba
					for (j = 1;j < num;j++) {
						if (r[0].intersects(r[j])) { // collision!
							if (r[j].y-r[0].y >= 16) { // mario was on top?
								if (r[j].y >= 480-64) r[0].y = r[j].y-65; // make them level
								// spill some goomba guts onto the screen
								for (n = 0;n < 50;n++) {
									int z = rand.nextInt(p.length-1);
									p[z][0] = r[j].x+16;
									p[z][1] = r[j].y+16;
									p[z][2] = -25+rand.nextInt(50);
									p[z][3] = -10+rand.nextInt(20);
									p[z][4] = 25+rand.nextInt(25);
								}
								// reset dead goomba
								r[j] = new Rectangle(rand.nextInt(w-32),-32-rand.nextInt(25),32,32);
								actor[j][0] = 0;
								while (actor[j][0] == 0) actor[j][0] = -4+rand.nextInt(8); // x velocity
								actor[j][1] = -rand.nextInt(5); // y velocity
								actor[j][2] = 2.0f+rand.nextInt(1); // frame in image array
								// mario bounces
								actor[0][1] = -10;
								score++;
								// time to increase difficulty?
								if (score%5 == 0) {
									num = Math.max(6,num-1); // remove a goomba
								}
								break; // only one collision per frame
							}
							else { // mario wasn't on top, he dies
								//state = 0;
							}
						}
					}
					// now check for collision with bullet bill
					for (j = 0;j < bullet.length;j++) {
						for (n = 0;n < bullet[j].length;n++) {
							if (r[0].intersects(bullet[j][n])) { // collision!
								state = 0; // mario dies
							}
						}
					}
				}
			}
			if (frame == 20) frame = 0;
			/* render */
			Graphics2D g = (Graphics2D)buffer.getGraphics();
			//g.setColor(Color.black);
			//g.fillRect(0,0,w,h);
			bg = new Color(80,136,160);
			g.setColor(bg);
			g.fillRect(0,0,w,50);
			int y;
			for (y = 50;!bg.equals(done) || y < h;y+=4) {
				bg = new Color(Math.min(175,bg.getRed()+2),Math.min(231,bg.getGreen()+2),Math.min(255,bg.getBlue()+2));
				g.setColor(bg);
				g.fillRect(0,y,w,4);
			}
			g.setColor(done);
			g.fillRect(0,y,w,h-y);
			for (j = 0;j <= w;j+=32) g.drawImage(b[6],j,h-32,null); // ground
			// draw the clouds
			for (j = 0;j < c.length;j++) {
				g.setColor(Color.white);
				g.fillOval(c[j][0],c[j][1],c[j][2],25);
			}
			if (state > 0) {
				for (j = (state > 1?0:1);j < num;j++) {
					g.drawImage(b[(int)actor[j][2]],r[j].x,r[j].y,null);
				}
				// render any goomba guts
				g.setColor(new Color(0xA67C51)); // brown
				for (j = 0;j < p.length;j++) {
					if (p[j][4] > 0) {
						g.fillRect(p[j][0],p[j][1],5,5);
					}
				}
				// render bullet bills
				for (j = 0;j < bullet.length;j++) {
					for (n = 0;n < bullet[j].length;n++) {
						g.drawImage(b[(j == 0?4:5)],bullet[j][n].x,bullet[j][n].y,null);
					}
				}
			}
			g.setColor(Color.white);
			g.drawString("Score: "+score,10,10);
			if (state < 2) {
				g.setFont(new Font("SansSerif",Font.BOLD,20));
				FontMetrics fm = g.getFontMetrics();
				String s = (state == 0?"Score: "+score+" (press space)":"Get Ready!");
				g.drawString(s,(w>>1)-(fm.stringWidth(s)>>1),(h>>1)-(fm.getHeight()>>1));
			}
			a.p.getGraphics().drawImage(buffer,0,0,null);
			/* timing code */
			long timeNow = System.currentTimeMillis();
			//rolling average for the last 10 time inputs
			frameAverage = (frameAverage * 10 + (timeNow - lastFrame)) / 11;
			lastFrame=timeNow;
			//16f = for 16msec
			//0.1f = damping value
			//and that +0.05f bit is for ensuring that it can grow faster after it ran flat out for a while
			yield+=yield*((16f/frameAverage)-1)*0.1f+0.05f;
			for(j = 0;j < yield ;j++) Thread.yield();
		}
		System.exit(0);
	}
}