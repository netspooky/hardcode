/*
 * Copyright (c) 2008-2009 Ulf Ochsenfahrt <ulf@ofahrt.de>
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import java.applet.Applet;
import java.awt.AWTEvent;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;

public final class Critters4k extends Applet //implements Runnable
{

private static final long serialVersionUID = 1L;

private static final boolean ANTIALIASING = false;
private static final boolean REPAINT_AFTER_EVENT = false;
private static final boolean SHOW_RADIUS_AS_TEXT = false;
private static final boolean CALL_SLEEP_INSTEAD_OF_YIELD = false;

private static final int W = 800;
private static final int H = 600;

private static final int FIELD_WIDTH = 29; // 27 fields+1 field border on each side
private static final int FIELD_HEIGHT = 25; // 23 fields+1 field border top and bottom
private static final int FIELD_SIZE = FIELD_WIDTH*FIELD_HEIGHT;

private static final int DRAW_SIZE = 14;
private static final int X_OFFSET = 70;
private static final int Y_OFFSET = 70;

private static final int TOTAL_FIELD_WIDTH = 2*X_OFFSET+FIELD_WIDTH*DRAW_SIZE;
private static final int TOTAL_FIELD_HEIGHT = 2*Y_OFFSET+FIELD_HEIGHT*DRAW_SIZE;

private static final int SCORE_X = TOTAL_FIELD_WIDTH+3+18;
private static final int SCORE_Y = 20;
private static final int LIVES_X = TOTAL_FIELD_WIDTH+3+18;
private static final int LIVES_Y = 40;
private static final int MONEY_X = TOTAL_FIELD_WIDTH+3+18;
private static final int MONEY_Y = 60;
private static final int SELECT_X_OFFSET = TOTAL_FIELD_WIDTH;
private static final int SELECT_Y_OFFSET = Y_OFFSET+75;
private static final int STATUS_X_OFFSET = TOTAL_FIELD_WIDTH+3;
private static final int STATUS_Y_OFFSET = Y_OFFSET+170;

private static final int LEVEL_Y_OFFSET = TOTAL_FIELD_HEIGHT;

private static final int TIME_STEP = 16;

private static final int SOURCE_X = 0;
private static final int SOURCE_Y = 11;
private static final int SOURCE2_X = 11;
private static final int SOURCE2_Y = 0;


// Shortest Paths Algorithm Constants
private static final int INFINITE_COST = 131072; // 2^17

// Map Storage Constants
private static final int MAP_BORDER = 1;
private static final int MAP_RESERVED = 2;
private static final int MAP_TOWER_FIRST = 3;
private static final int MAP_TOWER_BOOSTER = 3;
private static final int MAP_TOWER_SIMPLE = 4;
private static final int MAP_TOWER_ANTIAIR = 5;
private static final int MAP_TOWER_ANTIGROUND = 6;
private static final int MAP_TOWER_LAST = 6;

// calculate the upgrade cost from level to level+1:
// ((basecost >> (10*level+8)) & 0x3ff)-((basecost >> (10*level)) & 0x3ff)
private static final long TOWER_BOOSTER_COST =
	(500L << 40) | (400L << 30) | (300L << 20) | (200L << 10) | (100L << 0);

private static final long TOWER_SIMPLE_COST =
	(400L << 50) | (150L << 40) | (75L << 30) | (40L << 20) | (17L << 10) | (5L << 0);

private static final long TOWER_ANTIAIR_COST =
	(640L << 50) | (300L << 40) | (212L << 30) | (141L << 20) | (83L << 10) | (40L << 0);

// calculate the radius for level: ((TOWER_SIMPLE_RADIUS >> (8*level)) & 0xff)
private static final long TOWER_SIMPLE_RADIUS =
	(100L << 40) | (50L << 32) | (50L << 24) | (50L << 16) | (50L << 8) | (50L << 0);

// Critter Storage Constants
private static final int CR_SIZE = 13;
private static final int CR_DIAMETER = 0; // in pixel
private static final int CR_SPEED = 1; // in milliseconds per pixel
private static final int CR_RACE = 2;
private static final int CR_HEALTH = 3;
private static final int CR_X = 4;
private static final int CR_Y = 5;
private static final int CR_SOURCE = 6;
private static final int CR_DESTINATION = 7;
private static final int CR_MAX_HEALTH = 8;
private static final int CR_MIN_HEALTH = 9;
private static final int CR_MONEY = 10;
private static final int CR_TIME_REMAINING = 11;
private static final int CR_DIRECTION = 12;

// Tower Storage Constants
private static final int TW_SIZE = 5;
private static final int TW_TARGET = 0;
private static final int TW_TIME = 1;
private static final int TW_MAX_TIME = 2;
private static final int TW_DAMAGE = 3;
private static final int TW_LEVEL = 4;

private static final int STATE_INIT = 0;
private static final int STATE_PREPARE = 1;
private static final int STATE_RUNNING = 2;
private static final int STATE_LOST = 3;
private static final int STATE_WON = 4;

// Critter Constants
private static final int MAX_CRITTERS = 4096;

private static final int RACE_STRONG = 0;
private static final int RACE_NORMAL = 1;
private static final int RACE_FAST   = 2;
private static final int RACE_FLYING = 3;

private static final int STRONG_MINDAMAGE = 2;

// Game State Constants
private static final int GAME_STATE = 0;
private static final int GAME_LEVEL = 1;
// highlight x, y coordinates
private static final int GAME_OX = 2;
private static final int GAME_OY = 3;
private static final int GAME_LIVES = 4;
private static final int GAME_MONEY = 5;
private static final int GAME_CRITTER_COUNT = 6;
private static final int GAME_TIMER = 7;
private static final int GAME_SELECT = 8;
private static final int GAME_SCORE = 9;

private static final int NEXT_LEVEL_TIME = 25000;
private static final int MAX_LEVEL = 100;

// Map Storage
private final int[] map = new int[FIELD_SIZE];

// Tower Storage
// 5*i+0 = target
// 5*i+1 = time
// 5*i+2 = maximum time
// 5*i+3 = damage
// 5*i+4 = level
private final int[] towers = new int[TW_SIZE*FIELD_SIZE];

// Shortest Paths Storage
private final int[] predecessor = new int[2*FIELD_SIZE];

// Critter Storage (gameState[GAME_CRITTER_COUNT] critters)
// 13i+0 = diameter
// 13i+1 = speed
// 13i+2 = race
// 13i+3 = health
// 13i+4 = x
// 13i+5 = y
// 13i+6 = source field
// 13i+7 = destination field
// 13i+8 = maximum health
// 13i+9 = minimum health
// 13i+10 = money
// 13i+11 = remaining time (for step calculation)
// 13i+12 = direction (0=right, 1=bottom)
private final int[] critters = new int[CR_SIZE*MAX_CRITTERS];

// Game State
private final int[] gameState = new int[FIELD_SIZE];

// Timer
private long lastUpdateTime;

private BufferedImage offscreen;

public Critters4k()
{/*A default constructor is always present!*/}

