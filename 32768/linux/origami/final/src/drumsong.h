#ifndef __DRUMSONG_H__
#define __DRUMSONG_H__

unsigned char drumorder[] = {
    0, 0, 0, 0, // part 1
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,

    1, 1, 1, 1, // part 2
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1, // ~15 sekkaa ekstraa vau
  
    2, 2, 2, 2, // part 3
    2, 2, 2, 2,
    2, 2, 2, 2,
    2, 2, 2, 2,

    3, 4 , 4, 4,
    4, 4, 4, 4,
    END
};

unsigned char drumpatterns[] = {
    // 0
    C_1, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    C_1, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,

    C_1, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, C_1, OFF, OFF,
    OFF, C_1, OFF, OFF,
    OFF, C_1, OFF, OFF,
    OFF, C_1, OFF, OFF,

    C_1, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    C_1, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,

    C_1, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, C_1, OFF, OFF,
    OFF, C_1, OFF, OFF,
    OFF, C_1, OFF, OFF,
    OFF, C_1, OFF, OFF,

    // 1

    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,

    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, C_1, C_1, OFF,
    OFF, C_1, OFF, OFF,
    C_1, C_1, C_1, OFF,
    OFF, C_1, OFF, C_1,

    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,

    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, C_1, C_1, OFF,
    OFF, C_1, OFF, C_1,
    C_1, C_1, C_1, OFF,
    OFF, C_1, OFF, OFF,

    // 2
    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,

    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    C_1, C_1, C_1, OFF,
    OFF, C_1, OFF, OFF,
    C_1, C_1, C_1, OFF,
    OFF, C_1, OFF, C_1,

    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,

    C_1, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, C_1, OFF,
    OFF, OFF, OFF, OFF,
    C_1, C_1, C_1, OFF,
    OFF, C_1, OFF, C_1,
    C_1, C_1, C_1, OFF,
    OFF, C_1, OFF, OFF,

    // 3
    C_1, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,

    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,

    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,

    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,

    // 4
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,

    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,

    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,

    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,
    OFF, OFF, OFF, OFF,

    OFF, OFF, OFF, OFF,


};

#endif
