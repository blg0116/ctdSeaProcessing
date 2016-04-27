%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessing software for CTD-LADCP                                     %
% Autor: Pierre Rousselot / Date: 10/03/16                                 %
% Jedi master: Jacques Grelet                                              %
% -> Launch processing                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function launch_processing(p)

%% Open log file
logfile = fopen(p.log_filename, 'wt');
counter = p.copyctd+p.processctd+p.copyadcp+p.processadcp;
wbar    = waitbar(0, 'CTD-LADCP PreProcessing');
if p.debug_mode
    close(wbar)
end

%% CTD
% Copy CTD file
if p.copyctd
        % Test file exist
        p.filenameCTD    = sprintf('%s', p.id_mission, p.num_station);
        fileRawCtd_hex    = sprintf('%s', p.path_rawCTD, p.filenameCTD, '.hex');   
        
    if p.debug_mode    
        
        copy_CTD(p, logfile);
        
    else
        
        waitbar(p.copyctd/(counter+1), wbar, 'Copying CTD data');        
        if exist(fileRawCtd_hex,'file')
            Quest_process = questdlg({'CTD files exist !' 'Are you sure to make the process?'}, 'File exist', 'Yes', 'No', 'Yes');
            if strcmp(Quest_process,'Yes')
            copy_CTD(p, logfile);
            else
            close(wbar);
            return;
            end
        else
        copy_CTD(p, logfile);  
        end
    
    end

    
end

% Process CTD file
if p.processctd
    
        time_wbar=(p.copyctd+p.processctd)/(counter+1);    
        
    if p.debug_mode   

        process_CTD(p, logfile, wbar, time_wbar);
    
    else
        
        waitbar((p.copyctd+p.processctd)/(counter+1), wbar, 'Processing CTD file');
        process_CTD(p, logfile, wbar, time_wbar);
    
        if ~p.copyadcp
        close(wbar);
        end
        
    end
end

%% ADCP
% Copy ADCP file
if p.copyadcp
    
    if p.debug_mode   
        
        copy_ADCP(p, logfile);
    
    else
        
        waitbar((p.copyctd+p.processctd+p.copyadcp)/(counter+1), wbar, 'Copying ADCP data');
    
        % Test file exist    
        newfileADCPMraw = sprintf('%s',p.path_rawADCP,p.newfilename_ADCPM);
        newfileADCPSraw = sprintf('%s',p.path_rawADCP,p.newfilename_ADCPS);
        newfileADCPMprocess = sprintf('%s',p.path_processADCP,p.newfilename_ADCPM);
        newfileADCPSprocess = sprintf('%s',p.path_processADCP,p.newfilename_ADCPS);
        if exist(newfileADCPMraw,'file') && exist(newfileADCPSraw,'file')...
            && exist(newfileADCPMprocess,'file') && exist(newfileADCPSprocess,'file')
            Quest_process = questdlg({'ADCP files exist !' 'Are you sure to make the process?'}, 'File exist', 'Yes', 'No', 'Yes');   
            if strcmp(Quest_process,'Yes')
                copy_ADCP(p, logfile);
            else
                close(wbar);
                return;
            end
        else
            copy_ADCP(p, logfile);
        end
        
    end
end

% Process ADCP file
if p.processadcp
    
    if p.debug_mode
    
        process_ADCP(p, logfile);
        
    else
        
        waitbar(counter/(counter+1), wbar, 'Processing ADCP file');
        process_ADCP(p, logfile);  
        
    end
    
end

end