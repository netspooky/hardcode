/*
 * This file is part of "fingubni samselpla selsa'a" (FSS)
 * Copyright (C) 2017 PoroCYon
 *
 * FSS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3,
 * or at your option, any later version, as
 * published by the Free Software Foundation.
 *
 * FSS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FSS. If not, see <https://www.gnu.org/licenses/>.
 */
/*
 * lo ti datnyvei cu pagbu la fingubni samselpla selsa'a goi fysysy
 * noi proga gi'e se fukyzifpo'e la'oi PoroCYon de'i li 2017
 *
 * .i fysysy fingubni .ija'ebo do .e'a ti fairgau gi'e galfi
 * ti ja'i la'o gy. GNU General Public License .gy poi se versiio
 * li su'o 3 gi'e se finti la'o gy. Free Software Foundation .gy
 *
 * .i fysysy se fairgau tezu'e lo nu plixau SECAU LO SI'O SIDJU kuku'i
 * .i .e'u ko catlu gypyly tezu'e lo nu zvafa'i lo tcila
 *
 * .i .a'o do te bevri lo fukpi be gypyly sepa'u fysysy .i va'onai
 * la'edi'u ko catlu zoi .url. https://www.gnu.org/licenses/ .url.
 */

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <assert.h>

#define STB_IMAGE_STATIC
#define STB_IMAGE_IMPLEMENTATION
#define STBI_NO_LINEAR
#define STBI_NO_HDR
#include "stb/stb_image.h"

// xilbert kurvi
static void carna(ssize_t n, ssize_t *x, ssize_t *y, ssize_t rx, ssize_t ry) {
    if (!ry) {
        if (rx) {
            *x = -*x + n - 1;
            *y = -*x + n - 1;
        }

        ssize_t t  = *x;
        *x = *y;
        *y = t;
    }
}
static void xilbert_binxo(ssize_t n, ssize_t d, ssize_t *x, ssize_t *y) {
    *x = *y = 0;

    for (ssize_t s = 1; s < n; s <<= 1) {
        ssize_t rx = (d >> 1) & 1,
                ry = (d ^ rx) & 1;

        carna(s, x, y, rx, ry);

        *x += s * rx;
        *y += s * ry;
        d >>= 2;
    }
}

//static float nilvai[3] = { 0.2126f, 0.7125f, 0.0722f };
static bool tamsmirelskagahi(uint32_t xcbk) {
    // sruma me tu'a la'o gy. little-endian .gy
    uint8_t kln = (xcbk & 0xFF000000) >> 24/*,
            bln = (xcbk & 0x00FF0000) >> 16,
            crn = (xcbk & 0x0000FF00) >>  8,
            xnr =  xcbk & 0x000000FF       */;

    return kln & 0x80; // tolpo'u raunzu
}

static void demriha(uint32_t* selruhe, uint8_t* teryruhe, size_t nilgahu, size_t nilganra, bool xilbert, bool terfrica) {
    bool prulahi = false;
    for (size_t i = 0; i < nilgahu * nilganra; ++i) {
        size_t ii; // lo ti datnyvau cu terpa
        if (xilbert) {
            ssize_t x, y;
            xilbert_binxo((ssize_t)nilgahu, (ssize_t)i, &x, &y);
            ii = (size_t)y * nilganra + (size_t)x;
        }
        else {
            ii = i;
        }

        bool skari = tamsmirelskagahi(selruhe[ii]);
        if (terfrica) {
            bool _ = skari;
            skari ^= prulahi;
            prulahi = _;
        }

        teryruhe[(i & ~(size_t)7) >> 3] |= (uint8_t)((skari ? 1 : 0) << (i & 7));
    }
}

static void veirciha(uint8_t* dtn, size_t nilbra, const char* cmn) {
    if (access(cmn, F_OK) != -1) {
        assert(!unlink(cmn));
    }

    int dv = open(cmn, O_WRONLY|O_CREAT,0644);
    if (write(dv, dtn, nilbra) != (ssize_t)nilbra) {
        fprintf(stderr, "la'o gy. write .gy spofu\n");
    }
    close(dv);
}

int main(int argc, char* argv[]) {
    int ng, ngnr, skalai;
    stbi_uc* pxr = stbi_load("stalman.png", &ng, &ngnr, &skalai, 4);
    if (!pxr) {
        fprintf(stderr, "la'o gy. stbi_load .gy spofu\n");
        return 1;
    }

    size_t nilcla = (size_t)(ng * ngnr) >> 3;
    uint8_t* denmi = (uint8_t*)calloc(sizeof(uint8_t), nilcla);
    demriha((uint32_t*)pxr, denmi, (size_t)ng, (size_t)ngnr, false, false);
    veirciha(denmi, nilcla, "pixra.dtn");

    free(denmi);
    stbi_image_free(pxr);
}

