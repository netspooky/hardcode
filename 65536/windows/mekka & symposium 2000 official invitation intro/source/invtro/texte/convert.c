// text converter for ms2000 invitation intro

#include <stdio.h>
#include <string.h>

#define  NEWPARA          4
#define  NEWLINE          8

FILE  *in, *out;
char   outbuf[16384];
int    outp, outlen;

void output(char what)
{
  outbuf[outp++]=what;
  outlen++;

  if (outp==16384)
  {
    fwrite(outbuf, 1, outp, out);
    outp=0;
  }
}

void outflush()
{
  fwrite(outbuf, 1, outp, out);
  outp=0;
}

int iswhite(int c)
{
  return (c==' ') || (c=='\t') || (c=='\n');
}

int main(int argc, char *argv[])
{
  char   modes[8192];
  int    c, mode, w, inword;

  if (argc!=3)
  {
    printf("syntax: convert infile outfile\n");
    return 1;
  }

  in=fopen(argv[1], "rt");
  out=fopen(argv[2], "wb");

  if (!in || !out)
  {
    printf("file open error\n");
    if (in) fclose(in);
    if (out) fclose(out);
    return 1;
  }

  while (!feof(in))     // skip whitespace at begin
  {
    c=getc(in);

    if (!iswhite(c))
    {
      ungetc(c, in);
      break;
    }
  }

  mode=w=0;
  inword=0;
  outp=outlen=0;

  while (!feof(in))
  {
    c=getc(in);

    if (c=='') { mode&=~3; continue; };
    if (c=='~') { mode=(mode&~3)|1; continue; };
    if (c=='|') { mode=(mode&~3)|2; continue; };
    if (c=='^') { mode=(mode&~3)|3; continue; };
    if (c=='\\') { mode|=NEWLINE; continue; };

    if (iswhite(c) && inword)
    {
      output(0);
      modes[w++]=mode;
      inword=0;
      mode&=0x3;         // fontmask
    }

    if (!iswhite(c))
    {
      output(c);
      inword=1;
    }

    if (c=='\n')
    {
      if ((c=getc(in))=='\n')
      {
        mode|=NEWPARA;
        while (iswhite((c=getc(in))));
      }

      ungetc(c, in);
    }
  }

  if (inword)
  {
    output(0);
    modes[w++]=mode;
    inword=0;
    mode&=0x3;
  }

  output(0);

  for (c=0; c<w; c++)
    output(modes[c]);

  outflush();

  printf("%s: %ld words, %ld bytes\n", argv[2], w, outlen);

  fclose(in);
  fclose(out);

  return 0;
}
