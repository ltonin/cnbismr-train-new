function eegc3_smr_plotSpectrum(bci, GDFName, config, taskset, info)

% eegc3_smr_plotSpectrum(bci, GDFName, config, taskset, info)
%
% Function to plot the EEG spectrum for all channels of a run
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

% In the case of WP4 online data, we only have 1 class, either 770 or 769
if (bci.MI.task(1) == 783 || bci.MI.task(2) == 783)
        bci.MI.task = setdiff(bci.MI.task,783);
end

% Find min and max
for class = 1:length(bci.MI.task)
    
    
    Max = max(max(bci.MI.spectrum{class}(:)), max(bci.nonMI.spectrum{class}(:)) );
    Min = min(min(bci.MI.spectrum{class}(:)), min(bci.nonMI.spectrum{class}(:)) );

    if(Max > 1)
        MaxScale = ceil(log10(Max));
    else
        MaxScale = floor(log10(Max));
    end

    if(Min > 1)
        MinScale = ceil(log10(Min));
    else
        MinScale = floor(log10(Min));
    end

    eegc3_figure;
    eegc3_publish(12,12,2,2);

    leftspace = 0.06;
    rightspace = 0.02;
    topspace = 0.06;
    bottomspace = 0.06;
    hinterspace = 0.015;
    vinterspace = 0.025;

    width = (1-rightspace - leftspace - (Ncol-1)*hinterspace)/Ncol;
    height = (1-topspace - bottomspace - (Nrows-1)*vinterspace)/Nrows;

    ha=[];
    el=0;
    for i=1:Nrows
        for j=1:Ncol
            if(PosMat(i,j)==1)
                el = el+1;
                %subplot(Nrows, Ncol, (i-1)*Ncol + j); semilogy(f, bci.spectrum(:,el));
                ha(el)=axes('position',[(leftspace + (j-1)*(hinterspace+width))...
                    (bottomspace + (Nrows-i)*(vinterspace+height))...
                    width height]); 
                    semilogy(bci.MI.f, bci.MI.spectrum{class}(:,el),'r');
                    hold on;
                    semilogy(bci.nonMI.f, bci.nonMI.spectrum{class}(:,el),'b');
                    hold off;
                axis([min(bci.MI.f) max(bci.MI.f) Min Max]);
                text(bci.MI.f(end-5), Max-1,num2str(el), 'HorizontalAlignment', 'center',...
                    'VerticalAlignment', 'top');
                if(j==1)
                    ylabel('Bandpower [uV^2/Hz]');
                    set(gca,'YTick',10.^[MinScale:1:MaxScale]);
                else
                    set(gca,'YTick',[]);
                end
                if(i == Nrows)
                    xlabel('Frequency [Hz]');
                else
                    set(gca,'XTick',[]);
                end
                if(el==1)
                    legend('MI','Non MI');
                end
            end
        end
    end
    linkaxes(ha,'xy');

    % Create invisible axes to put a general title
    if(exist('info','var'))
        %suplabel([GDFName ', NFFT = ' num2str(info.nfft) ', Win = ' num2str(info.win) ],'t');
        axes('position',[0 0 1 1], 'visible','off');
        axis([0 1 0 1]);
        th = text(0.5,1-topspace/2,[GDFName ', NFFT = '...
        num2str(info.nfft) ', Win = ' num2str(info.win) ', Class: ' eegc3_smr_biosig2name(bci.MI.task(class))],...
            'HorizontalAlignment','center');
        set(th, 'interpreter', 'none');
    else
        %suplabel(GDFName,'t');
        axes('position',[0 0 1 1], 'visible','off');
        axis([0 1 0 1]);
        th = text(0.5,1-topspace/2,[GDFName ', Class: ' eegc3_smr_biosig2name(bci.MI.task(class))],...
            'HorizontalAlignment','center');
        set(th, 'interpreter', 'none');
    end
    
    for i=1:Nelec 
        axes(ha(i));
    end
    drawnow;
end
