/*  SD_MAIN.H

by yzi/fit 1997

versio 0.01

changes: 29.04.1997
         0.01 - everything is new

*/

#ifndef SD_MAIN_H
#define SD_MAIN_H

#define SD_ERR 0
#define SD_OK 1

#define AMIGA_MASTERCLOCK 3546836
#define SD_MAXSAMPLES 32
#define SD_MAXCHANNELS 32

#define LOOP_OFF 0
#define LOOP_NORMAL 1
#define LOOP_PINGPONG 2

#define PAN_MIDDLE 0x7F

#define SD_MAXMAINVOLUME 63

#include <stdio.h>
#include "sd_ns.h"

#define SD_USE_DSP16
#include "sd_dsp16.h"
//#define SD_USE_DSP8
//#include "sd_dsp8.h"

/* ---------- Funktio-osoittimien esittely: -------------- */

extern void (*sd_init)();

extern void (*sd_start)();
/* Pist‰‰ miksauksen p‰‰lle, kytkee irq:t jne. */

extern void (*sd_stop)();
/* Lopettaa miksauksen, irq pois. */

extern void (*sd_shutdown)();
/* Kioski kiinni. */

extern void (*sd_secondhand)();
/* T‰t‰ kutsutaan kakkosinterruptissa, mik‰li sellainen tarvitaan. */

extern int (*sd_getsample)(int snum, char *src, int len,
                           int loopstart, int loopend, int looptype);
/* Palauttaa SD_OK, tai SD_ERR, jos esim. GUSin muisti loppui. */

extern void (*sd_selectchannel)(int cnum);
/* Kanavakohtaiset funktiot - kanava on valittava ensin!!! */
extern void (*sd_setsample)(int snum);
extern void (*sd_setamigaperiod)(int period);
extern void (*sd_setvolume)(int volume);
extern void (*sd_setpanning)(int panning);
extern void (*sd_setoffset)(int offset);

/* Yhteiset funktiot */
extern void (*sd_setmainvolume)(int volume);
extern void (*sd_setactivechannels)(int activechannels);

/* -------------- Muuttujien esittely: ------------------- */

extern char *sd_devicename;
extern char *sd_errorstr;

extern int sd_hand;

#endif
