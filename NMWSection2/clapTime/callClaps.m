% callClaps()
% Does not accept arguments for ease of calling by command
% Creates data files containing only a vector of first decision times.
% Saves these vectors for a variety of thresholds (theta_array) using 
% an adapting size of timestep (dtK_array) over clique sizes that increase
% by a factor of 10 (for 10, 10^2, 10^3.... 10^maxnK) 
% The vectors are used by comparePN.m 
% to create a histogram distribution of first decision
% times for cliques of the given size using the given threshold value. The
% histogram has (numTrials) number of entries.
% 
% Note that this version of callClaps exits when finished.
%
% 'Claps' is a fanciful reference to the notion of a clapping noise
% when the first decision is made. 


function callClaps()

numTrials = 10^4;               % numTrials is the size of the histogram. 
                                % Increase numTrials to get finer
                                % resolution on the histogram of first
                                % decision times.
                              
maxnK = 4;                      % largest clique size is 10^maxnK.
                                % Increase maxnK to get data for larger
                                % cliques.
                                
theta_array = [0.1, 0.5, 1.0,2.0]; % List of threshold sizes
dtK_array = [23, 20,18, 16]; % List of corresponding timestep sizes. 
                             % size of timestep = dt = 2^(-dtK)
                             
                             % If adding more thresholds, be sure to also
                             % add a corresponding timestep of appropriate size. 
                             

szth = max(size(theta_array));
save('clapBack.mat', 'n', 'numTrials', 'theta_array');


for j = 1:maxnK
	n = 10^j;
    for i = 1:szth
        z = theta_array(i);
        nstr = num2str(n);
        zstr = strrep(num2str(z), '.','_');
        filename = strcat('claps_n',nstr,'z',zstr,'.mat');

        justTheClaps(n,z,numTrials,filename, dtK_array(i));
    end
end

    exit;
end

% justTheClaps(n,z,numTrials,filename,dtK)
% Runs numTrials number of trials of OneChoice
% and saves the created vector of first decision times, DT
% n,z,dtK are to pass to OneChoice
%
%   numTrials : number of trials
%   filename : saves the vector of first decision times
%               under the name filename as a .mat file

function justTheClaps(n,z,numTrials,filename,dtK)

parfor i = 1:numTrials
        k = OneChoice(n,z,dtK);
        DT(i) = k;
end

save(filename, 'DT');

end

% OneChoice(n,z,dtK)
% Runs n simultaneous realizations of the stochastic drift diffusion 
% process given by 
%           dx = dt + sqrt(2)dW
%
% until one realization has reached a threshold
% and returns the time of the first decison
% 
%   n : size of clique (number of agents)
%   z : size of threshold
%   dtK : size of timestep = 2^(-dtK)


function [time] = OneChoice(n,z, dtK)

dt = 2^(-dtK); 

x = sqrt(dt*2)*randn(n,1);

time = 0;
[S,L] = bounds(x);

while (S > -z) && (L < z)
    dx = dt + sqrt(dt*2)*randn(n,1);
    x = x +dx;
    
    time = time + dt;
    [S,L] = bounds(x);
end

end

