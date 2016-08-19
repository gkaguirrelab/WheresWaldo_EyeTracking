function Calibration(subnum,runnum,overwrite)
% Calibration function for Waldo pupil tracking experiment
% DO NOT USE TO CALIBRATE IR CAMERA WHEN USING EYEPIECE.
%
% Before running calibration, make sure that the LiveTrack camera is
% properly set up (ref. LiveTrack fMRI user manual).
%
% Includes: setup, collect calibration data, calculate calibration matrix,
% show calibration results on a plot.
%
% Usage:
% subnum - subject number, scalar
% runnum - run number, scalar
% overwrite - 0 or 1. if re-running a particlar run calibration, but want to retain
%             old calibration, set to 0. Otherwise can leave empty
%             (automatically set to 1)
%% Input params
% Screen('Preference', 'SkipSyncTests', 1); % uncomment for testing only

addpath(genpath('/Users/EpsteinLab/Documents/Users/Josh/LiveTrackfMRIToolbox-master'));

%overwrite flag, to overwrite old output if wanted
if nargin < 3
    overwrite = 0; %don't overwrite output
end

viewDist = 600;    % distance in mm from the screen

screenSize = 32;    % Diagonal of the screen in inches

Window1ID = 0;    % ID of controller monitor (1 should be the primary monitor on Windows)

Window2ID = 1;    % ID of stimulus monitor (2 should be the secondary monitor on Windows)

savePath = ['/Users/EpsteinLab/Documents/Experiments/Joshua/WALDO/S' num2str(subnum) '/Calibration/'] ;

filename = ['S' num2str(subnum) '_Run' num2str(runnum)]; %filename

%make data directory
if ~exist(savePath,'dir'); mkdir(savePath); end

%check if data with this file name already exists
if exist([savePath 'LTdat_' filename '.mat'],'file');
    if ~overwrite
        fprintf('\nFilename already exists!\n Appending timestamp.\n')
        formatOut = 'mmddyy_HHMMSS';
        filename = ['S' num2str(subnum) '_Run' num2str(runnum) datestr(clock,formatOut)]; %filename
    else
        fprintf('\nWarning: Filename already exists!\n Overwrite selected.\n')
    end
end
    
LiveTrack_GazeCalibration(viewDist, screenSize, Window1ID, Window2ID,savePath,filename)


end