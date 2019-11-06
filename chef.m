function chef(folderName,zMin,zMax,n,social)
% Processes the data in the Raw files and waves it as a 
% 'cooked' file

    % if social is 0, don't redo social information
    % (Social information takes a really long time 
    % to calculate locally; default should be 0)
    %------------------------------------
    % if social = -1, do the histograms for the thresholds
    % of agents in first and second waves (reusing parameter)
    % if social = 1, calculate total social made available
    % after first wave
    
    % Step 1: Check for a cooked file
    % If it exists, load data. If it doesn't, set baselines.

    filenameC = strcat(folderName,'/Cooked_n',num2str(n),'.mat');
    if isfile(filenameC)
        DNE = 0;
        gru1 = load(filenameC);
        topBatch = gru1.topBatch; % this will be the last batchnumber
                                 % incorporated into the cooked file
        NT = gru1.NT;
        avgTime = gru1.avgTime; histTime = gru1.histTime;
        FDThreshHist = gru1.FDThreshHist; avgFDThresh = gru1.avgFDThresh;
        rightDecidersHist = gru1.rightDecidersHist;
        decidersHist = gru1.decidersHist;
        firstWaveHistFDA = gru1.firstWaveHistFDA;
        firstWaveHistFDW = gru1.firstWaveHistFDW;
        firstWaveHist = gru1.firstWaveHist;
        secondWaveHistFDA = gru1.secondWaveHistFDA;
        secondWaveHistFDW = gru1.secondWaveHistFDW;
        secondWaveHist = gru1.secondWaveHist;
        wavesAcc = gru1.wavesAcc; maxWaves = gru1.maxWaves;
        wavesWrong = gru1.wavesWrong; wavesDec = gru1.wavesDec;
        perFDA = gru1.perFDA; perFDW = gru1.perFDW;
        avgSecUp = gru1.avgSecUp; avgSecUpFDA = gru1.avgSecUpFDA;
        avgSecUpFDW = gru1.avgSecUpFDW; 
        avgSecUpFDASelf = gru1.avgSecUpFDASelf;
        numFDA = gru1.numFDA; numFDW = gru1.numFDW;
        
    else
        DNE = 1;
        topBatch = 0; % this iterates the current batch number
        avgTime = 0; histTime = 0;  NT = 0;
        FDThreshHist = 0; avgFDThresh = 0;
        rightDecidersHist = zMin; decidersHist = zMin;
        firstWaveHistFDA = zMin;
        firstWaveHistFDW = zMin;
        firstWaveHist = zMin;
        secondWaveHistFDA = zMin;
        secondWaveHistFDW = zMin;
        secondWaveHist = zMin;
        maxWaves = 10; wavesAcc = zeros(maxWaves, 3); % [ num when FDA, num when FDW, num]
        wavesWrong = wavesAcc; wavesDec = wavesWrong;
        perFDA = 0; perFDW = 0; numFDA = 0; numFDW = 0;
        avgSecUp = 0; avgSecUpFDA = 0; avgSecUpFDW = 0;
        avgSecUpFDASelf = 0;
    end

    %-------------------------------------
    
    %-------------------------------------
    % Step 2: Check for new batches
    % Process each one as it loads.

    filenameB = strcat(folderName, '/Raw_n',num2str(n),...
        '_batch_', num2str(topBatch + 1), '.mat');
    
    while isfile(filenameB)
        gru = load(filenameB);
        NT = gru.batchSize + NT;
        maxWaves = min(maxWaves, gru.maxWaves);
        
            % Time information
            [avgTime, histTime] = timeStuffBasic(avgTime, histTime,...
                                    gru.batchSize,gru.times,NT);
                                
            % Decision information
            [perFDA, perFDW, totAcc,totWrong,totDec,numFDA,numFDW,...
                    wavesAcc, wavesWrong, wavesDec] = ...
            getWaves(gru.agents, gru.FDI, gru.batchSize, n, NT, maxWaves, ...
                    wavesAcc, wavesWrong, wavesDec, perFDA, perFDW,numFDA,numFDW);
            
             % Social information
            if social > 0
            [avgSecUpFDA,avgSecUpFDASelf] ...
                = getAvgSecUpFDA(gru.agents, gru.FDI, gru.times,...
                            n, gru.batchSize, avgSecUpFDA, numFDA);
            end
            % Threshold information
            % Technically, the below is threshold information, 
            % not social information
            if social < 0
                [fwFDA, fwFDW,fw,swFDA,swFDW ,sw]...
                 = waveHist(gru.agents, gru.batchSize,n,gru.FDI);
                firstWaveHistFDA = [firstWaveHistFDA; fwFDA];
                firstWaveHistFDW = [firstWaveHistFDW; fwFDW];
                firstWaveHist = [firstWaveHist; fw];
                secondWaveHistFDA = [secondWaveHistFDA; swFDA];
                secondWaveHistFDW = [secondWaveHistFDW; swFDW];
                secondWaveHist = [secondWaveHist; sw];
            end
            
            rdHist = getRightDecidersHist(gru.agents,gru.batchSize,n);
            [FDThreshHist, avgFDThresh] = getFDTHresh(gru.agents,... 
                gru.batchSize,NT,avgFDThresh,FDThreshHist,gru.FDI);
            rightDecidersHist = [rightDecidersHist;rdHist];
            
            [dHist] = getDecidersHist(gru.agents,gru.batchSize,n);
            decidersHist = [decidersHist;dHist];
                    
                          
             
            
        % Check for next batch file
        topBatch = topBatch + 1;
        filenameB = strcat(folderName, '/Raw_n',num2str(n),...
            '_batch_', num2str(topBatch + 1), '.mat');
    end
    
    %-----------------------------------------------------
    
    %-------------------------------------------------
    % Step 3: save.
    if DNE < 1
    save(filenameC,'-append');
    else
        save(filenameC);
    end
