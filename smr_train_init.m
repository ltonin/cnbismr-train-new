% Import all directories but modules
[file, basename] = mtpath_basename(which('smr_train_init'));

mtpath_include('$SMR_TRAIN_ROOT/classification/');
mtpath_include('$SMR_TRAIN_ROOT/configuration/');
mtpath_include('$SMR_TRAIN_ROOT/dataset/');
mtpath_include('$SMR_TRAIN_ROOT/featureextraction/');
mtpath_include('$SMR_TRAIN_ROOT/featureselection/');
mtpath_include('$SMR_TRAIN_ROOT/gui/');
mtpath_include('$SMR_TRAIN_ROOT/inputoutput/');
mtpath_include('$SMR_TRAIN_ROOT/integration/');
mtpath_include('$SMR_TRAIN_ROOT/performance/');
mtpath_include('$SMR_TRAIN_ROOT/preprocessing/');
mtpath_include('$SMR_TRAIN_ROOT/tools/');
mtpath_include('$SMR_TRAIN_ROOT/visualization/');
mtpath_include('$SMR_TRAIN_ROOT/toolboxes/');

mtpath_include('$SMR_TRAIN_ROOT/modules/smr/');
mtpath_include('$SMR_TRAIN_ROOT/modules/cl/');
mtpath_include('$SMR_TRAIN_ROOT/modules/eegc2/');
