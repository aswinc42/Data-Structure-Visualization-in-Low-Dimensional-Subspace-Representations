function Y = split_cluster(X, idx, level, L, Kvec, parentPos, Y)

data = X(idx,:);

% --- STOP CONDITION ---
if level > L
    % Map all points directly
    Yloc = mapFunc(data);

    % Center and superimpose
    Yloc = Yloc - mean(Yloc,1) + parentPos;

    Y(idx,:) = Yloc;
    return;
end

k = Kvec(level);

% --- HAC clustering ---
Z = linkage(data,'ward');
labels = cluster(Z,'maxclust',k);

% --- Compute centroids ---
D = size(X,2);
centroids = zeros(k,D);

for i=1:k
    centroids(i,:) = mean(data(labels==i,:),1);
end

% --- Map centroids ---
lowC = mapFunc(centroids);

% Center centroid layout
lowC = lowC - mean(lowC,1);

% Superimpose on parent
lowC = lowC + parentPos;

% --- Recurse on each child ---
for i=1:k
    childIdx = idx(labels==i);
    Y = split_cluster(X, childIdx, level+1, L, Kvec, lowC(i,:), Y);
end

end
