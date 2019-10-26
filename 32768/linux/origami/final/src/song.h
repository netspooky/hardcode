#ifndef __SONG_H__
#define __SONG_H__

#include "notes.h"

#include "stringsong.h"
#include "dingsong.h"
#include "drumsong.h"
#include "resosong.h"

unsigned char bassorder[] = {
    4, 4, 4, 4, // part 1
    4, 4, 4, 4,
    4, 4, 4, 4,
    4, 4, 4, 4,
    0, 1, 0, 1,
    0, 1, 2, 3,
    0, 1, 0, 1,
    0, 1, 2, 3,

    1, 5, 1, 5, // part 2
    1, 5, 1, 5,
    1, 5, 1, 5,
    1, 5, 1, 5,
    1, 5, 1, 5,
    1, 5, 1, 5,
    1, 5, 1, 5,
    1, 5, 1, 5,

    3, 3, 3, 3, // a#
    5, 5, 5, 5, // g#

    6, 6, 6, 6, // part 3
    6, 6, 6, 6,
    7, 7, 7, 7,
    7, 7, 7, 7,
    5, 5, 5, 5,
    5, 5, 5, 5,
    0, 0, 0, 0,
    0, 0, 0, 0,

    4, 4, 4, 4, // fak
    4, 4, 4, 4,
    4, 4, 4, 4,
    4, 4, 4, 4,
    4, 4, 4, 4,

    END
};

unsigned char basspatterns[] = {

    // 0
    A_1,
    OFF,
    A_1,
    OFF,
    A_2,
    OFF,
    A_1,
    OFF,

    A_1,
    OFF,
    A_2,
    OFF,
    G_2,
    OFF,
    G_1,
    OFF,

    A_1,
    OFF,
    A_1,
    OFF,
    A_2,
    OFF,
    A_1,
    OFF,

    A_1,
    OFF,
    A_2,
    OFF,
    G_2,
    OFF,
    G_1,
    OFF,

    // 1
    F_1,
    OFF,
    F_1,
    OFF,
    F_2,
    OFF,
    F_1,
    OFF,

    F_1,
    OFF,
    F_2,
    OFF,
    G_2,
    OFF,
    G_1,
    OFF,

    F_1,
    OFF,
    F_1,
    OFF,
    F_2,
    OFF,
    F_1,
    OFF,

    F_1,
    OFF,
    F_2,
    OFF,
    G_2,
    OFF,
    G_1,
    OFF,

    // 2
    Ds2,
    OFF,
    Ds2,
    OFF,
    Ds3,
    OFF,
    Ds2,
    OFF,

    Ds2,
    OFF,
    Ds3,
    OFF,
    Ds2,
    OFF,
    Ds2,
    OFF,

    Ds2,
    OFF,
    Ds2,
    OFF,
    Ds3,
    OFF,
    Ds2,
    OFF,

    Ds2,
    OFF,
    Ds3,
    OFF,
    Ds2,
    OFF,
    Ds2,
    OFF,

    // 3
    As1,
    OFF,
    As1,
    OFF,
    As2,
    OFF,
    As1,
    OFF,

    As1,
    OFF,
    As2,
    OFF,
    As2,
    OFF,
    As1,
    OFF,

    As1,
    OFF,
    As1,
    OFF,
    As2,
    OFF,
    As1,
    OFF,

    As1,
    OFF,
    As2,
    OFF,
    As2,
    OFF,
    As1,
    OFF,

    // 4
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,

    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,

    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,

    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,
    OFF,

    // 5
    Gs1,
    OFF,
    Gs1,
    OFF,
    Gs2,
    OFF,
    Gs1,
    OFF,

    Gs1,
    OFF,
    Gs2,
    OFF,
    Gs2,
    OFF,
    Gs1,
    OFF,

    Gs1,
    OFF,
    Gs1,
    OFF,
    Gs2,
    OFF,
    Gs1,
    OFF,

    Gs1,
    OFF,
    Gs2,
    OFF,
    Gs2,
    OFF,
    Gs1,
    OFF,

    // 6
    C_1,
    OFF,
    C_1,
    OFF,
    C_2,
    OFF,
    C_1,
    OFF,

    C_1,
    OFF,
    C_2,
    OFF,
    C_2,
    OFF,
    C_1,
    OFF,

    C_1,
    OFF,
    C_1,
    OFF,
    C_2,
    OFF,
    C_1,
    OFF,

    C_1,
    OFF,
    C_2,
    OFF,
    C_2,
    OFF,
    C_1,
    OFF,

    // 7

    F_1,
    OFF,
    F_1,
    OFF,
    F_2,
    OFF,
    F_1,
    OFF,

    F_1,
    OFF,
    F_2,
    OFF,
    F_2,
    OFF,
    F_1,
    OFF,

    F_1,
    OFF,
    F_1,
    OFF,
    F_2,
    OFF,
    F_1,
    OFF,

    F_1,
    OFF,
    F_2,
    OFF,
    F_2,
    OFF,
    F_1,
    OFF,

};

#endif
