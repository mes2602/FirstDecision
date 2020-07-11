function diffAll(z,T,dtK)

% Make folder to hold this data
folderName = 'S1';
if exist(folderName,'dir') ~= 7
    mkdir(folderName)
end

% Get solution for Smoluchowski equation
szt = 61;
zstr = strrep(num2str(z), '.', '_');
tstr = strrep(num2str(T), '.', '_');
filename = strcat('S1/FPDEtime', tstr, 'z', zstr,'.mat');
if ~isfile(filename)
    tic
    [xDense,uDense,S]=Fokker(z,T,szt,0);
    save(filename, 'xDense', 'uDense', 'S');
    toc
end


%Get histogram data (simulation data)
nK = 5;
n = 10^nK;
filename = strcat('S1/nK', num2str(nK), 'dtK', num2str(dtK),'time',tstr,'z', zstr, '.mat');
    

if ~isfile(filename)
    tic
    [xAvg,exitPos,exitNeg,~] = andFreeze(n,z,dtK,T,sqrt(2));
    hist = max(size(xAvg))/n;
    xtest = [ones(max(size(exitNeg)),1)*(-z - .5); xAvg; ones(max(size(exitPos)),1)*(z+.5)];
    save(filename, 'xtest','hist');
    toc
    
end
end

