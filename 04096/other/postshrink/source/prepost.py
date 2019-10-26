#!/usr/bin/env python
import sys,os,re,types,string
from compost import Compile
from outpost import Optimize

if __name__=="__main__":
    if not len(sys.argv) in (2,3):
        print "Usage:",sys.argv[0],"<source.pp> [<dest.ps>]"
        sys.exit(1)

    source=sys.argv[1]
    if len(sys.argv)>2:
        dest=sys.argv[2]
    else:
        dest=os.path.splitext(source)[0]+".ps"

    data=Compile(source)
    data=Optimize(data)

    try:
        file(dest,"w").write(data)
    except IOError:
        Error("output","cannot write output file `%s'"%dest)
