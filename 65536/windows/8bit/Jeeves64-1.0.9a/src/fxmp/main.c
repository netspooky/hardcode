/*
  This file is part of fxmp, an .xm player.
  fxmp is copyright 2000 by Osman Keskin <spectre@winterland.net>

  this version of fxmp is tailored for 64k GNU/Linux and win32 intro
  development (as part of Jeeves64 by Kuno Woudt <warp-tmt@dds.nl>).
  
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING; if not, write to
  the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
*/

#include <stdio.h>
#include <stdlib.h>

#include "Fxmp.h"
#include "Drv_dsp.h"
#include "drive.xm.h"

int
main (void)
{
	xm_module *xm;

	printf ("[F]lare [XM] [P]layer by spectre of flare\n");
	printf ("win32 waveOut support by Warp of Bliss <warp-tmt@dds.nl>\n\n");

	if (fxmp_init (&dsp, 0)!=0) exit(1); 

	xm = xm_load (drive_xm_data, DRIVE_XM_SIZE);
	if (xm == 0)
		{
			printf ("error decoding .xm\n");
			exit (1);
		}

	fxmp_load_patches (xm);

	if (getenv ("ORD"))
		fxmp_set_ord (atoi (getenv ("ORD")));

	fxmp_play (xm);
	printf("playing... press ctrl-c to stop\n");
	while (!fxmp_poll (xm));
	fxmp_deinit ();
	return 0;
}
