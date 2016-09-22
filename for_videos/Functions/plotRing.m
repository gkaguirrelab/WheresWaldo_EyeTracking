function plotRing(v)

    a=5;
    c=10;
    x = 0:2*pi./length(v):2*pi;
    patch([cos([x(1:end-1)' x(2:end)']).*a cos([x(2:end)' x(1:end-1)']).*c]',...
        [sin([x(1:end-1)' x(2:end)' ]).*a sin([x(2:end)' x(1:end-1)']).*c]',...
        v','linestyle','none')
    set(gca,'xlim',[-c-1 c+1],'ylim',[-c-1 c+1])
    caxis([0 max(v)]);
    axis off
    axis square
    title(num2str(max(v)))
end