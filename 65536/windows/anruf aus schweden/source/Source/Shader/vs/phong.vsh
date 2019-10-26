!!ARBvp1.0

PARAM	mvp[4]		= { state.matrix.mvp };

PARAM	lightPos	= program.env[0];
PARAM	viewPos		= program.env[1];

PARAM	model[4]	= { program.env[2..5] };

TEMP	pos;

# transform into screen space
DP4		result.position.x, mvp[0], vertex.position;
DP4		result.position.y, mvp[1], vertex.position;
DP4		result.position.z, mvp[2], vertex.position;
DP4		result.position.w, mvp[3], vertex.position;

# normal in world space
DP3		result.texcoord[0].x, model[0], vertex.normal;
DP3		result.texcoord[0].y, model[1], vertex.normal;
DP3		result.texcoord[0].z, model[2], vertex.normal;

# vertex pos in world space
DP4		pos.x, model[0], vertex.position;
DP4		pos.y, model[1], vertex.position;
DP4		pos.z, model[2], vertex.position;
DP4		pos.w, model[3], vertex.position;

# light vector
SUB		result.texcoord[1], lightPos, pos;

# view vector
SUB		result.texcoord[2], viewPos, pos;

END