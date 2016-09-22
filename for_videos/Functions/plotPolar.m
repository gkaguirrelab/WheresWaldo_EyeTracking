function plotPolar(t,act)
    s = deg2rad(10);
    forPlot = [0:s:2*pi-s; zeros(2,length(0:s:2*pi-s))];
    for bin = forPlot(1,:)
        forPlot(2,bin==forPlot(1,:)) = mean(act(t>=bin & t<=bin+s));
        forPlot(3,bin==forPlot(1,:)) = mean(t>=bin & t<=bin+s);
    end
    forPlot(2,:) = forPlot(2,:);
    forPlot(3,:) = forPlot(3,:);
    forPlot = [forPlot forPlot(:,1)];
    plot(sin(forPlot(1,:)).*forPlot(2,:),cos(forPlot(1,:)).*forPlot(2,:),'linestyle','-','linewidth',3,'color','k')
    hold on
    plot(sin(forPlot(1,:)).*forPlot(3,:),cos(forPlot(1,:)).*forPlot(3,:),'linestyle','--','linewidth',3,'color',[0.3 0.3 0.3])
    plot([-1 1],[0 0],'linestyle',':','color',[0.3 0.3 0.3],'linewidth',2)
    plot([0 0],[-1 1],'linestyle',':','color',[0.3 0.3 0.3],'linewidth',2)
    axis square
end