
#ifndef WRITER_H
#define WRITER_H

#define WR_SINGLE 1 /* Single color */
#define WR_TWO    2 /* Dual color */
#define WR_THREE  3 /* Three colors */
#define WR_ROWS   4 /* Rows */
#define WR_COLS   8 /* Columns */
#define WR_CHECKER 16 /* Checkerboard */

void writer_init(void);
void write_string(char *s,int rev,int clr,int mod);

#endif
