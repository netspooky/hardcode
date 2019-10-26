#ifndef _BITMAP_FONT_H
#define _BITMAP_FONT_H

class	Font{
	GLuint	base;				// Base Display List For The Font
	GLuint	loop;				// Generic Loop Variable

	GLfloat	cnt1;				// 1st Counter Used To Move Text & For Coloring
	GLfloat	cnt2;				// 2nd Counter Used To Move Text & For Coloring
	GLuint number_texture;
	int screen_x_font;
	int screen_y_font;
	
	int LoadGLTextures(char *texture_name,GLuint *texture)				// Naèíta obrázok a uloži ako textury
	{
		int Status=TRUE;								// indikator
		AUX_RGBImageRec *TextureImage;					// miesto pre štruktúru

		TextureImage=NULL;
		if (TextureImage=LoadBMP(texture_name))
		{
			glGenTextures(1, texture);
			glBindTexture(GL_TEXTURE_2D, *texture);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP );		// nastavuje za textury sa v smere u (vodorovnom) neopakuju
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP );		// nastavuje za textury sa v smere v (zvislom) neopakuju
			glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage->sizeX, TextureImage->sizeY, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage->data);
		}
		else 
		{	MessageBox(NULL,"Chyba naèítania obrázka.",texture_name,MB_ICONERROR);Status=false;}

		if (TextureImage)									// Ak textura existuje
		{
			if (TextureImage->data)free(TextureImage->data);// ak existuju data uvo¾ni z pamäte
			free(TextureImage);								// uvo¾ni štruktúru
		}
		return Status;
	}

	AUX_RGBImageRec* LoadBMP(char *Filename)			// Naèítanie bitmapového obrázka
	{
		FILE *File=NULL;								// smernik na subor

		if (!Filename)return NULL;						// skúška èi meno súboru bolo zadané
		File=fopen(Filename,"r");						// otvorenie súboru na èítanie
		if (File)										// existuje súbor ?
		{
			fclose(File);								// Uzatvorenie súbora
			return auxDIBImageLoad(Filename);			// Naèíta obrázok a vráti pointer
		}
		return NULL;									// Ak sa obrázok nenaèítal vráti NULL
	}