@Override
public void start()
{
	setFocusable(true);
	enableEvents(AWTEvent.MOUSE_MOTION_EVENT_MASK | AWTEvent.MOUSE_EVENT_MASK | AWTEvent.KEY_EVENT_MASK);
	offscreen = new BufferedImage(W, H, BufferedImage.TYPE_INT_ARGB);
}

private void computeAllShortestPaths()
{
	int[] mincost = new int[2*FIELD_SIZE];
	// initialize all fields minimum costs and predecessors
	for (int i = 0; i < 2*FIELD_SIZE; i++)
	{
		mincost[i] = INFINITE_COST;
		predecessor[i] = -1;
	}
	// the costs for the target field(s) are zero (to move to itself)
	// the initialization is a hack, to allow creeps to exit at all exit fields
	for (int i = 9; i <= 15; i++)
	{
		mincost[i*FIELD_WIDTH+FIELD_WIDTH-1] = 0;
		predecessor[i*FIELD_WIDTH+FIELD_WIDTH-1] = -2;
	}
	for (int i = 11; i <= 17; i++)
	{
		mincost[FIELD_SIZE+i+FIELD_WIDTH*(FIELD_HEIGHT-1)] = 0;
		predecessor[FIELD_SIZE+i+FIELD_WIDTH*(FIELD_HEIGHT-1)] = -3;
	}
	
	// Bellman-Ford shortest paths, including movement cost calculation
	for (int k = 0; k < FIELD_SIZE; k++)
	{
		for (int i = 0; i < 2*FIELD_SIZE; i++)
			for (int rx = -1; rx <= 1; rx++)
				for (int ry = -1; ry <= 1; ry++)
				{
					int i0 = i % FIELD_SIZE;
					if ((rx == 0) && (ry == 0)) continue;
					int ix = i0 % FIELD_WIDTH;
					int iy = i0 / FIELD_WIDTH;
					int jx = ix+rx;
					int jy = iy+ry;
					// check if j is out of bounds
					if ((jx < 0) || (jx > FIELD_WIDTH-1) || (jy < 0) || (jy > FIELD_HEIGHT-1)) continue;
					int j0 = jy*FIELD_WIDTH+jx;
					int j = j0+(i-i0);
					int cost = INFINITE_COST;
					// movement is only possible if source AND target fields are empty
					if ((map[i0] == 0) && (map[j0] == 0))
					{
						if ((rx == 0) || (ry == 0)) // horizontal or vertical movement
							cost = 10;
						else
						{ // diagonal movement
							// creeps can only go diagonal if all 4 corners are empty
							if ((map[i0-ix+jx] == 0) && (map[j0-jx+ix] == 0))
								cost = 19;
						}
					}
					if (cost != INFINITE_COST)
					{
						// relax target fields minimum costs if possible
						if (mincost[i]+cost < mincost[j])
						{
							mincost[j] = mincost[i]+cost;
							predecessor[j] = i;
						}
					}
				}
	}
}

// I'd love to avoid overriding both methods, but couldn't get it to work properly.
@Override
public void update(Graphics g)
{ paint(g); }

