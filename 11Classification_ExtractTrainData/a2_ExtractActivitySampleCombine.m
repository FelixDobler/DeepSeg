%%  Chunjing Xiao <ChunjingXiao@gmail.com>
%
%% combine 5 files (one data per user) into baseTrain ( 1,2, 3,4,5) and test (6 )
%

clear

global actionBaseCsi;
global actionBaseLab;
global actionTrainCsi;
global actionTrainLab;
global actionTestCsi;
global actionTestLab;

actionBaseCsi = [];
actionBaseLab = [];
actionTrainCsi = [];
actionTrainLab = [];
actionTestCsi = [];
actionTestLab = [];

currentDir = 'ExtractedActivitySample';
saveDir = {'..', '06Classification_ClassifyActivity', 'data'};

% dir_filter = '*ownUser1_data_label';
dir_filter = 'ownUser*a*_data_label';
% dir_filter = 'user1*_data_label';
data_dir = {currentDir, };
folders = dir(fullfile(data_dir{:}, dir_filter));
folders = folders([folders.isdir] & ~startsWith({folders.name}, '.'));
folderNames = {folders.name};

for user_i = 1:length(folderNames)
    user = folderNames{user_i};
    fprintf('Processing user: %s\n', user);

    user_data_dir = {currentDir, user};
    combineCsiLabel(user_data_dir);
end

%save([currentDir, '/actionBaseCsi'],'actionBaseCsi');
%save([currentDir, '/actionBaseLab'],'actionBaseLab');
%save([currentDir, '/actionTrainCsi'],'actionTrainCsi');
%save([currentDir, '/actionTrainLab'],'actionTrainLab');
save(fullfile(saveDir{:}, 'actionTestCsi'), 'actionTestCsi', '-v7.3');
save(fullfile(saveDir{:}, 'actionTestLab'), 'actionTestLab', '-v7.3');

actionBaseTrainCsi = cat(4, actionBaseCsi, actionTrainCsi);
actionBaseTrainLab = [actionBaseLab; actionTrainLab];
save(fullfile(saveDir{:}, 'actionBaseTrainCsi'), 'actionBaseTrainCsi', '-v7.3');
save(fullfile(saveDir{:}, 'actionBaseTrainLab'), 'actionBaseTrainLab', '-v7.3');
%fprintf('size(actionBaseCsi)         : %s\n', num2str(size(actionBaseCsi)))
%fprintf('size(actionBaseLab)         : %s\n', num2str(size(actionBaseLab)))
fprintf('size(actionBaseTrainCsi)    : %s\n', num2str(size(actionBaseTrainCsi)))
fprintf('size(actionBaseTrainLab)    : %s\n', num2str(size(actionBaseTrainLab)))
fprintf('size(actionTestCsi)         : %s\n', num2str(size(actionTestCsi)))
fprintf('size(actionTestLab)         : %s\n', num2str(size(actionTestLab)))

function combineCsiLabel(dataDir)
    display(dataDir)
    fileList = dir(fullfile(dataDir{:}, '*.mat'));
    numberFiles = length(fileList);
    global actionBaseCsi;
    global actionBaseLab;
    global actionTrainCsi;
    global actionTrainLab;
    global actionTestCsi;
    global actionTestLab;

    for i = 1:numberFiles
        fprintf('i    : %s -- fileName: %s\n', num2str(i), fileList(i).name)

        if ~isempty(strfind(fileList(i).name, '_1.mat')) || ~isempty(strfind(fileList(i).name, '_2.mat'))
            load(fullfile(dataDir{:}, fileList(i).name));
            actionBaseCsi = cat(4, actionBaseCsi, data_);
            load(fullfile(dataDir{:}, strrep(fileList(i).name, '.mat', '_label.mat')));
            actionBaseLab = [actionBaseLab; label_];
            fprintf('size(actionBaseCsi)         : %s\n', num2str(size(actionBaseCsi)))
        end

        if ~isempty(strfind(fileList(i).name, '_5.mat')) || ~isempty(strfind(fileList(i).name, '_4.mat')) || ...
                ~isempty(strfind(fileList(i).name, '_6.mat'))

            load(fullfile(dataDir{:}, fileList(i).name));
            actionTrainCsi = cat(4, actionTrainCsi, data_);
            load(fullfile(dataDir{:}, strrep(fileList(i).name, '.mat', '_label.mat')));
            actionTrainLab = [actionTrainLab; label_];
        end

        if ~isempty(strfind(fileList(i).name, '_3.mat'))
            load(fullfile(dataDir{:}, fileList(i).name));
            actionTestCsi = cat(4, actionTestCsi, data_);
            load(fullfile(dataDir{:}, strrep(fileList(i).name, '.mat', '_label.mat')));
            actionTestLab = [actionTestLab; label_];
        end

    end

end
