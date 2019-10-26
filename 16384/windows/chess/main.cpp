//Chessation by TasmBoy/Polonium. Modify, compile, and use at your own free will. I only ask you to distribute
//  the source, or give me credit for the original engine.

//  Yeah so I didn't finish this anywhere close to the goal I had in mind for the #asm compo.
//  I'm dissapointed I didn't need any asm code at all. I'm even more dissapointed all the rules of chess were
//  not even implemented. I originally intended for a fully working computer opponent, but without even
//  starting that code I had to step back at the last minute and make the game barely playable with 2 players.
//  I along with other people in #asm would have liked this game to have network support so we can play it..
//  Maybe if I'm bored one day I'll add, if someone like Maloeran doesn't want to do it!
//  Anyway thats it for now, enjoy - it's not much, but it's something. I worked my ass off on this ugly C++ code!
//  If you want, try changing the value of WhiteAtTop near the top of main() where the board is set up to flip it.

//Known limitations and bugs:
//  playing 2 player is more difficult for black because the board doesnt flip over. If I were to flip it,
//    the game would undoubtably be more confusing and unrealistic because both players cannot study the board
//    when their opponent is thinking. could have made 2 board views side-by-side, one for black one for white.
//  playerColour was never properly used. It's temporarily changed each turn so players can control both teams
//    instead of just 1, where the ai would typically control another
//	50 move rule doesn't exit - 50 moves without a piece taken or a pawn moved is so unlikely its not even implemented
//	repetition of moves: if you move same place 3 or more times in a row you should be able to _draw_ the game
//  may not be cross-platform compilable because I used msvc++ _DEBUG define. Comment all debug code or use NDEBUG
//    with gcc; better yet, make a custom #define for debug release (boy am I lazy)

//Todo list:
//	pawn promotion (really easy to do except for lack of a good user input method of selecting your piece type)
//	make it so you can't castle through check by checking each tile the king moves through (yea im just lazy.)
//	draw the game  - these just involve _buttons_ with confirmations basically, or set keyboard keys
//	resignations  _/
//	  computer ai (at least minimax) *scrapped, not enough time for compo*
//  networking for 2 players
//  optimize the code!!
//  could even add sounds in the space I have left! (er maybe..)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <SDL.h>
#include "sdlframework.h"
#include "sdlfont.h"
#include "board.h"
#include "main.h"
#include <vector>

//fonts
SDLFont* fontEngine;
char* statustext;

//castling
//-- special case checked whenever you try and move the king
bool KingMoved[2] = {false, false};	//0 is whoever is at the top, 1 at bottom
bool RookMoved[2][2] = {false, false, false, false}; //used for castling, 2 rooks per side (array 1 is for whoever is at top, dimension 2 is for bottom)
int castleMove; //castle this move? 0=no, 1=left, 2=right

//en passant
short LastPawnMovedLongX = -1; //the last pawn moved (we can check team from its position)
short LastPawnMovedLongY = -1;
bool LastMoveEnPassent = false;
char LastPieceMoved = 0; //the type of piece that just moved (used for en passant)

//the class containing the boarddata and pieces
Board CurrentBoard;
char turn=0; //current turn: 0=white, 1=black, other=paused game?
char playerColour=0; //for AI games: 0=white, 1=black, other=computer vs computer
bool WhiteAtTop; //true=white at top, false=white at bottom

//mouse drag
int DragTileX, DragTileY;
int DraggingPiece=0;


