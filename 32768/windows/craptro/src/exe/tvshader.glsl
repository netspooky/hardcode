uniform vec2 resolution;
uniform sampler2D Image;
uniform vec4 time;

varying vec4 vPos;

vec4 rgbdistort(vec2 tc, sampler2D tex)
{
   float chroma = 4;
   float shift = chroma / 512;

   chroma = 9;
   shift = chroma / 256;
  
   float red = texture2D(tex, tc+shift).r;
   float green = texture2D(tex,tc).g;
   float blue = texture2D(tex,tc-shift).b;
 
   return vec4(red,green ,blue , 1.0);
}

float scanline(float ypos)
{

	float c = mod(float(time * 3.0 + ypos * 5.0), 15.0);	
	return 1.0 - smoothstep(0.0, 1.0, c);
}

float seed_random (vec2 coords, float frame_cnt)
{
   frame_cnt = cos(frame_cnt);
   vec2 constant1 = frame_cnt * vec2(142.0/11.0, 1017.0/13.0);
   float constant2 = frame_cnt * 481344.0 / 11.0;
   return clamp(fract(sin(dot(coords, constant1)) * constant2) + 0.2,0.0,1.0);
}

void main(void)
{
   float frameLimit = 0.16;
   float frameShape = 0.44;
   float frameSharpness = 4.80;
   float interference = 0.43;
   float radius=2.0/float(resolution.x);
   vec2 p=gl_TexCoord[0].xy;
   const float base_brightness = 0.95;
   float f = (1.0 - vPos.x * vPos.x) * (1.0 - vPos.y * vPos.y);
   float frame = clamp(frameSharpness * (pow(f, frameShape) - frameLimit), 0.0, 1.0);
   
   
   vec4 image = texture2D(Image, p);
   image = (image - 16.0/255.0) * (255.0/219.0);
   float rand = seed_random(p, time.x);
   if (time.z == 1.0)
   {
   rand = seed_random(p, time.x);
   image *=rand*2;
   }
   float  luminance = dot(image.rgb, vec3(0.299, 0.587, 0.114));
  // float luminance = (image.r + image.g + image.b)/3.0;
   image.rgb = vec3(luminance,luminance,luminance);
   vec4 distortion = rgbdistort(p,Image);
   distortion.rgb += scanline(-p.y);
   gl_FragColor = frame * (interference *distortion*rand+ image);
   }