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

% Smoothing window of 0.5s
smooth_win = 256;

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
x = [0 0];
y = [-200 200];
xticks = -3: 7.75/3967:4.75;
style = {'--k','-.k',':k'};

for ch = 1:Nelec
    % Baseline Area
    if ch == 1
        subplot(subdim(1),subdim(2),3);
    else
        subplot(subdim(1),subdim(2),ch+4);
    end
    hold on;
    area([-2.95,-2],[50,50],'FaceColor',[.9 .9 .9],'EdgeColor',[.9 .9 .9]);
    area([-2.95,-2],[-50,-50],'FaceColor',[.9 .9 .9],'EdgeColor',[.9 .9 .9]);
    
    % Other Plots
    for cl = 1:length(avg_erds_alpha)
        if ch == 1
            subplot(subdim(1),subdim(2),3);
            hold on
            plot(xticks,smooth(avg_erds_alpha{cl}(:,ch),smooth_win),style{cl});
            plot(x,y,'Color',[0.9 0.9 0.9]);
            ylim(y);
            xlim([-3 4.75]);
            box on;
            title('Event Related Sync/Desync: \alpha band [8-12]Hz');
            xlabel('Time (s)');
            ylabel('Power Variation (%)')
        else
            subplot(subdim(1),subdim(2),ch+4);
            hold on
            plot(xticks,smooth(avg_erds_alpha{cl}(:,ch),smooth_win),style{cl});
            box on
            plot(x,y,'Color',[0.9 0.9 0.9]);
            ylim(y);
            xlim([-3 4.75]);
        end
    end
    plot(x,y,'k-');
end

%% BETA
eegc3_figure;
eegc3_publish(12,12,2,2);

for ch = 1:Nelec
    if ch == 1
        subplot(subdim(1),subdim(2),3);
    else
        subplot(subdim(1),subdim(2),ch+4);
    end
    hold on;
    area([-2.95,-2],[50,50],'FaceColor',[.9 .9 .9],'EdgeColor',[.9 .9 .9]);
    area([-2.95,-2],[-50,-50],'FaceColor',[.9 .9 .9],'EdgeColor',[.9 .9 .9]);
    
    hold on
    for cl = 1:length(avg_erds_beta)
        if ch == 1
            subplot(subdim(1),subdim(2),3);
            hold on
            plot(xticks,smooth(avg_erds_beta{cl}(:,ch),smooth_win),style{cl});
            ylim(y);
            xlim([-3 4.75]);
            box on
            title('Event Related Sync/Desync: \beta band [18-28]Hz')
            xlabel('Time (s)');
            ylabel('Power Variation (%)')
        else
            subplot(subdim(1),subdim(2),ch+4);
            hold on
            plot(xticks,smooth(avg_erds_beta{cl}(:,ch),smooth_win),style{cl});
            ylim(y);
            xlim([-3 4.75]);
            box on
        end
    end
    plot(x,y,'k-');
end
