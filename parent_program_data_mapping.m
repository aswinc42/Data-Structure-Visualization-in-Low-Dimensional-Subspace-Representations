clearvars
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Real world datasets
cd 'D:\Research work\Outlier Detection\Fresh datasets';

my_folder_info = dir('D:\Research work\Outlier Detection\Fresh datasets');

size_my_folder = size(my_folder_info);

dataset = cell(1,(size_my_folder(1)-2));

n_datasets = (size_my_folder(1)-2);

for i = 1:(size_my_folder(1)-2)
    file_name_store = char(my_folder_info(i+2).name);
    dataset{i} = file_name_store;
    directory_name_store = cd;
    complete_name = strcat(directory_name_store,'\',file_name_store);
    asdf = load(complete_name);
    DS{i} = asdf.data.data;
    label{i} = asdf.data.nlab - 1;
end

cd 'D:\Research work\Data Visualization\Archives'

data = DS{25}; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Synthetically generated data
% [data] = synthetic_data_generation();
% % figure, scatter3(data(:,1), data(:,2), data(:,3), 40, 'filled')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Y = recursive_hac_mapping(data, 2, [8, 8]);
figure, scatter(Y(:,1), Y(:,2), 40, 'filled'), title('Proposed method')
[count_proposed] = eval_metric_mapping(data, Y, 1e-1);

Y1 = tsne(data, [], 2, 3);
figure, scatter(Y1(:,1), Y1(:,2), 40, 'filled'), title('t-SNE')
[count_tsne] = eval_metric_mapping(data, Y1, 1e-1);
