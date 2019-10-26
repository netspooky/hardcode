/*
 * Copyright (c) 2005-2008 Ulf Ochsenfahrt <ulf@ofahrt.de>
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
import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.Polygon;
import java.awt.event.MouseEvent;

import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.SwingUtilities;

public final class aichess4k extends JComponent implements Runnable
{

private static final int EMPTY  = 0;
private static final int PAWN   = 1;
private static final int BISHOP = 2;
private static final int KNIGHT = 3;
private static final int ROOK   = 4;
private static final int QUEEN  = 5;
private static final int KING   = 6;
private static final int FIGURE = 15;

private static final int BLACK  = 16;
private static final int WHITE  = 32;
private static final int COLOR  = 32+16;

private static final int XOFFSET = 20;
private static final int YOFFSET = 20;

private static final int MAX_TICK = 500;

private static final int MAX = 100000;

private static final int KING_VALUE = 10000;
// use magic to calculate the figure value, using:
// (type == KING ? KING_VALUE : (MAGIC >> (4*type)) & 0xf)
private static final int MAGIC = 0x953310;

// board:
// 0-7  board
// 8    0-3 lastmove source x,y & dest x,y
//      4 activeplayer 5 leftrookmoved 6 kingmoved 7 rightrookmoved
// 9    0 movenum 1 movessincetake 2 check

// ply:
// 0-1 source position x,y
// 2-3 dest position x,y
// 4   target figure (only used for transformation moves)


// current board
private int[][] myboard;

// my move including transformation target if pawn ends up on final row
private int[] myply;

// move animation counter
private long time;

// all previous board configurations
private int[][][] undo;

// ai result
private int[] resply;

// ai difficulty (modifies search depth)
private int difficulty;

public aichess4k()
{ init(); }

private void init()
{
	myply = new int[5];
	myply[0] = -1;
	myply[4] = QUEEN;
	
	undo = new int[1000][][];
	myboard = new int[10][8];
	myboard[8][4] = WHITE;
	
	// White
	myboard[0][0] = WHITE | ROOK;
	myboard[1][0] = WHITE | KNIGHT;
	myboard[2][0] = WHITE | BISHOP;
	myboard[3][0] = WHITE | QUEEN;
	myboard[4][0] = WHITE | KING;
	myboard[5][0] = WHITE | BISHOP;
	myboard[6][0] = WHITE | KNIGHT;
	myboard[7][0] = WHITE | ROOK;
	for (int i = 0; i < 8; i++)
		myboard[i][1] = WHITE | PAWN;
	
	// Black
	for (int i = 0; i < 8; i++)
		myboard[i][6] = BLACK | PAWN;
	myboard[0][7] = BLACK | ROOK;
	myboard[1][7] = BLACK | KNIGHT;
	myboard[2][7] = BLACK | BISHOP;
	myboard[3][7] = BLACK | QUEEN;
	myboard[4][7] = BLACK | KING;
	myboard[5][7] = BLACK | BISHOP;
	myboard[6][7] = BLACK | KNIGHT;
	myboard[7][7] = BLACK | ROOK;
	
	myboard[8][2] = -1;
}


// For Debugging:
/*private static final char chs[] = 
	new char[] { ' ', 'p', 'b', 'n', 'r', 'q', 'k' };
private String toString(int[][] board)
{
	StringBuilder result = new StringBuilder();
	result.append("  A B C D E F G H\n");
	for (int j = 7; j >= 0; j--)
	{
		result.append((j+1));
		result.append(' ');
		for (int i = 0; i < 8; i++)
		{
			result.append(chs[board[i][j] & FIGURE]);
			result.append(' ');
		}
		result.append('\n');
	}
	result.append(board[8][0]).append(' ');
	result.append(board[8][1]).append(" -> ");
	result.append(board[8][2]).append(' ');
	result.append(board[8][3]).append("   ");
	result.append(board[8][4]).append("   ");
	result.append(board[8][5]).append(' ');
	result.append(board[8][6]).append(' ');
	result.append(board[8][7]);
	result.append('\n');
	return result.toString();
}*/

