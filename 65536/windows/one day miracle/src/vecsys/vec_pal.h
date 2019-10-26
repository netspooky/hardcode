/*
 *
 *      VecSys Palette
 *
 *      - paletin k„(si)ttelyyn rutiineja
 *      - palettia k„ytt„vien tekstuurien k„sittelyrutiineja
 *
 */

#ifndef VEC_PAL_H
#define VEC_PAL_H

#include "vecsys.h"
#include "vec_type.h"

//  Laskee paletin bumpille tai env+tekstuurille
extern void     vec_calc_etpal(uint8 *epal,uint8 *tpal,uint8 *de,int cols);
//  Laskee gouraudtekstuurin paletin
extern void     vec_calc_gtpal(uint8 *gpal,uint8 *tpal,uint8 *de,int cols,
                    int per);

//  Shiftailee tekstuurin arvoja
extern void     vec_init_tex(uint8 *tex,int cols);

#endif

