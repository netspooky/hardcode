#ifndef UTILS_S
#define UTILS_S

vec3 Hue( float hue )
{
	vec3 rgb = fract(hue + vec3(0.0,2.0/3.0,1.0/3.0));

	rgb = abs(rgb*2.0-1.0);
		
	return clamp(rgb*3.0-1.0,0.0,1.0);
}

vec3 HSVtoRGB3( vec3 hsv )
{
	return ((Hue(hsv.x)-1.0)*hsv.y+1.0) * hsv.z;
}

vec3 HSVtoRGB(float h, float s, float v)
{
	return HSVtoRGB3(vec3(h, s, v));
}

//関数オーバーロードにshader minifierが対応してない.
float lengthN3D(vec3 v, float n)
{
	vec3 tmp = pow(abs(v), vec3(n));
	return pow(tmp.x+tmp.y+tmp.z, 1.0/n);
}

float lengthN2D(vec2 v, float n)
{
	vec2 tmp = pow(abs(v), vec2(n));
	return pow(tmp.x+tmp.y, 1.0/n);
}

#endif
