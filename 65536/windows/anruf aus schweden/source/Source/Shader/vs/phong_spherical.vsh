!!ARBvp1.0

PARAM	view[4]		= { state.matrix.modelview };
PARAM	proj[4]		= { state.matrix.projection };

PARAM	lightPos	= program.env[0];
PARAM	viewPos		= program.env[1];

PARAM	model[4]	= { program.env[2..5] };

TEMP	pos, viewSpacePos, dist;

# transform into view space
DP4		viewSpacePos.x, view[0], vertex.position;
DP4		viewSpacePos.y, view[1], vertex.position;
DP4		viewSpacePos.z, view[2], vertex.position;
DP4		viewSpacePos.w, view[3], vertex.position;

# spherical projection: viewPos.z = ( viewSpacePos.z + ( viewSpacePos - cameraPos ) ) / 2
SUB		dist, viewSpacePos, view[3];
DP3		dist.w, dist, dist;
RSQ		dist.w, dist.w;
RCP		dist.w, dist.w;
ADD		viewSpacePos.z, viewSpacePos, -dist.w;
MUL		viewSpacePos.z, viewSpacePos, 0.5;

# transform into screen space
DP4		result.position.x, proj[0], viewSpacePos;
DP4		result.position.y, proj[1], viewSpacePos;
DP4		result.position.z, proj[2], viewSpacePos;
DP4		result.position.w, proj[3], viewSpacePos;

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
#SUB		view, viewPos, pos;
#DP3		view.w, view, view;
#RSQ		view.w, view.w;
#MUL		result.texcoord[2].xyz, view, view.w;
SUB			result.texcoord[2], viewPos, pos;

END