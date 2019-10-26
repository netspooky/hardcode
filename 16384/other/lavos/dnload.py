#!/usr/bin/env python
"""Script to read C/C++ source input and generate proper dynamic linker stub."""

import os
import re
import subprocess
import sys

compiler_command = None
default_compiler_list = ["gcc", "clang", "cl.exe"]
definitions = ["DNLOAD_H"]
definition_fullscreen = "fullscreen"
definition_height = "height"
definition_ld = "USE_LD"
definition_width = "width"
header_file = "dnload.h"
include_directories = ["/usr/include/SDL", "/usr/local/include", "/usr/local/include/SDL"]
source_files = []
symbol_table = "g_sym"
symbols = set(["SDL_Init", "SDL_SetVideoMode"])
target = None
target_search_path = []
verbose = False

function_definitions = (
    ("int", ("rand", "bsd_rand")),
    ("void", ("srand", "bsd_srand"), "unsigned int"),
    ("double", "acos", "double"),
    ("float", "acosf", "float"),
    ("void", "glActiveTexture", "GLenum"),
    ("void", "glAttachShader", "GLuint", "GLuint"),
    ("void", "glBindFramebuffer", "GLenum", "GLuint"),
    ("void", "glBindTexture", "GLenum", "GLuint"),
    ("void", "glClear", "GLbitfield"),
    ("void", "glClearColor", "GLclampf", "GLclampf", "GLclampf", "GLclampf"),
    ("void", "glCompileShader", "GLuint"),
    ("GLuint", "glCreateProgram"),
    ("GLuint", "glCreateShader", "GLenum"),
    ("void", "glDisable", "GLenum"),
    ("void", "glDisableVertexAttribArray", "GLuint"),
    ("void", "glDrawArrays", "GLenum", "GLint", "GLsizei"),
    ("void", "glEnable", "GLenum"),
    ("void", "glEnableVertexAttribArray", "GLuint"),
    ("void", "glFramebufferTexture2D", "GLenum", "GLenum", "GLenum", "GLuint", "GLint"),
    ("void", "glGenerateMipmap", "GLenum"),
    ("void", "glGenFramebuffers", "GLsizei", "GLuint*"),
    ("void", "glGenTextures", "GLsizei", "GLuint*"),
    ("GLint", "glGetAttribLocation", "GLuint", "const GLchar*"),
    ("GLint", "glGetUniformLocation", "GLuint", "const GLchar*"),
    ("void", "glLineWidth", "GLfloat"),
    ("void", "glLinkProgram", "GLuint"),
    ("void", "glRectf", "GLfloat", "GLfloat", "GLfloat", "GLfloat"),
    ("void", "glRects", "GLshort", "GLshort", "GLshort", "GLshort"),
    ("void", "glShaderSource", "GLuint", "GLsizei", "const GLchar**", "const GLint*"),
    ("void", "glTexImage2D", "GLenum", "GLint", "GLint", "GLsizei", "GLsizei", "GLint", "GLenum", "GLenum", "const GLvoid*"),
    ("void", "glTexImage2DMultisample", "GLenum", "GLsizei", "GLint", "GLsizei", "GLsizei", "GLboolean"),
    ("void", "glTexImage3D", "GLenum", "GLint", "GLint", "GLsizei", "GLsizei", "GLsizei", "GLint", "GLenum", "GLenum", "const GLvoid*"),
    ("void", "glTexParameteri", "GLenum", "GLenum", "GLint"),
    ("void", "glUseProgram", "GLuint"),
    ("void", "glUniform1i", "GLint", "GLint"),
    ("void", "glUniform1f", "GLint", "GLfloat"),
    ("void", "glUniform2i", "GLint", "GLint", "GLint"),
    ("void", "glUniform3f", "GLint", "GLfloat", "GLfloat", "GLfloat"),
    ("void", "glUniform3i", "GLint", "GLint", "GLint", "GLint"),
    ("void", "glUniform4i", "GLint", "GLint", "GLint", "GLint", "GLint"),
    ("void", "glUniform1fv", "GLint", "GLsizei", "const GLfloat*"),
    ("void", "glUniform2fv", "GLint", "GLsizei", "const GLfloat*"),
    ("void", "glUniform3fv", "GLint", "GLsizei", "const GLfloat*"),
    ("void", "glUniform4fv", "GLint", "GLsizei", "const GLfloat*"),
    ("void", "glUniformMatrix3fv", "GLint", "GLsizei", "GLboolean", "const GLfloat*"),
    ("void", "glVertexAttribPointer", "GLuint", "GLint", "GLenum", "GLboolean", "GLsizei", "const GLvoid*"),
    ("void", "glViewport", "GLint", "GLint", "GLsizei", "GLsizei"),
    ("GLint", "gluBuild3DMipmaps", "GLenum", "GLint", "GLsizei", "GLsizei", "GLsizei", "GLenum", "GLenum", "const void*"),
    ("float", "powf", "float", "float"),
    ("void", "SDL_GL_SwapBuffers"),
    ("int", "SDL_Init", "Uint32"),
    ("int", "SDL_OpenAudio", "SDL_AudioSpec*", "SDL_AudioSpec*"),
    ("void", "SDL_PauseAudio", "int"),
    ("int", "SDL_PollEvent", "SDL_Event*"),
    ("void", "SDL_Quit"),
    ("SDL_Surface*", "SDL_SetVideoMode", "int", "int", "int", "Uint32"),
    ("int", "SDL_ShowCursor", "int"),
    ("float", "tanhf", "float")
    )