@Override
public void paint(Graphics u)
{
	Graphics2D g = (Graphics2D) offscreen.getGraphics();
	
	if (gameState[GAME_STATE] == STATE_INIT)
	{
		// initialize data
		gameState[GAME_LIVES] = 20;
		gameState[GAME_MONEY] = 100;
		gameState[GAME_LEVEL] = 0;
		gameState[GAME_CRITTER_COUNT] = 0;
		gameState[GAME_TIMER] = NEXT_LEVEL_TIME;
		gameState[GAME_SELECT] = MAP_TOWER_SIMPLE;
		
		// initialize map (border is part of the map to simplify the code)
		for (int i = 0; i < FIELD_SIZE; i++)
			map[i] = 0;
		for (int i = 0; i < FIELD_WIDTH; i++)
		{
			if ((i >= 11) && (i <= 17)) continue;
			map[i] = MAP_BORDER;
			map[(FIELD_HEIGHT-1)*FIELD_WIDTH+i] = MAP_BORDER;
		}
		for (int i = 0; i < FIELD_HEIGHT; i++)
		{
			if ((i >= 9) && (i <= 15)) continue;
			map[i*FIELD_WIDTH] = MAP_BORDER;
			map[i*FIELD_WIDTH+FIELD_WIDTH-1] = MAP_BORDER;
		}
		
		// initially compute shortest paths
		computeAllShortestPaths();
		
		// start game
		gameState[GAME_STATE] = STATE_PREPARE;
	}
	
	long currentTime;
	do
	{
		if (CALL_SLEEP_INSTEAD_OF_YIELD)
		{
			try
			{
				Thread.sleep(TIME_STEP/4);
			}
			catch (Exception e)
			{/*IGNORED*/}
		}
		else
			Thread.yield();
		currentTime = System.currentTimeMillis();
	}
	while (currentTime-lastUpdateTime < TIME_STEP);
	
	if (ANTIALIASING)
		g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	
	// erase background
	g.setColor(new Color(201, 188, 145));
	g.fillRect(0, 0, W, H);
	
	// display score, lives, and money
	g.setColor(Color.BLACK);
	g.drawString(Integer.toString(gameState[GAME_SCORE]), SCORE_X, SCORE_Y);
	g.drawString(Integer.toString(gameState[GAME_LIVES]), LIVES_X, LIVES_Y);
	g.drawString(Integer.toString(gameState[GAME_MONEY]), MONEY_X, MONEY_Y);
	
	g.setColor(Color.RED);
	g.fillOval(LIVES_X-18, LIVES_Y-14+3, 14, 14);
	g.setColor(Color.DARK_GRAY);
	g.drawOval(LIVES_X-18, LIVES_Y-14+3, 14, 14);
	
	for (int i = 0; i < 2; i++)
	{
		g.setColor(Color.YELLOW);
		g.fillOval(MONEY_X-20+2*i, MONEY_Y-14+1+3*i, 14, 14);
		g.setColor(Color.DARK_GRAY);
		g.drawOval(MONEY_X-20+2*i, MONEY_Y-14+1+3*i, 14, 14);
	}
	
	// draw field with towers
	for (int i = 0; i < FIELD_SIZE; i++)
	{
		int type = map[i];
		int ix = DRAW_SIZE*(i % FIELD_WIDTH)+X_OFFSET;
		int iy = DRAW_SIZE*(i / FIELD_WIDTH)+Y_OFFSET;
		if (type >= MAP_TOWER_FIRST)
		{
			g.setColor(Color.LIGHT_GRAY);
			g.fillRect(ix+1, iy+1, 2*DRAW_SIZE-2, 2*DRAW_SIZE-2);
			g.setColor(Color.BLACK);
			g.drawRect(ix+1, iy+1, 2*DRAW_SIZE-3, 2*DRAW_SIZE-3);
			for (int j = 0; j < towers[TW_SIZE*i+TW_LEVEL]; j++)
				g.fillRect(ix+3+4*j, iy+2*DRAW_SIZE-6, 3, 3);
		}
		g.setColor(Color.DARK_GRAY);
		if (type == MAP_BORDER)
			g.fillRect(ix, iy, DRAW_SIZE, DRAW_SIZE);
		if (type == MAP_TOWER_BOOSTER)
		{
			g.fillRect(ix+7, iy+12, 14, 4);
			g.fillRect(ix+12, iy+7, 4, 14);
		}
		if (type == MAP_TOWER_ANTIAIR)
		{
			g.fillRect(ix+11, iy+7, 1, 14);
			g.fillRect(ix+13, iy+7, 2, 14);
			g.fillRect(ix+16, iy+7, 1, 14);
		}
		if (type == MAP_TOWER_ANTIGROUND)
			g.fillOval(ix+7, iy+7, 13, 13);
	}
	
	// draw ground critters
	for (int i = 0; i < gameState[GAME_CRITTER_COUNT]; i++)
	{
		int ix = critters[CR_SIZE*i+CR_X];
		int iy = critters[CR_SIZE*i+CR_Y];
		int diameter = critters[CR_SIZE*i+CR_DIAMETER];
		int race = critters[CR_SIZE*i+CR_RACE];
		if (race != RACE_FLYING)
		{
			if (race == RACE_NORMAL)
				g.setColor(Color.BLUE);
			else if (race == RACE_FAST)
				g.setColor(Color.ORANGE);
			else //if (race == RACE_STRONG)
				g.setColor(Color.BLACK);
			g.fillOval(ix, iy, diameter, diameter);
		}
//		g.setColor(Color.DARK_GRAY);
//		g.drawOval(ix, iy, diameter-1, diameter-1);
	}
	// draw flying critters
	g.setColor(Color.YELLOW);
	for (int i = 0; i < gameState[GAME_CRITTER_COUNT]; i++)
	{
		int diameter = critters[CR_SIZE*i+CR_DIAMETER];
		if (critters[CR_SIZE*i+CR_RACE] == RACE_FLYING)
		{
			if (critters[CR_SIZE*i+CR_DIRECTION] == 0)
				for (int j = 0; j < 2*diameter; j++)
					g.fillRect(critters[CR_SIZE*i+CR_X]+j, critters[CR_SIZE*i+CR_Y]+j/4, 1, diameter-2*(j/4));
			else
				for (int j = 0; j < 2*diameter; j++)
					g.fillRect(critters[CR_SIZE*i+CR_X]+j/4, critters[CR_SIZE*i+CR_Y]+j, diameter-2*(j/4), 1);
		}
	}
	
	// draw shots
	for (int i = 0; i < FIELD_SIZE; i++)
	{
		int type = map[i];
		int target = towers[TW_SIZE*i+TW_TARGET];
		if ((type >= MAP_TOWER_SIMPLE) && (target >= 0))
		{
			int ix = DRAW_SIZE*(i % FIELD_WIDTH)+DRAW_SIZE+X_OFFSET;
			int iy = DRAW_SIZE*(i / FIELD_WIDTH)+DRAW_SIZE+Y_OFFSET;
			int radius = critters[CR_SIZE*target+CR_DIAMETER]/2;
			int dx = critters[CR_SIZE*target+CR_X]+radius;
			int dy = critters[CR_SIZE*target+CR_Y]+radius;
			int time = towers[TW_SIZE*i+TW_TIME];
			int maxtime = towers[TW_SIZE*i+TW_MAX_TIME];
			int sx = (time*ix+(maxtime-time)*dx)/maxtime;
			int sy = (time*iy+(maxtime-time)*dy)/maxtime;
			g.setColor(Color.BLACK);
			g.fillOval(sx-2, sy-2, 5, 5);
		}
	}
	
	// draw health meter
	for (int i = 0; i < gameState[GAME_CRITTER_COUNT]; i++)
	{
		int ix = critters[CR_SIZE*i+CR_X];
		int iy = critters[CR_SIZE*i+CR_Y];
		int diameter = critters[CR_SIZE*i+CR_DIAMETER];
		int maxhealth = critters[CR_SIZE*i+CR_MAX_HEALTH];
		int health = (diameter*critters[CR_SIZE*i+CR_HEALTH]+maxhealth-1)/maxhealth;
		g.setColor(Color.RED);
		g.fillRect(ix, iy-5, diameter, 2);
		g.setColor(Color.GREEN);
		g.fillRect(ix, iy-5, health, 2);
	}
	
	// draw mouse selector
	int selected = -1;
	int ox = gameState[GAME_OX], oy = gameState[GAME_OY];
	if ((ox > 0) && (ox < FIELD_WIDTH-2) && (oy > 0) && (oy < FIELD_HEIGHT-2))
	{
		g.setColor(Color.RED);
		g.drawRect(ox*DRAW_SIZE+X_OFFSET+1, oy*DRAW_SIZE+Y_OFFSET+1, 2*DRAW_SIZE-3, 2*DRAW_SIZE-3);
		int index = oy*FIELD_WIDTH+ox;
		int towerlevel = towers[TW_SIZE*index+TW_LEVEL];
		if (map[index] >= MAP_TOWER_FIRST)
		{
			selected = map[index];
			long basecost = selected == MAP_TOWER_SIMPLE ? TOWER_SIMPLE_COST : (selected == MAP_TOWER_BOOSTER ? TOWER_BOOSTER_COST : TOWER_ANTIAIR_COST);
			int worth = (int) ((basecost >> (10*towerlevel)) & 0x3ff);
			int upgradecost = (int) ((basecost >> (10*towerlevel+10)) & 0x3ff)-worth;
			g.setColor(Color.BLACK);
			if (upgradecost > 0)
			{
				g.drawString("upgrade:", STATUS_X_OFFSET, STATUS_Y_OFFSET);
				g.drawString(Integer.toString(upgradecost), STATUS_X_OFFSET+60, STATUS_Y_OFFSET);
			}
			g.drawString("value:", STATUS_X_OFFSET, STATUS_Y_OFFSET+40);
			g.drawString(Integer.toString(worth), STATUS_X_OFFSET+60, STATUS_Y_OFFSET+40);
			if (selected >= MAP_TOWER_SIMPLE)
			{
				int damage = (towerlevel+1)*(towerlevel+1)*(selected == MAP_TOWER_SIMPLE ? 1 : 4);
				int additionaldamage = 0;
				for (int rx = -2; rx <= 2; rx++)
					for (int ry = -2; ry <= 2; ry++)
					{
						int tempindex = index+rx+ry*FIELD_WIDTH;
						// hack: this check && (tempindex < TW_SIZE*FIELD_SIZE) isn't necessary
						if ((tempindex >= 0) && (map[tempindex] == MAP_TOWER_BOOSTER))
							additionaldamage += towers[TW_SIZE*tempindex+TW_LEVEL]+1;
					}
				additionaldamage = (additionaldamage*damage+9)/10;
				g.drawString("damage:", STATUS_X_OFFSET, STATUS_Y_OFFSET+60);
				g.drawString(Integer.toString(damage), STATUS_X_OFFSET+60, STATUS_Y_OFFSET+60);
				g.drawString("+", STATUS_X_OFFSET+100, STATUS_Y_OFFSET+60);
				g.drawString(Integer.toString(additionaldamage), STATUS_X_OFFSET+110, STATUS_Y_OFFSET+60);
				
				// show radius
				int radius = (int) ((TOWER_SIMPLE_RADIUS >> (8*towerlevel)) & 0xff);
				if (SHOW_RADIUS_AS_TEXT)
				{
					g.drawString("radius:", STATUS_X_OFFSET, STATUS_Y_OFFSET+80);
					g.drawString(Integer.toString(radius), STATUS_X_OFFSET+60, STATUS_Y_OFFSET+80);
				}
				g.setColor(Color.YELLOW);
				g.drawOval(ox*DRAW_SIZE+X_OFFSET+DRAW_SIZE-radius, oy*DRAW_SIZE+DRAW_SIZE+Y_OFFSET-radius, 2*radius, 2*radius);
			}
		}
	}
	
	if (selected == -1)
	{
		selected = gameState[GAME_SELECT];
		long basecost = selected == MAP_TOWER_SIMPLE ? TOWER_SIMPLE_COST : (selected == MAP_TOWER_BOOSTER ? TOWER_BOOSTER_COST : TOWER_ANTIAIR_COST);
		int cost = (int) (basecost & 0x3ff);
		g.setColor(Color.BLACK);
		g.drawString("build:", STATUS_X_OFFSET, STATUS_Y_OFFSET);
		g.drawString(Integer.toString(cost), STATUS_X_OFFSET+60, STATUS_Y_OFFSET);
	}
	
	// draw tower selector
	for (int i = MAP_TOWER_FIRST; i <= MAP_TOWER_LAST; i++)
	{
		String text = "1: booster";
		if (i == MAP_TOWER_SIMPLE) text = "2: normal";
		if (i == MAP_TOWER_ANTIAIR) text = "3: anti-air";
		if (i == MAP_TOWER_ANTIGROUND) text = "4: anti-ground";
		int x = SELECT_X_OFFSET;
		int y = SELECT_Y_OFFSET+20*(i-MAP_TOWER_FIRST);
		if (selected == i)
		{
			g.setColor(Color.RED);
			g.fillRect(x, y-15, W-x, 15);
		}
		g.setColor(Color.BLACK);
		g.drawString(text, x+3, y-3);
	}
	
	// draw level indicator
	// set a larger font for level numbers
	Font normalFont = g.getFont();
	Font bigFont = normalFont.deriveFont(Font.BOLD, 25);
	for (int level = 0; level < MAX_LEVEL; level++)
	{
		if (level < gameState[GAME_LEVEL]-2) continue;
		if (level > gameState[GAME_LEVEL]+7) continue;
		
		int boss = (level % 5)/4;
		int race = ((boss == 0 ? level % 5 : level/5) +1)%4;
		int health = (1+9*boss)*(1+(level/5)*(level/5)*(level/5));
		int money = (1+9*boss)*(1+(level/5));
		
		if (race == RACE_NORMAL)
			g.setColor(Color.BLUE);
		else if (race == RACE_FAST)
			g.setColor(Color.ORANGE);
		else if (race == RACE_STRONG)
			g.setColor(Color.BLACK);
		else if (race == RACE_FLYING)
			g.setColor(Color.YELLOW);
		int x = X_OFFSET+100*(level-gameState[GAME_LEVEL])+(100*gameState[GAME_TIMER])/NEXT_LEVEL_TIME;
		g.fillRect(x, LEVEL_Y_OFFSET, 100, 50);
		g.setColor(Color.DARK_GRAY);
		g.drawRect(x, LEVEL_Y_OFFSET, 100, 50);
		
		// draw level number
		g.setColor(Color.LIGHT_GRAY);
		String text = Integer.toString(level+1);
		g.setFont(bigFont);
		g.drawString(text, x+50-g.getFontMetrics().stringWidth(text)/2, LEVEL_Y_OFFSET+34);
		
		// draw health and money info
		g.setFont(normalFont);
		if (boss == 1)
		{
			text = "boss";
			g.drawString(text, x+50-g.getFontMetrics().stringWidth(text)/2, LEVEL_Y_OFFSET+46);
		}
		g.drawString(Integer.toString(health), x+2, LEVEL_Y_OFFSET+12);
		g.drawString(Integer.toString(money), x+2, LEVEL_Y_OFFSET+48);
	}
	g.setColor(Color.BLACK);
	g.drawString("(space)", X_OFFSET, LEVEL_Y_OFFSET-5);
	// next level frame
	g.setColor(Color.RED);
	g.drawRect(X_OFFSET, LEVEL_Y_OFFSET, 100, 50);
	
	// skip frames if the last update was too long ago
	if (lastUpdateTime < currentTime-5*TIME_STEP)
	{
		lastUpdateTime = currentTime;
	}
	
	// output loose/win text
	if (gameState[GAME_STATE] == STATE_LOST)
	{
		g.setFont(bigFont);
		g.drawString("You lost!", X_OFFSET, FIELD_HEIGHT*DRAW_SIZE+Y_OFFSET+30);
	}
	if (gameState[GAME_STATE] == STATE_WON)
	{
		g.setFont(bigFont);
		g.drawString("Yay! You did it!", X_OFFSET, FIELD_HEIGHT*DRAW_SIZE+Y_OFFSET+30);
	}
	
	// update creeps and towers
	if (gameState[GAME_STATE] == STATE_RUNNING)
	{
		while (lastUpdateTime < currentTime)
		{
			// update towers
			for (int i = 0; i < FIELD_SIZE; i++)
			{
				int type = map[i];
				if (type >= MAP_TOWER_SIMPLE)
				{
					int ix = DRAW_SIZE*(i % FIELD_WIDTH)+DRAW_SIZE+X_OFFSET;
					int iy = DRAW_SIZE*(i / FIELD_WIDTH)+DRAW_SIZE+Y_OFFSET;
					if (towers[TW_SIZE*i+TW_TARGET] < 0)
					{
						int towerlevel = towers[TW_SIZE*i+TW_LEVEL];
						int radius = (int) ((TOWER_SIMPLE_RADIUS >> (8*towerlevel)) & 0xff);
						for (int j = 0; j < gameState[GAME_CRITTER_COUNT]; j++)
						{
							if ((type == MAP_TOWER_ANTIAIR) && (critters[CR_SIZE*j+CR_RACE] != RACE_FLYING))
								continue;
							if ((type == MAP_TOWER_ANTIGROUND) && (critters[CR_SIZE*j+CR_RACE] == RACE_FLYING))
								continue;
							int diameter = critters[CR_SIZE*j+CR_DIAMETER];
							int jx = critters[CR_SIZE*j+CR_X]+diameter/2;
							int jy = critters[CR_SIZE*j+CR_Y]+diameter/2;
							int d = (jx-ix)*(jx-ix)+(jy-iy)*(jy-iy);
							if ((d < radius*radius) && (critters[CR_SIZE*j+CR_MIN_HEALTH] > 0))
							{
								// calculate damage
								int damage = (towerlevel+1)*(towerlevel+1)*(type == MAP_TOWER_SIMPLE ? 1 : 4);
								int additionaldamage = 0;
								for (int rx = -2; rx <= 2; rx++)
									for (int ry = -2; ry <= 2; ry++)
									{
										int tempindex = i+rx+ry*FIELD_WIDTH;
										// hack: this check && (tempindex < TW_SIZE*FIELD_SIZE) isn't necessary
										if ((tempindex >= 0) && (map[tempindex] == MAP_TOWER_BOOSTER))
											additionaldamage += towers[TW_SIZE*tempindex+TW_LEVEL]+1;
									}
								additionaldamage = (additionaldamage*damage+9)/10;
								damage += additionaldamage;
								
								if (critters[CR_SIZE*j+CR_RACE] == RACE_STRONG)
									damage = damage > STRONG_MINDAMAGE ? damage-STRONG_MINDAMAGE : 0;
								int time = (int) (400*Math.sqrt(d)/radius);
								critters[CR_SIZE*j+CR_MIN_HEALTH] -= damage;
								towers[TW_SIZE*i+TW_TARGET] = j;
								towers[TW_SIZE*i+TW_TIME] = time;
								towers[TW_SIZE*i+TW_MAX_TIME] = time;
								towers[TW_SIZE*i+TW_DAMAGE] = damage;
								break;
							}
						}
					}
					else
					{
						towers[TW_SIZE*i+TW_TIME] -= TIME_STEP;
						if (towers[TW_SIZE*i+TW_TIME] <= 0)
						{
							critters[CR_SIZE*towers[TW_SIZE*i+TW_TARGET]+CR_HEALTH] -= towers[TW_SIZE*i+TW_DAMAGE];
							towers[TW_SIZE*i+TW_TARGET] = -1;
						}
					}
				}
			}
			
			// move critters
			int newCritterCount = 0;
			for (int i = 0; i < gameState[GAME_CRITTER_COUNT]; i++)
			{
				int ix = critters[CR_SIZE*i+CR_X];
				int iy = critters[CR_SIZE*i+CR_Y];
				
				int timeElapsed = TIME_STEP+critters[CR_SIZE*i+CR_TIME_REMAINING];
				while (timeElapsed > 0)
				{
					int destination = critters[CR_SIZE*i+CR_DESTINATION];
					int dx, dy;
					if (destination == -2)
					{
						dx = DRAW_SIZE*FIELD_WIDTH+2*X_OFFSET;
						dy = iy;
					}
					else if (destination == -3)
					{
						dx = ix;
						dy = DRAW_SIZE*FIELD_HEIGHT+2*Y_OFFSET;
					}
					else
					{
						dx = DRAW_SIZE*(destination % FIELD_WIDTH)+X_OFFSET;
						dy = DRAW_SIZE*((destination % FIELD_SIZE) / FIELD_WIDTH)+Y_OFFSET;
					}
					int diameter = critters[CR_SIZE*i+CR_DIAMETER];
					if ((ix >= dx) && (ix <= dx+DRAW_SIZE-diameter) &&
						(iy >= dy) && (iy <= dy+DRAW_SIZE-diameter))
					{
						int next = destination < 0 ? -4 : predecessor[destination];
						critters[CR_SIZE*i+CR_SOURCE] = critters[CR_SIZE*i+CR_DESTINATION];
						critters[CR_SIZE*i+CR_DESTINATION] = next;
						if (next == -4) timeElapsed = 0;
					}
					else
					{
						int steps = 0;
						if (ix < dx) { ix++; steps++; }
						else if (ix > dx+DRAW_SIZE-diameter) { ix--; steps++; }
						if (iy < dy) { iy++; steps++; }
						else if (iy > dy+DRAW_SIZE-diameter) { iy--; steps++; }
						timeElapsed -= ((steps-1)*41+100)*critters[CR_SIZE*i+CR_SPEED]/100;
					}
				}
				critters[CR_SIZE*i+CR_TIME_REMAINING] = timeElapsed;
				
				critters[CR_SIZE*i+CR_X] = ix;
				critters[CR_SIZE*i+CR_Y] = iy;
				
				// remove unused creeps by compressing the data array
				int newindex = -1;
				if ((critters[CR_SIZE*i+CR_HEALTH] > 0) && (critters[CR_SIZE*i+CR_DESTINATION] != -4))
				{
					newindex = newCritterCount;
					for (int k = 0; k < CR_SIZE; k++)
						critters[CR_SIZE*newCritterCount+k] = critters[CR_SIZE*i+k];
					newCritterCount++;
				}
				else
				{
					// update money or lives
					if (critters[CR_SIZE*i+CR_HEALTH] <= 0)
					{
						gameState[GAME_MONEY] += critters[CR_SIZE*i+CR_MONEY];
						gameState[GAME_SCORE] += critters[CR_SIZE*i+CR_MONEY];
					}
					else
						gameState[GAME_LIVES]--;
				}
				for (int k = 0; k < FIELD_SIZE; k++)
					if (towers[TW_SIZE*k+TW_TARGET] == i) towers[TW_SIZE*k+TW_TARGET] = newindex;
			}
			
			// create new critters when the timer runs out
			if (gameState[GAME_TIMER] <= 0)
			{
				int level = gameState[GAME_LEVEL];
				// every other level is a boss
				// race changes every other level
				// boss critters are stronger and give more money
				int boss = (level % 5)/4;
				int race = ((boss == 0 ? level % 5 : level/5) +1)%4;
				int health = (1+9*boss)*(1+(level/5)*(level/5)*(level/5));
				int money = (1+9*boss)*(1+(level/5));
				
				for (int i = 0; i < (20-18*boss); i++)
				{
					int ystart = 9+(level*20+i) % 7; // start y position between 9 and 15 (inclusive)
					if (boss == 1) ystart = 12;
					int index = CR_SIZE*newCritterCount;
					critters[index+CR_DIAMETER] = 11+2*boss;
					critters[index+CR_SPEED] = race == RACE_FLYING ? 1000/30 : 1000/(30+55*race); // in ms / pixel
					critters[index+CR_RACE] = race;
					critters[index+CR_HEALTH] = health;
					
					critters[index+CR_DIRECTION] = i % 2;
					if (i % 2 == 0)
					{
						critters[index+CR_X] = -DRAW_SIZE-i*DRAW_SIZE;
						critters[index+CR_Y] = ystart*DRAW_SIZE+Y_OFFSET;
						critters[index+CR_SOURCE] = ystart*FIELD_WIDTH;
						critters[index+CR_DESTINATION] = ystart*FIELD_WIDTH+(race == RACE_FLYING ? FIELD_WIDTH-1 : 0);
					}
					else
					{
						ystart += 2;
						critters[index+CR_X] = ystart*DRAW_SIZE+X_OFFSET;
						critters[index+CR_Y] = -DRAW_SIZE-i*DRAW_SIZE;
						critters[index+CR_SOURCE] = ystart+FIELD_SIZE;
						critters[index+CR_DESTINATION] = ystart+(race == RACE_FLYING ? FIELD_WIDTH*(FIELD_HEIGHT-1) : 0)+FIELD_SIZE;
					}
					
					critters[index+CR_MAX_HEALTH] = health;
					critters[index+CR_MIN_HEALTH] = health;
					critters[index+CR_MONEY] = money;
					newCritterCount++;
				}
				
				// next level in 25 seconds
				gameState[GAME_LEVEL]++;
				gameState[GAME_TIMER] = NEXT_LEVEL_TIME;
			}
			
			gameState[GAME_CRITTER_COUNT] = newCritterCount;
			
			// update time
			lastUpdateTime += TIME_STEP;
			gameState[GAME_TIMER] -= TIME_STEP;
			if (gameState[GAME_LEVEL] > MAX_LEVEL-1)
			{
				gameState[GAME_TIMER] = NEXT_LEVEL_TIME;
				if (newCritterCount == 0)
					gameState[GAME_STATE] = STATE_WON;
			}
		}
	}
	else
		lastUpdateTime = currentTime;
	
	if (gameState[GAME_LIVES] <= 0)
		gameState[GAME_STATE] = STATE_LOST;
	
	u.drawImage(offscreen, 0, 0, this);
	repaint();
}

