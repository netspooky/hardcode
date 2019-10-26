comment #+

    This is the source-release of "Stoerfall Ost", our winning 4kb
    multimedia presentation that was first shown at Dialogos 2000.
    If you have any questions concerning the sourcecode drop us a
    line at freestyle@freestylas.org. Feel free to visit our
    webpage at http://www.freestylas.org.
    Copyright (C) 2001 freestyle
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
    
+#



scriptRoboter1	label byte
	scptLinear	0,	20*16,3,6
	scptLoop	32,	32
	scptEnd

scriptRoboter2	label byte
	scptLinear	0,	22*16,2,6
	scptLoop	32,	32
	scptEnd


comment #+
scriptRoboter2	label byte
	scptLinear	0,	22*16,1,6
	scptLoop	32,	32
	scptEnd

scriptRoboter3	label byte
	scptLinear	0,	23*16,1,6
	scptLoop	32,	32
	scptEnd
+#

scriptRoboter4	label byte
	scptLinear	0,	30*16,5,4
	scptLoop	32,	32
	scptEnd
	
scriptRoboter5	label byte
	scptSet		0,	100*16
	scptClear	16,	100*16
	scptLoop	32,	32
	scptEnd
	
scriptRoboter6	label byte
	scptClear	0,	101*16
	scptSet		16,	101*16
	scptLoop	32,	32
	scptEnd
	
scriptTrav1	label byte
	scptDelay	0
	scptLinear	16,	70*16,4,1
	scptLoop	48,	32
	scptEnd

scriptBand1	label byte
	scptLinear	0,	50*16,3,1
	scptLoop	32,	32
	scptEnd

scriptPresse1	label byte
	scptDelay	0
	scptLinear	4,	60*16,1,2
	scptDelay	8
	scptLoop	32,	32
	scptEnd

scriptPresse2	label byte
	scptDelay	0
	scptLinear	20,	80*16,1,2
	scptDelay	24
	scptLoop	32,	32
	scptEnd

comment #+
END_TICK = 895
;END_TICK = 63

scriptLookat	label byte
	scptLinear	0,	210*16,3,7
	scptDelay	END_TICK
	scptEnd
	
scriptCamera	label byte
	scptLinear	0,	220*16,3,7
	scptSet		END_TICK,	0
	scptEnd
+#

scriptCamera	label byte
	scptLinear	0,	210*16,6,7
	scptDelay	896
	scptSet		896+71,	0
	scptEnd
