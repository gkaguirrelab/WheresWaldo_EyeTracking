function [Report] = Collect(subnum, runnum, overwrite)
% This function calls a standard driver to do pupil tracking during fMRI
% scans for Waldo. It will also record an MPEG-4 video
% and produce a MAT report with raw tracking values of the pupil, as well as RAW video using 
% a USB video capture device that has the IR-camera stream fed as a RCA input, using ezcap
% VideoCapture tool (for mac).

% If TTLtrigger=true, the report
% collection is initialized by the user. The video recording is triggered
% by the first TR via a TTL input. Every TTL is recorded in the report
% file. Video and data collection will end 2 seconds later than the
% recording time set by the user.
%
% If GetRawVideo = true, the routine will also save a raw video via ezCap
% videoGrabber (must be installed and open).
%
% The recording will last recTime in seconds. Result files will be saved in
% savepath. It's possible to interrupt the recording prematurely pressing
% OK on the STOP NOW window. All data will be saved as they are at the
% moment the recording was aborted.


% Usage:
% subnum - subject number, scalar
% runnum - run number, scalar
% overwrite - 0 or 1. if re-running a particlar run calibration, but want to overwrite, set to 1. Otherwise can leave empty
%             (automatically set to 0)
%
% HOW TO USE:
% At the beginning of the session:
% - make sure that the LiveTrack focusing screw has enough grip on the
% thread. Scanner vibrations could unscrew the lens causing a loss of
% focus.
% - position the LiveTrack on the head mount.
% - focus the lens on the subject pupil.
% - verify the tracking on the preview window.
% - after calibration, run this function.
%


addpath(genpath('/Users/EpsteinLab/Documents/Users/Josh/LiveTrackfMRIToolbox-master'));

if nargin < 3
    overwrite = 0; 
end

%% inputs
% set savepath
TTLtrigger= true;
GetRawVideo= false;
recTime= 390; %N.B. - recording ends 2 seconds after recTIME!
savePath = ['/Users/EpsteinLab/Documents/Experiments/Joshua/WALDO/DATA/S' num2str(subnum) '/GazeData/'] ;
filename = ['S' num2str(subnum) '_Run' num2str(runnum)]; %filename

%make data directory
if ~exist(savePath,'dir'); mkdir(savePath); end

%check if data with this file name already exists
if exist([savePath 'LiveTrackREPORT_' filename '.mat'],'file');
    if ~overwrite
        fprintf('\nFilename already exists!\n Appending timestamp.\n')
        formatOut = 'mmddyy_HHMMSS';
        filename = ['S' num2str(subnum) '_Run' num2str(runnum) datestr(clock,formatOut)]; %filename
    else
        fprintf('\nWarning: Filename already exists!\n Overwrite selected.\n')
    end
end


[Report] = LiveTrack_GetReportVideo(TTLtrigger,GetRawVideo,recTime,savePath,filename);


end

