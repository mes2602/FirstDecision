% comparePN
% Compares equations for p_N, the distribution of first decision times
% Creates 4 plots in a 2x2 arrangement comparing the equations with the
% original, exact formula and, if available, a histogram based on
% simulations run in the clapTime folder. The 4 plots hold the threshold
% stable and vary the number of agents.
%
% The equations are labelled by their location in the various papers.
%   BL : Benjamin Lindner's "Time until first decision in a group of N"
%           It's save-file name is smallest_decision_time.pdf
%   MW_KJ : manywalkers_KJ from the dropbox
%   NMW: NewManyWalkers from the dropbox
% Uncomment section under the desired equation to include it in the plot.
%
% It is recommended that BL (3) always be included, as it is the exact
% version and can be used as a comparison point when the histogram is not
% available.
% If a histogram is desired for a (z,n) combination for which one is not
% available, the data can be generated by running callClaps.m or 
% callClapsArg.m in the folder clapTime.
%
% Input arguments: 
%       z : size of threshold
%       nStart : the four plots shown will be for number of agents
%                 in the clique = n = 10^nStart,10^(nStart + 1), 
%                 10^(nStart + 2), 10^(nStart + 3)
%       endT: the right edge of the x-axis. endT should be a vector with 
%               four entries corresponding to the desired endpoints for the
%               above n values.
%               Because the time location of the plots can vary as n 
%               increases, if the right edge of the x-axis stays the same 
%               across plots it can be difficulto discern discrepancies
%               in the equations for the larger n values.
%               
% If desired, one may uncomment one of the preset input argument
% combinations and call the function with dummy arguments.
% 

function comparePN(z,nStart, endT)


% If desired, may skip the beginning arguments by uncommenting 
% one of the following lines:

% For z = 0.5
%endT = [0.1,0.03,.015,0.01]; nStart = 1; z = .5;   % for nK = 1..4
%endT = [.015,.01,.01,.006]; nStart = 4; z = .5;    % for nK = 4..7
%endT = [.006,.006,.005,.004]; nStart = 7; z = .5;  % for nK = 7..10

% For z = 1.0
%endT = [.4, .12,.06,.04]; nStart = 1; z = 1;       % for nK = 1..4
%endT = [.05,.04,.03,.025]; nStart = 4; z = 1;      % for nK = 4...7
%endT = [.025,.02,.015,.014]; nStart = 7; z = 1;    % for nK = 7..10
%endT = [.014,.013,.013,.012]; nStart = 10; z = 1;  % for nK = 10..13

% For z = 2.0
%endT = [1.5,.45,.25,.16]; nStart = 1; z = 2;   % for nK = 1..4
%endT = [.15,.115,.1,.08]; nStart = 4; z = 2;   % for nK = 4..7
%endT = [.08,.07,.06,.06]; nStart = 7; z = 2;   % for nK n = 7..10
%endT = [.06,.05,.05,.04]; nStart = 10; z = 2;  % for nK = 10..13
%endT = [.04,.04,.04,.04]; nStart = 13; z = 2;  % for nK = 13..16
%endT = [.03,.028,.0275,.025]; nStart = 16;z = 2;% for nK = 16..19

szT = 1001;

figure
% This for loop generates one subplot.
for i = nStart:nStart+3
    shift = i+1-nStart;
    subplot(2,2,shift)
    lw = 2; % linewidth for plots
    
    startT = ones(1,4) * 0.002;
    time = linspace(startT(shift),endT(shift),szT);
    n = 10^i;
   

    % Check to see if a histogram exists
            nstr = num2str(n);
            zstr = strrep(num2str(z),'.','_');
        filename = strcat('clapTime/claps_n',nstr,'z',zstr,'.mat');
        if isfile(filename)
            gru = load(filename,'DT');
            DT = gru.DT;
                 histogram(DT, 'DisplayName','Sims', 'facealpha',.3,'Normalization', 'pdf')
             hold on
            legend('-DynamicLegend')
        end
        
        
     %%%%%%%%%%%%%%%%%%%%%%%%%%
     % Equation options. Uncomment the functions for the equations you 
     % wish to include in the plots. 
     % The plotting of the equation occurs inside the function.
     
     % BL(3) = MW_KJ (4.2) pg 4: the exact version
        BL3(time, n, z,lw);
        
     % Modification: BL(3) with a normalization of 2/(1+exp(-z)) added
        BL3normed(time, n, z, lw);
        
     % BL(5) = MW_KJ (4.3) pg 5: the large N approximation
        BL5(time, n, z, lw);
        
     % Modification: BL(5) with a normalization of 2/(1+exp(-z)) added
        BL5normed(time, n, z, lw);
        
     % NMW (2.12)
        NMW2_12(time, n, z, lw);
        
     % Modification:
     % MW_KJ pg 7 #1. This is the same as NMW (2.12) with a normalization 
     % of 1/(1+exp(-z)) added
        MW_KJ7_1(time, n, z, lw);
        
     % NMW (2.13)
        NMW2_13(time, n, z, lw);        
     
     % Modification:
     % MW_KJ pg 7 #2. This is the same as NMW (2.13) with a normalization 
     % of 1/(1+exp(-z)) added
        MW_KJ7_2(time, n, z, lw);
        
     % NMW (2.14)
        NMW2_14(time, n, z, lw);                
     
     % Modification:
     % MW_KJ pg 7 #3. This is the same as NMW (2.13) with a normalization 
     % of 1/(1+exp(-z)) added
        MW_KJ7_3(time, n, z, lw);
        
     %%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        % Housekeeping for the plot
    
            str1 = 'First Decision Time distributions';
            str2 = strcat('for n = 10^{', num2str(i), '}, z = ', num2str(z));
            str = {str1,str2};
            title(str)
            xlabel('time')
