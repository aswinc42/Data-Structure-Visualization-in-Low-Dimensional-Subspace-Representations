function out = evaluate_pop(adjmat, popX)

    % If SINGLE solution (SPSA case)
    if size(popX,1) == 1
        
        cluster = evaluate_cluster(adjmat, popX);
        cluster = squeeze(cluster(:,:,1));

        pairs_list = nchoosek(1:size(cluster,1), 2);
        distance_pairwise = pdist(cluster)';

        G = graph( ...
            pairs_list(:,1)', ...
            pairs_list(:,2)', ...
            distance_pairwise' ...
        );

        T = minspantree(G);

        adj_mat_map_dimn = compute_adjacency_matrix( ...
            T.Edges.EndNodes, ...
            T.Edges.Weight ...
        );

        adj_mat_map_dimn = tril(adj_mat_map_dimn, -1);

        % RETURN scalar objective
        out = norm(adjmat - adj_mat_map_dimn, 'fro');
        return;
    end

    % ---------------- ORIGINAL POPULATION MODE ----------------
    popY = zeros(size(popX, 1), 1);

    parfor k = 1:size(popX, 1)

        cluster = evaluate_cluster(adjmat, popX(k, :));

        pairs_list = nchoosek(1:size(cluster,1), 2);
        distance_pairwise = pdist(cluster)';

        G = graph( ...
            pairs_list(:,1)', ...
            pairs_list(:,2)', ...
            distance_pairwise' ...
        );

        T = minspantree(G);

        adj_mat_map_dimn = compute_adjacency_matrix( ...
            T.Edges.EndNodes, ...
            T.Edges.Weight ...
        );

        adj_mat_map_dimn = tril(adj_mat_map_dimn, -1);

        popY(k) = norm(adjmat - adj_mat_map_dimn, 'fro');
    end

    popY = popY - min(popY);
    out = exp(-popY) / sum(exp(-popY));   % return probabilities
end