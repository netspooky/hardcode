BLOW_DEFINE_GLOBAL(final String[],txts,`{
/* * * * * * * * * * * * */
"    This was supposed    ",
"   to be an 4k invitro   ",
/* * * * * * * * * * * * */
"    for our demoparty    ",
"         H Y P E         ",
/* * * * * * * * * * * * */
"                         ",
"                         ",
/* * * * * * * * * * * * */
" But i guess it ended up ",
"  beeing an experiment   ",
/* * * * * * * * * * * * */
"   with using m4 as an   ",
"  preprocessor for java  ",
/* * * * * * * * * * * * */
"                         ",
"                         ",
/* * * * * * * * * * * * */
"   All code written at   ",
"    M A I N F R A M E    ",
/* * * * * * * * * * * * */
"           by            ",
"          blow           ",
/* * * * * * * * * * * * */
"   Most time was spent   ",
"     on learning m4      ",
/* * * * * * * * * * * * */
"      No time to do      ",
"         cool FX         ",
/* * * * * * * * * * * * */
"  Check the source-code  ",
" for my macros and stuff ",
/* * * * * * * * * * * * */
"Will implement obfuscator",
"     in next version     ",
/* * * * * * * * * * * * */
"     m4 is addictive     ",
"                         ",
/* * * * * * * * * * * * */
"                         ",
"                         ",
/* * * * * * * * * * * * */
"        Text will        ",
"          loop           ",
/* * * * * * * * * * * * */
"                         ",
"                         "
/* * * * * * * * * * * * */
}')

BLOW_ADD_POSTPAINT(`
define(xpos,40)
define(xpos2,40)
define(ypos,320)
define(ypos2,340)

if((fcnt%24)==0){
	g.setFont(new Font("Monospaced",Font.BOLD,18));
	g.setColor(Color.black);
	g.fillRect(0,300,400,100);
	g.setColor(Color.white);
	g.drawString(txts[((int)(fcnt/24)&0xf)*2],xpos,ypos);
	g.drawString(txts[((int)(fcnt/24)&0xf)*2+1],xpos2,ypos2);
}
')
