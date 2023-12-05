function [meanRespIndex, errRespIndex] = calculateResponseIndex(nSpkPre, nSpkDuring)
if length(nSpkPre) ~= length(nSpkDuring)
    error('No hay el mismo numero de trials en la frecuencia pre y post')
end

%si no hay spikes  salgo de la función
if nSpkDuring + nSpkPre == 0
    meanRespIndex = [];
    errRespIndex = [];
    return
else
    respIndex = zeros(1,length(nSpkPre));
for trial = 1:length(nSpkPre)
    respIndex(trial) = (nSpkDuring(trial) - nSpkPre(trial)) / (nSpkDuring(trial) + nSpkPre(trial));
end
    meanRespIndex = mean(respIndex);
    errRespIndex = std(respIndex)/sqrt(length(nSpkPre));
end