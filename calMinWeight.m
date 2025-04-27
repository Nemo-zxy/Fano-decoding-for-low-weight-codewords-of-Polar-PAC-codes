function dmin = calMinWeight(RP)
    I = find(RP == 1) - 1;
    w = sum(dec2bin(I)-'0',2);
    dmin = 2^(min(w));
end