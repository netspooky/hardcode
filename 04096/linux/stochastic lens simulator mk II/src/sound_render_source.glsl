out vec4 color;

float t = (gl_FragCoord.s + time * 4096) / 44100.0;
float sample_pos = t * "TIMERES";

float kick() {
    vec4 x = channel(t, "KICK");
    if (x.x < 1) return 0;
    float tt = t - x.y;
    float v = cos(pow(1-tt*4,3)*100);
    float m = bcos(0.3, tt / x.z*pi2) * -0.5 + 0.5;
    return v * m * 0.7;
}

float kosh() {
    vec4 x = channel(t, "KOSH");
    if (x.x < 1) return 0;
    float tt = t - x.y;
    float v = rand(vec2(tt,tt));
    float m = bcos(0.1, tt / x.z*pi2) * -0.5 + 0.5;
    return v * m * 0.3;
}

float noise() {
    vec4 x = channel(t, "NOISE");
    if (x.x < 1) return 0;
    float tt = t - x.y;
    float v = sin(rand(vec2(floor(tt*10),0))*tt*1000);
    float m = bcos(0.1, tt / x.z*pi2*20) * -0.5 + 0.5;
    return v * m * 0.3;
}

void main(){
    float t = (gl_FragCoord.s / 4096 + time);
    float f = 0;
    for (int i = 0; i < 10; ++i) {
        f += texture2DRect(tex, vec2((t * 4096) / 44100 * "TIMERES", i)).y;
    }
    vec4 k = texture2DRect(tex, vec2((t * 4096) / 44100 * "TIMERES", 0));
    color = (vec4(kick() + kosh() + noise()) * 0.5 + 0.5);
}
