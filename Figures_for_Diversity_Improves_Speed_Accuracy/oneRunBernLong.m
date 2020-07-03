function [numAcc,wavesDec,wavesSoc,FDTime,FDthresh] = oneRunBernLong(zns, maxWaves)
% Runs one realization for the self-referential case
    
    
    n_min = zns(1,2); th_min = zns(1,1);
    n_max = zns(2,2); th_max = zns(2,1);
    z = [ones(1,n_min)*th_min,ones(1,n_max)*th_max];
    n = length(z);
    % If the thresholds were given by z, accept
    % Else, get them using thresholds according to rule
    
    
    
    z = z';
    %------------------------------------
    % Adjusts the size of the timestep used based on the 
    % smallest used threshold
    dtK = getdtK(min(z));

    dt = 2^(-dtK);
    %---------------------------------------
    
    %---------------------------------------
    % Go until somebody hits a threshold. (wave -1)
    
    x = sqrt(2*dt)*randn(n,1);
    time = dt;
    
    george = min(z-abs(x));
    while george > 0
        x = x + dt + sqrt(2*dt)*randn(n,1);
        george = min(z-abs(x));
        time = time + dt;
    end
    
    FDTime = time;
    %-----------------------------------------
    
    %-----------------------------------------
    % Find the index of the threshold-hitter.
    % Set 
    [~,j] = min(z-abs(x),[],1,'includenan');
    
    FDIndex = j(1);
    FDthresh = z(FDIndex);
    if x(FDIndex) <= z(FDIndex)
        FDIndex = -FDIndex;
    end
    
    

    %--------------------------------------------
    clear george
    clear j
    clear dt
    clear dtK
    
    
    smalls = x(1:n_min);
    bigs = x(n_min+1:end);
    if abs(FDIndex) <= n_min
        smalls = smalls(abs(smalls) < th_min);
        soc = th_min*sign(FDIndex);
        if FDIndex > 0
        numAcc = 1; numAccSmall = 1; 
        else
        numAcc = 0; numAccSmall = 0;
        end
        numAccBig = 0; numDecBig = 0;
        numDecSmall = 1; 
    else
        bigs = bigs(abs(bigs) < th_max);
        soc = th_max * sign(FDIndex);
        if FDIndex > 0
        numAcc = 1; numAccBig = 1; 
        else
        numAcc = 0; numAccBig = 0;
        end
        numAccSmall = 0; numDecSmall = 0;
        numDecBig = 1; 
    end
    clear n_min
    clear n_max
    clear x
    clear z
    clear zns
    numWaves = 0;
    numDec = 1;
    R_minNonDec = 0; R_maxNonDec = 0; socNonDec = 0;
    R_maxDec = 0; R_minDec = 0; oldNonMax = 0; oldNonMin = 0;
    socMin = soc; socMax = soc; pastSocMax = 0; pastSocMin = 0;
    intMaxNonDec = 0; intMaxDec = 0; 
    intMinNonDec = 0; intMinDec = 0;
    clear soc
    oldIntMin = [-th_min,th_min]; oldIntMax = [-th_max,th_max];
    zquit = 0;
    % whenDec: row 1: smalls; row 2: bigs;
    % column 1: first wave (+- for right or wrong)
    % column 2: second wave
    % column 3: rest of waves <--- for this, you can only record decisions,
    %           not which direction the decisions were in
    wavesDec = zeros(2,10); wavesSoc = wavesDec;
    while numWaves < maxWaves && (numDec < n && zquit < 1)
        numWaves = numWaves + 1;
        smalls = smalls + socMin;
        bigs = bigs + socMax;
        
        % oldSoc for max and min might be different! 
        
        % record social data (for diagnostic purposes)
        if numWaves < 10
            wavesSoc(1,numWaves) = socMin;
            wavesSoc(2,numWaves) = socMax;
        else
            wavesSoc(1,10) = wavesSoc(1,10) + socMin;
            wavesSoc(2,10) = wavesSoc(2,10) + socMax;
        end
        
        if ~isempty(smalls)
        if socMin < 0
            
            newIntMinDec = [-th_min,-th_min-socMin];
            newIntMinNonDec = [-th_min-socMin,th_min];
            
            hokay = length(smalls);
            smalls = smalls(smalls > -th_min);
            nonDecSmall = length(smalls);
            DecSmall = hokay- nonDecSmall;    
            numDecSmall = numDecSmall + DecSmall;
            
            wavesDec = updateWavesDec(DecSmall, -1,1,numWaves, wavesDec);
            
            
            
        else
            if socMin > 0
            newIntMinDec = [th_min-socMin,th_min];
            newIntMinNonDec = [-th_min,th_min-socMin];
            
            hokay = length(smalls);
            smalls = smalls(smalls < th_min);
            nonDecSmall = length(smalls);
            DecSmall = hokay-nonDecSmall;
            numAcc = numAcc + DecSmall;
            numAccSmall = numAccSmall + DecSmall;
            numDecSmall = numDecSmall + DecSmall;
            
            wavesDec = updateWavesDec(DecSmall, 1, 1, numWaves, wavesDec);
            else
                newIntMinDec = [-th_min,th_min];
                newIntMinNonDec = [-th_min,th_min];
            end
        end
            intMinDec = intersect(oldIntMin,newIntMinDec-pastSocMin,th_min);
            intMinNonDec = intersect(oldIntMin, newIntMinNonDec-pastSocMin,th_min);
            oldNonMin = socNonDec - R_minNonDec; 
            R_minDec = 0; R_minNonDec = 0;

            if intMinDec(2)-intMinDec(1) > 0
                R_minDec = MoIMulti(th_min,intMinDec(1),intMinDec(2),time);
		if isnan(R_minDec)
			R_minDec = 0;
		end
            end
            if intMinNonDec(2)-intMinNonDec(1) > 0
                R_minNonDec = MoIMulti(th_min,intMinNonDec(1),intMinNonDec(2),time);
		if isnan(R_minNonDec)
			R_minNonDec = 0;
		end
            end
        
        else
            DecSmall = 0; nonDecSmall = 0; R_minDec = 0; R_minNonDec = 0;
        end
        
        
        if ~isempty(bigs)
        if socMax < 0
            newIntMaxDec = [-th_max,-th_max-socMax];
            newIntMaxNonDec = [-th_max-socMax,th_max];
            
            hokay = length(bigs);
            bigs = bigs(bigs > -th_max);
            nonDecBig = length(bigs);
            DecBig = hokay-nonDecBig;
            numDecBig = numDecBig + DecBig;
            
            wavesDec = updateWavesDec(DecBig, -1, 2, numWaves, wavesDec);
        else
            if socMax > 0
            newIntMaxDec = [th_max-socMax,th_max];
            newIntMaxNonDec = [-th_max,th_max-socMax];
            
            hokay = length(bigs);
            bigs = bigs(bigs < th_max);
            nonDecBig = length(bigs);
            DecBig = hokay-nonDecBig;
            numAcc = numAcc + DecBig;
            numDecBig = numDecBig + DecBig;
            numAccBig = numAccBig + DecBig;
            
            wavesDec = updateWavesDec(DecBig, 1, 2, numWaves, wavesDec);
            else
                newIntMaxDec = [-th_max,th_max];
                newIntMaxNonDec = [-th_max,th_max];
            end
        end
        
        intMaxDec = intersect(oldIntMax,newIntMaxDec-pastSocMax,th_max);
        intMaxNonDec = intersect(oldIntMax,newIntMaxNonDec-pastSocMax,th_max);
        oldNonMax = socNonDec - R_maxNonDec;
         R_maxDec = 0; R_maxNonDec = 0;
        if intMaxDec(2)-intMaxDec(1) > 0               
            R_maxDec = MoIMulti(th_max,intMaxDec(1),intMaxDec(2),time);
	    if isnan(R_maxDec)
		    R_maxDec = 0;
	    end
        end
        if intMaxNonDec(2)-intMaxNonDec(1) > 0
            R_maxNonDec = MoIMulti(th_max,intMaxNonDec(1),intMaxNonDec(2),time);
	    if isnan(R_maxNonDec)
		    R_maxNonDec = 0;
	    end
        end
        
        else
            DecBig = 0; nonDecBig = 0; R_maxDec = 0; R_maxNonDec = 0;
        end
    

        
       
       socDec = DecSmall*R_minDec + DecBig*R_maxDec; 
       socNonDec = nonDecSmall*R_minNonDec + nonDecBig*R_maxNonDec;
       
       pastSocMin = socMin + pastSocMin;
       socMin = socDec + (socNonDec - R_minNonDec) - oldNonMin; 
       pastSocMax = socMax + pastSocMax;
       socMax = socDec + (socNonDec - R_maxNonDec) - oldNonMax;
       
       oldIntMin = intMinNonDec; oldIntMax = intMaxNonDec;
       
       numDec = numDec + DecSmall + DecBig;
       
       if socMin == 0 && socMax == 0
           zquit = 1;
       end
    end
    
    numAcc = [numAcc,numDec;...
             numAccSmall,numDecSmall;...
             numAccBig, numDecBig];
