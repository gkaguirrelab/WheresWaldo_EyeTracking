function [err s] =  gof_ellipse(a,ellipse)
    s = (((a(:,1) - ellipse(1)).^2)./(ellipse(3).^2)) + ...
        (((a(:,2) - ellipse(2)).^2)./(ellipse(4).^2));
    
    err = mean(abs(1-s(s>0.25)));%+sum((mean(s>1).*1);%+abs(ellipse(3)-ellipse(4));
end