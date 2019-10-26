precision mediump float;

varying vec3 vLightWeighting;
varying vec3 vBaseColour;

void main(void) {
    gl_FragColor = vec4(vBaseColour.rgb * vLightWeighting, 1.0);
}
