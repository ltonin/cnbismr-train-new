% Edited by M. Tavella <michele.tavella@epfl.ch> on 20/05/09 21:28:47
%
% Gets frequency bands by name
% 
% function selected = eegc3_bands(bands)
%
% Where:   (carray)  bands        Bands to extract
%
% Returns: (carray)  selected     Selected bands
%                     .name       Selected bands names
%                     .band       Selected bands bands (whatever)
%
% TODO:    - Handle errors
%          - Better documentation + example

function selected = eegc3_bands(bands)

if(nargin < 1)
	bands = {'theta' 'alpha' 'beta_low' 'beta_high'};
end

bnd.name{1} = 'delta';		
bnd.name{2} = 'theta';		
bnd.name{3} = 'alpha';
bnd.name{4} = 'beta';
bnd.name{5} = 'beta_low';	
bnd.name{6} = 'beta_high';	
bnd.name{7} = 'gamma';		
% Matteo's mi-band: just as an example
bnd.name{8} = 'mi';		

bnd.name{9} = 'rob1';		
bnd.name{10} = 'rob2';		



bnd.band{1} = [ 0.2 4];
bnd.band{2} = [ 4   7];
bnd.band{3} = [ 8  12];
bnd.band{4} = [12  30];
bnd.band{5} = [12  18];
bnd.band{6} = [18  30];
bnd.band{7} = [30 100];
bnd.band{8} = [ 9  11];

bnd.band{9} = [ 5  8];
bnd.band{10} = [ 16 30];

bnd.title{1} = 'Delta';		
bnd.title{2} = 'Theta';		
bnd.title{3} = 'Alpha';		
bnd.title{4} = 'Beta';		
bnd.title{5} = 'Beta Low';	
bnd.title{6} = 'Beta High';	
bnd.title{7} = 'Gamma';		
bnd.title{8} = 'Mi';		

bnd.title{9} = 'Rob1';		
bnd.title{10} = 'Rob2';		

selected.name = {};
selected.band = {};

for bn = 1:length(bands)
	% God bless mathworks for not implementing hashtables. 
	idx = find(ismember(bnd.name, bands{bn}) == 1);
	if(~isempty(idx))
		selected.title{bn} = bnd.title{idx};
		selected.name{bn} = bnd.name{idx};
		selected.band{bn} = bnd.band{idx};
	else
		disp('[eegc2_bands] Error: kicked by Chuck Norris');
		selected.name = {};
		selected.band = {};
		break;
	end
end
