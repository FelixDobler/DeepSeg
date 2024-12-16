% this extracts amplitudes from raw CSI.dat files, and save as .mat files
clear

% dir_filter = '*ownUser1';
dir_filter = 'ownUser*a*';
% dir_filter = 'user*';
folders = dir(fullfile('Data_RawCSIDat', dir_filter));
folders = folders([folders.isdir] & ~startsWith({folders.name}, '.'));
folderNames = {folders.name};
disp('Folders in Data_RawCSIDat:');
disp(folderNames);
raw_dir = 'Data_RawCSIDat';
mat_dir = 'Data_CsiAmplitude';

isDeepSegData = false;
saveCSIMat = false;

addpath(genpath('linux-80211n-csitool-supplementary/matlab/'));
%addpath('C:\Program Files\MATLAB\R2018a\bin\dyc');

for user_dir_idx = 1:length(folderNames)
    user_dir = folderNames{user_dir_idx};
    fprintf('Processing user directory: %s\n', user_dir);
    convertFiles(5, 0.05, fullfile(raw_dir, user_dir), fullfile(mat_dir, user_dir), isDeepSegData, saveCSIMat);
end 

% convertFiles(5, 0.05, raw_dir, mat_dir, isDeepSegData, saveCSIMat)

function [] = convertFiles(N, Wn, datDir, matDir, isDeepSegData, saveCSIMat)

    if isDeepSegData == true
        action_files = dir(fullfile(datDir, '*.dat'));
    else
        action_files = dir(fullfile(datDir, '*.mat'));
    end

    for i_text = 1:length(action_files)
        fprintf('read data  : %s -- fileName: %s\n', num2str(i_text), action_files(i_text).name)
        file_name = action_files(i_text).name;
        data_file = fullfile(datDir, file_name);

        if isDeepSegData == true
            csi_trace = read_bf_file(data_file); %2�����Ͷˣ�3�����նˣ�ÿһ����·����30�����ز�
            [l k] = size(csi_trace);

            for idx = 1:l

                if isempty(csi_trace{idx}) == 1
                    g = idx - 1;
                else
                    g = idx;
                end

            end

            csi_mat = zeros(g, 3 * 30);
            % form csi_stream
            for a = 1:g % take num csi packets
                csia = get_scaled_csi(csi_trace{a}); % get scaled_csi,val(:,:,1)----val(:,:,30)

                for k = 1:3 %3

                    for m = 1:30 %30
                        B = csia(1, k, m); %ȡһ��CSI��
                        %csi_phase=angle(B);
                        %csi_mat(a,m+(k-1)*30) = csi_phase;
                        csi_amplitude = abs(B);
                        csi_mat(a, m + (k - 1) * 30) = csi_amplitude;
                    end

                end

            end

            if saveCSIMat == true
                % save the csi_mat to a file
                data = csi_mat;
                % use the filename and strip the .dat
                name = file_name(1:end - 4);
                fprintf('save mat  : %s -- fileName: %s\n', num2str(i_text), name)
                save([matDir, name, '_csi'], 'data', '-v7.3');
            end

        else
            data = load(data_file, 'data');
            csi_mat = data.data;
        end

        [a, b] = butter(N, Wn, 'low');

        lowpass_ = filter(a, b, csi_mat);
        data_Y{i_text} = lowpass_;

        file_name = action_files(i_text).name;
        % activity = regexp(file_name, 'seq-(\w{2})', 'tokens');
        % activity = activity{1}{1};

        % Check if this category already has a counter, otherwise initialize it
        % if isKey(category_counter, activity)
            % category_counter(activity) = category_counter(activity) + 1;
        % else
            % category_counter(activity) = 1;
        % end

        % name = [matUser, '_', activity, '_', num2str(category_counter(activity))];
        fprintf('save mat  : %s -- fileName: %s\n', num2str(i_text), file_name)

        lowpass = data_Y{1, i_text};
        data = zeros(length(lowpass(:, 1)), 30, 3);

        for i = 1:length(lowpass(:, 1))
            data(i, :, 1) = lowpass(i, 1:30);
            data(i, :, 2) = lowpass(i, 31:60);
            data(i, :, 3) = lowpass(i, 61:90);
        end
        
        if ~exist(matDir, 'dir')
            mkdir(matDir);
        end
        save(fullfile(matDir, file_name), 'data', '-v7.3')
    end

end
