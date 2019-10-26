
out Vertex {
    vec3 pos1;
    vec3 pos2;
    vec3 color;
    float size;
    float cull;
} vertex;

vec3 tr(vec4 p){
    float r = length(p);
    float i = acos(p.z/r) * 0.8;
    float a = atan(p.x, p.y);
    return vec3(sin(a)*i,cos(a)*i,pow(r/5000.0, 0.25));
}

vec3 la(float p) {
    return vec3(bcos(0, p*0.5+time*10), bsin(1, p*0.5+time*sin(time*10)) * 2, 0);
}

int chars[28] = int[](0,131618,630678,497559,430486,498071,988959,71455,433430,630681,139810,432264,611161,987409,629241,630201,432534,71575,678294,628631,1019678,139823,432537,305561,653721,628377,280217,988815);

int greet1[22] = int[](8,19,6,6,21,10,15,8,20,0,20,21,19,6,2,14,13,10,15,8,20,1);
int greet2[18] = int[](21,9,6,0,9,16,19,19,16,19,0,10,20,0,16,23,6,19);

vec3 g1() {
    int word = gl_VertexID / 20;
    int dot = gl_VertexID % 20;
    int x = dot % 4;
    int y = dot / 4;

    int l = chars[greet1[word % 22]];

    vertex.cull = 1;
    if (bool(l & (1<<dot))) vertex.cull = 0;

    return vec3(word * 5 + x - 11*5, y+bcos(0.2, time*pi2*2), 150 + (-time*20)) * 0.01;
}

vec3 g2() {
    int word = gl_VertexID / 20;
    int dot = gl_VertexID % 20;
    int x = dot % 4;
    int y = dot / 4;

    int l = chars[greet2[word % 23]];

    vertex.cull = 1;
    if (bool(l & (1<<dot))) vertex.cull = 0;

    return vec3(word * 5 + x - 9*5, y+bcos(0.2, time*pi2*4), 800 + (-time*20)) * 0.01;
}

vec3 rand3(float x) {
    return vec3(rand(vec2(x,0)), rand(vec2(0,x)), rand(vec2(x,x)));
}

vec3 turntable(vec3 p, float t1, float t2) {
    mat4 m = mat4(cos(t1), 0, sin(t2), 0,   0, 1, 0, 0,  -sin(t1), 0, cos(t2), 0,  0, 0, 0, 1) * 
        mat4(1000, 0, 0, 0,  0, -1000*"ASPECT", 0, 0, 0, 0, 1000, 1000, 0, 0, 0, 1);
    return tr(vec4(p,1) * m);
}

vec3 animate(float p, float t){
    vec3 p1 = vec3(0);
    vertex.cull = 0;
    if (t < 20) {
        if (gl_VertexID < 20*22) {
            p1 = g1();
            vertex.color = vec3(0);
            vertex.size = 0.015;
            return turntable(p1,0,0);
        }
    }
    if (t > 35 && t < 100) {
        if (gl_VertexID < 20*18) {
            p1 = g2();
            vertex.color = vec3(0);
            vertex.size = 0.015;
            return turntable(p1,0,0);
        }
    }
    if (gl_VertexID < 20*27) vertex.cull = 1;
    if (t > 0 && t < 20) {
        p1 = rand3(p) * 2 - 1;
        //p1 += p1 * bcos(0.6, t*pi2*2) * 0.1;
        vertex.color = vec3(0);
        vertex.size = 0.03;
        return turntable(p1,t,t);
    }
    if (t > 20 && t < 25) {
        p1 = rand3(p) * 2 - 1;
        vertex.color = rand3(p*2);
        vertex.size = 0.1;
        return turntable(p1 + p1 * bcos(0.1, t*pi2*2) * 0.2,t,t);
    }
    if (t > 25 && t < 27) {
        p1 = rand3(p) * 2 - 1;
        vertex.color = rand3(p*2);
        vertex.size = 0.1;
        return turntable(p1, bcos(0.2, t*pi2*2), bsin(0.2, t*pi2*2));
    }
    if (t > 27 && t < 35) {
        p1 = rand3(p) * 2 -1;
        vertex.color = rand3(p*2);
        vertex.size = 0.1;
        return turntable(p1, -t*2, t+cos(t*5));
    }
    if (t > 35) {
        p1 = rand3(p) * 2 - 1;
        vertex.color = rand3(p*2);
        vertex.size = 0.1 / (t-34);
        return turntable(p1 / (t-34), t, bcos(0.1,t));
    }

    vertex.cull = 1;
    return turntable(p1,0,0);
}

void main(){
    float p = gl_VertexID / "POINTS" * pi2;
    vec3 p1 = animate(p, time);
    vec3 p2 = animate(p, time+1.0/60.0);
    vec3 r = vec3(p*1.1, p*2.3, p*4.7);
    vertex.pos1 = p1;
    vertex.pos2 = p2;
}

