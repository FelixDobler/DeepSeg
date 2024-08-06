%% Chunjing Xiao <ChunjingXiao@gmail.com> 20200530
%% DeepSeg: Deep Learning based Motion Segmentation Framework for Activity Recognition using WiFi
%% IEEE Internet of Things Journal 2020

% this will reduce the rows of data, because the original data is too large
% and after reducing rows, the performance almost keep the same.
% In other words, this will extract 1 row every 20 rows
% For example, if the the original data has the size if 1000*30*3, this
% will output 50*30*3
clear
%userNum = 'user1';%userNum = 'user2';%userNum = 'user3';%userNum = 'user4';%userNum = 'user5';
% for userSelect = {'user1' 'user2' 'user3' 'user4' 'user5'}
for userSelect = {'philipp'}

userNum = userSelect{1,1}
% userNum = 'user1';
saveDir = ['Data_CsiAmplitudeCut/',userNum]; %'20191220SegmentTrainNew/user2_data_label';
dirMat = ['Data_CsiAmplitude/',userNum];  %'20191211OriginalMatData\user2'
% SegmentFiles = dir([dirMat,'/','*.mat']); % 55user1_iw_1.mat
SegmentFiles = dir([dirMat,'/','55philipp_uc_d.mat']); % 55user1_iw_1.mat
numberFiles = length(SegmentFiles);

for whichFile =1:numberFiles
    %fprintf('seectFile  : %s, matFileName: %s\n', num2str(whichFile), SegmentFiles(whichFile).name)
    
    fprintf('selectFile  : %s, matFileName: %s\n', num2str(whichFile), SegmentFiles(whichFile).name)
    data = load([dirMat,'/',SegmentFiles(whichFile).name]);
    data_ = data.data;
    
    %lowpassDiff = lowpass;
    
    
    data_ = data_(1:20:end,:,:,:);%���ݼ���С��20��
    
    %saveName = strrep(SegmentFiles(whichFile).name,'55','');
    %fprintf('size(data_)         : %s\n', num2str(size(data_)))
    save([saveDir,'/',SegmentFiles(whichFile).name], 'data_', '-v7.3');
end
end
