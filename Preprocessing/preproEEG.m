function preproEEG(varargin)
    eeglab;

    % Create an instance of the inputParser class
    p = inputParser;

    % Define the mandatory arguments
    addRequired(p,'dataPath', @ischar);
    addRequired(p, 'pathIn', @ischar);
    addRequired(p, 'nameOut', @ischar);
    addRequired(p, 'idNum', @ischar);
    addRequired(p, 'type_of_pp', @ischar);
    addRequired(p, 'ChanLocsBesa', @ischar);

    % Define optional arguments with default values
    addParameter(p, 'PE', false, @islogical);
    addParameter(p, 'ICA_reject', true, @islogical);
    addParameter(p, 'ASR', true, @islogical);
    addParameter(p, 'Cleanline', false, @islogical); %Not implemented
    addParameter(p, 'Filt60Hz', true, @islogical);
    addParameter(p, 'Interpolate', true, @islogical);
    addParameter(p, 'GlobalRef', false, @islogical);

    % Parse the input arguments
    parse(p, varargin{:});

    % Access the parsed values
    dataPath = p.Results.dataPath;
    type_of_pp = p.Results.type_of_pp;
    pathIn = p.Results.pathIn;
    idNum = p.Results.idNum;
    ChanLocsBesa = p.Results.ChanLocsBesa;
    nameOutpp = p.Results.nameOut;
    PE = p.Results.PE;
    ICA_reject = p.Results.ICA_reject;
    do_ASR = p.Results.ASR;
    do_Cleanline = p.Results.Cleanline;
    Filt60Hz = p.Results.Filt60Hz;
    do_Interpolate = p.Results.Interpolate;
    do_GlobalRef = p.Results.GlobalRef;
    
    rng default 
    
% (1) Cargar datos .edf
    EEG = pop_biosig(pathIn);
% (2) Downsample
    EEG = pop_resample( EEG, 250);
% (3) Editar ubicacion de canales
    channels = {'Fp1';'Fp2';'F3'; 'F4';'C3';'C4';'P3'; ...
    'P4';'O1';'O2';'F7';'F8';'T7';'T8';'P7'; ...
    'P8';'Fz';'Cz';'Pz';'M1';'M2';'AFz';'CPz'; 'POz'};
    for ch = 1:24
        EEG.chanlocs(ch).labels = cell2mat(channels(ch));
    end
    EEG = pop_select( EEG, 'rmchannel',{'Gyro 1','Gyro 2','Gyro 3'});
    EEG = pop_chanedit(EEG, 'lookup',ChanLocsBesa);
% (4) Re-referenciación
    EEG = pop_reref( EEG, [20 21] ); 
    if do_GlobalRef
        EEG = pop_reref( EEG, [] ); 
    end
% (5.1) Quitar componentes baja frecuencia 
    EEG = pop_firws(EEG, 'fcutoff', 1, 'ftype', 'highpass', 'wtype', ...
        'hamming', 'forder', 3300, 'minphase', 0, 'usefftfilt', 0, ...
        'plotfresp', 0, 'causal', 0); %Transition width of 0.5 Hz
% (5.2) Quitar componentes alta frecuencia
    EEG = pop_firws(EEG, 'fcutoff', 120, 'ftype', 'lowpass', 'wtype', ...
        'hamming', 'forder', 330, 'minphase', 0, 'usefftfilt', 0, ...
        'plotfresp', 0, 'causal', 0); % Transition width of 5 Hz
% (5.3) Quitar 60 Hz
    if Filt60Hz
        EEG = pop_firws(EEG, 'fcutoff', [59 61], 'ftype', 'bandstop', 'wtype',...
            'hamming', 'forder', 3300, 'minphase', 0, 'usefftfilt', 0, ...
            'plotfresp', 0, 'causal', 0); % Transition width of 0.5 Hz
    elseif do_Cleanline
        %Not implemented to use cleanline
    end
% (6.1) Rename Epochs to perceived
 if (PE) 
    Events = {'33028' , '33029' , '33030' , '33031',...
            '33032' , '33033'  ,'33034',  '33035',...
            '33024' , '33025' , '33026' , '33027', '19999'};
    file_path = fullfile(dataPath,idNum,['R_', idNum, '.txt']);
    
    % Read the entire file as a string
    file_contents = fileread(file_path);
    filtered_string = str2num(file_contents');
    reshaped_data = reshape(filtered_string,4,[])';
    reshaped_data(~ismember(reshaped_data, [1, 2, 3, 4])) = 99;
    reshaped_data(18:37,:) = reshaped_data(18:37,:) + 4;
    reshaped_data(38:57,:) = reshaped_data(38:57,:) + 8;
    reshaped_data(reshaped_data > 15) = 13;
    PerceivedIntensity = Events(reshaped_data);
    PerceivedIntensity = str2num(cell2mat(reshape(PerceivedIntensity',[],1)));
    PerceivedIntensity = reshape(PerceivedIntensity,4,[])';
    
    idx_event = zeros(57, 4);
    for i = 1:57
        idx_event(i, :) = (i - 1) * 9 + [3, 5, 7, 9];
    end
    for i = 1:57
        EEG = pop_editeventvals(EEG,'changefield',{idx_event(i,1),'type',PerceivedIntensity(i,1)}, ...
        'changefield',{idx_event(i,2),'type',PerceivedIntensity(i,2)}, ...
        'changefield',{idx_event(i,3),'type',PerceivedIntensity(i,3)}, ...
        'changefield',{idx_event(i,4),'type',PerceivedIntensity(i,4)});
    end
 end
% (6.2) Remove occasional large-amplitude noise/artifacts
    if do_Interpolate
        chanlocs_original = EEG.chanlocs; %Necessary for interpolation
    end
    if do_ASR
        [EEG,~,~] = clean_artifacts(EEG,'ChannelCriterion',0.65);
    end
% (6.3) Interpolate  (To interpolate or not to interpolate?)
    if do_Interpolate
        EEG = pop_interp(EEG, chanlocs_original, 'spherical');  
    end
% (7) Decomposing constant fixed-source noise/artifacts/signals (ICA)
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, ...
        'lrate', 1e-5, 'maxsteps', 2000,'interrupt','off'); % 1300th iterations to converge.
% (8) Remove ICs artifacts(ICA)
    EEG = iclabel(EEG);
        EEG = pop_icflag(EEG, [NaN NaN;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1]);
    if ICA_reject
        EEG = pop_subcomp(EEG,find(EEG.reject.gcompreject), 0,0);
    end
% (9) Rename labels
    events = {EEG.event.type};
    for i = 1:length(events)
            %air
        if cell2mat(events(i)) == "OVTK_StimulationId_Label_04"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33028});
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_05"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33029});    
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_06"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33030});    
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_07"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33031});    
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_13"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33043});
            %Vib
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_08"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33032});    
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_09"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33033});    
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_0A"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33034});    
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_0B"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33035}); 
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_12"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33042}); 
            %Car
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_00"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33024});
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_01"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33025});  
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_02"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33026});    
        elseif cell2mat(events(i)) == "OVTK_StimulationId_Label_03"
            EEG = pop_editeventvals(EEG,'changefield',{i,'type',33027});    
        end
    end
% (10) Save dataset
    EEG.setname = [idNum, '_' , type_of_pp];
    pop_saveset(EEG, 'filename', nameOutpp);
end
