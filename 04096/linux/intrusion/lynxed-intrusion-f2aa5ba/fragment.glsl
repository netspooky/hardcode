#include "defines.h"
#include "shader_defines.h"

escaped(#version 330)

in vec3 position;
in vec2 texcoord;

out vec3 out_color;

// CPU passes camera-position and -orientation and fractal parameters as an
// array of vectors. We've got some defines below, to make the access more
// readable.
uniform vec3 uf_cpu_data[];

#define cam_position uf_cpu_data[0]
#define cam_orientation mat3(uf_cpu_data[1], uf_cpu_data[2], uf_cpu_data[3])
#define box_scale uf_cpu_data[4].x
#define box_radius uf_cpu_data[4].y
#define sphere_radius uf_cpu_data[4].z

// This is never set in the CPU-code, to save some code. Some searching on the
// internet gave me the impression, that it is reliable initialized to the first
// unit implicitly, but, well, I didn't find a clear statement. So let's just
// cross fingers.
uniform sampler2D uf_overlay_texture;

void main()
{
    out_color.g = texture2D(uf_overlay_texture, texcoord).r;

    int steps = 0;
    if (int(mod(gl_FragCoord.y, 3.0)) == 0)
    {
        // the ray_direction is never used -- the same values is calculated
        // again, inline, a few lines below.
        // But both removing it here and using this variable, makes the binary
        // larger, therefore, we keep it this way.
        vec3 ray_direction = normalize(cam_orientation * (position + vec3(0.0, 0.0, -EYE_DISTANCE)));

        float dist = 0.0;

        while (dist < MAX_DISTANCE)
        {
            vec3 point = cam_position + normalize(cam_orientation
                    * (position + vec3(0.0, 0.0, -EYE_DISTANCE))) * dist;
            vec4 n = vec4(point, 1.0);

            int i = 0;
            while (i < MAX_ITERATIONS)
            {
                n.xyz = clamp(n.xyz, -box_radius, box_radius) * 2.0 - n.xyz;
                n *= max(sphere_radius * sphere_radius / dot(n.xyz, n.xyz), 1.0);
                n = box_scale * n + vec4(point, sign(box_scale * n.w));
                i++;
            }

            float next_step = length(n.xyz) / n.w;

            if (next_step < ACCURACY)
            {
                break;
            }

            dist += next_step;
            steps++;
        }

        out_color = OBJECT_GLOW / 85.0 * steps;
    }
}

