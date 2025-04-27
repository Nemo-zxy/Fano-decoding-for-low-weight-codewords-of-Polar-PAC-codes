function [li, L, ucap, ns, node] = calSCMetric(i, L, ucap, ns, node, n, ui)
    if i - 1 < node
        % i is starting from one, -1 make it start from 0
        % we node to go back, we should update the states like we have not
        % gone more than node i-1, we sould erase future from node i-1

        %%%%%%%%%%%%%%%%%%%%%%Erasing Future%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % when we go up, states should be zero as the case we have not 
        % touched these nodes
        for I = (node+1):-1:i+1 % going back in the leaf node
            npos = (2^n-1) + I;
            ns(npos) = 0; % always we start with going up
            tempU = npos;
            while (mod(tempU,2) == 0) % condition which we should go up more
                tempU = tempU/2;
                ns(tempU) = 0;
            end
            tempL = floor(tempU/2); %we can go up to a limit, then we start to go right.
            ns(tempL) = 1;
        end
        node = (i-1); % at the end node position is updated to the place we need the llr
        li = L(n+1,node+1); % llr starts from 1
        %%%%%%%%%%%%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        stop = i; % want to depolarize upto leaf node i-1 (nodes start from zero)
        if i > 1
            ucap(n+1,i-1) = ui; % store the last decoding bit
            depth = n;
        else 
            depth = 0; % when i == 0, the depolarize process start from the root.
        end
        %%%%%%%%%%%%%%%%%%%%%%Depolarize%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        done = 0;               % decoder has finished
        while(done == 0)
            if depth == n  % leaf or not
                li = L(n+1,node+1);
                if node == (stop-1)  % stop = i;
                    done = 1;
                else
                    node = floor(node/2); depth = depth - 1;
                end
            else
                % nonleaf
                npos = (2^depth-1) + node + 1;  % position of node in node state vector
                if ns(npos) == 0 % step L and go to the left child
                    temp = 2^(n-depth);
                    % f-operation
                    for ii = 1:temp/2      
                        L(depth+2,temp/2*node*2+ii) = ...
                            (1-2*(L(depth+1,temp*node+ii)<0)).*...
                            (1-2*(L(depth+1,temp*node+temp/2+ii)<0)).*...
                            min(abs(L(depth+1,temp*node+ii)),...
                            abs(L(depth+1,temp*node+temp/2+ii)));
                    end
                    node = node*2; depth = depth+1; % next node: left child
                    ns(npos) = 1;
                else
                    if ns(npos) == 1 % step R and go to the right chilc
                        temp = 2^(n-depth);
                        lnode = 2*node; ldepth = depth+1; % left child
                        ltemp = temp/2;
                        % g-operation
                        for ii = 1:temp/2           
                            L(depth+1+1,temp/2*(node*2+1)+ii) = ...
                                L(depth+1,temp*node+temp/2+ii)+...
                                (1-2*ucap(ldepth+1,ltemp*lnode+ii)).*...
                                L(depth+1,temp*node+ii);
                        end
                        node = node*2+1; depth = depth+1; % next node: right child
                        ns(npos) = 2;
                    else % go to the parent
                        temp = 2^(n-depth);
                        % update ucap
                        for ii = 1:temp/2
                            ucap(depth+1,temp*node+ii) = mod(ucap(depth+1+1,temp/2*2*node+ii)+...
                                                ucap(depth+1+1,temp/2*(2*node+1)+ii),2);
                            ucap(depth+1,temp*node+temp/2 + ii) = ucap(depth+1+1,temp/2*(2*node+1)+ii);
                        end
                        node = floor(node/2); depth = depth - 1;
                        ns(npos) = 3;
                    end
                end
            end
        end
    end
end