boolean isCastleing(final int[][] board,
	final int sx, final int sy, final int dx, final int dy)
{
	final int side = board[8][4];
	final int mustY = (side == WHITE) ? 0 : 7;
	final int rookX = (dx == 2) ? 0 : 7;
	
	if (sy != dy) return false;
	if (sy != mustY) return false;
	if (sx != 4) return false;
	if ((dx != 2) && (dx != 6)) return false;
	
	// not strictly necessary to check
	// if the pieces are unmoved, they got to be the right ones
//	if ((board[4][sy] & FIGURE) != KING) return false;
//	if ((board[rookX][sy] & FIGURE) != ROOK) return false;
	
	// check if path is empty
	int min, max;
	min = dx-1; //dx == 2 ? 1 : 5; EVIL HACK
	max = dx == 2 ? 3 : 6;
	for (int i = min; i <= max; i++)
	{
		if (board[i][sy] != EMPTY)
			return false;
	}
	
	// check if any of the king traversed fields is under attack
	min = dx == 2 ? 2 : 4;
	max = min+2;
	for (int i = min; i <= max; i++)
	{
		for (int x = 0; x < 8; x++)
			for (int y = 0; y < 8; y++)
			{
				final int figure = board[x][y];
				if ((figure != EMPTY) && ((figure & COLOR) != side))
				{
					if ((figure & FIGURE) == PAWN)
					{
						if (sy == y+(side == BLACK ? 1 : -1))
						{
							if (Math.abs(x-i) == 1)
								return false;
						}
					}
					else
					{
						if (isNormal(board, x, y, i, sy))
							return false;
					}
				}
			}
	}
	
	// check if pieces have been moved
	if ((board[8][6] & side) != 0) return false;
	if ((board[8][dx == 2 ? 5 : 7] & side) != 0) return false;
	
	return true;
}

boolean isEnPassant(int[][] board, int sx, int sy, int dx, int dy)
{
	final int side = board[8][4];
	final int mustDir = side == WHITE ? 1 : -1;
	final int mustSY = side == WHITE ? 4 : 3;
	
	// check if current move fits
	if (sy != mustSY) return false;
	if (dy != sy+mustDir) return false;
	if (Math.abs(sx-dx) != 1) return false;
	
	// check if the previous move fits
	// if (lastSX != dx) return false;
	// if (lastSY != mustSY+2*mustDir) return false;
	// if (lastDX != dx) return false;
	// if (lastDY != mustSY) return false;
	if (board[8][0] != dx) return false;
	if (board[8][1] != dy+mustDir) return false;
	if (board[8][2] != dx) return false;
	if (board[8][3] != sy) return false;
	
	// check if the pieces are correct
	if ((board[sx][sy] & FIGURE) != PAWN) return false;
	if ((board[dx][sy] & FIGURE) != PAWN) return false;
	return true;
}

