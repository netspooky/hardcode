/** \file
 * For details, please see README.
 */

//######################################
// Define ##############################
//######################################

/** Screen width. */
#define SCREEN_W (1280/*1024*/)

/** Screen heigth. */
#define SCREEN_H (720/*576*/)

/** Antialiaising level. */
#define AA_LEVEL 4

/** Intro length (in samples). */
#define INTRO_LENGTH (104 * 88200)

/** Intro start position (in samples). */
#define INTRO_START 0

/** Intro FOV. */
#define FOV 45.0f

/** Volume side. */
#define VOLUME_SIDE 128

/** \brief Number of elements per strand.
 *
 * 0-2 Position.
 * 3-5 Direction.
 * 6-8 Normal.
 * 9-11 Divergence.
 * 12-14 Color.
 * 15 Age.
 * 16-17 Unused.
 */
#define STRAND_ELEMENTS 18

/** Stride (bytes) between strand arrays. */
#define STRAND_STRIDE (STRAND_ELEMENTS * sizeof(float))

/** Lonkero data. */
#define LONKERO_NUM 8

/** Lonkero data. */
#define LONKERO_LEN 8192

/** Rihmasto data. */
#define RIHMASTO_NUM 128

/** Rihmasto data. */
#define RIHMASTO_LEN 1024

/** Yoksotot data. */
#define YOKSOTOT_NUM 26

/** Yoksotot data. */
#define YOKSOTOT_LEN 1088

/** Fade effect step (samples per pixel). */
#define FADE_STEP 8192

/** Fade effect length - how many pixels to fade at maximum. */
#define FADE_LENGTH (8)

/** \cond */
#if defined(WIN32)
#define _USE_MATH_DEFINES
#endif

#if defined(USE_LD)
#define IFUNCTION static
#define IVARIABLE static
#define ICONST static const
#else
#define IFUNCTION static
#define IVARIABLE static
#define ICONST static
#endif
/** \endcond */

//######################################
// Include #############################
//######################################

#include "intro.h"

#if defined(USE_LD)
#if defined(WIN32)
#include <math.h>
#include "windows.h"
#include "GL/glew.h"
#include "SDL.h"
#elif defined(__APPLE__)
#include <math.h>
#include "GL/glew.h"
#include "SDL/SDL.h"
#else
#include <math.h>
#include "GL/glew.h"
#include "SDL.h"
#endif
#else
#define GL_GLEXT_PROTOTYPES
#if defined(__FreeBSD__)
#include <sys/link_elf.h>
#elif defined(__linux__)
#include <link.h>
#else
#error "no elf header location known for current platform"
#endif
#include <math.h>
#include "GL/gl.h"
#include "GL/glext.h"
#include "GL/glu.h"
#include "SDL.h"
#endif

#include <float.h>

//######################################
// Global data #########################
//######################################

/** Audio buffer for output. */
IVARIABLE uint8_t g_audio_buffer[INTRO_LENGTH * 3 / 2];

/** Current audio position. */
IVARIABLE uint8_t *g_audio_position = &g_audio_buffer[INTRO_START * 88200];

/** Strand data. */
IVARIABLE float g_lonkerot[STRAND_ELEMENTS * (LONKERO_NUM * LONKERO_LEN + RIHMASTO_NUM * RIHMASTO_LEN) + VOLUME_SIDE * VOLUME_SIDE * VOLUME_SIDE];

/** Rihmasto offset. */
#define g_rihmasto (g_lonkerot + STRAND_ELEMENTS * LONKERO_NUM * LONKERO_LEN)

/** Volume offset. */
#define g_volume ((int8_t*)(g_lonkerot + STRAND_ELEMENTS * (LONKERO_NUM * LONKERO_LEN + RIHMASTO_NUM * RIHMASTO_LEN)))

/** Strand data. */
IVARIABLE float g_yoksotot[STRAND_ELEMENTS * YOKSOTOT_NUM * YOKSOTOT_LEN];

#if defined(USE_LD)

/** Effect. */
IVARIABLE unsigned g_effect = 0;

/** Lookat variable. */
IVARIABLE double g_position_x = 0.0;

/** Lookat variable. */
IVARIABLE double g_position_y = 0.0;

/** Lookat variable. */
IVARIABLE double g_position_z = 20.0;

/** Lookat variable. */
IVARIABLE double g_fw_x = 0.0;

/** Lookat variable. */
IVARIABLE double g_fw_y = 0.0;

/** Lookat variable. */
IVARIABLE double g_fw_z = -1.0;

/** Lookat variable. */
IVARIABLE double g_up_x = 0.0;

/** Lookat variable. */
IVARIABLE double g_up_y = 1.0;

/** Lookat variable. */
IVARIABLE double g_up_z = 0.0;

/** Developer mode global toggle. */
IVARIABLE uint8_t g_flag_developer = 0;

#endif

//######################################
// Dynamic loader ######################
//######################################

#if !defined(WIN32)
#include "dlfcn.h"
#endif

/** \brief DJB hash function.
 *
 * Hash function by Daniel J. Bernstein originally posted by comp.lang.c newsgroup in usenet.
 *
 * @param op String to hash.
 * @return Full hash.
 */
IFUNCTION uint32_t djb_hash(const uint8_t *op)
{
  uint32_t ret = 5381;

  for(;;)
  {
    uint32_t cc = *op++;

    if(!cc)
    {
      break;
    }

    ret = ret * 33 + cc;
  }

  return ret;
}

#define dcosf cosf
#define dsinf sinf

#if defined(USE_LD)

/** \cond */
#define dlActiveTexture glActiveTexture
#define dlAttachShader glAttachShader
#define dlBindFramebufferEXT glBindFramebufferEXT
#define dlBindRenderbufferEXT glBindRenderbufferEXT
#define dlBindTexture glBindTexture
#define dlClear glClear
#define dlClearColor glClearColor
#define dlCompileShader glCompileShader
#define dlCreateProgram glCreateProgram
#define dlCreateShader glCreateShader
#define dlDisable glDisable
#define dlDrawArrays glDrawArrays
#define dlDrawElementsInstanced glDrawElementsInstanced
#define dlEnable glEnable
#define dlEnableVertexAttribArray glEnableVertexAttribArray
#define dlFramebufferRenderbufferEXT glFramebufferRenderbufferEXT
#define dlFramebufferTexture2DEXT glFramebufferTexture2DEXT
#define dlGenerateMipmap glGenerateMipmap
#define dlGenFramebuffersEXT glGenFramebuffersEXT
#define dlGenRenderbuffersEXT glGenRenderbuffersEXT
#define dlGenTextures glGenTextures
#define dlLinkProgram glLinkProgram
#define dlLoadIdentity glLoadIdentity
#define dlReadPixels glReadPixels
#define dlRectf glRectf
#define dlRenderbufferStorageEXT glRenderbufferStorageEXT
#define dlRenderbufferStorageMultisampleEXT glRenderbufferStorageMultisampleEXT
#define dlShaderSource glShaderSource
#define dlTexImage2D glTexImage2D
#define dlTexImage2DMultisample glTexImage2DMultisample
#define dlTexImage3D glTexImage3D
#define dlTexParameteri glTexParameteri
#define dlUseProgram glUseProgram
#define dlUniform1i glUniform1i
#define dlUniform3fv glUniform3fv
#define dlVertexAttribDivisor glVertexAttribDivisor
#define dlVertexAttribPointer glVertexAttribPointer
#define dlViewport glViewport

#define dluBuild3DMipmaps gluBuild3DMipmaps
#define dluLookAt gluLookAt
#define dluPerspective gluPerspective

#define DDL_GL_SetAttribute SDL_GL_SetAttribute
#define DDL_GL_SwapBuffers SDL_GL_SwapBuffers
#define DDL_Init SDL_Init
#define DDL_OpenAudio SDL_OpenAudio
#define DDL_PauseAudio SDL_PauseAudio
#define DDL_PollEvent SDL_PollEvent
#define DDL_SetVideoMode SDL_SetVideoMode
#define DDL_ShowCursor SDL_ShowCursor
#define DDL_Quit SDL_Quit
/** \endcond */