int main(int argc, char *argv[])
{

	//Setup game
	printf("Chessation by Polonium. Vote if u like it");

	// 16 bits per pixel, not fullscreen, not anyformat
	if( !( envCreateWindow( "Chessation v1.0", 640, 480, 16, 0, 0 ) ) )
		return 0;

	CurrentBoard.LoadBoardImage();

	//setup default board
	turn = 0;
	playerColour = 0;
	WhiteAtTop = true;
	CurrentBoard.SetupBoard(WhiteAtTop);

	//setup font stuff
	fontEngine = new SDLFont; //will initialize itself
#ifdef _DEBUG
	fontEngine->GetImageDataDEBUG();
#endif
	statustext = (char*)malloc(50);
	strcpy(statustext, "GAME IN PROGRESS.");


	//main program loop
	for( ; ; )
	{
		if( !( envUpdate() ) )
		return 0;

		//// 'escape' key
		//if( envKey[SDLK_ESCAPE] )
		//break;
		//// Clear our buffers of keyboard and cursor events
		//envKeyboardEvents = 0;

		HandleMouseInput();

		// Render boarddata and pieces
		CurrentBoard.RenderBoard();

		// Render any text
		fontEngine->WriteString(statustext, 12, 300);
		if (turn == 0){
			fontEngine->WriteString("WHITE TO MOVE", 340, 30);
		}else{
			fontEngine->WriteString("BLACK TO MOVE", 340, 30);
		}

		// Updating 2d rendering
		envUpdate2D();
		SDL_FillRect(env_surface, NULL, 0x0); //clear offscreen buffer
		
	}

	//free goats and mooses in memory (why do i bother writing comments sometimes)
	SDL_FreeSurface(CurrentBoard.boardimage);
	free(statustext);

	envDestroyWindow();

	return 1;
}



