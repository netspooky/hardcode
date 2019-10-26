layout(points) in;
layout(triangle_strip, max_vertices = 42) out;

in D
{
  vec3 aa;
  vec3 bb;
  vec3 cc;
  vec3 pp;
  vec4 qq;
  float ss;
  float ww;
  mat4 mm;
} iarray[1];

out D
{
  vec2 aa;
  vec4 qq;
  float ss;
  flat int ww;
} oarray;

void main()
{
  float rotation = iarray[0].qq.w * 0.0001 + iarray[0].ww * sin(iarray[0].qq.w) * uniform_array[5].x * 0.00000000006;
  vec3 right = (cos(rotation) * iarray[0].aa + sin(rotation) * iarray[0].bb) * iarray[0].qq.x;
  vec3 up = (cos(rotation) * iarray[0].bb - sin(rotation) * iarray[0].aa) * iarray[0].qq.y;
  
  oarray.qq = iarray[0].qq;
  oarray.ss = iarray[0].ss;
  oarray.ww = int(iarray[0].ww);
  
  for(float advance = -1; advance <= 1; advance += 0.1) // advance = -1 => 1 in 21 steps
  {
    float nudge = cos(advance * 1.5) * iarray[0].ww * 0.0001;
    float aspect = iarray[0].qq.y / iarray[0].qq.x;
    
    oarray.aa = vec2(-1, advance * aspect);
    gl_Position = iarray[0].mm * vec4(iarray[0].pp + right * (oarray.aa.x + nudge) + up * advance, 1);
    EmitVertex();

    oarray.aa = vec2(1, advance * aspect);
    gl_Position = iarray[0].mm * vec4(iarray[0].pp + right * (oarray.aa.x + nudge) + up * advance, 1);
    EmitVertex();
  }

  // No need to end primitive if using all vertices.
#if defined(USE_LD)
  EndPrimitive();
#endif
}
