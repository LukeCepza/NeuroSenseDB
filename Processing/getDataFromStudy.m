function DataStruct = getDataFromStudy(StudyInfo, type_of_pp, tstimul, varargin)
% Must change the calculation of the number of clusters to be used    

% Create an instance of the inputParser class
    p = inputParser;

    % Define the mandatory argument
    addRequired(p, 'StudyInfo', @iscell);
    addRequired(p, 'type_of_pp', @ischar);
    addRequired(p, 'tstimul', @ischar);

    addParameter(p, 'ggERP', true, @islogical);
    addParameter(p, 'PSD', false, @islogical);
    addParameter(p, 'ERSP_ITPC', false, @islogical);
    addParameter(p, 'DipClus', false, @islogical);
    addParameter(p, 'savejpg', false, @islogical);
    addParameter(p, 'savemat', false, @islogical);
    %addParameter(p, 'outPath', false, @ischar);
    addParameter(p, 'fignum', false, @isnumeric);
    addParameter(p, 'saveStudy', false, @islogical);
    addParameter(p, 'recompute', true, @islogical)
    addParameter(p, 'numclust', 11, @isnumeric)
    addParameter(p, 'plot_clustmetrics', false, @islogical)

    % Parse the input arguments
    parse(p, StudyInfo,type_of_pp, tstimul,varargin{:});

   % Access the parsed values
    StudyInfo = p.Results.StudyInfo;
    type_of_pp = p.Results.type_of_pp;
    tstimul = p.Results.tstimul;
    do_ggERP = p.Results.ggERP;
    do_PSD = p.Results.PSD;
    do_ERSP_ITPC = p.Results.ERSP_ITPC;
    do_DipClus = p.Results.DipClus;
    savejpg = p.Results.savejpg;
    savemat = p.Results.savemat;
    %outPath = p.Results.outPath;
    fignum = p.Results.fignum;
    saveStudy = p.Results.saveStudy;
    recompute = p.Results.recompute;
    numclust = p.Results.numclust;
    do_plot_clustmetrics = p.Results.plot_clustmetrics;
    DataStruct = []
