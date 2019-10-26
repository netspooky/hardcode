#include "everything.h"

////////////////////////////////////////////////////////////////////////////////
// OpenGL Blend Function
void
cBlend::on(int sFactor, int dFactor)
{
	glDepthMask(GL_FALSE);
	glEnable(GL_BLEND);
	glBlendFunc(sFactor, dFactor);
}

void
cBlend::off(void)
{
	glDisable(GL_BLEND);
	glDepthMask(GL_TRUE);
}

////////////////////////////////////////////////////////////////////////////////
#ifdef _DEBUG
void dp(char *error, ...)
{
	va_list	argptr;
	char	text[1024];
	
	va_start (argptr,error);
	vsprintf (text, error,argptr);
	va_end (argptr);
	
	OutputDebugString( text );
	
	return;
}
#endif
