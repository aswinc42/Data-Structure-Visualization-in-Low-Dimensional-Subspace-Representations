function points = generateHyperspherePoints(numPoints, dimension, radius, centre)

% Generates random points within a hypersphere.

rand_rad = radius * rand(numPoints, 1);
rand_dir_cosines = -1 + (2 .* rand(numPoints, dimension));

points = zeros(numPoints, dimension);
for m = 1:numPoints
    points(m,:) = rand_rad(m) * rand_dir_cosines(m,:);
    points(m,:) = points(m,:) + centre;
end

points = cat(1, centre, points);

% figure; scatter(points(:,1), points(:,2), 40, 'filled')