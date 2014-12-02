% Test script

%% reload Java classes
clear ccgView spikeView
javaaddpath(fullfile(pwd, 'bin'))


%% generate some toy data
rng(1);
T = 10 * 60;
Fs = 10000;
M = 3;
[b, a] = butter(3, [1 100] / Fs * 2, 'bandpass');
x = randn(T * Fs, M);
x = filtfilt(b, a, x);
K = 10;
sigma = 0.1;
w = randn(K, M);
lambda = 5 * x * w' + randn(T * Fs, K) * sigma - 7;
y = exp(lambda) > rand(T * Fs, K);
[t, assignments] = find(y);
t = t / Fs * 1000;
for i = 1 : K
    ndx = find(assignments == i);
    del = diff(t(ndx)) < 1;
    t(ndx(del)) = [];
    assignments(ndx(del)) = [];
end
[t, order] = sort(t);
assignments = assignments(order);
ampl = 1 + randn(size(t)) / 20;


%% open CCG and spike time views
sel = 5 : 8;
ccg = correlogram(t, assignments, K, 0.2, 10);
ccgView = MCorrelogramView;
ccgView.setCCG(ccg)
ccgView.setSelected(sel)
ccgView.resize(600, 400)

spikeView = MSpikeTimeView;
spikeView.setSpikes(t, ampl, assignments)
spikeView.setSelected(sel)
spikeView.resize(600, 400)
