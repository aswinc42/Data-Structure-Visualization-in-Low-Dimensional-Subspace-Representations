function[count] = eval_metric_mapping(cluster, mapped_data, eps)

pairs_list = transpose(nchoosek(1:size(cluster,1),2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Original data
distance_pairwise_cluster = pdist(cluster);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mapped data
distance_pairwise_mapped_data = pdist(mapped_data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pairwise_ratio = distance_pairwise_cluster./distance_pairwise_mapped_data;

bool_upper = pairwise_ratio < (1+eps);
bool_lower = pairwise_ratio > (1-eps);

bool_near_one = bool_upper & bool_lower;

count = nnz(bool_near_one);



