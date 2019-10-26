
class SDLFont
{

public:

	SDLFont();
	~SDLFont();
	void SDLFont::WriteString(char* str, int X, int Y);

	#ifdef _DEBUG
	void GetImageDataDEBUG();
	#endif

private:
	SDL_Surface* characters;

};