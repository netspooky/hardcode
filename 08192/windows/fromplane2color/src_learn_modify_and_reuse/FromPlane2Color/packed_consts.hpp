#ifndef FROMPLANE2COLOR_PACKED_CONSTS_HPP
#define FROMPLANE2COLOR_PACKED_CONSTS_HPP

#define DECL_SS(name, val)												\
__declspec(align(16)) const static float name[] = {val, val, val, val};
#define DECL_PS(name, val0, val1, val2, val3)							\
__declspec(align(16)) const static float name[] = {val0, val1, val2, val3};

//Virtual constant scaler values.
//この定数を使った方がファイルサイズが小さくなったり大きくなったり・・・.
DECL_SS(cpsn1, -1.0f);
DECL_SS(cps1d8, 0.125f);
DECL_SS(cps1d4, 0.25f);
DECL_SS(cps1d2, 0.5f);
DECL_SS(cps0, 0.0f);
DECL_SS(cps1, 1.0f);
DECL_SS(cps2, 2.0f);
DECL_SS(cps4, 4.0f);
DECL_SS(cps8, 8.0f);
DECL_SS(cps16, 16.0f);
DECL_SS(cps255, 255.0f);

#endif
