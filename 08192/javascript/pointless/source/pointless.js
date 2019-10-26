// GLOBALS - Ought to be removed in the final version
var winWidth, winHeight, winRatio;	// Window size
var glCtx;				// WebGL context
var timeStart;				// Start time
var rngState=0,rngMax=0x7ffffffe,rngMult=2147483629,rngInc=2147483587; // Random number generator state & constants
var bVertices = [ ] , pVertices = [ ];	// Vertex data
var projMatrix;
var beastColormap, beastProg , beastBuffer, beasts = [];
var plants = [] , plantProg , plantBuffer , plantInstances = [];
var floorProg , floorBuffer;


// Vector operations
var vecDot = function(a,b) {
	var s = 0;
	for ( var i in a ) {
		s += a[i]*b[i];
	}
	return s;
};
var vecAdd = function(a,b) {
	var t = [];
	for ( var i in a ) {
		t[i] = a[i]+b[i];
	}
	return t;
};
var vecMul = function(a,v) {
	var t = [];
	for ( var i in a ) {
		t[i] = a[i]*v;
	}
	return t;
};
var vecSub = function(a,b) {
	return vecAdd(a,vecMul(b,-1));
};
var vecLen = function(a) {
	return Math.sqrt( vecDot(a,a) )
};
var vecNorm = function(a) {
	var l = vecLen(a);
	if ( l ) {
		for ( var i in a ) {
			a[i] /= l;
		}
	}
	return l;
};
var vecCross = function(a,b) {
	return [
		a[1]*b[2]-a[2]*b[1] ,
		a[2]*b[0]-a[0]*b[2] ,
		a[0]*b[1]-a[1]*b[0]
	];
};

// Matrix tools
var mkRotationMatrix = function(yaw,pitch,roll) {
	var c1 = Math.cos(yaw), s1 = Math.sin(yaw) ,
		c2 = Math.cos(pitch), s2 = Math.sin(pitch) ,
		c3 = Math.cos(roll), s3 = Math.sin(roll);
	return [
		c1 * c3 + s1 * s2 * s3 , c3 * s1 * s2 - c1 * s3 , c2 * s1 , 0 ,
		c2 * s3 , c2 * c3 , -s2 , 0 ,
		c1 * s2 * s3 - c3 * s1 , s1 * s3 + c1 * c3 * s2 , c1 * c2 , 0 ,
		0 , 0 , 0 , 1
	];
};

var mkTranslationMatrix = function(tv) {
	return [1,0,0,0,
	        0,1,0,0,
		0,0,1,0,
		tv[0],tv[1],tv[2],1
	];
};

var multiplyMatrix = function( m1 , m2 ) {
	var r = [];
	for ( var i = 0 ; i < 4 ; i ++ ) {
		for ( var j = 0 ; j < 4 ; j ++ ) {
			r.push( m1[i*4] * m2[j] + m1[i*4+1]*m2[j+4] + m1[i*4+2]*m2[j+8] + m1[i*4+3]*m2[j+12] );
		}
	}
	return r;
};

var vecMulMat = function( v , m ) {
	var r = [];
	for ( var i = 0 ; i < 4 ; i ++ ) {
		var n = 0;
		for ( var j = 0 ; j < 4 ; j ++ ) {
			n += v[j] * m[i*4+j];
		}
		r.push(n);
	}
	return r;
};

// Write vector components to an array
var putVecs = function(target,vecs) {
	for ( var i in vecs ) {
		target.push.apply( target, vecs[i] );
	}
};


// This definitely needs to be removed in the final version
var printLog = function (msg) {
	if (window.console && window.console.log) {
		window.console.log(msg);
	}
};

// Initialise the canvas. Should be inlined of course.
var initCanvas = function () {
	with ( document.body ) {
		innerHTML = '<canvas id=theCanvas>';
		style.margin = 0;
	}

	with ( theCanvas ) {
		width = winWidth = innerWidth;
		height = winHeight = innerHeight;
		winRatio = width / height;
		for ( var key in glCtx = getContext( 'experimental-webgl' ) ) {
			var nKey = key.match(/^..|[A-Z]|\df$/g).join('');
			//printLog( key + ' -> ' + nKey );
			if ( glCtx[ nKey ] ) {
//				printLog( '/!\\ Already exists' );
			} else {
				glCtx[ nKey ] = key;
			}
		}
	}
};


// This function loads a shader. Obviously, it should be mostly limited to
// createShader/shaderSource/compileShader for release. Still, no error checks, I
// cannot be bothered.
var loadShader = function( name ) {
	var sourceTag = document.getElementById( name );
	var source = '';
	var de = sourceTag.firstChild;
	while ( de ) {
		if ( de.nodeType == 3 ) {
			source += de.textContent;
		}
		de = de.nextSibling;
	}

	var shader = glCtx.createShader( sourceTag.type == "x-shader/x-fragment" ? glCtx.FRAGMENT_SHADER : glCtx.VERTEX_SHADER );
	glCtx.shaderSource( shader , source );
	glCtx.compileShader( shader );

	return shader;
};


// Random number generator
var rnd = function( ) {
	return ( rngState = ( rngState * rngMult + rngInc ) % ( rngMax + 1 ) )
};
var rndFloat = function() {
	return rnd() / rngMax
};
var rndRange = function(first,last) {
	return first + Math.round( ( last - first ) * rndFloat() )
};


