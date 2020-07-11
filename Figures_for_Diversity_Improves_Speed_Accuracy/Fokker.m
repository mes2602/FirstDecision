

function [x,uEnd,S,Rp]=Fokker(z,T,numT,plotYorN)
% x is xMesh, uEnd the solution at time T
% S survival probabilities (integral from -z to z) at each time increment
% Rp is upper integral (integral from 0 to z) at each time increment

%z is threshold; T is the end time, numT the number of time nodes
% a plot is generated if plotYorN = 1


m = 0;

part2 = (-.01):(10^(-6)):.01;

part1 = -z:.01:(-.02);
part3 = .02:.01:z;

x = cat(2,part1,part2,part3);

x0 = ceil(max(size(x))/2);

%t-span
t = linspace(0,T,numT);

sol = pdepe(m,@pdex1pdep,@pdex1ic,@pdex1bc,x,t);

% u : time x X-values
u = sol(:,:,1);



uEnd = u(end,:);


% Get survival probabilities (integral from -z to z)
S = zeros(numT,1); Rp = S;
for i = 1:numT
    S(i) = trapz(x, u(i,:));

    Rp(i) = trapz(x(x0:end),u(i,x0:end)); % integral from 0 to z
end
    

%Option to plot solution. 
if plotYorN ==1
%surface plot
    figure

surf(x,t,u) 
title(['p(x,t|x_0 = 0,t_0 = 0) with absorbing boundaries for z = ', num2str(z)])
xlabel('Distance x')
ylabel('Time t')
colormap spring
set(gca, 'Xdir', 'reverse')

% Plot of solution at the time we actually care about
figure


plot(x,uEnd, 'DisplayName', 'u')
legend('-DynamicLegend')

title(['p(x,t|x_0 = 0,t_0 = 0) at t = ', num2str(T)])
xlabel('Distance x')
ylabel(['u(x,',num2str(T),')'])

end

 
% --------------------------------------------------------------
function [c,f,s] = pdex1pdep(x,t,u,DuDx)
% It's going to give warnings about all these input arguments, but they are
% actually necessary. MATLAB will let us change the function name but not the
% number of arguments.
c = 1;
f = DuDx;
s = -DuDx;
% --------------------------------------------------------------
function u0 = pdex1ic(x)

a = .000001;
%u0 = dirac(x); % This won't integrate.

 % Approximation for initial delta function
u0 = (1/(2*sqrt(pi*a)))*exp(-(x^2/(4*a))); 

% --------------------------------------------------------------
function [pl,ql,pr,qr] = pdex1bc(xl,ul,xr,ur,t)
pl = ul;
ql = 0;
pr = ur;
qr = 0;

