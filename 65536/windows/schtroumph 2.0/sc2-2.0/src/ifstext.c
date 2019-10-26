/****************************************************************/
/* ifsspell.c - generates ifs matrix entry readable by fractint */
/****************************************************************/
/* Written by Wesley B. Loewer, Copyright 1994.                 */
/****************************************************************/

#define MAX_AFFINES_PER_LETTER  5
#define SCALING_FACTOR  10
#define NO_MATCH                 -1

typedef struct Point
{
        float x,y;
} Point;

#include "ifstext.h"
#include "math.h"

#define PI 3.141592654

float spacing=2;
float total_area, total_width, total_height=10;

typedef struct Affine
{
        float width, height;
        float rot_angle, skew_angle;
        float horiz_shift, vert_shift;
} Affine;

typedef struct Letter
{
        char letter;
        int affine_num;
        float width;
        Affine affines[MAX_AFFINES_PER_LETTER];
        float area;
} Letter;

Letter letters[] =
{
        {'A', 3, 8, {{10, 2, 78.7, 11.3, 2, 0},
                            {10, 2, -78.7, -11.3, 4, 10},
                            {2, 1.5, 0, 0, 3, 4.5},
                    }
        },

        {'B', 5, 6, {{10, 2, 90, 0, 2, 0},
                            {3.2, 2, -51.3, -38.7, 2, 10},
                            {3.2, 2, -128.7, 38.7, 4, 7.5},
                            {3.2, 2, -51.3, -38.7, 2, 5},
                            {3.2, 2, -128.7, 38.7, 4, 2.5},
                    }
        },

        {'C', 3, 6, {{6, 2, 0, 0, 0, 8},
                            {6, 2, 180, 0, 6, 2},
                            {6, 2, 90, 0, 2, 2},
                    }
        },

        {'D', 4, 6, {{10, 2, 90, 0, 2, 0},
                            {4, 2, 0, 45, 2, 8},
                            {6, 2, -90, 0, 4, 8},
                            {4, 2, 0, -45, 0, 0},
                    }
        },     

        {'E', 4, 6, {{6, 2, 0, 0, 0, 8},
                            {6, 2, 0, 0, 0, 0},
                            {4, 2, 0, 0, 2, 4},
                            {6, 2, 90, 0, 2, 2},
                    }
        },

        {'F', 3, 6, {{6, 2, 0, 0, 0, 8},
                            {4, 2, 0, 0, 2, 4},
                            {8, 2, 90, 0, 2, 0},
                    }
        },

        {'G', 5, 7, {{7, 2, 0, 0, 0, 8},
                            {6, 2, 90, 0, 2, 2},
                            {5, 2, 0, 0, 0, 0},
                            {3, 2, 90, 0, 7, 0},
                            {4, 2, 0, 0, 3, 3},
                    }
        },

        {'H', 5, 6, {{4, 2, 90, 0, 2, 0},
                            {4, 2, 90, 0, 2, 6},
                            {6, 2, 0, 0, 0, 4},
                            {4, 2, -90, 0, 4, 10},
                            {4, 2, -90, 0, 4, 4},
                    }
        },

        {'I', 1, 2, {{10, 2, 90, 0, 2, 0},
                    }
        },

        {'J', 3, 6, {{8, 2, -90, 0, 4, 10},
                            {4, 2, 180, 0, 6, 2},
                            {4, 2, 90, 0, 2, 0},
                    }
        },

        {'K', 3, 6, {{10, 2, 90, 0, 2, 0},
                            {5.4, 2, 68.2, 21.8, 4, 5},
                            {5.4, 2, 111.8, -21.8, 6, 0},
                    }
        },

        {'L', 2, 6, {{8, 2, 90, 0, 2, 2},
                            {6, 2, 0, 0, 0, 0},
                    }
        },

        {'M', 4, 10, {{10, 2, 90, 0, 2, 0},
                             {10.2, 2, -68.2, -21.8, 0, 10},
                             {10.2, 2, 68.2, 21.8, 6, 0},
                             {10, 2, 90, 0, 10, 0},
                     }
        },

        {'N', 3, 8, {{10, 2, 90, 0, 2, 0},
                            {10.2, 2, -68.2, -21.8, 1, 10},
                            {10, 2, 90, 0, 8, 0},
                    }
        },

        {'O', 4, 6, {{6, 2, 0, 0, 0, 8},
                            {6, 2, 180, 0, 6, 2},
                            {6, 2, 90, 0, 2, 2},
                            {6, 2, -90, 0, 4, 8},
                    }
        },

        {'P', 4, 6, {{8.5, 2, 90, 0, 2, 0},
                            {4.5, 1.5, 0, 0, 0, 8.5},
                            {3.5, 1.5, -90, 0, 4.5, 10},
                            {4, 1.5, 0, 0, 2, 5},
                    }
        },

        {'Q', 5, 7.5, {{6, 2, 0, 0, 0, 8},
                              {6, 2, 180, 0, 6, 2},
                              {6, 2, 90, 0, 2, 2},
                              {6, 2, -90, 0, 4, 8},
                              {4, 2, -45, 0, 2.5, 1.5},
                      }
        },

        {'R', 5, 6, {{8.5, 2, 90, 0, 2, 0},
                            {4.5, 1.5, 0, 0, 0, 8.5},
                            {3.5, 1.5, -90, 0, 4.5, 10},
                            {4, 1.5, 0, 0, 2, 5},
                            {5.47, 2, -66, -24, 2, 5},
                    }
        },

        {'S', 5, 6, {{6, 2, 0, 0, 0, 0},
                            {4, 2, 90, 0, 6, 2},
                            {4, 2 ,180, 0, 4, 6},
                            {4, 2, 90, 0, 2, 6},
                            {4, 2, 0, 0, 2, 8},
                    }
        },

        {'T', 2, 6, {{8, 2, 90, 0, 4, 0},
                            {6, 2, 0, 0, 0, 8},
                    }
        },

        {'U', 3, 6, {{8, 2, -90, 0, 4, 10},
                            {6, 2, 180, 0, 6, 2},
                            {8, 2, 90, 0, 2, 2},
                    }
        },

        {'V', 2, 8, {{10.4, 2, -73.3, -16.7, 0, 10},
                            {10.4, 2, 73.3, 16.7, 5, 0},
                    }
        },

        {'W', 4, 12, {{10.2, 2, -78.7, -11.3, 0, 10},
                             {6.7, 2, 63.4, 26.6, 4, 0},
                             {6.7, 2, -63.4, -26.6, 5, 6},
                             {10.2, 2, 78.7, 11.3, 10, 0},
                     }
        },

        {'X', 2, 7, {{11.2, 2, 63.4, 26.6, 2, 0},
                            {11.2, 2, -63.4, -26.6, 0, 10},
                    }
        },

        {'Y', 3, 8, {{5, 2, 90, 0, 5, 0},
                            {5.83, 2, 59, 31, 5, 5},
                            {5.83, 2, -59, -31, 0, 10},
                    }
        },

        {'Z', 3, 6, {{6, 2, 0, 0, 0, 0},
                            {6, 2, 0, 0, 0, 8},
                            {7.2, 2, 56.3, 33.7, 2, 2},
                    }
        },

        {'-', 1, 6, {{6, 2, 0, 0, 0, 4},
                    }
        },

        {'+', 2, 6, {{6, 2, 0, 0, 0, 4},
                            {6, 2, 90, 0, 4, 2},
                    }
        },

        {'=', 2, 6, {{6, 2, 0, 0, 0, 6},
                            {6, 2, 0, 0, 0, 2},
                    }
        },

        {'/', 1, 7, {{11.2, 2, 63.4, 26.6, 2, 0},
                    }
        },

        {'\\', 1, 7, {{11.2, 2, -63.4, -26.6, 0, 10},
                     }
        },

        {'!', 2, 2, {{6, 2, 90, 0, 2, 4},
                            {2, 2, 0, 0, 0, 0},
                    }
        },

        {'?', 5, 6, {{2, 2, 90, 0, 2, 6},
                            {4, 2, 0, 0, 0, 8},
                            {4, 2, -90, 0, 4, 10},
                            {3.6, 2, -123.7, 33.7, 4, 6},
                            {2, 2, 0, 0, 2, 0},
                    }
        },

        {'_', 0, 4}, /* to be used as a space character */

        {'\0' /* terminating character */
        }
};




