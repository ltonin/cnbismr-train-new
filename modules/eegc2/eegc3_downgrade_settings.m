% 2010-11-26  Michele Tavella <michele.tavella@epfl.ch>
% 2010-11-26  Serafeim Perdikis <serafeim.perdikis@epfl.ch>

function analysis = eegc3_downgrade_settings(file_new, file_old)
% function analysis = eegc3_downgrade_settings(file_new, file_old)
%
% Function that converts an eegc3 settings structure (SMR classifier 
% eegc3-style) to an obsolete eegc2 analysis structure (SMR 
% classifier MAT file) for backwards compatibility
%
% Inputs:
%
% file_new: eegc3 settings structure filename or struct
%
% file_old: eegc2 analysis structure filepath string for saving
%
% Outputs:
%
% analysis: eegc2-style SMR classifier (analysis)

if(nargin < 2)
    file_old = [];
end

% Load settings structure
if(ischar(file_new))
    % It is filepath
    new = load(file_new);
elseif(isstruct(file_new))
    % It is structure
    new.settings = file_new;
else
    disp('[eegc3_downgrade_settings] Unknown input, exiting');
    analysis = [];
    return;
end

settings = new.settings;

% Initialize new analysis structure
% TODO: retrieve date
analysis = eegc3_eegc2_settings(settings.info.subject, settings.info.date);

% List of remappings

analysis.info.subject               = settings.info.subject;
analysis.info.date                  = settings.info.date;
analysis.info.basename              = settings.info.basename;					
 				
analysis.settings.eeg.fs            = settings.acq.sf;
analysis.settings.eeg.chs           = settings.acq.channels_eeg;

analysis.options.prep.dc                            = ...
    settings.modules.smr.options.prep.dc;
analysis.options.prep.car                           = ...
    settings.modules.smr.options.prep.car;
analysis.options.prep.laplacian                     = ...
    settings.modules.smr.options.prep.laplacian;
analysis.options.selection.dpt                      = ... 
    settings.modules.smr.options.selection.dpt;
analysis.options.selection.cva                      = ...
    settings.modules.smr.options.selection.cva;
analysis.options.selection.stability                = ...
    settings.modules.smr.options.selection.stability;
analysis.options.selection.usegui                   = ...
    settings.modules.smr.options.selection.usegui;
analysis.options.selection.norm                     = ...
    settings.modules.smr.options.selection.norm;
analysis.options.classification.gau                 = ...
    settings.modules.smr.options.classification.gau;
analysis.options.classification.norm                 = ...
    settings.modules.smr.options.classification.norm;

analysis.settings.prep.montage                      = ...
    settings.modules.smr.montage;
analysis.settings.prep.laplacian                    = ...
	settings.modules.smr.laplacian;

analysis.settings.features.win.size                 = ...
    settings.modules.smr.win.size;
analysis.settings.features.win.shift                = ...
    settings.modules.smr.win.shift;

analysis.settings.features.psd.freqs                = ...
    settings.modules.smr.psd.freqs;	
analysis.settings.features.psd.win                  = ...
    settings.modules.smr.psd.win;
analysis.settings.features.psd.ovlX                 = ...
    analysis.settings.features.psd.ovl;

analysis.settings.selection.dp.threshold            = ...
    settings.modules.smr.dp.threshold;

analysis.settings.classification.gau.somunits       = ...
    settings.modules.smr.gau.somunits;
analysis.settings.classification.gau.sharedcov      = ...
    settings.modules.smr.gau.sharedcov;
analysis.settings.classification.gau.epochs         = ...
    settings.modules.smr.gau.epochs;
analysis.settings.classification.gau.mimean         = ...
    settings.modules.smr.gau.mimean;
analysis.settings.classification.gau.micov          = ...
    settings.modules.smr.gau.micov;
analysis.settings.classification.gau.th             = ...
    settings.modules.smr.gau.th;
analysis.settings.classification.gau.terminate      = ...
    settings.modules.smr.gau.terminate;

analysis.settings.task.classes_old                  = ...
    settings.bci.smr.taskset.classes;
