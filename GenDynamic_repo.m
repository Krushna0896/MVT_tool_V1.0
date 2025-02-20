% Create Dynamic analysis report
function [Harness_Path,MVT_Log] = GenDynamic_repo(Mdl_name,Sim_time,Dym_time,MVT_Log,Fnl_Mdl_path,Final_ArtifactsPath)
msg = strcat(newline,'Dynamic report generation is in progress........',newline);
disp(msg);
MVT_Log{end+1,1} = msg;

Dynamic_Path = strcat(Final_ArtifactsPath,'\','2.Dynamic');

cd(Final_ArtifactsPath);

if exist('2.Dynamic','file')
    cd(Dynamic_Path);
else
    mkdir('2.Dynamic');
    cd(Dynamic_Path);
end

% Copy model to Dynamic folder
Dynamic_Mdl = [Mdl_name,'_Dy.slx'];
status = copyfile(Fnl_Mdl_path,[Dynamic_Path,'\',Dynamic_Mdl]);
if status == 1
    msg = strcat(Mdl_name,' copied to Dynamic folder sucessfully!',newline);
    disp(msg);
    MVT_Log{end+1,1} = msg;
    Dy_flag = 1;
else
    msg = strcat(Mdl_name,' coping to Dynamic folder failed!',newline);
    disp(msg);
    MVT_Log{end+1,1} = msg;
    Dy_flag = 0;
end

% open_system(Dynamic_Mdl); % open model
load_system(Dynamic_Mdl); % Load model without opening
[~,St_MdlN,~] = fileparts(Dynamic_Mdl);
M_slover = get_param(St_MdlN,'SolverType');

if strcmp(M_slover,'Fixed-step')
    set_param(St_MdlN,'StartTime','0','Stoptime',num2str(Sim_time),'FixedStep','0.01');
    Dy_flag = 1;
else
    Dy_flag = 0;
    set_param(St_MdlN,'SolverType','Fixed-step');
    save_system(Dynamic_Mdl);
    set_param(St_MdlN,'StartTime','0','Stoptime',num2str(Sim_time),'FixedStep','0.01');
    Dy_flag = 1;
end

if Dy_flag == 1
    %     MRoot_Hdl = get_param(bdroot(gcb),'Handle');
    % Searh only level -1 subsystem names for top level subsystem except model info block
    Sub_Sys = find_system(St_MdlN,'SearchDepth',1,'BlockType','SubSystem','MaskType','');
    SpltSub_Sys = split(char(Sub_Sys),'/');
    Top_SubSys = SpltSub_Sys{2};
    TSubSys = [St_MdlN,'/',Top_SubSys];
    Sys_stas = get_param(TSubSys,'TreatAsAtomicUnit');
    
    if strcmp(Sys_stas,'off')
        set_param(TSubSys,'TreatAsAtomicUnit','on');
    end
    
    stcRepo_N = [St_MdlN,'_DED_Report'];
    set_param(St_MdlN,'DVMode','TestGeneration'); % Design verifier mode
    set_param(St_MdlN,'DVMaxProcessTime',Dym_time); % Sldv Maximum analysis time(s)
    % Enable Save report, Mention the report file name & diable report display
    set_param(St_MdlN,'DVSaveReport','on','DVReportFileName',stcRepo_N,'DVDisplayReport','off');
    Harness_Mdl = [St_MdlN,'_Harness'];
    % Enable to save harness & mention harness name
    set_param(St_MdlN,'DVSaveHarnessModel','on','DVHarnessModelFileName',Harness_Mdl);
   
    % check model compatibility
    [Mdl_Status,repoFile] =  sldvcompat(St_MdlN);
    
    if Mdl_Status == 1
        [Sltg_status,filess] = sldvrun(St_MdlN);
    else
        msg = strcat(newline,'Model is not compatibility faild. Kindly check the model...',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
    end
    
    close_system(filess.HarnessModel,0);
    save_system(Dynamic_Mdl)
    close_system(Dynamic_Mdl)
    
    if Sltg_status == 1
        msg = strcat(newline,'Simulink Design Error Detection completed successfully !',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
        DyRepo_pth = filess.Report;
        % copy dynamic report to Dynmic folder
        html_status = copyfile(DyRepo_pth,Dynamic_Path);
        if html_status == 1
            msg = strcat(newline,'Dynamic report copied sucessfully!',newline);
            disp(msg);
            MVT_Log{end+1,1} = msg;
        else
            msg = strcat(newline,'Dynamic report coping failed!',newline);
            disp(msg);
            MVT_Log{end+1,1} = msg;
        end
        % copy Harness model to Dynmic folder
        Harn_path = filess.HarnessModel;
        html_status = copyfile(Harn_path,Dynamic_Path);
        if html_status == 1
            msg = strcat(newline,[Harness_Mdl,'.slx'],' model copied to Dynamic folder sucessfully!',newline);
            disp(msg);
            MVT_Log{end+1,1} = msg;
        else
            msg = strcat(newline,[Harness_Mdl,'.slx'],' model coping to Dynamic folder failed!',newline);
            disp(msg);
            MVT_Log{end+1,1} = msg;
        end
        
        Harness_Path = [Dynamic_Path,'\',Harness_Mdl,'.slx'];
        
    elseif Sltg_status == 0
        msg = strcat(newline,'Simulink test generation failed !',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
    else
        msg = strcat(newline,'Simulink test generation exceeded the maximum processing time!',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
    end
    
else
    msg = strcat(newline,'Model configuration issue happened.',newline,' Kindly check model configuration parameters...',newline);
    disp(msg);
    MVT_Log{end+1,1} = msg;
end

% Delete extra un-wanted folders
if exist('rtwgen_tlc','file')
    rtw_st = rmdir('rtwgen_tlc');
    if rtw_st == 1
        msg = strcat(newline,'rtwgen_tlc folder deleted successfully !',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
    else
        msg = strcat(newline,'rtwgen_tlc folder deletion failed !',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
    end
else
    msg = strcat(newline,'rtwgen_tlc folder does not exist!',newline);
    disp(msg);
    MVT_Log{end+1,1} = msg;
end

if exist('sldv_output','file')
    slo_st = rmdir('sldv_output','s');
    if slo_st == 1
        msg = strcat(newline,'sldv_output folder deleted successfully !',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
    else
        msg = strcat(newline,'sldv_output folder deletion failed !',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
    end
else
    msg = strcat(newline,'sldv_output folder does not exist!',newline);
    disp(msg);
    MVT_Log{end+1,1} = msg;
end


end