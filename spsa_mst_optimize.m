function [theta_opt, fval] = spsa_mst_optimize(adj_mat, theta0, maxIter)

theta = theta0;
p = length(theta);

a = 0.1;
c = 0.1;
alpha = 0.602;
gamma = 0.101;

for k = 1:maxIter
    
    ak = a / (k^alpha);
    ck = c / (k^gamma);
    
    delta = 2*(rand(1,p) > 0.5) - 1;
    
    theta_plus  = theta + ck * delta;
    theta_minus = theta - ck * delta;
    
    y_plus  = evaluate_pop(adj_mat, theta_plus);
    y_minus = evaluate_pop(adj_mat, theta_minus);
    
    ghat = (y_plus - y_minus) ./ (2 * ck * delta);
    
    theta = theta - ak * ghat;
    theta = mod(theta, 2*pi);
end

theta_opt = theta;
fval = evaluate_pop(adj_mat, theta);

end