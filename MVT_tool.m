% This tool is design to automate the model testing process.
% 1.It will take SWC (.slx) model and test cases (excel sheet or test sequence block) as an input.
% 2.Create a harness model.
% 3.Create log sheet for individual testcases.
% 4.Generate Design error detection (Static) report and Test generation (Dynamic) report.
% 5.Generate cumulative coverage report and summary report.
% 6.Log reports.
% -------------------------------------------------------------------------------------------------------------------------------------------




% -------------------------------------------------------------------------------------------------------------------------------------------
clc
clear all
bdclose('all');

[Mdl_Name,Mdl_path] = uigetfile('*.slx','Select the model'); % browse the model
Sim_time = input('Enter the model simulation time: ');
Static_in = input('Enter your choice to generate static report (yes --> 1 or no --> 0): ');
if Static_in == 1
    Stc_time = input('Enter the maximum analysis time to generate static report: ');
end

Dynamic_in = input('Enter your choice to generate dynamic report(yes --> 1 or no --> 0): ');
if Dynamic_in == 1
    Dym_time = input('Enter the mximum analysis time to generate Dynamic report: ');
end

Cov_in = input('Enter your choice to generate the coverage(yes --> 1 or no --> 0): ');
Indv_in = input('Enter your choice to generate individual log(yes --> 1 or no --> 0): ');
Output_path = uigetdir(pwd,'Select a folder for artifacts'); % browse the output folder

Fnl_Mdl_path = strcat(Mdl_path,Mdl_Name);
[~,Mdl_name,~] = fileparts(Fnl_Mdl_path);

% To create a new folder inside output folder
t = datetime('now','TimeZone','local','Format','dMMMyy_HHmmss');
fldr_name = strcat(Mdl_name,'_Results_',char(t));
cd(Output_path)
if exist(fldr_name,'file')
    cd(fldr_name);
else
    mkdir(fldr_name);
    cd(fldr_name);
end

Final_ArtifactsPath = strcat( Output_path,'\',fldr_name);
%% Create MVT Log Report templet
R_name = strcat(Mdl_name,'_Log_report.txt');
Rid = fopen(R_name,'wt');
MVT_Log = {};
MVT_Log{end+1,1} = '------------------ MVT Log Report ------------------';
MVT_Log{end+1,1} = strcat('Model Name:    ', Mdl_name);
MVT_Log{end+1,1} = strcat('Time Stamp:    ', char(datetime('now','TimeZone','local','Format','d-MMM-yy HH:mm:ss')));
MVT_Log{end+1,1} = '-----------------------------------------------------------------------------------------';
fclose(Rid);

%%
msg = strcat('Enter the model simulation time: ',num2str(Sim_time));
MVT_Log{end+1,1} = msg;
msg = strcat('Enter your choice to generate static report (yes --> 1 or no --> 0): ',num2str(Static_in));
MVT_Log{end+1,1} = msg;
if Static_in == 1
    msg = strcat('Enter the maximum analysis time to generate static report: ',num2str(Stc_time));
    MVT_Log{end+1,1} = msg;
end
msg = strcat('Enter your choice to generate dynamic report(yes --> 1 or no --> 0): ',num2str(Dynamic_in));
MVT_Log{end+1,1} = msg;
if Dynamic_in == 1
    msg = strcat('Enter the maximum analysis time to generate Dynamic report: ',num2str(Dym_time));
    MVT_Log{end+1,1} = msg;
end
msg = strcat(newline,'Enter your choice to generate the coverage(yes --> 1 or no --> 0): ',num2str(Cov_in));
MVT_Log{end+1,1} = msg;
msg = strcat('Enter your choice to generate individual log(yes --> 1 or no --> 0): ', num2str(Indv_in));
MVT_Log{end+1,1} = msg;


%% Model handling
if Static_in == 1
    % Create Static analysis report
    [Static_Path,MVT_Log] = GenStatic_repo(Mdl_name,Sim_time,Stc_time,MVT_Log,Fnl_Mdl_path,Final_ArtifactsPath);
end

if Dynamic_in == 1
    % Create dynamic analysis report
    [Harness_Path,MVT_Log] = GenDynamic_repo(Mdl_name,Sim_time,Dym_time,MVT_Log,Fnl_Mdl_path,Final_ArtifactsPath);
    
    if Cov_in ==1
        % To create harness model
        [MVT_Log] = GenCoverage_repo(Harness_Path,Sim_time,MVT_Log,Final_ArtifactsPath);
    end
end


