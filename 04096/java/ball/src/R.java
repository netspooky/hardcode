/*
 * Code Copyright 2005 - Kevin Glass
 * 
 * Code is provided as is for education and ammusement purposes. It should not be 
 * posted publically or used in any other way without permission.
 * 
 * tilt4k@cokeandcode.com
 */

import java.awt.Color;
import java.awt.Font;
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.Polygon;
import java.awt.event.KeyEvent;
import java.awt.image.BufferStrategy;

import javax.swing.JFrame;

/**
 * @author Kevin Glass
 */
public class R extends JFrame
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
		new R();
	}

	//private static final int LEVELS = 2;
	//private static final byte TILE = 1;
	//private static final byte WEAR_OUT = 2;
	//private static final byte START = 3;
	//private static final byte FLASH = 11;
	//private static final byte TRANSPORT = 12;
	//private static final byte EXIT = 13;
	//private static final byte TOGGLE_OFF = 14;
	//private static final byte TOGGLE_ON = 15;
	
	private boolean[] controls = new boolean[20];
	// UPDATE LEVELS HERE
	private byte[] board = new byte[5*450];
	
	private double xp;
	private double yp;
	private double zp;
	private double ang;
	private double vx;
	private double vy;
	private double vz;
	private double dx;
	private double dy;
	private int l = 0;
	private int[] timers = new int[12];
	private boolean started;
	private String msg;
	private boolean complete;
	private int toggles;
	private int lastX;
	private int lastY;
	private boolean transport;
	private int[][] ports = new int[100][2];
	
	private R()
	{
		super("Ball");
		
		// normal setup for a frame accept using show which saves a call to pack()
		// and setVisible(true);
		setSize(640,510);
		setResizable(false);
		show();
		
		// icon creation and setting
		setIconImage(createImage(16,16));

		enableEvents(56);
		
		createBufferStrategy(2);
		BufferStrategy strategy = getBufferStrategy();
			
		init();
		
		long lastLoopTime = 0;
		
		while (true)
		{
			int delta = (int) (System.currentTimeMillis() - lastLoopTime);
			for (int i=0;i<delta/10;i++) {
				logic(10);
			}
			logic(delta % 10);
			
			lastLoopTime = System.currentTimeMillis();
			
			draw((Graphics2D) strategy.getDrawGraphics());
			
			strategy.show();
			if (!isVisible()) {
				System.exit(0);
			}
		}
	}
	
	public int getTile(int x,int y) {
		int index = (l*450)+(y*15)+(x/2);
		byte type = board[index];
		//if (x % 2 == 1) {
			type = (byte) (type >> ((x % 2)*4));
		//}
		type &= 0x0F;
		
		return type;
	}
	
	/**
	 * Initialise the board for the next level
	 */
	private void init()
	{
		try {
			Thread.currentThread().getContextClassLoader().getResourceAsStream("d").read(board);
		} catch (Exception e) {
			e.printStackTrace();
		}
		zp = 0;
		xp = 0.5f;
		yp = 0.5f;
		vx = 0;
		vy = 0;
		started = false;
		msg = "PRESS ENTER";
		int[] levelTimes = {80,80,99,99,99};
		timers[0] = levelTimes[l]*1000;
		toggles = 0;
		
		if (complete) {
			l++;
			// LEVELS
			if (l >= 5) {
				l = 0;
			}
		}
		
		//ports.clear();
		ports[99][0] = 0;
		for (int x=0;x<30;x++) {
			for (int y=0;y<30;y++) {
				int tile = getTile(x,y);
				
				if (tile == 3) {
					xp = x+0.5;
					yp = y+0.5;
				}
				if (tile == 14) {
					toggles++;
				}
				if (tile == 12) {
					ports[ports[99][0]][0] = x;
					ports[ports[99][0]][1] = y;
					ports[99][0]++;
				}
			}
		}
		
		complete = false;
	}
	
	/**
	 * Game logic.
	 * 
	 * @param delta The amount of time passed since last we were called.
	 */
	private void logic(int delta)
	{		
		if (!started) {
			return;
		}
		
		if (timers[11] > 0) {
			timers[11] -= delta;
			if (timers[0] > 0) {
				if (complete) {
					msg = "Level Complete!";
					zp += delta;
				} else {
					msg = "Try Again";
					zp -= delta;
				}
			}
			
			if (timers[11] <= 0) {
				init();
			}
			return;
		}
		
		timers[0] -= delta;
		timers[1] -= delta;
		timers[2] += delta;
		
		controls[19] = ((timers[2] / 1500) % 2) == 0;
		
		if (timers[0] <= 0) {
			timers[0] = 0;
			msg = "Time Out";
			timers[11] = 2000;
			return;
		}
		
		if (controls[5]) {
			ang -= 0.005 * delta;
		}
		if (controls[6]) {
			ang += 0.005 * delta;
		}

		// block rotate
		if (controls[7]) {
			if (controls[18] == false) {
				controls[18] = true;
				ang = (timers[8]-- % 4) * (Math.PI/2);
			}
		} else {
			controls[18] = false;
		}
		
		dx = Math.sin(ang);
		dy = Math.cos(ang);
		
		if (controls[1]) {
			vx += (dy * delta * 0.00001);
			vy -= (dx * delta * 0.00001);
		}
		if (controls[0]) {
			vx -= (dy * delta * 0.00001);
			vy += (dx * delta * 0.00001);
		}
		if (controls[2]) {
			vx += (dx * delta * 0.00001);
			vy += (dy * delta * 0.00001);
		}
		if (controls[3]) {
			vx -= (dx * delta * 0.00001);
			vy -= (dy * delta * 0.00001);
		}
		
		if (vx > 0.008) {
			vx = 0.008;
		}
		if (vx < -0.008) {
			vx = -0.008;
		}
		if (vy > 0.008) {
			vy = 0.008;
		}
		if (vy < -0.008) {
			vy = -0.008;
		}
		
		if (zp > 0) {
			vz -= 0.0098 * delta * 0.5;
		} else {
			vz = 0;
			zp = 0;
		}
		
		if (controls[4] && (timers[1] <= 0)) {
			vz = 1;
			timers[1] = 500;
		}
		
		// friction
		vx *= 0.997;
		vy *= 0.997;
		
		xp += (vx * delta);
		yp += (vy * delta);
		zp += (vz * delta);
		
		if ((lastX != (int) xp) || (lastY != (int) yp)) {
			if (getTile(lastX,lastY) == 2) {
				setTile(lastX,lastY,(byte) 0);
			}
			
			lastX = (int) xp;
			lastY = (int) yp;
		}
		
		if ((xp < 0) || (yp < 0) || (xp >= 30) || (yp >= 30)) {
			timers[11] = 2000;
			return;
		}

		int tile = getTile(lastX,lastY);
		
		if ((tile == 11) && (!controls[19])) {
			tile = 0;
		}
		if ((tile == 0) && (zp == 0)) {
			timers[11] = 2000;
			return;
		}
		
		if ((tile == 13) && (toggles <= 0)) {
			complete = true;
			timers[11] = 2000;
			return;
		}
		if (tile == 14) {
			setTile(lastX,lastY,(byte) 15);
			toggles--;
		}
		
		if (tile == 12) {
			if ((!transport) && (zp == 0)) {
				transport = true;
				
				int target = (int) (Math.random()*(ports[99][0]-1));
				if ((ports[target][0] == lastX) && (ports[target][1] == lastY)) {
					target++;				
				}
				
				xp = ports[target][0]+0.5;
				yp = ports[target][1]+0.5;
				vx = 0;
				vy = 0;
			}
		} else {
			transport = false;
		}
	}

	public void setTile(int x,int y,byte value) {
		int index = (l*450)+(y*15)+(x/2);
		byte type = board[index];
		
		if (x % 2 == 1) {
			value <<= 4;
			type &= 0x0F;
		} else {
			type &= 0xF0;			
		}

		type |= value;

		board[index] = type;
	}
	
	private int addPoint(double x,double y,Polygon p) {
		int pt[] = getPoint(x,y);

		if (pt[0]< -100) {
			return 0;
		}
		if (pt[1] > 600) {
			return 0;
		}
		
		p.addPoint(pt[0],pt[1]);
		return 1;
	}
	
	private int[] getPoint(double x,double y) {
		double px = x - xp;
		double py = y - yp;		
		double c = Math.cos(ang);
		double s = Math.sin(ang);
		
		double nx = (px * c) + (py * -s);
		double ny = (px * s) + (py * c);
		
		ny += 5;
		
		nx = (500 * (nx / (ny+10)) * 1.5) + 320;
		ny = 500 - (500 * (ny / (ny+10)) * 1.5);
		//ny *= 10;
		
		return new int[] {(int) nx,(int) ny};
	}
	
	/**
	 * Draw the game screen
	 * 
	 * @param g The graphics context on which to draw the game
	 */
	private void draw(Graphics2D g)
	{		
		Color[] cols = new Color[] {Color.red,Color.green,Color.blue};
		
		// clear the background
		g.setColor(Color.black);
		g.fillRect(0,0,640,510);
		
		g.translate(0,30);	

		if (zp < 0) {
			drawBall(g);
		} 

		Color[] colMap = new Color[16];
		colMap[3] = Color.white;
		colMap[12] = cols[(timers[0] / 100) % 3];
		colMap[13] = Color.black;
		colMap[14] = Color.gray;
		colMap[15] = Color.yellow;
		
		for (int x=0;x<30;x++) {
			for (int y=0;y<30;y++) {
				int tile = getTile(x,y);
				if (tile != 0) {
					Polygon p = new Polygon();

					int total = addPoint(x,y,p);
					total += addPoint(x+1,y,p);
					total += addPoint(x+1,y+1,p);
					total += addPoint(x,y+1,p);
					
					if (total == 4) {
						if ((tile == 11) && (!controls[19])) {
							continue;
						}
						if ((tile == 13) && (toggles > 0)) {
							tile = 1;
						}
						
						Color col = cols[l % 3];
						if ((x+y) % 2 == 0) {
							col = cols[l % 3].darker();
						}
						
						if (colMap[tile] != null) {
							col = colMap[tile];
						}
						
						g.setColor(col);
						g.fillPolygon(p);
						
						if (tile > 10) {
							g.setColor(Color.darkGray);
							if (tile == 11) {
								g.setColor(col.darker());
							}
							g.fillPolygon(p);
							
							Polygon p2 = new Polygon();
							
							addPoint(x+0.1,y+0.1,p2);
							addPoint(x+0.9,y+0.1,p2);				
							addPoint(x+0.9,y+0.9,p2);				
							addPoint(x+0.1,y+0.9,p2);
	
							g.setColor(col);
							g.fillPolygon(p2);
						}
					}
				}
			}
		}

		if (zp >= 0) {
			drawBall(g);
		}
		
		g.setColor(Color.black);
		g.fillRect(0,-20,640,45);
		g.setColor(Color.darkGray);
		g.drawLine(0,25,640,25);
		g.setFont(g.getFont().deriveFont(Font.BOLD, 20.0f));	
		g.setPaint(new GradientPaint(0,20,Color.green,0,0,Color.white));
		
		g.drawString("Time: "+(timers[0]/1000),530,20);
		g.drawString("Ball",20,20);
		
		g.setPaint(new GradientPaint(0,20,Color.yellow,0,0,Color.white));
		g.drawString(msg,(640-g.getFontMetrics().stringWidth(msg))/2,20);
		
		if (!started) {
			ang += 0.01f;
			g.drawString("Cursors - Move     PgUp/PgDown - View    Space - Jump",60,470);
		}
	}
	
	private void drawBall(Graphics2D g) {
		int[] ball = getPoint(xp,yp);
		g.translate(ball[0],ball[1]-zp);
		g.scale(1.5,1.5);
		
		if ((timers[11] <= 0) || (timers[0] <= 0)) {
			g.setColor(Color.black);
			int size = (int) (zp/50);
			g.fillOval(-10+size,(int) (-5+size+zp),20-(size*2),10-(size*2));
		}
		
		g.setColor(Color.gray);
		g.fillOval(-10,-20,20,20);
		g.setColor(Color.darkGray);
		g.drawArc(-8,-18,18,18,270,90);
		g.setColor(Color.lightGray);
		g.fillOval(-7,-17,5,5);
		g.setColor(Color.white);
		g.fillOval(-6,-16,2,2);
		g.scale(1/1.5,1/1.5);
		g.translate(-ball[0],-(ball[1]-zp));
	}

	protected void processKeyEvent(KeyEvent e)
	{
		int[] keys = new int[] {KeyEvent.VK_LEFT,KeyEvent.VK_RIGHT,KeyEvent.VK_UP,KeyEvent.VK_DOWN,KeyEvent.VK_SPACE,KeyEvent.VK_PAGE_UP,KeyEvent.VK_PAGE_DOWN,KeyEvent.VK_END};
		
		for (int i=0;i<8;i++) { 
			if (e.getKeyCode() == keys[i]) {
				controls[i] = e.getID() == KeyEvent.KEY_PRESSED;
			}
		}
		if ((e.getKeyCode() == KeyEvent.VK_ENTER) && (!started)) 
		{
			started = true;
			msg = "Level "+(l+1);
			ang = 0;
		}
		if (e.getKeyCode() == 27) 
		{
			System.exit(0);
		}
	}
}