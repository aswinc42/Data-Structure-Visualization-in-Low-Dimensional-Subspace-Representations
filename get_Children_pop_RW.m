function[childpopRW, n_child_pop] = get_Children_pop_RW(parentPop, popProb, radius)

pop_size = length(popProb);
n_child_pop = round(pop_size * popProb);
childpopRW = [];
for k = 1:pop_size
    if(n_child_pop(k) > 0)
        points = generateHyperspherePoints(n_child_pop(k), size(parentPop, 2), radius, parentPop(k,:));
        childpopRW  = cat(1, childpopRW, points);
    end
end


childpopRW(childpopRW < 0) = 0;
childpopRW(childpopRW > (2*pi)) = (2*pi);

