
layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

in Vertex {
    vec3 pos1;
    vec3 pos2;
    vec3 color;
    float size;
    float cull;
} vertex[];

out Fragment {
    vec3 pos1;
    vec3 pos2;
    vec3 color;
    float size;
} frag;

void main() {
   if (vertex[0].cull > 0) return;

   vec4 p1 = vec4(vertex[0].pos1, 1.0);
   vec4 p2 = vec4(vertex[0].pos2, 1.0);
   vec4 d = vec4(normalize(p2.xy - p1.xy), 0, 0);
   if (distance(p2.xy, p1.xy) < 0.0001) d = vec4(1,0,0,0);
   vec4 n = vec4(-d.y, d.x, 0, 0);
   float size = vertex[0].size;
   float z1 = distance(p1.z, focus.x)*focus.y + size * (1.0 - p1.z);
   float z2 = distance(p2.z, focus.x)*focus.y + size * (1.0 - p2.z);
   frag.pos1 = p1.xyz * vec3("ASPECT",1,1);
   frag.pos2 = p2.xyz * vec3("ASPECT",1,1);
   frag.color = vertex[0].color;
   frag.size = size;
   gl_Position = p1 - n*z1 - d*z1;
   EmitVertex();
   gl_Position = p1 + n*z1 - d*z1;
   EmitVertex();
   gl_Position = p2 - n*z2 + d*z2;
   EmitVertex();
   gl_Position = p2 + n*z2 + d*z2;
   EmitVertex();
}