public:	
	Font::Font(char *file_name, int *error, int scrwidth, int scrheight)					// Build Our Font Display List
	{
		screen_x_font = scrwidth;
		screen_y_font = scrheight;
		float	cx;											// Holds Our X Character Coord
		float	cy;											// Holds Our Y Character Coord
		*error = !LoadGLTextures(file_name, &number_texture);
		if(*error)return;

		base=glGenLists(256);								// Creating 256 Display Lists
		glBindTexture(GL_TEXTURE_2D, number_texture);		// Select Our Font Texture
		for (loop=0; loop<256; loop++)						// Loop Through All 256 Lists
		{
			cx=float(loop%16)/16.0f;						// X Position Of Current Character
			cy=float(loop/16)/16.0f;						// Y Position Of Current Character

			glNewList(base+loop,GL_COMPILE);				// Start Building A List
			glBegin(GL_QUADS);							// Use A Quad For Each Character
			glTexCoord2f(cx,1.0f-cy-0.0625f);		// Texture Coord (Bottom Left)
			glVertex2i(0,0);						// Vertex Coord (Bottom Left)
			glTexCoord2f(cx+0.0625f,1.0f-cy-0.0625f);	// Texture Coord (Bottom Right)
			glVertex2i(16,0);						// Vertex Coord (Bottom Right)
			glTexCoord2f(cx+0.0625f,1.0f-cy);		// Texture Coord (Top Right)
			glVertex2i(16,16);						// Vertex Coord (Top Right)
			glTexCoord2f(cx,1.0f-cy);				// Texture Coord (Top Left)
			glVertex2i(0,16);						// Vertex Coord (Top Left)
			glEnd();									// Done Building Our Quad (Character)
			glTranslatef(10,0,0);	//10,0,0			// Move To The Right Of The Character
			glEndList();									// Done Building The Display List
		}													// Loop Until All 256 Are Built
	}

	Font::~Font(GLvoid)									// Delete The Font From Memory
	{
		glDeleteLists(base,256);							// Delete All 256 Display Lists
		glDeleteTextures( 1, &number_texture );
	}

	GLvoid Font::glPrint_xy(GLint x, GLint y, char *string, int set)	// Where The Printing Happens
	{
		if (set>1)set=1;
		glBlendFunc(GL_SRC_ALPHA			,	GL_ONE_MINUS_SRC_COLOR);	// nastavenie miešania farieb
		//farba bodu = (pôvodná farba * ALPHA)	+	(kreslená farba - pôvodná farba)
		glEnable(GL_BLEND);									// povolenie miešania farieb

		glBindTexture(GL_TEXTURE_2D, number_texture);		// Select Our Font Texture
		glDisable(GL_DEPTH_TEST);							// Disables Depth Testing
		glMatrixMode(GL_PROJECTION);						// Select The Projection Matrix
		glPushMatrix();										// Store The Projection Matrix
		glLoadIdentity();									// Reset The Projection Matrix
		glOrtho(0,screen_x_font,0,screen_y_font,-1,1);				// Set Up An Ortho Screen
		glMatrixMode(GL_MODELVIEW);							// Select The Modelview Matrix
		glPushMatrix();										// Store The Modelview Matrix
		glLoadIdentity();									// Reset The Modelview Matrix
		glTranslated(x,y,0);								// Position The Text (0,0 - Bottom Left)
		glListBase(base-32+(128*set));						// Choose The Font Set (0 or 1)
		glCallLists(strlen(string),GL_BYTE,string);			// Write The Text To The Screen
		glMatrixMode(GL_PROJECTION);						// Select The Projection Matrix
		glPopMatrix();										// Restore The Old Projection Matrix
		glMatrixMode(GL_MODELVIEW);							// Select The Modelview Matrix
		glPopMatrix();										// Restore The Old Projection Matrix
		glEnable(GL_DEPTH_TEST);							// Enables Depth Testing

		glDisable(GL_BLEND);								//vypnutie miešania farieb

	}

	GLvoid Font::glPrint(GLint x, GLint y, char *string, int set)	// Where The Printing Happens
	{
		x = x*11;											// vypocet x zo suradnice stlpca
		y = screen_y_font - (y+1)*16;							// vypocet y zo suradnice riadka

		if (set>1)set=1;
		glBlendFunc(GL_SRC_ALPHA			,	GL_ONE_MINUS_SRC_COLOR);	// nastavenie miešania farieb
		//farba bodu = (pôvodná farba * ALPHA)	+	(kreslená farba - pôvodná farba)
		glEnable(GL_BLEND);									// povolenie miešania farieb

		glBindTexture(GL_TEXTURE_2D, number_texture);		// Select Our Font Texture
		glDisable(GL_DEPTH_TEST);							// Disables Depth Testing
		glMatrixMode(GL_PROJECTION);						// Select The Projection Matrix
		glPushMatrix();										// Store The Projection Matrix
		glLoadIdentity();									// Reset The Projection Matrix
		glOrtho(0,screen_x_font,0,screen_y_font,-1,1);				// Set Up An Ortho Screen
		glMatrixMode(GL_MODELVIEW);							// Select The Modelview Matrix
		glPushMatrix();										// Store The Modelview Matrix
		glLoadIdentity();									// Reset The Modelview Matrix
		glTranslatef((float)x,(float)y,0);					// Position The Text (0,0 - Bottom Left)
		glListBase(base-32+(128*set));						// Choose The Font Set (0 or 1)
		glCallLists(strlen(string),GL_BYTE,string);			// Write The Text To The Screen
		glMatrixMode(GL_PROJECTION);						// Select The Projection Matrix
		glPopMatrix();										// Restore The Old Projection Matrix
		glMatrixMode(GL_MODELVIEW);							// Select The Modelview Matrix
		glPopMatrix();										// Restore The Old Projection Matrix
		glEnable(GL_DEPTH_TEST);							// Enables Depth Testing

		glDisable(GL_BLEND);								//vypnutie miešania farieb

	}

	void Font::Begin()
	{
		glBlendFunc(GL_SRC_ALPHA			,	GL_ONE_MINUS_SRC_COLOR);	// nastavenie miešania farieb
		//farba bodu = (pôvodná farba * ALPHA)	+	(kreslená farba - pôvodná farba)
		glEnable(GL_BLEND);
		glBindTexture(GL_TEXTURE_2D, number_texture);		// Select Our Font Texture
		glDisable(GL_DEPTH_TEST);							// Disables Depth Testing
		glMatrixMode(GL_PROJECTION);						// Select The Projection Matrix
		glPushMatrix();										// Store The Projection Matrix
		glLoadIdentity();									// Reset The Projection Matrix
		glOrtho(0,screen_x_font,0,screen_y_font,-1,1);				// Set Up An Ortho Screen
		glMatrixMode(GL_MODELVIEW);							// Select The Modelview Matrix
		glPushMatrix();										// Store The Modelview Matrix
	}

	void Font::End()
	{
		glMatrixMode(GL_PROJECTION);						// Select The Projection Matrix
		glPopMatrix();										// Restore The Old Projection Matrix
		glMatrixMode(GL_MODELVIEW);							// Select The Modelview Matrix
		glPopMatrix();										// Restore The Old Projection Matrix
		glEnable(GL_DEPTH_TEST);							// Enables Depth Testing
		glDisable(GL_BLEND);								// vypnutie miešania farieb
	}

	void Font::Print(GLint x, GLint y, char * string, int set)
	{
		x = x*11;											// vypocet x zo suradnice stlpca
		y = screen_y_font - (y+1)*16;							// vypocet y zo suradnice riadka

		if (set>1)set=1;
		glLoadIdentity();									// Reset The Modelview Matrix
		glTranslatef((float)x,(float)y,0);					// Position The Text (0,0 - Bottom Left)
		glListBase(base-32+(128*set));						// Choose The Font Set (0 or 1)
		glCallLists(strlen(string),GL_BYTE,string);			// Write The Text To The Screen
	}

	void Font::Print_scale(GLint x, GLint y, char * string, int set,float scale_x,float scale_y)
	{
		x = x*11;											// vypocet x zo suradnice stlpca
		y = screen_y_font - (y+1)*16;							// vypocet y zo suradnice riadka

		if (set>1)set=1;
		glLoadIdentity();									// Reset The Modelview Matrix
		glTranslatef((float)x,(float)y,0);					// Position The Text (0,0 - Bottom Left)
		glScalef(scale_x,scale_y,1.0f);
		glListBase(base-32+(128*set));						// Choose The Font Set (0 or 1)
		glCallLists(strlen(string),GL_BYTE,string);			// Write The Text To The Screen
	}

	void Font::Print_xy(GLint x, GLint y, char *string, int set)
	{
		if (set>1)set=1;
		glLoadIdentity();									// Reset The Modelview Matrix
		glTranslatef((float)x,(float)y,0);					// Position The Text (0,0 - Bottom Left)
		glListBase(base-32+(128*set));						// Choose The Font Set (0 or 1)
		glCallLists(strlen(string),GL_BYTE,string);			// Write The Text To The Screen
	}

	void Font::Print_xy_scale(GLint x, GLint y, char *string, int set,float scale_x,float scale_y)
	{
		if (set>1)set=1;
		glLoadIdentity();									// Reset The Modelview Matrix
		glTranslatef((float)x,(float)y,0);					// Position The Text (0,0 - Bottom Left)
		glScalef(scale_x,scale_y,1.0f);
		glListBase(base-32+(128*set));						// Choose The Font Set (0 or 1)
		glCallLists(strlen(string),GL_BYTE,string);			// Write The Text To The Screen
	}

	void Font::Print_xy_rot(GLint x, GLint y, char *string, int set,float uhol,float scale)
	{
		if (set>1)set=1;
		glLoadIdentity();									// Reset The Modelview Matrix
		glTranslatef((float)x,(float)y,0);					// Position The Text (0,0 - Bottom Left)
		glRotatef(uhol,0,0,1);
		glScalef(scale,1.0f,1.0f);
		glListBase(base-32+(128*set));						// Choose The Font Set (0 or 1)
		glCallLists(strlen(string),GL_BYTE,string);			// Write The Text To The Screen
	}
};

#endif