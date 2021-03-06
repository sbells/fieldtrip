function test_bug103

% MEM 1500mb
% WALLTIME 00:03:04

% TEST test_bug103
% TEST ft_singleplotER

freq.freq       = 1:1:100;
freq.powspctrm  = randn(size(freq.freq)).^2;
freq.label      = {'chan1'};
freq.dimord     = 'chan_freq';

save test_bug103.mat freq

cfg = [];
figure; ft_singleplotER(cfg, freq);


% the following does not work on purpose, because plotting does not work with cfg.inputfile
%cfg = [];
%cfg.inputfile = 'test_bug103.mat';
%figure; ft_singleplotER(cfg);