end
end

function BL3(time, n,z,lw)
    szt = max(size(time));
    p_N_exext = zeros(1,szt);
    for j = 1:szt
        t = time(j);
         % Exact-exact: BL (3) = MW_KJ (4.2) pg 4
        p_N_exext(j)=n*(1-.5*(erfc((z-t)/sqrt(4*t))+exp(z)*erfc((z+t)/sqrt(4*t))...
            + erfc((z+t)/sqrt(4*t)) + exp(-z)*erfc((z-t)/sqrt(4*t))))^(n-1)...
            *(z/sqrt(4*pi*t^3))...
            *(exp((-(z-t)^2)/(4*t))...
            + exp((-(z+t)^2)/(4*t)));
    end
    
    plot(time,p_N_exext,...
        '-bo','Linewidth',lw,...
        'DisplayName','BL (3) ')
    hold on
    
    legend('-DynamicLegend')
    
end

function BL3normed(time, n, z, lw)
    szt = max(size(time));
    p_N_exexNormt = zeros(1,szt);
    for j = 1:szt
        t = time(j);
        p_N_exexNormt(j)=n*(1-(2/(1+exp(-z)))*...
            .5*(erfc((z-t)/sqrt(4*t))+exp(z)*erfc((z+t)/sqrt(4*t))...
            + erfc((z+t)/sqrt(4*t)) + exp(-z)*erfc((z-t)/sqrt(4*t))))^(n-1)*...
             (2/(1+exp(-z)))...
            *(z/sqrt(4*pi*t^3))*...
            (exp((-(z-t)^2)/(4*t)) + exp((-(z+t)^2)/(4*t)));
    end
    
    plot(time,p_N_exexNormt,...
        '-ro','Linewidth',lw,...
        'DisplayName','BL (3) w/ 2/(1+exp(-z))')
    hold on
    
    legend('-DynamicLegend')
end

function BL5(time, n, z, lw)
    szt = max(size(time));
    p_N_ext = zeros(1,szt);
    
    for j = 1:szt
        t = time(j);
        % Exact- 1 approx. BL(5) = KJ (4.3) pg 5
        p_N_ext(j)=n*exp((1-n)*.5*(erfc((z-t)/sqrt(4*t))+exp(z)*erfc((z+t)/sqrt(4*t))...
            + erfc((z+t)/sqrt(4*t)) + exp(-z)*erfc((z-t)/sqrt(4*t))))...
            *(z/sqrt(4*pi*t^3))*(exp((-(z-t)^2)/(4*t)) + exp((-(z+t)^2)/(4*t)));
    end
    
    plot(time,p_N_ext,...       
        'Linewidth',lw,...
        'DisplayName','BL(5), MW-KJ (4.3)  ')
    hold on    
    legend('-DynamicLegend')
end

