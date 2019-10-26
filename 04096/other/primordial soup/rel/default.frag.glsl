out vec4 output_color;

in D
{
  vec2 aa;
  vec4 qq;
  float ss;
  flat int ww;
} iarray;

void main()
{
  float radius = length(iarray.aa), magnitude;
  vec2 cumulative = vec2(0);
  vec2 pulse = iarray.aa * sin(uniform_array[5].z * 0.00002);
  vec2 complex_z;
  vec2 complex_w;

  if(iarray.ww == 0) // Kidney (0)
  {
    complex_z = iarray.aa * 2.07 + iarray.aa * sin(uniform_array[5].z * 0.00002) * 0.01 + vec2(0.4, 0);
    complex_w = vec2(-0.45, -1.56) + iarray.qq.zw * 0.000001 + pulse * 0.006;

    for(int ii = 0; ii < 55; ++ii)
    {
      complex_z = ilog(iabs(complex_z) + complex_w);
      cumulative += complex_z;
    }

    magnitude = abs(cumulative.y) * 0.01 * (1 - radius) - abs(cumulative.x) * 0.05 * radius;

    if(magnitude < radius * radius - 1)
    {
      discard;
    }

    output_color = vec4(mix(vec3(0.1, 0.2, 0.1), vec3(2.0, 0.9, 0.2), magnitude) + mix(vec3(0, 0.1, 0), vec3(0.6, 0, 0), radius), 1);
  }
  else if(iarray.ww == 1) // Mote (1)
  {
    if(calculate_noise(iarray.qq.xyz * 0.02 + vec3(iarray.aa.x, radius, iarray.aa.y) * 0.1) < radius)
    {
      discard;
    }
    
    output_color = vec4(0.1, 0.1, 0.11, 1);
  }
  else if(iarray.ww == 2) // Worm (2)
  {
    // Constant before subtranct must be as small as possible to not cause artifacts.
    complex_z = iarray.aa * vec2(1, 0.1) - vec2(0, 1.4 - uniform_array[5].x * 0.00000005);

    if(length(complex_z) > 1.0)
    {
      discard;
    }

    complex_z = complex_z.yx * vec2(-2, 0.02) + vec2(0, -1.22);
    complex_w = vec2(-0.06, -1.22) + iarray.qq.zw * 0.0000001;

    for(int ii = 0; ii < 55; ++ii)
    {
      complex_z = ilog(iabs(complex_z) + complex_w);
      cumulative += complex_z;
    }

    radius = 1 - iarray.aa.x * iarray.aa.x;
    output_color = vec4(mix(vec3(0), vec3(0.8, 0.4, 0.2), radius) * (abs(cumulative.y) * 0.1 + complex_z.y + complex_z.x) * 0.2 + mix(vec3(0), vec3(0.22, 0, 0), radius * complex_z.y/* * cumulative.x * complex_z.x*/), 1);
  }
  else // Plant
  {
    radius = length(iarray.aa * vec2(1, 0.2));
    complex_z = iarray.aa * 0.8 + vec2(0.2, 0);
    complex_w = vec2(0.67, -0.22) + iarray.qq.zw * 0.0000001;

    for(int ii = 0; ii < 55; ++ii)
    {
      complex_z = ilog(iabs(complex_z) + complex_w);
      cumulative += complex_z;
    }

    magnitude = sqrt(max(min(1 - cumulative.x, 2), 1.5));

    if(1.0 < radius * magnitude)
    {
      discard;
    }

    output_color = vec4(vec3((1 - cumulative.x) * 0.1) + mix(vec3(0, 0.8, 0.2), vec3(0.1, 0.4, 0.8), length(cumulative) * 0.05) * (1 - radius), 1);
  }

  output_color *= iarray.ss;
}
