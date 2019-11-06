% Notes:
% Many of the older functions don't automatically handle the difference
% between single variables (like avgTime) and array variable (like
% wavesAcc)
% If you need an array variable, set waves = 1 at the top of the function.
% If you need a single variable, set waves = 0.
% The default for social is 0. Only set social = 1 if you specifically need
% to reprocess social information.
% The default for redo is 0. If you've changed something and need to 
% regenerate the cooked files, set redo = 1. 
% If both social and redo are set to 1, running anything will take a Long
% Time.

% Generally, inside a plotting function you will need to specify
% folderName, which controls which distribution the thresholds are from,
% and
% variableName, which controls which variable gets displayed
% If changing folderName or variableName, be sure to modify titles and axis labels as
% well


% Generic settings; some functions take arguments, others don't
% Modify to suit. 
zMin = .1; zMax = 1; n = 40;
as = [0,.1,.2,.3,.5,.8];
h_as = [0,.5,1,2,3];
n_array = [40,150,300,1000,5000,10000,15000];

% Put function to actually be called here
%z1PerArray()
%Bernbyz1PervsA()

runChef(n_array);

%_______________________________________________________
% Available functions


%-------------------------------------------------------------
% Utility functions 


% Generic
function [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves)

    maybeA = zMin : .05 : .8;
    szA = length(maybeA);
    
        
    index = 0;
    for i = 1:szA
        zMin = maybeA(i);
        folderName2 = strcat(folderName, '/zMin_', ...
        strrep(num2str(zMin),'.','_'),'_zMax_',...
        strrep(num2str(zMax),'.','_'));
        filename = strcat(folderName2,'/Cooked_n',num2str(n),'.mat');
        
        % Check to see if the file has already been processed
        if isfile(filename)
            vars = whos('-file',filename);
            % Check to see if it's been processed since the desired 
            % variable was added
            if (~ismember(variableName,{vars.name})) || (redo ==1)
                delete (filename)
                chef(folderName, zMin, zMax, n,social);
                %fprintf(strcat('Recalculating for a = ',num2str(zMin)))
            end
            gru = load(filename, variableName);
            index = index + 1;
            if waves > 0
            variable(index,:,:) = gru.(variableName);
            else
            variable(index) = gru.(variableName);
            end
            a(index) = zMin;
        else
            % was debugging st = strcat('hi',num2str(i))
            
            if isfile(strcat(folderName2, '/Raw_n', num2str(n),'_batch_1.mat'))
                chef(folderName, zMin, zMax, n,social);
                %fprintf(strcat('Calculating for a = ',num2str(zMin)))
                gru = load(filename, variableName);
                index = index + 1;
                if waves > 0
                variable(index,:,:) = gru.(variableName);
                else
                variable(index) = gru.(variableName);
                end
                a(index) = zMin;
            end
        end
        
            
    end

end
function [ns, variable] = VsN(folderName, variableName, maxN,zMin,zMax,redo,social,waves)
    n_array = [10,20,40,60,80,100,150,300,500,1000,5000,10000];
    szN = length(n_array);
    % if this n value doesn't have a file, will return
        %ns = 0; variable = 0;
    
        
    index = 0; i = 1;
    n = n_array(i);
    while i <= szN && n < maxN
        n = n_array(i);
        
        folderName2 = strcat(folderName, '\zMin_', ...
        strrep(num2str(zMin),'.','_'),'_zMax_',...
        strrep(num2str(zMax),'.','_'));
        filename = strcat(folderName2,'\Cooked_n',num2str(n),'.mat');
        
        % Check to see if the file has already been processed
        if isfile(filename)
            vars = whos('-file',filename);
            % Check to see if it's been processed since the desired 
            % variable was added
            if ~ismember(variableName,{vars.name}) || redo ==1
                delete(filename)
                chef(folderName, zMin, zMax, n,social);
            end
            gru = load(filename, variableName);
            index = index + 1;
            if waves > 0
            variable(index,:,:) = gru.(variableName);
            else
            variable(index) = gru.(variableName);
            end
            ns(index) = n;
        else
            % was debugging st = strcat('hi',num2str(i))
            
            if isfile(strcat(folderName2, '\Raw_n', num2str(n),'_batch_1.mat'))
                chef(folderName, zMin, zMax, n,social);
                gru = load(filename, variableName);
                index = index + 1;
                if waves > 0
                variable(index,:,:) = gru.(variableName);
                else
                variable(index) = gru.(variableName);
                end
                ns(index) = n;
            end
        end
            i = i + 1;
    end

end
function [ha,variable] = VsH(folderName, variableName, n, zMin, zMax,hMax,redo,social,waves)

    maybeH = 0 : .05 : hMax;
    szH = length(maybeH);
    
    
    index = 0;
    for i = 1:szH
        h = maybeH(i);
        folderName3 = strcat(folderName,'/h_a_',...
        strrep(num2str(h),'.','_'));
        folderName2 = strcat(folderName3,'/zMin_', ...
        strrep(num2str(zMin),'.','_'),'_zMax_',...
        strrep(num2str(zMax),'.','_'));
        filename = strcat(folderName2,'/Cooked_n',num2str(n),'.mat');
        
        % Check to see if the file has already been processed
        if isfile(filename)
            vars = whos('-file',filename);
            % Check to see if it's been processed since the desired 
            % variable was added
            if (~ismember(variableName,{vars.name})) || (redo ==1)
                delete (filename)
                chef(folderName3, zMin, zMax, n,social);
                %fprintf(strcat('Recalculating for a = ',num2str(zMin)))
            end
            gru = load(filename, variableName);
            index = index + 1;
            if waves > 0
            variable(index,:,:) = gru.(variableName);
            else
            variable(index) = gru.(variableName);
            end
            ha(index) = h;
        else
            % was debugging st = strcat('hi',num2str(i))
            
            if isfile(strcat(folderName2, '/Raw_n', num2str(n),'_batch_1.mat'))
                chef(folderName3, zMin, zMax, n,social);
                %fprintf(strcat('Calculating for a = ',num2str(zMin)))
                gru = load(filename, variableName);
                index = index + 1;
                if waves > 0
                variable(index,:,:) = gru.(variableName);
                else
                variable(index) = gru.(variableName);
                end
                ha(index) = h;
            end
        end
        
            
    end

end
function [z1Per,variable] = Vsz1Per(folderName, variableName, n, zMin, zMax,redo,social,waves)

    maybePer = 0 : .1 : 1;
    szP = length(maybePer);
    
    
    index = 0;
    for i = 1:szP
        h = maybePer(i);
        folderName3 = strcat(folderName,'_smallPer_',...
        strrep(num2str(h),'.','_'));
        folderName2 = strcat(folderName3,'/zMin_', ...
        strrep(num2str(zMin),'.','_'),'_zMax_',...
        strrep(num2str(zMax),'.','_'));
        filename = strcat(folderName2,'/Cooked_n',num2str(n),'.mat');
        
        % Check to see if the file has already been processed
        if isfile(filename)
            vars = whos('-file',filename);
            % Check to see if it's been processed since the desired 
            % variable was added
            if (~ismember(variableName,{vars.name})) || (redo ==1)
                delete (filename)
                chef(folderName3, zMin, zMax, n,social);
                %fprintf(strcat('Recalculating for a = ',num2str(zMin)))
            end
            gru = load(filename, variableName);
            index = index + 1;
            if waves > 0
            variable(index,:,:) = gru.(variableName);
            else
            variable(index) = gru.(variableName);
            end
            z1Per(index) = h;
        else
            % was debugging st = strcat('hi',num2str(i))
            
            if isfile(strcat(folderName2, '/Raw_n', num2str(n),'_batch_1.mat'))
                chef(folderName3, zMin, zMax, n,social);
                %fprintf(strcat('Calculating for a = ',num2str(zMin)))
                gru = load(filename, variableName);
                index = index + 1;
                if waves > 0
                variable(index,:,:) = gru.(variableName);
                else
                variable(index) = gru.(variableName);
                end
                z1Per(index) = h;
            end
        end
        
            
    end

