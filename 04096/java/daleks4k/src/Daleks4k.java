import java.awt.*;
import java.awt.event.*;
import javax.swing.*;


public class Daleks4k extends JFrame 
{
	Font scoreFont     = new Font("Helvetica", 0, 15);
	Font gameOverFont  = new Font("Helvetica", 0, 50);
	Font infoFont      = new Font("Helvetica", 0, 30);

	private int level;
	public  int count=2000;
	private int zaps;
	private int score;
	private boolean gameOver;
	private boolean nextLevel;
	private boolean intro;
	private final int GRIDSIZE = 21;
	private final int EMPTY    =  0;
	private final int MONSTER  =  1;
	private final int MAN	   =  2;
	private final int CRASH	   =  3;

	Image images [] 	   = new Image[4];

	int x,y;

	
	Point playerloc;
	int grid[][];
	
	public Point getFreeSpot()
	{
		while (true)
		{
			int x = (int) (Math.random()*GRIDSIZE);
			int y = (int) (Math.random()*GRIDSIZE);
			if (grid[x][y]==EMPTY)
			{
				return new Point(x,y);
			} 
		}
	}
	public void nextLevel()
	{
		nextLevel=true;
		level++;
		if ((level%5) ==0) zaps=level;
		if (zaps<level) zaps++;
		initLevel();
	}
	public void zap()
	{
		if (zaps==0) return;
		zaps--;
		for (x=-1; x<=1; x++)
			for (y=-1; y<=1; y++)
			{
				if ((x+playerloc.x<0) || (y+playerloc.y<0) || 
					(x+playerloc.x>=GRIDSIZE) || (y+playerloc.y>=GRIDSIZE))
				{
					;
				}
				else
				{
					if (grid[x+playerloc.x][y+playerloc.y]==MONSTER)
						grid[x+playerloc.x][y+playerloc.y]=EMPTY;
				}
			}
		makeMove( 0, 0);
	}
	public void makeMove(int dx, int dy)
	{
		if (count>500) count -= ((count-500)/15);
		
		Point loc = new Point(playerloc.x + dx, playerloc.y +dy);
		
		if ((loc.x<0) || (loc.y<0) || 
			(loc.x>=GRIDSIZE) || (loc.y>=GRIDSIZE) ||
			grid[loc.x][loc.y] == CRASH
			) 
		{
			return;
		}
		else
		{
			
			int newgrid[][] = new int[GRIDSIZE][GRIDSIZE];
			int monsters = 0;
			for (y=0;y<GRIDSIZE;y++)
				for (x=0;x<GRIDSIZE;x++)
				{
					newgrid[x][y]=(grid[x][y]==CRASH)?CRASH:EMPTY;
					if (grid[x][y]==MONSTER) monsters++;
				}
				
			newgrid[loc.x][loc.y] = MAN;
			playerloc = loc;

			int newmonsters=0;
						
			for (y=0;y<GRIDSIZE;y++)
				for (x=0;x<GRIDSIZE;x++)
					if (grid[x][y]==MONSTER)
					{
						int mx = 0; 
						int my = 0;
//						if ((dx==0) && (dy==0))
//						{
							if (x<loc.x) mx = 1; if (x>loc.x) mx = -1;
							if (y<loc.y) my = 1; if (y>loc.y) my = -1;
//						}
						switch (newgrid[x+mx ][y+my ])
						{
							case MAN	: newgrid[x+mx ][y+my ] = MAN; gameOver = true; break;
							case MONSTER: newgrid[x+mx ][y+my ] = CRASH; newmonsters--;	break;
							case EMPTY  : newgrid[x+mx ][y+my ] = MONSTER; 	newmonsters++; break;
						}
					}
			grid = newgrid;
			
			if (gameOver) return;
			
			score += monsters-newmonsters;
			
			if (newmonsters == 0) 
			{
				nextLevel();
				return;
			}
			else
			{
				
			}
		}
		repaint();
		
	}
	
	
	public void initLevel()
	{
		for (y=0;y<GRIDSIZE;y++)
			for (x=0;x<GRIDSIZE;x++)
				grid[x][y]=EMPTY;
		
		for (x=0;x<level*5;x++)
		{
			Point loc = getFreeSpot();
			grid[loc.x][loc.y]=MONSTER;
		}
		playerloc = getFreeSpot();
		grid[playerloc.x][playerloc.y]=MAN;
		count=2000;
		repaint();
	}
	
	public void resetGame()
	{
		grid = new int[GRIDSIZE][GRIDSIZE];
		score= 0;
		level= 1;
		zaps = 2;
		gameOver = false;
		nextLevel=true;
		initLevel();
	}
/**
 * The constructor.
 */  
	public Daleks4k() 
	{
		images [MAN]     = Toolkit.getDefaultToolkit().getImage ( "rob.gif" );
		images [MONSTER] = Toolkit.getDefaultToolkit().getImage ( "monster.gif" );
		images [CRASH]   = Toolkit.getDefaultToolkit().getImage ( "crash.gif" );

		intro=true;
		resetGame();
		setTitle("Daleks4k");
		setSize(new Dimension(430, 447));
	}

