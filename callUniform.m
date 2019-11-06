
%function callUniform()
% The name is antiquated. 
% This script calls the script that generates the raw data files 

    foldername = 'Uniform';
    % This will be the top folder name you intend to fill
    % Make sure that the folder exists and that you have subfolders
    % For each a. 
    % For most distributions, subfolders should have the form
    % zMin_a_zMax_1
    % For example, if using as = [0.1, 0.5, 1] and the highest
    % possible threshold is zMax = 1, your top folder should contain
    % zMin_0_1_zMax_1 zMin_0_5_zMax_1 zMin_1_zMax_1
    % If desired, the last case is the same as the homogeneous 
    % and a filled zMin_1_zMax_1 folder may be copied from any distribution
    % so that it isn't necessary to re-run the data
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make sure that saveRaw.m is calling the version you want it to call!
    % (open saveRaw.m and check, around line 66) 
    
    % For self-referential case,
    %       oneRunSelf(arguments)
    % For omniscient case,
    %       oneRunPan(arguments)
    %
    % (Pan is short for 'panopticon', which was used originally to refer to
    % the omniscient case.) 
    
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make sure you're using the correct zNum!!!!!
    % zNum controls which distribution thresholds are drawn from
    
    % Uniform, Homogeneous
     zNum = 0;
    
    % Tent (peak in center):
    % zNum = 3;
    
    % Shed function
    % zNum = 5;
    
    % Note: if using shed function, make sure to list the desired
    % heights of the distribution at the smaller threshold in h,
    % and to add additional folders for each h to the top folder.
    % Ex: Shed/h_a_0_5/zMin_0_1_zMax_1 for height (0.5) at smaller
    % threshold (0.1)
    
    % Bernoulli function with 2 thresholds
    % zNum = 2;
    
    % If you want the 2 thresholds to have different percentages
    % (that is, want them not to be split half and half)
    % Either use zNum = 7 and give percents,
    % or go to saveRaw.m line 174 and change smallerPercent
    
    % Bernoulli function with many thresholds
    % zNum = 7;
    
    % Note: if using zNum = 7, zMin will need to be an array with the
    % desired threshold values and h should be an array with their
    % percentages. The variable names are being reused. 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    maxWaves = 10; % If a trial hasn't completed by 10 waves, it will be stopped
    
        % This would be an h for shed function:
        % Make sure to still have values for lower and higher thresholds
        % (as, zMax)
  %  h = [0, .1, .2, .5, 1, 1.5, 2, 2.5, 3];
  
        % This might be an h, zMin for a many-threshold bernoulli:
   % zMin = [0.1,0.15,0.25,0.45,0.85];
   % h = [.2,.2,.2,.2,.2];
   % zMax = 1;
   
        % This might be for a uniform or pan case
        % 'as' is the list of smaller thresholds
   h  = 0;
   as = [.05,.1,.2,.3,.4,.5,.6,.7,.8,.9];
   zMax = 1;
 

   n_array = [40,150,300,500,1000,5000,10000,15000];
   numBatches = 15;
   batchCutOff = [5,5]; % [n_cutoff, batch_cutoff]
                        % After the batch_cutoff batch has been reached,
                        % The n_array is truncated after the n_cutoff entry
          % For the current configuration, after the 5th batch, 
          % We will have n_array = [40,150,300,500,1000];
          % This helps reduce unecessarily high number of trials for larger
          % n values
   
    batchSize = 150; % number of realizations in a batch
 %   save(strcat(foldername,'/background.mat'))
 %       parpool(20);
 
    for i = 1:length(as)
        
        if zNum ~= 7
            zMin = as(i);
        end
        % Use (uncomment) this if doing homogeneous:
            % zMax = zMin; 
            
        for batch = 1:numBatches
            
            if batch == batchCutOff(2) + 1
                n_array = n_array(1:batchCutOff(1));
            end
            
            if zNum == 5 % This should only be used for Shed 
                for j = 1:length(h)
                    h_a = h(j);
                    saveRaw(n_array,zMin,zMax, zNum, maxWaves,batchSize,batch,foldername,h_a)
                end
            
            else

               	 saveRaw(n_array,zMin,zMax, zNum, maxWaves,batchSize,batch,foldername,h)
		   
            end

        end
    end
%end % This end went with the function definition

% If you are running locally, you might want to comment out the exit:
exit;
