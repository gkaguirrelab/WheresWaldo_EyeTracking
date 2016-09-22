function regenerate_gaze

    for s=9
        for run=3
            trackFromVideo(s,run,false);
            compareReports(s,run);
        end
    end
end
