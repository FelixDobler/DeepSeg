clear
% sampleLen = 200;
sampleLen = 100;

csi_dir = {'Data_CsiAmplitudeCut', };
label_dir = {'Label_CsiAmplitudeCut', };
save_dir = {'ExtractedActivitySample', };

% dir_filter = '*ownUser1';
dir_filter = 'ownUser1*a*';
% dir_filter = 'user*';
folders = dir(fullfile(csi_dir{:}, dir_filter));
display(folders)
folders = folders([folders.isdir] & ~startsWith({folders.name}, '.'));
folderNames = {folders.name};

display(folderNames)

startSampleNum = 1;
endSampleNum = 10;
sampleNumPerFile = endSampleNum - startSampleNum + 1; %ÿ���ļ���10������

for user_i = 1:length(folderNames)
    user = folderNames{user_i};
    display("Processing user: " + user);

    user_label_file = fullfile(label_dir{:}, user, 'ManualSegment.csv');
    % display(user_label_file)
    user_save_dir = [save_dir, strcat(user, '_data_label')];

    %whetherPlot = 0;
    %selectFile = 1;  % for user1, diff(lowpass) of 14 15 17 20 is not obvious,

    fid = fopen(user_label_file);
    dcells = textscan(fid, '%f,%f,%f,%f,%s', 'HeaderLines', 1, 'EndOfLine', '\r\n');
    fclose(fid);
    dcellneeds = dcells(1:4);
    cvsSegment = cell2mat(dcellneeds);

    dirMat = [csi_dir, user]; %'20191211OriginalMatData\user2'
    SegmentFiles = dir(fullfile(dirMat{:}, '*.mat')); % 55user1_iw_1.mat
    numberFiles = length(SegmentFiles);

    for whichFile = 1:numberFiles
        %fprintf('seectFile  : %s, matFileName: %s\n', num2str(whichFile), SegmentFiles(whichFile).name)

        data_ = zeros(sampleLen, 30, 3, sampleNumPerFile);
        label_ = zeros(sampleNumPerFile, 1);

        fprintf('selectFile  : %s, matFileName: %s\n', num2str(whichFile), SegmentFiles(whichFile).name)
        data = load(fullfile(dirMat{:}, SegmentFiles(whichFile).name));
        lowpass = data.data_; %lowpass = data.data;
        lenData = size(lowpass);
        lenData = lenData(1);
        %lowpassDiff = diff(lowpass);
        lowpassDiff = lowpass;
        startRow = whichFile * 10 - 9;
        endRow = whichFile * 10;
        %cvsOneFile = cvsSegment(:,:,whichFile);       % use Duan YuCheng
        cvsOneFile = cvsSegment(startRow:endRow, 3:4);

        for i = startSampleNum:1:endSampleNum %1:1:10
            rightActionStart = cvsOneFile(i, 1);
            rightActionEnd = cvsOneFile(i, 2);

            move_start = round(floor((rightActionStart + rightActionEnd) / 2) - (sampleLen / 2) + 1);
            move_end = round(floor((rightActionStart + rightActionEnd) / 2) + (sampleLen / 2));

            data_(:, :, :, i) = lowpassDiff(move_start:move_end, :, :);

            if (move_end - move_start + 1) ~= sampleLen
                fprintf('Error: %s, %s, %s\n', num2str(i), num2str(move_end - move_start + 1), num2str(sampleLen))
            end

            label_(i, 1) = getCategory(SegmentFiles(whichFile).name, i);
        end

        saveName = SegmentFiles(whichFile).name;
        %fprintf('size(data_)         : %s\n', num2str(size(data_)))
        if ~exist(fullfile(user_save_dir{:}), 'dir')
            mkdir(fullfile(user_save_dir{:}));
        end

        save(fullfile(user_save_dir{:}, saveName), 'data_', '-v7.3')
        save(fullfile(user_save_dir{:}, strrep(saveName, '.mat', '_label.mat')), 'label_', '-v7.3')

    end

end

function [categoryNum] = getCategory(readFileName, ii)
    %readFileName = SegmentFiles(whichFile).name;
    fn = readFileName(end - 7:end - 6); % select the catecory indicator from the filename "[user]_[category]_[index].mat"
    categoryNum = 0;
    % display(fn)
    % pause
    if (ii <= 5)

        if (fn == 'iw')
            categoryNum = 1;
        elseif (fn == 'ph')
            categoryNum = 3;
        elseif (fn == 'rp')
            categoryNum = 5;
        elseif (fn == 'sd')
            categoryNum = 7;
        elseif (fn == 'wd')
            categoryNum = 9;
        end

    else

        if (fn == 'iw')
            categoryNum = 2;
        elseif (fn == 'ph')
            categoryNum = 4;
        elseif (fn == 'rp')
            categoryNum = 6;
        elseif (fn == 'sd')
            categoryNum = 8;
        elseif (fn == 'wd')
            categoryNum = 10;
        end

    end

end
