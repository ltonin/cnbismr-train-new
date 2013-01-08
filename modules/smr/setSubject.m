function setSubject(sname)
    cmd = ['mv -v ~/sync/' sname '* ~/sync/online_mi_tdcs/' sname '//' ];
    [status result] = system(cmd);
    if (status==0)
        disp(result)
    else
        disp('[initSubject] Error!! please check the subject name')
    end
end