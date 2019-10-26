import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import javax.swing.JFrame;
import javax.swing.WindowConstants;

/**
 * @author John Greenhow
 */
public class D extends JFrame implements KeyListener {
	/** Has a key been hit?*/
	private boolean keyDown = false;
	/** the direction in which the line is currently moving.  modified when a key is pressed */
	private int dir;
	/** Chaos' little helper */
	private Random random = new Random();
	/** a list of stars */
	private List stars = new ArrayList();
	/** the one graphics context we'll be drawing to */
	private Graphics g;
	
	
	/**
	 * Private constructor - after all, who else will use it?
	 * Initialises the frame and starts the loop.
	 */
	private D() {
		// initialise the frame
		super("STAR DODGER 4K");
		setSize(640, 480);
		setVisible(true);
		setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);		
		// prepare the double-buffer
		g= getGraphics();
		g.setFont( new Font("sansserif", Font.BOLD, 18));		
		// initialise the level
		int level = 0;		
		// add a key listener - this means two empty methods below, but saves us an extra class file.
		addKeyListener(this);
		
		// START GAME LOOP
		while(true) {
			
			// TITLE SCREEN
			if(level == 0) {
				drawBorder();
				g.setColor(Color.white);
				g.drawString("STAR DODGER 4K", 240, 100); // 161
				g.drawString("You must get to the wonderous", 182, 140); // 275
				g.drawString("Next Screen Gap", 246, 160); // 148
				g.drawString("Space changes direction", 212, 180); // 215			
				g.drawString("Hit Enter to go", 255, 250);			// 130				
				while(keyDown == false);
				keyDown = false;
				level ++;
							
				
			// IN-GAME
			} else {
				//READY SCREEN
				initLevel( level);
				int alive = 0;
				int x = 30;
				int y = 250;
				dir = (random.nextInt(10) > 5) ? 1 : -1;
				long lastLoopTime = System.currentTimeMillis();
				
				// IN-GAME LOOP
				while(alive == 0) {
					x++;
					y += dir;					
					// have they hit anything? check upper, lower and right hand walls, then stars
					if(y < 50 || y>450 || (x > 600 && !(new Rectangle(600, 220, 50, 80).contains(x, y)))) alive = 1;
					if(x > 610) alive = 2;
					for(int i=0; i<stars.size(); i++) {
						int dx = x - ((Point)stars.get(i)).x;
						int dy = y - ((Point)stars.get(i)).y;
						int dist = (int)Math.sqrt((dx*dx) + (dy*dy));
						if(dist < 15) alive = 1;				
					}
					
					// add another pixel to the line
					g.drawRect(x, y, 1, 1);
					
					// give the user (and other processes) some time.
					try {
						if(lastLoopTime+5-System.currentTimeMillis() > 0) Thread.sleep( lastLoopTime+5-System.currentTimeMillis() );
					} catch(InterruptedException iex) {}
					lastLoopTime = System.currentTimeMillis();
				} // END IN-GAME LOOP
				
				// they made it across
				if(alive == 2) {
					level ++;
				}
				
				// they hit something
				else if(alive == 1) {
					// generate message
					String[] adj = new String[] { "felonius", "tiny", "sycophantic" };
					String[] noun = new String[] { "wombat", "weasel", "donut" };
					// draw screen
					level = 0;
					drawBorder();							
					g.setColor(Color.white);
					g.drawString("You failed!", 270, 100);  
					String insult = "You're clearly a " + adj[random.nextInt(3)] + " " + noun[random.nextInt(3)];
					g.drawString(insult, (640-g.getFontMetrics().stringWidth(insult))/2, 160);					
					//  wait for them to restart by hitting a key
					while(keyDown == false);
					keyDown = false;
				}
			}
		}
	}

	/** 
	 * Draws the ready screen and initialises the coming level.
	 * @param level
	 */
	private void initLevel( int level) {
		drawBorder();
		
		// instructions
		g.setColor(Color.white);
		g.drawString("Level " + level, 280, 100);
		g.drawString("Get Ready", 267, 160);		// 107
		g.drawString(" <ENTER>", 267, 190);		// 107
		
		// wait for input
		while(keyDown == false);
		keyDown = false;

		// draw the level
		drawBorder();
		
		g.setColor(Color.white);
		stars.clear();
		for(int i=0; i< level * 5; i++) {
			final int x = random.nextInt(480)+100;
			final int y = random.nextInt(370)+50;
			drawStar( x, y, 15);
			stars.add( new Point(x, y));
		}

		g.setColor(Color.black);
		g.fillRect(600, 220, 30, 80);
		g.setColor(Color.white);
	}
	
	/**
	 * Draws a star of radius r centered at cx,cy.
	 * @param cx
	 * @param cy
	 * @param r
	 */
	private void drawStar( int cx, int cy, int r) {
		for(int i=0; i<180; i+=30) {
			double rad = Math.toRadians(i);
			int x0 = cx - (int)(r * Math.cos( rad ));
			int y0 = cy - (int)(r * Math.sin( rad ));
			int x1 = cx + (int)(r * Math.cos(rad ));
			int y1 = cy + (int)(r * Math.sin( rad ));
			g.drawLine(x0, y0, x1, y1);
		}
	}
	
	/**
	 * Draws a little border round the screen to keep things in.
	 */
	private void drawBorder() {
		// draw border
		g.setColor(Color.black);
		g.fillRect(0,0, 640, 480);
		g.setColor(Color.white);
		g.fillRect(20, 40, 590, 420);	
		g.setColor(Color.black);
		g.fillRect(30,50, 570, 400);		

		// draw background stars
		g.setColor(Color.blue.darker());
		for(int i=0; i<50; i++) {
			drawStar( random.nextInt(550)+40, random.nextInt(380)+60, 3);
		}
	}


	
	
	/////////////////////////////////////////////////////////////////////////////
	//  Implementation of KeyListener
	/////////////////////////////////////////////////////////////////////////////
	
	/**
	 * @see java.awt.event.KeyListener#keyPressed(java.awt.event.KeyEvent)
	 */
	public final void keyPressed(KeyEvent e) {
		if (e.getKeyCode() == KeyEvent.VK_ESCAPE) 
		{
			System.exit(0);
		}
	
		if (e.getKeyCode() == KeyEvent.VK_ENTER)
		{
			keyDown = true;
		}
	}
	
	/**
	 * @see java.awt.event.KeyListener#keyReleased(java.awt.event.KeyEvent)
	 */
	public final void keyReleased(KeyEvent e) {
		if (e.getKeyCode() == KeyEvent.VK_ENTER)
		{
			keyDown = false;
		}
	}
	
	/**
	 * @see java.awt.event.KeyListener#keyTyped(java.awt.event.KeyEvent)
	 */
	public final void keyTyped(KeyEvent e) {	
		if (e.getKeyChar() == ' ')
		{
			dir = -dir;
		}
	}
	
	
	/////////////////////////////////////////////////////////////////////////////
	//  Static methods
	/////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Code entry point.  Instantiates a new frame.
	 * @param args
	 */
	public static void main(String[] args) {
		new D();
	}
}
