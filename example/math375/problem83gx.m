%
% Homework 8
% MATH 375 - Korotkevich
% Colby Gutierrez-Kraybill
%  problem 3
%
function [ g ] = problem83gx( x, xj )

n = length(xj);
nfinv = (1/factorial(n));
px = 1;

for k=1:n
  px = px.*(x - xj(k));
end

g = nfinv*px;

end

