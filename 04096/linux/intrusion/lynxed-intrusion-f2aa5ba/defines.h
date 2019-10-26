#ifndef DEFINES_H
#define DEFINES_H

// Some global compile-time options.
// As preprocessor-defines, since some of them are used in shader-code

#define RESOLUTION_X 1280
#define RESOLUTION_Y 720
#define FULLSCREEN true
#define WINDOW_RATIO ((float)RESOLUTION_X / RESOLUTION_Y)

// Hardcoded in 4klang, don't change
#define SOUND_CHANNELS 2

// We use OpenGL to implicitly resize the text, therefore this defines the
// text-scale. This is NOT relative to the window-size, since the size of the
// letters isn't, but should have the same ratio
#define OVERLAY_TEXTURE_WIDTH 512
#define OVERLAY_TEXTURE_HEIGHT ((int)(OVERLAY_TEXTURE_WIDTH / WINDOW_RATIO))

#define GLYPH_SPACING 3
#define CONSOLE_HEIGHT (OVERLAY_TEXTURE_HEIGHT / 2)
#define CONSOLE_INPUT_DELAY 128

#define EYE_DISTANCE 2.0
#define MAX_DISTANCE 8.0
#define ACCURACY 0.0005
#define OBJECT_GLOW vec3(0.36, 0.36, 0.24)

#define MAX_ITERATIONS 12

// Noop :o)
// While we don't want this to do anything in the code, build_glyphs.py uses it
// when parsing the source, to see that a string is going to be displayed and
// the glyphs it uses have to be included
#define _(x) x

#endif

