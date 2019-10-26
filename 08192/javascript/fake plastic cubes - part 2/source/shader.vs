attribute vec3 aVertexPosition;
attribute vec3 aVertexNormal;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;
uniform mat3 uNMatrix;

uniform float time;
uniform float choppiness;
uniform float uPurpleness;
uniform float uCubiness;
uniform float uZflight;

varying vec3 vLightWeighting;
varying vec3 vBaseColour;

uniform vec3 uPurple;
uniform vec3 uGreen;
const vec3 cWhite = vec3(1.0, 1.0, 1.0);

void main(void) {
	vec3 pointLightingLocation = vec3(4.0, 4.0, 0.0);
	vec3 pointLightingColor = vec3(1.0, 1.0, 1.0);
	vec3 ambientColor = vec3(0.1, 0.1, 0.1);

	vec3 cubePosition = aVertexPosition;
	vec3 cubeNormal = aVertexNormal;

	vec3 sphereNormal = normalize(aVertexPosition);
	vec3 spherePosition = sphereNormal;

	/* float cubiness = 0.5 + 0.5 * sin(time * 0.001); */
	float cubiness = 1.0 * uCubiness;

	vec3 actualPosition = mix(spherePosition, cubePosition, cubiness);
	vec3 actualNormal = mix(sphereNormal, cubeNormal, cubiness);

	vec2 disp = vec2(
		choppiness * sin((abs(cubePosition.x) + uZflight * 0.1) * 10.0 + time * 0.001),
		choppiness * sin((abs(cubePosition.z) - uZflight) * 10.0 + time * 0.001)
	);
	vec2 dispN = vec2(
		choppiness * cos((abs(cubePosition.x) + uZflight * 0.1) * 10.0 + time * 0.001),
		choppiness * cos((abs(cubePosition.z) - uZflight) * 10.0 + time * 0.001)
	);

	vec4 mvPosition = uMVMatrix * vec4(actualPosition + length(disp) * actualPosition, 1.0);
	vec3 transformedNormal = uNMatrix * (actualNormal + vec3(dispN.x, 0.0, dispN.y));

	gl_Position = uPMatrix * mvPosition;

	vec3 lightDirection = normalize(pointLightingLocation - mvPosition.xyz);

	float directionalLightWeighting = max(dot(transformedNormal, lightDirection), 0.0);
	vLightWeighting = ambientColor + pointLightingColor * directionalLightWeighting;

	vec3 whiteOrGreen = mix(cWhite, uGreen,
		(sin(time*0.003 + actualPosition.x * 2.0) + sin(time*0.0031 + actualPosition.x * 2.3) + 
		sin(time*0.0024 + actualPosition.y * 1.2) + sin(time*0.0037 + actualPosition.y * 3.3)) * 0.05 + 0.3
	);

	vBaseColour = mix(whiteOrGreen, uPurple,
		(0.5 + 0.5*sin(5.0 * actualPosition.x + actualPosition.z - uZflight + time*0.01)) * uPurpleness
	);

}
