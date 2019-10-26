shader_minifier -o smtemp.h --preserve-externals logo_blur_vs.glsl logo_blur_fs.glsl logo_vs.glsl logo_fs.glsl

sed smtemp.h -e "s/char /char */g;" | sed -e "s/\[\] =/ =/g;" > shader_code.h

