#include <stdbool.h>
#include <SDL.h>
#include <GL/gl.h>
#include "defines.h"
#include "shader_defines.h"
#include "clib.h"
#include "scene_state.h"
#include "sdl_functions.h"
#include "gl_functions.h"
#include "vector.h"
#include "shader.h"
#include "console.h"
#include "sound.h"
#include "keypoint.h"
#include "shader_code.h"

static struct scene_state scene_state;

// set by mainloop() when initialization is done, be able to substract that time
// when calculating where in the scenes we are.
static uint32_t initialization_time;

static regparm void setup_window()
{
    sdl_functions.SDL_SetVideoMode(RESOLUTION_X, RESOLUTION_Y, 0,
            SDL_OPENGL | (FULLSCREEN ? SDL_FULLSCREEN : 0));
    sdl_functions.SDL_ShowCursor(SDL_DISABLE);
}

static regparm void cleanup()
{
    // SDL_Quit crashes since main() is removed, but we need this call to reset
    // the screen resolution when running fullscreen
    sdl_functions.SDL_QuitSubSystem(SDL_INIT_VIDEO);
}

static regparm void create_overlay_texture()
{
    gl_functions.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
}

static regparm void update_overlay_texture()
{
    gl_functions.glTexImage2D(GL_TEXTURE_2D, 0, GL_R8,
            OVERLAY_TEXTURE_WIDTH, OVERLAY_TEXTURE_HEIGHT,
            0, GL_RED, GL_UNSIGNED_BYTE, console_buffer);
}

static regparm bool exit_requested()
{
    SDL_Event event;
    sdl_functions.SDL_PollEvent(&event);

    if (event.type == SDL_QUIT)
    {
        return true;
    }

    if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE)
    {
        return true;
    }

    return false;
}

static regparm void update_text(uint32_t time)
{
    // Start one element ::before:: the first one, to have the first entry set.
    // This is fine, since we only access next, until it is incremented.
    static const struct keypoint_text* current = keypoint_texts - 1;
    const struct keypoint_text* next = current + 1;

    if (time > next->time)
    {
        current += 1;
        next += 1;

        if (current->type == CONSOLE_TEXT_TYPE_INPUT)
        {
            console_print_input(current->text);
        }
        else
        {
            console_print_output(current->text);
        }
    }
}

static regparm bool update_keypoints(uint32_t time)
{
    // Transition to next keypoint is handled here.

    static const struct keypoint* current = keypoint_points;
    const struct keypoint* next = current + 1;

    if (time > keypoint_points[array_size(keypoint_points) - 1].time)
    {
        return false;
    }

    if (time > next->time)
    {
        current += 1;
        next += 1;
    }

    const float time_factor =
        (float)(time - current->time) / (next->time - current->time);

    float* state = (float*)&scene_state;
    float* origin = (float*)&current->state;
    float* destination = (float*)&next->state;

    for (int i = 0; i < sizeof(struct scene_state) / sizeof(float); i++)
    {
        state[i] = origin[i] + (destination[i] - origin[i]) * time_factor;
    }

    return true;
}

static regparm void update_scene()
{
    static bool done = false;

    if (!done)
    {
        // +1 to prevent divisions by zero
        uint32_t time = sdl_functions.SDL_GetTicks() - initialization_time + 1;

        update_text(time);

        if (console_update(time))
        {
            update_overlay_texture();
        }

        done = !update_keypoints(time);

        if (done)
        {
            sound_stop();
        }
    }
}

static regparm void draw_fullscreen_quad(GLuint program)
{
    GLuint position_location = gl_functions.glGetAttribLocation(program, uniform(in_position));
    GLuint texcoord_location = gl_functions.glGetAttribLocation(program, uniform(in_texcoord));

    gl_functions.glBegin(GL_QUADS);
    gl_functions.glVertexAttrib2f(position_location, -WINDOW_RATIO, -1.0f);
    gl_functions.glVertexAttrib2f(texcoord_location, 1.0f, 1.0f);
    gl_functions.glVertexAttrib2f(position_location, WINDOW_RATIO, -1.0f);
    gl_functions.glVertexAttrib2f(texcoord_location, 1.0f, 0.0f);
    gl_functions.glVertexAttrib2f(position_location, WINDOW_RATIO, 1.0f);
    gl_functions.glVertexAttrib2f(texcoord_location, 0.0f, 0.0f);
    gl_functions.glVertexAttrib2f(position_location, -WINDOW_RATIO, 1.0f);
    gl_functions.glVertexAttrib2f(texcoord_location, 0.0f, 1.0f);
    gl_functions.glEnd();
}

static regparm void output_info()
{
#ifdef OUTPUT_INFO
    static uint32_t time = 0;
    static uint32_t last_frame_time = 0;
    static uint32_t last_print_time = 0;

    time = sdl_functions.SDL_GetTicks();

    // Just print once per second, to avoid slowing down the execution too much
    if (time - last_print_time >= 1000)
    {
        uint32_t fps = 1000 / (time - last_frame_time);

        fprintf(stderr, "\033[0GFPS: %i, Time: %f\033[0K", fps, time / 1000.0);

        last_print_time = time;
    }

    last_frame_time = time;
#endif
}

static regparm void mainloop()
{
    GLuint program = shader_compile_program(vertex_glsl, fragment_glsl);

    initialization_time = sdl_functions.SDL_GetTicks();
    while (!exit_requested())
    {
        output_info();
        update_scene();

        // We pass all scene-data with a single call to the shader, to save some
        // bytes. This works, since it contains only floats.
        shader_uniform_vector3(program, uniform(uf_cpu_data),
                (float*)&scene_state, sizeof(scene_state) / sizeof(vector3));

        draw_fullscreen_quad(program);
        gl_functions.glUseProgram(program);
        sdl_functions.SDL_GL_SwapBuffers();
    }
}

// Save overhead from crt1.o, get control from entry point on
void _start()
{
    sdl_functions_initialize();
    setup_window();
    gl_functions_initialize();
    sound_initialize();

    create_overlay_texture();

    sound_play();
    mainloop();

    cleanup();

    clib_exit(0);
}

