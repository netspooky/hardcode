/*
 *
 *      VecSys 3ds
 *
 *      - 3ds-formaatin chunk id:t
 *
 */

#ifndef VEC_3DS_H
#define VEC_3DS_H

/*      3ds:n chunkien id:t     */

#define M3DMAGIC                0x4d4d      //      .3ds
#define MLIBMAGIC               0x3daa      //      .mli
#define PRJMAGIC                0x3dc2      //      .prj
#define MATMAGIC                0x3dff      //      .mat

#define NULL_CHUNK              0x0000
#define M3D_VERSION             0x0002
#define M3D_KFVERSION           0x0005
#define COLOR_F                 0x0010
#define COLOR_24                0x0011
#define LIN_COLOR_24            0x0012
#define LIN_COLOR_F             0x0013
#define INT_PERCENTAGE          0x0030
#define FLOAT_PERCENTAGE        0x0031
#define MASTER_SCALE            0x0100

#define MDATA                   0x3d3d      //      objektidata
#define MESH_VERSION            0x3d3e
#define NAMED_OBJECT            0x4000  
#define OBJ_HIDDEN              0x4010
#define OBJ_VIS_LOFTER          0x4011
#define OBJ_DOESNT_CAST         0x4012
#define OBJ_MATTE               0x4013
#define OBJ_FAST                0x4014
#define OBJ_PROCEDURAL          0x4015
#define OBJ_FROZEN              0x4016
#define OBJ_DONT_RCVSHADOW      0x4017
#define N_TRI_OBJECT            0x4100
#define POINT_ARRAY             0x4110
#define POINT_FLAG_ARRAY        0x4111
#define FACE_ARRAY              0x4120
#define MSH_MAT_GROUP           0x4130
#define OLD_MAT_GROUP           0x4131
#define TEX_VERTS               0x4140
#define SMOOTH_GROUP            0x4150
#define MESH_MATRIX             0x4160
#define MESH_COLOR              0x4165
#define MESH_TEXTURE_INFO       0x4170
#define PROC_NAME               0x4181
#define PROC_DATA               0x4182
#define MSH_BOXMAP              0x4190
#define N_D_L_OLD               0x4400
#define N_CAM_OLD               0x4500
#define N_DIRECT_LIGHT          0x4600
#define DL_SPOTLIGHT            0x4610
#define DL_OFF                  0x4620
#define DL_ATTENUATE            0x4625
#define DL_RAYSHAD              0x4627
#define DL_SHADOWED             0x4630
#define DL_LOCAL_SHADOW         0x4640
#define DL_LOCAL_SHADOW2        0x4641
#define DL_SEE_CONE             0x4650
#define DL_SPOT_RECTANGULAR     0x4651
#define DL_SPOT_OVERSHOOT       0x4652
#define DL_SPOT_PROJECTOR       0x4653
#define DL_EXCLUDE              0x4654
#define DL_RANGE                0x4655
#define DL_SPOT_ROLL            0x4656
#define DL_SPOT_ASPECT          0x4657
#define DL_RAY_BIAS             0x4658
#define DL_INNER_RANGE          0x4659
#define DL_OUTER_RANGE          0x465a
#define DL_MULTIPLIER           0x465b
#define N_AMBIENT_LIGHT         0x4680
#define N_CAMERA                0x4700
#define CAM_SEE_CONE            0x4710
#define CAM_RANGES              0x4720
#define HIERARCHY               0x4f00
#define PARENT_OBJECT           0x4f10
#define PIVOT_OBJECT            0x4f20
#define PIVOT_LIMITS            0x4f30
#define PIVOT_ORDER             0x4f40
#define XLATE_RANGE             0x4f50

#define KFDATA                  0xb000      //      keyframer
#define AMBIENT_NODE_TAG        0xb001
#define OBJECT_NODE_TAG         0xb002
#define CAMERA_NODE_TAG         0xb003
#define TARGET_NODE_TAG         0xb004
#define LIGHT_NODE_TAG          0xb005
#define L_TARGET_NODE_TAG       0xb006
#define SPOTLIGHT_NODE_TAG      0xb007
#define KFSEG                   0xb008
#define KFCURTIME               0xb009
#define KFHDR                   0xb00a
#define NODE_HDR                0xb010
#define INSTANCE_NAME           0xb011
#define PRESCALE                0xb012
#define PIVOT                   0xb013
#define BOUNDBOX                0xb014
#define MORPH_SMOOTH            0xb015
#define POS_TRACK_TAG           0xb020
#define ROT_TRACK_TAG           0xb021
#define SCL_TRACK_TAG           0xb022
#define FOV_TRACK_TAG           0xb023
#define ROLL_TRACK_TAG          0xb024
#define COL_TRACK_TAG           0xb025
#define MORPH_TRACK_TAG         0xb026
#define HOT_TRACK_TAG           0xb027
#define FALL_TRACK_TAG          0xb028
#define HIDE_TRACK_TAG          0xb029
#define NODE_ID                 0xb030

