#version 430 compatibility

layout(location=0)uniform ivec3 uniform_array[6];
layout(location=8)uniform sampler3D volume;
#if defined(USE_LD)
layout(location=9)uniform mat3 noise_matrix;
#endif

// Replaced verbatim where needed.
//float PI = 3.14159;

float i_plane_near = 1.0;
float i_plane_far = 8888.0;

vec2 iabs(vec2 complex_num)
{
  return vec2(complex_num.x, abs(complex_num.y));
}

vec2 ilog(vec2 complex_num)
{
  return vec2(log(length(complex_num)), atan(complex_num.y, complex_num.x));
}

float calculate_noise(vec3 pos)
{
#if !defined(USE_LD)
  mat3 noise_matrix=mat3(-0.99, -0.16, 0.02, 0.14, -0.77, 0.63, -0.08, 0.62, 0.78);
#endif
#if 0
  vec3 hh = noise_matrix * pos;
  vec3 ii = noise_matrix * hh * 3.0;
  vec3 jj = noise_matrix * ii * 3.0;
  float aa = texture(volume, hh).x * 0.6;
  float bb = texture(volume, ii).x * 0.3;
  float cc = texture(volume, jj).x * 0.1;
  return aa + bb + cc;
#else
  vec3 hh = noise_matrix * pos;
  vec3 ii = noise_matrix * hh * 3;
  return texture(volume, hh).x * 0.6 + texture(volume, ii).x * 0.3 + texture(volume, noise_matrix * ii * 3).x * 0.1;
#endif
}

#if 0
vec3 calculate_position()
{
  return mix(vec3(uniform_array[0]), vec3(uniform_array[1]), float(uniform_array[5].x) / uniform_array[5].y);
}

float calculate_dof()
{
  return mix(float(uniform_array[4].x), float(uniform_array[4].y), float(uniform_array[5].x) / uniform_array[5].y);
}
#else
float relative_time = float(uniform_array[5].x) / uniform_array[5].y;
float calculated_dof = mix(float(uniform_array[4].x), float(uniform_array[4].y), relative_time);
vec3 calculated_position = mix(vec3(uniform_array[0]), vec3(uniform_array[1]), relative_time);
#endif
