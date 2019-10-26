#include "linefont.h"



LineFont::LineFont(char* FN,HDC hdc)
{
	HFONT hf,oldf;
	hf = (HFONT)CreateFont(24,0,0,0,FW_DONTCARE,FALSE,FALSE,0,DEFAULT_CHARSET,OUT_TT_ONLY_PRECIS,CLIP_DEFAULT_PRECIS,DRAFT_QUALITY,DEFAULT_PITCH | FF_DONTCARE,FN);
	oldf = (HFONT)SelectObject(hdc,hf);
	
	GLYPHMETRICS glm;
	MAT2 m;
	FIXED f0={0,0},f1={0,100};
	
	m.eM11 = f1;m.eM12 = f0;m.eM21 = f0;m.eM22 = f1;
	
	for(int c=0; c<256; c++)
	{
		unsigned int bufsize = GetGlyphOutline(hdc,c,GGO_NATIVE,&glm,0,0,&m);
		char *glyphBuffer = new char[bufsize+1];

		GetGlyphOutline(hdc,c,GGO_NATIVE,&glm,bufsize,glyphBuffer,&m);
		LC[c].w = glm.gmBlackBoxX;
		LC[c].Curves = new Vector[bufsize/sizeof(POINTFX)];
		LC[c].curvecount=0;
		LC[c].ppcurve[LC[c].curvecount] = 0;
		unsigned int pointcount = 0;
		unsigned int bytes=0;
		
		while(bytes<bufsize)
		{
			TTPOLYGONHEADER *ph = (TTPOLYGONHEADER*)(glyphBuffer+bytes);
			LC[c].Curves[pointcount++]=Vector((float)ph->pfxStart.x.value,(float)-ph->pfxStart.y.value,0);
			LC[c].ppcurve[LC[c].curvecount]++;
			ph->cb += bytes;
			bytes += sizeof(TTPOLYGONHEADER);

			while(bytes<ph->cb)
			{
				TTPOLYCURVE *pc = (TTPOLYCURVE*)(&glyphBuffer[bytes]);
				bytes += sizeof(TTPOLYCURVE)+(pc->cpfx-1)*sizeof(POINTFX);
					for(int i=0; i<pc->cpfx; i++)
					{
						LC[c].Curves[pointcount]=Vector((float)pc->apfx[i].x.value,(float)-pc->apfx[i].y.value,0.0f);
						if(i)
						{
							float d = (LC[c].Curves[pointcount] - LC[c].Curves[pointcount-1]).Magnitude();
							float a = (LC[c].Curves[pointcount]*LC[c].Curves[pointcount-1])/d;
							if(d>200 || pc->wType==TT_PRIM_LINE)
							{
								pointcount++;
								LC[c].ppcurve[LC[c].curvecount]++;
							}
						}
						else
						{
							pointcount++;
							LC[c].ppcurve[LC[c].curvecount]++;
						}						
					}
			}
			LC[c].curvecount++;
			LC[c].ppcurve[LC[c].curvecount] = 0;
		}
		delete [] glyphBuffer;
	}
    SelectObject(hdc,oldf);
	DeleteObject(oldf);
}

LineFont::~LineFont(void)
{
}
