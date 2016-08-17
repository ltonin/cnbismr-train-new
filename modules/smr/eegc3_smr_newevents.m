% 2010-11-27  Michele Tavella <michele.tavella@epfl.ch>
function [cues, protocol, compat] = eegc3_smr_newevents()

protocol = {};
protocol.off 				= hex2dec('8000');
protocol.inc 				= hex2dec('030a');
protocol.trial 				= hex2dec('0300');
protocol.trialoff 			= hex2dec('8300');
protocol.cfeedback 			= hex2dec('030d');
protocol.cfeedbackoff 		= hex2dec('830d');
protocol.targethit 			= hex2dec('0381');
protocol.targetmiss 		= hex2dec('0382');
protocol.cross 				= hex2dec('0312');
protocol.beep 				= hex2dec('0311');
protocol.cueundef 			= hex2dec('030f');
protocol.trialbegin 		= hex2dec('0300');
protocol.trialend 			= hex2dec('02f6'); % Will become 8300

cues = {};
cues.right_hand_mi 			= hex2dec('0302');
cues.left_hand_mi 			= hex2dec('0301');
cues.both_hands_mi 			= hex2dec('0305');
cues.both_feet_mi 			= hex2dec('0303');
cues.both_hands_both_feet_mi= hex2dec('0306');
cues.rest_mi 				= hex2dec('030f');
cues.tongue_mi 				= hex2dec('0304');
cues.errp_detected 			= hex2dec('030b');
cues.errp_notdetected 		= hex2dec('030c');
cues.inc                    = hex2dec('030a');
cues.mi_onset_detected 		= hex2dec('010');
cues.mi_onset_notdetected	= hex2dec('011');

compat = {};
compat.protocol.trialoff 	= hex2dec('02F6');
