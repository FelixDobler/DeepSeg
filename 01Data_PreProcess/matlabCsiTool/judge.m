function [t_start,t_end] = judge(inputArg1,inputArg2)
%UNTITLED2 此处显示有关此函数的摘要
%   递归处

t_start = inputArg1;
t_end = inputArg2;
    j = 1;
    while(j<length(t_start))
        cd(j) = t_start(j+1) - t_start(j);
        j = j+1;
    end
    t_start(find(min(cd) == cd)+1) = [];
    t_end(find(min(cd) == cd)+1) = [];

end

