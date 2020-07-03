% Issues call to saveRaw, which generates batches of data.

function callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr)


% Make sure appropriate folders exist
if exist(folderName1,'dir') ~= 7
    mkdir(folderName1)
end

if zNum == 2
    folderName1 = strcat(folderName1, '/gamma_',strrep(num2str(gr),'.','_'));
end

if zNum == 5
    folderName1 = strcat(folderName1,'/Div_',num2str(gr));
    if gr ==1
        gr = 0;
    else
        gr = 2/(zMax-zMin);
    end
end

if exist(folderName1,'dir') ~= 7
    mkdir(folderName1)
end

% Set number of trials in each batch
batchSize = 150;

% Make a parpool
poolobj = gcp('nocreate');
if isempty(poolobj)
    if poolSize > 0
        parpool(poolSize)
    else
        parpool()
    end
end

% Loop through the values of thmin
for i= 1:length(thMins)
    thMin = thMins(i);
    % For homogeneous thresholds, we need thMin and thMax to be the same
    if zNum == 0
        thMax = thMin;
    end
    % Make sure the directory exists
    folderName2 = strcat(folderName1, '/zMin_', ...
        strrep(num2str(thMin),'.','_'), '_zMax_',...
        strrep(num2str(thMax),'.','_'));
    if exist(folderName2,'dir') ~= 7
        mkdir(folderName2)
    end
    
    for batch = 1:numBatches
        saveRaw(ns,thMin,thMax, zNum,batchSize,batch,folderName1,gr,selfVsOmni)
    end
    
    
end
