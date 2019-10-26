clear;
close all;

TEX_RES_IN_LAT = 100;
TEX_RES_IN_LON = 100;
SPIKES = 10;
TESTPOINTS = 500000;

% Form the spikes by multiplying the matrices with the function required. We want the spikes to cover around 10 degrees of arc, which means pi/20, we also want them to be about an unit distance high, so multiply by that scale
ANGULAR_SCALE_VARIANCE = 0.2;
ANGULAR_SCALE = pi/20+ANGULAR_SCALE_VARIANCE;
SCALE = (1/ANGULAR_SCALE)*2;

% To counter accuracy difference in latitude and longtitude, let's sample both when determining whether a point is inside or outside
tex_lalo = zeros(TEX_RES_IN_LAT,TEX_RES_IN_LON);
%tex_lola = zeros(TEX_RES_IN_LON,TEX_RES_IN_LAT);

% Beginning of texture generation
% First uniform distribution of points on ball surface, algorithm from Marsaglia (1972)
ii=1;
while (ii<=SPIKES)
	temp = rand(1,2)*2-1;
	if(sqrt(sum(temp.^2))<1)
		x = 2*temp(1)*sqrt(1-sum(temp.^2));
		y = 2*temp(2)*sqrt(1-sum(temp.^2));
		z = 1-2*sum(temp.^2);
		% We only want the spikes on the top half, discard any that are lower than z=0
%		if(z>0)
			coords(ii,1) = x;
			coords(ii,2) = y;
			coords(ii,3) = z;
			ii = ii+1;
%		end
	end
end

% Map points to dots in the texture matrices, as pseudo as possible
for ii=1:SPIKES
	x = coords(ii,1);
	y = coords(ii,2);
	z = coords(ii,3);
	coords_ll(ii,1) = acos(z/sqrt(x^2+y^2+z^2));
	coords_ll(ii,2) = atan2(y,x);
	% Randomize point intensity
	coords_ll(ii,3) = rand()*ANGULAR_SCALE_VARIANCE;
	% debug, check if everything is correct, map the point to the textures
	lat = TEX_RES_IN_LAT*coords_ll(ii,1)/pi;
	lon = TEX_RES_IN_LON*(pi+coords_ll(ii,2))/(2*pi);
	if((ceil(lat)<=TEX_RES_IN_LAT)&&(ceil(lon)<=TEX_RES_IN_LON))	
		tex_lalo(ceil(lat),ceil(lon))=1;
%		tex_lola(ceil(lon),ceil(lat))=1;
	else
		break
	end
end

% degub, test that the distribution is uniform at this point
figure
imagesc([-90:90], [-180:180], tex_lalo');
%figure
%imagesc([-180:180], [-90:90], tex_lola');

%pause

% Initialize matrices to be more than any angular distance
tex_lalo(:,:) = 2*pi;
%tex_lola(:,:) = 2*pi;

% The following operation is heavy and n*m, where n is the amount of pixels in the textures and m is the amount of spikes we want
% Using the list of points, filter the texture matrices by going over every point, finding the closest spike point, calculating angular distance and normalizing spike falloff as a function of that distance
for ii=1:TEX_RES_IN_LAT
	for jj=1:TEX_RES_IN_LON
		lat = pi*ii/TEX_RES_IN_LAT;
		lon = 2*pi*jj/TEX_RES_IN_LON-pi;
		dist = find_angular_distance_to_closest_point_in_ll(lat,lon,coords_ll);
		if(dist<tex_lalo(ii,jj)) tex_lalo(ii,jj) = dist; end
	end
end
%for ii=1:TEX_RES_IN_LON
%	for jj=1:TEX_RES_IN_LAT
%		lat = pi*jj/TEX_RES_IN_LAT;
%		lon = pi*ii/TEX_RES_IN_LON-pi/2;
%		dist = find_angular_distance_to_closest_point_in_ll(lat,lon,coords_ll);
%		if(dist<tex_lola(ii,jj)) tex_lola(ii,jj) = dist; end
%	end
%end


figure
imagesc([-90:90], [-180:180], tex_lalo');
%figure
%imagesc([-180:180], [-90:90], tex_lola');

tex_lalo = SCALE*max(ANGULAR_SCALE-tex_lalo, 0);
%tex_lola = SCALE*max(ANGULAR_SCALE-tex_lola, 0);

figure
imagesc([-90:90], [-180:180], tex_lalo');
%figure
%imagesc([-180:180], [-90:90], tex_lola');

% Test the form. Monte Carlo point accumulation inside/outside the shape, look at the accumulating shape in plot3 inside an unit box going from -2,-2 to 2,2. As pseudo as possible.
points = [];
jj=1;
for ii=1:TESTPOINTS
	testp = 4*(rand(1,3)-0.5);
	x = testp(1);
	y = testp(2);
	z = testp(3);
	c_lat = acos(z/sqrt(x^2+y^2+z^2));
	c_lon = atan(y/x);
	c_r = sqrt(sum(testp.^2));
	% Transform coordinates to coordinates inside textures
	lat = TEX_RES_IN_LAT*c_lat/pi;
	lon = TEX_RES_IN_LON*(pi/2+c_lon)/pi;
	% Check if point is inside & near the shell surface
	if((z>=0)&&(c_r> 0.95)&&(lat>-0.1)&&(c_r<tex_lalo(ceil(lat),ceil(lon))+1))
		points(jj,:) = testp;
		jj=jj+1;
	end
	% Transform coordinates to coordinates inside textures if we co directly up towards the sphere
	r_xy = sqrt(x^2+y^2);
	c_lat2 = asin(r_xy);
	h = sin(pi/2-asin(r_xy));
	lat2 = TEX_RES_IN_LAT*c_lat2/pi;
	if((z<0)&&(c_r> 0.95)&&(r_xy<1)&&(z>-tex_lalo(ceil(lat2),ceil(lon))-h))
		points(jj,:) = testp;
		jj=jj+1;
	end
end

figure
plot3(points(:,1),points(:,2),points(:,3),'k.');