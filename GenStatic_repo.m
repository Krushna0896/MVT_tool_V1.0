% Create Static analysis report
function [Static_Path,MVT_Log] = GenStatic_repo(Mdl_name,Sim_time,Stc_time,MVT_Log,Fnl_Mdl_path,Final_ArtifactsPath)
msg = strcat(newline,'Static report generation is in progress........',newline);
disp(msg);
MVT_Log{end+1,1} = msg;

Static_Path = strcat(Final_ArtifactsPath,'\','1.Static');

if exist('1.Static','file')
    cd(Static_Path);
else
    mkdir('1.Static');
    cd(Static_Path);
end

% Copy model to Static folder
static_Mdl = [Mdl_name,'_St.slx'];
status = copyfile(Fnl_Mdl_path,[Static_Path,'\',static_Mdl]);
if status == 1
    msg = strcat(Mdl_name,' copied to static folder sucessfully!',newline);
    disp(msg);
    MVT_Log{end+1,1} = msg;
    st_flag = 1;
else
    msg = strcat(Mdl_name,' coping to static folder failed!',newline);
    disp(msg);
    MVT_Log{end+1,1} = msg;
    st_flag = 0;
end

% open_system(static_Mdl); % open model
load_system(static_Mdl); % Load model without opening
[~,St_MdlN,~] = fileparts(static_Mdl);
M_slover = get_param(St_MdlN,'SolverType');

if strcmp(M_slover,'Fixed-step')
    set_param(St_MdlN,'StartTime','0','Stoptime',num2str(Sim_time),'FixedStep','0.01');
    st_flag = 1;
else
    st_flag = 0;
    set_param(St_MdlN,'SolverType','Fixed-step');
    save_system(static_Mdl);
    set_param(St_MdlN,'StartTime','0','Stoptime',num2str(Sim_time),'FixedStep','0.01');
    st_flag = 1;
end

if st_flag == 1
    
    MRoot_Hdl = get_param(bdroot(gcb),'Handle');
    Sub_Sys = find_system(St_MdlN,'SearchDepth',1,'BlockType','SubSystem','MaskType','');
    SpltSub_Sys = split(char(Sub_Sys),'/');
    Top_SubSys = SpltSub_Sys{2};
    TSubSys = [St_MdlN,'/',Top_SubSys];
    Sys_stas = get_param(TSubSys,'TreatAsAtomicUnit');
    
    if strcmp(Sys_stas,'off')
        set_param(TSubSys,'TreatAsAtomicUnit','on');
    end
    
    stcRepo_N = [St_MdlN,'_DED_Report'];
    set_param(St_MdlN,'DVMode','DesignErrorDetection');
    set_param(St_MdlN,'DVMaxProcessTime',Stc_time);
    set_param(St_MdlN,'DVSaveReport','on','DVReportFileName',stcRepo_N,'DVDisplayReport','off');
    
    [Mdl_Status,repoFile] =  sldvcompat(St_MdlN);
    
    if Mdl_Status == 1
        [Sldd_status,filess] = sldvrun(St_MdlN);
    end
    
    save_system(static_Mdl)
    close_system(static_Mdl)
    
    if Sldd_status == 1
        msg = strcat(newline,'Simulink Design Error Detection completed successfully !',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
        StRepo_pth = filess.Report;
        html_status = copyfile(StRepo_pth,Static_Path);
        if html_status == 1
            msg = strcat(newline,'Static report copied sucessfully!',newline);
            disp(msg);
            MVT_Log{end+1,1} = msg;
        else
            msg = strcat(newline,'Static report coping failed!',newline);
            disp(msg);
            MVT_Log{end+1,1} = msg;
        end
        
    elseif Sldd_status == 0
        msg = strcat(newline,'Simulink Design Error Detection failed !',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
    else
        msg = strcat(newline,'Simulink Design Error Detection exceeded the maximum processing time!',newline);
        disp(msg);
        MVT_Log{end+1,1} = msg;
    end
    
else
    msg = strcat(newline,'Model configure issue happened.',newline,' Kindly check model configuration parameters...',newline);
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