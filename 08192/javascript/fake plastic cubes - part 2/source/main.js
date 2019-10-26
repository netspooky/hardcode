fragmentShaderSource = String.fromCharCode.apply(null,f[2]);
vertexShaderSource = String.fromCharCode.apply(null,f[3]);

var raf = window.requestAnimationFrame || window.mozRequestAnimationFrame;

c.width=100; /* lose scrollbar */
canvas = document.createElement('canvas');
document.body.appendChild(canvas);
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;
canvas.style.position = 'absolute';
canvas.style.left = 0;
canvas.style.top = 0;

gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
gl.viewportWidth = canvas.width;
gl.viewportHeight = canvas.height;

gl.clearColor(0.3, 0.07, 0.0, 1.0);
gl.enable(gl.DEPTH_TEST);
gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);

/* init buffers */

cubeVertexPositionBuffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexPositionBuffer);

var vertices = [];
var normals = [];
// front
for (var y = 0; y < 11; y++) {
	for (var x = 0; x < 11; x++) {
		vertices.push(x * 0.2 - 1.0);
		vertices.push(y * 0.2 - 1.0);
		vertices.push(1.0);

		normals.push(0.0);
		normals.push(0.0);
		normals.push(1.0);
	}
}

// back
for (var y = 0; y < 11; y++) {
	for (var x = 0; x < 11; x++) {
		vertices.push(x * 0.2 - 1.0);
		vertices.push(y * 0.2 - 1.0);
		vertices.push(-1.0);

		normals.push(0.0);
		normals.push(0.0);
		normals.push(-1.0);
	}
}

// top
for (var y = 0; y < 11; y++) {
	for (var x = 0; x < 11; x++) {
		vertices.push(x * 0.2 - 1.0);
		vertices.push(1.0);
		vertices.push(y * 0.2 - 1.0);

		normals.push(0.0);
		normals.push(1.0);
		normals.push(0.0);
	}
}

// bottom
for (var y = 0; y < 11; y++) {
	for (var x = 0; x < 11; x++) {
		vertices.push(x * 0.2 - 1.0);
		vertices.push(-1.0);
		vertices.push(y * 0.2 - 1.0);

		normals.push(0.0);
		normals.push(-1.0);
		normals.push(0.0);
	}
}

// right
for (var y = 0; y < 11; y++) {
	for (var x = 0; x < 11; x++) {
		vertices.push(1.0);
		vertices.push(x * 0.2 - 1.0);
		vertices.push(y * 0.2 - 1.0);

		normals.push(1.0);
		normals.push(0.0);
		normals.push(0.0);
	}
}

// left
for (var y = 0; y < 11; y++) {
	for (var x = 0; x < 11; x++) {
		vertices.push(-1.0);
		vertices.push(x * 0.2 - 1.0);
		vertices.push(y * 0.2 - 1.0);

		normals.push(-1.0);
		normals.push(0.0);
		normals.push(0.0);
	}
}

gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
cubeVertexPositionBuffer.itemSize = 3;
cubeVertexPositionBuffer.numItems = vertices.length / 3;

cubeVertexNormalBuffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexNormalBuffer);

gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(normals), gl.STATIC_DRAW);
cubeVertexNormalBuffer.itemSize = 3;
cubeVertexNormalBuffer.numItems = normals.length / 3;

cubeVertexIndexBuffer = gl.createBuffer();
gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
var cubeVertexIndices = [];

for (fc = 0; fc < 6; fc++) {
	for (var y = 0; y < 10; y++) {
		for (var x = 0; x < 10; x++) {
			cubeVertexIndices.push(fc*121 + y*11 + x);
			cubeVertexIndices.push(fc*121 + y*11 + x+1);
			cubeVertexIndices.push(fc*121 + (y+1)*11 + x);

			cubeVertexIndices.push(fc*121 + y*11 + x+1);
			cubeVertexIndices.push(fc*121 + (y+1)*11 + x+1);
			cubeVertexIndices.push(fc*121 + (y+1)*11 + x);
		}
	}
}
gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndices), gl.STATIC_DRAW);
cubeVertexIndexBuffer.itemSize = 1;
cubeVertexIndexBuffer.numItems = cubeVertexIndices.length;


seaVertexPositionBuffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, seaVertexPositionBuffer);

var seaVertices = [];
var seaNormals = [];
for (var y = 0; y < 21; y++) {
	for (var x = 0; x < 21; x++) {
		seaVertices.push(x * 0.5 - 5.0);
		seaVertices.push(-2.0);
		seaVertices.push(y * 0.5 - 8.0);

		seaNormals.push(0.0);
		seaNormals.push(1.0);
		seaNormals.push(0.0);
	}
}
gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(seaVertices), gl.STATIC_DRAW);
seaVertexPositionBuffer.itemSize = 3;
seaVertexPositionBuffer.numItems = seaVertices.length / 3;

seaVertexNormalBuffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, seaVertexNormalBuffer);

gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(seaNormals), gl.STATIC_DRAW);
seaVertexNormalBuffer.itemSize = 3;
seaVertexNormalBuffer.numItems = seaNormals.length / 3;

seaVertexIndexBuffer = gl.createBuffer();
gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, seaVertexIndexBuffer);
var seaVertexIndices = [];
for (var y = 0; y < 20; y++) {
	for (var x = 0; x < 20; x++) {
		seaVertexIndices.push(y*21 + x);
		seaVertexIndices.push(y*21 + x+1);
		seaVertexIndices.push((y+1)*21 + x);

		seaVertexIndices.push(y*21 + x+1);
		seaVertexIndices.push((y+1)*21 + x+1);
		seaVertexIndices.push((y+1)*21 + x);
	}
}
gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(seaVertexIndices), gl.STATIC_DRAW);
seaVertexIndexBuffer.itemSize = 1;
seaVertexIndexBuffer.numItems = seaVertexIndices.length;



/* init shaders */
var fShader = gl.createShader(gl.FRAGMENT_SHADER);
gl.shaderSource(fShader, fragmentShaderSource);
gl.compileShader(fShader);

if (!gl.getShaderParameter(fShader, gl.COMPILE_STATUS)) {
    alert(gl.getShaderInfoLog(fShader));
}

var vShader = gl.createShader(gl.VERTEX_SHADER);
gl.shaderSource(vShader, vertexShaderSource);
gl.compileShader(vShader);

if (!gl.getShaderParameter(vShader, gl.COMPILE_STATUS)) {
    alert(gl.getShaderInfoLog(vShader));
}

var shaderProgram = gl.createProgram();
gl.attachShader(shaderProgram, vShader);
gl.attachShader(shaderProgram, fShader);
gl.linkProgram(shaderProgram);

if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
    alert("Could not initialise shaders");
}

gl.useProgram(shaderProgram);

var vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition");
gl.enableVertexAttribArray(vertexPositionAttribute);

var vertexNormalAttribute = gl.getAttribLocation(shaderProgram, "aVertexNormal");
gl.enableVertexAttribArray(vertexNormalAttribute);

var pMatrixUniform = gl.getUniformLocation(shaderProgram, "uPMatrix");
var mvMatrixUniform = gl.getUniformLocation(shaderProgram, "uMVMatrix");
var nMatrixUniform = gl.getUniformLocation(shaderProgram, "uNMatrix");

var timeUniform = gl.getUniformLocation(shaderProgram, "time");

var purpleUniform = gl.getUniformLocation(shaderProgram, "uPurple");
var greenUniform = gl.getUniformLocation(shaderProgram, "uGreen");
var choppinessUniform = gl.getUniformLocation(shaderProgram, "choppiness");
var purplenessUniform = gl.getUniformLocation(shaderProgram, "uPurpleness");
var cubinessUniform = gl.getUniformLocation(shaderProgram, "uCubiness");
var zFlightUniform = gl.getUniformLocation(shaderProgram, "uZflight");

/* init matrices */
pMatrix = new Float32Array(16);
mvMatrix = new Float32Array(16);
nMatrix = new Float32Array(9);

var purple = new Float32Array([171.0 / 255.0, 120.0 / 255.0, 199.0 / 255.0]);
var blue = new Float32Array([0.0 / 255.0, 60.0 / 255.0, 119.0 / 255.0]);
var green = new Float32Array([0.0 / 255.0, 60.0 / 255.0, 0.0 / 255.0]);
var white = new Float32Array([1,1,1]);

