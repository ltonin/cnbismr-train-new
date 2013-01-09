function MyPlotting(outputAll, subjects, runs, channels, sessions)

% Plot the raw signal of the selected subjects, runs, channels and
% sessions)
% outputAll = the output of Mytrain_classifier_All_Auto

for sub = 1:length(subjects)
    for ses = 1:length(sessions)
        for r = 1:length(runs)
            for chan = 1: length(channels)
                if isstruct(outputAll{subjects(sub),1}{1,sessions(ses)})
                    % Original dataset (Before rejection of trials)
                    figure()
                    samples = 1:size(outputAll{subjects(sub),1}{1,sessions(ses)}.data_Or{1,runs(r)}.eeg,1);
                    plot(samples,outputAll{subjects(sub),1}{1,sessions(ses)}.data_Or{1,runs(r)}.eeg(:,channels(chan)));
                    hold on;
                    xlabel('Sample Number');
                    ylabel('Potential (microV)');
                    title(['Raw signal BEFORE Rejection of Trials (Subject: ' num2str(subjects(sub)) ', Run: ' num2str(runs(r)) ', Channel: ' num2str(channels(chan)) ', Session:' num2str(sessions(ses)) ')'])
                    
                    figNum = get(0,'CurrentFigure');
                    saveas(figNum,['/homes/vliakoni/Plotting_Raw/BEFORE_Sub' num2str(subjects(sub)) '_Run' num2str(runs(r)) '_Channel' num2str(channels(chan)) '_Session' num2str(sessions(ses)) '.png'])
                    
                    
                    % New dataset(After rejection of trials)
                    figure()
                    samples = 1:size(outputAll{subjects(sub),1}{1,sessions(ses)}.data_New{1,runs(r)}.eeg,1);
                    plot(samples,outputAll{subjects(sub),1}{1,sessions(ses)}.data_New{1,runs(r)}.eeg(:,channels(chan)));
                    hold on;
                    xlabel('Sample Number');
                    ylabel('Potential (microV)');
                    title(['Raw signal AFTER Rejection of Trials (Subject: ' num2str(subjects(sub)) ', Run: ' num2str(runs(r)) ', Channel: ' num2str(channels(chan)) ', Session:' num2str(sessions(ses)) ')'])
                    figNum = get(0,'CurrentFigure');
                    saveas(figNum,['/homes/vliakoni/Plotting_Raw/AFTER_Sub' num2str(subjects(sub)) '_Run' num2str(runs(r)) '_Channel' num2str(channels(chan)) '_Session' num2str(sessions(ses)) '.png'])
                else
                    continue;
                end
            end
        end
    end
end