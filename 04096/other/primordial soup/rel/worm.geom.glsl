layout(lines_adjacency) in;
layout(triangle_strip, max_vertices = 102) out;

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
} iarray[4];

out D
{
  vec2 aa;
  vec4 qq;
  float ss;
  flat int ww;
} oarray;

vec3 bezier(vec3 aa, vec3 bb, vec3 cc, vec3 dd, float interpolation)
{
  vec3 ff = mix(bb, cc, interpolation);
  return mix(mix(mix(aa, bb, interpolation), ff, interpolation), mix(ff, mix(cc, dd, interpolation), interpolation), interpolation);
}

void main()
{
  vec3 p1 = iarray[1].pp;
  vec3 p2 = iarray[2].pp;
  vec3 bb = normalize(p2 - iarray[0].pp) * length(p2 - p1) + p1;
  vec3 cc = normalize(p1 - iarray[3].pp) * length(p1 - p2) + p2;

  for(float interpolation = 0; interpolation <= 1; interpolation += 0.02)
  {
    // Used below verbatim.
    //vec3 direction = normalize(bezier(p1, bb, cc, p2, interpolation + 0.1) - bezier(p1, bb, cc, p2, interpolation - 0.1));

    vec3 ee = bezier(p1, bb, cc, p2, interpolation);
    vec3 right = normalize(cross(normalize(bezier(p1, bb, cc, p2, interpolation + 0.01) - bezier(p1, bb, cc, p2, interpolation - 0.01)), normalize(iarray[1].cc - ee))) * iarray[1].qq.x;
    oarray.ss = mix(iarray[1].ss, iarray[2].ss, interpolation);
    oarray.ww = 2;

    oarray.aa = vec2(-1, interpolation + iarray[0].ww);
    gl_Position = iarray[1].mm * vec4(ee - right, 1);
    EmitVertex();
    
    oarray.aa = vec2(1, interpolation + iarray[0].ww);
    gl_Position = iarray[1].mm * vec4(ee + right, 1);
    EmitVertex();
  }

  // No need to end primitive if using all vertices.
#if defined(USE_LD)
  EndPrimitive();
#endif
}
