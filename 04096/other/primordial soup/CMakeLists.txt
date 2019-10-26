cmake_minimum_required(VERSION 3.1)
set(CMAKE_CONFIGURATION_TYPES "Debug;Release")
project(primordial_soup)

enable_language(C)
enable_language(CXX)

include("defaults.cmake")

find_boost("filesystem" "program_options" "system" "thread" "wave")
find_glew()
find_opengl()
find_png()
find_sdl2()

output_flags("DEBUG" on)

add_definitions(-DUSE_LD)

include_directories("${PROJECT_SOURCE_DIR}/src")

add_executable(primordial_soup
  "src/bsd_rand.c"
  "src/bsd_rand.h"
  "src/glsl_program.cpp"
  "src/glsl_program.hpp"
  "src/glsl_shader.cpp"
  "src/glsl_shader.hpp"
  "src/glsl_wave.cpp"
  "src/glsl_wave.hpp"
  "src/image_png.cpp"
  "src/image_png.hpp"
  "src/intro.cpp")
if(MSVC)
  target_link_libraries(primordial_soup "Imm32")
  target_link_libraries(primordial_soup "Version")
  target_link_libraries(primordial_soup "WinMM")
  target_link_libraries(primordial_soup "${OPENGL_gl_LIBRARY}")
  target_link_libraries(primordial_soup debug "${GLEW_LIBRARY_DEBUG}" optimized "${GLEW_LIBRARY}")
  target_link_libraries(primordial_soup debug "${PNG_LIBRARY_DEBUG}" optimized "${PNG_LIBRARY}")
  target_link_libraries(primordial_soup debug "${SDL2_LIBRARY_DEBUG}" optimized "${SDL2_LIBRARY}")
  target_link_libraries(primordial_soup debug "${SNDFILE_LIBRARY_DEBUG}" optimized "${SNDFILE_LIBRARY}")
  target_link_libraries(primordial_soup debug "${ZLIB_LIBRARY_DEBUG}" optimized "${ZLIB_LIBRARY}")
else()
  target_link_libraries(primordial_soup "${BOOST_FILESYSTEM_LIBRARY}")
  target_link_libraries(primordial_soup "${BOOST_PROGRAM_OPTIONS_LIBRARY}")
  target_link_libraries(primordial_soup "${BOOST_SYSTEM_LIBRARY}")
  target_link_libraries(primordial_soup "${BOOST_THREAD_LIBRARY}")
  target_link_libraries(primordial_soup "${BOOST_WAVE_LIBRARY}")
  target_link_libraries(primordial_soup "${GLEW_LIBRARY}")
  target_link_libraries(primordial_soup "${PNG_LIBRARY}")
  target_link_libraries(primordial_soup "${SDL2_LIBRARY}")
  target_link_libraries(primordial_soup "${SNDFILE_LIBRARY}")
endif()

# TODO: Remove when Wave works with FreeBSD/C++11.
if(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
  set_property(SOURCE "src/glsl_wave.cpp" APPEND_STRING PROPERTY COMPILE_FLAGS "-std=c++03")
endif()