string_help = """Usage: %s [args] [folder]\n
Searches for a dynamic loader header file (default: %s) starting from
<folder>. When found, searches source files looking for function calls made
through a so-called global symbol table.\n
All symbols found thus will have their definitions extracted from select header
files found from include directories. Then, the header file will be regenerated
with necessary code.\n
Command line options without arguments:
  -c, --call-table-name         Global symbol table name.
                                (default: %s).
  -d, --define                  Definition to use for checking whether to use
                                'safe' mechanism instead of dynamic loading.
                                (default: %s)
  -F, --fullscreen-definition   Definition containing fullscreen query.
                                (default: %s)
  -h, --help                    Print this help string.
  -H, --height-definition       Definition containing height.
                                (default: %s)
  -I, --include                 Add an include directory to be searched for
                                header files when preprocessing.
  -s, --source-file             Add a source file to be examined for calls made
                                through the global symbol table. If not
                                specified, all sources from the location of
                                target header will be examined.
  -t, --target                  Target header file to look for.
                                (default: %s)
  -v, --verbose                 Print more about what is being done.
  -W, --width-definition        Definition containing width.
                                (default: %s)
""" % (sys.argv[0], header_file, symbol_table, definition_ld,
    definition_fullscreen, definition_height, header_file, definition_width)

template_header_begin = """#ifndef DNLOAD_H
#define DNLOAD_H\n
/** \\file
 * \\brief Dynamic loader header stub.
 *
 * This file is automatically generated, do not modify.
 *
 * Include this file instead of the regular OpenGL et. al.
 */\n
#if !defined(%s)
#if defined(__FreeBSD__) || defined(__linux__)
#if defined(__i386)
#include \"dnload_elf32.h\"
#else
#error "no dynamic loading procedure defined for current architecture"
#endif
#else
#error "no dynamic loading procedure defined for current operating system"
#endif
#endif\n
#if defined(%s)
#if defined(WIN32)
#include \"windows.h\"
#include \"GL/glew.h\"
#include \"GL/glu.h\"
#include \"SDL.h\"
#elif defined(__APPLE__)
#include \"GL/glew.h\"
#include \"GL/glu.h\"
#include \"SDL/SDL.h\"
#else
#include \"GL/glew.h\"
#include \"GL/glu.h\"
#include \"SDL.h\"
#endif
#include \"bsd_rand.h\"
#else
/** \cond */
#define GL_GLEXT_PROTOTYPES
/** \endcond */
#include \"GL/gl.h\"
#include \"GL/glext.h\"
#include \"GL/glu.h\"
#include \"SDL.h\"
#include \"asm_exit.h\"
#endif\n
#if defined(GLEWAPIENTRY)
/** \cond */
#define DNLOADAPIENTRY GLEWAPIENTRY
/** \endcond */
#else
/** \cond */
#define DNLOADAPIENTRY
/** \endcond */
#endif\n
#if defined(WIN32)
/** \cond */
#define _USE_MATH_DEFINES
/** \endcond */
#endif\n
#include <math.h>\n
#if defined(__cplusplus)
extern "C" {
#endif
"""