/** Dynamically loaded symbols in one segment. */
ICONST char* dnload_symbols[] =
{
  "rand",
  "srand",
  "glAttachShader",
  "glBindFramebufferEXT",
  "glBindRenderbufferEXT",
  "glBindTexture",
  "glClear",
  "glCompileShader",
  "glCreateProgram",
  "glCreateShader",
  "glDisable",
  "glDrawArrays",
  "glEnable",
  "glEnableVertexAttribArray",
  "glFramebufferRenderbufferEXT",
  "glFramebufferTexture2DEXT",
  "glGenFramebuffersEXT",
  "glGenRenderbuffersEXT",
  "glGenTextures",
  "glLinkProgram",
  "glLoadIdentity",
  "glReadPixels",
  "glRectf",
  "glRenderbufferStorageMultisampleEXT",
  "glShaderSource",
  "glTexImage2DMultisample",
  "glUniform3fv",
  "glUseProgram",
  "glVertexAttribPointer",
  "gluBuild3DMipmaps",
  "gluLookAt",
  "gluPerspective",
  "SDL_GL_SwapBuffers",
  "SDL_Init",
  "SDL_OpenAudio",
  "SDL_PauseAudio",
  "SDL_PollEvent",
  "SDL_Quit",
  "SDL_SetVideoMode",
  "SDL_ShowCursor",
  NULL
};

/** \brief Perform dynamic loading.
 *
 * This is actually a stub function that will merely display some information.
 */
IFUNCTION void perform_dnload(void)
{
  const char **iter = dnload_symbols;

  puts("IVARIABLE void* dnload_pointers[] =\n{");

  do {
    printf("  (void*)%08x,\n", djb_hash((uint8_t*)*iter));
  } while(*++iter);

  puts("  NULL\n};");
}

#else

/* To understand this, you need to realize that we can store the function pointers in the same data block
 * whencefrom the names are loaded as long as at least the first names are of <pointer size> length. The
 * symbols here are just listed in the same order as they are defined before. */

/** \brief Locate a loaded function in the pointer table and cast.
 *
 * @param offset Offset in the table.
 */
#define dnload_pointer(offset) (dnload_pointers[offset])

/** \cond */
#define drand ((int (*)(void))dnload_pointer(0))
#define dsrand ((void (*)(unsigned int))dnload_pointer(1))

#define dlAttachShader ((void (*)(GLuint, GLuint))dnload_pointer(2))
#define dlBindFramebufferEXT ((void (*)(GLenum target, GLuint id))dnload_pointer(3))
#define dlBindRenderbufferEXT ((void (*)(GLenum,  GLuint))dnload_pointer(4))
#define dlBindTexture ((void (*)(GLenum, GLuint))dnload_pointer(5))
#define dlClear ((void (*)(GLbitfield))dnload_pointer(6))
#define dlCompileShader ((void (*)(GLuint))dnload_pointer(7))
#define dlCreateProgram ((GLuint (*)(void))dnload_pointer(8))
#define dlCreateShader ((GLuint (*)(GLenum))dnload_pointer(9))
#define dlDisable ((void (*)(GLenum))dnload_pointer(10))
#define dlDrawArrays ((void (*)(GLenum, GLint, GLsizei))dnload_pointer(11))
#define dlEnable ((void (*)(GLenum))dnload_pointer(12))
#define dlEnableVertexAttribArray ((void (*)(GLuint))dnload_pointer(13))
#define dlFramebufferRenderbufferEXT ((void (*)(GLenum, GLenum, GLenum, GLuint))dnload_pointer(14))
#define dlFramebufferTexture2DEXT ((void (*)(GLenum, GLenum, GLenum, GLuint, GLint))dnload_pointer(15))
#define dlGenFramebuffersEXT ((void (*)(GLsizei, GLuint*))dnload_pointer(16))
#define dlGenRenderbuffersEXT ((void (*)(GLsizei, GLuint*))dnload_pointer(17))
#define dlGenTextures ((void (*)(GLsizei, GLuint*))dnload_pointer(18))
#define dlLinkProgram ((void (*)(GLuint))dnload_pointer(19))
#define dlLoadIdentity ((void (*)(void))dnload_pointer(20))
#define dlReadPixels ((void (*)(GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, GLvoid*))dnload_pointer(21))
#define dlRectf ((void (*)(GLfloat, GLfloat, GLfloat, GLfloat))dnload_pointer(22))
#define dlRenderbufferStorageMultisampleEXT ((void (*)(GLenum, GLsizei, GLenum, GLsizei, GLsizei))dnload_pointer(23))
#define dlShaderSource ((void (*)(GLuint, GLsizei, const GLchar**, const GLint*))dnload_pointer(24))
#define dlTexImage2DMultisample ((void (*)(GLenum, GLsizei, GLint, GLsizei, GLsizei, GLboolean))dnload_pointer(25))
#define dlUniform3fv ((void (*)(GLint, GLsizei, GLfloat*))dnload_pointer(26))
#define dlUseProgram ((void (*)(GLuint))dnload_pointer(27))
#define dlVertexAttribPointer ((void (*)(GLuint, GLint, GLenum, GLboolean, GLsizei, const GLvoid*))dnload_pointer(28))

#define dluBuild3DMipmaps ((GLint (*)(GLenum, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLenum, const void*))dnload_pointer(29))
#define dluLookAt ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble))dnload_pointer(30))
#define dluPerspective ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble))dnload_pointer(31))

#define DDL_GL_SwapBuffers ((void (*)(void))dnload_pointer(32))
#define DDL_Init ((int (*)(Uint32))dnload_pointer(33))
#define DDL_OpenAudio ((int (*)(SDL_AudioSpec*, SDL_AudioSpec*))dnload_pointer(34))
#define DDL_PauseAudio ((void (*)(int))dnload_pointer(35))
#define DDL_PollEvent ((int (*)(SDL_Event*))dnload_pointer(36))
#define DDL_Quit ((void (*)(void))dnload_pointer(37))
#define DDL_SetVideoMode ((SDL_Surface* (*)(int, int, int, Uint32))dnload_pointer(38))
#define DDL_ShowCursor ((int (*)(int))dnload_pointer(39))
/** \endcond */

/** \brief Dynamically loaded pointers.
 *
 * Initial values are hashes of function names that are resolved into function addresses. The function names
 * are in the same order in dnload_symbols.
 */
IVARIABLE void* dnload_pointers[] =
{
  (void*)0x7c9d3dea,
  (void*)0x1060307d,
  (void*)0x9f5da104,
  (void*)0xb5000a6b,
  (void*)0xbe273220,
  (void*)0x9ac194a6,
  (void*)0xfd54903f,
  (void*)0x712f7898,
  (void*)0x205c8f24,
  (void*)0x835cdd03,
  (void*)0xebb1802c,
  (void*)0x2d14fe58,
  (void*)0xacb2ecbf,
  (void*)0x13ae32c2,
  (void*)0x32ca2448,
  (void*)0xf6b993b5,
  (void*)0xb7bd25db,
  (void*)0x3a25d7d0,
  (void*)0xa9f1b516,
  (void*)0x2fed8c1e,
  (void*)0x278b0662,
  (void*)0xe7228d49,
  (void*)0xfe60230c,
  (void*)0xb7d26805,
  (void*)0xbba22800,
  (void*)0x96328daf,
  (void*)0x509144a7,
  (void*)0x4f3ddefd,
  (void*)0x73e23bdd,
  (void*)0xe5a4430b,
  (void*)0x63b0f2f7,
  (void*)0xa5043337,
  (void*)0x811eb401,
  (void*)0x3fac837b,
  (void*)0xf44169cb,
  (void*)0x42850c57,
  (void*)0x92f25140,
  (void*)0x3fb1044a,
  (void*)0x7cc5e50f,
  (void*)0xdcc5fcc6,
  NULL
};

/** \brief ELF base address.
 *
 * NOTE: The following procedures are adapted from 'proof of concept' sources published by parcelshit and
 * las/Mercury for scouring the ELF headers for function addresses. They are essentially in form with the
 * original sources, having just been adapted for this particular purpose.
 *
 * Unfortunately the original 'release' sources seem not to be available at the time of writing this comment,
 * but the original discussion and proposals by las can be followed in this Pouet thread:
 * http://pouet.net/topic.php?which=5392&page=4
 * The code used as a reference is this one in particular:
 * http://pastebin.com/f479f8beb
 *
 * If I forgot to credit someone, please drop me a line and we'll get that in order.
 */
#define ELF_BASE_ADDRESS 0x08048000

/** Get the program link map by following from ELF header.
 */
