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
CLOW = -1;
CHIGH = 1;
% new_colormap = 'GrMg_16';
new_colormap = 'BuDRd_18';
Nelec = bci.settings.acq.channels_eeg;

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
avg_spectrogram_right = eegc3_smr_spectrogramToPlot (...
bci.afeats, bci.lbl_sample,bci.lbl, bci.evt, bci.MI.task(1), ...
   bci.settings.acq.channels_eeg, bci.settings.modules.smr.psd.freqs, ...
  bci.dur(4)+1);

%% MI Left 769
avg_spectrogram_left = eegc3_smr_spectrogramToPlot (...
bci.afeats, bci.lbl_sample,bci.lbl, bci.evt, bci.MI.task(2), ...
  bci.settings.acq.channels_eeg, bci.settings.modules.smr.psd.freqs, ...
  bci.dur(4)+1);

%% MI Rest
avg_spectrogram_rest = eegc3_smr_spectrogramToPlot (...
bci.afeats, bci.lbl_sample,bci.lbl, bci.evt, bci.MI.task(3), ...
  bci.settings.acq.channels_eeg, bci.settings.modules.smr.psd.freqs, ...
  bci.dur(4)+1);

%% Compute differences among spectrograms
spectrogram_differenceRL = avg_spectrogram_right - avg_spectrogram_left;
spectrogram_differenceRRst = avg_spectrogram_right - avg_spectrogram_rest;
spectrogram_differenceLRst = avg_spectrogram_left - avg_spectrogram_rest;
    
leftspace = 0.06;
rightspace = 0.02;
topspace = 0.06;
bottomspace = 0.06;
hinterspace = 0.015;
vinterspace = 0.025;

width = (1-rightspace - leftspace - (Ncol-1)*hinterspace)/Ncol;
height = (1-topspace - bottomspace - (Nrows-1)*vinterspace)/Nrows;

%% right - left
eegc3_figure;
eegc3_publish(12,12,2,2);
ha=[];
el=0;
% Plot line for trial start
x = 33* ones([10]);
y = [1 :23/10: 23];
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
            imagesc(squeeze(spectrogram_differenceRL(:,:,el))', [CLOW CHIGH] );
            hold on, plot(x,y,'k.');
            set(ha(el),'Xtick',[1 17 33 49 65 81],'XTickLabel',{'[-2 -1]','[-1 0]', '[0 1]s','[1 2]s','[2 3]s','[3 4]s'})
            set(ha(el),'Ytick',[1 5 11 17 23],'YTickLabel',{[4 12 24 36 48]})
        end
    end
end
linkaxes(ha,'xy');
colormap (othercolor(new_colormap))
drawnow;
% Create invisible axes to put a general title
if(exist('info','var'))
    axes('position',[0 0 1 1], 'visible','off');
    axis([0 1 0 1]);
    th = text(0.5,1-topspace/2,'Average Spectrogram: Right - Left Trials',...
        'HorizontalAlignment','center');
    set(th, 'interpreter', 'none');
else
    %suplabel(GDFName,'t');
    axes('position',[0 0 1 1], 'visible','off');
    axis([0 1 0 1]);
    th = text(0.5,1-topspace/2,'Average Spectrogram: Right - Left Trials',...
        'HorizontalAlignment','center');
    set(th, 'interpreter', 'none');
end
    

%% right - rest
eegc3_figure;
eegc3_publish(12,12,2,2);
ha=[];
el=0;
for i=1:Nrows
    for j=1:Ncol
        if(PosMat(i,j)==1)
            el = el+1;
            if (el == 1)
%                 title ('Right - Rest');
            end
            ha(el)=axes('position',[(leftspace + (j-1)*(hinterspace+width))...
                (bottomspace + (Nrows-i)*(vinterspace+height))...
                width height]);
            imagesc(squeeze(spectrogram_differenceRRst(:,:,el))', [CLOW CHIGH] );
            hold on, plot(x,y,'k.');
            set(ha(el),'Xtick',[1 17 33 49 65 81],'XTickLabel',{'[-2 -1]','[-1 0]', '[0 1]s','[1 2]s','[2 3]s','[3 4]s'})
            set(ha(el),'Ytick',[1 5 11 17 23],'YTickLabel',{[4 12 24 36 48]})
        end
    end
end
linkaxes(ha,'xy');
colormap (othercolor(new_colormap))
drawnow;
% Create invisible axes to put a general title
if(exist('info','var'))
    axes('position',[0 0 1 1], 'visible','off');
    axis([0 1 0 1]);
    th = text(0.5,1-topspace/2,'Average Spectrogram: Right - Rest Trials',...
        'HorizontalAlignment','center');
    set(th, 'interpreter', 'none');
else
    %suplabel(GDFName,'t');
    axes('position',[0 0 1 1], 'visible','off');
    axis([0 1 0 1]);
    th = text(0.5,1-topspace/2,'Average Spectrogram: Right - Resting Trials',...
        'HorizontalAlignment','center');
    set(th, 'interpreter', 'none');
end

%% left - rest
eegc3_figure;
eegc3_publish(12,12,2,2);
ha=[];
el=0;
for i=1:Nrows
    for j=1:Ncol
        if(PosMat(i,j)==1)
            el = el+1;
            if (el == 1)
%                 title ('Left - Rest');
            end
            ha(el)=axes('position',[(leftspace + (j-1)*(hinterspace+width))...
                (bottomspace + (Nrows-i)*(vinterspace+height))...
                width height]);
            imagesc(squeeze(spectrogram_differenceLRst(:,:,el))', [CLOW CHIGH] );
            hold on, plot(x,y,'k.');
            set(ha(el),'Xtick',[1 17 33 49 65 81],'XTickLabel',{'[-2 -1]','[-1 0]', '[0 1]s','[1 2]s','[2 3]s','[3 4]s'})
            set(ha(el),'Ytick',[1 5 11 17 23],'YTickLabel',{[4 12 24 36 48]})
        end
    end
end
linkaxes(ha,'xy');
colormap (othercolor(new_colormap))
drawnow;
% Create invisible axes to put a general title
if(exist('info','var'))
    axes('position',[0 0 1 1], 'visible','off');
    axis([0 1 0 1]);
    th = text(0.5,1-topspace/2,'Average Spectrogram: Left - Rest Trials',...
        'HorizontalAlignment','center');
    set(th, 'interpreter', 'none');
else
    %suplabel(GDFName,'t');
    axes('position',[0 0 1 1], 'visible','off');
    axis([0 1 0 1]);
    th = text(0.5,1-topspace/2,'Average Spectrogram: Left - Rest Trials',...
        'HorizontalAlignment','center');
    set(th, 'interpreter', 'none');
end