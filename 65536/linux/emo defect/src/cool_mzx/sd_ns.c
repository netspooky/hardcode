/*  SD_NS.C

by yzi/fit 1997

versio 0.01

changes: 08.05.1997
	 0.01 - everything is new

*/


#include "sd_main.h"
#include "sd_ns.h"
#include "sd_mix.h"

void ns_init ()
{
/*        sd_mix_init (44100);  */
} /* ns_init */

void ns_dummyfunction()
{
} /* ns_dummyfunction */

int sd_ns_init ()
{
        /* Asetellaan funktiot */
        sd_init = ns_init;

        sd_secondhand = ns_dummyfunction;
        sd_start = ns_dummyfunction;
        sd_stop = ns_dummyfunction;
        sd_shutdown = ns_dummyfunction;

        sd_mix_setfunctions();       

        sd_devicename = "Super Fit NoSound Device 2.0c";

	return SD_OK;
} /* sd_sb16_init */