end

% Functions
%__________________________________________
% Time
function [avgTime, histTime] = timeStuffBasic(prevAvgTime, prevHistTime,...
                            batchSize,times,NT)
                       
         avgTime = (prevAvgTime*(NT-batchSize) + sum(times(:,1)))/(NT);
         histTime = [prevHistTime;times];
end


%_________________________________________________________
% Decisions

% Basic processing; who was in what wave, how accurate were they
function [perFDA, perFDW, totAcc,totWrong,totDec,numFDA,numFDW,...
            wavesAcc, wavesWrong, wavesDec] = ...
    getWaves(agents, FDI, batchSize, n, NT, maxWaves, ...
            wavesAcc, wavesWrong, wavesDec, perFDA, perFDW, numFDA, numFDW)
    % Goal: num
    pNT = NT - batchSize;
%     numFDA = perFDA*(pNT); 
%     numFDW = perFDW*(pNT); 
    wA = wavesAcc(1:maxWaves, :); 
    wA(:,1) = wA(:,1) * numFDA; wA(:,2) = wA(:,2) * numFDW;
    wA(:,3) = wA(:,3) * pNT;
    wW = wavesWrong(1:maxWaves,:); 
    wW(:,1) = wW(:,1) * numFDA; wW(:,2) = wW(:,2) * numFDW;
    wW(:,3) = wW(:,3) * pNT;
    wD = wavesDec(1:maxWaves,:);
    wD(:,1) = wD(:,1) * numFDA; wD(:,2) = wD(:,2) * numFDW;
    wD(:,3) = wD(:,3) * pNT;
    
    for i = 1:batchSize
        if FDI(i) > 0
            numFDA = numFDA + 1;
            update = [1,0,1];
        else
            numFDW = numFDW + 1;
            update = [0,1,1];
        end
            
        for j = 1:n
                ind = agents(i,3,j);
                if ind > 0
                wA(ind,:) = wA(ind,:) + update;
                wD(ind,:) = wD(ind,:) + update;
                end
                if ind < 0
                    ind = abs(ind);
                    wW(ind,:) = wW(ind,:) + update;
                    wD(ind,:) = wD(ind,:) + update;
                end
        end
        
    end
    
    wA(:,1) = wA(:,1) / numFDA; wA(:,2) = wA(:,2) / numFDW;
    wA(:,3) = wA(:,3) / NT;
    wW(:,1) = wW(:,1) / numFDA; wW(:,2) = wW(:,2) / numFDW;
    wW(:,3) = wW(:,3) / NT;
    wD(:,1) = wD(:,1) / numFDA; wD(:,2) = wD(:,2) / numFDW;
    wD(:,3) = wD(:,3) / NT;
        perFDA = numFDA / NT; perFDW = numFDW / NT;
    totAcc = sum(wA(:,3)); totWrong = sum(wW(:,3)); totDec = sum(wD(:,3));
    
    wavesAcc = wA; wavesWrong = wW; wavesDec = wD;