IFUNCTION struct link_map* elf32_get_link_map()
{
  Elf32_Ehdr *ehdr;
  Elf32_Phdr *phdr;
  Elf32_Dyn *dynamic;

  // Get the headers, ELF header is in a fixed location in memory. First phdr is located directly after.
  ehdr = (Elf32_Ehdr*)ELF_BASE_ADDRESS; 
  phdr = (Elf32_Phdr*)((size_t)ehdr + (size_t)ehdr->e_phoff);

  // Find the dynamic header.
  for(; (phdr->p_type != PT_DYNAMIC); ++phdr);
  dynamic = (Elf32_Dyn*)phdr->p_vaddr;

  // Find the debug entry in the dynamic header.
  for(; (dynamic->d_tag != DT_DEBUG); ++dynamic);

  return ((struct r_debug*)dynamic->d_un.d_ptr)->r_map;
}

/** Get address of one section from a given link map.
 *
 * @param lmap Link map.
 * @param op Tag to look for.
 */
IFUNCTION void* elf32_get_dynamic_section_value(struct link_map* lmap, int op)
{
  Elf32_Dyn* dynamic = (Elf32_Dyn*)lmap->l_ld;
  void* ret;

  // Find the desired tag in the dynamic header.
  for(; (dynamic->d_tag != op); ++dynamic);

  ret = (void*)dynamic->d_un.d_ptr;

  if(ret < (void*)lmap->l_addr)
  {
    ret += (size_t)lmap->l_addr;
  }
  return ret;
}

/** Try to find a symbol in one link map.
 *
 * @param lmap Link map.
 * @param hash Symbol hash to find.
 * @return Symbol if found or NULL.
 */
IFUNCTION void* elf32_find_symbol_in_map(struct link_map* lmap, uint32_t hash)
{
  char* strtab = (char*)elf32_get_dynamic_section_value(lmap, DT_STRTAB);
  Elf32_Sym* symtab = (Elf32_Sym*)elf32_get_dynamic_section_value(lmap, DT_SYMTAB);
  uint32_t* hashtable = (uint32_t*)elf32_get_dynamic_section_value(lmap, DT_HASH);
  unsigned numchains = hashtable[1];
  unsigned ii;

  for(ii = 0; (ii < numchains); ++ii)
  {
    Elf32_Sym* sym = &symtab[ii];
    char *name = &strtab[sym->st_name];

    if(djb_hash(name) == hash)
    {
      return (void*)sym->st_value;
    }
  }

  return NULL;
}

/** Find a symbol in any of the link maps.
 *
 * @param hash Hash of the function name string.
 * return Symbol found or NULL.
 */
IFUNCTION void* elf32_find_symbol(uint32_t hash)
{
  struct link_map* lmap = elf32_get_link_map();

  for(;;)
  {
    void* ret = elf32_find_symbol_in_map(lmap, hash);

    if(ret)
    {
      return ret + (size_t)lmap->l_addr;
    }

    lmap = lmap->l_next;
  }
}

/** \brief Perform dynamic loading.
 */
IFUNCTION int perform_dnload()
{
  void **funcptr = dnload_pointers;

  do {
    *funcptr = elf32_find_symbol(*(uint32_t*)funcptr);
  } while(*++funcptr);
}

#endif

//######################################
// rand() ##############################
//######################################

#include "bsd_rand.h"

#if defined(USE_LD)

#define drand bsd_rand
#define dsrand bsd_srand

#endif

/** Random number -op to op.
 *
 * @param op Limit.
 * @return Random number [-op, op[
 */
IFUNCTION float frand(float op)
{
  uint16_t ret = (uint16_t)(drand() & 0xFFFF);
  return (float)*((int16_t*)&ret) / 32768.0f * op;
}

//######################################
// Music ###############################
//######################################

/** \brief Update audio stream.
 *
 * This function cannot have extra attributes due to needing to comply with
 * the system ABI.
 *
 * @param userdata Not used.
 * @param stream Target stream.
 * @param len Number of bytes to write.
 */
IFUNCTION void audio_callback(void *userdata, Uint8 *stream, int len)
{
  (void)userdata;

  do {
    *stream = *g_audio_position;
    ++stream;
    ++g_audio_position;
  } while(len--);
}

/** SDL audio specification struct. */
IVARIABLE SDL_AudioSpec audio_spec =
{
  44100,
  AUDIO_U8,
  2,
  0,
#if defined(USE_LD)
  4096,
#else
  256, // as low as we can go without coughing
#endif
  0,
  0,
  audio_callback,
  NULL
};

//######################################
// Shaders #############################
//######################################

/** Vertex shader common to audio and FBO. */
ICONST char g_shader_vertex_quad[] = ""
"in vec3 a;"
"out D"
"{"
"vec4 a;"
"vec4 b;"
"}o;"
"void main()"
"{"
"o.a=gl_ModelViewMatrixInverse*vec4(0,0,-.5,1);"
"o.b=gl_ModelViewMatrixInverse*vec4(a,1);"
"gl_Position=vec4(a,1);"
"}";

/** Vertex shader. */
ICONST char g_shader_vertex_main[] = ""
"in vec3 a;"
"in vec3 b;"
"in vec3 c;"
"in vec3 d;"
"in vec3 e;"
"in vec3 f;"
"out D"
"{"
"vec3 a;"
"vec3 b;"
"vec3 c;"
"vec3 d;"
"vec3 e;"
"vec3 f;"
"mat4 g;"
"}o;"
"void main()"
"{"
"o.a=a;"
"o.b=b;"
"o.c=c;"
"o.d=d;"
"o.e=e;"
"o.f=f;"
"o.g=gl_ModelViewMatrix;"
"}";

/** Geometry shader. */
ICONST char g_shader_geometry_main[] = ""
"layout(points)in;"
"layout(triangle_strip,max_vertices=22)out;"
"uniform vec3 l[3];"
"in D"
"{"
"vec3 a;"
"vec3 b;"
"vec3 c;"
"vec3 d;"
"vec3 e;"
"vec3 f;"
"mat4 g;"
"}i[1];"
"out D"
"{"
"vec3 a;"
"vec3 b;"
"vec3 c;"
"vec3 d;"
"}o;"
"void main()"
"{"
"vec3 a=i[0].a;"
"vec3 b=normalize(i[0].b);"
"vec3 f=i[0].f;"
"float t=smoothstep(f.x*333,(f.x+2222)*333,l[0].y);"
"float s=smoothstep((f.x+l[0].z)*222,(f.x+l[0].z*1.4)*222,l[0].y);"
"float m=1-s;"
"a=(a-(s*b)*length(a))*m;"
"a.xzy=vec3(a.xz*mat2(cos(s*15),sin(s*15),-sin(s*15),cos(s*15)),a.y);"
"vec3 d=i[0].d*sin(l[0].y/99999+f.x)*l[0].x;"
"for(int n=8;n>=0;--n)"
"{"
"b=normalize(b+d);"
"vec3 e=cross(b,normalize(i[0].c)*t*m*m*m);"
"o.d=normalize(cross(e,b));"
"e*=(n<8?n:0)*i[0].f.y;"
"o.c=i[0].e;"
"o.b=b;"
"o.a=a+e;"
"gl_Position=i[0].g*vec4(o.a,1);"
"EmitVertex();"
"o.a=a-e;"
"gl_Position=i[0].g*vec4(o.a,1);"
"EmitVertex();"
"a+=b*i[0].f.z*t;"
"}"
#if defined(USE_LD)
"EndPrimitive();"
#endif
"}";

/** Fragment shader. */
ICONST char g_shader_fragment_main[] = ""
"uniform vec3 l[3];"
"in D"
"{"
"vec3 a;"
"vec3 b;"
"vec3 c;"
"vec3 d;"
"}i;"
"void main()"
"{"
"vec3 m=normalize(l[2]-i.a);"
"gl_FragColor=vec4((dot(gl_FrontFacing?-i.d:i.d,m)+dot(i.b,m)+1)/2*i.c,1);"
"}";

