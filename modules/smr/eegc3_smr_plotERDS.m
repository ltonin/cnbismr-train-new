function eegc3_smr_plotPSD(bci, GDFName, config, taskset, info)

% eegc3_smr_plotPSD(bci, GDFName, config, taskset, info)
%
% Function to plot the PSDs for all channels of a run
% Iputs: 
%
% bci: MATLAB struct created by eegc3_smr_simloop for some run (GDF file)
% f: Frequency support for the plotting
% runid: 
% GDFname: String with the filename of this run
% config: Matrix representing spatial configuration of electrodes
%
% Outputs: None, just the plot for this run
%
%

% Find number of channels
Nelec = bci.settings.acq.channels_eeg;
freqs = bci.settings.modules.smr.psd.freqs;
trial_length = bci.dur(4)+1; % Continuous control event
CLOW = -7;
CHIGH = 7;
% new_colormap = 'GrMg_16';
new_colormap = 'BuDRd_18';
% Consider 0.5 seconds pretrial
preTime = 16;

% Plot all channels
if(nargin < 3 || length(find(config==1))~= Nelec)
    Ncol = floor(sqrt(Nelec));
    if(mod(Nelec,Ncol)==0)
        Nrows = Nelec/Ncol;
        PosMat = ones(Nrows,Ncol);
    else
        Nrows = floor(Nelec/Ncol) + 1;
        PosMat = ones(Nrows-1,Ncol);
        Nrest = mod(Nelec,Ncol);
        PosMat = [PosMat; [ones(1,Nrest) zeros(1,Ncol-Nrest)]];
    end
else
    Ncol = size(config,2);
    Nrows = size(config,1);
    PosMat = config;
end
% 
% % In the case of WP4 online data, we only have 1 class, either 770 or 771
% if (bci.MI.task(1) == 783 || bci.MI.task(2) == 783)
%         bci.MI.task = setdiff(bci.MI.task,783);
% end


%%% Average PSDs
%% MI Right 770
tmp_idx = find(bci.lbl_sample ==  bci.MI.task(1));
tmp_trials_number = length(tmp_idx)/trial_length;
% include 0.5s of preparation
tmp_prep_idx = [];
tmp_evt = bci.evt(find(bci.lbl == 770));
tmp_Ntr = length(find(bci.lbl == 770));
for i = 1: tmp_Ntr
    tmp_prep_idx = [tmp_prep_idx tmp_evt(i)-((1:preTime) -3)];