var makeBeastColormap = function() {
	var data = [] , d2 = [];
	for ( var i = 0 ; i < 512 ; i ++ ) {
		var r,g,b, v = i / 512.;
		if ( v < .4 ) {
			r = .5 + 1.25 * v;
			g = .5 + 1.25 * v;
			b = .25 + 1.25 * v;
		} else {
			r = 1 - ( 5 * v - 2 ) * .116;
			g = 1 - ( 5 * v - 2 ) / 3;
			b = .75 - Math.min( 1 , 5 * v - 2 ) * .75;
		}
		data.push(Math.round(255*r),Math.round(255*g),Math.round(255*b),1);

		v *= 3;
		r = Math.max( 0 , 1 - Math.min( v * v , ( v - 3 ) * ( v - 3 ) ) );
		g = Math.max( 0 , 1 - ( v - 1 ) * ( v - 1 ) );
		g = Math.max( 0 , 1 - ( v - 2 ) * ( v - 2 ) );
		d2.push(Math.round(255*r),Math.round(255*g),Math.round(255*b),1);

	}
	beastColormap = glCtx.createTexture();
	glCtx.bindTexture( glCtx.TEXTURE_2D , beastColormap );
	glCtx.texImage2D( glCtx.TEXTURE_2D, 0, glCtx.RGBA, 512 , 2, 0 , glCtx.RGBA, glCtx.UNSIGNED_BYTE, new Uint8Array(data.concat(d2)) );
	glCtx.texParameteri(glCtx.TEXTURE_2D, glCtx.TEXTURE_MIN_FILTER, glCtx.LINEAR);
};


var makeBeast = function() {
	var vlen = 0;
	for ( var b = 0 ; b < 5 ; b ++ ) {
		for ( var sz = .5 ; sz < 1.5 ; sz += rndFloat() * .5 ) {
			for ( var ca = 0 ; ca < Math.PI * 2 ; ca += ( rndFloat() + .1 ) * .75 ) {
				var z = rndRange( -10 , 10 ) , y = rndRange( -10 , 10 ) , xInc = rndRange( 0 , 10 ) + rndFloat();
				for ( var i = 0 ; i < rndRange( 50 , 150 ) ; i ++ ) {
					bVertices.push( xInc , y + rndFloat() - .5 , z + rndFloat() - .5 ,
							i , ca , sz ,
							rndFloat() , rndFloat() , rndFloat() * .25 , rndFloat() * 10.  );
				}
			}
		}
		var beastPoints = bVertices.length / 10 - vlen;
//		printLog( 'beast ' + ( b + 1 ) + ': points: ' + beastPoints );
		beasts[b] = {f:vlen,n:beastPoints};
		vlen += beastPoints;
	}
};

var makeModelMatrix = function(r,p) {
	return multiplyMatrix( mkRotationMatrix(r[0],r[1],r[2]),
			mkTranslationMatrix( p ) );
};


// Create the projection matrix. Most of this should be hardcoded.
var mkProjMatrix = function( ) {
	var sz = 1 / Math.tan( Math.PI / 8 );
	return [
		sz/winRatio,	0,		0,		0,
		0,		sz,		0,		0,
		0,		0,		1/1024,		1,
		0,		0,		-1,		0
	];
};

var mkViewMatrix = function(pos,lookat,angle) {
	var dir = vecSub(lookat,pos);
	vecNorm(dir);
	var pitch = Math.asin( -dir[1] );
	var yaw = Math.atan2( dir[0] , dir[2] );
	return multiplyMatrix( mkTranslationMatrix( vecMul(pos,-1) ) , mkRotationMatrix(yaw,pitch,angle) );
};


var createFloor = function() {
	var SZ = 1000;
	var r = [] , x , z;
	for ( x = 0 ; x < SZ ; x ++ ) {
		var m = x%2,i=m?-1:1;
		r.push( x , z = m?SZ:0 );
		while ( m ? ( z > 0 ) : ( z < SZ ) ) {
			r.push(
					x + 1 , z ,
					x , z + i
			      );
			z += i;
		}
		if ( x < SZ - 1 ) {
			r.push( x + 1 , z );
		}
	}
	return r;
};


var setupBeast = function(t) {
	glCtx.enable(glCtx.BLEND);
	glCtx.disable(glCtx.DEPTH_TEST);
	glCtx.blendFunc( glCtx.SRC_ALPHA , glCtx.ONE );

	glCtx.bindBuffer( glCtx.ARRAY_BUFFER , beastBuffer );
	glCtx.useProgram( beastProg );
	var ptrs = [
		{ n : 'Position' , s : 3 } ,
		{ n : 'Distance' , s : 1 } ,
		{ n : 'Angle' , s : 1 } ,
		{ n : 'Radius' , s : 1 } ,
		{ n : 'Brightness' , s : 4 }
	];
	var offs = 0;
	for ( var i in ptrs ) {
		var pos = glCtx.getAttribLocation( beastProg , "a_" + ptrs[i].n );
		glCtx.enableVertexAttribArray( pos );
		glCtx.vertexAttribPointer( pos , ptrs[i].s , glCtx.FLOAT , false , 40 , offs );
		offs += ptrs[i].s * 4;
	}
	glCtx.uniform1f( glCtx.getUniformLocation( beastProg , 'u_Time' ) , t );
	glCtx.uniform1i( glCtx.getUniformLocation( beastProg, "u_Colormap" ) , 0 );
};


