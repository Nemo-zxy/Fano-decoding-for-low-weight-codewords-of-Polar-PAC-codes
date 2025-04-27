% choose the decoding path by vector t
% t = 1: choose the optimal branch
%     2: choose the suboptimal branch
function [m1, m2, inp, ui] = updPathMetric(gamma0, gamma1, t, m0, u0, u1)
    tm = zeros(2,1);
    tb = zeros(2,1);
    tu = zeros(2,1);
    if gamma1 > gamma0
        tm(1) = gamma1;
        tb(1) = 1;
        tm(2) = gamma0;
        tb(2) = 0;
        tu(1) = u1;
        tu(2) = u0;
    else
        tm(1) = gamma0;
        tb(1) = 0;
        tm(2) = gamma1;
        tb(2) = 1;
        tu(1) = u0;
        tu(2) = u1;
    end
    m1 = m0 + tm(t);
    m2 = m0 + tm(-t+3);  % 1->2; 2->1
    inp = tb(t);
    ui = tu(t);
end