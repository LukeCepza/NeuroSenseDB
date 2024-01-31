% Define the folder path
folderPath = 'D:\shared_git\MaestriaThesis\results\pp_validation\eeglabStudy\MatlabDS';
fileKeywords = {'Air', 'Vib', 'Car'};
titles = {'Air', 'Vibration', 'Caress'};

channel = {'Fp1';'Fp2';'F3'; 'F4';'C3';'C4';'P3'; ...
        'P4';'O1';'O2';'F7';'F8';'T7';'T8';'P7'; ...
        'P8';'Fz';'Cz';'Pz';'AFz';'CPz'; 'POz'};
for chan = 7
    f = figure(3);
    set(f, 'Color', 'white', 'Position', [0 0 800, 600], 'renderer', 'painters');
    climmax = -100000;
    climmin = 100000;
    % Create a tiled layout with no spacing between tiles
    tiledlayout(3, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    for keywordIndex = 1:length(fileKeywords)
        keyword = fileKeywords{keywordIndex};
        files = dir(fullfile(folderPath, ['*' keyword '*']));
        
       for fileIndex = 1:length(files)
            nexttile((keywordIndex-1)*4 + fileIndex);
            filePath = fullfile(folderPath, files(fileIndex).name);
            load(filePath, 'DataStruct');
            
            dataToPlot = squeeze(DataStruct.ERDS(chan, :,:)); 
            
            t = DataStruct.ersptimes; 
            f = DataStruct.erspfreqs; 
            contourf(t,f,dataToPlot,20,'LineStyle', 'none');
    
            colormap(parula); 
    
            set(gca, 'FontUnits', 'points', 'FontName', 'Sans', 'FontSize', 10);
            set(gca,'YScale', 'log')
            yticks([5, 10, 20, 30, 40, 50, 80]);
            xlabel('Time (ms)');
            ylabel('Frequency (Hz)');
            title([titles(keywordIndex) + " Intensity " + string(fileIndex)]);
            ylim([3,60])
    
            climmax = max(climmax,max(dataToPlot,[],'all'));
            climmin = min(climmin,min(dataToPlot,[],'all'));
       end  
    
    
    end
    
    for keywordIndex = 1:length(fileKeywords)
        for fileIndex = 1:length(files)
            nexttile((keywordIndex-1)*4 + fileIndex);
            clim([climmin climmax])
        end
    end

    % Add a color bar to the entire figure
    cb = colorbar;
    cb.Position = [0.955 0.31 0.02 0.4];
    cb.Label.String = 'ERDS (%)';
    
    % Adjust the color limits of the color bar
    cb.Limits = [climmin climmax];

    disp([climmin climmax])
    climmax = -100000;
    climmin = 100000;
    
    sgtitle("ERDS at " + channel(chan))

    % Save the entire tiled layout figure as a .png file
    saveFileName = fullfile(saveFolder, ['plot_ERDS_' channel{chan} '.png']);
    saveas(gcf, saveFileName);
    clf(3)
end
