function result = find_angular_distance_to_closest_point_in_ll(lat,lon,points);

ang_dist = 2*pi;

% first unit vector is always the same
v1 = [sin(lat)*cos(lon) sin(lat)*sin(lon) cos(lat)];

%unit distance is assumed
for ii=1:size(points,1)
	v2 = [sin(points(ii,1))*cos(points(ii,2)) sin(points(ii,1))*sin(points(ii,2)) cos(points(ii,1))];
	alpha = acos(sum(v1.*v2))+points(ii,3);
	if(alpha<ang_dist)
		ang_dist=alpha;
	end
end

result = ang_dist;