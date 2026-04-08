function Y = recursive_hac_mapping(X, L, Kvec)

% X      : N x D data
% L      : number of levels
% Kvec   : [k1 k2 ... kL]
% mapFunc: function handle for dimensionality reduction

[N, D] = size(X);

% Storage for final low-dim (2D) coordinates
Y = zeros(N,2);          % Y = zeros(N, size(mapFunc(X(1:min(5,end),:)),2));

% Start recursion
indices = (1:N)';
parentPos = zeros(1, size(Y,2)); % root centered at origin

Y = split_cluster(X, indices, 1, L, Kvec, parentPos, Y);

end
