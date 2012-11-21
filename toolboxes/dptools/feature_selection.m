function [dp, selected] = feature_selection(feats,labels,percent)

warning('This method was marked as deprecated. Use dpfeatures instead');
[dp, selected] = dpfeatures(feats,labels,percent);
