#include "defines.h"
#include "shader_defines.h"

escaped(#version 330)

in vec3 in_position;
in vec2 in_texcoord;

out vec3 position;
out vec2 texcoord;

void main()
{
    // Save all orthogonal projection matrix stuff. At the end, it would only
    // lead to this:
    gl_Position.x = in_position.x * RESOLUTION_Y / RESOLUTION_X;
    gl_Position.yz = in_position.yz;

    position = in_position;
    texcoord = in_texcoord;
}