end

function [interval] = intersect(oldInt,newInt,th)
    interval = [0,0];
    if newInt(1) > oldInt(2) || newInt(2) > oldInt(1)
        interval(1) = min(th,max(newInt(1),oldInt(1)));
        interval(2) = max(-th,min(newInt(2),oldInt(2)));
    end
end

function [wavesDec] = updateWavesDec(DecSmall, PlusMinus, BigSmall, numWaves, wavesDec)

    %if numWaves == 1 
    %            wavesDec(1*BigSmall,1) = PlusMinus*DecSmall ;
    %        else
    %            if numWaves == 2
    %                wavesDec(1*BigSmall,2) = PlusMinus*DecSmall;
    %            else
    %                wavesDec(1*BigSmall,3) = wavesDec(1,3) + DecSmall;
    %            end 
    %end
    wavesDec(1*BigSmall,numWaves) = PlusMinus*DecSmall;

end

function [dtK] = getdtK(zMin)
          if zMin < .001
                dtK = 27;
            else
                if zMin < .005
                    dtK = 26;
                else
                    if zMin < .101
                        dtK = 25;
                    else
                        if zMin < .151
                            dtK = 24;
                        else
                            if zMin < .31
                                dtK = 20;
                            else 
                                if zMin < .51
                                    dtK = 19;
                                else
                                    dtK = 18;
                                end
                            end
                        end
                    end
                end
         end
    end
