layout(location=0) in vec2 vertex;

out vec2 position;

void main()
{
  position = vertex * 0.5 + 0.5;
  gl_Position = vec4(vertex, 0, 1);
}
