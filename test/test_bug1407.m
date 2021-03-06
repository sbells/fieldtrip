function test_bug1407

% MEM 1500mb
% WALLTIME 00:05:16

% TEST test_bug1407
% TEST ft_read_header ft_read_data ft_read_event

% the following are from the fieldtrip/external/egi directory
% TEST read_mff_header read_mff_data read_mff_event mff_getEEGFilename mff_getSummaryInfo mff_getObject mff_micros2Sample

ft_hastoolbox('egi_mff', 1);

if ispc
    datadir = 'H:/common/matlab/fieldtrip/data/test/bug1407';
else
    datadir = '/home/common/matlab/fieldtrip/data/test/bug1407';
end

dataset = {
    fullfile(datadir, 'Long64ChannelWithEvents.mff')
    fullfile(datadir, 'NS1000sps.mff')
    fullfile(datadir, 'NS500Sine6Hz.mff')
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test to see whether the file format can be detected in case the mff prefix has been removed
dir1 = fullfile(datadir, 'NS1000sps.mff');
dir2 = fullfile(datadir, 'NS1000sps');
assert(isequal(ft_filetype(dir1), ft_filetype(dir2)));

dir1 = fullfile(datadir, 'NS1000sps.mff', 'info.xml');
dir2 = fullfile(datadir, 'NS1000sps',     'info.xml');
assert(isequal(ft_filetype(dir1), ft_filetype(dir2)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
headerformat = 'egi_mff_v1';
dataformat   = 'egi_mff_v1';
eventformat  = 'egi_mff_v1';

for i=1:length(dataset)
    hdr   = ft_read_header(dataset{i}, 'headerformat', headerformat);
    dat   = ft_read_data(dataset{i},   'headerformat', headerformat, 'dataformat', dataformat);
    event = ft_read_event(dataset{i},  'headerformat', headerformat, 'eventformat', eventformat);
    assert(size(dat,1)==length(hdr.label));
    assert(size(dat,2)==hdr.nSamples*hdr.nTrials);
    % keep all results to compare v1 and v2
    v1_hdr{i} = hdr;
    v1_dat{i} = dat;
    v1_evt{i} = event;
end

% the purpose for the following code is try ensure that the v1 implementation does not break
% these numbers are hardcoded for the datasets defined above
assert(v1_hdr{1}.nSamples*v1_hdr{1}.nTrials==3087,  'incorrect number of samples')
assert(v1_hdr{2}.nSamples*v1_hdr{2}.nTrials==60660, 'incorrect number of samples')
assert(v1_hdr{3}.nSamples*v1_hdr{3}.nTrials==77113, 'incorrect number of samples')
assert(v1_hdr{1}.nChans==65,   'incorrect number of samples')
assert(v1_hdr{2}.nChans==257,  'incorrect number of samples')
assert(v1_hdr{3}.nChans==257,  'incorrect number of samples')
assert(v1_evt{1}(1)  .sample==49,   'incorrect event sample');
assert(v1_evt{1}(end).sample==2966, 'incorrect event sample');
assert(v1_evt{2}(1)  .sample==1099, 'incorrect event sample'); % there is only a calibration event
assert(v1_evt{2}(end).sample==1099, 'incorrect event sample'); % there is only a calibration event
assert(v1_evt{3}(1)  .sample==1050, 'incorrect event sample'); % there is only a calibration event
assert(v1_evt{3}(end).sample==1050, 'incorrect event sample'); % there is only a calibration event

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
headerformat = 'egi_mff_v2';
dataformat   = 'egi_mff_v2';
eventformat  = 'egi_mff_v2';

for i=1:length(dataset)
    hdr   = ft_read_header(dataset{i}, 'headerformat', headerformat);
    dat   = ft_read_data(dataset{i},   'headerformat', headerformat, 'dataformat', dataformat);
    event = ft_read_event(dataset{i},  'headerformat', headerformat, 'eventformat', eventformat);
    assert(size(dat,1)==length(hdr.label));
    assert(size(dat,2)==hdr.nSamples*hdr.nTrials);
    % keep all results to compare v1 and v2
    v2_hdr{i} = hdr;
    v2_dat{i} = dat;
    v2_evt{i} = event;
end

% compare the v1 results to the v2 results
for i=1:length(dataset)
    fprintf('comparing v1 and v2 for dataset %d\n', i);
    assert(isequal(v1_hdr{i}.Fs,          v2_hdr{i}.Fs)           , 'difference in hdr.Fs');
    assert(isequal(v1_hdr{i}.nChans,      v2_hdr{i}.nChans)       , 'difference in hdr.nChans');
    assert(isequal(v1_hdr{i}.nSamples,    v2_hdr{i}.nSamples)     , 'difference in hdr.nSamples');
    assert(isequal(v1_hdr{i}.nSamplesPre, v2_hdr{i}.nSamplesPre)  , 'difference in hdr.nSamplesPre');
    assert(isequal(v1_hdr{i}.nTrials,     v2_hdr{i}.nTrials)      , 'difference in hdr.nTrials');
    assert(isequal(v1_hdr{i}.label,       v2_hdr{i}.label)        , 'difference in hdr.label'); % this fails in revision 5979
    assert(isequal(v1_dat{i},  v2_dat{i})      , 'difference in data');
    assert(isequal(v1_evt{i},  v2_evt{i})      , 'difference in events'); % this fails in revision 5979
end