// all normal moves (not en-passant or castleing)
// Does not check colors!
boolean isNormal(int[][] board, int sx, int sy, int dx, int dy)
{
	final int f = board[sx][sy];
	final int g = board[dx][dy];
	
	// if no movement, it's not a move
	if ((dx == sx) && (dy == sy)) return false;
	
	// if the field is empty, it's not a move
	if (f == EMPTY) return false;
	
	// special handling of pawns when they take a figure
	if ((g != EMPTY) && ((f & FIGURE) == PAWN))
	{
		if (Math.abs(sx-dx) != 1) return false;
		if (dy != sy+((f & COLOR) == WHITE ? 1 : -1)) return false;
	}
	else
	{
		switch (f & FIGURE)
		{
			case PAWN :
				if (sx == dx)
				{
					if ((f & COLOR) == WHITE)
					{
						if (dy == sy+1) break;
						if ((sy == 1) && (dy == 3)) break;
					}
					else
					{
						if (dy == sy-1) break;
						if ((sy == 6) && (dy == 4)) break;
					}
				}
				return false;
			case ROOK :
				if ((sx == dx) || (sy == dy)) break;
				return false;
			case KNIGHT :
				if ((Math.abs(sx-dx) == 1) && (Math.abs(sy-dy) == 2)) return true;
				if ((Math.abs(sx-dx) == 2) && (Math.abs(sy-dy) == 1)) return true;
				return false;
			case BISHOP :
				if (sx-sy == dx-dy) break;
				if (sx+sy == dx+dy) break;
				return false;
			case QUEEN :
				if (sx-sy == dx-dy) break;
				if (sx+sy == dx+dy) break;
				if ((sx == dx) || (sy == dy)) break;
				return false;
			case KING :
				if ((Math.abs(sx-dx) <= 1) && (Math.abs(sy-dy) <= 1)) break;
				return false;
		}
	}
	
	// check if path is empty
	// knight already returned earlier
	while ((sx != dx) || (sy != dy))
	{
		if (sx < dx) sx++;
		if (sx > dx) sx--;
		if (sy < dy) sy++;
		if (sy > dy) sy--;
		if (((sx != dx) || (sy != dy)) && (board[sx][sy] != EMPTY))
			return false;
	}
	return true;
}

void copy(int[][] from, int[][] to)
{
	for (int i = 0; i < 10; i++)
		for (int j = 0; j < 8; j++)
			to[i][j] = from[i][j];
}

boolean move(int[][] board, int[] ply)
{
	final int sx = ply[0];
	final int sy = ply[1];
	final int dx = ply[2];
	final int dy = ply[3];
	final int side = board[8][4];
	
//	System.out.println("MOVE "+sx+","+sy+" -> "+dx+","+dy);
	
	final int f = board[sx][sy];
	if ((f & COLOR) != side) return false;
	if ((board[dx][dy] & COLOR) == side) return false;
	
	// make a copy for the undo history
	final int move = board[9][0];
	undo[move] = new int[10][8];
	copy(board, undo[move]);
	
	if (isCastleing(board, sx, sy, dx, dy))
	{
		final int rookSrcX = (dx == 2) ? 0 : 7;
//		final int rookDestX = (dx == 2) ? 3 : 5;
		final int g = board[rookSrcX][sy];
		
		// Modify Board
		board[rookSrcX][sy] = 0;
		board[sx][sy] = 0;
		board[dx][sy] = f;
		board[(dx == 2) ? 3 : 5][sy] = g;
		// set king moved flag
		//board[8][6] |= side;
	}
	else if (isEnPassant(board, sx, sy, dx, dy))
	{
		board[sx][sy] = EMPTY;
		board[dx][dy] = f;
		board[dx][sy] = EMPTY;
		board[9][1] = 0;
	}
	else if (isNormal(board, sx, sy, dx, dy))
	{
		if (board[dx][dy] != EMPTY)
			board[9][1] = 0;
		board[sx][sy] = EMPTY;
		board[dx][dy] = f;
		if ((f & FIGURE) == PAWN)
		{
			if ((dy == 0) || (dy == 7))
				board[dx][dy] = ply[4] | side;
		}
		if ((f & FIGURE) == KING)
			board[8][6] |= side;
		if ((f & FIGURE) == ROOK)
		{
			if (((sx == 0) || (sx == 7)) && ((sy == 0) || (sy == 7)))
				board[8][sx == 0 ? 5 : 7] |= sy == 0 ? WHITE : BLACK;
		}
	}
	else // none of the above
	{
		// board wasn't modified, so no need to undo
		return false;
	}
	
	board[8][0] = sx;
	board[8][1] = sy;
	board[8][2] = dx;
	board[8][3] = dy;
	board[8][4] = COLOR-side;
	board[9][0]++;
	board[9][1]++;
	
	// check for check
	int inCheck = 0;
	for (int x = 0; x < 8; x++)
		for (int y = 0; y < 8; y++)
		{
			if (board[x][y] != EMPTY)
			{
				for (int tx = 0; tx < 8; tx++)
					for (int ty = 0; ty < 8; ty++)
					{
						int g = board[tx][ty];
						if (((g & FIGURE) == KING) && ((g & COLOR) != (board[x][y] & COLOR)))
						{
							if (isNormal(board, x, y, tx, ty))
								inCheck |= g & COLOR;
						}
					}
			}
		}
	board[9][2] = inCheck;
	
	// if current player is in check, move is invalid
	if ((inCheck & side) != 0)
	{
		// undo changes to board
		copy(undo[move], board);
		return false;
	}
	
	return true;
}

