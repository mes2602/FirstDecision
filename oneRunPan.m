function [FDIndex, FDTime, waveIndex, agents] = oneRunPan(n, z, maxWaves)
% Runs one realization for the (Pan)opticon (omniscient) case

    
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
    
    Soc = agents(1,abs(FDIndex));
    if x(FDIndex) <= z(FDIndex)
        FDIndex = -FDIndex;
        Soc = -Soc;
    end
    
    agents(2,:) = x;
    
    %--------------------------------------------
    % Add a second layer to x, which tracks the original index of x
    
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
                z = [z(1,1);z(3:n,1)];
            else
                if j == (n-1)
                    x = [x(1:n-2,:);x(n,:)];
                    z = [z(1:n-2,1);z(n,1)];
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
    
    strikes = 0; % Three strikes and you're out
    alpha = z*(-1); beta = z;
    
    Socw_1 = ones(n-1,1)*Soc; 
    SumSocw_2 = zeros(n-1,1);
    ReplaceableSoc = SumSocw_2;
    
    waveIndex = 1;
    UnIndex = 0;
    CountNoNew = 0; oldCount = n-1; oldoldCount = n;
    llr_fw = 0;
    totSoc = 0; maxSoci = 0;
    totSoc(waveIndex,1) = Soc; maxSoci(waveIndex,1) = Soc;

    while strikes < 3 && waveIndex < maxWaves
        szx = length(x(:,1)); % size of u_w-1
        
        for i = 1:szx
            [x(i,1),alphaNew,betaNew] = ...
                equilibriate(x(i,1),alpha(i),beta(i),z(i),Socw_1(i), SumSocw_2(i));
            ll = MoIMulti(z(i),alphaNew,betaNew,time); % get llr_k
            
                     
            if abs(x(i,1)) >= abs(z(i))
                llr_fw = llr_fw + ll;
                if x(i,1) >= z(i)
                    agents(3,x(i,2)) = waveIndex;
                else
                    agents(3,x(i,2)) = -waveIndex;
                end
            end
            if abs(x(i,1)) < abs(z(i))
                UnIndex = UnIndex + 1;
                UnX(UnIndex,:) = x(i,:); 
                UnZ(UnIndex) = z(i);
                UnSumSocw_2(UnIndex) = SumSocw_2(i) + Socw_1(i);
                UnRepSoc(UnIndex) = ReplaceableSoc(i);
               
                llr(UnIndex) = ll;
                if alphaNew ==alpha(i) && betaNew == beta(i)
                    CountNoNew = CountNoNew + 1;
                end
                UnAlpha(UnIndex) = alphaNew; UnBeta(UnIndex) = betaNew;
            end
        end
        
        % Check to see whether we've run out of social information. We
        % shouldn't add another wave if this is the case.
        if (CountNoNew == UnIndex) && (CountNoNew == oldoldCount)
            strikes = 3;
        else
            if UnIndex == 0 % if everyone's decided, we're done
                strikes = 3;
                else
                % Ready things for the next round
                waveIndex = waveIndex + 1;
                
                totSoc(waveIndex,1) = llr_fw+sum(llr);
                Socw_1 = ((llr_fw + sum(llr)) - llr) - UnRepSoc;
                x = UnX; z = UnZ; SumSocw_2 = UnSumSocw_2;
                alpha = UnAlpha; beta = UnBeta;
                maxSoci(waveIndex,1) = max(Socw_1);
                ReplaceableSoc = sum(llr) - llr;
                oldoldCount = oldCount;
                oldCount = CountNoNew;

                UnIndex = 0; UnX = [0,0]; UnSumSocw_2 = 0; 
                llr = 0; CountNoNew = 0; UnAlpha = 0; UnBeta = 0; 
                llr_fw = 0; UnZ = 0; UnRepSoc = 0;
            end
        end
    end
    %------------------------------------------------------------------
end
    
    function [y,alpha_w,beta_w] = equilibriate(y,alphaw_1, betaw_1, theta, Socw_1, Sumw_2)
        y = y+ Socw_1;
        
        % if available social information is zero, 
        % default to the original interval
        aprime = -theta; bprime = theta;
        % get alpha'_w, beta'_w
        if Socw_1 > 0
            if y >= theta
                aprime = theta - Socw_1;
                bprime = theta;
            else
                aprime = -theta; 
                bprime = theta-Socw_1;
            end
        end
        if Socw_1 < 0
            if y <= -theta
                aprime = -theta;
                bprime = -theta - Socw_1;
            else
                aprime = -theta-Socw_1;
                bprime = theta;
            end
        end
        
        aprime = aprime - Sumw_2; bprime = bprime - Sumw_2;
        
        % ------------------------------------------
        % Get intersection of intervals for y_0
        if alphaw_1 < bprime && aprime > betaw_1
            alpha_w = 0; beta_w = 0;
            
        else
            alpha_w = max(aprime, alphaw_1);
            beta_w = min(bprime, betaw_1);
        end
        %--------------------------------------------
        
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