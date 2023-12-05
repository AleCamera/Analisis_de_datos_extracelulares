function stdErrFreq = getPSHstdErr(raster, index, nBins, tPre, tPost, varargin)

smoothPSH = false;
span = 5;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'smooth'
            smoothPSH = varargin{arg+1};
        case 'span'
            span = varargin{arg+1};
    end
end

trialFreqs = zeros(nBins, max(index));
for trial = 1:max(index)
    if ~isempty(raster(index == trial))
        [trialFreqs(:,trial),~] = SyncHist(raster(index == trial), index(index==trial),'mode', ...
            'mean' ,'durations', [-tPre; tPost], 'nBins', nBins);
        if smoothPSH
            trialFreqs(:,trial) = smooth(trialFreqs(:,trial), span);
        end
    else
        trialFreqs(:,trial) = 0;
    end
end
stdFreq = zeros(nBins,1);
for bin = 1:nBins
    stdFreq(bin) = std(trialFreqs(bin, :));
end
stdErrFreq = stdFreq / sqrt(max(index));