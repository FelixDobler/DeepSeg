%READ_BF_FILE Reads in a file of beamforming feedback logs.
%   This version uses the *C* version of read_bfee, compiled with
%   MATLAB's MEX utility.
%
% (c) 2008-2011 Daniel Halperin <dhalperi@cs.washington.edu>
%
function ret = read_bf_file(filename)
%% Input check   ������
error(nargchk(1,1,nargin));  %��֤��������ĸ���

%% Open file
f = fopen(filename, 'rb');   %�ԡ�rb���ķ�ʽ��filename�����С�rb��Ϊ��д��һ���������ļ���ֻ�����д����
if (f < 0)                   %�˺������ص�f��Ϊ+N�����ʾ�ļ��򿪳ɹ�����Ϊ-1��ʾ�ļ��򿪲��ɹ�  f���ļ����
    error('Couldn''t open file %s', filename);   %�ļ��򿪲��ɹ�
    return;
end

status = fseek(f, 0, 'eof');  %��λ��������ָ�붨λ��������һ���ֽ�
if status ~= 0     %������ֵstatus��Ϊ0�����������statusΪ0ʱ����ȷ�ģ�
    [msg, errno] = ferror(f);
    error('Error %d seeking: %s', errno, msg);
    fclose(f);
    return;
end
len = ftell(f);  %lenΪ�ļ�����  ���ļ��ֽ���

status = fseek(f, 0, 'bof');  %��λ��������ָ�붨λ����һ���ֽ�
if status ~= 0
    [msg, errno] = ferror(f);
    error('Error %d seeking: %s', errno, msg);
    fclose(f);
    return;
end

%% Initialize variables  ��ʼ������
ret = cell(ceil(len/95),1);     % ��������ֵ-1x1   csi��95�ֽڴ������Ӧ��������
cur = 0;                        % �ļ��еĵ�ǰƫ����
count = 0;                      % ��¼�����
broken_perm = 0;                % ����Ƿ������𻵵�CSI�ı�־
triangle = [1 3 6];             % 1��2��3�����ߵ����к��Ƕ���

%% Process all entries in file  �����ļ��е�������Ŀ
% Need 3 bytes -- 2 byte size field and 1 byte code   ��Ҫ3�ֽڣ�2�ֽڴ�С�ֶκ�1�ֽڴ��� 
while cur < (len - 3)
    % Read size and code
    field_len = fread(f, 1, 'uint16', 0, 'ieee-be');  %f���ļ����  ��ȡ���ֽڴ�С���ֶ�
    code = fread(f,1); %���һά����code  ��ȡһ�ֽڴ�С�Ĵ���
    cur = cur+3;   %�����ƶ������ֽڴ�С
    
    % If unhandled code, skip (seek over) the record and continue  ���δ����Ĵ��룬���������ң���¼������
    if (code == 187) % get beamforming or phy data
        bytes = fread(f, field_len-1, 'uint8=>uint8');
        cur = cur + field_len - 1;
        if (length(bytes) ~= field_len-1)
            fclose(f);
            return;
        end
    else % skip all other info  ��������������Ϣ
        fseek(f, field_len - 1, 'cof');
        cur = cur + field_len - 1;
        continue;
    end
    
    if (code == 187) %hex2dec('bb')) Beamforming matrix -- output a record
        count = count + 1;
        ret{count} = read_bfee(bytes);
        
        perm = ret{count}.perm;
        Nrx = ret{count}.Nrx;
        if Nrx == 1 % No permuting needed for only 1 antenna
            continue;
        end
        if sum(perm) ~= triangle(Nrx) % matrix does not contain default values
            if broken_perm == 0
                broken_perm = 1;
                fprintf('WARN ONCE: Found CSI (%s) with Nrx=%d and invalid perm=[%s]\n', filename, Nrx, int2str(perm));
            end
        else
            ret{count}.csi(:,perm(1:Nrx),:) = ret{count}.csi(:,1:Nrx,:);
        end
    end
end
ret = ret(1:count);

%% Close file
fclose(f);
end
