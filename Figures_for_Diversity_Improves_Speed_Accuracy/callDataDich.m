% Collect data for dichotomous omniscient heatmap

function callDataDich(gammas,thMins,thMax,numTrials,n,poolSize,folderName1)

% Make sure directories exist

if exist(folderName1,'dir') ~= 7
    mkdir(folderName1)
end

folderName2 = strcat(folderName1,'/zMax_1_n',num2str(n));

if exist(folderName2,'dir')~=7
    mkdir(folderName2)
end

% If we got interupted in the middle of the last run, pick up where we left
% off.

save(strcat(folderName2,'/background.mat'),'gammas',...
	'thMins','thMax','numTrials','n');

tempFileName = strcat(folderName2, '/temp.mat');


tempExists = 0;
ii = 1;
jj = 1;


z_min = thMins(ii);
fileName = strcat(folderName2,...
     '/zMin_', strrep(num2str(z_min),'.','_'),'.mat');
while(isfile(fileName))
    ii = ii + 1;
    z_min = thMins(ii);
    fileName = strcat(folderName2,...
	     '/zMin_', strrep(num2str(z_min),'.','_'),'.mat');
end
if isfile(tempFileName)
	gru = load(tempFileName);
	jj = gru.j;
    newThMin = gru.z_min;
    if thMins(ii) == newThMin
        ii = gru.i;
        accs = gru.accs; decs = gru.decs; socs = gru.socs;
        times = gru.times; threshes = gru.threshes;
        tempExists = 1;    
    end
end


% Make a parpool
poolobj = gcp('nocreate');
if isempty(poolobj)
    if poolSize > 0
        parpool(poolSize)
    else
        parpool()
    end
end

th_min_array = thMins;
gamma_array = gammas;
for i = ii:length(thMins)

    z_min = th_min_array(i);
    fileName = strcat(folderName2,...
	     '/zMin_', strrep(num2str(z_min),'.','_'),'.mat');

    datestr(now, 'HH:MM:SS')
    sprintf('Starting round %d, i = %d', z_min, i)
    
    % If we didn't get interupted, reset variables.
    if tempExists == 0
    	accs = zeros(length(gamma_array),numTrials,3,2);
        decs = zeros(length(gamma_array),numTrials,2,10);
        socs = decs;
        times = zeros(length(gamma_array),numTrials,1); threshes = times;
    end


    for j = jj:length(gamma_array)

         numAcc = zeros(numTrials,3,2); 
         wavesDec = zeros(numTrials, 2,10); wavesSoc = wavesDec;
         theseTimes = zeros(1,numTrials); theseThreshes = theseTimes;
         gen = ceil(gamma_array(j)*n);
         other = n - gen;

      parfor k = 1:numTrials
            [newAcc,newDec,newSoc,FDTime,FDthresh] = oneRunBernLong([z_min,gen; 1,other], 10);
            numAcc(k,:,:) = newAcc;
            wavesDec(k,:,:) = newDec;
            wavesSoc(k,:,:) = newSoc;
            theseTimes(1,k) = FDTime; 
            theseThreshes(1,k) = FDthresh;
      end
        
        accs(j,:,:,:) = numAcc;
        decs(j,:,:,:) = wavesDec;
        socs(j,:,:,:) = wavesSoc;
        times(j,:) = theseTimes; 
        threshes(j,:) = theseThreshes;
	clear numAcc
    clear wavesDec
    clear wavesSoc
    clear theseTimes
    clear theseThreshes
	if mod(j,5) == 0
		datestr(now, 'HH:MM:SS')
		sprintf('Round %d, %d gammas out of %d completed', i, j, length(gamma_array))
	
		save(tempFileName, 'accs','decs','socs','times','threshes', 'j','i','z_min')
	end
    end

    save(fileName,'accs', 'decs', 'socs','times', 'threshes');
    clear accs
    clear decs
    clear socs
    clear times
    clear threshes
    if exist(tempFileName,'file') == 2
        delete(tempFileName)
    end
    jj = 1; tempExists = 0;
    datestr(now, 'HH:MM:SS')
    sprintf('Finished round %d, i = %d', z_min,i)

    
end