/** Background fragment shader. */
ICONST char g_shader_fragment_background[] = ""
"uniform vec3 l[3];"
"uniform sampler3D t;"
"in D"
"{"
"vec4 a;"
"vec4 b;"
"}i;"
"void main()"
"{"
"vec3 a=i.a.xyz/i.a.a;"
"vec3 b=i.b.xyz/i.b.a;"
"vec3 c=normalize(b-a);"
"vec3 d=(a-l[2])-dot(a-l[2],c)*c;"
"vec3 e=(length(l[2]-b)*(a-b)+l[2]-b)*(l[0].y/2000000)+d;"
// Angle between the lines, not distance
"float s=acos(dot(normalize(l[2]-b),c));"
// Let's color
//"float d = length(e) * 0.05 * dot(e, texture3D(u, e).rgb);"
//"d *= abs(sin(gl_FragCoord.y*200.0));"
//"float d = abs(sin(angle*100.0));"
// Transformations
//"d *= 1.0/(0.01*length(s));"
//"d *= (1.0-smoothstep(0, 1.5708, angle));"
"gl_FragColor = vec4(mix(vec3(.2,.15,.1),vec3(.4,.5,.6),length((texture3D(t,e*.003).xyz+texture3D(t,e*.007).xyz+texture3D(t,e*.02).xyz+texture3D(t,e*.05).xyz))/(2*s+.02)*(1-smoothstep(0,1.5,s))),1)+vec4(mix(vec3(0),vec3(l[1].y,.2,l[1].z),1/(.01*abs(d.x*d.y)+1)+1/(.01*pow(abs(d.x)-abs(d.y),2)+1)),1);"
//"f = vec4(mix(vec3(1.0), vec3(0.4, 0.5, 0.6), d), 1.0);"
"}";

/** FBO fragment shader. */
ICONST char g_shader_fragment_fbo[] = ""
"uniform vec3 l[3];"
"uniform sampler2DMS t;"
"void main()"
"{"
"gl_FragColor=vec4(0);"
"for(int n=3;n>=0;--n)"
"{"
"ivec2 s=ivec2(gl_FragCoord.xy + vec2(n%2==1?-l[1].x:l[1].x,n>1?-l[1].x:l[1].x));"
"gl_FragColor+=texelFetch(t,s,n)/4;"
"}"
"}";

#include "audio_shader.h"

/** \cond */
#if defined(USE_LD)
GLuint g_program_background;
GLint g_attribute_background_a;
GLint g_uniform_background_l;
GLint g_uniform_background_t;
GLuint g_program_main;
GLint g_attribute_main_a;
GLint g_attribute_main_b;
GLint g_attribute_main_c;
GLint g_attribute_main_d;
GLint g_attribute_main_e;
GLint g_attribute_main_f;
GLint g_uniform_main_l;
GLuint g_program_fbo;
GLint g_attribute_fbo_a;
GLint g_uniform_fbo_l;
GLint g_uniform_fbo_t;
GLuint g_program_audio;
GLint g_attribute_audio_a;
GLint g_uniform_audio_l;
GLuint g_fbo;
GLuint g_fbo_texture;
GLuint g_volume_texture;
#else
#define g_program_main 1
#define g_attribute_main_a 0
#define g_attribute_main_b 1
#define g_attribute_main_c 2
#define g_attribute_main_d 3
#define g_attribute_main_e 4
#define g_attribute_main_f 5
#define g_uniform_main_l 0
#define g_program_background 5
#define g_attribute_background_a 0
#define g_uniform_background_l 0
#define g_uniform_background_t 3
#define g_program_fbo 8
#define g_attribute_fbo_a 0
#define g_uniform_fbo_l 0
#define g_uniform_fbo_t 3
#define g_program_audio 11
#define g_attribute_audio_a 0
#define g_uniform_audio_l 0
#define g_fbo 1
#define g_fbo_texture 1
#define g_volume_texture 2
#endif
/** \endcond */

#if defined(USE_LD)

/** \brief Prints an indent.
 *
 * @param indent Number of characters to draw.
 */
static void print_indent(unsigned indent)
{
  unsigned ii;
  for(ii = 0; (ii < indent); ++ii)
  {
    putc(' ', stdout);
  }
}

/** \brief Print a shader and make the output neater.
 *
 * @param shader Shader to print.
 */
static unsigned print_shader(const char *shader, unsigned indent)
{
  char *iter = (char*)shader;
  char cc = *iter;

  while(cc)
  {		
    switch(cc)
    {
      case ';':
        {
          puts(";");
          print_indent(indent);
        }
        break;

      case '{':
        putc('\n', stdout);
        print_indent(indent);
        puts("{");
        indent += 2;
        print_indent(indent);
        break;

      case '}':
        putc('\r', stdout);
        indent -= 2;
        print_indent(indent);
        puts("}");
        print_indent(indent);
        break;

      default:
        putc(cc, stdout);
        break;
    }

    ++iter;
    cc = *iter;
  }

  return indent;
}			

#endif

IVARIABLE const char *g_shader_parts[] = { "#version 150 compatibility\n", NULL };

/** \brief Create a shader.
 *
 * @param sh Shader content.
 * @param st Shader type.
 * @return Compiled shader.
 */
IFUNCTION GLuint shader_create(const char *source, GLenum st)
{
  GLuint ret = dlCreateShader(st);
  g_shader_parts[1] = source;
  dlShaderSource(ret, 2, (const char**)g_shader_parts, NULL);
  dlCompileShader(ret);
#if defined(USE_LD)
  {
    unsigned ii;
    unsigned indent;
    char slog[4096];
    GLsizei len;
    GLint status;

    for(ii = 0, indent = 0; (ii < 2); ++ii)
    {
      indent = print_shader(g_shader_parts[ii], indent);
    }

    glGetShaderInfoLog(ret, 4096, &len, slog);
    if(strlen(slog) > 0)
    {
      puts(slog);
    }

    glGetShaderiv(ret, GL_COMPILE_STATUS, &status);
    if(status != GL_TRUE)
    {
      DDL_Quit();
      exit(1);
    }
  }
#endif
  return ret;
}

/** \brief Create a program.
 *
 * Create a shader program using one vertex shader and one fragment shader.
 *
 * @param vs Vertex shader.
 * @param fs Fragement shader.
 * @return The compiled and linked program.
 */
IFUNCTION
#if defined(USE_LD)
GLuint
#else
void
#endif
program_create(const char *vertex, const char *geometry, const char* fragment)
{
  GLuint ret = dlCreateProgram();

  dlAttachShader(ret, shader_create(vertex, GL_VERTEX_SHADER));
  if(geometry)
  {
    dlAttachShader(ret, shader_create(geometry, GL_GEOMETRY_SHADER));
  }
  dlAttachShader(ret, shader_create(fragment, GL_FRAGMENT_SHADER));
  dlLinkProgram(ret);
#if defined(USE_LD)
  {
    char slog[4096];
    GLsizei len;
    GLint status;
    glGetProgramInfoLog(ret, 4096, &len, slog);
    if(strlen(slog) > 0)
    {
      puts(slog);
    }

    glGetProgramiv(ret, GL_LINK_STATUS, &status);
    if(status != GL_TRUE)
    {
      DDL_Quit();
      exit(1);
    }
    printf("GLSL program compiles to: %u\n", ret);
    return ret;
  }
#endif
}

//######################################
// Draw ################################
//######################################

IVARIABLE float g_uniform_array[] = 
{
  0.0f, (float)SCREEN_W, 0.0f,
  0.0f, 0.3f, 0.6f,
  12.0f, 18.0f, 28.0f,
};

/** 'Playground' area. */
#define DIRECTION_SCOPE 64.0f

/** Direction and scene information.
 *
 * This consists of 'scene' information where it is saved how the scenes are played.
 *
 * Data is listed as follows:
 * 0: Time at the end of this scene, in samples, multiplied by 44100.
 * 1: Bits 1-2 compose the scene number 0-3.
 *    Bit 3 tells if relative time should affect distort.
 *    Bit 4 tells if relative time base is 1 or 0.
 *    Bits 5-6 tell the color choice of background. 0=red, 16=magenta, 32=blue.
 *    Full number is input to srand() for the scene.
 * 2: Subjective time at the start of this scene, multiplied by 44100.
 * 3: Camera position at start of the scene (as input to srand()).
 * 4: Camera forward at start of the scene (as input to srand()).
 * 5: Camera up at start of the scene (as input to srand()).
 * 6: Camera position at end of the scene (as input to srand()).
 * 7: Camera forward at end of the scene (as input to srand()).
 * 8: Camera up at end of the scene (as input to srand()).
 */
