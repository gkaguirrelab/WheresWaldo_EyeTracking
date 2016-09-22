function calibrateAndSmooth(subNum,run,calRun)
    
    load(['Data/S' num2str(subNum) '/GazeData/S' num2str(subNum) '_Run' num2str(run) '_report_Aligned']);
    
    load(['Data/S' num2str(subNum) '/Calibration/LTcal_S' num2str(subNum) '_Run' num2str(calRun)'])
    
    smth = 0;
    linX = boxcar(alignedReport.Report.PupilCameraX_Ch01,smth);
    linY = boxcar(alignedReport.Report.PupilCameraY_Ch01,smth);
    linGlintX = boxcar(alignedReport.Report.GlintCameraX_Ch01,smth);
    linGlintY = boxcar(alignedReport.Report.GlintCameraY_Ch01,smth);
    
    tmp = CalMat*[([linX-linGlintX]./Rpc)'; ([linY-linGlintY]./Rpc)'; ...
        (1-sqrt(([linX-linGlintX]./Rpc).^2 + ([linY-linGlintY]./Rpc).^2))'; ones(1,length(linX))];
    calibratedXYZ = [bsxfun(@rdivide,tmp(1:3,:),tmp(4,:))]';
    
    calibratedXYZ(any(diff(calibratedXYZ(:,[1 2]))>500,2),:) = nan;
    
    smth = 11;
    calibratedXYZ(:,1) = boxcar(calibratedXYZ(:,1),smth);
    calibratedXYZ(:,2) = boxcar(calibratedXYZ(:,2),smth);
    
    rawX = calibratedXYZ(:,1);
    rawY = calibratedXYZ(:,2);
    [movementAngle b] = cart2pol(diff(calibratedXYZ(:,1)),diff(calibratedXYZ(:,2)));
    movementSpeed = (sqrt((diff(calibratedXYZ(:,1)).^2+diff(calibratedXYZ(:,2)).^2)));
    thresh =  nanmedian(movementSpeed);
    
    movementAngle(movementSpeed<thresh) = nan;
    
    
    
    hasAngle = false;
    anglePath = ['Data/S' num2str(subNum) '/rEC_gridAng.mat'];
    if exist(anglePath)==2
        hasAngle = true;
        grid = load(anglePath);
    end
    
    
    t = find(alignedReport.Report.Digital_IO1)';
    
    reg4 = nan(length(t),2);
    gridAlignedReg4 = reg4;
    
    reg6 = nan(length(t),2);
    gridAlignedReg6 = reg6;
    for i = 1:length(t)
        try
            seg = [t(i):t(i+1)-1];
        catch
            seg = [t(i):min(t(i)+30-1,length(movementAngle))];
        end
        reg6(i,:) = [nansum(sin(6*movementAngle(seg))) ...
            nansum(cos(6*movementAngle(seg)))];
        
        reg4(i,:) = [nansum(sin(4*movementAngle(seg))) ...
            nansum(cos(4*movementAngle(seg)))];
        
        if hasAngle
            gridAlignedReg6(i,:) = [nansum(sin(6*(movementAngle(seg)-grid.grid_angle))) ...
                nansum(cos(6*(movementAngle(seg)-grid.grid_angle)))];
            
            gridAlignedReg4(i,:) = [nansum(sin(4*(movementAngle(seg)-grid.grid_angle))) ...
                nansum(cos(4*(movementAngle(seg)-grid.grid_angle)))];
        end
    end
    
    reg6 = bsxfun(@rdivide,bsxfun(@minus,reg6,nanmean(reg6)),nanstd(reg6));
    reg4 = bsxfun(@rdivide,bsxfun(@minus,reg4,nanmean(reg4)),nanstd(reg4));
    if hasAngle
        gridAlignedReg6 = bsxfun(@rdivide,bsxfun(@minus,gridAlignedReg6,nanmean(gridAlignedReg6)),nanstd(gridAlignedReg6));
        gridAlignedReg4 = bsxfun(@rdivide,bsxfun(@minus,gridAlignedReg4,nanmean(gridAlignedReg4)),nanstd(gridAlignedReg6));
    end
    
    if ~isdir(['Regressors/6Fold/WithoutGridAngle/S' num2str(subNum)])
        mkdir(['Regressors/6Fold/WithoutGridAngle/S' num2str(subNum)])
    end
    
    if ~isdir(['Regressors/4Fold/WithoutGridAngle/S' num2str(subNum)])
        mkdir(['Regressors/4Fold/WithoutGridAngle/S' num2str(subNum)])
    end
    
    outP = ['Regressors/6Fold/WithoutGridAngle/S' num2str(subNum) '/S' num2str(subNum) '_Run' num2str(run) '_sin.txt'];
    fileID = fopen(outP,'w');
    fprintf(fileID,'%f\n',reg6(:,1));
    fclose(fileID);
    
    outP = ['Regressors/6Fold/WithoutGridAngle/S' num2str(subNum) '/S' num2str(subNum) '_Run' num2str(run) '_cos.txt'];
    fileID = fopen(outP,'w');
    fprintf(fileID,'%f\n',reg6(:,2));
    fclose(fileID);
    
    outP = ['Regressors/4Fold/WithoutGridAngle/S' num2str(subNum) '/S' num2str(subNum) '_Run' num2str(run) '_sin.txt'];
    fileID = fopen(outP,'w');
    fprintf(fileID,'%f\n',reg4(:,1));
    fclose(fileID);
    
    outP = ['Regressors/4Fold/WithoutGridAngle/S' num2str(subNum) '/S' num2str(subNum) '_Run' num2str(run) '_cos.txt'];
    fileID = fopen(outP,'w');
    fprintf(fileID,'%f\n',reg4(:,2));
    fclose(fileID);
    
    if hasAngle
        
        if ~isdir(['Regressors/4Fold/WithGridAngle/S' num2str(subNum)])
            mkdir(['Regressors/4Fold/WithGridAngle/S' num2str(subNum)])
        end
        if ~isdir(['Regressors/6Fold/WithGridAngle/S' num2str(subNum)])
            mkdir(['Regressors/6Fold/WithGridAngle/S' num2str(subNum)])
        end
        
        outP = ['Regressors/6Fold/WithGridAngle/S' num2str(subNum) '/S' num2str(subNum) '_Run' num2str(run) '_sin.txt'];
        fileID = fopen(outP,'w');
        fprintf(fileID,'%f\n',gridAlignedReg6(:,1));
        fclose(fileID);

        outP = ['Regressors/6Fold/WithGridAngle/S' num2str(subNum) '/S' num2str(subNum) '_Run' num2str(run) '_cos.txt'];
        fileID = fopen(outP,'w');
        fprintf(fileID,'%f\n',gridAlignedReg6(:,2));
        fclose(fileID);
        
        outP = ['Regressors/4Fold/WithGridAngle/S' num2str(subNum) '/S' num2str(subNum) '_Run' num2str(run) '_sin.txt'];
        fileID = fopen(outP,'w');
        fprintf(fileID,'%f\n',gridAlignedReg4(:,1));
        fclose(fileID);

        outP = ['Regressors/4Fold/WithGridAngle/S' num2str(subNum) '/S' num2str(subNum) '_Run' num2str(run) '_cos.txt'];
        fileID = fopen(outP,'w');
        fprintf(fileID,'%f\n',gridAlignedReg4(:,2));
        fclose(fileID);
    end
        
    figure(1)
    set(gcf,'position',[50 50 600 300])
    plot(reg6,'color','r')
    hold on
    
    figure(1)
    set(gcf,'position',[50 50 1800 1200].*0.6)

    subplot(2,3,1)
    plot(rawX,rawY)
    axis equal
    title('Raw Data')

    subplot(2,3,2)
    plot(linX,linY)
    axis equal
    title('Linearly Interpolated Data')

    subplot(2,3,3)
    plot(calibratedXYZ(:,1),calibratedXYZ(:,2))
    hold on
    plot(calibratedXYZ([false; movementSpeed<thresh],1),calibratedXYZ([false; movementSpeed<thresh],2),...
        'color','r','linestyle','none','marker','o','markerfacecolor','r','markersize',2)
    axis equal
    title('Calibrated Data')
    
    subplot(2,3,4)
    hist(movementSpeed,[0:0.5:20])
    hold on
    plot([thresh thresh],get(gca,'ylim'),'color','r','linestyle',':','linewidth',2)
    set(gca,'xlim',[-1 20])

%     subplot(2,3,4)
%     polarHeatmap(movementAngle,movementSpeed,[0:pi.*2./24:pi*2]-pi,[0 10000]);
%     title('Movement Angle');
%     colorbar

    subplot(2,3,5)
    polarHeatmap(movementAngle,movementSpeed,[0:pi.*2./24:pi*2]-pi,0:0.5:20);
    title('Movement Angle x Speed');
%     colorbar

    subplot(2,3,6)
    plot(calibratedXYZ(:,1),'color','b');
    hold on
%     plot(calibratedXYZ(:,2),'color','b');
    plot(find([false; movementSpeed<thresh]),calibratedXYZ([false; movementSpeed<thresh],1),...
        'color','r','linestyle','none','marker','o','markerfacecolor','r','markersize',3)
%     plot(find([false; movementSpeed<thresh]),calibratedXYZ([false; movementSpeed<thresh],2),...
%         'color','r','linestyle','none','marker','o','markerfacecolor','r','markersize',2)
    title('Calibrated Data')
    
    if ~isdir(['Plots/S' num2str(subNum)])
        mkdir(['Plots/S' num2str(subNum)]);
    end
    
    outP = ['Plots/S' num2str(subNum) '/Run' num2str(run) '_FinalTrackingData'];
    print(gcf,outP,'-dtiff')
    
    close all
    drawnow;
end