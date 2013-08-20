function eegc3_smr_plotERDS(data, config)

% eegc3_smr_plotERDS TODO
% see Pfurtscheller et al. "Event-related EEG/MEG synchronization and
% desynchronization: basic principles", Clinical Neurophysiology, 1999

% Find number of channels
Nelec = size(data.eeg,2);

% new_colormap = 'GrMg_16';
new_colormap = 'BuDRd_18';
% Consider 0.5 seconds pretrial
subdim = [5 5];

% % In the case of WP4 online data, we only have 1 class, either 770 or 771
% if (bci.MI.task(1) == 783 || bci.MI.task(2) == 783)
%         bci.MI.task = setdiff(bci.MI.task,783);
% end

%% Extract ERDS
% alpha band pass
filt.bfo      = 5;

filt.lcf      = 8;  % high cut freq
filt.hcf      = 12;   % low cut freq
[avg_erds_alpha] = eegc3_smr_erds(data,filt);

filt.lcf      = 18;  % high cut freq
filt.hcf      = 28;   % low cut freq
[avg_erds_beta] = eegc3_smr_erds(data,filt);

%% ALPHA
eegc3_figure;
eegc3_publish(12,12,2,2);
% Plot line for trial start
x = [513 513];
y = [-1000 1000];

for ch = 1:Nelec
    colors = {'c','m','g'};
    for cl = 1:length(avg_erds_alpha)-1
        if ch == 1
            hold on
            subplot(subdim(1),subdim(2),3),plot(avg_erds_alpha{cl}(:,ch),colors{cl});
            box on
            title('Event Related Sync/Desync: \alpha band [8-12]Hz')
            plot(x,y,'Color',[0.9 0.9 0.9]);
            ylim([-200 1000])
        else
            hold on
            subplot(subdim(1),subdim(2),ch+4);
            plot(avg_erds_alpha{cl}(:,ch),colors{cl});
            box on
            plot(x,y,'Color',[0.9 0.9 0.9]);
            ylim([-200 1000])
        end
    end

end

%% BETA
eegc3_figure;
eegc3_publish(12,12,2,2);

for ch = 1:Nelec
    colors = {'c','m','g'};
    for cl = 1:length(avg_erds_beta)-1
        if ch == 1
            hold on
            subplot(subdim(1),subdim(2),3),plot(avg_erds_beta{cl}(:,ch),colors{cl});
            box on
            title('Event Related Sync/Desync: \beta band [18-28]Hz')
            plot(x,y,'Color',[0.9 0.9 0.9]);
            ylim([-200 1000])
        else
            hold on
            subplot(subdim(1),subdim(2),ch+4);
            plot(avg_erds_beta{cl}(:,ch),colors{cl});
            box on
            plot(x,y,'Color',[0.9 0.9 0.9]);
            ylim([-200 1000])
        end
    end

end
