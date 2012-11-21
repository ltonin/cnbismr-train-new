% 2010-11-11  Michele Tavella <michele.tavella@epfl.ch>
% Import all directories but modules
[file, basename] = mtpath_basename(which('eegc3_init'));

mtpath_include('$EEGC3_ROOT/classification/');
mtpath_include('$EEGC3_ROOT/configuration/');
mtpath_include('$EEGC3_ROOT/dataset/');
mtpath_include('$EEGC3_ROOT/featureextraction/');
mtpath_include('$EEGC3_ROOT/featureselection/');
mtpath_include('$EEGC3_ROOT/gui/');
mtpath_include('$EEGC3_ROOT/inputoutput/');
mtpath_include('$EEGC3_ROOT/integration/');
mtpath_include('$EEGC3_ROOT/performance/');
mtpath_include('$EEGC3_ROOT/preprocessing/');
mtpath_include('$EEGC3_ROOT/tools/');
mtpath_include('$EEGC3_ROOT/visualization/');
mtpath_include('$EEGC3_ROOT/toolboxes/');