var drawFloor = function(pos,tm) {
	glCtx.enable(glCtx.DEPTH_TEST);
	glCtx.disable(glCtx.BLEND);

	glCtx.bindBuffer( glCtx.ARRAY_BUFFER , floorBuffer );
	glCtx.useProgram( floorProg );
	glCtx.enableVertexAttribArray( 0 );
	glCtx.vertexAttribPointer( 0 , 2 , glCtx.FLOAT , false , 8 , 0 );

	glCtx.uniform3fv( glCtx.getUniformLocation( floorProg , 'u_CamPos' ) , pos );
	glCtx.uniformMatrix4fv( glCtx.getUniformLocation( floorProg , 'u_Transformations' ) , false , tm );
	glCtx.drawArrays( glCtx.TRIANGLE_STRIP , 0 , 1997999 );
};

var setupPlant = function(t,pos) {
	glCtx.enable(glCtx.BLEND);
	glCtx.disable(glCtx.DEPTH_TEST);
	glCtx.blendFunc( glCtx.SRC_ALPHA , glCtx.ONE );

	glCtx.bindBuffer( glCtx.ARRAY_BUFFER , plantBuffer );
	glCtx.useProgram( plantProg );
	var ptrs = [
		{ n : 'Position' , s : 3 } ,
		{ n : 'Point' , s : 1 }
	];
	var offs = 0;
	for ( var i in ptrs ) {
		var pos = glCtx.getAttribLocation( plantProg , "a_" + ptrs[i].n );
		glCtx.enableVertexAttribArray( pos );
		glCtx.vertexAttribPointer( pos , ptrs[i].s , glCtx.FLOAT , false , 16 , offs );
		offs += ptrs[i].s * 4;
	}
};


var triangleWave = function(x,period) {
	var m = x%period , v = 2 * m / period;
	return ( m < period / 2 ) ? v : ( 2 - v );
};


