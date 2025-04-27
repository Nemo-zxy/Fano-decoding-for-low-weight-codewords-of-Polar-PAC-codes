function u = conv1bTrans(inp, polyL, reg)
    u = mod(sum(reg(polyL(2:end)))+inp,2);
end