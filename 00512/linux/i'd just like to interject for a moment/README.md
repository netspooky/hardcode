# fingubni samselpla selsa'a

.i ti samselpla la'o gy. PoroCYon .gy lo pu'u zbasu la fingubni samselpla selsa'a
je pa pixra be la stalman kuku poi'a su'e 512 bivjetka'u ni cmalu

.i py fukyzifpo'e fi la'o gy. GPL version >=3 .gy

## ni'oni'o zbasu lo proga

.i la klang je la'o gy. nasm .gy je la'o gy. xz .gy je la monos cu
sarcu .isesaubo ko zukte zoi bac.
```sh
make
```
.bac

.i va'o lo nu spofu ku, ko zukte zoi bac.
```
make jisygau && make -j1
```
.bac

## ni'oni'o .aktigau lo proga

### ni'o va'o lonu pilno la alsa

.i sarcu fa la'o gy. alsa-utils .gy
.isesaubo ko zukte zoi bac.
```sh
bin/fss-alsa
```
.bac

### ni'o va'o lonu pilno la'o gy. OSS .gy

.i ko zukte zoi bac.
```sh
# lonu spofu ku cumki
sudo vmixctl rate /dev/dsp 16384 && sudo ossmix envy24.rate 16384
bin/fss-oss
```
.bac

#### ni'o va'o lonu pilno lo drata

.i ko zukte zoi bac.
```sh
bin/fss-stdout | sox -b 8 -c 1 -e unsigned-integer -r 16384 -t raw fss-mupli.ogg
```
.bac mu'a

