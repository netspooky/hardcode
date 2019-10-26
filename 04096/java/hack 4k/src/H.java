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
import java.awt.Image;
import java.awt.event.KeyEvent;
import java.awt.image.BufferStrategy;
import java.awt.image.BufferedImage;

import javax.imageio.ImageIO;
import javax.swing.JFrame;

/**
 * @author Kevin Glass
 */
public class H extends JFrame
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
		new H();
	}

	private Image[] images = new Image[28];
	private int[][][] map = new int[1000][1000][5];
	private int level = 1;
	private int px;
	private int py;
	private boolean exit;
	private int[][] stats;
	private String[] messages = new String[5];
	private int count;
	
	private H()
	{
		super("H");

		try
		{
			// icon creation and setting
			BufferedImage src = ImageIO.read(Thread.currentThread().getContextClassLoader().getResource("h"));
			
			for (int i=0;i<11;i++) {
				int x = i % 5;
				int y = i / 5;
				images[i] = new BufferedImage(32,32,BufferedImage.TYPE_INT_ARGB); 
				if (i != 10) {
					images[i].getGraphics().drawImage(src.getSubimage(x*16,y*16,16,16),0,0,32,32,null);
				}
			}
		} 
		catch (Exception e)
		{
		}
		
		// normal setup for a frame accept using show which saves a call to pack()
		// and setVisible(true);
		setSize(640,510);
		setResizable(false);
		init();
		show();

		enableEvents(56);
		
		createBufferStrategy(2);
		BufferStrategy strategy = getBufferStrategy();
			
		
		while (true)
		{
			synchronized (this) 
			{
				draw((Graphics2D) strategy.getDrawGraphics());
			}
			
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
		if (level == 1) {
			stats = new int[][] {null,
					 // HP, Total HP, AP, DP, Exp, Level
					 {10,10,5,5,0,1}, // You
					 {5,5,3,2,50,1}, // Orc
					 {8,8,5,5,100,1}, // Vampire
					 {12,12,5,7,200,1}, // Dragon
					 {16,16,7,5,400,1}, // Snake
					 {20,20,7,7,900,1}, // Troll
					 {25,25,8,7,1000,1}, // Wizard
			};
		}
		
		if (level > 6) {
			level = 6;
		}
		addMessage("On Lvl "+level);
	
		px = 505;
		py = 505;
		for (int x=0;x<1000;x++) {
			for (int y=0;y<1000;y++) {
				map[x][y][0] = 0;
				map[x][y][1] = 0;
			}
		}
		
		exit = false;
		for (int s=1;s<(level*3);s++) {
			boolean edge = s == (level*3)-1;
			for (int x=-s;x<s+1;x++) {
				buildRoom(50+x,50-s,!edge,true,(x != -s) || !edge,(x != s) || !edge);
				buildRoom(50+x,50+s,true,!edge,(x != -s) || !edge,(x != s) || !edge);
			}
			for (int x=-s+1;x<s;x++) {
				buildRoom(50-s,50+x,true,true,!edge,true);
				buildRoom(50+s,50+x,true,true,true,!edge);
			}
		}
		buildRoom(50,50,true,true,true,true);		
		
		map[px][py][1] = 1;
	}
	
	private void buildRoom(int x,int y,boolean north,boolean south,boolean west,boolean east) {
		int xsize = (int) ((Math.random()*4) + 1);
		int ysize = (int) ((Math.random()*4) + 1);

		int rx = 10-xsize;
		int ry = 10-ysize;
		
		x *= 10;
		y *= 10;
		
		if (west) {
			for (int xp=0;xp<xsize;xp++) {
				map[x+xp][y+7][0] = 11;
				map[x+xp][y+6][0] = 9;
				map[x+xp][y+8][0] = 9;	
			}
		}
		if (north) {
			for (int yp=0;yp<ysize;yp++) {
				map[x+7][y+yp][0] = 11;
				map[x+6][y+yp][0] = 9;
				map[x+8][y+yp][0] = 9;	
			}
		}
		
		x += xsize;
		y += ysize;
				
		for (int xp=0;xp<rx;xp++) {
			for (int yp=0;yp<ry;yp++) {
				map[xp+x][yp+y][0] = 11;
				if ((xp == 0) || (xp+1 == rx) || ((yp == 0)) || (yp+1 == ry)) 
				{
					map[xp+x][yp+y][0] = 9;
				}
				
				if ((xp > 0) && (yp > 0) && (xp+1 < rx) && (yp+1 < ry)) {
					if (Math.random() > 0.97) {
						int type = (int) (2+(Math.random()*(level+1)));
						map[xp+x][yp+y][1] = type;
						map[xp+x][yp+y][3] = stats[type][1];
					}
				}
			}
		}
		
		if ((!exit) && (Math.random() > 0.5)) {
			map[x+1][y+1][0] = 10;
			exit = true;
		}
		
		x -= xsize;
		y -= ysize;
		
		if (west) {
			map[x+xsize][y+7][0] = 10;
		}
		if (east) {
			map[x+9][y+7][0] = 10;
		}
		if (north) {
			map[x+7][y+ysize][0] = 10;
		}		
		if (south) {
			map[x+7][y+9][0] = 10;
		}
	}
	
	private void addMessage(String msg) { 
		for (int i=0;i<4;i++) {
			messages[i] = messages[i+1];
		}
		messages[4] = msg;
	}
	
	private void logic(int xp,int yp)
	{	
		boolean dead = false;
		String[] names = new String[] {null,"You","Orc","Vamp","Drake","Snake","Troll","Mage"};
		
		if ((xp == 0) && (yp == 0)) {
			if (stats[1][0] < stats[1][1]) {
				stats[1][0]++;
				addMessage("HP+1");
			}
		}
		
		count++;
		
		synchronized (this) 
		{
			
			map[px][py][1] = 0;
			
			px += xp;
			py += yp;
			if ((map[px][py][0] != 11) || (map[px][py][1] != 0)) {
				if ((map[px][py][1] > 1) && (map[px][py][1] < 8)) {
					// attack!
					int attacked = map[px][py][1];
					int damage = (int) ((Math.random() * stats[1][2]) - (Math.random() * stats[attacked][3]));
					if (damage < 0) {
						damage = 0;
					}
					
					map[px][py][3] -= damage;
					if (map[px][py][3] < 1) {
						map[px][py][1] = 0;
						addMessage("Killed "+names[attacked]+" >"+stats[attacked][4]);
						stats[1][4] += stats[attacked][4];
						
						if ((stats[1][4] > (stats[1][5]*stats[1][5]*1000))) {
							stats[1][5]++;
							stats[1][1]+=5;
							addMessage("LvlUp "+stats[1][5]);
						}
					} else {
						addMessage("Hit "+names[attacked]+" for "+damage);
					}
					
					px -= xp;
					py -= yp;
				} else if (map[px][py][0] == 10) {
				} else if (map[px][py][0] == 8) {
					level++;
					init();
				} else {					
					px -= xp;
					py -= yp;
				}
			}
			
			map[px][py][1] = 1;
			
			for (int x=0;x<10;x++) {
				for (int y=0;y<10;y++) {
					int nx = ((px/10)*10)+x;
					int ny = ((py/10)*10)+y;
					int ox = nx;
					int oy = ny;
					
					int target = map[nx][ny][1];
					int hp = map[nx][ny][3];
					if ((target > 1) && (target < 8) && (map[nx][ny][4] != count)) {
						int dx = px - nx;
						int dy = py - ny;

						if (dx != 0) {
							dx /= Math.abs(dx);
						}
						if (dy != 0) {
							dy /= Math.abs(dy);
						}
						
						if (dx != 0) {
							nx += dx;
						} else if (dy != 0) {
							ny += dy;
						}
						
						if (map[nx][ny][0] > 9) {
							if (map[nx][ny][1] == 1) {
								int damage = (int) ((Math.random() * stats[target][2]) - (Math.random() * stats[1][3]));
								if (damage < 0) {
									damage = 0;
								}
								
								stats[1][0] -= damage;
								addMessage(names[target]+" hit for "+damage);
								if (stats[1][0] < 1) {
									addMessage("Killed!");
									level = 1;
									init();
								}
							} else if (map[nx][ny][1] == 0) {
								map[ox][oy][1] = 0;
								map[ox][oy][3] = 0;
								map[nx][ny][1] = target;
								map[nx][ny][3] = hp;
								map[nx][ny][4] = count;
							}
						}
						
					}
				}
			}
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
		g.setColor(new Color(0f,0f,0f));
		g.fillRect(0,0,640,510);
		
		g.translate(0,30);	

		for (int x=0;x<21;x++) {
			for (int y=0;y<15;y++) {
				int index = map[px-10+x][py-7+y][0];
				
				if (index != 0) {
					g.drawImage(images[index-1],x*32,y*32,null);
				}
				
				index = map[px-10+x][py-7+y][1];
				
				if (index != 0) {
					g.drawImage(images[index-1],x*32,y*32,null);
				}
			}
		}
		
		g.fillRect(100,400,440,80);
		g.setColor(new Color(1f,1f,1f));
		g.drawRect(100,400,440,80);
		
		for (int i=0;i<5;i++) {
			if (messages[4-i] != null) {
				g.drawString(messages[4-i],120,475-(i*15));
			}
		}
	}

	protected void processKeyEvent(KeyEvent e)
	{
		if (e.getID() == KeyEvent.KEY_RELEASED) {
			if (e.getKeyCode() == KeyEvent.VK_LEFT) {
				logic(-1,0);
			}
			if (e.getKeyCode() == KeyEvent.VK_RIGHT) {
				logic(1,0);
			}
			if (e.getKeyCode() == KeyEvent.VK_UP) {
				logic(0,-1);
			}
			if (e.getKeyCode() == KeyEvent.VK_DOWN) {
				logic(0,1);
			}
			if (e.getKeyCode() == KeyEvent.VK_H) {
				logic(0,0);
			}
		}
		
		if (e.getKeyCode() == 27) 
		{
			System.exit(0);
		}
	}
}