if(length(settings.bci.smr.taskset.classes)==2)
    analysis.settings.task.classes                      = [1 3]; % For historical reasons...does not affect anything if you put [1 2], since classes_old isused in fact
elseif(length(settings.bci.smr.taskset.classes)==3)
    analysis.settings.task.classes                      = [1 2 3];
else
    analysis.settings.task.classes                      = [1 2 3 4];
end


analysis.tools.features.channels  = settings.bci.smr.channels;
analysis.tools.features.bands     = settings.bci.smr.bands;
analysis.tools.net.gau.M          = settings.bci.smr.gau.M;      
analysis.tools.net.gau.C          = settings.bci.smr.gau.C;

if(isfield(settings.bci.smr,'lda'))
    analysis.tools.lda.m_right    = settings.bci.smr.lda.m_right;
    analysis.tools.lda.m_left    = settings.bci.smr.lda.m_left;
    analysis.tools.lda.m_global    = settings.bci.smr.lda.m_global;
    analysis.tools.lda.cov_right    = settings.bci.smr.lda.cov_right;
    analysis.tools.lda.cov_left    = settings.bci.smr.lda.cov_left;
    analysis.tools.lda.cov_global    = settings.bci.smr.lda.cov_global;
    analysis.tools.lda.w    = settings.bci.smr.lda.w;
    analysis.tools.lda.Bias    = settings.bci.smr.lda.Bias;
    
    analysis.tools.lda.n_right    = settings.bci.smr.lda.n_right;
    analysis.tools.lda.n_left    = settings.bci.smr.lda.n_left;
    analysis.tools.lda.n_all    = settings.bci.smr.lda.n_all;
    analysis.tools.lda.rej_th    = settings.bci.smr.lda.rej_th;
end

if(isfield(settings.bci.smr,'sep'))
    analysis.tools.sep.m_right    = settings.bci.smr.sep.m_right;
    analysis.tools.sep.m_left    = settings.bci.smr.sep.m_left;
    analysis.tools.sep.m_right_sep    = settings.bci.smr.sep.m_right_sep;
    analysis.tools.sep.m_left_sep    = settings.bci.smr.sep.m_left_sep;
    analysis.tools.sep.m_global    = settings.bci.smr.sep.m_global;
    analysis.tools.sep.cov_right    = settings.bci.smr.sep.cov_right;
    analysis.tools.sep.cov_left    = settings.bci.smr.sep.cov_left;
    analysis.tools.sep.cov_right_sep    = settings.bci.smr.sep.cov_right_sep;
    analysis.tools.sep.cov_left_sep    = settings.bci.smr.sep.cov_left_sep;    
    analysis.tools.sep.cov_global    = settings.bci.smr.sep.cov_global;
    analysis.tools.sep.w    = settings.bci.smr.sep.w;
    analysis.tools.sep.Bias    = settings.bci.smr.sep.Bias;
    
    analysis.tools.sep.n_right    = settings.bci.smr.sep.n_right;
    analysis.tools.sep.n_left    = settings.bci.smr.sep.n_left;
    analysis.tools.sep.n_all    = settings.bci.smr.sep.n_all;
    analysis.tools.sep.rej_th    = settings.bci.smr.sep.rej_th;
end

% Supporting potenital existence of Hamid's integration parameters
if(isfield(settings.bci.smr,'nbi'))
    if(isfield(settings.bci.smr.nbi, 'ConfMatBin'))
        analysis.tools.net.gau.ConfMatBin = settings.bci.smr.nbi.ComfMatBin;
    end
    if(isfield(settings.bci.smr.nbi, 'ConfMat'))
        analysis.tools.net.gau.ConfMat = settings.bci.smr.nbi.ComfMat;
    end
    if(isfield(settings.bci.smr.nbi, 'Beta'))
        analysis.tools.net.gau.Beta = settings.bci.smr.nbi.Beta;
    end
end
    
% Remapping complete, save settings structure with provided filename
% Search if file_new filename has a '.mat' extension, if not add it
if(~isempty(file_old))
    if(~strcmp(file_old(end-3:end),'.mat'))
        file_old = [file_old '.mat'];
        save(file_old, 'analysis');
    end
end
