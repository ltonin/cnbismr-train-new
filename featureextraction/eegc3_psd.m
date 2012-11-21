% Edited by M. Tavella <michele.tavella@epfl.ch> on 15/05/09 01:07:51
%
% Computes PSD sample from a chunk of EEG points
% 
% function [pattern, frequencies]  = eegc3_psd(EEGw, frqs, fs, window, overlap, dolog)
%
% Where:   (matrix)  EEGw         EEG window [1 x points]
%          (vector)  frqs         Vector of frequencies to compute the PSD for
%          (int)     fs           Sampling frequency
%          (int)     window       Window length (in seconds)
%          (int)     overlap      Overlap percent [0.00, 1.00]
%          (bool)    dolog        Log10 on PSD output (default = true)
%
% Returns: (vector)  pattern      PSD pattern
%
% Example:
%          [p, f] = eegc2_wpsd(x, [4:2:48], 512, 0.5, 0.5);
%
% TODO:    - Simis's opinion
%          - Handle errors
function [pattern, frequencies]  = eegc3_psd(EEGw, frqs, fs, ...
	window, overlap, dolog)

if(nargin < 6)
    dolog = true;
end

[psd, frq] = pwelch(EEGw, fs*window, fs*window*overlap , [], fs);
if(dolog == true)
    psd = log(psd);
end
[val, set] = intersect(frq, frqs);

if(length(set) ~= length(frqs))
	disp('[eegc3_psd] Warning: cannot provide requested frequencies!');
end

pattern = psd(set);
% Note by matteo.lostuzzo@epfl.ch Thu 01/10/09 09:47 CEST:
% pattern = spectrum.welch(set);  % -- New version?
% 2009-10-01  Michele Tavella <michele.tavella@epfl.ch>
% We need to verify if the output is exactly the same, btw, yes!
if(nargout == 2)
	frequencies = frq(set);
end