function BL5normed(time, n, z, lw)
    szt = max(size(time));
    p_N_exNormt = zeros(1,szt);
    
    for j = 1:szt
        t = time(j);
        p_N_exNormt(j)=n*exp((1-n)*(2/(1+exp(-z)))...
            *.5*(erfc((z-t)/sqrt(4*t))+exp(z)*erfc((z+t)/sqrt(4*t))...
            + erfc((z+t)/sqrt(4*t)) + exp(-z)*erfc((z-t)/sqrt(4*t))))...
            *(z/sqrt(4*pi*t^3))*(exp((-(z-t)^2)/(4*t)) + exp((-(z+t)^2)/(4*t)))*(2/(1+exp(-z)));
    end
    
    plot(time,p_N_exNormt,...
        'Linewidth', lw,'DisplayName',...
        'BL(5), MW-KJ(4.3), w/ 2/(1+exp(-z))  ')
    hold on
    legend('-DynamicLegend')
    
end

function NMW2_12(time, n, z, lw)
    szt = max(size(time));
    wat2_12 = zeros(1,szt);
    
    for j = 1:szt
        t = time(j);
        wat2_12(j) = n*(1-.5*((1+exp(-z))...
            *erfc((z-t)/(2*sqrt(t)))+(1+exp(z))*erfc((z+t)/(2*sqrt(t)))))^(n-1)*B(z,t);
    end
    
    plot(time,wat2_12,...
        'Linewidth', lw ,...
        'DisplayName', 'NMW (2.12)')
    hold on
    legend('-DynamicLegend')
end

function MW_KJ7_1(time, n, z, lw)
    szt = max(size(time));
    pN1New = zeros(1,szt);
    
    for j = 1:szt
        t = time(j);
        pN1New(j) = n*(1-.5*erfc((z-t)/(2*sqrt(t)))-(exp(z)/2)*erfc((z+t)/(2*sqrt(t))))^(n-1)*newR(z,t);
    end
    
    plot(time,pN1New,...
        'Linewidth', lw ,...
        'DisplayName', 'NMW (2.12) w/ 1/(1 + exp(-z))')
    hold on
    legend('-DynamicLegend')
end

function NMW2_13(time, n, z, lw)
    szt = max(size(time));
    wat2_13 = zeros(1,szt);
    
    for j = 1:szt
        t = time(j);
        wat2_13(j) = n*(exp(-(n-1)*(((1+exp(z))/2)...
            *erfc((z+t)/(2*sqrt(t)))+((1+exp(-z))/2)*erfc((z-t)/(2*sqrt(t))))))*B(z,t);
    end
    
    plot(time,wat2_13,...
        'Linewidth', lw ,...
        'DisplayName', 'NMW (2.13)')
    hold on
    legend('-DynamicLegend')
end

function MW_KJ7_2(time, n, z, lw)
    szt = max(size(time));
    pN2New = zeros(1,szt);
    
    for j = 1:szt
        t = time(j);      
        pN2New(j) = n*exp((1-n)*...
            ((exp(z)/2)*erfc((z+t)/(sqrt(4*t)))+.5*erfc((z-t)/(sqrt(4*t)))))*newR(z,t);
    end
    
    plot(time,pN2New,...
        'Linewidth', lw ,...
        'DisplayName', 'NMW (2.13) w/ 1/(1 + exp(-z))')
    hold on
    legend('-DynamicLegend')
end

function NMW2_14(time, n, z, lw)
    szt = max(size(time));
    wat2_14 = zeros(1,szt);
    
    for j = 1:szt
        t = time(j);
        wat2_14(j) = n*exp(-2*sqrt(t/pi)*(n-1)...
            *exp(-(z^2/(4*t)))*((2/z)*cosh(z/2)*(1-((2*t)/(z^2))) - sinh(z/2)))*B(z,t); 
    end
    
    plot(time,wat2_14,...
        'Linewidth', lw ,...
        'DisplayName', 'NMW (2.14)')
    hold on
    legend('-DynamicLegend')
end

function MW_KJ7_3(time, n, z, lw)
    szt = max(size(time));
    pN3New = zeros(1,szt);
    
    for j = 1:szt
        t = time(j);       
        pN3New(j) = n*exp(-((2*(n-1)*z*sqrt(t))/(sqrt(pi)*(z^2-t^2)))*exp(-(z-t)^2/(4*t)))*newR(z,t);
    end
    
    plot(time,pN3New,...
        'Linewidth', lw ,...
        'DisplayName', 'NMW (2.14) w/ 1/(1 + exp(-z))')
    hold on
    legend('-DynamicLegend')
end

function b = B(z,t)
    b=cosh(z/2)*(z/sqrt(pi*t^3))*exp(-(z^2 + t^2)/(4*t));
end

function nr = newR(z,t)
    nr = z*exp(-(z^2+t^2)/(4*t))*exp(z/2)/(sqrt(4*pi*t^3));
end
        