%READ_BF_FILE Reads in a file of beamforming feedback logs.
%   This version uses the *C* version of read_bfee, compiled with
%   MATLAB's MEX utility.
%
% (c) 2008-2011 Daniel Halperin <dhalperi@cs.washington.edu>
%
function ret = read_bf_file(filename)
%% Input check   输入检查
error(nargchk(1,1,nargin));  %验证输入参数的个数

%% Open file
f = fopen(filename, 'rb');   %以‘rb’的方式打开filename，其中‘rb’为读写打开一个二进制文件，只允许读写数据
if (f < 0)                   %此函数返回的f若为+N，则表示文件打开成功，若为-1表示文件打开不成功  f是文件句柄
    error('Couldn''t open file %s', filename);   %文件打开不成功
    return;
end

status = fseek(f, 0, 'eof');  %定位操作，将指针定位到倒数第一个字节
if status ~= 0     %若返回值status不为0，则输出错误（status为0时是正确的）
    [msg, errno] = ferror(f);
    error('Error %d seeking: %s', errno, msg);
    fclose(f);
    return;
end
len = ftell(f);  %len为文件长度  即文件字节数

status = fseek(f, 0, 'bof');  %定位操作，将指针定位到第一个字节
if status ~= 0
    [msg, errno] = ferror(f);
    error('Error %d seeking: %s', errno, msg);
    fclose(f);
    return;
end

%% Initialize variables  初始化变量
ret = cell(ceil(len/95),1);     % 保留返回值-1x1   csi是95字节大，因此这应该是上限
cur = 0;                        % 文件中的当前偏移量
count = 0;                      % 记录输出数
broken_perm = 0;                % 标记是否遇到损坏的CSI的标志
triangle = [1 3 6];             % 1，2，3个天线的排列和是多少

%% Process all entries in file  处理文件中的所有条目
% Need 3 bytes -- 2 byte size field and 1 byte code   需要3字节：2字节大小字段和1字节代码 
while cur < (len - 3)
    % Read size and code
    field_len = fread(f, 1, 'uint16', 0, 'ieee-be');  %f是文件句柄  读取两字节大小的字段
    code = fread(f,1); %输出一维数组code  读取一字节大小的代码
    cur = cur+3;   %往后移动三个字节大小
    
    % If unhandled code, skip (seek over) the record and continue  如果未处理的代码，跳过（查找）记录并继续
    if (code == 187) % get beamforming or phy data
        bytes = fread(f, field_len-1, 'uint8=>uint8');
        cur = cur + field_len - 1;
        if (length(bytes) ~= field_len-1)
            fclose(f);
            return;
        end
    else % skip all other info  跳过所有其他信息
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
