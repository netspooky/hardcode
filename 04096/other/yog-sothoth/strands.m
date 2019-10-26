clear
close all

STRANDS = 10;
STEPS = 1000;
ROTATIONRANDOMNESS = 0.001;
ROTATIONPERFRAME = pi/180;
STATICMOVEMENT = [0.5 0 0];

strand = [];
rotationvector = [];
movementvector = [];

%try swirly tentacles

%initialize first
for ii=1:STRANDS
	movementvector(ii, 1:3) = [rand() rand() rand()]*2 - 1;
	rotationvector(ii, 1:3) = ([rand() rand() rand()]*2 - 1)*ROTATIONPERFRAME;
end


% rotate movementvector a bit each frame and add
figure
hold on
for jj=1:STRANDS
	for ii=2:STEPS
		strand(ii,1:3) = [0 0 0];
		rotationvector(jj, 1:3) = rotationvector(jj, 1:3) + ([rand() rand() rand()]*2 - 1)*ROTATIONRANDOMNESS;
		movementvector(jj,1:3) = rotationmatrix(rotationvector(jj,1:3))*movementvector(jj,1:3)'
		strand(ii,1:3)
		movementvector(jj,1:3)
		strand(ii,1:3) = strand(ii-1,1:3) + movementvector(jj,1:3) + STATICMOVEMENT;
	end
	plot3(strand(:,1),strand(:,2),strand(:,3));
end
hold off