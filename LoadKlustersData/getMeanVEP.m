function trace = getMeanVEP(trialVEPs, stim)

for s = 1:length(trialVEPs)
    if trialVEPs(s).stim == stim
        trace = mean(trialVEPs(s).traces, 2);
        return+
    end
end
trace = [];
end