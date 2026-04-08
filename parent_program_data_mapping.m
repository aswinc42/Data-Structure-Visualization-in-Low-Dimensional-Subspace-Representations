clearvars;
clc;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 🔷 PARAMETERS (SCALABILITY CONTROL)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

K_true = 64;        % 👉 Try: 32, 64, 128, 256
dim = 10;           % 👉 Try: 3, 5, 10, 20
n_per_cluster = 30; % points per cluster
sigma = 0.3;        % cluster spread

% Hierarchical structure
L = 3;                      % number of levels
Kvec = [4, 4, 4];           % 4×4×4 = 64 clusters

rng(42);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 🔷 SYNTHETIC DATA GENERATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Generating synthetic data...\n');

total_points = K_true * n_per_cluster;
data = zeros(total_points, dim);

centers = rand(K_true, dim) * 10;  % spread cluster centers

idx = 1;
for k = 1:K_true
    pts = centers(k,:) + sigma * randn(n_per_cluster, dim);
    data(idx:idx+n_per_cluster-1, :) = pts;
    idx = idx + n_per_cluster;
end

fprintf('Data generated: %d points in %dD with %d clusters\n', ...
    total_points, dim, K_true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 🔷 VISUALIZE ORIGINAL DATA (ONLY IF 3D)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if dim == 3
    figure;
    scatter3(data(:,1), data(:,2), data(:,3), 20, 'filled');
    title(['Original Data (', num2str(K_true), ' clusters, ', num2str(dim), 'D)']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 🔷 PROPOSED METHOD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nRunning Recursive HAC Mapping...\n');
tic;

Y = recursive_hac_mapping(data, L, Kvec);

time_proposed = toc;

figure;
scatter(Y(:,1), Y(:,2), 20, 'filled');
title(['Proposed Method (K = ', num2str(K_true), ', dim = ', num2str(dim), ')']);

[count_proposed] = eval_metric_mapping(data, Y, 1e-1);

fprintf('Proposed Method Score: %d\n', count_proposed);
fprintf('Proposed Method Time : %.2f seconds\n', time_proposed);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 🔷 t-SNE (FIXED VERSION + SAFE EXECUTION)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nRunning t-SNE...\n');

try
    tic;

    % Safe perplexity (must be < N/3)
    perp = min(30, floor(size(data,1)/3));

    Y1 = tsne(data, ...
        'NumDimensions', 2, ...
        'Perplexity', perp, ...
        'Standardize', true);

    time_tsne = toc;

    figure;
    scatter(Y1(:,1), Y1(:,2), 20, 'filled');
    title('t-SNE');

    [count_tsne] = eval_metric_mapping(data, Y1, 1e-1);

    fprintf('t-SNE Score: %d\n', count_tsne);
    fprintf('t-SNE Time : %.2f seconds\n', time_tsne);

catch ME
    fprintf('t-SNE failed: %s\n', ME.message);
    count_tsne = NaN;
    time_tsne = NaN;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 🔷 FINAL COMPARISON SUMMARY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n========================================\n');
fprintf('FINAL COMPARISON\n');
fprintf('========================================\n');
fprintf('Clusters           : %d\n', K_true);
fprintf('Dimension          : %d\n', dim);
fprintf('Total Points       : %d\n', total_points);
fprintf('----------------------------------------\n');
fprintf('Proposed Score     : %d\n', count_proposed);
fprintf('t-SNE Score        : %d\n', count_tsne);
fprintf('----------------------------------------\n');
fprintf('Proposed Time (s)  : %.2f\n', time_proposed);
fprintf('t-SNE Time (s)     : %.2f\n', time_tsne);
fprintf('========================================\n');









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETER TUNING EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n========================================\n');
fprintf('PARAMETER TUNING STARTED\n');
fprintf('========================================\n');

% Define L values
L_values = [1, 2, 3];

% Define Kvec options
K_options = {
    [64],          % L = 1
    [8 8],         % L = 2
    [16 4],
    [4 16],
    [4 4 4],       % L = 3
    [8 4 2],
    [2 8 4]
};

results = [];
row = 1;

for L = L_values
    
    for i = 1:length(K_options)
        
        Kvec = K_options{i};
        
        % Skip invalid combinations
        if length(Kvec) ~= L
            continue;
        end
        
        fprintf('\nRunning L=%d, Kvec=%s\n', L, mat2str(Kvec));
        
        tic;
        Y = recursive_hac_mapping(data, L, Kvec);
        t = toc;
        
        score = eval_metric_mapping(data, Y, 1e-1);
        
        results(row).L = L;
        results(row).Kvec = Kvec;
        results(row).Score = score;
        results(row).Time = t;
        
        fprintf('Score: %d | Time: %.2f sec\n', score, t);
        
        row = row + 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DISPLAY RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n========================================\n');
fprintf('FINAL RESULTS TABLE\n');
fprintf('========================================\n');

for i = 1:length(results)
    fprintf('L=%d | Kvec=%s | Score=%d | Time=%.2f sec\n', ...
        results(i).L, ...
        mat2str(results(i).Kvec), ...
        results(i).Score, ...
        results(i).Time);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONVERT TO TABLE (CLEAN VIEW)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L_col = [results.L]';
Score_col = [results.Score]';
Time_col = [results.Time]';

Kvec_col = cell(length(results),1);
for i = 1:length(results)
    Kvec_col{i} = mat2str(results(i).Kvec);
end

T = table(L_col, Kvec_col, Score_col, Time_col, ...
    'VariableNames', {'L','Kvec','Score','Time'});

disp(T);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT: SCORE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scores = [results.Score];

figure;
plot(scores, '-o', 'LineWidth', 2);
xlabel('Experiment Index');
ylabel('Score');
title('Performance vs Parameter Settings');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT: TIME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

times = [results.Time];

figure;
plot(times, '-o', 'LineWidth', 2);
xlabel('Experiment Index');
ylabel('Time (seconds)');
title('Computation Time vs Parameters');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT: EFFICIENCY (Score / Time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

efficiency = scores ./ times;

figure;
plot(efficiency, '-o', 'LineWidth', 2);
xlabel('Experiment Index');
ylabel('Score / Time');
title('Efficiency vs Parameter Settings');
grid on;