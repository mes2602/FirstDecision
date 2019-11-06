function saveRaw(n_array,zMin,zMax, zNum, maxWaves,batchSize,batch,foldername,h_a)
% This script generates a batch (collection of realizations)
% of raw data files and saves them 
% in the appropriate folder

    szn = length(n_array);
    for i = 1:szn
        n = n_array(i);


        %---------------------------------------------
         % Get filename (depends on threshold distribution)


            if zNum == 0 || (zNum == 2 || zNum == 3)
                filename = makeNameUniform(zMin,zMax,n,foldername,batch);
            end

            if zNum == 5
                filename = makeNameShed(zMin,zMax,n,foldername, batch, h_a);
            end
            
            if zNum == 7
                filename = strcat(foldername, '/Raw_n_',...
                    strrep(num2str(n),'.','_'), '_batch_',...
                    num2str(batch),'.mat');
            end
        %-----------------------------------------------

        %-----------------------------------------------
        % Set/Reset Things we will save
            % Three entries for each agent:
            % agents = [threshold size; size of belief at FD; number of wave decided]
            % accuracy of decision given by pos/neg
            agents = zeros(batchSize,3,n);
            % waveSize records the number of the last wave with meaningful
            % social information
            waveSize = zeros(batchSize,1);
            % List of FD Indices.... and accuracy given by pos/neg
            FDI = zeros(batchSize,1);
            % time = time of first decision
            times = zeros(batchSize,1);
        %-------------------------------------------------

        %-------------------------------------------------
        % Run the parfor loop
            parfor j = 1:batchSize
                % get array of thresholds drawn from appropriate
                % distribution:
                        switch zNum
                            case 0
                                z = (zMax-zMin)*rand(n,1)+zMin;
                            case 2
                                z = Bern(zMin,zMax,n);
                            case 3
                                z = tentZ(zMin,zMax,n);
                            case 5
                                z = shed(zMin,zMax,h_a,n);
                            case 7
                                z = manyBern(zMin,n,h_a);
                        end
                        
                % Run one realization:        
                [FDIndex, FDTime, waveIndex, dummyagents] = ...
                    oneRunPan(n, z, maxWaves);

                    % Call to Pan and Self are interchangeable;
                    % just switch adjective from Pan to Self

                % ---- Time -------
                times(j,:) = FDTime;

                % ---- Waves ------
                waveSize(j,:) = waveIndex;

                % ---- FDIndex ------
                FDI(j,:) = FDIndex;

                % ---- Secret...agent..agent? -----
                agents(j,:,:) = dummyagents;

            end
         %----------------------------------------------

         %----------------------------------------------
         % Save things
            save(filename, 'agents', 'waveSize',...
                'times','FDI',...
                'batchSize','maxWaves');
         %-----------------------------------------------
    end
end

%------------------------------------------------
% Functions for setting filename
function [name] = makeNameUniform(zMin,zMax,n,foldername,batch)
    foldername = strcat(foldername,'/zMin_',strrep(num2str(zMin),'.','_'),...
        '_zMax_',strrep(num2str(zMax),'.','_'));
    name = strcat(foldername,'/Raw_',...
        'n',num2str(n),'_batch_', num2str(batch),'.mat');
end
function [name] = makeFilenameBernoulli(zMin,zMax,zNum,n,foldername,batch)
    foldername = strcat(foldername,'Raw_zMin_',strrep(num2str(zMin),'.','_'),...
        '_zMax_',strrep(num2str(zMax),'.','_'));
    name = strcat(foldername,'/Raw_',...
        'zNum',strrep(num2str(zNum),'.','_'),...
        'n',num2str(n), '_batch_',num2str(batch),...
        '.mat');
end
function [name] = makeNameShed(a,b,n,foldername, batch, h_a)
    foldername = strcat(foldername, '/h_a_', strrep(num2str(h_a), '.','_'));
    name = makeNameUniform(a,b,n,foldername, batch);
end

%--------------------------------------------------
% Functions for Generating Thresholds
%--------------------------------------------------
% For tent functions

function z = tentZ(zMin, zMax, n)
    z = zeros(n,1);
    nDex = 1;
    while nDex <= n
        candidate = (zMax-zMin)*rand + zMin;
        keep = tent(zMax,zMin,candidate);
        if keep == 1
            z(nDex,1) = candidate;
            nDex = nDex + 1;
        end
    end
end

%----------------------------
function keep = tent(zMax, zMin, candidate)
    midpoint = (zMax+zMin)/2;
    if candidate <= midpoint
        candY = (candidate - zMin)*(2/(zMax-zMin))^2;
    else
        candY = (zMax-candidate)*(2/(zMax-zMin))^2;
    end
    i = rand*(midpoint-zMin)*(2/(zMax-zMin))^2;
    if i > candY
        keep = 0;
    else
        keep = 1;
    end
end
%------------------------
% For Shed Functions
function z = shed(a,b,ha,n)

	if a == b
		z = ones(n,1)*a;
	else
   		 m = 2*((1/(b-a))-ha)/(b-a);
   		 hb = 2/(b-a)-ha;
    
  		 zIndex = 1; z = zeros(n,1);
    
   		 while zIndex <= n
        		candidate = (b-a)*rand+a;
        		candy = m*(candidate - a) + ha;
       			 i = rand*(max([ha,hb]));
        		if i < candy
           			 z(zIndex) = candidate;
           			 zIndex = zIndex + 1;
       			 end
        
    		 end
	end
end


%----------------------------------------------------------
% For Bernoulli Functions (half and half)
function z = Bern(zMin,zMax,n)
        smallerPercent = .5; 
        per = ceil(n*smallerPercent);
		z = [ones(per,1)*zMin;ones(n-per,1)*zMax];
end
%-----------------------------------------------------------
% For generalized Bernoulli Type (possibly with many thresholds)
function z = manyBern(zMin,n,h_a)
	% Treating zMin as array of values and h_a as their percents
	per = ceil(h_a(1)*n);
	z = ones(per,1)*zMin(1);
	for i = 2:(length(zMin)-1)
		per = ceil(h_a(i)*n);
		z = [z;ones(per,1)*zMin(i)];
	end
	z = [z;ones(n-length(z),1)*zMin(end)];
end
