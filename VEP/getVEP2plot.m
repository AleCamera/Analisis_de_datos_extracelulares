function [time, VEP] = getVEP2plot(reg, stim, varargin)
useMean = false;

for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'mean'
            useMean = varargin{arg+1};
        otherwise
            disp(['"', varargin{arg}, '" is not a valid argument'])
    end
end

for s = 1:length(reg.VEPs)
    if reg.VEPs(s).stim == stim
        break
    elseif s == length(reg.VEPs)
        disp(['stim ', num2str(stim), ' not found'])
        time = [];
        VEP = [];
        return
    end
end

VEP = reg.VEPs(s).traces;
if useMean
    VEP = mean(VEP, 2);
end

time = 0:1/reg.sampleRate:(length(VEP)-1) / reg.sampleRate;
time = time - 10;


end
