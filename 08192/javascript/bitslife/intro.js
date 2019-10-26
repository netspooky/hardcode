V=document.createElement('canvas');
V.style.position='fixed';V.style.top=0;V.style.left=0;
document.body.insertBefore(V,document.body.firstChild);
V.width=W=1680;
V.height=H=1050;
G=V.getContext("webgl");
G.getExtension('OES_texture_float');



/* TEXTURE */
function tex() {
    var i = G.createTexture();
    i.t = G.UNSIGNED_BYTE;
    i.f = G.LINEAR;
    return i;
}
function tex_upload(t, w, h) {
    G.bindTexture(G.TEXTURE_2D, t);
    G.pixelStorei(G.UNPACK_FLIP_Y_WEBGL, true);
    G.texParameteri(G.TEXTURE_2D, G.TEXTURE_MAG_FILTER, t.f);
    G.texParameteri(G.TEXTURE_2D, G.TEXTURE_MIN_FILTER, t.f);
    G.texParameteri(G.TEXTURE_2D, G.TEXTURE_WRAP_S, G.CLAMP_TO_EDGE);
    G.texParameteri(G.TEXTURE_2D, G.TEXTURE_WRAP_T, G.CLAMP_TO_EDGE);
    G.texImage2D(G.TEXTURE_2D, 0, G.RGBA, w, h, 0, G.RGBA, t.t, null);
}
function tex_bind(t, i) {
    G.activeTexture(G.TEXTURE0 + (i === undefined ? 0 : i));
    G.bindTexture(G.TEXTURE_2D, t);
}



/* PROGRAM */
function program(vs, fs) {
    var p = G.createProgram();
    function c(t, d) {
        var s = G.createShader(t);
        G.shaderSource(s, "precision highp float;"+d);
        G.compileShader(s);
        if (!G.getShaderParameter(s, G.COMPILE_STATUS)) { //TODO: not in final
            console.error(d);
            throw G.getShaderInfoLog(s);
        }
        G.attachShader(p, s);
    }
    c(G.VERTEX_SHADER, vs);
    c(G.FRAGMENT_SHADER, fs);
    G.linkProgram(p);
    return p;
}
var program_cur;
function program_use(p) {
    G.useProgram(p);
    program_cur = p;
}



/* MESH */
function mesh() {
    var m = G.createBuffer();
    m.v = [];
    m.m = G.TRIANGLES;
    m.i = 0;
    m.vs = 3;
    m.a = function(v) {
        for(var j = 0; j < v.length; j++)
            m.v[m.i++] = v[j];
    };
    return m;
    //this.outline = [];
}
function mesh_upload(m) {
    G.bindBuffer(G.ARRAY_BUFFER, m);
    G.bufferData(G.ARRAY_BUFFER, new Float32Array(m.v), G.STATIC_DRAW);
}
function mesh_draw(m) {
    G.bindBuffer(G.ARRAY_BUFFER, m);
    var aVertexPos = G.getAttribLocation(program_cur, "aV");
    G.enableVertexAttribArray(aVertexPos);
    G.vertexAttribPointer(aVertexPos, m.vs, G.FLOAT, false, 0, 0);
    G.drawArrays(m.m, 0, m.c);
}

function fbo(w, h) {
    var f = G.createFramebuffer();
    fbo_bind(f);
    var r = G.createRenderbuffer();
    G.bindRenderbuffer(G.RENDERBUFFER, r);
    G.renderbufferStorage(G.RENDERBUFFER, G.DEPTH_COMPONENT16, w, h);
    G.framebufferRenderbuffer(G.FRAMEBUFFER, G.DEPTH_ATTACHMENT, G.RENDERBUFFER, r);
    return f;
}
function fbo_bind(f) {
    G.bindFramebuffer(G.FRAMEBUFFER, f);
}
function fbo_tex(f, t) {
    fbo_bind(f);
    G.framebufferTexture2D(G.FRAMEBUFFER, G.COLOR_ATTACHMENT0, G.TEXTURE_2D, t, 0);
}

function mix(a, b, m) {
    return a*(1-m)+b*m;
}

var mQ = mesh();
mQ.v = [ //TODO => string and split
     1, 1, 0,
    -1, 1, 0,
     1,-1, 0,
     1,-1, 0,
    -1, 1, 0,
    -1,-1, 0
];
mQ.c = 6;
mesh_upload(mQ);

var fF = fbo(W, H);
fbo_bind(fF);
    var tBloom = tex();
    tex_bind(tBloom);
        tex_upload(tBloom, W, H);
    fbo_tex(fF, tBloom);
fbo_bind(null);

var GHF =
"uniform sampler2D uTex,uTex1;"+
"uniform float v[2];"+
"uniform vec2 d0,d1;"+
"varying vec2 uv;"+
"varying vec3 pos;"+
"uniform vec4 c;"+
"varying vec4 col;"+
"float PI=3.14159;"+
"vec2 step=vec2("+W+".,"+H+".),AS=vec2(1.0,"+W+"./"+H+".);"+
"mat4 mProj=mat4(2.,.0,.0,.0,.0,2.4,.0,.0,.0,.0,-1.002,-1.,.0,.0,-.2,.0);"+ //FIXME: replace this 16/10 ratio by a 1/1 ratio proj matrix and mult in the shader acording to screen ratio
"vec3 rotX(float a,vec3 p){return vec3(p.x,p.y*cos(a)-p.z*sin(a),p.z*cos(a)+p.y*sin(a));}"+
"vec3 rotY(float a,vec3 p){return vec3(p.x*cos(a)-p.z*sin(a),p.y,p.z*cos(a)+p.x*sin(a));}"+
"float hash(vec2 p){return -1.+2.*fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453123);}"+
"float noise(vec2 p){vec2 i=floor(p);vec2 f=fract(p);vec2 u=f*f*(3.-2.*f);return mix(mix(hash(i+vec2(.0,.0)),hash(i+vec2(1.,.0)),u.x),mix(hash(i+vec2(.0,1.)),hash(i+vec2(1.,1.)),u.x),u.y);}";

