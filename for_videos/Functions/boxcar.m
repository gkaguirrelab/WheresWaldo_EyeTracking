function newV = boxcar(v,n)
    isVert = false;
    if size(v,2) == 1
        isVert = true;
        v = v'; 
    end
    
    newV = zeros(size(v));
    for i = 1:length(v)
        newV(:,i) = nanmean(v(:,max(i-round(n./2),1):min(i+round(n./2),length(v))),2);
    end
    
    if isVert
        newV = newV';
    end
end