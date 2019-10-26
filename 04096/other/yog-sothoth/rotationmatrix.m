function result = rotationmatrix(rvalues)
alpha=rvalues(1);
beta=rvalues(2);
gamma=rvalues(3);

Ra = [	1		0		0
	0		cos(alpha)	-sin(alpha)
	0		sin(alpha)	cos(alpha)]

Rb = [	cos(beta)	0	sin(beta)
	0		1	0
	-sin(beta)	0	cos(beta)]

Rg = [ 	cos(gamma)	-sin(gamma)	0
	sin(gamma)	cos(gamma)	0
	0		0		1]

result = Ra*Rb*Rg;