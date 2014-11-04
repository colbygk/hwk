%
% Homework 8
% MATH 375 - Korotkevich
% Colby Gutierrez-Kraybill
%  problem 3
%

clearvars;
clf;

fx = @(x) 1./((x.^2)+1);

n = 11;
jr = [1:n];

xf1 = @(j,n) -4+(8*((j-1)/(n-1)));
xj1 = xf1(jr,n);
yj1 = fx(xj1);

xf2 = @(j,n) 4*cos((pi*((2*j)-1))/(2*n));
xj2 = xf2(jr,n);
yj2 = fx(xj2);
pr = linspace(-4,4,500);
fxpr = fx(pr);

c1 = interpnewt( xj1, yj1 );
c2 = interpnewt( xj2, yj2 );

p1 = hornernewt( c1, xj1, pr );
p2 = hornernewt( c2, xj2, pr );

% 1) Data and Interp
f=1;
figure(f);
plot(pr, fxpr, '-', pr, p1, 'r.' );
grid on;
l(f) = legend('$f(x)=\frac{1}{x^2+1}$','Interpolants','Location','South');
set(l(f),'Interpreter','Latex');
title( 'Data and interpolants,$x_j=-4+8\frac{j-1}{n-1}$',...
  'Interpreter', 'Latex');
xlabel('x');
ylabel('y');
cleanfigure;
matlab2tikz('p31f.tex','showInfo',...
  false, 'extraAxisOptions',['xlabel style={font={\large}},' ...
  'ylabel style={font={\large}}']);

% 1) Error 
f=f+1;
figure(f);
plot( pr, (fxpr - p1) );
grid on;
l(f) = legend('$e(x)$','Location','South');
set(l(f),'Interpreter','Latex');
title( 'Error for $x_j=-4+8\frac{j-1}{n-1},e(x)e(x)=f(x)-p(x), x\in [-4,4]$',...
  'Interpreter', 'Latex' );
xlabel('x');
ylabel('y');
cleanfigure;
matlab2tikz('p31e.tex','showInfo',...
  false, 'extraAxisOptions',['xlabel style={font={\large}},' ...
  'ylabel style={font={\large}}']);

% g(x)
f=f+1;
figure(f);
plot( pr, problem83gx(pr,xj1) );
grid on;
l(f) = legend('$g(x)$',...
  'Location','South');
set(l(f),'Interpreter','Latex');
title( '$g(x)=\frac{1}{n!}\prod_{k=1}^{n}(x-x_k),x_j=-4+8\frac{j-1}{n-1}$', ...
  'Interpreter', 'Latex' );
xlabel('x');
ylabel('y');
cleanfigure;
matlab2tikz('p31g.tex','showInfo',...
  false, 'extraAxisOptions',['xlabel style={font={\large}},' ...
  'ylabel style={font={\large}}']);

% 2) Data and Interp
f=f+1;
figure(f);
plot(pr, fxpr, '-', pr, p2, 'r.' );
grid on;
l(f) = legend('$f(x)=\frac{1}{x^2+1}$','Interpolants','Location','South');
set(l(f),'Interpreter','Latex');
title( 'Data and interpolants,$x_j=4cos\frac{\pi(2j-1)}{2n}$',...
  'Interpreter', 'Latex' );
xlabel('x');
ylabel('y');
cleanfigure;
matlab2tikz('p32f.tex','showInfo',...
  false, 'extraAxisOptions',['xlabel style={font={\large}},' ...
  'ylabel style={font={\large}}']);

% 2) error
f=f+1;
figure(f);
plot( pr, (fxpr - p2) );
grid on;
l(f) = legend('$e(x)$','Location','South');
set(l(f),'Interpreter','Latex');
title( 'Error for $x_j=4cos\frac{\pi(2j-1)}{2n},e(x)=f(x)-p(x), x\in [-4,4]$', ...
  'Interpreter', 'Latex' );
xlabel('x');
ylabel('y');
matlab2tikz('p32e.tex','showInfo',...
  false, 'extraAxisOptions',['xlabel style={font={\large}},' ...
  'ylabel style={font={\large}}']);

% 2) g(x)
f=f+1;
figure(f);
plot( pr, problem83gx(pr,xj2) );
grid on;
l(f) = legend('$g(x)$','Location','South');
set(l(f),'Interpreter','Latex');
title( '$g(x)=\frac{1}{n!}\prod_{k=1}^{n}(x-x_k), x\in [-4,4],x_j=4cos\frac{\pi(2j-1)}{2n}$', ...
  'Interpreter', 'Latex' );
xlabel('x');
ylabel('y');
matlab2tikz('p32g.tex','showInfo',...
  false, 'extraAxisOptions',['xlabel style={font={\large}},' ...
  'ylabel style={font={\large}}']);

