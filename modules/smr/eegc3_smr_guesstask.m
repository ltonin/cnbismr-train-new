function [taskset, resetevents, protocol_label] = eegc3_smr_guesstask(labels, settings)
% 2013  Andrea Biasiucci <andrea.biasiucci@epfl.ch>
% 2010  Michele Tavella <michele.tavella@epfl.ch>

taskset = [];
resetevents = [];

[cues, protocol] = eegc3_smr_newevents();

ulabels = unique(labels);

has.cfeedbackoff  = false;
has.cfeedback  = false;
has.targetmiss = false;
has.targethit  = false;
has.inc        = false;
has.cross      = false;
has.trialend      = false;

l = ulabels;
has.cfeedback = has.cfeedback || ismember(protocol.cfeedback, l);
has.cfeedbackoff = has.cfeedbackoff || ismember(protocol.cfeedbackoff, l);
has.targethit = has.targethit || ismember(protocol.targethit, l);
has.targetmiss = has.targetmiss || ismember(protocol.targetmiss, l);
has.inc = has.inc || ismember(protocol.inc, l);
has.cross = has.cross || ismember(protocol.cross, l);
has.trialend = has.trialend || ismember(protocol.trialend, l);

Nr_BCI_cues = length(intersect(ulabels,struct2array(cues)));

printf('[eegc3_smr_guesstask] Guessing protocol: ');

if(has.inc)
    
    if(has.trialend)
        protocol_label = 'INCMT2_eegc3';
        printf('INCMT2 online [eegc v3]\n');
        resetevents = ...
            [protocol.cfeedback protocol.targethit protocol.targetmiss];
    else
        % Old INC protocol
        protocol_label = 'INC_eegc2';
        printf('INC online [eegc v2]\n');
        resetevents = ...
            [protocol.cfeedback protocol.targethit protocol.targetmiss];
    end
    
else
    
    if(has.cross)
        
        % New loop eegc3 protocols
        if(has.targetmiss || has.targethit)
            if isfield(settings.modules,'wp4')
                protocol_label = 'WP4_Online_eegc3';
                printf('WP4 online [eegc v3]\n');
                resetevents = ...
                    [protocol.cfeedback protocol.targethit protocol.targetmiss];
            else
                protocol_label = 'SMR_Online_eegc3';
                printf('SMR online [eegc v3]\n');
                resetevents = ...
                    [protocol.cfeedback protocol.targethit protocol.targetmiss];
            end
        else

            if(settings.modules.wp4.datatype==1) % Hack for WP4 with only timeouts
                protocol_label = 'WP4_Online_eegc3';
                printf('WP4 online [eegc v3]\n');
                resetevents = ...
                    [protocol.cfeedback protocol.targethit protocol.targetmiss];
            else
                protocol_label = 'SMR_Offline_eegc3';
                printf('SMR offline [eegc v3]\n');
            end

        end
    else
        
        % Old loop eegc2 protocols
        if(has.cfeedback)
            protocol_label = 'SMR_Online_eegc2';
            printf('SMR online [eegc v2]\n');
            resetevents = ...
                [protocol.cfeedback protocol.targethit protocol.targetmiss];
        else
            protocol_label = 'SMR_Offline_eegc2';
            printf('SMR offline [eegc v2]\n');
        end
        
    end
    
end

did.right_hand_mi 	= false;
did.left_hand_mi 	= false;
did.both_hands_mi 	= false;
did.both_hands_both_feet_mi = false;
did.both_feet_mi 	= false;
did.rest_mi 		= false;
did.tongue_mi 		= false;

for l = ulabels
    did.right_hand_mi 	= did.right_hand_mi || (l == cues.right_hand_mi);
    did.left_hand_mi 	= did.left_hand_mi || (l == cues.left_hand_mi);
    did.both_hands_mi 	= did.both_hands_mi || (l == cues.both_hands_mi);
    did.both_hands_both_feet_mi 	= did.both_hands_both_feet_mi || (l == cues.both_hands_both_feet_mi);
    did.both_feet_mi 	= did.both_feet_mi || (l == cues.both_feet_mi);
    did.rest_mi 		= did.rest_mi || (l == cues.rest_mi);
    did.tongue_mi 		= did.tongue_mi || (l == cues.tongue_mi);
end
                