// Function that draws the scene. Should be inlined.
var nFrames = 0 , lTime = 0;
var defs = [
	// Time , CamPos , CamTarget , CamAngle ,
	//	Plant wave frequency , Plant wave amplitude , Plant colour change , Plant distortion ,
	//	[ Beast0Pos, Beast0Rot, ... ]
	[ 8 , '0,(8-t)*225-100,-250' , '0,-100,300' , 0 ,
		4 , 25 , 0 , 0 ,
		[ ] , 1
	] ,
	[ 12 , '150,-100,(t-8)*60-200' , '0,-100,(t-8)*60-200' , '.05*(8-t)' ,
		4 , 25 , 0 , 0 ,
		[ ] , 1
	] ,
	[ 16 , '-150,-100,(t-8)*60+200' , '0,-100,(t-8)*60+200' , '.05*(t-12)' ,
		4 , 25 , 0 , 0 ,
		[ ] , 1
	] ,
	[ 24 , 'x=Math.cos((t-16)*Math.PI/8)*150,Math.sin((t-16)*Math.PI/8)*100,(t-16)*60+400' , 'x,-30,(t-16)*60+650' , '.1*(t-20)' ,
		4 , 25 , 0 , 0 ,
		[ ] , 1
	] ,
	[ 32 , 'x=Math.cos((t-16)*Math.PI/8)*150,Math.sin((32-t)*Math.PI/8)*100,(t-16)*60+400' , 'x,t-54,(t-16)*60+650' , '.1*(28-t)' ,
		'4-(t-24)/4' , '25+(t-24)*.5' , 0 , 0 ,
		[ ] , 0
	] ,
	[ 46 , 'x=150+300*Math.sin((t-32)*Math.PI/4),0,(t-32)*90+1360' , 'x,10-t,(t-32)*90+1610' , '-.4*Math.cos((t-32)*Math.PI/4)' ,
		2 , 29 , 'triangleWave(t,.5)*.75' , 0 ,
		[ ] , 0
	] ,
	[ 48 , 'x=150+300*Math.sin((t-32)*Math.PI/4),0,(t-32)*90+1360' , 'x,10-t,(t-32)*90+1610' , 0 ,
		2 , 29 , 'triangleWave(t,.5)*.75' , 0 ,
		[ ] , 0
	] ,
	[ 64 , 'x=750-Math.cos(a=(t-48)*Math.PI/16)*600,0,z=Math.sin(a)*600+2800' , 'x+Math.sin(a),-.15,z+Math.cos(a)' , '-.4*triangleWave(t-48,16)' ,
		2 , '29-(t-48)/16' , 0 , '(t%2<1.375)?0:triangleWave(t,.0725)' ,
		[ '2950-(t-48)*100,-75,2380' , '0,0,0' , '(t-48)*100-250,-75,2450' , 'Math.PI,0,0' ] , 0
	] ,

	[ 80 , '1350,(t-64)*10,x=2800-(t-64)*150' , '1350,-60,x-420' , 0 ,
		2 , 25 , 'triangleWave(t,.5)*.75' , 0 ,
		[ '1350-Math.sin(a=(t-64)*Math.PI/4)*150,-75,2380-(t-64)*150' , 'triangleWave(t,8)*Math.PI,0,0' ,
			'1350+Math.sin(a)*150,-75,2450-(t-64)*150' , 'Math.PI*(1-triangleWave(t,8)),0,0' ] , 0
	] ,

	[ 96 , '2000,-20,0' , 'x=1000+(t-80)*125,-20,200' , '.1*(t-88)' ,
		2 , 25 , 'triangleWave(t,.5)*.75' , 0 ,
		[ 'x,0,100' , 'Math.PI,0,0' ,
			'x+40*Math.cos(t),75*Math.sin(t*.5),100+75*Math.cos(t*.5)' , 'Math.PI,0,0' ,
			'x+40*Math.sin(t),-75*Math.sin(t*.5),100-75*Math.cos(t*.5)' , 'Math.PI,0,0' ] , 1
	] ,
	[ 112 , '-1500-(t-96)*62.5,50,0' , 'x=-1000-(t-96)*125,50,500' , 0,
		2 , 25 , 'triangleWave(t,.5)*.75' , 0 ,
		[ 'x+50,50,500+Math.sin(a=(t-96)*Math.PI/4)*125' , 'w=(1.5+triangleWave(t,8))*Math.PI,0,0' ,
			'x,50,500-Math.sin(a)*125', '-w,0,0' ,
			'x-100,50-Math.cos(a)*125,540', '0,0,w=(triangleWave(t+2,8)-.5)*.5*Math.PI' ,
			'x+80,50+Math.cos(a)*125,460', '0,0,-w' ,
		] , 1
	] ,
	[ 136 , '(120-t)*40-1000,200,-2000' , '(112-t)*125,(t-112)*25-50,-1500' , 0,
		2 , 25 , 'triangleWave(t,.5)*.75' , '(t%2<1.375)?0:triangleWave(t,.0725)' ,
		[
			'(112-t)*125+80,(t-112)*25-50*Math.cos(t),50*Math.sin(t)-1500', '0,0,0' ,
			'(112-t)*125+40,(t-112)*25-50*Math.cos(t+1),50*Math.sin(t+1)-1500', '0,0,0' ,
			'(112-t)*125,(t-112)*25-50*Math.cos(t+2),50*Math.sin(t+2)-1500', '0,0,0' ,
			'(112-t)*125-40,(t-112)*25-50*Math.cos(t+3),50*Math.sin(t+3)-1500', '0,0,0' ,
			'(112-t)*125-80,(t-112)*25-50*Math.cos(t+4),50*Math.sin(t+4)-1500', '0,0,0' ,
		] , 1
	]
];
var drawScene = function(){
	var t = ( new Date( ).getTime( ) - timeStart ) / 1000.0;
	//if ( t >= 12 ) return;

	var pos, la, angle, pWave, pCol, pDist, bs=[];
	var d;
	if ( timeStart ) {
		var shifted = 0;
		if ( defs.length && defs[0][0] < t ) {
			defs.shift();
			shifted = 1;
		}
		if ( ! defs.length ) {
			return;
		}
		d = defs[0];
		if ( d[9] && shifted ) {
			clearFrameBuffers( );
		}
	} else {
		t = 80;
		d = defs[8];
	}
	eval('pos=['+d[1]+'],la=['+d[2]+'],angle='+d[3]+',pWave=('+d[5]+')*Math.sin(2*t*Math.PI/('+d[4]+')),pCol='+d[6]+',pDist='+d[7]);
	for ( var bi = 0 ; bi < d[8].length / 2 ; bi ++ ) {
		eval( 'bs[bi]=[['+d[8][bi*2]+'],['+d[8][bi*2+1]+']]' );
	}

	glCtx.clearColor( 0, .025, .05 , 1.);
	glCtx.clear( glCtx.COLOR_BUFFER_BIT | glCtx.DEPTH_BUFFER_BIT );
	var wvm = mkViewMatrix(pos,la,angle);
	var dir = vecSub( la , pos );
	vecNorm( dir );
	drawFloor(pos,multiplyMatrix( wvm , projMatrix ));

	glCtx.bindFramebuffer( glCtx.FRAMEBUFFER , framebuffers[curFB] );
	glCtx.clearColor( 0,0,0,1 );
	glCtx.clear( glCtx.COLOR_BUFFER_BIT );
	glCtx.bindTexture( glCtx.TEXTURE_2D , beastColormap );

	setupPlant();
	glCtx.uniformMatrix4fv( glCtx.getUniformLocation( plantProg , 'u_Transformations' ) , false , multiplyMatrix( wvm , projMatrix ) );
	glCtx.uniform3fv( glCtx.getUniformLocation( plantProg , 'u_CamPos' ) , pos );
	glCtx.uniform1f( glCtx.getUniformLocation( plantProg , 'u_Wave' ) , pWave );
	glCtx.uniform1f( glCtx.getUniformLocation( plantProg , 'u_Distort' ) , pDist );
	glCtx.uniform1f( glCtx.getUniformLocation( plantProg , 'u_ColourChange' ) , pCol * .5 );
	glCtx.uniform1i( glCtx.getUniformLocation( plantProg, "u_Colormap" ) , 0 );
	if ( bs.length >= 3 ) {
		bp = [0,0,0];
		for ( var i in bs ) {
			bp = vecAdd(bp,bs[i][0]);
		}
		glCtx.uniform3fv( glCtx.getUniformLocation( plantProg , 'u_BeastPos' ) , vecMul(bp,1/bs.length) );
	} else {
		glCtx.uniform3fv( glCtx.getUniformLocation( plantProg , 'u_BeastPos' ) , [0,-2000,0] );
	}

	for ( var n in plantInstances ) {
		var p = plantInstances[n];
		var d = vecSub( [ p.x , -200 , p.y ] , pos );
		var l = vecLen(d);
		if ( l > 1400 ) {
			continue;
		}

		vecNorm(d);
		d = vecDot( d , dir );
		if ( d < 0 && l > 300 ) {
			continue;
		}

		var lod = Math.floor( ( 1400 - l ) / 350 );
		glCtx.uniform1f( glCtx.getUniformLocation( plantProg, "u_MinSize" ) , 10 + ( 3 - lod ) );
		glCtx.uniform1f( glCtx.getUniformLocation( plantProg, "u_MaxSize" ) , 20 + ( 3 - lod ) * 3 );
		glCtx.uniform2f( glCtx.getUniformLocation( plantProg, "u_Position" ) , p.x , p.y );
		glCtx.uniform1f( glCtx.getUniformLocation( plantProg, "u_Rotate" ) , p.r );
		glCtx.uniform1f( glCtx.getUniformLocation( plantProg, "u_Colour" ) , p.c );
		glCtx.drawArrays( glCtx.POINTS , plants[p.i][lod].f , plants[p.i][lod].n );
	}

	setupBeast(t);
	for ( var bi in bs ) {
		var ti = t + bi * .7;
		var tmm = makeModelMatrix(bs[bi][1],bs[bi][0]);
		var tm = multiplyMatrix( multiplyMatrix( tmm , wvm ) , projMatrix );
		glCtx.uniformMatrix4fv( glCtx.getUniformLocation( beastProg , 'u_Transformations' ) , false , tm );
		glCtx.uniform1f( glCtx.getUniformLocation( beastProg , 'u_Compress' ) , Math.cos(ti) * .15 + .25 ); 
		glCtx.uniform1f( glCtx.getUniformLocation( beastProg , 'u_RotateRelative' ) , Math.sin(ti* .07) * Math.PI / 100 ); 
		glCtx.uniform1f( glCtx.getUniformLocation( beastProg , 'u_RotateWhole' ) , t ); 
		glCtx.uniform3f( glCtx.getUniformLocation( beastProg , 'u_TailAngle' ) , 0 , 50 * Math.sin(ti*.1) , 50 * Math.sin(ti*.1) );
		glCtx.drawArrays( glCtx.POINTS , beasts[bi].f , beasts[bi].n );
	}

	glCtx.bindBuffer( glCtx.ARRAY_BUFFER , fsBuffer );
	glCtx.useProgram( passthruProg );
	var ptrs = [
		{ n : 'Position' , s : 2 }
	];
	var offs = 0;
	for ( var i in ptrs ) {
		var pos = glCtx.getAttribLocation( textProg , "a_" + ptrs[i].n );
		glCtx.enableVertexAttribArray( pos );
		glCtx.vertexAttribPointer( pos , ptrs[i].s , glCtx.FLOAT , false , 8 , offs );
		offs += ptrs[i].s * 4;
	}
	glCtx.uniform1i( glCtx.getUniformLocation( passthruProg , 'u_Texture' ) , 0 );
	glCtx.uniform2f( glCtx.getUniformLocation( passthruProg , 'u_Screen' ) , winWidth, winHeight );

	glCtx.bindFramebuffer( glCtx.FRAMEBUFFER , null );
	for ( var i = 1 ; i <= N_FRAME_BUFFERS ; i ++ ) {
		glCtx.bindTexture( glCtx.TEXTURE_2D , fbTextures[(curFB+i)%N_FRAME_BUFFERS] );
		glCtx.uniform1f( glCtx.getUniformLocation( passthruProg , 'u_Decay' ) , Math.pow(2.5,i-N_FRAME_BUFFERS) );
		glCtx.drawArrays( glCtx.TRIANGLES , 0 , 6 );
	}


	glCtx.bindBuffer( glCtx.ARRAY_BUFFER , textBuffer );
	glCtx.useProgram( textProg );
	var ptrs = [
		{ n : 'Position' , s : 2 } ,
		{ n : 'Amplitude' , s : 1 } ,
		{ n : 'OscSpeed' , s : 1 } ,
		{ n : 'UpSpeed' , s : 1 } ,
		{ n : 'SizeVariation' , s : 1 }
	];
	var offs = 0;
	for ( var i in ptrs ) {
		var pos = glCtx.getAttribLocation( textProg , "a_" + ptrs[i].n );
		glCtx.enableVertexAttribArray( pos );
		glCtx.vertexAttribPointer( pos , ptrs[i].s , glCtx.FLOAT , false , 24 , offs );
		offs += ptrs[i].s * 4;
	}
	glCtx.uniform2f( glCtx.getUniformLocation( textProg , 'u_Screen' ) , winWidth, winHeight );

	for ( var i in text ) {
		var sd = text[i];
		if ( sd.sTime > t ) {
			continue;
		}

		var rt = Math.max( 0 , t - sd.rTime );
		if ( rt > winHeight/160 ) {
			continue;
		}

		glCtx.uniform2f( glCtx.getUniformLocation( textProg, "u_BasePos" ) , sd.x, sd.y );
		glCtx.uniform1f( glCtx.getUniformLocation( textProg, "u_Size" ) , winWidth/(7*sd.size) );
		glCtx.uniform1f( glCtx.getUniformLocation( textProg, "u_Rise" ) , rt );
		glCtx.uniform1f( glCtx.getUniformLocation( textProg, "u_Time" ) , t );
		glCtx.drawArrays( glCtx.POINTS , sd.first , sd.count );
	}

	if ( timeStart && t - lastFBSwitch > .05 ) {
		curFB = ( curFB + 1 ) % N_FRAME_BUFFERS;
		lastFBSwitch = t;
	}

	nFrames ++;
	//printLog( 'pos: ' + pos + '; la: ' + la );
	if ( Math.floor(t) > lTime ) {
		//printLog( 'fps ~ ' + nFrames + ' ; pos: ' + pos + '; la: ' + la );
		nFrames = 0 , lTime = Math.floor(t);
	}
};


