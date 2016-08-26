% Edited by M. Tavella <michele.tavella@epfl.ch> on 28/07/09 12:13:05

function [pdf1, pdf2, pdf3, pdf4] = eegc3_smr_cvaspace(data, labels, classes, fig, tit)

if(nargin < 4)
	fig = 0;
end

[dp, pwgr, v, vp, cs] = cva_tun_opt(data, labels);
labels_total = length(unique(labels));

switch(labels_total)
	case 2
		d1 = cs(find(labels == classes(1)), :);
		d2 = cs(find(labels == classes(2)), :);

		pdf1 = gkdeb(d1);
		pdf2 = gkdeb(d2);
        pdf3 = NaN;
        pdf4 = NaN;

		if(fig)
			eegc2_figure(fig);
			plot(pdf1.x, pdf1.f, 'r', 'LineWidth', 2); hold on;
			plot(pdf2.x, pdf2.f, 'k', 'LineWidth', 2); hold off;
			grid on;
			legend('First Class', 'Second Class');
			drawnow;
		end

	case 3
		 d1 = cs(find(labels == classes(1)), 1);
		 d2 = cs(find(labels == classes(2)), 1);
		 d3 = cs(find(labels == classes(3)), 1);
		
		pdf1 = gkdeb(d1);
		pdf2 = gkdeb(d2);
		pdf3 = gkdeb(d3);
        pdf4 = NaN;

		 if(fig)
			eegc2_figure(fig);
			plot(d1(:,1), d1(:,2), 'r.'); hold on;
			plot(d2(:,1), d2(:,2), 'k.'); 
			plot(d3(:,1), d3(:,2), 'b.'); hold off;
			grid on;
			legend('First Class', 'Second Class', 'Third Class');
			xlabel('cva1');
			xlabel('cva2');
			drawnow;
		end

	case 4
		 d1 = cs(find(labels == classes(1)), 1);
		 d2 = cs(find(labels == classes(2)), 1);
		 d3 = cs(find(labels == classes(3)), 1);
         d4 = cs(find(labels == classes(4)), 1);
		
		pdf1 = gkdeb(d1);
		pdf2 = gkdeb(d2);
		pdf3 = gkdeb(d3);
        pdf4 = gkdeb(d4);

		 if(fig)
			eegc2_figure(fig);
			plot(d1(:,1), d1(:,2), 'r.'); hold on;
			plot(d2(:,1), d2(:,2), 'k.'); 
			plot(d3(:,1), d3(:,2), 'b.');
            plot(d4(:,1), d4(:,2), 'b.'); hold off;
			grid on;
			legend('First Class', 'Second Class', 'Third Class', 'Fourth Class');
			xlabel('cva1');
			xlabel('cva2');
			drawnow;
		end

	otherwise
		disp('[eegc2_bursts] Error: kicked by Chuck Norris');
end

 if(fig)
	if(nargin < 5)
		title('Canonical Space');
	else
		title(tit);
	end
end