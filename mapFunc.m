function Y = mapFunc(X)
    N = size(X,1);
    if N < 2
        Y = zeros(N, 2);
        return;
    end

    pairs_list = nchoosek(1:N, 2)';
    dist_vec = pdist(X);
    G = graph(pairs_list(1,:), pairs_list(2,:), dist_vec);
    T = minspantree(G);
    adj_mat_original_min = compute_adjacency_matrix(T.Edges.EndNodes, T.Edges.Weight);
    adj_mat_original_min = tril(adj_mat_original_min, -1);

    [best_param, ~] = stochastic_search(50, 5, 20, 20, adj_mat_original_min);
    Y = evaluate_cluster(adj_mat_original_min, best_param);
end
