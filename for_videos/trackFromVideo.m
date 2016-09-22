function trackFromVideo(subnum,run,mkMovie)

%     root = ['/Volumes/My Passport for Mac/WALDO_BACKUP_EYETRACKING/DATA/S' num2str(subnum) '/GazeData'];

    root = ['Data/S' num2str(subnum) '/GazeData'];
    dat = [root '/S' num2str(subnum) '_Run' num2str(run) '_raw.mov'];

    if ~(exist(dat)==2)
        return
    end

    if nargin<3
        mkMovie = false;
    end

    PUPIL_THRESHOLD = 0.15;
    GLINT_THRESHOLD = 0.85;
    optimset('Display','off');


    fprintf(['\n\tTracking File:  ' dat '\tPending...\n' ])
    tic

    obj = VideoReader(dat);

    NumberOfFrames = obj.NumberOfFrames;

    pupil_X = nan(NumberOfFrames,1);
    pupil_Y = nan(NumberOfFrames,1);
    glint_X = nan(NumberOfFrames,1);
    glint_Y = nan(NumberOfFrames,1);
    pupil_error = nan(NumberOfFrames,1);

    movie(1:NumberOfFrames) = struct('cdata', [],...
        'colormap', []);

    % fprintf(num2str(NumberOfFrames)); 
    blah = [];

    fval = NumberOfFrames/obj.Duration;
    NoFinScan = fval*380;

    for fi = 1:NoFinScan

        isBlink = false;
        raw =read(obj,fi);
        if size(raw,3)==3
            raw=rgb2gray(raw);
        end
        
        if fi == 1
            
            figure(1)
            imshow(raw)
            [mask crop_y crop_x] = roipoly;
            
            close all
            drawnow
        end
        
        raw(~mask) = 125;
        
        raw = raw(floor(min(crop_x)):ceil(max(crop_x)), ...
            floor(min(crop_y)):ceil(max(crop_y)));
        
        raw = double(raw);
        raw = 255.*(raw-min(raw(:)))./(max(raw(:))-min(raw(:)));
        raw = uint8(raw);
        
        
        %             raw(1:150,:) = 155;

        %% Get Pupil Center

        segmented = ~im2bw(raw,PUPIL_THRESHOLD);
        regions = regionprops(segmented,'Area','Centroid','ConvexHull','BoundingBox');
        regions(cat(1,regions.Area)<750) = [];

        if isempty(regions) % Skip if can't find pupil
            %                 imshow(ones(size(segment)).*255);
            isBlink = true;
        else
            %                 params = nan(length(regions),4);
            %                 err = nan(length(regions),1);
            %                 for i = 1:length(regions)
            %                     [params(i,:) err(i)] = fit_ellipse(regions(i));
            %                 end
            %                 [err isGood] = min(err);
            %                 params = params(isGood,:);

            [a isPupil] = min(sum(bsxfun(@minus,cat(1,regions.Centroid),[size(raw)].*[1 0.5]).^2,2));
            %                 [a isPupil] = max(cat(1,regions.Area));
            [params err flag] = fit_ellipse(regions(isPupil));
            if flag~=1
                isBlink = true;
            end
        end

        %% Get Glint Center
        segmented = im2bw(raw,GLINT_THRESHOLD);
        regions = regionprops(segmented,'Area','Centroid','ConvexHull','BoundingBox');
        %             [a isGood] = max(cat(1,regions.Area));

        if isempty(regions) || isBlink % Skip if can't find pupil
            %                 imshow(ones(size(segment)).*255);
            isBlink = true;
        else
            [a isGood] = min(sqrt(sum(bsxfun(@minus,cat(1,regions.Centroid),[params(1:2)]).^2,2)));
            if a>=50
                isBlink = true;
            end
        end

        if ~isBlink
            glint_X(fi) = regions(isGood).Centroid(1);
            glint_Y(fi) = regions(isGood).Centroid(2);
            pupil_X(fi) = params(1);
            pupil_Y(fi) = params(2);
            pupil_error(fi) = err;
        end

