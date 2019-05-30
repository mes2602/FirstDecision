% callClapsArgs(numTrials, nK, z, dtK)
% A version of callClaps that accepts arguments for ease of calling
% from Matlab command window.
% Creates a data files containing only a vector of first decision times.
% The data file is used by comparePN.m to create a histogram of first
% decision times. 
%
% The vectors are used to create a histogram distribution of first decision
% times for cliques of the given size using the given threshold value. The
% histogram has (numTrials) number of entries.
%
%   numTrials : number of entries in the histogram of first decision times
%               Standard size is numTrials = 10^4.
%   nK : the size of the clique is 10^(nK).
%   z : the size of the threshold
%   dtK : size of timestep = dt = 2^(-dtK). Make sure this is appropriately
%           sized. For z = 1.0, probably 14 < dtK < 17, 
%                  For z = 0.5, probably 16 < dtK < 20, etc. 
% 
%   Note: the function that actually calls the realizations,
%   'justTheClaps', is set in this version to use a for loop. 
%   If desired, this may be changed to a parfor. 
% 'Claps' is a fanciful reference to the notion of a clapping noise
% when the first decision is made. 


function callClapsArgs(numTrials, nK, z, dtK)
                         
	n = 10^nK;
       
    nstr = num2str(n);
    zstr = strrep(num2str(z), '.','_');
    filename = strcat('claps_n',nstr,'z',zstr,'.mat');

    justTheClaps(n,z,numTrials,filename, dtK);
   
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
    
    DT = zeros(numTrials,1); % if changing the following for loop 
                             % to a parfor, comment this line out.
    
    for i = 1:numTrials
            k = OneChoice(n,z,dtK);
            DT(i,1) = k;
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

