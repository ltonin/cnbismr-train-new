function bci = eegc3_smr_labelPSD(bci, protocol_label)

    if(strcmp(protocol_label,'SMR_Offline_eegc2'))
       
        current_lbl = -1;
        trial = 0;
        for i=1:length(bci.lbl)    
            trial = trial + 1;
            current_lbl = bci.lbl(i);
            % Use by default seconds 0-5 of each trial
            bci.lbl_sample(bci.evt(i) + round(0*bci.Sf):bci.evt(i) + round(5*bci.Sf)...
                - round(bci.settings.modules.smr.win.size * bci.Sf)) = current_lbl;
            bci.trial_idx(bci.evt(i) + round(0*bci.Sf):bci.evt(i) + round(5*bci.Sf)...
                - round(bci.settings.modules.smr.win.size * bci.Sf)) = trial;
        end
       
    elseif(strcmp(protocol_label,'SMR_Online_eegc2'))
       
        current_lbl = -1;
        trial = 0;
        for i=1:length(bci.lbl)
            
            if(bci.lbl(i) == 781)
                trial = trial + 1;
                bci.lbl_sample(bci.evt(i):bci.evt(i+1)) = current_lbl;
                bci.trial_idx(bci.evt(i):bci.evt(i+1)) = trial;
            elseif(bci.lbl(i) == 897 || bci.lbl(i) == 898)
                % Do nothing
            else
                current_lbl = bci.lbl(i);
            end
        end
        
    elseif(strcmp(protocol_label,'INC_eegc2'))
        
        current_lbl = -1;
        for i=1:length(bci.lbl)
            
            if(bci.lbl(i) == 781)
                bci.lbl_sample(bci.evt(i):bci.evt(i+1)) = current_lbl; 
            elseif(bci.lbl(i) == 758 || bci.lbl(i) == 768 || ...
                bci.lbl(i) == 897 || bci.lbl(i) == 898)
                % Do nothing
            else
                current_lbl = bci.lbl(i);
            end
        end
        
    elseif(strcmp(protocol_label,'SMR_Offline_eegc3'))
        
        trial = 0;
        for i=1:length(bci.lbl)
            
            if(bci.lbl(i) == 781)
                % New trial
                trial = trial + 1;
                bci.lbl_sample(bci.evt(i):bci.evt(i) + bci.dur(i)) = bci.lbl(i-1);
                bci.trial_idx(bci.evt(i):bci.evt(i) + bci.dur(i)) = trial;
            end
        end
        
    elseif(strcmp(protocol_label,'SMR_Online_eegc3'))
        
        trial = 0;
        for i=1:length(bci.lbl)
            
            if(bci.lbl(i) == 781)
                % New trial
                trial = trial + 1;
                bci.lbl_sample(bci.evt(i):bci.evt(i) + bci.dur(i)) = bci.lbl(i-1);
                bci.trial_idx(bci.evt(i):bci.evt(i) + bci.dur(i)) = trial;
            end
        end
    elseif(strcmp(protocol_label,'WP4_Online_eegc3'))      
        trial = 0;
        for i=1:length(bci.lbl)            
            if(bci.lbl(i) == 1)
                % Wait period used as rest
                trial = trial + 1;
                %bci.lbl_sample(bci.evt(i):bci.evt(i) + bci.dur(i)) = bci.lbl(i);
                bci.lbl_sample(bci.evt(i):bci.evt(i) + bci.dur(i)) = 783;
                bci.trial_idx(bci.evt(i):bci.evt(i) + bci.dur(i)) = trial;
            end
            if(bci.lbl(i) == 781)
                % New trial
                trial = trial + 1;
                bci.lbl_sample(bci.evt(i):bci.evt(i) + bci.dur(i)) = bci.lbl(i-1);
                bci.trial_idx(bci.evt(i):bci.evt(i) + bci.dur(i)) = trial;
            end
        end
    elseif(strcmp(protocol_label,'INCMT2_eegc3'))
        trial = 0;
        for i=1:length(bci.lbl)
            if (bci.lbl(i) == 768)
                trial = trial + 1;
                current_lbl = bci.lbl(i+1);
                start_pos = bci.evt(i+2);
            elseif(bci.lbl(i) == 758)
                end_pos = bci.evt(i);
                bci.trial_idx(start_pos:end_pos) = trial;
                bci.lbl_sample(start_pos:end_pos) = current_lbl;
            else
                % DO NOTHING
            end
        end
        
        
    else
        disp('Cannot retrieve protocol type...Exiting!');
        return;
    end
