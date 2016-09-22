function [params err flag] = fit_ellipse(region)
    hull = region.ConvexHull;
    el = [mean(hull) max((max(hull)-min(hull))./2).*ones(1,2)];
    
%     optimset
    [params err flag] = fminsearch(@(inV)gof_ellipse(hull,inV),el);
%     [params err] = fmincon(@(inV)gof_ellipse(hull,inV),el,[],[],[],[],[min(hull) el(3:4)],[max(hull) el(3:4).*3]);
end
