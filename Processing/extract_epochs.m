function extract_epochs(varargin)
    % Create an instance of the inputParser class
    p = inputParser;
    
    % Define the mandatory argument
    addRequired(p, 'ppnum', @ischar);
    addRequired(p, 'epochNamesPairs', @iscell);
    addRequired(p, 'dataPath', @ischar);
    addRequired(p, 'id_str', @ischar);
    addRequired(p, 'epoch_wintime', @isnumeric);
    addRequired(p, 'epoch_rmbaseline', @isnumeric);

    %Optional arguments
    addParameter(p, 'do_dipolefit', false, @islogical);
    addParameter(p,'rerunAMICA', false, @islogical)
    addParameter(p,'rerunInfoMaxICA', false, @islogical)

    % Parse the input arguments
    parse(p, varargin{:});

    % Access the parsed values
    type_of_pp = p.Results.ppnum;
    dataPath = p.Results.dataPath;
    sub_id = p.Results.id_str;
    epochNamesPairs = p.Results.epochNamesPairs;
    epoch_wintime = p.Results.epoch_wintime;
    epoch_rmbaseline = p.Results.epoch_rmbaseline;

    do_dipolefit = p.Results.do_dipolefit;
    rerunAMICA = p.Results.rerunAMICA;
    rerunInfoMaxICA = p.Results.rerunInfoMaxICA;

    EEG = pop_loadset('filename',[sub_id, '_E_' , type_of_pp , '.set'],'filepath',fullfile(dataPath,sub_id, type_of_pp));

    for idx = 1:length(epochNamesPairs)
        
        try
            rmdir(fullfile(dataPath, sub_id, type_of_pp, epochNamesPairs{idx,2}), 's')
        catch
        end
        mkdir(fullfile(dataPath, sub_id, type_of_pp, epochNamesPairs{idx,2}))

        EEGt = pop_epoch( EEG,epochNamesPairs{idx,1}, ...
            epoch_wintime,  'epochinfo', 'yes');
        EEGt = pop_rmbase( EEGt, epoch_rmbaseline ,[]);
        
        if rerunAMICA
            outdir = fullfile(dataPath, sub_id, type_of_pp, epochNamesPairs{idx,2}, 'amicaouttmp');

            [weights,sphere,mods] = runamica15(EEGt.data, 'outdir',outdir);
            EEGt.etc.amicaResultStructure = mods;
            EEGt.icaweights = weights;
            EEGt.icasphere  = sphere;
            
            EEGt = iclabel(EEGt);
            EEGt = pop_icflag(EEGt, [NaN NaN;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1]);
            %EEGt = pop_subcomp(EEGt,find(EEGt.reject.gcompreject), 0,0);
        end

        if rerunInfoMaxICA
            EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, ...
            'lrate', 1e-5, 'maxsteps', 2000,'interrupt','off'); % 1300th iterations to converge.
            EEGt = iclabel(EEGt);
            EEGt = pop_icflag(EEGt, [NaN NaN;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1]);
        end

        if do_dipolefit
            EEGt = pop_dipfit_settings( EEGt, 'hdmfile', ...
                'D:\\NYNGroup\\eeglab2023.1\\plugins\\dipfit\\standard_BEM\\standard_vol.mat',...
                'mrifile','D:\\NYNGroup\\eeglab2023.1\\plugins\\dipfit\\standard_BEM\\standard_mri.mat',...
                'chanfile','D:\\NYNGroup\\eeglab2023.1\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc',...
                'coordformat','MNI','coord_transform','warpfiducials');
            EEGt = pop_multifit(EEGt, [] ,'threshold',10);
        end

        EEGt.setname = [sub_id, epochNamesPairs{idx,3}];
        pop_saveset(EEGt, 'filename', fullfile(dataPath, sub_id, type_of_pp, epochNamesPairs{idx,2},[EEGt.setname, '.set']));
    end
end
