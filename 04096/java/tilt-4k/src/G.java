/*
 * Code Copyright 2005 - Kevin Glass
 * 
 * Code is provided as is for education and ammusement purposes. It should not be 
 * posted publically or used in any other way without permission.
 * 
 * tilt4k@cokeandcode.com
 */

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Polygon;
import java.awt.RenderingHints;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.geom.Line2D;
import java.awt.image.BufferStrategy;
import java.awt.image.BufferedImage;
import java.io.InputStream;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

/**
 * The game class of Tilt4K, my entry into the Java 4K contest (which I urge you all to enter!). 
 * More as a reminder to me, What I have learnt about keeping under 4k:
 * <p>
 * Use KZIP/7ZIP not just jar or winzip.
 * Use an obsfucator (http://proguard.sourceforge.org);
 * Make small changes, then check your class size. Its surprising what has a big effect.
 * Keep messages short and simple.
 * Use int's where possible. 
 * Keep everything that can be private, private.
 * Try to keep the import list down (worth going through now and again to check it out)
 * Class scope variable names can make a difference (try it out)
 * Always compile with no debugging information
 * Keep the number of zip entries small (condense data files into one file)
 * Be wary of the ? : operator. Its not always smaller.
 * Don't second guess the compiler. CHECK!
 * 
 * @author Kevin Glass
 */
public class G extends JFrame implements KeyListener
{
	/**
	 * Game entry point
	 * 
	 * @param argv The arguments passed in to the program
	 */
	public static void main(String argv[])
	{
		// this gives us better performance on windows meaning I can just draw the 
		// polygons brute force (note you can set it to anything, as long as its set)
		System.setProperty("sun.java2d.noddraw","");
		new G();
	}

	/** The keyboard control states */
	private boolean[] ctl = new boolean[6];
	/** The keyboard control codes */
	private int[] ky = new int[] {KeyEvent.VK_LEFT,KeyEvent.VK_RIGHT,KeyEvent.VK_UP,KeyEvent.VK_DOWN,KeyEvent.VK_SPACE,KeyEvent.VK_ESCAPE};
	
	/** The current shear on the y axis (for the pseudo 3D) */
	private float ys;
	/** The current shear on the x axis (for the pseudo 3D) */
	private float xs;
	/** The ball's x position in terms of grid cells */
	private float bx;
	/** The ball's y position in terms of grid cells */
	private float by;
	/** The ball's x velocity */
	private float vx;
	/** The ball's y velocity */
	private float vy;
	
	/** True if the level has started, i.e. the ball can roll */
	private boolean sted = false; 
	/** Not-Floors, true if there is no floor present, this saved me at one point initialising this array */
	private boolean[][] nFlr = new boolean[12][12];
	/** True if the square has the top wall present */
	private boolean[][] top = new boolean[12][12];
	/** True if the square has the left wall present */
	private boolean[][] left = new boolean[12][12];
	/** True if there is a conunter of the square */
	private boolean[][] cnt = new boolean[12][12];
	/** The best times for each level */
	private int[] b = new int[20];
	
	/** The X position of the end square */
	private int eX; 
	/** The Y position of the end square */
	private int eY;
	
	/** The amount of time left */
	private int t; 
	/** True if the player is current dead */
	private boolean dead = false;
	/** The reason that the played died */
	private String msg; 
	/** The amount of time left until the game restarts */
	private int res;
	
	/** True if we just completed a level */
	private boolean cmp; 
	/** The current level number */
	private int l; 
	/** True if we're in easy mode */
	private boolean esy = false; 
	/** The total time allows for the current level */
	private int tot;
	/** The number of counters left on the board */
	private int cL = 0;
	/** The number of lifes left */
	private int v = 0;
	/** True if we should antialias the graphics */
	private boolean al = false;
	
