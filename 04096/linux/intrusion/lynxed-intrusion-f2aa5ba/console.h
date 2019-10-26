#ifndef CONSOLE_H
#define CONSOLE_H

#include "defines.h"
#include "clib.h"
#include "glyphs.h"

extern const char _some_null; // provided by linker-script

enum console_text_type
{
    CONSOLE_TEXT_TYPE_INPUT,
    CONSOLE_TEXT_TYPE_OUTPUT
};

static uint8_t console_buffer[OVERLAY_TEXTURE_WIDTH * OVERLAY_TEXTURE_HEIGHT];
static size_t console_current_x = 0;
static size_t console_current_y = 0;

static bool console_texture_needs_upload = false;

static const char* console_input_position = &_some_null;
static uint32_t console_next_input_char_time = 0;

static regparm bool console_is_part_of_glyph(uint32_t glyph, size_t x, size_t y)
{
    return (0x1 << (y * glyph_width + x)) & glyph;
}

static regparm void console_set_pixel(size_t x, size_t y, uint8_t intensity)
{
    console_buffer[y * OVERLAY_TEXTURE_WIDTH + x] = 0xff;
}

static regparm void console_render_character(char c, size_t x, size_t y)
{
    const uint32_t glyph = glyphs[c - glyphs_ascii_begin];

    for (size_t cy = 0; cy < glyph_height; cy++)
    {
        for (size_t cx = 0; cx < glyph_width; cx++)
        {
            if (console_is_part_of_glyph(glyph, cx, cy))
            {
                console_set_pixel(cx + x, cy + y, 0xff);
            }
        }
    }
}

static regparm void console_add_character(char c)
{
    if (c == '\n')
    {
        console_current_x = 0;

        if (console_current_y + glyph_height + GLYPH_SPACING >= CONSOLE_HEIGHT)
        {
            size_t line_size = OVERLAY_TEXTURE_WIDTH * (glyph_height + GLYPH_SPACING);
            clib_inaccurate_memcpy(console_buffer, console_buffer + line_size, sizeof(console_buffer) - line_size);
            clib_inaccurate_memset(console_buffer + sizeof(console_buffer) - line_size, 0, line_size);
        }
        else
        {
            console_current_y += glyph_height + GLYPH_SPACING;
        }
    }
    else
    {
        console_render_character(c, console_current_x, console_current_y);
        console_current_x += glyph_width + GLYPH_SPACING;
    }
}

// Returns true, if the texture was changed (and has to be resend to GPU), false
// if not.
static regparm bool console_update(uint32_t time)
{
    if (time == 0)
    {
        console_next_input_char_time = time;
    }

    if (*console_input_position && time >= console_next_input_char_time)
    {
        console_add_character(*console_input_position++);

        console_next_input_char_time += CONSOLE_INPUT_DELAY;
        console_texture_needs_upload = true;
    }

    bool ret = console_texture_needs_upload;
    console_texture_needs_upload = false;
    return ret;
}

static regparm void console_print_input(const char* text)
{
    console_input_position = text;
    console_next_input_char_time = 0;
}

static regparm void console_print_output(const char* text)
{
    for (const char* c = text; *c != '\0'; c++)
    {
        console_add_character(*c);
    }

    console_texture_needs_upload = true;
}

#endif