IVARIABLE uint8_t g_direction[] =
{
  8, 32 + 0, 255, 34, 225, 60, 182, 198, 35,
  21, 32 + 0, 0, 104, 226, 89, 82, 87, 89,
  29, 32 + 4 + 1, 1, 78, 165, 178, 222, 122, 89,
  33, 32 + 4 + 0, 8, 108, 102, 49, 191, 223, 6,
  38, 32 + 8, 5, 139, 200, 102, 191, 56, 254,
  52, 16 + 8 + 4 + 1, 19, 247, 230, 102, 12, 117, 13,
  57, 16 + 8 + 4 + 0, 31, 140, 233, 175, 140, 233, 171,
  75, 16 + 8 + 4 + 1, 37, 247, 230, 102, 12, 117, 13,
  82, 8 + 2, 0, 65, 126, 89, 135, 200, 19,
  90, 8 + 4 + 2, 2, 47, 27, 65, 4, 70, 108,
  104, 8 + 4 + 2, 20, 221, 235, 89, 221, 235, 89,
};

/** \brief Apply camera position.
 *
 * @param relative_time Relative time within the scene.
 * @param seed Packed seed data.
 * @param aspect Screen aspect ratio.
 */
IFUNCTION void apply_camera(float relative_time, uint8_t *seed, float aspect)
{
#if defined(USE_LD)
  glMatrixMode(GL_MODELVIEW);
#endif
  dlLoadIdentity();
  dluPerspective(FOV, aspect, 0.128f, 512.0f);

#if defined(USE_LD)
  if(g_flag_developer)
  {
    dluLookAt(g_position_x, g_position_y, g_position_z,
        g_position_x + g_fw_x, g_position_y + g_fw_y, g_position_z + g_fw_z,
        g_up_x, g_up_y, g_up_z);
  }
  else
#endif
  {
    float lookat[9];
    unsigned ii;
    unsigned jj;

    for(jj = 0; (jj < 3); ++jj)
    {
      dsrand(seed[jj]);

      for(ii = 0; (ii < 3); ++ii)
      {
        lookat[jj * 3 + ii] = frand(DIRECTION_SCOPE);
      }

      dsrand(seed[jj + 3]);

      for(ii = 0; (ii < 3); ++ii)
      {
        lookat[jj * 3 + ii] += (frand(DIRECTION_SCOPE) - lookat[jj * 3 + ii]) * relative_time;
      }
    }

    dluLookAt(lookat[0], lookat[1], lookat[2], lookat[3], lookat[4], lookat[5], lookat[6], lookat[7],
        lookat[8]);
  }
}

/** \brief Generate a strand.
 *
 * @param iter Iterator.
 * @param px X start point.
 * @param py Y start point.
 * @param pz Z start point.
 * @param xbias X direction bias.
 * @param morph Morph (on ticks).
 * @param jitter Jitter (on location).
 * @param diverge Diverge (on direction).
 * @param pr Red basis.
 * @param pg Green basis.
 * @param pb Blue basis.
 * @param width Width (at base).
 * @param length Length (total).
 * @param ticks Current tick count.
 * @return New iterator pointer.
 */
IFUNCTION float* generate_strand(float *iter, float px, float py, float pz, float xbias, float morph,
    float jitter, float diverge, float pr, float pg, float pb, float width, float length, unsigned ticks,
    unsigned len)
{
  float dx = xbias + frand(1.0f);
  float dy = frand(1.0f);
  float dz = frand(1.0f);
  unsigned ii;

  for(ii = 0; (ii < len); ++ii)
  {
    dx += xbias * 0.1f + frand(0.05f + morph * dsinf((float)ticks * 0.0000033f));
    dy += frand(0.05f + morph * dcosf(((float)ticks * 0.0000048f) + 0.7f));
    dz += frand(0.05f + morph * dsinf(((float)ticks * 0.0000035f) + 2.1f));

    {
      float dlen = 1.0f / sqrtf(dx * dx + dy * dy + dz * dz);

      dx *= dlen;
      dy *= dlen;
      dz *= dlen;
    }

    iter[0] = px + frand(jitter);
    iter[1] = py + frand(jitter);
    iter[2] = pz + frand(jitter);

    iter[3] = dx + frand(diverge);
    iter[4] = dy + frand(diverge);
    iter[5] = dz + frand(diverge);

    iter[6] = frand(1.0f);
    iter[7] = frand(1.0f);
    iter[8] = frand(1.0f);

    iter[9] = frand(0.2f);
    iter[10] = frand(0.2f);
    iter[11] = frand(0.2f);

    iter[12] = pr + frand(0.08f);
    iter[13] = pg + frand(0.08f);
    iter[14] = pb + frand(0.08f);

    iter[15] = (float)ii;
    iter[16] = width;
    iter[17] = length;

    iter += 18;

    px += dx * 0.06f;
    py += dy * 0.06f;
    pz += dz * 0.06f;
  }

  return iter;
}

/** \brief Draw the world.
 *
 * @param ms Milliseconds.
 * @param aspec Screen aspect.
 */
IFUNCTION void draw(unsigned ticks, float aspect)
{
  float *data;
  float relative_time;
  GLsizei count;
  unsigned fade = 0;
  unsigned absolute_time;
  uint8_t flags;

  uint8_t *scene = g_direction;
  unsigned previous_time = 0;

  for(;;)
  {
    unsigned scene_end = (unsigned)(*scene) * 88200;

    if(ticks < scene_end)
    {
      absolute_time = ticks - previous_time;
      relative_time = (float)absolute_time / (float)(scene_end - previous_time);
      if(absolute_time < FADE_STEP * FADE_LENGTH)
      {
        fade = FADE_LENGTH - absolute_time / FADE_STEP;
      }
      else if(scene_end - ticks < FADE_STEP * FADE_LENGTH)
      {
        fade = FADE_LENGTH - (scene_end - ticks) / FADE_STEP;
      }
      break;
    }

    previous_time = scene_end;
    scene += 9;
  }

  apply_camera(relative_time, &scene[3], aspect);
  flags = scene[1];

  {
    unsigned effect;
   
#if defined(USE_LD)
    if(g_flag_developer)
    {
      effect = g_effect;
    }
    else
#endif
    {
      effect = flags & (2 + 1);
      g_uniform_array[0] = (flags & 8) ? 1.0f : 0.0f;
      if(flags & 4)
      {
        g_uniform_array[0] += relative_time;
      }
      g_uniform_array[1] = (float)(absolute_time + (unsigned)scene[2] * 88200);
      g_uniform_array[3] = (float)fade;
    }
    // Background color.
    if(flags & 16)
    {
      g_uniform_array[4] = 0.7f;
      g_uniform_array[5] = 0.5f;
    }
    else if((flags & (32 + 16)) == 0)
    {
      g_uniform_array[4] = 0.7f;
      g_uniform_array[5] = 0.2f;
    }

    switch(effect)
    {
      case 0:
        {
          data = g_lonkerot;
          count = LONKERO_NUM * LONKERO_LEN;
          g_uniform_array[2] = 13000.0f;
        }
        break;

      case 1:
        {
          data = g_rihmasto;
          count = RIHMASTO_NUM * RIHMASTO_LEN;
          g_uniform_array[2] = 15500.0f;
        }
        break;

      default:
        {
          float *iter = g_yoksotot;

#if defined(USE_LD)
          if(g_flag_developer)
          {
            dsrand(6);
          }
          else
#endif
          {
            dsrand(flags);
          }

          {
            unsigned ii = YOKSOTOT_NUM;

            do {
              iter = generate_strand(iter, 0.0f, 0.0f, 0.0f,
                  0.0f, 0.1f, 0.07f, 0.16f, 0.8f, 0.4f, 0.2f, 0.06f, 0.45f, ticks, YOKSOTOT_LEN);
            } while(--ii);
          }

          data = g_yoksotot;
          count = YOKSOTOT_NUM * YOKSOTOT_LEN;
          g_uniform_array[2] = 9500.0f;
        }
    }
  }

  dlBindFramebufferEXT(GL_FRAMEBUFFER_EXT, g_fbo);
  dlUseProgram(g_program_background);
  dlUniform3fv(g_uniform_background_l, (int)3, g_uniform_array);
#if defined(USE_LD)
  dlBindTexture(GL_TEXTURE_2D_MULTISAMPLE, 0);
#endif
  dlBindTexture(GL_TEXTURE_3D, g_volume_texture);

  dlRectf(-1.0f, -1.0f, 1.0f, 1.0f);

  dlUseProgram(g_program_main);
  dlUniform3fv(g_uniform_main_l, (int)3, g_uniform_array);
#if defined(USE_LD)
  dlBindTexture(GL_TEXTURE_3D, 0);
#endif
  dlEnable(GL_DEPTH_TEST);
  dlClear(GL_DEPTH_BUFFER_BIT);

#if defined(USE_LD)
  dlEnableVertexAttribArray((GLuint)g_attribute_main_a);
  dlVertexAttribPointer((GLuint)g_attribute_main_a, 3, GL_FLOAT, GL_FALSE, STRAND_STRIDE, data + 0);

  dlEnableVertexAttribArray((GLuint)g_attribute_main_b);
  dlVertexAttribPointer((GLuint)g_attribute_main_b, 3, GL_FLOAT, GL_FALSE, STRAND_STRIDE, data + 3);

  dlEnableVertexAttribArray((GLuint)g_attribute_main_c);
  dlVertexAttribPointer((GLuint)g_attribute_main_c, 3, GL_FLOAT, GL_FALSE, STRAND_STRIDE, data + 6);

  dlEnableVertexAttribArray((GLuint)g_attribute_main_d);
  dlVertexAttribPointer((GLuint)g_attribute_main_d, 3, GL_FLOAT, GL_FALSE, STRAND_STRIDE, data + 9);

  dlEnableVertexAttribArray((GLuint)g_attribute_main_e);
  dlVertexAttribPointer((GLuint)g_attribute_main_e, 3, GL_FLOAT, GL_FALSE, STRAND_STRIDE, data + 12);

  dlEnableVertexAttribArray((GLuint)g_attribute_main_f);
  dlVertexAttribPointer((GLuint)g_attribute_main_f, 3, GL_FLOAT, GL_FALSE, STRAND_STRIDE, data + 15);
#else
  {
    unsigned ii;
   
    for(ii = g_attribute_main_a; (ii <= g_attribute_main_f); ++ii)
    {
      dlEnableVertexAttribArray((GLuint)ii);
      dlVertexAttribPointer((GLuint)ii, 3, GL_FLOAT, GL_FALSE, STRAND_STRIDE, data + ii * 3);
    }
  }
#endif
  dlDrawArrays(GL_POINTS, 0, (GLsizei)count);

  dlBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
  dlUseProgram(g_program_fbo);
  dlUniform3fv(g_uniform_fbo_l, (int)3, g_uniform_array);
  dlBindTexture(GL_TEXTURE_2D_MULTISAMPLE, g_fbo_texture);
  dlDisable(GL_DEPTH_TEST);

  dlRectf(-1.0f, -1.0f, 1.0f, 1.0f);
}

