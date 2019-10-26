
in Fragment {
    vec3 pos1;
    vec3 pos2;
    vec3 color;
    float size;
} frag;

out vec4 color;

void main(){
    vec2 xy = (gl_FragCoord.xy / "FB" * 2 - 1) * vec2("ASPECT",1);
    float t = rand(xy + time);
    float a = 6.3 * rand(xy * 1.1 + time);
    float r = rand(xy * 1.2 + time);
    vec2 lens = vec2(sin(a) * r, cos(a) * r);
    vec3 pos = mix(frag.pos1, frag.pos2, t);
    vec2 m = pos.st - xy + lens * distance(pos.z, focus.x) * focus.y;
    float d = length(m);
    if (d < frag.size * (1.0 - pos.z)) {
        color = vec4(frag.color, 1);
        gl_FragDepth = clamp(pos.z, 0.0, 0.99);
    } else {
        gl_FragDepth = 1.95;
        color = vec4(0.05);
    }
}

