cmake_minimum_required(VERSION 2.8)
set(CMAKE_CONFIGURATION_TYPES "Debug;Release")
project(whisky_in_a_tube)

enable_language(C)
enable_language(CXX)

cmake_policy(SET CMP0011 NEW)
if(${MSVC})
  cmake_policy(SET CMP0015 NEW)
endif()

include("defaults.cmake")

find_boost_program_options(TRUE)
find_glew(TRUE)
find_opengl(TRUE)
find_png(TRUE)
find_sdl(TRUE)

add_definitions(-DUSE_LD)

output_flags("DEBUG" on)

include_directories("${PROJECT_SOURCE_DIR}/src")

set(SOURCE_FILES
  "src/bsd_rand.c"
  "src/bsd_rand.h"
  "src/glsl_shader_source.cpp"
  "src/glsl_shader_source.hpp"
  "src/image_png.cpp"
  "src/image_png.hpp"
  "src/intro.cpp"
  "src/intro.hpp"
  "src/main.cpp"
  "src/SDLMain.h")

if (APPLE)
    list(APPEND SOURCE_FILES "src/SDLMain.m")
endif (APPLE)

add_executable(whisky_in_a_tube ${SOURCE_FILES})
if(${MSVC})
  target_link_libraries(whisky_in_a_tube ${OPENGL_gl_LIBRARY})
  target_link_libraries(whisky_in_a_tube debug ${GLEW_LIBRARY_DEBUG})
  target_link_libraries(whisky_in_a_tube debug ${PNG_LIBRARY_DEBUG})
  target_link_libraries(whisky_in_a_tube debug ${SDL_LIBRARY_DEBUG})
else()
  target_link_libraries(whisky_in_a_tube ${BOOST_PROGRAM_OPTIONS_LIBRARY})
endif()
target_link_libraries(whisky_in_a_tube general ${GLEW_LIBRARY})
target_link_libraries(whisky_in_a_tube general ${PNG_LIBRARY})
target_link_libraries(whisky_in_a_tube general ${SDL_LIBRARY})
