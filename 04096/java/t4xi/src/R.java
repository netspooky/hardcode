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

	private boolean[] controls = new boolean[10];
	
	private int[][][] city;
	private double[][] cars = new double[1000][10];
	private int[] timer = new int[11];
	private int carCount;
	private double targetX;
	private double targetY;
	private boolean pickup;
	private int points;
	private boolean hit;
	
	private R()
	{
		super("T4XI");
		
		setSize(640,510);
		setResizable(false);
		show();
		setIconImage(createImage(1,1));
		
		/*
		GraphicsDevice device = this.getGraphicsConfiguration().getDevice();
		setUndecorated(true);
		device.setFullScreenWindow(this);
		device.setDisplayMode(new DisplayMode(640,480,16,0));
		*/
				
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
	
	private void spawnTarget() {
		int x = 0;
		int y = 0;
		
		while (city[x][y][0] != 2) {
			x = (int) (Math.random()*300);
			y = (int) (Math.random()*300);
		}
		
		timer[10]++;
		targetX = x + 0.5;
		targetY = y + 0.5;
		pickup = !pickup;		
		timer[4] = (int) (50000-(timer[10]*50) + (Math.random()*50000));
	}
	
	/**
	 * Initialise the board for the next level
	 */
	private void init()
	{
		points = 500;
		city = new int[320][320][10];
		
		// random map generator
		int ypos = 22;
		while (ypos < 270) {
			int ysize = (int) (Math.random()*10)+6;
			if (ysize % 1 == 1) {
				ysize++;
			}
			
			int xpos = 22;

			for (int i=22;i<280;i++) {
				city[i][ypos][0] = 2;
				city[i][ypos+1][0] = 2;
			}
			ypos += 2;
			
			boolean lastPoint = false;
			
			while (xpos < 300) {
				int xsize = (int) (Math.random()*10)+6;
				if (xsize % 1 == 1) {
					xsize++;
				}
				
				if (xsize + xpos > 275) {
					xsize  = 275 - xpos;
					lastPoint = true;
				}
				else 
				{
					for (int i=ypos;i<ypos+ysize;i++) {
						city[xpos][i][0] = 2;
						city[xpos+1][i][0] = 2;
					}
					xpos += 2;
				}
				
				int[] colIndex = new int[4];
				int[] height = new int[4];
				for (int i=0;i<4;i++) {
					colIndex[i] = (int) ((Math.random()*3));
					height[i] = (int) (8+(Math.random()*6));
				}
				
				int blockx = xsize/2;
				int blocky = ysize/2;
				
				for (int x=0;x<blockx;x++) {
					for (int y=0;y<blocky;y++) {
						city[xpos+x][ypos+y][0] = 1;
						city[xpos+x][ypos+y][2] = colIndex[0];
						city[xpos+x][ypos+y][3] = height[0];

						city[xpos+xsize-blockx+x+1][ypos+y][0] = 1;
						city[xpos+xsize-blockx+x+1][ypos+y][2] = colIndex[1];
						city[xpos+xsize-blockx+x+1][ypos+y][3] = height[1];
						
						city[xpos+x][ypos+ysize-blocky+y+1][0] = 1;
						city[xpos+x][ypos+ysize-blocky+y+1][2] = colIndex[2];
						city[xpos+x][ypos+ysize-blocky+y+1][3] = height[2];
						
						city[xpos+xsize-blockx+x+1][ypos+ysize-blocky+y+1][0] = 1;
						city[xpos+xsize-blockx+x+1][ypos+ysize-blocky+y+1][2] = colIndex[3];
						city[xpos+xsize-blockx+x+1][ypos+ysize-blocky+y+1][3] = height[3];
							
						if ((x == 0) && (y == 0)) {
							city[xpos+x][ypos+y][4] = blockx;
							city[xpos+x][ypos+y][5] = blocky;
							
							city[xpos+xsize-blockx+x+1][ypos+y][4] = blockx-1;
							city[xpos+xsize-blockx+x+1][ypos+y][5] = blocky;
							
							city[xpos+x][ypos+ysize-blocky+y+1][4] = blockx;
							city[xpos+x][ypos+ysize-blocky+y+1][5] = blocky-1;
							
							city[xpos+xsize-blockx+x+1][ypos+ysize-blocky+y+1][4] = blockx-1;
							city[xpos+xsize-blockx+x+1][ypos+ysize-blocky+y+1][5] = blocky-1;
						}
					}
				}

				xpos += xsize;

				if (lastPoint) {
					break;
				}
			}
			
			for (int i=ypos;i<ypos+ysize;i++) {
				city[278][i][0] = 2;
				city[279][i][0] = 2;
			}
			xpos += 2;
			
			ypos += ysize;
		}

		for (int i=22;i<280;i++) {
			city[i][ypos][0] = 2;
			city[i][ypos+1][0] = 2;
		}
		
		int x = 200;
		int y = 100;
		while (city[x][y][0] != 2) {
			y++;
		}
		
		for (int i=1;i<1000;i++) {
			int xp = (int) (Math.random()*200)+50;
			int yp = (int) (Math.random()*200)+50;
			while (city[xp][yp][0] != 2) {
				yp++;				
			}	
			cars[i][0] = xp+0.5;
			cars[i][1] = yp+0.5;
			cars[i][2] = Math.PI / 2;
			if (city[xp-1][yp][0] != 2) {
				cars[i][2] -= Math.PI / 2;			
			}
			else if (city[xp+1][yp][0] != 2) {
				cars[i][2] += Math.PI / 2;			
			}
			else if (city[xp][yp+1][0] != 2) {
				cars[i][2] = -Math.PI / 2;		
			}
			
			cars[i][7] = 1+(Math.random()*3);
			cars[i][8] = 0;
			cars[i][4] = 1;
			cars[i][3] = 0.8 + (Math.random()*0.4);
		}
		carCount = 250;
		
		cars[0][0] = x+0.5;
		cars[0][1] = y+0.5;
		cars[0][2] = Math.PI/2;
		cars[0][4] = 1;
		
		spawnTarget();
	}
	
	/**
	 * Game logic.
	 * 
	 * @param delta The amount of time passed since last we were called.
	 */
	private void logic(int delta)
	{					
		timer[4] -= delta;
		timer[5] -= delta;
		if (timer[4] < 0) {
			timer[5] = 1000;
			if (pickup) {
				spawnTarget();
			}
			spawnTarget();
		}
		timer[3] += delta;
		
		if (controls[0]) {
			cars[0][2] -= delta/300.0;
			cars[0][4] = 1;
		}
		if (controls[1]) {
			cars[0][2] += delta/300.0;
			cars[0][4] = 1;
		}
		if (controls[2]) {
			cars[0][3] += (delta/100.0);
		}
		if (controls[3] && (cars[0][3] > -0.5)) {
			cars[0][3] -= (delta/100.0);
		}
		
		for (int i=0;i<carCount;i++) {
			if (cars[i][4] != 0) {
				cars[i][4] = 0;
				cars[i][5] = -Math.sin(cars[i][2]);
				cars[i][6] = Math.cos(cars[i][2]);
			}
			
			double dx = -cars[i][5];
			double dy = -cars[i][6];
			double lx = dy;
			double ly = -dx;
			
			double nx = cars[i][0] + (dx * (delta/200.0) * cars[i][3]);
			double ny = cars[i][1] + (dy * (delta/200.0) * cars[i][3]);
			
			if (i == 0) {
				cars[i][2] = ((int) (cars[i][2] * 70)) / 70.0;
				cars[i][3] *= 0.94;
				
				if (cars[0][3] < 0) {
					dx = -dx;
					dy = -dy;
				}
				
				if ((nx < 0) || (ny < 0) || (nx > 300) || (ny > 300)) {
					nx = cars[0][0];
					ny = cars[0][1];					
				} else {
					boolean failed = false;
					double tx = nx;
					double ty = ny;
					
					if ((city[((int) (tx+(0.4*dx)+(0.1 * dy)))][((int) (ty+(0.4*dy)+(0.1 * dx)))][0] != 2) ||
						(city[((int) (tx+(0.4*dx)-(0.1 * dy)))][((int) (ty+(0.4*dy)-(0.1 * dx)))][0] != 2))
					{
						tx = cars[0][0];
						if ((city[((int) (tx+(0.4*dx)+(0.1 * dy)))][((int) (ty+(0.4*dy)+(0.1 * dx)))][0] != 2) ||
							(city[((int) (tx+(0.4*dx)-(0.1 * dy)))][((int) (ty+(0.4*dy)-(0.1 * dx)))][0] != 2))
						{
							ty = cars[0][1];
							tx = nx;
							
							if ((city[((int) (tx+(0.4*dx)+(0.1 * dy)))][((int) (ty+(0.4*dy)+(0.1 * dx)))][0] != 2) ||
								(city[((int) (tx+(0.4*dx)-(0.1 * dy)))][((int) (ty+(0.4*dy)-(0.1 * dx)))][0] != 2))
							{
									nx = cars[0][0];
									ny = cars[0][1];
									cars[0][3] = 0;
							}
							else
							{
								ny = cars[0][1];
								cars[0][3] *= 0.98;
							}
						}
						else
						{ 
							nx = cars[0][0];	
							cars[0][3] *= 0.98;						
						}
					}
				}
				
				boolean foundHit = false;
				
				for (int c=1;c<carCount;c++) {
					if ((Math.abs(nx - cars[c][0]) < 0.6) && (Math.abs(ny-cars[c][1]) < 0.6)) {
						nx = cars[i][0];
						ny = cars[i][1];
						cars[i][3] = -cars[i][3];
						if (!hit) {
							points -= 5;
						}
						hit = true;
						foundHit = true;
					}
				}
				
				if (!foundHit) {
					hit = false;
				}
				
				if ((Math.abs(targetX - nx) < 2) && (Math.abs(targetY - ny) < 2)) {
					spawnTarget();
					if (pickup) {
						points += 1000;
						if (carCount < 1000) {
							carCount += 2;
						}
					} else {
						points += 100;
					}
				}
			} else {	
				if ((nx < 0) || (ny < 0) || (nx > 300) || (ny > 300)) {	
					nx = cars[i][0];
					ny = cars[i][1];		
					cars[i][3] = 0;
				} else {
					if ((Math.abs(nx - cars[0][0]) < 0.6) && (Math.abs(ny-cars[0][1]) < 0.6)) {
						nx = cars[i][0];
						ny = cars[i][1];
					}
					
					if ((Math.abs((nx - ((int) nx)) - 0.5) < 0.05) &&
						(Math.abs((ny - ((int) ny)) - 0.5) < 0.05))
					{
						if ((city[(int) (nx+lx)][(int) (ny+ly)][0] == 2) &&
							(city[(int) (nx+lx-dx)][(int) (ny+ly-dy)][0] != 2))
						{
							double change = Math.random();							
							if ((city[(int) (nx+(dx*2))][(int) (ny+(dy*2))][0] != 2) ||
								(city[(int) (nx+(dx*2)-lx)][(int) (ny+(dy*2)-ly)][0] != 2))
							{
								change = 1;
							} 
							
							if (change > 0.7) {
								cars[i][2] -= Math.PI / 2;
								cars[i][4] = 1; // mark the car for update
							}
						}
						
						if ((city[(int) (nx-(lx*2))][(int) (ny-(ly*2))][0] == 2) &&
							(city[(int) (nx-(lx*2)+dx)][(int) (ny-(ly*2)+dy)][0] != 2))
						{
							double change = Math.random();							
							if ((city[(int) (nx+(dx*2))][(int) (ny+(dy*2))][0] != 2) ||
								(city[(int) (nx+(dx*2)-lx)][(int) (ny+(dy*2)-ly)][0] != 2))
							{
								change = 1;
							} else {
								if (cars[i][8] > 0) {
									cars[i][8]--; 
									change = 0;
								}
							}

							if (change > 0.7) {
								cars[i][2] += Math.PI / 2;
								cars[i][4] = 1; // mark the car for update
								cars[i][8] = 10;
							}
						}
					}
				}
			}
			
			cars[i][0] = nx;
			cars[i][1] = ny;
		}
	}
	
	private String pad(String src,int size) {
		while (src.length() < size) {
			src = "0"+src;
		}
		
		return src;
	}
	
	private void drawFloor(Graphics2D g,int x,int y) {
		if (city[x][y][0] == 2) {
			int right = city[x+1][y][0];
			int left = city[x-1][y][0];
			int up = city[x][y-1][0];
			int down = city[x][y+1][0];
			
			g.setColor(Color.gray);
			g.fillRect(x*30,y*30,30,30);
			
			if ((left == 2) && (right != 2)) {
				g.setColor(Color.white);
				g.fillRect((x*30),(y*30),2,25);						
			}
			if ((left != 2) && (right == 2)) {
				g.setColor(Color.white);
				g.fillRect((x*30)+28,(y*30),2,25);
			}
			if ((up == 2) && (down != 2)) {
				g.setColor(Color.white);
				g.fillRect(x*30,(y*30),25,2);
			}
			if ((up != 2) && (down == 2)) {
				g.setColor(Color.white);
				g.fillRect(x*30,(y*30)+28,25,2);
			}
		}
	}
	
	private void drawBuildings(Graphics2D g,int x,int y) {
		Color[] colMap = new Color[] {new Color(0.5f,0.5f,1.0f),new Color(1.0f,0.5f,0.5f),new Color(1.0f,0.5f,1.0f)};
		
		if (city[x][y][0] == 1) {
			if (city[x][y][4] == 0) {
				return;
			}
			
			Color col = colMap[city[x][y][2]];
			int width = city[x][y][4]-1;
			if (width == 0) {
				width = 1;
			}
			int depth = city[x][y][5];
			
			int tx1 = (int) ((x*30)-((cars[0][0]-x)*city[x][y][3]));
			int ty1 = (int) ((y*30)-((cars[0][1]-y)*city[x][y][3]));
			int tx2 = (int) (((x+width)*30)-((cars[0][0]-(x+depth))*city[x][y][3]));
			int ty2 = (int) (((y+depth)*30)-((cars[0][1]-(y+depth))*city[x][y][3]));
			int bx = (x*30);
			int by = (y*30);
			
			g.setColor(col.darker());
			if (ty2-by < (depth*30)) {
				// bottom wall
				Polygon p = new Polygon();
				
				p.addPoint(bx,by+(30*depth));
				p.addPoint(bx+(30*width),by+(30*depth));
				p.addPoint(tx2,ty2);
				p.addPoint(tx1,ty2);
				
				g.fillPolygon(p);	
			}		
			if (ty1 > by) {
				// top wall
				Polygon p = new Polygon();
				
				p.addPoint(bx,by);
				p.addPoint(bx+(30*width),by);
				p.addPoint(tx2,ty1);
				p.addPoint(tx1,ty1);
				
				g.fillPolygon(p);
			}		
			g.setColor(col.darker().darker());
			if (tx2-bx < (width*30)) {
				// right wall
				Polygon p = new Polygon();
				
				p.addPoint(bx+(30*width),by);
				p.addPoint(bx+(30*width),by+(30*depth));
				p.addPoint(tx2,ty2);
				p.addPoint(tx2,ty1);
				
				g.fillPolygon(p);
			}	
			if (tx1 > bx) {
				// left wall
				Polygon p = new Polygon();
				
				p.addPoint(bx,by);
				p.addPoint(bx,by+(30*depth));
				p.addPoint(tx1,ty2);
				p.addPoint(tx1,ty1);
				
				g.fillPolygon(p);
			}	

			g.setColor(col);
			g.fillRect(tx1,ty1,tx2-tx1,ty2-ty1);	

			g.setColor(col.darker());
			
			Polygon p2 = new Polygon();
			int dify = ((by-ty1)/10);
			int basey = ty1+10;
			if (dify < 0) {
				basey = ty2-10;
			}
			p2.addPoint(tx1+10,basey);
			p2.addPoint(tx2-10,basey);
			p2.addPoint(tx2-15,basey+dify);
			p2.addPoint(tx1+15,basey+dify);
			g.fillPolygon(p2);
			Polygon p3 = new Polygon();
			int difx = ((bx-tx1)/10);
			int basex = tx1+10;
			if (difx < 0) {
				basex = tx2-10;
			}
			p3.addPoint(basex,ty1+10);
			p3.addPoint(basex,ty2-10);
			p3.addPoint(basex+difx,ty2-15);
			p3.addPoint(basex+difx,ty1+15);
			g.fillPolygon(p3);
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
		g.setColor(Color.darkGray);
		g.fillRect(0,0,640,510);
		
		g.translate(0,30);	

		int cx = (int) cars[0][0];
		int cy = (int) cars[0][1];
		
		int xo = (int) (320-(cars[0][0]*30));
		int yo = (int) (240-(cars[0][1]*30));
		g.translate(xo,yo);
		
		long start = System.currentTimeMillis();
		
		for (int i=11;i>=0;i--) {
			for (int j=0;j<i+1;j++) {
				drawFloor(g,cx-j,cy-i);
				drawFloor(g,cx-j,cy+i);
				if (j != 0) {
					drawFloor(g,cx+j,cy-i);
					drawFloor(g,cx+j,cy+i);
				}
				
				if (j != i) {
					drawFloor(g,cx-i,cy-j);
					drawFloor(g,cx+i,cy-j);
					if (j != 0) {
						drawFloor(g,cx-i,cy+j);
						drawFloor(g,cx+i,cy+j);
					}	
				}
				 
			}
		}
		
		g.setColor(Color.green);
		if (!pickup) {
			g.setColor(Color.red);
		}
		int offset = (timer[3] / 100) % 5;
		
		g.drawOval((int) ((targetX*30)-30-offset),(int) ((targetY*30)-30-offset),60+(offset*2),60+(offset*2));
		g.drawOval((int) ((targetX*30)-20-offset),(int) ((targetY*30)-20-offset),40+(offset*2),40+(offset*2));
		g.fillOval((int) ((targetX*30)-10),(int) ((targetY*30)-10),20,20);
		
		Color[] carCols = new Color[] {Color.red,Color.green,Color.cyan,Color.magenta};
		
		for (int i=0;i<carCount;i++) {
			if ((Math.abs(cars[i][0] - cars[0][0]) > 400) || (Math.abs(cars[i][1] - cars[0][1]) > 400)) {
				continue;
			}
			g.translate(cars[i][0]*30,cars[i][1]*30);
			g.rotate(cars[i][2]);
			g.setColor(Color.black);
			g.fillRect(-9,-7,14,5);
			g.fillRect(-9,5,14,5);
			g.setColor(carCols[(int) cars[i][7]].darker());
			g.fillRect(-7,-11,10,23);
			g.setColor(carCols[(int) cars[i][7]]);
			g.fillRect(-7,-5,10,15);
			g.rotate(-cars[i][2]);
			g.translate(-cars[i][0]*30,-cars[i][1]*30);
		}
		
		for (int i=19;i>=0;i--) {
			for (int j=i;j>=0;j--) {
				drawBuildings(g,cx-j,cy-i);
				drawBuildings(g,cx-j,cy+i);
				if (j != 0) {
					drawBuildings(g,cx+j,cy-i);
					drawBuildings(g,cx+j,cy+i);
				}
				
				if (j != i) {
					drawBuildings(g,cx-i,cy-j);
					drawBuildings(g,cx+i,cy-j);
					if (j != 0) {
						drawBuildings(g,cx-i,cy+j);
						drawBuildings(g,cx+i,cy+j);
					}	
				}
				 
			}
		}

		g.translate(-xo,-yo);
		
		double dx = (targetX - cars[0][0])*30;
		double dy = (targetY - cars[0][1])*30;
		double len = Math.sqrt((dx*dx)+(dy*dy));

		if (len > 235) {
			dx *= 235/len;
			dy *= 235/len;
		} 

		double ux = (dx/20);
		double uy = (dy/20);

		Polygon arrow = new Polygon();
		arrow.addPoint((int) (320+dx),(int) (240+dy));
		arrow.addPoint((int) ((320+dx)-ux-uy),(int) ((240+dy)-uy+ux));
		arrow.addPoint((int) ((320+dx)-ux+uy),(int) ((240+dy)-uy-ux));
		
		g.setColor(Color.green);
		if (!pickup) {
			g.setColor(Color.red);
		}
		g.fillPolygon(arrow);
		g.setColor(Color.black);
		g.drawPolygon(arrow);	
		
		g.setFont(g.getFont().deriveFont(Font.BOLD,20.0f));
		g.setColor(Color.black);
		g.drawString("CASH $"+points,20,27);
		g.drawString("TIME "+(timer[4]/1000),500,27);
		if (timer[5] > 0) {			
			g.drawString("TOO LATE!!",270,27);
		}
		g.setColor(Color.white);
		g.drawString("CASH $"+points,20,25);
		g.drawString("TIME "+(timer[4]/1000),500,25);
		if (timer[5] > 0) {			
			g.drawString("TOO LATE!!",270,25);
		}		
	}

	protected void processKeyEvent(KeyEvent e)
	{
		int[] keys = new int[] {KeyEvent.VK_LEFT,KeyEvent.VK_RIGHT,KeyEvent.VK_UP,KeyEvent.VK_DOWN,KeyEvent.VK_Z,KeyEvent.VK_X};
		
		for (int i=0;i<6;i++) {
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