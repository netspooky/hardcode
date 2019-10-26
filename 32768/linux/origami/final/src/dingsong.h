#ifndef __DINGSONG_H__
#define __DINGSONG_H__

// A A F F A A B B C# C# G# G# Gsus Gsus G G 

unsigned char dingorder[] = {
  2, 2, 2, 2,// part 1
   2, 2, 2, 2,

  2, 2, 2, 2, // part 2
  0, 1, 0, 1, 2, 2,

    2, 2, 2, 2, // part 3
    2, 2, 2, 3,

    2, 2, 2, 2, // sailöns
    2, 2, 2, 2,

    END
};

unsigned char dingpatterns[] = {

    // 0

    A_4, OFF, OFF,
    A_4, OFF, OFF,
    OFF, C_5, OFF,
    OFF, C_5, OFF,
    OFF, OFF, F_5,
    OFF, OFF, F_5,
    OFF, A_5, OFF,
    OFF, A_5, OFF,

    Gs5, OFF, OFF,
    Gs5, OFF, OFF,
    OFF, G_5, OFF,
    OFF, G_5, OFF,
    OFF, OFF, Ds5,
    OFF, OFF, Ds5,
    As5, OFF, OFF,
    As5, OFF, OFF,

    OFF, A_5, OFF,
    OFF, A_5, OFF,
    OFF, OFF, F_5,
    OFF, OFF, F_5,
    C_5, OFF, OFF,
    C_5, OFF, OFF,
    OFF, C_6, OFF,
    OFF, C_6, OFF,

    OFF, OFF, As5,
    OFF, OFF, As5,
    Gs5, OFF, OFF,
    Gs5, OFF, OFF,
    OFF, Ds5, OFF,
    OFF, Ds5, OFF,
    OFF, OFF, F_5,
    OFF, OFF, F_5,

    // 1

    G_5, OFF, OFF,
    G_5, OFF, OFF,
    OFF, A_5, OFF,
    OFF, A_5, OFF,
    OFF, OFF, F_5,
    OFF, OFF, F_5,
    C_5, OFF, OFF,
    C_5, OFF, OFF,

    OFF, Ds5, OFF,
    OFF, Ds5, OFF,
    OFF, OFF, G_5,
    OFF, OFF, G_5,
    Gs5, OFF, OFF,
    Gs5, OFF, OFF,
    OFF, C_6, OFF,
    OFF, C_6, OFF,

    OFF, OFF, As5,
    A_5, OFF, As5,
    A_5, F_5, OFF,
    A_5, F_5, OFF,
    OFF, F_5, OFF,
    OFF, F_5, OFF,
    OFF, F_5, OFF,
    OFF, OFF, OFF,

    Gs5, OFF, OFF,
    Gs5, G_5, OFF,
    OFF, G_5, Ds5,
    OFF, G_5, Ds5,
    OFF, G_5, Ds5,
    OFF, OFF, Ds5,
    OFF, OFF, Ds5,
    OFF, OFF, Ds5,

    // 2
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,

    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,

    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,

    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    OFF, OFF, OFF,

    // 3
    OFF, OFF, OFF,
    OFF, OFF, OFF,
    A_4, OFF, OFF,
    OFF, OFF, OFF,
    OFF, E_5, OFF,
    OFF, OFF, OFF,
    OFF, OFF, F_5,
    OFF, OFF, OFF,

    A_5, OFF, OFF,
    OFF, OFF, OFF,
    OFF, G_5, OFF,
    OFF, OFF, OFF,
    OFF, OFF, D_5,
    OFF, OFF, OFF,
    E_5, OFF, OFF,
    OFF, OFF, OFF,

    OFF, A_3, OFF,
    OFF, OFF, OFF,
    A_4, OFF, OFF,
    OFF, OFF, OFF,
    OFF, E_5, OFF,
    OFF, OFF, OFF,
    OFF, OFF, F_5,
    OFF, OFF, OFF,

    A_5, OFF, OFF,
    OFF, OFF, OFF,
    OFF, G_5, OFF,
    OFF, OFF, OFF,
    OFF, OFF, D_5,
    OFF, OFF, OFF,
    E_5, OFF, OFF,
    OFF, OFF, OFF,

 };

#endif
