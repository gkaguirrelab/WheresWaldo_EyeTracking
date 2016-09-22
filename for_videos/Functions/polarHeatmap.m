function polarHeatmap(theta,rho,thetaBin,rhoBin)
    binnedTheta = max(cumsum(bsxfun(@gt,theta,thetaBin)'));
    binnedRho = max(cumsum(bsxfun(@gt,rho,rhoBin)'));

    count = nan(length(thetaBin),length(rhoBin));
    for i = 1:length(count(:,1))
        for j = 1:length(count(1,:))
            count(i,j) = sum(binnedTheta==i & binnedRho == j);
        end
    end
    
    for i = 1:length(thetaBin)-1
        for j = 1:length(rhoBin)-1
            
            patch([cos(thetaBin(i)).*rhoBin(j) cos(thetaBin(i+1)).*rhoBin(j) ...
                cos(thetaBin(i+1)).*rhoBin(j+1) cos(thetaBin(i)).*rhoBin(j+1)],...
                [sin(thetaBin(i)).*rhoBin(j) sin(thetaBin(i+1)).*rhoBin(j) ...
                sin(thetaBin(i+1)).*rhoBin(j+1) sin(thetaBin(i)).*rhoBin(j+1)],count(i,j),'linestyle','none');
        end
    end
    caxis([0 max(caxis)]);
    axis equal
    axis off
end