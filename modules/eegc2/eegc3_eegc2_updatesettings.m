% 2010-11-26  Michele Tavella <michele.tavella@epfl.ch>
% 2010-11-26  Serafeim Perdikis <serafeim.perdikis@epfl.ch>

function settings = eegc3_eegc2_updatesettings(file_old, file_new)
% function sessions = eegc3_eegc2_updatesettings(file_old, file_new)
%
% Function that converts an obsolete eegc2 analysis structure (SMR 
% classifier MAT file) into an eegc3 settings structure (SMR classifier 
% eegc3-style). 
%
% Inputs:
%
% file_old: eegc2 analysis structure filepath
%
% file_new: eegc3 settings structure filename for saving. Settings 
% structure is saved in the current path. 
%
% Outputs:
%
% settings: eegc3-style SMR classifier derived by an eegc2 analysis

if(nargin < 2)
    file_new = [];
end

% Load analysis structure
if(ischar(file_old))
    % It is filepath
    old = load(file_old);
elseif(isstruct(file_old))
    % It is structure
    old.analysis = file_old;
else
    disp('[eegc3_eegc2_updatesettings] Unknown input, exiting');
    settings = [];
    return;
end

analysis = old.analysis;

% Initialize new structure
settings = eegc3_newsettings();
settings = eegc3_smr_newsettings(settings);

% List of remappings

settings.info.subject 				= analysis.info.subject;
settings.info.experimenter			= 'unknown';
settings.info.hostname				= 'unknown';
settings.info.date					= analysis.info.date;
settings.info.basename 				= analysis.info.basename;

settings.acq.id                     = 501; % gTec 16
settings.acq.sf                     = analysis.settings.eeg.fs;
settings.acq.channels_eeg			= analysis.settings.eeg.chs;
settings.acq.channels_exg           = 0;
settings.acq.channels_tri           = 1;

settings.modules.smr.options.prep.dc  				= ...
    analysis.options.prep.dc;
settings.modules.smr.options.prep.car 				= ...
    analysis.options.prep.car;
settings.modules.smr.options.prep.laplacian			= ...
    analysis.options.prep.laplacian;
settings.modules.smr.options.selection.dpt   		= ... 
    analysis.options.selection.dpt;
settings.modules.smr.options.selection.cva   		= ...
    analysis.options.selection.cva;
settings.modules.smr.options.selection.stability	= ...
    analysis.options.selection.stability;
settings.modules.smr.options.selection.usegui		= ...
    analysis.options.selection.usegui;
settings.modules.smr.options.classification.gau  	= ...
    analysis.options.classification.gau;

% Add edfault, since this filed was missing from analysis settings
settings.modules.smr.options.extraction.trials      = ...
    true;

settings.modules.smr.montage                        = ...
    analysis.settings.prep.montage;
settings.modules.smr.laplacian = ...
	analysis.settings.prep.laplacian;

settings.modules.smr.win.size                       = ...
    analysis.settings.features.win.size;
settings.modules.smr.win.shift                      = ...
    analysis.settings.features.win.shift;

settings.modules.smr.psd.freqs                      = ...
    analysis.settings.features.psd.freqs;	
settings.modules.smr.psd.win                        = ...
    analysis.settings.features.psd.win;
settings.modules.smr.psd.ovl                        = ...
    analysis.settings.features.psd.ovl;

settings.modules.smr.dp.threshold                   = ...
    analysis.settings.selection.dp.threshold;

settings.modules.smr.gau.somunits                   = ...
    analysis.settings.classification.gau.somunits;
settings.modules.smr.gau.sharedcov                  = ...
    analysis.settings.classification.gau.sharedcov;
settings.modules.smr.gau.epochs                     = ...
    analysis.settings.classification.gau.epochs;
settings.modules.smr.gau.mimean                     = ...
    analysis.settings.classification.gau.mimean;
settings.modules.smr.gau.micov                      = ...
    analysis.settings.classification.gau.micov;
settings.modules.smr.gau.th                         = ...
    analysis.settings.classification.gau.th;
settings.modules.smr.gau.terminate                  = ...
    analysis.settings.classification.gau.terminate;
settings.modules.smr.taskset.classes                = ...
    analysis.settings.task.classes_old;

settings.bci.smr.channels  = analysis.tools.features.channels;
settings.bci.smr.bands     = analysis.tools.features.bands;
settings.bci.smr.gau.M     = analysis.tools.net.gau.M;      
settings.bci.smr.gau.C     = analysis.tools.net.gau.C;

% Supporting potenital existence of Hamid's integration parameters
if(isfield(analysis.tools.net.gau, 'ConfMatBin'))
    settings.bci.smr.nbi.ComfMatBin = analysis.tools.net.gau.ConfMatBin;
end
if(isfield(analysis.tools.net.gau, 'ConfMat'))
    settings.bci.smr.nbi.ComfMat = analysis.tools.net.gau.ConfMat;
end
if(isfield(analysis.tools.net.gau, 'Beta'))
    settings.bci.smr.nbi.Beta = analysis.tools.net.gau.Beta;
end
    
% Remapping complete, save settings structure with provided filename
% Search if file_new filename has a '.mat' extension, if not add it
if(~isempty(file_new))
    if(~strcmp(file_new(end-3:end),'.mat'))
        file_new = [file_new '.mat'];
        save(file_new, 'settings');
    end
end
