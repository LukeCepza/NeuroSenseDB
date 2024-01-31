function StudyInfo = getStudyInfo(dataPath,tstimul,type_of_pp) 
% This function returns a cell of folders containing the .set data for
% given condition
    cells = cell(1,35);
    idx = 0;
    for id = 1:34
        sub_id = sprintf('sub-%02d', id);
        file = fullfile(dataPath,sub_id , type_of_pp, tstimul,  ...
            [sub_id, '_' ,type_of_pp, '_e',tstimul,'.set']);
        if exist(file, 'file') == 2 
            idx = idx + 1;
            cells{idx} = {'index',idx,'load',file,'subject',sub_id,...
                'condition',tstimul,'session',1,'group','1'};
            disp("attaching to list " + sub_id);
        else
            disp("Skipping " + file + " - file does not exist.");
        end
    end
    StudyInfo = cells(~cellfun('isempty', cells));%%
end