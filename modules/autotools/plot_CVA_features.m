plot_cva_features=zeros(16,50);

for i=1:length(analysis.tools.features.channels)
  for j=1:length(analysis.tools.features.bands{analysis.tools.features.channels(i)})
      freq_features=analysis.tools.features.bands{analysis.tools.features.channels(i)};
      plot_cva_features(analysis.tools.features.channels(i),freq_features(j))=1;
  end
end

 figure, pcolor(plot_cva_features(:,2:2:end));
ylim([0 18])
xlim([0 51])


