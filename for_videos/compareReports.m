function compareReports(subnum,run)

    %%%%% The video seems to start 6 frames after the first T. Because of
    %%%%% this we align by fitting the procrustes to overlapping tracking
    %%%%% data, add 6 frames of NaNs to the aligned tracking, and then
    %%%%% shift the Ts appropriately

%     root = ['/Volumes/My Passport for Mac/WALDO_BACKUP_EYETRACKING/DATA/S' num2str(subnum) '/GazeData'];

    root = ['Data/S' num2str(subnum) '/GazeData'];

    dat = [root '/S' num2str(subnum) '_Run' num2str(run) '_report.mat'];

    if ~(exist(dat)==2)
        return
    end
    
    oldReport = load(dat);
    
    dat = [root '/S' num2str(subnum) '_Run' num2str(run) '_report_fromVideo.mat'];
    
    if ~(exist(dat)==2)
        return
    end
    
    newReport = load(dat);
    
    % Fit Pupil Stuff
    
    oldX = cat(1,oldReport.Report.PupilCameraX_Ch01);
    oldY = cat(1,oldReport.Report.PupilCameraY_Ch01);
    frameInds = cat(1,oldReport.Report.frameCount);
    
    while ~isempty(find(diff(frameInds(find(frameInds==1,1,'first'):end))<1))
        start = find(diff(frameInds(find(frameInds==1,1,'first'):end))<1,1,'first');
        stop = find(diff(frameInds(start+find(frameInds==1,1,'first'):end))<1,1,'first');
        if isempty(stop)
            stop = length(frameInds)-start-find(frameInds==1,1,'first')+1;
        end
        frameInds(start+find(frameInds==1,1,'first'):start+find(frameInds==1,1,'first')+stop-1) = ...
            frameInds(start+find(frameInds==1,1,'first'):start+find(frameInds==1,1,'first')+stop-1) + ...
            frameInds(start+find(frameInds==1,1,'first')-1)+30;
    end
    
    isBlink = (~cat(1,oldReport.Report.PupilTracked_Ch01))|oldX==0|oldY==0;

    allVals = [];
    for i = -5000:100:1000
        [a b] = fminsearch(@(shift)help_fit_match(oldX,oldY,newReport.Report.PupilCameraX_Ch01,...
            newReport.Report.PupilCameraY_Ch01,frameInds,isBlink,shift),i);
        allVals = [allVals; a b];
    end
    [a b] = min(allVals(:,2));
    BestShift = round(allVals(b,1));

    [distance path transformation matched] = help_fit_match(oldX,oldY,newReport.Report.PupilCameraX_Ch01,...
        newReport.Report.PupilCameraY_Ch01,frameInds,isBlink,round(BestShift));

    figure(1)
    set(gcf,'position',[50 50 500 500])
    
    %close all
    drawnow;
    
    alignedReport = newReport;
    tmp = [newReport.Report.PupilCameraX_Ch01 ...
        newReport.Report.PupilCameraY_Ch01];
%     tmp = [b(:,1).*transformation(1)+transformation(3) b(:,2).*transformation(2)+transformation(4)];
    tmp = bsxfun(@plus,transformation.b*tmp*transformation.T,transformation.c(1,:));
        
%     plot(tmp(:,1),tmp(:,2),'color','k')
    hold on
%     plot([matched(:,1) path(:,1)]',[matched(:,2) path(:,2)]','color','k','marker','o',...
%         'markersize',2,'markerfacecolor','w')

    plot([matched(:,1)]',[matched(:,2)]','color','b','marker','o',...
        'markersize',3,'markerfacecolor','b','linestyle','none')

    plot([path(:,1)]',[path(:,2)]','color','r','marker','o',...
        'markersize',3,'markerfacecolor','r','linestyle','none')
    axis equal
    
    
    drawnow;
    outP = [root '/S' num2str(subnum) '_Run' num2str(run) '_ReportAlignment_Pupil'];
    print(gcf,outP,'-dtiff')
    
    alignedReport.Report.PupilCameraX_Ch01 = tmp(:,1);
    alignedReport.Report.PupilCameraY_Ch01 = tmp(:,2);
    
    close all
    drawnow
    
    % Fit Glint Stuff
    oldX = cat(1,oldReport.Report.Glint1CameraX_Ch01);
    oldY = cat(1,oldReport.Report.Glint1CameraY_Ch01);
    frameInds = cat(1,oldReport.Report.frameCount);
    
    while ~isempty(find(diff(frameInds(find(frameInds==1,1,'first'):end))<1))
        start = find(diff(frameInds(find(frameInds==1,1,'first'):end))<1,1,'first');
        stop = find(diff(frameInds(start+find(frameInds==1,1,'first'):end))<1,1,'first');
        if isempty(stop)
            stop = length(frameInds)-start-find(frameInds==1,1,'first')+1;
        end
        frameInds(start+find(frameInds==1,1,'first'):start+find(frameInds==1,1,'first')+stop-1) = ...
            frameInds(start+find(frameInds==1,1,'first'):start+find(frameInds==1,1,'first')+stop-1) + ...
            frameInds(start+find(frameInds==1,1,'first')-1)+30;
    end
    
    isBlink = (~cat(1,oldReport.Report.PupilTracked_Ch01))|oldX==0|oldY==0;

