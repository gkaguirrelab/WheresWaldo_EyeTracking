function cell2csv(filename,dat)
    checkP(filename);
    if exist([filename '.xls'],'file')>0 
        delete([filename '.xls']);
    end
    if exist([filename '.csv'],'file')>0
        delete([filename '.csv']);
    end
    if exist([filename '.xlsx'],'file')>0
        delete([filename '.xlsx']);
    end
    if exist([filename],'file')>0
        delete(filename);
    end

    try
        if length(filename)>=4 && strcmp(filename(length(filename)-3:length(filename)),'.csv')
            xlswrite(filename(1:length(filename)-4),dat);
        else
            xlswrite([filename '.xls'],dat);
        end
    catch
        if length(filename)>=4 && strcmp(filename(length(filename)-3:length(filename)),'.csv')
            fid = fopen(filename,'w');
        else
            fid = fopen([filename '.csv'],'w');
        end
        for i = 1:length(dat(:,1))
            for j = 1:length(dat(1,:))
                if isnumeric(dat{i,j}) || islogical(dat{i,j})
                    fprintf(fid, [num2str(dat{i,j}) ',']);
                else
                    fprintf(fid, [dat{i,j} ',']);
                end
            end
            fprintf(fid,'\n');
        end
        fclose(fid);
    end
end