end
tmp_idx = [tmp_prep_idx tmp_idx'];
% Spectrogram
tmp_spectrogram = bci.afeats(tmp_idx,:,:);
tmp_spectrogram = reshape(tmp_spectrogram,...
    [tmp_trials_number, trial_length+preTime, length(freqs), Nelec]);
avg_spectrogram_right = squeeze((mean(tmp_spectrogram)));

% ERD/S - alpha: 8-12Hz, beta: 18-28Hz
tmp_avg_spectrogram = avg_spectrogram_right;
alpha = 3:5;
beta = 8:13;
tmp_avg_erds_baseline_alpha = squeeze(mean(mean(tmp_avg_spectrogram(1:preTime,alpha,:),2)));
tmp_avg_erds_baseline_beta = squeeze(mean(mean(tmp_avg_spectrogram(1:preTime,beta,:),2)));
tmp_avg_erds_alpha =  squeeze(mean(tmp_avg_spectrogram(:,alpha,:),2));
tmp_avg_erds_beta = squeeze(mean(tmp_avg_spectrogram(:,beta,:),2));

avg_erds_alpha_right = zeros(size(tmp_avg_erds_alpha));
avg_erds_beta_right = zeros(size(tmp_avg_erds_beta));
for el = 1:Nelec
    avg_erds_alpha_right(:,el) = (tmp_avg_erds_alpha(:,el) - tmp_avg_erds_baseline_alpha(el))./tmp_avg_erds_baseline_alpha(el) * 100;
    avg_erds_beta_right(:,el) = (tmp_avg_erds_beta(:,el) - tmp_avg_erds_baseline_beta(el))./tmp_avg_erds_baseline_beta(el)*100;
end

%% MI Left 769
tmp_idx = find(bci.lbl_sample ==  bci.MI.task(2));
tmp_trials_number = length(tmp_idx)/trial_length;

% include 0.5s of preparation
tmp_prep_idx = [];
tmp_evt = bci.evt(find(bci.lbl == 769));
tmp_Ntr = length(find(bci.lbl == 769));
for i = 1: tmp_Ntr
    tmp_prep_idx = [tmp_prep_idx tmp_evt(i)-((1:preTime) -3)];
end
tmp_idx = [tmp_prep_idx tmp_idx'];
% Spectrogram
tmp_spectrogram = bci.afeats(tmp_idx,:,:);
tmp_spectrogram = reshape(tmp_spectrogram,...
    [tmp_trials_number, trial_length+preTime, length(freqs), Nelec]);
avg_spectrogram_left = squeeze((mean(tmp_spectrogram)));


% ERD/S - alpha: 8-12Hz, beta: 18-28Hz
tmp_avg_spectrogram = avg_spectrogram_left;
alpha = 3:5;
beta = 8:13;
tmp_avg_erds_baseline_alpha = squeeze(mean(mean(tmp_avg_spectrogram(1:preTime,alpha,:),2)));
tmp_avg_erds_baseline_beta = squeeze(mean(mean(tmp_avg_spectrogram(1:preTime,beta,:),2)));
tmp_avg_erds_alpha =  squeeze(mean(tmp_avg_spectrogram(:,alpha,:),2));
tmp_avg_erds_beta = squeeze(mean(tmp_avg_spectrogram(:,beta,:),2));

avg_erds_alpha_left = zeros(size(tmp_avg_erds_alpha));
avg_erds_beta_left = zeros(size(tmp_avg_erds_beta));
for el = 1:Nelec
    avg_erds_alpha_left(:,el) = (tmp_avg_erds_alpha(:,el)-tmp_avg_erds_baseline_alpha(el))./tmp_avg_erds_baseline_alpha(el)*100;
    avg_erds_beta_left(:,el) = (tmp_avg_erds_beta(:,el)-tmp_avg_erds_baseline_beta(el))./tmp_avg_erds_baseline_beta(el)*100;
end

%% MI Rest
tmp_idx = find(bci.lbl_sample ==  bci.MI.task(3));
tmp_trials_number = length(tmp_idx)/trial_length;

% include 0.5s of preparation
tmp_prep_idx = []
tmp_evt = bci.evt(find(bci.lbl == 783));
tmp_Ntr = length(find(bci.lbl == 783));
for i = 1: tmp_Ntr
    tmp_prep_idx = [tmp_prep_idx tmp_evt(i)-((1:preTime) -3)];
end
tmp_idx = [tmp_prep_idx tmp_idx'];
% Spectrogram
tmp_spectrogram = bci.afeats(tmp_idx,:,:);
tmp_spectrogram = reshape(tmp_spectrogram,...
    [tmp_trials_number, trial_length+preTime, length(freqs), Nelec]);
avg_spectrogram_rest = squeeze((mean(tmp_spectrogram)));

% ERD/S - alpha: 8-12Hz, beta: 18-28Hz
tmp_avg_spectrogram = avg_spectrogram_rest;
alpha = 3:5;
beta = 8:13;
tmp_avg_erds_baseline_alpha = squeeze(mean(mean(tmp_avg_spectrogram(1:preTime,alpha,:),2)));
tmp_avg_erds_baseline_beta = squeeze(mean(mean(tmp_avg_spectrogram(1:preTime,beta,:),2)));
tmp_avg_erds_alpha =  squeeze(mean(tmp_avg_spectrogram(:,alpha,:),2));
tmp_avg_erds_beta = squeeze(mean(tmp_avg_spectrogram(:,beta,:),2));

avg_erds_alpha_rest = zeros(size(tmp_avg_erds_alpha));
avg_erds_beta_rest = zeros(size(tmp_avg_erds_beta));
for el = 1:Nelec
    avg_erds_alpha_rest(:,el) = (tmp_avg_erds_alpha(:,el)-tmp_avg_erds_baseline_alpha(el))./tmp_avg_erds_baseline_alpha(el)*100;
    avg_erds_beta_rest(:,el) = (tmp_avg_erds_beta(:,el)-tmp_avg_erds_baseline_beta(el))./tmp_avg_erds_baseline_beta(el)*100;
end

% %% Compute differences among spectrograms
% spectrogram_differenceRL = avg_spectrogram_right - avg_spectrogram_left;
% spectrogram_differenceRRst = avg_spectrogram_right - avg_spectrogram_rest;
% spectrogram_differenceLRst = avg_spectrogram_left - avg_spectrogram_rest;
    
leftspace = 0.06;
rightspace = 0.02;
topspace = 0.06;
bottomspace = 0.06;
hinterspace = 0.015;
vinterspace = 0.025;

width = (1-rightspace - leftspace - (Ncol-1)*hinterspace)/Ncol;
height = (1-topspace - bottomspace - (Nrows-1)*vinterspace)/Nrows;

%% ALPHA
eegc3_figure;
eegc3_publish(12,12,2,2);
ha=[];
el=0;
% Plot line for trial start
x = [17 17];
y = [-1000 1000];
for i=1:Nrows
    for j=1:Ncol
        if(PosMat(i,j)==1)
            el = el+1;
            if (el == 1)
%                 title ('Right - Left');
            end
            ha(el)=axes('position',[(leftspace + (j-1)*(hinterspace+width))...
                (bottomspace + (Nrows-i)*(vinterspace+height))...
                width height]);
            hold on;
            plot(avg_erds_alpha_right(:,el),'c');
            plot(avg_erds_alpha_left(:,el),'m');
            plot(avg_erds_alpha_rest(:,el),'g');
            plot(x,y,'Color',[0.9 0.9 0.9]);
            ylim([-1000 1000]);
            box on
            set(ha(el),'Xtick',[1 17 33 49 65],'XTickLabel',{'[-1 0]', '[0 1]s','[1 2]s','[2 3]s','[3 4]s'})

%             set(ha(el),'Xtick',[1 17 33 49 65 77],'XTickLabel',{'[-1 0]', '[0 1]s','[1 2]s','[2 3]s','[3 4]s'})
%             set(ha(el),'Ytick',[1 5 11 17 23],'YTickLabel',{[4 12 24 36 48]})
        end
    end
end
colormap (othercolor(new_colormap))
drawnow;
% Create invisible axes to put a general title
if(exist('info','var'))
    axes('position',[0 0 1 1], 'visible','off');
    axis([0 1 0 1]);
    th = text(0.5,1-topspace/2,'Event Related Sync/Desync: alpha band [8-12]Hz',...
        'HorizontalAlignment','center');
    set(th, 'interpreter', 'none');
else
    %suplabel(GDFName,'t');
    axes('position',[0 0 1 1], 'visible','off');
    axis([0 1 0 1]);
    th = text(0.5,1-topspace/2,'Event Related Sync/Desync: alpha band [8-12]Hz',...
        'HorizontalAlignment','center');
    set(th, 'interpreter', 'none');
end
    

%% BETA
eegc3_figure;
eegc3_publish(12,12,2,2);
ha=[];
el=0;
for i=1:Nrows
    for j=1:Ncol
        if(PosMat(i,j)==1)
            el = el+1;
            if (el == 1)
%                 title ('Right - Left');
            end
            ha(el)=axes('position',[(leftspace + (j-1)*(hinterspace+width))...
                (bottomspace + (Nrows-i)*(vinterspace+height))...
                width height]);
            hold on;
            plot(avg_erds_beta_right(:,el),'b');
            plot(avg_erds_beta_left(:,el),'r');
            plot(avg_erds_beta_rest(:,el),'g');
            plot(x,y,'Color',[0.9 0.9 0.9]);
            ylim([-70 70]);
            box on
            set(ha(el),'Xtick',[1 17 33 49 65],'XTickLabel',{'[-1 0]', '[0 1]s','[1 2]s','[2 3]s','[3 4]s'})

%             set(ha(el),'Xtick',[1 17 33 49 65 77],'XTickLabel',{'[-1 0]', '[0 1]s','[1 2]s','[2 3]s','[3 4]s'})
%             set(ha(el),'Ytick',[1 5 11 17 23],'YTickLabel',{[4 12 24 36 48]})
        end
    end
end
colormap (othercolor(new_colormap))
drawnow;
% Create invisible axes to put a general title
if(exist('info','var'))
    axes('position',[0 0 1 1], 'visible','off');
    axis([0 1 0 1]);
    th = text(0.5,1-topspace/2,'Event Related Sync/Desync: beta band [8-12]Hz',...
        'HorizontalAlignment','center');
    set(th, 'interpreter', 'none');
else
    %suplabel(GDFName,'t');
    axes('position',[0 0 1 1], 'visible','off');
    axis([0 1 0 1]);
    th = text(0.5,1-topspace/2,'Event Related Sync/Desync: beta band [8-12]Hz',...
        'HorizontalAlignment','center');
    set(th, 'interpreter', 'none');
end