// ai search, also used for checkmate detection
// uses alpha-beta-search
// the return value is the value of the best possible move
// the move is actually returned in the field resply
int search(int[][] board, final int steps, final int maxsteps, int alpha, int beta)
{
	resply = null;
	
	// draw after 50 non-taking moves
	if (board[9][1] > 50) return 0;
	
	// draw after three back-and-forth moves
	final int move = board[9][0];
	if (move > 15)
	{
		boolean argh = true;
		for (int i = 0; argh & (i < 8); i++)
		{
			final int b0 = move-1-i;
			final int b1 = b0-4;
			for (int x = 0; x < 8; x++)
				for (int y = 0; y < 8; y++)
					if (undo[b0][x][y] != undo[b1][x][y])
						argh = false;
		}
		if (argh) return 0;
	}
	
	final int side = board[8][4];
	
	// evaluate board if search depth is reached
	if (steps <= 0)
	{
		int whiteValue = 0;
		for (int dx = 0; dx < 8; dx++)
			for (int dy = 0; dy < 8; dy++)
			{
				// add value of piece found at dx,dy
				if (board[dx][dy] != EMPTY)
				{
					int figure = board[dx][dy];
					int type = figure & FIGURE;
					int value = 40*(type == KING ? KING_VALUE : (MAGIC >> (4*type)) & 0xf);
					if ((figure & COLOR) == WHITE)
						whiteValue += value;
					else
						whiteValue -= value;
				}
				
				// calculate superiority at dx,dy by finding
				// all pieces that can attack dx,dy
				float sup = 0;
				for (int x = 0; x < 8; x++)
					for (int y = 0; y < 8; y++)
					{
						int figure = board[x][y];
						if (figure != EMPTY)
						{
							int type = figure & FIGURE;
							int color = figure & COLOR;
							float attack = 1.0f/(type == KING ? KING_VALUE : (MAGIC >> (4*type)) & 0xf);
							if (color == BLACK) attack = -attack;
							if (type == PAWN)
							{
								if (dy == y+(color == WHITE ? 1 : -1))
								{
									if (Math.abs(x-dx) == 1)
										sup += attack;
								}
							}
							else
							{
								if (isNormal(board, x, y, dx, dy))
									sup += attack;
							}
						}
					}
				
				// calculate value of field (dx,dy)
				int value;
				if (dx < dy)
					value = dx-dy;
				else
					value = dy-dx;
				if (dx < 7-dy)
					value += dx+dy;
				else
					value += 14-(dx+dy);
				
				// depending on the superiority, distribute the field's value
				if (sup != 0)
				{
					if (sup > 0)
						whiteValue += value;
					else
						whiteValue -= value;
				}
			}
		
		return side == WHITE ? whiteValue : -whiteValue;
	}
	
	int[] bestply = null;
	int[][] save = new int[10][8];
	
	for (int x = 0; x < 8; x++)
		for (int y = 0; y < 8; y++)
		{
			int figure = board[x][y];
			int type = figure & FIGURE;
			if ((figure & COLOR) == side)
			{
				for (int dx = 0; dx < 8; dx++)
				{
					for (int dy = 0; dy < 8; dy++)
					{
						if (((board[dx][dy] & COLOR) != side) &&
							(isEnPassant(board, x, y, dx, dy) ||
							 isCastleing(board, x, y, dx, dy) ||
							 isNormal(board, x, y, dx, dy)))
						{
//							System.out.println("CONSIDERING: "+x+" "+y+" -> "+dx+" "+dy);
							int newsteps = steps;
							if ((board[dx][dy] != EMPTY) && (steps < maxsteps))
								newsteps++;
							
							int min = QUEEN;
							if ((type == PAWN) && ((dy == 0) || (dy == 7)))
								min = BISHOP;
							for (int k = min; k <= QUEEN; k++)
							{
								int[] p = new int[] { x, y, dx, dy, k };
								copy(board, save);
								if (move(save, p))
								{
									int val = -search(save, newsteps-1, maxsteps-1, -beta, -alpha);
									if (val >= beta) return beta;
									if (val > alpha)
									{
										alpha = val;
										bestply = p;
									}
								}
							}
						}
					}
				}
			}
		}
	
	// resply must be set here
	resply = bestply;
	
	// if no move was found at all, the current side has lost
	return bestply == null ? -KING_VALUE : alpha;
}

