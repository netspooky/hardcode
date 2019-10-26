#!/usr/bin/env python

import re

def convertShader(name, in_filename, out_filename):
    shader_in = open(in_filename, "r")
    shader_out = open(out_filename, "w");
    shader_out.write("const char *%s = " % (name))
    for line in shader_in:
        line = re.sub("//.*", "", line).strip()
        line = re.sub("\"", "\\\"", line).strip()
        if len(line) > 0:
            shader_out.write("\"%s\\n\"" % (line))
            shader_out.write("\n")
    shader_out.write(";\n")
    shader_in.close()
    shader_out.close()

# main
convertShader("vertexShader", "demo.vsh", "demo.vsh.h")
convertShader("fragmentShader", "demo.fsh", "demo.fsh.h")
