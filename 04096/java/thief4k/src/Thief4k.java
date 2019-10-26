/*
 * Copyright (c) 2008 Ulf Ochsenfahrt <ulf@ofahrt.de>
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

import java.awt.AWTEvent;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.MouseEvent;
import java.awt.geom.Arc2D;
import java.awt.geom.Area;
import java.awt.geom.Ellipse2D;
import java.awt.geom.GeneralPath;

import javax.swing.JComponent;
import javax.swing.JFrame;

@SuppressWarnings({"serial","deprecation","static-access"})
public final class Thief4k extends JComponent
{

public static final boolean ANTIALIASING = true;
public static final boolean TRANSPARENCY = true;
public static final boolean SHOW_TAGLINE = true; // disabling this save 76 bytes
public static final String TAGLINE = "Steal the loot and escape unseen!";
public static final String WIN_LINE = "You are the master thief!";

public static final int W = 640;
public static final int H = 480;

// 20 px => 1 m
public static final int RADIUS = 5; // player/guard radius in pixel
public static final int PICKUP_DISTANCE = 10;
public static final int DRAW_RADIUS = 4; // player/guard image radius in pixel ~ 0.4 m
public static final int VELOCITY = 80; // pixel / second ~ 4 m/s
public static final int TIME_STEP = 1000/VELOCITY;
public static final int MAX_VISIBILITY = 200; // ~ 10 m
public static final int ANGLE = 80; // 80 degree
public static final float PI = (float) Math.PI; // 180 degree

public static final int ESCAPE_VERTEX = 0; // vertex index
public static final int LOOT_VERTEX   = 1; // vertex index
public static final int SWITCH_VERTEX = 2; // vertex index

public static final int GUARD_SIZE = 4; // size of one guard key-frame

public static final int MAX_LEVEL = 5; // at least 1, at most 25
public static final int COLUMNS = 5; // at least 1, at most 5

// game state
public static final int STATE_START  = 0;
public static final int STATE_LOOT   = 1;
public static final int STATE_CAUGHT_NO_LOOT = 2;
public static final int STATE_CAUGHT_WITH_LOOT = 3;
public static final int STATE_STATUS = 4;

// segment flags
public static final int FLAG_DOOR = 1;

// guard types
public static final int GTYPE_NORMAL = 0;
public static final int GTYPE_ON_CAMERA = 1;
public static final int GTYPE_OFF_CAMERA = 3;

// timing
private long start, last;

// level layout
private int[][] vertices; // 2 float each (first vertex = start, second vertex = loot)
private int[][] segments; // 3 int: vertices a,b, flags

// guards
private int[][] guards; // 5n int: deltatime+position+direction for keyframe interpolation
private int[][] gstate; // guard state 2 int: cycle position, time offset

// player
private float atX, atY;
private float toX, toY;
private int state = STATE_STATUS; // must be one of STATE_*
private int level;

public Thief4k()
{
	setPreferredSize(new Dimension(W, H));
	enableEvents(AWTEvent.MOUSE_MOTION_EVENT_MASK | AWTEvent.MOUSE_EVENT_MASK);
}

@Override
public void paint(Graphics u)
{
	Graphics2D g = (Graphics2D) u;
	
	try
	{ Thread.sleep(TIME_STEP); }
	catch (Exception e)
	{/*IGNORED*/}
	
	long now = System.currentTimeMillis();
	if (state >= STATE_CAUGHT_NO_LOOT) now = last;
	
	// enable anti-aliasing
	if (ANTIALIASING)
		g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	
	// fill background
	g.setColor(Color.BLACK);
	g.fillRect(0, 0, 1024, 1024);
	
	// draw status screen
	if (state == STATE_STATUS)
	{
/*		// back lines
		GeneralPath diamondBack = new GeneralPath();
		diamondBack.moveTo(276-323, 246-244); // left
		diamondBack.lineTo(315-323, 220-244); // mid back
		diamondBack.lineTo(371-323, 225-244); // right
		
		diamondBack.moveTo(315-323, 208-244); // top
		diamondBack.lineTo(315-323, 220-244); // mid back
		diamondBack.lineTo(332-323, 280-244); // bottom*/
		
		// outline
		GeneralPath diamondOutline = new GeneralPath();
		diamondOutline.moveTo(276-323, 246-244); // left
		diamondOutline.lineTo(292-323, 224-244); // top left
		diamondOutline.lineTo(315-323, 208-244); // top
		diamondOutline.lineTo(349-323, 211-244); // top right
		diamondOutline.lineTo(371-323, 225-244); // right
		diamondOutline.lineTo(332-323, 280-244); // bottom
		diamondOutline.lineTo(276-323, 246-244); // close outline for drawing
//		diamondOutline.closePath(); // not strictly necessary for filling
		
/*		// front lines
		GeneralPath diamondFront = new GeneralPath();
		diamondFront.moveTo(292-323, 224-244); // top left
		diamondFront.lineTo(326-323, 227-244); // top forward
		diamondFront.lineTo(349-323, 211-244); // top right
		
		diamondFront.moveTo(326-323, 227-244); // top forward
		diamondFront.lineTo(332-323, 251-244); // mid forward
		diamondFront.lineTo(332-323, 280-244); // bottom
		
		diamondFront.moveTo(276-323, 246-244); // left
		diamondFront.lineTo(332-323, 251-244); // mid forward
		diamondFront.lineTo(371-323, 225-244); // right*/
		
		for (int i = 0; i < MAX_LEVEL; i++)
		{
			if (MAX_LEVEL > COLUMNS)
				g.translate((i%COLUMNS+1)*W/(COLUMNS+1),
						(i/COLUMNS+1)*H/((MAX_LEVEL+COLUMNS-1)/COLUMNS+1));
			else
				g.translate((i+1)*W/(MAX_LEVEL+1), H/2);
			
			g.setColor(Color.DARK_GRAY);
			// back lines
			g.drawLine(315-323, 220-244, 276-323, 246-244); // left
			g.drawLine(315-323, 220-244, 371-323, 225-244); // right
			g.drawLine(315-323, 220-244, 315-323, 208-244); // top
			g.drawLine(315-323, 220-244, 332-323, 280-244); // bottom
			
			// outline
			if (i < level)
			{ // fill outline red if level is done
				g.setColor(new Color(1.0f, 0, 0, 0.5f));
				g.fill(diamondOutline);
			}
			g.setColor(Color.LIGHT_GRAY);
			g.draw(diamondOutline);
			
			// front lines
			g.drawLine(326-323, 227-244, 292-323, 224-244); // top left
			g.drawLine(326-323, 227-244, 349-323, 211-244); // top right
			g.drawLine(326-323, 227-244, 332-323, 251-244); // mid forward
			
			g.drawLine(332-323, 251-244, 332-323, 280-244); // bottom
			g.drawLine(332-323, 251-244, 276-323, 246-244); // left
			g.drawLine(332-323, 251-244, 371-323, 225-244); // right
			
			if (MAX_LEVEL > COLUMNS)
				g.translate(-(i%COLUMNS+1)*W/(COLUMNS+1),
						-(i/COLUMNS+1)*H/((MAX_LEVEL+COLUMNS-1)/COLUMNS+1));
			else
				g.translate(-(i+1)*W/(MAX_LEVEL+1), -H/2);
		}
		
		if (SHOW_TAGLINE)
		{
			g.setColor(Color.LIGHT_GRAY);
			g.drawString(TAGLINE, 10, H-10);
		}
		if (level == MAX_LEVEL)
		{
			g.scale(3, 3);
			g.setColor(Color.LIGHT_GRAY);
//			g.drawString(WIN_LINE, 35, 50);
			g.drawString(WIN_LINE, (W-3*g.getFontMetrics().stringWidth(WIN_LINE))/6, 50);
		}
		return;
	}
	
	// draw point light source
	// this unfortunately doesn't work
