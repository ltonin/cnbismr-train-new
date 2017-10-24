
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
settings.acq.sf = 300;
%settings.acq.channels_eeg = 19;
settings.acq.channels_eeg = 8;
settings.acq.channels_tri = 0;

settings.modules.smr.options.prep.dc  			= true; %% Wearable sensing needs this!!!!!!
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
settings.modules.smr.options.classification.artefacts = false;

settings.modules.wp4.datatype = 0;

%settings.modules.smr.montage = [0 1 0 1 0 ;...
%                                1 1 1 1 1; ...
%                                1 1 1 1 1; ...
%                                1 1 1 1 1; ...
%                                0 1 0 1 0];
settings.modules.smr.montage = [1 0 2;...
                                4 3 5;...
                                7 6 8];
settings.modules.smr.laplacian = ...
	eegc3_montage(settings.modules.smr.montage);

settings.modules.smr.options.prep.filter.z = [];
[settings.modules.smr.options.prep.filter.b,...
    settings.modules.smr.options.prep.filter.a] = ...
    butter(4,[1 40]./(settings.acq.sf/2), 'bandpass'); % Hardcode for now

settings.modules.smr.win.size 		= 1.00;
settings.modules.smr.win.shift		= 0.1; % 0.0625;

settings.modules.smr.psd.freqs		= [4:2:48];
settings.modules.smr.psd.win 		= 0.50;
settings.modules.smr.psd.ovl 		= 0.60;

settings.modules.smr.dp.threshold	= 0.50;

settings.modules.smr.gau.somunits 	= [1 1]; % QDA-style
settings.modules.smr.gau.sharedcov 	= 'f'; % No difference anyway
settings.modules.smr.gau.epochs 	= 50;
settings.modules.smr.gau.mimean		= 0.001;
settings.modules.smr.gau.micov		= 0.0001;
settings.modules.smr.gau.th         = 0.60;
settings.modules.smr.gau.terminate	= true;

%% EEG distribution params for artefact detection
settings.modules.smr.artefacts.zth	= 50;
settings.modules.smr.artefacts.mean	= [];
settings.modules.smr.artefacts.std	= [];
settings.modules.smr.artefacts.channels	= [1 2 13 14];

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