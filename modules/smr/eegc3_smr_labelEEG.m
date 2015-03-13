function data = eegc3_smr_labelEEG(data, protocol_label, settings)

    if(strcmp(protocol_label,'SMR_Offline_eegc2'))
       
        current_lbl = -1;
        trial = 0;
        for i=1:length(data.lbl)    
            trial = trial + 1;
            current_lbl = data.lbl(i);
            % Use by default seconds 0-5 of each trial
            data.lbl_sample(data.pos(i) + 0*settings.acq.sf:...
                data.pos(i) + 5*settings.acq.sf) = current_lbl;
            data.trial_idx(data.pos(i) + 0*settings.acq.sf:...
                data.pos(i) + 5*settings.acq.sf) = trial;
        end
       
    elseif(strcmp(protocol_label,'SMR_Online_eegc2'))
       
        current_lbl = -1;
        trial = 0;
        for i=1:length(data.lbl)
            
            if(data.lbl(i) == 781)
                trial = trial + 1;
                data.lbl_sample(data.pos(i):data.pos(i+1)) = current_lbl;
                data.trial_idx(data.pos(i):data.pos(i+1)) = trial;
            elseif(data.lbl(i) == 897 || data.lbl(i) == 898)
                % Do nothing
            else
                current_lbl = data.lbl(i);
            end
        end
        
    elseif(strcmp(protocol_label,'INC_eegc2'))
        
        current_lbl = -1;
        for i=1:length(data.lbl)
            
            if(data.lbl(i) == 781)
                data.lbl_sample(data.pos(i):data.pos(i+1)) = current_lbl; 
            elseif(data.lbl(i) == 758 || data.lbl(i) == 768 || ...
                data.lbl(i) == 897 || data.lbl(i) == 898)
                % Do nothing
            else
                current_lbl = data.lbl(i);
            end
        end
        
    elseif(strcmp(protocol_label,'SMR_Offline_eegc3'))
        
        trial = 0;
        for i=1:length(data.lbl)
            
            if(data.lbl(i) == 781)
                % New trial
                trial = trial + 1;
                data.lbl_sample(data.pos(i):data.pos(i) + data.dur(i)) = data.lbl(i-1);
                data.trial_idx(data.pos(i):data.pos(i) + data.dur(i)) = trial;
            end
        end
        
    elseif(strcmp(protocol_label,'SMR_Online_eegc3'))
        
        trial = 0;
        for i=1:length(data.lbl)
            
            if(data.lbl(i) == 781)
                % New trial
                trial = trial + 1;
                data.lbl_sample(data.pos(i):data.pos(i) + data.dur(i)) = data.lbl(i-1);
                data.trial_idx(data.pos(i):data.pos(i) + data.dur(i)) = trial;
            end
        end
    elseif(strcmp(protocol_label,'WP4_Online_eegc3'))
        
        trial = 0;
        for i=1:length(data.lbl)
            
            if(data.lbl(i) == 1)
                % Wait period used as rest
                trial = trial + 1;
                %data.lbl_sample(data.pos(i):data.pos(i) + data.dur(i)) = data.lbl(i);
                data.lbl_sample(data.pos(i):data.pos(i) + data.dur(i)) = 783;
                data.trial_idx(data.pos(i):data.pos(i) + data.dur(i)) = trial;
            end
            if(data.lbl(i) == 781)
                % New trial
                trial = trial + 1;
                data.lbl_sample(data.pos(i):data.pos(i) + data.dur(i)) = data.lbl(i-1);
                data.trial_idx(data.pos(i):data.pos(i) + data.dur(i)) = trial;
            end
        end
    elseif(strcmp(protocol_label,'INCMT2_eegc3'))
        trial = 0;
        for i=1:length(data.lbl)
            if (data.lbl(i) == 768)
                trial = trial + 1;
                current_lbl = data.lbl(i+1);
                start_pos = data.pos(i+2);
            elseif(data.lbl(i) == 758)
                end_pos = data.pos(i);
                data.trial_idx(start_pos:end_pos) = trial;
                data.lbl_sample(start_pos:end_pos) = current_lbl;
            else
                % DO NOTHING
            end
        end
        
        
    else
        disp('Cannot retrieve protocol type...Exiting!');
        return;
    end
