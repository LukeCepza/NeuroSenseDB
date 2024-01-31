[I1,I2,I3,I4] = extract_SLP_epoch("D:\shared_git\MaestriaThesis\SLP_data\aire_aislamiento-04.wav", ...
0,[12,14], 600718,c3_ch4,22,5,0, [4,1,2,3,4,2,3,1,2,3,1,4,3,1,4,2]);
A = [I1,I2,I3,I4];

[I1,I2,I3,I4] = extract_SLP_epoch("D:\shared_git\MaestriaThesis\SLP_data\Car_aislamiento-04.wav", ...
    0,[11,14], 604700,c3_ch4,18,4,0, [1,4,2,3,1,3,4,2,4,1,2,3,3,1,2,4]);

C = [I1,I2,I3,I4];

[I1,I2,I3,I4] = extract_SLP_epoch("D:\shared_git\MaestriaThesis\SLP_data\vibracion_aislamiento-04.wav", ...
0,[12,15], 598400,c3_ch4,18,4,0,   [2,3,1,4,3,2,1,4,3,1,4,2,4,1,2,3]);

B = [I1,I2,I3,I4];
D = {A,B,C}
%%

saveFolder = "D:\shared_git\MaestriaThesis\ValidationScripts\SPL"
titles = {'Air', 'Vibration', 'Caress'};

f = figure(3);
set(f, 'Color', 'white', 'Position', [0 0 900, 300], 'renderer', 'painters');

tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

t = {linspace(-1000, 4000, 1250),linspace(-1000, 3000, 1000),linspace(-1000, 3000, 1000)};
    % Get the jet colormap
cmap = parula(100);  

for idx = 1:length(titles)
    nexttile;
       colorGradient = cmap(round(linspace(60, 5, 4)), :);

    for idx2 = 1:4
        Q = D{idx};
        T = t{idx};
        plot(T, Q(:, idx2), 'Color', colorGradient(idx2, :), 'LineWidth', 2);
        hold on;
    end
    
    xlabel('Time (ms)');
    ylabel('SPL (dB)');
    title(titles(idx));
    axis([-300, inf, 38, 73]);
    
    hold off;
end

nexttile(1)
legend("Intensity 1","Intensity 2","Intensity 3","Intensity 4", "Location","northwest")
%sgtitle("Average SPL per module ")

% Save the entire tiled layout figure as a .png file
saveFileName = fullfile(saveFolder, ['plot_ERP_' channel{chan} '.png']);
saveas(gcf, saveFileName);
clf(3)
