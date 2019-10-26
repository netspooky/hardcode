/*
 * Code Copyright 2005 - Kevin Glass
 * 
 * Code is provided as is for education and ammusement purposes. It should not be 
 * posted publically or used in any other way without permission.
 * 
 * tilt4k@cokeandcode.com
 */

import java.applet.AudioClip;
import java.awt.Color;
import java.awt.Font;
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.event.KeyEvent;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferStrategy;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

import javax.swing.JFrame;

/**
 * @author Kevin Glass
 */
public class T extends JFrame
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
		new T();
	}

	private static final int MAX = 100;

	private static final int SHOT = 1;
	private static final int CRATE = -1;
	private static final int TROOPER = 0;
	private static final int BLAST = 2;
	
	private static final int X_POS = 0;
	private static final int Y_POS = 1;
	private static final int X_VEL = 2;
	private static final int Y_VEL = 3;
	private static final int WITH_SHUTE = 4;
	private static final int IN_USE = 5;
	private static final int TYPE = 6;
	private static final int COLOR = 7;
	private static final int LIFE = 9;
	
	private boolean snd = true;
	private AudioClip q;
	private AudioClip r;
	private float rot = 0;
	private boolean left;
	private boolean right;
	private boolean fire;
	private float[][] e = new float[MAX][10];
	private boolean sted = true;
	private int tCount = 0;
	private int next = 1000;
	private int rate = 1000;
	private int toFire = 250;
	private int health;
	private int score = 0;
	private int lives = -1;
	private boolean started = false;
	private String msg = "Trooper";
	private int restart;
	private int bestScore = 0;
	private File f;
	private int spaceDown = 0;
	
	private T()
	{
		super("Trooper");
		
		// icon creation and setting
		BufferedImage temp = new BufferedImage(16,16,BufferedImage.TYPE_INT_ARGB);
		Graphics2D g = (Graphics2D) temp.getGraphics();
		g.setColor(Color.black);
		g.fillRect(0,0,16,16);
		g.setColor(Color.gray);
		g.fillArc(0,0,16,16,90,90);
		g.fillArc(0,0,16,16,270,90);
		g.setColor(Color.blue);
		g.fillOval(4,4,8,8);
		setIconImage(temp);
		
		// normal setup for a frame accept using show which saves a call to pack()
		// and setVisible(true);
		setSize(640,510);
		setResizable(false);
		show();
		
		enableEvents(56);
		
		//requestFocus();
		createBufferStrategy(2);
		BufferStrategy strategy = getBufferStrategy();
			
		f = new File(System.getProperty("user.home")+File.separator+"trooper.hiscores");
		if (f.exists()) {
			try {
				FileInputStream in = new FileInputStream(f);
				byte[] dat = new byte[in.available()];
				in.read(dat);
				bestScore = Integer.parseInt(new String(dat));
				in.close();
			} catch (Throwable e) {}
		}
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
		try {
			FileOutputStream out = new FileOutputStream(f);
			out.write(new String(""+bestScore).getBytes());
			out.close();
		} catch (Throwable e) {};
		
		started = false;
		health = 3;
		fire = false;
		left = false;
		right = false;
		lives = 0;
		score = 50;
	}

	private int getEmpty() {
		for (int i=0;i<MAX;i++) {
			if (e[i][IN_USE] == 0) {
				return i;
			}
		}
		
		return -1;
	}
	
	/**
	 * Game logic.
	 * 
	 * @param delta The amount of time passed since last we were called.
	 */
	private void logic(int delta)
	{		
		if (!started) {
			restart += delta;
			if ((restart > 2000) && (lives < 0)) {
				msg = "Trooper";
			}
			return;
		}
	
		toFire -= delta;
		
		if ((score > 0) && (fire) && (toFire < 0)) {
			int i = getEmpty();

			score-=3;
			e[i][X_VEL] = (float) (Math.sin(rot) * 700);
			e[i][Y_VEL] = (float) (-Math.cos(rot) * 700);
			e[i][X_POS] = 320 + (e[i][X_VEL] / 20);
			e[i][Y_POS] = 410 + (e[i][Y_VEL] / 20);
			e[i][IN_USE] = 1;
			e[i][TYPE] = SHOT;
			e[i][LIFE] = -5000;
			toFire = 500;
			
			if ((spaceDown > 1000) && (spaceDown < 1800)) {
				toFire = 150;
			}
		}
		if (fire) {
			spaceDown += delta;
		} else {
			spaceDown = 0;
		}
		
		if ((left) && (rot > -1.6f)) {
			rot -= 0.0008f * delta;
		}
		if ((right) && (rot < 1.6f)) {
			rot += 0.0008f * delta;
		}
		
		next -= delta;
		if ((tCount < 40) && (next < 0)) {
			int i = getEmpty();
			
			e[i][X_POS] = (float) ((Math.random() * 500) + 20);
			if (e[i][X_POS] > 270) {
				e[i][X_POS] += 100;
			}
			e[i][Y_POS] = -10;
			e[i][X_VEL] = 0;
			e[i][Y_VEL] = (float) (Math.random() * 35) + 20;
			e[i][WITH_SHUTE] = 1;
			e[i][IN_USE] = 1;
			e[i][TYPE] = TROOPER;
			if (Math.random() * 100 <= 1.5) {
				e[i][TYPE] = CRATE;
			}
			
			next = rate;
			tCount++;
		}
		
		// move
		for (int i=0;i<MAX;i++) {
			e[i][X_POS] += e[i][X_VEL] * delta * 0.001;
			e[i][Y_POS] += e[i][Y_VEL] * delta * 0.001;
			e[i][LIFE] += delta * 0.001;
			
			if ((e[i][LIFE] > 0.25) && (e[i][TYPE] == BLAST)) {
				e[i][IN_USE] = 0;
			}
			
			if (e[i][Y_POS] > 445) {				
				e[i][Y_POS] = 445;
				
				if (e[i][WITH_SHUTE] == 0) {
					// splat
					e[i][TYPE] = BLAST;
					e[i][LIFE] = 0;
					e[i][X_VEL] = 0;
					e[i][Y_VEL] = 0;
					e[i][WITH_SHUTE] = 0;
					score += 25;
					rate-=2;
					tCount--;
				}
				else
				{
					if (e[i][X_POS] < 320) {
						e[i][X_VEL] = 60;
					} else {
						e[i][X_VEL] = -60;
					}
					e[i][Y_VEL] = 0;
					e[i][WITH_SHUTE] = 0;
					
					if (e[i][TYPE] == CRATE) {
						e[i][X_VEL] *= 5;
						e[i][Y_POS] = 435;
					}
				}
				tCount--;
			}
		}
		
		// collide
		for (int i=0;i<MAX;i++) {
			if (e[i][IN_USE] == 0) {
				continue;				
			}
			
			if (e[i][TYPE] <= TROOPER) {
				for (int j=0;j<MAX;j++) {
					if (e[j][IN_USE] == 0) {
						continue;				
					}
					
					if (e[j][TYPE] == SHOT) {
						float xd = e[j][X_POS] - e[i][X_POS];
						float yd = e[j][Y_POS] - (e[i][Y_POS] - 10);
						
						if ((Math.abs(xd) < 20) && (Math.abs(yd) < 25)) {
							if (yd > -5) {
								e[i][TYPE] = 2;
								e[i][LIFE] = 0;
								e[i][X_VEL] = 0;
								e[i][Y_VEL] = 0;
								e[i][WITH_SHUTE] = 0;
								e[j][IN_USE] = 0;
								tCount--;
								rate-=2;
							} else {
								// winged him
								e[i][WITH_SHUTE] = 0;
								e[i][Y_VEL] = 150;
							}
							
							score += 50;
						}
					}
				}
				
				// hit base?
				if ((e[i][X_POS] > 300) && (e[i][X_POS] < 340)) {
					if (e[i][TYPE] == TROOPER) {
						health--;
					} else {
						health++;
						if (health > 5) {
							health = 5;
						}
					}
					
					e[i][TYPE] = 2;
					e[i][LIFE] = 0;
					e[i][X_VEL] = 0;
					e[i][COLOR] = 1;
					
					if (health == 0) {
						msg = "You've been Overrun!";
						started = false;
						lives--;
						health = 5;
						rate = 1000;
						
						for (int k=0;k<MAX;k++) {
							e[k][IN_USE] = 0;
						}
					
						if (lives < 0) {
							if (score > bestScore) {
								bestScore = score;
							}
							
							msg = "Game Over";
							restart = 0;
						}
					}
				}
			}
			
			if ((e[i][X_POS] < -50) || (e[i][Y_POS] < -50) || (e[i][X_POS] > 700) || (e[i][Y_POS] > 700)) {
				e[i][IN_USE] = 0;
			}
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

		g.setPaint(new GradientPaint(0,450,Color.green,0,500,Color.green.darker()));
		g.fillRect(0,450,640,50);
		

		for (int i=0;i<MAX;i++) {
			if (e[i][IN_USE] == 0) {
				continue;
			}
			g.translate(e[i][X_POS],e[i][Y_POS]);

			if (e[i][TYPE] == SHOT) 
			{
				g.setPaint(new GradientPaint(-e[i][X_VEL] / 25,-e[i][Y_VEL] / 25,Color.black,0,0,Color.white));
				g.drawLine((int) (-e[i][X_VEL] / 25),(int) (-e[i][Y_VEL] / 25),0,0);
			}
			g.translate(-e[i][X_POS],-e[i][Y_POS]);
		}
		
		AffineTransform t = g.getTransform();
		g.translate(320,410);
		g.rotate(rot);
		g.setColor(Color.blue);
		g.fillRect(-10,-25,20,25);
		g.setColor(Color.blue.darker());
		g.drawRect(-10,-25,20,25);
		g.fillRect(-8,-50,16,25);
		g.rotate(-rot);

		g.setColor(Color.gray.darker());	
		g.fillOval(-21,-21,42,42);
		g.fillRect(-21,-1,42,42);
		g.setColor(Color.gray);		
		g.fillOval(-20,-20,40,40);
		g.fillRect(-20,0,40,40);
		g.setColor(Color.gray.darker());	
		g.fillRect(-20,35,40,5);
		g.setColor(Color.gray.brighter());	
		g.fillArc(-15,-15,30,30,(int) (90+Math.toDegrees(rot)),90);
		g.fillArc(-15,-15,30,30,(int) (270+Math.toDegrees(rot)),90);
		g.setColor(Color.blue.darker());
		g.fillOval(-8,-8,16,16);
		g.setColor(Color.blue);
		g.fillOval(-7,-7,14,14);

		for (int i=0;i<health;i++) {
			g.setColor(Color.red);
			g.fillRect(-25+(i*10),45,8,13);
			g.setColor(Color.red.darker());
			g.drawRect(-24+(i*10),45,7,13);
		}
		g.setTransform(t);

		if (!started) {
			g.setColor(Color.white);
			if (lives < 0) {
				g.drawString("Cursor Left/Right - Turn Turret",240,130);
				g.drawString("Space - Fire",290,150);
				g.drawString("Enter - Start Game",275,170);
				g.drawString("Escape - Quit",285,190);
				g.drawString("BestScore: "+pad(""+bestScore,10),255,240);
			}
			else
			{
				g.drawString("Enter to Continue",275,150);
			}
		}
		g.setFont(g.getFont().deriveFont(20.0f));
		String l = pad(""+lives,2);
		if (lives < 0) {
			l = "00";
		}
		g.setColor(Color.black);
		g.drawString("Score: "+pad(""+score,10),11,471);
		//g.drawString("Lives: "+l,541,471);
		g.setColor(Color.white);
		g.drawString("Score: "+pad(""+score,10),10,470);
		//g.drawString("Lives: "+l,540,470);
		
		if (!started) 
		{
			g.setColor(Color.blue);
			g.setFont(g.getFont().deriveFont(Font.ITALIC | Font.BOLD, 40.0f));
			g.drawString(msg, 320 - (g.getFontMetrics().stringWidth(msg)/2),100);
		}
		
		for (int i=0;i<MAX;i++) {
			if (e[i][IN_USE] == 0) {
				continue;
			}
			g.translate(e[i][X_POS],e[i][Y_POS]);

			if (e[i][TYPE] == BLAST) 
			{
				int rad = (int) (e[i][LIFE] * 50);
				g.setPaint(Color.yellow);

				if (e[i][COLOR] == 1) {
					g.setPaint(Color.white);
				}
				
				g.fillOval(-rad,-rad,rad*2,rad*2);
				g.setPaint(Color.yellow.darker());
				g.drawOval(-rad,-rad,rad*2,rad*2);				
			}
			if (e[i][TYPE] <= TROOPER) 
			{
				boolean withShute = e[i][WITH_SHUTE] == 1;
				
				g.setColor(Color.darkGray);
				if (withShute) {
					g.drawLine(-15,-25,0,-10);
					g.drawLine(14,-25,0,-10);
				}
				

				if (e[i][TYPE] == CRATE) {
					g.setColor(Color.gray);
					g.fillRect(-9,-9,18,18);
					g.setColor(Color.lightGray);
					g.drawRect(-9,-9,18,18);
					g.setColor(Color.darkGray);
					g.drawLine(9,9,9,-9);
					g.drawLine(9,9,-9,9);
					g.setColor(Color.black);
					g.fillRect(-7,-3,14,6);
					g.fillRect(-3,-7,6,14);
					g.setColor(Color.red);
					g.fillRect(-6,-2,12,4);
					g.fillRect(-2,-6,4,12);
				}
				
				if (e[i][TYPE] == TROOPER)
				{
					g.drawLine(0,0,-5,5);
					g.drawLine(0,0,5,5);
					g.setColor(Color.pink);
					g.drawLine(-7,-8,7,-8);
					g.fillOval(-5,-20,10,10);
					g.setColor(Color.red);
					g.fillArc(-3,-10,6,12,0,180);
				}
				
				if (withShute) {
					g.setColor(Color.red);
					g.fillArc(-15,-35,30,20,0,180);
				}

				if (e[i][TYPE] == TROOPER)
				{
					g.setColor(Color.red.darker());
					g.fillArc(-3,-10,6,12,180,180);
				}
			}
			g.translate(-e[i][X_POS],-e[i][Y_POS]);
		}
	}

	protected void processKeyEvent(KeyEvent e)
	{
		if (e.getID() == KeyEvent.KEY_PRESSED) {
			if (e.getKeyCode() == KeyEvent.VK_LEFT) {
				left = true;
			}
			if (e.getKeyCode() == KeyEvent.VK_RIGHT) {
				right = true;
			}
			if (e.getKeyCode() == KeyEvent.VK_SPACE) {
				fire = true;
			}
			return;
		}
		
		if (e.getKeyCode() == KeyEvent.VK_LEFT) {
			left = false;
		}
		if (e.getKeyCode() == KeyEvent.VK_RIGHT) {
			right = false;
		}
		if (e.getKeyCode() == KeyEvent.VK_SPACE) {
			fire = false;
		}
		
		if ((e.getID() == KeyEvent.KEY_TYPED) && (e.getKeyChar() == 's') && (r != null)) {
			snd = !snd;
		}

		if (e.getKeyCode() == KeyEvent.VK_ENTER)
		{
			if (!started) {
				if (lives < 0) {
					init();
				}
				started = true;
			}
		}
		if (e.getKeyCode() == 27) 
		{
			System.exit(0);
		}
	}
}