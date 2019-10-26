#include "stdinc.hpp"
#include "Texture.hpp"

static const int letterSize= 32;


Texture plasma;
Texture letterTexture;
Texture flareTexture;




void RenderFlare( Texture& texture )
{
	// make flare..

	for( int y= 0; y< textureHeight; y++ )
	{
		for( int x= 0; x< textureWidth; x++ )
		{
			float 
				ax= textureWidth/2.0 - x,
				ay= textureHeight/2.0 - y;
			float d= sqrt( ax*ax + ay*ay );

//			if( d < textureWidth*textureWidth/4.0) )
//				texture.data[ x + y*textureWidth ]= 
//					(1.0 - d/(textureWidth*textureWidth/4.0))*255.0;
			if( d < textureWidth/2.0 )
				texture.data[ x + y*textureWidth ]= 
					(1.0 - d/(textureWidth/2.0))*255.0;
			else
				texture.data[ x + y*textureWidth ]= 0;
		}
	}
}



void InitTextures()
{
	letterTexture.data= new byte[ textureWidth*textureHeight ];
	flareTexture.data= new byte[ textureWidth*textureHeight ];

	RenderFlare( flareTexture );
}

void DeInitTextures()
{
	delete []letterTexture.data;
}

void RenderLetter( Texture& texture, const byte *letter )
{
	const byte *src= letter;

	byte *dest= 
		&texture.data[ textureWidth*((textureHeight- letterSize)/2)
			+ ((textureWidth- letterSize)/2) ];
	

	for( int line= 0; line< letterSize; line++ )
	{
		memcpy( dest, src, letterSize );
		dest+= textureWidth;
		src+= letterSize;
	}
}




void HorizontalBlur( Texture& texture, float strength )
{
	static byte tempBuffer[ textureWidth ];

	for( unsigned int line= 0; line<textureHeight; line++) 
	{
		byte
			*srcPtr= texture.data+line*textureWidth,
			*dataPtr= tempBuffer;

		float colour = srcPtr[0];

		{
		for( unsigned int i = 0; i < textureWidth; i ++) {
			colour += (srcPtr[i] - colour) * strength;
			dataPtr[i]= int(colour);
		}
		}

		colour = dataPtr[ textureWidth - 1];

		for(unsigned int i = textureWidth - 1; i >0 ; i --) {
			colour += int((srcPtr[i] - colour) * strength);
			if(( dataPtr[i] + colour) > 255) {
				dataPtr[i] = 255;
			} else {
				dataPtr[i]+= int(colour);
			}
		}
		memcpy( srcPtr, dataPtr, textureWidth );
	}
}

void VerticalBlur( Texture& texture, float strength )
{
	float tempData[ textureWidth ];
	byte tplane[ textureWidth*textureHeight ];
	
	// init temp data
	for( unsigned int column= 0; column<textureWidth; column++ )
	{
		tempData[column]= texture.data[column];
	}

	{
	for( unsigned int row= 0; row< textureHeight; row++) 
	{
		byte
			*srcPtr= texture.data+row*textureWidth,
			*dataPtr= tplane+row*textureWidth;

		for( unsigned int column = 0; column < textureWidth; column++ ) 
		{
			tempData[column]+=
				(srcPtr[column] - tempData[column]) * strength;
			dataPtr[column] = tempData[column];
		}
	}
	}

	// init temp data (again)
	{
	for( unsigned int column= 0; column<textureWidth; column++ )
	{
		tempData[column]= texture.data[column+textureWidth-1];
	}
	}

	{
	for( int row= textureHeight-1; row>= 0; row--) {
		byte
			*srcPtr= texture.data + row*textureWidth,
			*dataPtr= tplane + row*textureWidth;

		for( unsigned int column= 0; column< textureWidth; column++ ) 
		{
			tempData[column] += 
				(srcPtr[column] - tempData[column]) * strength;

			if(dataPtr[column] + tempData[column] > 255) {
				dataPtr[column] = 255;
			} else {
				dataPtr[column] += tempData[column];
			}
		}
	}
	}
	memcpy( texture.data, tplane, textureWidth*textureHeight );

}