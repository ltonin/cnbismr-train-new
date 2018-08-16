function settings = eegc3_smr_newsettings(settings)
%
% function settings = eegc3_smr_newsettings()
%
% Function to create default settings structure for the SMR CNBI BCI
%
% Inputs: 
%
% None
%
% Outputs:
%
% settings: MATLAB structure holding settings information about feature
% extraction, feature selection, classification as well as the classifier
% parameters for a CNBI classifier. This function prepares the default
% settings for the SMR BCI
%



% Default gTec SMR BCI
settings.acq.id = 501;
settings.acq.sf = 512;
settings.acq.channels_eeg = 32;
% settings.acq.channel_lbl = {'FP1', 'FPZ',  'FP2', 'F7', 'F3', 'FZ', 'F4',...
%     'F8', 'FC5', 'FC1', 'FC2', 'FC6', 'M1', 'T7','C3', 'CZ', 'C4', 'T8',...
%     'M2', 'CP5', 'CP1', 'CP2', 'CP6', 'P7', 'P3', 'PZ', 'P4', 'P8', 'POZ',...
%     'O1', 'OZ', 'O2', 'AF7', 'AF3', 'AF4', 'AF8', 'F5', 'F1', 'F2', 'F6',...
%     'FC3', 'FCZ', 'FC4', 'C5',  'C1', 'C2', 'C6', 'CP3', 'CPZ', 'CP4', 'P5',...
%     'P1', 'P2', 'P6', 'PO5', 'PO3', 'PO4', 'PO6', 'FT7', 'FT8', 'TP7', 'TP8',...
%     'PO7','PO8'};

% gUSBAmp 32 - Motor Imagery
%settings.acq.channel_lbl = {'Fz','FC3','FC1','FCz','FC2','FC4','C3','C1','Cz','C2','C4','CP3',...
%    'CP1','CPz','CP2','CP4','F1','F2','FC5','FC6','C5','C6','CP5','CP6',...
%    'P5','P3','P1','Pz','P2','P4','P6','POz'};

% AntNeuro 32-channel on 64-channel cap standard layout
settings.acq.channel_lbl = {'Fz', 'FC5', 'FC1', 'FC2', 'FC6', 'C3', 'Cz', 'C4',  ...
							'CP5', 'CP1', 'CP2', 'CP6', 'P3', 'Pz', 'P4', 'POz', ...
							'EOG', 'F1', 'F2', 'FC3', 'FCz', 'FC4', 'C5', 'C1',  ...
							'C2', 'C6', 'CP3', 'CP4', 'P5', 'P1', 'P2', 'P6'};

% AntNeuro 32 channel standard layout (correct electrodes order)
%settings.acq.channel_lbl = {'Fp1','Fpz','Fp2','F7','F3','Fz','F4','F8',...
%    'FC5','FC1','FC2','FC6','M1','T7','C3','Cz','C4','T8','M2','CP5','CP1',...
%    'CP2','CP6','P7','P3','Pz','P4','P8','POz','O1','Oz','O2'};

% AntNeuro 32 channel standard layout (wrong electrodes order)
%settings.acq.channel_lbl = {'Fz','FC5','FC1','FC2','FC6','C3','Cz','C4',...
%    'CP5','CP1','CP2','CP6','P3','Pz','P4','M1','Fp1','Fpz','Fp2','F7','F3',...
%    'F4','F8','T7','T8','P7','P8','POz','O1','Oz','O2','M2'};

settings.acq.channels_tri = 1;

settings.modules.smr.options.prep.dc  			= true;
settings.modules.smr.options.prep.car 			= false;
settings.modules.smr.options.prep.laplacian		= true;
settings.modules.smr.options.prep.filter.f             = true;
settings.modules.smr.options.extraction.trials 		= false;
settings.modules.smr.options.extraction.fast 		= true;
settings.modules.smr.options.selection.dpt   		= false;
settings.modules.smr.options.selection.cva   		= true;
settings.modules.smr.options.selection.stability	= true;	
settings.modules.smr.options.selection.norm     	= false;
settings.modules.smr.options.selection.usegui		= true;
settings.modules.smr.options.classification.norm  	= false;
settings.modules.smr.options.classification.gau  	= true;
settings.modules.smr.options.classification.lda  	= false;
settings.modules.smr.options.classification.sep  	= false;
settings.modules.smr.options.classification.single 	= false;
%settings.modules.smr.options.classification.artefacts = true;

