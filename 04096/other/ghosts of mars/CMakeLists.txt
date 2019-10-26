cmake_minimum_required(VERSION 2.8)
set(CMAKE_CONFIGURATION_TYPES "Debug;Release")
project(ghosts_of_mars)

enable_language(C)
enable_language(CXX)

include("defaults.cmake")

find_boost_program_options(TRUE)
find_glew(TRUE)
find_opengl(TRUE)
find_png(TRUE)
find_sdl2(TRUE)

add_definitions(-DUSE_LD)

output_flags("DEBUG" on)

include_directories("${PROJECT_SOURCE_DIR}/src")

add_executable(ghosts_of_mars "src/bsd_rand.c" "src/glsl_shader_source.cpp" "src/image_png.cpp" "src/intro.cpp" "src/main.cpp")
if(${MSVC})
  target_link_libraries(ghosts_of_mars "WINMM")
  target_link_libraries(ghosts_of_mars ${OPENGL_gl_LIBRARY})
  target_link_libraries(ghosts_of_mars debug ${GLEW_LIBRARY_DEBUG})
  target_link_libraries(ghosts_of_mars debug ${PNG_LIBRARY_DEBUG})
  target_link_libraries(ghosts_of_mars debug ${SDL2_LIBRARY_DEBUG})
else()
  target_link_libraries(ghosts_of_mars ${BOOST_PROGRAM_OPTIONS_LIBRARY})
endif()
target_link_libraries(ghosts_of_mars general ${GLEW_LIBRARY})
target_link_libraries(ghosts_of_mars general ${PNG_LIBRARY})
target_link_libraries(ghosts_of_mars general ${SDL2_LIBRARY})
