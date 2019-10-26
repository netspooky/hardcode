#include <stdio.h>
#include <string.h>
#include <vector>

void CleanLine (char* line)
{
	// Strip return line
	if (strstr (line, "\n"))
	{
		*strstr(line, "\n") = 0;
	}

	// Strip line comments
	if (strstr (line, "//"))
	{
		*strstr(line, "//") = 0;
	}

	// Strip starting spaces and tabs
	while (line[0] == '\t' || line[0] == ' ')
	{
		strcpy (line,line+1);
	}

	// Format quotes correctly for the generated string
	char *linePtr = line;

	while (*(linePtr++))
	{
		if (*linePtr == '\"')
		{
			char temp[256] = {0};
			strcpy (temp, linePtr+1);

			*linePtr = '\\';
			*(linePtr+1) = '\"';
			linePtr++;

			strcpy (linePtr+1, temp);
		}
	}
}

int main (int argc, char *argv[])
{
	FILE *fIn, *fOut;

	if (argc < 4)
	{
		printf ("HELP: textIncluder <input> <output> <arrayName>\n");
		return -1;
	}

	fIn = fopen (argv[1], "rt");
	if (!fIn)
	{
		printf ("Unable to open %s\n", argv[1]);
		return -1;
	}

	fOut = fopen (argv[2], "wb");
	if (!fOut)
	{
		printf ("Unable to open %s\n", argv[2]);
		return -1;
	}

	fseek (fIn, 0, 2);
	int size = ftell (fIn);
	char* tmpBuffer = new char[size];
	memset (tmpBuffer, 0, size);
	fseek (fIn, 0, 0);
	
	printf ("Blitting \"%s\" to header file \"%s\" on array \"%s\" ...\n", argv[1],argv[2],argv[3]);

	do
	{
		char line[256] = {0};

		fgets	(line, 256, fIn);

		if (strlen(line) > 0)
		{
			CleanLine (line);

			if (strlen(line) > 0)
			{
				char tmpLine[256] = {0};

				// GLSL HACK: Avoid defines/version screwing stuff :P
				if (line[0] == '#')
					sprintf (tmpLine, "\"%s\\n\"\n", line);
				else
					sprintf (tmpLine, "\"%s\"\n", line);

				strcat (tmpBuffer, tmpLine);
			}
		}
	} while (!feof(fIn));

	fprintf (fOut, "char %s[] = {", argv[3]);
	fprintf (fOut, tmpBuffer);
	fprintf (fOut, "};");

	fclose (fOut);
	fclose (fIn);
}