var GHV =
"attribute vec3 aV;"+
GHF;

var pBloom = program(
    GHV+
    "void main(){"+
        "uv=aV.xy*.5+.5;"+
        "gl_Position=vec4(aV,1.);"+
    "}",
    GHF+
    "void main() {"+
        "vec3 a=vec3(0.);"+
        "for(float x=-6.;x<6.;x++){"+
            "for(float y=-6.;y<6.;y++){"+
                "vec4 v=texture2D(uTex,uv+vec2(x,y)/step);"+
                "float l=length(vec2(x,y));"+
                "a+=v.rgb*.25*exp((.05 /(1.-v.a))*-l*l);"+
            "}"+
        "}"+
        "gl_FragColor=vec4(a,1.);"+
    "}"
);



/****************
  BITS ADVECTION
 ****************/
var mBits = mesh();
mBits.v = new Float32Array(512 * 512 * 4);
for(var y = 0; y < 512; y++) {
    for(var x = 0; x < 512; x++) {
        mBits.a([x / 512, y / 512, 0]);
        mBits.a([x / 512, y / 512, 1]);
    }
}
mBits.c = 0; // 512 * 512 * 2 for bouillie
mBits.m = G.LINES;
mesh_upload(mBits);
var tAdv = [tex(), tex()];
for(var i = 0; i <= 1; i++) {
    tAdv[i].t = G.FLOAT;
    tAdv[i].f = G.NEAREST;
    tex_upload(tAdv[i], 512, 512);
}
var pAdv = program(
    GHV+
    "void main(){"+
        "uv=aV.xy*0.5+0.5;"+
        "gl_Position = vec4(aV, 1.0);"+
    "}",
    GHF+
    "void main(){"+
        "vec4 data = texture2D(uTex, uv);"+
        "highp float a = 2.0 * 3.14159 * floor(8.0 * noise(vec2(uv.x * 404.0 + (uv.y * 13.37), 0.3 * v[0]))) / 8.0;"+
        "data.xy += AS*(uv.x * 0.5 + 0.5) * v[1] * 0.8 * vec2(cos(a), sin(a));"+
        "data.xy = mod(data.xy * 0.5 + 0.5, 1.0) * 2.0 - 1.0;"+
        "gl_FragColor = vec4(data.rgb, 1.0);"+
    "}"
);
var pBits = program(
    GHV+
    "varying float d;"+
    "void main(){"+
        "vec2 d0 = texture2D(uTex, aV.xy).xy,"+
             "d1 = texture2D(uTex1, aV.xy).xy;"+
        "d=distance(d0.xy, d1.xy);"+
        "gl_Position = vec4(mix(d0,d1,aV.z),0.,1.);"+
    "}",
    GHF+
    "varying float d;"+
    "void main() {"+
        "if(d>.8) discard;"+
        "gl_FragColor = vec4(0.0, .5, 0.0, 0.5);"+
    "}"
);
var fA = fbo(512, 512);

/**************
  INVIDUAL BIT
 **************/
var mBit = mesh();
mBit.c = 2;
mBit.m = G.LINES;
mBit.v = [0, 0, 0,
          1, 1, 1];
mesh_upload(mBit);
var pBit = program(
    GHV+
    "void main(){"+
        "gl_PointSize = 2.;"+
        "gl_Position=vec4(AS*mix(d0,d1,aV.xy),0.,1.);"+
    "}",
    GHF+
    "void main(){"+
        "if(distance(d0,d1)>.8)discard;"+
        "gl_FragColor=c;"+
    "}"
);

