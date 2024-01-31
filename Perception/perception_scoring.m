%% Generate PPValidation .set data (preprocessed)
% CONFIGURATION VARIABLES
dataPath    = 'D:\shared_git\MaestriaThesis\NeuroSenseDatabase\';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resps = zeros(34,57,4);
tic
for id = 1:34
    % Format 'i' with leading zeros (e.g., sub-01, sub-02, etc.)
    sub_id = sprintf('sub-%02d', id);
    nameInE = fullfile(dataPath, sub_id, 'other', [sub_id '_R.txt']);
    
    % Open the file
    fid = fopen(nameInE, 'r');
    
    % Initialize an empty array to store the results
    data = [];
    
    % Read each line of the file
    while ~feof(fid)
        line = fgetl(fid); % Read a line as a string
        if ~ischar(line) % Skip if the line is not valid
            continue;
        end
        numbers = arrayfun(@(x) str2double(x), line); % Convert each character to a number
        numbers = numbers(1:4);
        data = [data; numbers]; % Append to the array
    end
    
    % Close the file
    fclose(fid);
    resps(id,:,:) = data; 
    data = [];
end

air =  resps(:,1:17,:);
vib =  resps(:,18:37,:);
car =  resps(:,38:57,:);
%%

data(data == 5) = 0;

filename = 'D:\shared_git\MaestriaThesis\NeuroSenseDatabase\PerceivedResponseAnswersheet.txt';

% Open the file
fid = fopen(filename, 'r');

% Initialize an empty array to store the results
correctans = [];

% Read each line of the file
while ~feof(fid)
    line = fgetl(fid); % Read a line as a string
    if ~ischar(line) % Skip if the line is not valid
        continue;
    end
    numbers = arrayfun(@(x) str2double(x), line); % Convert each character to a number
    correctans = [correctans; numbers]; % Append to the array
end

% Close the file
fclose(fid);
air_ca =  permute(repmat(correctans(1:17,:),1,1,34), [3,1,2]);
vib_ca =  permute(repmat(correctans(18:37,:),1,1,34), [3,1,2]);
car_ca =  permute(repmat(correctans(38:57,:),1,1,34), [3,1,2]);

%%
avgs = zeros(34,12)
porcs = zeros(34,12)

avgs(:,1) = sum((air_ca == 1) & (air == 1), [2,3]);
avgs(:,2) = sum((air_ca == 2) & (air == 2), [2,3]);
avgs(:,3) = sum((air_ca == 3) & (air == 3), [2,3]);
avgs(:,4) = sum((air_ca == 4) & (air == 4), [2,3]);
avgs(:,5) = sum((vib_ca == 1) & (vib == 1), [2,3]);
avgs(:,6) = sum((vib_ca == 2) & (vib == 2), [2,3]);
avgs(:,7) = sum((vib_ca == 3) & (vib == 3), [2,3]);
avgs(:,8) = sum((vib_ca == 4) & (vib == 4), [2,3]);
avgs(:,9) = sum((car_ca == 1) & (car == 1), [2,3]);
avgs(:,10) = sum((car_ca == 2) & (car == 2), [2,3]);
avgs(:,11) = sum((car_ca == 3) & (car == 3), [2,3]);
avgs(:,12) = sum((car_ca == 4) & (car == 4), [2,3]);

%%
porcs(:,1:4) = 100*avgs(:,1:4)./(17)
porcs(:,5:8) = 100*avgs(:,5:8)./(20)
porcs(:,9:12) = 100*avgs(:,9:12)./(20)

%%

% Create the boxplot with a stronger blue color
boxplot(porcs, 'BoxStyle', 'outline', 'Colors', [0, 0.4470, 0.7410]); % MATLAB default blue

% Set the labels for each boxplot
labels = {'Air1', 'Air2', 'Air3', 'Air4', 'Vib1', 'Vib2', 'Vib3', 'Vib4', 'Car1', 'Car2', 'Car3', 'Car4'};
set(gca, 'XTickLabel', labels, 'XTick',1:numel(labels));
set(gcf, 'Color', [1 1 1]); % White background for the figure

% Set xticks to normal (horizontal)
set(gca, 'XTickLabelRotation', 0);

% Remove the grid
grid off;

xlabel('Modality and Intensity ', 'FontSize', 12);
ylabel('Score (%)', 'FontSize', 12);

% Optional: Set the figure size
fig = gcf;
fig.Position = [100, 100, 580, 300]; % [left bottom width height]

%%
% Create a tiled layout
t = tiledlayout(1, 3); % 1 row, 3 columns

% Define labels for each boxplot
labels = {'1', '2', '3', '4'};

% First subplot with the first 4 boxplots
ax1 = nexttile;
boxplot(ax1, porcs(:, 1:4), 'Colors', [163,152,228]./255 );
set(gca, 'XTickLabel', labels, 'XTick', 1:4);
set(ax1, 'YTick', [0,0.2,0.4,0.6,0.8,1]*100, 'YTickLabel', {[0,0.2,0.4,0.6,0.8,1]*100}); % Hide Y-axis ticks and labels
title(ax1, 'Air');
ylim([0,1]*100)

% Second subplot withz the next 4 boxplots
ax2 = nexttile;
boxplot(ax2, porcs(:, 5:8), 'Colors', [246,133,119]./255);
set(gca, 'XTickLabel', labels, 'XTick', 1:4);
set(ax2, 'YTick', [0,0.2,0.4,0.6,0.8,1]*100, 'YTickLabel', {}); % Hide Y-axis ticks and labels
title(ax2, 'Vibration');
ylim([0,1]*100)

% Third subplot with the last 4 boxplots
ax3 = nexttile;
boxplot(ax3, porcs(:, 9:12), 'Colors', [246,219,123]./255);
set(gca, 'XTickLabel', labels, 'XTick', 1:4);
set(ax3, 'YTick', [0,0.2,0.4,0.6,0.8,1]*100, 'YTickLabel', {}); % Hide Y-axis ticks and labels
title(ax3, 'Caress ');
ylim([0,1]*100)

% Set overall title and labels
xlabel(t, 'Intensity');
ylabel(t, 'Accuracy (%)');
%title(t, 'Boxplot of Each Modality', 'FontSize', 14);

set(gcf, 'Color', 'w');

% Adjust the layout
t.Padding = 'compact';
t.TileSpacing = 'compact';

% Optional: Set the figure size
fig = gcf;
fig.Position = [100, 100, 300, 300]; % [left bottom width height]