	private G()
	{
		super("T4k");
		
		// icon creation and setting
		BufferedImage temp = new BufferedImage(16,16,BufferedImage.TYPE_INT_ARGB);
		Graphics2D g = (Graphics2D) temp.getGraphics();
		g.setColor(Color.black);
		g.fillRect(4,4,8,8);
		setIconImage(temp);
		
		// normal setup for a frame accept using show which saves a call to pack()
		// and setVisible(true);
		setSize(640,510);
		setResizable(false);
		show();
		
		addKeyListener(this);
		
		requestFocus();
		createBufferStrategy(2);
		BufferStrategy strategy = getBufferStrategy();
			
		init();
		
		long lastLoopTime = System.currentTimeMillis();
		
		while (true)
		{
			logic((int) (System.currentTimeMillis() - lastLoopTime));
			lastLoopTime = System.currentTimeMillis();
			draw((Graphics2D) strategy.getDrawGraphics());
			
			strategy.show();
			if (!isVisible()) {
				System.exit(0);
			}
		}
	}
	
	/**
	 * Initialise the board for the next level
	 */
	private void init()
	{
		// if we didn't complete the level take a life away
		// if we have no lifes and we're not in easy mode
		// restart the game at level 1
		if (!cmp)
		{
			v--;
			if (!esy && (v < 0)) {
				l = 1;
			}
		}
		
		// if we completed the level move on one
		//l = cmp ? l+1 : ((esy || (v >= 0)) ? l : 1);
		if (cmp) {
			l++;
		}
		
		cmp = false;
		// if we've just run out of lives reset it to 3
		if (v < 0) {
			v = 3;
		}
		
		// load the level here
		try {
			InputStream rin = Thread.currentThread().getContextClassLoader().getResourceAsStream("d");
			
			// if we've got no more levels in the data file then the player
			// has completed all levels - show a well done message.
			if (rin.available() < l*71) {
				JOptionPane.showMessageDialog(this,"Complete!");
				l = 1;
			}
			
			// skip the previous levels
			rin.skip((l-1) * 71);
			
			// read in the data. See the LevelDesigner.java for file format
			tot = t = (rin.read() * 1000);
			bx = rin.read() + 0.5f;
			by = rin.read() + 0.5f;
			
			eX = rin.read();
			eY = rin.read();
		
			cL = 0;
			
			for (int x=0;x<11;x++) 
			{
				for (int y=0;y<11;y++)
				{
					int value = rin.read();
					
					nFlr[x][y] = (value & 1) != 0;
					top[x][y] = (value & 2) != 0;
					left[x][y] = (value & 4) != 0;
					cnt[x][y] = (value & 8) != 0;
					//cL += cnt[x][y] ? 1 : 0;
					
					// if theres a counter increment our counter's left indicator
					if (cnt[x][y]) {
						cL++;
					}
					
					y++;
				
					nFlr[x][y] = (value & 16) != 0;
					top[x][y] = (value & 32) != 0;
					left[x][y] = (value & 64) != 0;
					cnt[x][y] = (value & 128) != 0;
					//cL += cnt[x][y] ? 1 : 0;
					// if theres a counter increment our counter's left indicator
					if (cnt[x][y]) {
						cL++;
					}
				}
			}
			
		// Note catching exception rather than anything explicit. Saves an import
		} catch (Exception e) {
			// not going to do anything cause I assuming this ain't going to happen! 
		}

		// reset the system state
		vx = 0;
		vy = 0;
		dead = false;
		msg = "";
		
		sted = false;
	}
		
	/**
	 * Add a specified location to a polygon by first passing it through
	 * our pseduo 3D convertor.
	 * 
	 * @param x The x position on the board
	 * @param y The y position on the board
	 * @param p The polygon to add to
	 */
	private void add(float x,float y,Polygon p)
	{
		Point t = get(x,y);
		p.addPoint(t.x,t.y);
	}

	/**
	 * Convert a coordinate from board position to screen position, account for the
	 * pseudo 3D shearing effect.
	 * 
	 * @param x The x position on the board
	 * @param y The y position on the board
	 * @return The Point on the screen at which the board position should be drawn
	 */
	private Point get(float x,float y)
	{
		return new Point((int) (220+(((x-5)*(35-((y-5)*ys))))),
						 (int) (220+(((y-5)*(35-((x-5)*xs))))));
	}
	
	/**
	 * End the level, used to be called die(). However, its also called when
	 * the level is completed successfully.
	 * 
	 * @param r The explanation of death.
	 */
	private void d(String r)
	{
		msg = r;
		dead = true;
		res = 2000;
	}
			
