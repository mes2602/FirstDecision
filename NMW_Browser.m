function NMW_Browser()
%demoBrowser: an example of using layouts to build a user interface
%
%   demoBrowser() opens a simple GUI that allows several of MATLAB's
%   built-in demos to be viewed. It aims to demonstrate how multiple
%   layouts can be used to create a good-looking user interface that
%   retains the correct proportions when resized. It also shows how to
%   hook-up callbacks to interpret user interaction.
%
%   See also: <a href="matlab:doc Layouts">Layouts</a>

%   Copyright 2010-2013 The MathWorks, Inc.

% Data is shared between all child functions by declaring the variables
% here (they become global to the function). We keep things tidy by putting
% all GUI stuff in one structure and all data stuff in another. As the app
% grows, we might consider making these objects rather than structures.
global data
global gui
data = createData();
gui = createInterface( data.DemoNames, data.Section2Names );

% Now update the GUI with the current data
updateInterface();
redrawDemo();

% Explicitly call the demo display so that it gets included if we deploy
displayEndOfDemoMessage('')

%-------------------------------------------------------------------------%
    function data = createData()
        % Create the shared data-structure for this application
        % the function calls for section lists will basically 
        % be redraws?
        demoList = {
            'Section 2 Figures'            'section2desc'
            'Section 3 Figures'            'section3desc'
            'Section 4 Figures'            'section4desc'
            'Section 6 Figures'            'section6desc'
            'Section 7 Figures'            'section7desc'

            };
        sectionList = {
            'Section2'
            'Section3'
            'Section4'
            'Section6'
            'Section7'
            };
        section2List = {
            'First Decision Time Distribution'  'section2FDTdistDesc'   'section2FDTdist'
            };
        selectedSection = 1;
        selectedFigure = 1;
        ns = 0; a = 0; theta = 1; nT = 500;
        data = struct( ...
            'DemoNames', {demoList(:,1)'}, ...
            'DemoFunctions', {demoList(:,2)'}, ...
            'SelectedSection', selectedSection,...
            'SectionNames', {sectionList(:,1)'},...
            'Section2Names', {section2List(:,1)'},...
            'Section2Descriptions', {section2List(:,2)},...
            'Section2Figures', {section2List(:,3)},...
            'SelectedFigure', selectedFigure,...
            'CreateN', ns,...
            'CreateA', a,...
            'CreateTheta', theta,...
            'CreateNT', nT,...
            'DisplayN', ns,...
            'DisplayA', a,...
            'DisplayTheta', theta);
            
    end % createData

%-------------------------------------------------------------------------%
    function gui = createInterface( demoList, section2List )
        % Create the user interface for the application and return a
        % structure of handles for global use.
        gui = struct();
        % Open a window and add some menus
        gui.Window = figure( ...
            'Name', 'Gallery browser', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off' );
        
        % + File menu
        gui.FileMenu = uimenu( gui.Window, 'Label', 'File' );
        uimenu( gui.FileMenu, 'Label', 'Exit', 'Callback', @onExit );
        
        % + View menu
        gui.ViewMenu = uimenu( gui.Window, 'Label', 'View' );
        for ii=1:numel( demoList )
            uimenu( gui.ViewMenu, 'Label', demoList{ii}, 'Callback', @onSectionSelection );
        end
        
        % + Help menu
        helpMenu = uimenu( gui.Window, 'Label', 'Help' );
        uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );
        
        
        % Arrange the main interface
        mainLayout = uix.HBoxFlex( 'Parent', gui.Window, 'Spacing', 3 );
        
        % + Create the panels
        controlPanel = uix.BoxPanel( ...
            'Parent', mainLayout, ...
            'Title', 'Select a Figure:' );
        gui.ViewPanel = uix.BoxPanel( ...
            'Parent', mainLayout, ...
            'Title', 'Viewing: ???', ...
            'HelpFcn', @onDemoHelp );
        gui.ViewContainer = uicontainer( ...
            'Parent', gui.ViewPanel );        

        % + Adjust the main layout
        set( mainLayout, 'Widths', [-1,-2]  );
        
        
        % + Create the controls
        controlLayout = uix.VBox( 'Parent', controlPanel, ...
            'Padding', 3, 'Spacing', 3 );
        gui.ListBox = uicontrol( 'Style', 'list', ...
            'BackgroundColor', 'w', ...
            'Parent', controlLayout, ...
            'String', section2List(:), ...
            'Value', 1, ...
            'Callback', @onFigureSelection);
        gui.HelpButton = uicontrol( 'Style', 'PushButton', ...
            'Parent', controlLayout, ...
            'String', 'Help for <demo>', ...
            'Callback', @onDemoHelp );
        set( controlLayout, 'Heights', [-1 28] ); % Make the list fill the space
        
        % + Create the view
        %p = gui.ViewContainer;
        %gui.ViewAxes = axes( 'Parent', p );
        viewLayout = uix.VBoxFlex( 'Parent', gui.ViewContainer, 'Spacing', 3 );
        % + Create the panels
        upperPanel = uix.BoxPanel(...
            'Parent', viewLayout,...
            'Title', 'Figure Data: ' );
        gui.lowerPanel = uix.BoxPanel( ...
            'Parent', viewLayout, ...
            'Title', 'Figure Description:' );
        upperPanelLayout = uix.VBoxFlex( 'Parent', upperPanel);
        gui.viewExistingData = uix.BoxPanel(...
            'Parent', upperPanelLayout,...
            'Title', 'Choose from existing data: ' );
        viewExistingLayout = uix.HBoxFlex( 'Parent', gui.viewExistingData);
        pickExisting = uix.BoxPanel(...
            'Parent', viewExistingLayout,...
            'Title', 'Choose (n, theta) pair: ');
        createExistingFigure = uix.BoxPanel(...
            'Parent', viewExistingLayout);
        createNewPanel = uix.BoxPanel( 'Parent', upperPanelLayout,...
            'Title', 'Create new dataset: ');
        
        
        createNewLayout = uix.HBoxFlex('Parent',createNewPanel, 'Spacing',3);
        gui.createNewDataPanelCreate = uix.BoxPanel( 'Parent', createNewLayout);
        
        % + Create the upper panel controls
        gui.chooseExistingData = uicontrol('Style','popupmenu',...
            'Parent', pickExisting,...
            'String', findHomoData(),...            
            'CallBack', @onSelectExisting );
        gui.makeFromExistingData = uicontrol('Style', 'pushbutton',...
            'Parent', createExistingFigure,...  
            'String', 'Show Figure',... 
            'CallBack', @onShowFigure );
       gui.createDataButton = uicontrol('Style', 'pushbutton',...
           'Parent', gui.createNewDataPanelCreate,...
           'String', 'Create Data! ',...
           'CallBack', @onCreateNewDataset );
       
       % + Create the lower panel textbox
       data.Section2Descriptions{1}
       a = evalin('base', data.Section2Descriptions{1})
       gui.figureDesc = uicontrol( 'Style', 'text',...
           'Parent', gui.lowerPanel,...
           'String', a );

        
    end % createInterface

%-------------------------------------------------------------------------%
    function updateInterface()
        % Update various parts of the interface in response to the demo
        % being changed.
        sectionStr = strcat(data.SectionNames(data.SelectedSection),'Names');
        sectionStr = sectionStr{1};
        % Update the list and menu to show the current demo
        set( gui.ListBox, 'Value', data.SelectedFigure );
        set( gui.chooseExistingData,...
            'String', findHomoData() );
        % Update the help button label
        figureName = data.(sectionStr)( data.SelectedFigure );
        figureName = figureName{1};
        demoName = data.DemoNames(data.SelectedSection);
        set( gui.HelpButton, 'String', ['Help for ',demoName] );
        % Update the view panel title
        set( gui.ViewPanel, 'Title', sprintf( 'Viewing: %s', figureName ) );
        % Untick all menus
        menus = get( gui.ViewMenu, 'Children' );
        set( menus, 'Checked', 'off' );
        % Use the name to work out which menu item should be ticked
        whichMenu = strcmpi( figureName, get( menus, 'Label' ) );
        set( menus(whichMenu), 'Checked', 'on' );
    end % updateInterface. Gosh I hope this is right.
%-------------------------------------------------------------------------%
    function redrawDemo()
%         % Draw a demo into the axes provided
%         
%         
%         % We first clear the existing axes ready to build a new one
%         if ishandle( gui.ViewAxes )
%             delete( gui.ViewAxes );
%         end
%         
%         % Some demos create their own figure. Others don't.
%         if data.SelectedFigure > 0
%             sectionStr = strcat(data.SectionNames(data.SelectedSection),'Functions');
%             sectionStr = sectionStr{1};
%             fcnName = data.(sectionStr)( data.SelectedFigure );
%             fcnName = fcnName{1};
%         else
%             fcnName = data.DemoFunctions(data.SelectedSection );
%         end
%         
%         switch upper( fcnName )
%             case 'LOGO'
%                 % These demos open their own windows
%                 evalin( 'base', fcnName );
%                 gui.ViewAxes = gca();
%                 fig = gcf();
%                 set( fig, 'Visible', 'off' );
%                 
%             otherwise
%                 % These demos need a window opening
%                 fig = figure( 'Visible', 'off' );
%                 evalin( 'base', fcnName );
%                 gui.ViewAxes = gca();
%         end
%         % Now copy the axes from the demo into our window and restore its
%         % state.
%         cmap = colormap( gui.ViewAxes );
%         set( gui.ViewAxes, 'Parent', gui.ViewContainer );
%         colormap( gui.ViewAxes, cmap );
%         rotate3d( gui.ViewAxes, 'on' );
%         % Get rid of the demo figure
%         close( fig );
     end % redrawDemo

%-------------------------------------------------------------------------%
    function onFigureSelection( src, ~ )
        % User selected a demo from the list - update "data" and refresh
        data.SelectedFigure = get( src, 'Value' );
        updateInterface();
        %redrawDemo();
    end % onListSelection

%-------------------------------------------------------------------------%
    function onSectionSelection( src, ~ )
        % User selected a demo from the menu - work out which one
        demoName = get( src, 'Label' );
        data.SelectedDemo = find( strcmpi( demoName, data.DemoNames ), 1, 'first' );
        updateInterface();
        %redrawDemo();
    end % onMenuSelection


%-------------------------------------------------------------------------%
    function onHelp( ~, ~ )
        % User has asked for the documentation
        doc layout
    end % onHelp

%-------------------------------------------------------------------------%
    function onDemoHelp( ~, ~ )
        % User wnats documentation for the current demo
        showdemo( data.DemoFunctions{data.SelectedDemo} );
    end % onDemoHelp

%-------------------------------------------------------------------------%
    function onExit( ~, ~ )
        % User wants to quit out of the application
        delete( gui.Window );
    end % onExit

%-------------------------------------------------------------------------%
    function desc = section2FDTdistDesc()
        % This should give information about what the variables are for,
        % etc.
        
        desc = 'I am a test string';
    end % section2FDTdistDesc
 %------------------------------------------------------------------------%
    function homoData = findHomoData()
    % Pairs have form n, theta
    if isfile('Homogeneous/background.mat')
         gru = load('Homogeneous/background.mat');
        dataPairs = gru.dataPairs;
    else
        dataPairs = [0,0];
    end
    homoData = {'(n, theta)' };
    for i = 2:length(dataPairs(:,1)) + 1
        strThing = strcat('(', num2str(dataPairs(i-1,1)), ', ', num2str(dataPairs(i-1,2)), ')');
        
        homoData{i} = strThing;
    end
    end % findHomoData

 %------------------------------------------------------------------------%
 function onCreateNewDataset(~, ~)
    done = 0;
    if data.SelectedSection < 6
        while done == 0
        prompt = {'Enter clique size:','Enter threshold \theta :',...
            'Enter number of trials (opt)'};
        dlgtitle = 'Homogeneous Threshold Dataset';
        dims = [1 60];
        definput = {'100','0.5','500'};
        opts.Interpreter = 'tex';
        answer = inputdlg(prompt,dlgtitle,dims,definput,opts);
        
        goodAnswer = -1;
        largeNwarning = ''; largeZwarning = '';
        if length(answer) > 1
            n = str2double(answer{1});
            z = str2double(answer{2});
            nT = str2double(answer{3});
            if n > 1
                data.CreateN = n;
                if n > 1000
                    largeNwarning = ...
                        'Clique size is large, so data generation may be slow';
                end
                goodAnswer = 1;
            else
                goodAnswer = 0;
            end
            if z > 0
                data.CreateA = z;
                if z > 1.5
                    largeZwarning = 'Threshold is large, so data generation may be slow.';
                end
            else
                goodAnswer = 0;
            end
            if nT > 1
                data.CreateNT = nT;
            else
                goodAnswer = 0;
            end
        end
        
        if goodAnswer > 0 
            opts.Interpreter = 'tex';
            opts.Default = 'Cancel';
            % Use the TeX interpreter to format the question
            quest = {strcat('Clique size n = ',num2str(data.CreateN));...
                strcat('Threshold \theta = ', num2str(data.CreateA));...
                strcat('Number of Trials = ', num2str(data.CreateNT));...
                largeNwarning;largeZwarning;...
                'Use these parameters?'};
            answer = questdlg(quest,'Create Homogeneous Dataset?',...
                              'Use','Change','Cancel',opts);
            switch answer
                case 'Use'
                    makeNewHomoData();
                    done = 1;
                case 'Change'
                    done = 0;
                case 'Cancel'
                    done = 1;
            end

        else
           if goodAnswer == 0
               opts.Interpreter = 'tex';
               opts.Default = 'Cancel';
                % Use the TeX interpreter to format the question
                quest = {strcat('Clique size n = ',num2str(n));...
                    strcat('Threshold \theta = ', num2str(z));...
                    strcat('Number of trials = ', num2str(nT));...
                    'These parameters are unusable. Change parameters?'};
                answer = questdlg(quest,'Create Homogeneous Dataset?',...
                                  'Change','Cancel',opts);
                switch answer
                    case 'Change'
                        done = 0;
                    case 'Cancel'
                        done = 1;
                end
           else
               done = 1;
           end
        end
        data.createN = 0; data.createA = 0; 
        data.createTheta = 1; data.createNT = 500;
        end

    else
        if data.SelectedSection == 6
            prompt = {'Enter clique size:', 'Enter minimum threshold: ',...
                'Enter maximum threshold: ' };
            dlgtitle = {'Create New Heterogeneous Threshold Dataset';...
                'Self-referential Social Rule'};
            dims = [1 35];
            definput = {'100', '0.5', '1'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
        else
            prompt = {'Enter clique size:', 'Enter minimum threshold: ',...
                'Enter maximum threshold: ' };
            dlgtitle = {'Create New Heterogeneous Threshold Dataset';...
                'Omniscient Social Rule'};
            dims = [1 35];
            definput = {'100', '0.5', '1'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
        end
    end
    
    
 end % onCreateNewDataset **********
 %------------------------------------------------------------------------%
 function onSelectExisting(src,~)
    index = get(src, 'Value');
    goodData = 1;
    if index == 1
        goodData = 0;
    else
        switch(data.SelectedSection)
            case 6
                dataStruct = findSelfUnData();
            case 7
                dataStruct = findOmniUnData();
            otherwise
                dataStruct = findHomoData();
        end
        %index = index - 1;
        if index <= length(dataStruct)
            dataStr = dataStruct{index};
        else
            goodData = 0;
        end
        
    end
    
    if goodData == 0
        data.DisplayN = 0; data.DisplayA = 0; data.DisplayTheta = 1;
    else
        % Remove parentheses
        dataStr = dataStr(2:end-1);
        splitStr = strsplit(dataStr,', ');
        if length(splitStr) < 2
            splitStr = strsplit(splitStr{1},',');
        end
        n = splitStr{1};
        a = splitStr{2};
        if length(splitStr) == 3
            theta = splitStr{3};
            data.DisplayTheta = str2double(theta);
        else
            data.DisplayTheta = 1;
        end
        
        data.DisplayN = str2double(n);
        data.DisplayA = str2double(a);
    end
            
 end % onSelectExisting
 %------------------------------------------------------------------------%
 function onShowFigure(~,~)
    
    sectionStr = strcat(data.SectionNames(data.SelectedSection),'Figures');
            sectionStr = sectionStr{1};
            fcnName = data.(sectionStr)( data.SelectedFigure );
            fcnName = fcnName{1};
            evalin( 'base', fcnName );
            %data.DisplayN = 0; data.DisplayA = 0; data.DisplayTheta = 1;
 end % onShowFigure **********
 %------------------------------------------------------------------------%
 function onSetNewN(src,~)
    thingy = get(src, 'String');
       o = str2num(thingy);
       r = ~isempty(o);
       if r
           o = floor(o);
           data.CreateN = max(o,0);           
       else
           data.CreateN = 0;
       end
                 
 end % onSetNewN

 %------------------------------------------------------------------------%
 function onSetNewThetaMin(src,~)
    thingy = get(src, 'String');
       o = str2num(thingy);
       r = ~isempty(o);
       if r
           o = floor(o);
           data.CreateA = max(o,0);           
       else
           data.CreateA = 0;
       end
 end % onSetNewThetaMin

 %------------------------------------------------------------------------%
 function onSetNewThetaMax(src,~) 
    thingy = get(src, 'String');
       o = str2num(thingy);
       r = ~isempty(o);
       if r
           o = floor(o);
           data.CreateTheta = max(o,0);           
       else
           data.CreateTheta = 1;
       end
 end % onSetNewThetaMax

 %------------------------------------------------------------------------%
 function makeNewHomoData()
    
    n = data.CreateN; z = data.CreateA; 
    % Select number of trials based on theta, n 
    batchSize = data.CreateNT;
    
    folderName = 'Homogeneous';
    folderNameLong = strcat(folderName, '/zMin_', ...
        strrep(num2str(z),'.','_'), '_zMax_',...
        strrep(num2str(z),'.','_'));
    A = exist( folderNameLong, 'dir');
    if A == 0
        mkdir(folderNameLong);
    end
    selfVsOmni = 0; % selfVsOmni = -1 for omni, else self
    maxWaves = 10;
    zMin = z; zMax = z; zNum = 0; 
    batch = 1; n_array = n;
    saveRaw(n_array,zMin,zMax, zNum, maxWaves,...
    batchSize,batch,folderName,selfVsOmni)

    
    
    social = 0; 
    
    qu = 'Beginning data processing...';
    h = msgbox(qu);
    set(findobj(h,'Tag','MessageBox'),'String', qu)
    chef(folderNameLong,zMin,zMax,n,social);
      
    
    if isfile(strcat(folderName, '/background.mat'))
        gru = load(strcat(folderName, '/background.mat'));
        dataPairs = gru.dataPairs;
        dataPairs(end + 1,:) = [n,z];
        save(strcat(folderName, '/background.mat'), 'dataPairs');
    else
       dataPairs = [n,z];
       save(strcat(folderName, '/background.mat'), 'dataPairs');
    end
    qu = 'Data processing complete.';
    set(findobj(h,'Tag','MessageBox'),'String', qu);
    
    updateInterface();
end % makeNewHomoData

%-------------------------------------------------------------------------%
% Utility functions 


% Generic
function [a,variable] = VsA(folderName, variableName, n, zMin, zMax,redo,social,waves)

    maybeA = zMin : .05 : .8;
    szA = length(maybeA);
    
        
    index = 0;
    for i = 1:szA
        zMin = maybeA(i);
        folderName2 = strcat(folderName, '/zMin_', ...
        strrep(num2str(zMin),'.','_'),'_zMax_',...
        strrep(num2str(zMax),'.','_'));
        filename = strcat(folderName2,'/Cooked_n',num2str(n),'.mat');
        
        % Check to see if the file has already been processed
        if isfile(filename)
            vars = whos('-file',filename);
            % Check to see if it's been processed since the desired 
            % variable was added
            if (~ismember(variableName,{vars.name})) || (redo ==1)
                delete (filename)
                chef(folderName2, zMin, zMax, n,social);
                %fprintf(strcat('Recalculating for a = ',num2str(zMin)))
            end
            gru = load(filename, variableName);
            index = index + 1;
            if waves > 0
            variable(index,:,:) = gru.(variableName);
            else
            variable(index) = gru.(variableName);
            end
            a(index) = zMin;
        else
            % was debugging st = strcat('hi',num2str(i))
            
            if isfile(strcat(folderName2, '/Raw_n', num2str(n),'_batch_1.mat'))
                chef(folderName2, zMin, zMax, n,social);
                %fprintf(strcat('Calculating for a = ',num2str(zMin)))
                gru = load(filename, variableName);
                index = index + 1;
                if waves > 0
                variable(index,:,:) = gru.(variableName);
                else
                variable(index) = gru.(variableName);
                end
                a(index) = zMin;
            end
        end
        
            
    end

end
function [ns, variable] = VsN(folderName, variableName, maxN,zMin,zMax,redo,social,waves)
    n_array = [10,20,40,60,80,100,150,300,500,1000,5000,10000];
    szN = length(n_array);
    % if this n value doesn't have a file, will return
        %ns = 0; variable = 0;
    
        
    index = 0; i = 1;
    n = n_array(i);
    while i <= szN && n < maxN
        n = n_array(i);
        
        folderName2 = strcat(folderName, '\zMin_', ...
        strrep(num2str(zMin),'.','_'),'_zMax_',...
        strrep(num2str(zMax),'.','_'));
        filename = strcat(folderName2,'\Cooked_n',num2str(n),'.mat');
        
        % Check to see if the file has already been processed
        if isfile(filename)
            vars = whos('-file',filename);
            % Check to see if it's been processed since the desired 
            % variable was added
            if ~ismember(variableName,{vars.name}) || redo ==1
                delete(filename)
                chef(folderName2, zMin, zMax, n,social);
            end
            gru = load(filename, variableName);
            index = index + 1;
            if waves > 0
            variable(index,:,:) = gru.(variableName);
            else
            variable(index) = gru.(variableName);
            end
            ns(index) = n;
        else
            % was debugging st = strcat('hi',num2str(i))
            
            if isfile(strcat(folderName2, '\Raw_n', num2str(n),'_batch_1.mat'))
                chef(folderName2, zMin, zMax, n,social);
                gru = load(filename, variableName);
                index = index + 1;
                if waves > 0
                variable(index,:,:) = gru.(variableName);
                else
                variable(index) = gru.(variableName);
                end
                ns(index) = n;
            end
        end
            i = i + 1;
    end

end
function [z1Per,variable] = Vsz1Per(folderName, variableName, n, zMin, zMax,redo,social,waves)

    maybePer = 0 : .1 : 1;
    szP = length(maybePer);
    
    
    index = 0;
    for i = 1:szP
        h = maybePer(i);
        folderName3 = strcat(folderName,'_smallPer_',...
        strrep(num2str(h),'.','_'));
        folderName2 = strcat(folderName3,'/zMin_', ...
        strrep(num2str(zMin),'.','_'),'_zMax_',...
        strrep(num2str(zMax),'.','_'));
        filename = strcat(folderName2,'/Cooked_n',num2str(n),'.mat');
        
        % Check to see if the file has already been processed
        if isfile(filename)
            vars = whos('-file',filename);
            % Check to see if it's been processed since the desired 
            % variable was added
            if (~ismember(variableName,{vars.name})) || (redo ==1)
                delete (filename)
                chef(folderName2, zMin, zMax, n,social);
                %fprintf(strcat('Recalculating for a = ',num2str(zMin)))
            end
            gru = load(filename, variableName);
            index = index + 1;
            if waves > 0
            variable(index,:,:) = gru.(variableName);
            else
            variable(index) = gru.(variableName);
            end
            z1Per(index) = h;
        else
            % was debugging st = strcat('hi',num2str(i))
            
            if isfile(strcat(folderName2, '/Raw_n', num2str(n),'_batch_1.mat'))
                chef(folderName2, zMin, zMax, n,social);
                %fprintf(strcat('Calculating for a = ',num2str(zMin)))
                gru = load(filename, variableName);
                index = index + 1;
                if waves > 0
                variable(index,:,:) = gru.(variableName);
                else
                variable(index) = gru.(variableName);
                end
                z1Per(index) = h;
            end
        end
        
            
    end

end

%-------------------------------------------------------------------------%
% Figure functions

% Section 2
    function section2FDTdist()
        
        n = data.DisplayN; z = data.DisplayA; 
        numT = 100; numBins = 50;
        zstr = strrep(num2str(z),'.','_');
        fileName = strcat('Homogeneous/zMin_',zstr,...
            '_zMax_',zstr, '/Cooked_n', num2str(n),'.mat');
        
        if isfile(fileName) < 1
            msgbox('Requested data does not exist.');
        else
            h = msgbox('Generating figure...');
            gru = load(fileName, 'histTime');
            histData = gru.histTime;
            
            smallT = min(histData); bigT = max(histData); 
            times = linspace(smallT,bigT, numT);
            for i = 1:numT
                t = times(i);
                em = erfc((z-t)/sqrt(4*t))*(.5 + exp(-z)/2); 
                eM = erfc((z+t)/sqrt(4*t))*(.5+exp(z)/2);

                b = z*cosh(z/2)*(1/sqrt(pi*t^3))*exp(-(z^2 + t^2)/(4*t));

                % 2.12
                eq1(i) = n*b*(1-(em+eM))^(n-1);

                % 2.13
                eq2(i) = n*exp((1-n)*(em+eM))*b;

                % 2.14
                eq3(i) = n*b*exp((1-n)*2*sqrt(t/pi)*...
                    exp(-z^2/(4*t))*((2/z)*(1-(2*t)/z^2)*cosh(z/2)-sinh(z/2)));
            end
            
            figure()
            histogram(histData, 'DisplayName', 'Sims', 'normalization', 'pdf')
            legend('-DynamicLegend')
            hold on
            plot(times, eq1, 'DisplayName', 'Eq. 1', 'LineWidth', 1.5)
            hold on
            plot(times, eq2, 'DisplayName', 'Eq. 2','LineWidth', 1.5)
            hold on
            plot(times, eq3, 'DisplayName', 'Eq. 3','LineWidth', 1.5)
            xlabel('time')
            
            tit1 = 'Distribution of First Decision Times';
            tit2 = strcat('n = ', num2str(n), ', threshold \theta = ', num2str(z));
            title({tit1;tit2})
            delete(h)
        end
    end

end % EOF