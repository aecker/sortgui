% Test script

%% reload Java classes
close all
clear ccgView spikeView waveView
javaaddpath(fullfile(pwd, 'bin'))


%% generate some toy data
rng(1);
T = 10 * 60;
Fs = 10000;
L = 3;
[b, a] = butter(3, [1 100] / Fs * 2, 'bandpass');
x = randn(T * Fs, L);
x = filtfilt(b, a, x);
M = 10;
sigma = 0.1;
w = randn(M, L);
lambda = 5 * x * w' + randn(T * Fs, M) * sigma - 7;
y = exp(lambda) > rand(T * Fs, M);
[t, assignments] = find(y);
t = t / Fs * 1000;
for i = 1 : M
    ndx = find(assignments == i);
    del = diff(t(ndx)) < 1;
    t(ndx(del)) = [];
    assignments(ndx(del)) = [];
end
[t, order] = sort(t);
assignments = assignments(order);
ampl = 1 + randn(size(t)) / 20;


%% generate some waveforms
rng(2)
spike = [0 10 18 10 -25 -60 -35 -11 0 7 10 12 13 13 12 10 7 3 1 0]';
K = 12;
locx = [0 1 0 1 0 1 0 1 0 1 0 1] * 0.9;
locy = 0 : 0.5 : 5.5;
px = rand(M, 1);
py = sort(rand(M, 1) * (locy(end) - 2)) + 1;
sdx = 0.2 + rand(M, 1) * 0.3;
sdy = 1 + randn(M, 1) * 0.2;

dx = bsxfun(@rdivide, bsxfun(@minus, locx, px) .^ 2, sdx .^ 2);
dy = bsxfun(@rdivide, bsxfun(@minus, locy, py) .^ 2, sdy .^ 2);
a = exp(-0.5 * (dx + dy));
W = bsxfun(@times, spike, permute(a, [3 2 1]));

B = 8;
drift = exp(randn(M, 1) * 0.4 * linspace(-1, 1, B));
drift = permute(drift, [3 4 1 2]);
W = bsxfun(@times, W, drift);


%% open CCG and spike time views
ccg = correlogram(t, assignments, M, 0.2, 10);
ccgView = MCorrelogramView;
ccgView.setCCG(ccg)
ccgView.resize(600, 400)

spikeView = MSpikeTimeView;
spikeView.setSpikes(t, ampl, assignments)
spikeView.resize(600, 400)

waveView = MWaveformView;
waveView.setChannelLayout(locx, locy)
waveView.setWaveforms(W)
waveView.setPadding(4)
waveView.setSpacing(75)
waveView.setColorScheme(HSVColorScheme)

sel = 2:5;
ccgView.setSelected(sel)
spikeView.setSelected(sel)
waveView.setSelected(sel)