#define MAT_NAME                0xa000      //      materiaalit
#define MAT_AMBIENT             0xa010
#define MAT_DIFFUSE             0xa020
#define MAT_SPECULAR            0xa030
#define MAT_SHININESS           0xa040
#define MAT_SHIN2PCT            0xa041
#define MAT_SHIN3PCT            0xa042
#define MAT_TRANSPARENCY        0xa050
#define MAT_XPFALL              0xa052
#define MAT_REFBLUR             0xa053
#define MAT_SELF_ILLUM          0xa080
#define MAT_TWO_SIDE            0xa081
#define MAT_DECAL               0xa082
#define MAT_ADDITIVE            0xa083
#define MAT_SELF_ILPCT          0xa084
#define MAT_WIRE                0xa085
#define MAT_SUPERSMP            0xa086
#define MAT_WIRESIZE            0xa087
#define MAT_FACEMAP             0xa088
#define MAT_XPFALLIN            0xa08a
#define MAT_PHONGSOFT           0xa08c
#define MAT_WIREABS             0xa08e
#define MAT_SHADING             0xa100
#define MAT_TEXMAP              0xa200
#define MAT_SPECMAP             0xa204
#define MAT_OPACMAP             0xa210
#define MAT_REFLMAP             0xa220
#define MAT_BUMPMAP             0xa230
#define MAT_USE_XPFALL          0xa240
#define MAT_USE_REFBLUR         0xa250
#define MAT_BUMP_PERCENT        0xa252
#define MAT_MAPNAME             0xa300
#define MAT_ACUBIC              0xa310
#define MAT_SXP_TEXT_DATA       0xa320
#define MAT_SXP_TEXT2_DATA      0xa321
#define MAT_SXP_OPAC_DATA       0xa322
#define MAT_SXP_BUMP_DATA       0xa324
#define MAT_SXP_SPEC_DATA       0xa325
#define MAT_SXP_SHIN_DATA       0xa326
#define MAT_SXP_SELFI_DATA      0xa328
#define MAT_SXP_TEXT_MASKDATA   0xa32a
#define MAT_SXP_TEXT2_MASKDATA  0xa32c
#define MAT_SXP_OPAC_MASKDATA   0xa32e
#define MAT_SXP_BUMP_MASKDATA   0xa330
#define MAT_SXP_SPEC_MASKDATA   0xa332
#define MAT_SXP_SHIN_MASKDATA   0xa334
#define MAT_SXP_SELFI_MASKDATA  0xa336
#define MAT_SXP_REFL_MASKDATA   0xa338
#define MAT_TEX2MAP             0xa33a
#define MAT_SHINMAP             0xa33c
#define MAT_SELFIMAP            0xa33d
#define MAT_TEXMASK             0xa33e
#define MAT_TEX2MASK            0xa340
#define MAT_OPACMASK            0xa342
#define MAT_BUMPMASK            0xa344
#define MAT_SHINMASK            0xa346
#define MAT_SPECMASK            0xa348
#define MAT_SELFIMASK           0xa34a
#define MAT_REFLMASK            0xa34c
#define MAT_MAP_TILINGOLD       0xa350
#define MAT_MAP_TILING          0xa351
#define MAT_MAP_TEXBLUR_OLD     0xa352
#define MAT_MAP_TEXBLUR         0xa353
#define MAT_MAP_USCALE          0xa354
#define MAT_MAP_VSCALE          0xa356
#define MAT_MAP_UOFFSET         0xa358
#define MAT_MAP_VOFFSET         0xa35a
#define MAT_MAP_ANG             0xa35c
#define MAT_MAP_COL1            0xa360
#define MAT_MAP_COL2            0xa362
#define MAT_MAP_RCOL            0xa364
#define MAT_MAP_GCOL            0xa366
#define MAT_MAP_BCOL            0xa368
#define MAT_ENTRY               0xafff

#endif

