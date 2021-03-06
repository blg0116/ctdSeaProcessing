%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessing software for CTD-LADCP                                     %
% Autor: Pierre Rousselot / Date: 10/03/16                                 %
% Jedi master: Jacques Grelet                                              %
% -> Launch processing                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function launch_processing(cfg)

%% Open log file
logfile = fopen(strcat(cfg.path_config, cfg.log_filename), 'wt');
counter = cfg.copy_CTD+cfg.process_CTD+cfg.copy_LADCP+cfg.process_LADCP;
wbar    = waitbar(0, 'CTD-LADCP PreProcessing');
if cfg.debug_mode
    close(wbar)
end

% error indicative
ind_error = 0;

%% CTD
% Copy CTD file
if cfg.copy_CTD
    % Test file exist
    cfg.filename_CTD    = sprintf('%s', cfg.id_mission, cfg.num_station);
    fileRawCtd_hex    = sprintf('%s', cfg.path_raw_CTD, cfg.filename_CTD, '.hex');
    
    if cfg.debug_mode
        
        [ind_error] = copy_CTD(p, logfile);
        
    else
        
        waitbar(cfg.copy_CTD/(counter+1), wbar, 'Copying CTD data');
        
        if exist(fileRawCtd_hex,'file')
            Quest_process = questdlg({'CTD files exist !' 'Are you sure to make the process?'}, 'File exist', 'Yes', 'No', 'Yes');
            if strcmp(Quest_process,'Yes')
                [ind_error] = copy_CTD(cfg, logfile);
            else
                close(wbar);
                return;
            end
        else
            [ind_error] = copy_CTD(cfg, logfile);
        end
        
    end
    
    
end

% Process CTD file
if cfg.process_CTD
    
    time_wbar=(cfg.copy_CTD+cfg.process_CTD)/(counter+1);
    
    if cfg.debug_mode
        
        process_CTD(cfg, logfile, wbar, time_wbar);
        
    else
        
        waitbar((cfg.copy_CTD+cfg.process_CTD)/(counter+1), wbar, 'Processing CTD file');
        
        if ind_error
            Quest_process = questdlg({'Some problems occued during the copying process !' 'Are you sure to continu?'}, 'File exist', 'Yes', 'No', 'Yes');
            if strcmp(Quest_process,'Yes')
                process_CTD(cfg, logfile, wbar, time_wbar);
            else
                close(wbar);
                return;
            end
        else
            process_CTD(cfg, logfile, wbar, time_wbar);
        end
        
        if ~cfg.copy_LADCP && ~cfg.process_LADCP
            close(wbar);
        end
        
    end
end

%% LADCP

% error indicative
ind_error = 0;

% Copy LADCP file
if cfg.copy_LADCP
    
    if cfg.debug_mode
        
        copy_LADCP(cfg, logfile);
        
    else
        
        waitbar((cfg.copy_CTD+cfg.process_CTD+cfg.copy_LADCP)/(counter+1), wbar, 'Copying LADCP data');
        
        % Test file exist
        newfileLADCPMraw = sprintf('%s', cfg.path_raw_LADCP, cfg.newfilename_LADCPM);
        newfileLADCPSraw = sprintf('%s', cfg.path_raw_LADCP, cfg.newfilename_LADCPS);
        newfileLADCPMprocess = sprintf('%s', cfg.path_processing_LADCP, cfg.newfilename_LADCPM);
        newfileLADCPSprocess = sprintf('%s', cfg.path_processing_LADCP, cfg.newfilename_LADCPS);
        
        if exist(newfileLADCPMraw,'file') && exist(newfileLADCPSraw,'file')...
                && exist(newfileLADCPMprocess,'file') && exist(newfileLADCPSprocess,'file')
            Quest_process = questdlg({'LADCP files exist !' 'Are you sure to make the process?'}, 'File exist', 'Yes', 'No', 'Yes');
            if strcmp(Quest_process,'Yes')
                [ind_error] = copy_LADCP(cfg, logfile);
            else
                close(wbar);
                return;
            end
        else
            [ind_error] = copy_LADCP(cfg, logfile);
        end
        
        if ~cfg.process_LADCP
            close(wbar);
        end
        
    end
end

% Process LADCP file

if cfg.process_LADCP
    
    if cfg.debug_mode
        
        process_LADCP(cfg, logfile);
        
    else
        
        if ind_error
            Quest_process = questdlg({'Some problems occued during the copying process !' 'Are you sure to continu?'}, 'File exist', 'Yes', 'No', 'Yes');
            if strcmp(Quest_process,'Yes')
                waitbar(counter/(counter+1), wbar, 'Processing LADCP file');
                process_LADCP(cfg, logfile);
            else
                close(wbar);
                return;
            end
        else
            waitbar(counter/(counter+1), wbar, 'Processing LADCP file');
            process_LADCP(cfg, logfile);
        end
    end
    
end

end
