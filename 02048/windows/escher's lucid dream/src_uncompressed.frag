#version 430

float EPS = 0.005;
float PI = 3.1415;
float TAU = 2.0 * PI;


const int N = 16;
vec4 colors[N];
float depths[N];
float opacities[N];

vec3 color1 = vec3(0.1, 0.115, 0.13);
vec3 color2 = vec3(0.2, 0.08, 0.08);


mat2 R2(float phi) {
    return mat2(cos(phi), sin(phi),
                -sin(phi), cos(phi));
}


vec2 rep(vec2 p, vec2 m) {
    return mod(p + 0.5*m, m) - 0.5*m;
}


float rep(float x, float m) {
    return mod(x + 0.5*m, m) - 0.5*m;
}


float sphere(vec2 p, float r) {
    return length(p) - r;
}


float  alpha_from_dist(float d) {
    return clamp(EPS - d, 0.0, EPS) / EPS;
}


float hexagon(vec2 p, float r, vec3 basecolor, out vec3 outcolor, float coloroffset) {
    float angle = (atan(p.x, p.y) + PI) * 3/TAU;
    float tmp = fract(angle);
    angle = mod(floor(angle) + coloroffset, 3.0);
    float col1 = angle;
    float col2 = mod(angle + 1, 3.0);

    float howmuchsmoothing = max(length(p)/r, 1.0);

    float whichcolor = mix(col1, col2, smoothstep(0.8 + 0.15*howmuchsmoothing, 1.0, tmp));

    outcolor = basecolor * (1.0 + whichcolor);

    vec2 q = abs(p);
    return max(q.y*sqrt(3)*0.5 + q.x*0.5, q.x) - r;
}


vec4 circle_of_squares(vec2 p, float rot_angle, out float outangle, out float opacity) {
    float m = TAU/11.;

    p.y = p.y*3.2;
    p = R2(rot_angle) * p;

    float angle = atan(p.y, p.x);
    float r = length(p);

    outangle = angle;
    float angle_tmp = round(angle/m)*m;
    angle = rep(angle, m);

    p = r * vec2(cos(angle), sin(angle));

    p.x -= 1.7;
    p = R2(angle_tmp - rot_angle) * p;
    p.y /= 3.2;
    vec3 color;
    float d = hexagon(p, 0.13, color2, color, 1.0);
    opacity = 0.5 + 0.4*sqrt(max(-d/0.13, 0.0));

    return vec4(color + 2.0*color2, d - EPS);
}


vec4 tower(vec2 p, int layer, float coloroffset) {
    vec3 color;
    vec2 q;
    float d;

    q = p;
    q.y = rep(q.y, 0.50);
    d = hexagon(q, 0.17, color1, color, coloroffset);
    colors[layer] = vec4(color, d - EPS);
    opacities[layer] = 1.0;
    depths[layer] = 0.5 + float(q.y < 0.0);

    q = p;
    q.y = rep(q.y + 0.25, 0.5);
    d = hexagon(q, 0.17, color1, color, coloroffset);
    colors[layer + 1] = vec4(color, d - EPS);
    opacities[layer + 1] = 1.0;
    depths[layer + 1] = 1.0;

    return vec4(1.0);
}

void draw(vec2 p) {
    float d, opacity, angle;
    float m = TAU/11.;
    float numlayers = 3;

    // Domain distortion
    p += 0.003*sin(55.0*p);

    for (int i=0; i<numlayers; i++) {
        colors[i] = circle_of_squares(p, -i*m/numlayers, angle, opacity);
        float which = round(angle/(m/numlayers));
        depths[i] = 1 + mod(which + 1.0, numlayers);
        opacities[i] = opacity;

        // get angle in 0..1 range (start left ccw)
        float tmpx = atan(p.y, p.x)/TAU + 0.5;
        // manipulate depth depending on where we are in the circle
        if (tmpx > 0.9) {
            depths[i] += 10;
        } else if (tmpx > 0.5) {
            depths[i] -= 10;
        } else if (tmpx > 0.1) {
            depths[i] += 10;
        } else {
            depths[i] -= 10;
        }
    }

    vec3 color; 
    vec2 q = p - vec2(0.3, 0);

    vec2 offset = vec2(0.433, 0);
    float tmp2 = 0.4;

    tower(q - offset, 4, 1.0);
    depths[4] += 2*float(q.x - 1.732*q.y>tmp2);
    depths[5] += 2*float(q.x - 1.732*q.y>tmp2);

    q = R2(TAU/3) * q;
    tower(q - offset, 6, 2.0);
    depths[6] += 2*float(q.x - 1.732*q.y>tmp2);
    depths[7] += 2*float(q.x - 1.732*q.y>tmp2);

    q = R2(TAU/3) * q;
    tower(q - offset, 8, 0.0);
    depths[8] += 2*float(q.x - 1.732*q.y>tmp2);
    depths[9] += 2*float(q.x - 1.732*q.y>tmp2);

    // hack: increase "ambient lighting"
    for (int i=4; i<10; i++) {
        colors[i].rgb += 2.0*color1;
    }

}


void swap(int i, int j) {
    float tmp = depths[i];
    depths[i] = depths[j];
    depths[j] = tmp;

    vec4 tmp4 = colors[i];
    colors[i] = colors[j];
    colors[j] = tmp4;

    tmp = opacities[i];
    opacities[i] = opacities[j];
    opacities[j] = tmp;
}

void sort_layers() {
    // basic even-odd sorting network
    // n^2 possible swaps, no branching.
    int i,j;
    for (i=0; i<N; i++) {
        for (j=i%2; j<N-1; j+=2) {
            if (depths[j] > depths[j+1]) {
                 swap(j, j+1);   
            }
        }
    }
}


vec4 merge_layers(vec4 old, vec4 color, float opacity) {
    return vec4(mix(old.rgb, color.rgb, opacity*alpha_from_dist(color.a)), 1.0);
}

void main() {
    for (int i=0; i<N; i++) {
        colors[i] = vec4(0.0, 0.0, 0.0, 1.0);
        depths[i] = 100.0;
        opacities[i] = 1.0;
    }

    vec2 p = (2*gl_FragCoord.xy - vec2(1920, 1080))/1080;

    draw(R2(0.34)*(1.3*p + vec2(0.0, 0.1)));

    // background
    colors[10] = vec4(0.75, 0.8, 0.8, 0.0);
    depths[10] = -100;

    // vignette
    colors[11] = vec4(0.0);
    depths[11] = 100;
    opacities[11] = clamp(sphere(p*vec2(9/16., 1), 0.6), 0.0, 1.0);

    sort_layers();

    vec4 color = vec4(0.0);
    for (int i=0; i<N; i++) {
        color = merge_layers(color, colors[i], opacities[i]);
    }

    gl_FragColor = color;
}
