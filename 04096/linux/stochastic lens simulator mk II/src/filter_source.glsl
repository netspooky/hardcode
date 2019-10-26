float w(float x) {
    return (pow(2.718281828, -(x*x))) / 7.3;
}
out vec4 color;

void main(){
    vec2 coord = gl_FragCoord.st;
    vec2 m;
    if (textureSize(tex).x == " FB_W ") m = vec2(1,0);
    else m = vec2(0,1);
    coord *= m*3+1;
    float x = -1.625;
    for (int i = -8; i < 8; ++i) {
        color += w(x) * texture2DRect(tex, coord + vec2(i,i) * m);
        x += 0.25;
    }
}
