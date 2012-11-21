% 2010-08-25  Michele Tavella <michele.tavella@epfl.ch>
% function mt_progressclean()
function mt_progressclean()

global mtprogress;

if(mtprogress.size > 0)
	if(mt_hasdesktop() == true)
		for i = 1:mtprogress.size
			fprintf('\b');
		end
		mtprogress.size = 0;
	else
		fprintf('\r');
	end
end