//######################################
// Main ################################
//######################################

#if defined(USE_LD)
int intro(int screen_w, int screen_h, uint8_t flag_developer, uint8_t flag_fullscreen, uint8_t flag_record)
{
#else
/** Required ELF symbol. */
void *environ;

/** Required ELF symbol. */
void *__progname;

/** \cond */
#define screen_w SCREEN_W
#define screen_h SCREEN_H
#define flag_developer 0
#define flag_fullscreen 1
/** \endcond */

/** \brief Object file starting point. */
void _start()
{
#endif
#if defined(USE_LD)
  uint32_t starttick;
#endif

  perform_dnload();

  // Graphics init.
  DDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
  DDL_SetVideoMode(screen_w, screen_h, 0, SDL_OPENGL | (flag_fullscreen ? SDL_FULLSCREEN : 0));
  DDL_ShowCursor(flag_developer);

#if defined(USE_LD)
  if(glewInit() != GLEW_OK)
  {
    DDL_Quit();
    return 1;
  }
#endif

#if defined(USE_LD)
  g_program_main =
#endif
  program_create(g_shader_vertex_main, g_shader_geometry_main, g_shader_fragment_main);
#if defined(USE_LD)
  g_attribute_main_a = glGetAttribLocation(g_program_main, "a");
  g_attribute_main_b = glGetAttribLocation(g_program_main, "b");
  g_attribute_main_c = glGetAttribLocation(g_program_main, "c");
  g_attribute_main_d = glGetAttribLocation(g_program_main, "d");
  g_attribute_main_e = glGetAttribLocation(g_program_main, "e");
  g_attribute_main_f = glGetAttribLocation(g_program_main, "f");
  g_uniform_main_l = glGetUniformLocation(g_program_main, "l");
  printf("Main program: %u\nAttributes:\na: %i\nb: %i\nc: %i\nd: %i\ne: %i\nf: %i\nUniforms:\nl: %i\n",
      g_program_main, g_attribute_main_a, g_attribute_main_b, g_attribute_main_c, g_attribute_main_d,
      g_attribute_main_e, g_attribute_main_f, g_uniform_main_l);
#endif

#if defined(USE_LD)
  g_program_background =
#endif
  program_create(g_shader_vertex_quad, NULL, g_shader_fragment_background);
#if defined(USE_LD)
  g_attribute_fbo_a = glGetAttribLocation(g_program_background, "a");
  g_uniform_fbo_l = glGetUniformLocation(g_program_background, "l");
  g_uniform_fbo_t = glGetUniformLocation(g_program_background, "t");
  printf("FBO program: %u\nAttributes:\na: %i\nUniforms:\nl: %i\nt: %i\n",
      g_program_fbo, g_attribute_fbo_a, g_uniform_fbo_l, g_uniform_fbo_t);
#endif

#if defined(USE_LD)
  g_program_fbo =
#endif
  program_create(g_shader_vertex_quad, NULL, g_shader_fragment_fbo);
#if defined(USE_LD)
  g_attribute_fbo_a = glGetAttribLocation(g_program_fbo, "a");
  g_uniform_fbo_l = glGetUniformLocation(g_program_fbo, "l");
  g_uniform_fbo_t = glGetUniformLocation(g_program_fbo, "t");
  printf("FBO program: %u\nAttributes:\na: %i\nUniforms:\nl: %i\nt: %i\n",
      g_program_fbo, g_attribute_fbo_a, g_uniform_fbo_l, g_uniform_fbo_t);
#endif

#if defined(USE_LD)
  g_program_audio =
#endif
  program_create(g_shader_vertex_quad, NULL, g_shader_fragment_audio);
#if defined(USE_LD)
  g_attribute_audio_a = glGetAttribLocation(g_program_audio, "a");
  g_uniform_audio_l = glGetUniformLocation(g_program_audio, "l");
  printf("Audio program: %u\nAttributes:\na: %i\nUniforms:\nl: %i\n",
      g_program_audio, g_attribute_audio_a, g_uniform_audio_l);
#endif

  // Perform CPU precalc first, it might give display devices time to change mode if need be.
  {
    dsrand(4);
    
    {
      float *iter = g_lonkerot;
      int8_t *volumeiter;
      unsigned ii = LONKERO_NUM;

      do {
        iter = generate_strand(iter, -52.0f, frand(12.0f), -16.0f + frand(16.0f), 0.1f, 0.0f, 0.05f, 0.3f,
            0.5f, 0.6f, 0.4f, 0.03f, 0.5f, 0, LONKERO_LEN);
      } while(--ii);

      ii = RIHMASTO_NUM;
      // Iterator is conveniently at rihmasto.
      do {
        iter = generate_strand(iter, frand(64.0f), frand(64.0f), frand(64.0f), 0.0f, 0.0f, 0.05f, 0.8f, 0.5f,
            0.6f, 0.35f, 0.03f, 0.6f, 0, RIHMASTO_LEN);
      } while(--ii);

      ii = VOLUME_SIDE * VOLUME_SIDE * VOLUME_SIDE * 3;
      volumeiter = (int8_t*)iter; // Iterator is conveniently at volume.
      do {
        *volumeiter++ = (int8_t)drand();
      } while(--ii);
    }
  }

  // Generate GL assets.
  {
    GLuint renderbuffer;

#if defined(USE_LD)
    dlGenTextures(1, &g_fbo_texture);
#else
    GLuint useless;
    dlGenTextures(1, &useless);
#endif
    dlBindTexture(GL_TEXTURE_2D_MULTISAMPLE, g_fbo_texture);
    dlTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE, AA_LEVEL, GL_RGBA, SCREEN_W, SCREEN_H, GL_FALSE);

    dlGenRenderbuffersEXT(1, &renderbuffer);
    dlBindRenderbufferEXT(GL_RENDERBUFFER, renderbuffer);
    dlRenderbufferStorageMultisampleEXT(GL_RENDERBUFFER, AA_LEVEL, GL_DEPTH_COMPONENT, SCREEN_W, SCREEN_H);

#if defined(USE_LD)
    dlGenFramebuffersEXT(1, &g_fbo);
#else
    dlGenFramebuffersEXT(1, &useless);
#endif
    dlBindFramebufferEXT(GL_FRAMEBUFFER_EXT, g_fbo);
    dlFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D_MULTISAMPLE,
        g_fbo_texture, 0);
    dlFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, renderbuffer);

