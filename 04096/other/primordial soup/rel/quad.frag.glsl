layout(location=6) uniform sampler2D color_fbo;
layout(location=7) uniform sampler2D depth_fbo;

in vec2 position;

out vec4 output_color;

#if defined(FRACTAL_DEBUG)
layout(location=20)uniform vec3 F;
layout(location=21)uniform vec3 G;
#endif

void main()
{
#if defined(FRACTAL_DEBUG)
  vec2 z = (position - 0.5) * 2.0 * F.z * vec2(1.67, 1.0) + F.xy;
  vec2 w = z * G.z + G.xy;
  vec2 g = vec2(0.0);
  
  for(int i = 0; i < 55; ++i)
  {
    z=ilog(iabs(z)+w);
    g+=z;
  }

  output_color = vec4((abs(z.x) + abs(z.y)) * 0.1, abs(z.x) * 0.1, abs(z.y) * 0.1, 1.);
#else
  vec4 cumulative = vec4(0);

  // Original
  //float dof = (2 * i_plane_near) / (i_plane_far + i_plane_near - texture(depth_fbo, position, 2.1).r * (i_plane_far - i_plane_near));
  //dof = (calculate_dof() / i_plane_far - dof) * 2;
  // Simplified.
  //float dof = (calculated_dof / i_plane_far - (2 * i_plane_near) / (i_plane_far + i_plane_near - texture(depth_fbo, position, 2.1).r * (i_plane_far - i_plane_near))) * 2;
  // Destroyed.
  float dof = (calculated_dof / 8888 - 2 / (8888 + 1 - texture(depth_fbo, position, 2.1).r * (8888 - 1))) * 2;

  for(float ii = -3.142; ii < 3.142; ii += 0.629) // Loop from -PI to +PI in 10 steps.
  {
    cumulative += texture(color_fbo, position + vec2(cos(ii), sin(ii)) * dof * 0.008, dof * dof) * 0.1;
    //vec2 offset = vec2(cos(ii), sin(ii)) * dof * 0.008;
    //cumulative += texture(color_fbo, position + offset, dof * dof) * 0.1;
  }

  // Lookat components.
  vec2 npos = position * 2 - 1;
  vec3 forward = normalize(uniform_array[2]);
  vec3 right = normalize(cross(forward, normalize(uniform_array[3])));
  //vec3 up = normalize(cross(right, forward));
  //vec3 direction = normalize(npos.x * 1.67 * right + npos.y * up - forward);
  vec3 direction = normalize(npos.x * 1.67 * right + npos.y * normalize(cross(right, forward)) - forward);
  
#if 0
  // Background noise.
  float depth = (calculated_position.y + i_plane_far * 3) / i_plane_far / 3;
  vec3 ambient = mix(vec3(0.0), mix(vec3(0.2, 0.2, 0.3), vec3(0.4, 0.4, 0.8), depth), calculate_noise(calculated_position * 0.00001 + direction * 0.006));
  vec4 background = vec4(ambient, 1.0);

  // Sky reflection.
  float FF = dot(normalize(vec3(-0.1, 1.0, -0.1)), direction);
  float GG = dot(normalize(vec3(-0.3, 1.0, -0.3)), direction);
  float HH = dot(normalize(vec3(-0.7, 1.0, -0.7)), direction);
  float II = max((FF + GG + HH) * 0.2, max(FF, max(GG, HH))) * (0.9 + calculate_noise(calculated_position * 0.0001 + direction * 0.009) * 0.2);
  background += max(II * II * II * II * II * depth, 0.0);

  float amplification = smoothstep(11111111.0, 16666666.0, float(uniform_array[5].z)) * 0.6;

  // Out.
  output_color = (1.0 - cumulative.a) * background * (1.0 - amplification) + cumulative * (1.0 + amplification);
#else
  // Background noise.
  float depth = (calculated_position.y + i_plane_far * 3) / i_plane_far / 3;

  // Sky reflection.
  float FF = dot(normalize(vec3(-0.1, 1, -0.1)), direction);
  float GG = dot(normalize(vec3(-0.3, 1, -0.3)), direction);
  float HH = dot(normalize(vec3(-0.7, 1, -0.7)), direction);
  float II = max((FF + GG + HH) / 5, max(FF, max(GG, HH))) * (0.9 + calculate_noise(calculated_position * 0.0001 + direction * 0.009) / 5);

  float amplification = smoothstep(11111111.0, 16000000.0, float(uniform_array[5].z)) * 0.6;

  // Out.
  output_color = (1 - cumulative.a) * vec4(mix(vec3(0), mix(vec3(0.2), vec3(0.4, 0.4, 0.8), depth), calculate_noise(calculated_position * 0.00001 + direction * 0.006)) + max(II * II * II * II * II * depth, 0), 1) * (1 - amplification) + cumulative * (1 + amplification);

  II = min(1, (2 - abs(position.y)) * smoothstep(-0.05, 0.0, relative_time - 0.05) * smoothstep(-1.0, -0.95, -relative_time));
  output_color *= II * II * II;
#endif
#endif
}
