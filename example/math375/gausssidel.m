% Function guasssidel
% MATH375 - Prof Korotkevich
%  Homework 7
%
% A - sparse, tridiagonally dom matrix
% b - rhs solution vector
% t - tolerence
% x - lhs solution vector
% steps - number of interations taken
% backerr - back error in inf norm
function [ x,steps,backerr ] = gausssidel( A, b, t )

if ( length(b) ~= length(A) )
  error( 'dimension mismatch' ); 
end

n = length(b);

x = zeros(n,1);
nx = zeros(n,1);

L = tril(A,-1);
U = triu(A,1);
D = diag(A);
Dinv = 1.0 ./ D;

steps = 1;
maxc = 1000;
rerr = Inf;

while ( (rerr > t) && (steps < maxc) )
  
  for k=1:n
    Lxk = L(k,1:k-1)*nx(1:k-1);
    Uxk = U(k,k+1:end)*x(k+1:end);
    
    if ( k == 1 )
      Lxk = 0;
    elseif ( k == n )
      Uxk = 0;
    end
    
    nx(k) = Dinv(k)*( b(k) - Uxk - Lxk );
  end
  
  rerr = abs(norm(nx-x)/(norm(nx)));
  x = nx;
  steps = steps + 1; 
end

if ( steps == maxc )
  error( sprintf('stopping after %d iterations',steps) );
end

% calculate error
errs = zeros(n,1);
cor = zeros(n,1);
%diffs = zeros(n,1);

for j=1:n
  for k=1:n
    cor(j) = cor(j) + A(j,k);
    errs(j) = errs(j) + A(j,k)*x(j);
  end
  diffs(j) = abs(errs(j) - cor(j));
end

backerr = max(diffs,[],2);


end