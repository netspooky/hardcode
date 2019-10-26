out vec4 color;

void main(){
    vec2 coord = gl_FragCoord.st;
    color = texture2DRect(tex, coord * "SCALE");
}