end

% This is just to generate cooked files without trying to
% do anything with them. Generally unnecessary.
function runChef(n_array)
	folderName = 'ManyBern/Attempt1';
	social = 0;
	gru = load(strcat(folderName, '/background.mat'));
	zz = gru.zMin;
	zMin = zz(1); zMax = zz(end);
	for i = 1:length(n_array)
		n = n_array(i);
		chef(folderName, zMin, zMax, n, social);
	end
end


%--------------------------------------------------------
% Plotting functions

    % compares Tent and Uniform function through a variety of a values.
function tentvsUniform()
    %n_array = [40,150,500,1000];
    %n_array = [1000,5000,10000,15000];
    n_array = [40,150,300,500,1000,5000,10000,15000];
    zMin = 0; zMax = 1;
    variableName = 'avgTime';
    tit = 'Average First Decision Time';
    redo = 1; social = -1; waves = 0;
    figure
    for i = 1:length(n_array)
        n = n_array(i);
%         subplot(1,3,1)
%         folderName = 'SelfHomo'
%         [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social)
%         plot(a,variable, 'DisplayName', strcat('n = ',num2str(n)),'LineWidth',4)
%             legend('-DynamicLegend')
%             hold on
        subplot(1,2,1)
        folderName = 'Uniform';
        [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
        plot(a,variable, 'DisplayName', strcat('n = ',num2str(n)),'LineWidth',4)
            legend('-DynamicLegend')
            hold on
        subplot(1,2,2)
        folderName = 'NewTent';
        [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
        plot(a,variable, 'DisplayName', strcat('n = ',num2str(n)),'LineWidth',4)
            legend('-DynamicLegend')
            hold on
            
     end
%     subplot(1,3,1)
%     xlabel('Threshold')
%     title('Homogeneous thresholds')
    subplot(1,2,1)
%     plot(a,a, '--','DisplayName', 'a = a', 'LineWidth', 4)
    xlabel('a = smallest possible threshold')
    title('Uniform Distribution')
    set(gca, 'FontWeight', 'bold', 'FontSize',12)
    subplot(1,2,2)
%     plot(a,a, '--','DisplayName', 'a = a', 'LineWidth', 4)
    xlabel('a = smallest possible threshold')
    title('Tent-function Distribution')
    set(gca, 'FontWeight', 'bold', 'FontSize',12)
    sgtitle(tit, 'FontWeight', 'bold')
    
end
    % Same as above, but lists each n in separate subplots.
function tentvsUniformSeparateN()
    n_array = [40,150,500,1000];
    zMin = 0; zMax = 1;
    variableName = 'avgTime';
    tit = 'Average First Decision Time';
    ylab = 'First Decision Time';
    redo = 0; social = 0; 
    figure
    for i = 1:length(n_array)
        n = n_array(i);
        subplot(2,2,i)
        
        folderName = 'Uniform';
        [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social);
        plot(a,variable, 'DisplayName', 'Uniform','LineWidth',4)
            legend('-DynamicLegend')
            hold on
        
        folderName = 'NewTent';
        [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social);
        plot(a,variable, '--','DisplayName','Tent','LineWidth',4)
            legend('-DynamicLegend')
        
            title(strcat('n = ', num2str(n)))
            xlabel('a = smallest possible threshold')
            ylabel(ylab)
            
    set(gca, 'FontWeight', 'bold', 'FontSize',12)
            
     end

    sgtitle(tit, 'FontWeight', 'bold')
    
end


    % Compares approximation and actual social increment
function secondIncrementSelfRefUniform(nForA)

    folderName = 'SelfUniform'; variableName = 'avgSecUpFDA';
    
    n = nForA; zMin = .05; zMax = .3; maxN = 300; redo = 0; zMin2 = .25;
    
    figure 
    subplot(1,2,1)
    [as,variable] = VsA(folderName, variableName, n, zMin, zMax,redo);
    ass = linspace(zMin,zMax,101);
    for i = 1:101
        a = ass(i);
        %aApprox(i) = (a^2*n)/(2*log(n));
        aApprox(i) = (a^2*(n-1))/(pi*(log((2*a^5*n^2)/(27*(zMax-a)^2))));
    end
    %variable = variable / n;
    plot(as, variable, 'DisplayName', strcat('Sims n = ', num2str(n)), 'LineWidth', 4);
    hold on
    legend('-DynamicLegend')
    plot(ass, aApprox, 'DisplayName', strcat('Approx n = ', num2str(n)), 'LineWidth', 4);
    xlabel('a = lowest possible threshold')
    ylabel('Increment Size')
    %ylim([-10 10])
    ylim([-2 2])
    title('Increment size vs a')
    
    subplot(1,2,2)
    %zMin = .15;
    [ns, variable] = VsN(folderName, variableName, maxN,zMin2,zMax,redo);
%     for i = 1:length(ns)
%         variable(i) = variable(i)/ns(i);
%     end
    nthings = linspace(10,maxN,101);
    a = zMin2;
    for i = 1:101
        n = nthings(i);
        %nApprox(i) = (a^2*n)/(2*log(n));
        nApprox(i) = (a^2*(n-1))/(pi*(log((2*a^5*n^2)/(27*(zMax-a)^2))));
    end
    plot(ns, variable, 'DisplayName', strcat('sims a = ', num2str(zMin2)),'LineWidth', 4);
    hold on
    legend('-DynamicLegend')
    plot(nthings, nApprox, 'DisplayName', strcat('Approx a = ', num2str(zMin2)),'LineWidth', 4);
    xlabel('n = size of clique')
    ylabel('Increment Size')
    %ylim([-10 10])
    ylim([-2 2])
    title('Increment size vs n')
    
    tit1 = 'Expected size of increment in second wave';
    tit2 = strcat('conditioned on accurate first decision, \theta_{max} = ', num2str(zMax));
    
    tit = {tit1;tit2};
    sgtitle(tit)
end



% Compares total fractions of accurate deciders split by FD accuracy
function fracDecidersAcc(zMin,zMax,n_array)
    fs = 12; lw = 3; 
    redo = 0; waves = 1; social = 0;
    folderName = 'NewTent';
    tit2 = 'Tent Distribution';
    waveNum = 2; % second wave. for first wave, waveNum = 1
    tit1 = 'Fraction of Deciders in Second Wave Choosing Correctly';
    figure
    for i = 1:length(n_array)
        n = n_array(length(n_array)+1-i);
        variableName = 'wavesDec';
        [a,variableDec] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
        variableName = 'wavesAcc';
        [a,variableAcc] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
        for j = 1:length(a)
            varFDA(j) = sum(variableAcc(j,waveNum,1))/sum(variableDec(j,waveNum,1));
            varFDW(j) = sum(variableAcc(j,waveNum,2))/sum(variableDec(j,waveNum,2));
            varFD(j) = sum(variableAcc(j,waveNum,3))/sum(variableDec(j,waveNum,3));
        end
        subplot(2,2,1)
        plot(a,varFDA, 'DisplayName', strcat('n = ', num2str(n)), ...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
        subplot(2,2,3)
        plot(a,varFDW, 'DisplayName', strcat('n = ', num2str(n)), ...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
        subplot(2,2,2)
        plot(a,varFD, 'DisplayName', strcat('n = ', num2str(n)), ...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
        
    end
    
    subplot(2,2,1)
    xlabel('a (smallest possible \theta )')
    ylabel('fraction of deciders correct')
    title('First Decision Accurate')
    %ylim([0 1])
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
    
    subplot(2,2,3)
    xlabel('a (smallest possible \theta )')
    ylabel('fraction of deciders correct')
    title('First Decision Wrong')
    ylim([0 1])
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
    
    subplot(2,2,2)
    xlabel('a (smallest possible \theta )')
    ylabel('fraction of deciders correct')
    title('First Decision Irrelevant')
    ylim([0 1])
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
    
    
    tit = {tit1;tit2};
    sgtitle(tit, 'FontSize', fs+4, 'FontWeight', 'bold')
end
function fracDecfracAcc2by2(zMin,zMax,n_array)
    folderName = 'Bern2';
    tit3 = 'Half and Half Bernoulli';
    
     lw = 2; fs = 12; social = 0; waves = 1;
    figure
    
        variableName = 'wavesAcc'; redo = 0;
    for q = 1:length(n_array)
       % fraction deciding when FDA
        n = n_array(length(n_array)+1-q);
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
    
    for j = 1:length(variable(:,1,2))
        variableFDW(j) = sum(variable(j,:,2))/n;
        variableFD(j) = sum(variable(j,:,3))/n;
        a2(j) = a(j);
    end
    %variable2 = variable2/n;
    subplot(2,2,1)
    plot(a2, variableFDW, ...
        'DisplayName', strcat('n = ',num2str(n)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    subplot(2,2,3)
    plot(a2, variableFD, ...
        'DisplayName', strcat('n = ',num2str(n)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    end
    subplot(2,2,1)
    tit1 = 'Fraction of clique deciding accurately';
    tit2 = 'conditioned on wrong first decision';
    tit = {tit1;tit2};
    title(tit, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')  
    
    subplot(2,2,3)
    tit1 = 'Fraction of clique deciding accurately';
    tit2 = 'disregarding first decision accuracy';
    tit = {tit1;tit2};
    title(tit, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')  
    
    variableName = 'wavesDec';
    for q = 1:length(n_array)
       % fraction deciding when FDA
        n = n_array(length(n_array)+1-q);
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
    
    for j = 1:length(variable(:,1,2))
        variableFDW(j) = sum(variable(j,:,2))/n;
        variableFD(j) = sum(variable(j,:,3))/n;
        a2(j) = a(j);
    end
    %variable2 = variable2/n;
    subplot(2,2,2)
    plot(a2, variableFDW, ...
        'DisplayName', strcat('n = ',num2str(n)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    subplot(2,2,4)
    plot(a2, variableFD, ...
        'DisplayName', strcat('n = ',num2str(n)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    end
    subplot(2,2,2)
    tit1 = 'Fraction of clique deciding';
    tit2 = 'conditioned on wrong first decision';
    tit = {tit1;tit2};
    title(tit, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')  
    
    subplot(2,2,4)
    tit1 = 'Fraction of clique deciding';
    tit2 = 'disregarding first decision accuracy';
    tit = {tit1;tit2};
    title(tit, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')  
    
    tit1 = 'Fraction of Clique Deciding Accurately and Deciding';
    
    tit = {tit1;tit3};
    sgtitle(tit,...
        'FontWeight', 'bold','FontSize', fs+8)
end
% Fraction of clique deciding in first and second wave
% split by first decision accuracy
function SecondAndFirst2by2(zMin,zMax,n_array)
    folderName = 'Bern2';
    tit3 = 'Half and Half Bernoulli';
    
     lw = 2; fs = 12; social = 0; waves = 1;
    figure
    
        variableName = 'wavesDec'; redo = 0;
    for q = 1:length(n_array)
       % fraction deciding when FDA
        n = n_array(length(n_array)+1-q);
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
    
    for j = 1:length(variable(:,1,2))
        variableFDW(j) = variable(j,2,2)/n;
        variableFDA(j) = variable(j,2,1)/n;
        a2(j) = a(j);
    end
    %variable2 = variable2/n;
    subplot(2,2,1)
    plot(a2, variableFDA, ...
        'DisplayName', strcat('n = ',num2str(n)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    subplot(2,2,3)
    plot(a2, variableFDW, ...
        'DisplayName', strcat('n = ',num2str(n)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    end
    subplot(2,2,1)
    tit1 = 'Fraction of clique deciding in second wave';
    tit2 = 'conditioned on accurate first decision';
    tit = {tit1;tit2};
    title(tit, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    ylim([0 1])
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')  
    
    subplot(2,2,3)
    tit1 = 'Fraction of clique deciding in second wave';
    tit2 = 'conditioned on wrong first decision';
    tit = {tit1;tit2};
    title(tit, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    ylim([0 1])
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')  
    
    %variableName = 'wavesDec';
    for q = 1:length(n_array)
       % fraction deciding when FDA
        n = n_array(length(n_array)+1-q);
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
    
    for j = 1:length(variable(:,1,2))
        variableFDW(j) = variable(j,1,2)/n;
        variableFDA(j) = variable(j,1,1)/n;
        a2(j) = a(j);
    end
    %variable2 = variable2/n;
    subplot(2,2,2)
    plot(a2, variableFDA, ...
        'DisplayName', strcat('n = ',num2str(n)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    subplot(2,2,4)
    plot(a2, variableFDW, ...
        'DisplayName', strcat('n = ',num2str(n)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    end
    subplot(2,2,2)
    tit1 = 'Fraction of clique deciding in first wave';
    tit2 = 'conditioned on accurate first decision';
    tit = {tit1;tit2};
    title(tit, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    ylim([0 1])
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')  
    
    subplot(2,2,4)
    tit1 = 'Fraction of clique deciding in first wave';
    tit2 = 'conditioned on wrong first decision';
    tit = {tit1;tit2};
    title(tit, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    ylim([0 1])
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')  
    
    tit1 = 'Fraction of Clique Deciding In Second (Left) and First (Right) Waves';
    
    tit = {tit1;tit3};
    sgtitle(tit,...
        'FontWeight', 'bold','FontSize', fs+8)
end

% Plots percent of those deciding in a wave accurately
% Fraction of those deciding in wave, not fraction in clique
function firstVsSecondAccuracy()
    fs = 12; lw = 3; maxN = 1000;
    waves = 1; social = 0; redo = 0;
    folderName = 'Bern2';
    variableName = 'wavesAcc';
    zMax = 1; zMin = .1;
    %figure
    [ns, acc] = VsN(folderName, variableName, maxN,zMin,zMax,redo,social,waves);
    variableName = 'wavesDec';
    [ns, dec] = VsN(folderName, variableName, maxN,zMin,zMax,redo,social,waves);
    for i = 1:length(ns)
        first(i) = acc(i,1,3)/dec(i,1,3);
        second(i) = acc(i,2,3)/dec(i,2,3);
    end
    subplot(1,2,1)
    plot(ns, first, 'DisplayName', strcat('a = ', num2str(zMin)),'LineWidth', lw)
    legend('-DynamicLegend')
    hold on
    xlabel('n = number of agents')
    ylabel('fraction of first wave')
    title('Fraction of First Wave Accurate')
    ylim([0 1])
    xlim([0 1000])
    set(gca, 'FontWeight', 'bold', 'FontSize', fs)
    subplot(1,2,2)
    plot(ns, second, 'DisplayName', strcat('\theta = ', num2str(zMax)),'LineWidth', lw)
    legend('-DynamicLegend')
    hold on
    xlabel('n = number of agents')
    ylabel('fraction of second wave')
    title('Fraction of Second Wave Accurate')
    ylim([0 1])
    xlim([0 1000])
    set(gca, 'FontWeight', 'bold', 'FontSize', fs)
    
end

% Fraction of clique choosing accurately and inaccurately
% in second wave, split by first decision accuracy
function secondWaveCheck(zMin,zMax,n_array)
    lw = 3; fs = 12; social = 0; waves = 1; redo = 0;
    
    folderName = 'Bern2'; variableName = 'wavesAcc';
    tit2 = 'Half and Half Bernoulli';
    figure
    for i = 1:length(n_array)
        n = n_array(i);
        variableName = 'wavesAcc';
        [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
        variable = variable ./ n;
        subplot(2,2,1) %FDA
        plot(a, variable(:,2,1),'DisplayName', strcat('n = ', num2str(n)),...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
        subplot(2,2,3) %FDW
        plot(a, variable(:,2,2),'DisplayName', strcat('n = ', num2str(n)),...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
        variableName = 'wavesWrong';
        [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
        variable = variable ./ n;
        subplot(2,2,2) % 1st wave FDA, for comparison
        plot(a, variable(:,2,1),'DisplayName', strcat('n = ', num2str(n)),...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
        subplot(2,2,4) % 1st wave FDW, for comparison
        plot(a, variable(:,2,2),'DisplayName', strcat('n = ', num2str(n)),...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
    end
    subplot(2,2,1)
    ylabel('Fraction of Clique')
    xlabel('a (smallest possible \theta )')
    ylim([0 1])
    title('Second Wave Accurate, FD: Accurate')
    set(gca, 'FontWeight', 'bold', 'FontSize', fs)
    
    subplot(2,2,2)
    ylabel('Fraction of Clique')
    xlabel('a (smallest possible \theta )')
    ylim([0 1])
    title('Second Wave Wrong, FD: Accurate')
    set(gca, 'FontWeight', 'bold', 'FontSize', fs)
    
    subplot(2,2,3)
    ylabel('Fraction of Clique')
    xlabel('a (smallest possible \theta )')
    ylim([0 1])
    title('Second Wave Accurate, FD: Wrong')
    set(gca, 'FontWeight', 'bold', 'FontSize', fs)
    
    subplot(2,2,4)
    ylabel('Fraction of Clique')
    xlabel('a (smallest possible \theta )')
    ylim([0 1])
    title('Second Wave Wrong, FD: Wrong ')
    set(gca, 'FontWeight', 'bold', 'FontSize', fs)
   tit1='Fraction choosing accurately (Left) and Inaccurately (Right) in Second Wave';
   
   tit = {tit1;tit2};
   sgtitle(tit, 'FontWeight', 'bold',...
        'FontSize', fs+4)
end

% plots both accurate and wrong first wave together, second wave together
function firstSecondFDAFDW()
    fs = 12; lw = 3; maxN = 15000;
    social = 0; redo = 0; waves = 1;
    folderName = 'Bern2';
    zMax = 1; zMin = .1;
    figure
    variableName = 'wavesAcc';
    [ns3, vAcc] = VsN(folderName, variableName, maxN,zMin,zMax,redo,social,waves);
    variableName = 'wavesWrong';
    [ns2, vWrong] = VsN(folderName, variableName, maxN,zMin,zMax,redo,social,waves);
    nndex = 1;
    for i = 1:length(ns2)
      
        n = ns2(i);
        vAcc(i,1,1) = vAcc(i,1,1)/n; vAcc(i,2,1) = vAcc(i,2,1)/n;
        vAcc(i,1,2) = vAcc(i,1,2)/n; vAcc(i,2,2) = vAcc(i,2,2)/n;
        vWrong(i,1,1) = vWrong(i,1,1)/n; vWrong(i,2,1) = vWrong(i,2,1)/n;
        vWrong(i,1,2) = vWrong(i,1,2)/n; vWrong(i,2,2) = vWrong(i,2,2)/n;
        sumAccFDA(nndex) = vAcc(i,1,1) + vAcc(i,2,1); sumWrongFDA(nndex) =  vWrong(i,1,1)+vWrong(i,2,1);
        sumAccFDW(nndex) = vAcc(i,1,2) + vAcc(i,2,2); sumWrongFDW(nndex) = vWrong(i,1,2) + vWrong(i,2,2);
        ns(nndex) = ns2(i);
        nndex = nndex + 1;
        
    end
    subplot(1,2,1)
    plot(ns, sumAccFDA, 'DisplayName', 'Accurate First Decision', 'LineWidth', lw)
    legend('-DynamicLegend')
    hold on
    plot(ns, sumAccFDW, 'DisplayName', 'Wrong First Decision', 'LineWidth', lw)
    xlabel('n = number of agents')
    ylabel('fraction of clique')
    title('Fraction Deciding Accurately')
    set(gca, 'FontWeight', 'bold', 'FontSize',fs)
    subplot(1,2,2)
    plot(ns, sumWrongFDA, 'DisplayName', 'Accurate First Decision', 'LineWidth', lw)
    legend('-DynamicLegend')
    hold on
    plot(ns, sumWrongFDW, 'DisplayName', 'Wrong First Decision', 'LineWidth', lw)
    xlabel('n = number of agents')
    ylabel('fraction of clique')
    title('Fraction Deciding Wrongly')
    set(gca, 'FontWeight', 'bold', 'FontSize',fs)
end


% Makes histogram of first decision times and compares it 
% with expected (analytic) values for Uniform dist
function FDTimeDistributionUniform2by2(zMin,zMax,n)
    figure
    subplot(1,2,1)
    FDTimeDistributionUniform(zMin,zMax,n(1))
    subplot(1,2,2)
    FDTimeDistributionUniform(zMin,zMax,n(2))
    tit1 = 'First Decision Time distributions';
    tit2 = strcat('for uniform distribution on [', num2str(zMin),', ', ...
        num2str(zMax),']');
    tit = {tit1;tit2};
    sgtitle(tit, 'FontSize', 18, 'FontWeight', 'bold')
end
function FDTimeDistributionUniform(zMin,zMax,n)
    folderName = 'Uniform'; 
    numT = 101; lw = 2; fs = 12; redo = 1;
    
    folderName2 = strcat(folderName, '/zMin_', ...
        strrep(num2str(zMin),'.','_'),'_zMax_',...
        strrep(num2str(zMax),'.','_'));
        filename = strcat(folderName2,'/Cooked_n',num2str(n),'.mat');
        if redo > 0
            delete(filename)
            chef(folderName, zMin, zMax, n);
        end
    gru = load(filename, 'histTime');
    histTime = gru.histTime;
    minT = min(histTime); maxT = max(histTime);
    sims = histTime;
    histogram(sims, 'normalization', 'pdf')
    hold on
    phi = @(theta,t) .5.*((1 + exp(theta)).*erfc((theta + t)/(2.*sqrt(t)))+...
        (1 + exp(-theta)).*erfc((theta-t)/(2.*sqrt(t))));
    rho = @(theta,t) (theta/sqrt(pi.*t^3)).*...
        exp(-(theta.^2 + t^2)/(4.*t)).*cosh(theta/2);
    thetaList = linspace(zMin,zMax,n);
    
    ts = linspace(minT, maxT, numT);
    for q = 1:numT
        t = ts(q);
        sumExp = 0;
        for i = 1:n
            sumPhi = 0;
            for j = 1:n
                sumPhi = sumPhi + phi(thetaList(j),t);
            end
            sumPhi = sumPhi - phi(thetaList(i),t);
            sumExp = sumExp + exp(-sumPhi)*rho(thetaList(i),t);
        end
        sigma(q) = sumExp;
        phiInte = integral(@(theta)phi(theta,t),zMin,zMax);
        rhoInte = integral(@(theta)rho(theta,t),zMin,zMax);
        inte(q) = (n/(zMax-zMin))*exp(((-n)/(zMax-zMin))*phiInte)*rhoInte;
    end
    
    plot(ts, sigma, 'DisplayName', 'Eq (6.6)', 'LineWidth', lw)
    legend('-DynamicLegend')
    hold on
    plot(ts, inte, 'DisplayName', 'Eq (6.7)', 'LineWidth', lw)
    ylabel('First Decision Time')
    title(strcat('n = ', num2str(n)))
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
end

function expectedFDTimeHomo2()
    fs = 12; lw = 3; 
    social = 0; waves = 0; redo = 1; 
    thetas = [.1,.3,.5]; maxN = 300;
    folderName = 'SelfHomo'; variableName = 'avgTime';
    colors = ['b','r','m'];
    figure
    for i = 1:3
        z = thetas(i);
        [ns, variable] = VsN(folderName, variableName, maxN,z,z,redo,social,waves);
        for j = 1:length(ns)
            n = ns(j);
            expec(j) = z^2/(4*log(n));            
        end
        plot(ns, variable, colors(i), 'DisplayName', strcat('Sims for \theta = ', num2str(z)),...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
        plotty = strcat(colors(i),'--');
        plot(ns, expec, plotty, 'DisplayName', strcat('E[T_1] for \theta = ', num2str(z)),...
            'LineWidth', lw)
    end
    xlabel('n = number of agents')
    ylabel('First Decision Time')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
end

function FDThreshold)
    fs = 12; lw = 3; maxN = 10000;
    waves = 0; social = 0; redo = 0;
    folderName = 'Uniform';
    variableName = 'avgFDThresh';
    %zMin = 0.1; 
    n_array = [40,150,1000,10000];
    zMin = 0.1;
    zMax = 1;
    tit1 = 'Average First Decision Threshold';
    tit2 = 'Uniform Distribution on [a, 1]';
    figure
    for i = 1:length(n_array)
        n = n_array(i);
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
    plot(a, variable, 'DisplayName', strcat('n = ', num2str(n)), 'LineWidth', lw)
    legend('-DynamicLegend')
    hold on
    end
    plot(a,a, '--','DisplayName', 'line a = a', 'LineWidth', lw)
    xlabel('a = smallest possible threshold')
    ylabel('average threshold')
    title({tit1;tit2})
    %ylim([0 .2])
    xlim([zMin max(a)])
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
end



% Compares expected (analytic) and simulation results 
% for the size of the first wave, uniform.
% The analytic expression may need updating.
% (Update inside the first two functions)
function expectedFirstSelfUniform(zMin, zMax,n)
    folderName = 'SelfUniform';
    variableName = 'wavesDec';
    redo = 0; numA = 101; lw = 4; fs = 12;
    social = 0; waves = 1;
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
    figure
    variable = variable/n;
    plot(a, variable(:,1,1), '--',...
        'DisplayName', 'Sims for first wave',...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    as = linspace(zMin,zMax,numA);
    for i = 1:numA
        a = as(i);
        %expec1(i) = ((n-1)/2)*(1 + (a/(sqrt(4*pi*log(n)))));
        expec1(i) = ((n-1)/2)*(1+(a/sqrt(2*pi*log((2*(a^5)*(n^2))/(27*(zMax-a)^2)))));
    end
    expec1 = expec1/n;
    plot(as,expec1,...
        'DisplayName', 'Expected value for first wave',...
        'LineWidth', lw)
    
    tit1 = 'Expected size of first wave';
    tit2 = 'conditioned on accurate first decision';
    tit3 = strcat('Self-referential uniform case, \theta_{max = }', num2str(zMax), ', n = ', num2str(n));
    tit = {tit1;tit2; tit3};
    title(tit, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
end
function expectedFirstUniform(zMin, zMax,n)
    folderName = 'Uniform';
    variableName = 'wavesDec';
    redo = 1; numA = 101; lw = 4; fs = 12;
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo);
    figure
    variable = variable/n;
    plot(a, variable(:,1,1), '--',...
        'DisplayName', 'Sims for first wave',...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    as = linspace(zMin,zMax,numA);
    for i = 1:numA
        a = as(i);
        %expec1(i) = ((n-1)/2)*(1 + (a/(sqrt(4*pi*log(n)))));
        expec1(i) = ((n-1)/2)*(a^2/(log((2*(a^5)*(n^2))/(27*(zMax-a)^2))))
    end
    expec1 = expec1/n;
    plot(as,expec1,...
        'DisplayName', 'Expected value for first wave',...
        'LineWidth', lw)
    
    tit1 = 'Expected size of first wave';
    tit2 = 'conditioned on accurate first decision';
    tit3 = strcat('Uniform case, \theta_{max = }', num2str(zMax), ', n = ', num2str(n));
    tit = {tit1;tit2; tit3};
    title(tit, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
end
function expectedFirstSelfUniform2by2(zMin, zMax,n_array)
    folderName = 'Uniform';
    variableName = 'wavesDec';
    redo = 0; numA = 101; lw = 4; fs = 12; social = 0;
    figure
    for q = 1:4
        subplot(2,2,q)
        n = n_array(q);
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social);
    
    variable = variable/n;
    plot(a, variable(:,1,1), '--o',...
        'DisplayName', 'Sims for first wave',...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    as = linspace(zMin,zMax,numA);
    for i = 1:numA
        a = as(i);
        %expec1(i) = ((n-1)/2)*(1 + (a/(sqrt(4*pi*log(n)))));
        %expec1(i) = ((n-1)/2)*(1+(a/sqrt(2*pi*log((2*(a^5)*(n^2))/(27*(zMax-a)^2)))));
        expec1(i) = ((n-1)/2)*(a^2/(log((2*(a^5)*(n^2))/(27*(zMax-a)^2))));
    end
    expec1 = expec1/n;
    plot(as,expec1,...
        'DisplayName', 'Expected value for first wave',...
        'LineWidth', lw)
    
    tit1 = 'Expected size of first wave';
    tit2 = 'conditioned on accurate first decision';
    tit3 = strcat('Uniform case, \theta_{max = }', num2str(zMax), ', n = ', num2str(n));
    tit = {tit1;tit2};
    title(tit3, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')  
    end
    sgtitle(tit, 'FontSize', fs+8, 'FontWeight', 'bold')
end
function expectedFirstUniform2by2(zMin, zMax,n_array)
    folderName = 'Uniform';
    variableName = 'wavesDec';
    redo = 0; numA = 101; lw = 4; fs = 12; social = 0;
    figure
    for q = 1:4
        subplot(2,2,q)
        n = n_array(q);
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social);
    
    variable = variable/n;
    plot(a, variable(:,1,1), '--o',...
        'DisplayName', 'Sims for first wave',...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    as = linspace(zMin,zMax-.4,numA);
    for i = 1:numA
        a = as(i);
        %expec1(i) = ((n-1)/2)*(1 + (a/(sqrt(4*pi*log(n)))));
        expec1(i) = ((n-1)/2)*(a^2/(log((2*(a^5)*(n^2))/(27*(zMax-a)^2))));
    end
    %expec1 = expec1/n;
    plot(as,expec1,...
        'DisplayName', 'Expected value for first wave',...
        'LineWidth', lw)
    
    tit1 = 'Expected size of first wave';
    tit2 = 'conditioned on accurate first decision';
    tit3 = strcat('Uniform case, \theta_{max = }', num2str(zMax), ', n = ', num2str(n));
    tit = {tit1;tit2};
    title(tit3, 'FontSize', fs + 4)
    xlabel('a = lower threshold')
    ylabel('fraction of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')  
    end
    sgtitle(tit, 'FontSize', fs+8, 'FontWeight', 'bold')
end


%--------------------------------------------------------

% Functions specifically for Bernoulli and Shed

% variableName may be changed to suit
function Bernbyz1PervsA()
    z1Per_array = [0.1,0.3,0.7,0.9];
    n_array = [150,1000,5000,10000,15000];
    folderSmall = 'Bern2_smallPer_';
    zMin = 0.05; zMax = 1;
    social = 0; redo = 0; waves = 0;
    variableName = 'avgTime';
    tit1 = 'Acerage First Decision Time';
    tit2 = 'Omniscient Bernoulli Case; Upper Threshold = 1';
    tit = {tit1;tit2};
    figure
    for i = 1:length(n_array)
        n = n_array(i);
        subplot(2,3,i)
        for j = 1:length(z1Per_array)
            z1Per = z1Per_array(j);
            folderName = strcat(folderSmall, strrep(num2str(z1Per), '.','_'));
            %variableName = 'wavesAcc';
             [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
%             for k = 1:length(a)
%                 %variable(k) = sum(variable1(k,:,3))/n;
%                 variable(k) = sum(variable1(k,:,3))/sum(variable2(k,:,3));
%             end
            plot(a,variable, 'DisplayName', strcat('z1Per = ', num2str(z1Per)), 'LineWidth', 2)
            legend('-DynamicLegend')
            hold on
        end
        xlabel('lower threshold')
        ylabel('fraction of clique')
        title(strcat('n = ', num2str(n)))
    end
    sgtitle(tit, 'FontWeight', 'bold', 'FontSize', 16)
end
function z1PerArray()
    n_array = [40,300,1000,5000,10000,15000];
    n_array = fliplr(n_array);
    a_array = [0.05,0.1,0.2,0.3,0.4,0.5,0.7,0.8];
    variableName = 'avgTime';
    xlab = 'Average First Decision Time';
    ylab = 'Fraction of Clique';
    tit1 = 'Fraction of Deciders Accurate';
    tit2 = 'Omniscient Bernoulli Case; Upper Threshold = 1';
    tit = {tit1;tit2};
    figure
    for i = 1:length(a_array)
        zMin = a_array(i);
        subplot(3,3,i)
        z1PerbyN2(zMin, variableName, n_array,xlab,ylab)
        ylim([0 1])
    end
    sgtitle(tit, 'FontSize', 16, 'FontWeight', 'bold')
end
function z1PerbyN(zMin, variableName, n_array,xlab,ylab)
%n_array = [40,150,300,500,1000];%,5000,10000,15000];
%zMin = .8; 
zMax = 1;
redo = 0; social = 0; waves = 0;
folderName = 'Bern2';
%ylab = 'Time'; xlab = 'Percent of Clique at lower threshold';
%figure
linecolors = winter(length(n_array));
tit1 = 'Percent of Clique Deciding Accurately';
tit2 = strcat('lower threshold = ', num2str(zMin));%, ', upper threshold = ', num2str(zMax));
for i = 1:length(n_array)
    n = n_array(i);
%     [z1Per,variable1] = Vsz1Per(folderName, variableName, n, zMin, zMax,redo,social,waves);
%     for j = 1:length(z1Per)
%         variable(j) = sum(variable1(j,:,3))/n;
%     end
    plot(z1Per, variable, 'DisplayName', strcat('n = ', num2str(n)),...
        'Color', linecolors(i,:),'LineWidth',2)
    legend('-DynamicLegend')
    hold on
end
tit = {tit1;tit2};
xlabel(xlab)
ylabel(ylab)
title(tit2)
set(gca, 'FontSize', 10)
end
function z1PerbyN2(zMin, variableName,n_array,xlab,ylab)
%n_array = [40,150,300,500,1000];%,5000,10000,15000];
%zMin = .8; 
zMax = 1;
redo = 0; social = 0; waves = 1;
folderName = 'Bern2';
%ylab = 'Time'; xlab = 'Percent of Clique at lower threshold';
%figure
linecolors = jet(length(n_array));
tit1 = 'Percent of Clique Deciding ';
tit2 = strcat('lower threshold = ', num2str(zMin));%, ', upper threshold = ', num2str(zMax));
for i = 1:length(n_array)
    n = n_array(i);
    variableName = 'wavesAcc';
    [z1Per,variable1] = Vsz1Per(folderName, variableName, n, zMin, zMax,redo,social,waves);
    
    variableName = 'wavesDec';
    [z1Per,variable2] = Vsz1Per(folderName, variableName, n, zMin, zMax,redo,social,waves);
    for j = 1:length(z1Per)
        variable(j) = sum(variable1(j,:,3))/sum(variable2(j,:,3));
    end
    plot(z1Per, variable, 'DisplayName', strcat('n = ', num2str(n)),...
        'Color', linecolors(i,:),'LineWidth',2)
    legend('-DynamicLegend')
    hold on
end
tit = {tit1;tit2};
xlabel(xlab)
ylabel(ylab)
title(tit2)
set(gca, 'FontSize', 10)
end


%-- Shed
function singleVariableShed(h_as,zMin,zMax,n, variableName,tit1)
    fs = 12; lw = 3;
    waves = 0; social = 0; redo = 0;
    smallFolder = 'Shed';
    
    
    tit2 = strcat('n = ', num2str(n));
    tit = {tit1;tit2};
    ylabel('FD time')
    for j = 1:length(h_as)
        ha = h_as(j);
        folderName = strcat(smallFolder, '/h_a_', strrep(num2str(ha),'.','_'));
        [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
        
        plot(a,variable, 'DisplayName', strcat('height = ', num2str(ha)),...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
    end
    xlabel('a = smallest possible threshold')
    title(tit)
    set(gca, 'FontWeight', 'bold', 'FontSize',fs)
end
function FDTimeShed(h_as, zMin, zMax,n_array)
    er = length(n_array);
    variableName = 'wavesAcc';
    tit1 = 'Fraction of Deciders Accurate';
    ylima = 0; ylimb = 1;
    if er <= 2
        rowNum = 1; colNum = 2;
    else
        if er <= 4
            rowNum = 2; colNum = 2;
        else
            if er <= 6
                rowNum = 3; colNum = 2;
            else
                if er <= 8
                    rowNum = 2; colNum = 4;
                end
            end
        end
    end
    figure
    for i = 1:er
        subplot(rowNum,colNum,i)
        n = n_array(i);
        wavesShed(h_as,zMin,zMax,n, variableName,tit1)
        %a = linspace(zMin,zMax,100);
        %plot(a,a,'--','DisplayName', 'a = a')
        ylim([ylima ylimb])
    end
end
function wavesShed(h_as,zMin,zMax,n, variableName,tit1)
    fs = 12; lw = 3;
    waves = 1; social = 0; redo = 0;
    smallFolder = 'Shed';
    
    
    tit2 = strcat('n = ', num2str(n));
    tit = {tit1;tit2};
    ylabel('FD time')
    for j = 1:length(h_as)
        ha = h_as(j);
        folderName = strcat(smallFolder, '/h_a_', strrep(num2str(ha),'.','_'));
        variableName = 'wavesAcc';
        [a,variableA] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
        variableName = 'wavesDec';
        [a,variableD] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves);
        for i = 1:length(a)
            dec(i) = sum(variableA(i,:,3))/n;
            accDec(i) = sum(variableA(i,:,3))/sum(variableD(i,:,3));
        end
        plot(a,accDec, 'DisplayName', strcat('height = ', num2str(ha)),...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
    end
    xlabel('a = smallest possible threshold')
    title(tit)
    set(gca, 'FontWeight', 'bold', 'FontSize',fs)
end

function singleVariableByHShed(zMin,zMax,n_array, variableName,tit1,ylab)
    fs = 12; lw = 3;
    waves = 0; social = 0; redo = 0;
    folderName = 'Shed'; hMax = 3;
    
    
    tit2 = strcat('a = ', num2str(zMin));
    tit = {tit1;tit2};
    ylabel(ylab)
    for j = 1:length(n_array)
        n = n_array(j);
        [ha,variable] = ...
            VsH(folderName, variableName, n, zMin, zMax,hMax,redo,social,waves);

        
        plot(ha,variable, 'DisplayName', strcat('n = ', num2str(n)),...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
    end
    xlabel('h = height at a')
    title(tit)
    set(gca, 'FontWeight', 'bold', 'FontSize',fs)
end
function wavesByH(zMin,zMax,n_array, variableName,tit1,ylab)
    fs = 12; lw = 3;
    waves = 1; social = 0; redo = 0;
    folderName = 'Shed'; hMax = 3;
    
    
    tit2 = strcat('a = ', num2str(zMin));
    tit = {tit1;tit2};
    ylabel(ylab)
    for j = 1:length(n_array)
        n = n_array(j);
        variableName = 'wavesAcc';
        [ha,variableA] = ...
            VsH(folderName, variableName, n, zMin, zMax,hMax,redo,social,waves);
        variableName = 'wavesDec';
        [ha,variableD] = ...
            VsH(folderName, variableName, n, zMin, zMax,hMax,redo,social,waves);
        for i = 1:length(ha)
            dec(i) = sum(variableD(i,:,3))/n;
            accDec(i) = sum(variableA(i,:,3))/sum(variableD(i,:,3));
        end
        plot(ha,accDec, 'DisplayName', strcat('n = ', num2str(n)),...
            'LineWidth', lw)
        legend('-DynamicLegend')
        hold on
    end
    xlabel('h = height at a')
    title(tit)
    set(gca, 'FontWeight', 'bold', 'FontSize',fs)
end
function GridShed(as, zMax,n_array)
    er = length(as);
    variableName = 'wavesDec';
    tit1 = 'Fraction of Deciders Accurate';
    ylab = 'fraction of deciders';
    ylima = 0; ylimb = 1;
    if er <= 2
        rowNum = 1; colNum = 2;
    else
        if er <= 4
            rowNum = 2; colNum = 2;
        else
            if er <= 6
                rowNum = 3; colNum = 2;
            else
                if er <= 8
                    rowNum = 2; colNum = 4;
                end
            end
        end
    end
    figure
    for i = 1:er
        subplot(rowNum,colNum,i)
        zMin = as(i);
        %singleVariableByHShed(zMin,zMax,n_array, variableName,tit1,ylab)
        wavesByH(zMin,zMax,n_array, variableName,tit1,ylab)
        ylim([ylima ylimb])
        %a = linspace(zMin,zMax,100);
        %plot(a,a,'--','DisplayName', 'a = a')
    end
end




%--------------------------------------------------------
% Unusable functions

% Too messy: (have been modified too many times; too messy)
function wavesForTentPickOne()
        zMin = .1; zMax = 1; 
        n_array = [40,80,150,300]; maxN = 300;
        a_array = [.1,.3,.5,.7];
        folderName = 'Tent'; 
        variableName = 'wavesAcc'; 
        normalize = 1; cumulative = 1;
        
        redo = 0;
        numRows = 3; numCols = 2;
        
        waveNum = 1; FD = 1;
        col1 = 1; col2 = 2; adj = ' first';
        %figure
        subplot(numRows,numCols,col1)
        %subplot(1,2,1)
        for i = 1:4
            n = n_array(i);
            [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo);
            
            if normalize > 0
                variable = variable ./n;
%                 if cumulative > 0
%                     if waveNum > 1
%                     for j = 2:waveNum
%                         variable(:,j,FD) = variable(:,j,FD) + variable(:,j-1,FD);
%                     end
%                     end
%                 end
                plot(a,variable(:,waveNum,FD), 'DisplayName', strcat('n =',num2str(n)),'LineWidth',4)
            else
                 plot(a,variable, 'DisplayName', strcat('n = ',num2str(n)),'LineWidth',4)
            end
            legend('-DynamicLegend')
            hold on
        end
        xlabel('zMin = lowest possible threshold')
        ylim([0 1])
        title(strcat('During ',adj,' wave'))
        subplot(numRows,numCols,col2)
                for i = 1:4
            n = n_array(i);
            [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo);
            
            if normalize > 0
                variable = variable ./n;
                if cumulative > 0
                    if waveNum > 1
                    for j = 2:waveNum
                        variable(:,j,FD) = variable(:,j,FD) + variable(:,j-1,FD);
                    end
                    end
                end
                plot(a,variable(:,waveNum,FD), 'DisplayName', strcat('n =',num2str(n)),'LineWidth',4)
            else
                 plot(a,variable, 'DisplayName', strcat('n = ',num2str(n)),'LineWidth',4)
            end
            legend('-DynamicLegend')
            hold on
        end
        xlabel('zMin = lowest possible threshold')
        ylim([0 1])
        title(strcat('After ',adj,' wave'))
        %subplot(3,2,6)
%         for i = 1:4
%             zMin = a_array(i);
%             [ns, variable] = VsN(folderName, variableName, maxN,zMin,zMax,redo);
%             if normalize == 1
%                 variable(1,waveNum,FD) = variable(1,waveNum,FD)/40; 
%                 variable(2,waveNum,FD) = variable(2, waveNum, FD)/80;
%                 variable(3,waveNum, FD) = variable(3,waveNum,FD)/150; 
%                 variable(4,waveNum,FD) = variable(4,waveNum,FD)/300;
%                 if cumulative > 0
%                     if waveNum > 1
%                     for j = 2:waveNum
%                         variable(:,j,FD) = variable(:,j,FD) + variable(:,j-1,FD);
%                     end
%                     end
%                 end
%                 plot(ns, variable(:,waveNum,FD), 'DisplayName', strcat('zMin =',num2str(zMin)), 'LineWidth',4);
%             else
%                 plot(ns, variable, 'DisplayName',strcat('zMin =', num2str(zMin)), 'LineWidth',4);
%             end
%             
%             legend('-DynamicLegend')
%             hold on
%         end
%         xlabel('n = clique size')
%         title('After First wave vs clique size')
        %gsgtitle(strcat(variableName, ' FD', num2str(FD), ' waveNum ', num2str(waveNum)))
end

% Old; haven't been updated; still usable if updated with waves, social
% Functionality may have been replaced by more generalized functions

    % Grid of plots of the fraction deciding in each wave
function waveSizes(zMin, zMax, minWaves, maxWaves, n)
    figure
    redo = 0;
    subplot(1,3,1)
    for i = minWaves: maxWaves
        waveDecSizes(zMin,zMax, n, i, redo)
        ylim([0 .6]);
        title('Fraction Deciding')
        ylabel('fraction of clique')
        xlabel('a = lower threshold')
    end
    subplot(1,3,2)
    for i = minWaves: maxWaves
        waveAccSizes(zMin,zMax, n, i, redo)
        ylim([0 .6]);
        title('Fraction Accurate')
        ylabel('fraction of clique')
        xlabel('a = lower threshold')
    end
    subplot(1,3,3)
    for i = minWaves: maxWaves
        waveWrongSizes(zMin,zMax, n, i, redo)
        ylim([0 .6]);
        title('Fraction Wrong')
        ylabel('fraction of clique')
        xlabel('a = lower threshold')
    end
    sgtitle(strcat('Self-Referential cases, fractions by wave, n = ',...
        num2str(n)))
end
    % Self descriptive
function expectedFDTandFirstWaveHomo(maxN, zMin)
    figure
    subplot(1,2,1)
    expectedFDTimeHomo(maxN, zMin)
    subplot(1,2,2)
    expectedFirstHomo(maxN,zMin)
    tit2 = strcat('Homogeneous case, \theta = ', num2str(zMin));
    sgtitle(tit2, 'FontSize', 18, 'FontWeight', 'bold')
    
end
function expectedFDTimeHomo(maxN,zMin)

    folderName = 'SelfHomo';
    variableName = 'avgTime';
    zMax = zMin; redo = 1; numN = 101; lw = 2; fs = 12;
    [ns, variable] = VsN(folderName, variableName, maxN,zMin,zMax,redo);
    %figure
    plot(ns, variable, '--',...
        'DisplayName', 'Sims',...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    ns2 = linspace(ns(1),ns(end),numN); theta = zMin;
    for i = 1:numN
        n = ns2(i); 
        expec2(i) = (theta^2)/(4*log(n));
    end
    plot(ns2,expec2,...
        'DisplayName', 'Eq (3.4)',...
        'LineWidth', lw)
    
    tit1 = 'Expected time of first decision';
    tit2 = strcat('homogeneous case, \theta = ', num2str(zMin));
    tit = {tit1;' '};
    title(tit, 'FontSize', fs + 4)
    ylabel('time of first decision')
    xlabel('size of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
end
function expectedSecondHomo(maxN,zMin)
    folderName = 'SelfHomo';
    variableName = 'wavesDec';
    zMax = zMin; redo = 0; numN = 101; lw = 4; fs = 12;
    [ns, variable] = VsN(folderName, variableName, maxN,zMin,zMax,redo);
    figure
    plot(ns, variable(:,2,3), ...
        'DisplayName', 'Sims for second wave',...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    ns2 = linspace(ns(1),ns(end),numN); theta = zMin;
    for i = 1:numN
        n = ns2(i); 
        %Actually, no: this is the expected update in belief.
        expec2(i) = ((theta^2)*n)/(2*pi*(log(n)));
    end
    plot(ns2,expec2,...
        'DisplayName', 'Expected value for second wave',...
        'LineWidth', lw)
    
    tit1 = 'Expected size of second wave for';
    tit2 = strcat('homogeneous case, \theta = ', num2str(zMin));
    tit = {tit1;tit2};
    title(tit, 'FontSize', fs + 4)
    ylabel('number of agents')
    xlabel('size of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
end
function expectedFirstHomo(maxN,zMin)
    folderName = 'SelfHomo';
    variableName = 'wavesDec';
    zMax = zMin; redo = 1; numN = 101; lw = 2; fs = 12;
    [ns, variable] = VsN(folderName, variableName, maxN,zMin,zMax,redo);
    %figure
    plot(ns, variable(:,1,3),'--', ...
        'DisplayName', 'Sims',...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
    
    ns2 = linspace(ns(1),ns(end),numN); theta = zMin;
    for i = 1:numN
        n = ns2(i); 
        expec2(i) = ((n-1)/2)*(1 + (theta/(sqrt(4*pi*log(n)))));
    end
    plot(ns2,expec2,...
        'DisplayName', 'Eq (3.5)',...
        'LineWidth', lw)
    
    tit1 = 'Expected size of first wave';
    tit2 = strcat('homogeneous case, \theta = ', num2str(zMin));
    tit = {tit1;' '};
    title(tit, 'FontSize', fs + 4)
    ylabel('number of agents')
    xlabel('size of clique')
    set(gca, 'FontSize', fs, 'FontWeight', 'bold')
end

% Give number of deciders, right and wrong inside wave
% specified by waveNumber
function waveDecSizes(zMin,zMax, n, waveNumber, redo)
    folderName = 'SelfUniform';
    variableName = 'wavesDec';
    lw = 4; 
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo);
    
    variable = variable/n;
    plot(a, variable(:,waveNumber,3), '--',...
        'DisplayName', strcat('Deciders, wave ', num2str(waveNumber)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
end
function waveAccSizes(zMin,zMax, n, waveNumber, redo)
    folderName = 'SelfUniform';
    variableName = 'wavesAcc';
    lw = 4; 
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo);
    
    variable = variable/n;
    plot(a, variable(:,waveNumber,3), '--',...
        'DisplayName', strcat('Accurate, wave ', num2str(waveNumber)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
end
function waveWrongSizes(zMin,zMax, n, waveNumber, redo)
    folderName = 'SelfUniform';
    variableName = 'wavesWrong';
    lw = 4; 
    [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo);
    
    variable = variable/n;
    plot(a, variable(:,waveNumber,3), '--',...
        'DisplayName', strcat('Wrong, wave ', num2str(waveNumber)),...
        'LineWidth',lw)
    legend('-DynamicLegend')
    hold on
end

function firstSecondWavesHomo()
    fs = 12; lw = 3;
    waves = 1; social = 0; redo = 0;
    maxN = 1000;
    zMin = .5; zMax = 1;
    tit1 = 'Size of First and Second Waves';
    tit2 = strcat('for Self-Referential Uniform Distribution on [ ', num2str(zMin),...
        ', ', num2str(zMax),']');
    figure
    folderName = 'SelfUniform';
    variableName = 'wavesDec';
    [ns, variable] = VsN(folderName, variableName, maxN,zMin,zMax,redo,social,waves);
    for j = 1:length(ns)
        variable(j,1,3) = variable(j,1,3)/ns(j);
        variable(j,2,3) = variable(j,2,3)/ns(j);
        sum2(j) = variable(j,1,3) + variable(j,2,3);
    end
    plot(ns, variable(:,1,3), 'DisplayName', 'First Wave', 'LineWidth', lw)
    legend('-DynamicLegend')
    hold on
    plot(ns, variable(:,2,3), 'DisplayName', 'Second Wave', 'LineWidth', lw)
    hold on
    
    plot(ns, sum2, 'DisplayName', 'Sum of First, Second Waves', 'LineWidth', lw)
    xlabel('n = number of agents')
    ylabel('fraction of clique')
    title({tit1;tit2})
    set(gca, 'FontWeight', 'bold', 'FontSize', fs)
end