var lsExpand = function(input,rdepth,rules) {
	var output = '';
	for ( var i = 0 ; i < input.length ; i ++ ) {
		var ch = input.charAt( i );
		if ( rules[ch] && ( rdepth || rules.terms.indexOf(ch)+1 ) ) {
			var tweight = 0;
			for ( var r in rules[ch] ) {
				tweight += rules[ch][r][0];
			}
			var rv = rnd();
			var val = rv%tweight;
			for ( var r in rules[ch] ) {
				if ( val < rules[ch][r][0] ) {
					output += rules[ch][r][1];
					break;
				}
				val -= rules[ch][r][0];
			}
		} else {
			output += ch;
		}
	}

	if ( rdepth > 0 ) {
		return lsExpand( output , rdepth - 1 , rules );
	}

	for ( var i = 0 ; i < rules.terms.length ; i ++ ) {
		if ( output.indexOf( rules.terms.charAt( i ) ) + 1 ) {
			return lsExpand( output , 0 , rules );
		}
	}

	//printLog( 'produced (rdepth = ' + rdepth + '): ' + output );
	return rdepth ? lsExpand( output , rdepth - 1 , rules ) : output;
};

var lsGen = function(input) {
	var state = {pos:[0,0,0],rot:[0,0,Math.PI/2],l:0} , stack = [] , lines = [], mlen = 0;
	var angle = Math.PI/13, rep = 0;
	for ( var i = 0 ; i < input.length ; i ++ ) {
		var instr = input.charAt(i);
//		printLog('next instr: ' + instr + '; state: ' + state.pos + ' / ' + state.rot + ' / ' + state.l);
		if ( '0123456789'.indexOf( instr ) != -1 ) {
			rep = rep * 10 + instr;
			continue;
		}
		switch(instr) {
			case 'F':
				dmat = mkRotationMatrix(state.rot[0],state.rot[1],state.rot[2]);
				(dvec = vecMulMat([1,0,0,1],dmat)).pop();
				lines.push([state.pos,ivec=vecAdd(state.pos,dvec),state.l]);
				state.pos=ivec;
				if ( ++ state.l > mlen ) {
					mlen = state.l;
				}
				break;
			case '+':
				state.rot[0] += angle;
				break;
			case '-':
				state.rot[0] -= angle;
				break;
			case '&':
				state.rot[1] += angle;
				break;
			case '^':
				state.rot[1] -= angle;
				break;
			case '<':
				state.rot[2] += angle;
				break;
			case '>':
				state.rot[2] -= angle;
				break;
			case '[':
				stack.push({pos:[].concat(state.pos),rot:[].concat(state.rot),l:state.l});
				break;
			case ']':
				state = stack.pop();
				break;
		}
		if ( rep ) {
			rep -- , i --;
		}
	}
//	printLog('exit state: ' + state.pos + ' / ' + state.rot + ' / ' + state.l);

	var r = [ ];
	for ( var NPOINTS = 2; NPOINTS < 6 ; NPOINTS ++ ) {
		var f = pVertices.length;
		pVertices.push( 0,0,0,0 );
		for ( var l in lines ) {
			var ln = lines[l], s = ln[0] , e = ln[1] , ll = ln[2] , v = vecSub(e,s) , d = vecMul(v,1/NPOINTS);
			for ( var i = 1 ; i <= NPOINTS ; i ++ ) {
				pVertices.push.apply( pVertices ,
					vecMul( vecAdd( s , vecMul( d , i ) ) , 12 ).concat( ( ll * NPOINTS + i ) / ( mlen * NPOINTS ) )
				);
			}
		}
		r.push( {f:f/4,n:(pVertices.length-f)/4} );
	}
	return r;
};

