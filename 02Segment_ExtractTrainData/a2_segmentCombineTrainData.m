%% Chunjing Xiao <ChunjingXiao@gmail.com> 20200530
%% DeepSeg: Deep Learning based Motion Segmentation Framework for Activity Recognition using WiFi
%% IEEE Internet of Things Journal 2020
%
% combine 5 files (one data per user) into segmentBaseTrainCsi (1,2,3,4,5) and test (6)
%
clear

global segmentBaseCsi;
global segmentBaseLab;
global segmentTrainCsi;
global segmentTrainLab;
global segmentTestCsi;
global segmentTestLab;

segmentBaseCsi = [];
segmentBaseLab = [];
segmentTrainCsi = [];
segmentTrainLab = [];
segmentTestCsi = [];
segmentTestLab = [];
currentDir = 'TrainingDataForSegment' %currentDir ='20191220SegmentTrainNew'

% dir_filter = '*ownUser1_data_label';
dir_filter = 'ownUser*a*_data_label';
% dir_filter = 'user1*_data_label';
folders = dir(fullfile('TrainingDataForSegment', dir_filter));
folders = folders([folders.isdir] & ~startsWith({folders.name}, '.'));
folderNames = {folders.name};

for i = 1:length(folderNames)
    user = folderNames{i};
    dataDir = {currentDir, user};
    display(dataDir);
    combineCsiLabel(dataDir);
end

save(fullfile(currentDir, 'segmentTestCsi'), 'segmentTestCsi', '-v7.3');
save(fullfile(currentDir, 'segmentTestLab'), 'segmentTestLab', '-v7.3');

segmentBaseTrainCsi = cat(4, segmentBaseCsi, segmentTrainCsi);
segmentBaseTrainLab = [segmentBaseLab; segmentTrainLab];
save(fullfile(currentDir, 'segmentBaseTrainCsi'), 'segmentBaseTrainCsi', '-v7.3');
save(fullfile(currentDir, 'segmentBaseTrainLab'), 'segmentBaseTrainLab', '-v7.3');

fprintf('size(segmentBaseTrainCsi)         : %s\n', num2str(size(segmentBaseTrainCsi)))
fprintf('size(segmentBaseTrainLab)         : %s\n', num2str(size(segmentBaseTrainLab)))
fprintf('size(segmentTestCsi)         : %s\n', num2str(size(segmentTestCsi)))
fprintf('size(segmentTestLab)         : %s\n', num2str(size(segmentTestLab)))

function combineCsiLabel(dataDir)
    fileList = dir(fullfile(dataDir{:}, '*.mat'));
    % filter out the files that end in _label.mat
    fileList = fileList(~contains({fileList.name}, '_label.mat'));
    numberFiles = length(fileList);
    global segmentBaseCsi;
    global segmentBaseLab;
    global segmentTrainCsi;
    global segmentTrainLab;
    global segmentTestCsi;
    global segmentTestLab;

    for i = 1:numberFiles
        fprintf('i    : %s -- fileName: %s\n', num2str(i), fileList(i).name)

        load(fullfile(dataDir{:}, fileList(i).name));
        load(fullfile(dataDir{:}, strrep(fileList(i).name, '.mat', '_label.mat')));

        % extract the number from the file name
        % example ownUser1a876_wd_3.mat should extract 3
        sample_idx_match = regexp(fileList(i).name, '_(\d+).mat', 'tokens', 'once');
        sample_idx = str2num(sample_idx_match{1});

        if sample_idx == 5
            segmentTestCsi = cat(4, segmentTestCsi, data_);
            segmentTestLab = [segmentTestLab; label_];
        % elseif sample_idx == 3 || sample_idx == 2
        elseif sample_idx == 1 || sample_idx == 2 || sample_idx == 3
            segmentBaseCsi = cat(4, segmentBaseCsi, data_);
            segmentBaseLab = [segmentBaseLab; label_];
        elseif sample_idx == 4 || sample_idx == 6
            segmentTrainCsi = cat(4, segmentTrainCsi, data_);
            segmentTrainLab = [segmentTrainLab; label_];
        end

    end

end