	public void processEvent (AWTEvent e)
	{
        if (e.getID()==KeyEvent.KEY_RELEASED)
		{
			if (intro    )  {intro    =false; repaint(); return;}
			if (nextLevel)  {nextLevel=false; repaint(); return;}
			if (gameOver)	{resetGame();}

			switch (((KeyEvent)e).getKeyCode())	
			{
				case KeyEvent.VK_ESCAPE : System.exit(0);
				case KeyEvent.VK_NUMPAD7: makeMove(-1,-1); break;			
				case KeyEvent.VK_NUMPAD8: makeMove( 0,-1); break;			
				case KeyEvent.VK_NUMPAD9: makeMove( 1,-1); break;			
				case KeyEvent.VK_NUMPAD4: makeMove(-1, 0); break;			
				case KeyEvent.VK_NUMPAD6: makeMove( 1, 0); break;			
				case KeyEvent.VK_NUMPAD1: makeMove(-1, 1); break;			
				case KeyEvent.VK_NUMPAD2: makeMove( 0, 1); break;			
				case KeyEvent.VK_NUMPAD3: makeMove( 1, 1); break;			
				case KeyEvent.VK_NUMPAD5: makeMove( 0, 0); break;			
				case KeyEvent.VK_DECIMAL:  zap(); break;			
				case KeyEvent.VK_NUMPAD0 : 
				{
					Point t = getFreeSpot();
					makeMove(t.x-playerloc.x, t.y-playerloc.y);
					break;			
				}
				
			}
			invalidate();
			repaint();	
		}
		
	}
	public void paint(Graphics g)
	{
		g.setColor(new Color(0,0,0));
		g.fillRect(0,0,500,500);
		if (intro)
		{
			int height = 50;
			g.setColor(Color.WHITE);
			g.setFont(infoFont);
			g.drawString("Welcome to Daleks4k!!", 20,height);height+=50;
/*			g.setFont(scoreFont);
			g.drawString("You are the blue ball", 20,height);height+=30;
			g.drawString("Avoid the red monsters, and try to make them", 20,height);height+=30;
			g.drawString("crash into each other, or into prevously    ", 20,height);height+=30;
			g.drawString("crashed monsters. You can also use your gun ", 20,height);height+=30;
			g.drawString("to zap the neightbourhood.                  ", 20,height);height+=30;
			g.drawString(" ", 20,height);height+=30;
			g.drawString("The game is played on the numeric part of the keyboard. ", 20,height);height+=30;
			g.drawString("NUMPAD 1 - 9", 20,height);g.drawString("Move in the direction", 220,height);height+=30;
			g.drawString("NUMPAD 0", 20,height);g.drawString("Teleport away", 220,height);height+=30;
			g.drawString("NUMPAD .", 20,height);g.drawString("Zap          ", 220,height);height+=30;
			g.drawString("Escape  ", 20,height);g.drawString("Ends the game", 220,height);height+=30;*/
			return;
		}
		if (nextLevel)
		{
			g.setFont(gameOverFont);
			g.setColor(Color.RED);
			g.drawString("LEVEL: "+level,92,242);
			g.setColor(Color.WHITE);
			g.drawString("LEVEL: "+level,94,244);
			
			g.setFont(infoFont);
			g.setColor(Color.WHITE);
			g.drawString("Score: "+score,94,312);
			g.drawString("Zaps : "+zaps ,94,344);
			
			return;
		}
		Insets i = this.getInsets();
		for (y=0;y<GRIDSIZE;y++)
			for (x=0;x<GRIDSIZE;x++)
			{
				int left = x*20 + i.left + 1;
				int top  = y*20 + i.top  + 1;
				if ((grid[x][y]==MAN) && gameOver)
				{
					{
						g.setColor(Color.BLACK);
						g.fillRect(left,top,18,18);
						g.setColor(Color.WHITE);
						g.drawRect(left,top,18,18);
						g.drawLine(left,top,left+18,top+18);
						g.drawLine(left+18,top,left,top+18);
					}
				}
				else
					if (grid[x][y]!=EMPTY)
						g.drawImage(images[grid[x][y]], left,top,18,18, this);
			}
			
		if (gameOver)
		{
			g.setFont(gameOverFont);
			g.setColor(Color.RED);
			g.drawString("GAME OVER",64,244);
			g.setColor(Color.WHITE);
			g.drawString("GAME OVER",66,246);
		}
		//20x20
		g.setColor(Color.GREEN);
		g.setFont(scoreFont);
		g.drawString("Score: "+score, 10,400);
		g.drawString("Zaps : "+zaps , 10,420);
		
	}

	public static void main(String[] args) throws Throwable
	{
		// Create application frame.
		Daleks4k frame = new Daleks4k();
		// Show frame
		frame.setVisible(true);
		while (true)
		{
			Thread.sleep(frame.count);
//			frame.makeMove(0,0);
			frame.repaint();
		}
	}
}
