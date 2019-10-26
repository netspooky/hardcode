cmake_minimum_required(VERSION 2.8)
set(CMAKE_CONFIGURATION_TYPES "Debug;Release")
project(junamatkailuintro)

enable_language(C)
enable_language(CXX)

cmake_policy(SET CMP0011 NEW)
if(${MSVC})
  cmake_policy(SET CMP0015 NEW)
endif()

include("defaults.cmake")

find_boost_program_options(TRUE)
find_png(TRUE)
find_sdl(TRUE)

check_raspberry_pi()
if(RASPBERRY_PI_FOUND)
  add_definitions(-DDNLOAD_VIDEOCORE -DDNLOAD_GLESV2)
  set(BCM_HOST_LIBRARY "bcm_host")
  set(EGL_LIBRARY "EGL")
  set(OPENGL_gl_LIBRARY "GLESv2")
else()
  find_opengl(TRUE)
  find_glew(TRUE)
endif()

add_definitions(-DUSE_LD)

output_flags("DEBUG" on)

include_directories("${PROJECT_SOURCE_DIR}/src")

set(SOURCE_FILES
  "src/bsd_rand.c"
  "src/bsd_rand.h"
  "src/common.hpp"
  "src/delay.hpp"
  "src/dnload.h"
  "src/env_gen.hpp"
  "src/filter.hpp"
  "src/font_data.hpp"
  "src/glsl_shader_source.cpp"
  "src/glsl_shader_source.hpp"
  "src/image_png.cpp"
  "src/image_png.hpp"
  "src/intro.cpp"
  "src/intro.hpp"
  "src/main.cpp"
  "src/MIDI2Freq.h"
  "src/model_auto.h"
  "src/model_lentsikka.h"
  "src/oscillator.hpp"
  "src/parameters.h"
  "src/poly_handler.hpp"
  "src/reverb.hpp"
  "src/SDLMain.h"
  "src/synth.hpp"
  "src/verbatim_array.hpp"
  "src/verbatim_bounding_volume.hpp"
  "src/verbatim_color.hpp"
  "src/verbatim_face.hpp"
  "src/verbatim_frame_buffer.hpp"
  "src/verbatim_height_map.hpp"
  "src/verbatim_image_rgb.hpp"
  "src/verbatim_mapping.hpp"
  "src/verbatim_matrix.hpp"
  "src/verbatim_mesh.hpp"
  "src/verbatim_object.hpp"
  "src/verbatim_program.hpp"
  "src/verbatim_realloc.hpp"
  "src/verbatim_shader.hpp"
  "src/verbatim_state.hpp"
  "src/verbatim_state_queue.hpp"
  "src/verbatim_synth.hpp"
  "src/verbatim_terrain.hpp"
  "src/verbatim_texture.hpp"
  "src/verbatim_threading.hpp"
  "src/verbatim_vector.hpp"
  "src/verbatim_vertex.hpp"
  "src/verbatim_vertex_buffer.hpp"
  "src/voice.hpp")

if (APPLE)
    list(APPEND SOURCE_FILES "src/SDLMain.mm")
    add_executable(junamatkailuintro MACOSX_BUNDLE ${SOURCE_FILES})
else (APPLE)
    add_executable(junamatkailuintro ${SOURCE_FILES})
endif (APPLE)

if(NOT ${MSVC})
  add_custom_command(
    OUTPUT dnload.h
    DEPENDS intro.cpp
    COMMAND sh refresh.sh
    WORKING_DIRECTORY ..)
endif()

if(RASPBERRY_PI_FOUND)
  target_link_libraries(junamatkailuintro ${BCM_HOST_LIBRARY})
  target_link_libraries(junamatkailuintro ${EGL_LIBRARY})
  target_link_libraries(junamatkailuintro ${OPENGL_gl_LIBRARY})
else()
  target_link_libraries(junamatkailuintro general ${GLEW_LIBRARY})
endif()
if(${MSVC})
  target_link_libraries(junamatkailuintro ${OPENGL_gl_LIBRARY})
  target_link_libraries(junamatkailuintro debug ${GLEW_LIBRARY_DEBUG})
  target_link_libraries(junamatkailuintro debug ${PNG_LIBRARY_DEBUG})
  target_link_libraries(junamatkailuintro debug ${SDL_LIBRARY_DEBUG})
else()
  target_link_libraries(junamatkailuintro ${BOOST_PROGRAM_OPTIONS_LIBRARY})
endif()
target_link_libraries(junamatkailuintro general ${PNG_LIBRARY})
target_link_libraries(junamatkailuintro general ${SDL_LIBRARY})