/*	{
		float px = 120, py = 110;
		p = calculateVisibilitySet(px, py, PI, TWOPI); //0, ANGLE); //PI, TWOPI);
		g.setClip(p);
		for (int radius = 40; radius > 0; radius--)
		{
			g.setColor(new Color(1.0f, 1.0f, 1.0f, 1.0f/radius));
			g.fill(new Ellipse2D.Float(px-2*radius, py-2*radius, 4*radius, 4*radius));
		}
		g.setClip(null);
	}*/
	
	// move self
	while (last+TIME_STEP < now)
	{
		last += TIME_STEP;
		//System.out.println(last);
		//float time = (now-last)/1000.0f;
		// calculate player velocity
		float vx = toX-atX, vy = toY-atY;
		float velocity = (float) Math.sqrt(vx*vx+vy*vy);
		if (velocity > 1)
		{
			vx = vx/velocity;
			vy = vy/velocity;
		}
		atX += vx;
		atY += vy;
		// perform collision detection
		// for every line segment
		for (int j = 0; j < segments.length; j++)
		{
			if ((segments[j][2] & FLAG_DOOR) == 0)
			{
				// (0,0) is the player position
				// (vx,vy) is the (attempted) player movement
				
				// (oax,oay) -> (obx,oby) is the edge
				float oax = vertices[segments[j][0]][0]-atX;
				float oay = vertices[segments[j][0]][1]-atY;
				float obx = vertices[segments[j][1]][0]-atX;
				float oby = vertices[segments[j][1]][1]-atY;
				
				// calculate the normalized edge normal (nx,ny)
				float nx = -(oby-oay), ny = (obx-oax);
				float length = (float) Math.sqrt(nx*nx+ny*ny);
				nx = nx/length; ny = ny/length;
				
				// calculate distance from the edge
				float dist = -(oax*nx+oay*ny);
				// calculate distance along the edge
				float along = -(oax*ny-oay*nx)/length;
				
				if (along < 0)
				{
					float dista = (float) Math.sqrt(oax*oax+oay*oay);
					if (dista < RADIUS)
					{
						//System.out.println(i+" "+j+" from "+atX+" "+atY);
						atX += oax-RADIUS*oax/dista;
						atY += oay-RADIUS*oay/dista;
						//System.out.println("       to "+atX+" "+atY);
					}
				}
				else if (along > 1)
				{
					float distb = (float) Math.sqrt(obx*obx+oby*oby);
					if (distb < RADIUS)
					{
						//System.out.println(i+" "+j+" from "+atX+" "+atY);
						atX += obx-RADIUS*obx/distb;
						atY += oby-RADIUS*oby/distb;
						//System.out.println("       to "+atX+" "+atY);
					}
				}
				else if ((dist >= 0) && (dist < RADIUS))
				{
					//System.out.println(i+" "+j+" from "+atX+" "+atY);
					atX += (RADIUS-dist)*nx;
					atY += (RADIUS-dist)*ny;
					//System.out.println("       to "+atX+" "+atY);
				}
				else if ((dist > -RADIUS) && (dist < 0))
				{
					atX += -(RADIUS+dist)*nx;
					atY += -(RADIUS+dist)*ny;
				}
			}
		}
	}
	
	// move guards
	float time = (now-start)/1000.0f;
	float[][] gposition = new float[gstate.length][3];
	for (int i = 0; i < gstate.length; i++)
	{
		int j = gstate[i][0];
		while (time-gstate[i][1] > guards[i][j])
		{
			gstate[i][1] += guards[i][j];
			j = (j+GUARD_SIZE) % guards[i].length;
		}
		gstate[i][0] = j;
		int k = (j+GUARD_SIZE) % guards[i].length;
		float f = (time-gstate[i][1])/guards[i][j];
		float x = (1-f)*guards[i][j+1]+f*guards[i][k+1];
		float y = (1-f)*guards[i][j+2]+f*guards[i][k+2];
		int sa = guards[i][j+3];
		int sb = guards[i][k+3];
		if (sb-64 >= sa) sb -= 128;
		if (sb+64 < sa) sb += 128;
		float dir = ((1-f)*sa+f*sb)*360.0f/128.0f;
		if (gstate[i][2] == GTYPE_NORMAL)
			dir += (float) Math.sin(2*time)*11.5f;
		
		gposition[i][0] = x;
		gposition[i][1] = y;
		gposition[i][2] = dir;
		
		// compute guard visibility sets
		if (gstate[i][2] == GTYPE_OFF_CAMERA) continue;
		Area visibilitySet = new Area(new Arc2D.Float(x-MAX_VISIBILITY, y-MAX_VISIBILITY, 2*MAX_VISIBILITY, 2*MAX_VISIBILITY,
				-45-dir, ANGLE, Arc2D.PIE));
		for (j = 0; j < segments.length; j++)
		{
			float ax = vertices[segments[j][0]][0]-x;
			float ay = vertices[segments[j][0]][1]-y;
			float bx = vertices[segments[j][1]][0]-x;
			float by = vertices[segments[j][1]][1]-y;
			
			GeneralPath p = new GeneralPath();
			p.moveTo(x+ax, y+ay);
			p.lineTo(x+1000*ax, y+1000*ay);
			p.lineTo(x+1000*bx, y+1000*by);
			p.lineTo(x+bx, y+by);
			p.lineTo(x+ax, y+ay);
			visibilitySet.subtract(new Area(p));
		}
		
		if (TRANSPARENCY)
		{
			if (visibilitySet.contains(atX, atY))
			{
//				if (state == STATE_START) state = STATE_CAUGHT_NO_LOOT;
//				if (state == STATE_LOOT) state = STATE_CAUGHT_WITH_LOOT;
				state = (state % 2)+STATE_CAUGHT_NO_LOOT;
				last = now;
				g.setColor(new Color(1.0f, 0, 0, 0.5f));
			}
			else
				g.setColor(new Color(0, 1.0f, 0, 0.5f));
		}
		else
		{
			if (visibilitySet.contains(atX, atY))
			{
				state = (state % 2)+STATE_CAUGHT_NO_LOOT;
				last = now;
				g.setColor(new Color(0.5f, 0, 0));
			}
			else
				g.setColor(new Color(0, 0.5f, 0));
		}
		g.fill(visibilitySet);
	}
	
	// draw loot
	if ((state % 2) == 0)
	{
		g.setColor(new Color(1.0f, 0, 0, 0.5f));
		int x = vertices[LOOT_VERTEX][0];
		int y = vertices[LOOT_VERTEX][1];
		float d = (float) Math.sqrt((x-atX)*(x-atX)+(y-atY)*(y-atY));
		if ((d < PICKUP_DISTANCE) && (state == STATE_START))
			state = STATE_LOOT;
		GeneralPath diamond = new GeneralPath();
		diamond.moveTo(x-3, y-4);
		diamond.lineTo(x+3, y-4);
		diamond.lineTo(x+5, y-2);
		diamond.lineTo(x+0, y+5);
		diamond.lineTo(x-5, y-2);
//		diamond.closePath(); // not strictly necessary for filling
		g.fill(diamond);
		g.setColor(Color.DARK_GRAY);
	}
	else
		g.setColor(Color.LIGHT_GRAY);
	
	// draw escape position
	{
		// the color selection can be part of the loot painting decision
/*		if ((state % 2) != 0)
			g.setColor(Color.LIGHT_GRAY);
		else
			g.setColor(Color.DARK_GRAY);*/
		int x = vertices[ESCAPE_VERTEX][0];
		int y = vertices[ESCAPE_VERTEX][1];
		float d = (float) Math.sqrt((x-atX)*(x-atX)+(y-atY)*(y-atY));
		if (d < PICKUP_DISTANCE)
		{
			if (state == STATE_LOOT)
			{
				state = STATE_STATUS;
				level++;
			}
		}
		GeneralPath p = new GeneralPath();
		p.moveTo(x+0, y+0);
		p.lineTo(x+8, y-8);
		p.lineTo(x+8, y-4);
		p.lineTo(x+20, y-4);
		p.lineTo(x+20, y+4);
		p.lineTo(x+8, y+4);
		p.lineTo(x+8, y+8);
//		p.closePath(); // not strictly necessary for filling
		g.fill(p);
//		g.fill(new Ellipse2D.Float(x-2*RADIUS, y-2*RADIUS, 4*RADIUS, 4*RADIUS));
	}
	
	// draw switch
	{
		int x = vertices[SWITCH_VERTEX][0];
		int y = vertices[SWITCH_VERTEX][1];
		float d = (float) Math.sqrt((x-atX)*(x-atX)+(y-atY)*(y-atY));
		if (d < PICKUP_DISTANCE)
		{
			for (int i = 0; i < gstate.length; i++)
				if (gstate[i][2] == GTYPE_ON_CAMERA)
					gstate[i][2] = GTYPE_OFF_CAMERA;
		}
		g.setColor(Color.LIGHT_GRAY);
		GeneralPath sw = new GeneralPath();
		// C+---+D
		//   \   \
		//    \   \
		//     \   \
		//A+----+B E+----+F
		// |      +      |
		//H+-------------+G
		sw.moveTo(x-5, y-1); //A
		sw.lineTo(x-1, y-1); //B
		sw.lineTo(x-3, y-5); //C
		sw.lineTo(x-1, y-5); //D
		sw.lineTo(x+1, y-1); //E
		sw.lineTo(x+5, y-1); //F
		sw.lineTo(x+5, y+1); //G
		sw.lineTo(x-5, y+1); //H
		g.fill(sw);
		g.setColor(Color.RED);
		g.fill(new Ellipse2D.Float(x-2-2, y-5-2, 4, 4));
	}
	
	// draw floor plan
	for (int i = 0; i < segments.length; i++)
	{
		if ((segments[i][2] & FLAG_DOOR) == 0)
			g.setColor(Color.WHITE);
		else
			g.setColor(Color.DARK_GRAY);
		g.drawLine(vertices[segments[i][0]][0], vertices[segments[i][0]][1],
				vertices[segments[i][1]][0], vertices[segments[i][1]][1]);
	}
	
	// draw self
	g.setColor(Color.YELLOW);
	g.fill(new Ellipse2D.Float(atX-DRAW_RADIUS+0.5f, atY-DRAW_RADIUS+0.5f, 2*DRAW_RADIUS, 2*DRAW_RADIUS));
	
	// draw guards
	for (int i = 0; i < gstate.length; i++)
	{
		if (gstate[i][2] == GTYPE_NORMAL)
		{
			g.setColor(Color.BLUE);
			g.fill(new Ellipse2D.Float(gposition[i][0]-DRAW_RADIUS+0.5f, gposition[i][1]-DRAW_RADIUS+0.5f, 2*DRAW_RADIUS, 2*DRAW_RADIUS));
		}
		else
		{
			//  (-dy,dx)
			//A+---+B
			// |   |/+D
			// |  +  | (dx,dy)
			// |   |\+E
			//H+---+G
			//  (dy,-dx)
			g.setColor(Color.CYAN);
			float x = gposition[i][0], y = gposition[i][1];
			float angle = gposition[i][2]*PI/180.0f;
			float dx = (float) Math.cos(angle);
			float dy = (float) Math.sin(angle);
			GeneralPath cam = new GeneralPath();
			cam.moveTo(x-8*dx-3*dy, y-8*dy+3*dx); //A
			cam.lineTo(x-0*dx-3*dy, y-0*dy+3*dx); //B
			cam.lineTo(x-0*dx-1*dy, y-0*dy+1*dx); //C
			cam.lineTo(x+3*dx-3*dy, y+3*dy+3*dx); //D
			cam.lineTo(x+3*dx+3*dy, y+3*dy-3*dx); //E
			cam.lineTo(x-0*dx+1*dy, y-0*dy-1*dx); //F
			cam.lineTo(x-0*dx+3*dy, y-0*dy-3*dx); //G
			cam.lineTo(x-8*dx+3*dy, y-8*dy-3*dx); //H
			g.fill(cam);
		}
	}
	
	repaint();
}

