%andFreeze returns xAvg = vector of evidence of undecided agents,
% exitPos = vector of exit times of agents who decided positively
% exitNeg = vector of exit times of agents who decided negatively
% doneTime = time at which last agent exits, if all agents exit before the
% requested time, and else = time.

function [x, exitPos, exitNeg,time] = andFreeze(n,z,dtK,stopTime,a)

dt = 2^(-dtK);

x = a*sqrt(dt)*randn(n,1);
time = 0;

% I think I also want a record of ending times, and which direction the exit was. 
numExitPos = 0; numExitNeg = 0; % These will be counters/indices on the vectors of exit times
exitNeg = zeros(n,1); exitPos = zeros(n,1); % Preallocating. We'll chop these at the end using the nums.

szX = n;

while (time < stopTime) && (szX > 0) % I want this to run until stopTime or until the agents have all decided
    
    [S,L] = bounds(x);
    
    % Let it go until someone hits a boundary, or we reach stopTime
    while (abs(S)< z) & (L < z) && (time < stopTime)
          dx = dt + a*sqrt(dt)*randn(szX,1);
            x = x +dx;
    
            time = time + dt;
            [S,L] = bounds(x);
    end

    %remove every agent who has reached a threshold
    % check both boundaries in case dt is too big and multiple
    % agents hit threshold at once.
    
        if (szX -1) > 0
            
            dummyX = zeros(szX-1,1);       
            dummyI = 0;
            
            for i = 1:szX
                if x(i,1) < z && x(i,1) > -z
                    dummyI = dummyI + 1;
                    dummyX(dummyI,1) = x(i,1);
                else
                    if x(i,1) > z
                    numExitPos = numExitPos + 1;
                    exitPos(numExitPos,1) = time;
                    end
                    if x(i,1) < -z
                        numExitNeg = numExitNeg + 1;
                        exitNeg(numExitNeg,1) = time;
                    end
                end
            end
            
        end
        
         if szX == 1
               if x > z 
                  numExitPos = numExitPos + 1;
                  exitPos(numExitPos,1) = time;
                end
                if x < -z
                    numExitNeg = numExitNeg + 1;
                    exitNeg(numExitNeg,1) = time;
                end
                
                szX = 0;
                x = 0;
          end
                
   
        if dummyI > 0
            dummyX = dummyX(1:dummyI,1);
            x = dummyX;
            szX = max(size(x));
        end
   
    
   
    
    
end 
        
        %So now we just need to chop and we're done.
        if numExitPos > 0
            exitPos = exitPos(1:numExitPos,1) ;
        else
            exitPos = 0;
        end
        
        if numExitNeg > 0
            exitNeg = exitNeg(1:numExitNeg,1);
        else
            exitNeg = 0;
        end