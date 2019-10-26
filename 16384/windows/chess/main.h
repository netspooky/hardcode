
//prototypes for main.cpp
void HandleMouseInput();
int MoveIsValid(int fromX, int fromY, int toX, int toY, const Board* board);
inline int PieceAtLocation(const Board* board, int X, int Y);
void GetImageData();
void LoadImageFromArray();
bool KingInCheck(const Board* board);
//bool KingInMate(const Board* board, bool* StaleMate)
bool DetectMate(const Board* board, char* mateType);