var font = [
	[255,17,17,17,18,252],		// A
	[255,145,145,145,170,196],	// B
	[60,66,129,129,129,66],		// C
	[255,129,129,129,130,124],	// D
	[127,145,145,145,144,128],	// E
	[254,17,17,17,17,1],		// F
	[60,66,129,145,145,98],		// G
	[255,16,16,23,56,192],		// H
	[129,129,255,129,129,129],	// I
	[97,128,128,127,1,1],		// J
	[255,16,24,36,66,129],		// K
	[127,128,128,128,128,128],	// L
	[255,2,12,12,2,255],		// M
	[255,2,12,48,64,255],		// N
	[126,129,129,129,129,126],	// O
	[255,17,17,17,10,4],		// P
	[126,129,129,161,193,254],	// Q
	[255,17,17,49,74,132],		// R
	[132,138,145,145,81,33],	// S
	[2,1,1,255,1,1],		// T
	[127,128,128,128,128,127],	// U
	[15,112,128,128,112,15],	// V
	[255,64,32,32,64,255],		// W
	[195,36,24,24,36,195],		// X
	[131,68,40,16,12,3],		// Y
	[129,193,161,145,141,131]	// Z
];

var renderLetter = function(output,index,column) {
	for ( var lCol = 0 ; lCol < 6; lCol ++ ) {
		var b = font[index][lCol];
		var row = 7;
		//printLog( 'lcol = ' + lCol );
		while ( b ) {
			if ( b & 1 ) {
				output.push(column+lCol,row,rndRange(-15,15),1+rndFloat()*4,rndRange(160,240),rndFloat()*.25);
			}
			b >>= 1;
			row --;
		}
	}
//	printLog( output );
};

var renderString = function(output,string) {
	var olen = output.length;
	var column = 0;
	for ( var i = 0 ; i < string.length ; i ++ ) {
		var cc = string.charCodeAt( i ) - 65;
		if ( cc >= 0 ) {
			renderLetter(output,cc,column);
		}
		column += 7;
	}
	return ( output.length - olen ) / 6;
};

