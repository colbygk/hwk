%
% Homework 7
% MATH 375 - Korotkevich
% Colby Gutierrez-Kraybill
%  problem 4b
%
% Plot usage of interpvandmon
%

clearvars;
clf;
hold off;

D4 = [ [0 1]; [1 4]; [2 1]; [3 1] ];

x = D4(:,1);
y = D4(:,2);
c = interpvandmon( x, y );
xr = [-0.5:0.01:3.5];

h = plot(xr, polyval(fliplr(c'), xr), '-b', x, y, 'or' );
grid on;
set(h(2),'MarkerEdgeColor','none','MarkerFaceColor','r');
xlabel('x');
ylabel('y');
title('Reproduction of plot from notes: interp1');
cleanfigure;
matlab2tikz('problem4bplot.tex','showInfo',...
  false, 'extraAxisOptions',['xlabel style={font={\large}},' ...
  'ylabel style={font={\large}}']);
