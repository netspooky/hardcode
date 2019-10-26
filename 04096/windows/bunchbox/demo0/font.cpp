// BUNCHBOX, Brad Smith 9/18/2009

#include "font.h"
#include "font56.h"
#include "geometry.h"

uint8 font_matrix[256]; // ascii mapping

void setup_font()
{
	// setup ascii mapping
	::memset(font_matrix,FONT56_BLANK,256);
	// setup consecutive characters
	for ( uint8 i='A'; i <= 'Z'; ++i )
	{
		font_matrix[i] = FONT56_A + i - 'A';
		uint8 il = i + 'a' - 'A';
		font_matrix[il] = FONT56_a + il - 'a';
	}
	for ( uint8 i='0'; i <= '9'; ++i )
	{
		font_matrix[i] = FONT56_0 + i - '0';
	}
	// setup individual characters
	font_matrix['.'] = 52;
	font_matrix[','] = 53;
	font_matrix[';'] = 54;
	//font_matrix['?'] = 55;
	font_matrix['!'] = 56;
	font_matrix[':'] = 57;
	font_matrix['-'] = 58;
	//font_matrix['\''] = 59;
	font_matrix['/'] = 60;
	//font_matrix['\\'] = 61;
	//font_matrix['|'] = 62;
	font_matrix['@'] = 63;
	//font_matrix['_'] = 64;
	//font_matrix['*'] = 75;
	//font_matrix['#'] = 76;
}

static bool font_pixel( uint32 value, int x, int y )
{
	ASSERT( x >= 0 && x < 5 );
	ASSERT( y >= 0 && y < 6 );
	uint32 mask = 1 << ( x + ( y * 5 ) );
	return 0 != ( mask & value );
}

void draw_char( char c, const vec3 & pos )
{
	const uint8 index = font_matrix[ uint8(c) ];
	ASSERT( index < 78 );
	const uint32 value = FONT56[ index ];

	const float BOX_SHRINK = 0.2f;
	const float YP = -1.0f / 6.0f;
	const float XP = 1.0f / 5.0f;
	const float YS = YP * BOX_SHRINK;
	const float XS = XP * BOX_SHRINK;
	float fy = 1.0f + YS;
	for ( int y = 0; y < 6; ++y, fy+=YP )
	{
		float fx = XS;
		for ( int x = 0; x < 5; ++x, fx+=XP )
		{
			if ( font_pixel( value, x, y ) )
			{
				vec3 min = pos + vec3( fx, fy, 0.0f );
				vec3 max = min + vec3( XP-XS, YP-YS, XP-XS );
				geom_box( min, max );
			}
		}
	}
}

// end of file