var renderText = function(vertices) {
	var data = [
		{ text:'THETOURIST',x:-.9,y:.55,size:30,sTime:1,rTime:4.25 } ,
		{ text:'IS ASHAMED TO PRESENT',x:-.85,y:.43,size:50,sTime:3,rTime:4 } ,
		{ text:'POINTLESS',x:-.9,y:.4,size:10,sTime:8,rTime:14 } ,

		{ text:'ADINPSZ',x:-.56,y:.65,size:25,sTime:64,rTime:65 } ,
		{ text:'ASD',x:0,y:.55,size:25,sTime:65,rTime:66 } ,
		{ text:'BRAIN CONTROL',x:-.92,y:.45,size:25,sTime:66,rTime:67 } ,
		{ text:'COCOON',x:0,y:.35,size:25,sTime:67,rTime:68 } ,
		{ text:'FAIRLIGHT',x:-.72,y:.25,size:25,sTime:68,rTime:69 } ,
		{ text:'FARBRAUSCH',x:0,y:.15,size:25,sTime:69,rTime:70 } ,

		{ text:'KEWLERS',x:-.56,y:.65,size:25,sTime:70,rTime:71 } ,
		{ text:'LNX',x:0,y:.55,size:25,sTime:71,rTime:72 } ,
		{ text:'POPSY TEAM',x:-.8,y:.45,size:25,sTime:72,rTime:73 } ,
		{ text:'RAZOR MCMXI',x:0,y:.35,size:25,sTime:73,rTime:74 } ,
		{ text:'RGBA',x:-.32,y:.25,size:25,sTime:74,rTime:75 } ,
		{ text:'SEVENTH CUBE',x:-.1,y:.15,size:25,sTime:75,rTime:76 } ,

		{ text:'STILL',x:-.4,y:.65,size:25,sTime:76,rTime:77 } ,
		{ text:'TIM',x:0,y:.55,size:25,sTime:77,rTime:78 } ,
		{ text:'TPOLM',x:-.4,y:.45,size:25,sTime:78,rTime:79 } ,
		{ text:'UMLAUT DESIGN',x:-.08,y:.35,size:25,sTime:79,rTime:80 } ,
		{ text:'XMEN',x:-.32,y:.25,size:25,sTime:80,rTime:81 } ,
		{ text:'YOUTH UPRISING',x:-.12,y:.15,size:25,sTime:81,rTime:82 } ,

		{ text:'AND OF COURSE EVERYONE',x:-.88,y:.55,size:25,sTime:82,rTime:86.5 } ,
		{ text:'HERE AT DEMOJS MMXIII',x:-.84,y:.35,size:25,sTime:83,rTime:86 } ,

		{ text:'SO SORRY FOR MAKING YOU WATCH THIS',x:-.64,y:0,size:50,sTime:84,rTime:88 }
	];
	var offset = 0;
	for ( var i in data ) {
		data[i].first = offset;
		data[i].count = renderString(vertices,data[i].text);
		offset += data[i].count;
	}
	return data;
};


var createFramebuffer = function(index){
	glCtx.bindTexture( glCtx.TEXTURE_2D , fbTextures[index] = glCtx.createTexture( ) );
	glCtx.texParameteri( glCtx.TEXTURE_2D , glCtx.TEXTURE_WRAP_S, glCtx.CLAMP_TO_EDGE );
	glCtx.texParameteri( glCtx.TEXTURE_2D , glCtx.TEXTURE_WRAP_T, glCtx.CLAMP_TO_EDGE );
	glCtx.texParameteri( glCtx.TEXTURE_2D , glCtx.TEXTURE_MIN_FILTER, glCtx.NEAREST );
	glCtx.texParameteri( glCtx.TEXTURE_2D , glCtx.TEXTURE_MAG_FILTER, glCtx.NEAREST );
	glCtx.texImage2D( glCtx.TEXTURE_2D, 0, glCtx.RGBA, winWidth , winHeight , 0 , glCtx.RGBA, glCtx.UNSIGNED_BYTE, null );
	glCtx.bindFramebuffer( glCtx.FRAMEBUFFER , framebuffers[index] = glCtx.createFramebuffer( ) );
	glCtx.framebufferTexture2D( glCtx.FRAMEBUFFER, glCtx.COLOR_ATTACHMENT0, glCtx.TEXTURE_2D, fbTextures[index], 0);
};

var clearFrameBuffers = function(){
	glCtx.clearColor( 0,0,0,1 );
	for ( var i = 0 ; i < N_FRAME_BUFFERS ; i ++ ) {
		glCtx.bindFramebuffer(glCtx.FRAMEBUFFER, framebuffers[i]);
		glCtx.clear( glCtx.COLOR_BUFFER_BIT );
	}
	glCtx.bindFramebuffer(glCtx.FRAMEBUFFER, null);
};


// MAIN PROGRAM
// Should be executed directly, but in this version it is called by the body's onload

var N_FRAME_BUFFERS = 4;

