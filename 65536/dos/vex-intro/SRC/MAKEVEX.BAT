@rem this batch converts the files needed for vex
@rem the font:  hooks.tga to hooks.fnt
convfont
@rem the crossfade pic:  pdpres.tga + asscont.tga to pdpres.scr
mergepic
@rem the scenery: vexintro.scn + *.dat to vexintro.3ds
makescn vexintro.scn 