var bit0 = [
    //hello world
    0,1,1,
    -1,0.2,1,
    2,0.5,0.5,
    -1,0.2,1,
    4,1,1,
    -1,0.2,1,
    6,0.5,0.5,
    -1,0.2,1,
    //oh and i can jump
    0,0.3,1,
    1,0.02,2,
    1,0.02,1,
    0,0.01,0.25,
    7,0.02,1,
    7,0.02,2,
    -1,0.1,1,
    0,0.2,1,
    //jumping style
    1,0.02,2,
    1,0.02,1,
    0,0.01,0.25,
    7,0.02,1,
    7,0.02,2,
    -1,0.1,1,
    //one last jump
    0,0.3,1,
    1,0.02,2,
    1,0.02,1,
    0,0.01,0.25,
    7,0.02,1,
    7,0.02,2,
    -1,0.1,1,
    0,1.1,1,

    //oh, someone !
    -1,0.2,1,
    1,0.02,2,
    1,0.02,1,
    0,0.01,0.25,
    7,0.02,1,
    7,0.02,2,
    //hello!
    2,0.5,1.7,
    0,1,1.7,

    //ouch
    3,0.02,2,
    3,0.02,1,
    4,0.01,0.25,
    5,0.02,1,
    5,0.02,2,
    -1,0.05,1,
    //what the hell happened ?
    5,0.04,0.3,
    6,0.01,0.3,
    5,0.04,0.3,
    6,0.01,0.3,
    5,0.04,0.3,
    6,0.01,0.3,
    5,0.04,0.3,
    0,0.04,0.3,
    5,0.04,0.3,
    0,0.04,0.3,
    5,0.04,0.3,
    -1,0.6,1,
    //you just fucking epicly ignored me ?
    //ok, fuck you dude
    3,0.1,0.8,
    2,0.1,1.5,
    1,0.1,2,
    0,0.1,2.5,
    7,0.1,4,
    6,0.1,5,
    5,0.1,5,
    4,1,5,
    5,0.1,5,
    6,0.05,5,
    0,0.05,5,
    4,0.05,5,
    6,0.05,5,
    7,0.1,5,
    0,1,5,
    7,0.1,5,
    6,0.1,5,
    5,0.1,5,
    4,0.1,5,
    3,0.1,5,
    2,0.1,5,
    1,0.1,5,
    -1,0.6,1,

    //roam, sad
    2,0.3,0.9,
    3,0.1,0.8,
    4,0.55,0.65,
    5,0.1,0.6,
    6,0.35,0.5,
    7,0.1,0.4,
    0,0.8,0.4,
    //omg a guuuuurl
    1,0.1,1.5,
    2,0.1,1.5,
    3,0.1,1.5,
    4,0.1,1.5,
    5,0.2,1.5,
    //dat ass
    4,0.65,1.5,
    //cutie!
    5,0.03,1.5,
    6,0.05,1.5,
    7,0.05,1.5,
    1,0.05,1.5,
    2,0.07,1.5,
    3,0.05,1.5,
    4,0.12,1.5,
    5,0.05,1.5,
    6,0.02,1.5,
    //hello there
    -1,0.4,1,
    //kiss me?
    7,0.04,0.2,
    -1,0.2,1,
    //no really, kiss me
    7,0.02,0.2,
    -1,0.9,1,
    // :(
    6,0.02,0.2,
    -1,1.6,1,
    1,0.4,1,
    -1,0.2,1,
    //♥
    1,0.05,2,
    7,0.05,2,
    5,0.1,2,
    3,0.1,2,
    1,0.05,2,
    7,0.05,2,
    -1,0.6,1,
    //wait for me
    6,0.3,1,
    6,0.1,0.5,
    6,0.1,0.25,
    -1,0.6,1,
    //forget it, she doesn't want me
    2,0.1,0.25,
    2,0.1,0.5,
    2,0.6,0.7,
    //did she?
    -1,0.4,1,
    //!
    6,0.5,0.7,
    -1,0.3,1,
    2,0.25,1.5,
    0,0.25,1.5,
    -1,0.35,1,
    4,0.25,1,
    //she is fun
    6,0.05,1,
    0,0.05,1,
    2,0.05,1,
    4,0.05,1,
    -1,0.4,1,
    0,0.05,1,
    6,0.05,1,
    4,0.05,1,
    2,0.05,1,
    0,0.05,1,
    6,0.05,1,
    4,0.05,1,
    2,0.05,1,
    -1,0.6,1,
    //hey you can't do that now
    6,0.05,1,
    -1,0.6,1,
    //watch this!
    3,0.7,1,
    4,0.49,1,

    0,2,40,
    6,0.2,40,
    0,2,40,
    6,0.2,40,
    0,2,40,
    6,0.2,40,
    0,2,40,
    6,0.2,40,
    0,2,40,
    6,0.2,40,
    0,2,40,
    6,0.2,40,
];
var bit1 = [
    -2,16,1,
    //wut?
    4,0.9,0.7,
    //what the hell?
    4,0.15,0.35,
    6,0.02,0.8,
    //who the fuck are you?
    -1,0.452,1,
    //no!
    7,0.02,0.3,
    -1,0.2,1,
    //go kiss your own prepuce
    0,0.02,0.3,
    -1,0.4,0.7,
    //get away from me
    0,0.1,0.5,
    0,0.8,0.7,
    2,0.25,1,
    4,0.65,1,
    //that's cute
    -1,0.6,1,
    //but no
    2,0.02,1,
    -1,0.1,1,
    7,0.02,1,
    5,0.04,1,
    7,0.02,1,
    6,1,0.7,
    0,0.04,0.7,
    6,1.2,0.7,
    //maybe i?
    -1,0.4,1,
    2,0.5,0.7,
    -1,0.4,1,
    6,0.24,1.5,
    4,0.25,1.5,
    -1,0.4,1,
    0,0.26,1,
    //he may be fun
    2,0.05,1,
    4,0.05,1,
    6,0.05,1,
    0,0.05,1,
    -1,0.4,1,
    4,0.05,1,
    2,0.05,1,
    0,0.05,1,
    6,0.05,1,
    4,0.05,1,
    2,0.05,1,
    0,0.05,1,
    6,0.05,1,
    //that was fun, now gtfo
    -1,0.4,1,
    6,0.3,0.7,
    -1,0.4,1,
    0,0.3,0.7,

    -1,0.7,1
];
var bit2 = [
    -2,7.2,1,
    0,0.66,0.7,
    2,0.95,0.74
];
function mod1(v) {
    while(v>1)
        v-=2;
    while(v<-1)
        v+=2;
    return v;
}
function bit_params(bit, t, x0, y0) {
    var u = 0;
    var x = x0, y = y0;
    for(var i = 0; i < bit0.length - 1; i += 3) {
        var dir = bit[i];
        if(dir>=0) {
            x += bit[i+1]*Math.cos(Math.PI*dir/4);
            y += bit[i+1]*Math.sin(Math.PI*dir/4);
        }

        var dur = bit[i+1]/(bit[i+2]*0.3);
        if(u + dur >= t) {
            if(dir==-2) return [13, 37];
            var m = (t - u) / (u + dur - u);
            return [mod1(mix(x0, x, m)), mod1(mix(y0, y, m))];
        }

        x0 = x;
        y0 = y;
        u += dur;
    }
}
function bit_draw(a, b, c) {
    if(a && b) {
        program_use(pBit);
        if(Math.abs(a[0]-b[0])<0.001&&Math.abs(a[1]-b[1])<0.001) {
            mBit.c = 1;
            mBit.m = G.POINTS;
        } else {
            mBit.c = 2;
            mBit.m = G.LINES;
        }
        G.uniform2fv(G.getUniformLocation(pBit, "d0"), a);
        G.uniform2fv(G.getUniformLocation(pBit, "d1"), b);
        G.uniform4fv(G.getUniformLocation(pBit, "c"), c);
        mesh_draw(mBit);
    }
}