var t0 = null;
function tick(t1) {
	t0 = t0 || t1;
	var t = t1 - t0;

	var distance, cubiness, purpleness, zFlight, choppiness, cubeChoppiness;
	var w;
	var addGreen = false;

	if (t < 12500) {
		distance = 20;
		cubiness = purpleness = zFlight = 0;
		choppiness = 0.2;
		cubeChoppiness = 0.1;
	} else if (t < 13500) {
		w = (t - 12500) / 1000;
		distance = 20 - 13*w;
		cubiness = w * 0.8;
		choppiness = 0.2;
		purpleness = zFlight = 0;
		cubeChoppiness = 0.1;
	} else if (t < 39000) {
		distance = 7;
		w = (t - 13500) * 0.002;
		cubiness = 0.8 + 0.2 * Math.sin(w);
		choppiness = 0.2;
		purpleness = zFlight = 0;
		cubeChoppiness = 0.1;
	} else if (t < 39200) {
		w = (t - 39000) / 200;
		distance = 7;
		cubiness = 1;
		purpleness = w;
		choppiness = 0.2;
		zFlight = (t - 39000) * 0.003;
		cubeChoppiness = 0.1;
	} else if (t < 64000) {
		distance = 7;
		cubiness = 1;
		purpleness = 1;
		choppiness = 0.4;
		zFlight = (t - 39000) * 0.003;
		cubeChoppiness = 0.1;
	} else if (t < 64500) {
		w = (t - 64000) / 500;
		distance = 7;
		cubiness = 1 - w;
		purpleness = 1;
		choppiness = 0.4;
		zFlight = (t - 39000) * 0.003;
		cubeChoppiness = 0.1 * (1 - w);
	} else if (t < 90000) {
		distance = 7;
		cubiness = 0;
		purpleness = 1;
		choppiness = 0.4;
		zFlight = (t - 39000) * 0.003;
		cubeChoppiness = 0.0;
		if (t > 77000) addGreen = true;
	} else if (t < 91000) {
		w = (t - 90000) / 1000;
		distance = 7;
		cubiness = w * 0.5;
		purpleness = 1;
		choppiness = 0.4;
		zFlight = (t - 39000) * 0.003;
		cubeChoppiness = w * 0.2;
	} else if (t < 115000) {
		w = (t - 91000) / 4000;
		distance = 7;
		cubiness = 0.5 + 0.5 * Math.sin(w);
		purpleness = 1;
		choppiness = 0.4;
		zFlight = (t - 39000) * 0.003;
		cubeChoppiness = 0.2 + 0.1 * Math.sin(w*0.9);
	} else {
		w = (t - 91000) / 4000;
		distance = 7 + Math.min((t - 115000) * 0.01, 30);
		cubiness = 0.5 + 0.5 * Math.sin(w);
		purpleness = 1;
		choppiness = 0.4;
		zFlight = (t - 39000) * 0.003;
		cubeChoppiness = 0.2 + 0.1 * Math.sin(w*0.9);
	}

	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

	/* set matrix uniforms */
	mat4.perspective(pMatrix, Math.PI/4, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0);

	mat4.identity(mvMatrix);
	mat4.translate(mvMatrix, mvMatrix, [0, 0, -distance]);

	mat4.rotateX(mvMatrix, mvMatrix, t * 0.002);
	mat4.rotateY(mvMatrix, mvMatrix, t * 0.0013);
	mat4.rotateZ(mvMatrix, mvMatrix, t * 0.00047);

	mat3.normalFromMat4(nMatrix, mvMatrix);

	gl.uniformMatrix4fv(pMatrixUniform, false, pMatrix);
	gl.uniformMatrix4fv(mvMatrixUniform, false, mvMatrix);
	gl.uniformMatrix3fv(nMatrixUniform, false, nMatrix);
	gl.uniform1f(timeUniform, t);
	gl.uniform1f(choppinessUniform, cubeChoppiness);
	gl.uniform1f(purplenessUniform, purpleness);
	gl.uniform1f(cubinessUniform, cubiness);
	gl.uniform1f(zFlightUniform, 0);

	gl.uniform3fv(purpleUniform, purple);

	if (addGreen) {
		gl.uniform3fv(greenUniform, green);
	} else {
		gl.uniform3fv(greenUniform, white);
	}

		/* cube */
        gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexPositionBuffer);
        gl.vertexAttribPointer(vertexPositionAttribute, cubeVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);

        gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexNormalBuffer);
        gl.vertexAttribPointer(vertexNormalAttribute, cubeVertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0);

        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
        gl.drawElements(gl.TRIANGLES, cubeVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);

       /* sea */
	mat4.identity(mvMatrix);
	mat4.translate(mvMatrix, mvMatrix, [0, 0, -7]);

	mat3.normalFromMat4(nMatrix, mvMatrix);
	gl.uniformMatrix4fv(mvMatrixUniform, false, mvMatrix);
	gl.uniformMatrix3fv(nMatrixUniform, false, nMatrix);
	gl.uniform3fv(purpleUniform, blue);
	gl.uniform1f(choppinessUniform, choppiness);
	gl.uniform1f(purplenessUniform, 1);
	gl.uniform1f(cubinessUniform, 1);
	gl.uniform1f(zFlightUniform, zFlight);
		gl.uniform3fv(greenUniform, white);

        gl.bindBuffer(gl.ARRAY_BUFFER, seaVertexPositionBuffer);
        gl.vertexAttribPointer(vertexPositionAttribute, seaVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);

        gl.bindBuffer(gl.ARRAY_BUFFER, seaVertexNormalBuffer);
        gl.vertexAttribPointer(vertexNormalAttribute, seaVertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0);

        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, seaVertexIndexBuffer);
        gl.drawElements(gl.TRIANGLES, seaVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);

	raf(tick);
}
raf(tick);

playAYFrameStream(UnVTXFile(f[1]));
