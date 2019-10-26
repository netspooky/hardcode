#!/usr/bin/env python

import os
import shutil
import subprocess
import sys

verbose = False

html_template = """<html>
<script type='text/javascript'>
function js_main()
{
%s
}
</script>
<body onload='js_main();'></body>
</html>"""

usage = """%s [option] <source>
Takes javascript source, runs it through compiler and Charles Boccato's jsexe
to generate minified output.\n
Command line options without arguments:
  -C, --no-compile        Do not compile, assume compilation already done.
  -h, --help              Print this help text.
  -N, --no-compressed     Do not compress, just write the uncompressed HTML.
  -U, --no-uncompressed   Do not write uncompressed HTML.
  -v, --verbose           Verbose output.\n
Command line options with arguments:
  -c, --closure     Specity path to closure compiler.
                    (default: '%s')
  -j, --jsexe       Specify path to jsexe.exe.
                    (default: '%s')
  -p, --pnginator   Specify path to pnginator.
                    (default: '%s')"""

def execute_command(cmd):
  """Run a command."""
  if verbose:
    print("executing command: '%s'" % (str(" ".join(cmd))))
  try:
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (so, se) = proc.communicate()
    return proc.returncode
  except OSError as ee:
    print("ERROR: failed to execute binary: '%s'" % (cmd[0]))
    raise ee

def run_closure(binary, infile, outfile):
  """Execute closure compiler."""
  cmd = ["java", "-jar", binary, "--compilation_level", "ADVANCED_OPTIMIZATIONS", "--js", infile, "--js_output_file", outfile]
  ret = execute_command(cmd)
  if 0 != ret:
    print("closure compiler command failed: %i" % (ret))
    sys.exit(1)
  if verbose:
    print("wrote compiled source: '%s'" % (outfile))

def run_jsexe(binary, infile, outfile):
  """Execute jsexe binary."""
  cmd = [binary, "-cn", infile, outfile]
  ret = execute_command(cmd)
  if 0 != ret:
    print("jsexe command failed: %i" % (ret))
    sys.exit(1)
  if verbose:
    print("wrote compressed binary: '%s'" % (outfile))

def run_pnginator(binary, infile, outfile):
  """Execute pnginator script."""
  cmd = ["ruby", binary, infile, outfile]
  ret = execute_command(cmd)
  if 0 != ret:
    print("pnginator command failed: %i" % (ret))
    sys.exit(1)
  if verbose:
    print("wrote compressed binary: '%s'" % (outfile))

def write_html_outlier(infile, outfile):
  """Write uncompressed output file."""
  infd = open(infile, "r")
  outfd = open(outfile, "w")
  outfd.write(html_template % (str(infd.read())))
  if verbose:
    print("wrote uncompressed html: '%s'" % (outfile))

if __name__ == "__main__":
  if "posix" == os.name:
    closure = "/usr/local/src/closure_compiler/compiler.jar"
    pnginator = "/usr/local/src/pnginator/pnginator.rb"
  else:
    closure = "c:\local\closure_compiler\compiler.jar"
    pnginator = "c:\local\pnginator\pnginator.rb"
  input_file = None
  jsexe = "c:\local\jsexe\jsexe.exe"
  perform_compile = True
  write_compressed = True
  write_uncompressed = True

  ii = 1
  while len(sys.argv) > ii:
    jj = sys.argv[ii]
    if jj in ("-c", "--help"):
      ii += 1
      closure = sys.argv[ii]
    elif jj in ("-C", "--no-compile"):
      perform_compile = False
    elif jj in ("-h", "--help"):
      print(usage % (os.path.basename(__file__), closure, jsexe))
      sys.exit(0)
    elif jj in ("-n", "--no-compressed"):
      write_compressed = False
    elif jj in ("-j", "--jsexe"):
      ii += 1
      jsexe = sys.argv[ii]
    elif jj in ("-U", "--no-uncompressed"):
      write_uncompressed = False
    elif jj in ("-v", "--verbose"):
      verbose = True
    else:
      if input_file:
        print("error: only one input file accepted")
        sys.exit(1)
      else:
        input_file = jj
    ii += 1

  if verbose:
      print("using input file: '%s'" % (input_file))

  closure_input = input_file
  (input_path, input_base) = os.path.split(input_file)
  (input_base, input_extension) = os.path.splitext(input_base)
  uncompressed_output = input_base + "_uncompressed.html"
  closure_output = input_base + "_compiled" + input_extension
  compressed_output = input_base + ".png.html"
  if input_path:
    closure_output = os.path.normpath(input_path + '/' + closure_output)
    compressed_output = os.path.normpath(input_path + '/' + compressed_output)

  if write_uncompressed:
    write_html_outlier(input_file, uncompressed_output)

  if write_compressed:
    if perform_compile:
      if os.path.isfile(closure):
        if verbose:
          print("using closure compiler: '%s'" % (closure))
        run_closure(closure, input_file, closure_output)
      else:
        print("WARNING: closure compiler (tried: '%s') not found, going without" % (closure))
        shutil.copyfile(input_file, closure_output)
    if os.path.isfile(jsexe):
      if verbose:
        print("using jsexe binary: '%s'" % (jsexe))
      run_jsexe(jsexe, closure_output, compressed_output)
    elif os.path.isfile(pnginator):
      if verbose:
        print("using pnginator binary: '%s'" % (pnginator))
      run_pnginator(pnginator, closure_output, compressed_output)
    else:
      print("ERROR: no compressor found for output binary")
      sys.exit(1)
    if verbose:
      print("final size: %i bytes" % (os.stat(compressed_output).st_size))

  sys.exit(0)