/*********
  TERRAIN
 *********/
var size = 50;
var stepx = 0.05;
var mTL = mesh();
mTL.v = new Float32Array((2 * (size + 1) / stepx) * (2 * size + 1) * 3 * 2);
var mT = mesh();
mT.v = new Float32Array((2 * (size + 1) / stepx) * (2 * size + 1) * 3 * 6);
for(var z = -size; z <= size; z += 1) {
    for(var x = -size; x <= size; x += stepx) {
        mTL.a([
            x, 0, z,
            x + stepx, 0, z
        ]);
        mT.a([
            x, 0, z,
            x + stepx, 0, z,
            x, 0, z + 1,
            x, 0, z + 1,
            x + stepx, 0, z,
            x + stepx, 0, z + 1
        ]);
    }
}
mT.c = mT.v.length / 3;
mesh_upload(mT);

mTL.m = G.LINES;
mTL.c = mTL.v.length / 3;
mesh_upload(mTL);

// No time to give that more content :(
var pTv =
    /*"float bg(float v, float a){"+
        "return v>a?v-a:0.;"+
    "}"+*/
    "void main(){"+
        "vec3 camPos = vec3(0.0, 2.-5., 10.0);"+
        "pos=aV;"+

        "pos.y -= 5.;"+ // ocean

        // colors
        "vec4 snow = vec4(1.0, 1.0, 1.0, 0.);"+
        "vec4 grass = vec4(0.0, 1.0, 0.0, 0.);"+
        "vec4 water = vec4(0.25, 0.0, 1.0, .4);"+
        //"vec4 fc=mix(mix(snow, grass, clamp(2.0-pos.y, 0.0, 1.0)), water, clamp(-pos.y,0.,1.));"+
        "col=mix(grass, water, clamp(2.-pos.y,0.,1.));"+
        "col.rgb*=clamp(v[0]-1.,0.,1.);"+ //fadein
        "col.rgb*=clamp(19.-v[0],0.,1.);"+ //fadeout

        "pos.y+=mix(.1*cos(aV.x * 3.0 - v[0]), .3*cos(aV.x * 4.0 - v[0] + 2.), cos(v[0] / 1.)) + sin(aV.z * 6.0);"+ // waves effect
        //"pos.y+=noise(.1*aV.xz - vec2(v[0],0.)) + sin(aV.z * 6.0);"+ // plains (works only on x)
        //"pos.y+=bg(noise(.5*aV.xz), .5);"+ // small islands
        //"pos = aV + vec3(0.0, cos(aV.x * 6.0) + sin(aV.z * 6.0), 0.0);"+
        "vec3 cp = rotX(PI/2.*smoothstep(0.0, 1.0, (9.-v[0])/4.),pos);"+
        "gl_Position = mProj * vec4(cp - camPos, 1.0);"+
    "}";
var pTL = program(
    GHV+
    pTv,
    GHF+
    "void main(){"+
        "gl_FragColor=vec4(col.rgb,(1.-col.w)*.04/gl_FragCoord.w);"+
    "}"
);
var pT = program(
    GHV+
    pTv,
    GHF+
    "void main(){"+
        "gl_FragColor=vec4(vec3(.0),1.);"+
    "}"
);



/*************
  MOTION BLUR
 *************/
var tBlur = [];
for(var i = 0; i <= 1; i++) {
    var t = tex();
    t.t = G.FLOAT;
    t.f = G.NEAREST;
    tex_upload(t, W, H);
    tBlur.push(t);
}
var pBlur = program(
    GHV+
    "void main() {"+
        "uv=aV.xy*.5+.5;"+
        "gl_Position=vec4(aV,1.);"+
    "}",
    GHF+
    "void main() {"+
        "gl_FragColor=vec4(.97,.95,.97,.97)*texture2D(uTex,uv);"+
    "}"
);

var pp = 0; //ping pong

b0x = -0.5; b0y = -0.25;
b1x = 0.75; b1y = -0.25;
b2x = 0; b2y = 0;
var b0a = bit_params(bit0, 0, b0x, b0y);
var b1a = bit_params(bit1, 0, b0x, b0y);
var b2a = bit_params(bit2, 0, b2x, b2y);


