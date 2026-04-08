function Y = mapFunc(X)

    N = size(X, 1);

    if N < 2
        Y = zeros(N, 2);
        return;
    end

    % Pairwise graph
    pairs_list = nchoosek(1:N, 2)';
    dist_vec = pdist(X);

    G = graph(pairs_list(1,:), pairs_list(2,:), dist_vec);

    % MST
    T = minspantree(G);

    adj_mat_original_min = compute_adjacency_matrix( ...
        T.Edges.EndNodes, ...
        T.Edges.Weight ...
    );

    adj_mat_original_min = tril(adj_mat_original_min, -1);

    % ---------------- SPSA Optimization ----------------
    num_edges = nnz(adj_mat_original_min);
    theta0 = 2*pi * rand(1, num_edges);

    maxIter = 100;

    [best_param, ~] = spsa_mst_optimize( ...
        adj_mat_original_min, theta0, maxIter ...
    );

    % Final embedding
    Y = evaluate_cluster(adj_mat_original_min, best_param);
    Y = squeeze(Y(:,:,1));
end