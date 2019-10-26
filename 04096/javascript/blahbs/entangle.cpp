#include <stdio.h>

int instr = 0;
int count = 0;
int prevchar = 0;

void emit(char c)
{
	if((c == 'f' || c == 'v') && prevchar == '}')
		putc('\n', stdout);
	prevchar = c;	
	if(++count >= 450 && !instr && (c == '(' || c == ')' || c == '{' || c == '}' || c == ';'))
	{
		count = 0;
		putc('\n', stdout);
		prevchar = 0;
	}
	putc(c, stdout);
}

int main(int argc, char** argv)
{
	FILE* fi = fopen(argv[1], "rb");
	fseek(fi, 0, SEEK_END);
	int fsize = ftell(fi);
	fseek(fi, 0, SEEK_SET);
	char* buf = new char [fsize];
	fread(buf, 1, fsize, fi);
	fclose(fi);
	int s = 0, d = 0, p = 0, incomment = 0;
	while(s < fsize)
	{
		char c = buf[s++];
		if(c == '#')
		{
			if(p != 0)
				buf[d++] = p;
			buf[d++] = c;
			while(c != '\n' && c != '\r')
			{
				c = buf[s++];
				buf[d++] = c;
			}
			while(c == '\n' || c == '\r')
				c = buf[s++];
			s--;
			p = 0;
		}
		else
		{
			if(p == '/' && c == '/')
			{
				incomment = 2;
			}
			else if(p == '/' && c == '*')
			{
				incomment = 1;
				c = 0;
			}
			else if(p == '*' && c == '/')
			{
				incomment = 0;
				c = 0;
			}
			else if(p >= ' ' && incomment == 0)
			{
				buf[d++] = p;
			}
			else if(incomment == 2 && c == '\n')
				incomment = 0; 
			p = c;
		}
	}
	if(p != 0)
		buf[d++] = p;
	s = 0;
	while(s < d)
	{
		char c = buf[s++];
		switch(c)
		{
		case '\"':
			emit(c);
			instr ^= 1;
			break;
		case '\'':
			emit(c);
			instr ^= 2;
			break;
		default:
			emit(c);
			break;
		}
		/*switch(c)
		{
		case '\"':
			emit(c);
			instr ^= 1;
			break;
		case '\'':
			emit(c);
			instr ^= 2;
			break;
		case ' ':
			if(instr)
				putc(c, stdout);
			else
				emit(c);
			break;
		default:
			if(c > 0 && c < 127)
				emit(c);
			break;
		}*/
	}
	return 0;
}
