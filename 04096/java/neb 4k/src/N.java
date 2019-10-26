/*
 * Code Copyright 2005 - Kevin Glass
 * 
 * Code is provided as is for education and ammusement purposes. It should not be 
 * posted publically or used in any other way without permission.
 * 
 * tilt4k@cokeandcode.com
 */

import java.awt.Color;
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.event.KeyEvent;
import java.awt.image.BufferStrategy;
import java.io.InputStream;

import javax.swing.JFrame;

/**
 * @author Kevin Glass
 */
public class N extends JFrame
{
	/**
	 * Game entry point
	 * 
	 * @param argv The arguments passed in to the program
	 */
	public static void main(String argv[])
	{
		// don't need it this time?
		// this gives us better performance on windows meaning I can just draw the 
		// polygons brute force (note you can set it to anything, as long as its set)
		//System.setProperty("sun.java2d.noddraw","");
		new N();
	}

	private boolean[] controls = new boolean[5];
	
	// 0 - Empty
	// 1 - Block
	// 2 - Transport
	// 3 - Fall Through
	// 4 - Door
	// 5 - Coin
	// 6 - End Point
	// 7 - Bad Guy
	// 8 - Key
	// 9 - Barrier
	private byte[][] map;
	
	private double[][] actors = new double[505][10]; // 0 = PLAYER // 105 - instance moves
	private byte[][] links = new byte[100][4];
	private double[] sinCosTable = new double[360*4];
	private int[][] stars = new int[500][2];
	private int[] timer = new int[40]; // 1,2 = door timers, 5 = game time, 11 = score, 12 == keys, 13 == linkCount, 12 == current level
	//private boolean[] flag = new boolean[10]; // 1 = FALLING, 8 = DEAD, 9 = WIN = timer[30+]
	
	private N()
	{
		super("N");
		
		// normal setup for a frame accept using show which saves a call to pack()
		// and setVisible(true);
		setSize(640,510);
		setResizable(false);
		show();

		enableEvents(56);
		
		createBufferStrategy(2);
		BufferStrategy strategy = getBufferStrategy();

		for (int i=0;i<360*4;i++) {			
			sinCosTable[i] = Math.sin(0.017453 * (i/4.0));
		}
						
		timer[14] = 3;
		init();
		timer[38] = 1;
		
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
		int actorCount = 1;
		
		timer[5] = 240 * 1000;
		timer[12] = 0;
		timer[11] = 0;
		
		// init basic actor
		actors[0][0] = 18;
		actors[0][1] = 2;
		actors[0][4] = 1;
		
		try
		{
			InputStream in = Thread.currentThread().getContextClassLoader().getResourceAsStream("d");
			
			timer[17] = in.read();
			
			for (int l=0;l<timer[14];l++)
			{				
				map = new byte[20][50];
				for (int j=0;j<50;j++) {
					j += in.read();
					
					if (j < 50) 
					{
						for (int i=0;i<20;i+=2) {
							int b = in.read();
							map[i][j] = (byte) (b & 0x0F);
							map[i+1][j] = (byte) ((b & 0xF0) >> 4);
						}
					}
				}
				
				timer[13] = in.read();
				
				for (int i=0;i<timer[13];i++) {					
					in.read(links[i]); 					
				}
			}
		}		
		catch (Exception e)
		{
		}
		
		for (int i=0;i<500;i++)
		{
			actors[i+1][9] = 0;
			stars[i][0] = (int) (Math.random()*640);
			stars[i][1] = (int) (sinCosTable[i]*3000);
		}
		
		for (int i=0;i<20;i++) {
			for (int j=0;j<50;j++) {
				if (map[i][j] == 7)
				{
					actors[actorCount][9] = 1;
					actors[actorCount][0] = i*18;
					actors[actorCount][1] = (j*80)+1;
					actors[actorCount][2] = 1;
					actorCount++;
				}
			}
		}
		
		timer[38] = 0;
		timer[39] = 0;		
	}
	
