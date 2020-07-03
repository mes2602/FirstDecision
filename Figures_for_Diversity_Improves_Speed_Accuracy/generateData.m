% This should be a thing the user can use to generate wanted data.


% Set number of cores to use for parallel processing.
% poolSize = 0 corresponds to using the default parpool settings.
poolSize = 0;


%---------------------------------------------------------------
% Sections that generate data for various cases
%---------------------------------------------------------------

% Homogeneous data
%---------------------------------------------------------------
%
% Used in Figures 1,2,4; Supplemental figures 3, 9
%---------------------------------------------------------------
ns = [50,70,100,145,205,290,415,595,845,1200,1710,2435,...
    3460,4935,7025,10000,15000];
thMins = [0.0001,0.0005,0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1];

selfVsOmni = 0; zNum = 0; thMax = 1; numBatches = 30; gr = 0; 
folderName1 = 'SelfHomo_Paper';
callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);

ns = [20000,50000]; numBatches = 12;
callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);

%---------------------------------------------------------------
% Dichotomous Data
%---------------------------------------------------------------
% Short: the figure 2 lines
gammas = [0.05,0.3,0.7];
thMins = [.05,.1,.2,.3,.4,.5,.6,.7,.8,.9,1];
ns = 15000;
    % Consensus Bias------------------------------------
    % 
    % Used in figure 2; Supplemental figure 4
    %---------------------------------------------------
    selfVsOmni = 0; zNum = 2; thMax = 1; numBatches = 30; 
    folderName1 = 'SelfDich';
    for i = 1:length(gammas)
        gr = gammas(i);
        callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);
    end
    % Omniscient ----------------------------------------
    %
    % Used in Supplemental figures 5 and 6
    %----------------------------------------------------
    selfVsOmni = -1; zNum = 2; thMax = 1; numBatches = 30; 
    folderName1 = 'Dich';
    for i = 1:length(gammas)
        gr = gammas(i);
        callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);
    end
%---------------------------------------------------------------   
% Long: for generating the figure 3 heat maps. Also used in Figure 4,
% and Supplement figure 9.

% Warning: This function may overwrite existing data, or fail to overwrite
% existing data, depending on what parameters you choose to change. If
% changing parameters, it is strongly suggested that the name of
% folderName1 be changed also. This will prevent issues in data generation,
% but will require a corresponding folder name shift where this data gets
% used (in figure 3 and figure 4). 

% Exception: If you got interupted in the middle of the last run and are
% not changing any of the parameters, rerunning without any changes should
% result in the function picking up where it left off. 

gammas = .001:.02:1; thMins = .01:.04:1;
thMax = 1; numTrials = 700; n = 15000;
folderName1 = 'Dich2Dense';
callDataDich(gammas,thMins,thMax,numTrials,n,poolSize,folderName1)
%---------------------------------------------------------------  




% Uniform
%---------------------------------------------------------------
thMins = [.05,.1,.2,.3,.4,.5,.6,.7,.8,.9,1];
ns = [5000,10000,15000];
    % Consensus Bias -------------------------------------------
    %
    % Used in Supplement figures 7 and 8
    %-----------------------------------------------------------
    selfVsOmni = 0; zNum = 1; thMax = 1; numBatches = 20; gr = 0;
    folderName1 = 'SelfUniform';
    callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);
    % Omniscient ------------------------------------------------
    %
    % Used in figure 4 and Supplement figure 9
    %------------------------------------------------------------
    selfVsOmni = -1; zNum = 1; thMax = 1; numBatches = 20; gr = 0;
    folderName1 = 'Uniform';
    callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);
    
    
  
    
% Shed
%---------------------------------------------------------------
% Omniscient cases used in figure 4. 
% Consensus Bias cases not used in figures.
thMins = [.05,.1,.2,.3,.4,.5,.6,.7,.8,.9,1];
ns = 15000;

    % Inclined, Omniscient---------------------------------------
    %
    % Used in Supplement figure 9
    %------------------------------------------------------------
    selfVsOmni = -1; zNum = 5; thMax = 1; numBatches = 20; gr = 1;
    folderName1 = 'Shed';
    callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);
    % Declined, Omniscient ---------------------------------------
    %
    % Used in Supplement figure 9
    %-------------------------------------------------------------
    selfVsOmni = -1; zNum = 5; thMax = 1; numBatches = 20; gr = 2;
    folderName1 = 'Shed';
    callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);
    
    
%     % Inclined,Consensus Bias-----------------------------------
%     %
%     % Not used in paper
%     %-----------------------------------------------------------
%     selfVsOmni = 0; zNum = 5; thMax = 1; numBatches = 20; gr = 1;
%     folderName1 = 'SelfShed';
%     callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);
%     % Declined, Consensus Bias-----------------------------------
%     %
%     % Not used in paper
%     %------------------------------------------------------------
%     selfVsOmni = 0; zNum = 5; thMax = 1; numBatches = 20; gr = 2;
%     folderName1 = 'SelfShed';
%     callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);

    
    
    
% Tent
%---------------------------------------------------------------
thMins = [.05,.1,.2,.3,.4,.5,.6,.7,.8,.9,1];
ns = 15000;

    % Omniscient ------------------------------------------------
    %
    % Used in Supplement figure 9
    %------------------------------------------------------------
    selfVsOmni = -1; zNum = 3; thMax = 1; numBatches = 20; gr = 0;
    folderName1 = 'Tent';
    callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);
   
%     % Consensus Bias --------------------------------------------
%     %
%     % Not used in paper
%     %------------------------------------------------------------
%     selfVsOmni = 0; zNum = 3; thMax = 1; numBatches = 20; gr = 0;
%     folderName1 = 'SelfTent';
%     callData(folderName1,selfVsOmni,zNum,thMax,thMins,ns,poolSize,numBatches,gr);



% Smoluchowski Equation
%-----------------------------------------------------------------
%
% Used in Supplement figure 1
%-----------------------------------------------------------------

diffAll(.1,.0004023,23); diffAll(.5,.01006,21);
diffAll(.1,.0004,22); diffAll(.5,.012,18);
diffAll(.1,.0012,18); diffAll(.5,.3,18);


% Make sure there's a figures folder:
%------------------------------------------------------------------
if exist('Figures','dir') ~= 7
    mkdir(folderName1)
end