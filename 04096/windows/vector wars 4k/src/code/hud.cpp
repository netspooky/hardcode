#include "stableheaders.hpp"

#include "hud.hpp"

#include "globals.hpp"
#include "gameobjects.hpp"
#include "video.hpp"

//////////////////////////////////////////////////////////////////////////
// DATA
//////////////////////////////////////////////////////////////////////////
#pragma data_seg(".data_hud")

// the text rectangle for any text displayed in the game. actual positioning
// is done via flags such as DT_CENTER, DT_TOP etc.
RECT g_textRect = 
{
	16, 
	16, 
	-16,	// the screen width is added during runtime to get an offset from the right border
	-16		// the screen height is added during runtime to get an offet from the lower border
};

//////////////////////////////////////////////////////////////////////////
// CODE
//////////////////////////////////////////////////////////////////////////
#pragma  code_seg(".code_seg")

////////////////////////////////////////////////////////////////////////////////
//
//	HUD_Init()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Sets up the HUD.

*/
void HUD_Init()
{
	// the width and height is only know during runtime, so adjust the text rendering rectangle
	g_textRect.right += SCREEN_WIDTH;
	g_textRect.bottom += SCREEN_HEIGHT;
}

////////////////////////////////////////////////////////////////////////////////
//
//	HUD_IntToString()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Converts an integer into a 6 digit string.

	\param _pBuffer

		Pointer to the buffer to store the string.

	\param _value

		The value to convert.

*/
void HUD_IntToString(char* _pBuffer, unsigned _value)
{
	unsigned divisor = 100000;
	unsigned quotient;

	// any more digits?
	while (divisor > 0)
	{
		// yes! so divide by the current divisor
		quotient = _value / divisor;
		
		// store the ansi digit and advance buffer
		*_pBuffer++ = '0' + quotient;

		// get the remaining digits
		_value %= divisor;
		
		// adjust the divisor for the next digit
		divisor /= 10;
	}

	// terminate the string
	*_pBuffer = 0;
}

////////////////////////////////////////////////////////////////////////////////
//
//	HUD_DrawText()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Render the given text with the given flags within the text rectangle.

	\param _pText

		The text to render.

	\param _flags

		The flags to use.

*/
void HUD_DrawText(const char* _pText, const DWORD _flags)
{
	g_pFontText->DrawText(NULL, _pText, -1, &g_textRect, _flags, COLOR_FONT);
}

////////////////////////////////////////////////////////////////////////////////
//
//	HUD_Render()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Render the ingame HUD (score).

*/
void HUD_Render()
{
	char buffer[16];

	// convert the score into a string
	HUD_IntToString(buffer, g_player.score);
	
	// render the score at the top of the screen
	HUD_DrawText(buffer, DT_WORDBREAK | DT_NOCLIP | DT_CENTER | DT_TOP);
}
