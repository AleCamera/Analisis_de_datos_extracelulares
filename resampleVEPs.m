function rsVEPs = resampleVEPs(VEPs, nf, of)
%toma un set de VEPs con frequencia de sampleo "of" y los resamplea a "nf"
for tr = 1:length(VEPs)
    rsVEPs(tr).stim = VEPs(tr).stim;
    if isempty(VEPs(tr).traces)
        rsVEPs(tr).traces = [];
    else
        rsVEPs(tr).traces = resample(VEPs(tr).traces, nf, of);
    end
end
end