/*
 *
 *      VecSys Keyframer
 *
 *      - keyframe-aminaatio
 *
 */

#ifndef VEC_KF_H
#define VEC_KF_H

#include "vec_cam.h"
#include "vec_type.h"

typedef struct VEC_POS_KEY
{
    int32   fnum;
    vec_fp  pos[3],
            tension,
            continuity,
            bias;
} vec_poskey;

typedef struct VEC_ROLL_KEY
{
    int32   fnum;
    vec_fp  angle,
            tension,
            continuity,
            bias;
} vec_rollkey;

typedef struct VEC_ROT_KEY
{
    int32   fnum;
    vec_fp  ax,ay,az,
            tension,
            continuity,
            bias,
            matr[4][4];
} vec_rotkey;

typedef struct VEC_CAM_KF
{
    int32       start,  end,    //      ensimm. ja viim. frame

                cpkeys,         //      paikan keyframejen m„„r„
                crkeys,         //      kulman keyframejen m„„r„
                tpkeys,         //      kohteen keyframejen m„„r„

                cpflags,
                crflags,
                tpflags;

    vec_rollkey *roll;
    vec_poskey  *cpos,
                *tpos;
} vec_ckf;

typedef struct VEC_OBJ_KF
{
    int32       rkeys,          //      rotaatiokeyframejen m„„r„
                pkeys,          //      paikan keyframejen m„„r„

                rflags,
                pflags;

    vec_rotkey  *rot;
    vec_poskey  *pos;
} vec_okf;

extern int      vec_get_frame(vec_cam *cam,vec_fp per);
extern int      vec_get_camframe(vec_cam *cam,vec_fp fnum);
extern int      vec_get_objframe(vec_nod *node,vec_fp fnum);
extern void     vec_free_kf(vec_cam *cam);

#endif