%     allVals = [];
%     for i = -3000:50:3000
%         [a b] = fminsearch(@(shift)help_fit_match(oldX,oldY,newReport.Report.GlintCameraX_Ch01,...
%             newReport.Report.GlintCameraY_Ch01,frameInds,isBlink,shift),i);
%         allVals = [allVals; a b];
%     end
%     [a b] = min(allVals(:,2));
%     BestShift = round(allVals(b,1));

%     [distance path transformation matched] = help_fit_match(oldX,oldY,newReport.Report.GlintCameraX_Ch01,...
%         newReport.Report.GlintCameraY_Ch01,frameInds,isBlink,BestShift);

    
    figure(1)
    set(gcf,'position',[50 50 500 500])
    
    tmp = [newReport.Report.GlintCameraX_Ch01 ...
        newReport.Report.GlintCameraY_Ch01];
%     tmp = [b(:,1).*transformation(1)+transformation(3) b(:,2).*transformation(2)+transformation(4)];
    tmp = bsxfun(@plus,transformation.b*tmp*transformation.T,transformation.c(1,:));
        
%     scatter(tmp(:,1),tmp(:,2),3,'b')
    hold on
    plot([matched(:,1) path(:,1)]',[matched(:,2) path(:,2)]','color','k','marker','o',...
        'markersize',2,'markerfacecolor','w')
    plot([path(:,1)]',[path(:,2)]','color','r','marker','o',...
        'markersize',3,'markerfacecolor','r','linestyle','none')
    axis equal
    
    
    drawnow;
    outP = [root '/S' num2str(subnum) '_Run' num2str(run) '_ReportAlignment_Glint'];
    print(gcf,outP,'-dtiff')
    close all
    drawnow
    
    alignedReport.Report.GlintCameraX_Ch01 = tmp(:,1);
    alignedReport.Report.GlintCameraY_Ch01 = tmp(:,2);
    
    
    % Align T's
    
    oldTs = cat(1,oldReport.Report.Digital_IO1);
    firstTCorrection = frameInds(find(oldTs,1,'first'))+BestShift;
    
    % interpolation
    
    
    newTs = zeros(length(tmp(:,1))-firstTCorrection,1);
    
    newTs(frameInds(logical(oldTs))+BestShift-firstTCorrection+1)= 1;
    
    while sum(oldTs)>0
    
        start = find(oldTs,1,'first');
        stop = find(oldTs(start+1:end)==1,1,'first');        
        if stop == 0
            oldTs(start) = 0;
            continue
        end
        
        if stop == 1
            oldTs(start+stop) = 0;
            continue
        end
        
        startInd = frameInds(start)+BestShift-firstTCorrection+1;
        
        if isempty(stop)
            stopInd = startInd + (floor((length(newTs)-startInd)./30)*30);
        else
            stopInd = frameInds(start+stop)+BestShift-firstTCorrection+1;
        end
        insertTs = round((stopInd-startInd)./30);
        insertTInds =round(startInd:(stopInd-startInd)./insertTs:stopInd);
        newTs(insertTInds) = 1;
        
        oldTs(start) = 0;
        
%         plot(newTs)
%         drawnow
    end
    newTs(cumsum(newTs)>380) = 0;
%     a = find(newTs,381,'first');
%     newTs(a(end):end) = 0;
    sum(newTs)
    
%     while sum(newTs)<380
%         insert = find(newTs==1,1,'last')+30;
%         newTs(insert) = 1;
%     end
%     

    % Shift for first T
    alignedReport.Report.GlintCameraX_Ch01 = [nan(-firstTCorrection,1); alignedReport.Report.GlintCameraX_Ch01];
    alignedReport.Report.GlintCameraY_Ch01 = [nan(-firstTCorrection,1); alignedReport.Report.GlintCameraY_Ch01];
    alignedReport.Report.PupilCameraX_Ch01 = [nan(-firstTCorrection,1); alignedReport.Report.PupilCameraX_Ch01];
    alignedReport.Report.PupilCameraY_Ch01 = [nan(-firstTCorrection,1); alignedReport.Report.PupilCameraY_Ch01];
    alignedReport.Report.Digital_IO1 = newTs;
    
    dat = [root '/S' num2str(subnum) '_Run' num2str(run) '_report_Aligned.mat'];
    save(dat,'alignedReport');
end