ml /AT /Cp /c /nologo demo.asm
dlink /nologo /tiny demo.obj,demo.com,,,,
256to64 demo.com >demo.asc

ml /AT /Cp /c /nologo loader.asm
dlink /nologo /tiny loader.obj,loader.com,,,,
