#version 150
#extension GL_ARB_texture_rectangle : enable
uniform sampler2DRect tex;
uniform float time;

vec2 focus = vec2(0.7,0.3);

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float bcos(float s, float x) { 
    return cos(x) / (s + abs(cos(x))) * (1 + s); 
}

float bsin(float s, float x) { 
    return sin(x) / (s + abs(sin(x))) * (1 + s); 
}

vec4 channel(float t, float i) {
    return texture2DRect(tex, vec2(t * "TIMERES", i));
}

float pi = acos(-1.0);
float pi2 = pi * 2;

