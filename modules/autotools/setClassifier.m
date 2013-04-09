function setClassifier

    xmlfile  = uigetfile('*.xml','Select config file [SubXX_config.xml]');
    if (xmlfile ==0)
        disp('[setClassifier] Error!! please check the names of config file and classifier')
        return        
    else
        classfile= uigetfile('*.mat','Select classifier file [SubXX_YYYYMMDD_auto.mat]');
        if (classfile==0)
            disp('[setClassifier] ERROR: No classifier was selected. Aborted!!!')
            return
        else
            cmd = ['~/bin/updateXML_Online.sh ' classfile ' ' xmlfile];
            [status result] = system(cmd);
            if (status~=0)
                disp('[setClassifier] ERROR: Could not update the configuration. Aborted!!!')
            end
            disp(result)
        end
    end
end