void InitLetters(void)
{
        int l, a;

        l=0;
        while (letters[l].letter != '\0') {
                letters[l].area = 0;
                for (a=0; a<letters[l].affine_num; a++) {
                        letters[l].affines[a].width /= 10;
                        letters[l].affines[a].height /= 10;
                        letters[l].affines[a].horiz_shift /= 10;
                        letters[l].affines[a].vert_shift /= 10;
                        letters[l].area += letters[l].affines[a].width * letters[l].affines[a].height;
                }
                letters[l].width /= 10;
                l++;
        }
        spacing /= 10;
        total_height /= 10;
}

static int GetLetter(int c)
{
        int l=0;

        while (letters[l].letter != (char)c && letters[l].letter != '\0') {
                l++;
        }
        return letters[l].letter != '\0' ? l : NO_MATCH;
}

static void GetTotals(char * string)
{
        int c;
        int i, l;
        int total_affine=0;

        total_area = 0;
        total_width = 0;
        i = 0;
        while ((c=string[i]) != '\0') {
                l = GetLetter(c);
                if (l != NO_MATCH) {
                        total_area += letters[l].area;
                        total_width += letters[l].width + spacing;

                        total_affine += letters[l].affine_num;
                }
                i++;
        }
        if (total_affine>=IFS_MAX) {
                //printf("nouveau ifsmax:%d\n", total_affine);
                //exit(4);
        }
}

void StringToIFS(IFS ifs, char * string)
{
        int c;
        int i, l, a, p;
        float pos, xscale, yscale, tan_phi, sin_theta, cos_theta, xshift, yshift, prob;
        Affine af;

        GetTotals(string);
        if (total_area == 0 || total_width == 0) {
                return;
        }

        pos = spacing/2;
        i = 0;
                p = 0;
        while ((c=string[i]) !=0) {
                l = GetLetter(c);
                if (l != NO_MATCH) {
                        for (a=0; a<letters[l].affine_num; a++) {
                                af = letters[l].affines[a]; /* just to make life easier */

                                xscale = af.width / total_width;
                                yscale = af.height / total_height;
                                        

                                tan_phi = -tan(PI/180*af.skew_angle);
                                sin_theta = sin(PI/180*af.rot_angle);
                                cos_theta = cos(PI/180*af.rot_angle);
                                prob = af.width * af.height / total_area;
                                xshift = af.horiz_shift+pos;
                                yshift = af.vert_shift;
                                

                                /* rotation_matrix * skew_matrix * scale_matrix * [x,y] + trans_matrix */
                                ifs[p][0] = xscale * cos_theta;
                                ifs[p][1] = yscale * (cos_theta*tan_phi - sin_theta);
                                ifs[p][2] = xscale * sin_theta;
                                ifs[p][3] = yscale * (sin_theta*tan_phi + cos_theta);
                                ifs[p][4] = xshift;
                                ifs[p][5] = yshift;
                                ifs[p][6] = prob;
                                p++;
                        }
                        pos += letters[l].width + spacing;
                }
                i++;
        }
}
