function [dec] = b2d(bin)
dec = 0;
for i = 1:length(bin)
    dec = dec + bin(i)*2^(length(bin)-i);
end