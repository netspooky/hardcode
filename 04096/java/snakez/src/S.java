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
import java.awt.event.KeyEvent;
import java.awt.image.BufferStrategy;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

import javax.swing.JFrame;

/**
 * @author Kevin Glass
 */
public class S extends JFrame
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
		new S();
	}
	
	private static final int BLOCK = -1;
	private static final int RIGHT = 1;
	private static final int LEFT = 2;
	private static final int UP = 3;
	private static final int DOWN = 4;
	private static final int POINT = -10;
	private static final int BONUS = -3;
	
	private static final int BSIZE = 30;
	private static final int DSIZE = 15;
	
	private static final Color[] cols = new Color[] {Color.red,Color.green,Color.blue,Color.cyan,Color.pink};
	private static final double[] rots = new double[] {0,Math.PI*1.5,Math.PI/2,Math.PI,0};
	private static final int[][] moves = new int[][] {{0,0},{1,0},{-1,0},{0,-1},{0,1}};
	
	private int[][] board = new int[BSIZE][BSIZE];
	private int len = 0;
	private int tx = 0;
	private int ty = -5;
	private int hx = 0;
	private int hy = 0;
	private int dir = RIGHT;
	private int speed = 300;
	private int step = speed;
	private boolean started = false;
	private String msg = "";
	private int dieWait;
	private int nextBonus;
	private int nextPoint;
	private int score;
	private int bestScore = 0;
	private int totalLen = 0;
	private int nextTarget = 2000;
	private File f;
	private int lastDir = RIGHT;
	
	private S()
	{
		super("Snakez");
		
		for (int x=0;x<BSIZE;x++) {
			board[x][0] = BLOCK;
			board[x][BSIZE-1] = BLOCK;
			board[0][x] = BLOCK;
			board[BSIZE-1][x] = BLOCK;			
		}
		
		// icon creation and setting
		BufferedImage temp = new BufferedImage(16,16,BufferedImage.TYPE_INT_ARGB);
		Graphics2D g = (Graphics2D) temp.getGraphics();
		g.setColor(Color.black);
		g.fillRect(0,0,16,16);
		g.setColor(Color.green);
		g.fillRect(0,4,16,8);
		setIconImage(temp);
		
		// normal setup for a frame accept using show which saves a call to pack()
		// and setVisible(true);
		setSize(640,510);
		setResizable(false);
		show();

		f = new File(System.getProperty("user.home")+File.separator+"snakez.hiscores");
		if (f.exists()) {
			try {
				FileInputStream in = new FileInputStream(f);
				byte[] dat = new byte[in.available()];
				in.read(dat);
				bestScore = Integer.parseInt(new String(dat));
				in.close();
			} catch (Throwable e) {}
		}
		
		enableEvents(56);
		
		createBufferStrategy(2);
		BufferStrategy strategy = getBufferStrategy();
			
		init();
		
		long lastLoopTime = System.currentTimeMillis();
		
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
	
	/**
	 * Initialise the board for the next level
	 */
	private void init()
	{
		if (score > bestScore) {
			bestScore = score;
		}
		
		try {
			FileOutputStream out = new FileOutputStream(f);
			out.write(new String(""+bestScore).getBytes());
			out.close();
		} catch (Throwable e) {};
		
		for (int x=1;x<BSIZE-1;x++) {
			for (int y=1;y<BSIZE-1;y++) {
				board[x][y] = 0;
			}
		}
		
		nextPoint = 0;
		nextBonus = (int) (Math.random()*15000) + 20000;
		hx = (BSIZE/2)+3;
		hy = BSIZE/2;
		tx = hx-5;
		ty = hy;
		dir = RIGHT;
		len = 0;
		totalLen = 5;
		score = 0;
		nextTarget = 2000;
		speed = 300;
		for (int x=0;x<6;x++) {
			board[hx-x][hy] = RIGHT;
		}
		
		msg = "Press Enter To Start";
	}
	
	private void die() {
		started = false;
		msg = "You're Dead";
		dieWait = 1000;
	}
	
	/**
	 * Game logic.
	 * 
	 * @param delta The amount of time passed since last we were called.
	 */
	private void logic(int delta)
	{		
		if (!started) {
			dieWait -= delta;
			if (dieWait <= 0) {
				init();
			}
			
			return;			
		}
		
		if (score > nextTarget) {
			nextTarget += 2000;
			speed -= 10;
		}
		
		nextBonus -= delta;
		nextPoint -= delta;
		
		if (nextPoint <= 0) {
			for (int x=0;x<BSIZE;x++) {
				for (int y=0;y<BSIZE;y++) {
					if (board[x][y] <= -10) {
						board[x][y] = 0;
					}
				}
			}
			
			int x = 0;
			int y = 0;
			
			while (board[x][y] != 0) {
				x = (int) (Math.random()*(BSIZE-2))+1;
				y = (int) (Math.random()*(BSIZE-2))+1;
			}
			
			board[x][y] = -10 - ((int) (Math.random()*5));
			
			nextPoint = (int) (Math.random()*5000)+10000;
		}
		if (nextBonus <= 0) {
			nextBonus = (int) (Math.random()*15000)+20000;
			
			int x = 0;
			int y = 0;
			
			while (board[x][y] != 0) {
				x = (int) (Math.random()*(BSIZE-2))+1;
				y = (int) (Math.random()*(BSIZE-2))+1;
			}
			
			board[x][y] = BONUS;
		}	
		
		step -= delta;
		if (step <= 0) {
			lastDir = dir;
			if (len == 0) {
				int d = board[tx][ty];
				board[tx][ty] = 0;
				tx += moves[d][0];
				ty += moves[d][1];			
			} else {
				len--;
			}
			
			board[hx][hy] = dir;
			hx += moves[dir][0];
			hy += moves[dir][1];
			
			if (board[hx][hy] != 0) {
				// check for collects here
				if (board[hx][hy] < BLOCK) {
					if (board[hx][hy] <= POINT) {
						len += -(board[hx][hy]+9);
						totalLen += -(board[hx][hy]+9);
						score += (-(board[hx][hy]+9))*100;
						nextPoint = 0;
					} 
					if (board[hx][hy] == BONUS) {
						score += 1000;
					}
					
					board[hx][hy] = 0;								
				} else {
					hx -= moves[dir][0];
					hy -= moves[dir][1];
					die();
				}
			}
			board[hx][hy] = dir;
			
			step = speed;
		}
	}
	
	private String pad(String src,int size) {
		while (src.length() < size) {
			src = "0"+src;
		}
		
		return src;
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

		for (int x=0;x<BSIZE;x++) {
			for (int y=0;y<BSIZE;y++) {
				if (board[x][y] == 0) {
					g.setColor(Color.darkGray.darker().darker());
					g.drawRect(20+(x*DSIZE),15+(y*DSIZE),DSIZE,DSIZE);
				}
			}
		}
		for (int x=0;x<BSIZE;x++) {
			for (int y=0;y<BSIZE;y++) {
				
				if (board[x][y] > 0) {
					if ((x==hx) && (y==hy)) {
						g.setColor(Color.green);
						g.translate(20+(x*DSIZE)+(DSIZE/2),15+(y*DSIZE)+(DSIZE/2));
						g.rotate(rots[board[x][y]]);
						g.fillArc(-(DSIZE/2)-1,-DSIZE-5,DSIZE+1,DSIZE+10,180,180);
						g.fillRect(-(DSIZE/2)-1,-(DSIZE/2)-2,DSIZE,3);
						g.setColor(Color.white);
						g.fillOval(-10,-4,10,10);
						g.fillOval(0,-4,10,10);
						g.setColor(Color.black);
						g.fillOval(-7,0,5,5);
						g.fillOval(3,0,5,5);
						g.setColor(Color.red);
						g.fillRect(-2,4,2,6);
						g.drawLine(0,10,2,12);
						g.drawLine(0,10,-2,12);
						g.rotate(-rots[board[x][y]]);
						g.translate(-(20+(x*DSIZE)+(DSIZE/2)),-(15+(y*DSIZE)+(DSIZE/2)));
					} else if ((x==tx) && (y==ty)) {						
						g.setColor(Color.green);
						g.translate(20+(x*DSIZE)+(DSIZE/2),15+(y*DSIZE)+(DSIZE/2));
						g.rotate(rots[board[x][y]]);
						g.fillArc(-(DSIZE/2)-1,0,DSIZE+1,DSIZE+1,0,180);
						g.rotate(-rots[board[x][y]]);
						g.translate(-(20+(x*DSIZE)+(DSIZE/2)),-(15+(y*DSIZE)+(DSIZE/2)));
					} else {
						g.setColor(Color.green);
						g.fillRect(20+(x*DSIZE),15+(y*DSIZE),DSIZE,DSIZE);
						g.setColor(Color.green.darker());
						g.drawLine(21+(x*DSIZE),15+(y*DSIZE),20+(x*DSIZE)+DSIZE,14+(y*DSIZE)+DSIZE);
						g.drawLine(22+(x*DSIZE),15+(y*DSIZE),20+(x*DSIZE)+DSIZE,13+(y*DSIZE)+DSIZE);
						g.drawLine(21+(x*DSIZE),16+(y*DSIZE),19+(x*DSIZE)+DSIZE,14+(y*DSIZE)+DSIZE);
					}
				}
				if (board[x][y] == BLOCK) {
					g.setColor(Color.gray);
					g.fillRect(20+(x*DSIZE),15+(y*DSIZE),DSIZE,DSIZE);
				}
				
				if (board[x][y] <= POINT) {
					int temp = (int) (DSIZE * 0.7);
					g.translate(21+(x*DSIZE)+(DSIZE/2),16+(y*DSIZE)+(DSIZE/2));
					g.rotate(Math.PI/4);
					g.setColor(cols[(-board[x][y]) - 10]);
					g.fillRect(-(temp/2),-(temp/2),temp,temp);
					g.setColor(cols[(-board[x][y]) - 10].darker());
					g.drawRect(-(temp/2),-(temp/2)+1,temp,temp);
					g.rotate(-Math.PI/4);
					g.translate(-(21+(x*DSIZE)+(DSIZE/2)),-(16+(y*DSIZE)+(DSIZE/2)));
				}
				
				if (board[x][y] == BONUS) {
					int temp = (int) (DSIZE * 0.7);
					g.translate(21+(x*DSIZE)+(DSIZE/2),16+(y*DSIZE)+(DSIZE/2));
					g.setColor(Color.yellow);
					g.fillOval(-(temp/2),-(temp/2),temp,temp);
					g.setColor(Color.yellow.darker());
					g.drawOval(-(temp/2),-(temp/2),temp,temp);
					g.translate(-(21+(x*DSIZE)+(DSIZE/2)),-(16+(y*DSIZE)+(DSIZE/2)));
				}
			}
		}

		g.setFont(g.getFont().deriveFont(Font.BOLD, 20.0f));	
		
		if (!started) 
		{
			g.setPaint(Color.black);
			g.fillRect(80,165,330,50);
			g.setColor(Color.white);
			g.drawRect(80,165,330,50);		
			g.drawString(msg,((500-g.getFontMetrics().stringWidth(msg))/2),200);
		}

		g.setPaint(new GradientPaint(0,100,Color.white.darker().darker(),0,80,Color.white));
		g.drawString("Score",530,100);
		g.setPaint(new GradientPaint(0,200,Color.white.darker().darker(),0,180,Color.white));
		g.drawString("Length",525,200);
		g.setPaint(new GradientPaint(0,300,Color.white.darker().darker(),0,280,Color.white));
		g.drawString("Best",535,300);
		
		g.setPaint(new GradientPaint(0,130,Color.yellow.darker().darker(),0,110,Color.yellow));
		g.drawString(pad(""+score,6),525,130);
		g.setPaint(new GradientPaint(0,230,Color.yellow.darker().darker(),0,210,Color.yellow));
		g.drawString(pad(""+totalLen,3),540,230);
		g.setPaint(new GradientPaint(0,330,Color.yellow.darker().darker(),0,310,Color.yellow));
		g.drawString(pad(""+bestScore,6),525,330);
		
		g.setFont(g.getFont().deriveFont(Font.BOLD, 40.0f));
		g.setPaint(new GradientPaint(0,60,Color.green.darker().darker(),0,40,Color.green));
		g.drawString("Snakez",490,60);
	}

	protected void processKeyEvent(KeyEvent e)
	{
		if (e.getID() != KeyEvent.KEY_PRESSED) {
			return;
		}
		
		if ((e.getKeyCode() == KeyEvent.VK_LEFT) && (lastDir != RIGHT)) {
			dir = LEFT;
		}
		if ((e.getKeyCode() == KeyEvent.VK_RIGHT) && (lastDir != LEFT)) {
			dir = RIGHT;
		}
		if ((e.getKeyCode() == KeyEvent.VK_UP) && (lastDir != DOWN)) {
			dir = UP;
		}
		if ((e.getKeyCode() == KeyEvent.VK_DOWN) && (lastDir != UP)) {
			dir = DOWN;
		}
		
		if (e.getKeyCode() == KeyEvent.VK_ENTER) {
			if ((!started) && (dieWait <= 0)) {
				started = true;
			}
		}
		if (e.getKeyCode() == 27) 
		{
			System.exit(0);
		}
	}
}