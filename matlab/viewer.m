% Test script

%% reload Java classes
clear ccg
javaaddpath(fullfile(pwd, 'bin'))


%% open CCG View with random data for testing
ccg = MCorrelogramView;
ccg.setCCG(rand(10, 10, 20))
ccg.setSelected(5 : 8)
ccg.resize([600 400]);