var main = function(){
	initCanvas( );

	glCtx.blendFunc( glCtx.SRC_ALPHA , glCtx.ONE );
	glCtx.depthFunc(glCtx.GEQUAL);
	glCtx.clearDepth( -1. );
	glCtx.viewport( 0 , 0 , winWidth , winHeight );

	framebuffers = [];
	fbTextures = [];
	for ( var i = 0 ; i < N_FRAME_BUFFERS ; i ++ ) createFramebuffer(i);
	curFB = lastFBSwitch = 0;

	beastProg = glCtx.createProgram( );
	glCtx.attachShader( beastProg , loadShader( 'vs-beast' ) );
	glCtx.attachShader( beastProg , loadShader( 'fs-beast' ) );
	glCtx.linkProgram( beastProg );

	floorProg = glCtx.createProgram( );
	glCtx.attachShader( floorProg , loadShader( 'vs-floor' ) );
	glCtx.attachShader( floorProg , loadShader( 'fs-floor' ) );
	glCtx.linkProgram( floorProg );

	plantProg = glCtx.createProgram( );
	glCtx.attachShader( plantProg , loadShader( 'vs-plant' ) );
	glCtx.attachShader( plantProg , loadShader( 'fs-plant' ) );
	glCtx.linkProgram( plantProg );

	textProg = glCtx.createProgram( );
	glCtx.attachShader( textProg , loadShader( 'vs-text' ) );
	glCtx.attachShader( textProg , loadShader( 'fs-text' ) );
	glCtx.linkProgram( textProg );

	passthruProg = glCtx.createProgram( );
	glCtx.attachShader( passthruProg , loadShader( 'vs-screen' ) );
	glCtx.attachShader( passthruProg , loadShader( 'fs-draw' ) );
	glCtx.linkProgram( passthruProg );

	projMatrix = mkProjMatrix();
	makeBeast();
	makeBeastColormap( );

	beastBuffer = glCtx.createBuffer( );
	glCtx.bindBuffer( glCtx.ARRAY_BUFFER , beastBuffer );
	glCtx.bufferData( glCtx.ARRAY_BUFFER ,
			new Float32Array( bVertices ) ,
			glCtx.STATIC_DRAW );

	floorBuffer = glCtx.createBuffer( );
	glCtx.bindBuffer( glCtx.ARRAY_BUFFER , floorBuffer );
	glCtx.bufferData( glCtx.ARRAY_BUFFER ,
			new Float32Array(createFloor()) ,
			glCtx.STATIC_DRAW );

	fsBuffer = glCtx.createBuffer( );
	glCtx.bindBuffer( glCtx.ARRAY_BUFFER , fsBuffer );
	glCtx.bufferData( glCtx.ARRAY_BUFFER ,
			new Float32Array([-1,1,-1,-1,1,1,1,1,-1,-1,1,-1]) ,
			glCtx.STATIC_DRAW );

	// Final version will need more models with != grammars
	for ( var i = 0 ; i < 30 ; i ++ ) {
		var out = lsExpand('.' , rndRange(9,13) , {
			terms: 'DEHIJ' ,
			'.' : [ [ 1 , '>>>>>A' ] , [ 4 , 'G' ] ] ,
			A : [ [ 1 , '[B]++[B]++[B]++[B]++[B]++[B]++[B]++[B]++[B]++[B]++[B]++[B]++[B]++' ] ] ,
			B : [ [ 1 , 'FECB' ] , [ 1 , 'FFECB' ] , [ 1 , 'FFC<B' ] ] ,
			C : [ [ 1 , '' ] , [ 1 , '[DB]' ] , [ 1 , 'CC' ] ] ,
			D : [ [ 1 , '&' ] , [ 1 , '^' ] , [ 1 , '<' ] , [ 4 , '>' ] , [ 1 , '+' ] , [ 1 , '-' ] ] ,
			E : [ [ 1 , '' ] , [ 2 , '<' ] , [ 1 , '>' ] ] ,
			G : [ [ 1 , '[HFG]FG' ]  ] ,
			H : [ [3,'I'],[2,'II'],[1,'III'] ],
			I : [ [1,'&J'],[1,'^J'] ] ,
			J : [ [1,''],[2,'+'],[2,'-'],[2,'<'],[2,'>'] ]
		} );
		plants[i] = lsGen( out );
	}
	for ( var i = -4000 , p = 0 ; i < 4000 ; i += 180 ) {
		for ( var j = -4000 ; j < 4000 ; j += 180 ) {
			plantInstances[p++] = {
				x: i + rndRange(-70,70) ,
				y: j + rndRange(-70,70) ,
				c: rndFloat( ) ,
				r: rndFloat( ) * Math.PI * 2. ,
				i: rndRange(0,29)
			};
		}
	}

	plantBuffer = glCtx.createBuffer( );
	glCtx.bindBuffer( glCtx.ARRAY_BUFFER , plantBuffer );
	glCtx.bufferData( glCtx.ARRAY_BUFFER ,
			new Float32Array(pVertices) ,
			glCtx.STATIC_DRAW );

	tVertices = [];
	text = renderText(tVertices);

	textBuffer = glCtx.createBuffer( );
	glCtx.bindBuffer( glCtx.ARRAY_BUFFER , textBuffer );
	glCtx.bufferData( glCtx.ARRAY_BUFFER ,
			new Float32Array(tVertices) ,
			glCtx.STATIC_DRAW );

	var USESONANT = 1, audio;
	if ( USESONANT ) {
		var songGen = new sonant();
		for (var t = 0; t < 6; t++) songGen.generate(t);
		audio = songGen.createAudio();
	}

	timeStart = 0; drawScene( ); glCtx.clear( glCtx.COLOR_BUFFER_BIT | glCtx.DEPTH_BUFFER_BIT ); clearFrameBuffers( );
	setTimeout(function(){
		if ( !USESONANT ) {
			htmlElementForSound = document.createElement("audio");
			htmlElementForSound.autoplay = true;
			htmlElementForSoundSource = document.createElement("source");
			htmlElementForSoundSource.src = 'music.wav';
			htmlElementForSound.appendChild(htmlElementForSoundSource);
		}

		setInterval(drawScene,32);
		timeStart = new Date( ).getTime( );
		if ( USESONANT ) {
			audio.play();
		}
		drawScene( )
	} , 1000 );
};
