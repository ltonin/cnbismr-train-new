% 2010-11-10  Michele Tavella <michele.tavella@epfl.ch>
% TODO
function roi = eegc3_smr_simprotocol(bci, cues, cuecolors, cuesskip, ...
	thresholds, plottrials, doplot);
%	revents, eventcolors, doplot)

% These events are defaulted for SMR BCI:
%   781		Continuos Feedback
%   897		Target hit
%   898		Target miss
% For this reason, here we have some ROIs
% TODO: use eegc3_smr_newevents()
roi.hits = bci.evt(find(bci.lbl == 897));
roi.miss = bci.evt(find(bci.lbl == 898));
roi.cfbk = bci.evt(find(bci.lbl == 781));
roi.tbeg = bci.evt(find(bci.lbl == 768));
roi.tend = bci.evt(find(bci.lbl == 758));

if(isempty(cues))
	printf('[eegc3_smr_simprotocol] Guessing cues: ');
	cuecolors = {};
	cues = setdiff(unique(bci.lbl), [897 898 781]);
	cues = setdiff(cues, cuesskip);
	for i = 1:length(cues)
		printf('%d ', cues(i));
		cuecolors{end+1} = 'k';
	end
	printf('\n');
end

if(isempty(thresholds))
	printf('[eegc3_smr_simprotocol] Guessing thresholds: ');
	thresholds(1) = mean(bci.iprobs(roi.hits(bci.iprobs(roi.hits) > 0.5)));
	thresholds(2) = 1 - mean(bci.iprobs(roi.hits(bci.iprobs(roi.hits) < 0.5)));
	
	for i = 1:length(thresholds)
		printf('%f ', thresholds(i));
	end
	printf('\n');
end

if(doplot == false)
	return;
end

if(doplot)
	eegc3_figure(doplot);
	clf;
	plot(bci.t, bci.cprobs(:, 1), '.', 'Color', [0.5 0.5 0.5]);
	hold on;
	plot(bci.t, bci.iprobs(:, 1), '.', 'Color', [0.0 0.0 0.0]);
	hold off;
	ylim([0 1]);
	xlim([bci.t(1) bci.t(end)]);
	grid on;

	eegc3_smr_barh(0.5, 'k', 1);
	eegc3_smr_barh(thresholds(1), 'k', 1);
	eegc3_smr_barh(1-thresholds(2), 'k', 1);

	% Draw target hit
	for i = 1:length(roi.hits)
		eegc3_smr_barv(roi.hits(i)/bci.Sf, 'g', 2);
	end
	% Draw target miss 
	for i = 1:length(roi.miss)
		eegc3_smr_barv(roi.miss(i)/bci.Sf, 'r', 2);
	end
	% Draw continuos feedback
	for i = 1:length(roi.cfbk)
		eegc3_smr_barv(roi.cfbk(i)/bci.Sf, 'k', 2);
	end
	% Draw cues
	for j = 1:length(cues)
		roi.cues{j} = bci.evt(find(bci.lbl ==  cues(j)));
		for i = 1:length(roi.cues{j})
			eegc3_smr_barv(roi.cues{j}(i)/bci.Sf, cuecolors{j}, 3);
		end
    end
    % Draw tbeg
    for i = 1:length(roi.tbeg)
		eegc3_smr_barv(roi.tbeg(i)/bci.Sf, 'c', 2);
    end
    % Draw tend
    for i = 1:length(roi.tend)
		eegc3_smr_barv(roi.tend(i)/bci.Sf, 'c', 2);
	end
    
	ylim([-0.05 +1.05]);
	% Draw target hit
	for i = 1:length(roi.hits)
		text(roi.hits(i)/bci.Sf, -0.015, 'h', 'HorizontalAlignment', 'center');
	end
	% Draw target miss 
	for i = 1:length(roi.miss)
		text(roi.miss(i)/bci.Sf, -0.015, 'm', 'HorizontalAlignment', 'center');
	end
	%% Draw continuos feedback
	for i = 1:length(roi.cfbk)
		text(roi.cfbk(i)/bci.Sf, -0.015, 'c', 'HorizontalAlignment', 'center');
	end
	% Draw cues
	for j = 1:length(cues)
		roi.cues{j} = bci.evt(find(bci.lbl ==  cues(j)));
		for i = 1:length(roi.cues{j})
			text(roi.cues{j}(i)/bci.Sf, 1.015, num2str(cues(j)), ...
				'HorizontalAlignment', 'center');
		end
	end
	% Draw trial lines
	if(plottrials)
		roi.trial0 = sort([roi.cues{1} roi.cues{2}]);
		roi.trial1 = sort([roi.hits roi.miss]);
		if(length(roi.trial0) == length(roi.trial1))
			for i = 1:length(roi.trial0)
				eegc3_smr_bart([roi.trial0(i) roi.trial1(i)]/bci.Sf);
			end
		end
    end
    % Draw tbeg 
	for i = 1:length(roi.tbeg)
		text(roi.tbeg(i)/bci.Sf, 1.015, '<', 'HorizontalAlignment', 'right');
        text(roi.tbeg(i)/bci.Sf, -0.015, 'tb', 'HorizontalAlignment', 'center');
    end
    % Draw tend 
	for i = 1:length(roi.tend)
		text(roi.tend(i)/bci.Sf, 1.015, '>', 'HorizontalAlignment', 'left');
        text(roi.tend(i)/bci.Sf, -0.015, 'te', 'HorizontalAlignment', 'center');
	end
	drawnow;
	eegc3_figure(doplot, 'fill');
	eegc3_figure(doplot, 'print', ...
		[bci.trace.eegc3_smr_simloop.figbasename '.simprotocol.png']);
end


perf.Nh = length(roi.hits);
perf.Nm = length(roi.miss);
perf.N = perf.Nh + perf.Nm;
perf.P = perf.Nh/perf.N;
perf.E = perf.Nm/perf.N;
perf.C = zeros(2, 2);

printf('[eegc3_smr_simprotocol] Performances:\n');
printf(' Hits: %.2f%% (%d/%d)\n', ...
	100*perf.P, perf.Nh, perf.N);
printf(' Miss: %.2f%% (%d/%d)\n', ...
	100*perf.E, perf.Nm, perf.N);
