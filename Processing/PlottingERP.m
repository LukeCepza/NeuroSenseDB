% Define the folder path
folderPath = 'D:\shared_git\MaestriaThesis\results\pp_validation\eeglabStudy\MatlabDS';
saveFolder = 'D:\shared_git\MaestriaThesis\ValidationScripts\Results';

fileKeywords = {'Air', 'Vib', 'Car'};
titles = {'Air', 'Vibration', 'Caress'};

channel = {'Fp1';'Fp2';'F3'; 'F4';'C3';'C4';'P3'; ...
        'P4';'O1';'O2';'F7';'F8';'T7';'T8';'P7'; ...
        'P8';'Fz';'Cz';'Pz';'AFz';'CPz'; 'POz'};
for chan = 5
    % Create a figure with white background
    f = figure(3);
    set(f, 'Color', 'white', 'Position', [0 0 900, 300], 'renderer', 'painters');
    
    % Create a tiled layout with no spacing between tiles
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    % Define the time vector outside the loop for efficiency
    t = linspace(-1000, 3000, 1000);
    
    % Get the jet colormap
    cmap = parula(100);  
    
    for keywordIndex = 1:length(fileKeywords)
        nexttile;
        keyword = fileKeywords{keywordIndex};
        files = dir(fullfile(folderPath, ['*' keyword '*']));
        
        colorGradient = cmap(round(linspace(60, 5, length(files))), :);
    
        for fileIndex = 1:length(files)
            filePath = fullfile(folderPath, files(fileIndex).name);
            load(filePath, 'DataStruct');
            
            dataToPlot = movmean(DataStruct.ggERP(chan, :), 5); 
    
            plot(t, dataToPlot, 'Color', colorGradient(fileIndex, :), 'LineWidth', 2);
            hold on;
        end
        
        xlabel('Time (ms)');
        ylabel('Amplitude (uV)');
        title(titles(keywordIndex));
        axis([-300, inf, -2, 1.5]);
        
        hold off;
    end
    
    nexttile(1)
    legend("Intensity 1","Intensity 2","Intensity 3","Intensity 4", "Location","south")
    %sgtitle("Grand ERP accross subjects for different intensities at " + channel(chan))
    
    % Save the entire tiled layout figure as a .png file
    saveFileName = fullfile(saveFolder, ['plot_ERP_' channel{chan} '.png']);
    %saveas(gcf, saveFileName);
    %clf(3)
end