#if defined(USE_LD)
    dlGenTextures(1, &g_volume_texture);
#else
    dlGenTextures(1, &useless);
#endif
    dlBindTexture(GL_TEXTURE_3D, g_volume_texture);
#if defined(USE_LD)
    dlTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    dlTexImage3D(GL_TEXTURE_3D, 0, GL_RGB8_SNORM, VOLUME_SIDE, VOLUME_SIDE, VOLUME_SIDE, 0, GL_RGB, GL_BYTE,
        g_volume);
    dlGenerateMipmap(GL_TEXTURE_3D);
#else
    dluBuild3DMipmaps(GL_TEXTURE_3D, GL_RGB8_SNORM, VOLUME_SIDE, VOLUME_SIDE, VOLUME_SIDE, GL_RGB, GL_BYTE,
        g_volume);
#endif

#if defined(USE_LD)
    printf("FBO: %u ; %u\nVolume: %u\n", g_fbo, g_fbo_texture, g_volume_texture);
#endif
  }

  // Audio precalc is visual.
  {
    dlDisable(GL_CULL_FACE);

    dlUseProgram(g_program_audio);
    dlBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    {
      int ii = 0;

      while(ii < INTRO_LENGTH)
      {
        g_uniform_array[0] = (float)ii;
#if defined(USE_LD)
        g_uniform_array[1] = (float)screen_w;
#endif
        dlUniform3fv(g_uniform_audio_l, 3, g_uniform_array);
        dlRectf(-1.0f, -1.0f, 1.0f, 1.0f);
        dlReadPixels(0, 0, screen_w, screen_h, GL_RED, GL_UNSIGNED_BYTE, g_audio_buffer + ii);
        DDL_GL_SwapBuffers();
        ii += screen_w * screen_h;
      }
    }
  }

#if defined(USE_LD)
  if(flag_record)
  {
    SDL_Event event;
    unsigned frame_idx = 0;

    // audio
    DDL_PauseAudio(1);

    write_audio_callback(g_audio_buffer, (unsigned)(INTRO_LENGTH * sizeof(uint8_t) * 2));

    // video
    for(;;)
    {
      unsigned ticks = (unsigned)((double)frame_idx / 60.0 * 44100.0);

      if(ticks > INTRO_LENGTH)
      {
        break;
      }

      if(DDL_PollEvent(&event) && (event.type == SDL_KEYDOWN) && (event.key.keysym.sym == SDLK_ESCAPE))
      {
        break;
      }

      draw(ticks, (float)screen_w / (float)screen_h);
      write_frame_callback(screen_w, screen_h, frame_idx);
      DDL_GL_SwapBuffers();
      ++frame_idx;
    }

    DDL_Quit();
    return 0;
  }

  if(!flag_developer)
  {
    DDL_OpenAudio(&audio_spec, NULL);
    DDL_PauseAudio(0);
  }
  g_flag_developer = flag_developer;
#else
  DDL_OpenAudio(&audio_spec, NULL);
  DDL_PauseAudio(0);
#endif

#if defined(USE_LD)
  starttick = SDL_GetTicks();	