printf('[eegc3_smr_guesstask] Guessing taskset:  ');
taskset.cues = zeros(1, 16);
while(true)
    if(did.right_hand_mi && did.left_hand_mi && did.both_feet_mi && did.rest_mi)
        printf('rlfr\n');
        taskset.cues(1) = cues.right_hand_mi;
        taskset.cues(2) = cues.left_hand_mi;
        taskset.cues(3) = cues.rest_mi;
        taskset.cues(4) = cues.both_feet_mi;
        break;
    end
    if(did.both_hands_mi && did.both_feet_mi && did.both_hands_both_feet_mi && did.rest_mi)
        printf('bhbfallrst\n');
        taskset.cues(1) = cues.both_hands_mi;
        taskset.cues(2) = cues.both_feet_mi;
        taskset.cues(3) = cues.rest_mi;
        taskset.cues(4) = cues.both_hands_both_feet_mi;
        break;
    end
    if(did.both_hands_mi && did.both_feet_mi && did.both_hands_both_feet_mi)
        printf('bhbfall\n');
        taskset.cues(1) = cues.both_hands_mi;
        taskset.cues(2) = cues.both_feet_mi;
        taskset.cues(3) = cues.both_hands_both_feet_mi;
        break;
    end        
    if(did.right_hand_mi && did.left_hand_mi && did.both_feet_mi && did.tongue_mi)
        printf('rltf\n');
        taskset.cues(1) = cues.right_hand_mi;
        taskset.cues(2) = cues.left_hand_mi;
        taskset.cues(3) = cues.tongue_mi;
        taskset.cues(4) = cues.both_feet_mi;
        break;
    end
    if(did.right_hand_mi && did.left_hand_mi && did.both_feet_mi)
        printf('rlbf\n');
        taskset.cues(1) = cues.right_hand_mi;
        taskset.cues(2) = cues.left_hand_mi;
        taskset.cues(3) = cues.both_feet_mi;
        break;
    end
    if(did.right_hand_mi && did.left_hand_mi)
        if(did.rest_mi)
            printf('rhlhrest\n');
            taskset.cues(1) = cues.right_hand_mi;
            taskset.cues(2) = cues.left_hand_mi;
            taskset.cues(3) = cues.rest_mi;
        else
            printf('rhlh\n');
            taskset.cues(1) = cues.right_hand_mi;
            taskset.cues(2) = cues.left_hand_mi;
        end
        
        break;
    end
    if(did.both_feet_mi && did.left_hand_mi)
        printf('bflh\n');
        taskset.cues(1) = cues.both_feet_mi;
        taskset.cues(2) = cues.left_hand_mi;
        break;
    end
    if(did.both_feet_mi && did.right_hand_mi)
        printf('rhbf\n');
        taskset.cues(1) = cues.right_hand_mi;
        taskset.cues(2) = cues.both_feet_mi;
        break;
    end
    if(did.both_feet_mi && did.both_hands_mi)
        printf('bhbf\n');
        taskset.cues(1) = cues.both_hands_mi;
        taskset.cues(2) = cues.both_feet_mi;
        break;
    end
    if((did.right_hand_mi && did.rest_mi) || ...
            (did.right_hand_mi && ~did.rest_mi && ~did.left_hand_mi ...
            && ~did.both_feet_mi && ~did.both_hands_mi))
        printf('rhrst\n');
        taskset.cues(1) = cues.right_hand_mi;
        taskset.cues(2) = cues.rest_mi;
        break;
    end
    if( (did.left_hand_mi && did.rest_mi) || ...
            (did.left_hand_mi && ~did.rest_mi && ~did.right_hand_mi ...
            && ~did.both_feet_mi && ~did.both_hands_mi))
        printf('lhrst\n');
        taskset.cues(1) = cues.rest_mi;
        taskset.cues(2) = cues.left_hand_mi;
        break;
    end
%     if(did.right_hand_mi && did.rest_mi)
%         printf('rhrst\n');
%         taskset.cues(1) = cues.right_hand_mi;
%         taskset.cues(2) = cues.rest_mi;
%         break;
%     end
%     if(did.left_hand_mi && did.rest_mi) 
%         printf('lhrst\n');
%         taskset.cues(1) = cues.rest_mi;
%         taskset.cues(2) = cues.left_hand_mi;
%         break;
%     end
%     if(did.right_hand_mi && has.cross) 
%         printf('rhcross\n');
%         taskset.cues(1) = cues.right_hand_mi;
%         taskset.cues(2) = 786;
%         break;
%     end
%     if(did.left_hand_mi && has.cross) 
%         printf('lhcross\n');
%         taskset.cues(1) = 786;
%         taskset.cues(2) = cues.left_hand_mi;
%         break;
%     end
    break;
end



taskset.bar.right = taskset.cues(1);
taskset.bar.left  = taskset.cues(2);
taskset.bar.up    = taskset.cues(3);
taskset.bar.down  = taskset.cues(4);
taskset.cues = taskset.cues(taskset.cues > 0);
taskset.tot = length(taskset.cues);


g = [2 72 0]/255;
r = [201 49 43]/255;
b = [0 27 91]/255;
y = [184 71 0]/255;
switch(taskset.tot)
    case 4
        taskset.colors = {r b g y};
    case 3
        taskset.colors = {r b g};
    case 2
        taskset.colors = {r b};
end