	/**
	 * Game logic.
	 * 
	 * @param delta The amount of time passed since last we were called.
	 */
	private void logic(int delta)
	{
		timer[3] -= delta;
		
		// if timers gone and we're completed level reinit
		if ((timer[39] == 2) && (timer[3] < 0)) {
			controls[4] = true;
		}
		
		if (timer[38] == 1) 
		{
			if (controls[4]) {
				if (timer[39] == 2)
				{
					timer[14]++; // increment level count, restart
				}
				
				init();
			}
			return;
		}

		if (timer[3] > 0) {
			return;
		}
		
		timer[5] -= delta;
		if (timer[5] < 0) 
		{
			timer[38] = 1;
			timer[3] = 2000;		
		}
		actors[0][5] += delta/100.0;
		
		for (int i=1;i<100;i++) {
			if (actors[i][9] != 0) 
			{
				//7362 - Recent Change
				double old = actors[i][0];
				actors[i][0] += (actors[i][2] * delta * 0.05);
				//if (actors[i][0] > 360) {
//					actors[i][0] -= 360;
	//			}
				actors[i][0] %= 360;
				if (actors[i][0] < 0) {
					actors[i][0] += 360;
				}
				
				// hit player?
				if ((Math.abs(actors[i][0] - actors[0][0]) < 5) && (Math.abs(actors[i][1] - actors[0][1]) < 5) && (timer[1] <= 0))
				{
					//actors[0][1] -= 80;
					actors[104][0] = 79;
					actors[104][1] = -1;
					timer[31] = 1;
					return;
				}
				
				int n = (int) ((actors[i][0]+(actors[i][2] * 9)) / 18);
				int h = (int) (actors[i][1] / 80);
				
				if (n < 0) {
					n += 20;
				}
				if (n > 19) {
					n -= 20;
				}
				if (map[n][h] == 0) 
				{
					actors[i][0] = old;
					actors[i][2] = -actors[i][2];
				}
			}
		}
					
		if (timer[0] > 0) {
			timer[0] -= delta;
			return;
		}
		
		// this is the first time we're coming out of the door so actually move us 
		// up to th expected location
		if (timer[1] == 750) {
			// make move
			int n = (int) (actors[0][0] / 18);
			int h = (int) (actors[0][1] / 80);
			
			for (int i=0;i<timer[13];i++) 
			{
				if ((links[i][0] == n) && (links[i][1] == h)) 
				{
					actors[0][0] = (links[i][2] * 18) + 8;
					actors[0][1] = (links[i][3] * 80) + 1;
					break;
				}
				if ((links[i][2] == n) && (links[i][3] == h)) 
				{
					actors[0][0] = (links[i][0] * 18) + 8;
					actors[0][1] = (links[i][1] * 80) + 1;
					break;
				}
			}
			
			timer[1]--;
		}
		if (timer[1] > 0) {
			timer[1] -= delta;
			return;
		}
	
		// check forced instance moves
		if (actors[104][0] > 0) {
			actors[104][0] -= delta * 0.2;
			actors[0][1] += actors[104][1] * delta * 0.2;
			return;
		} 
		
		double old = actors[0][0];
		double oldh = actors[0][1];
		
		if (timer[31] == 0)
		{
			//left	
			if (controls[0]) {
				actors[0][3] += 0.03f * delta;
				actors[0][0] -= 0.04f * delta;
				actors[0][4] = -1;			
			}
			// right	
			if (controls[1]) {
				actors[0][3] += 0.03f * delta;
				actors[0][0] += 0.04f * delta;
				actors[0][4] = 1;
			}
		}
		
		// rationalise angle
		actors[0][0] %= 360;
		if (actors[0][0] < 0) {
			actors[0][0] += 360;
		}
		
		// check blocked movement
		//int n = (int) (actors[0][0] / 18);
		int h = (int) ((actors[0][1]+79) / 80);
		int nl = (int) (((actors[0][0]-3) % 360) / 18);
		int n = nl;
		int nr = (int) (((actors[0][0]+3) % 360) / 18);
		
		if (h >= 0)
		{
			timer[31] = 0;
			if ((map[nl][h] == 0) && (map[nr][h] == 0)) {
				actors[0][1] -= 0.2 * delta;
				timer[31] = 1;
			} else {
				if (actors[0][1] != h * 80) {
					actors[0][1] = h * 80;
				}
			}
			
			// door
			if (map[n][h] == 4) 
			{
				if (controls[2]) 
				{
					timer[0] = 750;
					timer[1] = 750;
					actors[104][0] = 0;
					// we've used the door so jump out
					return;
				}
			}
			
			// fall away block
			if (map[n][h] == 3) 
			{
				map[n][h] = 0;
			}
			
			// coin
			if ((map[n][h] == 5) || (map[n][h] == 8))
			{
				if (map[n][h] == 8) {
					timer[12]++;
				}
				timer[11] += 1000;
				map[n][h] = 1;
			}
			
			// barrier
			if (map[n][h] == 9) 
			{
				if (timer[12] > 0) {
					timer[12]--;
					map[n][h] = 1;						
				} else {
					actors[0][0] = old;
					actors[0][1] = oldh;							
				}					
			}			
			
			// end point
			if (map[n][h] == 6)
			{
				if (timer[14] != timer[17])  // MAX LEVEL CHECK 
				{
					timer[39] = 2; // NEXT LEVEL
				} 
				else
				{
					timer[39] = 1; // GAME COMPLETE
					timer[14] = 1; // reset levels
				}
				timer[38] = 1;
				timer[3] = 3000;	
				return;
			}
			
			// transport pad
			if (map[n][h] == 2) {
				if (controls[2]) {
					for (int i=h+1;i<50;i++) {
						if (map[n][i] == 2) {
							actors[0][1] = (i * 80);
							controls[2] = false;
							break;
						}
					}
				}
				if (controls[3]) {
					for (int i=h-1;i>=0;i--) {
						if (map[n][i] == 2) {
							actors[0][1] = (i * 80);
							controls[3] = false;
							break;
						}
					}
				}
			}
		}
		else
		{
			actors[0][1] -= 0.2 * delta;		
		}
		
		if (actors[0][1] < -50) {
			timer[39] = 0; // GAME COMPLETE	
			timer[38] = 1;
			timer[3] = 2000;
		}
	}
	
		
	private int[] toScreen(double degrees,double height,int outer) {
		int[] pt = new int[2];
		
		height *= 80;
		
		degrees -= actors[0][0];
		height -= actors[0][1];
		
		if (degrees < 0) {
			degrees += 360;
		}
		double xofs = sinCosTable[(int) ((degrees%360)*4)] * (150+outer);
		double zofs = sinCosTable[(int) (((degrees+90)%360)*4)] * (150+outer);
		
		if (zofs < -80) {
			return null;
		}
		
		pt[0] = (int) (320+xofs);
		pt[1] = (int) (380-height);
		
		return pt;
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
		
		int top = (int) (-4000 + actors[0][1]);
		int bottom = (int) (420 + actors[0][1]);
		int obot = bottom;
		
		top = -10 > top ? -10 : top;
		bottom = 510 < bottom ? 510 : bottom;
		
		g.setColor(Color.white);
		for (int i=0;i<500;i++)
		{
			int px = (int) ((stars[i][0] - (actors[0][0] / 360.0) * 640));
			if (px < 0) {
				px += 640;
			}
			if (px > 640) {
				px -= 640;
			}
			g.fillOval(px,(int) (((480-stars[i][1])+actors[0][1])),5,5);
		}
		
		g.setColor(Color.cyan.darker());
		g.fillRect(0,(int) (410+actors[0][1]),640,550);
		
		int temp = (int) (actors[0][1]/80);
		for (int i=0;i<40;i++) {
			int[] pt1 = toScreen((i*9)+4,0,0);
			int[] pt2 = toScreen(((i+1)*9)+4,0,0);
			if ((pt1 != null) && (pt2 != null)) {
				g.setColor(new Color(0x222244));
				if (i % 2 == 0) {
					g.setColor(new Color(0x333355));
				}
				g.fillRect(pt1[0],top,pt2[0] - pt1[0],bottom-top);
			}
		}
				
		for (int h=temp-5;h<temp+15;h++) {
			if ((h < 0) || (h > 50)) 
			{
				continue;
			}
			for (int i=0;i<20;i++) {
				if (map[i][h] != 0) 
				{
					int[] pt1 = toScreen((i)*18,h,20);
					int[] pt2 = toScreen((i+0.9)*18,h,20);
					int[] pt1b = toScreen((i)*18,h,0);
					int[] pt2b = toScreen((i+0.9)*18,h,0);

					if ((pt1 != null) && (pt2 != null) && (pt1b != null) && (pt2b != null)) {
						g.setColor(Color.blue.darker().darker());
						g.fillRect(pt1b[0],pt1b[1],pt1[0]-pt1b[0],20);
						g.fillRect(pt2[0],pt2[1],pt2b[0]-pt2[0],20);
						
						if (map[i][h] == 4) {
							g.setColor(Color.black);
							g.fillRect(pt1b[0],pt1b[1]-50,pt2b[0]-pt1b[0],50);
						}						
					}
				}
			}
			for (int i=0;i<20;i++) {
				if (map[i][h] != 0)
				{
					int[] pt1 = toScreen(i*18,h,20);
					int[] pt2 = toScreen((i+0.9)*18,h,20);

					if ((pt1 != null) && (pt2 != null)) 
					{
						double step = (pt2[0] - pt1[0])/5.0;
						
						g.setPaint(new GradientPaint(0,pt1[1],Color.blue,0,pt1[1]+30,Color.black));
						g.fillRect(pt1[0],pt1[1],pt2[0]-pt1[0],20);
						
						if (map[i][h] == 2) {
							g.setColor(Color.yellow);
							g.fillRect(pt1[0],pt1[1],pt2[0]-pt1[0],4);
						}
						if (map[i][h] == 9) {
							g.setColor(Color.cyan);
							g.fillRect((int) (pt1[0]+(step*2)),pt1[1]-50,(int) ((pt2[0]-pt1[0])-(step*4)),55);
						}
						if (map[i][h] == 6) {
							g.setColor(Color.black);
							g.fillRect(pt1[0],pt1[1],(pt2[0]-pt1[0])/2,4);
							g.setColor(Color.white);
							g.fillRect(pt1[0]+((pt2[0]-pt1[0])/2),pt1[1],(pt2[0]-pt1[0])/2,4);
						}
						if ((map[i][h] == 5) || (map[i][h] == 8)) {
							g.setColor(Color.yellow);
							if (map[i][h] == 8) {
								g.setColor(Color.cyan);
							}
							g.fillOval((int) (pt1[0]+(step*2)),pt1[1]-30,(int) (step*2),20);
							g.setColor(Color.black);
							g.drawOval((int) (pt1[0]+(step*2)),pt1[1]-30,(int) (step*2),20);
						}
					}									
				}
			}
		}
				
		// draw bob
		if (timer[38] == 0) // check dead
		{
			int yo = ((int) (Math.sin(actors[0][5])*6));
			g.translate(320,-yo);
			g.scale(actors[0][4],1);
			
			if ((timer[0] > 500) || (timer[0] < 0) || (timer[1] < 250)) { // door walks	
				g.setColor(Color.green.darker());
				g.fillOval(-10,345,30,30);
				
				if (timer[1] > 0) 
				{
					g.setColor(Color.white);
					g.fillOval(5,343,10,20);
					g.fillOval(-5,343,10,20);
					g.setColor(Color.black);
					g.fillOval(7,347,5,10);
					g.fillOval(-3,347,5,10);
				}
				else
				{
					g.setColor(Color.white);
					g.fillOval(10,343,10,20);
					g.setColor(Color.black);
					g.fillOval(15,347,6,10);				
				}
				if (timer[0] > 0) 
				{
					g.setColor(Color.green.darker());
					g.fillOval(-10,345,30,30);					
				}
			}

			g.scale(1/actors[0][4],1);
			g.translate(-320,yo);
		}
		
		// draw all the other actors
		for (int i=1;i<100;i++)
		{
			// actor in use check
			if (actors[i][9] != 0) {
				double v = actors[i][1] / 80;
				int[] pt1 = toScreen(actors[i][0]-5,v,20);
				int[] pt2 = toScreen(actors[i][0]+5,v,20);
				
				if ((pt1 != null) && (pt2 != null)) 
				{
					double step = (pt2[0]-pt1[0])/5.0;
					
					g.setColor(Color.red);
					g.fillRect(pt1[0],pt1[1]-40,pt2[0]-pt1[0],30);
					g.setColor(Color.black);
					g.fillRect(pt1[0],pt1[1]-35,pt2[0]-pt1[0],10);
					
					g.setColor(Color.white);
					g.fillRect((int) (pt1[0]+step),pt1[1]-33,(int) step,6);
					g.fillRect((int) (pt1[0]+(step*3)),pt1[1]-33,(int) step,6);					
				}
			}
		}		
		
		if (timer[38] == 1) 
		{
			g.drawString("Press Space",290,250);
		}
		
		g.setPaint(new GradientPaint(0,30,Color.red,0,60,Color.yellow));
		
		g.setFont(g.getFont().deriveFont(1,20.0f));
		g.drawString(""+timer[11],10,50);
		g.drawString(""+(timer[5]/1000),300,50);
		g.drawString(""+timer[12],600,50);
		
		int offset = 5;
		if (timer[38] == 1)
		{
			String msg = "LOSER!";
			
			if (timer[3] > 0) 
			{
				if (timer[39] == 1)
				{
					msg = "WINNER!";
					offset = 0;
				}
				else if (timer[39] == 2)
				{
					msg = "COMPLETE";
					offset = -15;
				}
			}
			else
			{
				msg = "NEB 4K";
				offset = 0;
			}
			g.drawString(msg,285+offset,230);
		}
	}

	protected void processKeyEvent(KeyEvent e)
	{
		int[] keys = new int[] {KeyEvent.VK_LEFT,KeyEvent.VK_RIGHT,KeyEvent.VK_UP,KeyEvent.VK_DOWN,KeyEvent.VK_SPACE};
		for (int i=0;i<keys.length;i++) 
		{
			if (e.getKeyCode() == keys[i]) {
				controls[i] = e.getID() == KeyEvent.KEY_PRESSED;
			}
		}
		if (e.getKeyCode() == 27) 
		{
			System.exit(0);
		}
	}
}