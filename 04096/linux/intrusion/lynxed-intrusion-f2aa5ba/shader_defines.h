#ifndef SHADER_DEFINES
#define SHADER_DEFINES

// This file contains some defines for better readability of the shader-code,
// while not wasting bytes for long global identifiers shader minifier cannot
// rename.

// Escape from beeing processed by preprocessor.
// Needed for the version-directives in the shaders
#define escaped(x) x

#define uf_cpu_data a
#define uf_overlay_texture b

#define in_position c
#define in_texcoord d

#define position e
#define texcoord f

#define out_color g

// To stringify the identifiers defined above. Two levels are needed, since
// the preprocessor doesn't expand macros when using the stringify-operator
#define _str(s) #s
#define uniform(identifier) _str(identifier)

#endif

