\nasm\nasm cc.asm -fbin -l ccpal_e.lst -o ccpal_e.com
\nasm\nasm cc.asm -fbin -l ccpal.lst -o ccpal.com -DRELEASE
\nasm\nasm cc.asm -fbin -l cccc.lst -o cccc.com -DRELEASE -DNOPAL
\nasm\nasm cc.asm -fbin -l cccc_e.lst -o cccc_e.com -DNOPAL
\nasm\nasm cc.asm -fbin -l ccmono.lst -o ccmono.com -DNOPAL -DMONO -DRELEASE
\nasm\nasm cc.asm -fbin -l ccmono_e.lst -o ccmono_e.com -DNOPAL -DMONO
dir cc*.com
bfi -f=..\cc.img .