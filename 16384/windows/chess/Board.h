#pragma once

class Board
{
public:

	Board(void);
	~Board(void);
	void RenderBoard();
	void SetupBoard(bool WhitePlaysTop);
	void LoadBoardImage();

	//array of boarddata and the info of the piece currently on that tile. No piece = 0x0
	//lowest 5 bits is for the type of piece it is
	//highest bit tells which team the piece belongs to (0=white)
	//next 2 highest bits indicates information for castling
	unsigned short boarddata[8][8]; //16 bits each

	SDL_Surface* boardimage;

private:

};
