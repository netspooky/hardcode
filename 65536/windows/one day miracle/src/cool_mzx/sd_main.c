/*  SD_MAIN.C

by yzi/fit 1997

versio 0.01

changes: 29.04.1997
         0.01 - everything is new


Systeemi kaivannee v‰h‰n selityst‰:

        <selit‰n kun kerki‰n>

*/

#include "sd_main.h"


void (*sd_init)();

void (*sd_start)();
/* Pist‰‰ miksauksen p‰‰lle, kytkee irq:t jne. */

void (*sd_stop)();
/* Lopettaa miksauksen, irq pois. */

void (*sd_shutdown)();
/* Sulkee maailmankaikkeuden. */

void (*sd_secondhand)();
/* T‰t‰ kutsutaan kakkosinterruptissa. (GUS!) */

int (*sd_getsample)(int snum, char *src, int len,
                    int loopstart, int loopend, int looptype);

void (*sd_selectchannel)(int cnum);
/* Kanavakohtaiset funktiot - kanava on valittava ensin!!! */
void (*sd_setsample)(int snum);
void (*sd_setamigaperiod)(int period);
void (*sd_setvolume)(int volume);
void (*sd_setpanning)(int panning);
void (*sd_setoffset)(int offset);

void (*sd_setmainvolume)(int volume);
void (*sd_setactivechannels)(int activechannels);


char *sd_errorstr="";

char *sd_devicename="";

int sd_hand;
