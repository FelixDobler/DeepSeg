% this extracts amplitudes from raw CSI.dat files, and save as .mat files
clear
%datDir = 'Data_RawCSIDat/user1_Bai_ShiQing_dat/';      matUser = 'user1';
datDir = 'Data_OwnRawCSI/';      matUser = 'philipp';

%datDir = 'Data_RawCSIDat/user2_He_HaiSheng_dat/';     matUser = 'user2';
%datDir = 'Data_RawCSIDat/user3_Lei_Yue_dat/';         matUser = 'user3';
%datDir = 'Data_RawCSIDat/user4_Shao_HongTao_dat/';    matUser = 'user4';
% datDir = 'Data_RawCSIDat/user5_Yan_Di_dat/';          matUser = 'user5';
matDir = ['Data_CsiAmplitude/',matUser,'/']; %matDir = 'AmplitudeMat/user5/';


isDeepSegData = false;
saveCSIMat = false;

addpath(genpath('matlabCsiTool/'));
%addpath('C:\Program Files\MATLAB\R2018a\bin\dyc');


% for Wn = logspace(-0.001, -3, 10)
%     for N = 2:8
%         convertFiles(N, Wn, datDir, matDir, matUser, isDeepSegData)
%     end
% end
convertFiles(5, 0.05, datDir, matDir, matUser, isDeepSegData, saveCSIMat)

function [] = convertFiles(N, Wn, datDir, matDir, matUser, isDeepSegData, saveCSIMat)
if isDeepSegData == true
    action_files = dir(fullfile(datDir,'*.dat'));
else
    action_files = dir(fullfile(datDir,'*.mat'));
end

for i_text = 1:length(action_files)
    fprintf('read data  : %s -- fileName: %s\n',  num2str(i_text),action_files(i_text).name)
    file_name = action_files(i_text).name;
    data_file = [datDir,file_name];
    
    if isDeepSegData == true
        csi_trace=read_bf_file(data_file);%2�����Ͷˣ�3�����նˣ�ÿһ����·����30�����ز�
        [l k]=size(csi_trace);
        for idx=1:l
            if isempty(csi_trace{idx})==1
                g=idx-1;
            else
                g=idx;
            end
        end
        csi_mat = zeros(g,3*30);
        % form csi_stream
        for a = 1:g  % take num csi packets
            csia = get_scaled_csi(csi_trace{a}); % get scaled_csi,val(:,:,1)----val(:,:,30)
            for k = 1:3  %3
                for m = 1:30  %30
                    B = csia(1,k,m);  %ȡһ��CSI��
                    %csi_phase=angle(B);
                    %csi_mat(a,m+(k-1)*30) = csi_phase;
                    csi_amplitude = abs(B);
                    csi_mat(a,m+(k-1)*30) = csi_amplitude;
                end
            end
        end
        
        if saveCSIMat == true
            % save the csi_mat to a file
            data = csi_mat;
            % use the filename and strip the .dat
            name = file_name(1:end-4);
            fprintf('save mat  : %s -- fileName: %s\n',  num2str(i_text),name)
            save([matDir,name, '_csi'], 'data', '-v7.3');
        end
    else
        data = load(data_file, 'data');
        csi_mat = data.data;
    end
    
    [a, b] = butter(N, Wn, 'low');
    
    lowpass_ = filter(a, b,csi_mat);
    data_Y{i_text} = lowpass_;
    
    file_name = action_files(i_text).name;
    fn = [file_name(4),file_name(5)];
    % name = ['55',matUser,'_',fn,'_',strrep(file_name(7), '.', '-'),'_N',num2str(N),'_Wn',strrep(num2str(Wn), '.', '-')];
    name = ['55',matUser,'_',fn,'_',strrep(file_name(7), '.', '-')];
    fprintf('save mat  : %s -- fileName: %s\n',  num2str(i_text),name)
    
    lowpass = data_Y{1,i_text};
    data = zeros(length(lowpass(:,1)),30,3);
    for i = 1:length(lowpass(:,1))
        data(i,:,1) = lowpass(i,1:30);
        data(i,:,2) = lowpass(i,31:60);
        data(i,:,3) = lowpass(i,61:90);
    end
    save([matDir,name], 'data', '-v7.3')
end
end
