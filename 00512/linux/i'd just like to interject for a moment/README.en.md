# fingubni samselpla selsa'a

This is a 512 byte intro for the x86 Linux framebuffer.

## Compiling

    make

This requires `nasm`, a C compiler, `xz` and... `mono`.

## Running

### Using ALSA

    bin/fss-alsa

This requires `alsa-utils` to be installed.

### Using OSS

    sudo vmixctl rate /dev/dsp 16384 && sudo ossmix envy24.rate 16384
    bin/fss-oss

### Using something else

Example command:

    bin/fss-stdout | sox -b 8 -c 1 -e unsigned-integer -r 16384 -t raw fss-mupli.ogg