public void run()
{
//	for (int level = 0; level < 3; level++)
//		System.out.println(((level+4)/2)+" "+(4*level+2));
	setCursor(new Cursor(Cursor.WAIT_CURSOR));
	
	// maximum depth, and maximum extended depth
	// the ai may increase the search depth if a piece is taken,
	// but only up to the maximum extended depth
	search(myboard, (difficulty+4)/2, 4*difficulty+2, -MAX, MAX);
	if (resply != null)
	{
		move(myboard, resply);
		time = System.currentTimeMillis();
		// check if player can make any move at all
		search(myboard, 1, 0, -MAX, MAX);
	}
	
	// if either computer or player can't make a move
	if (resply == null)
	{
		if (myboard[9][2] == 0)
			myboard[8][4] = 0; // draw
		else // check-mate
			myboard[8][4] = -myboard[8][4];
	}
	
	setCursor(null);
	repaint();
}

// board drawing
public void paint(Graphics u)
{
	Graphics2D g = (Graphics2D) u;
	
	// fill background
	g.setColor(Color.LIGHT_GRAY);
	g.fillRect(0, 0, 1024, 1024);
	
	// translate origin
	g.translate(XOFFSET, YOFFSET);
	
	// draw current state
	int myside = myboard[8][4];
	g.setColor(Color.BLACK);
	String s = "Draw";
	if (myside == WHITE) s = "White";
	if (myside == BLACK) s = "Black";
	if (myside == -WHITE) s = "Black wins";
	if (myside == -BLACK) s = "White wins";
	g.drawString(s, 0, 8*64+16);
	
	// draw last move
	StringBuffer buffer = new StringBuffer();
	buffer//.append("Last: ")
		.append((char) (myboard[8][0]+'A'))
		.append((char) (myboard[8][1]+'1'))
		.append('-')
		.append((char) (myboard[8][2]+'A'))
		.append((char) (myboard[8][3]+'1'));
	if (myboard[8][2] != -1)
		g.drawString(buffer.toString(), 100, 8*64+16);
	
	// draw board
	g.drawRect(-1, -1, 8*64+1, 8*64+1);
	for (int i = 0; i < 8; i++)
		for (int j = 0; j < 8; j++)
		{
			// checker pattern
			if (((i+j) % 2) == 0)
				g.setColor(Color.ORANGE); // Color.LIGHT_GRAY
			else
				g.setColor(Color.ORANGE.darker()); // Color.DARK_GRAY
			
			// highlight last move destination
//			if ((i == myboard[8][2]) && (7-j == myboard[8][3]) && (time != 0))
//				g.setColor(Color.GREEN);
			
			// highlight move source
			if ((i == myply[0]) && (7-j == myply[1]))
				g.setColor(Color.BLUE);
			
			g.fillRect(i*64, j*64, 64, 64);
		}
	
	// draw board numbering
	g.setColor(Color.BLACK);
	for (int i = 0; i < 8; i++)
	{
		g.drawString(Character.toString((char) ('8'-i)), -16, i*64+35);
		g.drawString(Character.toString((char) (i+'A')), i*64+32, -4);
	}
	
	// enable antialiasing
	g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	
	// draw fat lines
	g.setStroke(new BasicStroke(3));
	
	// draw in white
	g.setColor(Color.WHITE);
	
	// draw difficulty button
	for (int i = 0; i <= difficulty; i++)
	{
		int wx = 8*64+18+14*i, wy = 2*64+32;
		g.translate(wx, wy);
		g.drawLine(0, -6, 3, 4);
		g.drawLine(3, 4, -5, -2);
		g.drawLine(-5, -2, 5, -2);
		g.drawLine(5, -2, -3, 4);
		g.drawLine(-3, 4, 0, -6);
		g.translate(-wx, -wy);
	}
	
	// draw undo button
	{
		int wx = 8*64+32, wy = 64+32;
		g.translate(wx, wy);
		g.drawLine(-16, 0, -8, -8);
		g.drawLine(-8, -8, -8, -4);
		g.drawLine(-8, -4, 13, -4);
		g.drawLine(14, -4, 16, -2);
		g.drawLine(16, -1, 16, 12);
		g.drawLine(16, 12, 8, 12);
		g.drawLine(8, 12, 8, 4);
		g.drawLine(8, 4, -8, 4);
		g.drawLine(-8, 4, -8, 8);
		g.drawLine(-8, 8, -16, 0);
		g.translate(-wx, -wy);
	}
	
	// draw restart button
	{
		int wx = 8*64+32, wy = 3*64+32;
		g.translate(wx, wy);
		g.drawLine(-8, 0, -16, -8);
		g.drawLine(-16, -8, -8, -16);
		g.drawLine(-8, -16, -8, -12);
		g.drawLine(-8, -12, 13, -12);
		g.drawLine(14, -12, 16, -10);
		g.drawLine(16, -9, 16, 8);
		
		g.drawLine(8, 0, 16, 8);
		g.drawLine(16, 8, 8, 16);
		g.drawLine(8, 16, 8, 12);
		g.drawLine(8, 12, -13, 12);
		g.drawLine(-14, 12, -16, 10);
		g.drawLine(-16, 9, -16, -8);
		
		g.drawRect(-8, -4, 16, 8);
		g.translate(-wx, -wy);
	}
	
	// calculate animation time
	long tickCount = System.currentTimeMillis()-time;
	
	// draw pieces
	for (int i = 0; i < 9; i++)
		for (int j = 0; j < 8; j++)
		{
			int figure = EMPTY;
			if (i < 8)
				figure = myboard[i][7-j];
			else if (j == 0)
				figure = WHITE | myply[4];
			
			if ((figure & COLOR) == WHITE)
				g.setColor(Color.WHITE);
			else
				g.setColor(Color.BLACK);
			
			float wx = i*64+32, wy = j*64+32;
			
			if ((tickCount < MAX_TICK) && (i == myboard[8][2]) &&
					(7-j == myboard[8][3]))
			{
				float sx = myboard[8][0]*64+32;
				float sy = (7-myboard[8][1])*64+32;
				wx = (tickCount*wx+(MAX_TICK-tickCount)*sx)/MAX_TICK;
				wy = (tickCount*wy+(MAX_TICK-tickCount)*sy)/MAX_TICK;
			}
			
			g.translate(wx, wy);
			switch (figure & FIGURE)
			{
				case PAWN :
					g.drawRect(-4, -6, 8, 8);
					g.drawRect(-8, 8, 16, 8);
					break;
				case BISHOP :
					g.drawRect(-8, -4, 16, 20);
					g.drawLine(0, -18, 6, -12);
					g.drawLine(6, -12, 0, -6);
					g.drawLine(0, -6, -6, -12);
					g.drawLine(-6, -12, 0, -18);
					break;
				case KNIGHT :
					g.drawLine(14, 16, -10, 16);
					g.drawLine(-10, 16, -1, -1);
					g.drawLine(-1, -1, -12, 2);
					g.drawLine(-12, 2, -16, -6);
					g.drawLine(-16, -6, 1, -16);
					g.drawLine(-3, -20, 14, -4);
					g.drawLine(14, -4, 14, 16);
					g.fillOval(-2, -10, 4, 4);
					break;
				case QUEEN :
					g.drawRect(-8, 8, 16, 8);
					g.drawLine(8, 2, -8, 2);
					g.drawLine(-8, 2, -16, -10);
					g.drawLine(-16, -10, -6, -7);
					g.drawLine(-6, -7, 0, -17);
					g.drawLine(0, -17, 6, -7);
					g.drawLine(6, -7, 16, -10);
					g.drawLine(16, -10, 8, 2);
					break;
				case KING :
					g.drawRect(-8, 8, 16, 8);
					g.drawLine(8, 2, -8, 2);
					g.drawLine(-8, 2, -16, -12);
					g.drawLine(-16, -12, 16, -12);
					g.drawLine(16, -12, 8, 2);
					g.drawLine(-4, -17, 4, -17);
					g.drawLine(0, -12, 0, -20);
					break;
				case ROOK :
					g.drawRect(-8, 8, 16, 8);
					g.drawRect(-16, -14, 32, 16);
					g.drawLine(-8, -14, -8, -8);
					g.drawLine(0, -14, 0, -8);
					g.drawLine(8, -14, 8, -8);
					break;
			}
			g.translate(-wx, -wy);
		}
	
	// repaint if animation isn't complete
	// or      invoke ai if it's black's turn
	if (tickCount < MAX_TICK)
		repaint();
	else if ((myboard[8][4] == BLACK) && (time != 0))
	{
		time = 0;
		new Thread(this).start();
//		SwingUtilities.invokeLater(this);
	}
}

