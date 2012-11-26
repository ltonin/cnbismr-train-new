%   Copyright (C) 2010 Michele Tavella <tavella.michele@gmail.com>
%
%   This file is part of matndf
%
%   The libndf library is free software: you can redistribute it and/or
%   modify it under the terms of the version 3 of the GNU General Public
%   License as published by the Free Software Foundation.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

function config = ndf_example_ack(pipeid, doplot)

try 
	if(nargin < 2)
		doplot = false;
	end
	if(nargin == 0)
		pipeid = '';
	end
	
	% Configuration 
	% - Initialize, configure and setup your stuff in here
	addpath('../');
	mtpath_include('$CNBITOOLKIT_APPS_ROOT/eegserver');

	% Pipe opening and NDF configuration
	% - Here the pipe is opened
	% - ... and the NDF ACK frame is received
	frame = ndf_frame();
	sink = ndf_sink(['/tmp/ndf.example.ack' pipeid]);
	disp('[ndf_example_gtec] Receiving ACK...');
	[config, rsize] = ndf_ack(sink);
	
	% NDF ACK check
	% - The NDF id describes the acquisition module running
	% - Bind your modules to a particular configuration (if needed)
	disp(['[ndf_example_gtec] NDF type id: ' num2str(config.id)]);

	% Ring-buffers
	% - By default they contain the last second of data
	% - Eventually, save CPU by not buffering unuseful data
	disp('[ndf_example_gtec] Creating ring-buffers');
	buffer.eeg = ndf_ringbuffer(config.sf, config.eeg_channels);
	buffer.exg = ndf_ringbuffer(config.sf, config.exg_channels);
	buffer.tri = ndf_ringbuffer(config.sf, config.tri_channels);

	% Initialize ndf_jump structure
	% - Each NDF frame carries an index number
	% - ndf_jump*.m are methods to verify whether your script is
	%   running too slow
	jump = ndf_jump();

	disp('[ndf_example_gtec] Receiving NDF frames...');
	tic;
	samples = 0;
	while(true) 
		% Read NDF frame from pipe
		[frame, rsize] = ndf_read(sink, config, frame);

		if(rsize == 0)
			disp('[ndf_example_gtec] Broken pipe');
			break;
		end
		
		% Buffer NDF streams to the ring-buffers
		buffer.eeg = ndf_add2buffer(buffer.eeg, frame.eeg);
		buffer.exg = ndf_add2buffer(buffer.exg, frame.exg);
		buffer.tri = ndf_add2buffer(buffer.tri, frame.tri);
		samples = samples + 1;
		
		if(doplot)
			eegc2_figure(1);
			subplot(7, 1, 1:4)
				imagesc(eegc2_car(eegc2_dc(buffer.eeg))');
				title(num2str(frame.index));
				ylabel('buffer.eeg');
			subplot(7, 1, 5:6)
				imagesc(eegc2_car(eegc2_dc(buffer.exg))');
				ylabel('buffer.exg');
			subplot(7, 1, 7)
				imagesc(buffer.tri');
				ylabel('buffer.tri');
			drawnow;
		end

		% Check if module is running slow
		jump = ndf_jump_update(jump, frame.index);
		if(jump.isjumping)
			disp('[ndf_example_gtec] Error: running slow');
			break;
		end
	end
	disp(['[ndf_example_gtec] Received ' ...
		num2str(samples) ' NDF frames in ' num2str(toc) 's']);

	ndf_close(sink);
catch exception
	ndf_close(sink);
	exit;
end
