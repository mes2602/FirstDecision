function [FDIndex, FDTime, waveIndex, agents] = oneRunSelf(n, z, maxWaves)
% Runs one realization for the self-referential case
    
    % If the thresholds were given by z, accept
    % Else, get them using thresholds according to rule
    
    agents = zeros(3,n);
    agents(1,:) = z';
    
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
    
    if x(FDIndex) <= z(FDIndex)
        FDIndex = -FDIndex;
    end
    
    agents(2,:) = x;
    
    %--------------------------------------------
    % Add a second layer to x, which is the original index of x
    
    for k = 1:n
        x(k,2) = k;
    end
    
    %--------------------------------------------
    
        j = j(1);
    % Remove first decider
    % (x is now 'dummy x'; original x is already part of agents)
    if (2<j) && (j<n-1) 
        x = [x(1:j-1,:);x(j+1:n,:)];
        z = [z(1:j-1);z(j+1:n)];
    else
        if j == 1
            x = x(2:n,:);
            z = z(2:n);
        else
            if j == n
                x = x(1:j-1,:);
                z = z(1:j-1);
            
            else
                if j ==2
                x = [x(1,:);x(3:n,:)];
                z = [z(1);z(3:n)];
            else
                if j == (n-1)
                    x = [x(1:n-2,:);x(n,:)];
                    z = [z(1:n-2);z(n)];
                end
                end
            end
        end
    end
    %--------------------------------------------
    
    %--------------------------------------------
    % Perform iterative waves until everyone has decided,
    % there is no new social information, or maxWaves has 
    % been reached
    
    
    
    % Update social information to be ready to begin round 1
    
   if FDIndex > 0
        x(:,1) = x(:,1) + z;
        lastUpdate = z;
   end 
    if FDIndex < 0
        x(:,1) = x(:,1) - z;
        lastUpdate = -z;
    end
    
    
    szU = n-1;
    numNew = n-1;
    waveIndex = 1; % We'll begin on the first wave
    % Set old boundaries. Will need to track these for deciders and non
    % [af, bf ; au, bu]
    abfu = [-z, z];
    sumSoc = lastUpdate;
    soc_w_1 = zeros(n-1,1);
    uX = [0,0];
    
    % Start rounds.
    while szU > 0 && (waveIndex < maxWaves + 1) && numNew > 0
        
        fCount = 0; uCount = 0; numNew = 0;
        % Sort deciders and non-deciders
        for i = 1:szU
            if abs(x(i,1)) > z(i) % decider
                if x(i,1) > 0 % accurate decider
                    agents(3,x(i,2)) = waveIndex;
                else
                    agents(3,x(i,2)) = -waveIndex;
                end
                fCount = fCount + 1;
            else % non-decider
                uCount = uCount + 1;
                uX(uCount,:) = x(i,:); uZ(uCount) = z(i);
                uSumSoc(uCount) = sumSoc(i);
                uLastUpdate(uCount) = lastUpdate(i);
                uSoc_w_1(uCount) = soc_w_1(i);
                uAbfu(uCount, :) = abfu(i,:);
            end
        end
        
        % Get new social evidence. 
        update = zeros(uCount,1);
        for i = 1:uCount
            
            % get temp a,b for f and u
            if uLastUpdate(i) > 0
                au = -uZ(i); bu = uZ(i) - uSumSoc(i);
                af = uZ(i) - uSumSoc(i); bf = uZ(i);
            else
                if uLastUpdate(i) < 0
                    au = -uZ(i) - uSumSoc(i); bu = uZ(i);
                    af = -uZ(i); bf = -uZ(i) - uSumSoc(i);
                end
            end
            
            % intersect with old a,b
             % For decided
             if uAbfu(i,1) > bf && af > uAbfu(i,2) %If the intervals don't intersect
                 uAbfu(i,1) = 0; uAbfu(i,2) = 0;
 
             else
                % Note that the previous data from these was the 
                % undecided data
                af = min(uZ(i),max(af, uAbfu(i,1)));
                bf = max(-uZ(i),min(bf, uAbfu(i,2)));
            end
            % For undecided
           if uAbfu(i,1) > bu && au > uAbfu(i,2) % Check for non-intersection
                 uAbfu(i,1) = 0; uAbfu(i,2) = 0;
 
             else
                uAbfu(i,1) = min(uZ(i),max(au, uAbfu(i,1)));
                uAbfu(i,2) = max(-uZ(i),min(bu, uAbfu(i,2)));
           end
            
            % Update evidence
            socF = MoIMulti(uZ(i),af,bf,FDTime);
            socU = MoIMulti(uZ(i),uAbfu(i,1),uAbfu(i,2),FDTime);
            
            update(i) = socF*fCount + socU * (uCount-1)-uSoc_w_1(i);
            uSoc_w_1(i) = socU*(uCount-1);
            uSumSoc(i) = uSumSoc(i) + update(i);
            uX(i,1) = uX(i,1)+ update(i);
            if update(i) ~= 0
                numNew = numNew + 1;
            end
        end
            
        % Reset
            waveIndex = waveIndex + 1;
            x = uX; uX = [0,0];  z = uZ; uZ = 0;
            abfu = uAbfu; sumSoc = uSumSoc;
            lastUpdate = update; soc_w_1 = uSoc_w_1;
            uSumSoc = 0; szU = uCount; uAbfu = [0,0]; 
            uLastUpdate = 0; uSoc_w_1 = 0;
    end
end

    function [dtK] = getdtK(zMin)
          if zMin < .001
                dtK = 33;
            else
                if zMin < .005
                    dtK = 31;
                else
                    if zMin < .101
                        dtK = 28;
                    else
                        if zMin < .151
                            dtK = 24;
                        else
                            if zMin < .31
                                dtK = 23;
                            else 
                                if zMin < .51
                                    dtK = 22;
                                else
                                    dtK = 21;
                                end
                            end
                        end
                    end
                end
         end
    end
