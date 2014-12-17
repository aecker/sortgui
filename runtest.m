bps = BPSorter('V1x32-Poly2', ...
    'TempDir', '/kyb/agmbrecordings/tmp/Charles/2014-07-21_13-50-16', ...
    'Debug', true, ...
    'Verbose', true, ...
    'MaxSamples', 5e6, ...
    'BlockSize', 5 * 60, ...
    'FullIter', 0, ...
    'pruningRadius', 55, ...
    'waveformBasis', getfield(load('B'), 'B'), ...
    'samples', -12 : 24, ...
    'logging', true, ...
    'mergeThreshold', 0.85, ...
    'pruningThreshold', 1.5, ...
    'driftRate', 0.005);
bps.readData();


%%
% file = '/kyb/agmbrecordings/Dennis/2014-10-31_13-50-33/bpsort';
file = '/kyb/agmbrecordings/Dennis/2014-12-10_14-21-21/bpsort';

load(fullfile(file, 'results'), 'bps')


%%
results = load(fullfile(bps.TempDir, 'results'));
% results = load(fullfile(bps.TempDir, 'iter01'));
ndx = find(results.X);
ampl = real(results.X(ndx));
[t, assignments] = ind2sub(size(results.X), ndx);
t = t + imag(results.X(ndx));
[t, order] = sort(t / bps.Fs * 1000);

assignments = assignments(order);
ampl = ampl(order);

W = bps.waveforms(results.Uw);
layout = bps.layout;
order = layout.channelOrder('yx');
channelLayout = [layout.x(order) > 1, layout.y(order) / 50];
W = W(:, order, :, :);

[groupings, su] = SortGUI.open(t, assignments, ampl, W, channelLayout);