#endif

  for(;;)
  {
    SDL_Event event;
    unsigned currtick;

#if defined(USE_LD)
    if(g_flag_developer)
    {
      currtick = 0;
    }
    else
    {
      currtick = (unsigned)(((float)(SDL_GetTicks() - starttick) / 1000.0f + (float)INTRO_START) * 88200.0f);
    }
#else
    currtick = (uint8_t*)g_audio_position - (uint8_t*)g_audio_buffer;
#endif

#if defined(USE_LD)
    {
      static double stored_position_x = 0.0;
      static double stored_position_y = 0.0;
      static double stored_position_z = 0.0;
      static double stored_fw_x = 0.0;
      static double stored_fw_y = 0.0;
      static double stored_fw_z = 0.0;
      static double stored_up_x = 0.0;
      static double stored_up_y = 0.0;
      static double stored_up_z = 0.0;
      static double move_speed = 0.128;
      static float staticity = 0.0f;
      static float time = 0.0f;
      static uint8_t mouse_look = 0;
      static int8_t move_backward = 0;
      static int8_t move_down = 0;
      static int8_t move_forward = 0;
      static int8_t move_left = 0;
      static int8_t move_right = 0;
      static int8_t move_up = 0;
      int mouse_look_x = 0;
      int mouse_look_y = 0;
      uint8_t quit = 0;

      while(DDL_PollEvent(&event))
      {
        if(SDL_QUIT == event.type)
        {
          quit = 1;
        }
        else if(SDL_KEYDOWN == event.type)
        {
          switch(event.key.keysym.sym)
          {
            case SDLK_1:
              g_effect = 0;
              break;

            case SDLK_2:
              g_effect = 1;
              break;

            case SDLK_3:
              g_effect = 2;
              break;

            case SDLK_a:
              move_left = 1;
              break;

            case SDLK_d:
              move_right = 1;
              break;

            case SDLK_e:
              move_up = 1;
              break;

            case SDLK_q:
              move_down = 1;
              break;

            case SDLK_s:
              move_backward = 1;
              break;

            case SDLK_w:
              move_forward = 1;
              break;

            case SDLK_l:
              {
                double best_pos_diff = DBL_MAX;
                double best_fw_diff = DBL_MAX;
                double best_up_diff = DBL_MAX;
                unsigned best_pos = 0xFFFFFFFF;
                unsigned best_fw = 0xFFFFFFFF;
                unsigned best_up = 0xFFFFFFFF;
                unsigned ii;

                stored_position_x = g_position_x;
                stored_position_y = g_position_y;
                stored_position_z = g_position_z;
                stored_fw_x = g_fw_x;
                stored_fw_y = g_fw_y;
                stored_fw_z = g_fw_z;
                stored_up_x = g_up_x;
                stored_up_y = g_up_y;
                stored_up_z = g_up_z;

                for(ii = 0; (ii < 256); ++ii)
                {
                  double pos_diff;
                  double px;
                  double py;
                  double pz;

                  dsrand(ii);

                  px = frand(DIRECTION_SCOPE) - stored_position_x;
                  py = frand(DIRECTION_SCOPE) - stored_position_y;
                  pz = frand(DIRECTION_SCOPE) - stored_position_z;

                  pos_diff = sqrt(px * px + py * py + pz * pz);

                  if((0xFFFFFFFF == best_pos) || (pos_diff < best_pos_diff))
                  {
                    best_pos_diff = pos_diff;
                    best_pos = ii;
                  }
                }

                for(ii = 0; (ii < 256); ++ii)
                {
                  double fw_diff;
                  double up_diff;
                  double px;
                  double py;
                  double pz;
                  double dx;
                  double dy;
                  double dz;
                  double ux;
                  double uy;
                  double uz;
                  double len;

                  dsrand(best_pos);

                  px = frand(DIRECTION_SCOPE);
                  py = frand(DIRECTION_SCOPE);
                  pz = frand(DIRECTION_SCOPE);

                  dsrand(ii);

                  dx = frand(DIRECTION_SCOPE) - px;
                  dy = frand(DIRECTION_SCOPE) - py;
                  dz = frand(DIRECTION_SCOPE) - pz;

                  len = sqrt(dx * dx + dy * dy + dz * dz);
                  dx /= len;
                  dy /= len;
                  dz /= len;
                  dx -= stored_fw_x;
                  dy -= stored_fw_y;
                  dz -= stored_fw_z;

                  fw_diff = sqrt(dx * dx + dy * dy + dz * dz);

                  if((0xFFFFFFFF == best_fw) || (fw_diff < best_fw_diff))
                  {
                    best_fw_diff = fw_diff;
                    best_fw = ii;
                  }

                  dsrand(ii);

                  ux = frand(DIRECTION_SCOPE);
                  uy = frand(DIRECTION_SCOPE);
                  uz = frand(DIRECTION_SCOPE);

                  len = sqrt(ux * ux + uy * uy + uz * uz);
                  ux /= len;
                  uy /= len;
                  uz /= len;
                  ux -= stored_up_x;
                  uy -= stored_up_y;
                  uz -= stored_up_z;

                  up_diff = sqrt(ux * ux + uy * uy + uz * uz);

                  if((0xFFFFFFFF == best_up) || (up_diff < best_up_diff))
                  {
                    best_up_diff = up_diff;
                    best_up = ii;
                  }
                }

                dsrand(best_pos);

                g_position_x = frand(DIRECTION_SCOPE);
                g_position_y = frand(DIRECTION_SCOPE);
                g_position_z = frand(DIRECTION_SCOPE);

                dsrand(best_fw);

                g_fw_x = frand(DIRECTION_SCOPE) - g_position_x;
                g_fw_y = frand(DIRECTION_SCOPE) - g_position_y;
                g_fw_z = frand(DIRECTION_SCOPE) - g_position_z;

                dsrand(best_up);

                g_up_x = frand(DIRECTION_SCOPE);
                g_up_y = frand(DIRECTION_SCOPE);
                g_up_z = frand(DIRECTION_SCOPE);

                printf("[%1.1f, %1.1f, %1.1f]\n[%1.1f, %1.1f, %1.1f]\n[%1.1f, %1.1f, %1.1f]\npos: %u || fw: %u || up: %u\n", g_position_x, g_position_y, g_position_z, g_fw_x, g_fw_y, g_fw_z, g_up_x, g_up_y, g_up_z, best_pos, best_fw, best_up);
              }
              break;

            case SDLK_LSHIFT:
            case SDLK_RSHIFT:
              move_speed = 1.0;
              break;            

            case SDLK_LCTRL:
              staticity = -0.01f;
              break;

            case SDLK_RCTRL:
              staticity = 0.01f;
              break;

            case SDLK_LALT:
              time = -88200 / 60.0f;
              break;

            case SDLK_MODE:
            case SDLK_RALT:
              time = 88200 / 60.0f;
              break;

            case SDLK_ESCAPE:
              quit = 1;
              break;

            default:
              break;
          }
        }
        else if(SDL_KEYUP == event.type)
        {
          switch(event.key.keysym.sym)
          {
            case SDLK_a:
              move_left = 0;
              break;

            case SDLK_d:
              move_right = 0;
              break;

            case SDLK_e:
              move_up = 0;
              break;

            case SDLK_q:
              move_down = 0;
              break;

            case SDLK_s:
              move_backward = 0;
              break;

            case SDLK_w:
              move_forward = 0;
              break;

            case SDLK_l:
              g_position_x = stored_position_x;
              g_position_y = stored_position_y;
              g_position_z = stored_position_z;
              g_fw_x = stored_fw_x;
              g_fw_y = stored_fw_y;
              g_fw_z = stored_fw_z;
              g_up_x = stored_up_x;
              g_up_y = stored_up_y;
              g_up_z = stored_up_z;
              break;

            case SDLK_LSHIFT:
            case SDLK_RSHIFT:
              move_speed = 0.128;
              break;            

            case SDLK_LCTRL:
            case SDLK_RCTRL:
              staticity = 0.0f;
              break;

            case SDLK_MODE:
            case SDLK_LALT:
            case SDLK_RALT:
              time = 0.0f;
              break;

            default:
              break;
          }
        }
        else if(SDL_MOUSEBUTTONDOWN == event.type)
        {
          if(1 == event.button.button)
          {
            mouse_look = 1;
          }
        }
        else if(SDL_MOUSEBUTTONUP == event.type)
        {
          if(1 == event.button.button)
          {
            mouse_look = 0;
          }
        }
        else if(SDL_MOUSEMOTION == event.type)
        {
          if(0 != mouse_look)
          {
            mouse_look_x += event.motion.xrel;
            mouse_look_y += event.motion.yrel;
          }
        }
      }

      if(g_flag_developer)
      {
        double uplen = sqrt(g_up_x * g_up_x + g_up_y * g_up_y + g_up_z * g_up_z);
        double fwlen = sqrt(g_fw_x * g_fw_x + g_fw_y * g_fw_y + g_fw_z * g_fw_z);
        double rt_x;
        double rt_y;
        double rt_z;
        double movement_rt = (double)(move_right - move_left) * move_speed;
        double movement_up = (double)(move_up - move_down) * move_speed;
        double movement_fw = (double)(move_forward - move_backward) * move_speed;

        g_up_x /= uplen;
        g_up_y /= uplen;
        g_up_z /= uplen;

        g_fw_x /= fwlen;
        g_fw_y /= fwlen;
        g_fw_z /= fwlen;

        rt_x = g_fw_y * g_up_z - g_fw_z * g_up_y;
        rt_y = g_fw_z * g_up_x - g_fw_x * g_up_z;
        rt_z = g_fw_x * g_up_y - g_fw_y * g_up_x;

        if(0 != mouse_look_x)
        {
          double angle = (double)mouse_look_x / (double)(screen_h / 4) * FOV / 180.0;
          double ca = cos(angle);
          double sa = sin(angle);
          double new_rt_x = ca * rt_x + sa * g_fw_x;
          double new_rt_y = ca * rt_y + sa * g_fw_y;
          double new_rt_z = ca * rt_z + sa * g_fw_z;
          double new_fw_x = ca * g_fw_x - sa * rt_x;
          double new_fw_y = ca * g_fw_y - sa * rt_y;
          double new_fw_z = ca * g_fw_z - sa * rt_z;

          rt_x = new_rt_x;          
          rt_y = new_rt_y;
          rt_z = new_rt_z;
          g_fw_x = new_fw_x;
          g_fw_y = new_fw_y;
          g_fw_z = new_fw_z;
        }
        if(0 != mouse_look_y)
        {
          double angle = (double)mouse_look_y / (double)(screen_h / 4) * FOV / 180.0;
          double ca = cos(angle);
          double sa = sin(angle);
          double new_fw_x = ca * g_fw_x + sa * g_up_x;
          double new_fw_y = ca * g_fw_y + sa * g_up_y;
          double new_fw_z = ca * g_fw_z + sa * g_up_z;
          double new_up_x = ca * g_up_x - sa * g_fw_x;
          double new_up_y = ca * g_up_y - sa * g_fw_y;
          double new_up_z = ca * g_up_z - sa * g_fw_z;

          g_fw_x = new_fw_x;
          g_fw_y = new_fw_y;
          g_fw_z = new_fw_z;
          g_up_x = new_up_x;
          g_up_y = new_up_y;
          g_up_z = new_up_z;
        }

        g_position_x += movement_rt * rt_x + movement_up * g_up_x + movement_fw * g_fw_x;
        g_position_y += movement_rt * rt_y + movement_up * g_up_y + movement_fw * g_fw_y;
        g_position_z += movement_rt * rt_z + movement_up * g_up_z + movement_fw * g_fw_z;

        g_uniform_array[0] += staticity;
        if(g_uniform_array[0] > 1.0f)
        {
          g_uniform_array[0] = 1.0f;
        }
        else if(g_uniform_array[0] < 0.0f)
        {
          g_uniform_array[0] = 0.0f;
        }
        g_uniform_array[1] += time;
        if(g_uniform_array[1] < 0.0)
        {
          g_uniform_array[1] = 0.0f;
        }
        currtick = (unsigned)g_uniform_array[1];
      }

      if(0 != quit)
      {
        break;
      }
    }
    if(currtick >= INTRO_LENGTH)
    {
      break;
    }
#else
    if((currtick >= INTRO_LENGTH) || (DDL_PollEvent(&event) && (event.type == SDL_KEYDOWN)))
    {
      break;
    }
#endif

    draw(currtick, (float)screen_w / (float)screen_h);
    DDL_GL_SwapBuffers();
  }

  DDL_Quit();
#if defined(USE_LD)
  return 0;
#elif defined(__x86_64)
  asm("xor %edi,%edi\nmovq $1,%rax\nsyscall");
#elif defined(__i386)
  asm("xor %ebx,%ebx\nmovl $1,%eax\nint $128");
#else
#error "no assembler exit procedure for current architecture"
#endif
}

//######################################
// End #################################
//######################################