%% load Data
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab; 
if recompute
    [STUDY, ALLEEG] = std_editset( [], [], 'name',tstimul,'task',tstimul,...
        'commands', StudyInfo,'updatedat','on','rmclust','on' );
    [EEG, ALLEEG, CURRENTSET] = eeg_retrieve(ALLEEG,1);
    [STUDY, ALLEEG] = std_editset( STUDY, ALLEEG, 'updatedat','on','rmclust','on' );
    [STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
    CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = 1:length(EEG);

else
    try
    [STUDY ALLEEG] = pop_loadstudy('filename', [tstimul , '.study'], 'filepath', ...
        fullfile('D:\shared_git\MaestriaThesis\results',...
          type_of_pp,'eeglabStudy','StudyDS'));
    catch
        error('File not found, try using recompute = true')
    end
end

%% do DipClust

    if do_DipClus && recompute
        [STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'commands',{{'inbrain','on','dipselect',0.10}},'updatedat','on','rmclust','on' );
        [STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
        [STUDY ALLEEG] = std_preclust(STUDY, ALLEEG, 1,{'dipoles','weight',1});
        [STUDY] = pop_clust(STUDY, ALLEEG, 'algorithm','kmeans','clus_num',  numclust  );
    end

    if do_plot_clustmetrics
        f = figure(); 
        f.Name = 'Eval Clust Plot'; 
        f.Color = 'white'; 
        pause(1); 
        set(gcf, 'Position', [0 0 700, 700]); % Set size
        plot_MakotoClusterOptimization(ALLEEG)
        saveas(gcf, fullfile('D:\shared_git\MaestriaThesis\results',...
        type_of_pp,'eeglabStudy','MatlabDipPlots',[tstimul,'_evalClusts.jpg']));
        clf(f)
        close(f)
    end

    if savejpg && do_DipClus
        figure(fignum+30)
        STUDY = std_dipplot(STUDY,ALLEEG,'clusters','all','figure', 'off');
        saveas(gcf, fullfile('D:\shared_git\MaestriaThesis\results',...
        type_of_pp,'eeglabStudy','MatlabDipPlots',[tstimul,'_dips.jpg']));
        clf(fignum+30)
        close(fignum+30)
    %else Not really necesary
        %STUDY = std_dipplot(STUDY,ALLEEG,'clusters','all','figure', 'on');
    
        if savemat
            locs = zeros(numclust+1,3);
            for clust = 2:numclust+1
                locs(clust,:) = STUDY.cluster(clust).dipole.posxyz;
            end
            DataStruct.locs = locs;
        end
    end

    
    
%% Do ERSP and ITC
    if do_ERSP_ITPC && recompute
        [STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on',...
            'rmicacomps','on','interp','on','recompute','on','ersp','on',...
            'erspparams',{'cycles',[3 0.8] ,'nfreqs',100,'ntimesout',200},...
            'itc','on'); 
    end

    if do_ERSP_ITPC
        ERSP = zeros(22,100,200);
        ERDS = zeros(22,100,200);
        ITPC = zeros(22,100,200);
        cwtAll = cell(22,1);
        for i = 1:22
            channels = {'Fp1';'Fp2';'F3'; 'F4';'C3';'C4';'P3'; ...
                'P4';'O1';'O2';'F7';'F8';'T7';'T8';'P7'; ...
                'P8';'Fz';'Cz';'Pz';'AFz';'CPz'; 'POz'};
            [~,ersp, ersptimes, erspfreqs] = std_erspplot(STUDY,ALLEEG,'channels',channels(i), 'design', 1,'noplot','on');
            %media
            ERSP(i,:,:) = mean(ersp{:,:,:},3);
            cwtAll{i} = ersp;
             
            timeidx = find(ersptimes < 0);
            
            erspd = 10.^((ersp{:,:,:})./10);
            baseline = erspd(:,min(timeidx):max(timeidx),:);
            baselined = repmat(mean(baseline, 2),[1,200,1]);
            ERDS(i,:,:) = mean((baselined - erspd)./baselined*100,3);
    
            [~,itpc] = std_itcplot(STUDY,ALLEEG,'channels',channels(i), 'design', 1,'noplot','on');
            ITPC(i,:,:) = mean(itpc{:,:,:},3);
    
        end
        
        DataStruct.ERSP = ERSP;
        DataStruct.cwtall = cwtAll;
        DataStruct.ersptimes = ersptimes;
        DataStruct.erspfreqs = erspfreqs;
        DataStruct.ITPC = ITPC;
        DataStruct.ERDS = ERDS;
    end
    
    if do_PSD && recompute
        [STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on',...
        'rmicacomps','on','interp','on','recompute','on','spec','on',...
        'specparams',{'specmode','fft','logtrials','off'});
    end
%% do ERP
    if do_ggERP && recompute
        [STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on',...
        'recompute','on','rmicacomps','on','interp','on','erp','on');
    end
    ggERP = zeros(22,1000);
    for i = 1:22
        channels = {'Fp1';'Fp2';'F3'; 'F4';'C3';'C4';'P3'; ...
        'P4';'O1';'O2';'F7';'F8';'T7';'T8';'P7'; ...
        'P8';'Fz';'Cz';'Pz';'AFz';'CPz'; 'POz'};
        [~,erp]=std_erpplot(STUDY,ALLEEG,'channels',channels(i), 'design', 1,'noplot','on');
        ggERP(i,:) = mean(cell2mat(erp),2);
    end
    DataStruct.ggERP = ggERP;
%% Save
    if saveStudy
        pop_savestudy( STUDY, EEG, 'filename', [tstimul , '.study'] ,...
          'filepath',fullfile('D:\shared_git\MaestriaThesis\results',...
          type_of_pp,'eeglabStudy','StudyDS'));      
    end

    if savemat
        save( fullfile('D:\shared_git\MaestriaThesis\results',...
        type_of_pp,'eeglabStudy','MatlabDS',[tstimul,'_DS.mat']),'DataStruct');
    end

    if savejpg
        save ERP
        figure(fignum+10)   

        ts = -1000:1/250*1000:2999;
        plotERPFull_TL(DataStruct.ggERP,ts ...
        ,'ylimits' , [-3 3]...
        ,'tstimul' , tstimul...
        ,'figColor', [1 0 0]...
        ,'LineW'   , 0.9...
        ,'fig_n'   , fignum+10)
        saveas(fignum+10, fullfile('D:\shared_git\MaestriaThesis\results',...
            type_of_pp,'eeglabStudy','PlotERP',[tstimul,'.jpg']));% Functions
        pause(1)
        clf(fignum+10)

        %save ERSP
        plotERSPFull_TL(tstimul,DataStruct.ERSP,fignum+10, ...
            'ylim', [3, 30] , 'clim', [-1, 1], ...
            'freq', DataStruct.erspfreqs, 'ts', DataStruct.ersptimes );
        saveas(fignum+10, fullfile('D:\shared_git\MaestriaThesis\results',...
            type_of_pp,'eeglabStudy','PlotERSP',[tstimul,'_l1.jpg']));% Functions
        clf(fignum+10)

        % plotERSPFull_TL(tstimul,DataStruct.ERSP,fignum+10, ...
        %     'ylim', [3, 60] , 'clim', [-1, 1]);
        % saveas(fignum+10, fullfile('D:\shared_git\MaestriaThesis\results',...
        %     type_of_pp,'eeglabStudy','PlotERSP',[tstimul,'_l2.jpg']));% Functions
        % clf(fignum+10)

        % save ITPC
        plotERSPFull_TL(tstimul,DataStruct.ITPC,fignum+10, ...
            'ylim', [3, 30] , 'clim', [0, 0.5], ...
            'freq', DataStruct.erspfreqs, 'ts', DataStruct.ersptimes );
        saveas(fignum+10, fullfile('D:\shared_git\MaestriaThesis\results',...
            type_of_pp,'eeglabStudy','PlotITPC',[tstimul,'_l1.jpg']));% Functions
        clf(fignum+10)

        % plotERSPFull_TL(tstimul,DataStruct.ITPC,fignum+10, ...
        %     'ylim', [3, 60] , 'clim', [0, 0.3]);
        % saveas(fignum+10, fullfile('D:\shared_git\MaestriaThesis\results',...
        %     type_of_pp,'eeglabStudy','PlotITPC',[tstimul,'_l2.jpg']));% Functions
        % clf(fignum+10)

        % save ERDS
        plotERSPFull_TL(tstimul,DataStruct.ERDS,fignum+10, ...
            'ylim', [3, 30] , 'clim', [-40, 40], ...
            'freq', DataStruct.erspfreqs, 'ts', DataStruct.ersptimes );
        saveas(fignum+10, fullfile('D:\shared_git\MaestriaThesis\results',...
            type_of_pp,'eeglabStudy','PlotERDS',[tstimul,'_l1.jpg']));% Functions
        clf(fignum+10)
        close(fignum+10)
    end
end