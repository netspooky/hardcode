vec2 p = gl_FragCoord.xy/360-vec2(1.78,1);
vec2 sincos;
float t;


vec2 sphere(vec2 p, float r) {
    float d = length(p);
    return (d-r)/d * p;
}


vec2 grid(vec2 p) {
    float m = 0.2 + 0.2*abs(p.x*p.y); 
    p = abs(mod(p - 0.5*m, m) - 0.5*m);
    return sphere(p + 0.15*sincos, 0.14);
}


vec2 bug(vec2 p) {
    return sphere(p + 0.2*sincos.yx, 0.2) + sphere(p + 0.3*sincos, 0.2);
}


vec2 f(vec2 p) {
    return mix(grid(p), bug(p),
               smoothstep(5.0, 8.0 + 3.0*length(p), sin(5.0*length(p) - 3.0*t) + t));
}


vec3 texture(vec2 p) {
    vec3 c1 = vec3(0.7, 0.8, 0.5);
    vec3 c2 = vec3(0.6, 0.8, 1.0);
    vec3 res = 0.3*abs(p.x*p.y)*c1 + 0.7*length(p)*c2;
    res *= smoothstep(0.0, 10.0, abs(length(p) - 10.0));
    return clamp(res, 0.0, 2.0);
}


vec3 newton(vec2 p) {
    vec3 color = vec3(0.0);
    float EPS = 0.05;
    vec2 e = vec2(EPS, 0.0), fp;

    for (float i=1.0; i<5.0; i++) {
        fp = f(p);
        mat2 Df = mat2(f(p+e) - fp, f(p+e.yx) - fp) / (1.5*EPS);
        p -= inverse(Df) * fp;
        color += texture(p) * pow(0.5, i);
    }
    return color;
}


void main() {
    t = 5.5 + 0.5*(cos(3.0*p.y) + cos(3.0*p.x));
    float N=15.0, weight, totalweight = 0.0;
    vec3 res = 0.0;
    
    for (float i=-N; i<=N; i++) {
        weight = 1.0 + N - abs(i);
        t += 0.03;
        sincos = vec2(sin(t), cos(t));
        res += weight*newton(p);
        totalweight += weight;
    }
    res /= totalweight;

    res -= 0.2*length(p);
    res = pow(res, 1.5);
    gl_FragColor.xyz = res;
}