	/**
	 * Game logic.
	 * 
	 * @param delta The amount of time passed since last we were called.
	 */
	private void logic(int delta)
	{
		// if escape is pressed end the application
		if (ctl[5]) {
			System.exit(0);
		}
		
		// if space is pressed and we're waiting to start the game, start it
		if ((ctl[4]) && (!sted)) {
			sted = true;
		}
		
		// if we're dead then decrent the restart timer. Once its run out 
		// reset the level.
		if (dead)
		{
			res -= delta;
			if (res < 0) {
				init();
			}
		}
		
		xs = 0;
		ys = 0;
		
		// if the game has started and we're not dead then run the main game logic 		
		if ((sted) && (!dead))
		{						
			// decrement the timer, if we've run out => die
			t -= delta;
			if (t <= 1000)
			{
				d("Time Out");
			}
			
			// caculate the xshear and yshear based on the start of the cursor 
			// keys
			xs = (ctl[0] ? -0.3f : 0) + (ctl[1] ? 0.3f : 0);
			ys = (ctl[2] ? -0.3f : 0) + (ctl[3] ? 0.3f : 0);
						
			final float deltaF = ((float) delta) / 1000.0f;
			
			// adjust the velocity of the ball based on the x and y shear
			vx += xs * deltaF * 10;
			vy += ys * deltaF * 10;
			
			// calcualte the new ball positions and store then locally while
			// validating them against collisions			
			float nbx = bx + (vx * deltaF);
			float nby = by + (vy * deltaF);
			
			final int BX = (int) bx;
			final int BY = (int) by;
			
			// if they're a counter on the current square, remove it and decrement
			// the counter indicator
			if (cnt[BX][BY]) 
			{
				cL--;
				cnt[BX][BY] = false;
			}
		
			// if we're on the end square and we've got all the counters then 
			// complete the level
			if ((BX == eX) && (BY == eY) && (cL <= 0))
			{
				cmp = true;
				d("Done!");
				
				// update best time for level 
				int o = ((tot - t) / 1000) + 1;
				if ((b[l] == 0) || (b[l] > o)) {
					b[l] = o;
				}
				//b[l] = (b[l] == 0) ? ((1000 + tot - t) / 1000) : Math.min((1000 + tot-t) / 1000,b[l]);
			}
			
			// if we've gone off the edge of the ball => die
			if ((bx < 0) || (by < 0) || (BX > 9) || (BY > 9)) {
				d("Fell!");
			}
			
			if (!dead)
			{
				final float edge = 0.3f;
				
				// if there's no floor on the current square => die
				if (nFlr[BX][BY]) 
				{
					d("Fell!");
				}
				
				// check the local area to the new ball position for walls
				// if any are present intersecting with the ball then 
				// invalidate the new position and reset back to the old position
				for (int x=BX-1;x<BX+2;x++) {
					for (int y=BY-1;y<BY+2;y++) {
						if ((x < 0) || (y < 0)) {
							continue;
						}
						
						if (left[x][y]) {
							Line2D temp = new Line2D.Double(x,y,x,y+1);
							
							if (temp.ptSegDist(nbx,nby) < edge) {
								if (BY != y)
								{
									nby = by;
									vy = (-vy / 10);
								}
								nbx = bx;
								vx = (-vx / 10);								
							}
						}
						if (top[x][y]) {
							Line2D temp = new Line2D.Double(x,y,x+1,y);
							
							if (temp.ptSegDist(nbx,nby) < edge) {
								if (BX != x)
								{
									nbx = bx;
									vx = (-vx / 10);
								}
								nby = by;
								vy = (-vy / 10);								
							}
						}
					}
				}	
			}
			
			bx = nbx;
			by = nby;			
		}
	}
	