protected void processMouseEvent(MouseEvent e)
{
	if (e.getID() != MouseEvent.MOUSE_PRESSED) return;
	if (myboard[8][4] == BLACK) return;
	
	// calculate clicked field position
	int xclick = (e.getX()-XOFFSET)/64;
	int yclick = (e.getY()-YOFFSET)/64;
	if ((xclick >= 0) && (xclick <= 7) && (yclick >= 0) && (yclick <= 7))
	{
		if (myply[0] == -1)
		{
			myply[0] = xclick;
			myply[1] = 7-yclick;
		}
		else
		{
			myply[2] = xclick;
			myply[3] = 7-yclick;
			// create ply and move
			if (move(myboard, myply))
			{
				time = System.currentTimeMillis();
				repaint();
			}
			
			// reset highlight
			myply[0] = -1;
		}
	}
	else if (xclick == 8)
	{
		if (yclick == 0)
		{
			// cycle through transformation targets
			myply[4] = (myply[4]+3)%4+BISHOP;
		}
		else if (yclick == 1)
		{ // undo last move
			int move = myboard[9][0];
			if (move > 0)
			{
				move = (move-1) & ~1;
				copy(undo[move], myboard);
			}
		}
		else if (yclick == 2) // cycle through difficulty levels
			difficulty = (difficulty+1)%3;
		else if (yclick == 3) // restart game
			init();
	}
	
	repaint();
}

public static void main(String[] args) throws Exception
{
	JFrame frame = new JFrame("UlfJack's aichess4k");
	frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	aichess4k ch = new aichess4k();
	ch.setPreferredSize(new Dimension(XOFFSET+8*64+64+6, YOFFSET+8*64+20));
	ch.enableEvents(AWTEvent.MOUSE_EVENT_MASK);
	frame.add(ch);
	frame.pack();
	frame.show();
}

}