void HandleMouseInput(){

	int tilex, tiley, i;
	tilex = envCursorX/36;	//current tile mouse is over
	tiley = envCursorY/36;

	for( i = 0 ; i < envCursorEvents ; i++ )
	{
		//see if we click the mouse down on a piece (left button)
		if (envCursorBuffer[i] == 1)
		{
			//make sure the mouse is inside the boundaries
			if ( (tilex >= 0) && (tilex <= 7) && (tiley >= 0) && (tiley <= 7) ){

				//make sure there is a piece under the cursor
				if ((CurrentBoard.boarddata[tilex][tiley] & 0x7FFF) != 0){

					//we have pressed the mouse down on a piece
					//store which tile/piece if it is our move *and the piece is ours*
					if ( (CurrentBoard.boarddata[tilex][tiley] >> 15) == turn ){
						if (turn == playerColour){
							DragTileX = tilex;
							DragTileY = tiley;
							DraggingPiece = 1;
						}
					}

				}

			}

		}
		//mouse left button up
		else if (envCursorBuffer[i] == 8)
		{
			if (DragTileX == tilex && DragTileY == tiley){
				//canceled move
			}
			else
			{
				//we have dragged a piece somewhere.
				//check it's a valid move and if so, move it there.
				if (turn == playerColour){

					//we are curently moving a piece
					if (DraggingPiece == 1){

						//make sure the move is inside the boundaries
						if ( (tilex >= 0) && (tilex <= 7) && (tiley >= 0) && (tiley <= 7) ){

							//test if it is a valid move for the piece
							if (MoveIsValid( DragTileX, DragTileY, tilex, tiley, &CurrentBoard) == (int)true)
							{

								//** does this next move put us in check or have us remain in check? if so its a no no

								//setup a temporary board then move this piece so we can see if it put us out of check
								Board tmpBoard;
								memcpy(&tmpBoard.boarddata, &CurrentBoard.boarddata, sizeof(unsigned short)*8*8);

								//temp. set this piece here
								tmpBoard.boarddata[tilex][tiley] = tmpBoard.boarddata[DragTileX][DragTileY];
								tmpBoard.boarddata[DragTileX][DragTileY] = 0;
								//if it was an en passent capture, remove the captured piece seeing as we don't overwrite it
								if (LastMoveEnPassent)
								{
									tmpBoard.boarddata[LastPawnMovedLongX][LastPawnMovedLongY] = 0;
								}
								//if it was a castle move, move the rook as well
								if (castleMove==2) //right (kings side)
								{
									tmpBoard.boarddata[5][turn*7] = tmpBoard.boarddata[7][turn*7];
									tmpBoard.boarddata[7][turn*7] = 0;
									KingMoved[turn] = true;
								}
								else if (castleMove==1) //left (queens side)
								{
									tmpBoard.boarddata[3][turn*7] = tmpBoard.boarddata[0][turn*7];
									tmpBoard.boarddata[0][turn*7] = 0;
								}

								//are we still in check?
								if ( KingInCheck(&tmpBoard) )
								{
									//can't allow the king to remain in check
									DraggingPiece = 0;
									return;
								}

								//set this piece here now that we know its valid
								CurrentBoard.boarddata[tilex][tiley] = CurrentBoard.boarddata[DragTileX][DragTileY];
								CurrentBoard.boarddata[DragTileX][DragTileY] = 0;
								//if it was an en passent capture, remove the captured piece seeing as we don't overwrite it
								if (LastMoveEnPassent)
								{
									CurrentBoard.boarddata[LastPawnMovedLongX][LastPawnMovedLongY] = 0;
									LastMoveEnPassent = false;
								}
								//if it was a castle move, move the rook as well
								if (castleMove > 0)
								{
									if (castleMove==2) //right (kings side)
									{
										if (WhiteAtTop){
											CurrentBoard.boarddata[5][turn*7] = CurrentBoard.boarddata[7][turn*7];
											CurrentBoard.boarddata[7][turn*7] = 0;
										}else{
											CurrentBoard.boarddata[5][!turn*7] = CurrentBoard.boarddata[7][!turn*7];
											CurrentBoard.boarddata[7][!turn*7] = 0;
										}
										KingMoved[turn] = true;
										castleMove = 0;
									}
									else if (castleMove==1) //left (queens side)
									{
										if (WhiteAtTop){
											CurrentBoard.boarddata[3][turn*7] = CurrentBoard.boarddata[0][turn*7];
											CurrentBoard.boarddata[0][turn*7] = 0;
										}else{
											CurrentBoard.boarddata[3][!turn*7] = CurrentBoard.boarddata[0][!turn*7];
											CurrentBoard.boarddata[0][!turn*7] = 0;
										}
										KingMoved[turn] = true;
										castleMove = 0;
									}
								}

								//and polish up
								DraggingPiece = 0;
								LastPieceMoved = (CurrentBoard.boarddata[tilex][tiley] & 0x1F);

								turn = !turn;
								//temp for 2 player game. comment this out for an AI game
								playerColour = !playerColour;

								//check if the next player is now in a stalemate or checkmate position
								char mateType;
								if (DetectMate(&CurrentBoard, &mateType))
								{
									if (mateType == 1)
									{
										//checkmated mate!
										if (turn == 0){
											strcpy(statustext, "BLACK MATES!");
										}else{
											strcpy(statustext, "WHITE MATES!");
										}
									}
									else if (mateType == 2)
									{
										//stalemated
										if (turn == 0){
											strcpy(statustext, "WHITE STALEMATED!");
										}else{
											strcpy(statustext, "BLACK STALEMATED!");
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	// Clear mouse input buffer
	envCursorEvents = 0;
}



int MoveIsValid(int fromX, int fromY, int toX, int toY, const Board* board)
{
	bool Capture = false;
	bool CheckForEnPassant = false;
	int PieceType = PieceAtLocation(board, fromX, fromY) & 0x1F;

	//capturing a piece possibly?
	if (PieceAtLocation(board, toX, toY) != 0){
		//or not: we are trying to capture one of our own pieces :p
		if ( PieceAtLocation(board, toX, toY) >> 15 == turn){   // turn=current player moving
			return false;
		}
		else
		{
			//we are going to capture an enemy piece if we pass criteria below
			Capture = true;
		}
	}

	switch (PieceType)
	{
	case 0: //nothing??
		break;

	case 1: //pawn

		//foward & diagonal capture
		if ( fromX != toX )
		{
			//only if it is a capture
			if (!Capture){
				//if its not an en passent capture
				if (LastPieceMoved != 1) //pawn
				{
					return false;
				}
				else
				{
					//this could be an en passent pawn capture still
					CheckForEnPassant = true; //check if its valid later on
				}
			}

			//if its diagonal it must be foward and one square to the left or right
			if (WhiteAtTop)
			{
				//white moving down the board
				if (turn == 0)
				{
					//left or right 1
					if ((toX == fromX - 1) || (toX == fromX + 1))
					{
						//down 1
						if (toY == fromY + 1)
						{
							//only move providing the en passant capture is valid
							if (CheckForEnPassant)
							{
								//only do the capture if the last pawn moved is just behind the piece to 1 side
								if (abs(LastPawnMovedLongX - fromX) == 1)
								{
									if (LastPawnMovedLongY == fromY)
									{
										//we have to remove the en passant captured piece if they are to move
										LastMoveEnPassent = true;
										return true;
									}
								}
							}
							else
							{
								return true;
							}
						}
					}
				}
				//black moving up the board
				else
				{
					//left or right 1
					if ((toX == fromX - 1) || (toX == fromX + 1))
					{
						//up 1
						if (toY == fromY - 1)
						{
							//only move providing the en passant capture is valid
							if (CheckForEnPassant)
							{
								//only do the capture if the last pawn moved is just behind the piece to 1 side
								if (abs(LastPawnMovedLongX - fromX) == 1)
								{
									if (LastPawnMovedLongY == fromY)
									{
										//we have to remove the en passant captured piece if they are to move
										LastMoveEnPassent = true;
										return true;
									}
								}
							}
							else
							{
								return true;
							}
						}
					}
				}
			}
			else
			{
				//white is moving up the board
				if (turn == 0)
				{
					//left or right 1
					if ((toX == fromX - 1) || (toX == fromX + 1))
					{
						//up 1
						if (toY == fromY - 1)
						{
							//only move providing the en passant capture is valid
							if (CheckForEnPassant)
							{
								//only do the capture if the last pawn moved is just behind the piece to 1 side
								if (abs(LastPawnMovedLongX - fromX) == 1)
								{
									if (LastPawnMovedLongY == fromY)
									{
										//we have to remove the en passant captured piece if they are to move
										LastMoveEnPassent = true;
										return true;
									}
								}
							}
							else
							{
								return true;
							}
						}
					}
				}
				//black moving down the board
				else
				{
					//left or right 1
					if ((toX == fromX - 1) || (toX == fromX + 1))
					{
						//down 1
						if (toY == fromY + 1)
						{
							//only move providing the en passant capture is valid
							if (CheckForEnPassant)
							{
								//only do the capture if the last pawn moved is just behind the piece to 1 side
								if (abs(LastPawnMovedLongX - fromX) == 1)
								{
									if (LastPawnMovedLongY == fromY)
									{
										//we have to remove the en passant captured piece if they are to move
										LastMoveEnPassent = true;
										return true;
									}
								}
							}
							else
							{
								return true;
							}
						}
					}
				}
			}
		}
		//moving the piece foward. is it moving 'foward' only one square or 2 if at original pos?
		else
		{
			if (WhiteAtTop)
			{
				//white moving down the board
				if (turn == 0)
				{
					//down 1
					if (toY == fromY + 1)
					{
						//we aren't moving foward into an enemy piece (pawns can't capture foward)
						if (PieceAtLocation(board, toX, toY) == 0)
						{
							return true;
						}
					}
					//down 2
					if (toY == fromY + 2)
					{
						//if it hasn't moved yet
						if (fromY == 1)
						{
							//we aren't moving foward into an enemy piece (pawns can't capture foward)
							if (PieceAtLocation(board, toX, toY) == 0)
							{
								if (PieceAtLocation(board, fromX, fromY+1) == 0)
								{
									LastPawnMovedLongX = toX;
									LastPawnMovedLongY = toY;
									return true;
								}
							}
						}
					}
				}
				//black moving up the board
				else
				{
					//up 1
					if (toY == fromY - 1)
					{
						//we aren't moving foward into an enemy piece (pawns can't capture foward)
						if (PieceAtLocation(board, toX, toY) == 0)
						{
							return true;
						}
					}
					//up 2
					if (toY == fromY - 2)
					{
						//if it hasn't moved yet
						if (fromY == 6)
						{
							//we aren't moving foward into an enemy piece (pawns can't capture foward)
							if (PieceAtLocation(board, toX, toY) == 0)
							{
								if (PieceAtLocation(board, fromX, fromY-1) == 0)
								{
									LastPawnMovedLongX = toX;
									LastPawnMovedLongY = toY;
									return true;
								}
							}
						}
					}
				}
			}
			else
			{
				//white moving up the board
				if (turn == 0)
				{
					//up 1
					if (toY == fromY - 1)
					{
						//we aren't moving foward into an enemy piece (pawns can't capture foward)
						if (PieceAtLocation(board, toX, toY) == 0)
						{
							return true;
						}
					}
					//up 2
					if (toY == fromY - 2)
					{
						//if it hasn't moved yet
						if (fromY == 6)
						{
							//we aren't moving foward into an enemy piece (pawns can't capture foward)
							if (PieceAtLocation(board, toX, toY) == 0)
							{
								if (PieceAtLocation(board, fromX, fromY-1) == 0)
								{
									LastPawnMovedLongX = toX;
									LastPawnMovedLongY = toY;
									return true;
								}
							}
						}
					}
				}
				//black moving down the board
				else
				{
					//down 1
					if (toY == fromY + 1)
					{
						//we aren't moving foward into an enemy piece (pawns can't capture foward)
						if (PieceAtLocation(board, toX, toY) == 0)
						{
							return true;
						}
					}
					//down 2
					if (toY == fromY + 2)
					{
						//if it hasn't moved yet
						if (fromY == 1)
						{
							//we aren't moving foward into an enemy piece (pawns can't capture foward)
							if (PieceAtLocation(board, toX, toY) == 0)
							{
								if (PieceAtLocation(board, fromX, fromY+1) == 0)
								{
									LastPawnMovedLongX = toX;
									LastPawnMovedLongY = toY;
									return true;
								}
							}
						}
					}
				}
			}
		}
		break;

	case 2: //rook
		
		//can only move in rows or columns
		//todo: make the algo like the bishop one
		if (toY == fromY)
		{
			//step through all the squares in the row from the square after fromX until the square before toX
			int dir=1;
			if (toX < fromX) dir = -1; //left
			for (int x = fromX+dir; x != toX; x += dir)
			{
				//if there's a piece in the way
				if (PieceAtLocation(board, x, toY) != 0)
				{
					//exit out immediately because it's blocking our path
					return false;
				}
			}
			//the path is all clear.
			return true;
		}
		else if (toX == fromX)
		{
			//step through all the squares in the column from the square after fromY until the square before toY
			char dir=1;
			if (toY < fromY) dir = -1; //upwards
			for (int y = fromY+dir; y != toY; y += dir)
			{
				//if there's a piece in the way
				if (PieceAtLocation(board, toX, y) != 0)
				{
					//exit out immediately because it's blocking our path
					return false;
				}
			}
			//the path is all clear.
			return true;
		}

		break;

	case 3: //knight

		//knight always has to move a distance of sqrt(2^2 + 1^2) = sqrt(5)
		if ( sqrt( (double)((fromX-toX)*(fromX-toX) + (fromY-toY)*(fromY-toY)) ) == sqrt((double)5.0) )
			return true;
		break;

	case 4: //bishop
		
		//can only move diagonals
		if ( abs(toX-fromX) == abs(toY-fromY) ){
			//we are moving at 45 degrees
			char dirx=1, diry=1;
			if (toX < fromX) dirx = -1;
			if (toY < fromY) diry = -1;
			//check each square along the diagonal
			for (int count = 1; count < abs(toX-fromX); count+=1){
				int currX, currY;
				currX = fromX + (count * dirx);
				currY = fromY + (count * diry);
				//if there's a piece in the way
				if (PieceAtLocation(board, currX, currY) != 0)
				{
					//exit out immediately because it's blocking our path
					return false;
				}
			}
			return true;
		}
		break;

	case 5: //queen

		//first check rows and columns like a rook
		if (toY == fromY)
		{
			//step through all the squares in the row from the square after fromX until the square before toX
			int dir=1;
			if (toX < fromX) dir = -1; //left
			for (int x = fromX+dir; x != toX; x += dir)
			{
				//if there's a piece in the way
				if (PieceAtLocation(board, x, toY) != 0)
				{
					//exit out immediately because it's blocking our path
					return false;
				}
			}
			//the path is all clear.
			return true;
		}
		else if (toX == fromX)
		{
			//step through all the squares in the column from the square after fromY until the square before toY
			int dir=1;
			if (toY < fromY) dir = -1; //upwards
			for (int y = fromY+dir; y != toY; y += dir)
			{
				//if there's a piece in the way
				if (PieceAtLocation(board, toX, y) != 0)
				{
					//exit out immediately because it's blocking our path
					return false;
				}
			}
			//the path is all clear.
			return true;
		}
		//now check diagonals like bishop
		if ( abs(toX-fromX) == abs(toY-fromY) ){
			//we are moving at 45 degrees
			char dirx=1, diry=1;
			if (toX < fromX) dirx = -1;
			if (toY < fromY) diry = -1;
			//check each square along the diagonal
			for (int count = 1; count < abs(toX-fromX); count+=1){
				int currX, currY;
				currX = fromX + (count * dirx);
				currY = fromY + (count * diry);
				//if there's a piece in the way
				if (PieceAtLocation(board, currX, currY) != 0)
				{
					//exit out immediately because it's blocking our path
					return false;
				}
			}
			return true;
		}
		break;

	case 6: //king

		//check for castling and move rook in either of the 2 cases
		if ((fromY==toY) && (abs(toX-fromX)==2))
		{
			//case 1, kings side
			if ( !KingInCheck(board) ) //can't castle out of check
			{
				if (!KingMoved[turn] && !RookMoved[turn][1]) //right rook
				{
					if (PieceAtLocation(board, fromX+1, fromY) == 0)
					{
						if (PieceAtLocation(board, fromX+2, fromY) == 0)
						{
							//TODO: simulate the king moving each step as to see its not in check on the way to its final position
							castleMove = 2; //right
							return true;
						}
					}
				}
			}
			//case 1, queens side
			if ( !KingInCheck(board) ) //can't castle out of check
			{
				if (!KingMoved[turn] && !RookMoved[turn][0]) //left rook
				{
					if (PieceAtLocation(board, fromX-1, fromY) == 0)
					{
						if (PieceAtLocation(board, fromX-2, fromY) == 0)
						{
							if (PieceAtLocation(board, fromX-3, fromY) == 0)
							{
								//TODO: simulate the king moving each step as to see its not in check on the way to its final position
								castleMove = 1; //left
								return true;
							}
						}
					}
				}
			}
		}

		//1 square movement at a time - must be less than sqrt(1^2 + 1^2) = sqrt(2) which would be diagonally 1 square
		if ( sqrt( (double)((fromX-toX)*(fromX-toX) + (fromY-toY)*(fromY-toY)) ) <= sqrt((double)2.0) )
		{
			KingMoved[turn] = true;
			return true;
		}

		break;

	}

	return false;
}



//would typically be called with location of a player's king or the tiles on the way to a castling
bool KingInCheck(const Board* board)
{
	int kingX, kingY;

	//first find where our king is
	for (int x=0; x<8; x++){
		for (int y=0; y<8; y++){
			if ( ((PieceAtLocation(board, x, y) >> 15 ) == turn) && ((PieceAtLocation(board, x, y) & 0x1F ) == 6))
			{
				//this is our king
				kingX = x;
				kingY = y;
			}
		}
	}
	//check through every one of the enemy's pieces and see if they can capture the king this move
	char tempturn = turn; //hack: we just have to trick MoveIsValid that the enemy is moving now in order to use the function properly
	turn = !turn;
	for (int x=0; x<8; x++)
	{
		for (int y=0; y<8; y++)
		{
			if ( (PieceAtLocation(board, x, y) >> 15) == turn )
			{
				//this is an enemy piece
				//check if its valid to move onto the square where the king resides (and therefore capture it)
				if ( MoveIsValid( x, y, kingX, kingY, board ) )
				{
					//the king must be in check if the board passed as a param was a temp one with the next future move in place
					turn = !turn; // restore the correct turn
					return true;
				}
			}
		}
	}
	turn = !turn; //retore the correct turn before returning false
	return false;
}


//check if we're in stalemate or checkmate
//ok heres the original deal. its slow but its lazy and simple
//thanks to maloeran for this idea of looping through all 64 squares instead of examining piece-specific moves
//what we can do is check if the king is in check.
//  if it's in check then check every valid move of every pieces
//    if no move on the board can get us out of check, it's checkmate.
//  if its not in check then check every valid move
//    if there are NO valid moves whatsoever then we are stalemated
bool DetectMate(const Board* board, char* mateType)
{
	//the above algorithm has been optimized with my brain to this nasty little one:
	//search all valid moves
	//  if a valid move is found
	//    is the king in check?
	//      yes, does this move get the king out of check?
	//        yes - return false
	//        no - if all no then at the end check if the king is in check and there was no way out - return true
	//      no - return false
	Board* tempBoard = new Board();

	//search all valid moves
	//optional: loop unrolling for more speed
	for (int fromX=0; fromX < 8; fromX++)
	{
		for (int fromY=0; fromY < 8; fromY++)
		{

			for (int toX=0; toX < 8; toX++)
			{
				for (int toY=0; toY < 8; toY++)
				{

					if (!((fromX == toX) && (fromY == toY)))
					{
						//if it is our piece
						if ((PieceAtLocation(board, fromX, fromY)>>15 == turn) && (PieceAtLocation(board, fromX, fromY) != 0))
						{
							//from A to B
							if (MoveIsValid(fromX, fromY, toX, toY, board)){
								if (KingInCheck(board))
								{
									//does this move get the king out of check?
									memcpy(tempBoard->boarddata, board->boarddata, 8*8*sizeof(unsigned short)); //too lazy to implement an = operator
									tempBoard->boarddata[toX][toY] = tempBoard->boarddata[fromX][fromY];
									tempBoard->boarddata[fromX][fromY] = 0;
									if (KingInCheck(tempBoard) == false)
									{
										//w00t we aren't in checkmate
										//cuz we can 'move' ourselves out of it
										free(tempBoard);
										return false;
									}
								}
								else
								{
									//not in stalemate (or checkmate) :)
									return false;
								}
							}
						}
					}

				}
			}

		}
	}
	//if we landed here it's bad.

	if (KingInCheck(board)){
		//we are in checkmate
		free(tempBoard);
		*mateType = 1;
		return true;
	}
	else
	{
		//stalemated
		*mateType = 2;
		return true;
	}
}


inline int PieceAtLocation(const Board* board, int X, int Y)
{
	try
	{
		if ((X>7)||(Y>7)||(X<0)||(Y<0)) throw "Error: Out of Range @ PieceAtLocation()";
		return board->boarddata[X][Y];
	}
	catch(char* strerr)
	{
		printf(strerr);
		exit(0); //not even tested
	}
}


