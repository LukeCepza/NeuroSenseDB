%% Generate PPValidation .set data (preprocessed)
% CONFIGURATION VARIABLES
dataPath    = 'D:\shared_git\MaestriaThesis\NeuroSenseDatabase\';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resps = zeros(34,57,3);
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
    a = diff(data')'; 
    a(a > 1) = 1;
    a(a < 1) = -1;
    resps(id,:,:) = a;

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

correctans = diff(correctans')'
correctans(correctans > 1) = 1;
correctans(correctans < 1) = -1;

% Close the file
fclose(fid);
air_ca =  permute(repmat(correctans(1:17,:),1,1,34), [3,1,2]);
vib_ca =  permute(repmat(correctans(18:37,:),1,1,34), [3,1,2]);
car_ca =  permute(repmat(correctans(38:57,:),1,1,34), [3,1,2]);

%%
avgs = zeros(34,6)
porcs = zeros(34,6)

avgs(:,1) = sum((air_ca == 1) & (air == 1), [2,3]);
avgs(:,2) = sum((air_ca == -1) & (air == -1), [2,3]);
avgs(:,3) = sum((vib_ca == 1) & (vib == 1), [2,3]);
avgs(:,4) = sum((vib_ca == -1) & (vib == -1), [2,3]);
avgs(:,5) = sum((car_ca == 1) & (car == 1), [2,3]);
avgs(:,6) = sum((car_ca == -1) & (car == -1), [2,3]);


%%
porcs(:,1) = 100*avgs(:,1)./(abs(sum(air_ca > 0,'all')/34));
porcs(:,2) = 100*avgs(:,2)./(abs(sum(air_ca < 0,'all')/34));
porcs(:,3) = 100*avgs(:,3)./(abs(sum(vib_ca > 0,'all')/34));
porcs(:,4) = 100*avgs(:,4)./(abs(sum(vib_ca < 0,'all')/34));
porcs(:,5) = 100*avgs(:,5)./(abs(sum(car_ca > 0,'all')/34));
porcs(:,6) = 100*avgs(:,6)./(abs(sum(car_ca < 0,'all')/34));
%%
% Assuming data is your 34x6 matrix
figure

% Create a tiled layout
t = tiledlayout(1, 3); % 1 row, 2 columns

% Define labels for each boxplot
labels = {'Inc.', 'Dec.'};

% First subplot with the first 3 boxplots (Air and Vib)
ax1 = nexttile;
boxplot(ax1, porcs(:, 1:2), 'Colors', [163,152,228]./255);
set(gca, 'XTickLabel', labels, 'XTick', 1:2);
set(ax1, 'YTick', [0.5,0.6 0.7,0.8,0.9,1]*100, 'YTickLabel', {[0.5,0.6 0.7,0.8,0.9,1]*100}); % Hide Y-axis ticks and labels

title(ax1, 'Air');
ylim([0.5,1]*100)

% Second subplot with the last 3 boxplots (Vib and Car)
ax2 = nexttile;
boxplot(ax2, porcs(:, 3:4), 'Colors', [246,133,119]./255);
set(gca, 'XTickLabel', labels, 'XTick', 1:2);
title(ax2, 'Vibration');
set(ax2, 'YTick', [0.5,0.6 0.7,0.8,0.9,1]*100, 'YTickLabel', {}); % Hide Y-axis ticks and labels
ylim([0.5,1]*100)

% Second subplot with the last 3 boxplots (Vib and Car)
ax3 = nexttile;
boxplot(ax3, porcs(:, 5:6), 'Colors', [246,219,123]./255);
set(gca, 'XTickLabel', labels, 'XTick', 1:2);
title(ax3, 'Caress');
set(ax3, 'YTick', [0.5,0.6 0.7,0.8,0.9,1]*100, 'YTickLabel', {}); % Hide Y-axis ticks and labels
ylim([0.5,1]*100)

% Set overall title and labels
xlabel(t, 'Change in intensity');
ylabel(t, 'Accuracy (%)');

set(gcf, 'Color', 'w');

% Adjust the layout
t.Padding = 'compact';
t.TileSpacing = 'compact';

% Optional: Set the figure size
fig = gcf;
fig.Position = [100, 100, 300, 300]; % [left bottom width height]
