#ifndef _WATER_H_
#define _WATER_H_

extern i16	*pBuffer[2];
extern i32	waterwh,current;
extern f32 radius;
extern i8 power;

extern void initWater(void);
extern void deinitWater(void);
extern void updateWater(void);
extern void drawWater(void);
//extern void drawWater2(void);
extern void hitWater(void);

#endif