end

%___________________________________________________________
% Social

% Get average social update after first wave (update available to members
% of second wave)
function [avgSecUpFDA,avgSecUpFDASelf] = getAvgSecUpFDA(agents, FDI, times, n, batchSize, ...
                            avgSecUpFDA, numFDA)
    sumAvgUp = avgSecUpFDA * numFDA;
    
    for i = 1:batchSize
        if FDI(i) > 0
            numFDA = numFDA + 1;
            time = times(i);
            f1 = 0; sumRf = 0; sumRu = 0;
            for j = 1:n
                
                z = agents(i,1,j);
                if agents(i,3,j) == 1
                    f1 = f1 + 1;
                    sumRf = sumRf + MoIMulti(z,0,z,time);
                else
                    sumRu = sumRu + MoIMulti(z,0,z,time);
                end
                
            end
            z = agents(i,1,abs(FDI(i)));
            sumRu = sumRu - MoIMulti(z,0,z,time);
            u1 = n - 1 - f1;
            sumAvgUpSelf = sumAvgUpSelf + (f1 - u1 + 1)*(sumRu/u1);
            sumAvgUp = sumAvgUp + ((sumRu + sumRf)/u1);
        end
    end
    
    avgSecUpFDA = sumAvgUp/numFDA;
    avgSecUpFDASelf = sumAvgUpSelf/numFDA;
    
end

%__________________________________________________________
% Thresholds

% Get lists of thresholds of agents in first and second wave
function [fwFDA, fwFDW,fw,swFDA,swFDW ,sw] = waveHist(agents, batchSize,n,FDI)
        fwAI = 0; fwWI = 0; fwI = 0;
        swAI = 0; swWI = 0; swI = 0;
        for i = 1:batchSize
            if FDI(i) > 0
                for j = 1:n
                    if agents(i,3,j) == 1
                        fwAI = fwAI + 1;
                        fwFDA(fwAI,1) = agents(i,1,j);
                        fwI = fwI + 1;
                        fw(fwI,1) = agents(i,1,j);
                    else
                        if abs(agents(i,3,j)) == 2
                            swAI = swAI+1;
                            swFDA(swAI,1) = agents(i,1,j);
                            swI = swI + 1;
                            sw(swI,1) = agents(i,1,j);
                        end
                    end
                end
            else
                for j = 1:n
                    if agents(i,3,j) == -1
                        fwWI = fwWI + 1;
                        fwFDW(fwWI, 1) = agents(i,1,j);
                        fwI = fwI + 1;
                        fw(fwI,1) = agents(i,1,j);
                    else
                        if abs(agents(i,3,j)) == 2
                            swWI = swWI + 1;
                            swFDW(swWI,1) = agents(i,1,j);
                            swI = swI + 1;
                            sw(swI,1) = agents(i,1,j);
                        end
                    end
                end
            end
        end
end

% Get list of First Decider thresholds, and their average
function [FDThreshHist, avgFDThresh] = getFDTHresh(agents,... 
                batchsize,NT,avgFDThresh,FDThreshHist,FDI)
            avgFDThresh = avgFDThresh * (NT-batchsize);
           lengthHist = length(FDThreshHist);
            for i = 1:batchsize
                thresh = agents(i,1,abs(FDI(i)));
                FDThreshHist(lengthHist + i) = thresh;
                avgFDThresh = avgFDThresh + thresh;
            end
            avgFDThresh = avgFDThresh / NT;
end
% Get list of thresholds of deciders
function [dHist] = getDecidersHist(agents,batchSize,n)
    
    counter = 0;
    for i = 1:batchSize
        for j = 1:n
            if agents(i,3,j) ~= 0
                counter = counter + 1;
                dHist(counter,1) = agents(i,1,j);
            end
        end
    end
end
% Get list of thresholds of accurate deciders
function [rdHist] = getRightDecidersHist(agents,batchSize,n)
    
    counter = 0;
    for i = 1:batchSize
        for j = 1:n
            if agents(i,3,j) > 0
                counter = counter + 1;
                rdHist(counter,1) = agents(i,1,j);
            end
        end
    end
end