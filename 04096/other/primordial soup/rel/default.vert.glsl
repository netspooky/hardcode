layout(location = 0) in ivec4 vertex;
layout(location = 1) in ivec4 additional;

out D
{
  vec3 aa;
  vec3 bb;
  vec3 cc;
  vec3 pp;
  vec4 qq;
  float ss;
  float ww;
  mat4 mm;
} oarray;

void main()
{
  // Lookat components.
  vec3 forward = normalize(vec3(uniform_array[2]));
  vec3 right = normalize(cross(forward, normalize(vec3(uniform_array[3]))));
  vec3 up = normalize(cross(right, forward));

  // Lookat matrix.
  mat3 lookat = transpose(mat3(right, up, forward));
  mat4 modelview = mat4(lookat);
  modelview[3] = vec4(lookat * -calculated_position, 1);

  // Perspective matrix
  mat4 perspective = mat4(0);
  float i_fov = 1.73;
  //float fov = 1.0 / tan(60.0 / 180.0 * PI * 0.5);
  perspective[0][0] = i_fov / 1.67;
  perspective[1][1] = i_fov;
  perspective[2][2] = (i_plane_near + i_plane_far) / (i_plane_near - i_plane_far);
  perspective[2][3] = -1;
  perspective[3][2] = (2 * i_plane_near * i_plane_far) / (i_plane_near - i_plane_far);

  // Output.
  oarray.aa = right;
  oarray.bb = up;
  oarray.cc = calculated_position;
  oarray.pp = vertex.xyz + vec3(33) * sin(uniform_array[5].x * 0.000002 + (vertex.z + vertex.x) * 0.002) * 9999.0 / additional.x / additional.y;
  oarray.ww = vertex.w;
  oarray.qq = additional;
  oarray.ss = 1 - length(vertex.xyz - calculated_position) / i_plane_far;
  oarray.mm = perspective * modelview;
  //gl_Position = (p * modelview) * vec4(a, 0, 1);
}
