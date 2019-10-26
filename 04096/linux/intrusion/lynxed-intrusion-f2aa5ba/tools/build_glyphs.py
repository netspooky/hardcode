#!/usr/bin/env python

'''
This script takes an image file (anything PIL can read) and reads chunks of
4 * 8 pixels from it, treating these as rasterized letters.
It expects the image to cover the ASCII-characters from 32 till 126.
Then, each letter it finds in the source, that is used in a string included
in _(), is encoded as bitmap in an int, and all of them are written
in form of an array to a C-headerfile.'''

import sys
import re
from sets import Set
from mako.template import Template
from PIL import Image

SCALE_X = 4
SCALE_Y = 8
GLYPH_CTYPE = 'uint32_t'  # sizeof() has to match SCALE_X * SCALE_Y / 8
GLYPH_CTYPE_LENGTH = 4  # sizeof(uint32_t)
START_ASCII_CODE = 32
END_ASCII_CODE = 126

OUTPUT_TEMPLATE = '''
#ifndef ${guard}
#define ${guard}

typedef ${glyph_ctype} glyph_t;

static const size_t glyphs_ascii_begin = ${glyphs_ascii_begin};
static const size_t glyphs_ascii_end = ${glyphs_ascii_end};
static const size_t glyph_width = ${glyph_width};
static const size_t glyph_height = ${glyph_height};

static const glyph_t glyphs[] = {
% for c, g in glyphs:
    ${g}, // ${c.replace('\\\\', 'backslash')}
% endfor
};

#endif
'''


def get_glyphs(filename):
    image = Image.open(filename).convert('L')
    for i in range(END_ASCII_CODE + 1 - START_ASCII_CODE):
        crop = image.crop(
            (i * SCALE_X, 0, (i + 1) * SCALE_X, SCALE_Y)).tobytes()
        yield chr(i + START_ASCII_CODE), crop


def encode_image(image):
    glyph = 0
    for i in xrange(SCALE_X * SCALE_Y):
        if image[i] != chr(0xff):
            glyph |= 0x1 << i
    return glyph


def get_used_letters(source_files):
    used_letters = Set()

    for filename in source_files:
        with open(filename) as file_:
            content = file_.read()

        in_identifier = False
        in_string = False
        skip_next = False
        for i in xrange(len(content)):
            if skip_next:
                skip_next = False
            elif not in_identifier and content[i] == '_' \
                    and len(content) >= i + 1 and content[i + 1] == '(':
                in_identifier = True
                skip_next = True
            elif in_identifier:
                if not in_string and content[i] == ')':
                    in_identifier = False
                elif in_string and content[i] == '\\':
                    skip_next = True
                elif content[i] == '"':
                    in_string = not in_string
                elif in_string:
                    used_letters.add(content[i])

    return used_letters


if __name__ == '__main__':
    if len(sys.argv) < 4:
        print 'usage: {} IMAGE_FILE SOURCE_FILE [SOURCE_FILE ...] OUTPUT_FILE' \
            .format(sys.argv[0])
        sys.exit(1)

    image_file = sys.argv[1]
    source_files = sys.argv[2:-1]
    output_file = sys.argv[-1]

    used_letters = get_used_letters(source_files)
    glyphs = {c: encode_image(i)
              if c in used_letters else 0x0
              for (c, i) in get_glyphs(image_file)}

    with open(output_file, 'w') as f:
        f.write(Template(OUTPUT_TEMPLATE).render(
            guard=re.sub('[^A-Z]', '_', output_file.upper()),
            glyph_ctype=GLYPH_CTYPE,
            glyphs_ascii_begin=START_ASCII_CODE,
            glyphs_ascii_end=END_ASCII_CODE,
            glyph_width=SCALE_X,
            glyph_height=SCALE_Y,
            glyphs=[(c, '0x{:0{}x}'.format(
                g, 2 * GLYPH_CTYPE_LENGTH))
                for (c, g) in sorted(glyphs.iteritems())]))
