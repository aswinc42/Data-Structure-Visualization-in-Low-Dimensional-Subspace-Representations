function[cluster] =  evaluate_cluster(adj_mat, popX)

cluster = zeros(size(adj_mat,1), 2, size(popX, 1));

for k = 1:size(popX,1)  
    adj_mat_temp = adj_mat + transpose(adj_mat);
    theta = popX(k,:);
    col_index = 1;  
    count = 0;
    visited_indices = col_index;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while(length(unique(visited_indices)) < size(adj_mat_temp,1))          
        nxt_col_index = [];
        for m = 1:length(col_index)
            current_col_index = col_index(m);
            row_indices = find(adj_mat_temp(:,current_col_index) ~= 0);   
            visited_indices = cat(1, visited_indices, row_indices);
            for n = 1:length(row_indices)
                dstnc = adj_mat_temp(row_indices(n),current_col_index);
                adj_mat_temp(row_indices(n),current_col_index) = 0;
                adj_mat_temp(current_col_index,row_indices(n)) = 0;
                count = count + 1;
                cluster(row_indices(n), 1, k) = cluster(current_col_index, 1, k) + (dstnc * cos(theta(count)));
                cluster(row_indices(n), 2, k) = cluster(current_col_index, 2, k) + (dstnc * sin(theta(count)));

                if(sum(adj_mat_temp(:, row_indices(n))) > 0)
                    nxt_col_index = cat(1, nxt_col_index, row_indices(n));
                end
            end
        end

        if(~isempty(nxt_col_index))
            col_index = nxt_col_index;
        end
    end
end    
