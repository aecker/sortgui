% Startup script for spike sorting GUI

% Matlab path
p = fileparts(mfilename('fullpath'));
addpath(fullfile(p, 'matlab'))
addpath(fullfile(p, 'matlab/util'))
addpath(fullfile(p, 'matlab/util/uicomponent'))

% Java path (needs to be on static class path: edit classpath.txt)
% javaaddpath(fullfile(p, 'bin'))
