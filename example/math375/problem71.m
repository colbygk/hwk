%
% Homework 7
% MATH 375 - Korotkevich
%  problem 1
%
% Compute solution via Gauss-Sidel,
% prints number of interations taken to solve and
% backerror
%

clearvars;

n = 100;

% Setup matrices:
%  3 -1
% -1  3 -1
%  0 -1  3 -1 ...
%  ...
e = ones(n,1);
A = spdiags( [ -e e.*3 -e ], -1:1, n, n );
% b [ 2 1 ... 1 2 ]'
b = ones(n,1);
b(1) = 2;
b(n) = 2;
%%%

[x,s,b] = gausssidel( A, b, 1e-6 );
 
disp( sprintf(' n: %d, steps: %d, backerror: %1.7g', n, s, b) );