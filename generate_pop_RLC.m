function popRLC = generate_pop_RLC(parentPop, nRLC, alpha)
    popRLC = zeros(nRLC, size(parentPop, 2));
    for k = 1:nRLC
        randtwo = randi(size(parentPop,1), 2, 1);
        popRLC(k, :) = alpha * parentPop(randtwo(1), :) + (1 - alpha) * parentPop(randtwo(2), :);
    end
end