template_header_end = """#if defined(__cplusplus)
}
#endif\n
#endif\n"""

template_loader = """/** \\brief Perform init.
 *
 * \\param screen_w Screen width definition.
 * \\param screen_h Screen height definition.
 * \\param flag_fullscreen Fullscreen flag definition.
 */
static void init(int screen_w, int screen_h, unsigned flag_fullscreen)
{
#if defined(%s)
  SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
  SDL_SetVideoMode(screen_w, screen_h, 0, SDL_OPENGL | (flag_fullscreen ? SDL_FULLSCREEN : 0));\n
  {
    GLenum err = glewInit();\n
    if(GLEW_OK != err)
    {
      SDL_Quit();
      fprintf(stderr, \"glewInit(): %%s\", glewGetErrorString(err));
      exit(1);
    }
  }\n
  %s
#else
  {
    void **iter = (void**)&%s;
    do {
      *iter = dnload_find_symbol(*(uint32_t*)iter);
      ++iter;
    } while(*iter);
  }\n
  %s.SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
  %s.SDL_SetVideoMode(screen_w, screen_h, 0, SDL_OPENGL | (flag_fullscreen ? SDL_FULLSCREEN : 0));
#endif
}
"""

template_symbol_table = """/** \\brief Symbol table structure.
 *
 * Contains all the symbols required for dynamic linking.
 */
struct SymbolTableStruct"""

template_symbol_table_instance = """/** Instance of the symbol table. */
static struct SymbolTableStruct"""

