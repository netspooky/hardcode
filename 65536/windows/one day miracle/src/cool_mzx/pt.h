/*

PT.H

yzi/fit

07.05.1997

*/


#ifndef PT_H
#define PT_H

extern unsigned char  *pt_errorstr; // tässä sitten lukee jotain tai ei lue...

void pt_init ();
int  pt_takemod (char *src);
void pt_play ();

extern int pt_bpmtempo;


#endif
