function adj_mat = compute_adjacency_matrix(nodes, weights)
    N = max(nodes(:));
    adj_mat = zeros(N);
    adj_mat(sub2ind([N N], nodes(:,1), nodes(:,2))) = weights;
    % Symmetric: upper to lower + diag 0
    adj_mat = tril(adj_mat + adj_mat' - diag(diag(adj_mat')), -1);
end