@Override
protected void processEvent(AWTEvent f)
{
	if (f.getID() == KeyEvent.KEY_PRESSED)
	{
		KeyEvent e = (KeyEvent) f;
		int key = e.getKeyCode();
		if (key == KeyEvent.VK_SPACE)
		{
			if (gameState[GAME_STATE] == STATE_PREPARE)
				gameState[GAME_STATE] = STATE_RUNNING;
			if (gameState[GAME_LEVEL] < MAX_LEVEL)
			{
				gameState[GAME_SCORE] += (gameState[GAME_LEVEL]*20*gameState[GAME_TIMER])/NEXT_LEVEL_TIME;
				gameState[GAME_TIMER] = 0;
			}
		}
		if (key == KeyEvent.VK_BACK_SPACE)
			gameState[GAME_STATE] = STATE_INIT;
		if ((key >= KeyEvent.VK_1) && (key <= KeyEvent.VK_1+MAP_TOWER_LAST-MAP_TOWER_FIRST))
			gameState[GAME_SELECT] = key-KeyEvent.VK_1+MAP_TOWER_FIRST;
	}
	else if (f instanceof MouseEvent)
	{
		MouseEvent e = (MouseEvent) f;
		int ox = (e.getX()-X_OFFSET-DRAW_SIZE/2)/DRAW_SIZE;
		int oy = (e.getY()-Y_OFFSET-DRAW_SIZE/2)/DRAW_SIZE;
		int index = oy*FIELD_WIDTH+ox;
		gameState[GAME_OX] = ox;
		gameState[GAME_OY] = oy;
		// only continue if this is a valid tower position
		if ((ox > 0) && (ox < FIELD_WIDTH-2) && (oy > 0) && (oy < FIELD_HEIGHT-2))
		{
			if ((f.getID() == MouseEvent.MOUSE_PRESSED) && (gameState[GAME_STATE] <= STATE_RUNNING))
			{
				if (e.getButton() == MouseEvent.BUTTON1)
				{
					// set a new tower
					// check if it is allowed to set a tower here
					// ox and oy must be in bounds
					// and the map at all four fields must be empty
					int selected = gameState[GAME_SELECT];
					long basecost = selected == MAP_TOWER_SIMPLE ? TOWER_SIMPLE_COST : (selected == MAP_TOWER_BOOSTER ? TOWER_BOOSTER_COST : TOWER_ANTIAIR_COST);
					int cost = (int) (basecost & 0x3ff);
					if ((map[index] == 0) && (map[index+1] == 0) &&
					    (map[index+FIELD_WIDTH] == 0) && (map[index+FIELD_WIDTH+1] == 0) &&
					    (gameState[GAME_MONEY] >= cost))
					{
						map[index] = selected;
						map[index+1] = MAP_RESERVED;
						map[index+FIELD_WIDTH] = MAP_RESERVED;
						map[index+FIELD_WIDTH+1] = MAP_RESERVED;
						towers[TW_SIZE*index+TW_TARGET] = -1;
						towers[TW_SIZE*index+TW_LEVEL] = 0;
						computeAllShortestPaths();
						
						boolean invalid = false;
						// it's not allowed to shut in creeps (or build on top of them)
						for (int i = 0; i < gameState[GAME_CRITTER_COUNT]; i++)
						{
							if ((critters[CR_SIZE*i+CR_DESTINATION] >= 0) &&
							    ((predecessor[critters[CR_SIZE*i+CR_SOURCE]] == -1) ||
							     (predecessor[critters[CR_SIZE*i+CR_DESTINATION]] == -1)))
								invalid = true;
						}
						// it's not allowed to block the path from the entrance
						if (predecessor[SOURCE_Y*FIELD_WIDTH+SOURCE_X] == -1)
							invalid = true;
						if (predecessor[SOURCE2_Y*FIELD_WIDTH+SOURCE2_X+FIELD_SIZE] == -1)
							invalid = true;
						
						if (invalid)
						{ // if building a tower here is illegal, remove it and update the shortest paths
							map[index] = 0;
							map[index+1] = 0;
							map[index+FIELD_WIDTH] = 0;
							map[index+FIELD_WIDTH+1] = 0;
							computeAllShortestPaths();
						}
						else
						{
							gameState[GAME_MONEY] -= cost;
						}
					}
					else if (map[index] >= MAP_TOWER_FIRST)
					{
						selected = map[index];
						basecost = selected == MAP_TOWER_SIMPLE ? TOWER_SIMPLE_COST : (selected == MAP_TOWER_BOOSTER ? TOWER_BOOSTER_COST : TOWER_ANTIAIR_COST);
						int towerlevel = towers[TW_SIZE*index+TW_LEVEL];
						int upgradecost = (int) ((basecost >> (10*towerlevel+10)) & 0x3ff)-
							(int) ((basecost >> (10*towerlevel)) & 0x3ff);
						if ((upgradecost > 0) && (gameState[GAME_MONEY] >= upgradecost))
						{
							towers[TW_SIZE*index+TW_LEVEL]++;
							gameState[GAME_MONEY] -= upgradecost;
						}
					}
				}
				else
				{
					// remove a tower
					// ox and oy must be in bounds
					// and the map at the top left corner must be a tower
					int selected = map[index];
					if (selected >= MAP_TOWER_FIRST)
					{
						int towerlevel = towers[TW_SIZE*index+TW_LEVEL];
						long basecost = selected == MAP_TOWER_SIMPLE ? TOWER_SIMPLE_COST : (selected == MAP_TOWER_BOOSTER ? TOWER_BOOSTER_COST : TOWER_ANTIAIR_COST);
						int cost = (int) ((basecost >> (10*towerlevel)) & 0x3ff);
						gameState[GAME_MONEY] += cost;
						map[index] = 0;
						map[index+1] = 0;
						map[index+FIELD_WIDTH] = 0;
						map[index+FIELD_WIDTH+1] = 0;
						if (towers[TW_SIZE*index+TW_TARGET] >= 0)
							critters[CR_SIZE*towers[TW_SIZE*index+TW_TARGET]+CR_MIN_HEALTH] += towers[TW_SIZE*index+TW_DAMAGE];
						towers[TW_SIZE*index+TW_TARGET] = -1;
						computeAllShortestPaths();
					}
				}
			}
		}
	}
	
	if (REPAINT_AFTER_EVENT) repaint();
}

}
