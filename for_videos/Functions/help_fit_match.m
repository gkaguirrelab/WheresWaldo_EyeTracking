function [distance path transform matched] = help_fit_match(oldX,oldY,pupil_X,pupil_Y,frameInds,isBlink,shift)
    
    shift = round(shift);

    badInds = find(frameInds==1,1,'first')-1;
    frameInds = frameInds+shift;
    
    oldX(isBlink) = nan;
    oldY(isBlink) = nan;

    oldX(1:badInds) = nan;
    oldY(1:badInds) = nan;

    matched = [[oldX(frameInds<length(pupil_X)&frameInds>0),oldY(frameInds<length(pupil_X)&frameInds>0)],...
        [pupil_X(frameInds((frameInds<length(pupil_X)&frameInds>0))),...
        pupil_Y(frameInds((frameInds<length(pupil_X)&frameInds>0)))]];
    matched(any(isnan(matched),2),:) = [];

    [distance path transform] = procrustes(matched(:,[1 2]), matched(:,[3 4]),'reflection',false);
%     [distance path transform] = help_crust(matched(:,[1 2]), matched(:,[3 4]));%,'reflection',false);
end

function [d p t] = help_crust(a,b)
    [t] = fminsearch(@(v)help_dist(a,b,v),[1 1 0 0]);
    [d p] = help_dist(a,b,t);
end

function [d b] = help_dist(a,b,v)
    b = [b(:,1).*v(1)+v(3) b(:,2).*v(2)+v(4)];
    d = mean(sqrt(sum((a-b).^2,2)),1);
end