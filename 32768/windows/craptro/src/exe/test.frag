uniform vec2 resolution;
uniform sampler2D Image;
varying vec4 vPos;

void main(void)
{
	vec2 p=gl_TexCoord[0].xy;
	vec4 image = texture2D(Image,p);
    gl_FragColor =  image;
 }