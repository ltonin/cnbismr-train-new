% Import all directories but modules
[file, basename] = mtpath_basename(which('eegc3_init'));

mtpath_include('$SMR_OFFLINE_ROOT/classification/');
mtpath_include('$SMR_OFFLINE_ROOT/configuration/');
mtpath_include('$SMR_OFFLINE_ROOT/dataset/');
mtpath_include('$SMR_OFFLINE_ROOT/featureextraction/');
mtpath_include('$SMR_OFFLINE_ROOT/featureselection/');
mtpath_include('$SMR_OFFLINE_ROOT/gui/');
mtpath_include('$SMR_OFFLINE_ROOT/inputoutput/');
mtpath_include('$SMR_OFFLINE_ROOT/integration/');
mtpath_include('$SMR_OFFLINE_ROOT/performance/');
mtpath_include('$SMR_OFFLINE_ROOT/preprocessing/');
mtpath_include('$SMR_OFFLINE_ROOT/tools/');
mtpath_include('$SMR_OFFLINE_ROOT/visualization/');
mtpath_include('$SMR_OFFLINE_ROOT/toolboxes/');
