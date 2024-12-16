%%  Chunjing Xiao <ChunjingXiao@gmail.com> 20200530
% DeepSeg: Deep Learning based Motion Segmentation Framework for Activity Recognition using WiFi

% This is to discreize continuous CSI data into bins  for segmentation
%
clear
sampleLen = 60; % the length of bins
%sampleCategory = 10;

dir_filter = 'ownUser*a*';
data_dir = {'..', '01Data_PreProcess', 'Data_CsiAmplitudeCut'};
folders = dir(fullfile(data_dir{:}, dir_filter));
folders = folders([folders.isdir] & ~startsWith({folders.name}, '.'));
folderNames = {folders.name};

% userNum = 'ownUser1';
%userNum = 'user1';
%userNum = 'user2';
%userNum = 'user3';
%userNum = 'user4';
% userNum = 'user5';

for i = 1:length(folderNames)
    user = folderNames{i};
    display("Processing user: " + user);

    save_dir = {'Data_DiscretizeCsi', strcat(user, '_test_data')}; %'Data_DiscretizeCsi/user2_data_label';
    load_dir = {data_dir{:}, user}; %'Data_CsiAmplitudeCut\user2'
    SegmentFiles = dir(fullfile(load_dir{:}, '*.mat')); % 55user1_iw_1.mat
    numberFiles = length(SegmentFiles);

    for whichFile = 1:numberFiles
        %fprintf('seectFile  : %s, matFileName: %s\n', num2str(whichFile), SegmentFiles(whichFile).name)

        fprintf('selectFile  : %s, matFileName: %s\n', num2str(whichFile), SegmentFiles(whichFile).name)
        data = load(fullfile(load_dir{:}, SegmentFiles(whichFile).name));
        lowpass = data.data_;
        %lowpass = lowpass(1:20:end,:,:);%���ݼ���С��20��

        lenData = size(lowpass);
        lenData = lenData(1);
        lowpassDiff = diff(lowpass);
        %lowpassDiff = lowpass;

        startSampleNum = sampleLen;
        endSampleNum = lenData - sampleLen;
        sampleNumPerFile = endSampleNum - startSampleNum + 1; %ÿ���ļ���10������
        data_ = zeros(sampleLen, 30, 3, sampleNumPerFile);

        for i = startSampleNum + 1:1:endSampleNum %1:1:10
            data_(:, :, :, i) = lowpassDiff(i:i + sampleLen - 1, :, :);
            x = i + sampleLen - 1;
        end

        saveName = SegmentFiles(whichFile).name;
        

        if ~exist(fullfile(save_dir{:}), 'dir')
            mkdir(fullfile(save_dir{:}));
        end
        save(fullfile(save_dir{:}, saveName), 'data_', '-v7.3')
    end

end
