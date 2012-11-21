function analysis = eegc3_eegc2_settings(subject, date)
% Edited by M. Tavella <michele.tavella@epfl.ch> on 16/07/09 15:55:55

analysis = {};

%% Infos are cool!
analysis.info.subject 					= subject;
analysis.info.date						= date;
analysis.info.basename 					= [analysis.info.date '_' analysis.info.subject];

%% General Options
analysis.options.prep.dc  				= true;
analysis.options.prep.car 				= false;
analysis.options.prep.laplacian			= true;

analysis.options.selection.dpt   		= false;
analysis.options.selection.cva   		= true;
analysis.options.selection.ecva  		= false;	% TODO
analysis.options.selection.stability	= true;	
analysis.options.selection.usegui		= true;

analysis.options.classification.gau  	= true;
analysis.options.classification.svm  	= false;
analysis.options.classification.lda  	= false;

analysis.options.save.workspace			= false;
analysis.options.save.analysis 			= true;
analysis.options.save.tdata	 			= false;
analysis.options.save.features 			= true;

%% EEG Settings
analysis.settings.eeg.fs				= 512;
analysis.settings.eeg.chs				= 16;

%% MI Task settings 
analysis.settings.task.onset 			= 1;
analysis.settings.task.duration			= 5;
% Edited by Tavella/Perdikis <michele.tavella@epfl.ch> 15/02/10 13:46:33
% We use 15 to ensure a decent stable selection!
analysis.settings.task.trialsperses		= 15;
analysis.settings.task.classes			= [1 3];
analysis.settings.task.online			= false;
analysis.settings.task.onlyHit			= true;

%% Preprocessing settings
analysis.settings.prep.montage 	= [0 0 1 0 0; 1 1 1 1 1; 1 1 1 1 1; 1 1 1 1 1];
analysis.settings.prep.laplacian = eegc3_laplacian_montage(...
	analysis.settings.prep.montage);

%% Feature extraction settings - Windowing
analysis.settings.features.win.size 	= 1.00;
analysis.settings.features.win.shift	= 0.0625;

%% Feature extraction settings - BP and Welch PSD
analysis.settings.features.bp.bands 	= eegc3_bands();
analysis.settings.features.psd.freqs	= [4:2:48];
analysis.settings.features.psd.win 		= 0.50;
analysis.settings.features.psd.ovl 		= 0.50;

%% Feature selection settings 
analysis.settings.selection.dp.threshold	= 0.50;

%% Classification settings 
analysis.settings.classification.gau.somunits 	= [2 2];
analysis.settings.classification.gau.sharedcov 	= 't';
analysis.settings.classification.gau.epochs 	= 20;
analysis.settings.classification.gau.mimean		= 0.00001  * 100;
analysis.settings.classification.gau.micov		= 0.000001 * 100;
analysis.settings.classification.gau.th			= 0.70;
analysis.settings.classification.gau.terminate	= true;
% Michele: 10/1000


analysis.settings.classification.svm.kernel		= 'linear';
analysis.settings.classification.svm.autoscale	= 0;
analysis.settings.classification.svm.epochs		= 100;
analysis.settings.classification.svm.th			= 0.50;

%% Save settings
analysis.settings.save.analysis  = [analysis.info.basename '_analysis.mat'];
analysis.settings.save.workspace = [analysis.info.basename '_workspace.mat'];
analysis.settings.save.tdata     = [analysis.info.basename '_tdata.mat'];
analysis.settings.save.features  = [analysis.info.basename '_features.mat'];

% Note by M.Tavella <michele.tavella@epfl.ch> on 29/08/09 11:37:04
% Tools keeps the classifiers and the feature selection results needed for
%online! 
analysis.tools = {};