	/**
	 * Draw the game screen
	 * 
	 * @param g The graphics context on which to draw the game
	 */
	private void draw(Graphics2D g)
	{		
		// clear the background
		g.setColor(Color.black);
		g.fillRect(0,0,640,510);
		
		g.translate(0,30);		
		g.setColor(Color.white);
		
		// if the game hasn't started show the instructions
		if (!sted)
		{
			g.drawString("SPACE TO START",480,450);
			g.drawString("Cursors Tilt",200,450);
		}		
		
		g.drawString(msg,200,450);
		g.drawString("TIME",520,150);
		g.drawString("BEST",520,230);
		g.drawString("LIVES",515,310);
		
		g.drawString("LEVEL "+l+(esy ? "E" : ""),200,30);
		g.drawString("By KevGlass",520,80);
		
		g.setColor(Color.blue);
		g.setFont(g.getFont().deriveFont(3, 40.0f));
		g.drawString("TILT-4K",450,60);
		g.drawString(""+v,520,360);
		g.setColor(Color.red);

		// draw the time and the best time making sure they're always 2 digits
		g.drawString((b[l] < 10 ? "0" : "")+b[l],510,280);
		g.drawString((t < 10000 ? "0" : "")+(t / 1000),510,200);
	
		if (al) {
			g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);
		}
		
		// cycle through the map drawing each square.  
		for (int x=0;x<11;x++)
		{
			for (int y=0;y<11;y++)
			{
				// floor
				final Polygon p = new Polygon();
		
				add(x,y,p);
				add(x+1,y,p);
				add(x+1,y+1,p);
				add(x,y+1,p);										
				
				final Point c = get(x+0.5f,y+0.5f);
				
				if (!nFlr[x][y] && (y < 10) && (x < 10))
				{
					g.setColor(Color.red);
					g.fill(p);
				}
									
				// draw the walls in white if they're present, otherwise black
				g.setColor(top[x][y] ? Color.white : Color.black);
				g.drawLine(p.xpoints[0],p.ypoints[0],p.xpoints[1],p.ypoints[1]);
				g.setColor(left[x][y] ? Color.white : Color.black);
				g.drawLine(p.xpoints[0],p.ypoints[0],p.xpoints[3],p.ypoints[3]);
				
				// if we're on the end square and we've got all the counters,
				// or we're on a counter then draw an circle on the square
				if (((eX == x) && (eY == y) && (cL <= 0)) || (cnt[x][y]))
				{
					g.setColor(cnt[x][y] ? Color.yellow : Color.black);
					g.fillOval(c.x-6,c.y-6,15,15);			
					if (cnt[x][y]) {
						g.setColor(Color.black);
						g.drawOval(c.x-6,c.y-6,15,15);			
					}
				}
			}
		}
		
		// draw ball
		int rad = 20;
		
		if (dead) {
			rad = (int) (2000 / (2100.0f - res));
		}
		
		int rad2 = rad/2;
		
		g.setColor(Color.darkGray);
		Point p = get(bx,by);
		g.fillOval(p.x-(rad2),p.y-(rad2),rad,rad);
		g.setColor(Color.black);
		rad -= 2;
		g.drawOval(p.x-(rad2)+1,p.y-(rad2)+1,rad,rad);
	
		// don't draw the shine of the ball if we're dead
		if (!dead)
		{		
			p.x += ((5.0f - bx) / 2.0f);
			p.y += ((5.0f - by) / 2.0f);
			g.setColor(Color.gray);
			g.fillOval(p.x-3,p.y-3,6,6);
			g.setColor(Color.white);
			g.fillOval(p.x-1,p.y-1,2,2);
		}
		
		g.dispose();
	}

	/**
	 * @see java.awt.KeyListener
	 */
	public void keyPressed(KeyEvent e) {
		// cycle the controls update control states
		for (int i=0;i<6;i++)
		{
			if (e.getKeyCode() == ky[i])  {
				ctl[i] = true;
			}
		}
	}
	
	/**
	 * @see java.awt.KeyListener
	 */
	public void keyReleased(KeyEvent e) {
		// cycle the controls update control states
		for (int i=0;i<6;i++)
		{
			if (e.getKeyCode() == ky[i]) {
				ctl[i] = false;
			}
		}
	}

	/**
	 * @see java.awt.KeyListener
	 */
	public void keyTyped(KeyEvent e) {
		// if the player pressed 'e' then toggle easy mode
		if (e.getKeyChar() == (char) 101)
		{
			esy = !esy;
		}
		if (e.getKeyChar() == (char) 97)
		{
			al = !al;
		}
	}

}