settings.modules.wp4.datatype = 0;

%settings.modules.smr.montage = [0 1 0 1 0 ;...
%                                1 1 1 1 1; ...
%                                1 1 1 1 1; ...
%                                1 1 1 1 1; ...
%                                0 1 0 1 0];
% settings.modules.smr.montage = [     0     0     0     1     2     3     0     0     0; ...
%     33     0    34     0     0     0    35     0    36;...
%      4    37     5    38     6    39     7    40     8;...
%     59     9    41    10    42    11    43    12    60;...
%     14    44    15    45    16    46    17    47    18;...
%     61    20    48    21    49    22    50    23    62;...
%     24    51    25    52    26    53    27    54    28;...
%     63    55    56     0    29     0    57    58    64;...
%      0     0     0    30    31    32     0     0     0];
settings.modules.smr.montage = eegc3_channels2montage(settings.acq.channel_lbl);

settings.modules.smr.laplacian = ...
	eegc3_montage(settings.modules.smr.montage); % HARDCODE NORMAL CROSS
	%eegc3_montage(settings.modules.smr.montage,'X'); % HARDCODE THE PATTERN FOR NOW

settings.modules.smr.options.prep.filter.z = [];
[settings.modules.smr.options.prep.filter.b,...
    settings.modules.smr.options.prep.filter.a] = ...
    butter(4,[1 40]./(settings.acq.sf/2), 'bandpass'); % Hardcode for now

settings.modules.smr.win.size 		= 1.00;
settings.modules.smr.win.shift		= 0.0625;

settings.modules.smr.psd.freqs		= [4:2:48];
settings.modules.smr.psd.win 		= 0.50;
settings.modules.smr.psd.ovl 		= 0.50;

settings.modules.smr.dp.threshold	= 0.50;

settings.modules.smr.gau.somunits 	= [1 1]; % QDA-style
settings.modules.smr.gau.sharedcov 	= 'f'; % No difference anyway
settings.modules.smr.gau.epochs 	= 50;
settings.modules.smr.gau.mimean		= 0.001;
settings.modules.smr.gau.micov		= 0.0001;
settings.modules.smr.gau.th         = 0.60;
settings.modules.smr.gau.terminate	= true;

% %% EEG distribution params for artefact detection
% settings.modules.smr.artefacts.zth	= 50;
% settings.modules.smr.artefacts.mean	= [];
% settings.modules.smr.artefacts.std	= [];
% settings.modules.smr.artefacts.channels	= [1 2 13 14];

% LDA settings
settings.modules.smr.lda.priors	= [0.5 0.5];
settings.modules.smr.lda.loss	= [0 1;1 0];
settings.modules.smr.lda.fstd	= 1;
settings.modules.smr.lda.shrink	= true;
settings.modules.smr.lda.reject	= true;

% Sep settings
settings.modules.smr.sep.priors	= [0.5 0.5];
settings.modules.smr.sep.loss	= [0 1;1 0];
settings.modules.smr.sep.reject	= true;
settings.modules.smr.sep.shrink	= true;
settings.modules.smr.sep.rej_th	= 2.0;

settings.modules.smr.sep.priors	= [0.5 0.5];
settings.modules.smr.sep.loss	= [0 1;1 0];
settings.modules.smr.single.rej_th	= 2.0;


settings.bci.smr.channels  = [];
settings.bci.smr.bands     = {};
settings.bci.smr.gau.M   = [];
settings.bci.smr.gau.C   = [];


% GDF Files used for this classifier
settings.bci.smr.trace.Paths = {};

% Taskset (modality) of this classifier
settings.bci.smr.taskset.modality = '';
settings.modules.smr.taskset.classes  = [0 0];
