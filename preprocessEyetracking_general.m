function preprocessEyetracking_general(subFolder,saveME)
%%function for preprocessing LiveTrack eye tracking data.
%expects data to be in the form output from HID2struct
%subFolder is a string of the directory name containing t he data to be
%analyzed
%saveME is either 1 or 0, depending if you want to save outputs, including
%calibrated position data, and a logical indicating i blinks occur

% Get Calibration Matrices
calibrationMatrices = dir([subFolder '/*cal*.mat']);
calNames = cat(2,{calibrationMatrices(:).name});

% Get targets
targets = dir([subFolder '/*dat*.mat']);
targetNames = cat(2,{targets(:).name});

% Rip calibration times from name
calTimes = nan(1,length(calNames));
for i = 1:length(calNames)
    calTimes(i) = str2num(calNames{i}(find('_' == calNames{i},1,'last')+1:find('.' == calNames{i},1,'last')-1));
end

rawData = dir([subFolder '/*REPORT*.mat']);
for dataName = cat(2,{rawData(:).name})
    runNumber = find(ismember(cat(2,{rawData(:).name}),dataName));
    
    % load data
    dat = load([subFolder '/' dataName{1}]);
    dat = dat.Report;
    
    rawX = cat(1,dat.PupilCameraX_Ch01);
    rawY = cat(1,dat.PupilCameraY_Ch01);
    glintX = cat(1,dat.Glint1CameraX_Ch01);
    glintY = cat(1,dat.Glint1CameraY_Ch01);
    isBlink = ~cat(1,dat.PupilTracked_Ch01);
    
    % Linearly interpolate blinks
    [linX linY] = linterpBlinkGaps(rawX,rawY,isBlink);
    [linGlintX linGlintY] = linterpBlinkGaps(glintX,glintY,isBlink);
    
    % Load the appropriate calibration matrix
    datTime = str2num(dataName{1}(find('_' == dataName{1},1,'last')+1:find('.' == dataName{1},1,'last')-1));
    calMatInd = find(calTimes<datTime & calTimes==max(calTimes(calTimes<datTime)));
    calMat = load([subFolder '/' calNames{calMatInd}]);
    Rpc = calMat.Rpc;
    calMat = calMat.CalMat;
    
    tar = load([subFolder '/' targetNames{calMatInd}]);
    
    
    % Transform data with calibration matrix
    tmp = calMat*[([linX-linGlintX]./Rpc)'; ([linY-linGlintY]./Rpc)'; ...
        (1-sqrt(([linX-linGlintX]./Rpc).^2 + ([linY-linGlintY]./Rpc).^2))'; ones(1,length(linX))];
    calibratedXYZ = [bsxfun(@rdivide,tmp(1:3,:),tmp(4,:))]';
    
    [movementAngle b] = cart2pol(diff(calibratedXYZ(:,1)),diff(calibratedXYZ(:,2)));
    movementSpeed = (sqrt((diff(calibratedXYZ(:,1)).^2+diff(calibratedXYZ(:,2)).^2)));
    
    
    %% Make Plots
    figure(1)
    %set(gcf,'position',[50 50 900 600])
    
    subplot(1,3,1)
    plot(rawX,rawY)
    axis equal
    title('Raw Data')
    axis square
    
    subplot(1,3,2)
    plot(linX,linY)
    axis equal
    title('Linearly Interpolated Data')
    axis square
    
    subplot(1,3,3)
    plot(calibratedXYZ(:,1),calibratedXYZ(:,2))
    axis equal
    title('Calibrated Data')
    axis square
    
    
    %% Write Output
    if saveME
        subName = subFolder(find(subFolder=='/',1,'last')+1:end);
        save(['CalibratedEyetrackingData/' subName '_CalibratedData_Run_' num2str(runNumber)],'calibratedXYZ','isBlink');
        
        if ~isdir(['Plots/' subName])
            mkdir(['Plots/' subName]);
        end
        
        outP = ['Plots/' subName '/Eyetracking_Descriptives_Run_' num2str(runNumber)];
        drawnow;
        print(outP,'-dtiff','-r300')
        close all
        drawnow;
        
    end
end
end

%% Linearly interpolate tracking gaps caused by blinking
function [linX linY] = linterpBlinkGaps(x,y,isB)
linX = x;
linY = y;

oldIsB = isB;
while any(isB)
    
    % Get first unlinterped blink
    startBlink = find(isB,1,'first');
    if startBlink == length(isB)
        finishBlink = 0;
    else
        finishBlink =  find(~isB(startBlink+1:end),1,'first')-1;
        if isempty(finishBlink)
            finishBlink = length(isB(startBlink+1:end));
        end
    end
    
    linInds = startBlink:startBlink+finishBlink;
    
    
    % Interpolation values (edge cases if blinks are at the beginning
    % or end dealt with by just setting all to the neighboring value)
    %% Dumb edge case stuff
    try
        xIn1 = x(linInds(1)-1);
    catch
        xIn1 = nan;
    end
    
    try
        xIn2 = x(linInds(end)+1);
    catch
        xIn2 = nan;
    end
    
    try
        yIn1 = y(linInds(1)-1);
    catch
        yIn1 = nan;
    end
    
    try
        yIn2 = y(linInds(end)+1);
    catch
        yIn2 = nan;
    end
    
    if isnan(xIn1)
        xIn1 = xIn2;
    end
    
    if isnan(xIn2)
        xIn2 = xIn1;
    end
    
    if isnan(yIn1)
        yIn1 = yIn2;
    end
    
    if isnan(yIn2)
        yIn2 = yIn1;
    end
    
    %% Interpolate
    linX(linInds) = linterp([linInds(1)-1 linInds(end)+1],[xIn1 xIn2],linInds);
    linY(linInds) = linterp([linInds(1)-1 linInds(end)+1],[yIn1 yIn2],linInds);
    
    % Remove the interpolated blink
    isB(linInds) = false;
end
end