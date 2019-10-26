// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

char ekbhit();
#pragma aux ekbhit modify [ah] value [al] = "mov ah,11h" "int 16h" "mov al,0" "jz nohit" "inc al" "nohit:"
unsigned short egetch();
#pragma aux egetch value [ax] = "mov ah,10h" "int 16h"

static escpressed;

void kbInit()
{
  escpressed=0;
}

void kbClose()
{
  while (ekbhit())
    egetch();
}

int kbCheckESC()
{
  while (ekbhit())
  {
    int k=egetch();
    if (k&0xFF)
      k&=0xFF;
    if (k==27)
      escpressed=1;
  }
  return escpressed;
}
