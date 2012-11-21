% 2011-01-21  Michele Tavella <michele.tavella@epfl.ch>

function msession = eegc3_cl_mergesessions(sessions, name)


msession = eegc3_cl_newsession();
msession.subject = sessions{1}.subject;
msession.daytime = sessions{1}.daytime;
if(nargin > 1)
	msession.name = name;
end

for i = 1:length(sessions)
	if(i > 1)
		msession.daytime = [msession.daytime '+' sessions{i}.daytime];
	end
	for k = 1:length(sessions{i}.runs.all)
		msession.runs.all{end+1} = sessions{i}.runs.all{k};
	end
	for k = 1:length(sessions{i}.runs.online)
		msession.runs.online{end+1} = sessions{i}.runs.online{k};
	end
	for k = 1:length(sessions{i}.runs.offline)
		msession.runs.offline{end+1} = sessions{i}.runs.offline{k};
	end
end