%         %% Plot
%         if fi>150 && mod(fi,30)==0
%             figure(2)
%             set(gcf,'position',[850 50 600 1000])
%             subplot(5,2,1:4)
%             imshow(raw)
%             hold on
%             plot(regions(length(regions)).ConvexHull(:,1),regions(length(regions)).ConvexHull(:,2))
%             rectangle('Position',[params(1:2)-params(3:4) params(3:4)*2],'Curvature',[1 1])
%             plot(pupil_X(fi),pupil_Y(fi),'marker','+','color','r')
%             plot(glint_X(fi),glint_Y(fi),'marker','+','color','g')
%             axis equal
%             hold off
% 
%             plotInd = find(~isnan(pupil_error),1,'last');
%             plotInd = plotInd-149:plotInd;
% 
%             subplot(5,2,5)
%             plot(pupil_error(plotInd),'linestyle','none','color','r','marker','o','markerfacecolor','r','markersize',5)
%             set(gca,'xticklabel',str2num(get(gca,'xticklabel')).*(1./29.97))
% 
%             subplot(5,2,7)
%             plot(pupil_X(plotInd),'linestyle','none','marker','o','markerfacecolor','r','markersize',5)
% 
%             subplot(5,2,9)
%             plot(pupil_Y(plotInd),'linestyle','none','marker','o','markerfacecolor','g','markersize',5)
%     %         set(gca,'xticklabel',str2num(get(gca,'xticklabel')).*(1./29.97))
% 
%             subplot(5,2,8)
%             plot(glint_X(plotInd),'linestyle','none','marker','o','markerfacecolor','r','markersize',5)
% 
%             subplot(5,2,10)
%             plot(glint_Y(plotInd),'linestyle','none','marker','o','markerfacecolor','g','markersize',5)
%             drawnow;
%         end

        if mkMovie & mod(fi,15)==1
            
            figure(1);
            set(gcf,'position',[1000 500 450 300])
            imshow(raw)
            hold on
            %             plot(regions(length(regions)).ConvexHull(:,1),regions(length(regions)).ConvexHull(:,2),'color','b')
            if ~isBlink
                rectangle('Position',[params(1:2)-params(3:4) params(3:4)*2],'Curvature',[1 1])
                plot(pupil_X(fi),pupil_Y(fi),'marker','+','color','r')
                plot(glint_X(fi),glint_Y(fi),'marker','+','color','b')
            else
                text(size(raw(:,:,1),1)./2,size(raw(:,:,1),2)./1.5,'TRACKING LOST',...
                    'fontname','arial','fontweight','bold','fontsize',30,'color','r')
            end
            axis equal
            hold off
            drawnow

            movie(fi) = getframe(gcf);
        end
    end

    toc

    reportDir = [root];
    if ~exist(reportDir,'dir')
        mkdir(reportDir);
    end
    reportName = ['S' num2str(subnum) '_Run' num2str(run) '_report_fromVideo.mat'];
    Report.PupilCameraX_Ch01 = pupil_X;
    Report.PupilCameraY_Ch01 = pupil_Y;
    Report.GlintCameraX_Ch01 = glint_X;
    Report.GlintCameraY_Ch01 = glint_Y;
    Report.PupilTracked_Ch01 = isnan(pupil_X);
    save([reportDir '/' reportName],'Report');

    if mkMovie
        tmp = movie(1:15:end);
        
        outP = [dat(1:end-4) '_offlineTracking'];
        myVideo = VideoWriter(outP);
        uncompressedVideo = VideoWriter(outP, 'Uncompressed AVI');
        myVideo.FrameRate = 15;  % Default 30
        myVideo.Quality = 100;    % Default 75
        open(myVideo);
        writeVideo(myVideo, tmp(1:380*2));
        close(myVideo);
    end
    close all
    drawnow

%     oldTracking = load(['Data/S11/GazeData/S11_Run1_report.mat']);
% 
%     oldX = cat(1,oldTracking.Report.PupilCameraX_Ch01);
%     oldY = cat(1,oldTracking.Report.PupilCameraY_Ch01);
%     frameInds = cat(1,oldTracking.Report.frameCount);
%     isBlink = (~cat(1,oldTracking.Report.PupilTracked_Ch01))|oldX==0|oldY==0;
% 
%     allVals = [];
%     for i = -1000:50:1000
%         [a b] = fminsearch(@(shift)help_fit_match(oldX,oldY,pupil_X,pupil_Y,frameInds,isBlink,shift),i);
%         allVals = [allVals; a b];
%     end
%     [a b] = min(allVals(:,2));
%     BestShift = round(allVals(b,1));
% 
%     [distance path transformation matched] = help_fit_match(oldX,oldY,pupil_X,pupil_Y,frameInds,isBlink,round(BestShift));
% 
%     figure(1)
%     set(gcf,'position',[50 50 500 500])
%     plot([matched(:,1) path(:,1)]',[matched(:,2) path(:,2)]','color','k','marker','o',...
%         'markersize',2,'markerfacecolor','w')
%     hold on
%     plot([path(:,1)]',[path(:,2)]','color','r','marker','o',...
%         'markersize',3,'markerfacecolor','r','linestyle','none')
%     axis equal
%     hold off
%     drawnow
end
















































































