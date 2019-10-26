#ifndef __ZN_TYPES_
#define __ZN_TYPES_

typedef unsigned char uchar;
typedef unsigned short ushort;
typedef unsigned int  uint;
typedef unsigned long ulong;

#define ZENITH_MAX_DATA_SIZE 1024

#define ZENITH_TYPE_CONSTRUCTOR     0
#define ZENITH_TYPE_KEYFRAME        1
#define ZENITH_TYPE_MODIFIER        2
#define ZENITH_TYPE_RENDER          3
#define ZENITH_TYPE_USEREFFECT      4

//ZENITH_TYPE_CONSTRUCTOR opcode constants
//constructors
#define ZENITH_OP_C_SCENE      0
#define ZENITH_OP_C_OBJECT     1
#define ZENITH_OP_C_CAMERA     2
#define ZENITH_OP_C_LIGHT      3
#define ZENITH_OP_C_SHAPE      4
//destructors
#define ZENITH_OP_D_SCENE      5
#define ZENITH_OP_D_OBJECT     6
#define ZENITH_OP_D_CAMERA     7
#define ZENITH_OP_D_LIGHT      8
#define ZENITH_OP_D_SHAPE      9
//---------------------------------------
//ZENITH_TYPE_MODIFIER opcode constants
#define ZENITH_OP_M_ARRAY         0
#define ZENITH_OP_M_TRANSFORM     1
#define ZENITH_OP_M_SHAPELOFT     2


//---------------------------------
typedef uchar ZENITH_CHUNK_TYPE;
//---------------------------------
#pragma pack(1)
//ZENITH_TYPE_CONSTRUCTOR header struct
struct ZENITH_CONSTRUCTOR{
  uchar      opcode;
  uchar      scene_id;
  union{
    uchar       object_id;
    uchar       camera_id;
    uchar       light_id;
    uchar       shape_id;
  };
  ushort     datasize;
};
//---------------------------------
#pragma pack(1)
//ZENITH_TYPE_MODIFIER header struct
struct ZENITH_MODIFIER{
  uchar      opcode;
  uchar      scene_id;
  union{
    uchar       object_id;
    uchar       camera_id;
    uchar       light_id;
    uchar       shape_id;
  };
  ushort     datasize;
};
//---------------------------------
#pragma pack(1)
//ZENITH_TYPE_KEYFRAME header struct
struct ZENITH_KEYFRAME{
  uint        startframe;
  uint        endframe;
  ushort      step;
};
//----------------------------------
#pragma pack(1)
//ZENITH_TYPE_RENDER header struct
struct ZENITH_RENDER{
  uchar       scene_id;
  uchar       camera_id;
};
//----------------------------------
#pragma pack(1)
struct ZENITH_SELECTOR{
  uchar       scene_id;
  uchar       object_id;
};
//----------------------------------
#pragma pack(1)
struct ZENITH_M_ARRAY{
  ushort      count;
  char        pmatrix[66];
};
//----------------------------------
#pragma pack(1)
struct ZENITH_M_TRANSFORM{
  char        pmatrix[66];
};
//----------------------------------
#endif