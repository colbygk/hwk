function p = hornernewt(c,x,z)
% function p = hornernewt(c,x,z)
% Uses Horner method to evaluate in nested form a polynomial defined
% by coefficients c and shifts x. Polynomial is evaluated at z.
n = length(c); % 1 + degree of polynomial.
p = c(n);
for k = n-1:-1:1
p = p.*(z-x(k))+c(k);
end