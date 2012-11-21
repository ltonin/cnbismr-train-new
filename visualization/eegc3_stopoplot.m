% 2011-06-09  Robert Leeb <robert.leeb@epfl.ch>
function eegc3_stopoplot(eeg, Rescale, DefaultValue, ch)

if(nargin < 2)
	Rescale = 10;
end

if(nargin < 3)
	DefaultValue = 0;
end

if(nargin < 4)
	ch = [ 0 0 1 0 0; ...
		   2  3 4 5 6; ...
		   7 8 9 10 11; ...
		   12 13 14 15 16];
end

% Define a neural zone around
ExtendedEEG = ones(size(ch,1)+2, size(ch,2)+2) * DefaultValue;
for x = 1 : size(ch,1)
    for y = 1 : size(ch,2)
        if ch(x,y)~=0
            ExtendedEEG(x+1,y+1) = eeg(ch(x,y));
        end
    end
end

% Bicubic interpolation
RescaleEEG = imresize(ExtendedEEG, Rescale,'bicubic');

% Plot data
figure
imagesc(ExtendedEEG)
ax=axis;
imagesc(RescaleEEG)
hold on

% add electrode position
for x = 1 : size(ch,1)
    for y = 1 : size(ch,2)
        if ch(x,y)~=0
            x1 = (x+1)*Rescale - ax(1)*Rescale;
            y1 = (y+1)*Rescale - ax(3)*Rescale;
            %hp = plot(y1, x1,'x');
            %set(hp,'MarkerSize',10,'LineWidth',2,'Color','k');
            hp = plot(y1, x1,'.');
            set(hp,'MarkerSize',20,'LineWidth',1,'Color','k');
        end
    end
end
hold off
