function [MVT_Log] = GenCoverage_repo(Harness_Path,Sim_time,MVT_Log,Final_ArtifactsPath)
msg = strcat(newline,'Coverage report generation is in progress........',newline);
disp(msg);
MVT_Log{end+1,1} = msg;

% initialization
 Hr_flag = 0;
 Cum_cov = [];

Cov_Path = strcat(Final_ArtifactsPath,'\','3.Coverage');

cd(Final_ArtifactsPath);

if exist('3.Coverage','file')
    cd(Cov_Path);
else
    mkdir('3.Coverage');
    cd(Cov_Path);
end
% Copy Harness model to Coverage folder
[Hr_path,Hr_name,Hr_ext] = fileparts(Harness_Path);
Hr_status = movefile(Harness_Path,Cov_Path);
if Hr_status == 1
    msg = strcat(Hr_name,' copied to Coverage folder sucessfully!',newline);
    disp(msg);
    MVT_Log{end+1,1} = msg;
    Hr_flag = 1;
else
    msg = strcat(Hr_name,' coping to Coverage folder failed!',newline);
    disp(msg);
    MVT_Log{end+1,1} = msg;
    Hr_flag = 0;
end
Hr_Mdl = [Hr_name,Hr_ext];
open_system([Hr_name,Hr_ext]); % open model
% load_system([Hr_name,Hr_ext]); % Load model without opening
M_slover = get_param(Hr_name,'SolverType');

if strcmp(M_slover,'Fixed-step')
    set_param(Hr_name,'StartTime','0','Stoptime',num2str(Sim_time),'FixedStep','0.01');
    Hr_flag = 1;
else
    Hr_flag = 0;
    set_param(Hr_name,'SolverType','Fixed-step');
    save_system(Dynamic_Mdl);
    set_param(Hr_name,'StartTime','0','Stoptime',num2str(Sim_time),'FixedStep','0.01');
    Hr_flag = 1;
end


if Hr_flag == 1
    % Enable coverage ,mention structure coverage level in coverage metrics & diable coverage report display
    set_param(Hr_name,'CovEnable','on','CovMetricStructuralLevel','MCDC','CovShowResultsExplorer','off');
    
%     % find signal builder block
%     Sigsb_name = find_system(Hr_name,'BlockType','signalbuilder','MaskType','');
[~,~,~,Ssgrp_N] = signalbuilder('Up_Counter_CUp_Dy_Harness/Inputs');
for Ccov = 1 : length(Ssgrp_N) 
    signalbuilder('Up_Counter_CUp_Dy_Harness/Inputs','activegroup',Ccov);
    Cov_out = cvsim(Hr_name);
    if isempty(Cum_cov)
      Cum_cov = Cov_out;  
    else
    Cum_cov =  Cum_cov + Cov_out;
    end
end

cvhtml('Cumulative Coverage Report',Cum_cov)
save_system(Hr_Mdl)
close_system(Hr_Mdl)
end