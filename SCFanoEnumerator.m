function Admin = SCFanoEnumerator(y,RP,poly)
%   Compute the number of minimum-weight codewords.
%   Note: 
%   1. The vector indexing in the MATLAB script starts from 1, which
%   differs from Algorithm 1 presented in the paper.
%   2. You can calculate a higher weight by modifying the threshold T and
%   add the corresponding detector Ad.
%   INPUTS:
%       y    - Channel output vector (1 x N)
%              BPSK mapping: {0,1} -> {1,-1}.
%
%       RP   - Logical vector (1 x N), type: logical.
%              RP(i) = 1 for information bits, 0 for frozen bits.
%
%       poly - Generator polynomial of the convolutional code in octal
%              form
%              Example: c = [1, 0, 1, 1, 0, 1, 1] corresponds to poly = 133.
%
%   OUTPUT:
%       Admin - Number of minimum-weight codewords.
tic
dmin = find_dmin_RP(RP);
T = -dmin;                                  % threshold
% T = -dmin - 8;                            % for higher weight codewords
N = size(y,2);n = log2(N);                  % number of branches
L = zeros(n+1,N);                           % node beliefs
L(1,:) = y;                                 % belief of root
M = zeros(N+2,1);                           % list of metrics
M(1) = -inf;                                % metric backward from root
M(2) = 0;                                   % metric at root
M_cut = zeros(N+2,1);
M_cut(1) = -inf;                            % metric backward from root
M_cut(2) = 0;                               % metric at root
t = ones(N,1);                              % branch being tested at each node
polyb = dec2bin(base2dec(num2str(poly), 8))-'0';
c = polyb == 1;                             % Logical array for faster calculation
constraint = length(polyb) - 1;             % Constraint Length
reg = zeros(1,constraint + N);              % shift register (Conv encoder replica in the decoder
Admin = 0;
i = 1;                                      % node index
% Ad2 = 0;
% Ad3 = 0;
% Ad4 = 0;
% Ad5 = 0;


% intermediate vector in calSCMetric
ucap = zeros(n+1,N);                        % decisions
ns = zeros(1,2*N-1);                        % node state vector 
node = 0;                                   % last decoding bit index
ui = 0;

while (1)
    t(i) = 1;
    while (1)
        [li, L, ucap, ns, node] = calSCMetric(i, L, ucap, ns, node, n, ui);
        if ~RP(i)
            ui = conv1bTrans(0,c,reg);
            gamma = calPathMetric(ui, li);
            M(i+2) = M(i+1) + gamma; M_cut(i+2) = M(i+2);
            inp = 0;
        else
            u0 = conv1bTrans(0,c,reg);
            u1 = conv1bTrans(1,c,reg);
            gamma0 = calPathMetric(u0, li);
            gamma1 = calPathMetric(u1, li);
            [M(i+2), M_cut(i+2), inp, ui] = ...
                updPathMetric(gamma0, gamma1, t(i), M(i+1),u0, u1);
        end
        if i == N && M(i+2) >= T
            if M(i+2) == -dmin
                Admin = Admin + 1;
            end
%             if M(i+2) == -dmin-2
%                 Ad2 = Ad2 + 1;
%             end
%             if M(i+2) == -dmin-4
%                 Ad3 = Ad3 + 1;
%             end
%             if M(i+2) == -dmin-6
%                 Ad4 = Ad4 + 1;
%             end
            M(i+2) = -inf;
        end
        if M(i+2) >= T 
            % Move forward
            reg(2:end) = reg(1,1:end-1); reg(1) = inp; % faster
%             reg = [inp, reg(1,1:end-1)];
            i = i + 1;
            break
        else
            while(1)
                if M(i) <  T
                    fprintf("dmin: %d, Admin: %d\n", dmin, Admin); 
%                     fprintf("d: %d, Admin: %d", dmin-2, Ad2); 
%                     fprintf("d: %d, Admin: %d", dmin-4, Ad3); 
%                     fprintf("d: %d, Admin: %d", dmin-6, Ad4); 
%                     fprintf("d: %d, Admin: %d", dmin-8, Ad5); 
                    toc
                    return
                else
                    % backtrack
                    i = i - 1; t(i) = t(i) + 1;
                    reg(1:end-1) = reg(2:end); reg(end) = 0; % faster
%                     reg = [reg(2:end) 0];
                    if ~RP(i) || t(i) == 3
                        continue
                    end
                    if M_cut(i+2) < T
                        continue;
                    end
                    break
                end
            end
        end
    end
end