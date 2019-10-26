#ifndef TEXTURE_HPP
#define TEXTURE_HPP


#include "LetterN.hpp"
#include "LetterI.hpp"
#include "LetterL.hpp"

#define WIN32_MEAN_AND_LEAN

#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>

#include "Types.hpp"

const int textureWidth= 64;
const int textureHeight= 64;

struct Texture
{
	GLuint	name;
	byte* data;
};

extern Texture plasma;
extern Texture letterTexture;
extern Texture flareTexture;

void InitTextures();
void DeInitTextures();

void RenderLetter( Texture& texture, const byte *letter );
void RenderFlare( Texture& texture );

void HorizontalBlur( Texture& texture, float strength );
void VerticalBlur( Texture& texture, float strength );

#endif