G.clearColor(0, 0, 0, 1);
G.enable(G.DEPTH_TEST);
//G.depthFunc(G.LESS);
var params = [0, 0];
var t0, t=0;
function draw() {
    var tn = Date.now();
    var dt = (tn - t0) / 1000;
    t += dt;
    ppn = 1 - pp; // switch ping-pong
    params[0] = t;
    params[1] = dt;

    mBits.c = 0;
    if(t > 31)
        mBits.c = 1;
    if(t > 45)
        mBits.c += 1;
    if(t > 47)
        mBits.c += 1;
    if(t > 49)
        mBits.c += 1;
    if(t > 52)
        mBits.c += 2;
    if(t > 55)
        mBits.c += 4;
    if(t > 55)
        mBits.c += 8;
    if(t > 107)
        mBits.c = 0;
    mBits.c *= 2;

    if(t < 107) { // scene 1
        // ping pong bits
        if(mBits.c > 0) {
            G.viewport(0, 0, 512, 512);
            fbo_bind(fA);
            fbo_tex(fA, tAdv[ppn]);
            G.clear(G.COLOR_BUFFER_BIT | G.DEPTH_BUFFER_BIT);
            program_use(pAdv);
            G.uniform1fv(G.getUniformLocation(pAdv, "v"), params);
            tex_bind(tAdv[pp], 0); G.uniform1i(G.getUniformLocation(pAdv, "uTex"), 0);
            mesh_draw(mQ);
        }

        G.viewport(0, 0, W, H);

        // motion blur
        fbo_bind(fF);
            fbo_tex(fF, tBlur[ppn]);

            // draw last frame * 0.99
            G.clear(G.COLOR_BUFFER_BIT | G.DEPTH_BUFFER_BIT);
            program_use(pBlur);
            tex_bind(tBlur[pp]); G.uniform1i(G.getUniformLocation(pBlur, "uTex"), 0);
            G.uniform1fv(G.getUniformLocation(pBlur, "v"), params);
            mesh_draw(mQ);

            G.clear(G.DEPTH_BUFFER_BIT);
            // draw lots of bits
            if(mBits.c > 0) {
                program_use(pBits);
                tex_bind(tAdv[ppn], 0); G.uniform1i(G.getUniformLocation(pBits, "uTex"), 0);
                tex_bind(tAdv[pp], 1); G.uniform1i(G.getUniformLocation(pBits, "uTex1"), 1);
                mesh_draw(mBits);
            }

            G.clear(G.DEPTH_BUFFER_BIT);
            b0b = bit_params(bit0, t, b0x, b0y);
            bit_draw(b0a, b0b, [0.25, 0, 1, 0]);
            b0a = b0b;

            b1b = bit_params(bit1, t, b1x, b1y);
            bit_draw(b1a, b1b, [1, 0, 0.25, 0]);
            b1a = b1b;

            b2b = bit_params(bit2, t, b2x, b2y);
            bit_draw(b2a, b2b, [0, 1, 0, 0]);
            b2a = b2b;
        fbo_bind(null);

        // bloom
        G.clear(G.COLOR_BUFFER_BIT | G.DEPTH_BUFFER_BIT);
        program_use(pBloom);
        tex_bind(tBlur[ppn]); G.uniform1i(G.getUniformLocation(pBloom, "uTex"), 0);
        mesh_draw(mQ);
    } else { // scene 2
        params[0] = t-107;
        // render to bloom texture
        fbo_bind(fF);
            fbo_tex(fF, tBloom);
            G.clear(G.COLOR_BUFFER_BIT | G.DEPTH_BUFFER_BIT);

            // terrain
            G.enable(G.POLYGON_OFFSET_FILL);
            G.polygonOffset(1, 1);
            program_use(pT);
            G.uniform1fv(G.getUniformLocation(pT, "v"), params);
            mesh_draw(mT);
            G.disable(G.POLYGON_OFFSET_FILL);

            G.enable(G.POLYGON_OFFSET_FILL);
            G.polygonOffset(-2, -2);
            program_use(pTL);
            G.uniform1fv(G.getUniformLocation(pTL, "v"), params);
            mesh_draw(mTL);
            G.disable(G.POLYGON_OFFSET_FILL);
        fbo_bind(null);

        // bloom
        G.clear(G.COLOR_BUFFER_BIT | G.DEPTH_BUFFER_BIT);
        program_use(pBloom);
        tex_bind(tBloom); G.uniform1i(G.getUniformLocation(pBloom, "uTex"), 0);
        mesh_draw(mQ);
    }


    pp = ppn;
    t0 = tn;
    if(window.mozRequestAnimationFrame)
        window.mozRequestAnimationFrame(draw);
    else
        window.requestAnimationFrame(draw);
}
    // Song data
    var song = {
      // Song length in seconds (how much data to generate)
      songLen: 146,  // Tune this to fit your needs!

      songData: [
        { // Instrument 0
          // Oscillator 1
          osc1_oct: 7,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 192,
          osc1_waveform: 2,
          // Oscillator 2
          osc2_oct: 7,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 0,
          osc2_vol: 192,
          osc2_waveform: 3,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 88,
          env_sustain: 137,
          env_release: 25350,
          env_master: 134,
          // Effects
          fx_filter: 2,
          fx_freq: 6620,
          fx_resonance: 198,
          fx_delay_time: 3,
          fx_delay_amt: 95,
          fx_pan_freq: 6,
          fx_pan_amt: 73,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 4,
          lfo_amt: 127,
          lfo_waveform: 1,
          // Patterns
          p: [0,0,0,0,0,0,1,1,2,1,2,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [123,0,0,0,135,0,0,0,123,0,0,0,135,0,0,0,126,0,0,0,138,0,0,0,126,0,0,0,138,0,0,0]},
            {n: [123,0,135,0,135,0,147,0,123,0,135,0,135,0,147,0,126,0,138,0,138,0,150,0,126,0,138,0,138,0,150,0]},
            {n: [149,0,149,0,152,0,152,0,151,0,151,0,154,0,154,0,156,0,0,0,161,0,163,0,0,0,159,0,154,0,0,0]},
            {n: [149,152,154,0,152,154,152,0,156,149,0,0,154,0,147,154,0,0,158,154,159,0,156,156,156,156,0,0,142,0,147,0]},
            {n: [135,135,139,139,140,140,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [152,149,152,0,156,156,0,0,147,0,151,149,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [135,140,147,0,0,0,0,144,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 1
          // Oscillator 1
          osc1_oct: 9,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 192,
          osc1_waveform: 0,
          // Oscillator 2
          osc2_oct: 9,
          osc2_det: 0,
          osc2_detune: 3,
          osc2_xenv: 0,
          osc2_vol: 192,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 200,
          env_sustain: 2000,
          env_release: 20000,
          env_master: 192,
          // Effects
          fx_filter: 2,
          fx_freq: 639,
          fx_resonance: 255,
          fx_delay_time: 3,
          fx_delay_amt: 120,
          fx_pan_freq: 3,
          fx_pan_amt: 60,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 3,
          lfo_amt: 93,
          lfo_waveform: 2,
          // Patterns
          p: [0,0,0,1,2,1,2,1,2,1,2,1,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [142,0,0,0,0,0,0,0,144,0,0,0,140,0,139,0,0,0,0,0,0,0,0,0,137,0,139,0,144,0,0,0]},
            {n: [137,0,146,0,140,0,0,0,142,0,139,0,144,0,0,0,135,0,0,0,140,142,0,0,0,0,139,0,146,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 2
          // Oscillator 1
          osc1_oct: 7,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 192,
          osc1_waveform: 2,
          // Oscillator 2
          osc2_oct: 8,
          osc2_det: 0,
          osc2_detune: 17,
          osc2_xenv: 0,
          osc2_vol: 156,
          osc2_waveform: 2,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 32505,
          env_sustain: 70004,
          env_release: 85661,
          env_master: 150,
          // Effects
          fx_filter: 2,
          fx_freq: 370,
          fx_resonance: 255,
          fx_delay_time: 8,
          fx_delay_amt: 65,
          fx_pan_freq: 0,
          fx_pan_amt: 0,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 0,
          lfo_amt: 0,
          lfo_waveform: 0,
          // Patterns
          p: [1,2,1,2,1,2,1,2,1,2,1,2,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [111,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,114,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [115,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,112,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 3
          // Oscillator 1
          osc1_oct: 7,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 0,
          osc1_waveform: 0,
          // Oscillator 2
          osc2_oct: 7,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 0,
          osc2_vol: 0,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 255,
          // Envelope
          env_attack: 133417,
          env_sustain: 10137,
          env_release: 121713,
          env_master: 214,
          // Effects
          fx_filter: 2,
          fx_freq: 2614,
          fx_resonance: 17,
          fx_delay_time: 2,
          fx_delay_amt: 160,
          fx_pan_freq: 3,
          fx_pan_amt: 109,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 2,
          lfo_amt: 48,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [147,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,149,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [149,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 4
          // Oscillator 1
          osc1_oct: 7,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 192,
          osc1_waveform: 2,
          // Oscillator 2
          osc2_oct: 8,
          osc2_det: 0,
          osc2_detune: 7,
          osc2_xenv: 0,
          osc2_vol: 192,
          osc2_waveform: 2,
          // Noise oscillator
          noise_fader: 49,
          // Envelope
          env_attack: 5970,
          env_sustain: 137,
          env_release: 20000,
          env_master: 255,
          // Effects
          fx_filter: 2,
          fx_freq: 4137,
          fx_resonance: 97,
          fx_delay_time: 2,
          fx_delay_amt: 156,
          fx_pan_freq: 1,
          fx_pan_amt: 31,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 3,
          lfo_amt: 192,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [147,154,0,0,150,157,0,0,154,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 5
          // Oscillator 1
          osc1_oct: 8,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 1,
          osc1_vol: 160,
          osc1_waveform: 0,
          // Oscillator 2
          osc2_oct: 8,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 1,
          osc2_vol: 160,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 158,
          // Envelope
          env_attack: 22,
          env_sustain: 137,
          env_release: 5268,
          env_master: 100,
          // Effects
          fx_filter: 4,
          fx_freq: 11025,
          fx_resonance: 255,
          fx_delay_time: 3,
          fx_delay_amt: 16,
          fx_pan_freq: 5,
          fx_pan_amt: 57,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 1,
          lfo_freq: 4,
          lfo_amt: 60,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        },
        { // Instrument 6
          // Oscillator 1
          osc1_oct: 7,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 1,
          osc1_vol: 192,
          osc1_waveform: 0,
          // Oscillator 2
          osc2_oct: 7,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 1,
          osc2_vol: 192,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 0,
          // Envelope
          env_attack: 22,
          env_sustain: 197,
          env_release: 5970,
          env_master: 99,
          // Effects
          fx_filter: 2,
          fx_freq: 817,
          fx_resonance: 255,
          fx_delay_time: 0,
          fx_delay_amt: 0,
          fx_pan_freq: 0,
          fx_pan_amt: 0,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 0,
          lfo_amt: 0,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,1,2,1,2,6,2,1,2,1,4,5,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [147,0,0,0,0,0,0,0,147,0,147,0,0,0,0,0,0,0,147,147,0,0,0,0,147,0,0,0,147,0,0,0]},
            {n: [147,0,147,0,0,0,0,0,147,0,147,0,0,0,0,0,147,0,147,0,0,0,0,0,147,0,147,0,0,0,0,0]},
            {n: [147,147,0,0,147,0,0,0,147,147,147,0,147,147,147,0,147,0,147,147,0,0,147,0,147,0,147,147,0,0,147,0]},
            {n: [0,0,0,0,0,0,0,0,147,0,0,0,0,0,0,0,147,0,0,0,0,0,0,0,147,0,0,0,0,0,0,0]},
            {n: [147,147,147,0,147,0,0,0,147,0,0,0,147,0,147,0,0,0,0,0,147,0,0,0,147,0,147,0,147,0,0,0]},
            {n: [147,147,147,0,0,0,0,0,147,0,147,0,0,0,0,0,0,0,147,147,147,0,0,0,147,0,147,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,147,0,0,0,0]}
          ]
        },
        { // Instrument 7
          // Oscillator 1
          osc1_oct: 0,
          osc1_det: 0,
          osc1_detune: 0,
          osc1_xenv: 0,
          osc1_vol: 0,
          osc1_waveform: 0,
          // Oscillator 2
          osc2_oct: 0,
          osc2_det: 0,
          osc2_detune: 0,
          osc2_xenv: 0,
          osc2_vol: 0,
          osc2_waveform: 0,
          // Noise oscillator
          noise_fader: 255,
          // Envelope
          env_attack: 49,
          env_sustain: 137,
          env_release: 4611,
          env_master: 11,
          // Effects
          fx_filter: 0,
          fx_freq: 11025,
          fx_resonance: 255,
          fx_delay_time: 0,
          fx_delay_amt: 0,
          fx_pan_freq: 0,
          fx_pan_amt: 0,
          // LFO
          lfo_osc1_freq: 0,
          lfo_fx_freq: 0,
          lfo_freq: 0,
          lfo_amt: 0,
          lfo_waveform: 0,
          // Patterns
          p: [0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
          // Columns
          c: [
            {n: [147,147,0,147,0,147,147,147,0,0,147,0,147,0,0,0,147,147,0,147,147,147,0,147,0,147,147,0,147,147,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},
            {n: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
          ]
        }
      ],
      rowLen: 11025,   // In sample lengths
      endPattern: 18  // End pattern
    };


//**************************************************************************
// End of Music
//**************************************************************************

// Wave data configuration
var WAVE_SIZE = 44100 * song.songLen; // Total song size (in samples)

// Work buffers
var chnBufWork, mixBufWork;


//--------------------------------------------------------------------------
// Private methods
//--------------------------------------------------------------------------

// Initialize buffers etc. (constructor)
(function ()
{
    // Note 1: We use a CanvasPixelArray instead of a traditional ECMAScript
    // array of numbers, since that gives us a typed byte array (much more
    // compact, and quite fast).
    //
    // Note 2: We would LIKE to create an (N x 1) bitmap buffer, but some
    // browsers (hrrr-o-mme...) have an upper bitmap size limit of
    // 32767 x 32767, so we create a square bitmap buffer (with some
    // trailing bytes that we don't care too much about)
    var size = Math.ceil(Math.sqrt(WAVE_SIZE));

    var ctx = document.createElement('canvas').getContext('2d');

    // Create the channel work buffer
    chnBufWork = ctx.createImageData(size, size).data;

    // Create & clear the channel mix buffer
    var b, mixBuf = ctx.createImageData(size, size).data;
    for(b = size * size * 4 - 2; b >= 0 ; b -= 2)
    {
        mixBuf[b] = 0;
        mixBuf[b + 1] = 128;
    }
    mixBufWork = mixBuf;
})();

// Oscillators
function osc_sin(value)
{
    return Math.sin(value * 6.283184);
}

function osc_square(value)
{
    if(osc_sin(value) < 0) return -1;
    return 1;
}

function osc_saw(value)
{
    return (value % 1) - 0.5;
}

function osc_tri(value)
{
    var v2 = (value % 1) * 4;
    if(v2 < 2) return v2 - 1;
    return 3 - v2;
}

function getnotefreq(n)
{
    return 0.00390625 * Math.pow(1.059463094, n - 128);
}


//--------------------------------------------------------------------------
// Public members
//--------------------------------------------------------------------------

// Number of lines per second (song speed)
//var lps = WAVE_SPS / song.rowLen;


//--------------------------------------------------------------------------
// Public methods
//--------------------------------------------------------------------------

// Generate audio data for a single track
function generate(track)
{
    // Array of oscillator functions
    var oscillators =
    [
        osc_sin,
        osc_square,
        osc_saw,
        osc_tri
    ];

    // Local variables
    var i, j, k, b, p, row, n, currentpos, cp,
        c1, c2, q, low, band, high, t, lfor, e, x,
        rsample, f, da, o1t, o2t;

    // Preload/precalc some properties/expressions (for improved performance)
    var chnBuf = chnBufWork,
        mixBuf = mixBufWork,
        waveSamples = WAVE_SIZE,
        waveBytes = WAVE_SIZE * 4,
        instr = song.songData[track],
        rowLen = song.rowLen,
        osc_lfo = oscillators[instr.lfo_waveform],
        osc1 = oscillators[instr.osc1_waveform],
        osc2 = oscillators[instr.osc2_waveform],
        attack = instr.env_attack,
        sustain = instr.env_sustain,
        release = instr.env_release,
        panFreq = Math.pow(2, instr.fx_pan_freq - 8) / rowLen,
        lfoFreq = Math.pow(2, instr.lfo_freq - 8) / rowLen;

    // Clear buffer
    for(b = 0; b < waveBytes; b += 2)
    {
        chnBuf[b] = 0;
        chnBuf[b+1] = 128;
    }

    currentpos = 0;
    for(p = 0; p < song.endPattern - 1; ++p) // Patterns
    {
        cp = instr.p[p];
        for(row = 0;row < 32; ++row) // Rows
        {
            if(cp)
            {
                n = instr.c[cp - 1].n[row];
                if(n)
                {
                    c1 = c2 = 0;

                    // Precalculate frequencues
                    o1t = getnotefreq(n + (instr.osc1_oct - 8) * 12 + instr.osc1_det) * (1 + 0.0008 * instr.osc1_detune);
                    o2t = getnotefreq(n + (instr.osc2_oct - 8) * 12 + instr.osc2_det) * (1 + 0.0008 * instr.osc2_detune);

                    // State variable init
                    q = instr.fx_resonance / 255;
                    low = band = 0;
                    for (j = attack + sustain + release - 1; j >= 0; --j)
                    {
                        k = j + currentpos;

                        // LFO
                        lfor = osc_lfo(k * lfoFreq) * instr.lfo_amt / 512 + 0.5;

                        // Envelope
                        e = 1;
                        if(j < attack)
                            e = j / attack;
                        else if(j >= attack + sustain)
                            e -= (j - attack - sustain) / release;

                        // Oscillator 1
                        t = o1t;
                        if(instr.lfo_osc1_freq) t += lfor;
                        if(instr.osc1_xenv) t *= e * e;
                        c1 += t;
                        rsample = osc1(c1) * instr.osc1_vol;

                        // Oscillator 2
                        t = o2t;
                        if(instr.osc2_xenv) t *= e * e;
                        c2 += t;
                        rsample += osc2(c2) * instr.osc2_vol;

                        // Noise oscillator
                        if(instr.noise_fader) rsample += (2*Math.random()-1) * instr.noise_fader * e;

                        rsample *= e / 255;

                        // State variable filter
                        f = instr.fx_freq;
                        if(instr.lfo_fx_freq) f *= lfor;
                        f = 1.5 * Math.sin(f * Math.PI / 44100);
                        low += f * band;
                        high = q * (rsample - band) - low;
                        band += f * high;
                        switch(instr.fx_filter)
                        {
                            case 1: // Hipass
                                rsample = high;
                                break;
                            case 2: // Lopass
                                rsample = low;
                                break;
                            case 3: // Bandpass
                                rsample = band;
                                break;
                            case 4: // Notch
                                rsample = low + high;
                            default:
                        }

                        // Panning & master volume
                        t = osc_sin(k * panFreq) * instr.fx_pan_amt / 512 + 0.5;
                        rsample *= 39 * instr.env_master;

                        // Add to 16-bit channel buffer
                        k <<= 2;
                        x = chnBuf[k] + (chnBuf[k+1] << 8) + rsample * (1 - t);
                        chnBuf[k] = x & 255;
                        chnBuf[k+1] = (x >> 8) & 255;
                        x = chnBuf[k+2] + (chnBuf[k+3] << 8) + rsample * t;
                        chnBuf[k+2] = x & 255;
                        chnBuf[k+3] = (x >> 8) & 255;
                    }
                }
            }
            currentpos += rowLen;
        }
    }

    // Delay
    p = (instr.fx_delay_time * rowLen) >> 1;
    t = instr.fx_delay_amt / 255;

    for(n = 0; n < waveSamples - p; ++n)
    {
        b = 4 * n;
        k = 4 * (n + p);

        // Left channel = left + right[-p] * t
        x = chnBuf[k] + (chnBuf[k+1] << 8) +
            (chnBuf[b+2] + (chnBuf[b+3] << 8) - 32768) * t;
        chnBuf[k] = x & 255;
        chnBuf[k+1] = (x >> 8) & 255;

        // Right channel = right + left[-p] * t
        x = chnBuf[k+2] + (chnBuf[k+3] << 8) +
            (chnBuf[b] + (chnBuf[b+1] << 8) - 32768) * t;
        chnBuf[k+2] = x & 255;
        chnBuf[k+3] = (x >> 8) & 255;
    }

    // Add to mix buffer
    for(b = 0; b < waveBytes; b += 2)
    {
        x = mixBuf[b] + (mixBuf[b+1] << 8) + chnBuf[b] + (chnBuf[b+1] << 8) - 32768;
        mixBuf[b] = x & 255;
        mixBuf[b+1] = (x >> 8) & 255;
    }
}

// Create an HTML audio element from the generated audio data
function createAudio()
{
    // Local variables
    var b, k, x, wave, l1, l2, s, y;

    // Turn critical object properties into local variables (performance)
    var mixBuf = mixBufWork,
        waveBytes = WAVE_SIZE * 4;

    // We no longer need the channel working buffer
    chnBufWork = null;

    // Convert to a WAVE file (in a binary string)
    l1 = waveBytes - 8;
    l2 = l1 - 36;
    wave = String.fromCharCode(82,73,70,70,
                               l1 & 255,(l1 >> 8) & 255,(l1 >> 16) & 255,(l1 >> 24) & 255,
                               87,65,86,69,102,109,116,32,16,0,0,0,1,0,2,0,
                               68,172,0,0,16,177,2,0,4,0,16,0,100,97,116,97,
                               l2 & 255,(l2 >> 8) & 255,(l2 >> 16) & 255,(l2 >> 24) & 255);
    for (b = 0; b < waveBytes;)
    {
        // This is a GC & speed trick: don't add one char at a time - batch up
        // larger partial strings
        x = "";
        for (k = 0; k < 256 && b < waveBytes; ++k, b += 2)
        {
            // Note: We amplify and clamp here
            y = 4 * (mixBuf[b] + (mixBuf[b+1] << 8) - 32768);
            y = y < -32768 ? -32768 : (y > 32767 ? 32767 : y);
            x += String.fromCharCode(y & 255, (y >> 8) & 255);
        }
        wave += x;
    }

    // Convert the string buffer to a base64 data uri
    s = "data:audio/wav;base64," + btoa(wave);
    wave = null;

    // Return the music as an audio element
    return new Audio(s);
}

for (var tr = 0; tr < 8; tr++)
    generate(tr);
var audio = createAudio();
audio.addEventListener('play', function() {
    t0 = Date.now();
    draw();
}, false);
audio.play();


/*
t0 = Date.now();
draw();
*/