@SuppressWarnings("null")
@Override
protected void processEvent(AWTEvent f)
{
	if ((f.getID() == MouseEvent.MOUSE_CLICKED) && (state >= STATE_CAUGHT_NO_LOOT) && (level < MAX_LEVEL))
	{
		if (state == STATE_STATUS)
		{
			// Level Setup (byte-packed level)
			String s;
			if (level == 0)
				s = "\013\005\006\064\027\000\000\001\001\017\001\077\001\017\024\017\032\001\057\017\057\077\057\007\004\006\000\006\007\001\007\011\000\003\010\000\010\012\000\012\005\000\005\003\000\003\001\002\004\032\014\000\010\100\001\002\004\071\044\100\010\000\000\004\011\033\044\162\007\001\071\014\011\011\062\007\001\033\044";
			else if (level == 1)
				s = "\014\007\051\061\037\067\007\001\001\077\001\017\015\077\015\017\037\017\044\001\057\017\057\077\057\010\004\013\000\005\007\000\013\011\000\011\003\000\003\004\000\007\010\001\010\012\000\006\005\000\002\001\001\004\051\043\166\000\004\012\010\007\000\003\001\061\011\012\100\003\001\010";
			else if (level == 2)
				s = "\023\003\004\034\030\000\000\001\001\007\001\077\001\017\011\052\011\056\011\077\011\007\026\007\032\017\047\052\047\056\047\077\047\001\057\007\057\077\057\016\005\022\000\004\012\000\022\020\000\020\003\000\003\005\000\012\013\001\013\021\000\011\010\000\010\007\001\007\006\000\006\014\000\014\015\000\015\016\001\016\017\000\003\001\002\004\023\030\033\010\145\000\010\010\012\004\000\003\001\053\011\011\040\005\001\052\011\010\100\013\001\012\077\011\011\140\005\001\004\000\010\010\014\054\000\003\001\055\011\011\140\005\001\006\011\010\100\003\001\014\011\011\040\005\001\054";
			else if (level == 3)
				s =	"\037\044\015\073\054\000\000\001\001\026\001\077\001\026\003\026\007\026\011\047\011\017\021\047\021\066\021\072\021\077\021\017\033\021\033\025\033\035\033\055\043\077\043\001\045\006\045\012\045\017\045\055\050\055\054\001\057\035\057\055\057\077\057\030\005\036\000\003\033\000\025\026\000\026\027\001\012\030\000\027\030\000\003\005\000\017\020\000\022\034\000\020\021\001\021\022\000\024\023\000\033\036\000\031\023\000\031\032\001\032\035\000\012\014\000\011\013\000\011\010\000\015\014\001\010\007\000\004\006\000\006\007\001\015\016\000\007\000\026\004\022\026\000\003\001\043\011\005\040\005\001\052\011\002\000\003\001\056\010\100\002\051\011\003\141\015\001\035\140\011\004\000\003\001\071\011\006\140\005\001\004\011\014\100\003\001\011\011\011\040\005\001\050\011\002\000\003\001\022\011\004\140\005\001\026\001\002\004\062\053\040\010\140\001\002\004\012\010\140\010\040\001\002\004\046\032\160\010\060\001\002\004\017\054\000\010\100\000\004\004\067\031\140\005\001\011\011\004\040\005\001\031\000\004\004\004\052\000\003\001\027\011\004\100\003\001\004";
			else
				s = "\047\014\034\070\051\015\024\001\001\030\001\077\001\030\005\030\011\037\016\042\016\046\016\064\016\011\021\030\021\037\021\064\021\064\025\037\026\064\030\077\030\011\032\017\032\037\032\011\036\017\036\037\036\042\036\046\036\053\036\056\036\062\036\064\036\001\045\003\045\007\045\011\045\001\057\053\057\077\057\037\005\046\000\003\044\000\040\041\000\041\042\001\014\024\000\042\043\000\003\005\000\044\046\000\034\045\000\014\016\000\015\007\000\004\006\000\006\007\001\024\025\000\025\030\000\027\043\000\013\012\000\011\012\001\031\026\000\026\021\001\021\010\000\011\010\000\013\017\000\035\033\000\017\020\001\020\037\000\035\036\001\036\037\000\023\022\000\033\032\001\032\027\000\011\001\001\004\076\056\117\000\004\010\005\012\037\005\001\052\011\010\140\005\001\012\000\014\006\024\030\000\003\001\057\011\003\035\007\001\061\045\011\002\000\003\001\071\011\002\107\007\001\060\042\011\002\140\005\001\030\011\007\100\003\001\024\000\004\014\010\007\001\003\001\071\011\014\100\003\001\010\001\002\004\050\051\116\010\144\001\002\004\045\002\054\010\027\000\010\006\036\051\153\007\001\053\023\011\003\000\003\001\072\011\004\100\003\001\052\011\006\052\007\001\036\051\000\004\007\042\012\024\007\001\063\044\011\007\124\007\001\042\012\000\010\006\015\053\000\003\001\045\011\003\140\005\001\034\011\003\040\005\001\053\011\006\100\003\001\015";
			byte[] data = null;
			try
			{ data = s.getBytes("UTF-8"); }
			catch (Exception e)
			{/*Ignored*/}
			
			// unpack vertices
			int offset = 0;
			int vcount = data[offset++];
			vertices = new int[vcount][2];
			for (int i = 0; i < vcount; i++)
				for (int j = 0; j < 2; j++)
					vertices[i][j] = 10*data[offset++];
			
			// unpack segments
			int scount = data[offset++];
			segments = new int[scount][3];
			for (int i = 0; i < scount; i++)
				for (int j = 0; j < 3; j++)
					segments[i][j] = data[offset++];
			
			// unpack guards
			int gcount = data[offset++];
			guards = new int[gcount][];
			gstate = new int[gcount][3];
			for (int i = 0; i < gcount; i++)
			{
				gstate[i][2] = data[offset++];
				int gsize = data[offset++];
				guards[i] = new int[4*gsize];
				for (int j = 0; j < gsize; j++)
				{
					int mask = j == 0 ? 15 : data[offset++];
					guards[i][4*j+0] = (mask & 1) != 0 ? data[offset++] : guards[i][4*j-4];
					guards[i][4*j+1] = (mask & 2) != 0 ? 10*data[offset++] : guards[i][4*j-3];
					guards[i][4*j+2] = (mask & 4) != 0 ? 10*data[offset++] : guards[i][4*j-2];
					guards[i][4*j+3] = (mask & 8) != 0 ? data[offset++] : guards[i][4*j-1];
				}
			}
			
			state = STATE_CAUGHT_NO_LOOT;
		}
		else
			state = STATE_START;
		
		//vertices = new int[][] {{20, 100}, {100, 100}, {50, 10}, {50, 200}};
		//segments = new int[][] {{2, 3, 0}};
		//guards = new int[0][0];
		//gstate = new int[0][0];
		
		// Level-independent Setup
		for (int i = 0; i < gstate.length; i++)
		{
			gstate[i][0] = 0;
			gstate[i][1] = 0;
			gstate[i][2] &= 1;
		}
		start = last = System.currentTimeMillis();
		atX = vertices[ESCAPE_VERTEX][0]; atY = vertices[ESCAPE_VERTEX][1];
		toX = atX; toY = atY;
	}
	
	MouseEvent e = (MouseEvent) f;
//	if ((e.getModifiersEx() & MouseEvent.BUTTON1_DOWN_MASK) != 0)
	{
		toX = e.getX();
		toY = e.getY();
	}
	repaint();
}

public static void main(String[] args) throws Exception
{
	JFrame frame = new JFrame("UlfJack's Thief4k");
	frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	frame.add(new Thief4k());
	frame.pack();
	frame.setResizable(false);
	frame.show();
}

}
