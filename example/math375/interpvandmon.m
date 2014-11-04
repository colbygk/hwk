%
% Homework 7
% MATH 375 - Korotkevich
% Colby Gutierrez-Kraybill
%  problem 4b
%
% Compute coefficients from Vandermonde matrix
% x - vector of length n with values for [x_1 ... x_n]^T (roots)
% y - vector of length n with values for [y_1 ... y_n]^T
% c - founding coefficients of [c_1 ... c_n]^T 
function [ c ] = interpvandmon( x, y )

polypow = repmat([0:1:length(x)-1],length(x),1);
A = repmat( x, 1, length(x) ).^polypow;
c = A \ y;

end

