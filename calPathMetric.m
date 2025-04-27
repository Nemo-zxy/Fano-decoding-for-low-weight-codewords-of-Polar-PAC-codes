%   ref. eq. (14)
function gamma = calPathMetric(u, li)
    if (1-2*u)*li >=0
        gamma = 0;
    else
        gamma = (1-2*u)*li;
    end
end