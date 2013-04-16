function plot_CVAspace_Auto(numSub_start, numSub,date)

cva_features_all=zeros(16,50);


try
    for sub = numSub_start:numSub
        
        %% File location for each subject
        FilePaths = {};
        
        if sub == 1 || sub == 3 || sub == 14 || sub == 24
            continue; % Skip them!
        end
        
        %% Auto-plot
        if sub == 5 %% skip session 1!
            
            i = 2;
            
            FilePaths = [getenv('TOLEDO_DATA') '/Results/Sub' num2str(sub) '/Results_GAU_CVA_Rejection_Sub'...
                num2str(sub) '_rhlh_Session' num2str(i) '_' num2str(date) '_auto'];
            
            load (FilePaths)
            
            % plotting
            plot_cva_features=zeros(16,50);
            
            for chan=1:length(analysis.tools.features.channels)
                freq_features=analysis.tools.features.bands{analysis.tools.features.channels(chan)};
                plot_cva_features(analysis.tools.features.channels(chan),freq_features)=1;
            end
            figure, imagesc(plot_cva_features);
            ylabel ('Channel')
            xlabel ('Band [Hz]')
            
            
            % saving
            saveas(gcf,[getenv('TOLEDO_DATA') '/Results/Sub' num2str(sub) '/Results_GAU_CVA_Rejection_features_Sub'...
                num2str(sub) '_rhlh_Session' num2str(i) '_' num2str(date) '_auto' '.png']);
            
            cva_features_all= cva_features_all+plot_cva_features;
            close;
            
        else %% for the remaining subjects!
            
            for i = 1:2 % if subject==5 skip session 1!
                
                FilePaths = [getenv('TOLEDO_DATA') '/Results/Sub' num2str(sub) '/Results_GAU_CVA_Rejection_Sub'...
                    num2str(sub) '_rhlh_Session' num2str(i) '_' num2str(date) '_auto'];
                
                load (FilePaths)
                
                % plotting
                plot_cva_features=zeros(16,50);
                
                for chan=1:length(analysis.tools.features.channels)
                    freq_features=analysis.tools.features.bands{analysis.tools.features.channels(chan)};
                    plot_cva_features(analysis.tools.features.channels(chan),freq_features)=1;
                end
                figure, imagesc(plot_cva_features);
                ylabel ('Channel')
                xlabel ('Band [Hz]')
                
                
                % saving
                saveas(gcf,[getenv('TOLEDO_DATA') '/Results/Sub' num2str(sub) '/Results_GAU_CVA_Rejection_features_Sub'...
                    num2str(sub) '_rhlh_Session' num2str(i) '_' num2str(date) '_auto' '.png']);
                
                cva_features_all= cva_features_all+plot_cva_features;
                close;
            end
            
            
            
        end
        
    end
    % saving plot of selected subjects
    figure, imagesc(cva_features_all);
    ylabel ('Channel')
    xlabel ('Band [Hz]')
    title ('For all subject');
    colorbar
    
    saveas(gcf,[getenv('TOLEDO_DATA') '/Results/All/Results_GAU_CVA_Rejection_features_All_'...
        num2str(numSub_start) '_' num2str(numSub) '.png']);
    close;
    
    
    
catch error
    disp(['Stopped at Subject: ' num2str(sub)]);
    disp(['The following error was detected:  ' error.message])
    
end