def analyze_source(command, fn, symbolre):
  """Analyze given source file for symbol names."""
  ret = set()
  run_command = command + [fn]
  if verbose:
    print("Preprocessing '%s': %s" % (fn, ' '.join(run_command)))
  run = subprocess.Popen(run_command, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
  (output, stderr) = run.communicate()
  returncode = run.returncode
  if (returncode != 0) and (returncode != 1):
    raise RuntimeError("preprocess of '%s' failed: %i" % (fn, returncode))
  results = symbolre.findall(str(output), re.MULTILINE)
  for ii in results:
    symbolset = set()
    symbolset.add(ii[1])
    ret = ret.union(symbolset)
  return ret

def check_compiler(op = []):
  """Check for existence of compilers, compilers within the list will be tried."""
  checked = []
  if isinstance(op, (list, tuple)):
    for ii in op:
      if not ii in checked:
        ret = check_compiler_sub(ii)
        if ret:
          return ret
        checked += [ii]
  elif isinstance(op, str):
    if not op in checked:
      ret = check_compiler_sub(op)
      if ret:
        return ret
      checked += [op]
  else:
    raise RuntimeError("weird argument given to compiler check: %s" % (str(op)))
  for ii in default_compiler_list:
    if not ii in checked:
      ret = check_compiler_sub(ii)
      if ret:
        return ret
      checked += [ii]
  return None

def check_compiler_sub(op):
  """Check for existence of a single compiler."""
  output_string = "Trying compiler '%s'..." % (op)
  if op == "cl.exe":
    command = ["cl.exe", "/E"] + generate_definition_list(["WIN32"] + definitions, "/D") + generate_include_list(include_directories, "/I")
  elif (op == "gcc") or (op == "clang"):
    command = [op, "-E"] + generate_definition_list(definitions, "-D") +generate_include_list(include_directories, "-I")
  else:
    raise RuntimeError("unknown compiler: %s" % (op))
  try:
    run = subprocess.Popen(command, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
  except OSError:
    if verbose:
      print(output_string + "not found.")
    return None
  if verbose:
    print(output_string + "found.")
  return command

def create_symbol_re():
  return re.compile(r"[\s;\(\*\+]" + symbol_table + "\s*(\.|->)\s*([^\s\(]+)")

def create_source_re():
  """Create the source filename matcher regular expression."""
  return re.compile(r".*(c|cpp)$")

def find_file(fn, path_list):
  """Search for given file from given paths downward."""
  for ii in path_list:
    ret = locate(ii, fn)
    if ret:
      return ret
  return None

def generate_definition_list(op, prefix):
  """Generate a definition listing."""
  ret = []
  if isinstance(op, (list, tuple)):
    for ii in op:
      ret += [prefix + ii]
  elif isinstance(op, str):
    ret += [prefix + op]
  else:
    raise RuntimeError("weird argument given to definition list generation: %s" % (str(op)))
  return ret

def generate_loader(symbol_table, symbols):
  """Generate the loader code."""
  return template_loader % (definition_ld, get_symbol_assignments(symbol_table, symbols), symbol_table, symbol_table, symbol_table)

def generate_include_list(lst, prefix):
  """Generate an include directory listing."""
  ret = []
  for ii in lst:
    if os.path.isdir(ii):
      ret += [prefix + ii]
  return ret

def generate_symbol_struct(symbol_table, symbols):
  """Generate the symbol struct definition."""
  ret = template_symbol_table + "\n{"
  hashes = []
  for ii in symbols:
    ret += "\n  %s;" % get_symbol_definition(ii)
    hashes += [get_symbol_prototype(ii) + sdbm_hash(ii)]
  hashes += ["NULL"]
  ret += "\n  void *terminator;\n};\n\n" + template_symbol_table_instance
  ret += " %s =\n{\n  %s\n};\n" % (symbol_table, ",\n  ".join(hashes))
  return ret

def get_symbol_assignments(symbol_table, symbols):
  ret = []
  for ii in symbols:
    for jj in function_definitions:
      name = jj[1]
      if isinstance(name, (list, tuple)):
        if name[0] == ii:
          ret += ["%s.%s = %s;" % (symbol_table, name[0], name[1])]
      elif name == ii:
        ret += ["%s.%s = %s;" % (symbol_table, ii, ii)]
  return "\n  ".join(ret)

def get_symbol_definition(symbol):
  for ii in function_definitions:
    name = ii[1]
    if isinstance(name, (list, tuple)):
      name = name[0]
    prefix = ""
    if name[:2] == "gl":
      prefix = "DNLOADAPIENTRY "
    if name == symbol:
      if 2 < len(ii):
        return "%s (%s*%s)(%s)" % (ii[0], prefix, name, ", ".join(ii[2:]))
      else:
        return "%s (%s*%s)(void)" % (ii[0], prefix, name)
  raise RuntimeError("no definition found for symbol '%s', please add it to the script" % (symbol))

def get_symbol_prototype(symbol):
  for ii in function_definitions:
    name = ii[1]
    if isinstance(name, (list, tuple)):
      name = name[0]
    if name == symbol:
      prefix = ""
      if name[:2] == "gl":
        prefix = "DNLOADAPIENTRY "
      if 2 < len(ii):
        return "(%s (%s*)(%s))" % (ii[0], prefix, ", ".join(ii[2:]))
      else:
        return "(%s (%s*)(void))" % (ii[0], prefix)
  raise RuntimeError("no prototype found for symbol '%s', please add it to the script" % (symbol))

def locate(pth, fn):
  """Search for given file from given path downward."""
  pthfn = pth + "/" + fn
  if os.path.isfile(pthfn):
    return os.path.normpath(pthfn)
  for ii in os.listdir(pth):
    iifn = pth + "/" + ii
    if os.path.isdir(iifn):
      ret = locate(iifn, fn)
      if ret:
        return ret
  return None

def sdbm_hash(name):
  """Calculate SDBM hash over a string."""
  ret = 0
  for ii in name:
    ret = ret * 65599 + ord(ii)
  return hex(int(ret & 0xFFFFFFFF))

if __name__ == "__main__":
  """Main function."""

  ii = 1
  while ii < len(sys.argv):
    arg = sys.argv[ii]
    if arg in ("-C", "--call-table-name"):
      ii += 1
      symbol_table = sys.argv[ii]
    elif arg in ("-d", "--define"):
      ii += 1
      definition_ld = sys.argv[ii]
    elif arg in ("-F", "--fullscreen-definition"):
      ii += 1
      definition_fullscreen = sys.argv[ii]
    elif arg in ("-h", "--help"):
      print(string_help)
      sys.exit(0)
    elif arg in ("-H", "--height-definition"):
      ii += 1
      definition_height = sys.argv[ii]
    elif arg in ("-I", "--include"):
      ii += 1
      include_directories += [sys.argv[ii]]
    elif arg in ("-s", "--source-file"):
      ii += 1
      source_files += [sys.argv[ii]]
    elif arg in ("-t", "--target"):
      ii += 1
      target = sys.argv[ii]
    elif arg in ("-v", "--verbose"):
      verbose = True
    elif arg in ("-W", "--width-definition"):
      ii += 1
      definition_width = sys.argv[ii]
    else:
      target_search_path += [sys.argv[ii]]
    ii += 1

  if 0 >= len(target_search_path):
    target_search_path = [ "." ]

  if target == None:
    target = header_file

  target_file = find_file(target, target_search_path)
  if target_file:
    target_path = os.path.dirname(target_file)
    target_file = os.path.basename(target_file)
    target = target_path + "/" + target_file
  else:
    raise RuntimeError("could not locate file '%s' from path(s): %s" % (target, str(target_search_path)))

  if verbose:
    print("Header file '%s' found in path '%s/'." % (target_file, target_path))

  if 0 >= len(source_files):
    potential_source_files = os.listdir(target_path)
    sourcere = create_source_re()
    for ii in potential_source_files:
      if sourcere.match(ii):
        source_files += [target_path + "/" + ii]
    if 0 >= len(source_files):
      raise RuntimeError("could not find any source files in '%s'" % (target_path))

  if not compiler_command:
    if os.name == "nt":
      compiler_command = check_compiler("cl.exe")
    elif os.name == "posix":
      compiler_command = check_compiler()
    else:
      compiler_command = check_compiler()
  if not compiler_command:
    raise RuntimeError("suitable compiler not found")

  symbolre = create_symbol_re()
  for ii in source_files:
    if verbose:
      print("Analyzing source file '%s'." % (ii))
    source_symbols = analyze_source(compiler_command, ii, symbolre)
    symbols = symbols.union(source_symbols)
  symbols = list(symbols)

  if verbose:
    print("Symbols found: %s" % (str(symbols)))

  file_contents = template_header_begin % (definition_ld, definition_ld) + "\n"
  file_contents += generate_symbol_struct(symbol_table, symbols) + "\n"
  file_contents += generate_loader(symbol_table, symbols) + "\n"
  file_contents += template_header_end

  fd = open(target, "w")
  fd.write(file_contents)
  fd.close()

  if verbose:
    print("'%s' written.""" % (target))

  sys.exit(0)
